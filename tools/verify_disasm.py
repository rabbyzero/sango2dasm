#!/usr/bin/env python3
"""Verify if disassembly matches ROM by checking bytes at several known addresses."""

with open('/home/zero/project/sango2dasm/rom/prg/prg_17_18_combined.bin', 'rb') as f:
    rom = f.read()

# Check several addresses from the disassembly
test_addrs = [
    (0xA8D3, [0xA0, 0x00]),         # LDY #$00 from disasm
    (0xA8D5, [0xAD, 0x0D, 0x00]),   # LDA a:$000D
    (0xA8FD, [0x48]),                # PHA from disasm
    (0xA8FE, [0xAC, 0x19, 0x00]),   # LDY a:$0019
    (0xA901, [0xB9, 0x80, 0x06]),   # LDA $0680,Y
]

print("Checking if disassembly matches ROM:")
for addr, expected_bytes in test_addrs:
    offset = addr - 0x8000
    actual = rom[offset:offset+len(expected_bytes)]
    actual_hex = ' '.join('{:02X}'.format(b) for b in actual)
    expected_hex = ' '.join('{:02X}'.format(b) for b in expected_bytes)
    match = "OK" if list(actual) == expected_bytes else "MISMATCH"
    print("${:04X}: expected {} got {} [{}]".format(addr, expected_hex, actual_hex, match))

# Also check the actual bytes at $A8D3
offset = 0xA8D3 - 0x8000
print("\nActual bytes at $A8D3 (32 bytes):")
actual = rom[offset:offset+32]
for i in range(0, 32, 16):
    addr = 0xA8D3 + i
    chunk = actual[i:i+16]
    hex_str = ' '.join('{:02X}'.format(b) for b in chunk)
    print("${:04X}: {}".format(addr, hex_str))
