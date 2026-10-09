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
            `$03`'s leading unanalysed data are reachable too.

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

CELL = 20                    # grid cell edge in px
LABEL = 26                   # left/top ruler width/height
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
    """Province name from docs/province_names.csv when the repo is present."""
    if prov in _PROVINCE_NAMES:
        return _PROVINCE_NAMES[prov]
    path = os.path.join(m.ROOT, 'docs', 'province_names.csv')
    name = 'id %d' % prov
    if os.path.exists(path):
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
        self.tile_table = model.TILE_TERRAIN_TABLE
        self._dragging = False
        self._dirty = False
        self._selector_cache = {}        # view kind -> dropdown entries
        self._build_ui()
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

        body = ttk.Panedwindow(self, orient='horizontal')
        body.pack(side='top', fill='both', expand=True, padx=6, pady=4)
        left = ttk.Frame(body)
        right = ttk.Frame(body, width=340)
        body.add(left, weight=3)
        body.add(right, weight=1)

        self.canvas = tk.Canvas(left, bg='#202020', highlightthickness=0)
        self.hscroll = ttk.Scrollbar(left, orient='horizontal',
                                     command=self.canvas.xview)
        self.canvas.configure(xscrollcommand=self.hscroll.set)
        self.canvas.pack(side='top', fill='both', expand=True)
        self.hscroll.pack(side='bottom', fill='x')
        self.canvas.bind('<Button-1>', self.on_press)
        self.canvas.bind('<B1-Motion>', self.on_drag)
        self.canvas.bind('<ButtonRelease-1>', self.on_release)
        self.canvas.bind('<Motion>', self.on_motion)
        self.canvas.bind('<Configure>', lambda e: self.draw_grid())

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
        col = int((x - geom['ox']) // CELL)
        row = int((y - geom['oy']) // CELL)
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

        Provinces are named from docs/province_names.csv, which makes switching
        obvious: `17  荆州 (ショウシュウ)` instead of a bare number.
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

    def select_by_digit(self, digit):
        """Keys 0-9 jump straight to provinces 0-9 (the rest: dropdown)."""
        focus = self.focus_get()
        if isinstance(focus, (tk.Entry, tk.Text, ttk.Entry, ttk.Combobox)):
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

    def _on_view_kind(self):
        kind = self.view_kind.get()
        if self.view_index.get() >= self.index_limit():
            self.view_index.set(0)
        if kind == 'raw':
            self.canvas.pack_forget()
            self.hscroll.pack_forget()
            self.tree.pack(side='top', fill='both', expand=True)
        else:
            self.tree.pack_forget()
            self.canvas.pack(side='top', fill='both', expand=True)
            self.hscroll.pack(side='bottom', fill='x')
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
        self._set_text(self.census, lines)

    def _view_cells(self):
        if self.view_kind.get() == 'province':
            return province_view(self.m, self.view_index.get())[:3]
        return crop_view(self.m, self.view_index.get())[:3]

    def draw_grid(self):
        m = self.m
        c = self.canvas
        c.delete('all')
        if self.view_kind.get() == 'raw':
            return
        cols, rows, cells, _ = self._view_cells()
        ox, oy = LABEL, LABEL
        w = ox + cols * CELL + 2
        h = oy + rows * CELL + 2
        c.configure(scrollregion=(0, 0, max(w, c.winfo_width()),
                                  max(h, c.winfo_height())))
        self.geom = {'ox': ox, 'oy': oy, 'cells': cells}
        for y in range(rows):
            for x in range(cols):
                cell = cells[y][x]
                tile = self.get_byte(cell.bank, cell.offset)
                tid = m.tile_terrain(tile, self.tile_table)
                colour = '#%02X%02X%02X' % m.TERRAIN_RGB.get(
                    tid, (0x80, 0x80, 0x80))
                if cell.is_gap:
                    colour = '#404040'
                if tile >= m.BLOCKED:
                    colour = '#FF00FF'
                x0, y0 = ox + x * CELL, oy + y * CELL
                c.create_rectangle(x0, y0, x0 + CELL, y0 + CELL,
                                   fill=colour, outline='#101010', width=1,
                                   tags='cell')
                if self.show_glyphs.get() and not cell.is_gap:
                    c.create_text(x0 + CELL // 2, y0 + CELL // 2,
                                  text=m.terrain_char(tile, self.tile_table),
                                  fill='#000000' if tid in (1, 2, 8)
                                  else '#FFFFFF',
                                  font=('DejaVu Sans Mono', 8))
                base = self.stock.get(cell.bank)
                if (self.show_edits.get() and base is not None
                        and base[cell.offset] != tile):
                    c.create_rectangle(x0 + 1, y0 + 1, x0 + CELL - 1,
                                       y0 + CELL - 1, outline='#FFFF00',
                                       width=2, tags='mark')
        for x in range(cols):
            c.create_text(ox + x * CELL + CELL // 2, LABEL // 2, text=str(x),
                          fill='#AAAAAA', font=('DejaVu Sans Mono', 7))
        for y in range(rows):
            c.create_text(LABEL // 2, oy + y * CELL + CELL // 2, text=str(y),
                          fill='#AAAAAA', font=('DejaVu Sans Mono', 7))
        if self.view_kind.get() == 'province':
            # where the four crops are spliced, and the province stronghold
            c.create_line(ox + m.GRID * CELL, oy, ox + m.GRID * CELL,
                          oy + rows * CELL, fill='#FFFFFF', dash=(4, 3))
            c.create_line(ox, oy + m.TOP_ROWS * CELL, ox + cols * CELL,
                          oy + m.TOP_ROWS * CELL, fill='#FFFFFF', dash=(4, 3))
            for y in range(rows):
                for x in range(cols):
                    cell = cells[y][x]
                    if m.tile_terrain(self.get_byte(cell.bank, cell.offset),
                                      self.tile_table) == 5:
                        c.create_oval(ox + x * CELL + 5, oy + y * CELL + 5,
                                      ox + x * CELL + CELL - 5,
                                      oy + y * CELL + CELL - 5,
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
