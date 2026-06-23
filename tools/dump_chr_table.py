#!/usr/bin/env python3
"""Dump bytes around $A8FD from prg_17_18_combined.bin to verify disassembly."""

with open('/home/zero/project/sango2dasm/rom/prg/prg_17_18_combined.bin', 'rb') as f:
    # CPU $A8D3 -> offset $A8D3 - $8000 = $28D3
    f.seek(0x28D3)
    data = f.read(256)  # Read more context
    print('ROM bytes at $A8D3 (256 bytes):')
    for i in range(0, 256, 16):
        addr = 0x8000 + 0x28D3 + i
        hex_bytes = ' '.join('{:02X}'.format(b) for b in data[i:i+16])
        print('{:04X}: {}'.format(addr, hex_bytes))
