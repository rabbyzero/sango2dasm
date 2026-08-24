#!/usr/bin/env python3
"""Extract name strings from bank $30 at $901A."""
import os

ROM_DIR = os.path.join(os.path.dirname(__file__), '..', 'rom')
PRG_COMBINED = os.path.join(ROM_DIR, 'prg_combined.bin')

with open(PRG_COMBINED, 'rb') as f:
    prg_data = f.read()

# Bank $30 = physical $10, offset = $10 * $2000 = $20000
# $901A in bank $30: file offset = $20000 + ($901A - $8000) = $2101A
bank30_ofs = 0x10 * 0x2000
name_base = bank30_ofs + (0x901A - 0x8000)

print(f"Name data in bank $30 at $901A (file offset {name_base:#x}):")
for i in range(50):
    addr = name_base + i * 10
    name_bytes = []
    for j in range(10):
        b = prg_data[addr + j]
        if b == 0:
            break
        name_bytes.append(b)
    if name_bytes:
        hex_str = ' '.join(f'${b:02X}' for b in name_bytes)
        # These are tile indices, not ASCII
        print(f"  [{i:2d}] @${0x901A + i*10:04X}: {hex_str}")
