#!/usr/bin/env python3
"""Scan raw RAM address references ($00xx-$07xx, $6Fxx/$7xxx) in prg_19_1a.asm and
prg_1b_1c.asm operand fields; print per-address usage with one sample comment."""
import re
from collections import defaultdict

FILES = ["asm/banks/prg_19_1a.asm", "asm/banks/prg_1b_1c.asm"]
op_re = re.compile(r"^\s*(?:[A-Z]{3}[A-Z]?|\.byte|\.word)\s+(.*?)(?:\s*;.*)?$")
addr_re = re.compile(r"\$([0-9A-Fa-f]{3,4})\b")

for path in FILES:
    print("=" * 100)
    print("FILE:", path)
    print("=" * 100)
    usage = defaultdict(list)
    with open(path, encoding="utf-8", errors="replace") as f:
        for lineno, line in enumerate(f, 1):
            m = op_re.match(line)
            if not m:
                continue
            ops = m.group(1)
            # strip inline label defs
            for am in addr_re.finditer(ops):
                v = int(am.group(1), 16)
                # keep full 4-digit addresses in RAM ranges; 3-digit like $300 also OK
                if v >= 0x100 and v <= 0x7FF or 0x6000 <= v <= 0x7FFF:
                    comment = line.split(";", 1)[1].strip() if ";" in line else ""
                    usage[v].append((lineno, comment))
    for v in sorted(usage):
        occs = usage[v]
        # pick a comment that mentions the address or the first non-empty
        sample = next((c for _, c in occs if c), "")
        print(f"${v:04X} x{len(occs):<4} {sample[:110]}")
    print()
