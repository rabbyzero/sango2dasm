#!/usr/bin/env python3
"""Zoom-render specific tiles from pages $70/$97 for careful reading."""
from PIL import Image, ImageDraw

SCALE = 16


def load_page(page):
    f = page // 8
    ofs = (page % 8) * 0x400
    d = open(f'rom/chr/chr_{f:02x}.bin', 'rb').read()
    return d[ofs:ofs + 0x400]


def read_tile(cd, i):
    o = i * 16
    p0, p1 = cd[o:o + 8], cd[o + 8:o + 16]
    return [[((p0[r] >> (7 - c)) & 1) | (((p1[r] >> (7 - c)) & 1) << 1)
             for c in range(8)] for r in range(8)]


codes = [0x04, 0x05, 0x06, 0x07, 0x09, 0x0A, 0x0B, 0x0D, 0x0E, 0x0F,
         0x11, 0x14, 0x15, 0x18, 0x1E, 0x23, 0x28, 0x2B, 0x31, 0x36,
         0x37, 0x38, 0x39, 0x3A]
pg70 = load_page(0x70)
COLS = 8
cw = 8 * SCALE + 8
ch = 8 * SCALE + 24
rows = (len(codes) + COLS - 1) // COLS
img = Image.new('RGB', (COLS * cw, rows * ch), 'white')
d = ImageDraw.Draw(img)
for i, code in enumerate(codes):
    px = read_tile(pg70, code)
    x0 = (i % COLS) * cw + 4
    y0 = (i // COLS) * ch + 20
    d.text(((i % COLS) * cw + 4, (i // COLS) * ch + 2), f"${code:02X}", fill='red')
    for y in range(8):
        for x in range(8):
            if px[y][x]:
                c = 0 if px[y][x] == 3 else 140
                d.rectangle([x0 + x * SCALE, y0 + y * SCALE,
                             x0 + x * SCALE + SCALE - 1, y0 + y * SCALE + SCALE - 1], fill=c)
img.save('output/kana_zoom.png')
print('saved output/kana_zoom.png')
