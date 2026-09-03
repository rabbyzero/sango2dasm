#!/usr/bin/env python3
"""Extract RAM equates (values in $0000-$07FF or $6000-$7FFF) from each bank asm file.

Groups results per bank and prints comments attached to each equate so the
consolidated map can quote the per-bank semantic meaning.
"""
import re
import os

BANK_DIR = "asm/banks"
BANKS = [
    "prg_08_09.asm", "prg_0a_0b.asm", "prg_0c_0d.asm", "prg_0e_0f.asm",
    "prg_17_18.asm", "prg_19_1a.asm", "prg_1b_1c.asm", "prg_1d_1e.asm",
    "prg_1f.asm",
]

eq_re = re.compile(r"^\s*([A-Za-z_][\w]*)\s*=\s*\$([0-9A-Fa-f]{1,4})\b\s*;?(.*)$")


def val_in_range(v):
    return v <= 0x07FF or 0x6000 <= v <= 0x7FFF


for bank in BANKS:
    path = os.path.join(BANK_DIR, bank)
    if not os.path.exists(path):
        continue
    print("=" * 100)
    print("BANK:", bank)
    print("=" * 100)
    found = {}
    with open(path, encoding="utf-8", errors="replace") as f:
        for lineno, line in enumerate(f, 1):
            m = eq_re.match(line)
            if not m:
                continue
            name, hexv, comment = m.group(1), m.group(2), m.group(3).strip()
            v = int(hexv, 16)
            if len(hexv) < 3:
                continue  # skip 1-2 digit values (not full addresses)
            if not val_in_range(v):
                continue
            found.setdefault((name, v), []).append((lineno, comment))
    for (name, v), occs in sorted(found.items(), key=lambda kv: (kv[0][1], kv[0][0])):
        # print first occurrence comment + count if duplicated
        lineno, comment = occs[0]
        dup = f" (x{len(occs)})" if len(occs) > 1 else ""
        print(f"${v:04X}  {name}{dup:<8} [{bank}:{lineno}]  {comment}")
    print()
