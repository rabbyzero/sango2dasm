#!/usr/bin/env python3
"""Extract town (町) data from the ROM: per-province town commands, the
armory (武器屋) weapon/armor stock with prices, and the market (商店) rice
trade rates. Writes CSV files to docs/.

All data is read from the ROM image; every table is code-referenced:

Town screen (strategy mode frame state 5, TownCommandDispatch $BFB7,
asm/banks/prg_1b_1c.asm):

* Province -> town type (0-9): bank $1C $C025, 30 bytes, indexed by
  province id (`LDY $0402 / LDA $C025,Y`), also selecting the town-screen
  stream through the UI table at $C043 ($AE-$B6, $6E).
* Town type -> facility screens: bank $1C $C10E, 4 bytes per town type,
  indexed by town type * 4 + facility slot (`LDA $C10E,Y` at $C098).
  Screen ids: 0 = 武器屋 Armory, 1 = 学問所 Academy, 2 = 病院 Hospital,
  3 = 商店 Market. $FF = no facility in that slot. Verified against the
  manual (p. 27: 町には4種類の施設がありますが、国によって備わり方には
  らつきがあります) and the p. 55 sample (并州 = 武/病/商 = type 7).

Armory stock (subs 19-21 of the town dispatch, $C76E-$C9EF):

* Province -> armory formation id: bank $1C $C801, 30 bytes
  (`LDY $0402 / LDA $C801,Y`), passed as the formation argument through the
  banked trampoline at $C7AB (bank $28 & $1F = $08, $A01E -> bank $09) into
  ExpandFormationSlots (prg_08_09.asm $C851), which fans the formation's
  16 tile cells out to the 4 armory pages (side * 4 + slot).
* Cell -> sale price: TileOffsetTable bank $09 $C89E, 32 words
  (the same table the battle formations use for slot positions; the armory
  purchase code at $C962 reads the word the fan-out wrote to $042C+sel*3
  and subtracts it from the province gold at record +2).
* Cell -> item: cell index == equipment id as encoded in the officer
  record +10 (bits 0-4 weapon, bits 5-7 armor; see
  tools/extract_officer_data.py). Weapons: 0-4 剣, 8-13 刀, 16-21 槍;
  armor: 24-29 = armor ids 0-5. Cells 14/15/22/23 (weapons) and 30/31
  (armor ids 6/7) never appear on any starting officer; 14 is unpriced,
  the rest are the hidden top-tier items (15 sold only in 建業's armory,
  22/23/30/31 in no starting-scenario armory).

Rice market (sub 3 of the town dispatch, $C1C1):

* Province -> trade rates: virtual bank $30 (physical $10, the
  B1F_SwitchBank8_A bank) $8FC0, 2 bytes per province
  (`LDA $0402 / ASL / ADC #$C0`, hi $8F). Byte 0 = sell rate, byte 1 =
  buy rate; provinces without a 商店 store $00 $00. Buy path (sel 0,
  $C254): rice obtained = gold * buy_rate / 100 ($EBE9 multiply, $DB72
  divide by 100, remainder rounds up), i.e. the rate is rice units per
  100 gold and the price per rice is 100 / rate gold. Sell path (sel 1,
  $C22B) shows the province rice stock with the sell rate.

Usage:
    python tools/extract_town_data.py            # write output files
    python tools/extract_town_data.py --print    # also dump to stdout
"""
import argparse
import csv
import os
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PROVINCE_COUNT = 30

# --- ROM offsets (file offsets inside the split 8 KB bank binaries) ---
B1C = 'rom/prg/prg_1c.bin'    # maps at CPU $C000
TOWN_TYPE_OFF = 0x0025        # $C025: province -> town type
FACILITY_ROUTE_OFF = 0x010E   # $C10E: town type -> 4 facility screen ids
ARMORY_FORMATION_OFF = 0x0801  # $C801: province -> armory formation id
B09 = 'rom/prg/prg_09.bin'    # maps at CPU $C000
FORMATION_LAYOUT_OFF = 0x08DE  # $C8DE: FormationTileLayouts, 6 x 16
PRICE_TABLE_OFF = 0x089E       # $C89E: TileOffsetTable, 32 words
B30 = 'rom/prg/prg_10.bin'    # virtual bank $30, maps at CPU $8000
RICE_RATE_OFF = 0x0FC0         # $8FC0: province -> (sell_rate, buy_rate)

# --- Town facility screens (town dispatch $C08B-$C0E1 routes) ---
FACILITY_SHORT = ['武', '学', '病', '商']

# --- Armory catalog: cell/equipment id -> name ---
# Names follow tools/extract_officer_data.py (recovered by correlating all
# 237 officer records against a published roster of this ROM).
WEAPON_NAMES = {
    0: '短剣', 1: '飛剣', 2: '長剣', 3: '破斬剣', 4: '大剣',
    8: '薤刀', 9: '眉尖刀', 10: '三尖刀', 11: '鉤鐮刀', 12: '偃月刀',
    13: '鳳嘴刀',
    16: '矛', 17: '双戟', 18: '単鉤槍', 19: '戦斧', 20: '双鉤槍',
    21: '方天画戟',
    14: '(unused blade)', 15: '(hidden blade)',
    22: '(hidden spear-class weapon)', 23: '(hidden spear-class weapon)',
}
ARMOR_NAMES = {
    0: '綸巾', 1: '籠手', 2: '兜', 3: '硬皮', 4: '鶴氅', 5: '甲冑',
    6: '(hidden armor)', 7: '(hidden armor)',
}


def item_name(cell):
    """Catalog name for an armory cell (== equipment id)."""
    if cell < 24:
        return WEAPON_NAMES.get(cell, f'(weapon id {cell})')
    return ARMOR_NAMES.get(cell - 24, f'(armor id {cell - 24})')


def item_class(cell):
    if cell < 5:
        return '剣 sword'
    if cell < 8:
        return '剣 sword (unused)'
    if cell < 14:
        return '刀 blade'
    if cell < 16:
        return '刀 blade (hidden)'
    if cell < 22:
        return '槍 spear'
    if cell < 24:
        return '槍 spear (hidden)'
    if cell < 30:
        return '防具 armor'
    return '防具 armor (hidden)'


def load_province_names():
    """id -> (katakana, zh_hans, kanji_ja) from docs/province_names.csv."""
    path = os.path.join(ROOT, 'docs', 'province_names.csv')
    names = {}
    with open(path, encoding='utf-8', newline='') as f:
        for row in csv.DictReader(f):
            names[int(row['id'])] = (row['katakana'], row.get('zh_hans', ''),
                                     row.get('kanji_ja', ''))
    return names


def extract():
    """Return (town_rows, stock_rows, catalog_rows, rice_rows)."""

    def bank(path):
        with open(os.path.join(ROOT, path), 'rb') as f:
            return f.read()

    b1c, b09, b30 = bank(B1C), bank(B09), bank(B30)
    names = load_province_names()

    town_types = b1c[TOWN_TYPE_OFF:TOWN_TYPE_OFF + PROVINCE_COUNT]
    formations = b1c[ARMORY_FORMATION_OFF:ARMORY_FORMATION_OFF + PROVINCE_COUNT]
    routes = b1c[FACILITY_ROUTE_OFF:FACILITY_ROUTE_OFF + 10 * 4]
    layouts = b09[FORMATION_LAYOUT_OFF:FORMATION_LAYOUT_OFF + 6 * 16]
    prices = struct.unpack_from('<32H', b09, PRICE_TABLE_OFF)
    rates = b30[RICE_RATE_OFF:RICE_RATE_OFF + PROVINCE_COUNT * 2]

    town_rows, stock_rows, catalog_rows, rice_rows = [], [], [], []
    sold_in = {}

    for pid in range(PROVINCE_COUNT):
        kata, zh, kanji = names.get(pid, ('', '', ''))
        ttype = town_types[pid]
        form = formations[pid]
        cells = sorted(layouts[form * 16:form * 16 + 16])
        have = sorted({r for r in routes[ttype * 4:ttype * 4 + 4]
                       if r != 0xFF})
        town_rows.append({
            'province_id': pid,
            'katakana': kata,
            'zh_hans': zh,
            'kanji_ja': kanji,
            'town_type': ttype,
            'bukiya': 'yes' if 0 in have else '',
            'gakumonjo': 'yes' if 1 in have else '',
            'byouin': 'yes' if 2 in have else '',
            'shouten': 'yes' if 3 in have else '',
            'facilities_abbr': '/'.join(FACILITY_SHORT[c] for c in have),
            'armory_formation_id': form,
        })
        for cell in cells:
            price = prices[cell]
            if not price:
                continue
            sold_in.setdefault(cell, []).append(pid)
            stock_rows.append({
                'province_id': pid,
                'province': f'{zh} {kata}',
                'item_id': cell,
                'item_name': item_name(cell),
                'category': item_class(cell),
                'price_gold': price,
            })
        sell_rate, buy_rate = rates[pid * 2], rates[pid * 2 + 1]
        rice_rows.append({
            'province_id': pid,
            'province': f'{zh} {kata}',
            'has_market': 'yes' if 3 in have else 'no',
            'buy_rate_rice_per_100g': buy_rate,
            'sell_rate_rice_per_100g': sell_rate,
            'buy_price_gold_per_rice':
                round(100 / buy_rate, 2) if buy_rate else '',
            'sell_price_gold_per_rice':
                round(100 / sell_rate, 2) if sell_rate else '',
        })

    for cell in range(32):
        price = prices[cell]
        where = sold_in.get(cell, [])
        catalog_rows.append({
            'item_id': cell,
            'item_name': item_name(cell),
            'category': item_class(cell),
            'price_gold': price if price else '',
            'sold_at_189_start': ('yes' if where else
                                  ('no (unpriced)' if not price else
                                   'no (hidden item)')),
            'provinces': ' '.join(str(p) for p in where),
        })

    return town_rows, stock_rows, catalog_rows, rice_rows


def write_csv(path, rows, cols):
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        w.writerows(rows)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--check', action='store_true',
                    help='validate only, write nothing')
    ap.add_argument('--print', dest='dump', action='store_true',
                    help='also dump the tables to stdout')
    args = ap.parse_args()

    town_rows, stock_rows, catalog_rows, rice_rows = extract()

    # sanity checks
    problems = []
    if len(town_rows) != PROVINCE_COUNT:
        problems.append(f'{len(town_rows)} town rows, expected '
                        f'{PROVINCE_COUNT}')
    for r in town_rows:
        if not any(r[k] for k in ('bukiya', 'gakumonjo', 'byouin',
                                  'shouten')):
            problems.append(f"province {r['province_id']}: no facilities")
    for r in rice_rows:
        if r['has_market'] == 'no' and r['buy_rate_rice_per_100g']:
            problems.append(f"province {r['province_id']}: market-less "
                            'province has a rice rate')
        if r['has_market'] == 'yes' and not r['buy_rate_rice_per_100g']:
            problems.append(f"province {r['province_id']}: market province "
                            'has no rice rate')
    for p in problems:
        print(f'FAIL: {p}', file=sys.stderr)
    if problems:
        return 1
    markets = sum(1 for r in rice_rows if r['has_market'] == 'yes')
    print(f'ok: {len(town_rows)} provinces, {len(stock_rows)} armory stock '
          f'rows, {markets} market provinces')

    if args.check:
        return 0

    docs = os.path.join(ROOT, 'docs')
    os.makedirs(docs, exist_ok=True)
    write_csv(os.path.join(docs, 'town_commands.csv'), town_rows,
              ['province_id', 'katakana', 'zh_hans', 'kanji_ja', 'town_type',
               'bukiya', 'gakumonjo', 'byouin', 'shouten',
               'facilities_abbr', 'armory_formation_id'])
    write_csv(os.path.join(docs, 'armory_stock.csv'), stock_rows,
              ['province_id', 'province', 'item_id', 'item_name', 'category',
               'price_gold'])
    write_csv(os.path.join(docs, 'equipment_catalog.csv'), catalog_rows,
              ['item_id', 'item_name', 'category', 'price_gold',
               'sold_at_189_start', 'provinces'])
    write_csv(os.path.join(docs, 'rice_prices.csv'), rice_rows,
              ['province_id', 'province', 'has_market',
               'buy_rate_rice_per_100g', 'sell_rate_rice_per_100g',
               'buy_price_gold_per_rice', 'sell_price_gold_per_rice'])
    for name in ('town_commands.csv', 'armory_stock.csv',
                 'equipment_catalog.csv', 'rice_prices.csv'):
        print(f'  wrote docs/{name}')

    if args.dump:
        print('\n== town commands ==')
        for r in town_rows:
            print(f"{r['province_id']:>2} {r['facilities_abbr']:<7} "
                  f"type={r['town_type']} form={r['armory_formation_id']} "
                  f"{r['zh_hans']} {r['katakana']}")
        print('\n== rice rates (rice per 100 gold) ==')
        for r in rice_rows:
            print(f"{r['province_id']:>2} buy={r['buy_rate_rice_per_100g']:<3} "
                  f"sell={r['sell_rate_rice_per_100g']:<3} {r['province']}")
        print('\n== armory catalog ==')
        for r in catalog_rows:
            print(f"{r['item_id']:>2} {r['item_name']:<28} "
                  f"{r['category']:<22} {r['price_gold'] or '-':>4} "
                  f"{r['sold_at_189_start']}")
    return 0


if __name__ == '__main__':
    sys.exit(main() or 0)
