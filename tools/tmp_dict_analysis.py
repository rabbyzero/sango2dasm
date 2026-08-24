#!/usr/bin/env python3
"""Build char-code map from the $901A sorted string dictionary.

Anchor: entry 14 = エンショウ (袁紹) -> code(エ)=08, code(ン)=06,
code(シ)=14, code(ョ)=36, code(ウ)=06?? no: エ ン シ ョ ウ = 5 kana,
bytes 08 06 14 36 06 -> エ=08 ン=06 シ=14 ョ=36 ウ=06?? COLLISION ン=ウ=06!
So recheck: maybe 06 is long-vowel マル or the reading differs.
Dump entries sharing codes to find consistent assignments.
"""

d = open('rom/prg_combined.bin', 'rb').read()
off = 0x2101A
entries = []
for i in range(50):
    e = d[off + i * 10:off + i * 10 + 10]
    nb = []
    for b in e:
        if b == 0:
            break
        nb.append(b)
    if nb:
        entries.append(nb)

from collections import Counter
code_freq = Counter(b for e in entries for b in e)
print("Code frequency (top 20):")
for c, n in code_freq.most_common(20):
    print("  $%02X: %d" % (c, n))

print("\nEntries ending in $31 (likely X-shuu place names):")
for e in entries:
    if e[-1] == 0x31:
        print("  ", ' '.join('%02X' % b for b in e))

print("\nEntries containing $31 mid-word:")
for e in entries:
    if 0x31 in e[:-1]:
        print("  ", ' '.join('%02X' % b for b in e))

print("\nAll entries:")
for i, e in enumerate(entries):
    print(" %2d  %s" % (i, ' '.join('%02X' % b for b in e)))
