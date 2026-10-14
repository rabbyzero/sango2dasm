#!/usr/bin/env python3
"""Verify asm/banks/data_02_sound.asm reproduces rom/prg/prg_02.bin byte-for-byte.

Bank $02 (the Namco-163 sound/note data bank, read by B1F_SoundNotePlayer) is
rendered by tools/gen_data_bank_02_asm.py: the SoundNoteHeaderTable is decoded
descriptor records and SoundCommandStreams is decoded note records plus 2-byte
command cells (format: tools/sound_streams.py). This harness assembles the bank
on its own (its own linker config, $8000-$9FFF window) and compares the result
to the stock ROM, so any edit produces a diff described in sound terms: region,
sound ID, stream, cell index and field.

It also re-walks the stream area, because a hand-edit that stays byte-exact in
one bank can still break the stream layout (the area is packed, and the last
stream's tail lives in rom/prg/prg_03.bin).

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
import sound_streams as ss                  # noqa: E402

ROOT = gen.ROOT
CC65 = '/home/zero/.local/bin/ca65'
LD65 = '/home/zero/.local/bin/ld65'
BUILD = os.path.join(ROOT, 'build')

FIELD_NAME = {0: 'b0 slot', 1: 'b1 ch', 2: 'b2 strm-lo', 3: 'b3 strm-hi'}


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
    src = os.path.join(ROOT, 'asm', 'banks', 'data_02_sound.asm')
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


def stream_map():
    """[(start, end, ids, first-header-byte)] over the packed sound area."""
    sd = ss.SoundData()
    out = []
    for group in ss.streams(sd):
        desc = group[0]
        if not (ss.SHARED_NOTE_CPU <= desc['addr'] < ss.STREAM_B03_END):
            continue                      # descriptor $B7 points at $4010: never read
        cells, hdr, end, problems = ss.walk(sd, desc['addr'], desc['channel'])
        out.append((desc['addr'], end, [d['id'] for d in group], problems))
    return out


def describe(offset, streams):
    """One differing byte -> a human-readable line naming region/stream/cell."""
    cpu = gen.WINDOW_CPU + offset
    if cpu < gen.STREAM_CPU:
        sid = offset // gen.ENTRY_SIZE
        field = FIELD_NAME[offset % gen.ENTRY_SIZE]
        name = ('SoundNoteHeaderTable entry $B7 (ptr word target of 17 entries)'
                if sid == 183 else 'SoundNoteHeaderTable soundID $%02X' % sid)
        return ('$%04X  %s (entry @ $%04X) field %s'
                % (cpu, name, gen.HEADER_CPU + sid * gen.ENTRY_SIZE, field))
    for start, end, ids, _ in streams:
        if start <= cpu < end:
            ids_txt = ' '.join('$%02X' % i for i in ids)
            if start == ss.SHARED_NOTE_CPU:
                return ('$%04X  shared note (header entry $B7 row, %s) byte %d'
                        % (cpu, ids_txt, cpu - start))
            if cpu < start + 4:
                return ('$%04X  soundID %s stream $%04X record header byte %d'
                        % (cpu, ids_txt, start, cpu - start))
            cell = (cpu - start - 4) // 2
            return ('$%04X  soundID %s stream $%04X cell %d, byte %d (%s)'
                    % (cpu, ids_txt, start, cell, (cpu - start - 4) % 2,
                       'opcode' if (cpu - start - 4) % 2 == 0 else 'operand'))
    return '$%04X  sound area, not reached by any stream pointer' % cpu


def check_streams(streams):
    """The decode must still explain the whole packed area; returns problems."""
    problems = []
    bad = [s for s in streams if s[3]]
    if bad:
        problems.append('%d stream(s) do not terminate at $FF: %s'
                        % (len(bad), ', '.join('$%04X' % b[0] for b in bad[:5])))
    prev = ss.SHARED_NOTE_CPU
    for start, end, ids, _ in sorted(streams):
        if start < ss.SHARED_NOTE_CPU or start >= ss.STREAM_B03_END:
            continue
        if start != prev:
            problems.append('gap/overlap at $%04X (expected $%04X)' % (start, prev))
        prev = max(prev, end)
    if prev != ss.STREAM_B03_END:
        problems.append('streams end at $%04X, expected $%04X' % (prev, ss.STREAM_B03_END))
    return problems


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
    streams = stream_map()
    print('bank 02 (asm/banks/data_02_sound.asm): %d bytes assembled' % len(built))
    rc = 0
    if len(built) != len(stock):
        print('  FAIL: length %d, expected %d' % (len(built), len(stock)))
        return 1
    diffs = [i for i, (a, b) in enumerate(zip(built, stock)) if a != b]
    if not diffs:
        print('  byte-exact vs rom/prg/prg_02.bin')
    else:
        print('  %d byte(s) differ from the stock ROM:' % len(diffs))
        for i in diffs[:60]:
            print('    %s: $%02X -> $%02X' % (describe(i, streams), stock[i], built[i]))
        if len(diffs) > 60:
            print('     ... %d more' % (len(diffs) - 60))
        rc = 1

    problems = check_streams(streams)
    if problems:
        print('  STREAM LAYOUT BROKEN:')
        for p in problems:
            print('    %s' % p)
        rc = 1
    else:
        print('  %d streams cover $82DC-$A965 with no gaps and all end at $FF'
              % len([s for s in streams if s[0] >= ss.SHARED_NOTE_CPU]))
    if args.dump:
        print('\n  descriptor table (as assembled):')
        for i in range(gen.HEADER_COUNT):
            e = built[i * gen.ENTRY_SIZE:i * gen.ENTRY_SIZE + gen.ENTRY_SIZE]
            print('    ID $%02X  %02X %02X %02X %02X -> strm $%04X'
                  % (i, e[0], e[1], e[2], e[3],
                     (((e[3] + ss.PTR_HIGH_BIAS) << 8) | e[2]) & 0xFFFF))
    return rc


if __name__ == '__main__':
    sys.exit(main())
