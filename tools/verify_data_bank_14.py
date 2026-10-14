#!/usr/bin/env python3
"""Verify asm/banks/data_14_sprite_set_a.asm against rom/prg/prg_14.bin byte-for-byte.

Assembles the bank standalone (its own linker config, $8000-$9FFF window) with
the real ca65/ld65 and compares the 8192 built bytes with the stock ROM. On a
mismatch the offset is mapped to its region (pointer table / sprite record /
filler) so an edited record can be located in human terms.

    python tools/verify_data_bank_14.py
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CC65 = '/home/zero/.local/bin/ca65'
LD65 = '/home/zero/.local/bin/ld65'
BUILD = os.path.join(ROOT, 'build')
BANK = 0x14

LINKER_CFG = ('MEMORY {\n'
              '    BANK14: start = $8000, size = $2000, type = ro, fill = yes,\n'
              '            fillval = $FF, file = "build/_seed14.bin";\n'
              '}\n'
              'SEGMENTS {\n'
              '    CODE_BANK14: load = BANK14, type = ro;\n'
              '}\n')


def assemble():
    os.makedirs(BUILD, exist_ok=True)
    asm = os.path.join(BUILD, '_seed14.asm')
    cfg = os.path.join(BUILD, '_seed14.cfg')
    obj = os.path.join(BUILD, '_seed14.o')
    out = os.path.join(BUILD, '_seed14.bin')
    with open(os.path.join(ROOT, 'asm', 'banks', 'data_14_sprite_set_a.asm'),
              encoding='utf-8') as f:
        text = f.read()
    with open(asm, 'w', encoding='utf-8') as f:
        f.write(text)
    with open(cfg, 'w', encoding='utf-8') as f:
        f.write(LINKER_CFG)
    r = subprocess.run([CC65, '-I', os.path.join(ROOT, 'include'),
                        '-I', os.path.join(ROOT, 'asm', 'banks'),
                        asm, '-o', obj], capture_output=True, text=True,
                       cwd=ROOT)
    if r.returncode != 0:
        print('CA65 FAILED:\n%s' % r.stderr[:4000], file=sys.stderr)
        return None
    if r.stderr.strip():
        print('ca65 notes: %s' % r.stderr.strip()[:400])
    r = subprocess.run([LD65, '-C', cfg, obj, '-o', out],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('LD65 FAILED:\n%s' % r.stderr[:4000], file=sys.stderr)
        return None
    with open(out, 'rb') as f:
        return f.read()


def region_of(offset):
    if offset < 0x0F4:
        return 'SpritePtrTable entry id %02X' % (offset // 2)
    return 'SpriteRecords'


def main():
    built = assemble()
    if built is None:
        return 1
    with open(os.path.join(ROOT, 'rom', 'prg', 'prg_14.bin'), 'rb') as f:
        rom = f.read()
    if len(built) != len(rom):
        print('SIZE MISMATCH: built %d bytes, rom %d bytes'
              % (len(built), len(rom)))
        return 1
    diffs = [i for i in range(len(rom)) if built[i] != rom[i]]
    if not diffs:
        print('compared %d bytes, 0 mismatches' % len(rom))
        return 0
    print('%d mismatches:' % len(diffs))
    for i in diffs[:40]:
        print('  $%04X: asm %02X != rom %02X  (%s)'
              % (0x8000 + i, built[i], rom[i], region_of(i)))
    return 1


if __name__ == '__main__':
    sys.exit(main())
