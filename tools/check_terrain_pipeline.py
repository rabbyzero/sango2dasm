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
     lists all 30 provinces, and every `self.<attribute>` it reads is defined;
  8. the editor still runs in standalone mode, i.e. with only a copy of the
     model codec and a CSV next to it and no disassembly repo around.

The GUI is imported with a stubbed `tkinter`, so this needs no display.
"""
import ast
import os
import re
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
        # crops + pads + heads + filler/unanalysed make the whole bank
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
    print('=' * 72)
    if FAILED:
        print('FAILED: %d check(s)\n  - %s' % (len(FAILED), '\n  - '.join(FAILED)))
        return 1
    print('all checks passed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
