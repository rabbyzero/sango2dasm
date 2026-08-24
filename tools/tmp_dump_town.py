#!/usr/bin/env python3
"""Dump town command list region bank 13 $9320-$9380."""
src = open('tools/tmp_decode_menu_text.py').read()
exec(src.split("print('=== bank 13 text region")[0])
for base in range(0x9320, 0x9380, 0x10):
    ofs = 0x13 * 0x2000 + (base - 0x8000)
    row = data[ofs:ofs + 16]
    print(f'  ${base:04X}: ' + ' '.join(f'{b:02X}' for b in row) + '  | ' + dec(row))
