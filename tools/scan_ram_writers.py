#!/usr/bin/env python3
"""List every ROM site that writes a RAM byte, with the value and the proc.

Proc names in this project are partly guesses, and several state/scene procs are
misnamed, so "who calls X" cannot always be answered by reading names. This tool
answers it from bytes: it scans `rom/prg/prg_XX.bin` for absolute stores to a RAM
address and reports, per site, the nearest preceding `LDA #imm` (the value the
store most likely writes) and the enclosing `.proc` / top-level label of that
address in the matching `asm/banks/*.asm`.

Usage:
    # every writer of addr_game_state ($007A), all banks
    python tools/scan_ram_writers.py --addr 007A

    # narrow to one bank, or to a single value, or to INC/DEC as well
    python tools/scan_ram_writers.py --addr 0400 --value 0E --ops sta,inc
    python tools/scan_ram_writers.py --addr 0078 --bank 1f
    python tools/scan_ram_writers.py --addr 0400 --ops sta,inc,sty

Output is grouped by value so a state/slot's full caller set is visible at once.
The value column is heuristic (last LDA #imm within 16 bytes); sites printing '?'
load their value from memory or a register and need to be read by hand.
"""
import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRG_DIR = os.path.join(ROOT, 'rom', 'prg')
ASM_DIR = os.path.join(ROOT, 'asm', 'banks')

# opcode -> mnemonic for the absolute forms scanned
OPS = {0x8D: 'STA', 0x8E: 'STX', 0x8C: 'STY', 0xEE: 'INC', 0xCE: 'DEC'}

# CPU window each 8KB PRG file is disassembled at: the code pairs occupy
# $A000-$BFFF (even bank) + $C000-$FFFF (odd bank), bank $1F is the boot bank at
# $E000-$FFFF, and every other (data) bank is reached through the $8000 window.
CODE_PAIR_ODD = (0x09, 0x0B, 0x0D, 0x0F, 0x18, 0x1A, 0x1C, 0x1E)


def window_base(bank):
    if bank == 0x1F:
        return 0xE000
    if bank in CODE_PAIR_ODD:
        return 0xC000
    if bank in (0x08, 0x0A, 0x0C, 0x0E, 0x17, 0x19, 0x1B, 0x1D):
        return 0xA000
    return 0x8000


def asm_owner(addr, sig, bank):
    """(file, store line, enclosing label) of the asm line commented `$ADDR: <sig>`.

    `sig` (the instruction's own bytes) is required because bare address tokens
    also occur in data-byte comments, e.g. `.byte ... ; $BBAA: 01 8D 7A 00`.
    """
    token = '$%04X: %s' % (addr, sig)
    hits = []
    for fn in sorted(os.listdir(ASM_DIR)):
        if not fn.endswith('.asm'):
            continue
        lines = open(os.path.join(ASM_DIR, fn), errors='replace').read().splitlines()
        for i, line in enumerate(lines):
            if token in line:
                hits.append((fn, i, lines))
    if not hits:
        return '?', 0, '?'
    preferred = [h for h in hits if '%02x' % bank in h[0]]
    fn, i, lines = (preferred or hits)[0]
    for j in range(i, -1, -1):
        m = re.match(r'\.proc\s+(\S+)', lines[j])
        if m:
            return fn, i + 1, m.group(1)
        m = re.match(r'([A-Za-z_]\w*):\s*(?:;.*)?$', lines[j])
        if m:
            return fn, i + 1, m.group(1)
    return fn, i + 1, '?'


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--addr', required=True, help='RAM address written, hex (e.g. 007A)')
    ap.add_argument('--bank', default='all', help='PRG bank hex, or "all"')
    ap.add_argument('--value', default=None, help='only report this stored value (hex)')
    ap.add_argument('--ops', default='sta', help='comma list of sta,stx,sty,inc,dec')
    args = ap.parse_args()

    addr = int(args.addr, 16)
    want = {v for v, k in (('STA', 'sta'), ('STX', 'stx'), ('STY', 'sty'),
                           ('INC', 'inc'), ('DEC', 'dec')) if k in args.ops}
    lo, hi = addr & 0xFF, addr >> 8

    rows = []
    for fn in sorted(os.listdir(PRG_DIR)):
        m = re.match(r'prg_([0-9a-f]{2})\.bin$', fn)
        if not m:
            continue
        if args.bank != 'all' and m.group(1) != args.bank.lower():
            continue
        data = open(os.path.join(PRG_DIR, fn), 'rb').read()
        bank = int(m.group(1), 16)
        base = window_base(bank)
        for i in range(len(data) - 2):
            op = OPS.get(data[i])
            if op not in want or data[i + 1] != lo or data[i + 2] != hi:
                continue
            cpu = base + i
            imm = None
            for j in range(max(0, i - 16), i):
                if data[j] == 0xA9:
                    imm = data[j + 1]
            if args.value is not None and imm != int(args.value, 16):
                continue
            sig = ' '.join('%02X' % b for b in data[i:i + 3])
            src, line, proc = asm_owner(cpu, sig, bank)
            rows.append((None if imm is None else imm, fn, cpu, op, proc, src, line))

    if not rows:
        print('no %s sites to $%04X' % ('/'.join(sorted(want)), addr))
        return 1
    print('%d site(s) writing $%04X' % (len(rows), addr))
    for imm, fn, cpu, op, proc, src, line in sorted(
            rows, key=lambda r: (r[0] is None, r[0] or 0, r[1])):
        print('  value %-4s %-13s $%04X %-3s $%04X   %-38s %s:%d' % (
            '$%02X' % imm if imm is not None else '?', fn, cpu, op, addr,
            proc, src, line))
    return 0


if __name__ == '__main__':
    sys.exit(main())
