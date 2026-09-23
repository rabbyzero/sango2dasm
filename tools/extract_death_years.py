#!/usr/bin/env python3
"""Extract the per-officer natural-death year table from the ROM.

The strategy-mode turn-start death check (OfficerNaturalDeathScene /
DeathChanceRoll in asm/banks/prg_19_1a.asm, bank $19 $BD28) reads a
one-byte-per-officer table from bank $31 (mapper page $31 -> PRG $22000)
at CPU $9C58. Each byte stores death_year - 100; the monthly death roll
starts in the year table[id] + 100.

Writes docs/officer_death_years.csv and docs/officer_death_years.md.
"""
import csv
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRG_COMBINED = os.path.join(ROOT, 'rom', 'prg_combined.bin')
OFFICER_CSV = os.path.join(ROOT, 'docs', 'officer_data.csv')
TABLE_CPU = 0x9C58          # CPU address inside the bank-$31 window
BANK31_PRG_BASE = 0x22000   # mapper page $31 (5-bit mask) -> PRG offset
OFFICER_COUNT = 237         # officer ids $00-$EC


def load_table():
    with open(PRG_COMBINED, 'rb') as f:
        rom = f.read()
    off = BANK31_PRG_BASE + (TABLE_CPU - 0x8000)
    return list(rom[off:off + OFFICER_COUNT])


def load_names():
    names = []
    with open(OFFICER_CSV, newline='', encoding='utf-8') as f:
        for row in csv.DictReader(f):
            names.append((int(row['id']), row['katakana'], row['kanji_ja'],
                          row['zh_hans'], row['pinyin']))
    return names


def write_csv(rows, path):
    with open(path, 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(['id', 'katakana', 'kanji_ja', 'zh_hans', 'pinyin',
                    'table_byte', 'death_year'])
        w.writerows(rows)


def write_md(rows, path):
    with open(path, 'w', encoding='utf-8') as f:
        w = f.write
        w('# Officer natural-death years (シホウ death table)\n\n')
        w('Extracted from the bank-$31 death-year table at CPU `$9C58`\n')
        w('(PRG `$23C58`), one byte per officer id `$00-$EC`. Each byte\n')
        w('stores `death_year - 100`; from that year on, every strategy\n')
        w('turn (month) the officer rolls death against\n')
        w('`DeathChanceThreshold` in `asm/banks/prg_19_1a.asm`\n')
        w('(`DeathChanceRoll`, $BD28).\n\n')
        w('| id | name | 漢字 | death year | table byte |\n')
        w('|---:|---|---|---:|---:|\n')
        for r in rows:
            w('| %d | %s | %s | %d | $%02X |\n' % (
                r[0], r[1], r[2], r[6], r[5]))


def main():
    table = load_table()
    names = load_names()
    if len(names) != OFFICER_COUNT:
        print('officer_data.csv rows != %d' % OFFICER_COUNT, file=sys.stderr)
        return 1
    rows = []
    for oid, kata, kanji, hans, pinyin in names:
        b = table[oid]
        rows.append((oid, kata, kanji, hans, pinyin, b, b + 100))
    out_dir = os.path.join(ROOT, 'docs')
    csv_path = os.path.join(out_dir, 'officer_death_years.csv')
    md_path = os.path.join(out_dir, 'officer_death_years.md')
    write_csv(rows, csv_path)
    write_md(rows, md_path)
    print('wrote docs/officer_death_years.csv')
    print('wrote docs/officer_death_years.md')
    return 0


if __name__ == '__main__':
    sys.exit(main())
