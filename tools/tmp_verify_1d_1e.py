#!/usr/bin/env python3
"""Extract annotated bytes from prg_1d_1e.asm and compare vs ROM banks 1D+1E."""
import re, json, sys

path = sys.argv[1] if len(sys.argv) > 1 else "asm/banks/prg_1d_1e.asm"
extracted = {}
pat = re.compile(r";\s*\$([0-9A-Fa-f]{4}):\s*((?:[0-9A-Fa-f]{2}(?:\s|$))+)(?=\||;|$)")
for lineno, line in enumerate(open(path), 1):
    m = pat.search(line)
    if m:
        addr = int(m.group(1), 16)
        for i, hb in enumerate(m.group(2).split()):
            extracted[addr + i] = int(hb, 16)

orig = open("rom/prg/prg_1d.bin", "rb").read() + open("rom/prg/prg_1e.bin", "rb").read()
base = 0xA000
mism = [(a, extracted[a], orig[a - base]) for a in sorted(extracted)
        if a - base < len(orig) and extracted[a] != orig[a - base]]
print(f"annotated_bytes={len(extracted)} rom_mismatches={len(mism)}")
json.dump(mism, open(sys.argv[2] if len(sys.argv) > 2 else "/tmp/byte_mismatch.json", "w"))
