#!/usr/bin/env python3
"""
Verify that the disassembly output matches the original binary byte-for-byte.
Extracts all hex bytes from the assembly comments and compares against prg_1d.bin.
"""

import re

# Load original binary
with open("/home/zero/project/sango2dasm/rom/prg/prg_1d.bin", "rb") as f:
    original = f.read()

# Parse the assembly file and extract bytes from comments
with open("/tmp/prg_1d_final.asm") as f:
    asm_lines = f.readlines()

extracted = {}  # addr -> byte value
errors = []

for lineno, line in enumerate(asm_lines, 1):
    line = line.rstrip('\n')
    # Match lines with byte comments: "; $ADDR: XX XX [XX]"
    m = re.search(r';\s*\$([0-9A-Fa-f]{4}):\s*([0-9A-Fa-f ]+)$', line)
    if m:
        addr = int(m.group(1), 16)
        hex_bytes = m.group(2).strip().split()
        for i, hb in enumerate(hex_bytes):
            b = int(hb, 16)
            a = addr + i
            if a in extracted:
                errors.append(f"Line {lineno}: Duplicate address ${a:04X}")
            extracted[a] = b

# Check coverage
expected_addrs = set(range(0xA000, 0xA000 + len(original)))
covered_addrs = set(extracted.keys())

missing = expected_addrs - covered_addrs
extra = covered_addrs - expected_addrs

if missing:
    print(f"MISSING {len(missing)} bytes:")
    for a in sorted(missing)[:20]:
        print(f"  ${a:04X}")
    if len(missing) > 20:
        print(f"  ... and {len(missing)-20} more")

if extra:
    print(f"EXTRA {len(extra)} bytes (outside range):")
    for a in sorted(extra)[:20]:
        print(f"  ${a:04X}")

# Check byte values
mismatches = 0
for offset in range(len(original)):
    addr = 0xA000 + offset
    if addr in extracted:
        if extracted[addr] != original[offset]:
            mismatches += 1
            if mismatches <= 20:
                print(f"MISMATCH at ${addr:04X}: binary=${original[offset]:02X}, asm=${extracted[addr]:02X}")

# Summary
total = len(original)
covered = len(covered_addrs & expected_addrs)
print(f"\nCoverage: {covered}/{total} bytes ({covered*100//total}%)")
print(f"Missing:  {len(missing)} bytes")
print(f"Mismatch: {mismatches} bytes")
print(f"Extra:    {len(extra)} bytes")

if covered == total and mismatches == 0 and len(extra) == 0:
    print("\n✓ VERIFICATION PASSED: Assembly matches binary exactly!")
else:
    print("\n✗ VERIFICATION FAILED")
