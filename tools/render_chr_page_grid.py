#!/usr/bin/env python3
"""Render a 1KB CHR page as a labeled tile-index grid PNG for charmap work.

Usage: python3 tools/render_chr_page_grid.py <chr_file> <offset_hex> <base_tile_hex> <out.png> [scale]
Page value V: file = V//8, offset = (V%8)*0x400.
"""
import sys
from PIL import Image, ImageDraw, ImageFont

PALETTE = [(0, 0, 0), (255, 255, 255), (0, 0, 0), (255, 255, 255)]


def main():
    chr_path, offset, base_tile, out_path = sys.argv[1], int(sys.argv[2], 16), int(sys.argv[3], 16), sys.argv[4]
    scale = int(sys.argv[5]) if len(sys.argv) > 5 else 10
    label_h = 24
    with open(chr_path, 'rb') as f:
        f.seek(offset)
        chunk = f.read(0x400)
    cols, rows = 16, 4
    cell, tw = 8 * scale, 8 * scale
    img = Image.new('RGB', (cols * cell, rows * (cell + label_h)), (255, 255, 255))
    dr = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype('/usr/share/fonts/TTF/DejaVuSansMono-Bold.ttf', 18)
    except OSError:
        font = ImageFont.load_default()
    for t in range(64):
        p0 = chunk[t * 16:t * 16 + 8]
        p1 = chunk[t * 16 + 8:t * 16 + 16]
        tx = (t % cols) * cell
        ty = (t // cols) * (cell + label_h) + label_h
        dr.text((tx + 2, ty - label_h + 2), f'{base_tile + t:02X}', fill=(180, 0, 0), font=font)
        for r in range(8):
            for c in range(8):
                bit = 7 - c
                px = (p0[r] >> bit) & 1 | (((p1[r] >> bit) & 1) << 1)
                if px:
                    dr.rectangle([tx + c * scale, ty + r * scale,
                                  tx + c * scale + scale - 1, ty + r * scale + scale - 1],
                                 fill=PALETTE[px] if px != 2 else (60, 60, 60))
        dr.rectangle([tx, ty, tx + cell - 1, ty + cell - 1], outline=(200, 200, 200))
    img.save(out_path)
    print(f'wrote {out_path}')


if __name__ == '__main__':
    main()
