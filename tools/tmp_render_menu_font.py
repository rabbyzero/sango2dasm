#!/usr/bin/env python3
"""Render strategy-menu font pages as monochrome hi-zoom PNGs for visual reading.

Pages (from OfficerParamDisp records 2-9): slot4=$95 (tiles $00-$3F),
slot5/6=$78 (tiles $40-$7F). 1KB chunk: file=V//8, offset=(V%8)*0x400.
  page $95 -> chr_12.bin @ $1400
  page $78 -> chr_0f.bin @ $0000
"""
from PIL import Image, ImageDraw

SCALE = 8


def render_page(chr_path, offset, out_path, base_tile, cols=16):
    with open(chr_path, 'rb') as f:
        f.seek(offset)
        chunk = f.read(0x400)
    rows = 64 // cols
    img = Image.new('RGB', (cols * 8 * SCALE, rows * 8 * SCALE), (0, 0, 0))
    dr = ImageDraw.Draw(img)
    for t in range(64):
        p0 = chunk[t * 16:t * 16 + 8]
        p1 = chunk[t * 16 + 8:t * 16 + 16]
        tx = (t % cols) * 8 * SCALE
        ty = (t // cols) * 8 * SCALE
        for row in range(8):
            for col in range(8):
                bit = 7 - col
                px = (p0[row] >> bit) & 1 | (((p1[row] >> bit) & 1) << 1)
                if px:
                    dr.rectangle(
                        [tx + col * SCALE, ty + row * SCALE,
                         tx + col * SCALE + SCALE - 1, ty + row * SCALE + SCALE - 1],
                        fill=(255, 255, 255))
        # label grid lines
    img.save(out_path)
    print(f"wrote {out_path} ({chr_path} @ ${offset:04X}, tiles ${base_tile:02X}+)")


render_page('rom/chr/chr_12.bin', 0x1400, 'output/tmp_page95_mono.png', 0x00)
render_page('rom/chr/chr_0f.bin', 0x0000, 'output/tmp_page78_mono.png', 0x00)
