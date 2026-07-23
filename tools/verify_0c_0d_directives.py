#!/usr/bin/env python3
"""Verify that .word directives in prg_0c_0d.asm match the original binary."""
import struct
import re
import sys

# Load original binary
data_0c = open('/home/zero/project/sango2dasm/rom/prg/prg_0c.bin', 'rb').read()
data_0d = open('/home/zero/project/sango2dasm/rom/prg/prg_0d.bin', 'rb').read()
data = data_0c + data_0d
BASE = 0xA000

# Load ASM file
with open('/home/zero/project/sango2dasm/asm/banks/prg_0c_0d.asm') as f:
    lines = f.readlines()

errors = 0
checked = 0

for i, line in enumerate(lines):
    # Match .word lines with address comments
    m = re.match(r'\s+\.word\s+\$([0-9A-F]{4})\s+;\s*\$([0-9A-F]{4}):\s*\$([0-9A-F]{2})\s+\$([0-9A-F]{2})', line)
    if not m:
        continue
    
    word_val = int(m.group(1), 16)
    addr = int(m.group(2), 16)
    byte_lo = int(m.group(3), 16)
    byte_hi = int(m.group(4), 16)
    
    # Verify against binary
    offset = addr - BASE
    if offset < 0 or offset + 1 >= len(data):
        print(f"  Line {i+1}: Address ${addr:04X} out of range")
        errors += 1
        continue
    
    actual_lo = data[offset]
    actual_hi = data[offset + 1]
    actual_word = struct.unpack_from('<H', data, offset)[0]
    
    checked += 1
    
    # Check bytes match
    if actual_lo != byte_lo or actual_hi != byte_hi:
        print(f"  Line {i+1}: BYTE MISMATCH at ${addr:04X}: comment says ${byte_lo:02X} ${byte_hi:02X}, binary has ${actual_lo:02X} ${actual_hi:02X}")
        errors += 1
    elif actual_word != word_val:
        print(f"  Line {i+1}: WORD MISMATCH at ${addr:04X}: .word ${word_val:04X} but binary is ${actual_word:04X}")
        errors += 1

# Also verify .byte lines still match
for i, line in enumerate(lines):
    m = re.search(r'\.byte\s+(.*?)\s*;\s*\$([0-9A-F]{4}):', line)
    if not m:
        continue
    
    byte_str = m.group(1)
    addr = int(m.group(2), 16)
    offset = addr - BASE
    
    # Parse byte values
    vals = re.findall(r'\$([0-9A-F]{2})', byte_str)
    if not vals:
        continue
    
    for j, v in enumerate(vals):
        expected = int(v, 16)
        if offset + j >= len(data):
            break
        actual = data[offset + j]
        if actual != expected:
            print(f"  Line {i+1}: .byte MISMATCH at ${addr+j:04X}: comment says ${expected:02X}, binary has ${actual:02X}")
            errors += 1
            break
    checked += 1

print(f"\nChecked {checked} directives, {errors} errors")
if errors == 0:
    print("ALL DIRECTIVES MATCH THE ORIGINAL BINARY!")
else:
    print(f"FAILED: {errors} mismatches found")
    sys.exit(1)
