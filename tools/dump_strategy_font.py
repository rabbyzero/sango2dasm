#!/usr/bin/env python3
"""Dump the STRATEGY-MENU text font pages as ASCII:
  slot 4 (tiles $00-$3F): page $95 = chr_12 @ $1400
  slot 5 (tiles $40-$7F): page $78 = chr_0f @ $0000
"""

out = []


def load(path, ofs):
    d = open(path, 'rb').read()
    return d[ofs:ofs + 0x400]


def show(chunk, t):
    o = (t & 0x3F) * 16
    p0 = chunk[o:o + 8]
    p1 = chunk[o + 8:o + 16]
    rows = []
    for row in range(8):
        line = ''
        for col in range(8):
            bit = 7 - col
            px = (p0[row] >> bit) & 1 | (((p1[row] >> bit) & 1) << 1)
            line += ' .o@'[px]
        rows.append(line)
    return rows


def dump(chunk, tiles, title):
    out.append(title)
    for i in range(0, len(tiles), 8):
        grp = tiles[i:i + 8]
        tt = {t: show(chunk, t) for t in grp}
        out.append(' '.join('$%02X      ' % t for t in grp))
        for row in range(8):
            out.append(' '.join('|%s|' % tt[t][row] for t in grp))
        out.append('')


c95 = load('rom/chr/chr_12.bin', 0x1400)
dump(c95, list(range(0x00, 0x20)), "=== page $95 (chr_12@1400) tiles $00-$1F ===")
dump(c95, list(range(0x20, 0x40)), "=== page $95 tiles $20-$3F ===")

c78 = load('rom/chr/chr_0f.bin', 0x0000)
dump(c78, list(range(0x40, 0x60)), "=== page $78 (chr_0f@0000) tiles $40-$5F ===")
dump(c78, list(range(0x60, 0x80)), "=== page $78 tiles $60-$7F (digits $76-$7F) ===")

open('output/strategy_font_ascii.txt', 'w').write('\n'.join(out))
print('ok')
