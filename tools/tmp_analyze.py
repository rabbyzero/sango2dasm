#!/usr/bin/env python3
"""Analyze dispatch tables in prg_0c_0d.asm ranges."""
import struct

data = open("rom/prg/prg_0c.bin", "rb").read()
BASE = 0xA000  # Bank 0C maps to $A000-$BFFF

def read_word(addr):
    off = addr - BASE
    return struct.unpack_from('<H', data, off)[0]

def read_bytes(addr, count):
    off = addr - BASE
    return data[off:off+count]

print("=== Action Executor Dispatch Table at $B042 ===")
for i in range(18):
    addr = 0xB042 + i * 2
    target = read_word(addr)
    print(f"  [{i:2d}] ${addr:04X}: ${target:04X}")

print(f"\n=== Bytes at $B066 (after table) ===")
b = read_bytes(0xB066, 16)
print(f"  {' '.join(f'{x:02X}' for x in b)}")

print(f"\n=== Bytes at $B062 (entry 0 target) ===")
b = read_bytes(0xB062, 16)
print(f"  {' '.join(f'{x:02X}' for x in b)}")

print(f"\n=== Bytes at $B070 ===")
b = read_bytes(0xB070, 16)
print(f"  {' '.join(f'{x:02X}' for x in b)}")

print(f"\n=== Data at $AD0A-$AD62 (should be .byte) ===")
for row_start in range(0xAD0A, 0xAD63, 16):
    count = min(16, 0xAD63 - row_start)
    b = read_bytes(row_start, count)
    hexs = ','.join(f'${x:02X}' for x in b)
    print(f"  .byte {hexs}  ; ${row_start:04X}")

print(f"\n=== Validation Dispatch Table at $ADAC (16 entries) ===")
for i in range(16):
    addr = 0xADAC + i * 2
    target = read_word(addr)
    print(f"  [{i:2d}] ${addr:04X}: ${target:04X}")

print(f"\n=== Loc_A44D Dispatch Table at $A462 (7 entries) ===")
for i in range(7):
    addr = 0xA462 + i * 2
    target = read_word(addr)
    print(f"  [{i:2d}] ${addr:04X}: ${target:04X}")

print(f"\n=== Loc_A87C Dispatch Table at $A888 (11 entries) ===")
for i in range(11):
    addr = 0xA888 + i * 2
    target = read_word(addr)
    print(f"  [{i:2d}] ${addr:04X}: ${target:04X}")
