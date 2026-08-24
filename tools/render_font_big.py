#!/usr/bin/env python3
"""Render menu font 1KB chunks from chr_00.bin big, with labels.

PPUCTRL = $10 -> BG pattern table = PPU $1000, served by CHR slots 4-7.
Officer param record 0 (bank $21 @ $946C): slots 4-6 = $00,$01,$02
  tiles $00-$3F -> chr_00.bin @ $0000
  tiles $40-$7F -> chr_00.bin @ $0400
  tiles $80-$BF -> chr_00.bin @ $0800
"""
from PIL import Image, ImageDraw, ImageFont


def render(chunk_ofs, base, out_path):
    scale = 8
    cols, rows = 16, 4
    with open('rom/chr/chr_00.bin', 'rb') as f:
        f.seek(chunk_ofs)
        chunk = f.read(0x400)
    cell = 8 * scale
    img = Image.new('RGB', (cols * cell, rows * (cell + 16)), (0, 0, 0))
    dr = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 12)
    except Exception:
        font = ImageFont.load_default()
    for t in range(64):
        p0 = chunk[t * 16:t * 16 + 8]
        p1 = chunk[t * 16 + 8:t * 16 + 16]
        tx = (t % cols) * cell
        ty = (t // cols) * (cell + 16)
        dr.text((tx + 1, ty + cell + 2), "$%02X" % (t + base), fill=(255, 200, 0), font=font)
        for row in range(8):
            for col in range(8):
                bit = 7 - col
                px = (p0[row] >> bit) & 1 | (((p1[row] >> bit) & 1) << 1)
                if px:
                    dr.rectangle([tx + col * scale, ty + row * scale,
                                  tx + col * scale + scale - 1, ty + row * scale + scale - 1],
                                 fill=(255, 255, 255))
    img.save(out_path)
    print('ok', out_path, img.size)


render(0x0000, 0x00, 'output/font_slot0_big.png')
render(0x0400, 0x40, 'output/font_slot1_big.png')
render(0x0800, 0x80, 'output/font_slot2_big.png')
