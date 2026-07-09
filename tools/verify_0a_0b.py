#!/usr/bin/env python3
"""Final verification: PRG bank 0A+0B test build matches original ROM."""
import sys

with open('Sangokushi 2 - Haou no Tairiku (J).nes', 'rb') as f:
    rom = f.read()
prg_0a = rom[16+0x0A*0x2000:16+0x0B*0x2000]
prg_0b = rom[16+0x0B*0x2000:16+0x0C*0x2000]
original = prg_0a + prg_0b

with open('build/prg_0a_0b_test.bin', 'rb') as f:
    rebuilt = f.read()

mismatches = 0
for i in range(len(original)):
    if original[i] != rebuilt[i]:
        addr = 0xA000 + i
        if mismatches < 10:
            print(f"  Mismatch at ${addr:04X}: ROM ${original[i]:02X} rebuilt ${rebuilt[i]:02X}")
        mismatches += 1

print(f"Total mismatches: {mismatches} / {len(original)}")
if mismatches == 0:
    print("PASS: PRG 0A+0B is byte-for-byte identical to original ROM!")
else:
    print("FAIL")
    sys.exit(1)
