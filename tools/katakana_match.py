#!/usr/bin/env python3
"""
Compare game font tiles against a standard katakana reference.
Uses a built-in 8x8 katakana bitmap set to match tile indices to characters.
"""

# Standard 8x8 katakana bitmaps (1-bit, row-major, MSB first)
# These are hand-crafted reference bitmaps for common katakana characters
# Each entry: (character, romaji, 8 bytes of bitmap data)
# Format: each byte = one row, MSB = leftmost pixel

KATAKANA_8X8 = {
    # Basic katakana - Gojuon order
    'ア': 'a',  'イ': 'i',  'ウ': 'u',  'エ': 'e',  'オ': 'o',
    'カ': 'ka', 'キ': 'ki', 'ク': 'ku', 'ケ': 'ke', 'コ': 'ko',
    'サ': 'sa', 'シ': 'shi','ス': 'su', 'セ': 'se', 'ソ': 'so',
    'タ': 'ta', 'チ': 'chi','ツ': 'tsu','テ': 'te', 'ト': 'to',
    'ナ': 'na', 'ニ': 'ni', 'ヌ': 'nu', 'ネ': 'ne', 'ノ': 'no',
    'ハ': 'ha', 'ヒ': 'hi', 'フ': 'fu', 'ヘ': 'he', 'ホ': 'ho',
    'マ': 'ma', 'ミ': 'mi', 'ム': 'mu', 'メ': 'me', 'モ': 'mo',
    'ヤ': 'ya', 'ユ': 'yu', 'ヨ': 'yo',
    'ラ': 'ra', 'リ': 'ri', 'ル': 'ru', 'レ': 're', 'ロ': 'ro',
    'ワ': 'wa', 'ヲ': 'wo', 'ン': 'n',
    # Dakuten
    'ガ': 'ga', 'ギ': 'gi', 'グ': 'gu', 'ゲ': 'ge', 'ゴ': 'go',
    'ザ': 'za', 'ジ': 'ji', 'ズ': 'zu', 'ゼ': 'ze', 'ゾ': 'zo',
    'ダ': 'da', 'ヂ': 'di', 'ヅ': 'du', 'デ': 'de', 'ド': 'do',
    'バ': 'ba', 'ビ': 'bi', 'ブ': 'bu', 'ベ': 'be', 'ボ': 'bo',
    'パ': 'pa', 'ピ': 'pi', 'プ': 'pu', 'ペ': 'pe', 'ポ': 'po',
    # Small characters
    'ァ': 'a_s', 'ィ': 'i_s', 'ゥ': 'u_s', 'ェ': 'e_s', 'ォ': 'o_s',
    'ャ': 'ya_s','ュ': 'yu_s','ョ': 'yo_s','ッ': 'tsu_s',
    # Special
    'ー': 'ー', '。': '。', '、': '、',
}

def read_chr_slice(bank, slice_idx):
    data = open(f'rom/chr/chr_{bank:02x}.bin', 'rb').read()
    offset = slice_idx * 1024
    return data[offset:offset + 1024]

def get_tile_bitmap(slice_data, tile_idx):
    """Get 1-bit bitmap of a tile (combining both bitplanes)."""
    offset = tile_idx * 16
    tile_data = slice_data[offset:offset + 16]
    bitmap = []
    for row in range(8):
        # Combine both bitplanes: pixel is "on" if either bitplane has a bit set
        combined = tile_data[row] | tile_data[row + 8]
        bitmap.append(combined)
    return bitmap

def bitmap_to_string(bitmap):
    """Convert 8-byte bitmap to visual string."""
    lines = []
    for byte in bitmap:
        line = ''
        for col in range(7, -1, -1):
            line += '#' if (byte >> col) & 1 else ' '
        lines.append(line)
    return lines

def count_set_bits(bitmap):
    """Count total set bits in bitmap."""
    count = 0
    for byte in bitmap:
        count += bin(byte).count('1')
    return count

def compare_bitmaps(bm1, bm2):
    """Compare two 8-byte bitmaps. Returns number of matching pixels."""
    matches = 0
    total = 64
    for i in range(8):
        # XOR to find differences, then count matches
        xor = bm1[i] ^ bm2[i]
        matches += 8 - bin(xor).count('1')
    return matches, total

def extract_hero_names():
    data = open('rom/prg/prg_10.bin', 'rb').read()
    names = []
    offset = 0x101A
    while offset + 10 <= len(data):
        entry = data[offset:offset + 10]
        name_bytes = []
        for b in entry:
            if b == 0x00:
                break
            name_bytes.append(b)
        if name_bytes:
            names.append(name_bytes)
        offset += 10
        if offset + 10 > len(data):
            break
    return names

# Load game font tiles from chr_00 slice 4 (most common $00AE value)
# and chr_00 slice 0
candidates = [
    (0x00, 4, 'chr_00 slice 4'),
    (0x00, 0, 'chr_00 slice 0'),
]

hero_names = extract_hero_names()
print(f"Total hero names: {len(hero_names)}")

for bank, slice_idx, label in candidates:
    slice_data = read_chr_slice(bank, slice_idx)
    print(f"\n{'='*70}")
    print(f"Analyzing: {label}")
    print(f"{'='*70}")
    
    # Render all tiles 4-56 as 1-bit bitmaps
    print("\n--- Tile bitmaps (1-bit, combined bitplanes) ---")
    for tile_idx in range(0x04, 0x39):
        bitmap = get_tile_bitmap(slice_data, tile_idx)
        lines = bitmap_to_string(bitmap)
        density = count_set_bits(bitmap)
        hex_bytes = ' '.join(f'{b:02X}' for b in bitmap)
        print(f'Tile ${tile_idx:02X} ({density:2d}/64): {hex_bytes}')
        for line in lines:
            print(f'  |{line}|')

# Now try hero name matching using known Three Kingdoms characters
print(f"\n{'='*70}")
print("Hero name pattern analysis")
print(f"{'='*70}")

# Known hero names in katakana (most famous ones)
known_names = {
    'リュウビ': '劉備',
    'カンウ': '関羽',
    'チョウヒ': '張飛',
    'ソウソウ': '曹操',
    'リョフ': '呂布',
    'チョウウン': '趙雲',
    'ソンケン': '孫権',
    'エンショウ': '袁紹',
    'バチョウ': '馬超',
    'コウチュウ': '黄忠',
    'ギエン': '魏延',
    'テンイ': '典韋',
    'キョチョ': '許褚',
    'カコウトン': '夏侯惇',
    'カコウエン': '夏侯淵',
    'シバイ': '司馬懿',
    'シュウユ': '周瑜',
    'ロシュク': '魯粛',
    'リクソン': '陸遜',
    'リョモウ': '呂蒙',
    'カンネイ': '甘寧',
    'タイシジ': '太史慈',
    'ホウトウ': '龐統',
    'ショカツリョウ': '諸葛亮',
    'カク': '郭嘉',
    'シカク': '司馬徽',
    'シュハ': '周倉',
    'リカク': '李角',
}

# Try to match hero name byte sequences against known katakana patterns
# Strategy: find byte sequences where the same byte always represents the same katakana

# First, find which hero names have unique byte counts (can help identify)
print("\n--- Hero names by length ---")
by_length = {}
for i, name in enumerate(hero_names):
    l = len(name)
    if l not in by_length:
        by_length[l] = []
    by_length[l].append((i, name))

for l in sorted(by_length.keys()):
    entries = by_length[l]
    print(f"\nLength {l} ({len(entries)} heroes):")
    for idx, name in entries[:10]:
        hex_str = ' '.join(f'{b:02X}' for b in name)
        print(f'  Hero {idx:3d}: [{hex_str}]')
    if len(entries) > 10:
        print(f'  ... and {len(entries)-10} more')

# Try constraint-based matching
# Find heroes where we can identify the name from the byte pattern
print(f"\n--- Constraint-based matching ---")

# Hero 6: [07 15 0A 15] - byte $15 appears at pos 1 and 3
# This matches ソンケン (ソ, ン, ケ, ン) if $07=ソ, $15=ン, $0A=ケ
# Or other XンYン patterns
h6 = hero_names[6]
print(f"Hero 6: [{' '.join(f'{b:02X}' for b in h6)}]")
print(f"  Possible: ソンケン if $07=ソ, $15=ン, $0A=ケ")

# If $15=ン, check other names with $15
print(f"\nHeroes containing $15 (potential ン):")
for i, name in enumerate(hero_names[:50]):
    if 0x15 in name:
        hex_str = ' '.join(f'{b:02X}' for b in name)
        positions = [j for j, b in enumerate(name) if b == 0x15]
        print(f"  Hero {i:3d}: [{hex_str}] $15 at pos {positions}")

# If $31=ウ, check other names with $31
print(f"\nHeroes containing $31 (potential ウ):")
for i, name in enumerate(hero_names[:50]):
    if 0x31 in name:
        hex_str = ' '.join(f'{b:02X}' for b in name)
        positions = [j for j, b in enumerate(name) if b == 0x31]
        print(f"  Hero {i:3d}: [{hex_str}] $31 at pos {positions}")

# If $06 is common, check what character it could be
print(f"\nHeroes containing $06 (high frequency):")
for i, name in enumerate(hero_names[:50]):
    if 0x06 in name:
        hex_str = ' '.join(f'{b:02X}' for b in name)
        positions = [j for j, b in enumerate(name) if b == 0x06]
        print(f"  Hero {i:3d}: [{hex_str}] $06 at pos {positions}")
