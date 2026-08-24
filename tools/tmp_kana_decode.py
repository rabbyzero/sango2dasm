#!/usr/bin/env python3
"""Decode officer name entries with a SERIAL gojuon katakana map and inspect leftovers.

Hypothesis: $04 = ア, serial gojuon order; $39 = dakuten, $3A = handakuten.
"""
data = open('rom/prg_combined.bin', 'rb').read()
BASE = 0x20000 + 0x101A

KATA = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
kmap = {}
for i, ch in enumerate(KATA):
    kmap[0x04 + i] = ch
# small ya/yu/yo + extras guessed serial after ン
kmap[0x35] = 'ャ'
kmap[0x36] = 'ュ'
kmap[0x37] = 'ョ'
kmap[0x39] = '゛'
kmap[0x3A] = '゜'

anchors = [('Liubei', 222, 'リュウビ'), ('Guanyu', 38, 'カンウ'),
           ('Zhangfei', 153, 'チョウヒ'), ('Zhugeliang', 109, 'ショカツリョウ')]
for nm, oid, expect in anchors:
    e = data[BASE + oid * 10: BASE + oid * 10 + 10]
    s = ''.join(kmap.get(b, f'[{b:02X}]') for b in e if b)
    print(f"{nm:12s} {e.hex()}  -> {s}   (expect {expect})  {'OK' if s.replace('゛','') == expect.replace('ビ','ヒ') or s == expect else 'CHECK'}")

# decode all valid entries, collect unknown codes
from collections import Counter
unk = Counter()
entries = []
for i in range(600):
    e = data[BASE + i * 10: BASE + i * 10 + 10]
    if e[0] in (0x00, 0xFF):
        break
    s = []
    for b in e:
        if b == 0:
            break
        if b in kmap:
            s.append(kmap[b])
        else:
            s.append(f'[{b:02X}]')
            unk[b] += 1
    entries.append((i, e, ''.join(s)))

print("\ntotal valid entries:", len(entries))
print("unknown code freq:", {f"{k:02X}": v for k, v in sorted(unk.items())})
print("\nsample decodes:")
for i, e, s in entries[:60]:
    print(f"  {i:3d} {e.hex()}  {s}")
