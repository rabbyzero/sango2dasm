#!/usr/bin/env python3
"""
Systematic katakana font identification for Sangokushi 2 (NES).

Strategy:
1. Render all 64 tiles from each candidate CHR 1KB slice
2. Cross-reference with hero name byte frequencies
3. Use known katakana character patterns to identify tiles
4. Build the tile-index-to-katakana mapping table
"""

import os
import sys
from collections import Counter

CHR_DIR = "/home/zero/project/sango2dasm/rom/chr"
PRG_DIR = "/home/zero/project/sango2dasm/rom/prg"

# Hero name data location: prg_10.bin offset $101A
# Each entry: 10 bytes, $00 = terminator
HERO_NAME_OFFSET = 0x101A
HERO_NAME_ENTRY_SIZE = 10
HERO_NAME_BANK = "prg_10.bin"

def read_chr_bank(bank_num):
    """Read an 8KB CHR bank file."""
    fname = os.path.join(CHR_DIR, f"chr_{bank_num:02x}.bin")
    with open(fname, "rb") as f:
        return f.read()

def read_prg_bank(bank_num):
    """Read an 8KB PRG bank file."""
    fname = os.path.join(PRG_DIR, f"prg_{bank_num:02x}.bin")
    with open(fname, "rb") as f:
        return f.read()

def get_tile_from_slice(slice_data, tile_index):
    """Extract 16 bytes for a tile from a 1KB slice (64 tiles)."""
    offset = tile_index * 16
    if offset + 16 > len(slice_data):
        return None
    return slice_data[offset:offset+16]

def render_tile(tile_data, compact=False):
    """Render a tile as ASCII art. tile_data is 16 bytes."""
    lines = []
    for row in range(8):
        bp0 = tile_data[row]
        bp1 = tile_data[row + 8]
        line = ""
        for col in range(7, -1, -1):
            bit0 = (bp0 >> col) & 1
            bit1 = (bp1 >> col) & 1
            pixel = bit0 | (bit1 << 1)
            if compact:
                line += " .o#"[pixel]
            else:
                line += ["  ", "..", "oo", "##"][pixel]
        lines.append(line)
    return lines

def tile_has_content(tile_data):
    """Check if a tile has any non-zero pixels."""
    return any(b != 0 for b in tile_data)

def tile_pixel_count(tile_data):
    """Count total non-zero pixels in a tile."""
    count = 0
    for row in range(8):
        bp0 = tile_data[row]
        bp1 = tile_data[row + 8]
        for col in range(8):
            bit0 = (bp0 >> col) & 1
            bit1 = (bp1 >> col) & 1
            if bit0 or bit1:
                count += 1
    return count

def extract_hero_names():
    """Extract hero name byte sequences from prg_10.bin."""
    data = read_prg_bank(0x10)
    names = []
    offset = HERO_NAME_OFFSET
    while offset + HERO_NAME_ENTRY_SIZE <= len(data):
        entry = data[offset:offset + HERO_NAME_ENTRY_SIZE]
        # Find terminator
        name_bytes = []
        for b in entry:
            if b == 0x00:
                break
            name_bytes.append(b)
        if name_bytes:
            names.append(name_bytes)
        offset += HERO_NAME_ENTRY_SIZE
        # Safety: don't read past end
        if offset + HERO_NAME_ENTRY_SIZE > len(data):
            break
    return names

def analyze_slice_for_font(slice_data, slice_label):
    """Analyze a 1KB CHR slice for font-like properties."""
    tiles_with_content = 0
    total_pixels = 0
    tile_pixel_counts = []

    for t in range(64):
        tile = get_tile_from_slice(slice_data, t)
        if tile is None:
            break
        pc = tile_pixel_count(tile)
        tile_pixel_counts.append(pc)
        if pc > 0:
            tiles_with_content += 1
            total_pixels += pc

    if tiles_with_content == 0:
        return None

    avg_pixels = total_pixels / tiles_with_content
    # Font tiles typically have 12-28 pixels per tile (not too dense, not too sparse)
    # and tile 0 should be blank (space)
    tile0_blank = tile_pixel_counts[0] == 0

    return {
        'label': slice_label,
        'tiles_with_content': tiles_with_content,
        'avg_pixels': avg_pixels,
        'tile0_blank': tile0_blank,
        'tile_pixel_counts': tile_pixel_counts
    }

def render_all_tiles_from_slice(slice_data, slice_label, tile_range=None):
    """Render all tiles from a 1KB slice as compact text."""
    if tile_range is None:
        tile_range = range(64)

    print(f"\n=== {slice_label} ===")
    # Render in rows of 8 tiles
    for row_start in range(0, 64, 8):
        row_tiles = [t for t in range(row_start, row_start + 8) if t in tile_range]
        if not row_tiles:
            continue

        # Header line with tile indices
        header = ""
        for t in row_tiles:
            header += f" {t:02X}      "
        print(header)

        # 8 pixel rows
        for pixel_row in range(8):
            line = ""
            for t in row_tiles:
                tile = get_tile_from_slice(slice_data, t)
                if tile is None:
                    line += "         "
                    continue
                bp0 = tile[pixel_row]
                bp1 = tile[pixel_row + 8]
                for col in range(7, -1, -1):
                    bit0 = (bp0 >> col) & 1
                    bit1 = (bp1 >> col) & 1
                    pixel = bit0 | (bit1 << 1)
                    line += " .o#"[pixel]
                line += " "
            print(line)
        print()

def main():
    print("=" * 80)
    print("Sangokushi 2 - Katakana Font Identification")
    print("=" * 80)

    # Step 1: Extract hero names and analyze byte frequencies
    hero_names = extract_hero_names()
    print(f"\n--- Hero Names (first 20 of {len(hero_names)}) ---")
    byte_counter = Counter()
    for i, name in enumerate(hero_names[:20]):
        hex_str = " ".join(f"{b:02X}" for b in name)
        print(f"  Hero {i:2d}: [{hex_str}]")
        byte_counter.update(name)

    print(f"\n--- Byte Frequency in Hero Names (top 20) ---")
    for byte_val, count in byte_counter.most_common(20):
        print(f"  ${byte_val:02X} (tile {byte_val}): {count} occurrences")

    # Step 2: Find all CHR slices with font-like properties
    print(f"\n--- Scanning all CHR banks for font candidates ---")
    candidates = []

    for bank in range(32):
        chr_data = read_chr_bank(bank)
        for slice_idx in range(8):
            slice_offset = slice_idx * 1024
            slice_data = chr_data[slice_offset:slice_offset + 1024]
            result = analyze_slice_for_font(slice_data, f"chr_{bank:02x} slice {slice_idx} (offset ${slice_offset:04X})")
            if result and result['tiles_with_content'] >= 30:
                # Score: prefer slices with tile 0 blank, many content tiles,
                # and average pixel count in font range
                score = 0
                if result['tile0_blank']:
                    score += 10
                score += result['tiles_with_content']
                if 10 <= result['avg_pixels'] <= 30:
                    score += 20
                if 15 <= result['avg_pixels'] <= 25:
                    score += 10
                candidates.append((score, result))

    candidates.sort(key=lambda x: x[0], reverse=True)
    print(f"\nTop 15 font candidates (by score):")
    for score, result in candidates[:15]:
        print(f"  Score {score:3d}: {result['label']}")
        print(f"           Tiles with content: {result['tiles_with_content']}, "
              f"Avg pixels: {result['avg_pixels']:.1f}, "
              f"Tile0 blank: {result['tile0_blank']}")

    # Step 3: Render tiles from top candidates
    # Focus on tiles in the hero name range ($04-$38)
    hero_tile_range = set(range(0x04, 0x39))

    print(f"\n--- Rendering top 5 candidates (tiles $04-$38 only) ---")
    for score, result in candidates[:5]:
        label = result['label']
        # Parse bank and slice from label
        parts = label.split()
        bank_str = parts[0]  # chr_XX
        bank_num = int(bank_str.split('_')[1], 16)
        slice_idx = int(parts[2])

        chr_data = read_chr_bank(bank_num)
        slice_offset = slice_idx * 1024
        slice_data = chr_data[slice_offset:slice_offset + 1024]

        render_all_tiles_from_slice(slice_data, label, hero_tile_range)

    # Step 4: Also render the previously identified candidate (chr_1e slice $F0)
    print(f"\n--- Previously identified candidate: chr_1e slice 0 (offset $0000) ---")
    chr_1e = read_chr_bank(0x1e)
    # Slice $F0 means the full 8KB, so slice_idx = 0xF0 / 8 = not valid
    # Actually chr_1e.bin is 8KB = 8 slices of 1KB each
    # The previous analysis found slice at offset $0000, which is slice 0
    render_all_tiles_from_slice(chr_1e[0:1024], "chr_1e slice 0 (offset $0000)", hero_tile_range)
    render_all_tiles_from_slice(chr_1e[1024:2048], "chr_1e slice 1 (offset $0400)", hero_tile_range)
    render_all_tiles_from_slice(chr_1e[2048:3072], "chr_1e slice 2 (offset $0800)", hero_tile_range)
    render_all_tiles_from_slice(chr_1e[3072:4096], "chr_1e slice 3 (offset $0C00)", hero_tile_range)
    render_all_tiles_from_slice(chr_1e[4096:5120], "chr_1e slice 4 (offset $1000)", hero_tile_range)
    render_all_tiles_from_slice(chr_1e[5120:6144], "chr_1e slice 5 (offset $1400)", hero_tile_range)
    render_all_tiles_from_slice(chr_1e[6144:7168], "chr_1e slice 6 (offset $1800)", hero_tile_range)
    render_all_tiles_from_slice(chr_1e[7168:8192], "chr_1e slice 7 (offset $1C00)", hero_tile_range)

    # Step 5: For the best candidates, try to match hero name patterns
    # Known Sangokushi 2 hero names in katakana:
    # 劉備 = リュウビ (Ryuubi), 関羽 = カンウ (Kanu), 張飛 = チョウヒ (Chouhi)
    # These should appear as sequences in the data
    print(f"\n--- Attempting katakana identification for chr_1e ---")
    print("Looking for byte patterns matching known hero names...")

    # Known characters from Romance of the Three Kingdoms:
    # リ(lu) ュ(yu) ウ(u) ビ(bi) = 劉備
    # カ(ka) ン(n) ウ(u) = 関羽
    # チ(chi) ョ(yo) ウ(u) ヒ(hi) = 張飛
    # 曹操 = ソウソウ (SouSou)
    # 呂布 = リョフ (Ryofu)
    # 諸葛亮 = ショカツリョウ (Shokatsuryou)
    # 趙雲 = チョウウン (Chouun)
    # 孫権 = ソンケン (Sonken)
    # 袁紹 = エンショウ (Enshou)

    # Let's see if any name has a repeated byte pattern (like ソウソウ for 曹操)
    print("\nSearching for repeated byte patterns (like ソウソウ):")
    for i, name in enumerate(hero_names):
        if len(name) >= 4:
            for pat_len in range(2, len(name)//2 + 1):
                pat = name[:pat_len]
                rest = name[pat_len:]
                if rest.startswith(pat) or name[:pat_len*2] == pat + pat:
                    print(f"  Hero {i}: [{' '.join(f'{b:02X}' for b in name)}] has repeated pattern [{' '.join(f'{b:02X}' for b in pat)}]")

    # Find names with the same starting byte as others (potential shared katakana)
    print("\nNames grouped by first byte:")
    by_first = {}
    for i, name in enumerate(hero_names):
        key = name[0]
        if key not in by_first:
            by_first[key] = []
        by_first[key].append((i, name))

    for key in sorted(by_first.keys()):
        entries = by_first[key]
        if len(entries) >= 3:
            print(f"  ${key:02X}: {len(entries)} heroes", end="")
            for idx, name in entries[:5]:
                print(f"  [{','.join(f'{b:02X}' for b in name[:4])}]", end="")
            print()

if __name__ == "__main__":
    main()
