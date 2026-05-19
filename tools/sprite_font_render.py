#!/usr/bin/env python3
"""Render sprite CHR tiles and print ASCII art for katakana identification."""
from PIL import Image, ImageDraw
import os

sprite_candidates = [
    (0x00, 0, 'chr_00 slice 0 ($B2=$00)'),
    (0x01, 2, 'chr_01 slice 2 ($B2=$0A)'),
    (0x11, 0, 'chr_11 slice 0 ($B2=$88)'),
    (0x12, 5, 'chr_12 slice 5 ($B2=$95)'),
    (0x13, 0, 'chr_13 slice 0 ($B2=$98)'),
    (0x14, 0, 'chr_14 slice 0 ($B2=$A0)'),
    (0x15, 0, 'chr_15 slice 0 ($B2=$A8)'),
    (0x19, 0, 'chr_19 slice 0 ($B2=$C8)'),
]

scale = 6
os.makedirs('output', exist_ok=True)

for bank, slice_idx, label in sprite_candidates:
    data = open(f'rom/chr/chr_{bank:02x}.bin', 'rb').read()
    slice_offset = slice_idx * 1024
    slice_data = data[slice_offset:slice_offset + 1024]

    # Generate PNG
    tiles_per_row = 16
    rows = 4
    sheet_w = tiles_per_row * 8 * scale + 40
    sheet_h = rows * (8 * scale + scale) + 50
    img = Image.new('RGB', (sheet_w, sheet_h), (32, 32, 32))
    pixels = img.load()
    draw = ImageDraw.Draw(img)
    draw.text((10, 3), label, fill=(255, 255, 0))
    for tile_idx in range(64):
        tile_offset = tile_idx * 16
        if tile_offset + 16 > len(slice_data):
            break
        tile_data = slice_data[tile_offset:tile_offset + 16]
        row = tile_idx // tiles_per_row
        col = tile_idx % tiles_per_row
        x = 20 + col * 8 * scale
        y = 25 + row * (8 * scale + scale)
        draw.text((x, y - 6), f'{tile_idx:02X}', fill=(100, 100, 100))
        for py in range(8):
            bp0 = tile_data[py]
            bp1 = tile_data[py + 8]
            for px in range(8):
                bit0 = (bp0 >> (7 - px)) & 1
                bit1 = (bp1 >> (7 - px)) & 1
                pixel = bit0 | (bit1 << 1)
                colors = [(0,0,0), (255,255,255), (170,170,170), (220,220,80)]
                for dy in range(scale):
                    for dx in range(scale):
                        pixels[x + px * scale + dx, y + py * scale + dy] = colors[pixel]
    fname = f'output/sprite_chr{bank:02x}_s{slice_idx}.png'
    img.save(fname)

    # Print ASCII art for tiles 4-38 (hero name range)
    print(f'\n=== {label} - Tiles $04-$38 ===')
    for tile_idx in range(0x04, 0x39):
        tile_offset = tile_idx * 16
        tile_data = slice_data[tile_offset:tile_offset + 16]
        bitmap = []
        for row in range(8):
            combined = tile_data[row] | tile_data[row + 8]
            bitmap.append(combined)
        density = sum(bin(b).count('1') for b in bitmap)
        lines = []
        for byte in bitmap:
            line = ''
            for col in range(7, -1, -1):
                line += '#' if (byte >> col) & 1 else ' '
            lines.append(line)
        print(f'Tile ${tile_idx:02X} ({density:2d}/64):')
        for line in lines:
            print(f'  |{line}|')

print('\nDone generating sprite CHR tile renders.')
