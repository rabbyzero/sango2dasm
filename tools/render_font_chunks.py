#!/usr/bin/env python3
"""Render the menu font 1KB CHR chunks as PNG images.

Record-0 officer param table (bank $21 @ $946C) gives CHR slots:
  slot0=$04, slot1=$01, slot2=$02, slot3=$04, slot4=$00, slot5=$01, slot6=$02, slot7=$10
Register value V selects 1KB chunk: file = V//8, offset = (V%8)*0x400.
Menu tiles $00-$3F -> slot 0 (chunk $04 -> chr_00.bin @ $1000)
Menu tiles $40-$7F -> slot 1 (chunk $01 -> chr_00.bin @ $0400)
"""
from PIL import Image, ImageDraw

PALETTE = [(0, 0, 0), (170, 170, 170), (85, 85, 85), (255, 255, 255)]


def render_chunk_png(chr_path, offset, out_path, base_tile, scale=4):
    with open(chr_path, 'rb') as f:
        f.seek(offset)
        chunk = f.read(0x400)
    cols, rows = 16, 4  # 64 tiles per 1KB chunk
    img = Image.new('RGB', (cols * 8 * scale, rows * 8 * scale), (0, 0, 0))
    dr = ImageDraw.Draw(img)
    for t in range(64):
        p0 = chunk[t * 16:t * 16 + 8]
        p1 = chunk[t * 16 + 8:t * 16 + 16]
        tx = (t % cols) * 8 * scale
        ty = (t // cols) * 8 * scale
        for row in range(8):
            for col in range(8):
                bit = 7 - col
                px = (p0[row] >> bit) & 1 | (((p1[row] >> bit) & 1) << 1)
                if px:
                    dr.rectangle(
                        [tx + col * scale, ty + row * scale,
                         tx + col * scale + scale - 1, ty + row * scale + scale - 1],
                        fill=PALETTE[px])
    img.save(out_path)
    print(f"wrote {out_path}: {chr_path} @ ${offset:04X}, tiles ${base_tile:02X}-${base_tile + 63:02X}")


render_chunk_png('rom/chr/chr_00.bin', 0x1000, 'output/font_slot0_tiles00.png', 0x00)
render_chunk_png('rom/chr/chr_00.bin', 0x0400, 'output/font_slot1_tiles40.png', 0x40)
