#!/usr/bin/env python3
"""Verify the terrain bank assembly files data_00_terrain/03/04/05.asm byte-for-byte.

The banks are rendered by tools/gen_terrain_asm.py: every byte is a labelled
`.byte` row, no `.incbin` remains. This harness assembles each bank on its own
(its own linker config, `$8000-$9FFF` window) and compares the result with
rom/prg/prg_XX.bin.

Any difference is reported in terrain terms, not just as an offset: the byte is
mapped to its region (crop / pad / overlay head / sound stream / filler), the
province, the quadrant crop, the crop row and column, and the old/new decoded
terrain - so editing a `.byte` (or regenerating from an edited
docs/terrain_bank_XX.csv) produces a readable diff.

Modes:
    python tools/verify_terrain_banks.py                  # strict: equal to the stock ROM
    python tools/verify_terrain_banks.py --allow-edits    # list decoded edits, exit 0 when
                                                          # the structure still holds
    python tools/verify_terrain_banks.py --against-csv    # compare each asm to its CSV twin
    python tools/verify_terrain_banks.py --dump-csv       # also write build/<bank>_from_asm.csv
    python tools/verify_terrain_banks.py --bank 03

Checks that survive intentional edits (they are what makes the terrain valid,
not just byte-identical):

  * the model's embedded driver tables still equal the live ones in bank `$08`
    (TileTerrainTable $B74B, TerrainMapPtrTable $B7CB, TileBankTable $B8BB);
  * every province 0-29 keeps a Castle cell in its authored 32 x 20 map (the
    authored data has exactly one; losing one is an error, a second one is a
    warning) - layout doc §2;
  * a crop row that the engine reads as a ribbon gap ($00 blank tile) is
    reported when an edit gives it authored terrain;
  * tiles >= `$80` short-circuit to terrain 0 without a table lookup, so any
    newly introduced blocked tile outside the `$FF` filler is reported.
"""
import argparse
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import terrain_model as model                    # noqa: E402

ROOT = model.ROOT
CC65 = '/home/zero/.local/bin/ca65'
LD65 = '/home/zero/.local/bin/ld65'
BUILD = os.path.join(ROOT, 'build')


def linker_cfg(bank):
    return ('MEMORY {\n'
            '    BANK%02X: start = $8000, size = $2000, type = ro, fill = yes,\n'
            '            fillval = $FF, file = "build/_terrain%02x.bin";\n'
            '}\n'
            'SEGMENTS {\n'
            '    CODE_BANK%02X: load = BANK%02X, type = ro;\n'
            '}\n' % (bank, bank, bank, bank))


def assemble_bank(bank, src=None):
    """ca65 + ld65 the single bank; return the built 8KB image or None."""
    os.makedirs(BUILD, exist_ok=True)
    src = src or model.asm_path(bank)
    obj = os.path.join(BUILD, '_terrain%02x.o' % bank)
    asm = os.path.join(BUILD, '_terrain%02x.asm' % bank)
    cfg = os.path.join(BUILD, '_terrain%02x.cfg' % bank)
    out = os.path.join(BUILD, '_terrain%02x.bin' % bank)
    # The bank declares `.segment "CODE_BANKxx"`; standalone assembly needs that
    # segment in the config, which linker_cfg provides. The source is copied so
    # relative include paths keep resolving from the repo root.
    with open(src, encoding='utf-8') as f:
        text = f.read()
    for path, content in ((asm, text), (cfg, linker_cfg(bank))):
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
    r = subprocess.run([CC65, '-I', os.path.join(ROOT, 'include'),
                        '-I', os.path.join(ROOT, 'asm', 'banks'), asm,
                        '-o', obj], capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('CA65 FAILED (bank %02X):\n%s' % (bank, r.stderr[:3000]),
              file=sys.stderr)
        return None
    if r.stderr.strip():
        print('ca65 notes (bank %02X): %s' % (bank, r.stderr.strip()[:400]))
    r = subprocess.run([LD65, '-C', cfg, obj, '-o', out],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('LD65 FAILED (bank %02X):\n%s' % (bank, r.stderr[:3000]),
              file=sys.stderr)
        return None
    with open(out, 'rb') as f:
        return f.read()


def check_driver_tables():
    """The embedded copies are what the comments and the editor decode with."""
    live = model.load_driver_tables()
    if live is None:
        print('  driver tables: rom/prg/prg_08.bin absent, skipped (using the '
              'embedded copies)')
        return True
    names = (('TILE_TERRAIN_TABLE', model.TILE_TERRAIN_TABLE),
             ('TERRAIN_MAP_PTR', model.TERRAIN_MAP_PTR),
             ('TILE_BANK_TABLE', model.TILE_BANK_TABLE))
    drift = []
    for name, embedded in names:
        index = [n for n, _ in names].index(name)
        if live[index] != embedded:
            bad = [i for i, (a, b) in enumerate(zip(live[index], embedded))
                   if a != b]
            drift.append('%s differs at %d entr%s ($%04X%s)'
                         % (name, len(bad), 'y' if len(bad) == 1 else 'ies',
                            bad[0], ', ...' if len(bad) > 1 else ''))
    if drift:
        for line in drift:
            print('  INVALID: tools/terrain_model.py %s' % line, file=sys.stderr)
        return False
    print('  driver tables match bank $08 ($B74B / $B7CB / $B8BB)')
    return True


def check_structure(banks, stock, table):
    """Terrain invariants over all four banks; returns (problems, warnings).

    `stock` (the ROM images) makes the last two checks edit-focused: gap rows
    already carry a few stray bytes and zone 31 already ends in `$FF`, so only
    newly introduced ones warn.
    """
    problems, warnings = [], []

    # A single-bank run only assembles that bank, but the province/Castle check
    # spans all 30 maps across four banks. Resolve each bank to its assembled
    # bytes when present, else its stock image, else read the ROM - so checking
    # one edited bank still validates every other province against the stock.
    resolved = {}

    def bank_bytes(bank):
        if bank not in resolved:
            data = banks.get(bank) or stock.get(bank)
            if data is None:
                data = model.read_bank(bank)
            resolved[bank] = data
        return resolved[bank]

    def get_byte(bank, offset):
        return bank_bytes(bank)[offset]

    # 1. every province needs its stronghold (layout doc §2: one Castle per map)
    for prov in range(model.PROVINCES):
        castles = sum(1 for row in model.province_map(get_byte, prov)
                      for tile in row
                      if model.tile_terrain(tile, table) == 5)
        if castles == 0:
            problems.append('province %d has no Castle cell - the tactical map '
                            'loses its stronghold' % prov)
        elif castles > 1:
            warnings.append('province %d has %d Castle cells, the authored data '
                            'has exactly 1' % (prov, castles))
    if not problems:
        print('  all %d provinces keep their Castle cell' % model.PROVINCES)
    for bank in banks:
        stock_bank = stock.get(bank)
        # 2. ribbon gap rows must stay blank; they are read as terrain anyway
        for zone in model.bank_zones(bank):
            for row in model.gap_rows(zone):
                owner, _orow, _bank, _off = model.cell_owner(zone, row, 0)
                if owner != zone:
                    continue        # aliased into the next window: not ours
                off = model.zone_offset(zone) + row * model.GRID
                if off + model.GRID > model.BANK_SIZE:
                    continue
                line = banks[bank][off:off + model.GRID]
                old = stock_bank[off:off + model.GRID] if stock_bank else None
                for i, tile in enumerate(line):
                    if tile and (old is None or old[i] == 0):
                        warnings.append(
                            'bank $%02X zone %d %s gap row %d col %d now holds '
                            'tile $%02X %s - @GetTileTerrain reads map row %d '
                            'from this row'
                            % (bank, zone, model.zone_meta(zone)[1], row, i,
                               tile, model.terrain_name(tile, table),
                               row if model.zone_meta(zone)[2]
                               else model.TOP_ROWS + row))
        # 3. blocked tiles outside the $FF filler short-circuit to Forest (§5)
        for reg in model.regions(bank):
            if reg.kind != 'crop':
                continue
            for off in range(reg.start, reg.end):
                tile = banks[bank][off]
                was_blocked = (stock_bank is None
                               or stock_bank[off] >= model.BLOCKED)
                if tile >= model.BLOCKED and tile != 0xFF and not was_blocked:
                    warnings.append('bank $%02X offset $%04X (zone %d %s) holds '
                                    'blocked tile $%02X - the engine reads it '
                                    'as Forest without a table lookup'
                                    % (bank, off, reg.zone, reg.quadrant, tile))
    if len(warnings) > 12:
        print('  ... %d more warnings' % (len(warnings) - 12))
    return problems, warnings[:12]


def report_diffs(bank, reference, built, ref_rows, table, limit=40):
    """Byte drift -> one decoded line per changed owner row."""
    diffs = [i for i, (a, b) in enumerate(zip(reference, built)) if a != b]
    if not diffs:
        return 0
    by_off = {model.parse_int(r['offset']): r for r in ref_rows}
    touched = {}
    for off in diffs:
        reg = next((r for r in model.regions(bank) if r.start <= off < r.end),
                   None)
        row_off = (reg.start + (off - reg.start) // model.GRID * model.GRID
                   if reg else off)
        touched.setdefault(row_off, []).append(off)
    print('  %d byte(s) differ across %d row(s):' % (len(diffs), len(touched)))
    for i, row_off in enumerate(sorted(touched)):
        if i >= limit:
            print('     ... %d more rows' % (len(touched) - limit))
            break
        ref_row = by_off.get(row_off)
        if ref_row is None:
            print('    offset $%04X: unowned byte' % row_off)
            continue
        new_row = dict(ref_row)
        new_row['tiles'] = list(built[row_off:row_off + ref_row['length']])
        print('   ', model.describe_edit(ref_row, new_row, table))
    return len(diffs)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--bank', default='all',
                    help='terrain bank: 00, 03, 04, 05, a comma list, or all')
    ap.add_argument('--allow-edits', action='store_true',
                    help='report decoded edits instead of failing on them')
    ap.add_argument('--against-csv', action='store_true',
                    help='compare each bank to its CSV twin instead of the ROM')
    ap.add_argument('--asm', help='asm path override (single bank only)')
    ap.add_argument('--dump-csv', action='store_true',
                    help='also write build/terrain_<bank>_from_asm.csv')
    args = ap.parse_args()

    banks = banks_list(args.bank)
    if args.asm and len(banks) != 1:
        raise SystemExit('--asm accepts a single --bank value')
    table = model.TILE_TERRAIN_TABLE
    print('terrain banks: %s' % ', '.join('$%02X' % b for b in banks))
    ok = check_driver_tables()
    rc = 0
    built_all = {}
    # the stock images are the baseline for the structural warnings even when
    # the byte comparison itself runs against the CSV twins
    stock = {b: s for b, s in ((b, _stock_or_none(b)) for b in banks) if s}
    for bank in banks:
        built = assemble_bank(bank, args.asm if len(banks) == 1 else None)
        if built is None:
            return 1
        built_all[bank] = built
        if len(built) != model.BANK_SIZE:
            print('bank $%02X FAIL: length %d, expected %d'
                  % (bank, len(built), model.BANK_SIZE))
            return 1
        if args.against_csv:
            path = model.csv_path(bank)
            if not os.path.exists(path):
                print('bank $%02X FAIL: no CSV twin at %s'
                      % (bank, os.path.relpath(path, ROOT)), file=sys.stderr)
                return 1
            ref_rows = model.csv_read(path, bank)
            reference = model.bank_from_rows(bank, ref_rows)
            label = os.path.relpath(path, ROOT)
        else:
            reference = stock.get(bank)
            if reference is None:
                print('bank $%02X FAIL: rom/prg/prg_%02x.bin is missing; run '
                      '`make split` (or use --against-csv)'
                      % (bank, bank), file=sys.stderr)
                return 1
            ref_rows = model.rows_from_bank(bank, reference)
            label = 'rom/prg/prg_%02x.bin' % bank
        print('bank $%02X (%s): %d bytes assembled'
              % (bank, model.asm_path(bank), len(built)))
        n = report_diffs(bank, reference, built, ref_rows, table)
        if n == 0:
            print('  byte-exact vs %s' % label)
        elif not args.allow_edits:
            print('  FAIL: %d byte(s) drift from %s (use --allow-edits once the '
                  'edit is intended)' % (n, label), file=sys.stderr)
            rc = 1
        if args.dump_csv:
            path = os.path.join(BUILD, 'terrain_%02x_from_asm.csv' % bank)
            model.csv_write(path, model.rows_from_bank(bank, built))
            print('  wrote %s' % os.path.relpath(path, ROOT))
    problems, warnings = check_structure(built_all, stock, table)
    for w in warnings:
        print('  WARN: %s' % w)
    for p in problems:
        print('  INVALID: %s' % p, file=sys.stderr)
    if problems or not ok:
        rc = 1
    print('  %s' % ('OK' if rc == 0 else 'FAILED'))
    return rc


def banks_list(text):
    if text == 'all':
        return list(model.TERRAIN_BANKS)
    return [int(value.replace('$', ''), 16)
            for value in text.split(',')]


def _stock_or_none(bank):
    path = os.path.join(model.PRG_DIR, 'prg_%02x.bin' % bank)
    return model.read_bank(bank) if os.path.exists(path) else None


if __name__ == '__main__':
    sys.exit(main())
