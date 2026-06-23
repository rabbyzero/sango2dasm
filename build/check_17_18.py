#!/usr/bin/env python3
# Compare assembled bank 17+18 output with raw PRG binaries
with open('rom/prg/prg_17.bin', 'rb') as f:
    orig17 = f.read()
with open('rom/prg/prg_18.bin', 'rb') as f:
    orig18 = f.read()
orig = orig17 + orig18

with open('build/test_17_18.bin', 'rb') as f:
    built = f.read()

print(f'Original combined: {len(orig)} bytes, Built: {len(built)} bytes')
if orig == built:
    print('Banks 17+18: byte-identical!')
else:
    diffs = [(i, a, b) for i, (a, b) in enumerate(zip(orig, built)) if a != b]
    print(f'{len(diffs)} byte differences')
    for i, a, b in diffs[:10]:
        bank = 17 if i < 8192 else 18
        offset = i % 8192
        addr = 0xA000 + offset
        print(f'  Bank ${bank:02X} offset {offset:04X} (addr ${addr:04X}): orig={a:02X} built={b:02X}')
