#!/usr/bin/env python3
"""Model for the tactical terrain banks $00/$03/$04/$05: ROM <-> CSV <-> asm.

This is the single codec shared by

  * `tools/gen_terrain_asm.py`        - renders `asm/banks/data_XX.asm` (+ CSV)
  * `tools/verify_terrain_banks.py`   - assembles those banks, proves byte-exactness
  * `tools/check_terrain_pipeline.py` - proves the whole loop is lossless
  * `editor/tactical_map_editor.py`   - the standalone tactical-map GUI editor

The 120 terrain quadrant crops of the game's 30 provinces are spread over four
`$8000-$9FFF` data banks (`@GetTileTerrain` $B6EF reads them through
TerrainMapPtrTable + TileBankTable in bank `$08`):

| Zones | Provinces | Physical bank | Ribbon block head |
|---|---|---|---|
| 0-31 | 0-7 | `$00` | `$8040` |
| 32-55 | 8-13 | `$03` | `$89A6` |
| 56-63 | 14-15 | `$05` | `$9540` (2nd run, after provinces 24-29) |
| 64-95 | 16-23 | `$04` | `$8040` |
| 96-119 | 24-29 | `$05` | `$8040` |

Every bank carries the same ribbon geometry (layout doc §4): blocks of `$1C0`
bytes, an upper crop window (256 B) at block+`$000`, a 48 B pad at block+`$100`
and a lower crop window at block+`$130`, whose rows 9-15 are physically the next
block's rows 0-6. Bank `$03` is the odd one out: its ribbon starts at `$89A6`, so
the first `$09A6` bytes are other (unanalysed) data, not terrain.

Layout and field evidence: `code/bank_00_data_layout.md` (its §4/§5/§6 model
holds verbatim in all four banks, verified by §8.1's checks).

Editing surface design
----------------------
Every byte of a bank belongs to exactly one *owner* region, so each bank's CSV is
lossless in both directions and never stores a byte twice:

    crop           a 16x16 window, cut where the next window starts, so the
                   ribbon overlap is stored once and aliased on read
    pad            the 48 B inter-crop gap (Battle Mode's overlay crop source)
    overlay head   the first 64 B when the ribbon starts at $0040 (zone 0's
                   Battle Mode overlay crop)
    filler         an all-$FF tail
    unanalysed     everything else (bank $03's leading $09A6 bytes)

CSV shape (one row per up-to-16 physical bytes, in offset order):

    offset,kind,zone,province,quadrant,crop_row,t0..t15

A region whose length is not a multiple of 16 ends with a short row: the unused
tile columns are left empty, never zero-filled. Tile bytes - not terrain ids -
are stored, because `TileTerrainTable` collapses 128 tile ids into 9 terrain
classes and the reverse mapping is not unique (§5).
"""
import csv
import os
from collections import namedtuple

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRG_DIR = os.path.join(ROOT, 'rom', 'prg')

BANK_SIZE = 0x2000
WINDOW_CPU = 0x8000              # banks are only ever mapped into $8000-$9FFF

# --- geometry (layout doc §1/§4) ----------------------------------------
GRID = 16                        # crop edge in cells
CROP_BYTES = GRID * GRID         # 256 B window per zone
ZONE_COUNT = 120                 # 30 provinces x 4 quadrants
PROVINCES = ZONE_COUNT // 4
TERRAIN_BANKS = (0x00, 0x03, 0x04, 0x05)   # what TileBankTable selects
MAP_H = 20                       # authored map height: rows 0-14 + 15-19
MAP_COLS = 32                    # authored map width: 16 + 16 crops
TOP_ROWS = 15                    # content rows in an upper crop
BOTTOM_ROWS = 5                  # content rows in a lower crop
GAP_ROWS_UPPER = (15,)           # ribbon $00 gaps inside an upper window
GAP_ROWS_LOWER = (5, 6, 7, 8)    # ... and inside a lower window
BLOCKED = 0x80                   # tile >= $80 -> terrain 0, no table lookup
PAD_LEN = 0x30                   # inter-crop gap, addressed by no terrain zone
OVERLAY_HEAD_LEN = 0x40          # Battle Mode overlay crop ahead of a $8040 ribbon

# Zone order inside a province is column-major: TL, BL, TR, BR (§2).
QUAD_NAMES = ('TL', 'BL', 'TR', 'BR')
QUAD_UPPER = ('TL', 'TR')        # crops supplying authored map rows 0-14
CSV_COLUMNS = (['offset', 'kind', 'zone', 'province', 'quadrant', 'crop_row']
               + ['t%d' % i for i in range(GRID)])

# Terrain classes as the engine sees them (layout doc §6). Ids >= 6 are clamped
# to 2 by `@GetTileTerrainClamped` ($B6E5), so 6/7/8 stay unresolved labels.
TERRAIN_NAMES = {0: 'Forest', 1: 'Sandland', 2: 'Plain', 3: 'River',
                 4: 'Mountain', 5: 'Castle', 6: 'Special6', 7: 'Special7',
                 8: 'Special8'}
TERRAIN_CHAR = {0: 'f', 1: 's', 2: 'p', 3: 'r', 4: 'm', 5: 'c',
                6: '6', 7: '7', 8: '8'}
TERRAIN_RGB = {
    0: (0x2E, 0x7D, 0x32), 1: (0xE0, 0xC8, 0x7A), 2: (0xB8, 0xE8, 0x9A),
    3: (0x3A, 0x7E, 0xD0), 4: (0x8C, 0x6A, 0x4A), 5: (0x8D, 0x3A, 0x3A),
    6: (0xC0, 0x80, 0xE0), 7: (0x60, 0x60, 0x60), 8: (0xF0, 0xF0, 0xF0),
}

# --- the three driver tables, resident in PRG bank $08 ------------------
# Embedded so the editor and the asm comments work without the split ROM on
# disk; `tools/verify_terrain_banks.py` re-reads them from rom/prg/prg_08.bin
# and fails if a copy ever drifts.
#
# TileTerrainTable ($B74B): tile byte $00-$7F -> terrain id.
TILE_TERRAIN_TABLE = (
    0x00, 0x01, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
    0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x02, 0x02, 0x02, 0x02,
    0x04, 0x04, 0x02, 0x04, 0x04, 0x02, 0x04, 0x02, 0x04, 0x04, 0x04, 0x02, 0x00, 0x00, 0x02, 0x02,
    0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x02, 0x00, 0x00, 0x00, 0x02, 0x02, 0x02, 0x02,
    0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x04, 0x02, 0x02, 0x04, 0x02, 0x04, 0x04, 0x04, 0x03, 0x00,
    0x00, 0x05, 0x05, 0x05, 0x05, 0x03, 0x00, 0x03, 0x03, 0x03, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02,
    0x01, 0x02, 0x02, 0x02, 0x01, 0x02, 0x02, 0x03, 0x03, 0x06, 0x07, 0x08, 0x00, 0x00, 0x00, 0x00,
)
# TerrainMapPtrTable ($B7CB): zone id -> bank offset of its 16x16 crop.
TERRAIN_MAP_PTR = (
    0x0040, 0x0170, 0x0200, 0x0330, 0x03C0, 0x04F0, 0x0580, 0x06B0, 0x0740, 0x0870,
    0x0900, 0x0A30, 0x0AC0, 0x0BF0, 0x0C80, 0x0DB0, 0x0E40, 0x0F70, 0x1000, 0x1130,
    0x11C0, 0x12F0, 0x1380, 0x14B0, 0x1540, 0x1670, 0x1700, 0x1830, 0x18C0, 0x19F0,
    0x1A80, 0x1BB0, 0x09A6, 0x0AD6, 0x0B66, 0x0C96, 0x0D26, 0x0E56, 0x0EE6, 0x1016,
    0x10A6, 0x11D6, 0x1266, 0x1396, 0x1426, 0x1556, 0x15E6, 0x1716, 0x17A6, 0x18D6,
    0x1966, 0x1A96, 0x1B26, 0x1C56, 0x1CE6, 0x1E16, 0x1540, 0x1670, 0x1700, 0x1830,
    0x18C0, 0x19F0, 0x1A80, 0x1BB0, 0x0040, 0x0170, 0x0200, 0x0330, 0x03C0, 0x04F0,
    0x0580, 0x06B0, 0x0740, 0x0870, 0x0900, 0x0A30, 0x0AC0, 0x0BF0, 0x0C80, 0x0DB0,
    0x0E40, 0x0F70, 0x1000, 0x1130, 0x11C0, 0x12F0, 0x1380, 0x14B0, 0x1540, 0x1670,
    0x1700, 0x1830, 0x18C0, 0x19F0, 0x1A80, 0x1BB0, 0x0040, 0x0170, 0x0200, 0x0330,
    0x03C0, 0x04F0, 0x0580, 0x06B0, 0x0740, 0x0870, 0x0900, 0x0A30, 0x0AC0, 0x0BF0,
    0x0C80, 0x0DB0, 0x0E40, 0x0F70, 0x1000, 0x1130, 0x11C0, 0x12F0, 0x1380, 0x14B0,
)
# TileBankTable ($B8BB): zone id -> physical PRG bank (register value & $1F).
TILE_BANK_TABLE = (
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
    0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x05, 0x05, 0x05, 0x05,
    0x05, 0x05, 0x05, 0x05, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
    0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x05, 0x05, 0x05, 0x05,
    0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
)


# --- addressing ---------------------------------------------------------
def zone_bank(zone):
    """Physical PRG bank holding one zone's crop ($00/$03/$04/$05)."""
    return TILE_BANK_TABLE[zone] & 0x1F


def zone_offset(zone):
    """Bank offset of a zone's 16x16 crop window."""
    return TERRAIN_MAP_PTR[zone]


def zone_cpu(zone):
    return WINDOW_CPU + TERRAIN_MAP_PTR[zone]


def zone_meta(zone):
    """(province, quadrant name, is_upper) - zone ids run TL, BL, TR, BR per province."""
    quad = QUAD_NAMES[zone % 4]
    return zone // 4, quad, quad in QUAD_UPPER


def province_zones(province):
    """The four zone ids of a province in (TL, BL, TR, BR) order."""
    return tuple(province * 4 + i for i in range(4))


def bank_zones(bank):
    """Zone ids held by one data bank, sorted by their physical offset."""
    zs = [z for z in range(ZONE_COUNT) if zone_bank(z) == bank]
    return sorted(zs, key=zone_offset)


def gap_rows(zone):
    """Ribbon gap rows of a crop window - never authored terrain (§1)."""
    return GAP_ROWS_UPPER if zone_meta(zone)[2] else GAP_ROWS_LOWER


def is_gap(zone, row):
    return row in gap_rows(zone)


# --- region walk --------------------------------------------------------
class Region(namedtuple('Region',
                        'bank kind start length zone province quadrant first_row')):
    """One physically owned slice of a bank, emitted as up-to-16-byte lines."""
    __slots__ = ()

    @property
    def end(self):
        return self.start + self.length

    @property
    def row_count(self):
        return -(-self.length // GRID)          # ceil: a short tail is its own row

    def row_span(self, index):
        """(offset, length) of one emitted line."""
        start = self.start + index * GRID
        return start, min(GRID, self.end - start)

    @property
    def label(self):
        if self.kind == 'crop':
            return zone_label(self.zone)
        if self.kind == 'pad':
            return PAD_LABEL % (self.bank, self.zone)
        if self.kind == 'overlay_head':
            return HEAD_LABEL % self.bank
        if self.kind == 'filler':
            return FILLER_LABEL % self.bank
        return OTHER_LABEL % (self.bank, self.start)

    @property
    def desc(self):
        """Short region description for the asm section header."""
        if self.kind == 'crop':
            return ('zone %03d - province %d %s 16x16 crop window, rows 0-%d '
                    'owned here' % (self.zone, self.province, self.quadrant,
                                    self.first_row + self.row_count - 1))
        return self.note

    @property
    def note(self):
        if self.kind == 'crop':
            return ''
        if self.kind == 'pad':
            return ('pad between crops %d/%d - no terrain zone reads it, Battle '
                    'Mode overlay source (§7)'
                    % (self.zone, self.zone + 1))
        if self.kind == 'overlay_head':
            return ('overlay head - Battle Mode overlay crop of the first zone, '
                    'no terrain zone points here (§7)')
        if self.kind == 'filler':
            return '$FF bank filler'
        return 'unanalysed data (not terrain) - kept as hex, editable with care'


HEAD_LABEL = 'TerrainOverlayHead_B%02X'
PAD_LABEL = 'TerrainPad_B%02X_Z%03d'
FILLER_LABEL = 'TerrainFFFiller_B%02X'
OTHER_LABEL = 'TerrainOther_B%02X_%04X'
ZONE_LABEL = 'TerrainCrop_Z%03d_P%02d_%s'

_REGION_CACHE = {}


def regions(bank):
    """The owned slices of one terrain bank, in physical offset order.

    A crop window owns bytes up to the point where the next window starts, which
    is exactly how the ribbon overlap resolves: an odd crop's rows 9-15 are
    physically the next block's rows 0-6 and are owned by that next window.
    """
    if bank in _REGION_CACHE:
        return _REGION_CACHE[bank]
    zones = bank_zones(bank)
    crops = []
    for i, zone in enumerate(zones):
        start = zone_offset(zone)
        limit = BANK_SIZE
        if i + 1 < len(zones):
            limit = min(limit, zone_offset(zones[i + 1]))
        length = min(CROP_BYTES, limit - start)
        prov, quad, _ = zone_meta(zone)
        crops.append(Region(bank, 'crop', start, length, zone, prov, quad, 0))
    out = []
    cursor = 0
    for index, crop in enumerate(crops):
        if crop.start > cursor:
            out.append(_gap_region(bank, cursor, crop.start, crops[index - 1]
                                   if index else None, crop))
        out.append(crop)
        cursor = crop.end
    if cursor < BANK_SIZE:
        out.append(_tail_region(bank, cursor))
    total = sum(r.length for r in out)
    if total != BANK_SIZE:
        raise AssertionError('bank $%02X regions cover %d bytes, want %d'
                             % (bank, total, BANK_SIZE))
    _REGION_CACHE[bank] = out
    return out


def _gap_region(bank, start, end, upper, lower):
    """Classify an unowned span between two crop regions.

    Only two shapes occur: the 64-byte Battle Mode overlay head in front of a
    ribbon that starts at `$0040`, and the 48-byte inter-crop pad at block+`$100`
    between a pair's upper and lower crop (`code/bank_00_data_layout.md` §4, §9).
    """
    length = end - start
    if start == 0 and length == OVERLAY_HEAD_LEN:
        return Region(bank, 'overlay_head', start, length, None, None, '', None)
    if (length == PAD_LEN and upper is not None and lower is not None
            and upper.zone % 2 == 0 and upper.end == start
            and lower.start == end):
        # the gap inside one block, between its upper (even) and lower (odd) crop
        return Region(bank, 'pad', start, length, upper.zone, upper.zone // 4,
                      '', None)
    return Region(bank, 'unanalysed', start, length, None, None, '', None)


def _tail_region(bank, start):
    """The span after the last crop window: $FF filler or unanalysed data."""
    kind = 'filler' if _tail_is_ff(bank, start) else 'unanalysed'
    return Region(bank, kind, start, BANK_SIZE - start, None, None, '', None)


_FF_CACHE = {}


def _tail_is_ff(bank, start):
    """Is everything from `start` to the bank end plain $FF padding?"""
    key = (bank, start)
    if key not in _FF_CACHE:
        try:
            data = read_bank(bank)
        except OSError:
            return True              # no ROM to check against: assume filler
        _FF_CACHE[key] = all(b == 0xFF for b in data[start:BANK_SIZE])
    return _FF_CACHE[key]


def pad_province(bank, region):
    """Province whose crop pair a pad sits between (pads belong to a block)."""
    return region.zone // 4 if region.zone is not None else None

# --- ownership / aliasing ----------------------------------------------
_OWNER_CACHE = {}


def owner_map(bank):
    """[(offset -> Region)] for crop bytes, used to resolve the ribbon overlap."""
    if bank not in _OWNER_CACHE:
        table = {}
        for reg in regions(bank):
            if reg.kind == 'crop':
                for off in range(reg.start, reg.end):
                    table[off] = reg
        _OWNER_CACHE[bank] = table
    return _OWNER_CACHE[bank]


def cell_owner(zone, row, col):
    """(owner zone, owner row, bank, offset) of one crop-window cell.

    Reading a crop window at an aliased row (an odd crop's rows 9-15) lands in
    the next block, so edits must go through the owner or they would be lost.
    """
    bank = zone_bank(zone)
    off = zone_offset(zone) + row * GRID + col
    reg = owner_map(bank).get(off)
    if reg is None:
        # the byte is inside the window but not owned by any crop (bank $03's
        # trailing filler, zone 31's $FF tail): it belongs to this window only
        return zone, row, bank, off
    return reg.zone, (off - reg.start) // GRID, bank, off


# --- terrain decoding --------------------------------------------------
def tile_terrain(tile, table=None):
    """Terrain id of one tile byte, following `@GetTileTerrain` (§1 step 6)."""
    table = table or TILE_TERRAIN_TABLE
    return 0 if tile >= BLOCKED else table[tile]


def terrain_clamped(tid):
    """`@GetTileTerrainClamped` folds ids >= 6 into 2 = Plain."""
    return 2 if tid >= 6 else tid


def terrain_name(tile, table=None):
    return TERRAIN_NAMES.get(tile_terrain(tile, table), '?')


def terrain_char(tile, table=None):
    """One-char preview for asm comments: terrain, or '@' for a blocked tile."""
    return '@' if tile >= BLOCKED else TERRAIN_CHAR.get(tile_terrain(tile), '?')


def terrain_grid_text(tiles, table=None):
    """16 terrain glyphs for one crop row."""
    return ''.join(terrain_char(t, table) for t in tiles)


def load_driver_tables():
    """(TileTerrainTable, TerrainMapPtrTable, TileBankTable) from bank $08.

    Returns None when the ROM dump is absent, so the embedded copies above stay
    authoritative for standalone use while the verifier can still cross-check.
    """
    path = os.path.join(PRG_DIR, 'prg_08.bin')
    if not os.path.exists(path):
        return None
    with open(path, 'rb') as f:
        code = f.read()
    base = 0xB74B - 0xA000              # CPU $B74B inside bank $08 ($A000 window)
    if len(code) < base + 128 + (0xB8BB - 0xB74B) + 120:
        return None
    tt = tuple(code[base:base + 128])
    ptr_raw = code[0xB7CB - 0xA000:0xB7CB - 0xA000 + ZONE_COUNT * 2]
    bank = tuple(code[0xB8BB - 0xA000:0xB8BB - 0xA000 + ZONE_COUNT])
    ptr = tuple((ptr_raw[i] | ptr_raw[i + 1] << 8) - WINDOW_CPU
                for i in range(0, ZONE_COUNT * 2, 2))
    return tt, ptr, tuple(b & 0x1F for b in bank)


def read_bank(bank):
    with open(os.path.join(PRG_DIR, 'prg_%02x.bin' % bank), 'rb') as f:
        return f.read()


# --- grids (the editing views) -----------------------------------------
def zone_grid(get_byte, zone):
    """16x16 tile bytes of a crop window, as the engine addresses it."""
    bank = zone_bank(zone)
    base = zone_offset(zone)
    return [[get_byte(bank, base + y * GRID + x) for x in range(GRID)]
            for y in range(GRID)]


def province_cells(province):
    """[(x, y, zone, bank, crop_row, offset)] of one authored 32 x 20 map.

    Rows 0-14 come from the upper crops' rows 0-14, rows 15-19 from the lower
    crops' rows 0-4 - the authored 15 + 5 split, not the engine's off-by-one
    16/4 read (§1). All four crops of a province live in one bank.
    """
    zone_tl, zone_bl, zone_tr, zone_br = province_zones(province)
    grid = []
    for y in range(MAP_H):
        line = []
        for x in range(MAP_COLS):
            if x < GRID:
                zone = zone_tl if y < TOP_ROWS else zone_bl
            else:
                zone = zone_tr if y < TOP_ROWS else zone_br
            row = y if y < TOP_ROWS else y - TOP_ROWS
            off = zone_offset(zone) + row * GRID + (x & 15)
            line.append((x, y, zone, zone_bank(zone), row, off))
        grid.append(line)
    return grid


def province_map(get_byte, province):
    """[[tile]] of one province's authored 32 x 20 map."""
    return [[get_byte(cell[3], cell[5]) for cell in row]
            for row in province_cells(province)]


# --- rows: the CSV/asm serialization ----------------------------------
def rows_from_bank(bank, data):
    """Flatten one bank into owner-keyed rows (physical order)."""
    if len(data) != BANK_SIZE:
        raise ValueError('bank $%02X must be %d bytes, got %d'
                         % (bank, BANK_SIZE, len(data)))
    rows = []
    for reg in regions(bank):
        for index in range(reg.row_count):
            off, length = reg.row_span(index)
            crop_row = ('' if reg.first_row is None
                        else str(reg.first_row + index))
            rows.append({
                'offset': '$%04X' % off,
                'kind': reg.kind,
                'zone': '' if reg.zone is None else '%03d' % reg.zone,
                'province': '' if reg.province is None else str(reg.province),
                'quadrant': reg.quadrant,
                'crop_row': crop_row,
                'length': length,
                'tiles': list(data[off:off + length]),
            })
    return rows


def bank_from_rows(bank, rows, template=None):
    """Rebuild the 8KB image from CSV rows; every byte has exactly one owner."""
    data = bytearray(template if template is not None else
                     bytes([0xFF]) * BANK_SIZE)
    seen = set()
    for r in rows:
        off = parse_int(r['offset'])
        tiles = [parse_int(t) for t in r['tiles'] if str(t).strip() != '']
        if not 1 <= len(tiles) <= GRID:
            raise ValueError('row %s has %d tile columns, expected 1-%d'
                             % (r['offset'], len(tiles), GRID))
        if any(not 0 <= t <= 0xFF for t in tiles):
            raise ValueError('row %s holds a byte outside $00-$FF' % r['offset'])
        if off in seen:
            raise ValueError('duplicate owner row at $%04X' % off)
        seen.add(off)
        data[off:off + len(tiles)] = bytes(tiles)
    covered = sum(1 for r in rows
                  for i in range(len([t for t in r['tiles']
                                      if str(t).strip() != ''])))
    if covered != BANK_SIZE:
        raise ValueError('rows of bank $%02X cover %d bytes, expected %d'
                         % (bank, covered, BANK_SIZE))
    return bytes(data)


def parse_int(text):
    """Accept `$44`, `44`, `0x44` or an int - the CSV is hand-editable."""
    if isinstance(text, int):
        return text
    s = str(text).strip().replace('$', '').replace('0x', '').replace('0X', '')
    return int(s, 16) if s else 0


def csv_path(bank, root=None):
    return os.path.join(root or ROOT, 'docs', 'terrain_bank_%02x.csv' % bank)


def asm_path(bank, root=None):
    return os.path.join(root or ROOT, 'asm', 'banks', 'data_%02x.asm' % bank)


def csv_write(path, rows):
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        w.writerow(CSV_COLUMNS)
        for r in rows:
            cells = ['$%02X' % t for t in r['tiles']]
            cells += [''] * (GRID - len(cells))   # short tail row: empty, not $00
            w.writerow([r['offset'], r['kind'], r['zone'], r['province'],
                        r['quadrant'], r['crop_row']] + cells)


def csv_read(path, bank=None):
    """Parse a bank CSV back into rows; blank/unknown lines are skipped."""
    rows = []
    with open(path, encoding='utf-8', newline='') as f:
        for record in csv.DictReader(f):
            if not (record.get('offset') or '').strip():
                continue
            tiles = [record['t%d' % i] for i in range(GRID)]
            filled = [t for t in tiles if str(t).strip() != '']
            rows.append({
                'offset': record['offset'].strip(),
                'kind': (record['kind'] or '').strip(),
                'zone': (record['zone'] or '').strip(),
                'province': (record['province'] or '').strip(),
                'quadrant': (record['quadrant'] or '').strip(),
                'crop_row': (record['crop_row'] or '').strip(),
                'length': len(filled),
                'tiles': [parse_int(t) for t in filled],
            })
    total = sum(r['length'] for r in rows)
    if total != BANK_SIZE:
        raise ValueError('%s covers %d bytes, expected %d (bank $%02X)'
                         % (os.path.basename(path), total, BANK_SIZE,
                            bank if bank is not None else 0))
    return rows


# --- assembly rendering ------------------------------------------------
def zone_label(zone):
    """Label of one crop's data region, naming zone, province and quadrant."""
    prov, quad, _ = zone_meta(zone)
    return ZONE_LABEL % (zone, prov, quad)


def bank_asm_label(bank):
    return 'CODE_BANK%02X' % bank


ASM_TITLE = {
    'crop': 'terrain crop',
    'pad': 'pad',
    'overlay_head': 'overlay head',
    'filler': '$FF filler',
    'unanalysed': 'unanalysed',
}


def asm_text(bank, rows, source_note, table=None):
    """Render one terrain bank as labelled `.byte` hex, one line per map row.

    `source_note` says where the bytes came from (stock ROM or the CSV), so the
    generated file is self-documenting about its editing surface.
    """
    table = table or TILE_TERRAIN_TABLE
    lines = [
        ';===============================================================================',
        '; DATA Bank %02X (PRG $%02X) - 8KB terrain bank, mapped into $8000-$9FFF by'
        % (bank, bank),
        '; SwitchBank8; no code lives here (see code/bank_switch_map.md 5.2).',
        ';',
        '; GENERATED by tools/gen_terrain_asm.py --write - byte-exactness is enforced by',
        '; tools/verify_terrain_banks.py. Edit the terrain through docs/terrain_bank_%02x.csv'
        % bank,
        '; (or editor/tactical_map_editor.py) and regenerate; keep this file and the CSV',
        '; in step.',
        ';',
        '; Content: %s' % _bank_content_summary(bank),
        '; GetTileTerrain ($B6EF) reads them through TileBankTable + the ($A8) province',
        '; zone table; 4 crops form one province 32x20 tactical map (15 content rows from',
        '; the upper crops, 5 from the lower); Battle Mode re-reads the same bytes.',
        '; Layout: code/bank_00_data_layout.md (sections cited per region below).',
        ';',
        '; Byte source: %s' % source_note,
        '; Row comment: bank offset, zone/province/quadrant, crop row, then one glyph',
        ';   per cell - f Forest, s Sandland, p Plain, r River, m Mountain, c Castle,',
        ';   6/7/8 unresolved, @ blocked (tile >= $80), . ribbon gap row (tile $00).',
        ';===============================================================================',
        '',
        '.segment "%s"' % bank_asm_label(bank),
    ]
    by_offset = {parse_int(r['offset']): r for r in rows}
    if len(by_offset) != len(rows):
        raise ValueError('CSV rows carry duplicate offsets - not a full map')
    for reg in regions(bank):
        lines.append('')
        lines.append('; --- $%04X-$%04X  %s ---' % (WINDOW_CPU + reg.start,
                                                    WINDOW_CPU + reg.end - 1,
                                                    reg.desc))
        lines.append('%s:' % reg.label)
        for index in range(reg.row_count):
            off, length = reg.row_span(index)
            r = by_offset[off]
            lines.append(_byte_line(r['tiles'], _row_comment(off, r, length,
                                                             table)))
    lines.append('')
    return '\n'.join(lines) + '\n'


def _bank_content_summary(bank):
    zones = bank_zones(bank)
    provs = sorted({zone_meta(z)[0] for z in zones})
    return ('%d terrain quadrant crops (16x16 cells, 1 tile byte each) = '
            'provinces %s (zones %d-%d)'
            % (len(zones), _ranges(provs), zones[0], zones[-1]))


def _ranges(values):
    """Compact '8-13, 14-15' style list of consecutive province ids."""
    out, start, prev = [], None, None
    for v in list(values) + [None]:
        if start is None:
            start = prev = v
            continue
        if v != prev + 1:
            out.append(str(start) if start == prev else '%d-%d' % (start, prev))
            start = prev = v
        else:
            prev = v
    return ', '.join(out)


def _byte_line(tiles, comment):
    body = ', '.join('$%02X' % t for t in tiles)
    return '  .byte %-46s ; %s' % (body, comment)


def _row_comment(off, r, length, table):
    """`; $8040  z000 P00 TL r00  <glyphs>` - address, ownership, terrain preview."""
    parts = ['$%04X' % (WINDOW_CPU + off)]
    kind = r['kind']
    if kind == 'crop':
        zone = int(r['zone'])
        row = int(r['crop_row'])
        glyphs = terrain_grid_text(r['tiles'], table)
        parts.append('z%-3s' % r['zone'])
        parts.append('P%-2s %s' % (r['province'], r['quadrant']))
        parts.append('r%02d' % row)
        if is_gap(zone, row):
            # a gap row is blank by authoring, but $FF filler can overlap it
            parts.append('(ribbon gap row) %s'
                         % (glyphs if any(r['tiles']) else '.' * length))
        else:
            parts.append(glyphs)
    elif kind == 'overlay_head':
        parts.append('overlay head')
        parts.append(''.join(terrain_char(t, table) for t in r['tiles']))
    elif kind == 'unanalysed':
        # not terrain: decoding it as tiles would invent meaning that is not there
        parts.append('%-13s' % 'unanalysed')
        parts.append('(%d bytes, no zone points here)' % length)
    elif kind == 'pad':
        stray = sum(1 for t in r['tiles'] if t)
        parts.append('pad            %2d/%d bytes non-zero' % (stray, length))
    else:
        parts.append('filler')
    return '  '.join(parts)


# --- edit reporting (used by the verifier and the GUI diff view) -------
def describe_edit(stock_row, new_row, table=None):
    """Human line for one differing row: which cell, old -> new meaning."""
    diffs = [(i, a, b) for i, (a, b) in enumerate(zip(stock_row['tiles'],
                                                      new_row['tiles']))
             if a != b]
    if not diffs:
        return None
    off = parse_int(stock_row['offset'])
    where = 'offset $%04X (CPU $%04X)' % (off, WINDOW_CPU + off)
    if stock_row['kind'] == 'crop':
        zone = int(stock_row['zone'])
        prov, quad, _ = zone_meta(zone)
        row = int(stock_row['crop_row'])
        label = ('%s bank $%02X province %d %s crop row %d'
                 % (where, zone_bank(zone), prov, quad, row))
        if is_gap(zone, row):
            label += ' [ribbon gap row - the engine reads it as terrain]'
    else:
        label = '%s %s' % (where, stock_row['kind'])
    changes = ', '.join('col %d $%02X %s -> $%02X %s'
                        % (i, a, terrain_name(a, table),
                           b, terrain_name(b, table))
                        for i, a, b in diffs)
    return '%s: %s' % (label, changes)
