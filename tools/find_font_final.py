#!/usr/bin/env python3
"""Definitive menu-font page finder: score kana + digits, dump ASCII of winners.

Text tiles live in slot5 ($40-$7F). Within a page (page-relative index = t&0x3F):
  - $44-$75 should be kana (medium density 10-45)
  - $76-$7F should be digits 0-9 (density 6-40, none solid)
  - $40-$43 often space/fill
"""

def page_tiles(path, ofs):
    d = open('rom/chr/' + path, 'rb').read()
    return d[ofs:ofs + 0x400]


def dens(chunk, t):
    o = (t & 0x3F) * 16
    return sum(bin(b).count('1') for b in chunk[o:o + 16])


def score(chunk):
    s = 0
    # kana range
    for t in range(0x44, 0x76):
        n = dens(chunk, t)
        if 10 <= n <= 45:
            s += 1
    # digits: all 10 present, none solid, none blank
    dg = [dens(chunk, t) for t in range(0x76, 0x80)]
    if all(5 <= n <= 42 for n in dg):
        s += 12
    return s


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


results = []
for bank in range(32):
    for sl in range(8):
        path = 'chr_%02x.bin' % bank
        ofs = sl * 0x400
        chunk = page_tiles(path, ofs)
        s = score(chunk)
        results.append((s, bank, sl, chunk))

results.sort(key=lambda x: -x[0])
print("Top pages by score:")
for s, bank, sl, _ in results[:8]:
    print("  score %3d  chr_%02x @ $%04X (page $%02X)" % (s, bank, sl * 0x400, bank * 8 + sl))

# Dump $40-$7F of the winner
s, bank, sl, chunk = results[0]
print("\n=== WINNER chr_%02x @ $%04X : tiles $40-$5F ===" % (bank, sl * 0x400))
tiles = list(range(0x40, 0x60))
tt = {t: show(chunk, t) for t in tiles}
for i in range(0, len(tiles), 8):
    grp = tiles[i:i + 8]
    print(' '.join('$%02X      ' % t for t in grp))
    for row in range(8):
        print(' '.join('|%s|' % tt[t][row] for t in grp))
    print()
print("=== tiles $60-$7F (incl digits $76-$7F) ===")
tiles = list(range(0x60, 0x80))
tt = {t: show(chunk, t) for t in tiles}
for i in range(0, len(tiles), 8):
    grp = tiles[i:i + 8]
    print(' '.join('$%02X      ' % t for t in grp))
    for row in range(8):
        print(' '.join('|%s|' % tt[t][row] for t in grp))
    print()
