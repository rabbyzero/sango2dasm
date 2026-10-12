#!/usr/bin/env python3
"""Render a 1KB CHR page as 16x16 glyphs (2x2 tile quadrants) with hex labels.

Quadrant order variants via argv[5]: tltr (TL,TR,BL,BR = 4n..4n+3) or tlbl (TL,BL,TR,BR).
"""
import sys
from PIL import Image, ImageDraw, ImageFont

PALETTE = [(255, 255, 255), (0, 0, 0), (0, 0, 0), (120, 120, 120)]


def main():
    chr_path, offset, base_tile, out_path = sys.argv[1], int(sys.argv[2], 16), int(sys.argv[3], 16), sys.argv[4]
    order = sys.argv[5] if len(sys.argv) > 5 else 'tltr'
    scale = 10
    label_h = 20
    with open(chr_path, 'rb') as f:
        f.seek(offset)
        chunk = f.read(0x400)
    cols, rows = 8, 2
    cell = 16 * scale
    img = Image.new('RGB', (cols * cell, rows * (cell + label_h)), (255, 255, 255))
    dr = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype('/usr/share/fonts/TTF/DejaVuSansMono-Bold.ttf', 16)
    except OSError:
        font = ImageFont.load_default()
    for g in range(16):
        if order == 'tltr':
            quads = [g * 4, g * 4 + 1, g * 4 + 2, g * 4 + 3]  # TL TR BL BR
        else:
            quads = [g * 4, g * 4 + 2, g * 4 + 1, g * 4 + 3]  # TL BL TR BR
        tx = (g % cols) * cell
        ty = (g // cols) * (cell + label_h) + label_h
        dr.text((tx + 2, ty - label_h + 2), f'{base_tile + quads[0]:02X}', fill=(180, 0, 0), font=font)
        for qi, tile in enumerate(quads):
            ox = tx + (qi % 2) * 8 * scale
            oy = ty + (qi // 2) * 8 * scale
            p0 = chunk[tile * 16:tile * 16 + 8]
            p1 = chunk[tile * 16 + 8:tile * 16 + 16]
            for r in range(8):
                for c in range(8):
                    bit = 7 - c
                    px = (p0[r] >> bit) & 1 | (((p1[r] >> bit) & 1) << 1)
                    if px:
                        dr.rectangle([ox + c * scale, oy + r * scale,
                                      ox + c * scale + scale - 1, oy + r * scale + scale - 1],
                                     fill=PALETTE[px])
        dr.rectangle([tx, ty, tx + cell - 1, ty + cell - 1], outline=(200, 200, 200))
    img.save(out_path)
    print(f'wrote {out_path}')


if __name__ == '__main__':
    main()
