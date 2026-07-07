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

for proc_info in procs:
    start, end, name = proc_info
    for i in range(start-1, min(end, len(lines))):
        for m in ram_re.finditer(lines[i]):
            addr = int(m.group(0)[1:], 16)
            addr_usage[addr][name] += 1

# Check specific addresses
check = [0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x20,
         0x424, 0x425, 0x478, 0x479, 0x47A, 0x47B, 0x47C, 0x47D, 0x47E, 0x47F,
         0x480, 0x481, 0x482, 0x483, 0x486,
         0x3A5, 0x3AA, 0x3AB, 0x3BA,
         0x42C, 0x42D, 0x42E, 0x44C, 0x44D, 0x44E,
         0x470, 0x471, 0x472, 0x473,
         0x4AE, 0x509, 0x664,
         0x72, 0x73, 0x74,
         0x100, 0x10C, 0x11C, 0x130,
         0x166, 0x16F, 0x175, 0x17D, 0x190,
         0x204, 0x3C3,
         0x40C, 0x4D6,
         0xB9, 0xBF, 0xC0, 0xC7, 0xC8, 0xCF,
         0xD6, 0xDA,
         0x05, 0x0F, 0xBE, 0xC6, 0xCE]

print("=== Address usage check ===")
for addr in sorted(check):
    if addr in addr_usage:
        procs = addr_usage[addr]
        n = len(procs)
        procs_str = ", ".join(f"{nm}({c})" for nm, c in sorted(procs.items(), key=lambda x: -x[1]))
        status = "GLOBAL" if n >= 2 else "LOCAL"
        print(f"  ${addr:04X}: [{status}] {n} procs -> {procs_str}")
    else:
        print(f"  ${addr:04X}: NOT FOUND")
