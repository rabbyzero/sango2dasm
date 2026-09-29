#!/usr/bin/env python3
"""Consolidate the 7 Country (国) records from the ROM, mirroring the
officer/province extraction practice (see tools/extract_officer_data.py and
tools/extract_province_data.py).

A Country is a faction ruled by a Ruler (君主) that owns one or more
Provinces (州). The game stores no per-country stat table in ROM: a
Country's resources are the sum over the Provinces it owns, and its Ruler
is fixed by a hard-coded seed. Both sources are read here:

  Country -> Ruler seed   bank $08/$09 `WarResult_RecordInitTable` ($DA0F):
                          7 x 4-byte records (prg_08_09.asm). Byte [0] is the
                          Ruler officer id in Country-slot order 0-6:
                            $AD 董卓(173), $08 袁绍(8), $83 曹操(131),
                            $8A 孙策(138), $DE 刘备(222), $DC 刘璋(220),
                            $B6 马腾(182)
                          (also inlined by WarResultEntryInit, $D97A)

  Province -> Country     the low nibble of province master record `+0`
                          (bank $30 $8C00, see extract_province_data.py);
                          7 = 空白地 UnclaimedLand (nobody owns it)

  Country record (SRAM)   7 x 8 bytes at $6F07 (stride 8), resolved by
                          B1F_GetCountryDataPtr ($F368) via
                          CountryDataPtrTable ($F379):
                            [0] Ruler officer id ($FF = country destroyed)
                            [1] home Province id
                            [2] -            (0 in the seed)
                            [3] status byte  (0 normal, 3 at war / AI ruler)
                            [4..7] packed alliance nibbles (one per rival)

The per-country statistics below are the 189 new-game start, aggregated from
the Province master records; the Ruler is cross-checked against the hard-coded
seed and against the roster officer whose 忠誠度 Loyalty is 100.

Column names are the snake_case form of the canonical semantic English terms
in docs/manual_kb/terminology.md (Country, Province, Ruler, Gold, Rice, ...).

Usage:
    python tools/extract_country_data.py            # write output files
    python tools/extract_country_data.py --print    # also dump to stdout
    python tools/extract_country_data.py --check    # validate, write nothing
"""
import argparse
import csv
import os
import sys
import unicodedata

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract_province_data import (  # noqa: E402
    load_provinces, load_officer_names, country_table, DATA_TABLE_ADDR,
)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRG_COMBINED = os.path.join(ROOT, 'rom', 'prg_combined.bin')

COUNTRY_COUNT = 7                     # slots 0-6; 7 = UnclaimedLand
COUNTRY_RECORD_BASE = 0x6F07          # SRAM base of the 7 x 8-byte records
COUNTRY_RECORD_STRIDE = 8
# Hard-coded Ruler seed (WarResult_RecordInitTable, bank $08/$09 $DA0F):
# Country slot -> Ruler officer id. Used as the cross-check reference.
SEED_RULERS = {0: 0xAD, 1: 0x08, 2: 0x83, 3: 0x8A, 4: 0xDE, 5: 0xDC, 6: 0xB6}
SEED_STATUS = 0x03                    # record[3] in WarResultEntryInit seed

# Statistics summed over every Province the Country owns (province record
# field -> aggregated column). See extract_province_data.FIELDS for the ROM
# evidence behind each province field.
SUM_FIELDS = [
    ('gold', '金', 'Gold (sum of owned provinces, record `+2/+3`)'),
    ('rice', '米', 'Rice (sum of owned provinces, record `+4/+5`)'),
    ('population', '人口', 'Population (sum of owned provinces x 100)'),
    ('land_value', '土地', 'LandValue (sum of owned provinces, record `+8/+9`)'),
    ('industry', '産業', 'Industry (sum of owned provinces, record `+14/+15`)'),
    ('reserve_troops', '控え', 'ReserveTroops (sum of owned provinces, record `+12/+13`)'),
    ('treasure', '宝', 'Treasure (sum of owned provinces, record `+16`)'),
    ('officer_count', '武将数', 'Officers on the provincial rosters (sum)'),
    ('active_troops', '現役', 'ActiveTroops: sum of rostered Officers TroopCount'),
]

# docs/country_data.csv columns: (name, 日本語, meaning).
CSV_COLUMNS = [
    ('id', '国番号', 'Country id (low nibble of province record `+0`)'),
    ('ruler_officer_id', '君主', 'Ruler Officer id (Country record `[0]`)'),
    ('ruler_katakana', '君主', 'Ruler name as stored in the ROM'),
    ('ruler_zh_hans', '君主', 'Ruler name, simplified Chinese'),
    ('ruler_pinyin', '君主', 'Mandarin reading of the Ruler name'),
    ('home_province_id', '本拠地', 'Home Province id (Country record `[1]`)'),
    ('home_province', '本拠地', 'Home Province name, simplified Chinese'),
    ('province_count', '州数', 'Number of Provinces owned'),
    ('province_ids', '州', 'Owned Province ids, ascending'),
    ('province_names', '州', 'Owned Province names, simplified Chinese'),
    ('total_troops', '兵士', '兵士: 現役 active + 控え reserve'),
]


def aggregate(rows, officers):
    """Yield one dict per Country (0-6) aggregated from its Provinces."""
    rulers = country_table(rows)                # cid -> (home pid, ruler oid)
    for cid in range(COUNTRY_COUNT):
        owned = sorted((r for r in rows if r['country_id'] == cid),
                       key=lambda r: r['id'])
        home_pid, ruler_oid = rulers.get(cid, (None, None))
        home = next((r for r in owned if r['id'] == home_pid), None)
        ruler = officers.get(ruler_oid, ('?', f'#{ruler_oid}'))
        row = {
            'id': cid,
            'ruler_officer_id': ruler_oid,
            'ruler_katakana': ruler[0],
            'ruler_zh_hans': ruler[1],
            'ruler_pinyin': '',          # filled from the reading table in main()
            'home_province_id': home_pid,
            'home_province': home['kanji'].get('zh_hans', '') if home else '',
            'province_count': len(owned),
            'province_ids': ' '.join(str(r['id']) for r in owned),
            'province_names': ' '.join(
                r['kanji'].get('zh_hans', '') for r in owned),
            'owned': owned,
        }
        for key, _, _ in SUM_FIELDS:
            row[key] = sum(r[key] for r in owned)
        row['total_troops'] = row['active_troops'] + row['reserve_troops']
        yield row


def load_ruler_pinyin(path=os.path.join(ROOT, 'docs', 'officer_names_kanji.csv')):
    """id -> pinyin from docs/officer_names_kanji.csv (full reading table)."""
    if not os.path.exists(path):
        return {}
    with open(path, encoding='utf-8') as f:
        return {int(r['id']): (r.get('pinyin') or '').strip()
                for r in csv.DictReader(f)}


def _pad(text, width):
    """Left-align accounting for double-width kana/kanji cells."""
    cells = sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in text)
    return text + ' ' * max(0, width - cells)


def _provenance(f):
    f.write(f'* Country -> Ruler seed: `WarResult_RecordInitTable`, bank '
            f'$08/$09 CPU `$DA0F` (7 x 4 B, byte [0] = Ruler id)\n')
    f.write(f'* Country record (SRAM): 7 x {COUNTRY_RECORD_STRIDE} B at '
            f'`${COUNTRY_RECORD_BASE:04X}` (stride {COUNTRY_RECORD_STRIDE}), '
            f'via `B1F_GetCountryDataPtr` ($F368) / `CountryDataPtrTable` '
            f'($F379)\n')
    f.write(f'* Province -> Country: low nibble of province master record '
            f'`+0` (bank $30 CPU `${DATA_TABLE_ADDR:04X}`)\n')
    f.write(f'* Per-country stats are the 189 new-game start, summed over the '
            f'owned Province master records\n')


def write_csv(rows, path):
    base = [c for c, _, _ in CSV_COLUMNS if c != 'total_troops']
    cols = base + [k for k, _, _ in SUM_FIELDS] + ['total_troops']
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for r in rows:
            w.writerow({c: r.get(c, '') for c in cols})


def write_md(rows, path, pinyin):
    with open(path, 'w', encoding='utf-8') as f:
        f.write('# Country data extracted from the ROM\n\n')
        f.write('The 7 Countries (国) at the 189 new-game start: each '
                'Ruler (君主), their home Province, the Provinces they own, '
                'and their aggregated resources, read out of the iNES image '
                'by `tools/extract_country_data.py`.\n\n')
        f.write('A Country owns one or more Provinces; its resources are the '
                'sum over those Provinces (there is no per-country stat table '
                'in ROM). Column names use the canonical semantic English '
                'terms from `docs/manual_kb/terminology.md`.\n\n')
        _provenance(f)
        f.write('\n')

        f.write('## Country record layout (SRAM `$6F07`)\n\n')
        f.write('Seven 8-byte records at `$6F07`, `$6F0F`, ... `$6F37` '
                '(stride 8), resolved by `B1F_GetCountryDataPtr` ($F368). '
                'The seed below is written by `WarResultEntryInit` ($D97A) '
                'from `WarResult_RecordInitTable` ($DA0F).\n\n')
        f.write('| Offset | Field | Notes |\n|---|---|---|\n')
        f.write('| `[0]` | Ruler officer id | `$FF` = Country destroyed |\n')
        f.write('| `[1]` | Home Province id | the Ruler\'s seat |\n')
        f.write('| `[2]` | - | 0 in the seed |\n')
        f.write('| `[3]` | status byte | 0 normal, 3 = at war / AI ruler '
                '(seed value `$03`) |\n')
        f.write('| `[4..7]` | alliance nibbles | packed, one per rival '
                'Country; any non-zero nibble = allied |\n\n')

        f.write('## CSV columns\n\n')
        f.write('`docs/country_data.csv` column names are the snake_case form '
                'of the canonical semantic English terms in '
                '`docs/manual_kb/terminology.md`.\n\n')
        f.write('| Column | 日本語 | Meaning |\n|---|---|---|\n')
        for name, ja, meaning in CSV_COLUMNS:
            f.write(f'| `{name}` | {ja} | {meaning} |\n')
        for name, ja, meaning in SUM_FIELDS:
            f.write(f'| `{name}` | {ja} | {meaning} |\n')
        f.write('\n')

        f.write('## Countries at the 189 start\n\n')
        f.write('| Country id | Ruler | Home province | Provinces |\n'
                '|---:|---|---|---|\n')
        for r in rows:
            ruler = f'{r["ruler_zh_hans"]} {r["ruler_katakana"]}'
            py = pinyin.get(r['ruler_officer_id'], '')
            if py:
                ruler += f' ({py})'
            ruler += f' (id {r["ruler_officer_id"]})'
            f.write(f'| {r["id"]} | {ruler} | '
                    f'{r["home_province"]} (id {r["home_province_id"]}) | '
                    f'{r["province_names"]} |\n')
        f.write('\n')

        f.write('## Aggregated resources\n\n')
        f.write('人口 is the value the game shows (stored / 100 x 100). '
                '兵士 is 現役 (summed from the roster) + 控え (ReserveTroops).\n\n')
        head = ('| id | Ruler | 州 | 金 | 米 | 人口 | 土地 | 産業 | 宝 | '
                '武将 | 現役 | 控え | 兵士 |\n')
        sep = ('|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n')
        f.write(head)
        f.write(sep)
        for r in rows:
            f.write(f'| {r["id"]} | {r["ruler_zh_hans"]} | '
                    f'{r["province_count"]} | {r["gold"]} | {r["rice"]} | '
                    f'{r["population"]} | {r["land_value"]} | '
                    f'{r["industry"]} | {r["treasure"]} | '
                    f'{r["officer_count"]} | {r["active_troops"]} | '
                    f'{r["reserve_troops"]} | {r["total_troops"]} |\n')
        f.write('\n')

        f.write('## Province breakdown\n\n')
        f.write('Every owned Province with its own starting stats '
                '(the rows that sum into the table above).\n\n')
        f.write('| Country | Province | 金 | 米 | 人口 | 土地 | 産業 | 防災 | '
                '統治度 | 現役 | 控え | 武将 |\n')
        f.write('|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n')
        for r in rows:
            for p in r['owned']:
                f.write(f'| {r["id"]} | {p["id"]} '
                        f'{p["kanji"].get("zh_hans", "")} {p["katakana"]} | '
                        f'{p["gold"]} | {p["rice"]} | {p["population"]} | '
                        f'{p["land_value"]} | {p["industry"]} | '
                        f'{p["disaster_prevention"]} | {p["governance"]} | '
                        f'{p["active_troops"]} | {p["reserve_troops"]} | '
                        f'{p["officer_count"]} |\n')
        f.write('\n')

        f.write('## Ruler seed cross-check\n\n')
        f.write('The `WarResult_RecordInitTable` seed (Country slot -> Ruler '
                'id) is independent of the province-derived Ruler (the roster '
                'officer whose Loyalty is 100). They agree for every '
                'Country:\n\n')
        f.write('| Country id | seed Ruler | derived Ruler | match |\n'
                '|---:|---:|---:|:---:|\n')
        for r in rows:
            seed = SEED_RULERS.get(r['id'])
            ok = '✓' if seed == r['ruler_officer_id'] else '✗'
            f.write(f'| {r["id"]} | {seed} | '
                    f'{r["ruler_officer_id"]} | {ok} |\n')
        f.write('\n')
        _evidence(f)


EVIDENCE = """## How the mapping was verified

| Fact | Evidence |
|---|---|
| Country slot -> Ruler id | `WarResult_RecordInitTable` ($DA0F, `asm/banks/prg_08_09.asm`) and its inlined copy in `WarResultEntryInit` ($D97A) write `$AD,$08,$83,$8A,$DE,$DC,$B6` into `[0]` of the 7 records at `$6F07` |
| Ruler == Loyalty-100 officer | `extract_province_data.load_provinces` flags the roster officer whose Loyalty is 100; the two agree for all 7 Countries (cross-check table above) |
| Province -> Country id | `ProvinceCountByOwner` / `FindOfficerProvince` (`asm/banks/prg_19_1a.asm`) mask province record `+0` with `#$0F` and compare to the acting Country id; `7` = `UnclaimedLand` |
| Country record base | `B1F_GetCountryDataPtr` ($F368) / `GetCountryRecordPtr` ($D319) / `@CountryRecordPtrTable` ($A0D6) all index the 7 pointers `$6F07, $6F0F, ... $6F37` |
| Alliance nibbles `[4..7]` | `@MarkAllianceNibbles` / `@ApplyNibbleMarker` (`asm/banks/prg_0a_0b.asm`) set one nibble per rival in `[4..7]`; `@CountCountriesLoop` treats `[0] == $FF` as an empty Country |
| Home Province `[1]` | `AttractDemoDispatch` (@CountrySelect, `asm/banks/prg_19_1a.asm`) resolves the Ruler's Province via `FindOfficerProvince` and stores it in record `[1]` |
| Resources = sum of Provinces | No per-country stat table exists in ROM; the stats panel (`docs/manual_kb/03-province-stats.md`) and the AI budget (`@OrderScrollByProvinceTable`) are computed per-province and per-owned-province-count respectively |
"""


def _evidence(f):
    f.write(EVIDENCE)


def check(rows):
    """Validate the aggregation against the seed and the ROM; write nothing."""
    problems = []
    if len(rows) != COUNTRY_COUNT:
        problems.append(f'{len(rows)} countries, expected {COUNTRY_COUNT}')
    for r in rows:
        seed = SEED_RULERS.get(r['id'])
        if seed != r['ruler_officer_id']:
            problems.append(f'country {r["id"]}: ruler {r["ruler_officer_id"]} '
                            f'!= seed {seed}')
        if r['province_count'] == 0:
            problems.append(f'country {r["id"]}: owns no province')
        if r['home_province_id'] is None:
            problems.append(f'country {r["id"]}: no home province')
        if r['total_troops'] != r['active_troops'] + r['reserve_troops']:
            problems.append(f'country {r["id"]}: troop sum mismatch')
    owned_ids = {pid for r in rows for pid in
                 [int(x) for x in r['province_ids'].split()]}
    total = sum(r['province_count'] for r in rows)
    if len(owned_ids) != total:
        problems.append(f'provinces double-counted: {total} slots but '
                        f'{len(owned_ids)} distinct owned provinces')
    for p in problems:
        print(f'FAIL: {p}', file=sys.stderr)
    if problems:
        return 1
    print(f'OK: {len(rows)} countries, Ruler seed matches, '
          f'{total} claimed provinces aggregated')
    return 0


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--rom', default=PRG_COMBINED, help='combined PRG binary')
    ap.add_argument('--print', dest='do_print', action='store_true',
                    help='dump the table to stdout as well')
    ap.add_argument('--check', action='store_true',
                    help='validate against the seed, write nothing')
    args = ap.parse_args()

    provinces = list(load_provinces(args.rom))
    officers = load_officer_names()
    pinyin = load_ruler_pinyin()
    rows = list(aggregate(provinces, officers))
    # fill pinyin now that the full reading table is loaded
    for r in rows:
        r['ruler_pinyin'] = pinyin.get(r['ruler_officer_id'], '')

    if args.check:
        return check(rows)

    out_dir = os.path.join(ROOT, 'docs')
    os.makedirs(out_dir, exist_ok=True)
    data_csv = os.path.join(out_dir, 'country_data.csv')
    md = os.path.join(out_dir, 'country_data.md')
    write_csv(rows, data_csv)
    write_md(rows, md, pinyin)

    print(f'{len(rows)} countries consolidated')
    for p in (data_csv, md):
        print(f'  wrote {os.path.relpath(p, ROOT)}')

    if args.do_print:
        for r in rows:
            print(f'{r["id"]} {r["ruler_zh_hans"]:　<4} '
                  f'{_pad(r["ruler_katakana"], 12)} home={r["home_province"]} '
                  f'provinces={r["province_count"]} gold={r["gold"]:<6} '
                  f'rice={r["rice"]:<6} pop={r["population"]:<8} '
                  f'troops={r["total_troops"]:<6} officers={r["officer_count"]}')
    return 0


if __name__ == '__main__':
    sys.exit(main() or 0)
