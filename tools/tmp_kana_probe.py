#!/usr/bin/env python3
"""Kana name-table exploration: dump officer name entries from bank $30 $901A."""

data = open('rom/prg_combined.bin', 'rb').read()
BASE = 0x20000 + 0x101A  # bank $30 $901A -> file offset

def entry(i):
    o = BASE + i * 10
    return data[o:o + 10]

# table extent: find first all-zero entry
last = -1
for i in range(600):
    e = entry(i)
    if e[0] != 0:
        last = i
print("last non-empty entry index:", last)

# dump sample ids
for n, i in [('Liubei', 222), ('Guanyu', 38), ('Zhangfei', 153), ('Zhugeliang', 109)]:
    print(f"{n:12s} id={i:3d}  {entry(i).hex()}")

# sorted check on first byte
firsts = [entry(i)[0] for i in range(last + 1)]
print("monotonic non-decreasing first byte:", all(firsts[i] <= firsts[i+1] for i in range(len(firsts)-1)))

# frequency of bytes across all entries
from collections import Counter
c = Counter()
for i in range(last + 1):
    for b in entry(i):
        if b:
            c[b] += 1
print("byte freq (top):", c.most_common(20))
print("codes > $3F used:", sorted(b for b in c if b > 0x3F))
print("$39 count:", c.get(0x39, 0), " $3A count:", c.get(0x3A, 0))
