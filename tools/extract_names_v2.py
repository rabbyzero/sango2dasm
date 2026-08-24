#!/usr/bin/env python3
"""Properly extract name strings from PRG bank $30 at $901A.
For Namco-163 with 8KB banks:
  register $30 = byte offset $30 * $1000 = $30000 in combined PRG
  (or equivalently, file prg_18.bin at offset $1000)
"""
import os, struct

ROM_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rom')

# Method 1: From combined PRG
combined_path = os.path.join(ROM_DIR, 'prg_combined.bin')
with open(combined_path, 'rb') as f:
    prg_data = f.read()

print(f"PRG combined: {len(prg_data)} bytes ({len(prg_data)//0x2000} x 8KB banks)")

# Bank $30 = physical bank $18, offset in combined = $30 * $1000 = $30000
bank30_combined_ofs = 0x30 * 0x1000
# Or from individual file: prg_18.bin at $101A offset from $8000
bank_file_path = os.path.join(ROM_DIR, 'prg', 'prg_18.bin')
with open(bank_file_path, 'rb') as f:
    prg18_data = f.read()

print(f"prg_18.bin: {len(prg18_data)} bytes")

# $901A is at offset $101A within the 8KB bank ($901A - $8000 = $101A)
name_offset_in_bank = 0x901A - 0x8000  # = $101A

# Check from combined file
print(f"\n--- From prg_combined.bin at offset {bank30_combined_ofs + name_offset_in_bank:#x} ---")
name_base_combined = bank30_combined_ofs + name_offset_in_bank
for i in range(20):
    addr = name_base_combined + i * 10
    if addr + 10 > len(prg_data):
        print(f"  [{i:2d}] out of range")
        break
    name_bytes = []
    for j in range(10):
        b = prg_data[addr + j]
        if b == 0:
            break
        name_bytes.append(b)
    if name_bytes:
        hex_str = ' '.join(f'${b:02X}' for b in name_bytes)
        print(f"  [{i:2d}] @${0x901A + i*10:04X}: {hex_str}")

# Check from individual bank file
print(f"\n--- From prg_18.bin at offset {name_offset_in_bank:#x} ---")
name_base_file = name_offset_in_bank
for i in range(20):
    addr = name_base_file + i * 10
    if addr + 10 > len(prg18_data):
        print(f"  [{i:2d}] out of range")
        break
    name_bytes = []
    for j in range(10):
        b = prg18_data[addr + j]
        if b == 0:
            break
        name_bytes.append(b)
    if name_bytes:
        hex_str = ' '.join(f'${b:02X}' for b in name_bytes)
        print(f"  [{i:2d}] @${0x901A + i*10:04X}: {hex_str}")

# Also check what extract_names.py was reading (offset $20000 = bank $10)
print(f"\n--- From prg_combined.bin at offset 0x20000 + 0x101A (bank $10) ---")
name_base_old = 0x20000 + name_offset_in_bank
for i in range(20):
    addr = name_base_old + i * 10
    if addr + 10 > len(prg_data):
        print(f"  [{i:2d}] out of range")
        break
    name_bytes = []
    for j in range(10):
        b = prg_data[addr + j]
        if b == 0:
            break
        name_bytes.append(b)
    if name_bytes:
        hex_str = ' '.join(f'${b:02X}' for b in name_bytes)
        print(f"  [{i:2d}] @${0x901A + i*10:04X}: {hex_str}")
    else:
        print(f"  [{i:2d}] @${0x901A + i*10:04X}: (empty)")
