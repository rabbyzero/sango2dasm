#!/usr/bin/env python3
"""Render full 1KB CHR pages (tiles $40-$FF) at high scale for visual reading."""
from PIL import Image, ImageDraw

SCALE = 8


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


for page in (0x78, 0x70, 0x97):
    cd = load_page(page)
    img = Image.new('RGB', (16 * 8 * SCALE, 4 * 8 * SCALE), 'white')
    d = ImageDraw.Draw(img)
    for t in range(0xC0):
        px = read_tile(cd, t + 0x40)
        x0 = (t % 16) * 8 * SCALE
        y0 = (t // 16) * 8 * SCALE
        d.text((x0 + 2, y0 + 2), f"{t + 0x40:02X}", fill='red')
        for y in range(8):
            for x in range(8):
                if px[y][x]:
                    d.rectangle([x0 + x * SCALE, y0 + 16 + y * SCALE,
                                 x0 + x * SCALE + SCALE - 1, y0 + 16 + y * SCALE + SCALE - 1],
                                fill=0)
    img.save(f'output/page_{page:02x}_hi.png')
    print('saved', hex(page))
