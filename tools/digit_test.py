#!/usr/bin/env python3
"""Decisive digit test: on the real text font page, $76-$7F = 0..9.
Digit 1 is thin, 0 round, 8 densest. Find pages where the density ordering
matches plausible digit shapes, then dump them.
"""


def load(bank, sl):
    d = open('rom/chr/chr_%02x.bin' % bank, 'rb').read()
    return d[sl * 0x400:sl * 0x400 + 0x400]


def dens(chunk, t):
    o = (t & 0x3F) * 16
    return sum(bin(b).count('1') for b in chunk[o:o + 16])


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


hits = []
for bank in range(32):
    for sl in range(8):
        chunk = load(bank, sl)
        dg = [dens(chunk, 0x76 + i) for i in range(10)]
        if any(n < 4 or n > 46 for n in dg):
            continue
        # digit-1 ($77) thinner than digit-0 ($76); digit-8 ($7E) dense
        if dg[1] >= dg[0]:
            continue
        if dg[8] < dg[0]:
            continue
        hits.append((bank, sl, dg, chunk))

print("Candidates (%d):" % len(hits))
for bank, sl, dg, _ in hits:
    print("  chr_%02x @ $%04X  digits0-9 px=%s" % (bank, sl * 0x400, dg))

# dump top few
for bank, sl, dg, chunk in hits[:6]:
    print("\n=== chr_%02x @ $%04X  $76-$7F ===" % (bank, sl * 0x400))
    tt = {t: show(chunk, t) for t in range(0x76, 0x80)}
    for row in range(8):
        print(' '.join('|%s|' % tt[t][row] for t in range(0x76, 0x80)))
