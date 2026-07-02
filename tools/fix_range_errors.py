#!/usr/bin/env python3
"""Fix range errors by converting branch instructions to raw .byte directives."""
import re
import sys

asm_file = sys.argv[1]

# First, get the error lines
import subprocess
result = subprocess.run(
    ['/home/zero/.local/bin/ca65', '-I', 'include', asm_file, '-o', '/dev/null'],
    capture_output=True, text=True
)

error_lines = set()
for line in result.stderr.split('\n'):
    m = re.search(r':(\d+): Error: Range error', line)
    if m:
        error_lines.add(int(m.group(1)) - 1)  # 0-indexed

print(f"Found {len(error_lines)} range error lines")

lines = open(asm_file).readlines()

for i in error_lines:
    line = lines[i].rstrip()
    # Extract raw bytes from comment
    m = re.search(r';\s*\$([0-9A-Fa-f]{4}):\s+([0-9A-Fa-f\s]+)', line)
    if m:
        addr = m.group(1)
        bytes_str = m.group(2).strip()
        byte_vals = bytes_str.split()
        byte_directive = ', '.join(['$' + b for b in byte_vals])
        indent = len(line) - len(line.lstrip())
        lines[i] = ' ' * indent + '.byte ' + byte_directive + ' ; $' + addr + ': ' + bytes_str + '\n'

with open(asm_file, 'w') as f:
    f.writelines(lines)

print(f"Fixed {len(error_lines)} range errors")
