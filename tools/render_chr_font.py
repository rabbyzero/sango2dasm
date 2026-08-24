#!/usr/bin/env python3
"""Render CHR tiles from all banks as a PNG image for visual font identification.
Focuses on tile indices $04-$09 (raw) and $84-$89 (after +$80 adjustment)."""

from PIL import Image
import os, sys

CHR_DIR = 'rom/chr'
TILE_SIZE = 8
SCALE = 4  # pixels per NES pixel

# Tile indices to examine (both raw and +$80 adjusted)
TILES_TO_CHECK = list(range(0, 16)) + list(range(0x80, 0xA0))

def read_tile(chr_data, tile_idx):
    """Read 8x8 tile from CHR data. Returns 8x8 pixel array (0-3)."""
    ofs = tile_idx * 16
    plane0 = chr_data[ofs:ofs+8]
    plane1 = chr_data[ofs+8:ofs+16]
    pixels = []
    for row in range(8):
        line = []
        for col in range(8):
            bit = 7 - col
            p0 = (plane0[row] >> bit) & 1
            p1 = (plane1[row] >> bit) & 1
            line.append(p0 | (p1 << 1))
        pixels.append(line)
    return pixels

# Collect all interesting tiles
results = []
for bank in range(32):
    path = os.path.join(CHR_DIR, f'chr_{bank:02x}.bin')
    if not os.path.exists(path):
        continue
    with open(path, 'rb') as f:
        data = f.read()
    
    # Check tiles $04-$09 (raw name bytes)
    for tile_idx in range(4, 10):
        pixels = read_tile(data, tile_idx)
        non_zero = sum(1 for row in pixels for px in row if px > 0)
        if non_zero > 4:  # not empty
            results.append((bank, tile_idx, pixels, non_zero))
    
    # Check tiles $84-$89 (name bytes + $80)
    for tile_idx in range(0x84, 0x8A):
        pixels = read_tile(data, tile_idx)
        non_zero = sum(1 for row in pixels for px in row if px > 0)
        if non_zero > 4:
            results.append((bank, tile_idx, pixels, non_zero))

# Also check $31, $36, $37 (modifier bytes)
for bank in range(32):
    path = os.path.join(CHR_DIR, f'chr_{bank:02x}.bin')
    with open(path, 'rb') as f:
        data = f.read()
    for tile_idx in [0x31, 0x36, 0x37, 0xB1, 0xB6, 0xB7]:
        pixels = read_tile(data, tile_idx)
        non_zero = sum(1 for row in pixels for px in row if px > 0)
        if non_zero > 4:
            results.append((bank, tile_idx, pixels, non_zero))

print(f"Found {len(results)} non-empty tiles")

# Create image grid
COLS = 16
ROWS = (len(results) + COLS - 1) // COLS
CELL_W = TILE_SIZE * SCALE
CELL_H = TILE_SIZE * SCALE + 16  # extra for label

img = Image.new('RGB', (COLS * CELL_W, ROWS * CELL_H), (255, 255, 255))
draw_ctx = img.load()

# Color palette (NES grayscale for simplicity)
COLORS = [(255, 255, 255), (192, 192, 192), (128, 128, 128), (0, 0, 0)]

for i, (bank, tile_idx, pixels, nz) in enumerate(results):
    col = i % COLS
    row = i // COLS
    x0 = col * CELL_W
    y0 = row * CELL_H
    
    # Draw tile
    for py in range(8):
        for px in range(8):
            color = COLORS[pixels[py][px]]
            for sy in range(SCALE):
                for sx in range(SCALE):
                    draw_ctx[x0 + px * SCALE + sx, y0 + py * SCALE + sy] = color
    
    # Draw border
    for px in range(TILE_SIZE * SCALE):
        draw_ctx[x0 + px, y0] = (200, 200, 200)
        draw_ctx[x0 + px, y0 + TILE_SIZE * SCALE - 1] = (200, 200, 200)
    for py in range(TILE_SIZE * SCALE):
        draw_ctx[x0, y0 + py] = (200, 200, 200)
        draw_ctx[x0 + TILE_SIZE * SCALE - 1, y0 + py] = (200, 200, 200)

out_path = 'output/chr_font_tiles.png'
img.save(out_path)
print(f"Saved to {out_path}")

# Print text summary
print("\nTile listing:")
for i, (bank, tile_idx, pixels, nz) in enumerate(results):
    # Check if tile looks like a font glyph (thin strokes, not solid fill)
    row_counts = [sum(1 for px in row if px > 0) for row in pixels]
    avg_width = sum(row_counts) / 8
    is_font_like = 1 < avg_width < 7  # not too thin, not too thick
    
    marker = " *FONT*" if is_font_like else ""
    print(f"  chr_{bank:02x} tile ${tile_idx:02x}: nz={nz:3d} avg_width={avg_width:.1f}{marker}")
