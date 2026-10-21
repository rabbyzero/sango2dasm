#!/usr/bin/env python3
"""Render the bank-$16 command-menu OAM blobs as the sprites the PPU drew.

Bank $16 holds 34 .word tables interleaved with 130 $80-terminated
[y_off, tile, attr, x_off] OAM blobs (tools/gen_data_bank_16_asm.py decodes the
structure; this tool decodes the PICTURE). Each blob is one sprite row of a
strategy result panel, posted by DisplayTileData ($C994, prg_1d_1e_menu_screens)
through B1F_SpriteOamWriterSimple ($F1AD, prg_1f_boot):

    OAM Y   = y_off + $000A      ($000A = $2F  -> screen Y = y_off + $2F)
    OAM X   = x_off + $000C      ($000C = $20 left panel, $90 right panel)
    OAM tile= tile + $0003       ($0003 = 0    -> no tile bias)
    OAM attr= attr XOR $0002     ($0002 = 3    -> stored $00 = palette 3)

CHR: the PPUCTRL mirror is $10 from boot (prg_1f_boot $E0C2, bit 4 set / bit 3
clear) and no code ever changes bits 3-4, so the SPRITE pattern table is PPU
$1000-$1FFF = NAMCO-163 CHR slots 4-7 = menu font record BYTES 4-7 (BG reads
slots 0-3 = bytes 0-3). Slot 4-7 covers tile ids $00-$3F, $40-$7F, $80-$BF,
$C0-$FF in that order, and a page value V is the 1 KB slice
rom/chr/chr_(V//8).bin @ (V%8)*$400. The 14 font records live in bank $01 at
$946C (data_01_bg_and_sprites.asm); --record picks one, and the MenuActions run
under record = action_type($0544)+2 (prg_1f_boot State_StrategyMode $E237/$E252),
so records 2-9. Records 2-4/6 have bytes 4-7 = 95 78 78 18 -> sprite tiles
$40-$BF = chr_0f @ $0000 (the command-scene icon sheet, which also carries the
digits at $74-$7D and precomposed 10/$7E and 100/$7F) and $C0-$FF = chr_03 @
$0000; record 5 swaps slot 5 to $7A and records 7-8 swap slot 4 to $97, record 9
swaps slot 7 to $90. --slots 03 forces the BG bytes instead, which is what the
bank-16 header comment used to assume; it renders the same blobs as noise.

Colour: PaletteRecordLoad ($DBB1) index = the same action_type+2, and its 32-B
record is the $3F00 block (byte 0 backdrop, BG 0-3 at bytes 1/5/9/13, sprite
0-3 at bytes 17/21/25/29). For records 2-9 sprite palette 3 = $20 $27 $17 =
white / gold / black over transparent, palette 2 = $0F $20 $16 $0F.

Usage:
    python3 tools/render_menu_oam_blobs.py                      # every handler
    python3 tools/render_menu_oam_blobs.py --handler 1b --scale 6
    python3 tools/render_menu_oam_blobs.py --cells              # per-glyph strip
    python3 tools/render_menu_oam_blobs.py --tiles 40 bf        # tile id legend
    python3 tools/render_menu_oam_blobs.py --slots 03           # the wrong-reading A/B
"""
import argparse
import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import gen_data_bank_16_asm as gen                        # noqa: E402
from render_ppu_screen import NES_RGB, PALETTE_CPU, load_palette  # noqa: E402

FONT_REC_CPU = 0x946C          # bank $01, 14 x 48 B menu font records
FONT_REC_BYTES = 48
FONT_REC_BANK_FILE = os.path.join(ROOT, 'rom', 'prg', 'prg_01.bin')
TRANSPARENT = (128, 128, 128)  # what the render shows where a sprite pixel is color 0


def font_rec_pages(record, slots):
    """The 4 CHR page bytes for `slots` ('03' = PPU $0000, '47' = PPU $1000)."""
    with open(FONT_REC_BANK_FILE, 'rb') as f:
        f.seek((FONT_REC_CPU - 0x8000) + record * FONT_REC_BYTES + (0 if slots == '03' else 4))
        return list(f.read(4))


def page_of_tile(tile, pages):
    """Slot 4-7 (or 0-3) cover tile ids $00-$3F/$40-$7F/$80-$BF/$C0-$FF."""
    return pages[tile >> 6]


def chr_file(page):
    return os.path.join(ROOT, 'rom', 'chr', 'chr_%02x.bin' % (page // 8))


def chr_offset(page):
    return (page % 8) * 0x400


class TileCache:
    def __init__(self, pages):
        self.pages = pages
        self._chunks = {}
        self._tiles = {}

    def tile(self, tile):
        if tile not in self._tiles:
            page = page_of_tile(tile, self.pages)
            if page not in self._chunks:
                with open(chr_file(page), 'rb') as f:
                    f.seek(chr_offset(page))
                    self._chunks[page] = f.read(0x400)
            chunk = self._chunks[page]
            idx = tile & 0x3F
            rows = []
            for r in range(8):
                lo = chunk[idx * 16 + r]
                hi = chunk[idx * 16 + 8 + r]
                rows.append([(lo >> (7 - c)) & 1 | (((hi >> (7 - c)) & 1) << 1)
                             for c in range(8)])
            self._tiles[tile] = (rows, page)
        return self._tiles[tile]


def sprite_palette(record):
    """{oam palette index: [transparent, colour 1-3 rgb]} for that palette record.
    The record mirrors PPU $3F00-$3F1F, so sprite palette k's colours 1-3 are
    bytes $11+4k..$13+4k of the 32-byte $0100 buffer."""
    pal = load_palette(record)
    return {k: [TRANSPARENT] + [NES_RGB[c] for c in pal[0x11 + 4 * k:0x14 + 4 * k]]
            for k in range(4)}


def font(size=13):
    for path in ('/usr/share/fonts/TTF/DejaVuSansMono-Bold.ttf',
                 '/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf'):
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def paste_tile(px, tile, cache, pals, attr, ox, oy, scale):
    """Draw one 8x8 sprite, honouring the OAM flips and its palette."""
    final_attr = attr ^ 0x03
    rows, _page = cache.tile(tile)
    if final_attr & 0x20:                       # OAM bit 5 = horizontal flip
        rows = [list(reversed(r)) for r in rows]
    if final_attr & 0x40:                       # OAM bit 6 = vertical flip
        rows = list(reversed(rows))
    rgb = pals[final_attr & 3]
    for r in range(8):
        for c in range(8):
            color = rgb[rows[r][c]]
            for sy in range(scale):
                for sx in range(scale):
                    px[(ox + c) * scale + sx, (oy + r) * scale + sy] = color


def blob_panel(blob, cache, pals, scale):
    """One blob at its absolute record offsets - what the panel really showed."""
    recs = blob['recs']
    if not recs:
        return None
    w = max(r[3] for r in recs) + 8
    h = max(r[0] for r in recs) + 8
    img = Image.new('RGB', (w * scale, h * scale), TRANSPARENT)
    px = img.load()
    for (y, tile, attr, x) in recs:
        paste_tile(px, tile, cache, pals, attr, x, y, scale)
    return img


def cells_of(blob):
    """Group a blob's records into glyph cells: the 2x2 sprite block at
    (x,y),(x+8,y),(x,y+8),(x+8,y+8). Partial blocks are kept, so an 8x16 kana
    (two stacked tiles) and a lone 8x8 digit both come out as cells."""
    by_pos = {}
    for (y, tile, attr, x) in blob['recs']:
        by_pos.setdefault((x, y), []).append((tile, attr))
    seen, cells = set(), []
    for (x, y) in sorted(by_pos, key=lambda p: (p[1], p[0])):
        if (x, y) in seen:
            continue
        quad = {}
        for dx in (0, 8):
            for dy in (0, 8):
                if (x + dx, y + dy) in by_pos and (x + dx, y + dy) not in seen:
                    quad[(dx, dy)] = by_pos[(x + dx, y + dy)][0]
                    seen.add((x + dx, y + dy))
        cells.append((x, y, quad))
    return cells


def cell_strip(cells, cache, pals, scale, cols_max):
    if not cells:
        return None
    pad, label_h = 6, 13
    side = 16 * scale
    cols = max(1, min(len(cells), cols_max))
    rows = (len(cells) + cols - 1) // cols
    img = Image.new('RGB', (cols * (side + pad), rows * (side + label_h + pad)),
                    TRANSPARENT)
    for n, (x, y, quad) in enumerate(cells):
        ox = (n % cols) * (side + pad)
        oy = (n // cols) * (side + label_h + pad) + label_h
        cell = Image.new('RGB', (side, side), TRANSPARENT)
        cpx = cell.load()
        for (dx, dy), (tile, attr) in quad.items():
            paste_tile(cpx, tile, cache, pals, attr, dx, dy, scale)
        img.paste(cell, (ox, oy))
    dr = ImageDraw.Draw(img)
    for n, (x, y, quad) in enumerate(cells):
        ox = (n % cols) * (side + pad)
        oy = (n // cols) * (side + label_h + pad)
        dr.text((ox, oy), '%d@%02X,%02X' % (n, x, y), fill=(255, 0, 0),
                font=font(11))
    return img


def report_cells(entries, cache, pals, scale, outdir, cols_max):
    for e in entries:
        print('%s  table %s' % (e['name'], gen.hexw(e['tab'])))
        strips = []
        for i, b in enumerate(e['blobs']):
            cells = cells_of(b)
            desc = ' | '.join('%02X,%02X[%s]' % (x, y, ' '.join(
                gen.hexb(quad[k][0])
                for k in sorted(quad, key=lambda k: (k[1], k[0]))))
                for x, y, quad in cells)
            print('  blob[%d] %s %drec %d cells  %s'
                  % (i, gen.hexw(b['start']), len(b['recs']), len(cells), desc))
            img = cell_strip(cells, cache, pals, scale, cols_max)
            if img:
                strips.append(('%s[%d]' % (e['name'][10:12], i), img))
        if not strips:
            continue
        w = max(im.width for _, im in strips)
        h = sum(im.height for _, im in strips) + 14 * len(strips)
        canvas = Image.new('RGB', (w, h), (248, 248, 248))
        dr = ImageDraw.Draw(canvas)
        y = 0
        for cap, im in strips:
            dr.text((4, y), cap, fill=(0, 0, 140), font=font(12))
            y += 14
            canvas.paste(im, (0, y))
            y += im.height
        path = os.path.join(outdir, 'menu_oam_cells_%s.png' % e['name'][10:12])
        canvas.save(path)
        print('  -> %s' % os.path.relpath(path, ROOT))


def report_panels(entries, cache, pals, scale, outdir):
    for e in entries:
        for i, b in enumerate(e['blobs']):
            img = blob_panel(b, cache, pals, scale)
            if img is None:
                continue
            path = os.path.join(outdir, 'menu_oam_panel_%s_%d.png'
                                % (e['name'][10:12], i))
            img.save(path)
            print('wrote %s' % os.path.relpath(path, ROOT))


def report_sheets(entries, cache, pals, scale, outdir):
    """One PNG per handler: its blobs side by side, at their real offsets."""
    for e in entries:
        imgs = [(i, b, blob_panel(b, cache, pals, scale))
                for i, b in enumerate(e['blobs'])]
        imgs = [(i, b, im) for i, b, im in imgs if im]
        if not imgs:
            continue
        pad, label_h = 10, 16
        cell_w = max(im.width for _, _, im in imgs) + pad
        cell_h = max(im.height for _, _, im in imgs) + label_h + pad
        cols = min(len(imgs), 4)
        rows = (len(imgs) + cols - 1) // cols
        canvas = Image.new('RGB', (cols * cell_w + pad,
                                   rows * cell_h + 24), (248, 248, 248))
        dr = ImageDraw.Draw(canvas)
        dr.text((8, 5), '%s  table %s  %d blobs'
                % (e['name'], gen.hexw(e['tab']), len(imgs)),
                fill=(0, 0, 140), font=font(15))
        for n, (i, b, im) in enumerate(imgs):
            x = pad + (n % cols) * cell_w
            y = 24 + (n // cols) * cell_h
            dr.text((x, y), '[%d] %s %drec' % (i, gen.hexw(b['start']),
                                               len(b['recs'])),
                    fill=(150, 0, 0), font=font(12))
            canvas.paste(im, (x, y + label_h))
        path = os.path.join(outdir, 'menu_oam_sheet_%s.png' % e['name'][10:12])
        canvas.save(path)
        print('wrote %s' % os.path.relpath(path, ROOT))


def report_tiles(cache, pages, scale, outdir, lo, hi):
    """A labeled legend of the tile ids the blobs actually use."""
    ids = list(range(lo, hi + 1))
    pad, label_h, cols = 4, 16, 8
    rows = (len(ids) + cols - 1) // cols
    img = Image.new('RGB', (cols * (8 * scale + pad),
                            rows * (8 * scale + label_h + pad)), TRANSPARENT)
    dr = ImageDraw.Draw(img)
    for n, t in enumerate(ids):
        x = (n % cols) * (8 * scale + pad)
        y = (n // cols) * (8 * scale + label_h + pad)
        dr.text((x + 2, y), '$%02X p$%02X' % (t, page_of_tile(t, pages)),
                fill=(255, 40, 40), font=font(min(15, scale)))
        rows_px, _ = cache.tile(t)
        for r in range(8):
            for c in range(8):
                dr.rectangle([x + c * scale, y + label_h + r * scale,
                              x + c * scale + scale - 1,
                              y + label_h + r * scale + scale - 1],
                             fill=[TRANSPARENT, (255, 255, 255),
                                   (255, 180, 0), (0, 0, 0)][rows_px[r][c]])
    path = os.path.join(outdir, 'menu_oam_tiles_%02x_%02x.png' % (lo, hi))
    img.save(path)
    print('wrote %s' % os.path.relpath(path, ROOT))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--record', type=lambda s: int(s, 16), default=4,
                    help='menu font record index (MenuActions = action_type+2, 2-9)')
    ap.add_argument('--slots', choices=('47', '03'), default='47',
                    help="record bytes feeding the pattern table: 47 = CHR slots "
                         "4-7 (what PPUCTRL $10 gives the sprites), 03 = slots 0-3")
    ap.add_argument('--handler', help='only this table id (hex, e.g. 1b)')
    ap.add_argument('--scale', type=int, default=6)
    ap.add_argument('--cells', action='store_true', help='per-glyph-cell strips')
    ap.add_argument('--panels', action='store_true', help='one PNG per blob')
    ap.add_argument('--tiles', nargs=2, metavar=('LO', 'HI'),
                    help='dump a tile-id legend instead of the blobs')
    ap.add_argument('--cols', type=int, default=8, help='cells per row in --cells')
    ap.add_argument('--outdir', default=os.path.join(ROOT, 'output'))
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    pages = font_rec_pages(args.record, args.slots)
    cache = TileCache(pages)
    pals = sprite_palette(args.record)
    print('record $%02X slots %s -> pages %s; sprite pal3 c1-3 %s pal2 c1-3 %s'
          % (args.record, args.slots,
             ' '.join('$%02X' % p for p in pages),
             ['%02X' % c for c in load_palette(args.record)[0x11 + 12:0x14 + 12]],
             ['%02X' % c for c in load_palette(args.record)[0x11 + 8:0x14 + 8]]))
    if args.tiles:
        report_tiles(cache, pages, args.scale, args.outdir,
                     int(args.tiles[0], 16), int(args.tiles[1], 16))
        return 0
    entries = gen.build_plan(gen.read_bank())
    if args.handler:
        want = args.handler.upper()
        entries = [e for e in entries if e['name'][10:12].upper() == want]
        if not entries:
            print('no table with id %s' % args.handler)
            return 1
    if args.cells:
        report_cells(entries, cache, pals, args.scale, args.outdir, args.cols)
    elif args.panels:
        report_panels(entries, cache, pals, args.scale, args.outdir)
    else:
        report_sheets(entries, cache, pals, args.scale, args.outdir)
    return 0


if __name__ == '__main__':
    sys.exit(main())
