#!/usr/bin/env python3
"""Dump chr_0f@0x0000 (page $78) digits + kanji as ASCII."""

d = open('rom/chr/chr_0f.bin', 'rb').read()
ch = d[0x0000:0x0400]


def show(t):
    o = (t & 0x3F) * 16
    p0 = ch[o:o + 8]
    p1 = ch[o + 8:o + 16]
    rows = []
    for row in range(8):
        line = ''
        for col in range(8):
            bit = 7 - col
            px = (p0[row] >> bit) & 1 | (((p1[row] >> bit) & 1) << 1)
            line += ' .o@'[px]
        rows.append(line)
    return rows


def block(tiles, label):
    print(label + ':')
    tt = {t: show(t) for t in tiles}
    print(' '.join('$%02X      ' % t for t in tiles))
    for row in range(8):
        print(' '.join('|%s|' % tt[t][row] for t in tiles))
    print()


block(list(range(0x76, 0x80)), "digits $76-$7F (0-9)")
block(list(range(0x44, 0x4C)), "kanji $44-$4B")
block(list(range(0x4C, 0x54)), "kanji $4C-$53")
block(list(range(0x54, 0x5C)), "kanji $54-$5B")
block(list(range(0x5C, 0x64)), "kanji $5C-$63")
block(list(range(0x64, 0x6C)), "kanji $64-$6B")
block(list(range(0x6C, 0x76)), "kanji $6C-$75")
