#!/usr/bin/env python3
"""
Generate PNG images of CHR tiles for katakana font identification.
Renders tiles from candidate CHR slices as scaled-up PNG images.
"""

import os
from PIL import Image

CHR_DIR = "/home/zero/project/sango2dasm/rom/chr"
OUTPUT_DIR = "/home/zero/project/sango2dasm/output"

def read_chr_bank(bank_num):
    fname = os.path.join(CHR_DIR, f"chr_{bank_num:02x}.bin")
    with open(fname, "rb") as f:
        return f.read()

def render_tile_to_image(tile_data, scale=4):
    """Render a single tile as a PIL Image."""
    img = Image.new('RGB', (8 * scale, 8 * scale), (0, 0, 0))
    pixels = img.load()

    for row in range(8):
        bp0 = tile_data[row]
        bp1 = tile_data[row + 8]
        for col in range(8):
            bit0 = (bp0 >> (7 - col)) & 1
            bit1 = (bp1 >> (7 - col)) & 1
            pixel = bit0 | (bit1 << 1)

            # NES palette-like colors for 2bpp
            colors = [
                (0, 0, 0),         # 0: black (transparent)
                (255, 255, 255),   # 1: white
                (128, 128, 128),   # 2: gray
                (200, 200, 80),    # 3: yellow-ish (highlight)
            ]
            color = colors[pixel]

            for dy in range(scale):
                for dx in range(scale):
                    pixels[col * scale + dx, row * scale + dy] = color
    return img

def generate_font_sheet(bank_num, slice_idx, output_name, tile_range=None):
    """Generate a PNG sheet of tiles from a CHR slice."""
    chr_data = read_chr_bank(bank_num)
    slice_offset = slice_idx * 1024
    slice_data = chr_data[slice_offset:slice_offset + 1024]

    if tile_range is None:
        tile_range = range(64)

    tiles_per_row = 16
    num_tiles = len(list(tile_range))
    rows = (num_tiles + tiles_per_row - 1) // tiles_per_row
    scale = 6

    sheet_w = tiles_per_row * 8 * scale
    sheet_h = rows * 8 * scale + rows * scale  # extra space for labels

    img = Image.new('RGB', (sheet_w + 40, sheet_h + 40), (32, 32, 32))
    pixels = img.load()

    # Draw grid and tile indices
    from PIL import ImageDraw, ImageFont
    draw = ImageDraw.Draw(img)

    for i, tile_idx in enumerate(tile_range):
        tile_offset = tile_idx * 16
        if tile_offset + 16 > len(slice_data):
            continue
        tile_data = slice_data[tile_offset:tile_offset + 16]

        row = i // tiles_per_row
        col = i % tiles_per_row

        x = 40 + col * 8 * scale
        y = 20 + row * (8 * scale + scale)

        # Draw tile index label
        draw.text((x, y - scale - 2), f"{tile_idx:02X}", fill=(180, 180, 180))

        # Draw tile
        for py in range(8):
            bp0 = tile_data[py]
            bp1 = tile_data[py + 8]
            for px in range(8):
                bit0 = (bp0 >> (7 - px)) & 1
                bit1 = (bp1 >> (7 - px)) & 1
                pixel = bit0 | (bit1 << 1)
                colors = [
                    (0, 0, 0),
                    (255, 255, 255),
                    (128, 128, 128),
                    (200, 200, 80),
                ]
                color = colors[pixel]
                for dy in range(scale):
                    for dx in range(scale):
                        pixels[x + px * scale + dx, y + py * scale + dy] = color

    # Title
    draw.text((40, 2), output_name, fill=(255, 255, 0))

    outpath = os.path.join(OUTPUT_DIR, output_name + ".png")
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    img.save(outpath)
    print(f"Saved: {outpath} ({img.size[0]}x{img.size[1]})")
    return outpath

# Generate font sheets for top candidates
# Focus on the hero name tile range $04-$38
hero_tiles = list(range(0x04, 0x39))
all_tiles = list(range(64))

# chr_14 slice 4 (highest score, tile 0 blank)
generate_font_sheet(0x14, 4, "chr14_slice4_hero", hero_tiles)
generate_font_sheet(0x14, 4, "chr14_slice4_all", all_tiles)

# chr_1e slice 0 (previously identified candidate)
generate_font_sheet(0x1e, 0, "chr1e_slice0_hero", hero_tiles)
generate_font_sheet(0x1e, 0, "chr1e_slice0_all", all_tiles)

# chr_0b slice 7 (2nd highest score)
generate_font_sheet(0x0b, 7, "chr0b_slice7_hero", hero_tiles)
generate_font_sheet(0x0b, 7, "chr0b_slice7_all", all_tiles)

# chr_0c slices 0-1 (3rd-4th)
generate_font_sheet(0x0c, 0, "chr0c_slice0_hero", hero_tiles)
generate_font_sheet(0x0c, 1, "chr0c_slice1_hero", hero_tiles)

# chr_0d slice 0
generate_font_sheet(0x0d, 0, "chr0d_slice0_hero", hero_tiles)

print("\nDone! Check output/ directory for PNG files.")
