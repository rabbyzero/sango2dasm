#!/usr/bin/env python3
"""Inspect $38 occurrences and the ROM region right after the 237-entry name table."""
data = open('rom/prg_combined.bin', 'rb').read()
BASE = 0x20000 + 0x101A

KATA = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
kmap = {0x04 + i: ch for i, ch in enumerate(KATA)}
kmap.update({0x35: 'ャ', 0x36: 'ュ', 0x37: 'ョ', 0x39: '゛', 0x3A: '゜'})

for i in range(600):
    e = data[BASE + i * 10: BASE + i * 10 + 10]
    if e[0] in (0x00, 0xFF):
        print("table ends at id", i)
        break
    if 0x38 in e:
        s = ''.join(kmap.get(b, f'[{b:02X}]') for b in e if b)
        print(f"id {i:3d}: {e.hex()}  {s}")

# region right after the table
end = BASE + i * 10
print(f"\ntable end file ofs {end:#x} (bank30 ${0x8000 + (end - 0x20000):04X})")
seg = data[end:end + 128]
print(seg.hex())

# also dump a few bytes before $901A for context
pre = data[BASE - 32:BASE]
print("pre:", pre.hex())
