#!/usr/bin/env python3
"""Extract the original officer data straight out of the .nes ROM file.

Everything here is read from the unmodified iNES image (header parsed, no
hardcoded 16-byte assumption), not from the split banks:

  officer names       PRG offset $2101A, 10 bytes/entry, $00-terminated
                      (CPU $901A in PRG bank $30 -> physical bank $10)
  officer master data PRG offset $22000, 12 bytes/record, records 0-236
                      (CPU $8000 in PRG bank $31 -> physical bank $11)

The 12-byte master record is the seed image of the officer's SRAM record at
`id * 12 + $63C0`, so it holds the new-game starting state. Field names follow
the canonical glossary in `docs/manual_kb/terminology.md`:

  +0       体力     Vitality
  +1       武力     Might
  +2       知力     Intelligence
  +3       忠誠度   Loyalty (100 = a playable ruler)
  +4       人徳     Virtue
  +5       位置     LocationProvince (province id $00-$2D; runtime-only,
                    always 0 in the ROM seed)
  +6/+7    経験値   Experience, 16-bit little-endian
  +8/+9    兵数     TroopCount, 16-bit little-endian (non-zero only for the
                    officers already on the map in the 189 start year)
  +10      equipment, packed: bits 0-4 = 武器 (Weapon), bits 5-7 = 防具 (Armor)
  +11      bits 4-7 = レベル (OfficerLevel, 0-based; the game displays it +1)
           bits 2-3 = 軍の属性 (ArmyAffinity): 0 平, 1 山, 2 水
           bits 0-1 = 状態 (OfficerStatus): the seed only ever holds 1
                    (hidden, not yet appeared - 180 officers) or 2 (rostered
                    to a Province - 57 officers), and those 57 are exactly the
                    ids listed in the Province roster slots, which is how the
                    two bit fields were separated. Never 0 or 3 in the seed:
                    0 (free) and 3 (out of action) only arise at runtime.

Everything else the new game needs is stored beside these records: the
starting Province of a hidden officer and his appearance year live in the
arrival schedule at bank `$31` `$8B1C` (30 Province blocks, stride `$14`, ten
(officer id, appear year) pairs each, `$FF $FF` padded).

Weapon indices fall into three groups of 8 (剣 / 刀 / 槍系) and armor is
ordered worst-to-best; both tables were recovered by correlating every record
against a published roster of this ROM and cross-checked against the scanned
manual (`docs/manual_kb/10-duel-mode.md` gives 呂布 = 方天画戟 + 甲冑, which is
exactly what record 218 decodes to).

Simplified-Chinese names are joined in from tools/data/officer_kanji.tsv.
The full evidence chain for the table locations is in
code/initial_data_tables.md.

Usage:
    python tools/extract_officer_data.py            # write output files
    python tools/extract_officer_data.py --print    # also dump to stdout
"""
import argparse
import csv
import os
import sys
import unicodedata

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from charmap_kana import decode_name  # noqa: E402
from map_officer_kanji import load_map  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_ROM = os.path.join(ROOT, 'Sangokushi 2 - Haou no Tairiku (J).nes')

NAME_TABLE_PRG = 0x2101A      # PRG offset of officer name 0
NAME_STRIDE = 10
DATA_TABLE_PRG = 0x22000      # PRG offset of officer record 0
DATA_STRIDE = 12
OFFICER_COUNT = 237           # records 0-236; the table ends here
# Physical 8KB banks (rom/prg/prg_XX.bin); the mapper register value is $20 + n.
NAME_BANK_FILE = ('prg_10.bin', 0x101A)   # bank register $30, CPU $901A
DATA_BANK_FILE = ('prg_11.bin', 0x0000)   # bank register $31, CPU $8000
# SramInit ($DD8B) copies $0B40 bytes, i.e. 240 slots; slots $ED-$EF are padding
SRAM_COPY_BYTES = 0x0B40
SRAM_COPY_SLOTS = SRAM_COPY_BYTES // DATA_STRIDE      # 240
SRAM_RECORD_BASE = 0x63C0
# Province master records, needed to cross-check the OfficerStatus bit pair:
PROVINCE_TABLE_PRG = 0x20C00  # PRG offset of province record 0 (bank $30 $8C00)
PROVINCE_STRIDE = 32
PROVINCE_COUNT = 30
PROVINCE_ROSTER_OFS = 0x11    # +$11..+$1A: 10 officer slots, $FF = empty
ARRIVAL_SCHEDULE_PRG = 0x22000 + 0x0B1C   # bank $31 $8B1C
ARRIVAL_SCHEDULE_STRIDE = 0x14

WEAPONS = {
    0: '短剣', 1: '飛剣', 2: '長剣', 3: '破斬剣', 4: '大剣',
    8: '薤刀', 9: '眉尖刀', 10: '三尖刀', 11: '鉤鐮刀', 12: '偃月刀',
    13: '鳳嘴刀',
    16: '矛', 17: '双戟', 18: '単鉤槍', 19: '戦斧', 20: '双鉤槍',
    21: '方天画戟',
}
ARMOR = {0: '綸巾', 1: '籠手', 2: '兜', 3: '硬皮', 4: '鶴氅', 5: '甲冑'}
# 軍の属性 (ArmyAffinity) = bits 2-3 of +11; the battle AI masks the field with
# AND #$0C, so the two low bits are free for OfficerStatus.
ARMY_AFFINITY = {0: '平', 1: '山', 2: '水'}
# 状態 (OfficerStatus) = bits 0-1 of +11, per docs/manual_kb/terminology.md.
OFFICER_STATUS = {0: 'free', 1: 'hidden', 2: 'rostered', 3: 'out of action'}
SEED_STATUSES = (1, 2)        # the ROM seed only ever holds these two


def read_prg(path):
    """Return the PRG-ROM image of an iNES file, validating the header."""
    with open(path, 'rb') as f:
        rom = f.read()
    if rom[:4] != b'NES\x1a':
        raise SystemExit(f'{path}: not an iNES image')
    prg_size = rom[4] * 16384
    has_trainer = bool(rom[6] & 0x04)
    start = 16 + (512 if has_trainer else 0)
    prg = rom[start:start + prg_size]
    if len(prg) != prg_size:
        raise SystemExit(f'{path}: truncated PRG '
                         f'({len(prg)} of {prg_size} bytes)')
    mapper = (rom[6] >> 4) | (rom[7] & 0xF0)
    need = DATA_TABLE_PRG + OFFICER_COUNT * DATA_STRIDE
    if prg_size < need:
        raise SystemExit(f'{path}: PRG is {prg_size} bytes, need {need}')
    return prg, {'prg_size': prg_size, 'chr_size': rom[5] * 8192,
                 'mapper': mapper, 'prg_start': start}


def decode_record(rec):
    """Split one 12-byte officer master record into named fields.

    Field names follow the canonical glossary in
    docs/manual_kb/terminology.md (武力 = Might, 兵数 = TroopCount,
    レベル = OfficerLevel, 軍の属性 = ArmyAffinity, 状態 = OfficerStatus).
    """
    weapon_index = rec[10] & 0x1F
    armor_index = rec[10] >> 5
    affinity_code = rec[11] & 0x0F      # affinity + status packed together
    affinity_bits = (rec[11] >> 2) & 0x03
    status_bits = rec[11] & 0x03
    return {
        'vitality': rec[0],
        'might': rec[1],
        'intelligence': rec[2],
        'loyalty': rec[3],
        'virtue': rec[4],
        'officer_level': (rec[11] >> 4) + 1,
        'experience': rec[6] | (rec[7] << 8),
        'troop_count': rec[8] | (rec[9] << 8),
        'army_affinity': ARMY_AFFINITY.get(affinity_bits,
                                           f'?{affinity_bits}'),
        'officer_status': OFFICER_STATUS.get(status_bits, f'?{status_bits}'),
        'weapon': WEAPONS.get(weapon_index, f'?{weapon_index}'),
        'armor': ARMOR.get(armor_index, f'?{armor_index}'),
        'weapon_index': weapon_index,
        'armor_index': armor_index,
        'army_affinity_bits': affinity_bits,
        'officer_status_bits': status_bits,
        'army_affinity_code': affinity_code,
        'location5': rec[5],
        'hex': bytes(rec).hex().upper(),
    }


def load_province_roster(prg):
    """Officer ids that start in a Province roster (bank $30 $8C00, +$11..+$1A).

    Returns (set of ids, id -> province id). This is the independent source
    used to prove that +11 bits 0-1 are the seed OfficerStatus.
    """
    ids, home = set(), {}
    for pid in range(PROVINCE_COUNT):
        base = PROVINCE_TABLE_PRG + pid * PROVINCE_STRIDE
        for slot in range(PROVINCE_ROSTER_OFS,
                          PROVINCE_ROSTER_OFS + 10):
            oid = prg[base + slot]
            if oid != 0xFF:
                ids.add(oid)
                home[oid] = pid
    return ids, home


def load_arrival_schedule(prg):
    """Officer id -> (province id, appear year) from bank $31 $8B1C."""
    out = {}
    for pid in range(PROVINCE_COUNT):
        base = ARRIVAL_SCHEDULE_PRG + pid * ARRIVAL_SCHEDULE_STRIDE
        for pair in range(10):
            oid = prg[base + pair * 2]
            year = prg[base + pair * 2 + 1]
            if oid == 0xFF:
                break
            out[oid] = (pid, year)
    return out


def load_rows(rom_path=DEFAULT_ROM):
    prg, info = read_prg(rom_path)
    kanji = load_map()
    rostered, roster_province = load_province_roster(prg)
    schedule = load_arrival_schedule(prg)
    rows = []
    for oid in range(OFFICER_COUNT):
        nofs = NAME_TABLE_PRG + oid * NAME_STRIDE
        entry = prg[nofs:nofs + NAME_STRIDE]
        dofs = DATA_TABLE_PRG + oid * DATA_STRIDE
        rec = list(prg[dofs:dofs + DATA_STRIDE])
        m = kanji.get(oid, {})
        row = {
            'id': oid,
            'katakana': decode_name(entry),
            'zh_hans': m.get('zh_hans', ''),
            'kanji_ja': m.get('kanji_ja', ''),
            'pinyin': m.get('pinyin', ''),
            'name_offset': info['prg_start'] + nofs,
            'data_offset': info['prg_start'] + dofs,
            'bank_file': DATA_BANK_FILE[0],
            'bank_offset': oid * DATA_STRIDE,
            'in_province_roster': oid in rostered,
            'roster_province_id': roster_province.get(oid),
            'schedule_province_id': schedule.get(oid, (None, None))[0],
            'appear_year': schedule.get(oid, (None, None))[1],
        }
        row.update(decode_record(rec))
        rows.append(row)
    return rows, info


def check(rows):
    """Sanity-check the decode; returns a list of problems."""
    problems = []
    if len(rows) != OFFICER_COUNT:
        problems.append(f'expected {OFFICER_COUNT} rows, got {len(rows)}')
    for r in rows:
        if not r['katakana']:
            problems.append(f'id {r["id"]}: empty name')
        if not r['zh_hans']:
            problems.append(f'id {r["id"]}: no simplified-Chinese name')
        if r['location5'] != 0:
            problems.append(f'id {r["id"]}: +5 is {r["location5"]}, expected 0')
        for f in ('weapon', 'armor', 'army_affinity'):
            if r[f].startswith('?'):
                problems.append(f'id {r["id"]}: unknown {f} code {r[f][1:]}')
        for f in ('vitality', 'might', 'intelligence', 'loyalty', 'virtue'):
            if not 1 <= r[f] <= 100:
                problems.append(f'id {r["id"]}: {f} out of range ({r[f]})')
        # +11 bits 0-1 = OfficerStatus; the seed only carries 1 (hidden) or
        # 2 (rostered), and must agree with the independent Province roster
        st = r['officer_status_bits']
        if st not in SEED_STATUSES:
            problems.append(f'id {r["id"]}: seed OfficerStatus {st}, '
                            f'expected 1 or 2')
        elif (st == 2) != r['in_province_roster']:
            problems.append(
                f'id {r["id"]}: OfficerStatus {st} but '
                f'in_province_roster={r["in_province_roster"]} '
                f'(status 2 must equal "in a Province roster")')
        elif st == 1 and r['in_province_roster']:
            problems.append(f'id {r["id"]}: hidden officer is rostered')
    # loyalty 100 marks the playable rulers; the manual lists exactly seven
    rulers = [r['id'] for r in rows if r['loyalty'] == 100]
    if len(rulers) != 7:
        problems.append(f'expected 7 loyalty-100 rulers, got {rulers}')
    # the arrival schedule (bank $31 $8B1C) must cover every hidden officer
    # except a fixed set of 26 that never appear on schedule
    hidden_without_schedule = [r['id'] for r in rows
                               if r['officer_status_bits'] == 1
                               and r['appear_year'] is None]
    if len(hidden_without_schedule) != 26:
        problems.append(
            f'expected the 26 unscheduled hidden officers to have no arrival-'
            f'schedule entry, got {len(hidden_without_schedule)}')
    scheduled = [r['id'] for r in rows if r['appear_year'] is not None]
    if len(scheduled) != 154:
        problems.append(f'expected 154 scheduled officers, got {len(scheduled)}')
    if any(r['appear_year'] is not None and r['officer_status_bits'] != 1
           for r in rows):
        problems.append('an officer with an arrival-year entry is not hidden')
    return problems


COLUMNS = [
    ('id', 'id'), ('katakana', 'katakana'), ('zh_hans', '简体'),
    ('kanji_ja', 'kanji_ja'), ('pinyin', 'pinyin'),
    ('vitality', '体力'), ('might', '武力'), ('intelligence', '知力'),
    ('loyalty', '忠誠度'), ('virtue', '人徳'), ('officer_level', 'レベル'),
    ('experience', '経験値'), ('troop_count', '兵数'),
    ('army_affinity', '軍の属性'), ('officer_status', '状態'),
    ('weapon', '武器'), ('armor', '防具'),
]


def write_csv(rows, path):
    keys = [k for k, _ in COLUMNS] + ['weapon_index', 'armor_index',
                                      'army_affinity_bits',
                                      'officer_status_bits',
                                      'army_affinity_code',
                                      'in_province_roster',
                                      'roster_province_id',
                                      'schedule_province_id', 'appear_year',
                                      'data_offset', 'bank_file', 'bank_offset',
                                      'hex']
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=keys)
        w.writeheader()
        for r in rows:
            w.writerow({k: r[k] for k in keys})


def _pad(text, width):
    cells = sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1
                for c in text)
    return text + ' ' * max(0, width - cells)


def write_md(rows, path, info):
    with open(path, 'w', encoding='utf-8') as f:
        f.write('# Officer data extracted from the ROM\n\n')
        f.write('All 237 officers with their katakana name (as stored in the\n'
                'ROM), simplified-Chinese name, and starting data, read\n'
                'directly out of the iNES image by\n'
                '`tools/extract_officer_data.py`.\n\n')
        f.write(f'* PRG {info["prg_size"] // 1024} KB, '
                f'CHR {info["chr_size"] // 1024} KB, mapper '
                f'{info["mapper"]} (Namco 163)\n')
        f.write(f'* names: PRG `${NAME_TABLE_PRG:05X}`, '
                f'{NAME_STRIDE} bytes/entry (CPU `$901A`, bank `$30`, '
                f'`rom/prg/{NAME_BANK_FILE[0]}` + `${NAME_BANK_FILE[1]:04X}`)\n')
        f.write(f'* data: PRG `${DATA_TABLE_PRG:05X}`, '
                f'{DATA_STRIDE} bytes/record (CPU `$8000`, bank `$31`, '
                f'`rom/prg/{DATA_BANK_FILE[0]}` + `${DATA_BANK_FILE[1]:04X}`)\n\n')
        f.write('Both tables live in the two PRG banks that are only ever\n'
                'selected into the $8000-$9FFF data window (256 KB PRG =\n'
                '32 x 8 KB, so mapper register `$3n` selects physical bank\n'
                '`$0n`). `SramInit` (`$DD8B`, `asm/banks/prg_1d_1e.asm`) seeds\n'
                'SRAM from them, and `GetOfficerRomRecordAddr` (`$F387`) also\n'
                'reads the seed straight from ROM at runtime; see\n'
                '`code/initial_data_tables.md` for the byte-exact evidence.\n\n')
        f.write('## Record layout\n\n')
        f.write('The master record is the seed image of the officer\'s SRAM\n'
                'record at `id * 12 + $63C0`, i.e. the new-game starting\n'
                'state. `SramInit` copies `$0B40` bytes = 240 slots, so slots\n'
                '`$ED`-`$EF` are padding; every scan loop bounds itself at\n'
                '`CMP #$ED` (237). Column names use the canonical semantic\n'
                'English terms from `docs/manual_kb/terminology.md`.\n\n')
        f.write('| Offset | Field | Notes |\n|---|---|---|\n')
        for off, name, note in (
                ('`+0`', '体力 Vitality', '1-100'),
                ('`+1`', '武力 Might', '1-100'),
                ('`+2`', '知力 Intelligence', '1-100'),
                ('`+3`', '忠誠度 Loyalty', '100 = playable ruler'),
                ('`+4`', '人徳 Virtue', '1-100'),
                ('`+5`', '位置 LocationProvince', 'province id $00-$2D; runtime-only, always 0 in ROM'),
                ('`+6/+7`', '経験値 Experience', '16-bit LE; 0/1000/2000/3500/5000'),
                ('`+8/+9`', '兵数 TroopCount', '16-bit LE; non-zero only for officers on the map at the 189 start'),
                ('`+10`', '武器 Weapon / 防具 Armor', 'bits 0-4 weapon, bits 5-7 armor'),
                ('`+11`', 'レベル OfficerLevel / 軍の属性 ArmyAffinity / 状態 OfficerStatus', 'bits 4-7 level (0-based), bits 2-3 affinity (0 平 / 1 山 / 2 水), bits 0-1 status (1 hidden / 2 rostered in the seed; see below)')):
            f.write(f'| {off} | {name} | {note} |\n')
        f.write('\n### Equipment codes\n\n')
        f.write('Weapons come in three groups of eight; armor is ordered\n'
                'worst to best.\n\n')
        f.write('| 武器 | idx | | 防具 | idx |\n|---|---:|---|---|---:|\n')
        wk = sorted(WEAPONS)
        ak = sorted(ARMOR)
        for n in range(max(len(wk), len(ak))):
            wi = f'{WEAPONS[wk[n]]} | {wk[n]}' if n < len(wk) else ' | '
            ai = f'{ARMOR[ak[n]]} | {ak[n]}' if n < len(ak) else ' | '
            f.write(f'| {wi} | | {ai} |\n')
        f.write('\n軍の属性 / ArmyAffinity is bits 2-3 of `+11`: `0` = 平軍 '
                'PlainsArmy (111 officers), `1` = 山軍 MountainArmy (70),\n'
                '`2` = 水軍 NavalArmy (56); value `3` never occurs. The battle AI\n'
                'indexes its order-vector tables with the masked field\n'
                '(`prg_0e_0f.asm` `@OrderResolve` `$D110`: `LSR LSR AND #$03`),\n'
                'and every reader of the status nibble uses `AND #$03` /\n'
                '`ORA #$03`, so the two bit pairs are independent fields that\n'
                'happen to sit next to each other. (Reading the whole low\n'
                'nibble as one code was the earlier, coarser model: the seed\n'
                'only ever shows the six values `1`/`2`/`5`/`6`/`9`/`10`,\n'
                'because affinity 0/1/2 combines with status 1/2.)\n')
        f.write('\n### OfficerStatus (`+11` bits 0-1) and location (`+5`)\n\n')
        f.write('OfficerStatus *is* present in the ROM seed - it is what makes\n'
                'the new-game roster. Across the 237 seed records only two\n'
                'values occur, and they match the Province rosters exactly:\n\n')
        f.write('| seed `& $03` | count | independent cross-check |\n|---|---:|---|\n')
        f.write(
            '| `2` rostered | 57 | exactly the 57 distinct ids found in the '
            '30 Province roster slots (bank `$30` `$8C00`, `+$11..+$1A`); 55 of '
            'them also carry a non-zero 兵数 TroopCount, the exceptions being '
            '王甫 (id 16) and 黄権 (id 70) |\n')
        f.write(
            '| `1` hidden | 180 | none of them is in any roster; 154 have an '
            'entry in the bank-`$31` `$8B1C` arrival schedule, 26 do not |\n')
        f.write(
            '| `0` free, `3` out of action | 0 | never appear in the seed; the '
            'runtime writes them (defection clears the bits, `OfficerKill` sets '
            '`3`) |\n')
        f.write('\nRuntime meaning of the four values, decoded from the code\n'
                'that maintains them:\n\n')
        f.write('| `& $03` | Meaning | Key evidence |\n|---|---|---|\n')
        f.write(
            '| `0` | 在野 free / unaffiliated | `OfficerArrivalScan` fallback '
            '(prg_19_1a `$BA1A`) looks for free officers whose `+5` location '
            'matches the scouted province; defection paths clear the bits '
            '(prg_0a_0b `$CBE0`) |\n')
        f.write(
            '| `1` | hidden / not yet appeared (the seed state of the 180 '
            'officers off the map) | arrival-schedule scan '
            'prg_0a_0b `$C63B` only considers `&3 == 1` officers whose appear '
            'year has passed, and recruits them to the province roster as `2` '
            '(prg_0a_0b `$C657`); reinforcement scan prg_19_1a `$AF04` |\n')
        f.write(
            '| `2` | rostered to a province (the seed state of the 57 officers '
            'on the map) | `ValidateProvinceSlots` '
            '(prg_19_1a `$A59A`, debug): every non-empty province roster slot '
            'must hold a status-2 officer |\n')
        f.write(
            '| `3` | out of action (dead / removed; triggers ruler '
            'succession) | `OfficerKill` (prg_19_1a `$BDCA`) sets it via '
            '`ORA #$03` and `$FF`s the roster slot; prg_0a_0b `$CA4B` labels '
            'the already-3 case `@RulerAlreadyDead`; the year-end '
            '`OfficerStatusScene` (prg_19_1a `$ADD5`) arms '
            '`RulerSuccessionScene` on it; counted as excluded at '
            'prg_19_1a `$A284` |\n')
        f.write('\n`+5` 位置 LocationProvince holds the province id ($00-$2D)\n'
                'where the officer currently is. It is written whenever an\n'
                'officer changes location: a defecting roster officer is\n'
                're-tagged with the province he defects in\n'
                '(`prg_0a_0b.asm` `$CBE4`, post-succession pass; likewise the\n'
                'arrival relocation `prg_19_1a.asm` `$C0A1`), and the AI\n'
                'stationing pass assigns a free officer a province from the\n'
                'companion-province table $9D72 with a 1-in-8 roll\n'
                '(`prg_0a_0b.asm` `$AC3A`).\n\n'
                'Starting province and appearance year are *not* in this\n'
                'record; they live in the arrival schedule at bank `$31`\n'
                '`$8B1C`: ten (officer id, appear year) pairs per province\n'
                '(stride `$14`), walked by `OfficerArrivalScan`\n'
                '(`prg_19_1a.asm` `$B964`).\n')
        f.write('\n### Notes\n\n')
        f.write('* Records 237-239 exist in the 240-slot SRAM array but hold\n'
                '  unrelated bytes: `SramInit` copies `$0B40` bytes from\n'
                '  bank `$31` `$8000` to `$63C0`, while the officer table ends\n'
                '  at `$8B1C` (237 x 12), so the last `$24` bytes of the copy\n'
                '  window land on the head of the arrival schedule. No scan\n'
                '  loop ever reaches those slots (`CMP #$ED`), which is why the\n'
                '  officer count is 237.\n')
        f.write('* Experience only ever takes the five values that mark a\n'
                '  level boundary, so it is redundant with the level nibble -\n'
                '  except for id 71 侯成, who has 1000 experience but a level\n'
                '  nibble of 0. That looks like a data-entry slip in the\n'
                '  original ROM.\n')
        f.write('* Starting province and appearance year are read from the\n'
                '  bank-`$31` arrival schedule at `$8B1C` (see the status and\n'
                '  location section above), not from this record. For the 57\n'
                '  rostered officers the starting province is instead the\n'
                '  roster they appear in, and the 26 hidden officers with no\n'
                '  schedule entry can only be found by the reinforcement /\n'
                '  free-officer scans.\n')
        f.write('* The *状態* column is the seed value (`rostered` / `hidden`);\n'
                '  `free` and `out of action` exist only at runtime.\n')
        f.write('\n## Officers\n\n')
        head = [label for _, label in COLUMNS if label != 'kanji_ja']
        f.write('| ' + ' | '.join(head) + ' |\n')
        f.write('|' + '|'.join(['---'] * len(head)) + '|\n')
        for r in rows:
            cells = [str(r[k]) for k, label in COLUMNS if label != 'kanji_ja']
            f.write('| ' + ' | '.join(cells) + ' |\n')


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--rom', default=DEFAULT_ROM, help='iNES ROM image')
    ap.add_argument('--check', action='store_true', help='validate only')
    ap.add_argument('--print', dest='dump', action='store_true',
                    help='also dump the table to stdout')
    args = ap.parse_args()

    rows, info = load_rows(args.rom)
    problems = check(rows)
    for p in problems:
        print(f'FAIL: {p}', file=sys.stderr)
    if problems:
        return 1
    print(f'ok: {len(rows)} officer records read from '
          f'{os.path.basename(args.rom)} '
          f'(PRG {info["prg_size"] // 1024} KB, mapper {info["mapper"]})')

    if not args.check:
        out_dir = os.path.join(ROOT, 'docs')
        os.makedirs(out_dir, exist_ok=True)
        csv_path = os.path.join(out_dir, 'officer_data.csv')
        md_path = os.path.join(out_dir, 'officer_data.md')
        write_csv(rows, csv_path)
        write_md(rows, md_path, info)
        print(f'wrote {os.path.relpath(csv_path, ROOT)}')
        print(f'wrote {os.path.relpath(md_path, ROOT)}')

    if args.dump:
        print(f'{"id":>3}  {_pad("katakana", 14)}{_pad("简体", 8)}'
              f'{"体":>3}{"武":>4}{"知":>4}{"忠":>4}{"徳":>4}{"Lv":>4}'
              f'{"経験":>7}{"兵数":>6}  軍 状態      武器/防具')
        for r in rows:
            print(f'{r["id"]:>3}  {_pad(r["katakana"], 14)}'
                  f'{_pad(r["zh_hans"], 8)}'
                  f'{r["vitality"]:>3}{r["might"]:>4}{r["intelligence"]:>4}'
                  f'{r["loyalty"]:>4}{r["virtue"]:>4}{r["officer_level"]:>4}'
                  f'{r["experience"]:>7}{r["troop_count"]:>6}  '
                  f'{r["army_affinity"]} {_pad(r["officer_status"], 10)}'
                  f'{r["weapon"]}/{r["armor"]}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
