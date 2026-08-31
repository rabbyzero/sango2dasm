#!/usr/bin/env python3
"""Generate B0E_0F_* functions.h entries from prg_0e_0f.asm proc headers.

Reads the "=== $ADDR: Name ..." header comment block above each top-level
.proc, takes the first summary line after the "$ADDR: Name" line, and emits
functions.h-style equates ordered by address (verified against the ld65
label dump in build/_labels_0e0f.txt).
"""
import re

src = open('/home/zero/project/sango2dasm/asm/banks/prg_0e_0f.asm').read()
lines = src.split('\n')

# address -> summary from header comment blocks
summaries = {}
for i, l in enumerate(lines):
    m = re.match(r'^; (\$[0-9A-F]{4}): (\w+)\s*$', l)
    if not m:
        continue
    addr = int(m.group(1).lstrip('$'), 16)
    # first non-empty following comment line is the summary
    for j in range(i + 1, min(i + 6, len(lines))):
        mm = re.match(r'^; (.+?)\s*$', lines[j])
        if mm and not mm.group(1).startswith('$') and mm.group(1) != '=':
            summaries.setdefault(addr, mm.group(1))
            break

# authoritative addresses from ld65 label dump
addrs = {}
for line in open('/home/zero/project/sango2dasm/build/_labels_0e0f.txt'):
    m = re.match(r'al ([0-9A-F]+) \.(\w+)\s*$', line)
    if m:
        addrs[m.group(2)] = int(m.group(1), 16)

skip = {'BattleVBlankFrameUpdate_Entry', 'BattleAnimSoundEngine_Entry',
        'OfficerBattleExpLevelCheck_Entry', 'OfficerStatSumBattleTransfer_Entry',
        'SoundPlayAlt_Entry'}
names = sorted((n for n in addrs if n not in skip), key=lambda n: addrs[n])
for n in names:
    a = addrs[n]
    summ = summaries.get(a, '')
    eq = 'B0E_0F_' + n
    print('{} = ${:04X}   ; {}'.format(eq.ljust(40), a, summ))
