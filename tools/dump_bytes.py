#!/usr/bin/env python3
"""Dump bytes from ROM for data region conversion."""
import os

combined = '/home/zero/project/sango2dasm/rom/prg_combined.bin'
with open(combined, 'rb') as f:
    # Address $CFE6 is in bank 0D ($C000-$DFFF)
    # Bank 0D is at file offset 0x0D * 0x2000 = 0x1A000
    # Offset in bank = $CFE6 - $C000 = $0FE6
    offset = 0x0D * 0x2000 + (0xCFE6 - 0xC000)
    print(f'Offset: 0x{offset:05X}')
    f.seek(offset)
    data = f.read(224)
    for i in range(0, min(224, len(data)), 16):
        addr = 0xCFE6 + i
        hex_bytes = ' '.join(f'{b:02X}' for b in data[i:i+16])
        byte_list = ','.join(f'${b:02X}' for b in data[i:i+16])
        print(f'  .byte {byte_list}; ${addr:04X}: {hex_bytes}')
