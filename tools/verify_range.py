#!/usr/bin/env python3
"""Verify disassembly bytes in prg_1f.aligned.asm against the binary for range $E843-$F2AE."""

import re
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BIN_PATH = os.path.join(BASE_DIR, 'rom', 'prg', 'prg_1f.bin')
ASM_PATH = os.path.join(BASE_DIR, 'asm', 'banks', 'prg_1f.aligned.asm')

# Read binary
with open(BIN_PATH, 'rb') as f:
    binary = f.read()

# Read asm
with open(ASM_PATH, 'r') as f:
    asm_lines = f.readlines()

# Pattern: match "; $XXXX: XX XX XX" at end of line (only hex byte pairs)
pattern = re.compile(r';\s*\$([0-9A-Fa-f]{4}):\s+((?:[0-9A-Fa-f]{2}\s?)+)\s*$')

errors = 0
checked = 0
total_addrs = 0

for line_num, line in enumerate(asm_lines, 1):
    m = pattern.search(line.rstrip())
    if m:
        addr = int(m.group(1), 16)
        if addr < 0xE843 or addr > 0xF2AE:
            continue

        expected_bytes_str = m.group(2).strip()
        expected_bytes = expected_bytes_str.split()

        # Validate: all tokens must be exactly 2 hex chars
        valid = all(len(b) == 2 and all(c in '0123456789ABCDEFabcdef' for c in b) for b in expected_bytes)
        if not valid:
            continue

        file_offset = addr - 0xE000
        total_addrs += 1

        for i, hex_byte in enumerate(expected_bytes):
            if file_offset + i >= len(binary):
                break
            expected = int(hex_byte, 16)
            actual = binary[file_offset + i]
            checked += 1
            if expected != actual:
                errors += 1
                if errors <= 20:
                    print(f"MISMATCH line {line_num}: ${addr:04X}+{i} expected {expected:02X} got {actual:02X}")
                    print(f"  Line: {line.rstrip()[:120]}")

print(f"\nVerification complete:")
print(f"  Addresses checked: {total_addrs}")
print(f"  Total bytes checked: {checked}")
print(f"  Mismatches: {errors}")
if errors == 0:
    print("  ALL BYTES MATCH! Disassembly is byte-accurate.")
