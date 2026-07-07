#!/usr/bin/env python3
import re
from collections import defaultdict

with open("asm/banks/prg_1d_1e.asm") as f:
    lines = f.readlines()

# Build proc map: list of (start_line, end_line, proc_name)
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

# Already defined addresses (file-scope in this file)
already_defined = {
    0x0300, 0x0303, 0x0304, 0x0305, 0x0306, 0x0307, 0x0308, 0x0309,
    0x030A, 0x030B, 0x030C, 0x030F, 0x0310, 0x0311, 0x0312, 0x0313,
    0x031C, 0x031D, 0x031E, 0x034C, 0x034D, 0x034E,
    0x0012, 0x00A6, 0x00A7, 0x007E, 0x0081, 0x008B, 0x00E1,
}

# Defined in prg_17_18.asm (extern)
extern_defined = {
    0x0078, 0x007A, 0x007C, 0x0082, 0x0083, 0x0084, 0x0085, 0x0086,
    0x0087, 0x008C, 0x0098, 0x0099,
}

# RAM pattern: $0000-$07FF
ram_re = re.compile(r'\$0([0-7][0-9a-fA-F]{2})\b')

addr_usage = defaultdict(lambda: defaultdict(int))
addr_filescope = defaultdict(int)

for proc_info in procs:
    start, end, name = proc_info
    for i in range(start-1, min(end, len(lines))):
        for m in ram_re.finditer(lines[i]):
            addr = int(m.group(0)[1:], 16)
            if 0 <= addr <= 0x07FF:
                addr_usage[addr][name] += 1

in_proc = set()
for s, e, n in procs:
    for l in range(s-1, e):
        in_proc.add(l)

for i, line in enumerate(lines):
    if i not in in_proc:
        for m in ram_re.finditer(line):
            addr = int(m.group(0)[1:], 16)
            if 0 <= addr <= 0x07FF:
                addr_filescope[addr] += 1

global_addrs = {}
local_addrs = {}

for addr in sorted(addr_usage.keys()):
    proc_map = addr_usage[addr]
    total_refs = sum(proc_map.values())
    num_procs = len(proc_map)
    
    fs_refs = addr_filescope.get(addr, 0)
    if fs_refs > 0:
        num_procs += 1
        total_refs += fs_refs
    
    if addr in already_defined or addr in extern_defined:
        continue
    
    if num_procs >= 2:
        global_addrs[addr] = {'procs': dict(proc_map), 'total_refs': total_refs, 'fs': fs_refs}
    elif num_procs == 1:
        proc_name = list(proc_map.keys())[0]
        local_addrs[addr] = {'proc': proc_name, 'refs': proc_map[proc_name], 'fs': fs_refs}

print("=== GLOBAL ADDRESSES (used by 2+ procs, not yet named) ===")
print(f"Total: {len(global_addrs)}")
for addr in sorted(global_addrs.keys()):
    info = global_addrs[addr]
    procs_str = ", ".join(f"{n}({c})" for n, c in sorted(info['procs'].items(), key=lambda x: -x[1]))
    fs = f" +file({info['fs']})" if info['fs'] else ""
    print(f"  ${addr:04X}: {info['total_refs']} refs -> {procs_str}{fs}")

print(f"\n=== PROC-LOCAL ADDRESSES (used by 1 proc, not yet named) ===")
print(f"Total: {len(local_addrs)}")
by_proc = defaultdict(list)
for addr, info in local_addrs.items():
    by_proc[info['proc']].append((addr, info['refs']))

for proc_name in sorted(by_proc.keys()):
    addrs = by_proc[proc_name]
    print(f"\n  {proc_name}:")
    for addr, refs in sorted(addrs):
        print(f"    ${addr:04X}: {refs} refs")
