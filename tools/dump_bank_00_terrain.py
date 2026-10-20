#!/usr/bin/env python3
"""Decode/draw the tactical (war layer) terrain maps stored in the $8000-window banks.

Each province's tactical map is **20 rows x 32 columns**, assembled from four
16-column quadrant crops: the two upper crops carry 15 content rows each and the
two lower crops carry 5, so rows 0-14 come from TL/TR and rows 15-19 from BL/BR.
That is the authored layout, proved by the blank tile $00 (never used as terrain)
occurring only in the ribbon's inter-crop gap rows - `--check-geometry`.

`@GetTileTerrain` ($B6EF, prg_08_09_tactical_war.asm) does the runtime lookup:

    quadrant = (x >= 16) | ((y >= 16) << 1)          ; 0=TL 1=TR 2=BL 3=BR
    zone     = ($00A8)[quadrant]                     ; 4-byte per-war table
    ptr      = TerrainMapPtrTable[zone]              ; $B7CB, 120 words
    bank     = TileBankTable[zone] & $1F             ; $B8BB, 120 bytes
    JSR B1F_SwitchBank8_A                            ; $E000 = bank, $8000 window
    tile     = [ptr + ((y & 15) << 4 | (x & 15))]    ; flat 16 rows x 16 bytes
    terrain  = 0 if tile >= $80 else TileTerrainTable[tile]   ; $B74B, 128 bytes

Note the lookup splits at y >= 16 and indexes with y & 15, while the data splits
at 15: the engine reads the upper crops' gap row 15 as terrain for y=15 (a blank
Forest band) and never reaches the lower crops' 5th content row. `--model engine`
draws what the engine reads; the default `--model authored` draws the map the
data describes. `@EvalStepCost` bounds queries at X < $1F and Y < $14, so column
31 is never read (`--width 31` for that view).

The 120 zones are exactly 30 provinces x 4 quadrants. `DataRecordLoader` ($DF15,
prg_17_18_duel_and_display.asm) installs the `($00A8)` table: `PermutationTable` ($DF86, bank $18)
holds 30 groups of 4 zone ids, indexed by the battlefield province `$050E`, and
the group is copied to ZP `$00AA-$00AD`. Each group is {base, base+2, base+1,
base+3}, so zone order inside a province is TL, BL, TR, BR.

This tool loads the tables straight out of the ROM binaries (byte-exact), and emits

  * a text table per province or per zone, with terrain histograms
  * a CSV, one row per cell
  * a PNG sheet for visual confirmation

Usage:
    python tools/dump_bank_00_terrain.py                  # bank $00 provinces 0-7
    python tools/dump_bank_00_terrain.py --bank all       # all 30 provinces
    python tools/dump_bank_00_terrain.py --zones          # the 32 raw 16x16 crops
    python tools/dump_bank_00_terrain.py --ascii          # + char grids of each map
    python tools/dump_bank_00_terrain.py --model engine   # what @GetTileTerrain reads
    python tools/dump_bank_00_terrain.py --verify-asm     # tables: asm hex == ROM
    python tools/dump_bank_00_terrain.py --check-geometry     # 15 + 5 row split
    python tools/dump_bank_00_terrain.py --check-provinces    # province/quadrant model
    python tools/dump_bank_00_terrain.py --check-layout       # zone ribbon packing
    python tools/dump_bank_00_terrain.py --check-alias        # field-map pointer alias

Terrain ids are the *clamped* values the engine uses (>= 6 collapses to 2); the
labels come from the stratagem feasibility handlers ($ACAE-$AE20) and the
step-cost table ($A7CD), cross-checked against docs/manual_kb/06-reference-tables.md.
See code/bank_00_data_layout.md for the full write-up.
"""
import argparse
import os
import re
import struct
import sys
import zlib
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRG_DIR = os.path.join(ROOT, 'rom', 'prg')
OUT_DIR = os.path.join(ROOT, 'output')

# Terrain lookup tables, resident in PRG bank $08 (CPU $A000-$BFFF).
CODE_BANK, CODE_WINDOW = 0x08, 0xA000
TILE_TERRAIN_CPU, TILE_TERRAIN_LEN = 0xB74B, 128
MAP_PTR_CPU, MAP_PTR_COUNT = 0xB7CB, 120
BANK_TABLE_CPU, BANK_TABLE_LEN = 0xB8BB, 120

# Province -> 4 quadrant zones, resident in PRG bank $18 (CPU $C000-$FFFF).
ZONE_BANK, ZONE_WINDOW = 0x18, 0xC000
ZONE_GROUP_CPU = 0xDF86        # PermutationTable: 30 groups x 4 zone ids
ZONE_RECORD_CPU = 0xDF4A       # DataRecordPtrTable: 30 words -> the groups
PROVINCES = 30
QUADRANTS = ('TL', 'TR', 'BL', 'BR')   # indexed by the ($A8) quadrant number
ZONE_GROUP = ('TL', 'BL', 'TR', 'BR')  # zone id order inside a province

WINDOW_CPU = 0x8000            # $8000-$9FFF data window selected by SwitchBank8_A
MAP_SIZE = 256                 # 16 rows x 16 bytes, index = (y&15)*16 + (x&15)
GRID = 16                      # quadrant crop edge, in cells
MAP_H = 20                     # tactical map height: Y < $14 (@EvalStepCost $A785)
MAP_COLS = 32                  # authored width: 16 columns per crop, left + right
TOP_ROWS, BOTTOM_ROWS = 15, 5  # content rows per crop half: 15 + 5 = MAP_H
ENGINE_SPLIT = GRID            # @GetTileTerrain picks the lower crops at y >= $10
ENGINE_X_LIMIT = 0x1F          # @EvalStepCost $A773: X < $1F -> X 0-30 queryable
GAP_ROWS_TOP = (15,)           # ribbon gap rows inside a TL/TR crop window
GAP_ROWS_BOTTOM = (5, 6, 7, 8)  # ribbon gap rows inside a BL/BR crop window
BLOCKED = 0x80                 # tile >= $80 -> terrain 0 without a table lookup

# Second consumer of the same bytes: the Tactical Mode field map (prg_17_18_duel_and_display.asm),
# whose crop tile / overlay loaders keep copies of the zone pointer table.
FIELDMAP_BANK = 0x17
FIELDMAP_WINDOW = 0xA000
FIELDMAP_TILE_CPU = 0xA642       # FieldMapCropPtrTable
FIELDMAP_OVERLAY_CPU = 0xA732    # FieldMapOverlayPtrTable
FIELDMAP_BANKTAB_CPU = 0xA822    # FieldMapCropBankTable
OVERLAY_PHASE = 0x40           # overlay ptr == terrain ptr - $40

# Clamped terrain id -> (name, RGB). 0/3/4/5 are asserted by the AiFeasible_*
# handlers; 1 is the step-cost column matching the manual's 砂地 row; 6/7/8 are
# never distinguished by the engine (clamped to 2 = Plain).
TERRAIN = {
    0: ('Forest',    (0x2E, 0x7D, 0x32)),
    1: ('Sandland',  (0xE0, 0xC8, 0x7A)),
    2: ('Plain',     (0xB8, 0xE8, 0x9A)),
    3: ('River',     (0x3A, 0x7E, 0xD0)),
    4: ('Mountain',  (0x8C, 0x6A, 0x4A)),
    5: ('Castle',    (0xD8, 0x3A, 0x3A)),
    6: ('Special6',  (0xC0, 0x80, 0xE0)),
    7: ('Special7',  (0x60, 0x60, 0x60)),
    8: ('Special8',  (0xF0, 0xF0, 0xF0)),
}
UNMAPPED = (0xFF, 0x00, 0xFF)
BLOCKED_RGB = (0xFF, 0x00, 0xFF)
GAP_RGB = (0x40, 0x40, 0x40)    # ribbon gap row: no authored terrain

# One-char terrain ids for --ascii grids; '@' marks a blocked (tile >= $80) cell.
TERRAIN_CHAR = {0: 'f', 1: 's', 2: 'p', 3: 'r', 4: 'm', 5: 'c',
                6: '6', 7: '7', 8: '8'}

# 3x5 digit glyphs, rows top to bottom, bit 2 = left pixel.
DIGITS = {
    '0': (7, 5, 5, 5, 7), '1': (2, 6, 2, 2, 7), '2': (7, 1, 7, 4, 7),
    '3': (7, 1, 3, 1, 7), '4': (1, 3, 5, 7, 1), '5': (7, 4, 7, 1, 7),
    '6': (7, 4, 7, 5, 7), '7': (7, 1, 2, 2, 2), '8': (7, 5, 7, 5, 7),
    '9': (7, 5, 7, 1, 7),
}


def read_bank(bank):
    with open(os.path.join(PRG_DIR, 'prg_%02x.bin' % bank), 'rb') as f:
        return f.read()


def load_tables():
    """(TileTerrainTable, TerrainMapPtrTable, TileBankTable) from bank $08."""
    code = read_bank(CODE_BANK)
    tt = code[TILE_TERRAIN_CPU - CODE_WINDOW:
              TILE_TERRAIN_CPU - CODE_WINDOW + TILE_TERRAIN_LEN]
    tp = code[MAP_PTR_CPU - CODE_WINDOW:
              MAP_PTR_CPU - CODE_WINDOW + MAP_PTR_COUNT * 2]
    tb = code[BANK_TABLE_CPU - CODE_WINDOW:
              BANK_TABLE_CPU - CODE_WINDOW + BANK_TABLE_LEN]
    if len(tt) != TILE_TERRAIN_LEN or len(tp) != MAP_PTR_COUNT * 2 or \
            len(tb) != BANK_TABLE_LEN:
        raise SystemExit('prg_%02x.bin is too small to hold the three tables'
                         % CODE_BANK)
    return tt, list(struct.unpack('<%dH' % MAP_PTR_COUNT, tp)), tb


def load_zone_groups():
    """The 30 x 4 province/quadrant zone table plus its pointer table, bank $18."""
    code = read_bank(ZONE_BANK)
    groups = code[ZONE_GROUP_CPU - ZONE_WINDOW:
                  ZONE_GROUP_CPU - ZONE_WINDOW + PROVINCES * 4]
    recs = code[ZONE_RECORD_CPU - ZONE_WINDOW:
                ZONE_RECORD_CPU - ZONE_WINDOW + PROVINCES * 2]
    if len(groups) != PROVINCES * 4 or len(recs) != PROVINCES * 2:
        raise SystemExit('prg_%02x.bin does not hold the province zone table'
                         % ZONE_BANK)
    return groups, list(struct.unpack('<%dH' % PROVINCES, recs))


def decode_zone(data, ptr, tile_terrain):
    """(tile bytes, terrain ids) of one zone's 16x16 grid in a data bank."""
    off = ptr - WINDOW_CPU
    if off < 0 or off + MAP_SIZE > len(data):
        raise SystemExit('ptr $%04X (bank offset $%04X) does not fit in the %d-'
                         'byte bank; wrong --bank?' % (ptr, off, len(data)))
    tiles = data[off:off + MAP_SIZE]
    terrain = [0 if t >= BLOCKED else tile_terrain[t] for t in tiles]
    return tiles, terrain


def load_zones():
    """{zone: (ptr, bank, tiles, terrain)} for all 120 zones, every data bank."""
    tile_terrain, map_ptrs, bank_table = load_tables()
    data = {b: read_bank(b) for b in {x & 0x1F for x in bank_table}}
    zones = {}
    for z in range(MAP_PTR_COUNT):
        bank = bank_table[z] & 0x1F
        tiles, terrain = decode_zone(data[bank], map_ptrs[z], tile_terrain)
        zones[z] = (map_ptrs[z], bank, tiles, terrain)
    return zones


def quadrant_of(x, y, split=GRID):
    """The ($00A8) index for map coord (x, y); split = upper/lower boundary."""
    return (1 if x >= GRID else 0) | (2 if y >= split else 0)


def cell_source(x, y, model='authored'):
    """(quadrant, crop row) a map coord reads from, per geometry model.

    authored: the crops carry 15 content rows (TL/TR) + 5 content rows (BL/BR)
              = 20 rows; the rows outside that are the ribbon's $00 gaps.
    engine:   what @GetTileTerrain actually does - `y >= $10` picks the lower
              crops and the index is `y & 15`, so it reads one gap row at y=15
              and never reaches the lower crops' 5th content row.
    """
    if model == 'engine':
        return quadrant_of(x, y, ENGINE_SPLIT), y & 15
    lower = y >= TOP_ROWS
    return quadrant_of(x, y, TOP_ROWS), (y - TOP_ROWS if lower else y)


def province_cells(province, groups, zones, model='authored', width=MAP_COLS):
    """(x, y, zone, quadrant, cpu, tile, terrain) for one province's map."""
    cells = []
    for y in range(MAP_H):
        for x in range(width):
            q, row = cell_source(x, y, model)
            zone = groups[province * 4 + q]
            ptr, _, tiles, terrain = zones[zone]
            i = row * GRID + (x & 15)
            cells.append((x, y, zone, q, ptr + i, tiles[i], terrain[i]))
    return cells


def histogram_text(terrain, tiles):
    """Terrain-id counts; tiles >= $80 counted separately, not as Forest."""
    blocked = sum(1 for t in tiles if t >= BLOCKED)
    parts = []
    for tid in sorted(set(terrain)):
        name = TERRAIN.get(tid, ('?', None))[0]
        count = terrain.count(tid)
        if tid == 0 and blocked:
            parts.append('%s(%d)=%d +blocked=%d'
                         % (name, tid, count - blocked, blocked))
        else:
            parts.append('%s(%d)=%d' % (name, tid, count))
    return ' '.join(parts)


def cell_char(tile, terrain):
    return '@' if tile >= BLOCKED else TERRAIN_CHAR.get(terrain, '?')


def write_png(path, img):
    """RGB pixel rows -> PNG (stdlib only, same approach as render_ppu_screen)."""
    h, w = len(img), len(img[0])
    rows = [b'\x00' + b''.join(bytes(px) for px in row) for row in img]

    def chunk(tag, data):
        return (struct.pack('>I', len(data)) + tag + data +
                struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF))
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(b''.join(rows), 9))
    png += chunk(b'IEND', b'')
    with open(path, 'wb') as f:
        f.write(png)
    return w, h


def draw_label(img, x, y, text, fg=(255, 255, 255), bg=(0, 0, 0), scale=1):
    """Blit a digit-only 3x5 label at (x, y) into the pixel grid."""
    for i, ch in enumerate(text):
        glyph = DIGITS.get(ch)
        if glyph is None:
            continue
        for row in range(5):
            for col in range(3):
                px = fg if (glyph[row] >> (2 - col)) & 1 else bg
                for sy in range(scale):
                    for sx in range(scale):
                        img[y + row * scale + sy][
                            x + i * 4 * scale + col * scale + sx] = px


def draw_legend(img, x, y, scale, swatch):
    """One swatch per terrain id, tagged with the id's digit."""
    for tid in sorted(TERRAIN):
        for yy in range(swatch):
            for xx in range(swatch):
                img[y + yy][x + xx] = TERRAIN[tid][1]
        draw_label(img, x + swatch + scale, y, str(tid), scale=scale)
        x += swatch + 5 * scale
    return x


def render_sheet(items, cols, cell, gutter, scale, view, legend=True):
    """`items` = [(label, width, height, [(x, y, tile, terrain), ...]), ...]."""
    swatch = 2 * cell * scale
    label_h = 6 * scale
    legend_h = max(6 * scale, swatch + 3 * scale) if legend else 0
    cell_px = cell * scale
    col_w = []
    for c in range(cols):
        widest = max((w for i, (_, w, _, _) in enumerate(items)
                      if i % cols == c), default=0)
        col_w.append(widest * cell_px)
    w = sum(col_w) + (cols + 1) * gutter * scale
    if legend:
        w = max(w, gutter * scale + len(TERRAIN) * (swatch + 5 * scale))
    rows = (len(items) + cols - 1) // cols
    row_h = [max((h for i, (_, _, h, _) in enumerate(items)
                  if i // cols == r), default=0) * cell_px
             for r in range(rows)]
    h = legend_h + sum(row_h) + label_h * rows + (rows + 1) * gutter * scale
    img = [[(16, 16, 16)] * w for _ in range(h)]
    if legend:
        draw_legend(img, gutter * scale, scale, scale, swatch)
    for n, (label, _, _, cells) in enumerate(items):
        cx = gutter * scale + sum(col_w[:n % cols]) + (n % cols) * gutter * scale
        cy = legend_h + gutter * scale + sum(row_h[:n // cols]) \
            + (n // cols) * gutter * scale
        draw_label(img, cx, cy, label, scale=scale)
        cy += label_h
        for (x, y, tile, terrain) in cells:
            if tile is None:
                px = GAP_RGB
            elif view == 'raw':
                px = (BLOCKED_RGB if tile >= BLOCKED
                      else (tile * 2,) * 3)
            else:
                px = (BLOCKED_RGB if tile >= BLOCKED
                      else TERRAIN[terrain][1] if terrain in TERRAIN else UNMAPPED)
            for sy in range(cell_px):
                for sx in range(cell_px):
                    img[cy + y * cell_px + sy][cx + x * cell_px + sx] = px
    return img


def gap_rows(z):
    """Ribbon gap rows inside crop z's window (never authored terrain)."""
    return GAP_ROWS_TOP if z % 4 in (0, 2) else GAP_ROWS_BOTTOM


def zone_items(zones, selected, mark_gaps=True):
    """One sheet item per zone: its 16x16 crop, gap rows flagged tile=None."""
    items = []
    for z in selected:
        _, _, tiles, terrain = zones[z]
        gaps = gap_rows(z) if mark_gaps else ()
        cells = [(i % GRID, i // GRID,
                  None if i // GRID in gaps else tiles[i], terrain[i])
                 for i in range(MAP_SIZE)]
        items.append((str(z), GRID, GRID, cells))
    return items


def province_items(groups, zones, provinces, model='authored', width=MAP_COLS):
    """One sheet item per province: the assembled tactical map."""
    items = []
    for p in provinces:
        cells = [(x, y, tile, terr) for (x, y, z, q, cpu, tile, terr)
                 in province_cells(p, groups, zones, model, width)]
        items.append((str(p), width, MAP_H, cells))
    return items


# ---------------------------------------------------------------- checks ----

def verify_against_asm(path):
    """Compare the ROM tables with the trailing hex comments of the disassembly."""
    hexrow = re.compile(r';\s*\$([0-9A-Fa-f]{4}):\s+([0-9A-Fa-f ]+)\s*$')
    src = open(path).read()
    tile_terrain, map_ptrs, bank_table = load_tables()
    cases = [('TileTerrainTable', TILE_TERRAIN_CPU, bytes(tile_terrain)),
             ('TerrainMapPtrTable', MAP_PTR_CPU,
              struct.pack('<%dH' % len(map_ptrs), *map_ptrs)),
             ('TileBankTable', BANK_TABLE_CPU, bytes(bank_table))]
    ok = True
    for label, cpu, rom in cases:
        lines = src[src.index(label + ':'):].split('\n')[1:]
        asm = []
        for line in lines:
            m = hexrow.search(line.rstrip())
            if not m or int(m.group(1), 16) != cpu + len(asm):
                break
            asm += [int(x, 16) for x in m.group(2).split()]
            if len(asm) >= len(rom):
                break
        same = asm == list(rom)
        ok = ok and same
        print('%-19s $%04X  %3d B  asm==prg_%02x.bin: %s'
              % (label, cpu, len(rom), CODE_BANK, same))
    return ok


def check_provinces():
    """Verify the 30 provinces x 4 quadrants model (see the layout doc §2)."""
    groups, recs = load_zone_groups()
    zones = load_zones()
    ok = True
    stride = all(recs[p] == ZONE_GROUP_CPU + 4 * p for p in range(PROVINCES))
    print('  DataRecordPtrTable[p] == PermutationTable + 4*p : %s' % stride)
    ok = ok and stride
    pattern = all(list(groups[p * 4:p * 4 + 4]) ==
                  [4 * p, 4 * p + 2, 4 * p + 1, 4 * p + 3]
                  for p in range(PROVINCES))
    print('  groups == {base, base+2, base+1, base+3}       : %s' % pattern)
    ok = ok and pattern
    flat = sorted(groups)
    print('  120 zone ids, all distinct 0-119               : %s'
          % (flat == list(range(120))))
    ok = ok and flat == list(range(120))
    # castle count and seam continuity under both geometry models
    for model in ('authored', 'engine'):
        castles = [sum(1 for c in province_cells(p, groups, zones, model)
                       if c[6] == 5)
                   for p in range(PROVINCES)]
        same = total = 0
        for p in range(PROVINCES):
            grid = {(c[0], c[1]): c[6] for c
                    in province_cells(p, groups, zones, model)}
            split = TOP_ROWS if model == 'authored' else ENGINE_SPLIT
            for x in range(MAP_COLS):
                same += grid[(x, split - 1)] == grid[(x, split)]
                total += 1
            for y in range(MAP_H):
                same += grid[(15, y)] == grid[(16, y)]
                total += 1
        print('  %-8s: one-castle provinces %2d/30 (%d castle cells), '
              'seam match %.3f'
              % (model, sum(1 for c in castles if c == 1), sum(castles),
                 same / total))
    ok = ok and set(castles) == {1}
    # the same count under the wrong corner assignments, as a control
    for name, perm in (('identity', (0, 1, 2, 3)), ('row swap', (1, 0, 3, 2)),
                       ('col swap', (2, 3, 0, 1))):
        hits = 0
        for p in range(PROVINCES):
            n = 0
            for y in range(MAP_H):
                for x in range(MAP_COLS):
                    q, row = cell_source(x, y)
                    z = 4 * p + perm[q]
                    n += zones[z][3][row * GRID + (x & 15)] == 5
            hits += n == 1
        print('  (control) one-castle provinces under %-9s: %2d/30'
              % (name, hits))
    return ok


def check_geometry():
    """Prove the 15 + 5 content-row split from the tile-$00 row profile.

    Tile $00 is the blank tile and is never used as authored terrain, so it can
    only occur in the ribbon's inter-crop gaps. Measured over all 120 crops it
    appears in exactly two places: row 15 of the top crops and rows 5-8 of the
    bottom crops. Everything else is authored terrain.
    """
    zones = load_zones()
    ok = True
    for label, idx, content, gaps in (
            ('TL/TR', (0, 2), range(TOP_ROWS), GAP_ROWS_TOP),
            ('BL/BR', (1, 3), range(BOTTOM_ROWS), GAP_ROWS_BOTTOM)):
        prof = []
        for r in range(GRID):
            z = tot = 0
            for i in range(MAP_PTR_COUNT):
                if i % 4 in idx:
                    tiles = zones[i][2]
                    tot += GRID
                    z += tiles[r * GRID:r * GRID + GRID].count(0)
            prof.append(100.0 * z / tot)
        clean = all(prof[r] == 0.0 for r in content)
        gapish = all(prof[r] > 50.0 for r in gaps)
        ok = ok and clean and gapish
        print('  %s content rows %d-%d hold no tile $00 : %s'
              % (label, content[0], content[-1], clean))
        print('  %s gap rows %s are >50%% $00        : %s  (%s)'
              % (label, list(gaps), gapish,
                 ' '.join('r%d=%.0f%%' % (r, prof[r]) for r in gaps)))
        print('  %s row profile: %s' % (label, ' '.join('%.0f' % p for p in prof)))
    print('  => authored map = %d + %d = %d rows x (%d + %d) columns'
          % (TOP_ROWS, BOTTOM_ROWS, MAP_H, GRID, GRID))
    return ok


def check_layout(data, map_ptrs, zones):
    """Verify the ribbon packing claimed in code/bank_00_data_layout.md §4."""
    off = [map_ptrs[z] - WINDOW_CPU for z in zones]
    bad = 0
    for i in range(0, len(off) - 1, 2):
        if zones[i + 1] != zones[i] + 1:
            continue                      # seam between two zone ranges of a bank
        if off[i + 1] - off[i] != 0x130:
            print('  pair %s/%s: +$%03X, expected +$130'
                  % (zones[i], zones[i + 1], off[i + 1] - off[i]))
            bad += 1
        if i + 2 < len(off) and zones[i + 2] == zones[i] + 2:
            if off[i + 2] - off[i] != 0x1C0:
                print('  block %s: stride $%03X, expected $1C0'
                      % (zones[i], off[i + 2] - off[i]))
                bad += 1
            if data[off[i + 1] + 144:off[i + 1] + 256] != \
                    data[off[i + 2]:off[i + 2] + 112]:
                print('  shared band after zone %s differs' % zones[i + 1])
                bad += 1
    last_real = None
    for i in range(len(data) - 1, off[-1], -1):
        if data[i] != 0xFF:
            last_real = i
            break
    print('  %d zone maps, %d pairs, block head $%04X, last non-$FF byte: %s,'
          ' mismatches: %d'
          % (len(off), (len(off) + 1) // 2, off[0],
             '$%04X' % last_real if last_real is not None else 'none', bad))
    return bad


def check_alias():
    """The field map's pointer tables vs the terrain tables."""
    _, map_ptrs, bank_table = load_tables()
    code = read_bank(FIELDMAP_BANK)
    n = MAP_PTR_COUNT * 2
    tile = struct.unpack('<%dH' % MAP_PTR_COUNT,
                         code[FIELDMAP_TILE_CPU - FIELDMAP_WINDOW:
                              FIELDMAP_TILE_CPU - FIELDMAP_WINDOW + n])
    overlay = struct.unpack('<%dH' % MAP_PTR_COUNT,
                            code[FIELDMAP_OVERLAY_CPU - FIELDMAP_WINDOW:
                                 FIELDMAP_OVERLAY_CPU - FIELDMAP_WINDOW + n])
    fieldmap_banks = code[FIELDMAP_BANKTAB_CPU - FIELDMAP_WINDOW:
                          FIELDMAP_BANKTAB_CPU - FIELDMAP_WINDOW + BANK_TABLE_LEN]
    ok = True
    same = list(tile) == map_ptrs
    ok = ok and same
    print('  %-24s == TerrainMapPtrTable      : %s' % ("FieldMapCropPtrTable", same))
    phase = [i for i in range(MAP_PTR_COUNT)
             if overlay[i] != map_ptrs[i] - OVERLAY_PHASE]
    ok = ok and not phase
    print('  %-24s == TerrainMapPtrTable - $%02X : %s%s'
          % ("FieldMapOverlayPtrTable", OVERLAY_PHASE, not phase,
             '' if not phase else ' (idx %s)' % phase[:6]))
    same_banks = list(fieldmap_banks) == list(bank_table)
    ok = ok and same_banks
    print('  %-24s == TileBankTable            : %s' % ("FieldMapCropBankTable", same_banks))
    return ok


# ------------------------------------------------------------------- main ----

def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--bank', default='0', help='physical PRG bank to decode '
                    '(TileBankTable & $1F); "all" covers every province')
    ap.add_argument('--zones', action='store_true', help='draw the raw 16x16 crop '
                    'windows instead of the assembled 32x20 province maps')
    ap.add_argument('--view', choices=('terrain', 'raw'), default='terrain',
                    help='PNG colouring: decoded terrain id, or tile byte as '
                    'brightness ($80+ blocked = magenta)')
    ap.add_argument('--provinces', default=None, help='comma list of province '
                    'ids (default: every province whose zones lie in --bank)')
    ap.add_argument('--zone-list', default=None, help='comma list of zone ids '
                    '(default: every zone routed to --bank)')
    ap.add_argument('--ascii', action='store_true',
                    help='also print each drawn map as a char grid')
    ap.add_argument('--model', choices=('authored', 'engine'), default='authored',
                    help='authored (default): 15 upper + 5 lower content rows. '
                    'engine: what @GetTileTerrain actually reads (y >= $10, '
                    'y & 15), which lands on a ribbon gap row at y=15')
    ap.add_argument('--width', type=int, default=MAP_COLS,
                    help='columns to draw: %d authored (default), %d = the '
                    'engine query bound X < $1F, or fewer'
                    % (MAP_COLS, ENGINE_X_LIMIT))
    ap.add_argument('--cell', type=int, default=6, help='pixels per map cell')
    ap.add_argument('--scale', type=int, default=2, help='sheet magnification')
    ap.add_argument('--cols', type=int, default=0, help='sheet columns '
                    '(default 8 for zones, 5 for provinces)')
    ap.add_argument('--no-png', action='store_true', help='skip the png sheet')
    ap.add_argument('--out-prefix', default=None,
                    help='output stem (default output/bank_<bank>_terrain)')
    ap.add_argument('--verify-asm', metavar='ASM', nargs='?',
                    const=os.path.join(ROOT, 'asm', 'banks', 'prg_08_09_tactical_war.asm'),
                    help='check the ROM tables against the disassembly hex '
                    'comments and exit')
    ap.add_argument('--check-provinces', action='store_true',
                    help='verify the 30 x 4-quadrant province model and exit')
    ap.add_argument('--check-geometry', action='store_true',
                    help='prove the 15 + 5 content-row split from the $00 gap '
                    'rows and exit')
    ap.add_argument('--check-layout', action='store_true',
                    help='verify the zone ribbon packing and exit')
    ap.add_argument('--check-alias', action='store_true',
                    help='verify Battle Mode\'s copy of the tables and exit')
    args = ap.parse_args()

    if args.verify_asm:
        return 0 if verify_against_asm(args.verify_asm) else 1
    if args.check_provinces:
        print('province/quadrant model:')
        return 0 if check_provinces() else 1
    if args.check_geometry:
        print('crop geometry (tile $00 = ribbon gap rows, 120 crops):')
        return 0 if check_geometry() else 1
    if args.check_alias:
        print('Field-map alias (bank $%02X):' % FIELDMAP_BANK)
        return 0 if check_alias() else 1

    _, map_ptrs, bank_table = load_tables()
    zones = load_zones()
    groups, _ = load_zone_groups()

    if args.bank.lower() == 'all':
        stem_bank, bank_zones = 'all', list(range(MAP_PTR_COUNT))
    else:
        bank = int(args.bank, 16) & 0x1F
        stem_bank = '%02d' % bank
        bank_zones = [z for z in range(MAP_PTR_COUNT)
                      if bank_table[z] & 0x1F == bank]

    if args.check_layout:
        first = bank_zones[0]
        print('bank %s layout:' % args.bank)
        bad = check_layout(read_bank(bank_table[first] & 0x1F), map_ptrs, bank_zones)
        return 0 if bad == 0 else 1

    stem = args.out_prefix or os.path.join(OUT_DIR, 'bank_%s_terrain' % stem_bank)
    os.makedirs(os.path.dirname(stem), exist_ok=True)

    if args.zones:
        selected = ([int(z, 0) for z in args.zone_list.split(',')]
                    if args.zone_list else bank_zones)
        items = zone_items(zones, selected)
        cols = args.cols or 8
        suffix = '_zones'
        header = 'zone,province,quadrant,y,x,cpu,tile,terrain,terrain_name'
        rows = []
        for z in selected:
            ptr, bank_id, tiles, terrain = zones[z]
            print('zone %3d  prov %2d %s  bank $%02X $%04X-$%04X  ptr $%04X  %s'
                  % (z, z // 4, ZONE_GROUP[z % 4], bank_id,
                     ptr - WINDOW_CPU, ptr - WINDOW_CPU + MAP_SIZE - 1, ptr,
                     histogram_text(terrain, tiles)))
            for y in range(GRID):
                for x in range(GRID):
                    i = y * GRID + x
                    rows.append((z, z // 4, ZONE_GROUP[z % 4], y, x,
                                 ptr + i, tiles[i], terrain[i],
                                 TERRAIN.get(terrain[i], ('?', None))[0]))
            if args.ascii:
                print('  ' + '\n  '.join(
                    ''.join(' ' if y in gap_rows(z)
                            else cell_char(tiles[y * GRID + x],
                                           terrain[y * GRID + x])
                            for x in range(GRID)) for y in range(GRID)))
                print('')
    else:
        provinces = ([int(p, 0) for p in args.provinces.split(',')]
                     if args.provinces else
                     sorted({z // 4 for z in bank_zones}))
        items = province_items(groups, zones, provinces, args.model, args.width)
        cols = args.cols or 5
        suffix = '_provinces'
        header = 'province,y,x,zone,quadrant,cpu,tile,terrain,terrain_name'
        rows = []
        for p in provinces:
            cells = province_cells(p, groups, zones, args.model, args.width)
            print('province %2d  %dx%d %s  %s'
                  % (p, args.width, MAP_H, ' '.join('%s=zone%d'
                                                     % (QUADRANTS[q],
                                                        groups[p * 4 + q])
                                                     for q in range(4)),
                     histogram_text([c[6] for c in cells],
                                    [c[5] for c in cells])))
            for (x, y, zone, q, cpu, tile, terrain) in cells:
                rows.append((p, y, x, zone, QUADRANTS[q], cpu, tile, terrain,
                             TERRAIN.get(terrain, ('?', None))[0]))
            if args.ascii:
                for y in range(MAP_H):
                    print('  ' + ''.join(
                        cell_char(c[5], c[6]) for c in cells if c[1] == y))
                print('')

    csv_path = stem + suffix + '.csv'
    with open(csv_path, 'w') as cf:
        cf.write(header + '\n')
        for r in rows:
            cf.write(','.join(str(v) for v in r) + '\n')
    print('csv  -> %s (%d cells)' % (csv_path, len(rows)))

    if not args.no_png:
        img = render_sheet(items, cols, args.cell, 8, args.scale, args.view)
        png_path = stem + suffix + '.png'
        w, h = write_png(png_path, img)
        print('png  -> %s (%dx%d px, %d maps of %dx%d cells)'
              % (png_path, w, h, len(items),
                 items[0][1] if items else 0, items[0][2] if items else 0))
    return 0


if __name__ == '__main__':
    sys.exit(main())
