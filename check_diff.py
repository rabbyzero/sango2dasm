#!/usr/bin/env python3
rom = open('rom/prg/prg_1f.bin', 'rb').read()
asm = open('build/bank1f.bin', 'rb').read()
print(f'ROM size: {len(rom)}')
print(f'ASM size: {len(asm)}')

# Find first diff
for i in range(min(len(rom), len(asm))):
    if rom[i] != asm[i]:
        print(f'First diff at offset {i} (${0xE000+i:04X}): ROM=${rom[i]:02X} ASM=${asm[i]:02X}')
        break

# Check how ASM ends
last_real = len(asm) - 1
while last_real > 0 and asm[last_real] == 0xFF:
    last_real -= 1
print(f'Last non-$FF byte in ASM: offset {last_real} (${0xE000+last_real:04X}) = ${asm[last_real]:02X}')

# Check if the assembled code is just shorter (missing gap bytes)
# by comparing the first N bytes that DO match
match_count = sum(1 for i in range(min(len(rom), len(asm))) if rom[i] == asm[i])
print(f'Matching bytes: {match_count} / {min(len(rom), len(asm))} ({100*match_count/min(len(rom),len(asm)):.1f}%)')

# Check if assembled output is a subset (shifted addresses)
# Try to find the first 16 bytes of ROM in the ASM output
search = rom[:16]
pos = asm.find(search)
if pos >= 0:
    print(f'First 16 ROM bytes found at ASM offset {pos}')
else:
    print('First 16 ROM bytes NOT found in ASM output')
    # Try first 8 bytes
    pos = asm.find(rom[:8])
    print(f'First 8 ROM bytes found at ASM offset {pos}')
