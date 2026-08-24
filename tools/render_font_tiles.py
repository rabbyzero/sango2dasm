#!/usr/bin/env python3
"""Render font tiles from chr_08.bin as ASCII art to a text file."""

def render_tile(data, tile_idx):
    ofs = tile_idx * 16
    p0 = data[ofs:ofs+8]
    p1 = data[ofs+8:ofs+16]
    lines = []
    for row in range(8):
        line = ''
        for col in range(8):
            bit = 7 - col
            b0 = (p0[row] >> bit) & 1
            b1 = (p1[row] >> bit) & 1
            px = b0 | (b1 << 1)
            line += ' .o@'[px]
        lines.append(line)
    return lines

with open('rom/chr/chr_08.bin', 'rb') as f:
    chr08 = f.read()

out = []
out.append("chr_08.bin: %d bytes" % len(chr08))

# Tiles $04-$3F
out.append("\n=== Tiles $04-$3F ===\n")
for t in range(0x04, 0x40):
    ofs = t * 16
    tile_data = chr08[ofs:ofs+16]
    density = sum(bin(b).count('1') for b in tile_data)
    if density == 0:
        continue
    lines = render_tile(chr08, t)
    marker = " <<<" if 0x04 <= t <= 0x09 else ""
    out.append("Tile $%02X (density %3d):%s" % (t, density, marker))
    for l in lines:
        out.append("  |%s|" % l)
    out.append("")

# Tiles $84-$89 (name byte + $80)
out.append("\n=== Tiles $84-$89 (name byte + $80) ===\n")
for t in range(0x84, 0x8A):
    ofs = t * 16
    tile_data = chr08[ofs:ofs+16]
    density = sum(bin(b).count('1') for b in tile_data)
    lines = render_tile(chr08, t)
    out.append("Tile $%02X (density %3d):" % (t, density))
    for l in lines:
        out.append("  |%s|" % l)
    out.append("")

# Density table
out.append("\n=== Density table (first 64 tiles) ===")
for t in range(64):
    ofs = t * 16
    density = sum(bin(b).count('1') for b in chr08[ofs:ofs+16])
    out.append("  $%02X: %3d" % (t, density))

with open('output/chr08_font.txt', 'w') as f:
    f.write('\n'.join(out))

print("Done: output/chr08_font.txt")
