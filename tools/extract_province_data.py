#!/usr/bin/env python3
"""Extract the 30 province katakana names and their starting records from the ROM.

Province name table (verified against CmdDrawNameFromData, which computes
``ptr = index * 8 + $9A1A`` and draws up to 6 glyphs):

  bank register $30 -> physical PRG bank $10 (256 KB PRG => reg & $1F)
  name address      = index * 8 + $9A1A
  file offset       = 0x20000 + ($9A1A - $8000) + index * 8 = 0x21A1A + index*8
  entry             = 8 bytes, $00-terminated, zero padded

Province master records (seed image of SRAM, copied by SramInit $DD8B in bank
$3D/$3E: 0x3C0 bytes from bank $30 $8C00 to SRAM $6000):

  file offset       = 0x20000 + ($8C00 - $8000) + index * 32 = 0x20C00 + index*32
  SRAM record       = index * 32 + $6000  (B1F_GetProvinceRecordAddr $F2AF)

Index == province id for both tables, and (0x63C0 - 0x6000) / 32 = 30 records,
which matches the 30 provinces of the printed manual map.

Encoding is the serial gojuon code space documented in tools/charmap_kana.py
($04=ア .. $31=ン, $35-$38 = ャュョッ, $39/$3A = postfix ゛/゜).

Kanji / Chinese readings come from tools/data/province_kanji.tsv.

Usage:
    python tools/extract_province_data.py            # write output files
    python tools/extract_province_data.py --print     # also dump to stdout
    python tools/extract_province_data.py --check     # validate, write nothing
"""
import argparse
import csv
import os
import sys
import unicodedata

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from charmap_kana import DAKUTEN, HANDAKUTEN, KATAKANA, decode_name  # noqa: E402
from extract_officer_names import romanize  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRG_COMBINED = os.path.join(ROOT, 'rom', 'prg_combined.bin')
KANJI_TSV = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                         'data', 'province_kanji.tsv')
OFFICER_KANJI_CSV = os.path.join(ROOT, 'docs', 'officer_names_kanji.csv')

NAME_TABLE_OFFSET = 0x21A1A    # file offset of province 0's name
NAME_TABLE_ADDR = 0x9A1A       # CPU address in bank $30
NAME_ENTRY_SIZE = 8

DATA_TABLE_OFFSET = 0x20C00    # file offset of province 0's master record
DATA_TABLE_ADDR = 0x8C00       # CPU address in bank $30
RECORD_SIZE = 32
PROVINCE_COUNT = 30            # (0x63C0 - 0x6000) / 32
PROVINCE_RECORD_BASE = 0x6000

OFFICER_TABLE_OFFSET = 0x22000  # officer master records, bank $31 $8000
OFFICER_RECORD_SIZE = 12
OFFICER_TROOPS_OFFSET = 8       # bytes +8/+9 = 兵数 TroopCount (16-bit LE)
OFFICER_LOYALTY_OFFSET = 3      # +3 = 忠誠度 Loyalty; 100 marks a Ruler
OFFICER_NAME_OFFSET = 0x2101A
OFFICER_NAME_SIZE = 10

ROSTER_START = 0x11            # record offsets $11-$1A: 10 officer slots
ROSTER_SLOTS = 10
EMPTY_SLOT = 0xFF
UNCLAIMED = 7                  # record[0] low nibble 7 = 空白地 (unclaimed)
POPULATION_SCALE = 100         # panel appends two literal "0" tiles

# Province record layout. Offsets verified against the code that reads them:
#   +2/+3, +4/+5, +16   物資を運ぶ transfer ($B8D7, bank $39/$3A) = 金/米/宝
#   +2/+3, +12/+13      徴兵 conscription ($B294, bank $3B/$3C), cap $2710
#   +6/+7 (x100), +8/+9, +10, +11, +14/+15
#                       ProvinceDetailTilemap $B305 stat panel (bank $3D/$3E):
#                       $F1/$F2 = 16/8-bit field draw, $F0 = roster count,
#                       $F3 = sum of roster troop counts
#   +8/+9               annual harvest ($A60B, bank $39/$3A): scaled into 米
#                       => this field is 土地 LandValue
#   +14/+15             annual tax ($A446, bank $39/$3A): scaled into 金
#                       => this field is 産業 Industry
#   +11                 AnnualTakeoverCheck ($AB6E, bank $39/$3A) revolt roll;
#                       also the 50/60/../100 tier multiplier on both incomes
#   +27                 revolt cooldown written there (6 months)
# Column names below are the snake_case form of the canonical semantic English
# terms in docs/manual_kb/terminology.md (Country, LandValue, Treasure, ...).
FIELDS = [
    ('country_id', 0, 1, '所属国 Country id (low nibble; 7 = 空白地 UnclaimedLand)'),
    ('gold', 2, 2, '金 Gold (cap 9999)'),
    ('rice', 4, 2, '米 Rice (cap 9999)'),
    ('population_raw', 6, 2, '人口 Population / 100 (panel draws value + "00")'),
    ('land_value', 8, 2, '土地 LandValue (cap 999)'),
    ('disaster_prevention', 10, 1, '防災 DisasterPrevention (cap 99)'),
    ('governance', 11, 1, '統治度 Governance (cap 100; < 50 = annual revolt roll)'),
    ('reserve_troops', 12, 2, '控え ReserveTroops (cap 10000; 徴兵 target)'),
    ('industry', 14, 2, '産業 Industry (cap 999)'),
    ('treasure', 16, 1, '宝 Treasure (cap 99)'),
    ('revolt_timer', 27, 1, '反乱クールダウン RevoltCooldown in months (0 in ROM)'),
]

# docs/province_data.csv columns: (name, 日本語, meaning). Stat column names are
# the snake_case form of the canonical semantic English terms in
# docs/manual_kb/terminology.md.
DATA_CSV_COLUMNS = [
    ('id', '国番号', 'Province id; index into both ROM tables'),
    ('katakana', '国名', 'Province name as stored in the ROM'),
    ('zh_hans', '国名', 'Simplified Chinese name'),
    ('kanji_ja', '国名', 'Japanese kanji name'),
    ('pinyin', '国名', 'Mandarin reading of the Chinese name'),
    ('country_id', '所属国', 'Owning Country id (record `+0` low nibble); '
                             '7 = 空白地 UnclaimedLand'),
    ('ruler_officer_id', '君主', 'Ruler: the rostered Officer whose Loyalty is 100'),
    ('gold', '金', 'Gold (record `+2/+3`)'),
    ('rice', '米', 'Rice (record `+4/+5`)'),
    ('population', '人口', 'Population as displayed (record `+6/+7` x 100)'),
    ('land_value', '土地', 'LandValue (record `+8/+9`); drives the annual Rice harvest'),
    ('industry', '産業', 'Industry (record `+14/+15`); drives the annual Gold tax'),
    ('disaster_prevention', '防災', 'DisasterPrevention (record `+10`)'),
    ('governance', '統治度', 'Governance (record `+11`)'),
    ('reserve_troops', '控え', 'ReserveTroops (record `+12/+13`)'),
    ('treasure', '宝', 'Treasure (record `+16`)'),
    ('officer_count', '武将数', 'Officers on the roster (record `+17..+26`)'),
    ('active_troops', '現役', 'ActiveTroops: sum of the rostered Officers TroopCount'),
    ('officer_ids', '武将', 'Roster Officer ids, in slot order'),
    ('officer_names', '武将', 'Roster Officer names, simplified Chinese'),
    ('sram_record', '-', 'SRAM address of the record after SramInit'),
    ('data_offset', '-', 'PRG file offset of the record'),
    ('hex', '-', 'The raw 32 record bytes'),
]


def read16(rec, ofs):
    return rec[ofs] | (rec[ofs + 1] << 8)


def load_kanji(path=KANJI_TSV):
    """id -> {kanji_ja, zh_hant, zh_hans, pinyin, note} from the curated TSV."""
    out = {}
    with open(path, encoding='utf-8') as f:
        rows = [ln for ln in f if not ln.startswith('#')]
    for row in csv.DictReader(rows, delimiter='\t'):
        pid = int(row['id'])
        out[pid] = {k: (row.get(k) or '').strip()
                    for k in ('katakana', 'kanji_ja', 'zh_hant', 'zh_hans',
                              'pinyin', 'note')}
    return out


def load_officer_names(path=OFFICER_KANJI_CSV):
    """id -> (katakana, zh_hans) for roster rendering; optional file."""
    if not os.path.exists(path):
        return {}
    with open(path, encoding='utf-8') as f:
        return {int(r['id']): (r['katakana'], r['zh_hans'])
                for r in csv.DictReader(f)}


def glyph_count(entry):
    """Character count as the name drawers see it (combining marks excluded)."""
    n = 0
    for b in entry:
        if b == 0:
            break
        if b in (DAKUTEN, HANDAKUTEN):
            continue
        n += 1
    return n


def load_provinces(path=PRG_COMBINED, count=PROVINCE_COUNT):
    """Yield one dict per province: name, master record and decoded fields."""
    with open(path, 'rb') as f:
        prg = f.read()
    end = max(NAME_TABLE_OFFSET + count * NAME_ENTRY_SIZE,
              DATA_TABLE_OFFSET + count * RECORD_SIZE)
    if len(prg) < end:
        raise SystemExit(f'{path}: too small ({len(prg)} bytes, need {end})')

    kanji = load_kanji()
    officers = load_officer_names()

    for pid in range(count):
        nofs = NAME_TABLE_OFFSET + pid * NAME_ENTRY_SIZE
        entry = prg[nofs:nofs + NAME_ENTRY_SIZE]
        raw = entry.split(b'\x00')[0]
        unknown = sorted({b for b in raw
                          if b not in KATAKANA and b not in (DAKUTEN, HANDAKUTEN)})
        kata = decode_name(entry)

        dofs = DATA_TABLE_OFFSET + pid * RECORD_SIZE
        rec = prg[dofs:dofs + RECORD_SIZE]

        roster, troops = [], 0
        for slot in range(ROSTER_SLOTS):
            oid = rec[ROSTER_START + slot]
            if oid == EMPTY_SLOT:
                continue
            roster.append(oid)
            orec = OFFICER_TABLE_OFFSET + oid * OFFICER_RECORD_SIZE
            troops += read16(prg, orec + OFFICER_TROOPS_OFFSET)

        ruler = None
        for oid in roster:
            orec = OFFICER_TABLE_OFFSET + oid * OFFICER_RECORD_SIZE
            if prg[orec + OFFICER_LOYALTY_OFFSET] == 100:
                ruler = oid

        row = {
            'id': pid,
            'name_addr': NAME_TABLE_ADDR + pid * NAME_ENTRY_SIZE,
            'name_offset': nofs,
            'data_addr': DATA_TABLE_ADDR + pid * RECORD_SIZE,
            'data_offset': dofs,
            'sram_record': PROVINCE_RECORD_BASE + pid * RECORD_SIZE,
            'name_hex': raw.hex().upper(),
            'katakana': kata,
            'hiragana': decode_name(entry, hiragana=True),
            'romaji': romanize(kata),
            'glyphs': glyph_count(entry),
            'unknown': unknown,
            'roster': roster,
            'officer_count': len(roster),
            'active_troops': troops,
            'ruler_officer_id': ruler,
            'hex': rec.hex().upper(),
        }
        for name, ofs, size, _ in FIELDS:
            row[name] = rec[ofs] if size == 1 else read16(rec, ofs)
        row['country_id'] &= 0x0F
        row['population'] = row['population_raw'] * POPULATION_SCALE
        row['officer_names'] = ' '.join(
            officers.get(o, ('?', f'#{o}'))[1] for o in roster)
        row['officer_katakana'] = ' '.join(
            officers.get(o, (f'#{o}', '?'))[0] for o in roster)
        row['kanji'] = kanji.get(pid, {})
        yield row


def country_table(rows):
    """Country id -> (ruler province id, ruler officer id) from the ROM data."""
    out = {}
    for r in rows:
        if r['ruler_officer_id'] is not None:
            out[r['country_id']] = (r['id'], r['ruler_officer_id'])
    return out


def _pad(text, width):
    """Left-align accounting for double-width kana/kanji cells."""
    cells = sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in text)
    return text + ' ' * max(0, width - cells)


def _provenance(f, count):
    f.write(f'* PRG 256 KB, CHR 256 KB, mapper 19 (Namco 163)\n')
    f.write(f'* names: PRG `${NAME_TABLE_OFFSET:05X}`, {NAME_ENTRY_SIZE} bytes/entry '
            f'(CPU `${NAME_TABLE_ADDR:04X}`, bank `$30`), `$00`-terminated\n')
    f.write(f'* data: PRG `${DATA_TABLE_OFFSET:05X}`, {RECORD_SIZE} bytes/record '
            f'(CPU `${DATA_TABLE_ADDR:04X}`, bank `$30`)\n')
    f.write(f'* {count} provinces; record `id * {RECORD_SIZE} + '
            f'${PROVINCE_RECORD_BASE:04X}` once copied to SRAM\n')


def write_names_csv(rows, path):
    cols = ['id', 'name_addr', 'file_offset', 'hex', 'katakana', 'hiragana',
            'romaji', 'glyphs', 'kanji_ja', 'zh_hant', 'zh_hans', 'pinyin', 'note']
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for r in rows:
            k = r['kanji']
            w.writerow({
                'id': r['id'],
                'name_addr': f'${r["name_addr"]:04X}',
                'file_offset': f'{r["name_offset"]:#07x}',
                'hex': r['name_hex'],
                'katakana': r['katakana'],
                'hiragana': r['hiragana'],
                'romaji': r['romaji'],
                'glyphs': r['glyphs'],
                'kanji_ja': k.get('kanji_ja', ''),
                'zh_hant': k.get('zh_hant', ''),
                'zh_hans': k.get('zh_hans', ''),
                'pinyin': k.get('pinyin', ''),
                'note': k.get('note', ''),
            })


def write_data_csv(rows, path):
    cols = [c for c, _, _ in DATA_CSV_COLUMNS]
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for r in rows:
            k = r['kanji']
            row = {c: r.get(c, '') for c in cols}
            row.update({
                'zh_hans': k.get('zh_hans', ''),
                'kanji_ja': k.get('kanji_ja', ''),
                'pinyin': k.get('pinyin', ''),
                'ruler_officer_id': '' if r['ruler_officer_id'] is None
                                    else r['ruler_officer_id'],
                'officer_ids': ' '.join(str(o) for o in r['roster']),
                'sram_record': f'${r["sram_record"]:04X}',
                'data_offset': f'{r["data_offset"]:#07x}',
            })
            w.writerow(row)


def write_md(rows, path, officers):
    countries = country_table(rows)
    with open(path, 'w', encoding='utf-8') as f:
        f.write('# Province data extracted from the ROM\n\n')
        f.write('All 30 provinces with their katakana name (as stored in the\n'
                'ROM), Chinese name, and starting data, read directly out of\n'
                'the iNES image by `tools/extract_province_data.py`.\n\n')
        _provenance(f, len(rows))
        f.write('\n')

        f.write('## Record layout\n\n')
        f.write('The master record is the seed image of the province\'s SRAM\n'
                'record at `id * 32 + $6000`, i.e. the new-game starting state;\n'
                '`SramInit` copies all `$3C0` bytes verbatim. Column names use\n'
                'the canonical semantic English terms from\n'
                '`docs/manual_kb/terminology.md`.\n\n')
        f.write('| Offset | Field | Notes |\n|---|---|---|\n')
        f.write('| `+0` | 所属国 Country | low nibble = Country id 0-6, '
                '`7` = 空白地 UnclaimedLand |\n')
        f.write('| `+1` | - | always 0 in ROM (runtime field) |\n')
        f.write('| `+2/+3` | 金 Gold | 16-bit LE; capped at 9999 |\n')
        f.write('| `+4/+5` | 米 Rice | 16-bit LE; capped at 9999 |\n')
        f.write('| `+6/+7` | 人口 Population | 16-bit LE, stored / 100 '
                '(panel appends two `0` tiles) |\n')
        f.write('| `+8/+9` | 土地 LandValue | 16-bit LE; capped at 999 |\n')
        f.write('| `+10` | 防災 DisasterPrevention | capped at 99 |\n')
        f.write('| `+11` | 統治度 Governance | capped at 100; below 50 the '
                'annual check rolls a revolt |\n')
        f.write('| `+12/+13` | 控え ReserveTroops | 16-bit LE; 徴兵 adds here, '
                'capped at 10000 |\n')
        f.write('| `+14/+15` | 産業 Industry | 16-bit LE; capped at 999 |\n')
        f.write('| `+16` | 宝 Treasure | capped at 99; 0 in ROM |\n')
        f.write('| `+17..+26` | 武将 Officer roster | 10 slots (`$11-$1A`), '
                '`$FF` = empty |\n')
        f.write('| `+27` | 反乱クールダウン RevoltCooldown | months, set to 6 '
                'on a revolt; 0 in ROM |\n')
        f.write('| `+28..+31` | - | always 0 in ROM (runtime fields) |\n\n')
        f.write('The 現役 (active) soldier total the game shows in the province\n'
                'panel is not stored here: it is summed on the fly from the\n'
                'roster officers\' 兵数 TroopCount field (officer record '
                '`+8/+9`).\n\n')

        f.write('## CSV columns\n\n')
        f.write('`docs/province_data.csv` column names are the snake_case form\n'
                'of the canonical semantic English terms in\n'
                '`docs/manual_kb/terminology.md`.\n\n')
        f.write('| Column | 日本語 | Meaning |\n|---|---|---|\n')
        for name, ja, meaning in DATA_CSV_COLUMNS:
            f.write(f'| `{name}` | {ja} | {meaning} |\n')
        f.write('\n')

        f.write('## Countries at the 189 start\n\n')
        f.write('Country ids are the low nibble of record `+0`; the Ruler is the\n'
                'roster officer whose 忠誠度 Loyalty is 100.\n\n')
        f.write('| Country id | Ruler | Home province | Provinces |\n'
                '|---:|---|---|---|\n')
        for cid in sorted(countries):
            pid, oid = countries[cid]
            owned = [r for r in rows if r['country_id'] == cid]
            home = next(r for r in rows if r['id'] == pid)
            ruler = officers.get(oid, ('?', f'#{oid}'))
            f.write(f'| {cid} | {ruler[1]} {ruler[0]} (id {oid}) | '
                    f'{home["kanji"].get("zh_hans", "")} {home["katakana"]} | '
                    + ', '.join(r['kanji'].get('zh_hans', '') for r in owned)
                    + ' |\n')
        free = [r for r in rows if r['country_id'] == UNCLAIMED]
        f.write(f'| 7 | - (空白地 unclaimed) | - | '
                + ', '.join(r['kanji'].get('zh_hans', '') for r in free) + ' |\n\n')

        f.write('## Province names\n\n')
        f.write('| id | addr | bytes | katakana | hiragana | romaji | 日本語 | '
                '繁體 | 简体 | pinyin |\n')
        f.write('|---:|---|---|---|---|---|---|---|---|---|\n')
        for r in rows:
            k = r['kanji']
            f.write(f'| {r["id"]} | `${r["name_addr"]:04X}` | `{r["name_hex"]}` | '
                    f'{r["katakana"]} | {r["hiragana"]} | {r["romaji"]} | '
                    f'{k.get("kanji_ja", "")} | {k.get("zh_hant", "")} | '
                    f'{k.get("zh_hans", "")} | {k.get("pinyin", "")} |\n')
        f.write('\n')

        notes = [r for r in rows if r['kanji'].get('note')]
        if notes:
            f.write('### Reading notes\n\n')
            for r in notes:
                f.write(f'* **{r["katakana"]}** ({r["kanji"].get("kanji_ja", "")}) — '
                        f'{r["kanji"]["note"]}\n')
            f.write('\n')

        f.write('## Starting data\n\n')
        f.write('人口 is the value the game displays (stored value x 100).\n'
                '兵士 is 現役 (summed from the roster) + 控え (record `+12/+13`).\n\n')
        f.write('| id | province | 国 | 金 | 米 | 人口 | 土地 | 産業 | 防災 | '
                '統治度 | 現役 | 控え | 宝 | 武将 |\n')
        f.write('|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n')
        for r in rows:
            owner = '-' if r['country_id'] == UNCLAIMED else str(r['country_id'])
            f.write(f'| {r["id"]} | {r["kanji"].get("zh_hans", "")} '
                    f'{r["katakana"]} | {owner} | {r["gold"]} | {r["rice"]} | '
                    f'{r["population"]} | {r["land_value"]} | {r["industry"]} | '
                    f'{r["disaster_prevention"]} | {r["governance"]} | '
                    f'{r["active_troops"]} | {r["reserve_troops"]} | '
                    f'{r["treasure"]} | {r["officer_count"]} |\n')
        f.write('\n')

        f.write('## Starting officer rosters\n\n')
        f.write('| id | province | officers (id: name) |\n|---:|---|---|\n')
        for r in rows:
            names = ', '.join(
                f'{o}: {officers.get(o, ("?", f"#{o}"))[1]} '
                f'{officers.get(o, ("?", "?"))[0]}' for o in r['roster'])
            f.write(f'| {r["id"]} | {r["kanji"].get("zh_hans", "")} '
                    f'{r["katakana"]} | {names or "-"} |\n')
        f.write('\n')

        f.write('## Raw records\n\n')
        f.write('32 bytes per province, exactly as stored at PRG '
                f'`${DATA_TABLE_OFFSET:05X}` (bank `$30` `${DATA_TABLE_ADDR:04X}`).\n\n')
        f.write('```\n')
        f.write('id  file    sram   bytes\n')
        for r in rows:
            hexs = ' '.join(r['hex'][i:i + 2] for i in range(0, len(r['hex']), 2))
            f.write(f'{r["id"]:>2}  {r["data_offset"]:#07x} ${r["sram_record"]:04X}  '
                    f'{hexs}\n')
        f.write('```\n\n')
        f.write('Province name strings, 8 bytes per entry at PRG '
                f'`${NAME_TABLE_OFFSET:05X}` (bank `$30` `${NAME_TABLE_ADDR:04X}`):\n\n')
        f.write('```\n')
        for r in rows:
            f.write(f'{r["id"]:>2}  {r["name_offset"]:#07x} ${r["name_addr"]:04X}  '
                    f'{_pad(r["name_hex"], 16)} {_pad(r["katakana"], 14)}'
                    f'{r["kanji"].get("zh_hans", "")}\n')
        f.write('```\n\n')
        _evidence(f)


EVIDENCE = """## How the field map was verified

Every offset in the record layout above is backed by code, not
guessed from the values:

| Field | Evidence |
|---|---|
| `+0` 所属国 | `ProvinceCountByOwner` (`asm/banks/prg_19_1a.asm`) masks the byte with `#$0F` and compares against a Country id; `FindOfficerProvince` scans the same records |
| `+2/+3` 金 | 徴兵 (`$B294`, `asm/banks/prg_1b_1c.asm`) charges 20 gold per 100 men here; 輸送 (`$B8D7`, `prg_19_1a.asm`) moves it |
| `+4/+5` 米 | 輸送 moves it as the second 16-bit resource; the annual harvest (below) credits it |
| `+6/+7` 人口 | panel stream draws it with 5 digits followed by two literal `$B6` (`0`) tiles, so the stored value is / 100 |
| `+8/+9` 土地 | annual harvest (`$A60B`, `prg_19_1a.asm`): `land / lvl_div * lvl_base / $3C * 統治度tier / 100` is **added to 米** (`+4/+5`) |
| `+10` 防災 | panel stream draws it with 2 digits (max 99) right after 人口, matching the panel order in `docs/manual_kb/03-country-stats.md` |
| `+11` 統治度 | `AnnualTakeoverCheck` (`$AB6E`) rolls a revolt when it is `< 50` (tiers at 50/40/30/20); both income routines scale their yield by its 50/60/70/80/90/100 tier |
| `+12/+13` 控え | 徴兵 adds the recruited men here and clamps at `$2710` (10000) |
| `+14/+15` 産業 | annual tax (`$A446`, `prg_19_1a.asm`): `industry / lvl_div * lvl_base / $50 * 統治度tier / 100` is **added to 金** (`+2/+3`) |
| `+16` 宝 | 輸送 moves it as an 8-bit resource, clamped at 99 |
| `+17..+26` 武将 | `FindOfficerProvince` and the `$F0`/`$F3` panel commands walk slots `$11-$1A` looking for `$FF` |
| `+27` cooldown | `AnnualTakeoverMark` stores 6 there, and the revolt check skips a province while it is non-zero |

The 産業 -> 金 / 土地 -> 米 pair is what disambiguates the two
999-capped 16-bit stats, and it agrees with the panel order
(金, 米, 土地, 産業, 人口, 防災, 武将, 兵士, 統治度) transcribed
from the manual.
"""


def _evidence(f):
    f.write(EVIDENCE)


def write_inc(rows, path):
    """ca65 include: PROVINCE_<ROMAJI> = <id> equates for use in disassembly."""
    seen = {}
    with open(path, 'w', encoding='utf-8') as f:
        f.write('; Province id equates, generated by tools/extract_province_data.py\n')
        f.write(f'; Name table:    id * {NAME_ENTRY_SIZE} + ${NAME_TABLE_ADDR:04X} '
                f'in PRG bank $30\n')
        f.write(f'; Master record: id * {RECORD_SIZE} + ${DATA_TABLE_ADDR:04X} '
                f'in PRG bank $30\n')
        f.write(f'; SRAM record:   id * {RECORD_SIZE} + '
                f'${PROVINCE_RECORD_BASE:04X}\n\n')
        f.write(f'PROVINCE_COUNT        = {len(rows)}\n')
        f.write(f'PROVINCE_NAME_BASE    = ${NAME_TABLE_ADDR:04X}\n')
        f.write(f'PROVINCE_NAME_STRIDE  = {NAME_ENTRY_SIZE}\n')
        f.write(f'PROVINCE_RECORD_BASE  = ${PROVINCE_RECORD_BASE:04X}\n')
        f.write(f'PROVINCE_RECORD_SIZE  = {RECORD_SIZE}\n')
        f.write(f'PROVINCE_COUNTRY_NONE = ${UNCLAIMED:02X}   '
                f'; 空白地 UnclaimedLand\n\n')
        for r in rows:
            sym = 'PROVINCE_' + ''.join(
                c for c in r['romaji'].upper() if c.isalnum() or c == '_')
            seen[sym] = seen.get(sym, 0) + 1
            if seen[sym] > 1:
                sym = f'{sym}_{seen[sym]}'
            f.write(f'{sym:<28} = {r["id"]:>3}   ; {r["katakana"]} '
                    f'{r["kanji"].get("kanji_ja", "")}\n')


def check(rows, bad, missing, mismatched):
    """Validate the extraction without writing; returns a process exit code."""
    problems = []
    if len(rows) != PROVINCE_COUNT:
        problems.append(f'{len(rows)} records read, expected {PROVINCE_COUNT}')
    if bad:
        problems.append(f'{len(bad)} name(s) with unmapped kana codes')
    if missing:
        problems.append(f'{len(missing)} province(s) with no Chinese name')
    if mismatched:
        problems.append(f'{len(mismatched)} TSV katakana mismatch(es)')

    names = [r['katakana'] for r in rows]
    dupes = sorted({n for n in names if names.count(n) > 1})
    if dupes:
        problems.append('duplicate katakana names: ' + ', '.join(dupes))

    owners = {r['country_id'] for r in rows}
    if not owners <= set(range(UNCLAIMED + 1)):
        problems.append(f'owner ids out of range: {sorted(owners)}')

    slots = [o for r in rows for o in r['roster']]
    redupes = sorted({o for o in slots if slots.count(o) > 1})
    if redupes:
        problems.append('officers rostered twice: '
                        + ', '.join(str(o) for o in redupes))

    countries = country_table(rows)
    claimed = owners - {UNCLAIMED}
    if set(countries) != claimed:
        problems.append(f'rulers found for {sorted(countries)}, '
                        f'countries present {sorted(claimed)}')

    for r in rows:
        rec = bytes.fromhex(r['hex'])
        if rec[1] or any(rec[28:]):
            problems.append(f'province {r["id"]}: runtime fields not zero')

    for p in problems:
        print(f'FAIL: {p}', file=sys.stderr)
    if problems:
        return 1
    print(f'OK: {len(rows)} provinces, {len(countries)} countries, '
          f'{len(slots)} rostered officers, all names mapped')
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--rom', default=PRG_COMBINED, help='combined PRG binary')
    ap.add_argument('--count', type=int, default=PROVINCE_COUNT,
                    help='province records to read')
    ap.add_argument('--print', dest='do_print', action='store_true',
                    help='dump the table to stdout as well')
    ap.add_argument('--check', action='store_true',
                    help='validate names/records against the ROM, write nothing')
    args = ap.parse_args()

    rows = list(load_provinces(args.rom, args.count))

    bad = [r for r in rows if r['unknown']]
    for r in bad:
        codes = ' '.join(f'${b:02X}' for b in r['unknown'])
        print(f'WARNING: province {r["id"]}: unmapped codes {codes} '
              f'({r["name_hex"]})', file=sys.stderr)
    missing = [r for r in rows if not r['kanji'].get('zh_hans')]
    for r in missing:
        print(f'WARNING: province {r["id"]} ({r["katakana"]}) has no Chinese name '
              f'in tools/data/province_kanji.tsv', file=sys.stderr)
    mismatched = []
    for r in rows:
        tsv_kata = r['kanji'].get('katakana')
        if tsv_kata and tsv_kata != r['katakana']:
            mismatched.append(r)
            print(f'WARNING: province {r["id"]}: TSV katakana {tsv_kata} != '
                  f'ROM {r["katakana"]}', file=sys.stderr)

    if args.check:
        return check(rows, bad, missing, mismatched)

    officers = load_officer_names()
    out_dir = os.path.join(ROOT, 'docs')
    os.makedirs(out_dir, exist_ok=True)
    names_csv = os.path.join(out_dir, 'province_names.csv')
    data_csv = os.path.join(out_dir, 'province_data.csv')
    md = os.path.join(out_dir, 'province_data.md')
    inc = os.path.join(ROOT, 'include', 'province_ids.inc')
    write_names_csv(rows, names_csv)
    write_data_csv(rows, data_csv)
    write_md(rows, md, officers)
    write_inc(rows, inc)

    print(f'{len(rows)} provinces read'
          + ('' if not bad else f', {len(bad)} with unmapped codes'))
    for p in (names_csv, data_csv, md, inc):
        print(f'  wrote {os.path.relpath(p, ROOT)}')

    if args.do_print:
        for r in rows:
            f = r['kanji']
            print(f'{r["id"]:>2} ${r["name_addr"]:04X} {r["name_hex"]:<16} '
                  f'{_pad(r["katakana"], 14)}{_pad(f.get("zh_hans", ""), 8)}'
                  f'owner={r["country_id"]} gold={r["gold"]:<5} rice={r["rice"]:<5} '
                  f'pop={r["population"]:<7} land={r["land_value"]:<4} '
                  f'ind={r["industry"]:<4} dis={r["disaster_prevention"]:<3} '
                  f'gov={r["governance"]:<4} res={r["reserve_troops"]:<5} '
                  f'officers={r["officer_count"]}')


if __name__ == '__main__':
    sys.exit(main() or 0)
