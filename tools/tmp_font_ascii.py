#!/usr/bin/env python3
"""
ASCII-render candidate menu-font CHR slices and dump officer-name byte table.
Used to build the text-code -> character map for menu strings.
"""
import os

CHR_DIR = "/home/zero/project/sango2dasm/rom/chr"
PRG_DIR = "/home/zero/project/sango2dasm/rom/prg"

def load(path):
    with open(path, "rb") as f:
        return f.read()

def render_slice(data, off, label, lo=0, hi=64, per_row=16):
    print(f"\n===== {label} =====")
    idx = lo
    while idx < hi:
        end = min(idx + per_row, hi)
        hdr = "".join(f" {t:02X}   " for t in range(idx, end))
        print(hdr)
        rows = [""] * 8
        for t in range(idx, end):
            tile = data[off + t * 16: off + t * 16 + 16]
            for r in range(8):
                bp0 = tile[r]; bp1 = tile[r + 8]
                line = ""
                for c in range(7, -1, -1):
                    p = ((bp0 >> c) & 1) | (((bp1 >> c) & 1) << 1)
                    line += " .o#"[p]
                rows[r] += line + " "
        for r in rows:
            print(r)
        print()
        idx = end

def dump_names():
    d = load(os.path.join(PRG_DIR, "prg_10.bin"))
    print("=== officer name table @ prg_10.bin + $101A (id: bytes) ===")
    base = 0x101A
    for i in range(40):
        off = base + i * 10
        e = d[off:off + 10]
        nb = []
        for b in e:
            if b == 0:
                break
            nb.append(b)
        print(f"  {i:3d}: {' '.join(f'{b:02X}' for b in nb)}")

if __name__ == "__main__":
    # Candidates from earlier font scanning (font_bankNN_sliceM.png artifacts)
    cands = [
        (0x00, 4), (0x00, 0), (0x0F, 4), (0x01, 2),
        (0x04, 0), (0x10, 0), (0x14, 7), (0x1E, 0),
    ]
    for bank, sl in cands:
        d = load(os.path.join(CHR_DIR, f"chr_{bank:02x}.bin"))
        # only render slices that have many non-blank tiles
        off = sl * 1024
        n_content = 0
        for t in range(64):
            tile = d[off + t * 16: off + t * 16 + 16]
            if any(tile):
                n_content += 1
        if n_content >= 24:
            render_slice(d, off, f"chr_{bank:02x} slice {sl} (${off:04X}) [{n_content} nonblank]")
    dump_names()
