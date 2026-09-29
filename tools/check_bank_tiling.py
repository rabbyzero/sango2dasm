#!/usr/bin/env python3
"""Check that a generated seed-data bank reproduces exactly its 8KB window.

The seed-data banks are assembled from a list of analysed regions whose DECLARED
lengths tile the $8000-$9FFF window, with raw .incbin slices for everything else
(see tools/gen_data_bank_asm.py:bank_regions). render_bank() advances its cursor
by the declared length, not by what the emitter actually wrote, so an emitter that
over- or under-emits is invisible there: it only surfaces as an ld65 "segment
overflows memory area" error, or - worse - as a silent byte shift of every region
after it. Every emitted line carries its CPU address in a trailing comment, so
this script walks the file, follows that address stream, and reports the first
line where the stream and the comment disagree.

Usage:
    python3 tools/check_bank_tiling.py [bank ...]   # default: 10 11
Exit status is 0 only when the regions tile $8000-$9FFF exactly.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WINDOW_CPU = 0x8000
BANK_SIZE = 0x2000
HEX2 = re.compile(r'\$([0-9A-Fa-f]{2})\b')
WORD = re.compile(r'\$[0-9A-Fa-f]{2,4}\b')
ADDR = re.compile(r'\$([89][0-9A-Fa-f]{3})')


def emitted_entries(path):
    """(cpu_addr, byte_count, lineno, text) for each emitting directive line."""
    entries = []
    for lineno, raw in enumerate(open(path, encoding='utf-8'), 1):
        code, _, comment = raw.rstrip('\n').partition(';')
        text = raw.strip()[:70]
        if '.incbin' in code:
            m = re.search(r'\$([0-9A-Fa-f]{4}),\s*\$([0-9A-Fa-f]{4})', code)
            if not m:
                continue
            # .incbin carries the FILE offset; the data window base is $8000
            entries.append((WINDOW_CPU + int(m.group(1), 16),
                            int(m.group(2), 16), lineno, text))
        elif '.word' in code:
            n = 2 * len(WORD.findall(code))
            m = ADDR.search(comment)
            entries.append((int(m.group(1), 16) if m else None, n, lineno, text))
        elif '.byte' in code:
            n = len(HEX2.findall(code))
            m = ADDR.search(comment)
            entries.append((int(m.group(1), 16) if m else None, n, lineno, text))
    return entries


def check(bank):
    path = os.path.join(ROOT, 'asm', 'banks', 'data_%02x.asm' % bank)
    if not os.path.exists(path):
        print('missing %s' % path)
        return 1
    pos = WINDOW_CPU
    bad = 0
    unnamed = 0
    for addr, n, lineno, text in emitted_entries(path):
        if addr is None:
            # A line without an address comment (the trade tables chunk by id, not
            # by address) is counted but cannot be validated.
            unnamed += 1
            pos += n
            continue
        if addr != pos:
            print('  line %d: stream is at $%04X, line says $%04X (delta %+d)'
                  '  %s' % (lineno, pos, addr, addr - pos, text))
            bad += 1
        pos = addr + n
    delta = pos - (WINDOW_CPU + BANK_SIZE)
    print('bank %02X: emission ends at $%04X, delta %+d bytes; %d address drift'
          ' line(s), %d line(s) without an address comment'
          % (bank, pos, delta, bad, unnamed))
    return 0 if bad == 0 and delta == 0 else 1


if __name__ == '__main__':
    banks = [int(a, 16) for a in sys.argv[1:]] or [0x10, 0x11]
    sys.exit(sum(check(b) for b in banks))
