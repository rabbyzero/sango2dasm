#!/usr/bin/env python3
"""Locate menu item strings in ROM using katakana anchors from manual scans.

Katakana codes (charmap_kana): ク=0B ニ=19 ツ=15 ヅ=15+39 り=2B ...
Search prg_combined for クニづ (0B 19 15 39) and similar anchors to find
the command-list tables and the hiragana codes used for づくり/あつめ/の/する.
"""
data = open('rom/prg_combined.bin', 'rb').read()

patterns = {
    'クニづ': bytes([0x0B, 0x19, 0x15, 0x39]),
    'ジョウホウ': bytes([0x0F, 0x39, 0x37, 0x06, 0x21, 0x06]),
    'サクリャク': bytes([0x0E, 0x0B, 0x2B, 0x35, 0x0B]),
    'ブショウ': bytes([0x1F, 0x39, 0x0F, 0x37, 0x06]),
    'ボウサイ': bytes([0x21, 0x06, 0x0E, 0x05]),
    'キロク': bytes([0x09, 0x05, 0x2B, 0x0B]),
    'トチのカ': bytes([0x17, 0x15, 0x09, 0x0B]),  # トチ no... ト=17 チ=15 ノ=? カ=09
    'サンギョウ': bytes([0x0E, 0x39, 0x37, 0x06]),
    'マチのカ': bytes([0x22, 0x15, 0x09, 0x0B]),
}
for name, pat in patterns.items():
    print(name)
    i = 0
    hits = []
    while True:
        i = data.find(pat, i)
        if i < 0:
            break
        hits.append(i)
        i += 1
    for h in hits[:8]:
        # show 16 bytes context
        ctx = data[h - 2:h + 18]
        print(f'  ofs {h:06X} (bank {h//0x2000:02X} @{0x8000+h%0x2000:04X}): '
              + ' '.join(f'{b:02X}' for b in ctx))
    if not hits:
        print('  (not found)')
