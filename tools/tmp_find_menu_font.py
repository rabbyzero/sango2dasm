#!/usr/bin/env python3
"""Scan all CHR slices for the menu font: digits must live at tiles $76-$7F
(known from CmdDrawNumber: digit tile = $76 + digit)."""
import os

CHR_DIR = "/home/zero/project/sango2dasm/rom/chr"

def pc(tile):
    n = 0
    for r in range(8):
        x = tile[r] | tile[r + 8]
        n += bin(x).count("1")
    return n

def sym(tile):
    # horizontal mirror similarity (digits 0,1,8 are mirror-symmetric)
    s = 0
    for r in range(8):
        b = tile[r]
        rev = int(f"{b:08b}"[::-1], 2)
        if b == rev:
            s += 1
    return s

cands = []
for bank in range(32):
    with open(os.path.join(CHR_DIR, f"chr_{bank:02x}.bin"), "rb") as f:
        d = f.read()
    if len(d) < 8192:
        d = d + b"\x00" * (8192 - len(d))
    for pt in range(4):  # 2KB pattern-table granularity
        off = pt * 2048
        counts = []
        ok = True
        for t in range(0x76, 0x80):
            tile = d[off + t * 16: off + t * 16 + 16]
            c = pc(tile)
            counts.append(c)
            if c < 8 or c > 40:
                ok = False
        if ok:
            t0 = pc(d[off:off + 16])
            n_kana = sum(1 for t in range(0x20, 0x76)
                         if pc(d[off + t * 16: off + t * 16 + 16]) >= 8)
            s76 = sym(d[off + 0x76 * 16: off + 0x76 * 16 + 16])
            cands.append((bank, pt, counts, t0, n_kana, s76))

for bank, pt, counts, t0, n_kana, s76 in cands:
    print(f"chr_{bank:02x} ptable {pt} (${pt*2048:04X}): digits76-7F px={counts} "
          f"tile0={t0} kana-like($20-75)={n_kana} sym76={s76}")
