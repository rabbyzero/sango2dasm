#!/usr/bin/env python3
"""ASCII-render a full 2KB pattern table (256 tiles) of a CHR bank, block by block."""
import os
import sys

CHR_DIR = "/home/zero/project/sango2dasm/rom/chr"

def load(bank):
    with open(os.path.join(CHR_DIR, f"chr_{bank:02x}.bin"), "rb") as f:
        d = f.read()
    if len(d) < 8192:
        d += b"\x00" * (8192 - len(d))
    return d

def render(d, base, lo, hi, per_row=16):
    idx = lo
    while idx < hi:
        end = min(idx + per_row, hi)
        print(" ".join(f" {t:02X}   " for t in range(idx, end)))
        rows = [""] * 8
        for t in range(idx, end):
            tile = d[base + t * 16: base + t * 16 + 16]
            for r in range(8):
                bp0 = tile[r]; bp1 = tile[r + 8]
                line = "".join(
                    " .o#"[((bp0 >> c) & 1) | (((bp1 >> c) & 1) << 1)]
                    for c in range(7, -1, -1))
                rows[r] += line + " "
        print("\n".join(rows))
        print()
        idx = end

if __name__ == "__main__":
    bank = int(sys.argv[1], 16)
    pt = int(sys.argv[2])
    lo = int(sys.argv[3], 16)
    hi = int(sys.argv[4], 16)
    d = load(bank)
    render(d, pt * 2048, lo, hi)
