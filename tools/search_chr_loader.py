#!/usr/bin/env python3
"""Search for CHR loader pattern in ROM."""

with open('/home/zero/project/sango2dasm/rom/prg/prg_17_18_combined.bin', 'rb') as f:
    data = f.read()

# Look for TAY (A8) followed by LDA absolute,Y (B9 xx xx)
print("Searching for TAY, LDA abs,Y pattern:")
for i in range(len(data) - 4):
    if data[i] == 0xA8 and data[i+1] == 0xB9:
        addr = 0x8000 + i
        next_bytes = data[i:i+8]
        hex_str = ' '.join('{:02X}'.format(b) for b in next_bytes)
        print('${:04X}: {}'.format(addr, hex_str))
