#!/usr/bin/env python3
"""Check if disassembly matches a different ROM or offset."""

# Check prg_combined.bin
with open('/home/zero/project/sango2dasm/rom/prg_combined.bin', 'rb') as f:
    combined = f.read()

print("prg_combined.bin size: {} bytes".format(len(combined)))
print("Expected bank $17 offset: ${:04X}".format(0x17 * 0x2000))

# Bank $17 at offset $17 * $2000 = $2E000
bank17_offset = 0x17 * 0x2000
addr = 0xA8D3
cpu_to_file = bank17_offset + (addr - 0x8000)
print("CPU ${:04X} -> file offset ${:04X}".format(addr, cpu_to_file))

if cpu_to_file + 16 <= len(combined):
    data = combined[cpu_to_file:cpu_to_file+16]
    hex_str = ' '.join('{:02X}'.format(b) for b in data)
    print("Bytes at offset: {}".format(hex_str))

# Also check if the disassembly bytes A0 00 AD 0D 00 exist anywhere
target = bytes([0xA0, 0x00, 0xAD, 0x0D, 0x00])
pos = combined.find(target)
if pos >= 0:
    cpu_addr = 0x8000 + (pos % 0x2000)
    bank = pos // 0x2000
    print("\nFound disassembly bytes at file offset ${:04X} (bank ${:02X}, CPU ${:04X})".format(pos, bank, cpu_addr))
else:
    print("\nDisassembly bytes not found in prg_combined.bin")

# Check individual prg_17.bin
with open('/home/zero/project/sango2dasm/rom/prg/prg_17.bin', 'rb') as f:
    prg17 = f.read()

target_offset = 0xA8D3 - 0x8000
if target_offset < len(prg17):
    data = prg17[target_offset:target_offset+16]
    hex_str = ' '.join('{:02X}'.format(b) for b in data)
    print("\nprg_17.bin at offset ${:04X}: {}".format(target_offset, hex_str))
else:
    print("\nprg_17.bin too small for offset ${:04X}".format(target_offset))
