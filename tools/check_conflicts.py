#!/usr/bin/env python3
import re

with open("asm/banks/prg_1d_1e.asm") as f:
    lines = f.readlines()

defs = {}
in_proc = None
for i, line in enumerate(lines):
    m = re.match(r'^\.proc\s+(\S+)', line)
    if m:
        in_proc = m.group(1)
    if re.match(r'^\.endproc', line):
        in_proc = None
    # Match symbol definitions: name = $xxxx (skip comments)
    stripped = line.lstrip()
    if stripped.startswith(';'):
        continue
    m = re.match(r'(\w+)\s*=\s*\$([0-9a-fA-F]+)', stripped)
    if m:
        name = m.group(1)
        addr = m.group(2)
        scope = in_proc if in_proc else 'GLOBAL'
        if name not in defs:
            defs[name] = []
        defs[name].append((i+1, scope, addr))

conflicts = 0
for name, locations in sorted(defs.items()):
    if len(locations) > 1:
        scopes = [loc[1] for loc in locations]
        if 'GLOBAL' in scopes and any(s != 'GLOBAL' for s in scopes):
            conflicts += 1
            print(f'CONFLICT: {name} defined in multiple scopes:')
            for line, scope, addr in locations:
                print(f'  line {line}: {scope} = ${addr}')

if conflicts == 0:
    print("No global/local conflicts found!")
else:
    print(f"\n{conflicts} conflicts found")
