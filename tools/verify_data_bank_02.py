#!/usr/bin/env python3
"""Verify asm/banks/data_02.asm reproduces rom/prg/prg_02.bin byte-for-byte.

Bank $02 (the Namco-163 sound/note data bank, read by B1F_SoundNotePlayer) is
rendered by tools/gen_data_bank_02_asm.py: the SoundNoteHeaderTable is analysed
`.byte` records, the SoundCommandStreams tail is a sliced `.incbin`. This harness
assembles the bank on its own (its own linker config, $8000-$9FFF window) and
compares the result to the stock ROM. Any difference is reported in sound terms:
the byte is mapped to its region and, inside the header table, to its sound ID,
entry slot and field, so an edit produces a readable diff.

Modes:
    python tools/verify_data_bank_02.py            # strict: must be byte-exact
    python tools/verify_data_bank_02.py --dump     # print the assembled header decode

Exit 0 on byte-exactness, 1 otherwise.
"""
import argparse
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_data_bank_02_asm as gen          # noqa: E402

ROOT = gen.ROOT
CC65 = '/home/zero/.local/bin/ca65'
LD65 = '/home/zero/.local/bin/ld65'
BUILD = os.path.join(ROOT, 'build')

FIELD_NAME = {0: 'b0 slot', 1: 'b1 ch', 2: 'b2 dat', 3: 'b3 strm'}


def linker_cfg():
    return ('MEMORY {\n'
            '    BANK02: start = $8000, size = $2000, type = ro, fill = yes,\n'
            '            fillval = $FF, file = "build/_d02.bin";\n'
            '}\n'
            'SEGMENTS {\n'
            '    CODE_BANK02: load = BANK02, type = ro;\n'
            '}\n')


def assemble():
    """ca65 + ld65 the single bank; returns the built bytes or None."""
    os.makedirs(BUILD, exist_ok=True)
    src = os.path.join(ROOT, 'asm', 'banks', 'data_02.asm')
    obj = os.path.join(BUILD, '_d02.o')
    cfg = os.path.join(BUILD, '_d02.cfg')
    out = os.path.join(BUILD, '_d02.bin')
    with open(cfg, 'w', encoding='utf-8') as f:
        f.write(linker_cfg())
    r = subprocess.run([CC65, '-I', os.path.join(ROOT, 'include'),
                        '-I', os.path.join(ROOT, 'asm', 'banks'),
                        src, '-o', obj], capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('CA65 FAILED:\n%s' % r.stderr[:3000], file=sys.stderr)
        return None
    if r.stderr.strip():
        print('ca65 notes: %s' % r.stderr.strip()[:400])
    r = subprocess.run([LD65, '-C', cfg, obj, '-o', out],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('LD65 FAILED:\n%s' % r.stderr[:3000], file=sys.stderr)
        return None
    with open(out, 'rb') as f:
        return f.read()


def describe(offset):
    """One differing byte -> a human-readable line naming region / sound ID / field."""
    cpu = gen.WINDOW_CPU + offset
    if offset < gen.STREAM_CPU - gen.WINDOW_CPU:
        sid = offset // gen.ENTRY_SIZE
        field = FIELD_NAME[offset % gen.ENTRY_SIZE]
        return ('$%04X  SoundNoteHeaderTable soundID $%02X (entry @ $%04X) field %s'
                % (cpu, sid, gen.HEADER_CPU + sid * gen.ENTRY_SIZE, field))
    return '$%04X  SoundCommandStreams (raw slice region)' % cpu


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--dump', action='store_true',
                    help='print the assembled header decode as a sanity view')
    args = ap.parse_args()

    built = assemble()
    if built is None:
        return 1
    stock = gen.read_bank()
    print('bank 02 (asm/banks/data_02.asm): %d bytes assembled' % len(built))
    if len(built) != len(stock):
        print('  FAIL: length %d, expected %d' % (len(built), len(stock)))
        return 1
    rc = 0
    diffs = [i for i, (a, b) in enumerate(zip(built, stock)) if a != b]
    if not diffs:
        print('  byte-exact vs rom/prg/prg_02.bin')
    else:
        print('  %d byte(s) differ from the stock ROM:' % len(diffs))
        for i in diffs[:60]:
            print('    %s: $%02X -> $%02X' % (describe(i), stock[i], built[i]))
        if len(diffs) > 60:
            print('     ... %d more' % (len(diffs) - 60))
        rc = 1

    # Confirm the region split the source claims actually matches the ROM bytes.
    hdr_len = gen.STREAM_CPU - gen.WINDOW_CPU
    if built[:hdr_len] != stock[:hdr_len]:
        print('  INVALID: header table region drifted')
        rc = 1
    if args.dump:
        print('\n  header table (as assembled):')
        for i in range(gen.HEADER_COUNT):
            e = built[i * gen.ENTRY_SIZE:i * gen.ENTRY_SIZE + gen.ENTRY_SIZE]
            print('    ID $%02X  %02X %02X %02X %02X' % (i, e[0], e[1], e[2], e[3]))
    return rc


if __name__ == '__main__':
    sys.exit(main())
