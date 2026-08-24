#!/usr/bin/env python3
"""Temp: dump ROM bytes at specific addresses for prg_1f verification."""
ROM = open("rom/prg/prg_1f.bin", "rb").read()
addrs = [(0xE13A, 20), (0xE1D0, 24), (0xE27E, 16)]
for a, n in addrs:
    off = a - 0xE000
    row = ROM[off:off + n]
    print("$%04X: %s" % (a, " ".join("%02X" % x for x in row)))
