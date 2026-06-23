#!/usr/bin/env python3
"""Search for specific CHR loader pattern with $0530/$0531 stores."""

with open('/home/zero/project/sango2dasm/rom/prg/prg_17_18_combined.bin', 'rb') as f:
    data = f.read()

# Look for: TAY (A8), LDA abs,Y (B9), STA $0530 (8D 30 05), LDA abs,Y (B9), STA $0531 (8D 31 05)
print("Searching for TAY, LDA, STA $0530, LDA, STA $0531 pattern:")
for i in range(len(data) - 12):
    if (data[i] == 0xA8 and      # TAY
        data[i+1] == 0xB9 and    # LDA abs,Y
        data[i+4] == 0x8D and    # STA abs
        data[i+5] == 0x30 and data[i+6] == 0x05 and  # $0530
        data[i+7] == 0xB9 and    # LDA abs,Y
        data[i+10] == 0x8D and   # STA abs
        data[i+11] == 0x31 and data[i+12] == 0x05):  # $0531
        addr = 0x8000 + i
        next_bytes = data[i:i+16]
        hex_str = ' '.join('{:02X}'.format(b) for b in next_bytes)
        print('${:04X}: {}'.format(addr, hex_str))
