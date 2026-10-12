#!/usr/bin/env python3
"""Render a 1KB CHR page as 8x16 glyphs (tile 2n top, 2n+1 bottom) with hex labels."""
import sys
from PIL import Image, ImageDraw, ImageFont

PALETTE = [(255, 255, 255), (0, 0, 0), (0, 0, 0), (120, 120, 120)]


def main():
    chr_path, offset, base_tile, out_path = sys.argv[1], int(sys.argv[2], 16), int(sys.argv[3], 16), sys.argv[4]
    scale = int(sys.argv[5]) if len(sys.argv) > 5 else 12
    label_h = 22
    with open(chr_path, 'rb') as f:
        f.seek(offset)
        chunk = f.read(0x400)
    cols, rows = 8, 4
    cell_w, cell_h = 8 * scale, 16 * scale
    img = Image.new('RGB', (cols * cell_w, rows * (cell_h + label_h)), (255, 255, 255))
    dr = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype('/usr/share/fonts/TTF/DejaVuSansMono-Bold.ttf', 17)
    except OSError:
        font = ImageFont.load_default()
    for g in range(32):
        top, bot = g * 2, g * 2 + 1
        tx = (g % cols) * cell_w
        ty = (g // cols) * (cell_h + label_h) + label_h
        dr.text((tx + 2, ty - label_h + 2), f'{base_tile + top:02X}', fill=(180, 0, 0), font=font)
        for half, tile in enumerate((top, bot)):
            p0 = chunk[tile * 16:tile * 16 + 8]
            p1 = chunk[tile * 16 + 8:tile * 16 + 16]
            oy = ty + half * 8 * scale
            for r in range(8):
                for c in range(8):
                    bit = 7 - c
                    px = (p0[r] >> bit) & 1 | (((p1[r] >> bit) & 1) << 1)
                    if px:
                        dr.rectangle([tx + c * scale, oy + r * scale,
                                      tx + c * scale + scale - 1, oy + r * scale + scale - 1],
                                     fill=PALETTE[px])
        dr.rectangle([tx, ty, tx + cell_w - 1, ty + cell_h - 1], outline=(200, 200, 200))
    img.save(out_path)
    print(f'wrote {out_path}')


if __name__ == '__main__':
    main()
