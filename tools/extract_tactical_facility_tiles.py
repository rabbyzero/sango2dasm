#!/usr/bin/env python3
"""Extract the ProvinceTacticalFacilityTiles (bank $31 / physical $11, $9BA4-$9C57)
and write docs/province_tactical_facility_tiles.csv + docs/province_tactical_facility_tiles.md.

30 rows x 6 bytes: three ordered (X,Y) tile pairs per province - the
facility locations of the province's tactical-mode battlefield (32x32 tile
grid). Fixed slot order (see code/tactical_facility_tile_decode.md for the reader
evidence):

  +0/+1  House    民家  rice market   - march target of Action_BuyRice
                                       (prg_08_09 $A329, sliding *3 index)
  +2/+3  Armory   武器屋             - remaining manual village facility,
                                       by elimination
  +4/+5  Hospital 病院               - march target of Action_RestoreHP
                                       (prg_08_09 $A507, entry +4/+5)

A pair is unused when its X byte has bit7 set (readers BMI/BPL; the padding
stored is $FF $FF). The stride-6 readers are DrawStratagemTargetMarkers
(prg_08_09 $D24D, city-target markers at each pair) and
MoveState_CheckDest (prg_0c_0d $A4DD, scans the 3 pairs against the
move destination; a match enters the war action panel state $09).

Usage:
    python tools/extract_tactical_facility_tiles.py            # write output files
    python tools/extract_tactical_facility_tiles.py --print    # also dump the table
"""
import argparse
import csv
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK_PATH = os.path.join(ROOT, 'rom', 'prg', 'prg_11.bin')
PROV_CSV = os.path.join(ROOT, 'docs', 'province_data.csv')
RICE_CSV = os.path.join(ROOT, 'docs', 'rice_prices.csv')
OUT_CSV = os.path.join(ROOT, 'docs', 'province_tactical_facility_tiles.csv')
OUT_MD = os.path.join(ROOT, 'docs', 'province_tactical_facility_tiles.md')

FACILITY_TILE_CPU = 0x9BA4
STRIDE = 6
PROV_COUNT = 30
SLOTS = (('House', '民家'), ('Armory', '武器屋'), ('Hospital', '病院'))


def load_rows():
    with open(BANK_PATH, 'rb') as f:
        data = f.read()
    base = FACILITY_TILE_CPU - 0x8000
    rows = []
    for pid in range(PROV_COUNT):
        chunk = data[base + pid * STRIDE:base + (pid + 1) * STRIDE]
        assert len(chunk) == STRIDE, 'bank $11 short at province %d' % pid
        rows.append(chunk)
    return rows


def load_provinces():
    with open(PROV_CSV, newline='', encoding='utf-8') as f:
        return {int(r['id']): r for r in csv.DictReader(f)}


def load_markets():
    with open(RICE_CSV, newline='', encoding='utf-8') as f:
        return {int(r['province_id']): r['has_market'] for r in csv.DictReader(f)}


def used(chunk, i):
    return chunk[2 * i] < 0x80


def write_csv(rows, provs, markets):
    with open(OUT_CSV, 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(['province_id', 'province', 'katakana', 'has_strategy_market']
                   + [c for name, _ in SLOTS
                      for c in (name.lower() + '_x_hex', name.lower() + '_y_hex',
                                name.lower() + '_x', name.lower() + '_y')])
        for pid, chunk in enumerate(rows):
            p = provs[pid]
            line = [pid, '%s %s' % (p['zh_hans'], p['katakana']), p['katakana'],
                    markets.get(pid, '?')]
            for i in range(3):
                if used(chunk, i):
                    line += ['$%02X' % chunk[2 * i], '$%02X' % chunk[2 * i + 1],
                             chunk[2 * i], chunk[2 * i + 1]]
                else:
                    line += ['', '', '', '']
            w.writerow(line)


def write_md(rows, provs, markets):
    lines = ['# ProvinceTacticalFacilityTiles - tactical-map facility tiles',
             '',
             'Bank $31 (physical `rom/prg/prg_11.bin`) `$9BA4-$9C57`, label',
             '`ProvinceTacticalFacilityTiles` in `asm/banks/data_11.asm`. 30 rows x 6 bytes;',
             'three ordered (X,Y) tile pairs per province giving the facility',
             'locations of that province\'s tactical-mode battlefield (32x32 tile',
             'grid, values observed $01-$1D). Slot order: 0 House 民家 (rice market),',
             '1 Armory 武器屋, 2 Hospital 病院. Pair unused when X has bit7 set',
             '(stored `$FF $FF`). Full reader evidence: `code/tactical_facility_tile_decode.md`.',
             '',
             '| id | province | House 民家 (X,Y) | Armory 武器屋 (X,Y) | Hospital 病院 (X,Y) |',
             '|---:|---|---|---|---|']
    for pid, chunk in enumerate(rows):
        p = provs[pid]
        cells = []
        for i in range(3):
            cells.append('—' if not used(chunk, i)
                         else '(%02X,%02X) = (%d,%d)' % (
                             chunk[2 * i], chunk[2 * i + 1],
                             chunk[2 * i], chunk[2 * i + 1]))
        lines.append('| %d | %s %s | %s | %s | %s |'
                     % (pid, p['zh_hans'], p['katakana'], *cells))
    lines += ['',
              'Slot occupancy: %d provinces use the House slot, %d the Armory,'
              % (sum(used(c, 0) for c in rows), sum(used(c, 1) for c in rows)),
              'and %d the Hospital slot (%d use all three). The House slot does'
              % (sum(used(c, 2) for c in rows),
                 sum(used(c, 0) and used(c, 1) and used(c, 2) for c in rows)),
              'not equal the strategy-layer 商店 market flag',
              '(docs/rice_prices.csv): 青州 has a market but no House tile, 襄阳',
              'the reverse.', '']
    with open(OUT_MD, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--print', action='store_true')
    args = ap.parse_args()
    rows = load_rows()
    provs = load_provinces()
    markets = load_markets()
    write_csv(rows, provs, markets)
    write_md(rows, provs, markets)
    print('wrote %s and %s' % (OUT_CSV, OUT_MD))
    if args.print:
        for pid, chunk in enumerate(rows):
            print('%2d %-14s m=%-3s %s' % (
                pid, provs[pid]['katakana'], markets.get(pid, '?'),
                '  '.join('%s(%02X,%02X)' % (SLOTS[i][0], chunk[2 * i],
                                             chunk[2 * i + 1]) if used(chunk, i)
                          else '%s--' % SLOTS[i][0] for i in range(3))))
    return 0


if __name__ == '__main__':
    sys.exit(main())
