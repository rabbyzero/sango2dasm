#!/usr/bin/env python3
"""Check individual bank files for the disassembly bytes."""

import os

# The disassembly at $A8D3 shows A0 00 (LDY #$00)
# $A8D3 is in PRG_SLOT1 ($A000-$BFFF)
# If bank $17 is at $8000-$9FFF and bank $18 is at $A000-$BFFF
# Then $A8D3 = bank $18, offset $08D3

target_bytes = bytes([0xA0, 0x00, 0xAD, 0x0D, 0x00])

# Check prg_18.bin at offset $08D3
prg18_path = '/home/zero/project/sango2dasm/rom/prg/prg_18.bin'
if os.path.exists(prg18_path):
    with open(prg18_path, 'rb') as f:
        data = f.read()
    print("prg_18.bin size: {} bytes".format(len(data)))
    offset = 0xA8D3 - 0xA000  # $08D3
    if offset < len(data):
        chunk = data[offset:offset+16]
        hex_str = ' '.join('{:02X}'.format(b) for b in chunk)
        print("Bytes at offset ${:04X} (CPU $A8D3): {}".format(offset, hex_str))
        match = data[offset:offset+5] == target_bytes
        print("Matches disassembly: {}".format(match))
else:
    print("prg_18.bin not found")

# Check prg_17.bin at offset $08D3 (for $88D3)
prg17_path = '/home/zero/project/sango2dasm/rom/prg/prg_17.bin'
with open(prg17_path, 'rb') as f:
    data17 = f.read()
print("\nprg_17.bin size: {} bytes".format(len(data17)))
offset17 = 0x8D3
if offset17 < len(data17):
    chunk = data17[offset17:offset17+16]
    hex_str = ' '.join('{:02X}'.format(b) for b in chunk)
    print("Bytes at offset ${:04X} (CPU $88D3): {}".format(offset17, hex_str))

# Also check combined bank at the right offset for the 17_18 combined file
with open('/home/zero/project/sango2dasm/rom/prg/prg_17_18_combined.bin', 'rb') as f:
    combined = f.read()
print("\nprg_17_18_combined.bin size: {} bytes".format(len(combined)))
# Bank $17 at $0000-$1FFF, bank $18 at $2000-$3FFF
# $A8D3 = bank $18, offset $08D3 -> file offset $2000 + $08D3 = $28D3
offset_combined = 0x2000 + 0x08D3
chunk = combined[offset_combined:offset_combined+16]
hex_str = ' '.join('{:02X}'.format(b) for b in chunk)
print("Bytes at offset ${:04X} (CPU $A8D3): {}".format(offset_combined, hex_str))
