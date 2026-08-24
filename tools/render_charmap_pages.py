#!/usr/bin/env python3
"""Render menu font pages as readable ASCII art for char-map construction.

Pages (from code/font_analysis.md):
  - page $70 = chr_0e.bin @ $0000, tiles $00-$3F (pure kana, officer-list font)
  - page $95 = chr_12.bin @ $1400, tiles $00-$3F (kanji/kana, strategy menus)
  - page $78 = chr_0f.bin @ $0000, tiles $40-$7F (kanji + digits)

Tile byte B: slot = B >> 6 selects the 1KB page; glyph index within the
page = B & $3F. So page $78 tiles $40-$7F are page-internal indices $00-$3F.
Tile byte -> 2bpp NES pattern: color = lo_bit | (hi_bit << 1).
Ink chars: color3='@' color2='o' color1='.' color0=' '.
"""
import os
import sys

CHR_DIR = os.path.join(os.path.dirname(__file__), '..', 'rom', 'chr')
INK = ' .o@'


def load(name):
    with open(os.path.join(CHR_DIR, name), 'rb') as f:
        return f.read()


def tile_rows(data, base, idx):
    off = base + idx * 16
    lo = data[off:off + 8]
    hi = data[off + 8:off + 16]
    rows = []
    for y in range(8):
        line = ''
        for x in range(8):
            c = ((lo[y] >> (7 - x)) & 1) | (((hi[y] >> (7 - x)) & 1) << 1)
            line += INK[c]
        rows.append(line)
    return rows


def render(data, base, entries, cols, label, scale=2):
    """entries: list of (tile_byte_label, page_internal_index)."""
    print(f'=== {label} ===')
    for row_start in range(0, len(entries), cols):
        chunk = entries[row_start:row_start + cols]
        header = ''.join(f'${lbl:02X}'.ljust(8 * scale + 2) for lbl, _ in chunk)
        print(header)
        arts = [tile_rows(data, base, idx) for _, idx in chunk]
        for y in range(8):
            line = ''.join(('|' + arts[i][y] * scale + '| ')
                           for i in range(len(chunk)))
            print(line)
        print()


def main():
    chr0e = load('chr_0e.bin')
    chr0f = load('chr_0f.bin')
    chr12 = load('chr_12.bin')

    # tiles $00-$3F: byte == page-internal index
    low = [(i, i) for i in range(0x00, 0x40)]
    render(chr0e, 0x0000, low, 8,
           'page $70 (chr_0e @ $0000) tiles $00-$3F  [kana font]')
    render(chr12, 0x1400, low, 8,
           'page $95 (chr_12 @ $1400) tiles $00-$3F  [strategy-menu kanji]')
    # tiles $40-$7F: page-internal index = byte & $3F
    high = [(b, b & 0x3F) for b in range(0x40, 0x80)]
    render(chr0f, 0x0000, high, 8,
           'page $78 (chr_0f @ $0000) tiles $40-$7F  [kanji + digits]')


if __name__ == '__main__':
    main()
