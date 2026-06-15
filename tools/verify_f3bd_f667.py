#!/usr/bin/env python3
"""Verify prg_1f_F3BD_F667.asm bytes against binary."""
import re

# Read the assembly file
with open('/home/zero/project/sango2dasm/asm/banks/prg_1f_F3BD_F667.asm', 'r') as f:
    asm_lines = f.readlines()

# Read the binary
with open('/home/zero/project/sango2dasm/rom/prg/prg_1f.bin', 'rb') as f:
    bindata = f.read()

base = 0xE000
errors = 0
total_bytes = 0

# Match inline byte comments: "; $XXXX: XX XX XX..." with strict 2-digit hex bytes
# Requires at least one pair of hex digits and nothing else after the bytes
pattern = re.compile(r';\s*\$([0-9A-Fa-f]{4}):\s*((?:[0-9A-Fa-f]{2}\s*)+)$')

for lineno, line in enumerate(asm_lines, 1):
    m = pattern.search(line.rstrip())
    if m:
        addr = int(m.group(1), 16)
        byte_str = m.group(2).strip()
        expected_bytes = [int(b, 16) for b in byte_str.split()]
        offset = addr - base
        actual_bytes = list(bindata[offset:offset+len(expected_bytes)])
        total_bytes += len(expected_bytes)
        if expected_bytes != actual_bytes:
            errors += 1
            print(f'Line {lineno}: ${addr:04X} mismatch:')
            print(f'  asm: {[f"0x{b:02X}" for b in expected_bytes]}')
            print(f'  bin: {[f"0x{b:02X}" for b in actual_bytes]}')

print(f'Total bytes verified: {total_bytes}')
print(f'Expected: 683 bytes')
print(f'Errors: {errors}')
if total_bytes == 683 and errors == 0:
    print('FULL VERIFICATION PASSED - all 683 bytes match!')
elif errors == 0:
    print(f'All bytes correct but count mismatch (got {total_bytes}, expected 683)')
else:
    print('VERIFICATION FAILED')
