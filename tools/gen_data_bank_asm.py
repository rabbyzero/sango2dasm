#!/usr/bin/env python3
"""Render the new-game seed banks (PRG $10 / $11) as annotated .byte sources.

Both banks are pure data (see code/initial_data_tables.md). Instead of a blind
`.incbin`, this tool writes every analysed table region as labelled `.byte`
records with the decoded meaning in the comment, and keeps the not-yet-analysed
gaps as sliced includes, so the bank still reproduces the ROM byte-for-byte:

    .incbin "rom/prg/prg_10.bin", $0000, $0C00   ; not analysed yet
    ProvinceRecord_RYOUTOU:                       ; id  0  リョウトウ 遼東
      .byte $01, $00, $A0, $00, $F0, $00, $96, $00   ; 国=1 金=160 米=240 人口=150

Record labels come from the authoritative id equates in include/officer_ids.inc
and include/province_ids.inc, so a label in the assembly, a symbol used by code
and a CSV row always name the same officer or province.

Two sources for the record bytes:

  default     read them straight from rom/prg/prg_XX.bin (the stock ROM)
  --from-csv  rebuild them from the decoded columns of docs/officer_data.csv /
              docs/province_data.csv, i.e. edit the CSV, regenerate the
              assembly. tools/verify_data_banks.py then reports the drift from
              the stock ROM in human terms (which record, which field, old ->
              new), so the CSV is the comfortable editing surface and the .byte
              listing is the readable in-tree rendering.

Usage:
    python tools/gen_data_bank_asm.py --bank all                # preview
    python tools/gen_data_bank_asm.py --bank all --write        # update asm/banks
    python tools/gen_data_bank_asm.py --bank 11 --from-csv --write
"""
import argparse
import csv
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from charmap_kana import decode_name                # noqa: E402
import extract_officer_data as officer_tool         # noqa: E402
import extract_province_data as province_tool       # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK_DIR = os.path.join(ROOT, 'rom', 'prg')
ASM_DIR = os.path.join(ROOT, 'asm', 'banks')
DOCS = os.path.join(ROOT, 'docs')

BANK_SIZE = 0x2000
WINDOW_CPU = 0x8000          # both banks are only ever mapped into $8000-$9FFF

# --- analysed regions (CPU addresses inside the window) ------------------
PROV_RECORD_CPU = province_tool.DATA_TABLE_ADDR      # $8C00
PROV_RECORD_STRIDE = province_tool.RECORD_SIZE       # 32
PROV_COUNT = province_tool.PROVINCE_COUNT            # 30
PROV_NAME_CPU = province_tool.NAME_TABLE_ADDR        # $9A1A
PROV_NAME_STRIDE = province_tool.NAME_ENTRY_SIZE     # 8

OFF_RECORD_CPU = 0x8000                              # bank $31 base
OFF_RECORD_STRIDE = officer_tool.DATA_STRIDE         # 12
OFF_RECORD_COUNT = officer_tool.OFFICER_COUNT        # 237
OFF_RECORD_SLOTS = officer_tool.SRAM_COPY_SLOTS      # 240 (3 padding)
OFF_NAME_CPU = 0x901A
OFF_NAME_STRIDE = officer_tool.NAME_STRIDE           # 10

ARRIVAL_CPU = 0x8B1C                                 # bank $31
TRADE_CPU = 0x8FC0                    # bank $10: per-province 町 rate pairs + facility flags
TRADE_PRICE_BYTES = PROV_COUNT * 2    # $8FC0-$8FFB rice rate byte pairs
TRADE_FLAG_BYTES = PROV_COUNT         # $8FFC-$9019 province facility flags
ARRIVAL_STRIDE = 0x14
ARRIVAL_PAIRS = 10
YEAR_BASE = 0xBD                                     # $BD = 189
DEATH_CPU = 0x9C58                                   # bank $31
DEATH_COUNT = officer_tool.OFFICER_COUNT
DEATH_YEAR_OFFSET = 100                              # byte = death year - 100

# Bank $10 $8000-$8BFF: three full PPU screens (960 tile bytes + 64 attribute
# bytes each), i.e. the game's pre-baked background nametables.
SCREEN_CPU = 0x8000
SCREEN_COUNT = 3
SCREEN_SIZE = 0x400
SCREEN_ROWS = 30                     # tile rows (8 px each)
SCREEN_COLS = 32                     # tile columns
ATTR_ROWS = 8                        # attribute rows (4x4 tiles each)
ATTR_COLS = 8

# Per 8-byte chunk of a province record, for the inline comment.
PROV_CHUNK_FIELDS = [
    '国 country / - / 金 gold / 米 rice / 人口 population/100',
    '土地 land / 防災 disaster / 統治 governance / 控え reserve / 産業 industry',
    '宝 treasure / 武将 roster slots 0-6',
    '武将 roster slots 7-9 / 反乱 cooldown / unused x4',
]
STATUS_NAMES = officer_tool.OFFICER_STATUS
AFFINITY_NAMES = officer_tool.ARMY_AFFINITY

# Filled by init_names(): id -> label / Chinese name, from include/*.inc and
# docs/officer_data.csv.
OFF_LABELS, PROV_LABELS, OFF_ZH = {}, {}, {}


def init_names():
    OFF_LABELS.update(load_labels('officer_ids.inc', 'OFFICER_'))
    PROV_LABELS.update(load_labels('province_ids.inc', 'PROVINCE_'))
    rows = officer_tool.load_rows(os.path.join(
        ROOT, 'Sangokushi 2 - Haou no Tairiku (J).nes'))[0]
    OFF_ZH.update({r['id']: r['zh_hans'] for r in rows})
    return rows


def read_bank(bank):
    path = os.path.join(BANK_DIR, 'prg_%02x.bin' % bank)
    with open(path, 'rb') as f:
        data = f.read()
    if len(data) != BANK_SIZE:
        raise SystemExit('%s: %d bytes, expected %d' % (path, len(data), BANK_SIZE))
    return data


def load_labels(inc_name, prefix):
    """`NAME = id ; comment` lines -> {id: NAME minus the prefix}."""
    path = os.path.join(ROOT, 'include', inc_name)
    out = {}
    with open(path, encoding='utf-8') as f:
        for line in f:
            m = re.match(r'^%s([A-Z0-9_]+)\s*=\s*(\d+)' % re.escape(prefix), line)
            if m:
                out[int(m.group(2))] = m.group(1)
    return out


def byte_list(data):
    return ', '.join('$%02X' % b for b in data)


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def load_officers(from_csv, rom_rows):
    """Officer rows with label, raw name bytes and the record bytes to emit."""
    rows = []
    for row in rom_rows:
        label = OFF_LABELS.get(row['id'])
        if label is None:
            raise SystemExit('no OFFICER_ label for id %d in include/officer_ids.inc'
                             % row['id'])
        out = dict(row)
        out['label'] = label
        if from_csv:
            out['record'] = officer_record_from_fields(row)
        else:
            out['record'] = bytes.fromhex(row['hex'])
        rows.append(out)
    return rows


def load_officer_csv_rows():
    path = os.path.join(DOCS, 'officer_data.csv')
    with open(path, newline='', encoding='utf-8') as f:
        return [{**r, **{k: int(r[k]) for k in INT_OFFICER_COLS if r[k] != ''}}
                for r in csv.DictReader(f)]


INT_OFFICER_COLS = ['id', 'vitality', 'might', 'intelligence', 'loyalty',
                    'virtue', 'officer_level', 'experience', 'troop_count',
                    'weapon_index', 'armor_index', 'army_affinity_bits',
                    'officer_status_bits']

PROV_CSV_INT = ('country_id', 'gold', 'rice', 'population', 'land_value',
                'industry', 'disaster_prevention', 'governance',
                'reserve_troops', 'treasure')

NES_PATH = os.path.join(ROOT, 'Sangokushi 2 - Haou no Tairiku (J).nes')
PRG_COMBINED = os.path.join(ROOT, 'rom', 'prg_combined.bin')


def officer_record_from_fields(row):
    """Rebuild 12 record bytes from decoded CSV columns (+5 stays 0)."""
    return bytes([
        row['vitality'], row['might'], row['intelligence'], row['loyalty'],
        row['virtue'], 0,
        row['experience'] & 0xFF, (row['experience'] >> 8) & 0xFF,
        row['troop_count'] & 0xFF, (row['troop_count'] >> 8) & 0xFF,
        (row['armor_index'] << 5) | row['weapon_index'],
        ((row['officer_level'] - 1) << 4)
        | (row['army_affinity_bits'] << 2) | row['officer_status_bits'],
    ])


def load_provinces(from_csv, rom_rows):
    rows = []
    for row in rom_rows:
        label = PROV_LABELS.get(row['id'])
        if label is None:
            raise SystemExit('no PROVINCE_ label for id %d in province_ids.inc'
                             % row['id'])
        out = dict(row)
        out['label'] = label
        out['name_bytes'] = bytes.fromhex(row['name_hex']).ljust(
            PROV_NAME_STRIDE, b'\x00')[:PROV_NAME_STRIDE]
        if from_csv:
            out['record'] = province_record_from_fields(row)
        else:
            out['record'] = bytes.fromhex(row['hex'])
        rows.append(out)
    return rows


def province_record_from_fields(row):
    """Rebuild 32 record bytes from decoded CSV columns."""
    rec = bytearray(PROV_RECORD_STRIDE)
    rec[0x00] = row['country_id'] & 0x0F
    write16(rec, 0x02, row['gold'])
    write16(rec, 0x04, row['rice'])
    write16(rec, 0x06, row['population'] // province_tool.POPULATION_SCALE)
    write16(rec, 0x08, row['land_value'])
    rec[0x0A] = row['disaster_prevention']
    rec[0x0B] = row['governance']
    write16(rec, 0x0C, row['reserve_troops'])
    write16(rec, 0x0E, row['industry'])
    rec[0x10] = row['treasure']
    for slot in range(province_tool.ROSTER_SLOTS):
        rec[province_tool.ROSTER_START + slot] = 0xFF
    for slot, oid in enumerate(row['roster']):
        rec[province_tool.ROSTER_START + slot] = oid
    return bytes(rec)


def write16(rec, ofs, value):
    rec[ofs] = value & 0xFF
    rec[ofs + 1] = (value >> 8) & 0xFF


def load_death_years(bank_bytes):
    """[{byte, year, short}] for the 237 ids, read from the ROM bank."""
    rows = []
    for oid in range(DEATH_COUNT):
        raw = bank_bytes[DEATH_CPU - WINDOW_CPU + oid]
        rows.append({'byte': raw, 'year': raw + DEATH_YEAR_OFFSET,
                     'short': OFF_ZH.get(oid, '?')})
    return rows


def load_schedule(officers):
    """province id -> [(officer id, year)]; blank/None columns mean no entry."""
    per_province = {p: [] for p in range(PROV_COUNT)}
    for row in officers:
        pid, year = row['schedule_province_id'], row['appear_year']
        if pid in (None, '') or year in (None, ''):
            continue
        per_province[int(pid)].append((int(row['id']), int(year)))
    for pid in per_province:
        per_province[pid].sort(key=lambda pair: (pair[1], pair[0]))
    return per_province


# ---------------------------------------------------------------------------
# Emitters
# ---------------------------------------------------------------------------

def emit_gap(out, bank, start_off, end_off):
    if start_off >= end_off:
        return
    out.append('; ' + '-' * 78)
    out.append('; $%04X-$%04X (%d bytes): NOT ANALYSED - raw slice of'
               % (WINDOW_CPU + start_off, WINDOW_CPU + end_off - 1,
                  end_off - start_off))
    out.append('; rom/prg/prg_%02x.bin, so this bank always reproduces the ROM.'
               % bank)
    out.append('; Verify with: python tools/verify_data_banks.py --bank %02x' % bank)
    out.append('.incbin "rom/prg/prg_%02x.bin", $%04X, $%04X'
               % (bank, start_off, end_off - start_off))
    out.append('')


def emit_province_records(out, rows):
    end = PROV_RECORD_CPU + PROV_COUNT * PROV_RECORD_STRIDE
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Province master records: %d x %d bytes'
               % (PROV_RECORD_CPU, end - 1, PROV_COUNT, PROV_RECORD_STRIDE))
    out.append('; Seed of SRAM $6000. SramInit @Copy1Loop ($DDED) copies exactly')
    out.append('; $%03X bytes from bank $30 $%04X, i.e. all %d records, no padding.'
               % (PROV_COUNT * PROV_RECORD_STRIDE, PROV_RECORD_CPU, PROV_COUNT))
    out.append('; Reader: B1F_GetProvinceRecordAddr ($F2AF) = id*%d + $6000.'
               % PROV_RECORD_STRIDE)
    out.append('; Field map (16-bit LE): +00 所属国 Country (low nibble, 7=空白地)')
    out.append(';   +01 unused  +02 金 Gold  +04 米 Rice  +06 人口 Population/100')
    out.append(';   +08 土地 LandValue  +0A 防災 DisasterPrevention  +0B 統治 Governance')
    out.append(';   +0C 控え ReserveTroops  +0E 産業 Industry  +10 宝 Treasure')
    out.append(';   +11..+1A 武将 roster (10 ids, $FF=empty)  +1B 反乱 cooldown')
    out.append(';   +1C..+1F unused. Evidence: docs/province_data.md')
    out.append('; ' + '=' * 78)
    out.append('ProvinceRecordTable:')
    out.append('')
    for row in rows:
        out.append('; %s' % province_summary(row))
        out.append('ProvinceRecord_%s:' % row['label'])
        for n in range(PROV_RECORD_STRIDE // 8):
            chunk = row['record'][n * 8:(n + 1) * 8]
            out.append('  .byte %-34s ; $%04X %s'
                       % (byte_list(chunk), PROV_RECORD_CPU
                          + row['id'] * PROV_RECORD_STRIDE + n * 8,
                          PROV_CHUNK_FIELDS[n]))
        out.append('')


def emit_province_trade(out, data, rows):
    """$8FC0-$9019: the two parallel per-province trade/facility tables."""
    base = TRADE_CPU - WINDOW_CPU
    price_end = TRADE_CPU + TRADE_PRICE_BYTES - 1
    flag_cpu = TRADE_CPU + TRADE_PRICE_BYTES

    def cleared(bit):
        return ', '.join(str(r['id']) for r in rows
                         if not data[base + TRADE_PRICE_BYTES + r['id']] & bit)

    def facility_names(byte):
        bits = {0: '兵', 1: '学', 2: '町', 3: '募'}
        return ''.join(bits[b] if byte >> b & 1 else '-' for b in range(4))

    def prov_kanji(row):
        return row['kanji'].get('zh_hans', row['katakana'])

    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Province trade rates + facility flags: two parallel'
               % (TRADE_CPU, flag_cpu + TRADE_FLAG_BYTES - 1))
    out.append('; %d-entry rows, one per province id. Both are read only through the'
               % PROV_COUNT)
    out.append('; $8000 window after switching in bank $30 (B1F_SwitchBank8_A/B).')
    out.append(';')
    out.append(';   $%04X-$%04X  ProvinceRiceTradeRateTable: 2 rate bytes per' % (TRADE_CPU, price_end))
    out.append(';       province (the game always reads the two rates at consecutive')
    out.append(';       addresses, so they are stored as bytes rather than words):')
    out.append(';       +0 = rate used by the market BUY RICE leg (gold = rice*100/rate,')
    out.append(';           @RiceBuySeed prg_1b_1c $C254; the pair is also the action')
    out.append(';           parameter record of the war-layer buy/sell panel, State 0')
    out.append(';           prg_08_09 $C129 dereferences ($02) = id*2 + $%04X),' % TRADE_CPU)
    out.append(';       +1 = rice per 100 gold for the SELL legs (SellSurplusRice')
    out.append(';           prg_0a_0b $CC9E, Action_BuyRice rice cost prg_08_09 $A457).')
    out.append(';       Provinces with no 町 rice trade hold $00, $00; every (+0, +1)')
    out.append(';       pair matches the sell/buy rate columns of docs/rice_prices.csv.')
    out.append(';   $%04X-$%04X  ProvinceFacilityFlags: one flag byte per province' % (flag_cpu, flag_cpu + TRADE_FLAG_BYTES - 1))
    out.append(';       (initial-value seed) - province facility flags behind the town')
    out.append(';       commands. The town screen menu layout comes from a separate table')
    out.append(';       pair (@TownFacilitySetTable/@FacilityActionCodeTable prg_1b_1c')
    out.append(';       $C025/$C10E, action codes 0=兵器工房 armory, 1=学校 academy,')
    out.append(';       2=医院 hospital, 3=町 market); these bits gate the individual')
    out.append(';       commands, so they are not a bijection onto those 4 codes.')
    out.append(';       Per-row comments list the flags as 兵 facility bit0 / 学 bit1 /')
    out.append(';       町 bit2 / 募 bit3, `-` = clear.')
    out.append(';       Consumers test one bit each:')
    out.append(';       bit0 = gate for the war-AI action loop (@AiAction_')
    out.append(';              EvaluateAndExecute prg_0a_0b $C33F AND #$01 - clear => skip')
    out.append(';              to the next province). Clear: %s.' % cleared(1))
    out.append(';       bit1 = additional town-command facility flag (not yet tied to a')
    out.append(';              named command; overlaps but is not contained in bit2).')
    out.append(';              Clear: %s.' % cleared(2))
    out.append(';       bit2 = has a working 町 rice market - the 23 provinces whose rate')
    out.append(';              pair is non-zero (docs/rice_prices.csv has_market matches')
    out.append(';              this bit exactly). Also gates the AI sell path')
    out.append(';              (SellSurplusRice prg_0a_0b $CC45 AND #$04).')
    out.append(';              Clear: %s.' % cleared(4))
    out.append(';       bit3 = recruit/transfer eligible (@CheckEligibility prg_0a_0b')
    out.append(';              $C872 AND #$08, together with the <10 subordinate count; the')
    out.append(';              $C7F1 dispatch routes on the same bit). Clear on exactly')
    out.append(';              the seven ruler capitals. Clear: %s.' % cleared(8))
    out.append('; ' + '=' * 78)
    out.append('ProvinceRiceTradeRateTable:')
    for n in range(0, PROV_COUNT, 4):
        last = min(n + 4, PROV_COUNT)
        chunk = data[base + n * 2:base + last * 2]
        rates = ', '.join('%s sell %d buy %d'
                          % (prov_kanji(rows[i]),
                             data[base + i * 2], data[base + i * 2 + 1])
                          for i in range(n, last))
        out.append('  .byte %-39s ; $%04X id %2d-%2d %s'
                   % (byte_list(chunk), TRADE_CPU + n * 2, n, last - 1, rates))
    out.append('')
    out.append('ProvinceFacilityFlags:')
    for n in range(0, PROV_COUNT, 8):
        last = min(n + 8, PROV_COUNT)
        chunk = data[base + TRADE_PRICE_BYTES + n:base + TRADE_PRICE_BYTES + last]
        names = ' '.join('%s=%s' % (prov_kanji(rows[i]),
                                    facility_names(data[base + TRADE_PRICE_BYTES + i]))
                         for i in range(n, last))
        out.append('  .byte %-39s ; $%04X id %2d-%2d %s'
                   % (byte_list(chunk), flag_cpu + n, n, last - 1, names))
    out.append('')


def province_summary(row):
    k = row['kanji']
    ruler = row['ruler_officer_id']
    ruler_txt = 'ruler=%s (%s)' % (
        OFF_ZH.get(ruler, '?'), OFF_LABELS.get(ruler, '?')) if ruler is not None \
        else 'no ruler'
    roster = ' '.join(str(o) for o in row['roster']) or 'empty'
    return ('id %2d %s %s (%s) | 国=%d %s | 金=%d 米=%d 人口=%d 土地=%d 産業=%d'
            ' 防災=%d 統治=%d 控え=%d 宝=%d | 現役=%d | 武将[%s]'
            % (row['id'], row['katakana'], k.get('zh_hans', ''), row['romaji'],
               row['country_id'], ruler_txt, row['gold'], row['rice'],
               row['population'], row['land_value'], row['industry'],
               row['disaster_prevention'], row['governance'],
               row['reserve_troops'], row['treasure'], row['active_troops'],
               roster))


def emit_province_names(out, rows):
    end = PROV_NAME_CPU + PROV_COUNT * PROV_NAME_STRIDE
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Province katakana names: %d x %d bytes, $00-terminated'
               % (PROV_NAME_CPU, end - 1, PROV_COUNT, PROV_NAME_STRIDE))
    out.append('; Reader: CmdDrawNameFromData ($A426) = id*%d + $%04X, up to 6 glyphs.'
               % (PROV_NAME_STRIDE, PROV_NAME_CPU))
    out.append('; Code space: tools/charmap_kana.py ($04=ア .. $31=ン, $35-$38=ャュョッ,')
    out.append('; $39/$3A = postfix ゛/゜). Names/translations: docs/province_names.csv')
    out.append('; ' + '=' * 78)
    out.append('ProvinceNameTable:')
    out.append('')
    for row in rows:
        out.append('ProvinceName_%s: .byte %-34s ; $%04X id %2d  %s %s (%s)'
                   % (row['label'], byte_list(row['name_bytes']),
                      PROV_NAME_CPU + row['id'] * PROV_NAME_STRIDE, row['id'],
                      row['katakana'], row['kanji'].get('zh_hans', ''),
                      row['romaji']))
    out.append('')


def emit_officer_names(out, rows, slots):
    end = OFF_NAME_CPU + OFF_RECORD_COUNT * OFF_NAME_STRIDE
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Officer katakana names: %d real x %d bytes, $00-terminated'
               % (OFF_NAME_CPU, end - 1, OFF_RECORD_COUNT, OFF_NAME_STRIDE))
    out.append('; %d slots are addressable; slots $ED-$EF are blank padding, matching'
               % slots)
    out.append('; the officer record array. Reader: GetNameDisplayScale ($F308) =')
    out.append('; id*%d + $%04X. Kanji/Chinese/pinyin: docs/officer_names_kanji.csv.'
               % (OFF_NAME_STRIDE, OFF_NAME_CPU))
    out.append('; ' + '=' * 78)
    out.append('OfficerNameTable:')
    out.append('')
    for row in rows:
        out.append('OfficerName_%s: .byte %-44s ; $%04X id %3d %s %s'
                   % (row['label'], byte_list(row['name_bytes']),
                      OFF_NAME_CPU + row['id'] * OFF_NAME_STRIDE, row['id'],
                      row['katakana'], row['zh_hans']))
    for slot in range(OFF_RECORD_COUNT, slots):
        out.append('OfficerName_Unused_%d: .byte %-44s ; $%04X slot $%02X padding'
                   % (slot, byte_list(b'\x00' * OFF_NAME_STRIDE),
                      OFF_NAME_CPU + slot * OFF_NAME_STRIDE, slot))
    out.append('')


def emit_officer_records(out, rows, slots):
    end = OFF_RECORD_CPU + OFF_RECORD_COUNT * OFF_RECORD_STRIDE
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Officer master records: %d real x %d bytes'
               % (OFF_RECORD_CPU, end - 1, OFF_RECORD_COUNT, OFF_RECORD_STRIDE))
    out.append('; Seed of SRAM $63C0. SramInit @Copy2Loop ($DE32) copies $%03X bytes'
               % officer_tool.SRAM_COPY_BYTES)
    out.append('; = %d slots, so slots $ED-$EF are padding that overlaps the arrival'
               % slots)
    out.append('; schedule below; no loop reads them (officer scans stop at CMP #$ED).')
    out.append('; Readers: B1F_GetOfficerRecordAddr ($F2D7) SRAM,'
               ' B1F_GetOfficerRomRecordAddr')
    out.append('; ($F387) maps bank $31 and reads id*%d + $%04X directly.'
               % (OFF_RECORD_STRIDE, OFF_RECORD_CPU))
    out.append('; Field map: +00 体力 Vitality +01 武力 Might +02 知力 Intelligence')
    out.append(';   +03 忠誠度 Loyalty (100 = playable ruler) +04 人徳 Virtue')
    out.append(';   +05 位置 LocationProvince (0 in ROM)  +06/+07 経験値 Experience')
    out.append(';   +08/+09 兵数 TroopCount  +0A 武器 bits0-4 / 防具 bits5-7')
    out.append(';   +0B レベル bits4-7 (0-based) | 軍の属性 bits2-3 (0平 1山 2水) |')
    out.append(';      状態 bits0-1 (0在野 1hidden 2rostered 3out of action; seed 1/2).')
    out.append('; Evidence: docs/officer_data.md, code/initial_data_tables.md')
    out.append('; ' + '=' * 78)
    out.append('OfficerRecordTable:')
    out.append('')
    for row in rows:
        out.append('OfficerRecord_%s: .byte %-66s ; $%04X %s'
                   % (row['label'], byte_list(row['record']),
                      OFF_RECORD_CPU + row['id'] * OFF_RECORD_STRIDE,
                      officer_summary(row)))
    out.append('; --- slots $ED-$EF (offsets $%04X-$%04X) are the padding the copy'
               % (OFF_RECORD_CPU + OFF_RECORD_COUNT * OFF_RECORD_STRIDE,
                  OFF_RECORD_CPU + OFF_RECORD_SLOTS * OFF_RECORD_STRIDE - 1))
    out.append(';     window reaches past record 236; those %d bytes are physically'
               % ((OFF_RECORD_SLOTS - OFF_RECORD_COUNT) * OFF_RECORD_STRIDE))
    out.append(';     the head of ArrivalScheduleTable below, so they are emitted')
    out.append(';     there and not duplicated as officer records. ---')
    out.append('')


def officer_summary(row):
    bits = row['army_affinity_bits'] << 2 | row['officer_status_bits']
    return ('id %3d %s %s 体%d 武%d 知%d 忠%d 徳%d Lv%d 経験%d 兵%d | %s軍 %s | '
            '%s/%s (+0B=$%02X)'
            % (row['id'], row['katakana'], row['zh_hans'], row['vitality'],
               row['might'], row['intelligence'], row['loyalty'], row['virtue'],
               row['officer_level'], row['experience'], row['troop_count'],
               AFFINITY_NAMES.get(row['army_affinity_bits'], '?'),
               STATUS_NAMES.get(row['officer_status_bits'], '?'),
               row['weapon'], row['armor'], bits))


def emit_arrival_schedule(out, schedule, provinces):
    end = ARRIVAL_CPU + PROV_COUNT * ARRIVAL_STRIDE
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Officer arrival schedule: %d Province blocks x $%02X'
               % (ARRIVAL_CPU, end - 1, PROV_COUNT, ARRIVAL_STRIDE))
    out.append('; Up to %d (officer id, appear year) pairs per block, $FF $FF padded to'
               % ARRIVAL_PAIRS)
    out.append('; the block end. Year is plain binary ($BD=189 .. $D2=210) and ascends')
    out.append('; inside a block. Reader: OfficerArrivalScan ($B964, prg_19_1a.asm) =')
    out.append('; $%04X + province*$%02X. These ids are exactly the officers whose seed'
               % (ARRIVAL_CPU, ARRIVAL_STRIDE))
    out.append('; 状態 = 1 (hidden). 154 of the 180 hidden officers appear here.')
    out.append('; ' + '=' * 78)
    out.append('ArrivalScheduleTable:')
    out.append('')
    for prov in provinces:
        pairs = schedule[prov['id']]
        base = ARRIVAL_CPU + prov['id'] * ARRIVAL_STRIDE
        out.append('; %s %s (%s) - %d scheduled'
                   % (prov['id'], prov['katakana'], prov['romaji'], len(pairs)))
        out.append('ArrivalSchedule_%s:' % prov['label'])
        for line in range(2):
            body, notes = [], []
            for idx in range(line * 5, line * 5 + 5):
                if idx < len(pairs):
                    oid, year = pairs[idx]
                    body.append('$%02X, $%02X' % (oid, year))
                    notes.append('%d(%s)->%d' % (oid, OFF_ZH.get(oid, '?'), year))
                else:
                    body.append('$FF, $FF')
            out.append('  .byte %-58s ; $%04X %s'
                       % (', '.join(body), base + line * 10,
                          ' '.join(notes) or 'empty'))
        out.append('')


def emit_death_years(out, rows):
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Officer natural-death year table: 1 byte per id (%d)'
               % (DEATH_CPU, DEATH_CPU + DEATH_COUNT - 1, DEATH_COUNT))
    out.append('; byte = death year - %d; from that year on, every strategy turn rolls'
               % DEATH_YEAR_OFFSET)
    out.append('; death against DeathChanceThreshold (DeathChanceRoll, $BD28,')
    out.append('; prg_19_1a.asm). Full table: docs/officer_death_years.csv')
    out.append('; ' + '=' * 78)
    out.append('OfficerDeathYearTable:')
    for start in range(0, len(rows), 8):
        chunk = rows[start:start + 8]
        out.append('  .byte %-42s ; $%04X id %3d-%3d: %s'
                   % (byte_list([c['byte'] for c in chunk]),
                      DEATH_CPU + start, start, start + len(chunk) - 1,
                      ' '.join('%s=%d' % (c['short'], c['year']) for c in chunk)))
    out.append('')


# ---------------------------------------------------------------------------
# Bank $10 PPU screens
# ---------------------------------------------------------------------------

# (label, doc-comment lines) per 1KB screen, address order. Every claim here is
# pinned to the loader code listed in the comment itself. The proc names of the
# loaders are NOT evidence of which mode a screen belongs to (three of them are
# wrong); the mode is pinned by addr_sub_state -> the NMI dispatch table ($F87B,
# indexed by $0078) and by every writer of addr_game_state in the ROM - see
# tools/scan_ram_writers.py and code/initial_data_tables.md §9.
SCREEN_SPECS = [
    ('StrategyMapBaseScreen', [
        'Role: Strategy Mode - the map screen background (China seen from above:',
        '  mountain / forest / river / city glyphs) plus the 年 ... 月 date plate.',
        '  The loader proc used to be called State_NewGameInit; it is now',
        '  State_StrategyMapLaunch, because it runs on every return to the map (the',
        '  new-game data re-seed is a different proc, State_NewGameSetup $E3EE). It',
        '  stores addr_sub_state = 2 ($E0DD), so the frames that follow run',
        '  NmiState2_MapScreen ($F8B5); it writes the $6F8B request mailbox with $FF',
        '  only when the caller has not staged a scene handoff ($0400 = $0D, done by',
        '  ClearOverlayWait and WarPostProcess); and it parks the map camera',
        '  $6F41 = $F0 / $6F3F = $80 ($E15D-$E164).',
        'Callers - every writer of addr_game_state ($007A) = 1 in the ROM:',
        '  ClearOverlayWait $DB0C (prg_0a_0b)      - clear overlay done: after',
        '    CopySramToWork, with frame state $0400 = $0D / $0401 = 3 and the player',
        '    country $6F03 looked up in PlayerPtrTable',
        '  WarPostProcess $BBAA (prg_08_09)        - tactical war layer finished',
        '  WarResult_Finalize $D8FF (prg_08_09)    - war result finalized',
        '  StrategyCommand_InitOfficerScroll $D74E (prg_17_18) - on A while',
        '    sram_scroll_pending $6F43 is set (A with $6F43 = 0 resets via B1F_Reset)',
        '  WarPostProcess also stores frame state $0400 = $0D (post-war officer',
        '  status scene, $0401 = 0); WarResult_Finalize jumps to WarResultSlotReset.',
        '  The $0400 = $0D handoff is what the mailbox test at $E126 keys on.',
        'Loader: prg_1f State_StrategyMapLaunch ($E0DA) - LDY #$30 / JSR',
        '  SwitchBank8_B ($E0E9), ($000A/$000B) <- $8000 ($E0EC-$E0F3), PPU addr',
        '  $0000/$0001 <- $2000, then LDY #$37 / JSR B17_18_PpuCopyRaw ($E113).',
        '  PpuCopyRaw ($A212, prg_17_18.asm) streams exactly $400 bytes',
        '  ($000C/$000D counter) from ($000A) to PPUDATA, so this block is one whole',
        '  screen at $2000.',
        'CHR (render-verified): display mode $00 (DisplayInit #$00 at $E0E4 ->',
        '  MenuFontRecordLoad record 0 = pages 00 01 02 10): BG tiles $C0-$FF from',
        '  CHR page $10 = chr_02.bin slot 0 (map art), tiles $00-$3F from page $00',
        '  (the plate kanji and the digits). Palette record 0 ($E11B-$E120).',
        'Date plate: tile rows 1-3 carry the 年 ... 月 plate. Its only sub-$40 tiles',
        '  are $0E/$1E at row 2-3 col 6 and $0F/$1F at row 2-3 col 10, i.e. two 8x16',
        '  kanji (upper + lower tile); YearDisplaySetup ($A6B6, prg_1d_1e) turns the',
        '  scenario year $6F00 + $64 and the month $6F01 + 1 into BCD digit tiles',
        '  nibble + $04 (upper) / + $14 (lower) and writes them into the gaps.',
        'Tile rows 20-29 are the blank tile $01 - the bottom 80 px is always covered',
        '  by the command panel drawn at runtime.',
    ]),
    ('DuelBaseScreen', [
        'Role: Duel Mode (一騎討ち) base screen. Its loader proc used to be called',
        '  State_TacticalMode (and before that State_BattlePhase); it is now',
        '  State_DuelSceneLaunch, because it stores addr_sub_state = 5 ($E2ED), so',
        '  its frames run NmiState5_Duel ($F9A0) -> B17_18_DuelModeDispatch ($F9CD).',
        '  The picture is a dark field between two frame bands - what the duel',
        '  sprites are drawn over.',
        'Callers - the only writer of addr_game_state ($007A) = 7 in the ROM:',
        '  Phase5SideEventPanelSetup $CD66 (prg_0e_0f) - Battle Mode phase 5 side',
        '    event panel; it disables NMI and stores through the $007A slot, which',
        '    that bank aliases as btl_flash_counter.',
        'Loader: prg_1f State_DuelSceneLaunch ($E2E8) - LDY #$30 / JSR',
        '  SwitchBank8_B ($E2FC), ($000A/$000B) <- $8400 ($E2FF-$E306), PPU addr <-',
        '  $2000, then LDY #$37 / JSR B17_18_PpuCopyRaw ($E318). Same 1KB raw stream',
        '  as above.',
        'CHR: display mode $0A (DisplayInit #$0A at $E2F2 -> record 10 = pages',
        '  8D 8E 8F 90); palette record $0A ($E320-$E325).',
        'Picture: flat base screen - only three tile values ($01 rows 0-5 and 20-29,',
        '  $00 rows 6-19, plus $08 at row 5 cols 14 and 28). The visible bands come',
        '  from the attribute table (palettes), not from the tiles.',
    ]),
    ('TacticalTerrainScreen', [
        'Role: Tactical Mode (war scene) terrain. Display record 1 is armed by the',
        '  game-state-3 proc State_WarSceneLaunch ($E193) - "war" is this project\'s',
        '  name for the tactical layer - and game state 3 is stored by',
        '  WarSceneLaunch $B5E3 (prg_1b_1c), Spoils_ExitFade $C356 (prg_17_18),',
        '  ArmyDeploySceneTrigger $CA4C (prg_19_1a) and Phase4ResultFlashTrigger',
        '  $A403 (prg_0e_0f).',
        'Loader: prg_1d_1e SceneRenderer ($BC71) callback 1 ScenePageCopy ($BC9B) -',
        '  LDY #$30 / JSR B1F_SwitchBank8_B ($BC9D), source ($0470/$0471) = $8800',
        '  seeded by callback 0 ($BC83), PPU destination ($0472/$0473) = $2400 and',
        '  +$40 per call until the high byte reaches $28, i.e. exactly this 1KB.',
        '  Each call builds one 64-byte PPU stream packet at $0380: count $40, addr',
        '  hi/lo, 64 tile bytes, $FF terminator (written back through $03C3), and',
        '  $0401 only advances at $2800, so the screen is uploaded over 16 frames.',
        'Callers: NmiState2_MapScreen $F8EF (LDY #$3B = banks $1B+$1C, JSR $A000;',
        '  the label there used to read B19_1A_OverlayStripRender_Entry, which is',
        '  wrong for that bank pair - see code/bank_switch_map.md) ->',
        '  MapScreenFrameUpdate ($A00C) -> frame state $0E = CallSceneRenderer',
        '  ($A06D) -> B1D_1E_SceneRenderer ($A039). Frame state $0400 = $0E is',
        '  written by exactly one site in the ROM: MapRulerIntroCancelCheck $A172',
        '  (Select during the ruler intro / camera focus phase).',
        'CHR (render-verified): display mode $01 (record 1 = pages 88 89 8A 88), so',
        '  BG tiles $40-$7F come from CHR page $89 = chr_11.bin slot 1; palette',
        '  record 0 is loaded by SceneRenderSetup ($BD26-$BD2B).',
        'Picture: terrain only - mountain / forest / water dither in tile rows 0-19,',
        '  blank $40 below, and no city glyphs (unlike the strategy map base). It',
        '  fills the nametable at $2400, the neighbour of $2000 in the mirror pair.',
    ]),
]


def emit_ppu_screens(out, data):
    """Emit the three 1KB nametable screens as tile-row / attribute-row bytes."""
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  PPU background screens: %d x %d bytes' % (
        SCREEN_CPU, SCREEN_CPU + SCREEN_COUNT * SCREEN_SIZE - 1,
        SCREEN_COUNT, SCREEN_SIZE))
    out.append('; Each screen is one nametable image: %d tile bytes (%d rows x %d' % (
        SCREEN_ROWS * SCREEN_COLS, SCREEN_ROWS, SCREEN_COLS))
    out.append('; cols, 8 px each) followed by %d attribute bytes (%d rows x %d cols,' % (
        ATTR_ROWS * ATTR_COLS, ATTR_ROWS, ATTR_COLS))
    out.append('; one 2-bit palette index per 2x2 tile block). Read only through the')
    out.append('; $8000 window (SwitchBank8, Y=$30); no code ever runs here.')
    out.append('; ' + '=' * 78)
    out.append('')
    for n, (label, doc) in enumerate(SCREEN_SPECS):
        cpu = SCREEN_CPU + n * SCREEN_SIZE
        out.append('; ------------------------------------------------------------------------------')
        out.append('; $%04X-$%04X  %s (screen %d/3, %d bytes)' % (
            cpu, cpu + SCREEN_SIZE - 1, label, n + 1, SCREEN_SIZE))
        for line in doc:
            out.append(';   %s' % line)
        out.append('; ------------------------------------------------------------------------------')
        out.append('%s:' % label)
        for row in range(SCREEN_ROWS):
            start = n * SCREEN_SIZE + row * SCREEN_COLS
            chunk = data[start:start + SCREEN_COLS]
            out.append('  .byte %-96s ; $%04X tile row %2d' % (
                byte_list(chunk), cpu + row * SCREEN_COLS, row))
        attr_cpu = cpu + SCREEN_ROWS * SCREEN_COLS
        out.append('%sAttr:' % label)
        for row in range(ATTR_ROWS):
            start = (n * SCREEN_SIZE + SCREEN_ROWS * SCREEN_COLS
                     + row * ATTR_COLS)
            chunk = data[start:start + ATTR_COLS]
            out.append('  .byte %-24s ; $%04X attr row %d (tile rows %d-%d)' % (
                byte_list(chunk), attr_cpu + row * ATTR_COLS, row,
                row * 4, min(SCREEN_ROWS - 1, row * 4 + 3)))
        out.append('')


# ---------------------------------------------------------------------------
# Bank assembly
# ---------------------------------------------------------------------------

def bank_regions(bank):
    """(cpu_start, length, emitter) tuples, address order, for one bank."""
    if bank == 0x10:
        return [
            (SCREEN_CPU, SCREEN_COUNT * SCREEN_SIZE, 'ppu_screens'),
            (PROV_RECORD_CPU, PROV_COUNT * PROV_RECORD_STRIDE, 'prov_records'),
            (TRADE_CPU, TRADE_PRICE_BYTES + TRADE_FLAG_BYTES, 'prov_facility'),
            (OFF_NAME_CPU, OFF_RECORD_SLOTS * OFF_NAME_STRIDE, 'off_names'),
            (PROV_NAME_CPU, PROV_COUNT * PROV_NAME_STRIDE, 'prov_names'),
        ]
    if bank == 0x11:
        return [
            # 237 records only: the copy window's 36-byte tail is physically the
            # head of the arrival schedule below, so it is rendered there.
            (OFF_RECORD_CPU, OFF_RECORD_COUNT * OFF_RECORD_STRIDE,
             'off_records'),
            (ARRIVAL_CPU, PROV_COUNT * ARRIVAL_STRIDE, 'schedule'),
            (DEATH_CPU, DEATH_COUNT, 'death_years'),
        ]
    raise SystemExit('only banks 0x10 and 0x11 are seed banks, got $%02X' % bank)


def header(bank, regions):
    reg = 0x20 + bank
    lines = [
        ';=======================================================================',
        '; DATA Bank %02X (PRG $%02X) - 8KB seed-data bank, mapped into $8000-$9FFF'
        % (bank, bank),
        '; by mapper register $%02X (SwitchBank8_A/B). GENERATED by' % reg,
        '; tools/gen_data_bank_asm.py --bank %02x --write; byte-exactness is' % bank,
        '; enforced by tools/verify_data_banks.py --bank %02x.' % bank,
        ';',
        '; Analysed regions (editable .byte records, one label per row):',
    ]
    for cpu, length, kind in regions:
        lines.append(';   $%04X-$%04X  %-18s (%d bytes)'
                     % (cpu, cpu + length - 1, kind, length))
    lines += [
        ';',
        '; Everything else is a sliced .incbin of rom/prg/prg_%02x.bin and must not'
        % bank,
        '; be edited here: the raw image stays the source for those bytes.',
        '; Layout and field evidence: code/initial_data_tables.md.',
        ';=======================================================================',
        '',
        '.segment "CODE_BANK%02X"' % bank,
        '',
    ]
    return lines


def render_bank(bank, ctx):
    data = ctx['bank_bytes']
    regions = bank_regions(bank)
    out = header(bank, regions)
    cursor = 0
    emitters = {
        'ppu_screens': lambda: emit_ppu_screens(out, data),
        'prov_records': lambda: emit_province_records(out, ctx['provinces']),
        'prov_facility': lambda: emit_province_trade(out, data, ctx['provinces']),
        'prov_names': lambda: emit_province_names(out, ctx['provinces']),
        'off_names': lambda: emit_officer_names(out, ctx['officers'],
                                                OFF_RECORD_SLOTS),
        'off_records': lambda: emit_officer_records(out, ctx['officers'],
                                                    OFF_RECORD_SLOTS),
        'schedule': lambda: emit_arrival_schedule(out, ctx['schedule'],
                                                  ctx['provinces']),
        'death_years': lambda: emit_death_years(out, ctx['deaths']),
    }
    for cpu, length, kind in regions:
        start = cpu - WINDOW_CPU
        emit_gap(out, bank, cursor, start)
        emitters[kind]()
        cursor = start + length
    emit_gap(out, bank, cursor, BANK_SIZE)
    return out


def build_context(bank, from_csv):
    """Load everything the emitters need for one bank.

    With from_csv the record bytes are rebuilt from the decoded CSV columns (the
    CSV is then the editing surface); otherwise they come from the ROM. Name
    bytes always come from the ROM bank: the kana code space is not re-encoded
    from CSV text.
    """
    data = read_bank(bank)
    rom_officers = officer_tool.load_rows(NES_PATH)[0]
    stock_off_records = {r['id']: bytes.fromhex(r['hex']) for r in rom_officers}
    if from_csv:
        by_id = {r['id']: r for r in load_officer_csv_rows()}
        rows = []
        for row in rom_officers:
            merged = dict(by_id[row['id']])
            merged['katakana'] = row['katakana']
            merged['zh_hans'] = row['zh_hans']
            rows.append(merged)
        officer_source = rows
    else:
        officer_source = rom_officers
    officers = load_officers(from_csv, officer_source)
    name_base = OFF_NAME_CPU - WINDOW_CPU
    for row in officers:
        row['name_bytes'] = data[name_base + row['id'] * OFF_NAME_STRIDE:
                                 name_base + (row['id'] + 1) * OFF_NAME_STRIDE]

    rom_provinces = list(province_tool.load_provinces(PRG_COMBINED))
    stock_prov_records = {r['id']: bytes.fromhex(r['hex']) for r in rom_provinces}
    if from_csv:
        with open(os.path.join(DOCS, 'province_data.csv'), newline='',
                  encoding='utf-8') as f:
            csv_provs = {int(r['id']): r for r in csv.DictReader(f)}
        rows = []
        for row in rom_provinces:
            src = csv_provs[row['id']]
            merged = dict(row)
            merged.update({k: int(src[k]) for k in PROV_CSV_INT})
            merged['roster'] = [int(o) for o in src['officer_ids'].split()]
            rows.append(merged)
        province_source = rows
    else:
        province_source = rom_provinces
    provinces = load_provinces(from_csv, province_source)

    drift = []
    if from_csv:
        drift = [('%s %d' % ('officer', row['id']),
                  row['record'], stock_off_records[row['id']])
                 for row in officers if row['record'] != stock_off_records[row['id']]]
        drift += [('%s %d' % ('province', row['id']),
                   row['record'], stock_prov_records[row['id']])
                  for row in provinces
                  if row['record'] != stock_prov_records[row['id']]]
        if drift:
            print('%d records rebuilt from CSV differ from the stock ROM:'
                  % len(drift), file=sys.stderr)
            for name, new, old in drift[:20]:
                print('  %-12s %s -> %s' % (name, old.hex().upper(),
                                            new.hex().upper()), file=sys.stderr)

    return {'bank_bytes': data, 'officers': officers, 'provinces': provinces,
            'schedule': load_schedule(officers),
            'deaths': load_death_years(data)}


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--bank', default='all', choices=['10', '11', 'all'])
    ap.add_argument('--write', action='store_true',
                    help='update asm/banks/data_XX.asm (default: stdout)')
    ap.add_argument('--from-csv', dest='from_csv', action='store_true',
                    help='rebuild record bytes from docs/*.csv instead of the ROM')
    args = ap.parse_args()

    init_names()
    banks = [0x10, 0x11] if args.bank == 'all' else [int(args.bank, 16)]
    for bank in banks:
        ctx = build_context(bank, args.from_csv)
        lines = render_bank(bank, ctx)
        if args.write:
            path = os.path.join(ASM_DIR, 'data_%02x.asm' % bank)
            with open(path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(lines) + '\n')
            print('wrote %s (%d lines)'
                  % (os.path.relpath(path, ROOT), len(lines)))
        else:
            sys.stdout.write('\n'.join(lines) + '\n')
    return 0


if __name__ == '__main__':
    sys.exit(main())
