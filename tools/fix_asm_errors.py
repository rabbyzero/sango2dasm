#!/usr/bin/env python3
"""Fix illegal addressing mode errors in prg_1d_1e.asm by converting to .byte directives."""
import re
import sys

asm_file = sys.argv[1]
error_file = sys.argv[2]

# Read error lines (1-indexed line numbers)
error_lines = set()
for l in open(error_file).read().strip().split('\n'):
    error_lines.add(int(l) - 1)  # 0-indexed

# Read and fix the asm file
lines = open(asm_file).readlines()

fixed = 0
for i in error_lines:
    line = lines[i].rstrip()
    # Extract byte data from comment: "; $ADDR: XX XX XX"
    m = re.search(r';\s+\$([0-9A-Fa-f]+):\s+([0-9A-Fa-f\s]+)', line)
    if m:
        addr = m.group(1)
        bytes_str = m.group(2).strip()
        byte_vals = bytes_str.split()
        byte_directive = ', '.join(['$' + b for b in byte_vals])
        indent = len(line) - len(line.lstrip())
        lines[i] = ' ' * indent + '.byte ' + byte_directive + ' ; $' + addr + ': ' + bytes_str + '\n'
        fixed += 1

with open(asm_file, 'w') as f:
    f.writelines(lines)

print(f'Fixed {fixed} lines')
