#!/usr/bin/env python3
"""Dump scroll-panel command-list rows from prg_06 ($95E6/$976E/$98F6)."""
d = open('rom/prg/prg_06.bin', 'rb').read()
for base, name in [(0x15E6, '$95E6'), (0x176E, '$976E'), (0x18F6, '$98F6')]:
    print(f'=== {name} ===')
    for r in range(8):
        row = d[base + r * 0x1C: base + (r + 1) * 0x1C]
        print(f' {r}: ' + ' '.join(f'{b:02X}' for b in row))
    print()
