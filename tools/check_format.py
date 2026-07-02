#!/usr/bin/env python3
"""Quick quality check for hex formatting in the assembly."""
import re

with open('/home/zero/project/sango2dasm/asm/banks/prg_1d_1e.asm') as f:
    lines = f.readlines()

issues = 0
for i, line in enumerate(lines, 1):
    line = line.rstrip()
    if not line or line.startswith(';') or line.startswith('.') or line.startswith('Entry'):
        continue
    # Check instruction lines
    if line.startswith('  ') and not line.strip().startswith(';'):
        instr_part = line.split(';')[0].strip()
        # Check for immediate values without #$ prefix
        if re.search(r'#[0-9A-Fa-f]{2}', instr_part):
            issues += 1
            if issues <= 5:
                print(f'Line {i}: Missing dollar on immediate: {instr_part}')
        # Check for bare hex digits that should be addresses
        parts = instr_part.split()
        if len(parts) >= 2:
            for p in parts[1:]:
                clean = p.rstrip(',X').rstrip(',Y')
                if re.match(r'^[0-9A-Fa-f]{2,4}$', clean) and clean not in ('A',):
                    issues += 1
                    if issues <= 5:
                        print(f'Line {i}: Possible missing dollar: {p} in {instr_part}')

print(f'Total formatting issues: {issues}')
if issues == 0:
    print('All hex values properly formatted!')
