#!/usr/bin/env python3
"""Find hidden dispatcher/trampoline calls in remaining Data Regions."""
import re

with open('/home/zero/project/sango2dasm/asm/banks/prg_0c_0d.asm') as f:
    lines = f.readlines()

print('=== Remaining Data Regions that may hide dispatcher/trampoline calls ===')
for i, line in enumerate(lines):
    if '; --- Data Region ---' in line:
        j = i + 1
        region_bytes = []
        region_addr = None
        while j < len(lines):
            s = lines[j].strip()
            if s.startswith('.byte'):
                m = re.search(r';\s*\$([0-9A-F]{4}):', lines[j])
                if m and region_addr is None:
                    region_addr = int(m.group(1), 16)
                bm = re.search(r'\.byte\s+(.*?)(?:\s*;|$)', lines[j])
                if bm:
                    vals = re.findall(r'\$([0-9A-F]{2})', bm.group(1))
                    region_bytes.extend(int(v, 16) for v in vals)
                j += 1
            elif s.startswith('; ---') or s.startswith('Loc_') or s == '':
                break
            else:
                break

        if region_addr and len(region_bytes) >= 3:
            for k in range(len(region_bytes) - 2):
                if region_bytes[k] == 0x20 and region_bytes[k+1] == 0x07 and region_bytes[k+2] == 0xEE:
                    addr = region_addr + k
                    print(f'  Line {i+1}: Hidden BankedCallbackTrampoline at ${addr:04X}')
                if region_bytes[k] == 0x20 and region_bytes[k+1] == 0xDE and region_bytes[k+2] == 0xEA:
                    addr = region_addr + k
                    print(f'  Line {i+1}: Hidden CallbackDispatcher at ${addr:04X}')

# Also check: the A02B dispatcher is special - it's hidden because Loc_A02A
# starts at the 3rd byte of LDA $0500 (AD 00 05), causing misalignment.
# The bytes at A02B-A02D are 20 DE EA = JSR $EADE
# The table at A02E-A04D has 16 entries
print()
print('=== Special case: A02B dispatcher hidden by Loc_A02A misalignment ===')
print('  A028: AD 00 05 = LDA $0500')
print('  A02B: 20 DE EA = JSR B1F_CallbackDispatcher')
print('  A02E-A04D: 16 word table entries')
print('  Loc_A02A label points to 3rd byte of LDA $0500 - should be removed')
