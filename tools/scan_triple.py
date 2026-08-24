#!/usr/bin/env python3
"""Triple-constraint font scan:
  $04-$39 kanji (dense glyphs, names dict renders here)
  $44-$75 kana
  $76-$7F digits
"""


def load(bank, sl):
    d = open('rom/chr/chr_%02x.bin' % bank, 'rb').read()
    return d[sl * 0x400:sl * 0x400 + 0x400]


def dens(chunk, t):
    o = (t & 0x3F) * 16
    return sum(bin(b).count('1') for b in chunk[o:o + 16])


results = []
for bank in range(32):
    for sl in range(8):
        chunk = load(bank, sl)
        kanji = [dens(chunk, t) for t in range(0x04, 0x3A)]
        kana = [dens(chunk, t) for t in range(0x44, 0x76)]
        digs = [dens(chunk, t) for t in range(0x76, 0x80)]
        # kanji: all present, dense
        k_ok = sum(1 for n in kanji if 20 <= n <= 62)
        n_ok = sum(1 for n in kana if 10 <= n <= 45)
        d_ok = all(6 <= n <= 42 for n in digs)
        score = k_ok * 2 + n_ok + (15 if d_ok else 0)
        results.append((score, k_ok, n_ok, d_ok, bank, sl))

results.sort(reverse=True)
for r in results[:12]:
    s, k, n, dok, bank, sl = r
    print('score %3d  kanji %2d/54  kana %2d/50  digits %s  chr_%02x @ $%04X (page $%02X)'
          % (s, k, n, 'OK ' if dok else 'no ', bank, sl * 0x400, bank * 8 + sl))
