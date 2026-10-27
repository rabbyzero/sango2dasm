#!/usr/bin/env python3
"""End-to-end checks for the terrain pipeline: ROM <-> CSV <-> asm <-> GUI.

The tactical maps live in FOUR data banks (`$00/$03/$04/$05`) that together hold
120 quadrant crops for all 30 provinces. This harness proves the whole editing
loop is lossless across every one of them.

Run it after touching tools/terrain_model.py, tools/gen_terrain_asm.py,
tools/verify_terrain_banks.py or editor/tactical_map_editor.py:

    python3 tools/check_terrain_pipeline.py

Proves, in order:

  1. the model's three driver-table copies still match bank `$08`
     (TileTerrainTable $B74B, TerrainMapPtrTable $B7CB, TileBankTable $B8BB);
  2. for each bank the owner region walk tiles all 8192 bytes exactly once and
     the kinds total to the physical layout;
  3. per bank ROM -> rows -> bank and ROM -> CSV -> bank and ROM -> asm hex ->
     bank are all the identity;
  4. the four generated asm files assemble byte-exact (verify_terrain_banks.py);
  5. an intentional edit in a NON-$00 bank survives the whole loop: CSV edit ->
     regenerate asm -> assemble -> decode back, and is reported by name;
  6. all 30 provinces address bytes across the four banks (the four provinces
     straddling a bank seam included), and every province keeps a Castle;
  7. the GUI's view builders address the same bytes as the model, its selector
     lists all 30 provinces, every `self.<attribute>` it reads is defined, the
     view tuple its canvas unpacks is the one it asks for, the town overlay
     follows the bank `$31` marker tables rather than the crop bytes, and the
     zoom arithmetic (pixel->cell hit test, fit, scroll clamp) holds at 6-96 px;
  8. the editor still runs in standalone mode, i.e. with only a copy of the
     model codec and a CSV next to it and no disassembly repo around;
  9. the real-tile render mode's chain holds: MetaTileData is read from $F477,
     every tile byte the banks can hold decodes to a 16x16 RGB cell, blocked
     bytes stay unrenderable, and the mode degrades instead of crashing when
     the ROM dumps are missing; and the two bank `$31` tables that place the
     buildings hold their documented shape - $9D58 is each province's $61 castle
     cell, the $9BA4 pairs are the 67 towns, and the marker rows skip $0F.

The GUI is imported with a stubbed `tkinter`, so this needs no display.
"""
import ast
import os
import re
import struct
import subprocess
import sys
import types

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(ROOT, 'editor'))

import terrain_model as model                    # noqa: E402

FAILED = []


def check(label, condition, detail=''):
    print('  %-58s %s%s' % (label, 'ok' if condition else 'FAIL',
                            (' - ' + detail) if detail else ''))
    if not condition:
        FAILED.append(label)
    return condition


def section(title):
    print('%s' % title)


# --- 1 driver tables ----------------------------------------------------
def test_driver_tables():
    section('1. terrain vocabulary and driver tables')
    live = model.load_driver_tables()
    if check('three driver tables read from rom/prg/prg_08.bin', live is not None):
        tt, ptr, bank = live
        check('TILE_TERRAIN_TABLE == bank $08 $B74B',
              tt == model.TILE_TERRAIN_TABLE)
        check('TERRAIN_MAP_PTR == bank $08 $B7CB (120 zones)',
              ptr == model.TERRAIN_MAP_PTR and len(ptr) == model.ZONE_COUNT)
        check('TILE_BANK_TABLE == bank $08 $B8BB (120 zones)',
              bank == model.TILE_BANK_TABLE and len(bank) == model.ZONE_COUNT)
    check('120 zones / 30 provinces / 4 banks',
          model.ZONE_COUNT == 120 and model.PROVINCES == 30
          and model.TERRAIN_BANKS == (0x00, 0x03, 0x04, 0x05))
    # every zone resolves to a bank that actually carries it
    check('every zone maps to one of the four terrain banks',
          all(model.zone_bank(z) in model.TERRAIN_BANKS
              for z in range(model.ZONE_COUNT)))


# --- 2 region walk per bank --------------------------------------------
def test_regions():
    section('2. owner region walk tiles every bank once')
    for bank in model.TERRAIN_BANKS:
        offs = []
        for reg in model.regions(bank):
            offs += range(reg.start, reg.end)
        kinds = {}
        for reg in model.regions(bank):
            kinds[reg.kind] = kinds.get(reg.kind, 0) + reg.length
        crop = sum(model.CROP_BYTES for _ in model.bank_zones(bank))
        check('bank $%02X: 8192 bytes owned exactly once' % bank,
              len(offs) == model.BANK_SIZE
              and len(set(offs)) == model.BANK_SIZE
              and offs == sorted(offs)
              and offs[0] == 0 and offs[-1] == model.BANK_SIZE - 1,
              str(kinds))
        # crops + pads + heads + sound streams + filler make the whole bank
        check('bank $%02X: region kinds total the bank size' % bank,
              sum(kinds.values()) == model.BANK_SIZE
              and kinds.get('crop', 0) <= crop, str(kinds))


# --- 3 lossless round trips --------------------------------------------
def decode_asm(bank, text):
    """Read generated .byte rows back into one 8KB image (offset-keyed)."""
    data = bytearray(b'\xFF' * model.BANK_SIZE)
    for line in text.splitlines():
        m = re.match(r'^  \.byte (.*); \$(\w{4})', line)
        if not m:
            continue
        off = int(m.group(2), 16) - model.WINDOW_CPU
        tiles = [int(x, 16) for x in re.findall(r'\$([0-9A-Fa-f]{2})',
                                                m.group(1))]
        data[off:off + len(tiles)] = bytes(tiles)
    return bytes(data)


def test_lossless():
    section('3. ROM <-> rows <-> CSV <-> hex is lossless (all banks)')
    tmp = os.path.join(ROOT, 'build', '_pipeline.csv')
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    for bank in model.TERRAIN_BANKS:
        data = model.read_bank(bank)
        rows = model.rows_from_bank(bank, data)
        check('bank $%02X rows -> bank reproduces the ROM' % bank,
              model.bank_from_rows(bank, rows) == data,
              '%d rows' % len(rows))
        model.csv_write(tmp, rows)
        check('bank $%02X csv -> parse -> bank reproduces the ROM' % bank,
              model.bank_from_rows(bank, model.csv_read(tmp, bank)) == data)
        check('bank $%02X asm .byte lines decode back to the ROM' % bank,
              decode_asm(bank, model.asm_text(bank, rows, 'pipeline test'))
              == data)
    os.remove(tmp)


# --- 4 the real assembler ----------------------------------------------
def test_assembler():
    section('4. the four terrain asm files assemble byte-exact')
    r = subprocess.run([sys.executable, 'tools/verify_terrain_banks.py',
                        '--bank', 'all'],
                       cwd=ROOT, capture_output=True, text=True)
    out = (r.stdout or '') + (r.stderr or '')
    check('verify_terrain_banks.py --bank all exits 0', r.returncode == 0,
          out.strip().splitlines()[-1] if out.strip() else '')
    for bank in model.TERRAIN_BANKS:
        check('bank $%02X byte-exact vs its ROM' % bank,
              'byte-exact vs rom/prg/prg_%02x.bin' % bank in out)
    check('in-tree asm hex matches the ROM for every bank',
          all(decode_asm(b, open(model.asm_path(b), encoding='utf-8').read())
              == model.read_bank(b) for b in model.TERRAIN_BANKS))


# --- 5 an edit in a non-$00 bank round-trips and is named --------------
def test_edit_roundtrip():
    section('5. edited terrain in a non-$00 bank round-trips through the loop')
    prov = 20                              # lives in bank $04, straddles nothing
    bank = model.zone_bank(prov * 4)
    check('province 20 sits in bank $%02X (not $00)' % bank, bank != 0x00)
    # pick the first authored cell that is not already a Castle
    target = None
    for line in model.province_cells(prov):
        for _x, _y, zone, obank, row, off in line:
            if model.tile_terrain(model.read_bank(obank)[off]) != 5:
                target = (zone, obank, row, off)
                break
        if target:
            break
    zone, obank, row, col_off = target
    col = col_off - model.zone_offset(zone) - row * model.GRID
    data = bytearray(model.read_bank(obank))
    data[col_off] = 0x61                    # a Castle where there was not one
    print('    cell: bank $%02X offset $%04X province %d crop row %d col %d'
          ' -> $61 Castle' % (obank, col_off, prov, row, col))
    csv_path = os.path.join(ROOT, 'build', '_pipeline_edit.csv')
    asm_path = os.path.join(ROOT, 'build', '_pipeline_edit.asm')
    model.csv_write(csv_path, model.rows_from_bank(obank, bytes(data)))
    subprocess.run([sys.executable, 'tools/gen_terrain_asm.py', '--bank',
                    '%02x' % obank, '--from-csv', '--csv', csv_path,
                    '--asm', asm_path, '--write'],
                   cwd=ROOT, capture_output=True, text=True)
    r = subprocess.run([sys.executable, 'tools/verify_terrain_banks.py',
                        '--bank', '%02x' % obank, '--asm', asm_path,
                        '--allow-edits'],
                       cwd=ROOT, capture_output=True, text=True)
    out = (r.stdout or '') + (r.stderr or '')
    check('regenerated asm reassembles to the edited bytes',
          decode_asm(obank, open(asm_path, encoding='utf-8').read())
          == bytes(data))
    check('verifier accepts the edit under --allow-edits', r.returncode == 0,
          out.strip().splitlines()[-1] if out.strip() else '')
    check('the diff is named in terrain terms (province/quadrant/row/col)',
          'province %d' % prov in out and 'crop row %d' % row in out
          and 'Castle' in out,
          next((ln.strip() for ln in out.splitlines()
                if 'province %d' % prov in ln and 'crop row' in ln), 'no line'))
    check('structure gate flags the extra Castle as a warning',
          'province %d has 2 Castle cells' % prov in out)
    for path in (csv_path, asm_path, asm_path.replace('.asm', '.o')):
        if os.path.exists(path):
            os.remove(path)


# --- 6 all 30 provinces across the four banks --------------------------
def test_all_provinces():
    section('6. all 30 provinces address bytes across the four banks')
    images = {b: model.read_bank(b) for b in model.TERRAIN_BANKS}

    def get_byte(bank, off):
        return images[bank][off]

    banks_used = set()
    ok_offsets = True
    castles_ok = True
    for prov in range(model.PROVINCES):
        banks_used.add(model.zone_bank(prov * 4))
        for line in model.province_cells(prov):
            for _x, _y, _zone, bank, _row, off in line:
                if not 0 <= off < model.BANK_SIZE or images[bank][off] is None:
                    ok_offsets = False
        castles = sum(1 for row in model.province_map(get_byte, prov)
                      for tile in row if model.tile_terrain(tile) == 5)
        if castles != 1:
            castles_ok = False
    check('the 30 provinces span all four terrain banks',
          banks_used == set(model.TERRAIN_BANKS),
          ', '.join('$%02X' % b for b in sorted(banks_used)))
    check('every authored cell addresses a byte inside its bank', ok_offsets)
    check('every province 0-29 keeps exactly one Castle cell', castles_ok)
    # bank seams: a bank must hold whole provinces (all 4 crops of a province)
    check('no province straddles two banks (all four crops share a bank)',
          all(len({model.zone_bank(z) for z in model.province_zones(p)}) == 1
              for p in range(model.PROVINCES)))


# --- 7 the GUI addresses the same bytes --------------------------------
def test_gui_views():
    section('7. editor view builders agree with the model')
    stub_tkinter()
    import tactical_map_editor as gui
    images = {b: model.read_bank(b) for b in model.TERRAIN_BANKS}

    # a $00 province and a later-bank province address the same bytes
    for prov in (3, 20):
        cols, rows, cells, title = gui.province_view(model, prov)
        check('province %d view is 32 x 20 (bank $%02X)'
              % (prov, model.zone_bank(prov * 4)),
              (cols, rows) == (model.MAP_COLS, model.MAP_H), title)
        grid = model.province_map(lambda b, o: images[b][o], prov)
        check('province %d view tiles == model.province_map' % prov,
              all(images[c.bank][c.offset] == grid[y][x]
                  for y in range(rows) for x, c in enumerate(cells[y])))

    cols, rows, cells, title = gui.crop_view(model, 5)
    check('crop view is 16 x 16', (cols, rows) == (model.GRID, model.GRID), title)
    check('crop rows 9-15 alias the next crop (overlap resolved)',
          all(cells[12][x].offset == model.zone_offset(6) + 3 * model.GRID + x
              for x in range(model.GRID)))
    check('crop rows 0-8 stay in their own window',
          all(cells[2][x].offset == model.zone_offset(5) + 2 * model.GRID + x
              for x in range(model.GRID)))

    names = [gui.province_name(model, i) for i in (0, 15, 29)]
    check('province names resolve for first/middle/last',
          all(n and 'id ' not in n for n in names), ' / '.join(names))
    check_editor_attributes(gui)
    check_selector(gui)
    check_view_cells(gui)
    check_town_markers(gui)
    check_zoom(gui)


class _Var:
    """Stand-in for a tk.StringVar so a method can run without a display."""

    def __init__(self, value):
        self.value = value

    def get(self):
        return self.value


def check_selector(gui):
    """The province/crop/bank dropdown lists, built on a bare instance."""
    app = gui.TacticalMapEditor.__new__(gui.TacticalMapEditor)
    app.m = model
    app.banks = {b: bytearray(model.read_bank(b)) for b in model.TERRAIN_BANKS}
    app._selector_cache = {}
    expect = {
        'province': (model.PROVINCES, '青州', 'Province'),
        'zone': (model.ZONE_COUNT, 'prov  1', 'Crop zone'),
        'raw': (len(model.TERRAIN_BANKS), 'bank $03', 'Terrain bank'),
    }
    for kind, (count, sample, label) in expect.items():
        app.view_kind = _Var(kind)
        values = app.selector_values()
        check('%s dropdown lists %d named entries' % (kind, count),
              len(values) == count and values[0].strip() != ''
              and any(sample in v for v in values),
              next((v for v in values if sample in v), ''))
        check('%s view: index_limit and selector label agree' % kind,
              app.index_limit() == count
              and gui.TacticalMapEditor.SELECTOR_TITLE[kind] == label)
    # the province dropdown must reach all 30, not just the first bank
    app.view_kind = _Var('province')
    provs = app.selector_values()
    check('province dropdown is 30 entries (0-29), one per map',
          len(provs) == 30 and any('17' in v for v in provs), provs[17])


def check_view_cells(gui):
    """The arity contract draw_grid()/_update_census() rely on at launch.

    A headless build cannot paint the canvas, so unpack _view_cells() the same
    way its callers do; that is what catches a truncated view tuple without a
    human having to launch the GUI to find the crash.
    """
    app = gui.TacticalMapEditor.__new__(gui.TacticalMapEditor)
    app.m = model
    for kind, index in (('province', 0), ('province', model.PROVINCES - 1),
                        ('zone', 0), ('zone', model.ZONE_COUNT - 1)):
        app.view_kind = _Var(kind)
        app.view_index = _Var(index)
        label = '%s %s view' % (kind, index)
        try:
            cols, rows, cells, title = app._view_cells()
        except ValueError as exc:
            check('%s unpacks into the 4 values its callers expect' % label,
                  False, str(exc))
            continue
        check('%s: %d x %d tiles addressed, titled' % (label, cols, rows),
              len(cells) == rows and all(len(r) == cols for r in cells)
              and bool(title), title)


def check_town_markers(gui):
    """The overlay follows the bank $31 tables, not the $61/$79/$7A/$7B bytes.

    12 of the 67 town pairs have no stamp in the crops, so a byte-keyed overlay
    drops towns the console really draws; these are the cells the editor must show.
    """
    import terrain_tiles as tiles
    app = gui.TacticalMapEditor.__new__(gui.TacticalMapEditor)
    app.m = model
    app.banks = {b: bytearray(model.read_bank(b)) for b in model.TERRAIN_BANKS}
    app.tile_codec = tiles
    app.facilities = model.load_facilities()
    app.castles = model.load_castles()
    app.render_mode = _Var('tile')
    app.show_objects = _Var(True)
    wrong, unstamped, orphan = [], 0, 0
    for prov in range(model.PROVINCES):
        app.view_kind, app.view_index = _Var('province'), _Var(prov)
        cols, rows, cells, _ = app._view_cells()
        grid = model.province_map(lambda b, o: app.banks[b][o], prov)
        drawn = {(c.col, c.row) for r in cells for c in r if app._object_marker(c)}
        expect = {app.castles[prov]} | {p for p in app.facilities[prov] if p}
        if drawn != expect:
            wrong.append('prov %d: drew %s, tables say %s'
                         % (prov, sorted(drawn), sorted(expect)))
        unstamped += sum(1 for x, y in expect if grid[y][x] not in tiles.OBJECT_TILES)
        orphan += sum(1 for y in range(rows) for x in range(cols)
                      if grid[y][x] in tiles.OBJECT_TILES and (x, y) not in expect)
    check('province overlay == the $9D58/$9BA4 marker cells (all 30)',
          not wrong, wrong[0] if wrong else '')
    check('the 12 unstamped towns draw and the 2 unpaired stamps do not',
          unstamped == 12 and orphan == 2,
          '%d marker cells with no stamp, %d stamps with no marker'
          % (unstamped, orphan))
    app.render_mode = _Var('class')
    letters = []
    for prov in range(model.PROVINCES):
        app.view_kind, app.view_index = _Var('province'), _Var(prov)
        cols, rows, cells, _ = app._view_cells()
        for r in cells:
            for c in r:
                town = app._town(c)
                if town and app._object_char(c) not in 'cahb':
                    letters.append('prov %d cell (%d,%d) -> %r'
                                   % (prov, c.col, c.row, app._object_char(c)))
    check('every table marker gets a classes-view letter', not letters,
          letters[0] if letters else '')


def check_zoom(gui):
    """Zoom is pure arithmetic, so its hit-test contract checks without a screen.

    Painting resolves a pixel back to a cell, so a scale that drifts that
    inverse would silently write the wrong bank byte. These are the invariants
    the GUI relies on at every cell edge it can be zoomed to.
    """
    bad = ['%d px: x=%d -> col %d, want %d' % (s, gui.LABEL + col * s + s // 2,
                                               gui.cell_at(gui.LABEL + col * s
                                                           + s // 2,
                                                           gui.LABEL, s), col)
           for s in range(gui.CELL_MIN, gui.CELL_MAX + 1)
           for col in (0, 1, 15, 16, 31)
           if gui.cell_at(gui.LABEL + col * s + s // 2, gui.LABEL, s) != col]
    check('pixel->cell hit test exact at every zoom level (%d-%d px)'
          % (gui.CELL_MIN, gui.CELL_MAX), not bad, bad[0] if bad else '')

    fits = all(gui.fit_cell(c, r, w, h) * c + gui.LABEL <= w
               and gui.fit_cell(c, r, w, h) * r + gui.LABEL <= h
               for c, r in ((model.MAP_COLS, model.MAP_H), (model.GRID,
                                                            model.GRID))
               for w, h in ((400, 300), (700, 430), (1200, 900)))
    check('fit_cell never asks for more than the pane holds', fits)
    check('fit_cell stays inside the clamp',
          gui.fit_cell(32, 20, 120, 120) == gui.CELL_MIN
          and gui.fit_cell(32, 20, 100000, 100000) == gui.CELL_MAX)

    fracs = [gui.scroll_frac(o, 1948, 700) for o in (-500, 0, 600, 1248, 5000)]
    check('scroll fractions clamp to the scrollable span',
          fracs[0] == 0.0 and fracs[1] == 0.0 and abs(fracs[2] - 0.4808) < 1e-3
          and fracs[3] == 1.0 and fracs[4] == 1.0, str(fracs))

    notches = [(types.SimpleNamespace(num=n, delta=d), want)
               for n, d, want in ((4, 0, 1), (5, 0, -1), (None, 120, 1),
                                  (None, -120, -1), (None, 0, 0))]
    check('wheel notches read the same on X11 and Windows/mac',
          all(gui.wheel_steps(e) == want for e, want in notches))
    check('glyph size stays bounded and grows with the cell',
          all(6 <= gui.glyph_font(s) <= 16 for s in range(1, 200))
          and gui.glyph_font(8) <= gui.glyph_font(20) <= gui.glyph_font(96))


# Methods inherited from tkinter.Tk / standard widget API, so they are not
# assigned anywhere in the editor source but are still valid `self.<name>` reads.
TK_BASE_API = {'title', 'geometry', 'protocol', 'bind', 'destroy', 'mainloop',
               'winfo_width', 'winfo_height', 'winfo_children', 'config',
               'focus_get', 'pack', 'grid', 'place'}


def check_editor_attributes(gui):
    """Every self.<attr> the widget code reads must be assigned or inherited.

    A headless test cannot build the UI, so this AST audit stands in for the
    AttributeError a real launch would raise (a button wired to a method name
    that does not exist, a widget stored under one name and read under another).
    """
    path = os.path.join(ROOT, 'editor', 'tactical_map_editor.py')
    tree = ast.parse(open(path, encoding='utf-8').read(), path)
    defined, reads = set(), {}
    for cls in [n for n in tree.body if isinstance(n, ast.ClassDef)]:
        for stmt in cls.body:
            if isinstance(stmt, (ast.FunctionDef, ast.AsyncFunctionDef)):
                defined.add(stmt.name)
            elif isinstance(stmt, ast.Assign):
                for target in stmt.targets:
                    if isinstance(target, ast.Name):
                        defined.add(target.id)   # class attribute
        for node in ast.walk(cls):
            if (isinstance(node, ast.Attribute)
                    and isinstance(node.value, ast.Name)
                    and node.value.id == 'self'):
                if isinstance(node.ctx, ast.Store):
                    defined.add(node.attr)
                else:
                    reads.setdefault(node.attr, node.lineno)
    missing = {k: v for k, v in reads.items()
               if k not in defined and k not in TK_BASE_API}
    check('editor has no unresolved self attribute (%d reads)' % len(reads),
          not missing,
          '; '.join('self.%s at line %d' % (k, v)
                    for k, v in sorted(missing.items(), key=lambda x: x[1])))


def stub_tkinter():
    """Replace tkinter with attribute-absorbing dummies so the import works."""
    class Dummy:
        def __init__(self, *a, **k):
            pass

        def __getattr__(self, name):
            return Dummy()

        def __call__(self, *a, **k):
            return Dummy()

    if 'tkinter' in sys.modules and isinstance(sys.modules['tkinter'], Dummy):
        return
    tk_stub = types.ModuleType('tkinter')
    for name in ('Tk', 'Canvas', 'StringVar', 'IntVar', 'BooleanVar', 'Text'):
        setattr(tk_stub, name, Dummy)
    for name in ('filedialog', 'messagebox', 'ttk', 'simpledialog'):
        sub = types.ModuleType('tkinter.' + name)
        sub.__getattr__ = lambda attr: Dummy()
        setattr(tk_stub, name, sub)
        sys.modules['tkinter.' + name] = sub
    sys.modules['tkinter'] = tk_stub


def test_standalone():
    section('8. editor standalone mode (model copy + CSV only)')
    import shutil
    sandbox = os.path.join(ROOT, 'build', '_standalone')
    os.makedirs(sandbox, exist_ok=True)
    shutil.copy(os.path.join(HERE, 'terrain_model.py'),
                os.path.join(sandbox, 'terrain_model.py'))
    stub_tkinter()
    import tactical_map_editor as gui
    saved_path = list(sys.path)
    saved_module = sys.modules.pop('terrain_model', None)
    try:
        solo, _root = gui.load_model(sandbox)
    finally:
        sys.path[:] = saved_path
        sys.modules.pop('terrain_model', None)
        if saved_module is not None:
            sys.modules['terrain_model'] = saved_module
    check('load_model() accepts a bare model copy', solo is not None
          and os.path.dirname(solo.__file__) == sandbox)
    check('no ROM in the sandbox -> read_bank() raises OSError',
          _raises_oserror(lambda: solo.read_bank(0)))
    check('no bank $08 in the sandbox -> driver-table loader returns None',
          solo.load_driver_tables() is None)
    csv_copy = os.path.join(sandbox, 'terrain.csv')
    shutil.copy(model.csv_path(0), csv_copy)
    rows = solo.csv_read(csv_copy, 0)
    check('CSV alone is a complete editing surface (%d rows)' % len(rows),
          solo.bank_from_rows(0, rows) == model.read_bank(0))
    solo.csv_write(csv_copy, rows)
    check('CSV rewrite from the sandbox stays lossless',
          solo.bank_from_rows(0, solo.csv_read(csv_copy, 0)) == model.read_bank(0))
    shutil.rmtree(sandbox)


def test_tile_graphics():
    section('9. real CHR tile graphics (MetaTileData + display record 1)')
    import shutil
    import terrain_tiles as tiles
    set_ = tiles.load()
    check('tile graphics load from the repo ROM dumps', set_.available,
          set_.summary())

    with open(os.path.join(ROOT, 'rom', 'prg', 'prg_1f.bin'), 'rb') as f:
        f.seek(tiles.METATILE_CPU - tiles.PRG_1F_WINDOW)
        raw = f.read(tiles.METATILE_BYTES)
    check('MetaTileData is read as 128 entries x 4 bytes from $%04X'
          % tiles.METATILE_CPU,
          bytes(set_.metatile) == raw and len(raw) == tiles.METATILE_BYTES)
    check('a known tile byte maps to its 4 nametable bytes',
          list(set_.metatile_bytes(0x39)) == [0x22, 0x23, 0x32, 0x33],
          ' '.join('$%02X' % b for b in set_.metatile_bytes(0x39)))

    bad = [t for t in range(model.BLOCKED)
           if (lambda c: c is None or len(c) != tiles.CELL_PX
               or any(len(r) != tiles.CELL_PX or any(len(px) != 3 for px in r)
                      for r in c))(set_.cell_rgb(t))]
    check('all 128 tile bytes render as a 16x16 RGB cell', not bad, str(bad[:6]))
    check('cell_rgb honours the BG sub-palette',
          set_.cell_rgb(0x02, 0) != set_.cell_rgb(0x02, 1))
    check('the tactical palette record is $%02X (gold land, blue water)'
          % tiles.PALETTE_RECORD, tiles.PALETTE_RECORD == 1)

    # Colour correctness, as an invariant over the authored data: the attribute
    # head in front of each crop must say sub-palette 1 for River and 0 for
    # every other class. This is what makes the tile render match the manual.
    images = {b: model.read_bank(b) for b in model.TERRAIN_BANKS}
    wrong = []
    for prov in range(model.PROVINCES):
        for cy in range(model.MAP_H):
            for cx in range(model.MAP_COLS):
                zone = (prov * 4 + (0 if cy < model.TOP_ROWS else 1)
                        + (2 if cx >= model.GRID else 0))
                gx = cx % model.GRID
                gy = cy if cy < model.TOP_ROWS else cy - model.TOP_ROWS
                bank = model.zone_bank(zone)
                off = model.zone_offset(zone)
                data = images[bank]
                tid = model.tile_terrain(data[off + gy * model.GRID + gx],
                                         model.TILE_TERRAIN_TABLE)
                got = tiles.head_palette(data[off - tiles.HEAD_BYTES:off], gx, gy)
                if got != (1 if tid == 3 else 0):
                    wrong.append((prov, cx, cy, tid, got))
    check('attribute head = River -> sub-palette 1, all other classes -> 0 '
          'over %d cells' % (model.PROVINCES * model.MAP_H * model.MAP_COLS),
          not wrong, '%d mismatches, first %s' % (len(wrong), wrong[:3]))
    check('blocked bytes have no entry (the engine never looks one up)',
          all(set_.metatile_bytes(t) is None for t in (0x80, 0xFE, 0xFF)))

    used = set()
    for bank in model.TERRAIN_BANKS:
        for zone in model.bank_zones(bank):
            for row in model.zone_grid(lambda b, o: model.read_bank(b)[o], zone):
                used.update(row)
    check('every tile byte in the 120 crops renders (%d distinct bytes)'
          % len(used),
          all(set_.cell_rgb(t) is not None for t in used if t < model.BLOCKED))
    check('the blocked bytes present in the banks stay unrenderable',
          all(set_.cell_rgb(t) is None for t in used if t >= model.BLOCKED),
          ' '.join('$%02X' % t for t in sorted(used) if t >= model.BLOCKED)[:60])

    sandbox = os.path.join(ROOT, 'build', '_tiles_solo')
    os.makedirs(sandbox, exist_ok=True)
    try:
        solo = tiles.load(sandbox)
        check('no ROM -> tile graphics degrade instead of crashing',
              not solo.available and bool(solo.error), solo.error)
    finally:
        shutil.rmtree(sandbox)

    # Settlement objects: the map byte is an id, the picture is an OAM sprite.
    ground = set_.cell_rgb(0x39, 0)
    same = [t for t in tiles.OBJECT_TILES if set_.cell_rgb(t, 0) != ground]
    check('every settlement byte renders as plain ground, never a building',
          not same, ' '.join('$%02X' % t for t in same))
    check('the settlement bytes that exist in the data are $61/$79/$7A/$7B',
          set(tiles.OBJECT_TILES) == {0x61, 0x79, 0x7A, 0x7B})
    for kind in ('castle', 'facility'):
        rgb = set_.marker_rgb(kind)
        ink = sum(1 for r in rgb for p in r if p is not None)
        check('%s marker is a 16x16 sprite with transparency' % kind,
              len(rgb) == tiles.CELL_PX and all(len(r) == tiles.CELL_PX
                                                for r in rgb)
              and 0 < ink < tiles.CELL_PX ** 2, '%d/%d opaque'
              % (ink, tiles.CELL_PX ** 2))
    fac = model.load_facilities()
    check('ProvinceTacticalFacilityTiles loads (30 rows x 3 slots)',
          fac is not None and len(fac) == model.PROVINCES
          and all(len(row) == 3 for row in fac))
    castles = model.load_castles()
    check('ProvincePixelPositionTable loads (30 castle cells)',
          castles is not None and len(castles) == model.PROVINCES)

    # The two bank $31 tables, not the crop bytes, are where the console draws a
    # building, so they have to land on cells the map actually has.
    maps = {p: model.province_map(lambda b, o: images[b][o], p)
            for p in range(model.PROVINCES)}
    obj = {p: {(x, y): t for y, row in enumerate(maps[p])
               for x, t in enumerate(row) if t in tiles.OBJECT_TILES}
           for p in range(model.PROVINCES)}
    pairs = [(p, s, pair) for p in range(model.PROVINCES)
             for s, pair in enumerate(fac[p]) if pair]
    all_cells = [pair for _, _, pair in pairs] + list(castles)
    check('every marker cell is inside the authored 32 x 20 map',
          all(0 <= x < model.MAP_COLS and 0 <= y < model.MAP_H
              for x, y in all_cells),
          '%d pairs + %d castles' % (len(pairs), len(castles)))
    dup = [(p, pair) for p in range(model.PROVINCES)
           for pair in set(c for c in fac[p] if c)
           if [c for c in fac[p] if c].count(pair) > 1]
    check('no two markers of a province share a cell', not dup, str(dup[:3]))
    check('each province has exactly one $61 castle cell',
          all(sum(1 for t in obj[p].values() if t == 0x61) == 1
              for p in range(model.PROVINCES)))
    # ProvincePixelPositionTable ($9D58) is the tactical castle position: its
    # pixel (X, Y) is the $61 cell, with the row-15 gap fixup the tables share.
    bad = ['prov %d: $9D58 -> (%d,%d) but the $61 is %s'
           % (p, castles[p][0], castles[p][1],
              [c for c, t in obj[p].items() if t == 0x61])
           for p in range(model.PROVINCES)
           if [c for c, t in obj[p].items() if t == 0x61] != [castles[p]]]
    check('$9D58 is the castle marker: 30/30 land on the province $61 cell',
          not bad, bad[0] if bad else '')
    stamped = sum(1 for p, _, pair in pairs if pair in obj[p])
    no_pair = sum(1 for p in range(model.PROVINCES)
                  for c, t in obj[p].items()
                  if t != 0x61 and c not in fac[p])
    check('the town table is the marker set: 55 pairs on a stamp, 12 unstamped, '
          '2 stamps the table never pairs',
          len(pairs) == 67 and stamped == 55 and len(pairs) - stamped == 12
          and no_pair == 2,
          '%d/%d stamped, %d stamps unpaired' % (stamped, len(pairs), no_pair))
    check('no facility pair sits on a province castle cell',
          all(fac[p][s] != [c for c, t in obj[p].items() if t == 0x61][0]
              for p in range(model.PROVINCES) for s in range(3) if fac[p][s]))

    # the row convention both tables and the bank $06 pools follow: $0F is the
    # gap row, so a raw tile Y of $0F never appears and $10+ means one row lower
    blob = model.read_bank(model.MARKER_BANK)
    offset = model.FACILITY_CPU - model.WINDOW_CPU
    raw_fac = blob[offset:offset + model.PROVINCES * model.FACILITY_STRIDE]
    offset = model.CASTLE_CPU - model.WINDOW_CPU
    raw_castle = blob[offset:offset + model.PROVINCES * model.CASTLE_STRIDE]
    raw_y = [raw_fac[p * 6 + 2 * s + 1] for p in range(model.PROVINCES)
             for s in range(3) if raw_fac[p * 6 + 2 * s] < 0x80]
    check('marker rows skip $0F (the gap row) and stay inside the 20-row map',
          0x0F not in raw_y and min(raw_y) >= 1 and max(raw_y) <= 0x13,
          'Y $%02X-$%02X, $0F absent: %s'
          % (min(raw_y), max(raw_y), 0x0F not in raw_y))
    castle_y = [struct.unpack_from('<2H', raw_castle, p * 4)[0] // model.MARKER_PX
                for p in range(model.PROVINCES)]
    check('castle rows skip $0F too', 15 not in castle_y,
          'Y tile %d-%d, $0F absent: %s'
          % (min(castle_y), max(castle_y), 15 not in castle_y))
    check('marker_row maps $10 to the gap row below it',
          model.marker_row(0x0E) == 0x0E and model.marker_row(0x10) == 0x0F
          and model.marker_row(0x12) == 0x11)


def _raises_oserror(fn):
    try:
        fn()
    except OSError:
        return True
    return False


def main():
    print('terrain banks $00/$03/$04/$05 pipeline check (30 provinces)')
    print('=' * 72)
    test_driver_tables()
    test_regions()
    test_lossless()
    test_assembler()
    test_edit_roundtrip()
    test_all_provinces()
    test_gui_views()
    test_standalone()
    test_tile_graphics()
    print('=' * 72)
    if FAILED:
        print('FAILED: %d check(s)\n  - %s' % (len(FAILED), '\n  - '.join(FAILED)))
        return 1
    print('all checks passed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
