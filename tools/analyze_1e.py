#!/usr/bin/env python3
"""Analyze prg_1e.bin structure."""
data = open('rom/prg/prg_1e.bin','rb').read()
print('RTS positions:')
for i in range(len(data)):
    if data[i] == 0x60:
        addr = 0xC000 + i
        print(f'  ${addr:04X} (offset {i})')

print()
print('JMP targets:')
for i in range(len(data)-2):
    if data[i] == 0x4C:
        target = data[i+1] | (data[i+2] << 8)
        addr = 0xC000 + i
        if 0xC000 <= target <= 0xDFFF:
            print(f'  ${addr:04X}: JMP ${target:04X}')

print()
# Intra-bank JSR targets (unique)
targets = set()
for i in range(len(data)-2):
    if data[i] == 0x20:
        target = data[i+1] | (data[i+2] << 8)
        if 0xC000 <= target <= 0xDFFF:
            targets.add(target)
print(f'Unique intra-bank JSR targets: {sorted([f"${t:04X}" for t in targets])}')

# Check what's at the end
print()
print('Last 128 bytes:')
for i in range(len(data)-128, len(data), 16):
    addr = 0xC000 + i
    hex_str = ' '.join(f'{data[j]:02X}' for j in range(i, min(i+16, len(data))))
    print(f'  ${addr:04X}: {hex_str}')
