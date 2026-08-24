#!/usr/bin/env python3
"""Cross-reference officer name bytes with known katakana readings.

Name table: bank $30 @ $901A (physical bank $10, file ofs 0x2101A),
10-byte entries, $00-terminated. CmdDrawName stores bytes directly as
tile indices (StoreTileByte, offset 0) -> byte values ARE char codes.
"""

d = open('rom/prg_combined.bin', 'rb').read()
off = 0x2101A
names = []
for i in range(50):
    e = d[off + i * 10:off + i * 10 + 10]
    nb = []
    for b in e:
        if b == 0:
            break
        nb.append(b)
    names.append(nb)

KNOWN = [
    "リュウビ", "カンウ", "チョウヒ", "チョウウン", "ショカツリョウ",
    "カンキョウ", "ソンケン", "ソウソウ", "ソウヒ", "カコウトン",
    "カコウエン", "テンイ", "キョチョ", "リョフ", "エンショウ",
    "エンジュツ", "バチョウ", "カク", "シュウユ", "ロシュク",
    "リクソン", "リョモウ", "カンネイ", "タイシジ", "ホウトウ",
    "コウチュウ", "ギエン", "マダイ", "シバイ", "シュハ",
    "キョウカイ", "キョウト", "オウヘイ", "チョウホウ", "ギカイ",
    "コウガイ", "ジョウタイ", "レイソウ", "チョウイン", "サイボウ",
]

for i, nb in enumerate(names[:40]):
    hx = ' '.join('%02X' % b for b in nb)
    kn = KNOWN[i] if i < len(KNOWN) else '?'
    print('%2d  %-12s  [%s]  len=%d/%d%s' % (
        i, hx, kn, len(nb), len(kn),
        '  MISMATCH' if i < len(KNOWN) and len(nb) != len(kn) else ''))
