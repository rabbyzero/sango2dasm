#!/usr/bin/env python3
"""Real CHR tile graphics for the tactical (war-layer) map, for the map editor.

The map editor's normal view paints one flat colour per terrain *class*, which
is a decode: `TileTerrainTable` collapses 128 tile ids into 9 classes, so many
different-looking tiles share a colour. This module renders the bytes the way
the console does, through the same chain the war scene uses:

    tile byte -> MetaTileData[$F477 + byte*4] -> 4 nametable bytes (TL,TR,BL,BR)
              -> 8x8 CHR patterns (display record 1 pages) -> NES palette

Evidence for each link:
  * `MetaTileData` $F477, 512 B = 128 entries x 4, in the fixed $E000-$FFFF bank
    (`asm/banks/prg_1f_boot.asm:3585`). `CalcTileAddrHoriz` (`asm/banks/prg_17_18_duel_and_display.asm:1125`)
    computes it as `ASL A / ROL $0009 / ASL A / ROL $0009 / ADC $0002($77) /
    ADC $0003($F4)`, i.e. base + byte*4, indexed by the **raw crop byte**.
  * `CopyTileRowHoriz` (`prg_17_18_duel_and_display.asm:1139`) writes 2 of the 4 bytes per PPU
    row and picks the pair from a row bit, so a cell is 2x2 patterns = 16x16 px.
  * CHR pages come from display record 1 (`88 89 8A 88`), armed for the war
    scene by `State_WarSceneLaunch` - `asm/banks/data_10_seed.asm:200` documents the
    static `TacticalTerrainScreen` with exactly that record and calls the result
    "terrain only - mountain / forest / water dither". Page V -> chr_V//8.bin at
    (V%8)*$400 (`code/font_analysis.md:17`).
  * Palette record 0, loaded for the same screen by `SceneRenderSetup`
    ($BD26-$BD2B) - `tools/render_ppu_screen.py` reads the records from bank $1E.

Each cell's palette comes from the 64-byte NES **attribute head** that precedes
every crop (`FieldMapOverlayPtrTable == TerrainMapPtrTable - $40`). The game's own
indexing is `prg_0c_0d_tactical_commands.asm:7543` (`AND #$0E / LSR / AND #$0E / ASL / ASL / ORA`),
i.e. byte `((x & $0E) >> 1) | ((y & $0E) << 2)` over the 16x16 crop, and the
2-bit field `((y & 1) * 2 + (x & 1))` within it. That is what `head_palette`
below implements, and it is provably the authored terrain palette: across all 30
provinces it assigns sub-palette 1 to *exclusively* River cells and sub-palette 0
to every other class, with no exceptions (`tools/check_terrain_pipeline.py`
section 9 asserts it). Palette record $01 is the one that makes those two
sub-palettes read as the manual's tactical screenshot - gold plains, dark green
pines, solid blue water (record $00 swaps land and water).

Blocked bytes ($80-$FF) have no `MetaTileData` entry at all - the engine never
looks one up - and are reported as None.

Usage:
    python3 tools/terrain_tiles.py                        # province 3 at 2x
    python3 tools/terrain_tiles.py --province all --scale 1
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

import render_ppu_screen as ppu              # noqa: E402  (CHR + palette helpers)

ROOT = os.path.dirname(HERE)
PRG_1F = os.path.join(ROOT, 'rom', 'prg', 'prg_1f.bin')
PRG_1F_WINDOW = 0xE000          # the file holds $E000-$FFFF
METATILE_CPU = 0xF477           # MetaTileData: 128 entries x 4 nametable bytes
METATILE_BYTES = 512
CELL_PX = 16                    # a map cell is 2x2 patterns
HEAD_BYTES = 0x40               # attribute head in front of every crop
DISPLAY_RECORD = (0x88, 0x89, 0x8A, 0x88)   # record 1, the war scene
SPRITE_PAGE = 0x04              # record 1 slot 0: sprite tiles $00-$3F
PALETTE_RECORD = 1              # gold land + blue water, per the manual screenshot
LAND_PALETTE = 0                # the sub-palette every non-River class uses
RIVER_PALETTE = 1               # what the crops' attribute heads say for River

# Settlement objects. These bytes are NOT terrain art: $61's metatile is plain
# ground and $62-$64 (never used in any crop) point into the font page, so the
# building you see is a 16x16 OAM sprite drawn over the cell by
# DrawStratagemTargetMarkers (prg_08_09_tactical_war $D24D) from @ProvinceMarkerOam ($D315)
# and @CityMarkerOam ($D326). Each list is (xoff, tile, attr, yoff); all four
# sprites share attribute $01 = sprite palette 1, colour 0 transparent.
MARKER_TILES = {'castle': (0x02, 0x03, 0x0E, 0x0F),
                'facility': (0x3C, 0x3D, 0x3E, 0x3F)}
MARKER_PALETTE = 1
OBJECT_TILES = {0x61: 'castle', 0x79: 'facility', 0x7A: 'facility',
                0x7B: 'facility'}          # terrain 5 / 6 / 7 / 8
FACILITY_CPU = 0x9BA4             # ProvinceTacticalFacilityTiles, bank $31
FACILITY_ROWS, FACILITY_STRIDE = 30, 6
FACILITY_SLOTS = ('House 民家', 'Armory 武器屋', 'Hospital 病院')


def facility_pair(row, slot):
    """(cell_x, cell_y) of one facility slot, or None when the slot is unused.

    X bit7 marks an unused pair (every reader tests it with BMI/BPL; the
    authored padding is $FF $FF). Y >= $10 is decremented for the map's blank
    gap row, the same fixup the march readers and `AiExecuteMove` apply.
    """
    x, y = row[2 * slot], row[2 * slot + 1]
    if x >= 0x80:
        return None
    return (x, y - 1 if y >= 0x10 else y)


def load_facilities(root=None):
    """30 x 3 facility cells from bank $31, or None when the ROM is missing."""
    path = os.path.join(root or ROOT, 'rom', 'prg', 'prg_11.bin')
    try:
        with open(path, 'rb') as f:
            f.seek(FACILITY_CPU - 0x8000)
            blob = f.read(FACILITY_ROWS * FACILITY_STRIDE)
    except OSError:
        return None
    if len(blob) != FACILITY_ROWS * FACILITY_STRIDE:
        return None
    return [[facility_pair(blob[p * FACILITY_STRIDE:(p + 1) * FACILITY_STRIDE], s)
             for s in range(3)] for p in range(FACILITY_ROWS)]


def head_palette(head, cx, cy):
    """2-bit BG sub-palette of crop cell (cx, cy) from its 64-byte head.

    Indexing copied from the game: `prg_0c_0d_tactical_commands.asm:7543`.
    """
    if not head or len(head) < HEAD_BYTES:
        return LAND_PALETTE
    byte = head[((cx & 0x0E) >> 1) | ((cy & 0x0E) << 2)]
    return (byte >> (((cy & 1) * 2 + (cx & 1)) * 2)) & 3


class TileSet:
    """Decoded CHR graphics for the tactical layer, or why it could not load."""

    def __init__(self, metatile, pages, palette, source):
        self.metatile = metatile
        self.pages = pages
        self.palette = palette
        self.source = source        # what the editor can show in its log
        self.error = None
        self._patterns = {}
        self._rgb = {}

    @property
    def available(self):
        return self.metatile is not None

    def metatile_bytes(self, tile):
        """The 4 nametable bytes (TL,TR,BL,BR) of one tile byte, or None."""
        if not self.available or tile >= 0x80:
            return None             # blocked bytes are never looked up
        off = tile * 4
        return self.metatile[off:off + 4]

    def _pattern(self, nametable):
        key = (self.pages[nametable >> 6], nametable & 0x3F)
        bmp = self._patterns.get(key)
        if bmp is None:
            bmp = self._patterns[key] = ppu.load_tile(*key)
        return bmp

    def cell_rgb(self, tile, bgpal=LAND_PALETTE):
        """16x16 RGB tuples for a tile byte in BG sub-palette `bgpal`.

        `bgpal` is what the crop's attribute head says for that cell - see
        `head_palette`. None for a blocked byte, which has no metatile.
        """
        key = (tile, bgpal)
        if key in self._rgb:
            return self._rgb[key]
        entry = self.metatile_bytes(tile)
        if entry is None:
            return None
        rgb = [[(0, 0, 0)] * CELL_PX for _ in range(CELL_PX)]
        pal = self.palette
        back = ppu.NES_RGB[pal[0] & 0x3F]
        for quad, nametable in enumerate(entry):
            pattern = self._pattern(nametable)
            qx, qy = (quad & 1) * 8, (quad >> 1) * 8
            for y in range(8):
                row = pattern[y]
                for x in range(8):
                    ci = row[x]
                    rgb[qy + y][qx + x] = (
                        back if ci == 0
                        else ppu.NES_RGB[pal[1 + 4 * bgpal + ci - 1] & 0x3F])
        self._rgb[key] = rgb
        return rgb

    def marker_rgb(self, kind):
        """16x16 grid of RGB tuples, with None where the sprite is transparent.

        `kind` is 'castle' (@ProvinceMarkerOam) or 'facility' (@CityMarkerOam).
        Sprites use the pattern table at PPU $0000, i.e. display record 1's
        slots 0-3, and sprite palette 1 = buffer bytes 8-10.
        """
        rgb = [[None] * CELL_PX for _ in range(CELL_PX)]
        pal = self.palette
        for quad, tile in enumerate(MARKER_TILES[kind]):
            bmp = ppu.load_tile(SPRITE_PAGE, tile)
            qx, qy = (quad & 1) * 8, (quad >> 1) * 8
            for y in range(8):
                for x in range(8):
                    ci = bmp[y][x]
                    if ci:
                        rgb[qy + y][qx + x] = \
                            ppu.NES_RGB[pal[4 + 4 * MARKER_PALETTE + ci - 1] & 0x3F]
        return rgb

    def summary(self):
        if not self.available:
            return 'unavailable: %s' % self.error
        return ('MetaTileData $%04X + display record %s + palette record $%02X'
                % (METATILE_CPU, ' '.join('%02X' % p for p in self.pages),
                   PALETTE_RECORD))


def load(root=None):
    """Build the tile set from the repo ROM dumps, or a disabled stub."""
    root = root or ROOT
    metatile_path = os.path.join(root, 'rom', 'prg', 'prg_1f.bin')
    try:
        with open(metatile_path, 'rb') as f:
            f.seek(METATILE_CPU - PRG_1F_WINDOW)
            metatile = f.read(METATILE_BYTES)
        if len(metatile) != METATILE_BYTES:
            raise OSError('%s is too short for MetaTileData' % metatile_path)
        palette = ppu.load_palette(PALETTE_RECORD)
    except (OSError, IndexError) as exc:      # standalone mode: no ROM around
        set_ = TileSet(None, DISPLAY_RECORD, None, None)
        set_.error = str(exc)
        return set_
    return TileSet(metatile, DISPLAY_RECORD, palette, metatile_path)


def main(argv=None):
    """Render province maps at their real size, as a check on the mapping."""
    import argparse
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[1],
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--province', default='3', help='0-29 or "all"')
    ap.add_argument('--scale', type=int, default=2)
    ap.add_argument('--out', default=os.path.join(ROOT, 'build'))
    args = ap.parse_args(argv)

    sys.path.insert(0, HERE)
    import terrain_model as model
    tiles = load()
    if not tiles.available:
        raise SystemExit('cannot render: %s' % tiles.error)
    os.makedirs(args.out, exist_ok=True)
    provinces = (range(model.PROVINCES) if args.province == 'all'
                 else [int(args.province)])
    images = {b: model.read_bank(b) for b in model.TERRAIN_BANKS}
    s = max(1, args.scale)
    for prov in provinces:
        w, h = model.MAP_COLS * CELL_PX * s, model.MAP_H * CELL_PX * s
        img = [[(0, 0, 0)] * w for _ in range(h)]
        for cy in range(model.MAP_H):
            for cx in range(model.MAP_COLS):
                zone = (prov * 4 + (0 if cy < model.TOP_ROWS else 1)
                        + (2 if cx >= model.GRID else 0))
                gx = cx if cx < model.GRID else cx - model.GRID
                gy = cy if cy < model.TOP_ROWS else cy - model.TOP_ROWS
                bank = model.zone_bank(zone)
                off = model.zone_offset(zone)
                tile = images[bank][off + gy * model.GRID + gx]
                bgpal = head_palette(images[bank][off - HEAD_BYTES:off], gx, gy)
                rgb = tiles.cell_rgb(tile, bgpal) \
                    or [[(255, 0, 255)] * CELL_PX] * CELL_PX
                for y in range(CELL_PX):
                    for x in range(CELL_PX):
                        for sy in range(s):
                            for sx in range(s):
                                img[cy * CELL_PX * s + y * s + sy][
                                    cx * CELL_PX * s + x * s + sx] = rgb[y][x]
        path = os.path.join(args.out, 'terrain_tiles_p%02d.png' % prov)
        ppu.write_png(path, img)
        print('%s  %dx%d  province %d  (%s)'
              % (path, w, h, prov, tiles.summary()))
    return 0


if __name__ == '__main__':
    sys.exit(main())
