#!/usr/bin/env python3
"""Dump $40-$7F ASCII for all candidate text-font pages (compact, readable)."""

def load(path, ofs):
    d = open('rom/chr/' + path, 'rb').read()
    return d[ofs:ofs + 0x400]


def dens(chunk, t):
    o = (t & 0x3F) * 16
    return sum(bin(b).count('1') for b in chunk[o:o + 16])


def score(chunk):
    s = 0
    for t in range(0x44, 0x76):
        if 10 <= dens(chunk, t) <= 45:
            s += 1
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
        chunk = load('chr_%02x.bin' % bank, sl * 0x400)
        results.append((score(chunk), bank, sl, chunk))
results.sort(key=lambda x: -x[0])

out = []
for s, bank, sl, chunk in results[:14]:
    out.append("########## score %3d  chr_%02x @ $%04X (page $%02X) ##########"
               % (s, bank, sl * 0x400, bank * 8 + sl))
    for start in (0x40, 0x60):
        tiles = list(range(start, start + 0x20))
        tt = {t: show(chunk, t) for t in tiles}
        for i in range(0, 32, 8):
            grp = tiles[i:i + 8]
            out.append(' '.join('$%02X      ' % t for t in grp))
            for row in range(8):
                out.append(' '.join('|%s|' % tt[t][row] for t in grp))
            out.append('')
    out.append('')

open('output/font_pages_all.txt', 'w').write('\n'.join(out))
print('ok', len(results[:14]), 'pages dumped')
