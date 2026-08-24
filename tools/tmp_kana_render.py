#!/usr/bin/env python3
"""Render the officer-list kana font pages and decode the 4 anchor officer names.

Officer-list screen (display record 14): tiles $00-$3F <- page $70 (chr_0e @0),
tiles $40-$7F <- page $97 (chr_18 @ $1C00).
"""
from PIL import Image, ImageDraw
import os

SCALE = 6
PAD = 2
LABEL_H = 12


def load_page(page):
    f = page // 8
    ofs = (page % 8) * 0x400
    data = open(f'rom/chr/chr_{f:02x}.bin', 'rb').read()
    return data[ofs:ofs + 0x400]


def read_tile(chr_data, idx):
    ofs = idx * 16
    p0, p1 = chr_data[ofs:ofs + 8], chr_data[ofs + 8:ofs + 16]
    px = []
    for row in range(8):
        line = []
        for col in range(8):
            bit = 7 - col
            line.append(((p0[row] >> bit) & 1) | (((p1[row] >> bit) & 1) << 1))
        px.append(line)
    return px


def tile_nonzero(px):
    return sum(1 for r in px for v in r if v)


pages = {
    0x70: load_page(0x70),   # tiles $00-$3F of officer list
    0x97: load_page(0x97),   # tiles $40-$7F
}

# ---- full grid of tiles $00-$7F ----
COLS = 16
tiles = []
for t in range(0x80):
    pg = 0x70 if t < 0x40 else 0x97
    tiles.append((t, read_tile(pages[pg], t % 0x40)))

rows = (len(tiles) + COLS - 1) // COLS
cw, ch = 8 * SCALE + PAD * 2, 8 * SCALE + PAD * 2 + LABEL_H
img = Image.new('RGB', (COLS * cw, rows * ch), 'white')
d = ImageDraw.Draw(img)
for i, (t, px) in enumerate(tiles):
    x0 = (i % COLS) * cw + PAD
    y0 = (i // COLS) * ch + PAD + LABEL_H
    d.text(((i % COLS) * cw + PAD, (i // COLS) * ch + 1), f"{t:02X}", fill='red')
    for y in range(8):
        for x in range(8):
            if px[y][x]:
                c = 0 if px[y][x] == 3 else 120
                d.rectangle([x0 + x * SCALE, y0 + y * SCALE,
                             x0 + x * SCALE + SCALE - 1, y0 + y * SCALE + SCALE - 1], fill=c)
os.makedirs('output', exist_ok=True)
img.save('output/kana_font_grid.png')
print('saved output/kana_font_grid.png')

# ---- decode 4 anchor names as strips ----
data = open('rom/prg_combined.bin', 'rb').read()
BASE = 0x20000 + 0x101A
anchors = [('Liubei 222', 222), ('Guanyu 38', 38), ('Zhangfei 153', 153), ('Zhugeliang 109', 109)]
strip = Image.new('RGB', (10 * cw + 120, len(anchors) * ch), 'white')
ds = ImageDraw.Draw(strip)
for row, (nm, oid) in enumerate(anchors):
    e = data[BASE + oid * 10: BASE + oid * 10 + 10]
    ds.text((2, row * ch + 4), f"{nm}: {e.hex()}", fill='blue')
    for ci, code in enumerate(e):
        if code == 0:
            continue
        pg = 0x70 if code < 0x40 else 0x97
        px = read_tile(pages[pg], code % 0x40)
        x0 = 120 + ci * cw + PAD
        y0 = row * ch + PAD
        ds.text((x0, row * ch), f"{code:02X}", fill='red')
        for y in range(8):
            for x in range(8):
                if px[y][x]:
                    c = 0 if px[y][x] == 3 else 120
                    ds.rectangle([x0 + x * SCALE, y0 + LABEL_H + y * SCALE,
                                  x0 + x * SCALE + SCALE - 1, y0 + LABEL_H + y * SCALE + SCALE - 1], fill=c)
strip.save('output/kana_anchor_names.png')
print('saved output/kana_anchor_names.png')

# table extent: first entry whose byte0 is $FF or 0
for i in range(600):
    o = BASE + i * 10
    if data[o] in (0x00, 0xFF):
        print('first empty/$FF entry:', i)
        break
