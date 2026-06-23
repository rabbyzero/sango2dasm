#!/usr/bin/env python3
"""Check bytes at various offsets to find the CHR loader."""

with open('/home/zero/project/sango2dasm/rom/prg/prg_17.bin', 'rb') as f:
    prg17 = f.read()

# The disassembly maps $A000-$BFFF to prg_17.bin offset $0000-$1FFF
# So $A8D3 -> offset $08D3, $A944 -> offset $0944

print("Bytes at disassembly address $A8D3 (offset $08D3 in prg_17.bin):")
offset = 0x08D3
for i in range(0, 192, 16):
    addr = 0xA000 + offset + i
    chunk = prg17[offset+i:offset+i+16]
    hex_str = ' '.join('{:02X}'.format(b) for b in chunk)
    print("${:04X}: {}".format(addr, hex_str))

print("\nBytes at disassembly address $A944 (offset $0944):")
offset = 0x0944
for i in range(0, 64, 16):
    addr = 0xA000 + offset + i
    chunk = prg17[offset+i:offset+i+16]
    hex_str = ' '.join('{:02X}'.format(b) for b in chunk)
    print("${:04X}: {}".format(addr, hex_str))

# Check what's at the user's data table addresses
print("\nChecking user's data table pointers:")
# User says Entry 0 points to $A989
# That would be offset $0989 in prg_17.bin
ptr_offset = 0x0989
print("Bytes at $A989 (offset $0989): {}".format(
    ' '.join('{:02X}'.format(b) for b in prg17[ptr_offset:ptr_offset+16])))
