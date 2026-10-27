#!/usr/bin/env python3
"""Sangokushi 2 tactical map editor - standalone GUI for the terrain data banks.

What it edits
-------------
The tactical (war-layer) maps of all **30 provinces** of *Sangokushi 2 - Haou no
Tairiku* (Namco-163, mapper 19). Each province map is an authored 32 x 20 grid
assembled from four 16x16 quadrant crops, one tile byte per cell, and the 120
crops live in four `$8000-$9FFF` data banks (`@GetTileTerrain` $B6EF reads them
through TerrainMapPtrTable + TileBankTable):

| Provinces | Bank | | Provinces | Bank |
|---|---|---|---|---|
| 0-7   | `$00` | | 16-23 | `$04` |
| 8-13  | `$03` | | 24-29 | `$05` |
| 14-15 | `$05` | |       |      |

The editor keeps all four banks in memory and writes through the project's data
pipeline, so painting one province and painting its neighbour use the same tool:

    banks $00/$03/$04/$05  <->  docs/terrain_bank_XX.csv  ->  asm/banks/data_XX.asm

Views
-----
  Province  the authored 32 x 20 tactical map of any of the 30 provinces (one
            edit per map cell). Switch with the named dropdown (`17  荆州 ...`),
            the ◀ / ▶ buttons, PageDown/PageUp, or digit keys 0-9.
  Crop      one of the 120 raw 16 x 16 crop windows as the engine addresses them,
            ribbon gap rows marked, including rows 9-15 of a lower crop which
            physically belong to the next crop (edits go through the owner).
  Bank rows  a bank exactly as its CSV states it - every owner row of 16 bytes,
            so the overlay heads, the inter-crop pads, the $FF tails and bank
            `$03`'s leading sound command streams are reachable too.

Zoom
----
The grid scales from 6 to 96 px per cell (100 % = 20 px). Ctrl+wheel zooms at
the pointer, plain wheel pans, `+` / `-` zoom about the centre, `Ctrl+0` returns
to 100 %, `f` (or `Fit`) sizes the view so the whole map is visible. Glyphs and
ruler digits drop out below 10 px / 16 px so a zoomed-out map stays readable.
Painting always resolves the pointer back through the current scale, so a click
writes the byte under the cursor at any zoom.

Render modes
------------
  Classes   the decode view: one flat colour per terrain class plus a letter
            glyph, which is what makes a 128->9 collapse legible.
  Real tiles the graphics the console actually draws: the tile byte indexes
            `MetaTileData` ($F477, bank $1F) for 4 nametable bytes (TL,TR,BL,BR)
            = one 16x16 px cell, decoded from display record 1's CHR pages
            ($88/$89/$8A) and coloured with the crop's own attribute head under
            palette record $01. Codec in `tools/terrain_tiles.py`, which is also
            a standalone PNG renderer. Needs `rom/prg/prg_1f.bin` +
            `rom/chr/*.bin`; without them the mode disables itself and the class
            view keeps working.

Settlement objects
------------------
The buildings are not in the crop bytes. `$61` (Castle) and `$79`/`$7A`/`$7B` are
gameplay ids whose metatile is plain ground, and `DrawStratagemTargetMarkers`
draws the picture as a 16x16 OAM sprite at the position of two bank `$31` tables:
`ProvincePixelPositionTable` `$9D58` (the castle) and
`ProvinceTacticalFacilityTiles` `$9BA4` (up to three towns per province, in
House 民家 / Armory 武器屋 / Hospital 病院 slot order). So the *tables* decide where
a town is; the map bytes are the designer's stamps for the same cells, and the
authored data is not consistent - 12 of the 67 pairs have no stamp and 2 stamps
sit one row off from their pair. The classes view writes letters (`c` castle,
`h`/`a`/`b` the town the table marks, `v` a stamp with no marker), and only the
real-tiles view draws the sprites (`@ProvinceMarkerOam`, `@CityMarkerOam`), when
`objects` is ticked.

Running it
----------
    python3 editor/tactical_map_editor.py                     # repo CSVs/banks
    python3 editor/tactical_map_editor.py --csv bank_00.csv   # one bank's CSV
    python3 editor/tactical_map_editor.py --rom prg_03.bin    # raw bank image
    python3 editor/tactical_map_editor.py --model . --csv x.csv   # outside the repo

Dependencies: Python 3 with `tkinter` only (stdlib). The codec lives in
`tools/terrain_model.py`; `--model PATH` (or a copy of that file next to this
script) points the editor at it, which is what lets the same editor travel
outside the disassembly repo with nothing but a CSV.

Editing model
-------------
Everything is a *tile byte*, never a terrain id: `TileTerrainTable` collapses
128 tile ids into 9 terrain classes, so the terrain shown here is a decode, and
the palette offers real tile bytes grouped by the class they resolve to. Saving
writes every bank's CSV; `Write ASM` then calls `tools/gen_terrain_asm.py
--bank all --from-csv --write` and `tools/verify_terrain_banks.py`, so the
assembly and the byte-exactness gate stay in one place.
"""
import argparse
import os
import subprocess
import sys
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

CELL = 20                    # grid cell edge in px (the 100 % zoom)
CELL_MIN = 6                 # smallest cell edge that still reads as a grid
CELL_MAX = 96                # one cell per screen quarter-ish; keeps pan useful
ZOOM_STEP = 1.25             # per wheel notch / per +/- keypress
GLYPH_MIN_PX = 10            # below this cell edge a tile glyph is unreadable
TILE_PX = 16                 # a map cell is 16x16 px: MetaTileData is 2x2 tiles
# Classes-view letters for the settlement markers. The bank $31 tables decide
# which cell shows a building, so the letters follow them: 'c' castle
# ($9D58), 'h'/'a'/'b' = the House 民家 / Armory 武器屋 / Hospital 病院 pair in
# $9BA4 slot order. 'v' marks a $79/$7A/$7B stamp that no table pair covers.
OBJECT_CHARS = {'castle': 'c', 'facility': 'hab', 'village': 'v'}
LABEL = 26                   # left/top ruler width/height
CANVAS_W = 700               # requested grid pane, see _build_ui (a canvas
CANVAS_H = 430               # otherwise requests nothing and gets starved)
MAX_UNDO = 40


# --- codec import -------------------------------------------------------
def load_model(cli_path=None):
    """Import terrain_model from --model, a local copy, or the parent repo.

    Search order: the explicit path, this directory (so the editor travels with
    a copy of the codec), then `tools/` of the repo that holds `editor/`.
    """
    here = os.path.dirname(os.path.abspath(__file__))
    repo = os.path.dirname(here)
    directories = []
    if cli_path:
        directories.append(cli_path if os.path.isdir(cli_path)
                           else os.path.dirname(os.path.abspath(cli_path)))
    directories += [here, os.path.join(repo, 'tools')]
    for directory in directories:
        candidate = os.path.join(directory, 'terrain_model.py')
        if os.path.exists(candidate):
            if directory not in sys.path:
                sys.path.insert(0, directory)
            import terrain_model
            return terrain_model, directory
    raise SystemExit(
        'terrain_model.py not found (looked in: %s).\n'
        'Pass --model PATH, drop a copy next to this script, or keep it inside\n'
        'the sango2dasm repo where tools/terrain_model.py lives.'
        % ', '.join(directories))


# --- tile graphics import ------------------------------------------------
def load_tiles(directory=None):
    """Import terrain_tiles from wherever the codec came from (optional).

    The real-tile render mode needs ROM dumps (prg_1f.bin, chr_*.bin) that a
    standalone CSV-only copy of the editor does not have, so failing to find the
    module is a supported state, not an error.
    """
    here = os.path.dirname(os.path.abspath(__file__))
    directories = ([directory] if directory else []) + [
        here, os.path.join(os.path.dirname(here), 'tools')]
    for path in directories:
        if os.path.exists(os.path.join(path, 'terrain_tiles.py')):
            if path not in sys.path:
                sys.path.insert(0, path)
            import terrain_tiles
            return terrain_tiles
    return None


# --- view geometry ------------------------------------------------------
class Cell:
    """One paintable grid position: which bank byte it stands for."""
    __slots__ = ('col', 'row', 'bank', 'offset', 'zone', 'quad', 'crop_row',
                 'is_gap')

    def __init__(self, col, row, bank, offset, zone=None, quad='',
                 crop_row=None, is_gap=False):
        self.col, self.row = col, row
        self.bank, self.offset = bank, offset
        self.zone, self.quad, self.crop_row = zone, quad, crop_row
        self.is_gap = is_gap


def cell_at(px, origin, cell):
    """Grid index for a canvas coordinate - the inverse of draw_grid's layout."""
    return int((px - origin) // cell)


def fit_cell(cols, rows, avail_w, avail_h):
    """Largest cell edge that shows a whole view without any scrolling."""
    return max(CELL_MIN, min(CELL_MAX, (avail_w - LABEL) // cols,
                             (avail_h - LABEL) // rows))


def scroll_frac(origin, total, visible):
    """xview/yview fraction placing canvas coordinate `origin` at the edge."""
    span = total - visible
    return 0.0 if span <= 0 else max(0.0, min(1.0, float(origin) / span))


def wheel_steps(event):
    """Normalise a wheel event to notches: +1 up, -1 down, 0 none."""
    num = getattr(event, 'num', None)
    if num in (4, 5):                       # X11 reports the button, not delta
        return 1 if num == 4 else -1
    return int(event.delta / 120)


def glyph_font(cell):
    """Monospace size for a tile glyph/ruler digit at this cell edge."""
    return max(6, min(16, int(cell * 0.5)))


CONTROL_MASK = 0x0004
SHIFT_MASK = 0x0001


# --- view builders ------------------------------------------------------
def province_view(m, prov):
    """Authored 32 x 20 map cells; every cell is an owned crop byte."""
    rows = []
    for y in range(m.MAP_H):
        line = []
        for x in range(m.MAP_COLS):
            zone = (prov * 4 + (0 if y < m.TOP_ROWS else 1)
                    + (2 if x >= m.GRID else 0))
            crop_row = y if y < m.TOP_ROWS else y - m.TOP_ROWS
            off = m.zone_offset(zone) + crop_row * m.GRID + (x & 15)
            line.append(Cell(x, y, m.zone_bank(zone), off, zone,
                             m.zone_meta(zone)[1], crop_row))
        rows.append(line)
    bank = m.zone_bank(prov * 4)
    return m.MAP_COLS, m.MAP_H, rows, ('province %d - %s   (bank $%02X)'
                                       % (prov, province_name(m, prov), bank))


def crop_view(m, zone):
    """Raw 16 x 16 crop window, every cell resolved to its physical owner."""
    bank = m.zone_bank(zone)
    rows = []
    for y in range(m.GRID):
        line = []
        for x in range(m.GRID):
            _oz, _orow, obank, off = m.cell_owner(zone, y, x)
            line.append(Cell(x, y, obank, off, zone, m.zone_meta(zone)[1], y,
                             is_gap=m.is_gap(zone, y)))
        rows.append(line)
    prov, quad, _ = m.zone_meta(zone)
    alias = '' if not zone % 2 else ' - rows 9-15 alias zone %d' % (zone + 1)
    return m.GRID, m.GRID, rows, ('zone %d - province %d %s (bank $%02X)%s'
                                  % (zone, prov, quad, bank, alias))


def province_name(m, prov):
    """Province name from the repo's province CSVs, when they are present.

    docs/province_data.csv is the editing surface the province editor writes,
    so it wins over the extraction-time docs/province_names.csv.
    """
    if prov in _PROVINCE_NAMES:
        return _PROVINCE_NAMES[prov]
    name = 'id %d' % prov
    for csv_name in ('province_data.csv', 'province_names.csv'):
        path = os.path.join(m.ROOT, 'docs', csv_name)
        if not os.path.exists(path):
            continue
        import csv
        with open(path, encoding='utf-8') as f:
            for row in csv.DictReader(f):
                if (row.get('id') or '').strip() == str(prov):
                    kanji = (row.get('kanji_ja') or row.get('zh_hans')
                             or row.get('romaji') or '').strip()
                    kana = (row.get('katakana') or '').strip()
                    if kanji:
                        name = '%s (%s)' % (kanji, kana) if kana else kanji
                    break
        if name != 'id %d' % prov:
            break
    _PROVINCE_NAMES[prov] = name
    return name


_PROVINCE_NAMES = {}


# --- application --------------------------------------------------------
class TacticalMapEditor(tk.Tk):
    SELECTOR_TITLE = {'province': 'Province', 'zone': 'Crop zone',
                      'raw': 'Terrain bank'}

    def __init__(self, model, csv_path=None, rom_path=None):
        super().__init__()
        self.m = model
        self.title('Sangokushi 2 - Tactical Map Editor (terrain banks $00/$03/'
                   '$04/$05, 30 provinces)')
        self.geometry('1200x780')
        self.banks = {b: bytearray(b'\xFF' * model.BANK_SIZE)
                      for b in model.TERRAIN_BANKS}
        self.stock = {}                  # reference images for the diff view
        self.sources = {}                # bank -> path it was loaded from
        self.undo, self.redo = [], []
        self.view_kind = tk.StringVar(value='province')
        self.view_index = tk.IntVar(value=0)
        self.brush = tk.IntVar(value=0x39)  # Plain tile $39, the common ground
        self.show_glyphs = tk.BooleanVar(value=True)
        self.show_edits = tk.BooleanVar(value=False)
        self.show_objects = tk.BooleanVar(value=True)
        self.cell = CELL                   # current zoom: cell edge in px
        self.render_mode = tk.StringVar(value='class')
        self.tiles = None
        self.tile_codec = None               # the terrain_tiles module, if found
        # bank $31: $9BA4 ProvinceTacticalFacilityTiles + $9D58 the castle
        self.facilities = model.load_facilities()
        self.castles = model.load_castles()
        self._images = {}                  # (tile, cell px) -> PhotoImage
        self._markers = {}                 # (kind, cell px)  -> marker PhotoImage
        self.tile_table = model.TILE_TERRAIN_TABLE
        self._dragging = False
        self._dirty = False
        self._selector_cache = {}        # view kind -> dropdown entries
        self._build_ui()
        self._load_tiles()
        self._zoom_var().set('%d px  %d%%' % (self.cell, 100))
        self._load_default(csv_path, rom_path)
        self._refresh_all()
        self.protocol('WM_DELETE_WINDOW', self.on_close)

    # -- widget layout ---------------------------------------------------
    def _build_ui(self):
        top = ttk.Frame(self, padding=6)
        top.pack(side='top', fill='x')
        ttk.Label(top, text='View').pack(side='left')
        for text, val in (('Province (authored 32x20)', 'province'),
                          ('Crop window (16x16)', 'zone'),
                          ('Bank CSV rows', 'raw')):
            ttk.Radiobutton(top, text=text, value=val, variable=self.view_kind,
                            command=self._on_view_kind).pack(side='left')
        # the map selector: a named dropdown plus step buttons and digit keys
        self.selector_label = ttk.Label(top, text='Province',
                                        font=('TkDefaultFont', 9, 'bold'))
        self.selector_label.pack(side='left', padx=(12, 3))
        ttk.Button(top, text='\u25c0', width=3,
                   command=lambda: self.step_view(-1)).pack(side='left')
        self.selector = ttk.Combobox(top, state='readonly', width=30)
        self.selector.pack(side='left', padx=2)
        self.selector.bind('<<ComboboxSelected>>', self.on_select_index)
        ttk.Button(top, text='\u25b6', width=3,
                   command=lambda: self.step_view(1)).pack(side='left')
        ttk.Label(top, textvariable=self._subtitle_var()).pack(side='left',
                                                               padx=8)

        bar = ttk.Frame(self, padding=(6, 0))
        bar.pack(side='top', fill='x')
        for text, cmd in (('Open CSV', self.open_csv),
                          ('Open ROM bin', self.open_rom),
                          ('Save all CSVs', self.save_csv),
                          ('Export bin', self.export_bin),
                          ('Write ASM', self.write_asm),
                          ('Verify', self.verify),
                          ('Revert to source', self.reload),
                          ('Undo', self.undo_edit)):
            ttk.Button(bar, text=text, command=cmd).pack(side='left', padx=2)
        ttk.Checkbutton(bar, text='glyphs', variable=self.show_glyphs,
                        command=self.draw_grid).pack(side='left', padx=6)
        ttk.Checkbutton(bar, text='highlight edits', variable=self.show_edits,
                        command=self.draw_grid).pack(side='left')
        ttk.Checkbutton(bar, text='objects', variable=self.show_objects,
                        command=self.draw_grid).pack(side='left', padx=6)

        body = ttk.Panedwindow(self, orient='horizontal')
        body.pack(side='top', fill='both', expand=True, padx=6, pady=4)
        left = ttk.Frame(body)
        right = ttk.Frame(body, width=340)
        body.add(left, weight=3)
        body.add(right, weight=1)
        # ttk only lays sashes out from requested sizes when the window is
        # resized, so a cold start leaves the map pane a sliver without this.
        self._sash_placed = False
        body.bind('<Configure>', self._place_sash)
        # A Panedwindow splits by each pane's *requested* size, and a bare
        # tk.Canvas requests 0x0, which would starve the map down to a sliver.
        self.canvas = tk.Canvas(left, bg='#202020', highlightthickness=0,
                                width=CANVAS_W, height=CANVAS_H)
        self.hscroll = ttk.Scrollbar(left, orient='horizontal',
                                     command=self.canvas.xview)
        self.vscroll = ttk.Scrollbar(left, orient='vertical',
                                     command=self.canvas.yview)
        self.canvas.configure(xscrollcommand=self.hscroll.set,
                              yscrollcommand=self.vscroll.set)
        self._show_grid(True)
        self.canvas.bind('<Button-1>', self.on_press)
        self.canvas.bind('<B1-Motion>', self.on_drag)
        self.canvas.bind('<ButtonRelease-1>', self.on_release)
        self.canvas.bind('<Motion>', self.on_motion)
        self.canvas.bind('<Configure>', lambda e: self.draw_grid())
        # one wheel handler: Tk delivers MouseWheel or Button-4/5 per platform
        for seq in ('<MouseWheel>', '<Button-4>', '<Button-5>'):
            self.canvas.bind(seq, self.on_wheel)

        # what the grid is painted with: the terrain decode, or the real CHR art
        mode = ttk.Frame(right)
        mode.pack(side='top', fill='x', pady=(0, 4))
        ttk.Label(mode, text='Render',
                  font=('TkDefaultFont', 9, 'bold')).pack(side='left')
        self._mode_buttons = []
        for text, val in (('classes', 'class'), ('real tiles', 'tile')):
            button = ttk.Radiobutton(mode, text=text, value=val,
                                     variable=self.render_mode,
                                     command=self._refresh_all)
            button.pack(side='left', padx=4)
            self._mode_buttons.append(button)

        # zoom controls live in the side panel: the button bar is already full
        zoom = ttk.Frame(right)
        zoom.pack(side='top', fill='x', pady=(0, 6))
        ttk.Label(zoom, text='Zoom', font=('TkDefaultFont', 9, 'bold')).pack(
            side='left')
        ttk.Button(zoom, text='Fit', command=self.zoom_fit).pack(side='right')
        ttk.Label(zoom, textvariable=self._zoom_var(), width=10).pack(
            side='right', padx=4)
        ttk.Button(zoom, text='+', width=3,
                   command=lambda: self.zoom_step(ZOOM_STEP)).pack(side='right')
        ttk.Button(zoom, text='\u2212', width=3,
                   command=lambda: self.zoom_step(1 / ZOOM_STEP)).pack(
            side='right', padx=(0, 4))

        ttk.Label(right, text='Brush - tile byte (terrain it resolves to)',
                  font=('TkDefaultFont', 9, 'bold')).pack(anchor='w')
        row = ttk.Frame(right)
        row.pack(side='top', fill='x', pady=2)
        self.brush_entry = ttk.Entry(row, width=8)
        self.brush_entry.insert(0, '$%02X' % self.brush.get())
        self.brush_entry.pack(side='left')
        ttk.Button(row, text='Set', command=self.apply_brush_entry).pack(
            side='left', padx=3)
        ttk.Label(row, textvariable=self._brush_label_var()).pack(side='left')
        self.palette = ttk.Combobox(right, state='readonly', width=44,
                                    values=self._palette_values())
        self.palette.current(0)
        self.palette.pack(side='top', fill='x', pady=2)
        self.palette.bind('<<ComboboxSelected>>', self.on_palette)

        ttk.Label(right, text='Cell info', font=('TkDefaultFont', 9, 'bold')) \
            .pack(anchor='w', pady=(10, 0))
        self.info = tk.Text(right, height=6, wrap='word', state='disabled',
                            bg='#262626', fg='#DDDDDD')
        self.info.pack(side='top', fill='x')

        ttk.Label(right, text='Terrain census (current view)',
                  font=('TkDefaultFont', 9, 'bold')).pack(anchor='w',
                                                          pady=(10, 0))
        self.census = tk.Text(right, height=7, wrap='word', state='disabled',
                              bg='#262626', fg='#DDDDDD')
        self.census.pack(side='top', fill='x')

        ttk.Label(right, text='Output', font=('TkDefaultFont', 9, 'bold')) \
            .pack(anchor='w', pady=(10, 0))
        self.log = tk.Text(right, height=10, wrap='word', state='disabled',
                           bg='#1B1B1B', fg='#B7E4B7')
        self.log.pack(side='top', fill='both', expand=True)

        self.status = ttk.Label(self, text='', anchor='w', padding=(6, 3))
        self.status.pack(side='bottom', fill='x')
        self.bind('<Control-s>', lambda e: self.save_csv())
        self.bind('<Control-b>', lambda e: self.write_asm())
        self.bind('<Control-z>', lambda e: self.undo_edit())
        self.bind('<Control-y>', lambda e: self.redo_edit())
        self.bind('<Next>', lambda e: self.step_view(1))
        self.bind('<Prior>', lambda e: self.step_view(-1))
        for digit in range(10):
            self.bind('<KeyPress-%d>' % digit,
                      lambda e, n=digit: self.select_by_digit(n))
        for seq in ('<KeyPress-plus>', '<KeyPress-equal>', '<KeyPress-KP_Add>'):
            self.bind(seq, lambda e: self.zoom_key(ZOOM_STEP))
        for seq in ('<KeyPress-minus>', '<KeyPress-KP_Subtract>'):
            self.bind(seq, lambda e: self.zoom_key(1 / ZOOM_STEP))
        self.bind('<Control-KeyPress-0>',
                  lambda e: self.set_cell(CELL))     # 100 %, Ctrl+ avoids the digit keys
        self.bind('<KeyPress-f>', lambda e: self.zoom_fit())

        # bank row tree (hidden unless the CSV-rows view is active)
        self.tree = ttk.Treeview(self.canvas.master, columns=(
            'offset', 'kind', 'zone', 'prov', 'quad', 'row', 'tiles'),
            show='headings', height=20)
        for key, text, width in (('offset', 'offset', 70), ('kind', 'kind', 70),
                                 ('zone', 'zone', 55), ('prov', 'province', 65),
                                 ('quad', 'quadrant', 70), ('row', 'crop_row', 65),
                                 ('tiles', 't0..t15 (hex)', 420)):
            self.tree.heading(key, text=text)
            self.tree.column(key, width=width,
                             anchor='w' if key == 'tiles' else 'center')
        self.tree.bind('<Double-1>', self.edit_raw_row)
        self.tree.pack_forget()

    def _subtitle_var(self):
        if not hasattr(self, '_subtitle'):
            self._subtitle = tk.StringVar(value='')
        return self._subtitle

    def _brush_label_var(self):
        if not hasattr(self, '_brush_label'):
            self._brush_label = tk.StringVar(value='')
        return self._brush_label

    def _zoom_var(self):
        if not hasattr(self, '_zoom'):
            self._zoom = tk.StringVar(value='')
        return self._zoom

    def _place_sash(self, event):
        """Give the map pane its requested width once, on the first real size."""
        if self._sash_placed or event.width < 2:
            return
        self._sash_placed = True
        event.widget.sashpos(0, max(1, min(CANVAS_W, event.width - 420)))

    def _load_tiles(self):
        """Try to arm the real-tile render mode; the class view works without it."""
        for button in self._mode_buttons:
            button.config(state='disabled')
        module = load_tiles(os.path.dirname(os.path.abspath(self.m.__file__)))
        if module is None:
            self.log_line('terrain_tiles.py not found - real tiles unavailable')
            return
        self.tiles = module.load(self.m.ROOT)
        if not self.tiles.available:
            self.log_line('real tiles unavailable: %s' % self.tiles.error)
            return
        self.tile_codec = module
        for button in self._mode_buttons:
            button.config(state='normal')
        self.log_line('real tiles: %s' % self.tiles.summary())
        self.log_line('town markers: %s' % (
            '%d towns + %d castles from bank $31 $9BA4/$9D58'
            % (sum(1 for row in self.facilities for pair in row if pair),
               len(self.castles)) if self.facilities and self.castles else
            'bank $31 not readable, so only the $61/$79/$7A/$7B map bytes show'))

    def _tiles_ready(self):
        return (self.tiles is not None and self.tiles.available
                and self.render_mode.get() == 'tile')

    def _cell_palette(self, cell):
        """Sub-palette of one crop cell, from its zone's attribute head."""
        if self.tile_codec is None:
            return 0
        m = self.m
        off = m.zone_offset(cell.zone)
        head = self.banks[m.zone_bank(cell.zone)]
        return self.tile_codec.head_palette(
            head[off - self.tile_codec.HEAD_BYTES:off],
            cell.col & (m.GRID - 1), cell.crop_row)

    def _tile_image(self, tile, size, bgpal=0):
        """A cell-size PhotoImage of one tile byte, nearest-neighbour scaled.

        Tk only scales by whole numbers, and the zoom steps are not multiples of
        16, so the resample is done here instead of with PhotoImage.zoom.
        """
        key = (tile, size, bgpal)
        image = self._images.get(key)
        if image is not None:
            return image
        image = tk.PhotoImage(width=size, height=size)
        rgb = self.tiles.cell_rgb(tile, bgpal)
        if rgb is None:                       # blocked byte: no MetaTileData row
            image.put([['#FF00FF'] * size for _ in range(size)])
        else:
            step = float(TILE_PX) / size
            image.put([['#%02X%02X%02X' % rgb[min(TILE_PX - 1, int(y * step))][
                                                  min(TILE_PX - 1, int(x * step))]
                        for x in range(size)] for y in range(size)])
        self._images[key] = image
        return image

    def _marker_image(self, kind, size):
        """A cell-size marker sprite, transparent where the game leaves holes.

        A fresh tk.PhotoImage is fully transparent, so only the opaque pixels are
        put() and the map shows through - which is how the OAM sprite behaves.
        """
        key = (kind, size)
        image = self._markers.get(key)
        if image is not None:
            return image
        image = tk.PhotoImage(width=size, height=size)
        rgb = self.tiles.marker_rgb(kind)
        step = float(TILE_PX) / size
        for y in range(size):
            for x in range(size):
                px = rgb[min(TILE_PX - 1, int(y * step))][
                    min(TILE_PX - 1, int(x * step))]
                if px is not None:
                    image.put('#%02X%02X%02X' % px, (x, y))
        self._markers[key] = image
        return image

    def _map_cell(self, cell):
        """(province, map_x, map_y) a grid position stands for, in any view."""
        m = self.m
        prov, quad = m.zone_meta(cell.zone)[0], cell.quad
        gx = cell.col & (m.GRID - 1)
        return (prov, gx if quad in ('TL', 'BL') else m.GRID + gx,
                cell.crop_row if quad in ('TL', 'TR') else m.TOP_ROWS + cell.crop_row)

    def _town(self, cell):
        """('castle', None) or ('facility', slot) where the ROM tables put a marker.

        `DrawStratagemTargetMarkers` takes both positions from bank $31 - the
        castle from `ProvincePixelPositionTable` ($9D58) and each town from
        `ProvinceTacticalFacilityTiles` ($9BA4) - so these cells are where the
        console really draws a building. The $61/$79/$7A/$7B stamps in the crop
        bytes only mark the same cells for the designer: 12 of the 67 pairs have
        no stamp and 2 stamps sit one row off from their pair.
        """
        prov, x, y = self._map_cell(cell)
        if self.castles and self.castles[prov] == (x, y):
            return 'castle', None
        if self.facilities:
            for slot, pair in enumerate(self.facilities[prov]):
                if pair == (x, y):
                    return 'facility', slot
        return None

    def _stamp(self, cell):
        """'castle' / 'facility' when the map *byte* here is a settlement id."""
        if self.tile_codec is None:
            return None
        return self.tile_codec.OBJECT_TILES.get(
            self.get_byte(cell.bank, cell.offset))

    def _object_marker(self, cell):
        """The marker sprite kind to draw on this cell, or None.

        Markers belong to the real-tiles view only; the classes view spells the
        same objects out as characters instead.
        """
        if (self.tile_codec is None or not self.show_objects.get()
                or self.render_mode.get() != 'tile'):
            return None
        town = self._town(cell)
        return town[0] if town else None

    def _facility_index(self, cell):
        """Which ProvinceTacticalFacilityTiles slot (0/1/2) marks this cell, or None."""
        town = self._town(cell)
        return town[1] if town and town[0] == 'facility' else None

    def _facility_slot(self, cell):
        """The facility name the table gives this cell, e.g. 'Hospital 病院'."""
        index = self._facility_index(cell)
        return None if index is None else self.m.FACILITY_SLOTS[index]

    def _object_char(self, cell):
        """The classes-view character for a settlement cell, else None.

        The tables decide which town is drawn, so they pick the letter: `c`
        castle, `h`/`a`/`b` House/Armory/Hospital. `v` is a $79/$7A/$7B stamp the
        tables have no pair for, i.e. a settlement the console never draws.
        """
        town = self._town(cell)
        if town is not None:
            return (OBJECT_CHARS['castle'] if town[0] == 'castle'
                    else OBJECT_CHARS['facility'][town[1]])
        return OBJECT_CHARS['village'] if self._stamp(cell) else None

    def _object_note(self, tile, cell):
        """The cell-info line for a marker cell or a settlement stamp, else ''."""
        town, stamp = self._town(cell), self._stamp(cell)
        if town is None and stamp is None:
            return ''
        byte = '$%02X %s' % (tile, self.m.terrain_name(tile, self.tile_table))
        if town is not None:
            name, table = (
                ('castle', 'ProvincePixelPositionTable $9D58')
                if town[0] == 'castle'
                else (self.m.FACILITY_SLOTS[town[1]],
                      'ProvinceTacticalFacilityTiles $9BA4'))
            note = ('marker sprite here (%s, from %s) - map byte %s'
                    % (name, table, byte))
            if stamp is None:
                note += ' (never stamped in the terrain)'
            elif stamp != town[0]:
                note += ' (map byte says %s)' % stamp
            return note
        return ('no marker on this cell - the map byte %s is a settlement the '
                'tables have no pair for' % byte)

    def _prune_images(self, keep):
        """Drop cached tile/marker images for zoom levels the user has left behind."""
        for cache in (self._images, self._markers):
            for key in [k for k in cache if k[1] not in keep]:
                del cache[key]            # Tk frees the image with the last ref

    def _show_grid(self, show):
        """Pack/forget the canvas with its scrollbars in the right order.

        Pack order matters in tkinter: the scrollbars claim their edge first,
        so the canvas fills what is left instead of pushing them off-screen.
        """
        for widget in (self.vscroll, self.hscroll, self.canvas):
            widget.pack_forget()
        if not show:
            return
        self.vscroll.pack(side='right', fill='y')
        self.hscroll.pack(side='bottom', fill='x')
        self.canvas.pack(side='top', fill='both', expand=True)

    # -- bank access -----------------------------------------------------
    def get_byte(self, bank, offset):
        return self.banks[bank][offset]

    def set_byte(self, bank, offset, value):
        self.banks[bank][offset] = value

    def current_bank(self):
        """The bank the current view is centred on (used by Export bin)."""
        kind = self.view_kind.get()
        if kind == 'province':
            return self.m.zone_bank(self.view_index.get() * 4)
        if kind == 'zone':
            return self.m.zone_bank(self.view_index.get())
        return self.m.TERRAIN_BANKS[min(self.view_index.get(),
                                        len(self.m.TERRAIN_BANKS) - 1)]

    # -- loading ---------------------------------------------------------
    def _load_default(self, csv_path, rom_path):
        if rom_path:
            self.load_rom(rom_path)
            return
        if csv_path:
            self.load_csv(csv_path)
            return
        loaded = 0
        for bank in self.m.TERRAIN_BANKS:
            path = self.m.csv_path(bank)
            if os.path.exists(path):
                self._apply_rows(bank, self.m.csv_read(path, bank), path)
                loaded += 1
                continue
            bin_path = os.path.join(self.m.PRG_DIR, 'prg_%02x.bin' % bank)
            if os.path.exists(bin_path):
                self._apply_bank(bank, self.m.read_bank(bank), bin_path)
                loaded += 1
        self._refresh_stock()
        if loaded == 0:
            self.log_line('no docs/terrain_bank_XX.csv and no rom/prg/*.bin; '
                          'started empty - use Open CSV / Open ROM bin')
        elif loaded < len(self.m.TERRAIN_BANKS):
            self.log_line('loaded %d of %d terrain banks - the rest show as '
                          '$FF filler until you open them'
                          % (loaded, len(self.m.TERRAIN_BANKS)))

    def _apply_rows(self, bank, rows, path):
        self.banks[bank] = bytearray(self.m.bank_from_rows(bank, rows))
        self.sources[bank] = path

    def _apply_bank(self, bank, data, path):
        if len(data) != self.m.BANK_SIZE:
            raise ValueError('%s is %d bytes, a terrain bank is %d'
                             % (path, len(data), self.m.BANK_SIZE))
        self.banks[bank] = bytearray(data)
        self.sources[bank] = path

    def _refresh_stock(self):
        """Reference images for the diff view: the stock ROM banks, if present."""
        self.stock = {}
        for bank in self.m.TERRAIN_BANKS:
            try:
                self.stock[bank] = self.m.read_bank(bank)
            except OSError:
                pass

    def load_csv(self, path):
        """Load one bank's CSV twin by path (used by the dialog and `--csv`)."""
        bank = self._bank_from_name(path)
        self._apply_rows(bank, self.m.csv_read(path, bank), path)
        self._after_load('loaded bank $%02X from %s' % (bank, path))

    def load_rom(self, path):
        """Load one bank's 8KB image by path (used by the dialog and `--rom`)."""
        bank = self._bank_from_name(path)
        with open(path, 'rb') as f:
            self._apply_bank(bank, f.read(), path)
        self._after_load('loaded bank $%02X from %s' % (bank, path))

    def open_csv(self):
        start = self.m.csv_path(self.current_bank())
        path = filedialog.askopenfilename(
            title='Open terrain CSV', initialdir=os.path.dirname(start),
            filetypes=[('CSV', '*.csv'), ('All files', '*.*')])
        if not path:
            return
        try:
            self.load_csv(path)
        except (ValueError, KeyError, OSError) as exc:
            messagebox.showerror('Cannot load CSV', str(exc))

    def open_rom(self):
        start = os.path.join(self.m.PRG_DIR,
                             'prg_%02x.bin' % self.current_bank())
        path = filedialog.askopenfilename(
            title='Open 8KB bank image', initialdir=os.path.dirname(start),
            filetypes=[('binary', '*.bin'), ('All files', '*.*')])
        if not path:
            return
        try:
            self.load_rom(path)
        except (ValueError, OSError) as exc:
            messagebox.showerror('Cannot load bank image', str(exc))

    def _bank_from_name(self, path):
        """Infer the bank from a terrain_bank_03.csv / prg_03.bin style name."""
        import re
        match = re.search(r'(?:terrain_bank_|prg_)([0-9a-fA-F]{2})',
                          os.path.basename(path))
        if match:
            bank = int(match.group(1), 16)
            if bank in self.m.TERRAIN_BANKS:
                return bank
        choice = messagebox.askquestion(
            'Which bank?',
            'Cannot tell the PRG bank from %s.\n\nLoad it as bank $%02X (Yes) '
            'or cancel (No)?' % (os.path.basename(path), self.current_bank()))
        if choice != 'yes':
            raise ValueError('aborted: specify the bank through the filename')
        return self.current_bank()

    def _after_load(self, message):
        self._refresh_stock()
        self.undo, self.redo = [], []
        self._dirty = False
        self.log_line(message)
        self._refresh_all()

    def reload(self):
        if not self._confirm_discard():
            return
        for bank, path in list(self.sources.items()):
            try:
                if path.endswith('.csv'):
                    self._apply_rows(bank, self.m.csv_read(path, bank), path)
                else:
                    with open(path, 'rb') as f:
                        self._apply_bank(bank, f.read(), path)
            except (OSError, ValueError) as exc:
                messagebox.showerror('Cannot reload', str(exc))
                return
        self._after_load('reloaded %d bank(s) from their files'
                         % len(self.sources))

    # -- painting --------------------------------------------------------
    def _cell_at(self, event):
        geom = getattr(self, 'geom', None)
        if not geom:
            return None
        x = self.canvas.canvasx(event.x)
        y = self.canvas.canvasy(event.y)
        col = cell_at(x, geom['ox'], self.cell)
        row = cell_at(y, geom['oy'], self.cell)
        if 0 <= row < len(geom['cells']) and 0 <= col < len(geom['cells'][0]):
            return geom['cells'][row][col]
        return None

    def on_press(self, event):
        if self.view_kind.get() == 'raw':
            return
        cell = self._cell_at(event)
        if cell is None:
            return
        self._push_undo()
        self._dragging = True
        self.paint(cell)

    def on_drag(self, event):
        if self._dragging:
            self.paint(self._cell_at(event))

    def on_release(self, event):
        self._dragging = False

    def on_motion(self, event):
        if self.view_kind.get() == 'raw':
            return
        cell = self._cell_at(event)
        if cell is not None:
            self.show_cell(cell)

    def paint(self, cell):
        if cell is None:
            return
        tile = self.brush.get()
        if self.get_byte(cell.bank, cell.offset) == tile:
            return
        self.set_byte(cell.bank, cell.offset, tile)
        self._dirty = True
        self.draw_grid()
        self._update_census()
        self.show_cell(cell)

    def show_cell(self, cell):
        m = self.m
        tile = self.get_byte(cell.bank, cell.offset)
        tid = m.tile_terrain(tile, self.tile_table)
        lines = [
            'bank $%02X offset $%04X (CPU $%04X)'
            % (cell.bank, cell.offset, m.WINDOW_CPU + cell.offset),
            'zone %s  province %d %s  crop row %s  grid (%d, %d)'
            % (cell.zone, m.zone_meta(cell.zone)[0], cell.quad,
               cell.crop_row, cell.col, cell.row),
            'tile $%02X -> terrain %d %s%s'
            % (tile, tid, m.TERRAIN_NAMES.get(tid, '?'),
               '  [blocked: tile >= $80, no table lookup]'
               if tile >= m.BLOCKED else ''),
            'ribbon gap row - the engine still reads it as terrain'
            if cell.is_gap else '',
            self._object_note(tile, cell),
        ]
        self._set_text(self.info, [ln for ln in lines if ln])
        self.status.config(text='%s | tile $%02X %s | brush $%02X %s'
                           % (self._title(), tile,
                              m.TERRAIN_NAMES.get(tid, '?'),
                              self.brush.get(),
                              m.terrain_name(self.brush.get(),
                                             self.tile_table)))

    # -- views -----------------------------------------------------------
    def index_limit(self):
        """How many entries the active view can select."""
        kind = self.view_kind.get()
        return (self.m.PROVINCES if kind == 'province'
                else self.m.ZONE_COUNT if kind == 'zone'
                else len(self.m.TERRAIN_BANKS))

    def selector_values(self):
        """Dropdown entries for the active view, aligned with the view index.

        Provinces are named from the repo's province CSVs (docs/province_data.csv
        first), which makes switching obvious: `17  荆州 (ショウシュウ)` instead
        of a bare number.
        """
        m = self.m
        kind = self.view_kind.get()
        if kind == 'province':
            return ['%2d  %s' % (p, province_name(m, p))
                    for p in range(m.PROVINCES)]
        if kind == 'zone':
            out = []
            for z in range(m.ZONE_COUNT):
                prov, quad, _ = m.zone_meta(z)
                tail = ''
                if z % 2:
                    tail = ('  - r9-15 = tail'
                            if z == m.ZONE_COUNT - 1
                            else '  - r9-15 alias z%d' % (z + 1))
                out.append('z%-3d prov %2d %s (bank $%02X)%s'
                           % (z, prov, quad, m.zone_bank(z), tail))
            return out
        return ['bank $%02X  provinces %s'
                % (b, self._bank_provinces(m, b)) for b in m.TERRAIN_BANKS]

    @staticmethod
    def _bank_provinces(m, bank):
        provs = sorted({m.zone_meta(z)[0] for z in m.bank_zones(bank)})
        ranges, start, prev = [], None, None
        for v in provs + [None]:
            if start is None:
                start = prev = v
                continue
            if v != prev + 1:
                ranges.append(str(start) if start == prev
                              else '%d-%d' % (start, prev))
                start = prev = v
            else:
                prev = v
        return ', '.join(ranges)

    def sync_selector(self):
        """Point the dropdown at the active view's list and current selection."""
        kind = self.view_kind.get()
        self.selector_label.config(text=self.SELECTOR_TITLE[kind])
        values = self._selector_cache.get(kind)
        if values is None:
            values = self._selector_cache[kind] = self.selector_values()
        self.selector['values'] = values
        index = min(self.view_index.get(), len(values) - 1)
        self.view_index.set(index)
        self.selector.current(index)
        self.selector.set(values[index])

    def on_select_index(self, event=None):
        current = self.selector.current()
        if current >= 0:
            self.view_index.set(current)
        self._refresh_all()

    def _typing_focus(self):
        """True when an entry/combobox/text panel owns the keystroke."""
        return isinstance(self.focus_get(),
                          (tk.Entry, tk.Text, ttk.Entry, ttk.Combobox))

    def select_by_digit(self, digit):
        """Keys 0-9 jump straight to provinces 0-9 (the rest: dropdown)."""
        if self._typing_focus():
            return                      # the keys belong to the text widget
        if self.view_kind.get() != 'province' or digit >= self.m.PROVINCES:
            return
        self.view_index.set(digit)
        self._refresh_all()

    def step_view(self, delta):
        """PageDown/PageUp and the arrow buttons walk the current list."""
        limit = self.index_limit()
        self.view_index.set((self.view_index.get() + delta) % limit)
        self._refresh_all()

    # -- zoom ------------------------------------------------------------
    def zoom_key(self, factor):
        if not self._typing_focus():
            self.zoom_step(factor)

    def zoom_step(self, factor):
        self.set_cell(self.cell * factor)

    def zoom_fit(self):
        """Scale the current view so the whole map fits without scrolling."""
        if self.view_kind.get() == 'raw':
            return
        self.canvas.update_idletasks()      # else winfo_* reports a stale box
        cols, rows = self._view_cells()[:2]
        self.set_cell(fit_cell(cols, rows, self.canvas.winfo_width(),
                               self.canvas.winfo_height()))
        self.canvas.xview_moveto(0.0)
        self.canvas.yview_moveto(0.0)

    def set_cell(self, value, anchor=None):
        """Scale the grid, keeping the map point under `anchor` (a widget xy) put.

        Without an anchor the visible centre is the pivot, which is what the
        toolbar buttons and +/- keys want; the wheel passes the pointer instead.
        """
        if self.view_kind.get() == 'raw':     # the row table has no zoom
            return
        new = max(CELL_MIN, min(CELL_MAX, int(round(value))))
        old = self.cell
        if new == old:
            return
        c = self.canvas
        vis_w, vis_h = max(1, c.winfo_width()), max(1, c.winfo_height())
        ax, ay = (vis_w // 2, vis_h // 2) if anchor is None else anchor
        px, py = c.canvasx(ax), c.canvasy(ay)
        self.cell = new
        self.draw_grid()
        # only after the repaint: a canvas item may not reference a freed image
        self._prune_images({new, old})
        total_w, total_h = max(self.geom['w'], vis_w), max(self.geom['h'],
                                                           vis_h)
        # where the pivot's cell landed at the new scale, then scroll it back
        self.canvas.xview_moveto(scroll_frac(
            LABEL + (px - LABEL) * new / old - ax, total_w, vis_w))
        self.canvas.yview_moveto(scroll_frac(
            LABEL + (py - LABEL) * new / old - ay, total_h, vis_h))
        self._zoom_var().set('%d px  %d%%' % (new, 100 * new // CELL))

    def on_wheel(self, event):
        """Ctrl+wheel zooms at the pointer, plain wheel pans, Shift pans X."""
        steps = wheel_steps(event)
        if not steps:
            return
        if event.state & CONTROL_MASK:
            self.set_cell(self.cell * (ZOOM_STEP if steps > 0 else 1 / ZOOM_STEP),
                          anchor=(event.x, event.y))
        elif event.state & SHIFT_MASK:
            self.canvas.xview_scroll(-steps * 2, 'units')
        else:
            self.canvas.yview_scroll(-steps * 2, 'units')

    def _on_view_kind(self):
        kind = self.view_kind.get()
        if self.view_index.get() >= self.index_limit():
            self.view_index.set(0)
        self.tree.pack_forget()
        if kind == 'raw':
            self._show_grid(False)
            self.tree.pack(side='top', fill='both', expand=True)
        else:
            self._show_grid(True)
        self._refresh_all()

    def _title(self):
        if self.view_kind.get() == 'province':
            return province_view(self.m, self.view_index.get())[3]
        if self.view_kind.get() == 'zone':
            return crop_view(self.m, self.view_index.get())[3]
        return ('bank $%02X CSV rows (%s)'
                % (self.current_bank(),
                   self._bank_provinces(self.m, self.current_bank())))

    def _refresh_all(self):
        self.sync_selector()
        self._subtitle_var().set(self._title())
        if self.view_kind.get() != 'raw':
            self.draw_grid()
        else:
            self.fill_raw_tree()
        self._update_brush_label()
        self._update_census()

    def _update_census(self):
        """Terrain histogram of the cells currently on screen."""
        m = self.m
        if self.view_kind.get() == 'raw':
            self._set_text(self.census, ['bank row view - no terrain histogram',
                                         '(heads, pads and filler are not '
                                          'terrain)'])
            return
        cols, rows, cells, _ = self._view_cells()
        counts, gaps, blocked, banks = {}, 0, 0, set()
        for y in range(rows):
            for x in range(cols):
                cell = cells[y][x]
                tile = self.get_byte(cell.bank, cell.offset)
                banks.add(cell.bank)
                if tile >= m.BLOCKED:
                    blocked += 1
                if cell.is_gap:
                    gaps += 1
                tid = m.tile_terrain(tile, self.tile_table)
                counts[tid] = counts.get(tid, 0) + 1
        total = cols * rows
        lines = ['%d cells (%d x %d) in bank %s, %d distinct tiles:'
                 % (total, cols, rows,
                    '/'.join('$%02X' % b for b in sorted(banks)),
                    len({self.get_byte(c.bank, c.offset)
                         for r in cells for c in r}))]
        for tid in sorted(counts):
            lines.append('  %-9s %4d  %5.1f%%  %s'
                         % (m.TERRAIN_NAMES.get(tid, '?'), counts[tid],
                            100.0 * counts[tid] / total,
                            '#' * max(1, counts[tid] // 8)))
        if gaps:
            lines.append('  %d cells sit on ribbon gap rows' % gaps)
        if blocked:
            lines.append('  %d blocked tiles (>= $80) read as Forest' % blocked)
        if self.facilities or self.castles:
            seen = {}
            for r in cells:
                for cc in r:
                    char = self._object_char(cc)
                    if not char:
                        continue
                    town = self._town(cc)
                    label = ('castle' if town and town[0] == 'castle' else
                             (self._facility_slot(cc) if town
                              else 'unpaired stamp'))
                    seen.setdefault(char, [label, 0])
                    seen[char][1] += 1
            if seen:
                lines.append('  towns as the game draws them (bank $31 tables): %s'
                             % ', '.join('%d %s=%s' % (n, ch, lab)
                                         for ch, (lab, n) in sorted(seen.items())))
        self._set_text(self.census, lines)

    def _view_cells(self):
        if self.view_kind.get() == 'province':
            return province_view(self.m, self.view_index.get())
        return crop_view(self.m, self.view_index.get())

    def draw_grid(self):
        m = self.m
        c = self.canvas
        c.delete('all')
        if self.view_kind.get() == 'raw':
            return
        s = self.cell
        cols, rows, cells, _ = self._view_cells()
        ox, oy = LABEL, LABEL
        w, h = ox + cols * s + 2, oy + rows * s + 2
        total_w, total_h = max(w, c.winfo_width()), max(h, c.winfo_height())
        c.configure(scrollregion=(0, 0, total_w, total_h))
        self.geom = {'ox': ox, 'oy': oy, 'cells': cells, 'w': total_w,
                     'h': total_h}
        grid = '#101010' if s >= 8 else ''   # outlines would eat a sub-8 px cell
        font = ('DejaVu Sans Mono', glyph_font(s))
        mark = max(1, s // 10)
        tiles = self._tiles_ready()
        for y in range(rows):
            for x in range(cols):
                cell = cells[y][x]
                tile = self.get_byte(cell.bank, cell.offset)
                x0, y0 = ox + x * s, oy + y * s
                if tiles:
                    c.create_image(x0 + s // 2, y0 + s // 2, anchor='center',
                                   image=self._tile_image(
                                       tile, s, self._cell_palette(cell)),
                                   tags='cell')
                else:
                    tid = m.tile_terrain(tile, self.tile_table)
                    colour = '#%02X%02X%02X' % m.TERRAIN_RGB.get(
                        tid, (0x80, 0x80, 0x80))
                    if cell.is_gap:
                        colour = '#404040'
                    if tile >= m.BLOCKED:
                        colour = '#FF00FF'
                    c.create_rectangle(x0, y0, x0 + s, y0 + s, fill=colour,
                                       outline=grid, width=1 if grid else 0,
                                       tags='cell')
                    # the classes view spells settlement objects out as letters
                    # (c/h/a/b/v); the real-tiles view draws their sprites instead
                    char = self._object_char(cell) or m.terrain_char(
                        tile, self.tile_table)
                    if (self.show_glyphs.get() and not cell.is_gap
                            and s >= GLYPH_MIN_PX):
                        c.create_text(x0 + s // 2, y0 + s // 2, text=char,
                                      fill='#000000' if tid in (1, 2, 8)
                                      else '#FFFFFF', font=font)
                base = self.stock.get(cell.bank)
                if (self.show_edits.get() and base is not None
                        and base[cell.offset] != tile):
                    c.create_rectangle(x0 + mark, y0 + mark, x0 + s - mark,
                                       y0 + s - mark, outline='#FFFF00',
                                       width=mark, tags='mark')
        # settlement objects: 16x16 OAM markers over the cell, as the game draws
        # them (the terrain byte under them is plain ground, never a building)
        if self.tiles is not None and self.tiles.available:
            for y in range(rows):
                for x in range(cols):
                    kind = self._object_marker(cells[y][x])
                    if kind:
                        c.create_image(ox + x * s + s // 2, oy + y * s + s // 2,
                                       anchor='center',
                                       image=self._marker_image(kind, s),
                                       tags='mark')
        # the rulers thin out as cells shrink so their digits never overlap
        every = 1 if s >= 16 else (2 if s >= 8 else 4)
        ruler = ('DejaVu Sans Mono', min(7, glyph_font(s)))
        for x in range(0, cols, every):
            c.create_text(ox + x * s + s // 2, LABEL // 2, text=str(x),
                          fill='#AAAAAA', font=ruler)
        for y in range(0, rows, every):
            c.create_text(LABEL // 2, oy + y * s + s // 2, text=str(y),
                          fill='#AAAAAA', font=ruler)
        if self.view_kind.get() == 'province':
            # where the four crops are spliced, and the province stronghold
            c.create_line(ox + m.GRID * s, oy, ox + m.GRID * s, oy + rows * s,
                          fill='#FFFFFF', dash=(4, 3))
            c.create_line(ox, oy + m.TOP_ROWS * s, ox + cols * s,
                          oy + m.TOP_ROWS * s, fill='#FFFFFF', dash=(4, 3))
            inset = max(2, s // 4)
            for y in range(rows):
                for x in range(cols):
                    cell = cells[y][x]
                    if m.tile_terrain(self.get_byte(cell.bank, cell.offset),
                                      self.tile_table) != 5:
                        continue
                    if self._object_marker(cell):
                        continue      # the castle marker already shows it
                    c.create_oval(ox + x * s + inset, oy + y * s + inset,
                                  ox + (x + 1) * s - inset,
                                  oy + (y + 1) * s - inset,
                                  outline='#FFFFFF', tags='mark')

    # -- bank row table --------------------------------------------------
    def fill_raw_tree(self):
        m = self.m
        bank = self.current_bank()
        self.tree.delete(*self.tree.get_children())
        for r in m.rows_from_bank(bank, bytes(self.banks[bank])):
            self.tree.insert('', 'end', iid=r['offset'], values=(
                r['offset'], r['kind'], r['zone'], r['province'], r['quadrant'],
                r['crop_row'],
                ' '.join('$%02X' % t for t in r['tiles'])))

    def edit_raw_row(self, event):
        """Double-click the tile column to paste the row's hex bytes."""
        if self.tree.identify_region(event.x, event.y) != 'cell':
            return
        item = self.tree.focus()
        if not item:
            return
        values = self.tree.item(item, 'values')
        if self.tree.identify_column(event.x) != '#7':
            messagebox.showinfo('Edit tiles',
                                'Double-click the last column (t0..t15).')
            return
        new = _ask_text(self, 'Bank $%02X row %s' % (self.current_bank(),
                                                     values[0]),
                        'Hex bytes ($44 / 44 / 0x44, 1-16 of them):', values[6])
        if new is None:
            return
        try:
            tiles = [self.m.parse_int(t)
                     for t in new.replace(',', ' ').split()]
        except ValueError:
            messagebox.showerror('Bad hex', 'could not parse: %s' % new)
            return
        if not 1 <= len(tiles) <= self.m.GRID:
            messagebox.showerror('Bad row', 'got %d bytes, need 1-%d'
                                 % (len(tiles), self.m.GRID))
            return
        self._push_undo()
        bank = self.current_bank()
        off = self.m.parse_int(values[0])
        self.banks[bank][off:off + len(tiles)] = bytes(tiles)
        self._dirty = True
        self.fill_raw_tree()
        self.log_line('bank $%02X row %s replaced (%d bytes)'
                      % (bank, values[0], len(tiles)))

    # -- palette ---------------------------------------------------------
    def _palette_values(self):
        """Every tile byte the banks can hold, grouped by terrain class."""
        m = self.m
        used = {}
        for bank in m.TERRAIN_BANKS:
            try:
                for tile in m.read_bank(bank):
                    used[tile] = used.get(tile, 0) + 1
            except OSError:
                pass
        by_terrain = {}
        for tile in range(m.BLOCKED):
            by_terrain.setdefault(m.tile_terrain(tile, self.tile_table),
                                  []).append(tile)
        items = []
        for tid in sorted(by_terrain):
            for tile in sorted(by_terrain[tid]):
                marks = []
                if tile == 0:
                    marks.append('blank tile - the ribbon gap value')
                if used.get(tile):
                    marks.append('%dx in banks' % used[tile])
                items.append(('%s $%02X  %s'
                              % (m.TERRAIN_NAMES.get(tid, '?'), tile,
                                 ' / '.join(marks)), tile))
        items.append(('Blocked $80-$FF  reads as Forest (no table lookup)', 0xFF))
        self._palette_map = items
        return [text for text, _ in items]

    def on_palette(self, event):
        self.brush.set(self._palette_map[self.palette.current()][1])
        self.brush_entry.delete(0, 'end')
        self.brush_entry.insert(0, '$%02X' % self.brush.get())
        self._update_brush_label()

    def apply_brush_entry(self):
        try:
            value = self.m.parse_int(self.brush_entry.get())
        except ValueError:
            value = -1
        if not 0 <= value <= 0xFF:
            messagebox.showerror('Bad brush', 'enter one hex byte, $00-$FF')
            return
        self.brush.set(value)
        self._update_brush_label()
        self.status.config(text='brush set to $%02X %s'
                           % (value,
                              self.m.terrain_name(value, self.tile_table)))

    def _update_brush_label(self):
        tile = self.brush.get()
        self._brush_label_var().set(
            '$%02X -> %s' % (tile, self.m.terrain_name(tile, self.tile_table)))

    # -- undo ------------------------------------------------------------
    def _snapshot(self):
        return {b: bytes(v) for b, v in self.banks.items()}

    def _push_undo(self):
        self.undo.append(self._snapshot())
        if len(self.undo) > MAX_UNDO:
            self.undo.pop(0)
        self.redo.clear()

    def undo_edit(self):
        if not self.undo:
            return
        self.redo.append(self._snapshot())
        self.banks = {b: bytearray(v) for b, v in self.undo.pop().items()}
        self._dirty = True
        self._refresh_all()

    def redo_edit(self):
        if not self.redo:
            return
        self.undo.append(self._snapshot())
        self.banks = {b: bytearray(v) for b, v in self.redo.pop().items()}
        self._dirty = True
        self._refresh_all()

    # -- file actions ----------------------------------------------------
    def save_csv(self, ask=False):
        """Write every bank's CSV twin (the editable link)."""
        written = []
        for bank in self.m.TERRAIN_BANKS:
            path = self.sources.get(bank) or self.m.csv_path(bank)
            if ask:
                path = None
            try:
                self.m.csv_write(path, self.m.rows_from_bank(
                    bank, bytes(self.banks[bank])))
            except (OSError, TypeError) as exc:
                messagebox.showerror('Cannot write CSV', str(exc))
                return None
            self.sources[bank] = path
            written.append(path)
        if not ask:
            self._dirty = False
            self.log_line('saved %d CSVs: %s' % (len(written), ', '.join(
                os.path.basename(p) for p in written)))
        return written

    def export_bin(self):
        bank = self.current_bank()
        path = filedialog.asksaveasfilename(
            title='Export bank $%02X as an 8KB image' % bank,
            defaultextension='.bin',
            initialfile='prg_%02x.bin' % bank,
            filetypes=[('binary', '*.bin')])
        if not path:
            return
        with open(path, 'wb') as f:
            f.write(bytes(self.banks[bank]))
        self.log_line('wrote %s (%d bytes)' % (path, self.m.BANK_SIZE))

    def write_asm(self):
        """CSVs are the source of truth: save them, then let the repo tools render.

        The generator/verifier stay the single rendering path so the GUI can
        never disagree with `make terrain-csv`.
        """
        if not self._repo_tools():
            return
        if self.save_csv() is None:
            return
        self._run([sys.executable, 'tools/gen_terrain_asm.py', '--bank', 'all',
                   '--from-csv', '--write'])
        self._run([sys.executable, 'tools/verify_terrain_banks.py', '--bank',
                   'all', '--against-csv', '--allow-edits'])

    def verify(self):
        if not self._repo_tools():
            return
        self._run([sys.executable, 'tools/verify_terrain_banks.py', '--bank',
                   'all', '--against-csv', '--allow-edits'])

    def _repo_tools(self):
        tools = os.path.join(self.m.ROOT, 'tools')
        if not os.path.exists(os.path.join(tools, 'gen_terrain_asm.py')):
            messagebox.showinfo(
                'Standalone mode',
                'The disassembly repo tools are not next to this model copy,\n'
                'so the assembly cannot be regenerated from here.\n'
                'Save the CSVs (or export the bins) and run\n'
                '  python3 tools/gen_terrain_asm.py --bank all --from-csv --write\n'
                'in the repo.')
            return False
        return True

    def _run(self, argv):
        self.log_line('$ ' + ' '.join(argv))
        try:
            r = subprocess.run(argv, cwd=self.m.ROOT, capture_output=True,
                               text=True)
        except OSError as exc:
            self.log_line('failed to run: %s' % exc)
            return
        for line in ((r.stdout or '') + (r.stderr or '')).strip().splitlines():
            self.log_line(line)
        self.log_line('[exit %d]' % r.returncode)

    # -- misc ------------------------------------------------------------
    def _set_text(self, widget, lines):
        widget.config(state='normal')
        widget.delete('1.0', 'end')
        for line in lines:
            widget.insert('end', line + '\n')
        widget.config(state='disabled')

    def log_line(self, line):
        self.log.config(state='normal')
        self.log.insert('end', line + '\n')
        self.log.see('end')
        self.log.config(state='disabled')

    def _confirm_discard(self):
        if not self._dirty:
            return True
        return messagebox.askyesno('Unsaved edits',
                                   'Discard the edits that are not in the CSVs?')

    def on_close(self):
        if self._confirm_discard():
            self.destroy()


def _ask_text(parent, title, prompt, initial):
    """Minimal wrapper so the import stays lazy for the headless checks."""
    from tkinter import simpledialog
    return simpledialog.askstring(title, prompt, initialvalue=initial,
                                  parent=parent)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--csv', help='one bank CSV to open at start')
    ap.add_argument('--rom', help='one raw 8KB bank image to open at start')
    ap.add_argument('--model', help='directory holding terrain_model.py')
    args = ap.parse_args()
    model, _dir = load_model(args.model)
    app = TacticalMapEditor(model, csv_path=args.csv, rom_path=args.rom)
    app.mainloop()


if __name__ == '__main__':
    main()
