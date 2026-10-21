#!/usr/bin/env python3
"""Render the bank $14 / $15 metasprites as the OAM they produce.

Both banks hold `[y_off, tile, attr, x_off]` records in the
B1F_SpriteOamWriterSimple format, drawn by DrawSpriteFromBank ($CEA5,
prg_17_18_duel_and_display). Every caller lives in that bank, so the sprites
are Duel Mode (display record 10) pictures: sprite pattern table is PPU
$0000 (PPUCTRL $10, bit 3 clear), so the four CHR slots are font record 10
bytes 0-3 = pages $80 $81 $82 $85, palette record 10.

    OAM Y    = y_off + $000A
    OAM tile = tile + $0003 (bias 0 on this path)
    OAM attr = attr XOR $0002 (caller flip flags; 0 for the raw record)
    OAM X    = x_off + $000C

Usage:
    python3 tools/render_sprite_banks.py --bank 14
    python3 tools/render_sprite_banks.py --bank 15 --scale 4
    python3 tools/render_sprite_banks.py --bank 14 --from 0x22 --to 0x3f
"""
import argparse
import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import gen_data_bank_14_asm as gen14                     # noqa: E402
import gen_data_bank_15_asm as gen15                     # noqa: E402
from render_menu_oam_blobs import TileCache, font, font_rec_pages, sprite_palette  # noqa: E402

TRANSPARENT = (128, 128, 128)
CELL_W, CELL_H = 176, 168


def load_bank14():
    data = gen14.read_bank()
    ptrs, records, _ = gen14.parse(data)
    return [(i, records[i]) for i in range(len(records))]


def load_bank15():
    data = gen15.read_bank()
    _, blobs = gen15.build_plan(data)
    out = []
    for i, bl in enumerate(blobs):
        ofs = bl['ofs']
        out.append((0x80 + i, [tuple(data[ofs + e * 4:ofs + e * 4 + 4])
                               for e in range(bl['entries'])]))
    return out


def draw_sprite(recs, cache, pals, scale):
    if not recs:
        return None
    minx = min(r[3] for r in recs)
    miny = min(r[0] for r in recs)
    w = max(r[3] for r in recs) + 8 - minx
    h = max(r[0] for r in recs) + 8 - miny
    img = Image.new('RGB', (w * scale, h * scale), TRANSPARENT)
    px = img.load()
    # OAM priority: lower-index sprites cover higher-index ones, and colour 0
    # is transparent, so composite back to front and never overwrite with it.
    for (y, tile, attr, x) in reversed(recs):
        rows, _page = cache.tile(tile)
        if attr & 0x40:
            rows = [list(reversed(r)) for r in rows]
        if attr & 0x80:
            rows = list(reversed(rows))
        rgb = pals[attr & 3]
        ox = (x - minx) * scale
        oy = (y - miny) * scale
        for r in range(8):
            for c in range(8):
                if rows[r][c] == 0:
                    continue
                color = rgb[rows[r][c]]
                for sy in range(scale):
                    for sx in range(scale):
                        px[ox + c * scale + sx, oy + r * scale + sy] = color
    return img


def sheet(items, cache, pals, scale, cols, title, out):
    rows = (len(items) + cols - 1) // cols
    label_h = 26
    canvas = Image.new('RGB', (cols * CELL_W, rows * (CELL_H + label_h) + 24),
                       (248, 248, 248))
    dr = ImageDraw.Draw(canvas)
    dr.text((6, 4), title, fill=(0, 0, 120), font=font(14))
    for n, (sid, recs) in enumerate(items):
        x = (n % cols) * CELL_W
        y = 24 + (n // cols) * (CELL_H + label_h)
        dr.text((x + 2, y), '$%02X  %d rec' % (sid, len(recs)),
                fill=(150, 0, 0), font=font(11))
        img = draw_sprite(recs, cache, pals, scale)
        if img:
            if img.width > CELL_W - 4 or img.height > CELL_H - 2:
                img = img.resize((min(CELL_W - 4, img.width * 2 // 3),
                                  min(CELL_H - 2, img.height * 2 // 3)))
            canvas.paste(img, (x + 2, y + 16))
    canvas.save(out)
    print('wrote %s (%dx%d)' % (os.path.relpath(out, ROOT), canvas.width, canvas.height))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--bank', type=lambda s: int(s, 16),
                    choices=(0x14, 0x15), default=0x14)
    ap.add_argument('--record', type=int, default=10,
                    help='font/CHR record index (Duel Mode = 10)')
    ap.add_argument('--from', dest='lo', type=lambda s: int(s, 0), default=None)
    ap.add_argument('--to', dest='hi', type=lambda s: int(s, 0), default=None)
    ap.add_argument('--scale', type=int, default=2)
    ap.add_argument('--cols', type=int, default=8)
    ap.add_argument('--tiles', action='store_true', help='print the tile ids in use')
    ap.add_argument('--outdir', default=os.path.join(ROOT, 'output'))
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    pages = font_rec_pages(args.record, '03')
    cache = TileCache(pages)
    pals = sprite_palette(args.record)
    items = load_bank14() if args.bank == 0x14 else load_bank15()
    if args.lo is not None:
        items = [(i, r) for i, r in items if i >= args.lo]
    if args.hi is not None:
        items = [(i, r) for i, r in items if i <= args.hi]
    if args.tiles:
        used = sorted({t for _, recs in items for (_, t, _, _) in recs})
        print('pages %s; tiles: %s' % (' '.join('$%02X' % p for p in pages),
                                       ' '.join('$%02X' % t for t in used)))
        return 0
    out = os.path.join(args.outdir, 'sprites_bank%02x_%02x-%02x.png'
                       % (args.bank, items[0][0], items[-1][0]))
    sheet(items, cache, pals, args.scale, args.cols,
          'bank $%02X sprites $%02X-$%02X (record %d, pages %s)'
          % (args.bank, items[0][0], items[-1][0], args.record,
             ' '.join('%02X' % p for p in pages)), out)
    return 0


if __name__ == '__main__':
    sys.exit(main())
