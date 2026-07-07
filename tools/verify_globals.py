#!/usr/bin/env python3
import re
from collections import defaultdict

with open("asm/banks/prg_1d_1e.asm") as f:
    lines = f.readlines()

procs = []
for i, line in enumerate(lines):
    m = re.match(r'^\.proc\s+(\S+)', line)
    if m:
        procs.append((i+1, m.group(1)))
    m = re.match(r'^\.endproc', line)
    if m and procs:
        start, name = procs[-1]
        procs[-1] = (start, i+1, name)
procs = [p for p in procs if len(p) == 3]

ram_re = re.compile(r'\$0([0-7][0-9a-fA-F]{2})\b')
addr_usage = defaultdict(lambda: defaultdict(int))
addr_filescope = defaultdict(int)

for proc_info in procs:
    start, end, name = proc_info
    for i in range(start-1, min(end, len(lines))):
        for m in ram_re.finditer(lines[i]):
            addr = int(m.group(0)[1:], 16)
            addr_usage[addr][name] += 1

in_proc = set()
for s, e, n in procs:
    for l in range(s-1, e):
        in_proc.add(l)
for i, line in enumerate(lines):
    if i not in in_proc:
        for m in ram_re.finditer(line):
            addr = int(m.group(0)[1:], 16)
            addr_filescope[addr] += 1

# Check all currently-defined global addresses
global_defs = [
    0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0006, 0x0007, 0x0008, 0x0009,
    0x000A, 0x000B, 0x000C, 0x0010, 0x0011, 0x0013, 0x0017,
    0x005E, 0x0061, 0x0068, 0x0069, 0x006A, 0x006B, 0x006C, 0x006D, 0x006E,
    0x006F, 0x0070, 0x0071,
    0x00AE, 0x00B2, 0x00B3, 0x00B4,
    0x00C1, 0x00C2, 0x00C3, 0x00C4, 0x00C9, 0x00CA, 0x00CB, 0x00CC,
    0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x00DB, 0x00DC,
    0x0100, 0x0140, 0x0141, 0x0142, 0x0143, 0x0144, 0x0145, 0x0146, 0x0147,
    0x0148, 0x0149, 0x014A, 0x014B, 0x0150, 0x0151, 0x0152, 0x0153, 0x0154,
    0x0160,
    0x037C, 0x037D, 0x037E, 0x0380, 0x03A5,
    0x0400, 0x0401, 0x0402,
    0x0420, 0x0478, 0x0479, 0x047A, 0x047B,
    0x0480, 0x0481,
    0x04A0, 0x04A1, 0x04A2, 0x04A3, 0x04A4, 0x04A5,
    0x04CC, 0x04D0, 0x04D2, 0x04D3, 0x04D4, 0x04D5, 0x04D6,
]

errors = []
for addr in global_defs:
    procs_map = addr_usage.get(addr, {})
    fs = addr_filescope.get(addr, 0)
    n = len(procs_map)
    if fs > 0:
        n += 1
    if n < 2:
        proc_name = list(procs_map.keys())[0] if procs_map else "file-scope"
        errors.append(f"  ERROR: ${addr:04X} defined global but only used by {proc_name}")

if errors:
    print("=== GLOBAL DEFINITION ERRORS ===")
    for e in errors:
        print(e)
else:
    print("All global definitions verified OK (2+ procs each)")

# Also check for missed globals (2+ procs, not defined)
already_named = {
    0x0300, 0x0303, 0x0304, 0x0305, 0x0306, 0x0307, 0x0308, 0x0309,
    0x030A, 0x030B, 0x030C, 0x030F, 0x0310, 0x0311, 0x0312, 0x0313,
    0x031C, 0x031D, 0x031E, 0x034C, 0x034D, 0x034E,
    0x0012, 0x00A6, 0x00A7, 0x007E, 0x0081, 0x008B, 0x00E1,
    0x0078, 0x007A, 0x007C, 0x0082, 0x0083, 0x0084, 0x0085, 0x0086,
    0x0087, 0x008C, 0x0098, 0x0099,
}
all_defined = set(global_defs) | already_named

print("\n=== UNNAMED GLOBAL ADDRESSES (2+ procs, not defined) ===")
found = False
for addr in sorted(addr_usage.keys()):
    if addr in all_defined:
        continue
    procs_map = addr_usage[addr]
    fs = addr_filescope.get(addr, 0)
    n = len(procs_map)
    if fs > 0:
        n += 1
    if n >= 2:
        found = True
        procs_str = ", ".join(f"{nm}({c})" for nm, c in sorted(procs_map.items(), key=lambda x: -x[1]))
        print(f"  ${addr:04X}: {n} users -> {procs_str}" + (f" +file({fs})" if fs else ""))
if not found:
    print("  None - all globals are named!")
