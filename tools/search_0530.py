#!/usr/bin/env python3
"""Search for any reference to $0530 in the ROM."""

with open('/home/zero/project/sango2dasm/rom/prg/prg_17_18_combined.bin', 'rb') as f:
    data = f.read()

# Look for STA $0530 (8D 30 05)
print("Searching for STA $0530 (8D 30 05):")
for i in range(len(data) - 3):
    if data[i] == 0x8D and data[i+1] == 0x30 and data[i+2] == 0x05:
        addr = 0x8000 + i
        context = data[max(0,i-4):i+8]
        hex_str = ' '.join('{:02X}'.format(b) for b in context)
        print('${:04X}: {}'.format(addr, hex_str))

print("\nSearching for STA $0531 (8D 31 05):")
for i in range(len(data) - 3):
    if data[i] == 0x8D and data[i+1] == 0x31 and data[i+2] == 0x05:
        addr = 0x8000 + i
        context = data[max(0,i-4):i+8]
        hex_str = ' '.join('{:02X}'.format(b) for b in context)
        print('${:04X}: {}'.format(addr, hex_str))
