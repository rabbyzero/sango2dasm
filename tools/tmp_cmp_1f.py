#!/usr/bin/env python3
"""Temp: compare build/test_1f.bin against rom/prg/prg_1f.bin."""
a = open("build/test_1f.bin", "rb").read()
b = open("rom/prg/prg_1f.bin", "rb").read()
print("sizes: built=%d rom=%d" % (len(a), len(b)))
n = min(len(a), len(b))
diffs = [(i, a[i], b[i]) for i in range(n) if a[i] != b[i]]
print("differing bytes: %d" % len(diffs))
for i, x, y in diffs[:60]:
    print("$%04X: built=%02X rom=%02X" % (0xE000 + i, x, y))
