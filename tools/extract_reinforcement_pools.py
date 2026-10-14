#!/usr/bin/env python3
"""Extract the family-heir reinforcement pools from the ROM.

Each January, EventReinforceGate ($A33C, prg_19_1a_event_scenes) picks the acting
Country's pool from the pointer table at bank $31 $8D74 (Countries 2/3/4,
with 6 aliasing slot 3; 0/1/5 have none), and OfficerReinforceScene ($AEC0)
inducts the FIRST still-hidden officer (record[$0B] & 3 == 1) whose join
year has arrived into the Country's home Province roster (status <- 2,
officer card shown). The four $FF-terminated (Officer id, join year) lists
hold exactly the 26 hidden officers that have no arrival-schedule entry.

Pointer layout: $8D74-$8D7B holds 4 little-endian words whose HIGH byte is
stored biased by -$60 (the reader adds #$60 back), each pointing at one
list inside $8D7C-$8DB3. Unlike the arrival schedule at $8B1C (which stores
the display year and subtracts $64 at @ScheduleYear $B9C0), @ReinforceScan
($AF10/$AF12) compares the pair byte straight against $6F00, so here
byte = year - 100.

The CSV this writes is the editing surface:
tools/officer_model.py loads it, editor/officer_editor.py and
editor/officer_cli.py edit it, and tools/gen_data_bank_asm.py --from-csv
re-renders the ReinforceCandidatePtrTable / ReinforceCandidateList_N blocks
of asm/banks/data_11_officer.asm from it (tools/verify_data_banks.py gates the
bytes).

Usage:
    python tools/extract_reinforcement_pools.py            # write output
    python tools/extract_reinforcement_pools.py --print    # also to stdout
"""
import argparse
import csv
import os
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRG_COMBINED = os.path.join(ROOT, 'rom', 'prg_combined.bin')
OFFICER_CSV = os.path.join(ROOT, 'docs', 'officer_data.csv')
PTR_CPU = 0x8D74            # pointer table, bank-$31 window
PTR_COUNT = 4
POOL_COUNTRIES = (2, 3, 4, 6)   # EventReinforceGate: Country 6 aliases slot 3
HI_BIAS = 0x60              # stored high byte = target hi - $60
YEAR_OFFSET = 100           # byte = display year - 100
WINDOW_BASE = 0x22000       # mapper page $31 -> PRG offset
REGION_END = 0x8DB4         # the kanji plate table starts right after


def load_pools():
    with open(PRG_COMBINED, 'rb') as f:
        rom = f.read()
    base = WINDOW_BASE + (PTR_CPU - 0x8000)
    words = [rom[base + i * 2] | ((rom[base + i * 2 + 1] + HI_BIAS) << 8)
             for i in range(PTR_COUNT)]
    pools = []
    for word in words:
        cursor = WINDOW_BASE + (word - 0x8000)
        pairs = []
        while rom[cursor] != 0xFF:
            pairs.append((rom[cursor], rom[cursor + 1] + YEAR_OFFSET))
            cursor += 2
        if cursor >= WINDOW_BASE + (REGION_END - 0x8000):
            raise SystemExit('reinforcement list from $%04X is not '
                             '$FF-terminated before $%04X' % (word, REGION_END))
        pools.append(pairs)
    return words, pools


def load_names():
    names = {}
    with open(OFFICER_CSV, newline='', encoding='utf-8') as f:
        for row in csv.DictReader(f):
            names[int(row['id'])] = (row['katakana'], row['zh_hans'])
    return names


def check(pools):
    problems = []
    ids = [oid for pairs in pools for oid, _ in pairs]
    if sorted(ids) != sorted(set(ids)):
        problems.append('an officer appears in two pools')
    if len(ids) != 26:
        problems.append('expected the 26 unscheduled heirs, got %d' % len(ids))
    for oid in ids:
        if not 0 <= oid < 237:
            problems.append('pool officer id %d out of range' % oid)
    years = [y for pairs in pools for _, y in pairs]
    if min(years) < 150 or max(years) > 255:
        problems.append('join years %d-%d look wrong for the byte encoding'
                        % (min(years), max(years)))
    return problems


COLUMNS = ['pool', 'country', 'officer_id', 'katakana', 'zh_hans',
           'table_byte', 'join_year']


def write_csv(pools, names, path):
    with open(path, 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(COLUMNS)
        for pool, pairs in enumerate(pools):
            for oid, year in pairs:
                kata, hans = names.get(oid, ('?', '?'))
                w.writerow([pool, POOL_COUNTRIES[pool], oid, kata, hans,
                            year - YEAR_OFFSET, year])


def _pad(text, width):
    cells = sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1
                for c in str(text))
    return str(text) + ' ' * max(0, width - cells)


def write_md(pools, names, path):
    with open(path, 'w', encoding='utf-8') as f:
        f.write('# Family-heir reinforcement pools (bank $31 $8D74)\n\n')
        f.write('Each January `EventReinforceGate` (`$A33C`, prg_19_1a_event_scenes) picks\n')
        f.write('the acting Country\'s pool - Countries 2/3/4, with 6 aliasing\n')
        f.write('slot 3; Countries 0/1/5 have none - and\n')
        f.write('`OfficerReinforceScene` (`$AEC0`) inducts the FIRST still-\n')
        f.write('hidden officer whose year has arrived into the Country\'s\n')
        f.write('home Province roster (状態 <- 2, officer card shown). The\n')
        f.write('byte stored is `year - 100` (`@ReinforceScan` $AF12 compares\n')
        f.write('it straight against $6F00).\n\n')
        f.write('These are exactly the 26 hidden officers with no arrival-\n')
        f.write('schedule entry, grouped by family. Editing surface:\n')
        f.write('`docs/officer_reinforcement.csv` (this file\'s CSV twin),\n')
        f.write('re-rendered into `asm/banks/data_11_officer.asm` by\n')
        f.write('`tools/gen_data_bank_asm.py --from-csv`.\n\n')
        for pool, pairs in enumerate(pools):
            f.write('## Pool %d -> Country %d\n\n' % (pool,
                                                      POOL_COUNTRIES[pool]))
            f.write('| officer | name | join year | byte |\n|---|---|---:|---:|\n')
            for oid, year in pairs:
                kata, hans = names.get(oid, ('?', '?'))
                f.write('| %d | %s %s | %d | $%02X |\n'
                        % (oid, hans, _pad(kata, 0).strip(), year,
                           year - YEAR_OFFSET))
            f.write('\n')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--print', dest='show', action='store_true',
                    help='also print the pools to stdout')
    args = ap.parse_args()
    words, pools = load_pools()
    names = load_names()
    problems = check(pools)
    if problems:
        for line in problems:
            print('FAIL: %s' % line, file=sys.stderr)
        return 1
    if args.show:
        for pool, (word, pairs) in enumerate(zip(words, pools)):
            print('pool %d (Country %d, <- $%04X): %s'
                  % (pool, POOL_COUNTRIES[pool], word,
                     ' '.join('%d(%s)->%d' % (oid, names.get(oid, ('?', '?'))[1],
                                              year)
                              for oid, year in pairs)))
    write_csv(pools, names, os.path.join(ROOT, 'docs',
                                         'officer_reinforcement.csv'))
    write_md(pools, names, os.path.join(ROOT, 'docs',
                                        'officer_reinforcement.md'))
    print('wrote docs/officer_reinforcement.csv')
    print('wrote docs/officer_reinforcement.md')
    return 0


if __name__ == '__main__':
    sys.exit(main())
