#!/usr/bin/env python3
"""Verify lines 4253-4375 of asm/banks/prg_0e_0f.asm against ROM bytes.

Checks:
 1. every .byte line: directive bytes == ROM bytes at the annotated addr,
    and the trailing hex comment matches both.
 2. every .word table line: address continuity ($BBFD..$BC7B) and the ROM
    word equals the first named label's address.
 3. label addresses implied by following .byte rows match expectations.
"""
import re

data = (open('rom/prg/prg_0e.bin', 'rb').read() +
        open('rom/prg/prg_0f.bin', 'rb').read())
base = 0xA000

src = open('asm/banks/prg_0e_0f.asm').read().splitlines()
lines = src[4252:4375]  # file lines 4253-4375

label_addr = {
    'BattleCursorArrowSpritePtrs': 0xBBFD,
    'BattleCursorArrowSprTiles40': 0xBC7D,
    'BattleCursorArrowSprTiles60': 0xBC8E,
    'BattleCursorArrowSprTiles40Dup': 0xBC9F,
    'BattleCursorArrowSprTiles60Dup': 0xBCB0,
    'BattleCursorArrowSprBox08': 0xBCC1,
    'BattleCursorArrowSprBox38': 0xBCD2,
    'BattleCursorArrowSprBox0C': 0xBCE3,
    'BattleCursorArrowSprBox2C': 0xBCF4,
    'BattleCursorArrowSprBox42': 0xBD05,
    'BattleCursorArrowSprBox62': 0xBD16,
    'BattleCursorArrowSprBox42b': 0xBD27,
    'BattleCursorArrowSprBox62b': 0xBD38,
    'BattleCursorArrowSprBox0A': 0xBD49,
    'BattleCursorArrowSprBox0AHi': 0xBD5A,
    'BattleCursorArrowSprBox0E': 0xBD6B,
    'BattleCursorArrowSprBox2E': 0xBD7C,
    'BattleCursorArrowSprBox06': 0xBD8D,
    'BattleCursorArrowSprBox26': 0xBD9E,
    'BattleCursorArrowSprBox04': 0xBDAF,
    'BattleCursorArrowSprBox24': 0xBDC0,
    'BattleCursorArrowSprBox00': 0xBDD1,
    'BattleCursorArrowSprBox20': 0xBDE2,
    'BattleCursorArrowSprBox02': 0xBDF3,
    'BattleCursorArrowSprBox22': 0xBE04,
    'BattleCursorArrowSprMarker': 0xBE65,
}

errors = 0
want_addr = 0xBBFD
n_byte = n_word = 0

for n, ln in enumerate(lines, start=4253):
    s = ln.strip()
    if s.startswith('.byte'):
        n_byte += 1
        body = s.split(';')[0]
        vals = [int(x, 16) for x in re.findall(r'\$([0-9A-F]{2})', body)]
        am = re.search(r'; \$([0-9A-F]{4}): (.*)$', s)
        if not am:
            print('line %d: NO addr/hex comment' % n)
            errors += 1
            continue
        addr = int(am.group(1), 16)
        romrow = list(data[addr - base:addr - base + len(vals)])
        cmbytes = [int(x, 16) for x in am.group(2).strip().split()]
        if vals != romrow:
            print('line %d $%04X: .byte %s != ROM %s' %
                  (n, addr, vals, romrow))
            errors += 1
        if cmbytes != romrow:
            print('line %d $%04X: hex comment %s != ROM %s' %
                  (n, addr, cmbytes, romrow))
            errors += 1
    elif s.startswith('.word'):
        n_word += 1
        am = re.search(r'; \$([0-9A-F]{4}):\s*([0-9A-F ]+?)(?:\s*;.*)?$', s)
        if not am:
            print('line %d: .word missing addr/hex comment' % n)
            errors += 1
            continue
        addr = int(am.group(1), 16)
        hexbytes = [int(x, 16) for x in am.group(2).split()]
        romrow = list(data[addr - base:addr - base + 4])
        if hexbytes != romrow:
            print('line %d $%04X: .word hex comment %s != ROM %s' %
                  (n, addr, hexbytes, romrow))
            errors += 1
        if addr != want_addr:
            print('line %d: addr $%04X, expected $%04X' % (n, addr, want_addr))
            errors += 1
        want_addr += 4
        m = re.match(r'\.word\s+(\w+),(\w+)', s)
        for k, lbl in enumerate((m.group(1), m.group(2))):
            a = addr + 2 * k
            romw = data[a - base] | (data[a - base + 1] << 8)
            want = label_addr.get(lbl)
            if want is not None and romw != want:
                print('line %d $%04X: ROM word $%04X != %s ($%04X)' %
                      (n, a, romw, lbl, want))
                errors += 1

if want_addr != 0xBC7D:
    print('word table ended at $%04X, expected $BC7D' % want_addr)
    errors += 1

print('.byte lines checked: %d, .word lines checked: %d' % (n_byte, n_word))
print('errors:', errors)
