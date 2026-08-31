#!/usr/bin/env python3
"""Cross-check functions.h B0E_0F_* equates against the verified ld65
label dump (build/_labels_0e0f.txt) plus the SoundPlayAlt sub-entry."""
import re

truth = {}
for line in open('/home/zero/project/sango2dasm/build/_labels_0e0f.txt'):
    m = re.match(r'al ([0-9A-F]+) \.(\w+)\s*$', line)
    if m:
        truth[m.group(2)] = int(m.group(1), 16)
# sub-entry not exported by the harness: resolve via the JMP at $A00C
truth['SoundPlayAlt'] = 0xDF6E

bad = 0
count = 0
for line in open('/home/zero/project/sango2dasm/include/functions.h'):
    m = re.match(r'(B0E_0F_\w+)\s*=\s*\$([0-9A-F]{4})', line)
    if not m:
        continue
    count += 1
    name, val = m.group(1), int(m.group(2), 16)
    key = name[len('B0E_0F_'):]
    if key not in truth:
        print('UNKNOWN SYMBOL: {} = ${:04X}'.format(name, val))
        bad += 1
    elif truth[key] != val:
        print('MISMATCH: {} = ${:04X} but linker says ${:04X}'.format(
            name, val, truth[key]))
        bad += 1
print('checked {}, {} problems'.format(count, bad))
