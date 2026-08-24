#!/usr/bin/env python3
"""Render candidate pages $16/$63/$91 (record 14) full 64-tile grids."""
from PIL import Image, ImageDraw

SCALE = 6


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


for page in (0x16, 0x63, 0x91):
    cd = load_page(page)
    img = Image.new('RGB', (16 * (8 * SCALE + 4), 4 * (8 * SCALE + 16)), 'white')
    d = ImageDraw.Draw(img)
    for t in range(64):
        px = read_tile(cd, t)
        x0 = (t % 16) * (8 * SCALE + 4) + 2
        y0 = (t // 16) * (8 * SCALE + 16) + 14
        d.text((x0, y0 - 13), f"{t:02X}", fill='red')
        for y in range(8):
            for x in range(8):
                if px[y][x]:
                    c = 0 if px[y][x] == 3 else 140
                    d.rectangle([x0 + x * SCALE, y0 + y * SCALE,
                                 x0 + x * SCALE + SCALE - 1, y0 + y * SCALE + SCALE - 1], fill=c)
    img.save(f'output/page_{page:02x}_grid.png')
    print('saved', hex(page))
