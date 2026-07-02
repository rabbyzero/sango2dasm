#!/usr/bin/env python3
"""Deep structure analysis of prg_1e.bin"""
data = open('rom/prg/prg_1e.bin','rb').read()
SIZE = len(data)
BASE = 0xC000

# Find all JMP $C934 positions and what follows
print("=== JMP $C934 positions and data after ===")
for i in range(SIZE - 2):
    if data[i] == 0x4C and data[i+1] == 0x34 and data[i+2] == 0xC9:
        addr = BASE + i
        after = i + 3
        # Show 8 bytes after
        hex_after = ' '.join(f'{data[after+j]:02X}' for j in range(min(16, SIZE-after)))
        # Find next A9 xx 8D 10 00 pattern
        next_proc = None
        for j in range(after, min(after + 64, SIZE - 4)):
            if data[j] == 0xA9 and data[j+2] == 0x8D and data[j+3] == 0x10 and data[j+4] == 0x00:
                next_proc = BASE + j
                break
        print(f"  JMP $C934 at ${addr:04X}, data after: {hex_after}")
        if next_proc:
            print(f"    -> next proc at ${next_proc:04X}, data table size: {next_proc - BASE - after}")

# Check the region around $DF1A-$DF88
print("\n=== Region $DF10-$DF90 ===")
for off in range(0x1F10, 0x1F90, 16):
    addr = BASE + off
    hex_str = ' '.join(f'{data[off+j]:02X}' for j in range(min(16, SIZE-off)))
    print(f"  ${addr:04X}: {hex_str}")

# Find where $FF padding starts
print("\n=== $FF padding ===")
for i in range(SIZE-1, -1, -1):
    if data[i] != 0xFF:
        print(f"  Last non-$FF byte at offset {i} (${BASE+i:04X}): ${data[i]:02X}")
        print(f"  $FF padding starts at offset {i+1} (${BASE+i+1:04X})")
        # Show bytes around it
        start = max(0, i-8)
        hex_str = ' '.join(f'{data[start+j]:02X}' for j in range(i-start+17 if i-start+17 <= SIZE-start else SIZE-start))
        print(f"  Context: ${BASE+start:04X}: {hex_str}")
        break

# Find all RTS and what follows (to identify callback patterns)
print("\n=== RTS positions and what follows ===")
for i in range(SIZE):
    if data[i] == 0x60:
        addr = BASE + i
        after = i + 1
        if after < SIZE:
            hex_after = ' '.join(f'{data[after+j]:02X}' for j in range(min(8, SIZE-after)))
            print(f"  RTS at ${addr:04X}, next bytes: {hex_after}")
