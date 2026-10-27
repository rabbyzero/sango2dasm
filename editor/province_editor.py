#!/usr/bin/env python3
"""Sangokushi 2 province editor - standalone GUI for the 30 seed records.

What it edits
-------------
The 30 Provinces (州) of *Sangokushi 2 - Haou no Tairiku* (Famicom,
Namco-163 / mapper 19) as the new game seeds them:

| table | bank | CPU | shape | edited through |
|---|---|---|---|---|
| master records | `$30` | `$8C00` | 30 x 32 B | `docs/province_data.csv` |
| katakana names | `$30` | `$9A1A` | 30 x 8 B, `$00`-terminated | `docs/province_data.csv` |
| officer rosters | `$30` | `$8C00 + $11..$1A` | 30 x 10 slots, `$FF` = empty | `docs/province_data.csv` |

The master record is the seed image of the province's SRAM record at
`id * 32 + $6000`. `SramInit` (`$DD8B`) copies exactly `$3C0` bytes = the 30
records, so these bytes are the new game:

    +0  所属国 Country (low nibble, 7 = 空白地 UnclaimedLand)
    +2  金 Gold        (16-bit LE, <= 9999)
    +4  米 Rice        (16-bit LE, <= 9999)
    +6  人口 Population (16-bit LE, displayed x 100)
    +8  土地 LandValue  (<= 999, annual Rice harvest)
    +A  防災 DisasterPrevention (<= 99)
    +B  統治度 Governance (<= 100; below 50 the annual check rolls a rebellion)
    +C  控え ReserveTroops (16-bit LE, <= 9999; 徴兵 adds here)
    +E  産業 Industry   (<= 999, annual Gold tax)
    +10 宝 Treasure     (<= 99)
    +11..+1A 武将 roster (10 ids, $FF = empty; +$11 is the 太守 governor)
    +1B 反乱クールダウン RebellionCooldown (runtime, 0 in the seed)

The roster is the cross-bank half of the officer invariant: every id in a
roster slot is exactly an officer whose seed status (`+0B` bits 0-1) is 2, and
every other officer is 1 (hidden). Assign and Remove are the only way this
editor moves 状態, and they edit `docs/officer_data.csv` in the same save.
That cross-bank gate is re-proved on the assembled bytes by
`tools/verify_data_banks.py`.

Names: the katakana field is live (`docs/province_data.csv`); the kanji /
simplified / pinyin columns are annotations and stay read-only.

What it shows (read-only)
-------------------------
The province selector is a two-tab notebook: **List 一覧** (the editable
table) and **Strategy map 戦略図**. The map is the game's own screen —
`StrategyMapBaseScreen` (bank $10 `$8000`) rendered through display record 0
(CHR pages `00 01 02 10`) and palette record 0, cropped to the authored
map band (tile rows 0-19) and overlaid with the province marker sprites
(bank $1C `$DFC0`/`$DFC8`, sprite page `$04`) — and it is a selector, not a
diagram: clicking a point resolves the province exactly as
`MapProvinceHitTest` (`$DEBA`) does — 16 × 16 zones from the `$DEE9`/`$DF07`
origin tables, scanned id `$1D` down to 0. The line below the map lists the
selected province's neighbour slots with their attack/defense side types
(bank $30 `$9D72`, selectors `$9E62` bank $10 / `$9AB4` bank $11).

The detail pane is a three-tab notebook. Besides the Record tab above:

* **Town 町** — the province's town type (`$C025`, bank $1C) and the four
  facility screens it routes to (武器屋 armory / 学問所 academy / 病院
  hospital / 商店 market, `$C10E`), the `ProvinceFacilityFlags` bits (兵/学/町/
  募, bank $30 `$8FFC`), the rice trade rates (bank $30 `$8FC0`) and the
  armory's 16-cell grid (formation id `$C801` fanned through
  `FormationTileLayouts`, priced by `ItemPriceTable` bank $09 `$C89E`).
* **Tactical map 戦術図** — the province's authored 32 × 20 terrain (the same
  bytes `tools/terrain_model.py` decodes) with the buildings the console draws on
  top: 城 from `ProvincePixelPositionTable` (bank $11 `$9D58`) and the 民/武/病
  towns from `ProvinceTacticalFacilityTiles` (`$9BA4`), both through the codec's
  row fixup, plus the initial deployment geometry from bank $06: one initial
  area **per approach route** — the side type is keyed on the adjacency slot
  holding the opposing province, so each attack record is the area used when
  that specific neighbour marches in. All routes draw at once in their own
  colours (`(y, x)` pairs, anchor = pair 0, rows ≥ `$10` rendered one row
  higher — the `GetOrderedDestination` quirk) beside the city bounds
  rectangles the 出兵 command checks; the dropdowns isolate one type.

These tables have no CSV editing surface (the town tables live inside the
disassembled code bank $1C), so the three views decode the ROM and edit
nothing. Outside the repo they degrade to a note.

Running it
----------
    python3 editor/province_editor.py
    python3 editor/province_editor.py --province-csv province_data.csv \
        --officer-csv officer_data.csv
    make province-editor

Dependencies: Python 3 with `tkinter` only (stdlib). The codec is
`tools/officer_model.py`; `--model PATH` (or a copy of that file next to this
script) points the editor at it, which is what lets the editor travel outside
the disassembly repo with nothing but the two CSVs. Without the repo the
*Write ASM* / *Verify* buttons explain that the generator lives there; editing,
the invariant report, `Save CSVs` and `Diff` all keep working.

Editing model
-------------
The CSVs are the editing surface, exactly as for the officer and terrain
editors: `Save CSVs` writes them, and `Write ASM` then runs

    tools/gen_data_bank_asm.py --bank all --from-csv --write
    tools/verify_data_banks.py --allow-edits

so the assembly is re-rendered by the repo's own generator and the byte gate
reports every deliberate edit in decoded terms. Nothing here writes
`rom/prg/*.bin`; the stock dumps stay the reference images for byte-exactness.
"""
import argparse
import base64
import os
import struct
import subprocess
import sys
import tkinter as tk
import tkinter.font as tkfont
import zlib
from tkinter import filedialog, messagebox, ttk

MAX_UNDO = 60
TABLE_H = 18                   # table rows requested; the pane stretches
ROW_PAD = 8                    # row height = font linespace + this, so CJK
                               # fallback glyphs are never clipped mid-stroke
DETAIL_W = 560                 # requested detail pane width; the resource grid
                               # and roster table set the floor
WRAP_MARGIN = 40               # pane padding a wrapped label must stay inside
TACTICAL_CELL = 14             # tactical map zoom: 32 x 20 cells
MAP_SCALE = 3                  # strategy map zoom (author map band)
MAP_ROWS = 20                  # rows 0-19; rows 20-29 are the blank panel band
FACILITY_SCREENS = {0: '武器屋 Armory', 1: '学問所 Academy',
                    2: '病院 Hospital', 3: '商店 Market'}
FACILITY_FLAG_BITS = ((0, '兵', 'war-AI action gate'),
                      (1, '学', 'town-command facility flag'),
                      (2, '町', 'working rice market'),
                      (3, '募', 'recruit / transfer eligible'))
# One colour per side type: the side type is keyed on the adjacency slot
# holding the opposing province, so each attack record is the initial area of
# one approach route (bank $06 pools; selectors bank $10 $9E62 / bank $11
# $9AB4). Attack runs reach 4 records, defense runs 2.
ATTACK_PALETTE = ('#d63031', '#e67e22', '#8e44ad', '#c2185b',
                  '#8fa800', '#5d4037', '#00838f', '#6d4c41')
DEFENSE_PALETTE = ('#2471a3', '#148f77', '#5b4fc0', '#008ba3',
                   '#4a148c', '#1b5e20', '#ad1457', '#455a64')
COLUMN_WIDTHS = {
    'id': 44, 'katakana': 104, 'zh_hans': 72, 'country': 44,
    'gold': 50, 'rice': 50, 'population': 64, 'land_value': 48,
    'industry': 50, 'disaster_prevention': 44, 'governance': 46,
    'reserve_troops': 52, 'treasure': 42, 'roster': 44,
    'active_troops': 54, 'governor': 110,
}
PICKER_NOTE = (
    'The roster is the cross-bank 状態 gate: a rostered officer is exactly an '
    'officer seed record whose +0B bits 0-1 are 2. Picking an officer who is '
    'already rostered elsewhere moves him out of that province, so the two '
    'CSVs stay consistent.')
ARRIVAL_PICKER_NOTE = (
    'The arrival schedule (bank $31 $8B1C, walked by OfficerArrivalScan $B964, '
    'the 探索 scout handler) only lists 状態 1 hidden officers: once his pair '
    'year is reached, scouting this province finds him. Picking an officer '
    'who is already scheduled elsewhere moves his arrival here.')
TOWN_NOTE = (
    'Read-only: the town type ($C025), facility routes ($C10E) and armory '
    'formation id ($C801) live inside the disassembled code bank $1C, and the '
    'rice rates / facility flags render straight from the ROM bytes - none of '
    'them has a CSV editing surface, so this tab only decodes what the game '
    'shows. The town screen facility list comes from the town type, not from '
    'the flag bits; the bits gate the war-AI loop (兵), a town command (学), '
    'the working market (町) and recruit/transfer eligibility (募).')

# NES 2C02 palette, $3F00-$3F3F as RGB.
NES_RGB_HEX = (
    '606060003298001aac280098540070740028682000443c001c5000005c00005028003858000000000000000000000000'
    'b2b2b21480db2860ff5c3cffa028dcd01c74e83028c060008c8c004cb00014c83000c87800b8d8000000000000000000'
    'f0f4f844c4ff68a8ffb488fffc74f8fc74a0fc9458e8b400bcd40088fc1040fc4c00f88c00e8e800000000000000f800'
    'f8f8f8a8f0f8c0dcf8d8c8f8f8b8f8f8b4d8f8c8b8f8d878e8e860c0f878a8f89ca8f8d8a8f0f8a8a8a8fcfcfc000000')
NES_RGB = tuple((int(NES_RGB_HEX[i:i + 2], 16),
                 int(NES_RGB_HEX[i + 2:i + 4], 16),
                 int(NES_RGB_HEX[i + 4:i + 6], 16))
                for i in range(0, len(NES_RGB_HEX), 6))


def chr_tile(chr_dir, page, index):
    """8x8 2-bit colour indices of one BG/sprite tile.

    A Namco-163 CHR page value V lives at chr_(V//8).bin, offset (V%8)*$400
    (the repo's CHR split); each tile is 16 bytes, plane 0 then plane 1.
    """
    path = os.path.join(chr_dir, 'chr_%02x.bin' % (page // 8))
    with open(path, 'rb') as f:
        f.seek((page % 8) * 0x400 + index * 16)
        plane0 = f.read(8)
        plane1 = f.read(8)
    return [[((plane0[y] >> (7 - x)) & 1) |
             (((plane1[y] >> (7 - x)) & 1) << 1)
             for x in range(8)] for y in range(8)]


def strategy_map_hit(x, y, zone_x, zone_y):
    """Province id at a strategy-map point, or None.

    Byte-identical to MapProvinceHitTest ($DEBA, bank $1C): a point in the
    top-left $20 x $20 corner belongs to no province, and the zone scan runs
    from id $1D down to 0, so the higher id wins. Each zone is
    [origin, origin + $10) on both axes, tested on the 8-bit difference.
    """
    if x < 0x20 and y < 0x20:
        return None
    for pid in range(len(zone_x) - 1, -1, -1):
        if ((x - zone_x[pid]) & 0xFF) < 0x10 and \
                ((y - zone_y[pid]) & 0xFF) < 0x10:
            return pid
    return None


def strategy_map_pixels(data, countries, scale=MAP_SCALE):
    """RGB rows of the in-game strategy map plus its OAM province markers.

    The background is StrategyMapBaseScreen (bank $10 $8000, 960 tiles + 64
    attribute bytes) drawn with display record 0's BG pages and palette
    record 0. Only the authored map band (tile rows 0-19) is kept: rows 20-29
    of the screen are the blank $36-coloured band the game's overlay panels
    occupy. The markers are the game's own 8x8 OAM icons at the zone origins:
    MapProvinceSpriteRefresh ($DF35) picks tile $DFC0[country & 7] and
    attribute $DFC8[country & 7] for every province, using sprite slot 0 of
    the same display record.
    """
    screen = data['map_screen']
    tiles, attrs = screen[:960], screen[960:1024]
    palette = data['palette0']
    record = data['map_display']
    bg_pages, sprite_page = record[4:8], record[0]
    cache = {}

    def tile(page, index):
        key = (page, index)
        if key not in cache:
            cache[key] = chr_tile(data['chr_dir'], page, index)
        return cache[key]

    def colour(index):
        return NES_RGB[palette[index] & 0x3F]

    width, height = 256 * scale, MAP_ROWS * 8 * scale
    img = [[colour(0)] * width for _ in range(height)]
    for row in range(MAP_ROWS):
        for col in range(32):
            value = tiles[row * 32 + col]
            bitmap = tile(bg_pages[value >> 6], value & 0x3F)
            # One 2-bit BG palette per 2x2 tile block.
            bgpal = (attrs[(row >> 2) * 8 + (col >> 2)]
                     >> ((row & 2) * 2 + ((col & 2) >> 1) * 2)) & 3
            for y in range(8):
                for x in range(8):
                    ci = bitmap[y][x]
                    px = colour(0 if ci == 0 else 1 + 4 * bgpal + ci - 1)
                    for dy in range(scale):
                        line = img[(row * 8 + y) * scale + dy]
                        for dx in range(scale):
                            line[(col * 8 + x) * scale + dx] = px
    for pid, (x, y) in enumerate(zip(data['zone_x'], data['zone_y'])):
        kind = countries[pid] & 7
        bitmap = tile(sprite_page, data['marker_tiles'][kind])
        spal = data['marker_attrs'][kind] & 3
        for sy in range(8):
            for sx in range(8):
                ci = bitmap[sy][sx]
                if not ci:                      # sprite colour 0 = transparent
                    continue
                px = colour(16 + 4 * spal + ci)
                for dy in range(scale):
                    line = img[(y + sy) * scale + dy]
                    for dx in range(scale):
                        line[(x + sx) * scale + dx] = px
    return img


def png_bytes(rows):
    """RGB rows as a PNG byte string (Tk 8.6 loads PNG from a data string)."""
    height, width = len(rows), len(rows[0])
    raw = b''.join(b'\x00' + bytes(value for px in row for value in px)
                   for row in rows)

    def chunk(tag, payload):
        return (struct.pack('>I', len(payload)) + tag + payload +
                struct.pack('>I', zlib.crc32(tag + payload) & 0xFFFFFFFF))
    return (b'\x89PNG\r\n\x1a\n' +
            chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2,
                                       0, 0, 0)) +
            chunk(b'IDAT', zlib.compress(raw, 9)) +
            chunk(b'IEND', b''))


# --- codec import --------------------------------------------------------
def load_model(cli_path=None):
    """Import officer_model from --model, a local copy, or the parent repo."""
    here = os.path.dirname(os.path.abspath(__file__))
    repo = os.path.dirname(here)
    directories = []
    if cli_path:
        directories.append(cli_path if os.path.isdir(cli_path)
                           else os.path.dirname(os.path.abspath(cli_path)))
    directories += [here, os.path.join(repo, 'tools')]
    for directory in directories:
        candidate = os.path.join(directory, 'officer_model.py')
        if os.path.exists(candidate):
            if directory not in sys.path:
                sys.path.insert(0, directory)
            import officer_model
            return officer_model, directory
    raise SystemExit(
        'officer_model.py not found (looked in: %s).\n'
        'Pass --model PATH, drop a copy next to this script, or keep it inside\n'
        'the sango2dasm repo where tools/officer_model.py lives.'
        % ', '.join(directories))


def combo_width(values):
    """Width units for a combobox that must show every value unclipped.

    Tk counts `width` in average-size characters, but these labels mix CJK
    with ASCII, so a fixed count clips them. Measure the longest value with
    the font the widget actually renders and convert through '0'.
    """
    font = tkfont.nametofont('TkTextFont')
    unit = font.measure('0')
    return max(4, max((font.measure(str(v)) for v in values), default=unit)
               // unit + 2)


def item_category(cell):
    """Catalog class of an armory cell (== equipment id)."""
    if cell < 24:
        base = ('剣 sword', '刀 blade', '槍 spear')[cell // 8]
        special = cell in (5, 6, 7, 14, 15, 22, 23)
    else:
        base = '防具 armor'
        special = cell in (30, 31)
    return base + (' (special)' if special else '')


# --- read-only ROM tables (bank $01/$06/$09/$10/$11/$1C/$1E) --------------
# These tables have no CSV editing surface - town types and the armory
# formation live inside the disassembled code bank $1C, and the tactical
# geometry is generated straight from the ROM - so the views below are
# read-only on purpose. Every offset is the one the repo's generators and
# docs pin (tools/extract_town_data.py, tools/gen_data_bank_06_asm.py,
# data_10_initial_data.asm / data_11_officer.asm), and the strategy-map
# record/palette/zone/marker offsets are the readers themselves
# (MenuFontRecordLoad $DE7E, PaletteRecordLoad $DBB1, MapProvinceHitTest
# $DEBA, MapProvinceSpriteRefresh $DF35).
def load_repo_data(repo):
    """Parse the ROM-authored tables the Town / Map / Tactical views show."""
    if not repo:
        return None
    prg = os.path.join(repo, 'rom', 'prg')

    def bank(name):
        path = os.path.join(prg, name)
        if not os.path.exists(path):
            raise OSError(path)
        with open(path, 'rb') as f:
            return f.read()

    try:
        b10, b11, b1c, b09, b06, b01, b1e = (
            bank(n) for n in ('prg_10.bin', 'prg_11.bin', 'prg_1c.bin',
                              'prg_09.bin', 'prg_06.bin', 'prg_01.bin',
                              'prg_1e.bin'))
    except OSError:
        return None
    try:
        import terrain_model as terrain
    except ImportError:
        terrain = None

    import struct
    town_types = b1c[0x0025:0x0025 + 30]
    routes = b1c[0x010E:0x010E + 40]
    formations = b1c[0x0801:0x0801 + 30]
    layouts = b09[0x08DE:0x08DE + 6 * 16]
    prices = struct.unpack_from('<32H', b09, 0x089E)
    rates = b10[0x0FC0:0x0FC0 + 60]
    flags = b10[0x0FFC:0x0FFC + 30]
    adjacency = [b10[0x1D72 + p * 8:0x1D72 + (p + 1) * 8] for p in range(30)]
    attack_types = [b10[0x1E62 + p * 8:0x1E62 + (p + 1) * 8]
                    for p in range(30)]
    defense_types = [b11[0x1AB4 + p * 8:0x1AB4 + (p + 1) * 8]
                     for p in range(30)]
    # The two bank $11 marker tables place the sprites the console draws, through
    # the terrain codec so its $0F-skipping row fixup stays in one place.
    facility_tiles = None if terrain is None else terrain.load_facilities()
    castle_cells = None if terrain is None else terrain.load_castles()

    def pool_groups(ptr_cpu, region_end, stride):
        base = ptr_cpu - 0x8000
        ptrs = [b06[base + 2 * i] | b06[base + 2 * i + 1] << 8
                for i in range(30)]
        groups = []
        for i, start in enumerate(ptrs):
            end = ptrs[i + 1] if i + 1 < 30 else region_end
            records = []
            for addr in range(start, end, stride):
                off = addr - 0x8000
                pairs = [(b06[off + 2 * k], b06[off + 2 * k + 1])
                         for k in range(stride // 2)]
                records.append(pairs)
            groups.append(records)
        return groups

    def rect_groups(ptr_cpu, region_end):
        base = ptr_cpu - 0x8000
        ptrs = [b06[base + 2 * i] | b06[base + 2 * i + 1] << 8
                for i in range(30)]
        groups = []
        for i, start in enumerate(ptrs):
            end = ptrs[i + 1] if i + 1 < 30 else region_end
            groups.append([tuple(b06[addr - 0x8000:addr - 0x8000 + 4])
                           for addr in range(start, end, 4)])
        return groups

    attack_groups = pool_groups(0x8000, 0x8C52, 34)
    defense_groups = pool_groups(0x8C52, 0x932E, 32)
    return {
        'terrain': terrain,
        'town_types': town_types,
        'routes': routes,
        'formations': formations,
        'layouts': layouts,
        'prices': prices,
        'rates': rates,
        'flags': flags,
        'adjacency': adjacency,
        'attack_types': attack_types,
        'defense_types': defense_types,
        # Strategy map: the pre-baked nametable, the display/palette records
        # State_StrategyMapLaunch arms, and MapProvinceHitTest's zone tables.
        'map_screen': b10[0x0000:0x0400],
        'map_display': b01[0x146C:0x146C + 48],
        'palette0': b1e[0x1BEB:0x1BEB + 32],
        'zone_x': b1c[0x1EE9:0x1EE9 + 30],
        'zone_y': b1c[0x1F07:0x1F07 + 30],
        'marker_tiles': b1c[0x1FC0:0x1FC8],
        'marker_attrs': b1c[0x1FC8:0x1FD0],
        'chr_dir': os.path.join(repo, 'rom', 'chr'),
        'facility_tiles': facility_tiles,
        'castle_cells': castle_cells,
        'attack_pools': attack_groups,
        'defense_pools': defense_groups,
        'attack_bounds': rect_groups(0x932E, 0x94D6),
        'defense_bounds': rect_groups(0x94D6, 0x95E6),
    }


def row_height():
    """The font linespace floor for a Treeview row in this theme."""
    return max(tkfont.nametofont(name).metrics('linespace')
               for name in ('TkTextFont', 'TkDefaultFont', 'TkHeadingFont')) \
        + ROW_PAD


class OfficerPicker(tk.Toplevel):
    """Pick an officer for a roster slot or an arrival entry, with a filter."""

    def __init__(self, parent, model, province, mode='roster'):
        super().__init__(parent)
        self.model = model
        self.province = province
        self.mode = mode
        self.result = None
        self.title('Add officer to %s' % province.title())
        self.geometry('820x560')
        self.minsize(680, 420)
        self.transient(parent)
        ttk.Label(self, text=PICKER_NOTE if mode == 'roster'
                  else ARRIVAL_PICKER_NOTE, wraplength=780,
                  justify='left').pack(fill='x', padx=8, pady=(8, 4))
        top = ttk.Frame(self)
        top.pack(fill='x', padx=8, pady=(0, 4))
        ttk.Label(top, text='Filter').pack(side='left')
        self.filter_var = tk.StringVar()
        entry = ttk.Entry(top, textvariable=self.filter_var, width=28)
        entry.pack(side='left', padx=(3, 8))
        entry.bind('<Return>', lambda e: self._refresh())
        self.filter_var.trace_add('write', lambda *a: self._refresh())
        entry.focus_set()

        frame = ttk.Frame(self)
        frame.pack(fill='both', expand=True, padx=8)
        style = ttk.Style(self)
        style.configure('Picker.Treeview', rowheight=row_height())
        self.tree = ttk.Treeview(
            frame, columns=('id', 'name', 'status', 'place', 'troops'),
            show='headings', selectmode='browse', height=16,
            style='Picker.Treeview')
        for key, text, width, anchor in (
                ('id', 'id', 48, 'e'), ('name', '名前', 210, 'w'),
                ('status', '状態', 90, 'w'), ('place', 'now', 260, 'w'),
                ('troops', '兵数', 64, 'e')):
            self.tree.heading(key, text=text)
            self.tree.column(key, width=width, anchor=anchor, stretch=True)
        vsb = ttk.Scrollbar(frame, orient='vertical',
                            command=self.tree.yview)
        self.tree.configure(yscrollcommand=vsb.set)
        self.tree.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        self.tree.tag_configure('elsewhere', foreground='#8a5a00')
        self.tree.bind('<Double-1>', lambda e: self._ok())
        self.tree.bind('<Return>', lambda e: self._ok())

        buttons = ttk.Frame(self)
        buttons.pack(fill='x', padx=8, pady=8)
        ttk.Button(buttons, text='Cancel', command=self.destroy).pack(
            side='right')
        ttk.Button(buttons, text='Add', command=self._ok).pack(
            side='right', padx=(0, 4))
        self._refresh()
        self.tree.focus_set()
        self.grab_set()

    def _refresh(self):
        needle = self.filter_var.get().strip().lower()
        self.tree.delete(*self.tree.get_children())
        for off in self.model.officers:
            if self.mode == 'roster':
                if off.id in self.province.roster:
                    continue
                place = ('province %s' % self.model.province(
                    off.roster_province).title()
                    if off.roster_province is not None else
                    ('arrives %d' % off.appear_year
                     if off.appear_year is not None else ''))
                elsewhere = off.roster_province is not None
            else:
                if not off.is_hidden:
                    continue
                if off.schedule_province_id == self.province.id \
                        and off.appear_year is not None:
                    continue
                place = ('arrives %d @%s' % (
                    off.appear_year,
                    self.model.province(off.schedule_province_id).title())
                    if off.appear_year is not None
                    and off.schedule_province_id is not None else
                    ('no arrival entry' if off.is_hidden and
                     off.appear_year is None else 'arrival entry incomplete'))
                elsewhere = off.appear_year is not None
            if needle:
                haystack = ' '.join(str(x) for x in (
                    off.id, off.katakana, off.zh_hans, off.kanji_ja,
                    off.label, place, off.officer_status)).lower()
                if needle not in haystack:
                    continue
            self.tree.insert(
                '', 'end', iid=str(off.id),
                tags=('elsewhere',) if elsewhere else (),
                values=(off.id, off.name, off.officer_status, place,
                        off.troop_count))

    def _ok(self):
        selection = self.tree.selection()
        if not selection:
            return
        self.result = int(selection[0])
        self.destroy()


class ProvinceEditor(tk.Tk):
    """The province seed-data editor: one table, one detail pane, one gate."""

    def __init__(self, m, repo=None, officer_csv=None, province_csv=None):
        super().__init__()
        self.m = m
        self.repo = repo
        self.undo = []
        self.redo = []
        self.w = {}
        self.wrapping = []
        self.scrollers = []
        self.current = None
        self._loading = False
        self.data = load_repo_data(repo)
        self._terrain_banks = {}
        self.title('Sangokushi 2 province editor')
        self.geometry('1440x860')
        self.minsize(1120, 640)
        self._build_ui()
        self.load_paths(officer_csv, province_csv)
        self._refresh_all()
        self.protocol('WM_DELETE_WINDOW', self.on_close)

    # -- construction ----------------------------------------------------
    def _build_ui(self):
        self.status = tk.StringVar(value='')
        self._build_toolbar()
        body = ttk.PanedWindow(self, orient='horizontal')
        body.pack(fill='both', expand=True, padx=4, pady=(0, 2))
        body.add(self._build_selector(), weight=1)
        body.add(self._build_detail(), weight=0)
        bottom = ttk.PanedWindow(self, orient='horizontal')
        bottom.pack(fill='x', padx=4, pady=(0, 2))
        bottom.add(self._build_report(), weight=1)
        bottom.add(self._build_log(), weight=1)
        ttk.Label(self, textvariable=self.status, anchor='w',
                  relief='sunken').pack(fill='x', side='bottom')
        self.bind('<Control-s>', lambda e: self.save_csv())
        self.bind('<Control-b>', lambda e: self.write_asm())
        self.bind('<Control-z>', lambda e: self.undo_edit())
        self.bind('<Control-y>', lambda e: self.redo_edit())
        self.bind('<Control-f>', lambda e: self.focus_filter())
        self.bind('<Escape>', lambda e: self.clear_filter())
        self.bind_all('<KeyPress>', self._on_key, add='+')

    def _build_toolbar(self):
        bar = ttk.Frame(self)
        bar.pack(fill='x', padx=4, pady=3)
        left = ttk.Frame(bar)
        left.pack(side='left')
        for text, command, tip in (
                ('Open CSVs…', self.open_csv,
                 'load another province_data.csv and its officer_data.csv'),
                ('Save CSVs', self.save_csv,
                 'write province_data.csv and officer_data.csv (Ctrl+S)'),
                ('Write ASM', self.write_asm,
                 'save, then re-render the seed banks and report the decoded '
                 'edits (Ctrl+B)'),
                ('Verify', self.verify,
                 'run tools/verify_data_banks.py --allow-edits'),
                ('Diff', self.show_diff, 'list the edits not yet in the CSVs'),
                ('Revert', self.reload, 'reload the CSVs, discarding edits'),
                ('Undo', self.undo_edit, 'Ctrl+Z'),
                ('Redo', self.redo_edit, 'Ctrl+Y')):
            button = ttk.Button(left, text=text, command=command)
            button.pack(side='left', padx=(0, 3))
            self._tip(button, tip)
        right = ttk.Frame(bar)
        right.pack(side='right')
        ttk.Label(right, text='Filter').pack(side='left')
        self.filter_var = tk.StringVar()
        self.filter_entry = ttk.Entry(right, textvariable=self.filter_var,
                                      width=22)
        self.filter_entry.pack(side='left', padx=(2, 8))
        self.filter_entry.bind('<Return>', lambda e: self._refresh_table())
        self.filter_var.trace_add('write', lambda *a: self._refresh_table())

    def _build_selector(self):
        """The province selector: the list and the in-game strategy map."""
        self.selector = ttk.Notebook(self)
        list_tab = ttk.Frame(self.selector)
        self.selector.add(list_tab, text='List 一覧')
        self._build_table(list_tab).pack(fill='both', expand=True)
        map_tab = ttk.Frame(self.selector)
        self.selector.add(map_tab, text='Strategy map 戦略図')
        self._build_strategy_map(map_tab)
        return self.selector

    def _build_table(self, parent=None):
        frame = ttk.Frame(parent or self)
        style = ttk.Style(self)
        style.configure('Province.Treeview', rowheight=row_height())
        self.tree = ttk.Treeview(
            frame, columns=[k for k, _, _ in self.m.PROVINCE_COLUMNS],
            show='headings', height=TABLE_H, selectmode='browse',
            style='Province.Treeview')
        for key, heading, align in self.m.PROVINCE_COLUMNS:
            self.tree.heading(key, text=heading)
            self.tree.column(key, width=COLUMN_WIDTHS.get(key, 60),
                             anchor=align, stretch=False)
        vsb = ttk.Scrollbar(frame, orient='vertical', command=self.tree.yview)
        hsb = ttk.Scrollbar(frame, orient='horizontal',
                            command=self.tree.xview)
        self.tree.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        self.tree.grid(row=0, column=0, sticky='nsew')
        vsb.grid(row=0, column=1, sticky='ns')
        hsb.grid(row=1, column=0, sticky='ew')
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        self.tree.tag_configure('problem', foreground='#b00020')
        self.tree.tag_configure('edited', foreground='#0b4f8a')
        self.tree.tag_configure('unclaimed', foreground='#666666')
        self.tree.bind('<<TreeviewSelect>>', self._on_select)
        return frame

    def _build_detail(self):
        self.notebook = ttk.Notebook(self, width=DETAIL_W)
        record_tab = ttk.Frame(self.notebook)
        self.notebook.add(record_tab, text='Record 記録')
        self.detail = self._scroll_frame(record_tab)
        self._build_identity()
        self._build_resources()
        self._build_roster()
        self._build_arrival()
        self._build_country()
        self._build_record()

        town_tab = ttk.Frame(self.notebook)
        self.notebook.add(town_tab, text='Town 町')
        self.town_detail = self._scroll_frame(town_tab)
        self._build_town()

        tac_tab = ttk.Frame(self.notebook)
        self.notebook.add(tac_tab, text='Tactical map 戦術図')
        self._build_tactical_map(tac_tab)
        return self.notebook

    def _scroll_frame(self, parent):
        """A width-pinned scrolling frame; every tab shares the configure."""
        outer = ttk.Frame(parent)
        canvas = tk.Canvas(outer, highlightthickness=0, width=DETAIL_W)
        vsb = ttk.Scrollbar(outer, orient='vertical', command=canvas.yview)
        inner = ttk.Frame(canvas)
        inner.bind('<Configure>', lambda e: canvas.configure(
            scrollregion=canvas.bbox('all')))
        win = canvas.create_window((0, 0), window=inner, anchor='nw')
        canvas.configure(yscrollcommand=vsb.set)
        canvas.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        canvas.bind('<Configure>', self._on_detail_configure)
        for event, step in (('<MouseWheel>', None), ('<Button-4>', -1),
                            ('<Button-5>', 1)):
            canvas.bind(event, lambda e, c=canvas, s=step:
                        c.yview_scroll(-1 if s is None and
                                       getattr(e, 'delta', 0) > 0
                                       else (s if s is not None else 1),
                                       'units'))
        self.scrollers.append((canvas, win, inner))
        outer.pack(fill='both', expand=True)
        return inner

    def _on_detail_configure(self, event):
        for canvas, win, _inner in self.scrollers:
            canvas.itemconfigure(win, width=event.width)
        for widget in self.wrapping:
            widget.configure(wraplength=max(160, event.width - WRAP_MARGIN))

    def _wrap(self, widget):
        self.wrapping.append(widget)
        widget.configure(wraplength=DETAIL_W - WRAP_MARGIN, justify='left')
        return widget

    def _group(self, title, parent=None):
        box = ttk.LabelFrame(parent if parent is not None else self.detail,
                             text=title)
        box.pack(fill='x', padx=8, pady=4)
        return box

    def _build_identity(self):
        parent = self.detail
        self.head_var = tk.StringVar(value='(no province selected)')
        ttk.Label(parent, textvariable=self.head_var,
                  font=('TkDefaultFont', 11, 'bold')).pack(fill='x', padx=8,
                                                           pady=(8, 2))
        box = self._group('身分 Identity')
        row = ttk.Frame(box)
        row.pack(fill='x', padx=6, pady=2)
        ttk.Label(row, text='名前 katakana').pack(side='left')
        self.w['katakana'] = ttk.Entry(row, width=18)
        self.w['katakana'].pack(side='left', padx=(6, 0))
        self.w['katakana'].bind('<Return>',
                                lambda e: self._commit('katakana'))
        self.w['katakana'].bind('<FocusOut>',
                                lambda e: self._commit('katakana'))
        self.name_info_var = tk.StringVar()
        self._wrap(ttk.Label(box, textvariable=self.name_info_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=(0, 4))
        row = ttk.Frame(box)
        row.pack(fill='x', padx=6, pady=2)
        ttk.Label(row, text='所属国 Country').pack(side='left')
        values = ['%d %s' % (i, self.m.COUNTRY_LABELS[i])
                  for i in range(self.m.PROVINCE_COUNTRY_NONE + 1)]
        self.w['country_id'] = ttk.Combobox(
            row, values=values, state='readonly', width=combo_width(values))
        self.w['country_id'].pack(side='left', padx=(6, 0))
        self.w['country_id'].bind(
            '<<ComboboxSelected>>', lambda e: self._commit('country_id'))
        self.identity_var = tk.StringVar()
        self._wrap(ttk.Label(box, textvariable=self.identity_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=(0, 4))

    def _build_resources(self):
        box = self._group('資源 Resources (+02..+10)')
        fields = [spec for spec in self.m.PROVINCE_FIELDS
                  if spec.group == 'resources']
        for spec in fields:
            cell = ttk.Frame(box)
            cell.pack(fill='x', padx=6, pady=2)
            ttk.Label(cell, text='%s  %s' % (spec.jp, spec.en),
                      width=18, anchor='w').pack(side='left')
            step = (self.m.PROVINCE_POPULATION_STEP
                    if spec.key == 'population' else 1)
            widget = ttk.Spinbox(cell, from_=spec.lo, to=spec.hi,
                                 increment=step, width=14)
            widget.pack(side='left', padx=(6, 0))
            widget.bind('<Return>', lambda e, k=spec.key: self._commit(k))
            widget.bind('<FocusOut>', lambda e, k=spec.key: self._commit(k))
            widget.bind('<KeyRelease-Up>',
                        lambda e, k=spec.key: self._commit(k))
            widget.bind('<KeyRelease-Down>',
                        lambda e, k=spec.key: self._commit(k))
            self.w[spec.key] = widget

    def _build_roster(self):
        box = self._group('武将 Roster (+11..+1A, +$11 = 太守)')
        frame = ttk.Frame(box)
        frame.pack(fill='x', padx=6, pady=3)
        style = ttk.Style(self)
        style.configure('Roster.Treeview', rowheight=row_height())
        self.roster_tree = ttk.Treeview(
            frame, columns=('slot', 'id', 'name', 'status', 'troops'),
            show='headings', selectmode='browse', height=10,
            style='Roster.Treeview')
        for key, text, width, anchor in (
                ('slot', 'slot', 44, 'e'), ('id', 'id', 44, 'e'),
                ('name', '名前', 150, 'w'), ('status', '状態', 90, 'w'),
                ('troops', '兵数', 64, 'e')):
            self.roster_tree.heading(key, text=text)
            self.roster_tree.column(key, width=width, anchor=anchor,
                                    stretch=True)
        vsb = ttk.Scrollbar(frame, orient='vertical',
                            command=self.roster_tree.yview)
        self.roster_tree.configure(yscrollcommand=vsb.set)
        self.roster_tree.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        self.roster_tree.tag_configure('governor', foreground='#0a6b2a')
        self.roster_tree.tag_configure('empty', foreground='#888888')

        buttons = ttk.Frame(box)
        buttons.pack(fill='x', padx=6, pady=(0, 3))
        row1 = ttk.Frame(buttons)
        row1.pack(fill='x')
        row2 = ttk.Frame(buttons)
        row2.pack(fill='x', pady=(2, 0))
        for index, (text, command, tip) in enumerate((
                ('Add officer…', self.add_officer,
                 'put a hidden or other-province officer in the next slot'),
                ('Remove', self.remove_officer,
                 'take the selected officer out (状態 becomes 1 hidden)'),
                ('太守 slot 0', self.make_governor,
                 'move the selected officer to roster slot +$11'),
                ('Up', lambda: self.move_roster(-1), 'move one slot earlier'),
                ('Down', lambda: self.move_roster(1), 'move one slot later'))):
            button = ttk.Button(row1 if index < 3 else row2,
                                text=text, command=command)
            button.pack(side='left', padx=(0, 3))
            self._tip(button, tip)
        self.roster_info_var = tk.StringVar()
        self._wrap(ttk.Label(box, textvariable=self.roster_info_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=(0, 4))

    def _build_country(self):
        box = self._group('国 Country (live aggregate)')
        self.country_var = tk.StringVar()
        self._wrap(ttk.Label(box, textvariable=self.country_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=4)

    def _build_record(self):
        box = self._group('記録 Raw record')
        self.record_var = tk.StringVar()
        self._wrap(ttk.Label(box, textvariable=self.record_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=4)

    def _build_arrival(self):
        box = self._group('出現武将 Arrival officers (schedule $8B1C)')
        frame = ttk.Frame(box)
        frame.pack(fill='x', padx=6, pady=3)
        style = ttk.Style(self)
        style.configure('Arrival.Treeview', rowheight=row_height())
        self.arrival_tree = ttk.Treeview(
            frame, columns=('year', 'id', 'name', 'status'),
            show='headings', selectmode='browse', height=6,
            style='Arrival.Treeview')
        for key, text, width, anchor in (
                ('year', '年', 52, 'e'), ('id', 'id', 44, 'e'),
                ('name', '名前', 170, 'w'), ('status', '状態', 90, 'w')):
            self.arrival_tree.heading(key, text=text)
            self.arrival_tree.column(key, width=width, anchor=anchor,
                                     stretch=True)
        vsb = ttk.Scrollbar(frame, orient='vertical',
                            command=self.arrival_tree.yview)
        self.arrival_tree.configure(yscrollcommand=vsb.set)
        self.arrival_tree.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')

        buttons = ttk.Frame(box)
        buttons.pack(fill='x', padx=6, pady=(0, 3))
        row1 = ttk.Frame(buttons)
        row1.pack(fill='x')
        row2 = ttk.Frame(buttons)
        row2.pack(fill='x', pady=(2, 0))
        ttk.Label(row1, text='年 year').pack(side='left')
        self.arrival_year = ttk.Spinbox(row1, from_=189, to=255, width=6)
        self.arrival_year.set(190)
        self.arrival_year.pack(side='left', padx=(3, 8))
        for text, command, tip in (
                ('Add…', self.add_arrival,
                 'schedule a hidden officer to arrive here in the year above'),
                ('Set year', self.set_arrival_year,
                 're-point the selected officer\'s arrival at the year above'),
                ('Remove', self.remove_arrival,
                 'drop the selected arrival entry (he stays hidden, '
                 'unscheduled)')):
            button = ttk.Button(row1 if text != 'Remove' else row2,
                                text=text, command=command)
            button.pack(side='left', padx=(0, 3))
            self._tip(button, tip)
        self.arrival_info_var = tk.StringVar()
        self._wrap(ttk.Label(box, textvariable=self.arrival_info_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=(0, 4))

    def _show_arrival(self, prov):
        self.arrival_tree.delete(*self.arrival_tree.get_children())
        pairs = self.model.schedule_blocks().get(prov.id, [])
        for oid, year in pairs:
            off = self.model.by_id.get(oid)
            self.arrival_tree.insert(
                '', 'end', iid=str(oid),
                values=(year, oid, off.name if off else '?',
                        off.officer_status if off else '?'))
        self.arrival_info_var.set(
            '%d/%d schedule pairs in this province block (the renderer sorts '
            'by year, then id; only 状態 1 officers can appear)'
            % (len(pairs), self.m.ARRIVAL_PAIRS))

    def add_arrival(self):
        if self.current is None:
            return
        try:
            year = int(str(self.arrival_year.get()), 0)
        except ValueError:
            messagebox.showerror('Invalid year',
                                 'The arrival year must be a number.')
            return
        picker = OfficerPicker(self, self.model, self.current, mode='arrival')
        self.wait_window(picker)
        if picker.result is None:
            return
        oid = picker.result
        before = self.model.snapshot()
        try:
            self.model.set_schedule(oid, self.current.id, year)
        except self.m.FieldError as exc:
            messagebox.showerror('Edit refused', str(exc))
            return
        self._push_undo(before)
        self.log_line('arrival: officer %d (%s) now arrives %d in province %d'
                      ' (%s)' % (oid, self.model.officer(oid).name, year,
                                 self.current.id, self.current.name))
        self._refresh_after_roster()

    def set_arrival_year(self):
        if self.current is None:
            return
        selection = self.arrival_tree.selection()
        if not selection:
            return
        try:
            year = int(str(self.arrival_year.get()), 0)
        except ValueError:
            messagebox.showerror('Invalid year',
                                 'The arrival year must be a number.')
            return
        oid = int(selection[0])
        before = self.model.snapshot()
        try:
            self.model.set_schedule(oid, self.current.id, year)
        except self.m.FieldError as exc:
            messagebox.showerror('Edit refused', str(exc))
            return
        self._push_undo(before)
        self.log_line('arrival: officer %d (%s) now arrives %d in province %d'
                      % (oid, self.model.officer(oid).name, year,
                         self.current.id))
        self._refresh_after_roster()

    def remove_arrival(self):
        if self.current is None:
            return
        selection = self.arrival_tree.selection()
        if not selection:
            return
        oid = int(selection[0])
        before = self.model.snapshot()
        self.model.clear_schedule(oid)
        self._push_undo(before)
        self.log_line('arrival: officer %d (%s) dropped from province %d; he '
                      'stays hidden and unscheduled'
                      % (oid, self.model.officer(oid).name, self.current.id))
        self._refresh_after_roster()

    # -- town facilities (read-only ROM tables) --------------------------
    def _build_town(self):
        box = self._group('町 Town facilities (read-only)', self.town_detail)
        self.town_head_var = tk.StringVar()
        self._wrap(ttk.Label(box, textvariable=self.town_head_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=(4, 2))
        self.town_flags_var = tk.StringVar()
        self._wrap(ttk.Label(box, textvariable=self.town_flags_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=(0, 4))
        market = self._group('商店 Market (rice trade, bank $30 $8FC0)',
                             self.town_detail)
        self.market_var = tk.StringVar()
        self._wrap(ttk.Label(market, textvariable=self.market_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=4)
        armory = self._group('武器屋 Armory (bank $1C $C801 + bank $09 grid)',
                             self.town_detail)
        self.armory_var = tk.StringVar()
        self._wrap(ttk.Label(armory, textvariable=self.armory_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=6, pady=(4, 2))
        frame = ttk.Frame(armory)
        frame.pack(fill='x', padx=6, pady=(0, 3))
        style = ttk.Style(self)
        style.configure('Stock.Treeview', rowheight=row_height())
        self.stock_tree = ttk.Treeview(
            frame, columns=('page', 'cell', 'item', 'class', 'price'),
            show='headings', selectmode='browse', height=9,
            style='Stock.Treeview')
        for key, text, width, anchor in (
                ('page', 'page', 48, 'e'), ('cell', 'cell', 48, 'e'),
                ('item', 'item', 120, 'w'), ('class', 'class', 130, 'w'),
                ('price', '金', 60, 'e')):
            self.stock_tree.heading(key, text=text)
            self.stock_tree.column(key, width=width, anchor=anchor,
                                   stretch=True)
        vsb = ttk.Scrollbar(frame, orient='vertical',
                            command=self.stock_tree.yview)
        self.stock_tree.configure(yscrollcommand=vsb.set)
        self.stock_tree.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        self.stock_tree.tag_configure('unpriced', foreground='#888888')
        self.town_note_var = tk.StringVar(value=TOWN_NOTE)
        self._wrap(ttk.Label(self.town_detail,
                             textvariable=self.town_note_var,
                             font=('TkFixedFont', 8),
                             foreground='#555555')).pack(
                                 fill='x', padx=8, pady=(0, 8))

    def _show_town(self, prov):
        if self.data is None:
            self.town_head_var.set(
                'Town facilities need the repo ROM banks '
                '(rom/prg/prg_1c.bin, prg_09.bin, prg_10.bin); standalone '
                'mode shows nothing here.')
            for var in (self.town_flags_var, self.market_var,
                        self.armory_var):
                var.set('')
            self.stock_tree.delete(*self.stock_tree.get_children())
            return
        data = self.data
        pid = prov.id
        ttype = data['town_types'][pid]
        have = [r for r in data['routes'][ttype * 4:ttype * 4 + 4]
                if r != 0xFF]
        self.town_head_var.set(
            '町タイプ town type %d -> %s'
            % (ttype, ', '.join(FACILITY_SCREENS[r] for r in have) or 'none'))
        flags = data['flags'][pid]
        self.town_flags_var.set(
            '施設フラグ ProvinceFacilityFlags ($8FFC): %s'
            % '  '.join('%s%s (%s)' % (glyph, '✓' if flags >> bit & 1 else '-',
                                       what)
                        for bit, glyph, what in FACILITY_FLAG_BITS))
        sell, buy = data['rates'][pid * 2], data['rates'][pid * 2 + 1]
        if sell or buy:
            self.market_var.set(
                'rice per 100 金: sell %d (gold/rice %.2f), buy %d '
                '(gold/rice %.2f)'
                % (sell, 100.0 / sell if sell else 0.0,
                   buy, 100.0 / buy if buy else 0.0))
        else:
            self.market_var.set('no 商店 in this province ($00 $00)')
        form = data['formations'][pid]
        cells = data['layouts'][form * 16:form * 16 + 16]
        self.armory_var.set('armory formation id %d, 16 grid cells '
                            '(cell = equipment id, price = ItemPriceTable '
                            'bank $09 $C89E)' % form)
        self.stock_tree.delete(*self.stock_tree.get_children())
        for index, cell in enumerate(cells):
            price = data['prices'][cell]
            self.stock_tree.insert(
                '', 'end', iid=str(index),
                tags=() if price else ('unpriced',),
                values=(index // 4, index % 4, '%d %s'
                        % (cell, self._item_name(cell)),
                        item_category(cell),
                        price if price else '—'))

    def _item_name(self, cell):
        if cell < 24:
            return self.m.WEAPONS.get(cell, '?')
        return self.m.ARMOR.get(cell - 24, '?')

    # -- strategy map ------------------------------------------------------
    def _build_strategy_map(self, parent):
        self._map_photo = None
        self._map_photo_key = None
        self._map_rows = None
        self._map_hover = None
        ttk.Label(parent, text=(
            'The game strategy map; click a province to select it.'),
            wraplength=256 * MAP_SCALE - 16, justify='left').pack(
                fill='x', padx=8, pady=(8, 2))
        self.map_canvas = tk.Canvas(
            parent, width=256 * MAP_SCALE, height=MAP_ROWS * 8 * MAP_SCALE,
            bg='#000000', highlightthickness=0, cursor='tcross')
        self.map_canvas.pack(padx=8, pady=4, anchor='n')
        self.map_canvas.bind('<Button-1>', self._on_map_click)
        self.map_canvas.bind('<Motion>', self._on_map_motion)
        self.map_canvas.bind('<Leave>', self._on_map_leave)
        self.map_hover_var = tk.StringVar()
        ttk.Label(parent, textvariable=self.map_hover_var,
                  wraplength=256 * MAP_SCALE - 16, justify='left').pack(
                      fill='x', padx=8)
        self.map_info_var = tk.StringVar()
        ttk.Label(parent, textvariable=self.map_info_var,
                  wraplength=256 * MAP_SCALE - 16, justify='left',
                  font=('TkFixedFont', 9)).pack(
                      fill='x', padx=8, pady=(0, 8))

    def _map_photo_for(self):
        """The rendered screen; re-render only when marker ownership changed."""
        countries = tuple(prov.country_id for prov in self.model.provinces)
        if self._map_photo_key != countries:
            self._map_rows = strategy_map_pixels(self.data, countries)
            self._map_photo = tk.PhotoImage(
                data=base64.b64encode(
                    png_bytes(self._map_rows)).decode('ascii'))
            self._map_photo_key = countries
        return self._map_photo

    def _map_hit(self, x, y):
        if y >= MAP_ROWS * 8:
            return None
        return strategy_map_hit(x, y, self.data['zone_x'],
                                self.data['zone_y'])

    def _map_zone_centre(self, pid):
        return (self.data['zone_x'][pid] + 8, self.data['zone_y'][pid] + 8)

    def _draw_zone(self, tag, pid, colour):
        if pid is None:
            return
        x0 = self.data['zone_x'][pid] * MAP_SCALE
        y0 = self.data['zone_y'][pid] * MAP_SCALE
        x1 = x0 + 8 * MAP_SCALE - 1        # box the visible 8x8 marker icon
        y1 = y0 + 8 * MAP_SCALE - 1
        self.map_canvas.create_rectangle(x0, y0, x1, y1, outline='#000000',
                                         width=3, tags=('zone', tag))
        self.map_canvas.create_rectangle(x0, y0, x1, y1, outline=colour,
                                         width=1, tags=('zone', tag))

    def _hover_text(self):
        if self._map_hover is None:
            return ('no province in this 16 x 16 zone (MapProvinceHitTest '
                    'returns $FF)')
        return ('under cursor: %d %s - click to select'
                % (self._map_hover,
                   self.model.province(self._map_hover).title()))

    def _draw_strategy_map(self):
        canvas = self.map_canvas
        canvas.delete('all')
        if self.data is None:
            canvas.create_text(
                128 * MAP_SCALE, 100, text='Strategy map needs '
                'rom/prg/prg_01.bin, prg_10.bin, prg_1c.bin, prg_1e.bin and '
                'rom/chr; standalone mode shows nothing here.',
                width=256 * MAP_SCALE - 80, justify='left')
            return
        canvas.create_image(0, 0, anchor='nw', image=self._map_photo_for())
        self._draw_zone('selected', self.current.id if self.current else None,
                        '#ffffff')
        self._draw_zone('hover', self._map_hover, '#ffe14d')
        self.map_hover_var.set(self._hover_text())
        if self.current is not None:
            pid = self.current.id
            nbrs = [n for n in self.data['adjacency'][pid]
                    if n != 0xFF and n < 30]
            slots = []
            for slot, nbr in enumerate(nbrs):
                name = self.model.province(nbr).title()
                slots.append('%d %s (atk %d/def %d)'
                             % (nbr, name,
                                self.data['attack_types'][pid][slot],
                                self.data['defense_types'][pid][slot]))
            self.map_info_var.set(
                'province %d %s: %d neighbours\n%s\n'
                'zone (X,Y) %d,%d · $1C $DEE9/$DF07 · 16×16 · $DEBA'
                % (pid, self.current.title(), len(nbrs),
                   ' · '.join(slots) or '(none)',
                   self.data['zone_x'][pid], self.data['zone_y'][pid]))

    def _on_map_motion(self, event):
        if self.data is None:
            return
        pid = self._map_hit(event.x // MAP_SCALE, event.y // MAP_SCALE)
        if pid != self._map_hover:
            self._map_hover = pid
            self._draw_strategy_map()

    def _on_map_leave(self, event=None):
        if self._map_hover is not None:
            self._map_hover = None
            self._draw_strategy_map()

    def _on_map_click(self, event):
        if self.data is None:
            return
        x, y = event.x // MAP_SCALE, event.y // MAP_SCALE
        pid = self._map_hit(x, y)
        if pid is None:
            self.map_hover_var.set(
                'no province at map (%d,%d): MapProvinceHitTest returns $FF'
                % (x, y))
            return
        self.tree.selection_set(str(pid))
        self.tree.see(str(pid))
        self._on_select()

    # -- tactical map ------------------------------------------------------
    def _build_tactical_map(self, parent):
        controls = ttk.Frame(parent)
        controls.pack(fill='x', padx=8, pady=(8, 2))
        ttk.Label(controls, text='attack route').pack(side='left')
        self.atk_type_box = ttk.Combobox(controls, state='readonly',
                                         width=5, values=('all',))
        self.atk_type_box.set('all')
        self.atk_type_box.pack(side='left', padx=(3, 10))
        self.atk_type_box.bind('<<ComboboxSelected>>',
                               lambda e: self._draw_tactical_map())
        ttk.Label(controls, text='defense variant').pack(side='left')
        self.def_type_box = ttk.Combobox(controls, state='readonly',
                                         width=5, values=('all',))
        self.def_type_box.set('all')
        self.def_type_box.pack(side='left', padx=(3, 0))
        self.def_type_box.bind('<<ComboboxSelected>>',
                               lambda e: self._draw_tactical_map())
        self.tac_canvas = tk.Canvas(
            parent, width=32 * TACTICAL_CELL, height=20 * TACTICAL_CELL,
            bg='#101010', highlightthickness=0)
        self.tac_canvas.pack(fill='both', expand=True, padx=8, pady=4)
        self.tac_legend_var = tk.StringVar()
        self._wrap(ttk.Label(parent, textvariable=self.tac_legend_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=8, pady=(0, 8))

    def _terrain_bytes(self, bank):
        if bank not in self._terrain_banks:
            path = os.path.join(self.repo, 'rom', 'prg',
                                'prg_%02x.bin' % bank)
            with open(path, 'rb') as f:
                self._terrain_banks[bank] = f.read()
        return self._terrain_banks[bank]

    def _show_tactical(self, prov):
        if self.data is None or self.data['terrain'] is None:
            self.atk_type_box.configure(values=('all',), state='disabled')
            self.def_type_box.configure(values=('all',), state='disabled')
            self._draw_tactical_map()
            return
        data = self.data
        atk_values = ('all',) + tuple(str(i)
                                      for i in range(
                                          len(data['attack_pools'][prov.id])))
        def_values = ('all',) + tuple(str(i)
                                      for i in range(
                                          len(data['defense_pools'][prov.id])))
        self.atk_type_box.configure(values=atk_values, state='readonly')
        self.def_type_box.configure(values=def_values, state='readonly')
        if self.atk_type_box.get() not in atk_values:
            self.atk_type_box.set('all')
        if self.def_type_box.get() not in def_values:
            self.def_type_box.set('all')
        self._draw_tactical_map()

    def _type_routes(self, slots, types):
        """side type -> the neighbour provinces whose adjacency slot selects
        it (the approach route that initial area belongs to)."""
        routes = {}
        for nbr, t in zip(slots, types):
            if nbr == 0xFF or nbr >= 30 or t & 0x80:
                continue
            routes.setdefault(t, []).append(
                '%d %s' % (nbr, self.model.province(nbr).zh_hans))
        return routes

    def _draw_tactical_map(self):
        canvas = self.tac_canvas
        cell = TACTICAL_CELL
        canvas.delete('all')
        if self.data is None or self.data['terrain'] is None \
                or self.data['castle_cells'] is None \
                or self.data['facility_tiles'] is None \
                or self.current is None:
            canvas.create_text(
                16 * cell, 10 * cell,
                text='Tactical map needs the repo ROM banks and the terrain '
                     'codec (tools/terrain_model.py); standalone mode shows '
                     'nothing here.', fill='#dddddd',
                width=32 * cell - 40, justify='left')
            self.tac_legend_var.set('')
            return
        tm = self.data['terrain']
        if not self._terrain_banks:
            for bank in tm.TERRAIN_BANKS:
                self._terrain_banks[bank] = self._terrain_bytes(bank)
        banks = self._terrain_banks
        tiles = tm.province_map(lambda bank, off: banks[bank][off],
                                self.current.id)
        for y, row in enumerate(tiles):
            for x, tile in enumerate(row):
                tid = tm.terrain_clamped(tm.tile_terrain(tile))
                colour = '#%02x%02x%02x' % tm.TERRAIN_RGB.get(
                    tid, (0x88, 0x88, 0x88))
                canvas.create_rectangle(x * cell, y * cell,
                                        (x + 1) * cell, (y + 1) * cell,
                                        fill=colour, outline='#2a2a2a')
        # The buildings are the two marker sprites that DrawStratagemTargetMarkers
        # places from bank $11: the castle from $9D58 and each town from $9BA4.
        # The $61/$79/$7A/$7B stamps in the terrain are notes for the same cells,
        # not what draws them, so they do not decide what appears here.
        marks = [('城', self.data['castle_cells'][self.current.id])]
        marks += list(zip(('民', '武', '病'),
                          self.data['facility_tiles'][self.current.id]))
        for letter, pair in marks:
            if pair is None:
                continue
            x, y = pair
            canvas.create_rectangle(x * cell + 1, y * cell + 1,
                                    (x + 1) * cell - 1, (y + 1) * cell - 1,
                                    outline='#ffffff', width=2)
            canvas.create_text((x + 0.5) * cell, (y + 0.5) * cell,
                               text=letter, fill='#ffffff',
                               font=('TkDefaultFont', 8, 'bold'))
        prov = self.current
        atk_sel = self.atk_type_box.get() or 'all'
        def_sel = self.def_type_box.get() or 'all'
        atk_pools = self.data['attack_pools'][prov.id]
        def_pools = self.data['defense_pools'][prov.id]
        atk_routes = self._type_routes(self.data['adjacency'][prov.id],
                                       self.data['attack_types'][prov.id])
        def_routes = self._type_routes(self.data['adjacency'][prov.id],
                                       self.data['defense_types'][prov.id])
        for t, pairs in enumerate(atk_pools):
            if atk_sel not in ('all', str(t)):
                continue
            self._draw_pool(canvas, cell, pairs,
                            self.data['attack_bounds'][prov.id][t],
                            ATTACK_PALETTE[t % len(ATTACK_PALETTE)])
        for t, pairs in enumerate(def_pools):
            if def_sel not in ('all', str(t)):
                continue
            self._draw_pool(canvas, cell, pairs,
                            self.data['defense_bounds'][prov.id][t],
                            DEFENSE_PALETTE[t % len(DEFENSE_PALETTE)])
        lines = ['province %d %s: %d attack route(s), %d defense variant(s)'
                 % (prov.id, prov.title(), len(atk_pools), len(def_pools))]
        for t in range(len(atk_pools)):
            lines.append('atk %d ← %s' % (t, ', '.join(atk_routes.get(t, []))
                                          or '(no slot selects it)'))
        for t in range(len(def_pools)):
            lines.append('def %d ← %s' % (t, ', '.join(def_routes.get(t, []))
                                          or '(no slot selects it)'))
        lines.append('one colour per side type: ◆ = its anchor (pair 0), '
                     'outline = its unit cells, dashed = its city bounds; '
                     'the dropdowns isolate one type. 民 house / 武 armory / '
                     '病 hospital; pool rows ≥ $10 render one row higher '
                     '(GetOrderedDestination quirk).')
        self.tac_legend_var.set('\n'.join(lines))

    def _draw_pool(self, canvas, cell, pairs, rect, colour):
        for index, (y, x) in enumerate(pairs):
            row = y - 1 if y >= 0x10 else y
            if not (0 <= row < 20 and 0 <= x < 32):
                continue
            if index == 0:
                cx, cy = (x + 0.5) * cell, (row + 0.5) * cell
                canvas.create_polygon(cx, cy - 6, cx + 6, cy, cx, cy + 6,
                                      cx - 6, cy, fill=colour,
                                      outline='#ffffff')
            else:
                canvas.create_rectangle(x * cell + 2, row * cell + 2,
                                        (x + 1) * cell - 2,
                                        (row + 1) * cell - 2,
                                        outline=colour, width=2)
        if rect and len(rect) == 4:
            r0, c0, r1, c1 = rect
            r0 = r0 - 1 if r0 >= 0x10 else r0
            r1 = r1 - 1 if r1 >= 0x10 else r1
            canvas.create_rectangle(c0 * cell, r0 * cell,
                                    c1 * cell, r1 * cell,
                                    outline=colour, width=2, dash=(4, 3))

    def _build_report(self):
        frame = ttk.LabelFrame(self, text='Invariants (problems) and '
                                          'live province totals')
        self.report = tk.Text(frame, height=6, wrap='word', state='disabled',
                              font=('TkFixedFont', 9))
        for tag, colour in (('problem', '#b00020'), ('note', '#6a4b00'),
                            ('ok', '#0a6b2a')):
            self.report.tag_configure(tag, foreground=colour)
        vsb = ttk.Scrollbar(frame, orient='vertical',
                            command=self.report.yview)
        self.report.configure(yscrollcommand=vsb.set)
        self.report.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        return frame

    def _build_log(self):
        frame = ttk.LabelFrame(self, text='Output')
        self.log = tk.Text(frame, height=6, wrap='none', state='disabled',
                           font=('TkFixedFont', 9))
        vsb = ttk.Scrollbar(frame, orient='vertical', command=self.log.yview)
        self.log.configure(yscrollcommand=vsb.set)
        self.log.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        return frame

    def _tip(self, widget, text):
        widget.bind('<Enter>', lambda e: self.status.set(text))
        widget.bind('<Leave>', lambda e: self.status.set(self._status_text()))

    # -- loading ---------------------------------------------------------
    def _twins(self, province_csv, officer_csv=None):
        paths = self.m.default_paths(self.repo) if self.repo else {}
        province_csv = province_csv or paths.get('province')
        officer_csv = (officer_csv
                       or (self.m.sibling_path(province_csv,
                                               'officer_data.csv')
                           if province_csv else None)
                       or paths.get('officer'))
        return province_csv, officer_csv

    def load_paths(self, officer_csv=None, province_csv=None):
        province_csv, officer_csv = self._twins(province_csv, officer_csv)
        if not province_csv or not os.path.exists(province_csv):
            province_csv = filedialog.askopenfilename(
                title='Open docs/province_data.csv',
                filetypes=[('CSV', '*.csv'), ('all files', '*')])
            if not province_csv:
                raise SystemExit('no province CSV to edit')
            province_csv, officer_csv = self._twins(province_csv, officer_csv)
        if not officer_csv or not os.path.exists(officer_csv):
            officer_csv = filedialog.askopenfilename(
                title='Open the officer_data.csv holding the rostered officers',
                filetypes=[('CSV', '*.csv'), ('all files', '*')])
            if not officer_csv:
                raise SystemExit('no officer CSV to load the rosters from')
        self._load(province_csv, officer_csv)

    def _load(self, province_csv, officer_csv):
        self.model = self.m.Model.load(officer_csv,
                                       province_csv=province_csv)
        missing = [column for column in (
            'id', 'katakana', 'country_id', 'gold', 'rice', 'population',
            'land_value', 'industry', 'disaster_prevention', 'governance',
            'reserve_troops', 'treasure', 'officer_ids', 'hex')
            if column not in self.model.fieldnames.get('province', [])]
        if missing:
            raise SystemExit(
                '%s: missing column(s) %s - the province editor needs the '
                'full docs/province_data.csv written by '
                'tools/extract_province_data.py'
                % (province_csv, ', '.join(missing)))
        self.current = None
        self.source = dict(self.model.paths)
        self.log_line('loaded %s and %s (%d provinces, %d officers)'
                      % (self.model.paths['officer'],
                         self.model.paths['province'],
                         len(self.model.provinces), len(self.model.officers)))
        if not self.repo:
            self.log_line('standalone mode: no repo tools beside the model, so '
                          'Write ASM / Verify are unavailable')

    def reload(self):
        if not self._confirm_discard():
            return
        self._load(self.source['province'], self.source['officer'])
        self.undo, self.redo = [], []
        self.log_line('reverted to the CSVs on disk')
        self._refresh_all()

    def open_csv(self):
        if not self._confirm_discard():
            return
        province_csv = filedialog.askopenfilename(
            title='Open docs/province_data.csv',
            filetypes=[('CSV', '*.csv'), ('all files', '*')])
        if not province_csv:
            return
        province_csv, officer_csv = self._twins(province_csv)
        if not officer_csv or not os.path.exists(officer_csv):
            officer_csv = filedialog.askopenfilename(
                title='Open the matching officer_data.csv',
                filetypes=[('CSV', '*.csv'), ('all files', '*')])
            if not officer_csv:
                return
        self._load(province_csv, officer_csv)
        self.undo, self.redo = [], []
        self._refresh_all()

    # -- table / detail --------------------------------------------------
    def _refresh_all(self):
        self._refresh_table()
        self._refresh_report()
        self._show_province(self.current)
        self._refresh_title()

    def _refresh_title(self):
        source = self.model.paths.get('province', '')
        self.title('Sangokushi 2 province editor - %s'
                   % (os.path.basename(source) if source else 'no CSV'))

    def _refresh_table(self):
        keep = self.current.id if self.current else None
        provinces = self.m.visible_provinces(self.model,
                                             self.filter_var.get())
        changed = {ch.pid for ch in self.model.province_changes()}
        changed.update(ch.oid for ch in self.model.changes()
                       if ch.field == 'officer_ids')
        problems = self.model.province_problem_ids()
        self.tree.delete(*self.tree.get_children())
        for prov in provinces:
            tags = []
            if prov.id in problems:
                tags.append('problem')
            elif prov.id in changed:
                tags.append('edited')
            if prov.country_id == self.m.PROVINCE_COUNTRY_NONE:
                tags.append('unclaimed')
            self.tree.insert('', 'end', iid=str(prov.id), tags=tags,
                             values=self.m.province_row_values(self.model,
                                                               prov))
        ids = self.tree.get_children()
        if keep is not None and str(keep) in ids:
            self.tree.selection_set(str(keep))
            self.tree.see(str(keep))
            self.current = self.model.province(keep)
        elif ids:
            self.tree.selection_set(ids[0])
            self.tree.see(ids[0])
            self.current = self.model.province(int(ids[0]))
        else:
            self.current = None
            self._show_province(None)
        self.status.set(self._status_text(len(ids)))

    def _on_select(self, event=None):
        selection = self.tree.selection()
        if not selection:
            return
        self.current = self.model.province(int(selection[0]))
        self._show_province(self.current)
        self.status.set(self._status_text())

    def _show_province(self, prov):
        self._loading = True
        try:
            if prov is None:
                self.head_var.set('(no province selected)')
                for var in (self.name_info_var, self.identity_var,
                            self.roster_info_var, self.country_var,
                            self.record_var, self.arrival_info_var,
                            self.town_head_var, self.town_flags_var,
                            self.market_var, self.armory_var,
                            self.map_info_var, self.tac_legend_var):
                    var.set('')
                for widget in self.w.values():
                    widget.configure(state='disabled')
                self.roster_tree.state(['disabled'])
                self.roster_tree.delete(*self.roster_tree.get_children())
                self.arrival_tree.delete(*self.arrival_tree.get_children())
                self.stock_tree.delete(*self.stock_tree.get_children())
                self.map_canvas.delete('all')
                self.tac_canvas.delete('all')
                return
            for widget in self.w.values():
                widget.configure(state='readonly'
                                 if isinstance(widget, ttk.Combobox)
                                 else 'normal')
            self.roster_tree.state(['!disabled'])
            self.head_var.set('%d  %s  %s' % (prov.id, prov.katakana,
                                              prov.zh_hans))
            self.w['katakana'].delete(0, 'end')
            self.w['katakana'].insert(0, prov.katakana)
            self.w['country_id'].set(
                '%d %s' % (prov.country_id,
                           self.m.COUNTRY_LABELS.get(prov.country_id, '?')))
            name_error = self._name_error(prov)
            name_bytes = ('(cannot encode)'
                          if name_error else
                          self.m.encode_province_name(prov.katakana)
                          .hex().upper())
            self.name_info_var.set(
                '日本語 %s   简体 %s   pinyin %s\n'
                'name $%04X + id*%d   %s'
                % (prov.kanji_ja or '-', prov.zh_hans or '-',
                   prov.pinyin or '-', self.m.PROV_NAME_CPU,
                   self.m.PROV_NAME_STRIDE, name_bytes))
            ruler = self.m.province_ruler(self.model, prov)
            self.identity_var.set(
                '君主 ruler %s\n太守 governor %s\n'
                'record $%04X   SRAM $%04X'
                % ('%d %s' % (ruler.id, ruler.name) if ruler else '-',
                   ('%d %s' % (prov.governor,
                               self.m.province_governor_name(self.model, prov))
                    if prov.governor is not None else '-'),
                   self.m.PROV_RECORD_CPU + prov.id * self.m.PROV_RECORD_STRIDE,
                   self.m.PROVINCE_RECORD_BASE
                   + prov.id * self.m.PROV_RECORD_STRIDE))
            for spec in self.m.PROVINCE_FIELDS:
                if spec.key in ('katakana', 'country_id'):
                    continue
                widget = self.w[spec.key]
                widget.delete(0, 'end')
                widget.insert(0, str(prov.get(spec.key)))
            self._show_roster(prov)
            self._show_arrival(prov)
            self._show_country(prov)
            self._show_town(prov)
            self._draw_strategy_map()
            self._show_tactical(prov)
            rec = prov.record_bytes()
            self.record_var.set(
                '$%04X  %s\n       %s\n+00 国  +02 金  +04 米  +06 人口  '
                '+08 土地  +0A 防災  +0B 統治\n+0C 控え  +0E 産業  +10 宝  '
                '+11..+1A 武将  +1B 反乱CD'
                % (self.m.PROV_RECORD_CPU + prov.id * self.m.PROV_RECORD_STRIDE,
                   ' '.join('%02X' % b for b in rec[:16]),
                   ' '.join('%02X' % b for b in rec[16:])))
        finally:
            self._loading = False

    def _name_error(self, prov):
        try:
            self.m.encode_province_name(prov.katakana)
        except self.m.NameEncodeError as exc:
            return str(exc)
        return ''

    def _show_roster(self, prov):
        self.roster_tree.delete(*self.roster_tree.get_children())
        for slot in range(self.m.ROSTER_SLOTS):
            if slot < len(prov.roster):
                oid = prov.roster[slot]
                off = self.model.by_id.get(oid)
                tags = ('governor',) if slot == 0 else ()
                self.roster_tree.insert(
                    '', 'end', iid=str(slot), tags=tags,
                    values=(slot, oid, off.name if off else '?',
                            off.officer_status if off else '?',
                            off.troop_count if off else '?'))
            else:
                self.roster_tree.insert('', 'end', iid=str(slot),
                                        tags=('empty',),
                                        values=(slot, '-', 'empty', '-', '-'))
        self.roster_info_var.set(
            '武将 %d/%d  現役 %d  太守 %s'
            % (len(prov.roster), self.m.ROSTER_SLOTS,
               self.m.province_active_troops(self.model, prov),
               self.m.province_governor_name(self.model, prov)))

    def _show_country(self, prov):
        cid = prov.country_id
        if cid == self.m.PROVINCE_COUNTRY_NONE:
            self.country_var.set(
                '空白地 UnclaimedLand (Country 7) - no Country owns this '
                'province; its roster can still hold officers.')
            return
        owned = [p for p in self.model.provinces if p.country_id == cid]
        totals = self.m.province_totals(self.model, owned)
        ruler = None
        for owned_prov in owned:
            ruler = self.m.province_ruler(self.model, owned_prov)
            if ruler is not None:
                break
        self.country_var.set(
            'Country %d owns %d province%s: %s\n'
            '君主 ruler %s\n'
            '金 %d   米 %d   人口 %d   現役 %d   控え %d'
            % (cid, totals['provinces'], '' if totals['provinces'] == 1 else 's',
               ', '.join('%d %s' % (p.id, p.name) for p in owned) or '-',
               '%d %s' % (ruler.id, ruler.name) if ruler else '-',
               totals['gold'], totals['rice'], totals['population'],
               totals['active_troops'], totals['reserve_troops']))

    # -- edits -----------------------------------------------------------
    def _commit(self, key):
        if self._loading or self.current is None:
            return
        prov = self.current
        widget = self.w[key]
        old = prov.get(key)
        value = widget.get()
        if isinstance(widget, ttk.Combobox):
            try:
                value = int(str(value).split()[0])
            except (ValueError, IndexError):
                messagebox.showerror('Invalid choice', 'Pick a Country id.')
                self._show_province(prov)
                return
        before = self.model.snapshot()
        try:
            self.model.set_province(prov.id, key, value)
        except (self.m.FieldError, self.m.NameEncodeError) as exc:
            messagebox.showerror('Edit refused', str(exc))
            self._show_province(prov)
            return
        if prov.get(key) == old:
            self._show_province(prov)
            return
        self._push_undo(before)
        self.log_line('province %d (%s) %s: %s -> %s'
                      % (prov.id, prov.name, key, old, prov.get(key)))
        self._refresh_table()
        self._refresh_report()
        self._show_province(prov)

    def _selected_roster_slot(self):
        selection = self.roster_tree.selection()
        if not selection or self.current is None:
            return None
        slot = int(selection[0])
        return slot if slot < len(self.current.roster) else None

    def add_officer(self):
        if self.current is None:
            return
        if len(self.current.roster) >= self.m.ROSTER_SLOTS:
            messagebox.showinfo('Roster full',
                                'Province %d already fills all %d slots.'
                                % (self.current.id, self.m.ROSTER_SLOTS))
            return
        picker = OfficerPicker(self, self.model, self.current)
        self.wait_window(picker)
        if picker.result is None:
            return
        oid = picker.result
        old_province = self.model.officer(oid).roster_province
        before = self.model.snapshot()
        try:
            self.model.assign(oid, self.current.id)
        except self.m.FieldError as exc:
            messagebox.showerror('Edit refused', str(exc))
            return
        self._push_undo(before)
        self.log_line('roster: officer %d (%s) -> province %d (%s)%s'
                      % (oid, self.model.officer(oid).name, self.current.id,
                         self.current.name,
                         '' if old_province is None else
                         ' (moved from province %d)' % old_province))
        self._refresh_after_roster()

    def remove_officer(self):
        slot = self._selected_roster_slot()
        if slot is None:
            return
        prov = self.current
        oid = prov.roster[slot]
        before = self.model.snapshot()
        self.model.unassign(oid)
        self._push_undo(before)
        self.log_line('roster: officer %d (%s) removed from province %d (%s); '
                      '状態 is now 1 (hidden)'
                      % (oid, self.model.officer(oid).name, prov.id, prov.name))
        self._refresh_after_roster()

    def make_governor(self):
        slot = self._selected_roster_slot()
        if slot is None:
            return
        prov = self.current
        oid = prov.roster[slot]
        before = self.model.snapshot()
        self.model.move_slot(oid, 0)
        self._push_undo(before)
        self.log_line('roster: officer %d (%s) is now the 太守 of province %d'
                      % (oid, self.model.officer(oid).name, prov.id))
        self._refresh_after_roster(select_slot=0)

    def move_roster(self, delta):
        slot = self._selected_roster_slot()
        if slot is None:
            return
        prov = self.current
        target = slot + delta
        if not 0 <= target < len(prov.roster):
            return
        oid = prov.roster[slot]
        before = self.model.snapshot()
        self.model.move_slot(oid, target)
        self._push_undo(before)
        self.log_line('roster: officer %d (%s) moved to slot %d of province %d'
                      % (oid, self.model.officer(oid).name, target, prov.id))
        self._refresh_after_roster(select_slot=target)

    def _refresh_after_roster(self, select_slot=None):
        self._refresh_table()
        self._refresh_report()
        self._show_province(self.current)
        if select_slot is not None and self.roster_tree.exists(str(select_slot)):
            self.roster_tree.selection_set(str(select_slot))

    # -- undo / redo -----------------------------------------------------
    def _push_undo(self, before=None):
        self.undo.append(before if before is not None
                         else self.model.snapshot())
        self.undo = self.undo[-MAX_UNDO:]
        self.redo.clear()

    def undo_edit(self):
        if not self.undo:
            self.log_line('nothing to undo')
            return
        self.redo.append(self.model.snapshot())
        self.model.restore(self.undo.pop())
        self.log_line('undo')
        self._refresh_all()

    def redo_edit(self):
        if not self.redo:
            self.log_line('nothing to redo')
            return
        self.undo.append(self.model.snapshot())
        self.model.restore(self.redo.pop())
        self.log_line('redo')
        self._refresh_all()

    # -- report / diff ---------------------------------------------------
    def _change_count(self):
        return len(self.model.changes()) + len(self.model.province_changes())

    def _refresh_report(self):
        problems = self.model.problems()
        lines = []
        for problem in problems:
            lines.append(('problem', problem))
        if not problems:
            lines.append(('ok', 'no problems: every province field is in range, '
                                'every roster matches the officer 状態 set, and '
                                'every name encodes.'))
        totals = self.m.province_totals(self.model, self.model.provinces)
        claimed = [p for p in self.model.provinces
                   if p.country_id != self.m.PROVINCE_COUNTRY_NONE]
        lines.append(('note',
                      '30 provinces: %d claimed, %d 空白地 | rosters %d/%d | '
                      '金 %d 米 %d 人口 %d 現役 %d 控え %d'
                      % (len(claimed), len(self.model.provinces) - len(claimed),
                         totals['roster'],
                         len(self.model.provinces) * self.m.ROSTER_SLOTS,
                         totals['gold'], totals['rice'], totals['population'],
                         totals['active_troops'], totals['reserve_troops'])))
        for cid in range(self.m.PROVINCE_COUNTRY_NONE):
            owned = [p for p in self.model.provinces if p.country_id == cid]
            if owned:
                t = self.m.province_totals(self.model, owned)
                ruler = next((r for r in (self.m.province_ruler(self.model, p)
                                          for p in owned) if r is not None),
                             None)
                lines.append(('note',
                              'Country %d: %d provinces, 君主 %s, 金 %d 米 %d '
                              '現役 %d'
                              % (cid, len(owned),
                                 '%d %s' % (ruler.id, ruler.name)
                                 if ruler else '-', t['gold'], t['rice'],
                                 t['active_troops'])))
        self.report.config(state='normal')
        self.report.delete('1.0', 'end')
        for tag, line in lines:
            self.report.insert('end', line + '\n', tag)
        self.report.config(state='disabled')

    def show_diff(self):
        lines = self.model.province_change_lines()
        lines += self.model.change_lines()
        if not lines:
            self.log_line('no edits: the model still matches the CSVs on disk')
            return
        for line in lines:
            self.log_line(line)

    # -- save / repo -----------------------------------------------------
    def save_csv(self):
        try:
            written = self.model.save()
        except OSError as exc:
            messagebox.showerror('Cannot write CSV', str(exc))
            return None
        self.model.commit()
        self.log_line('saved %s' % ', '.join(os.path.basename(p)
                                             for p in written))
        self._refresh_all()
        return written

    def write_asm(self):
        if not self._repo_tools():
            return
        if self.save_csv() is None:
            return
        self._run([sys.executable, 'tools/gen_data_bank_asm.py', '--bank',
                   'all', '--from-csv', '--write'])
        self._run([sys.executable, 'tools/verify_data_banks.py',
                   '--allow-edits'])

    def verify(self):
        if not self._repo_tools():
            return
        self._run([sys.executable, 'tools/verify_data_banks.py',
                   '--allow-edits'])

    def _repo_tools(self):
        if not self.repo:
            messagebox.showinfo(
                'Standalone mode',
                'The disassembly repo tools are not next to this model copy,\n'
                'so the assembly cannot be regenerated from here.\n'
                'Save CSVs still writes both CSV twins.')
            return False
        return True

    def _run(self, argv):
        self.log_line('$ ' + ' '.join(a if not a.endswith('.py')
                                      else os.path.relpath(a, self.repo)
                                      for a in argv))
        try:
            r = subprocess.run(argv, cwd=self.repo, capture_output=True,
                               text=True)
        except OSError as exc:
            self.log_line('failed to run: %s' % exc)
            return None
        for line in ((r.stdout or '') + (r.stderr or '')).strip().splitlines():
            self.log_line(line)
        self.log_line('[exit %d]' % r.returncode)
        return r.returncode

    def log_line(self, line):
        self.log.config(state='normal')
        self.log.insert('end', line + '\n')
        self.log.see('end')
        self.log.config(state='disabled')

    # -- keys ------------------------------------------------------------
    def _on_key(self, event):
        if self._typing_focus():
            return
        if event.char == '/':
            self.focus_filter()
        elif event.keysym == 'PageDown':
            self._step(1)
        elif event.keysym == 'PageUp':
            self._step(-1)

    def _typing_focus(self):
        try:
            widget = self.focus_get()
        except (tk.TclError, KeyError):
            return False
        return isinstance(widget, (ttk.Entry, tk.Entry, tk.Text, ttk.Spinbox,
                                   tk.Spinbox, ttk.Combobox))

    def focus_filter(self):
        self.filter_entry.focus_set()
        self.filter_entry.select_range(0, 'end')

    def clear_filter(self):
        if self.filter_var.get():
            self.filter_var.set('')

    def _step(self, delta):
        ids = list(self.tree.get_children())
        if not ids:
            return
        selection = self.tree.selection()
        index = ids.index(selection[0]) if selection else 0
        index = max(0, min(len(ids) - 1, index + delta))
        self.tree.selection_set(ids[index])
        self.tree.see(ids[index])

    def _status_text(self, count=None):
        count = len(self.tree.get_children()) if count is None else count
        edits = self._change_count()
        return ('%d province%s | %d edit%s | source: %s'
                % (count, '' if count == 1 else 's', edits,
                   '' if edits == 1 else 's',
                   os.path.basename(self.model.paths.get('province', '?'))))

    # -- closing ---------------------------------------------------------
    def _confirm_discard(self):
        edits = self._change_count()
        if not edits:
            return True
        return messagebox.askyesno(
            'Unsaved edits',
            'Discard the %d edit%s that are not in the CSVs?'
            % (edits, '' if edits == 1 else 's'))

    def on_close(self):
        if self._confirm_discard():
            self.destroy()


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--province-csv', help='docs/province_data.csv to edit')
    ap.add_argument('--officer-csv',
                    help='officer_data.csv holding the roster statuses')
    ap.add_argument('--model', help='directory or file holding officer_model.py')
    ap.add_argument('--repo', help='disassembly repo root for Write ASM/Verify')
    args = ap.parse_args()
    module, _ = load_model(args.model)
    repo = module.find_repo(args.repo,
                            os.path.dirname(os.path.dirname(
                                os.path.abspath(__file__))))
    app = ProvinceEditor(module, repo=repo,
                         officer_csv=args.officer_csv,
                         province_csv=args.province_csv)
    app.mainloop()


if __name__ == '__main__':
    main()
