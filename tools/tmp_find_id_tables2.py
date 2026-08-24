#!/usr/bin/env python3
"""Dump bank11 ID-table context and search castle table with 03+0C+11."""
data = open('rom/prg_combined.bin', 'rb').read()


def dump(bank, lo, hi):
    for base in range(lo, hi, 0x10):
        ofs = bank * 0x2000 + (base - 0x8000)
        row = data[ofs:ofs + 16]
        print(f'  bank{bank:02X} ${base:04X}: ' + ' '.join(f'{b:02X}' for b in row))


print('--- bank11 $8F50-$8F90 ---')
dump(0x11, 0x8F50, 0x8F90)
print('--- bank11 $9680-$96A0 ---')
dump(0x11, 0x9680, 0x96A0)

print('--- tables containing 03,0C,11 (castle-ish) ---')
for i in range(0x10 * 0x2000, 0x14 * 0x2000 - 8):
    b = data[i:i + 6]
    if {0x03, 0x0C, 0x11} <= set(b):
        bank, loc = i // 0x2000, 0x8000 + i % 0x2000
        print(f'  bank{bank:02X} ${loc:04X}: ' + ' '.join(f'{x:02X}' for x in data[i:i + 10]))
