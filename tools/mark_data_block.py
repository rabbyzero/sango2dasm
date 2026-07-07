#!/usr/bin/env python3
"""Replace $DBCF-$DD8A in prg_1d_1e.asm with proper .byte data."""

asm_path = 'asm/banks/prg_1d_1e.asm'
rom_path = 'rom/prg/prg_1e.bin'

with open(asm_path, 'r') as f:
    lines = f.readlines()

with open(rom_path, 'rb') as f:
    rom = f.read()

# Find the line with "; $DBCF: InitKingdomDefaults" header block
# and the line before .proc SramInit
start_idx = None
end_idx = None
for i, line in enumerate(lines):
    if '; $DBCF: InitKingdomDefaults' in line:
        # Go back to find the separator line before it
        start_idx = i - 1  # the ;=== line
    if '.proc SramInit' in line:
        end_idx = i
        break

print(f"Replacing lines {start_idx+1} to {end_idx} (0-indexed: {start_idx} to {end_idx-1})")
print(f"First line: {lines[start_idx].rstrip()}")
print(f"Last line to replace: {lines[end_idx-1].rstrip()}")
print(f"Next line (kept): {lines[end_idx].rstrip()}")

# Generate .byte data from ROM
start_offset = 0x1BCF  # $DBCF - $C000
end_offset = 0x1D8B    # $DD8A - $C000 + 1
raw = rom[start_offset:end_offset]

new_lines = []
new_lines.append(';===============================================================================\n')
new_lines.append('; $DBCF-$DD8A: Data block (ScenarioDataTable / kingdom defaults)\n')
new_lines.append(';===============================================================================\n')

for i in range(0, len(raw), 16):
    chunk = raw[i:i+16]
    addr = 0xDBCF + i
    bytes_str = ', '.join(f'${b:02X}' for b in chunk)
    comment = ' '.join(f'{b:02X}' for b in chunk)
    new_lines.append(f'  .byte {bytes_str:<64s} ; ${addr:04X}: {comment}\n')

new_lines.append('\n')

# Replace
result = lines[:start_idx] + new_lines + lines[end_idx:]

with open(asm_path, 'w') as f:
    f.writelines(result)

print(f"Done. Wrote {len(new_lines)} lines replacing {end_idx - start_idx} lines.")
