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
  +5       always 0 in ROM (runtime field)
  +6/+7    経験値   Experience, 16-bit little-endian
  +8/+9    兵数     TroopCount, 16-bit little-endian (non-zero only for the
                    officers already on the map in the 189 start year)
  +10      equipment, packed: bits 0-4 = 武器 (Weapon), bits 5-7 = 防具 (Armor)
  +11      bits 4-7 = レベル (OfficerLevel, 0-based; the game displays it +1)
           bits 0-3 = 軍の属性 (ArmyAffinity): {1,2} 平, {5,6} 山, {9,10} 水

Weapon indices fall into three groups of 8 (剣 / 刀 / 槍系) and armor is
ordered worst-to-best; both tables were recovered by correlating every record
against a published roster of this ROM and cross-checked against the scanned
manual (`docs/manual_kb/10-duel-mode.md` gives 呂布 = 方天画戟 + 甲冑, which is
exactly what record 218 decodes to).

Simplified-Chinese names are joined in from tools/data/officer_kanji.tsv.

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

WEAPONS = {
    0: '短剣', 1: '飛剣', 2: '長剣', 3: '破斬剣', 4: '大剣',
    8: '薤刀', 9: '眉尖刀', 10: '三尖刀', 11: '鉤鐮刀', 12: '偃月刀',
    13: '鳳嘴刀',
    16: '矛', 17: '双戟', 18: '単鉤槍', 19: '戦斧', 20: '双鉤槍',
    21: '方天画戟',
}
ARMOR = {0: '綸巾', 1: '籠手', 2: '兜', 3: '硬皮', 4: '鶴氅', 5: '甲冑'}
# 軍の属性 (ArmyAffinity), low nibble of +11; the game only stores these six
ARMY_AFFINITY = {1: '平', 2: '平', 5: '山', 6: '山', 9: '水', 10: '水'}


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
    レベル = OfficerLevel, 軍の属性 = ArmyAffinity).
    """
    weapon_index = rec[10] & 0x1F
    armor_index = rec[10] >> 5
    affinity_code = rec[11] & 0x0F
    return {
        'vitality': rec[0],
        'might': rec[1],
        'intelligence': rec[2],
        'loyalty': rec[3],
        'virtue': rec[4],
        'officer_level': (rec[11] >> 4) + 1,
        'experience': rec[6] | (rec[7] << 8),
        'troop_count': rec[8] | (rec[9] << 8),
        'army_affinity': ARMY_AFFINITY.get(affinity_code, f'?{affinity_code}'),
        'weapon': WEAPONS.get(weapon_index, f'?{weapon_index}'),
        'armor': ARMOR.get(armor_index, f'?{armor_index}'),
        'weapon_index': weapon_index,
        'armor_index': armor_index,
        'army_affinity_code': affinity_code,
        'unused5': rec[5],
        'hex': bytes(rec).hex().upper(),
    }


def load_rows(rom_path=DEFAULT_ROM):
    prg, info = read_prg(rom_path)
    kanji = load_map()
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
        if r['unused5'] != 0:
            problems.append(f'id {r["id"]}: +5 is {r["unused5"]}, expected 0')
        for f in ('weapon', 'armor', 'army_affinity'):
            if r[f].startswith('?'):
                problems.append(f'id {r["id"]}: unknown {f} code {r[f][1:]}')
        for f in ('vitality', 'might', 'intelligence', 'loyalty', 'virtue'):
            if not 1 <= r[f] <= 100:
                problems.append(f'id {r["id"]}: {f} out of range ({r[f]})')
    # loyalty 100 marks the playable rulers; the manual lists exactly seven
    rulers = [r['id'] for r in rows if r['loyalty'] == 100]
    if len(rulers) != 7:
        problems.append(f'expected 7 loyalty-100 rulers, got {rulers}')
    return problems


COLUMNS = [
    ('id', 'id'), ('katakana', 'katakana'), ('zh_hans', '简体'),
    ('kanji_ja', 'kanji_ja'), ('pinyin', 'pinyin'),
    ('vitality', '体力'), ('might', '武力'), ('intelligence', '知力'),
    ('loyalty', '忠誠度'), ('virtue', '人徳'), ('officer_level', 'レベル'),
    ('experience', '経験値'), ('troop_count', '兵数'),
    ('army_affinity', '軍の属性'), ('weapon', '武器'), ('armor', '防具'),
]


def write_csv(rows, path):
    keys = [k for k, _ in COLUMNS] + ['weapon_index', 'armor_index',
                                      'army_affinity_code', 'data_offset',
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
                f'{NAME_STRIDE} bytes/entry (CPU `$901A`, bank `$30`)\n')
        f.write(f'* data: PRG `${DATA_TABLE_PRG:05X}`, '
                f'{DATA_STRIDE} bytes/record (CPU `$8000`, bank `$31`)\n\n')
        f.write('## Record layout\n\n')
        f.write('The master record is the seed image of the officer\'s SRAM\n'
                'record at `id * 12 + $63C0`, i.e. the new-game starting\n'
                'state. Column names use the canonical semantic English\n'
                'terms from `docs/manual_kb/terminology.md`.\n\n')
        f.write('| Offset | Field | Notes |\n|---|---|---|\n')
        for off, name, note in (
                ('`+0`', '体力 Vitality', '1-100'),
                ('`+1`', '武力 Might', '1-100'),
                ('`+2`', '知力 Intelligence', '1-100'),
                ('`+3`', '忠誠度 Loyalty', '100 = playable ruler'),
                ('`+4`', '人徳 Virtue', '1-100'),
                ('`+5`', '-', 'always 0 in ROM (runtime field)'),
                ('`+6/+7`', '経験値 Experience', '16-bit LE; 0/1000/2000/3500/5000'),
                ('`+8/+9`', '兵数 TroopCount', '16-bit LE; non-zero only for officers on the map at the 189 start'),
                ('`+10`', '武器 Weapon / 防具 Armor', 'bits 0-4 weapon, bits 5-7 armor'),
                ('`+11`', 'レベル OfficerLevel / 軍の属性 ArmyAffinity', 'bits 4-7 level (0-based), bits 0-3 affinity')):
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
        f.write('\n軍の属性 / ArmyAffinity (low nibble of `+11`) only ever takes\n'
                'six values, in pairs: `1`/`2` = 平軍 PlainsArmy, `5`/`6` = 山軍\n'
                'MountainArmy, `9`/`10` = 水軍 NavalArmy. The affinity itself\n'
                'is `(n - 1) / 4`; what distinguishes the two values within\n'
                'each pair is not yet known.\n')
        f.write('\n### Notes\n\n')
        f.write('* Records 237-239 exist in the 240-slot array but hold\n'
                '  unrelated bytes, which is why the officer count is 237.\n')
        f.write('* Experience only ever takes the five values that mark a\n'
                '  level boundary, so it is redundant with the level nibble -\n'
                '  except for id 71 侯成, who has 1000 experience but a level\n'
                '  nibble of 0. That looks like a data-entry slip in the\n'
                '  original ROM.\n')
        f.write('* Starting province and appearance year are *not* in this\n'
                '  record; they live in a separate scenario table.\n')
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
              f'{"経験":>7}{"兵数":>6}  軍 武器/防具')
        for r in rows:
            print(f'{r["id"]:>3}  {_pad(r["katakana"], 14)}'
                  f'{_pad(r["zh_hans"], 8)}'
                  f'{r["vitality"]:>3}{r["might"]:>4}{r["intelligence"]:>4}'
                  f'{r["loyalty"]:>4}{r["virtue"]:>4}{r["officer_level"]:>4}'
                  f'{r["experience"]:>7}{r["troop_count"]:>6}  '
                  f'{r["army_affinity"]} {r["weapon"]}/{r["armor"]}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
