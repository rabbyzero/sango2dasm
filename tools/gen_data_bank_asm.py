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
              docs/province_data.csv / docs/officer_death_years.csv, i.e. edit
              the CSV, regenerate the assembly. The officer name strings are
              re-encoded from the CSV `katakana` column and the arrival schedule
              from its province/year columns. tools/verify_data_banks.py then
              reports the drift from the stock ROM in human terms (which record,
              which field, old -> new), so the CSV is the comfortable editing
              surface and the .byte listing is the readable in-tree rendering.
              editor/officer_editor.py drives exactly this path.

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
import officer_model                                # noqa: E402
import bank_asm_names as bank_names                 # noqa: E402

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
ARRIVAL_PAIRS_PER_LINE = 5                             # one .byte line
YEAR_BASE = 0xBD                                     # $BD = 189
DEATH_CPU = 0x9C58                                   # bank $31
DEATH_COUNT = officer_tool.OFFICER_COUNT
DEATH_YEAR_OFFSET = 100                              # byte = death year - 100

# Bank $10 tail $9B0A-$9FFF: three accessed byte tables after the province
# katakana names. Evidence (all read through the $8000 window once bank $30
# is switched in):
#   $9B12 EquipmentNamePtrTable  - 32 little-endian words; the code adds $80 to the
#     high byte, so CPU target = stored_word + $8000, i.e. into $9B52-$9D71.
#     Entry n is the 8x16-kanji NAME pattern of equipment id n (0-31, matching
#     docs/equipment_catalog.csv): the armory / warehouse grid indexes it by
#     equipment id, and the name-plate renderer reuses it by strip id (0-31).
#     Readers: State6_RenderArmoryItems prg_08_09_tactical_war $C565, TownCommandDispatch
#     prg_1b_1c_strategy_mode $C840 (index = equipment id), NamePlateStripSetup prg_19_1a_event_scenes
#     $B7C8 (index = strip id * 2).
#   $9B52 EquipmentNamePatterns - the 32 pointer targets, each 17 bytes ($11
#     grid): byte0 = the NAMCO-163 CHR code page the record's tile bytes
#     decode on (page V = 1KB slice: chr_(V//8).bin @ (V%8)*$400), then
#     2 lines x 8 tile bytes ($80-$BF = page offsets $00-$3F, $01 = blank)
#     spelling the name (kanji mixed with hiragana の). Each weapon class
#     has its own page (sword $04 / blade $54 / spear $56 / armor $55), so
#     the same tile byte is a different glyph across pages ($92/$93 = 剣
#     top on $04 vs 刀 bottom on $54). Two special items carry a page of
#     their own: id 7 七星宝剣 = $0D, id 29 甲冑 = $10. Verified by
#     rendering each page from rom/chr and reading the names (2026-09-30).
#   $9D72 ProvinceAdjacencyTable - 30 x 8 neighbor province ids, $FF-terminated
#     (see code/bank_switch_map.md 5.2 and the AI/war readers).
#   $9E62 TacticalAttackSideTypeTable - parallel to the adjacency table (same
#     id*8 index); per-neighbor roster-layout byte. Readers: GetCityDataA
#     prg_0c_0d_tactical_commands $DEB8 (returns it as that neighbor's "city data" byte) and
#     @SetupAttackerRoster prg_08_09_tactical_war $B331 (value * 34 -> a side-1 roster base
#     in bank $26).
PATTERN_PTR_CPU = 0x9B12
PATTERN_PTR_COUNT = 32
PATTERN_PTR_STRIDE = 2
PATTERN_REC_CPU = 0x9B52
PATTERN_REC_STRIDE = 0x11
PATTERN_REC_COUNT = 32

# Names decoded by rendering each record's byte0 CHR code page from rom/chr
# and reading the composed glyphs, cross-checked against known in-game item
# lists (2026-09-30). The catalog CSV can only offer '(weapon id N)'/
# '(hidden ...)' placeholders for these because they are not in the regular
# armory stock lists; they are real in-game items (hidden armories for
# appointed officers / duel loot from appointed rulers).
EQUIP_DECODED_NAMES = {
    5: '青釭の剣', 6: '倚天の剣', 7: '七星宝剣',
    14: '龍牙刀', 15: '関王刀',
    22: '狼牙鎗', 23: '蛇矛',
    30: '聖者の衣', 31: '竜鱗の鎧',  # id14 uses full-form 龍; id31 uses the
                                      # 立+日+乚 variant 竜 (U+7ADC)
}
ADJ_CPU = 0x9D72
ADJ_STRIDE = 8
ATTACK_SIDE_TYPE_CPU = 0x9E62

# Bank $10 tail padding $9F52-$9FFF (174 bytes): unused $FF filler after the
# attack side type table (which ends at $9F51). No reader reaches it. Rendered as
# .byte rows (not a .incbin) so the whole bank tail is visible in-tree.
FF_FILLER_CPU = 0x9F52
FF_FILLER_LEN = BANK_SIZE - (FF_FILLER_CPU - WINDOW_CPU)   # $2000 - $1F52 = $AE
FF_FILLER_ROW = 16

# Bank $10 gap $997A-$9A19 (160 bytes) between off_names (ends $9979) and
# prov_names (starts $9A1A): unreferenced filler, not a table. Rendered as
# .byte rows (not a sliced .incbin) purely for in-tree traceability of the
# ROM bytes.
RAW_DUMP_CPU = 0x997A
RAW_DUMP_LEN = 160
RAW_DUMP_ROW = 10

# Bank $10 slot $9B0A-$9B11 (8 bytes): 下野 (ざいや) label, read through the
# same id*8+$9A1A province-name mechanism as ProvinceNameTable. The tactical
# Withdraw menu uses this entry when an officer opts to 下野 (retire from
# service) instead of retreating to another province. Glyph bytes live in the
# hiragana menu block ($44+), not the katakana name block ($04-$38); reader
# CmdDrawNameFromData ($A426) indexes them identically (slot 30 = $1E).
PROV_NAME_WITHDRAW_CPU = 0x9B0A
PROV_NAME_WITHDRAW_LEN = PATTERN_PTR_CPU - PROV_NAME_WITHDRAW_CPU

# Bank $11 $8D74-$8DB3: four reinforcement candidate pools. $8D74-$8D7B holds
# four little-endian word pointers whose HIGH byte is stored biased by -$60
# (@ReinforceScan adds #$60 back), so each word addresses a $FF-terminated list
# of (Officer id, reinforcement year) pairs in the same slice. The year byte is
# the reign encoding (display year - 100), which is what $6F00 also holds.
REINFORCE_CPU = 0x8D74
REINFORCE_PTR_COUNT = 4
REINFORCE_HI_BIAS = 0x60
REINFORCE_ENTRY_STRIDE = 2           # [0] Officer id, [1] year - 100
REINFORCE_YEAR_OFFSET = 100          # display year = byte + 100
REINFORCE_PAIRS_PER_ROW = 4
REINFORCE_BYTES = 0x8DB4 - REINFORCE_CPU       # 64
# EventReinforceGate ($A33C, prg_19_1a_event_scenes) is sub-state 2 of the
# monthly event dispatch, so it runs in every month for the acting Country and
# picks pool (Country - 2); Country 6 aliases slot 3, and Countries 0/1/5
# have no pool. OfficerReinforceScene ($AEC0) then inspects the first
# still-hidden officer: if his year has arrived he joins the Country's home
# Province roster when a slot is free, else the scan retries next month.
REINFORCE_POOL_COUNTRIES = (2, 3, 4, 6)

# Bank $11 $8DB4-$99BC: Officer name-glyph records, 13 bytes per Officer id:
# [0] = name-font CHR code page, then 4 CONTIGUOUS bytes per character - the
# 8x8 quadruple (n, n+1, n+$10, n+$11) of one 16x16 kanji - $FF terminated.
# (The bank $10 equipment patterns at $9B52 are line-major instead: 2 lines x
# 8 tiles, so a character's 4 cells straddle the two lines.)
# Field evidence: code/ruler_card_decode.md section 4.
NAME_GLYPH_CPU = 0x8DB4
NAME_GLYPH_STRIDE = 0x0D
NAME_GLYPH_TILES = 4                 # tile cells per character (2x2 of 8x8)

# Bank $11 gap $99BD-$9AB3 (247 bytes) between the glyph records (end $99BC)
# and the tactical defense side type table (starts $9AB4): every byte is $00 and no
# analysed reader reaches it. Rendered as .byte rows (not a sliced .incbin) so
# the whole bank is visible in-tree, like the bank $10 filler regions.
B11_GAP_CPU = 0x99BD
B11_GAP_LEN = 0x9AB4 - B11_GAP_CPU    # 247
B11_GAP_ROW = 16

# Bank $11 $9AB4-$9BA3: one byte per (province, neighbor) slot, 30 x 8, exactly
# parallel to the bank $10 adjacency graph $9D72 - every row's $FF run starts on
# the same slot as its adjacency row (verified 30/30). Values are $00/$01 only.
DEFENSE_SIDE_TYPE_CPU = 0x9AB4

# Bank $11 $9BA4-$9C57: battlefield facility-tile table, 30 rows x 6 = three
# ordered (X,Y) tile pairs per province - the facility tiles of the province's
# tactical map. Fixed slot order: 0=market (march target of Action_BuyRice,
# entry+0/+1), 2=hospital (march target of Action_RestoreHP, entry+4/+5),
# 1=remaining facility (armory) by elimination. A pair is unused when its X has
# bit7 set (readers BMI/BPL; padding stored is $FF $FF). Coords are 32x32
# battlefield tiles ($00-$1D observed); Y >= $10 is decremented once by the
# march readers (map gap row). The row area ends exactly at
# OfficerDeathYearTable $9C58.
FACILITY_TILE_CPU = 0x9BA4
FACILITY_TILE_STRIDE = 6
FACILITY_TILE_PAIRS = 3
FACILITY_TILE_SLOTS = ('House', 'Armory', 'Hospital')

# Bank $11 tail $9D45-$9FFF: the raw slice that used to cover it splits into
# three parts, all now rendered in-tree (same treatment as the bank $10 raw
# dump / FF filler); the table itself uses .word, the filler stays .byte.
#   $9D45-$9D57  19 x $00 gap right after OfficerDeathYearTable (ends $9D44);
#                no reader reaches it.
#   $9D58-$9DCF  province pixel-position table: 30 rows x 4 bytes indexed
#                province *4, each row two .word entries - map pixel Y then
#                map pixel X, both stored offset by the $8000 window base
#                (like the reinforcement pool pointers, whose high byte is
#                stored biased by -$60). On-map pixel = coord - $8000, so every
#                stored value is $0050-$0180 (a multiple of $10 px) and the hi
#                byte is only ever $00/$01. The stride is exactly 30 rows: the
#                4 bytes after the last row ($9DD0-$9DD3) are $FF like the
#                following filler, which the emitter asserts instead of drawing
#                them into the table region.
#   $9DD0-$9FFF  560 x $FF tail padding (the first $FF byte of the bank sits
#                at $9DD0, right where the table stride ends).
B11_TAIL_GAP_CPU = 0x9D45
B11_TAIL_GAP_LEN = 0x9D58 - B11_TAIL_GAP_CPU      # 19
B11_TAIL_GAP_ROW = 16
PIXEL_POS_CPU = 0x9D58
PIXEL_POS_STRIDE = 4
PIXEL_POS_ROWS = PROV_COUNT        # 30 rows, ending $9DCF
PIXEL_POS_TAIL_PAD = 4             # $9DD0-$9DD3: $FF, stride alignment proof
PIXEL_POS_MAX_COORD = 0x01F0       # sane 16-bit map pixel bound (asserted)
PIXEL_POS_WINDOW_BASE = WINDOW_CPU  # coords carry the $8000 window as a base
B11_FF_FILLER_CPU = 0x9DD0
B11_FF_FILLER_LEN = BANK_SIZE - (B11_FF_FILLER_CPU - WINDOW_CPU)   # 560
B11_FF_FILLER_ROW = 16

# Notes printed inside a remaining raw slice, keyed by (bank, cpu_start).
GAP_NOTES = {
}

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
    """Rebuild 12 record bytes from decoded CSV columns (+5 stays 0).

    The packing lives in `tools/officer_model.py`, which the standalone officer
    editor uses too, so both write the same bytes for the same columns.
    """
    return officer_model.record_from_fields(row)


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


def load_death_years(bank_bytes, from_csv=False):
    """[{byte, year, short}] for the 237 ids.

    Default reads the ROM bank; `--from-csv` takes the `table_byte` column of
    docs/officer_death_years.csv instead, so the death table is as editable as
    the records are.
    """
    table, path = None, None
    if from_csv:
        path = os.path.join(DOCS, 'officer_death_years.csv')
        with open(path, newline='', encoding='utf-8') as f:
            table = {int(r['id']): int(r['table_byte'])
                     for r in csv.DictReader(f)}
    rows = []
    for oid in range(DEATH_COUNT):
        if table is None:
            raw = bank_bytes[DEATH_CPU - WINDOW_CPU + oid]
        else:
            if oid not in table:
                raise SystemExit('%s: no row for officer id %d' % (path, oid))
            raw = table[oid]
            if not 0 <= raw <= 0xFF:
                raise SystemExit('%s: id %d table_byte %d is not one byte '
                                 '(death year %d)'
                                 % (path, oid, raw, raw + DEATH_YEAR_OFFSET))
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

def load_equipment_names():
    """item_id -> (item_name, category) from docs/equipment_catalog.csv.

    Only used for comments in the bank $10 pattern tables; tolerant of a
    missing file (returns {} so the tables still render).
    """
    names = {}
    path = os.path.join(DOCS, 'equipment_catalog.csv')
    try:
        with open(path, newline='', encoding='utf-8') as f:
            for r in csv.DictReader(f):
                try:
                    iid = int(r['item_id'])
                except (KeyError, ValueError):
                    continue
                names[iid] = (r.get('item_name', ''), r.get('category', ''))
    except OSError:
        pass
    return names

def emit_gap(out, bank, start_off, end_off):
    if start_off >= end_off:
        return
    out.append('; ' + '-' * 78)
    out.append('; $%04X-$%04X (%d bytes): NOT ANALYSED - raw slice of'
               % (WINDOW_CPU + start_off, WINDOW_CPU + end_off - 1,
                  end_off - start_off))
    out.append('; rom/prg/prg_%02x.bin, so this bank always reproduces the ROM.'
               % bank)
    for note in GAP_NOTES.get((bank, WINDOW_CPU + start_off), ()):
        out.append(('; ' + note).rstrip())
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
    out.append(';       +0 = the SELL rate: SellSurplusRice prg_0a_0b_strategy_ai $CC9E loads it')
    out.append(';           with ASL/TAY and no INY, then computes gold = rice * rate / 100,')
    out.append(';       +1 = the BUY rate: @RiceBuySeed prg_1b_1c_strategy_mode $C254 loads it with')
    out.append(';           LDY #$01 and computes gold = ceil(rice * rate / 100); Action_BuyRice\'s')
    out.append(';           rice cost prg_08_09_tactical_war $A457 uses the same +1 byte.')
    out.append(';       The pair is also the action parameter record of the war-layer buy/sell')
    out.append(';       panel: State 0 prg_08_09_tactical_war $C129 dereferences ($02) = id*2 +')
    out.append(';       $%04X with Y = 0/1 selecting the leg.' % TRADE_CPU)
    out.append(';       Provinces with no 町 rice trade hold $00, $00; every (+0, +1)')
    out.append(';       pair matches the sell/buy rate columns of docs/rice_prices.csv.')
    out.append(';   $%04X-$%04X  ProvinceFacilityFlags: one flag byte per province' % (flag_cpu, flag_cpu + TRADE_FLAG_BYTES - 1))
    out.append(';       (initial-value seed) - province facility flags behind the town')
    out.append(';       commands. The town screen menu layout comes from a separate table')
    out.append(';       pair (@TownFacilitySetTable/@FacilityActionCodeTable prg_1b_1c_strategy_mode')
    out.append(';       $C025/$C10E, action codes 0=兵器工房 armory, 1=学校 academy,')
    out.append(';       2=医院 hospital, 3=町 market); these bits gate the individual')
    out.append(';       commands, so they are not a bijection onto those 4 codes.')
    out.append(';       Per-row comments list the flags as 兵 facility bit0 / 学 bit1 /')
    out.append(';       町 bit2 / 募 bit3, `-` = clear.')
    out.append(';       Consumers test one bit each:')
    out.append(';       bit0 = gate for the war-AI action loop (@AiAction_')
    out.append(';              EvaluateAndExecute prg_0a_0b_strategy_ai $C33F AND #$01 - clear => skip')
    out.append(';              to the next province). Clear: %s.' % cleared(1))
    out.append(';       bit1 = additional town-command facility flag (not yet tied to a')
    out.append(';              named command; overlaps but is not contained in bit2).')
    out.append(';              Clear: %s.' % cleared(2))
    out.append(';       bit2 = has a working 町 rice market - the 23 provinces whose rate')
    out.append(';              pair is non-zero (docs/rice_prices.csv has_market matches')
    out.append(';              this bit exactly). Also gates the AI sell path')
    out.append(';              (SellSurplusRice prg_0a_0b_strategy_ai $CC45 AND #$04).')
    out.append(';              Clear: %s.' % cleared(4))
    out.append(';       bit3 = recruit/transfer eligible (@CheckEligibility prg_0a_0b_strategy_ai')
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
    out.append('; inside a block. Reader: OfficerArrivalScan ($B964, prg_19_1a_event_scenes.asm) =')
    out.append('; $%04X + province*$%02X. These ids are exactly the officers whose seed'
               % (ARRIVAL_CPU, ARRIVAL_STRIDE))
    out.append('; 状態 = 1 (hidden). 154 of the 180 hidden officers appear here.')
    out.append('; ' + '=' * 78)
    out.append('ArrivalScheduleTable:')
    out.append('')
    for prov in provinces:
        pairs = schedule[prov['id']]
        if len(pairs) > ARRIVAL_PAIRS:
            # A block is ARRIVAL_STRIDE bytes wide, so the extra pairs have
            # nowhere to go: emitting only the first ARRIVAL_PAIRS would drop
            # officers from the schedule without a word, and the bank would
            # still assemble byte-exact.
            raise SystemExit('arrival schedule province %d holds %d entries but '
                             'a block is $%02X bytes = %d pairs'
                             % (prov['id'], len(pairs), ARRIVAL_STRIDE,
                                ARRIVAL_PAIRS))
        base = ARRIVAL_CPU + prov['id'] * ARRIVAL_STRIDE
        out.append('; %s %s (%s) - %d scheduled'
                   % (prov['id'], prov['katakana'], prov['romaji'], len(pairs)))
        out.append('ArrivalSchedule_%s:' % prov['label'])
        for line in range(ARRIVAL_PAIRS // ARRIVAL_PAIRS_PER_LINE):
            first = line * ARRIVAL_PAIRS_PER_LINE
            body, notes = [], []
            for idx in range(first, first + ARRIVAL_PAIRS_PER_LINE):
                if idx < len(pairs):
                    oid, year = pairs[idx]
                    body.append('$%02X, $%02X' % (oid, year))
                    notes.append('%d(%s)->%d' % (oid, OFF_ZH.get(oid, '?'), year))
                else:
                    body.append('$FF, $FF')
            out.append('  .byte %-58s ; $%04X %s'
                       % (', '.join(body), base + first * 2,
                          ' '.join(notes) or 'empty'))
        out.append('')


def emit_death_years(out, rows):
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Officer natural-death year table: 1 byte per id (%d)'
               % (DEATH_CPU, DEATH_CPU + DEATH_COUNT - 1, DEATH_COUNT))
    out.append('; byte = death year - %d; from that year on, every strategy turn rolls'
               % DEATH_YEAR_OFFSET)
    out.append('; death against DeathChanceThreshold (DeathChanceRoll, $BD28,')
    out.append('; prg_19_1a_event_scenes.asm). Full table: docs/officer_death_years.csv')
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
# Bank $11 tail $9D45-$9FFF: zero gap, province pixel-position table, FF filler
# ---------------------------------------------------------------------------

def pixel_pos_rows(data):
    """Decode the $9D58 province pixel-position table, one row per province.

    Row = two 16-bit LE words: map pixel Y (+0/+1) then map pixel X (+2/+3),
    each carrying the $8000 window base, indexed province *4 exactly as the two
    readers do. Raises if a coordinate leaves the sane map-pixel range, if a
    province row is $FF padded, or if the 4 bytes after the last row are not
    the surrounding $FF filler - so the emitter can never mis-parse the stride
    or swallow a hidden byte.
    """
    base = PIXEL_POS_CPU - WINDOW_CPU
    rows = []
    for pid in range(PIXEL_POS_ROWS):
        chunk = data[base + pid * PIXEL_POS_STRIDE:
                     base + (pid + 1) * PIXEL_POS_STRIDE]
        if 0xFF in chunk:
            raise SystemExit('bank $11 pixel table province id %d is $FF padded'
                             % pid)
        y = chunk[0] | chunk[1] << 8
        x = chunk[2] | chunk[3] << 8
        if y > PIXEL_POS_MAX_COORD or x > PIXEL_POS_MAX_COORD:
            raise SystemExit('bank $11 pixel table id %d coords Y=$%04X '
                             'X=$%04X out of range' % (pid, y, x))
        rows.append({'id': pid, 'bytes': chunk, 'y': y, 'x': x})
    tail = data[base + PIXEL_POS_ROWS * PIXEL_POS_STRIDE:
                base + PIXEL_POS_ROWS * PIXEL_POS_STRIDE + PIXEL_POS_TAIL_PAD]
    if set(tail) != {0xFF}:
        raise SystemExit('bank $11 pixel table does not end on the $FF filler '
                         '($9DD0-$9DD3 changed)')
    return rows


def emit_b11_tail_gap(out, data):
    """$9D45-$9D57: $00 gap after the death-year table, shown as .byte rows."""
    base = B11_TAIL_GAP_CPU - WINDOW_CPU
    end = B11_TAIL_GAP_CPU + B11_TAIL_GAP_LEN - 1
    if set(data[base:base + B11_TAIL_GAP_LEN]) != {0x00}:
        raise SystemExit('bank $11 tail gap $9D45-$9D57 is no longer all $00')
    out.append('; ' + '-' * 78)
    out.append('; $%04X-$%04X (%d bytes): unused $00 gap.'
               % (B11_TAIL_GAP_CPU, end, B11_TAIL_GAP_LEN))
    out.append('; Between OfficerDeathYearTable (ends $9D44) and the province')
    out.append('; pixel-position table (starts $9D58). The death-year scan reads')
    out.append('; 237 bytes from $9C58 and stops at $9D44, so no code reaches here.')
    out.append('; ' + '-' * 78)
    out.append('B11TailGap_%04X_%04X:' % (B11_TAIL_GAP_CPU, end))
    for off in range(0, B11_TAIL_GAP_LEN, B11_TAIL_GAP_ROW):
        n = min(B11_TAIL_GAP_ROW, B11_TAIL_GAP_LEN - off)
        chunk = data[base + off:base + off + n]
        out.append('  .byte %-78s ; $%04X (%d bytes)'
                   % (byte_list(chunk), B11_TAIL_GAP_CPU + off, n))
    out.append('')


def emit_province_pixel_positions(out, data, provinces):
    """$9D58-$9DCF: 16-bit map pixel (Y,X) per province, one row per province."""
    pad_end = (PIXEL_POS_CPU + PIXEL_POS_ROWS * PIXEL_POS_STRIDE
               + PIXEL_POS_TAIL_PAD)
    last_row = PIXEL_POS_CPU + PIXEL_POS_ROWS * PIXEL_POS_STRIDE - 1
    pad_start = last_row + 1
    by_id = {r['id']: r for r in provinces}
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Province pixel-position table: %d provinces x %d bytes'
               % (PIXEL_POS_CPU, last_row, PIXEL_POS_ROWS, PIXEL_POS_STRIDE))
    out.append('; Indexed province *%d ($050E / $0402 *4), one row = two .word'
               % PIXEL_POS_STRIDE)
    out.append('; entries: map pixel Y then map pixel X, both stored offset by the')
    out.append('; $%04X window base (like the reinforcement pool pointers above), so'
               % PIXEL_POS_WINDOW_BASE)
    out.append('; the on-map pixel is coord - $%04X; all stored values are'
               % PIXEL_POS_WINDOW_BASE)
    out.append('; $0050-$0180. The stride is exactly')
    out.append('; %d rows: the %d bytes after the last row ($%04X-$%04X) are $FF like'
               % (PIXEL_POS_ROWS, PIXEL_POS_TAIL_PAD, pad_start, pad_end - 1))
    out.append('; the following filler, so no province is missing. Readers (bank $31')
    out.append('; window via LDY #$31 / B1F_SwitchBank8_B):')
    out.append(';   DrawStratagemTargetMarkers prg_08_09_tactical_war $D204 -> $D20F: the pair goes')
    out.append(';     to a:$000A-$000D as the sprite base position for')
    out.append(';     B1F_SpriteOamWriterScroll (battle stratagem province marker).')
    out.append(';   TacticalMapScene_Init prg_0c_0d_tactical_commands $DC99 -> $DCCE: 16-bit clamp of')
    out.append(';     X - $80 into $0512/$0513 and Y - $60 into $0510/$0511 (the')
    out.append(';     exchange-scene map window bounds).')
    out.append('; ' + '=' * 78)
    out.append('ProvincePixelPositionTable:')
    out.append('')
    for row in pixel_pos_rows(data):
        pid = row['id']
        prov = by_id.get(pid, {})
        addr = PIXEL_POS_CPU + pid * PIXEL_POS_STRIDE
        out.append('ProvincePixelPos_%s:' % prov.get('label', '%02X' % pid))
        out.append('  .word $%04X                       ; $%04X id %2d %s  pixel Y'
                   % (row['y'], addr, pid, prov.get('katakana', '')))
        out.append('  .word $%04X                       ; $%04X pixel X'
                   % (row['x'], addr + 2))
    out.append('')


def emit_b11_ff_filler(out, data):
    """$9DD0-$9FFF: unused $FF tail padding (incl. the 4-byte stride pad)."""
    base = B11_FF_FILLER_CPU - WINDOW_CPU
    end = B11_FF_FILLER_CPU + B11_FF_FILLER_LEN - 1
    last_row = PIXEL_POS_CPU + PIXEL_POS_ROWS * PIXEL_POS_STRIDE - 1
    if set(data[base:base + B11_FF_FILLER_LEN]) != {0xFF}:
        raise SystemExit('bank $11 tail $9DD0-$9FFF is no longer all $FF')
    out.append('; ' + '-' * 78)
    out.append('; $%04X-$%04X (%d bytes): unused $FF tail padding.'
               % (B11_FF_FILLER_CPU, end, B11_FF_FILLER_LEN))
    out.append('; The pixel-position table stride ends at $%04X, so these are its'
               % last_row)
    out.append('; first %d bytes; nothing from here to the end of the bank is read.'
               % PIXEL_POS_TAIL_PAD)
    out.append('; Listed as .byte rows so the whole bank is visible in-tree, like')
    out.append('; the bank $10 filler regions.')
    out.append('; ' + '-' * 78)
    out.append('B11FFFiller_%04X_%04X:' % (B11_FF_FILLER_CPU, end))
    for off in range(0, B11_FF_FILLER_LEN, B11_FF_FILLER_ROW):
        n = min(B11_FF_FILLER_ROW, B11_FF_FILLER_LEN - off)
        chunk = data[base + off:base + off + n]
        out.append('  .byte %-78s ; $%04X (%d bytes)'
                   % (byte_list(chunk), B11_FF_FILLER_CPU + off, n))
    out.append('')


# ---------------------------------------------------------------------------
# Bank $11: the tables that used to live in the $8D74-$9C57 raw slice
# ---------------------------------------------------------------------------

def reinforce_lists(blk):
    """Decode the $8D74 block: returns (word_values, [(cpu, [(id, year), ...]), ...]).

    The stored high bytes are biased by -$60, so word = lo | (hi + $60) << 8.
    Raises if a pointer leaves the block, the lists do not tile it, an entry is
    not a whole (id, year) pair, or an Officer id is out of range - so the
    emitter can never drift from the ROM bytes or mis-parse the stride.
    """
    words = [blk[i * 2] | (blk[i * 2 + 1] + REINFORCE_HI_BIAS) << 8
             for i in range(REINFORCE_PTR_COUNT)]
    lists = []
    for word in words:
        start = word - REINFORCE_CPU
        if not 0 <= start < len(blk):
            raise SystemExit('reinforce pointer $%04X leaves $%04X-$%04X'
                             % (word, REINFORCE_CPU, REINFORCE_CPU + len(blk) - 1))
        n = start
        while n < len(blk) and blk[n] != 0xFF:
            n += 1
        body = blk[start:n]
        if len(body) % REINFORCE_ENTRY_STRIDE:
            raise SystemExit('reinforce list at $%04X holds %d bytes, not whole '
                             '%d-byte pairs'
                             % (word, len(body), REINFORCE_ENTRY_STRIDE))
        pairs = [(body[k], body[k + 1])
                 for k in range(0, len(body), REINFORCE_ENTRY_STRIDE)]
        for oid, _ in pairs:
            if oid >= OFF_RECORD_COUNT:
                raise SystemExit('reinforce entry at $%04X names Officer %d'
                                 % (word, oid))
        lists.append((REINFORCE_CPU + start, pairs))
    spans = sorted([(cpu, cpu + REINFORCE_ENTRY_STRIDE * len(pairs) + 1)
                    for cpu, pairs in lists])
    for (_, prev_end), (cpu, _) in zip(spans, spans[1:]):
        if prev_end != cpu:
            raise SystemExit('reinforce lists overlap or leave holes at $%04X'
                             % cpu)
    if spans and spans[-1][1] != REINFORCE_CPU + len(blk):
        raise SystemExit('reinforce lists do not end at $%04X'
                         % (REINFORCE_CPU + len(blk) - 1))
    return words, lists


def emit_reinforce_pools(out, data, officers, pools_csv=None):
    """$8D74-$8DB3: 4 word pointers plus the (Officer id, year) pair pools.

    Default decodes the ROM bytes; on the --from-csv path `pools_csv` (from
    load_reinforce_csv) rebuilds the same layout from
    docs/officer_reinforcement.csv, recomputing the pointers from the list
    lengths.
    """
    by_id = {r['id']: r for r in officers}
    if pools_csv is not None:
        lists = []
        cursor = REINFORCE_CPU + 2 * REINFORCE_PTR_COUNT
        for country in REINFORCE_POOL_COUNTRIES:
            pairs = pools_csv[country]
            lists.append((cursor, pairs))
            cursor += REINFORCE_ENTRY_STRIDE * len(pairs) + 1
        if cursor - 1 > REINFORCE_CPU + REINFORCE_BYTES - 1:
            raise SystemExit('CSV pools overflow $%04X-$%04X (end at $%04X) - '
                             'drop some entries'
                             % (REINFORCE_CPU, REINFORCE_CPU
                                + REINFORCE_BYTES - 1, cursor - 1))
        words = [cpu for cpu, _ in lists]
    else:
        base = REINFORCE_CPU - WINDOW_CPU
        blk = data[base:base + REINFORCE_BYTES]
        words, lists = reinforce_lists(blk)
    end = REINFORCE_CPU + REINFORCE_BYTES - 1
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Reinforcement candidate pools: %d pointers + %d lists'
               % (REINFORCE_CPU, end, REINFORCE_PTR_COUNT, len(lists)))
    out.append('; $%04X-$%04X holds %d little-endian words whose HIGH byte is stored'
               % (REINFORCE_CPU, REINFORCE_CPU + 2 * REINFORCE_PTR_COUNT - 1,
                  REINFORCE_PTR_COUNT))
    out.append('; biased by -$%02X (the reader adds #$%02X back), so every target stays'
               % (REINFORCE_HI_BIAS, REINFORCE_HI_BIAS))
    out.append('; inside this bank (stored value = target - $6000). Each word addresses')
    out.append('; one $FF-terminated candidate list; the lists sit back-to-back in')
    out.append('; $%04X-$%04X.' % (words[0], end))
    out.append('; List format: %d-byte entries, [0] = Officer id, [1] = reinforcement'
               % REINFORCE_ENTRY_STRIDE)
    out.append('; year in the reign encoding (byte = display year - %d), $FF padded to'
               % REINFORCE_YEAR_OFFSET)
    out.append('; the list end. Every entry is therefore a multiple of %d bytes and no'
               % REINFORCE_ENTRY_STRIDE)
    out.append('; Officer id reaches $ED (checked here at generation time).')
    out.append('; Year encoding differs from the arrival schedule $8B1C above: that one')
    out.append('; stores the DISPLAY year literally (@ScheduleYear prg_19_1a_event_scenes $B9C0 does')
    out.append('; SBC #$64 before comparing), while @ReinforceScan compares the pair')
    out.append('; byte straight against $6F00 ($AF10/$AF12), so here the byte is')
    out.append('; already year - %d. Observed display years: %d-%d.'
               % (REINFORCE_YEAR_OFFSET,
                  min(y for _, pairs in lists for _, y in pairs) + REINFORCE_YEAR_OFFSET,
                  max(y for _, pairs in lists for _, y in pairs) + REINFORCE_YEAR_OFFSET))
    out.append('; Reader - @ReinforceScan prg_19_1a_event_scenes $AECE: LDY #$31 / SwitchBank8_B,')
    out.append(';   ($0000) <- $%04X, index $0470 is a BYTE offset into the pointer'
               % REINFORCE_CPU)
    out.append(';   table ($00/$02/$04/$06 = the four pools); ($10) = the chosen list.')
    out.append(';   The scan $AEF0 walks it by PAIRS (INX/INX at $AF08 to skip a')
    out.append(';   rejected entry, single INX at $AF0D to step onto the year byte):')
    out.append(';     1. entry[0] == $FF -> no candidate ($AF19 frame state $0401 = 3).')
    out.append(';     2. keep only a hidden Officer (SRAM record[$0B] & 3 == 1).')
    out.append(';     3. entry[1] > $6F00 (reign year not reached) -> also no candidate;')
    out.append(';        entry[1] <= $6F00 -> append the Officer to the province roster')
    out.append(';        ($00 + $11..) and set his status to 2 = rostered ($AF4E-$AF52).')
    out.append(';     4. all ten roster slots $11-$1A occupied -> also no candidate')
    out.append(';        ($AF36 CPX #$0A / BEQ $AF19); the next monthly pass retries.')
    out.append('; Content (decoded names): the pools group Officers by family -')
    out.append('; list 0 曹氏/夏侯氏/司马氏, list 1 周瑜+孙氏+诸葛恪, list 2')
    out.append('; 关氏/张苞/刘封/诸葛瞻, list 3 马氏. EventReinforceGate ($A33C,')
    out.append('; prg_19_1a_event_scenes; sub-state 2 of the monthly dispatch) picks')
    out.append('; pool (Country-2) for the acting Country every month (Country 6 aliases')
    out.append('; slot 3; Countries 0/1/5 have none), and OfficerReinforceScene ($AEC0)')
    out.append('; inspects the first still-hidden Officer: once his year has arrived he')
    out.append('; joins the Country\'s home Province roster if a slot is free; a full')
    out.append('; 10-slot roster retries next month.')
    out.append('; Editing surface: docs/officer_reinforcement.csv.')
    out.append('; ' + '=' * 78)
    out.append('ReinforceCandidatePtrTable:')
    out.append('  .word %-54s ; $%04X -> %s'
               % (', '.join('$%04X' % (w - (REINFORCE_HI_BIAS << 8))
                            for w in words), REINFORCE_CPU,
                  ' / '.join('$%04X (%d pairs)' % (cpu, len(pairs))
                             for cpu, pairs in lists)))
    out.append('')
    for idx, (cpu, pairs) in enumerate(lists):
        label = 'ReinforceCandidateList_%d:' % idx
        years = [y for _, y in pairs]
        out.append('%s%s; $%04X Country %d, %d (Officer id, year) pairs, '
                   'display years %d-%d'
                   % (label, ' ' * max(1, 27 - len(label)), cpu,
                      REINFORCE_POOL_COUNTRIES[idx], len(pairs),
                      min(years) + REINFORCE_YEAR_OFFSET,
                      max(years) + REINFORCE_YEAR_OFFSET))
        for start in range(0, len(pairs), REINFORCE_PAIRS_PER_ROW):
            chunk = pairs[start:start + REINFORCE_PAIRS_PER_ROW]
            flat = [b for oid, year in chunk for b in (oid, year)]
            out.append('  .byte %-40s ; $%04X %s'
                       % (byte_list(flat), cpu + 2 * start,
                          ' '.join('%d(%s)->%d'
                                   % (oid, by_id[oid]['zh_hans'] if oid in by_id
                                      else '?', year + REINFORCE_YEAR_OFFSET)
                                   for oid, year in chunk)))
        out.append('  .byte $FF                                  '
                   '         ; $%04X list end' % (cpu + 2 * len(pairs)))
        out.append('')


def emit_officer_name_glyphs(out, data, officers):
    """$8DB4-$99BC: 13-byte Officer name-glyph records (sprite tile ids)."""
    base = NAME_GLYPH_CPU - WINDOW_CPU
    end = NAME_GLYPH_CPU + OFF_RECORD_COUNT * NAME_GLYPH_STRIDE - 1
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Officer name-glyph records: %d real x %d bytes'
               % (NAME_GLYPH_CPU, end, OFF_RECORD_COUNT, NAME_GLYPH_STRIDE))
    out.append('; Index id*%d + $%04X. Layout: [0] = the NAMCO-163 CHR code page the'
               % (NAME_GLYPH_STRIDE, NAME_GLYPH_CPU))
    out.append('; tile bytes decode on (page V = 1KB slice chr_(V//8).bin @')
    out.append('; (V%8)*$400, same convention as the bank-$30 name patterns), then 4')
    out.append('; bytes PER CHARACTER - CHARACTER-major, not line-major:')
    out.append(';   [1..4] = character 1, [5..8] = character 2, [9..12] = character 3,')
    out.append('; each group being the four 8x8 cells of one 16x16 kanji (top-left,')
    out.append('; top-right, bottom-left, bottom-right) = tile ids (n, n+1, n+$10,')
    out.append('; n+$11): horizontal step +$01, vertical step +$10 on a 16-tile page')
    out.append('; row, so one page holds 16 kanji (64 tiles). Up to 3 characters, $FF')
    out.append('; terminated and padded to the record end. Verified 237/237: every')
    out.append('; record\'s tile count is a multiple of 4 and every group obeys the')
    out.append('; (+1, +$10, +$11) relation.')
    out.append('; The bank-$30 EquipmentNamePatterns ($9B52, data_10_initial_data.asm) store the')
    out.append('; same kind of glyph data LINE-major instead: 2 lines x 8 tiles, so')
    out.append('; there character k = line1[2k], line1[2k+1], line2[2k], line2[2k+1]')
    out.append('; and its four tiles are NOT adjacent.')
    out.append('; Tile bytes are page-relative; the readers add #$C0 to reach the')
    out.append('; sprite tile page $C0-$FF. Officers sharing a surname share the')
    out.append('; leading ids (ids 29-33 夏侯淵/惇/覇/楙/蘭 all start 00 01 10 11 |')
    out.append('; 02 03 12 13).')
    out.append('; Readers (all after LDY #$31; the byte [$0B] bias and the +$C0 tile')
    out.append('; bias live in the readers, not here):')
    out.append(';   OfficerNameSpritePost prg_1d_1e_menu_screens $AB38 - officer-card name sprites;')
    out.append(';   ProvinceDataWindowFrame $ABD7 -> RenderSubState $B1B1 - province')
    out.append(';     window ruler/governor names; prg_17_18_duel_and_display $B1EE ->')
    out.append(';     ExpandMetatileToSprites $CFDB - 4 rows x 6 tiles metatile;')
    out.append(';   RecalcExchangeStats prg_0c_0d_tactical_commands $CC29 -> @GetRulerValue $CC86 -')
    out.append(';     exchange-screen ruler name (index = ruler base value, not id);')
    out.append(';   @MarchFormationOamDraw prg_19_1a_event_scenes $D2EA -> $D334 - marching')
    out.append(';     formation name flag (index $0664[$0509]).')
    out.append('; [0] has no disassembled reader ($00B9 is written but never read).')
    out.append('; The trailing comment groups the tile bytes per character, 4 apiece.')
    out.append('; Field evidence: code/ruler_card_decode.md section 4.')
    out.append('; ' + '=' * 78)
    out.append('OfficerNameGlyphTable:')
    out.append('')
    for row in officers:
        chunk = data[base + row['id'] * NAME_GLYPH_STRIDE:
                     base + (row['id'] + 1) * NAME_GLYPH_STRIDE]
        tiles = chunk[1:]
        n = 0
        while n < len(tiles) and tiles[n] != 0xFF:
            n += 1
        groups = [' '.join('%02X' % b for b in tiles[k:k + NAME_GLYPH_TILES])
                  for k in range(0, n, NAME_GLYPH_TILES)]
        out.append('OfficerNameGlyph_%s: .byte %-64s ; $%04X id %3d %s %s page $%02X '
                   'kanji %d: %s'
                   % (row['label'], byte_list(chunk),
                      NAME_GLYPH_CPU + row['id'] * NAME_GLYPH_STRIDE, row['id'],
                      row['katakana'], row['zh_hans'], chunk[0], len(groups),
                      ' | '.join(groups) or 'none'))
    out.append('')


def emit_zero_filler11(out, data):
    """$99BD-$9AB3: $00 filler between the tables, shown as .byte rows."""
    base = B11_GAP_CPU - WINDOW_CPU
    end = B11_GAP_CPU + B11_GAP_LEN - 1
    if set(data[base:base + B11_GAP_LEN]) != {0x00}:
        raise SystemExit('bank $11 gap $99BD-$9AB3 is no longer all $00')
    out.append('; ' + '-' * 78)
    out.append('; $%04X-$%04X (%d bytes): unused $00 filler.'
               % (B11_GAP_CPU, end, B11_GAP_LEN))
    out.append('; Gap between the name-glyph records (end $99BC) and the defense side')
    out.append('; type table (starts $9AB4); every byte is $00. No analysed code')
    out.append('; accesses it - the bank-$31 readers key off $8D74 / $8DB4 + id*$0D /')
    out.append('; $9AB4 / $9BA4 only. Listed as .byte rows so the whole bank is visible.')
    out.append('; ' + '-' * 78)
    out.append('ZeroFiller11_%04X_%04X:' % (B11_GAP_CPU, end))
    for off in range(0, B11_GAP_LEN, B11_GAP_ROW):
        n = min(B11_GAP_ROW, B11_GAP_LEN - off)
        chunk = data[base + off:base + off + n]
        out.append('  .byte %-78s ; $%04X (%d bytes)'
                   % (byte_list(chunk), B11_GAP_CPU + off, n))
    out.append('')


def emit_defense_side_types(out, data, provinces):
    """$9AB4-$9BA3: tactical defense side type, one byte per (province, neighbour)."""
    base = DEFENSE_SIDE_TYPE_CPU - WINDOW_CPU
    end = DEFENSE_SIDE_TYPE_CPU + PROV_COUNT * ADJ_STRIDE - 1
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Tactical DEFENSE side types: %d provinces x %d slots'
               % (DEFENSE_SIDE_TYPE_CPU, end, PROV_COUNT, ADJ_STRIDE))
    out.append('; One byte per adjacency slot, same province*%d + $%04X index the bank'
               % (ADJ_STRIDE, DEFENSE_SIDE_TYPE_CPU))
    out.append('; $30 adjacency graph $9D72 uses, and $FF padded on exactly the same')
    out.append('; slot in all %d rows (checked row by row against prg_10.bin $9D72;'
               % PROV_COUNT)
    out.append('; the adjacency scan that yields the index runs under LDY #$30, the')
    out.append('; read itself under LDY #$31). Observed values are $00/$01 only.')
    out.append('; Meaning (user-confirmed): the defense side type, selecting the')
    out.append('; defender\'s initial officer arrangement for Tactical Mode. Counterpart')
    out.append('; of the bank-$30 $9E62 TacticalAttackSideTypeTable; the two are chosen')
    out.append('; by SIDE, never by controller.')
    out.append('; Readers (both scan the bank-$30 adjacency row of $050E for $052A,')
    out.append('; then read this table at that slot):')
    out.append(';   @SetupDefenderRoster in .proc WarSetup prg_08_09_tactical_war $B2AE -> $B2D6,')
    out.append(';     and GetCityOfficerData prg_0c_0d_tactical_commands $DEDE -> $DEE2 (called from')
    out.append(';     @BuildOfficerList $C3D2 and @CheckBoundsForPosition $C44E in the')
    out.append(';     cursor-driven army-deploy scene).')
    out.append('; Role of the value: a SELECTOR index, never a count. Every consumer')
    out.append('; scales it and adds it to a per-province base in the bank-$26 geometry')
    out.append('; tables (physical bank $06):')
    out.append(';   $8C52[$050E*2] + type*32 -> defender unit placement pool (16 (Y,X)')
    out.append(';     pairs: anchor, then runs for unit ids 1-4 at offsets $02/$08/$0C/')
    out.append(';     $14); @StoreCoordinates prg_08_09_tactical_war $B266 writes it to $0600/$0614,')
    out.append(';     @BuildOfficerList feeds it to SearchRosterByTileCoord.')
    out.append(';   $94D6[$050E*2] + type*4  -> city bounds rectangle ([Ymin,Ymax] at')
    out.append(';     +0/+2, [Xmin,Xmax] at +1/+3) tested by @CheckBoundsForPosition.')
    out.append('; The bank-$30 twin $9E62 (values 0-$03) does the same job for the')
    out.append('; attacker side: $8000[$050E] + type*34 and $932E[$050E] + type*4.')
    out.append('; The key is not the province alone but the adjacency SLOT holding')
    out.append('; $052A inside $050E\'s row - a per-approach-route selector.')
    out.append('; Controller independence (it is NOT an AI-only table): WarSetup has')
    out.append('; no human/AI gating - the only status tests in $B130-$B310 are')
    out.append('; faction record[$03] == 3 for side 0 then side 1, and @FillCoordinates')
    out.append('; $B258 branches on side_unit_base $6F91 (0 = defender, $0A = attacker),')
    out.append('; so the type is read whenever side 0 deploys, human or AI. Its')
    out.append('; launcher State_WarSceneLaunch prg_1f_boot $E18B dispatches only on')
    out.append('; war_scene_id $0500 ($0B officer-fate vs battle deployment), and the')
    out.append('; arming sites include the player-driven WarSceneLaunch prg_1b_1c_strategy_mode $B5DC')
    out.append('; (frame sub-state 21, controller polled at $0081) plus')
    out.append('; ArmyDeploySceneTrigger prg_19_1a_event_scenes $CA42. The GetCityOfficerData readers')
    out.append('; are player UI in the army-deploy scene ArmyDeployDispatch prg_0c_0d_tactical_commands')
    out.append('; $C204: the readers test only mode byte $050B == 2, written by')
    out.append('; @State_CheckSrcRuler $C267 (side 0 of $0507, the defender); every other')
    out.append('; value ($03 from @State_CheckDestRuler $C2A6 = side 1, $00 from')
    out.append('; @State_ResetForTransfer $C2E0) takes the attacker twin.')
    out.append('; $00 vs $01 (measured over the 23 provinces that reserve the second')
    out.append('; 32-byte block): two authored variants of the DEFENDER ARRAY, and the')
    out.append('; $8C52 base table reserves exactly (max type + 1) * 32 bytes in all 29')
    out.append('; measurable provinces (6 x 32, 23 x 64). The anchor pair (bytes 0-1) is')
    out.append('; identical in both; the other 15 (Y,X) unit positions all change (5-10')
    out.append('; of 15 shared by coincidence). Type 0 sits west of the city anchor')
    out.append('; (mean dX <= 0 in 23/23), type 1 east (mean dX > 0 in 19/23; provinces')
    out.append('; 9/10/15/17 shift along Y). Unlike the attack side, where the anchor')
    out.append('; itself moves, the garrison keeps its city and only re-arrays.')
    out.append('; The bounds rectangle is a DUPLICATED pair - byte-identical for 0 and')
    out.append('; 1 in 22/23, province 14 differs by one X column - so what actually')
    out.append('; changes with the type is the placement array, not the city area.')
    out.append('; What selects 1 is hand-authored, not derived: the relative map')
    out.append('; direction of the two provinces predicts it no better than a coin flip')
    out.append('; (best rule 68/128 over all 128 province/neighbour pairs), slot parity')
    out.append('; does not (66/128), and the value is directional - 46 of the 64 shared')
    out.append('; borders use different values in the two directions. Provinces')
    out.append('; 0/3/4/6/7/18/29 never use 1, none use only 1, and exactly the 23')
    out.append('; provinces that do have base+32 reserved as a spare geometry block.')
    out.append('; Bank-window note: under LDY #$30 the same CPU address $9AB4 is bank')
    out.append('; $10 EquipmentNamePatterns, and bank $10 keeps its own attacker-side')
    out.append('; table at $9E62; the three tables are distinct.')
    out.append('; ' + '=' * 78)
    out.append('TacticalDefenseSideTypeTable:')
    out.append('')
    for row in provinces:
        pid = row['id']
        chunk = data[base + pid * ADJ_STRIDE:base + (pid + 1) * ADJ_STRIDE]
        n = chunk.index(0xFF) if 0xFF in chunk else ADJ_STRIDE
        out.append('  .byte %-40s ; $%04X id %2d %s  defense type per neighbour slot: %s'
                   % (byte_list(chunk), DEFENSE_SIDE_TYPE_CPU + pid * ADJ_STRIDE,
                      pid, row['katakana'],
                      ', '.join('%d' % b for b in chunk[:n]) or 'none'))
    out.append('')


def emit_tactical_facility_tiles(out, data, provinces):
    """$9BA4-$9C57: three (X,Y) facility-tile pairs per province (war map)."""
    base = FACILITY_TILE_CPU - WINDOW_CPU
    end = FACILITY_TILE_CPU + PROV_COUNT * FACILITY_TILE_STRIDE - 1
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Tactical facility tiles: %d rows x %d bytes - the'
               % (FACILITY_TILE_CPU, end, PROV_COUNT, FACILITY_TILE_STRIDE))
    out.append('; facility locations of each province\'s tactical-mode battlefield.')
    out.append('; %d ordered (X,Y) tile pairs per province, fixed slot order:' % FACILITY_TILE_PAIRS)
    out.append(';   +0/+1 House (民家/rice market), +2/+3 Armory (武器屋),')
    out.append(';   +4/+5 Hospital (病院). Direct proof: arriving on pair N')
    out.append(';   routes route_mode $0470=N through State9_RouteNextAction')
    out.append(';   prg_08_09_tactical_war $C7C8: N=$00 -> State0 rice-buy panel $C0D5, N=$01')
    out.append(';   -> State5 armory grid $C4B8, else -> State3 vitality check')
    out.append(';   $C3E3 -> State4 hospital heal $C3E9. Also: slot 0 is the')
    out.append(';   Action_BuyRice march target, slot 2 the Action_RestoreHP one')
    out.append(';   (both via the sliding *3 index below). The')
    out.append(';   market slot does NOT equal the strategy-layer has_market bit')
    out.append(';   (docs/rice_prices.csv): 青州 has a market but no slot-0 tile,')
    out.append(';   襄阳 no market yet slot 2. Row area ends exactly at')
    out.append(';   OfficerDeathYearTable $%04X. A pair is unused when its X has' % DEATH_CPU)
    out.append(';   bit7 set (readers BMI/BPL; padding stored is $FF $FF). Coords are')
    out.append(';   tiles of the 32x32 battlefield ($00-$1D observed); the march')
    out.append(';   readers decrement a Y >= $10 once (map gap row).')
    out.append('; Readers - two indexings exist; stride-6 (correct rows):')
    out.append(';   DrawStratagemTargetMarkers prg_08_09_tactical_war $D24D -> $D25D: $050E *3 *2')
    out.append(';     (=*6), walks pairs at +0/+2/+4 and draws a city-target marker')
    out.append(';     (tiles *16 -> pixels) at each used pair;')
    out.append(';   MoveState_CheckDest prg_0c_0d_tactical_commands $A4DD -> $A4EF: $050E *3 *2')
    out.append(';     (=*6), scans the 3 pairs vs the destination (X,Y); a match')
    out.append(';     stores the slot index (X) as the action selector and enters')
    out.append(';     state $09 (war action panel, WarTownActionDispatch).')
    out.append(';   The war/AI readers use $050E * 3 instead, so they slide across the')
    out.append(';   rows ($FF means "no entry" to them): Action_BuyRice $A329 ->')
    out.append(';   $A33B (+0/+1 = this row\'s House slot exactly), Action_RestoreHP')
    out.append(';   $A507 -> $A51C (+4/+5 = lands on the NEXT row\'s House slot byte')
    out.append(';   pair, not this row\'s Hospital), casualty Phases 5/6 $CA5F ->')
    out.append(';   $CA71 / $CAC2 -> $CAD7 (presence tests: +0 / +4 != $FF gates the')
    out.append(';   reinforcement/morale path). Kept as raw evidence.')
    out.append('; ' + '=' * 78)
    out.append('ProvinceTacticalFacilityTiles:')
    out.append('')
    for row in provinces:
        pid = row['id']
        chunk = data[base + pid * FACILITY_TILE_STRIDE:
                     base + (pid + 1) * FACILITY_TILE_STRIDE]
        pairs = ' '.join(
            '%s(%02X,%02X@%d,%d)' % (FACILITY_TILE_SLOTS[i // 2], chunk[i],
                                     chunk[i + 1], chunk[i], chunk[i + 1])
            if chunk[i] < 0x80 else '%s-' % FACILITY_TILE_SLOTS[i // 2]
            for i in range(0, FACILITY_TILE_STRIDE, 2))
        out.append('  .byte %-34s ; $%04X id %2d %s  %s'
                   % (byte_list(chunk), FACILITY_TILE_CPU + pid * FACILITY_TILE_STRIDE,
                      pid, row['katakana'], pairs))
    out.append('')


# ---------------------------------------------------------------------------
# Bank $10 tail: raw dump, FF filler, pattern pointers, adjacency, deployment
# ---------------------------------------------------------------------------

def emit_raw_dump(out, data):
    """$997A-$9A19: unreferenced filler rendered as .byte rows for traceability."""
    base = RAW_DUMP_CPU - WINDOW_CPU
    end = RAW_DUMP_CPU + RAW_DUMP_LEN - 1
    out.append('; ' + '-' * 78)
    out.append('; $%04X-$%04X (%d bytes): NOT ANALYSED - raw dump of'
               % (RAW_DUMP_CPU, end, RAW_DUMP_LEN))
    out.append('; rom/prg/prg_10.bin $%04X-$%04X, byte-exact against the ROM'
               % (base, base + RAW_DUMP_LEN - 1))
    out.append('; (verify with: python tools/verify_data_banks.py --bank 10).')
    out.append('; Gap between off_names (ends $9979) and prov_names (starts $9A1A); no')
    out.append('; analysed code accesses it (all $30-window reads key off the $8000/')
    out.append('; $8400/$8800/$8C00/$8FC0/$8FFC/$901A/$9A1A bases), so it stays')
    out.append('; unreferenced filler, listed as .byte rows for in-tree traceability.')
    out.append('; ' + '-' * 78)
    out.append('RawDump_%04X_%04X:' % (RAW_DUMP_CPU, end))
    for off in range(0, RAW_DUMP_LEN, RAW_DUMP_ROW):
        chunk = data[base + off:base + off + RAW_DUMP_ROW]
        out.append('  .byte %-44s ; $%04X' % (byte_list(chunk),
                                              RAW_DUMP_CPU + off))
    out.append('')


def emit_prov_name_withdraw(out, data):
    """$9B0A-$9B11: 下野 (ざいや) label, hiragana block via id*8+$9A1A."""
    base = PROV_NAME_WITHDRAW_CPU - WINDOW_CPU
    end = PROV_NAME_WITHDRAW_CPU + PROV_NAME_WITHDRAW_LEN - 1
    out.append('; ' + '-' * 78)
    out.append('; $%04X-$%04X (%d bytes): 下野 (ざいや) label'
               % (PROV_NAME_WITHDRAW_CPU, end, PROV_NAME_WITHDRAW_LEN))
    out.append('; Read through the same id*8+$9A1A province-name mechanism')
    out.append('; (CmdDrawNameFromData $A426, slot index $1E = 30). The tactical')
    out.append('; Withdraw menu renders this when an officer opts to 下野 instead')
    out.append('; of retreating to another province. Glyph codes are in the')
    out.append('; hiragana menu block ($44+): $4E=さ $39=゛→ざ $45=い $67=や.')
    out.append('; ' + '-' * 78)
    out.append('ProvinceName_WITHDRAW:')
    out.append('  .byte %-34s ; $%04X  ざいや (下野)'
               % (byte_list(data[base:base + PROV_NAME_WITHDRAW_LEN]),
                  PROV_NAME_WITHDRAW_CPU))
    out.append('')


def emit_ff_filler(out, data):
    """$9F52-$9FFF: unused $FF tail padding, shown as .byte rows."""
    base = FF_FILLER_CPU - WINDOW_CPU
    end = FF_FILLER_CPU + FF_FILLER_LEN - 1
    out.append('; ' + '-' * 78)
    out.append('; $%04X-$%04X (%d bytes): unused $FF tail padding.'
               % (FF_FILLER_CPU, end, FF_FILLER_LEN))
    out.append('; The attack side type table ends at $9F51; nothing from here to the end of')
    out.append('; the bank is read. Listed as .byte rows so the whole bank is visible.')
    out.append('; ' + '-' * 78)
    out.append('FFFiller_%04X_%04X:' % (FF_FILLER_CPU, end))
    for off in range(0, FF_FILLER_LEN, FF_FILLER_ROW):
        n = min(FF_FILLER_ROW, FF_FILLER_LEN - off)
        chunk = data[base + off:base + off + n]
        out.append('  .byte %-48s ; $%04X' % (byte_list(chunk),
                                              FF_FILLER_CPU + off))
    out.append('')


def emit_pattern_ptrs(out, data, equip):
    base = PATTERN_PTR_CPU - WINDOW_CPU
    end = PATTERN_PTR_CPU + PATTERN_PTR_COUNT * PATTERN_PTR_STRIDE - 1
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Equipment-name pattern-pointer table: %d words'
               % (PATTERN_PTR_CPU, end, PATTERN_PTR_COUNT))
    out.append('; Entry n -> the 8x16-kanji name pattern of equipment id n (0-31,')
    out.append('; docs/equipment_catalog.csv). Words are stored page-relative; the')
    out.append('; code adds $80 to the high byte, so CPU target = word + $8000, which')
    out.append('; is exactly the EquipName_NN record in the EquipmentNamePatterns')
    out.append('; block below. The armory / warehouse grid indexes this by equipment')
    out.append('; id (State6_RenderArmoryItems prg_08_09_tactical_war $C565, TownCommandDispatch')
    out.append('; prg_1b_1c_strategy_mode $C840); the name-plate renderer reuses it by strip id')
    out.append('; (NamePlateStripSetup prg_19_1a_event_scenes $B7C8). All switch bank $30 first.')
    out.append('; ' + '=' * 78)
    out.append('EquipmentNamePtrTable:')
    for n in range(PATTERN_PTR_COUNT):
        target = PATTERN_REC_CPU + n * PATTERN_REC_STRIDE
        name, _cat = equip.get(n, ('', ''))
        name = EQUIP_DECODED_NAMES.get(n, name)
        out.append('  .word EquipName_%02d-$8000%s; $%04X -> $%04X  equip %02d %s'
                   % (n, ' ' * 9, PATTERN_PTR_CPU + n * 2, target, n, name))
    out.append('')


def emit_pattern_records(out, data, equip):
    base = PATTERN_REC_CPU - WINDOW_CPU
    end = PATTERN_REC_CPU + PATTERN_REC_COUNT * PATTERN_REC_STRIDE - 1
    # byte0 is the CHR code page the record's tiles decode on; find its
    # canonical value per category (most common byte0 across the 8 items of
    # that type) and mark the items that carry a page of their own.
    cat_of = {}
    b0_of = {}
    for n in range(PATTERN_REC_COUNT):
        b0_of[n] = data[base + n * PATTERN_REC_STRIDE]
        cat_of[n] = equip.get(n, ('', ''))[1].split()[0] if equip.get(n) else ''
    canon = {}
    for cat in {c for c in cat_of.values() if c}:
        vals = [b0_of[n] for n in range(PATTERN_REC_COUNT) if cat_of[n] == cat]
        canon[cat] = max(set(vals), key=vals.count)
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Equipment-name patterns: %d records x %d bytes'
               % (PATTERN_REC_CPU, end, PATTERN_REC_COUNT, PATTERN_REC_STRIDE))
    out.append('; One 8x16-kanji equipment name per record, drawn as 2 lines of 8')
    out.append('; tiles: byte0 = the NAMCO-163 CHR code page the tile bytes decode')
    out.append('; on (page V = 1KB slice chr_(V//8).bin @ (V%8)*$400), bytes 1-8 =')
    out.append('; line 1, bytes 9-16 = line 2. Tile bytes $80-$BF are offsets $00-$3F')
    out.append('; into that page ($01 = blank), so the same byte is a different glyph')
    out.append('; on a different page ($92/$93 = 剣 top on $04 vs 刀 bottom on $54).')
    out.append('; Storage is LINE-major: character k = line1[2k], line1[2k+1] (top')
    out.append('; cells) plus line2[2k], line2[2k+1] (bottom cells), so its 4 tiles')
    out.append('; are NOT adjacent - 4 character columns of 2 cells per line. The')
    out.append('; bank-$31 OfficerNameGlyphTable ($8DB4, data_11_officer.asm) is the other')
    out.append('; way round: 4 CONTIGUOUS bytes per character (character-major).')
    out.append('; Group by those offsets, not by value: kanji on the class pages do')
    out.append('; follow (n, n+1, n+$10, n+$11) (短 = 90 91 / A0 A1), but hiragana の')
    out.append('; occupies a single cell and the dedicated pages ($0D 七星宝剣, $10')
    out.append('; 甲冑) allocate tiles sequentially, so their vertical step differs.')
    out.append('; Each class has its own page (sword $04, blade $54, spear $56, armor')
    out.append('; $55); two special items carry a page of their own (id 7 七星宝剣')
    out.append('; $0D, id 29 甲冑 $10), marked below. Names mix kanji with の.')
    out.append('; The armory/warehouse renderers never draw byte0: they compare it')
    out.append('; against the cached page of cell 0 and add $40 to the tiles of a')
    out.append('; different-page item, routing it to the other loaded CHR slot.')
    out.append('; ' + '=' * 78)
    out.append('EquipmentNamePatterns:')
    out.append('')
    for n in range(PATTERN_REC_COUNT):
        off = base + n * PATTERN_REC_STRIDE
        b0 = data[off]
        line1 = data[off + 1:off + 9]
        line2 = data[off + 9:off + 17]
        name, cat = equip.get(n, ('', ''))
        name = EQUIP_DECODED_NAMES.get(n, name)
        cat = cat.split(' (')[0]  # drop catalog (unused)/(hidden) qualifiers:
                                  # these items are in-game obtainable (hidden
                                  # armories for appointed officers, duel loot
                                  # from appointed rulers) - not unused/hidden
        ckey = cat.split()[0] if cat else ''
        exp = canon.get(ckey)
        tag = 'font page $%02X (%s)' % (b0, cat) if b0 == exp else \
            'own font page $%02X (special %s item)' % (b0, ckey)
        out.append('EquipName_%02d: .byte $%02X%s; $%04X %s | %s'
                   % (n, b0, ' ' * 38, PATTERN_REC_CPU + n * PATTERN_REC_STRIDE,
                      name, tag))
        out.append('          .byte %-24s ; $%04X line 1: top cells of chars 0-3'
                   % (byte_list(line1), PATTERN_REC_CPU + n * PATTERN_REC_STRIDE + 1))
        out.append('          .byte %-24s ; $%04X line 2: bottom cells of chars 0-3'
                   % (byte_list(line2), PATTERN_REC_CPU + n * PATTERN_REC_STRIDE + 9))
    out.append('')


def emit_province_adjacency(out, data, provinces):
    base = ADJ_CPU - WINDOW_CPU
    end = ADJ_CPU + PROV_COUNT * ADJ_STRIDE - 1
    by_id = {r['id']: r for r in provinces}
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Province adjacency graph: %d provinces x %d slots'
               % (ADJ_CPU, end, PROV_COUNT, ADJ_STRIDE))
    out.append('; Up to %d neighbor province ids per row, $FF padded to the row end' % ADJ_STRIDE)
    out.append('; (readers stop on $FF / BMI). Indexed id*%d + $%04X, read only' % (ADJ_STRIDE, ADJ_CPU))
    out.append('; through the $8000 window after switching bank $30. Neighbor values')
    out.append('; are province ids (see include/province_ids.inc).')
    out.append('; This is the strategic-map neighbor list used across the AI turn and')
    out.append('; the war layer. Readers (representative):')
    out.append(';   prg_0a_0b_strategy_ai  BuildAdjacencyBitmap $D4F6, FindBestEnemyProvince')
    out.append(';              $A274, AiCountExpansionRoom $A0EF, SettleStagedOfficers')
    out.append(';              $ABBA, EvalProvinceAbsorption $B1B1, CalcActionProb')
    out.append(';              $C70E, CountDefendedBorderProvinces $D0E9,')
    out.append(';              CollectEnemyBorderProvinces $D1C5/$D216')
    out.append(';   prg_08_09_tactical_war  AiTurnProcess $B01D, WarSetup $B2BA, SetupPostWarState $BBEB')
    out.append(';   prg_0c_0d_tactical_commands  ProvinceSelect_InitList $BBBB, TacticalMapScene $DEAA')
    out.append(';   prg_19_1a_event_scenes  OfficerArrivalScan $B9F8')
    out.append(';   prg_1b_1c_strategy_mode  ProvinceAdjacencyValidate $DD8A')
    out.append('; ' + '=' * 78)
    out.append('ProvinceAdjacencyTable:')
    out.append('')
    for row in provinces:
        pid = row['id']
        chunk = data[base + pid * ADJ_STRIDE:base + (pid + 1) * ADJ_STRIDE]
        nbrs = [b for b in chunk if b != 0xFF]
        nb_txt = ' '.join('%s' % by_id[b]['label'] if b in by_id else '%d' % b
                          for b in nbrs) or 'empty'
        out.append('ProvinceAdj_%s: .byte %-34s ; $%04X id %2d %s -> [%s]'
                   % (row['label'], byte_list(chunk),
                      ADJ_CPU + pid * ADJ_STRIDE, pid, row['katakana'], nb_txt))
    out.append('')


def emit_attack_side_types(out, data, provinces):
    base = ATTACK_SIDE_TYPE_CPU - WINDOW_CPU
    end = ATTACK_SIDE_TYPE_CPU + PROV_COUNT * ADJ_STRIDE - 1
    out.append('; ' + '=' * 78)
    out.append('; $%04X-$%04X  Tactical ATTACK side types: %d provinces x %d slots'
               % (ATTACK_SIDE_TYPE_CPU, end, PROV_COUNT, ADJ_STRIDE))
    out.append('; One byte per neighbour slot, row-parallel to ProvinceAdjacencyTable')
    out.append('; $9D72 (same id*%d + $%04X index, $FF where that adjacency slot is' % (ADJ_STRIDE, ATTACK_SIDE_TYPE_CPU))
    out.append('; $FF), so a value belongs to the (province, neighbour) pair - the')
    out.append('; approach route - not to a province alone.')
    out.append('; Meaning (user-confirmed): the attack side type 0-$03, selecting the')
    out.append('; attacker\'s initial officer arrangement for Tactical Mode. Counterpart')
    out.append('; of the bank-$31 $9AB4 TacticalDefenseSideTypeTable; the two are chosen')
    out.append('; by SIDE, never by controller.')
    out.append('; Readers (bank $30 window, after the same $9D72 slot scan):')
    out.append(';   @SetupAttackerRoster prg_08_09_tactical_war $B312 -> $B331: $8000[$050E*2] +')
    out.append(';     type*34 -> side-1 placement pool, cursors @AttackerCursorSeeds')
    out.append(';     $02/$0C/$16/$1C (5+5+3+2 (Y,X) pairs after the anchor).')
    out.append(';   GetCityDataA prg_0c_0d_tactical_commands $DEB8 -> @Mode2Bounds $C41C (same pool,')
    out.append(';     type*34 on $8000[$050E*2]) and @OtherModeBounds $C48E')
    out.append(';     ($932E[$050E*2] + type*4 bounds rectangle). The army-deploy scene')
    out.append(';     takes this table whenever its mode byte $050B != 2; $050B == 2')
    out.append(';     (@State_CheckSrcRuler $C267, source side) takes $9AB4 instead.')
    out.append('; Geometry (measured in bank $06, physical file prg_06.bin): each')
    out.append('; province reserves exactly (max type used + 1) 34-byte records - the')
    out.append('; $8000 base table steps 34/68/102/136 across the 29 measurable')
    out.append('; provinces (1/4/16/8 provinces respectively) and no row violates the')
    out.append('; rule, which pins both the stride and the record ownership.')
    out.append('; Attack vs defense asymmetry: the attack records differ in their')
    out.append('; ANCHOR as well as in the 15 unit positions (province 1 types 0-3')
    out.append('; anchor at (3,2) (4,28) (16,29) (18,2) - i.e. the army enters along a')
    out.append('; map flank), while the defense records keep one city anchor and only')
    out.append('; re-array the garrison. Each attack record also carries a 17th (Y,X)')
    out.append('; pair at +32/+33 that none of the four seeded cursors reaches.')
    out.append('; The entry flank is only weakly tied to the route: the anchor side')
    out.append('; matches the neighbour\'s map side in 59%% of the 128 province/neighbour')
    out.append('; pairs on each axis, so the type is an authored per-route choice, not')
    out.append('; a computed direction.')
    out.append('; ' + '=' * 78)
    out.append('TacticalAttackSideTypeTable:')
    out.append('')
    for row in provinces:
        pid = row['id']
        chunk = data[base + pid * ADJ_STRIDE:base + (pid + 1) * ADJ_STRIDE]
        adj = data[ADJ_CPU - WINDOW_CPU + pid * ADJ_STRIDE:
                   ADJ_CPU - WINDOW_CPU + (pid + 1) * ADJ_STRIDE]
        pairs = ', '.join('%d' % b if a != 0xFF else '-' for a, b in zip(adj, chunk))
        out.append('  .byte %-34s ; $%04X id %2d %s  attack type per neighbour slot: %s'
                   % (byte_list(chunk), ATTACK_SIDE_TYPE_CPU + pid * ADJ_STRIDE, pid,
                      row['katakana'], pairs))
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
        '  NmiState2_StrategyMap ($F8B5); it writes the $6F8B request mailbox with $FF',
        '  only when the caller has not staged a scene handoff ($0400 = $0D, done by',
        '  ClearOverlayWait and WarPostProcess); and it parks the map camera',
        '  $6F41 = $F0 / $6F3F = $80 ($E15D-$E164).',
        'Callers - every writer of addr_game_state ($007A) = 1 in the ROM:',
        '  ClearOverlayWait $DB0C (prg_0a_0b_strategy_ai)      - clear overlay done: after',
        '    CopySramToWork, with frame state $0400 = $0D / $0401 = 3 and the player',
        '    country $6F03 looked up in PlayerPtrTable',
        '  WarPostProcess $BBAA (prg_08_09_tactical_war)        - tactical war layer finished',
        '  CountrySelect_Finalize $D8FF (prg_08_09_tactical_war) - country select finalized',
        '  EventMessageScene_ChronPanel $D74E (prg_17_18_duel_and_display) - on A while',
        '    sram_scroll_pending $6F43 is set (A with $6F43 = 0 resets via B1F_Reset)',
        '  WarPostProcess also stores frame state $0400 = $0D (post-war officer',
        '  status scene, $0401 = 0); CountrySelect_Finalize jumps to CountrySelectSlotReset.',
        '  The $0400 = $0D handoff is what the mailbox test at $E126 keys on.',
        'Loader: prg_1f_boot State_StrategyMapLaunch ($E0DA) - LDY #$30 / JSR',
        '  SwitchBank8_B ($E0E9), ($000A/$000B) <- $8000 ($E0EC-$E0F3), PPU addr',
        '  $0000/$0001 <- $2000, then LDY #$37 / JSR B17_18_PpuCopyRaw ($E113).',
        '  PpuCopyRaw ($A212, prg_17_18_duel_and_display.asm) streams exactly $400 bytes',
        '  ($000C/$000D counter) from ($000A) to PPUDATA, so this block is one whole',
        '  screen at $2000.',
        'CHR (render-verified): display mode $00 (DisplayInit #$00 at $E0E4 ->',
        '  MenuFontRecordLoad record 0 = pages 00 01 02 10): BG tiles $C0-$FF from',
        '  CHR page $10 = chr_02.bin slot 0 (map art), tiles $00-$3F from page $00',
        '  (the plate kanji and the digits). Palette record 0 ($E11B-$E120).',
        'Date plate: tile rows 1-3 carry the 年 ... 月 plate. Its only sub-$40 tiles',
        '  are $0E/$1E at row 2-3 col 6 and $0F/$1F at row 2-3 col 10, i.e. two 8x16',
        '  kanji (upper + lower tile); YearDisplaySetup ($A6B6, prg_1d_1e_menu_screens) turns the',
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
        '  SideEventPanelSetup $CD66 (prg_0e_0f_battle) - Battle Mode phase 5 side',
        '    event panel; it disables NMI and stores through the $007A slot, which',
        '    that bank aliases as btl_flash_counter.',
        'Loader: prg_1f_boot State_DuelSceneLaunch ($E2E8) - LDY #$30 / JSR',
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
        '  WarSceneLaunch $B5E3 (prg_1b_1c_strategy_mode), Spoils_ExitFade $C356 (prg_17_18_duel_and_display),',
        '  ArmyDeploySceneTrigger $CA4C (prg_19_1a_event_scenes) and BattleResultFlashTrigger',
        '  $A403 (prg_0e_0f_battle).',
        'Loader: prg_1d_1e_menu_screens SceneRenderer ($BC71) callback 1 ScenePageCopy ($BC9B) -',
        '  LDY #$30 / JSR B1F_SwitchBank8_B ($BC9D), source ($0470/$0471) = $8800',
        '  seeded by callback 0 ($BC83), PPU destination ($0472/$0473) = $2400 and',
        '  +$40 per call until the high byte reaches $28, i.e. exactly this 1KB.',
        '  Each call builds one 64-byte PPU stream packet at $0380: count $40, addr',
        '  hi/lo, 64 tile bytes, $FF terminator (written back through $03C3), and',
        '  $0401 only advances at $2800, so the screen is uploaded over 16 frames.',
        'Callers: NmiState2_StrategyMap $F8EF (LDY #$3B = banks $1B+$1C, JSR $A000;',
        '  the label there used to read B19_1A_OverlayStripRender_Entry, which is',
        '  wrong for that bank pair - see code/bank_switch_map.md) ->',
        '  StrategyFrameUpdate ($A00C) -> frame state $0E = CallSceneRenderer',
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
            (RAW_DUMP_CPU, RAW_DUMP_LEN, 'raw_dump'),
            (PROV_NAME_CPU, PROV_COUNT * PROV_NAME_STRIDE, 'prov_names'),
            (PROV_NAME_WITHDRAW_CPU, PROV_NAME_WITHDRAW_LEN, 'prov_name_withdraw'),
            (PATTERN_PTR_CPU, PATTERN_PTR_COUNT * PATTERN_PTR_STRIDE, 'pattern_ptr'),
            (PATTERN_REC_CPU, PATTERN_REC_COUNT * PATTERN_REC_STRIDE, 'pattern_rec'),
            (ADJ_CPU, PROV_COUNT * ADJ_STRIDE, 'adjacency'),
            (ATTACK_SIDE_TYPE_CPU, PROV_COUNT * ADJ_STRIDE, 'attack_side_type'),
            (FF_FILLER_CPU, FF_FILLER_LEN, 'ff_filler'),
        ]
    if bank == 0x11:
        return [
            # 237 records only: the copy window's 36-byte tail is physically the
            # head of the arrival schedule below, so it is rendered there.
            (OFF_RECORD_CPU, OFF_RECORD_COUNT * OFF_RECORD_STRIDE,
             'off_records'),
            (ARRIVAL_CPU, PROV_COUNT * ARRIVAL_STRIDE, 'schedule'),
            (REINFORCE_CPU, REINFORCE_BYTES, 'reinforce_pools'),
            (NAME_GLYPH_CPU, OFF_RECORD_COUNT * NAME_GLYPH_STRIDE,
             'off_glyphs'),
            (B11_GAP_CPU, B11_GAP_LEN, 'zero_filler11'),
            (DEFENSE_SIDE_TYPE_CPU, PROV_COUNT * ADJ_STRIDE, 'defense_side_type'),
            (FACILITY_TILE_CPU, PROV_COUNT * FACILITY_TILE_STRIDE, 'facility_tiles'),
            (DEATH_CPU, DEATH_COUNT, 'death_years'),
            (B11_TAIL_GAP_CPU, B11_TAIL_GAP_LEN, 'b11_tail_gap'),
            (PIXEL_POS_CPU, PIXEL_POS_ROWS * PIXEL_POS_STRIDE, 'pixel_pos'),
            (B11_FF_FILLER_CPU, B11_FF_FILLER_LEN, 'b11_ff_filler'),
        ]
    raise SystemExit('only banks 0x10 and 0x11 are seed banks, got $%02X' % bank)


def header(bank, regions):
    reg = 0x20 + bank
    kind = 'initial' if bank == 0x10 else 'seed'
    lines = [
        ';=======================================================================',
        '; DATA Bank %02X (PRG $%02X) - 8KB %s-data bank, mapped into $8000-$9FFF'
        % (bank, bank, kind),
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
    ]
    lines += [
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
        'raw_dump': lambda: emit_raw_dump(out, data),
        'prov_name_withdraw': lambda: emit_prov_name_withdraw(out, data),
        'off_names': lambda: emit_officer_names(out, ctx['officers'],
                                                OFF_RECORD_SLOTS),
        'off_records': lambda: emit_officer_records(out, ctx['officers'],
                                                    OFF_RECORD_SLOTS),
        'schedule': lambda: emit_arrival_schedule(out, ctx['schedule'],
                                                  ctx['provinces']),
        'death_years': lambda: emit_death_years(out, ctx['deaths']),
        'reinforce_pools': lambda: emit_reinforce_pools(out, data,
                                                        ctx['officers'],
                                                        ctx['reinforce_csv']),
        'off_glyphs': lambda: emit_officer_name_glyphs(out, data,
                                                       ctx['officers']),
        'zero_filler11': lambda: emit_zero_filler11(out, data),
        'defense_side_type': lambda: emit_defense_side_types(out, data,
                                                      ctx['provinces']),
        'facility_tiles': lambda: emit_tactical_facility_tiles(out, data, ctx['provinces']),
        'b11_tail_gap': lambda: emit_b11_tail_gap(out, data),
        'pixel_pos': lambda: emit_province_pixel_positions(out, data,
                                                           ctx['provinces']),
        'b11_ff_filler': lambda: emit_b11_ff_filler(out, data),
        'pattern_ptr': lambda: emit_pattern_ptrs(out, data, ctx['equip']),
        'pattern_rec': lambda: emit_pattern_records(out, data, ctx['equip']),
        'adjacency': lambda: emit_province_adjacency(out, data,
                                                     ctx['provinces']),
        'attack_side_type': lambda: emit_attack_side_types(out, data,
                                                          ctx['provinces']),
        'ff_filler': lambda: emit_ff_filler(out, data),
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

    With from_csv the record bytes are rebuilt from the decoded CSV columns, the
    names are re-encoded from the CSV `katakana` text and the death years come
    from docs/officer_death_years.csv - the CSVs are then the editing surface
    (see tools/officer_model.py, which the standalone officer editor shares).
    Otherwise everything comes from the ROM.
    """
    data = read_bank(bank)
    rom_officers = officer_tool.load_rows(NES_PATH)[0]
    stock_off_records = {r['id']: bytes.fromhex(r['hex']) for r in rom_officers}
    if from_csv:
        by_id = {r['id']: r for r in load_officer_csv_rows()}
        rows = []
        for row in rom_officers:
            merged = dict(by_id[row['id']])
            # The CSV is the editing surface for the name bytes, so an emptied
            # cell must fail here rather than fall back to the stock ROM text:
            # tools/officer_model.py refuses it, and the two would render
            # different bytes for the same CSV.
            if not str(merged.get('katakana', '')).strip():
                raise SystemExit('docs/officer_data.csv: officer %d has an '
                                 'empty katakana name - every officer has one, '
                                 'and the field is a $00-terminated string'
                                 % row['id'])
            # 简体 is comment-only, so an empty cell keeps the extracted name
            # instead of blanking the annotation.
            merged['zh_hans'] = merged.get('zh_hans') or row['zh_hans']
            rows.append(merged)
        officer_source = rows
    else:
        officer_source = rom_officers
    officers = load_officers(from_csv, officer_source)
    name_base = OFF_NAME_CPU - WINDOW_CPU
    for row in officers:
        if from_csv:
            row['name_bytes'] = officer_model.encode_name(row['katakana'])
        else:
            row['name_bytes'] = data[name_base + row['id'] * OFF_NAME_STRIDE:
                                     name_base + (row['id'] + 1)
                                     * OFF_NAME_STRIDE]

    rom_provinces = list(province_tool.load_provinces(PRG_COMBINED))
    stock_prov_records = {r['id']: bytes.fromhex(r['hex']) for r in rom_provinces}
    if from_csv:
        with open(os.path.join(DOCS, 'province_data.csv'), newline='',
                  encoding='utf-8') as f:
            csv_provs = {int(r['id']): r for r in csv.DictReader(f)}
        rows = []
        officer_by_id = {r['id']: r for r in officers}
        for row in rom_provinces:
            src = csv_provs[row['id']]
            merged = dict(row)
            merged.update({k: int(src[k]) for k in PROV_CSV_INT})
            merged['roster'] = [int(o) for o in src['officer_ids'].split()]
            # officer_count / active_troops / ruler_officer_id are derived from
            # the roster, and tools/officer_model.py recomputes them on every
            # save - so recompute them here too. Only province_summary reads
            # them, but keeping the ROM values would print a stale 現役= and
            # ruler= next to the edited roster on the same comment line.
            rostered = [officer_by_id[o] for o in merged['roster']
                        if o in officer_by_id]
            merged['officer_count'] = len(merged['roster'])
            merged['active_troops'] = sum(o['troop_count'] for o in rostered)
            rulers = [o['id'] for o in rostered if o['loyalty'] == 100]
            merged['ruler_officer_id'] = rulers[-1] if rulers else None
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
            'equip': load_equipment_names(),
            'deaths': load_death_years(data, from_csv),
            'reinforce_csv': load_reinforce_csv() if from_csv else None}


def load_reinforce_csv():
    """{Country id: [(Officer id, table byte), ...]} from the pools CSV.

    docs/officer_reinforcement.csv (written by
    tools/extract_reinforcement_pools.py, edited by the officer editor) holds
    one row per pair in stored list order; row order within a country is the
    list order, and the lists are emitted back-to-back in
    REINFORCE_POOL_COUNTRIES order with the pointers recomputed from the
    lengths.
    """
    path = os.path.join(DOCS, 'officer_reinforcement.csv')
    with open(path, newline='', encoding='utf-8') as f:
        rows = list(csv.DictReader(f))
    pools = {country: [] for country in REINFORCE_POOL_COUNTRIES}
    for row in rows:
        country = int(row['country'])
        if country not in pools:
            raise SystemExit('%s: Country %d is not one of %s - the pool '
                             'selector in EventReinforceGate ($A33C) only '
                             'addresses those four'
                             % (path, country, REINFORCE_POOL_COUNTRIES))
        oid = int(row['officer_id'])
        if not 0 <= oid < OFF_RECORD_COUNT:
            raise SystemExit('%s: Officer id %d out of range' % (path, oid))
        byte = int(row['table_byte'])
        if not 0 <= byte <= 0xFF:
            raise SystemExit('%s: table_byte %d does not fit one byte'
                             % (path, byte))
        pools[country].append((oid, byte))
    return pools


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
            path = os.path.join(ASM_DIR, bank_names.data_asm_name(bank))
            with open(path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(lines) + '\n')
            print('wrote %s (%d lines)'
                  % (os.path.relpath(path, ROOT), len(lines)))
        else:
            sys.stdout.write('\n'.join(lines) + '\n')
    return 0


if __name__ == '__main__':
    sys.exit(main())
