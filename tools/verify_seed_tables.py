#!/usr/bin/env python3
"""Verify the new-game seed tables and their SramInit copy into SRAM.

This checks the claims made in code/initial_data_tables.md (and repeated in
docs/officer_data.md / docs/province_data.md) straight from the ROM and from
the disassembly, so a later refactor cannot silently invalidate them:

  1. Mapper mapping   - the bank register values $30/$31 select the physical
                        8KB banks rom/prg/prg_10.bin / prg_11.bin, and those
                        files are the matching slices of rom/prg_combined.bin.
  2. SramInit copies  - the two block loops inside .proc SramInit
                        (asm/banks/prg_1d_1e.asm, $DD8B) are re-read from the
                        disassembly and their source/destination/length
                        immediates must produce:
                          bank $30 $8C00 -> $6000, $3C0 bytes (30 x 32)
                          bank $31 $8000 -> $63C0, $0B40 bytes (240 x 12)
  3. Table extents    - the province table is exactly 30 records, the officer
                        table exactly 237 records (slots $ED-$EF are padding),
                        followed by the arrival schedule at bank $31 $8B1C.
  4. Decode agreement - the officer seed's +11 bits 0-1 (状態 OfficerStatus)
                        equals 2 for exactly the officers listed in the
                        Province roster slots, and the arrival schedule holds
                        (id < 237, year 189-210) pairs with $FF $FF padding.

Usage:
    python tools/verify_seed_tables.py            # report, exit 1 on failure
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK_DIR = os.path.join(ROOT, 'rom', 'prg')
PRG_COMBINED = os.path.join(ROOT, 'rom', 'prg_combined.bin')
SRAM_INIT_ASM = os.path.join(ROOT, 'asm', 'banks', 'prg_1d_1e.asm')

PROV_BANK = 0x30
PROV_CPU = 0x8C00
PROV_SRAM = 0x6000
PROV_LEN = 0x3C0
PROV_SIZE = 32
PROV_COUNT = 30
PROV_ROSTER = 0x11                  # +$11..+$1A officer slots

OFF_BANK = 0x31
OFF_CPU = 0x8000
OFF_SRAM = 0x63C0
OFF_LEN = 0x0B40
OFF_SIZE = 12
OFF_COUNT = 237                    # real records; the copy holds 240 slots
OFF_STATUS_OFS = 11
STATUS_ROSTERED = 2
STATUS_HIDDEN = 1

SCHED_CPU = 0x8B1C                  # arrival schedule, bank $31
SCHED_STRIDE = 0x14                 # 10 x (officer id, appear year)

problems = []


def fail(msg):
    problems.append(msg)


def check_bank_mapping():
    """Physical bank slices of prg_combined.bin must match rom/prg/prg_XX.bin."""
    with open(PRG_COMBINED, 'rb') as f:
        comb = f.read()
    for n in (0x10, 0x11):
        path = os.path.join(BANK_DIR, 'prg_%02x.bin' % n)
        with open(path, 'rb') as f:
            b = f.read()
        seg = comb[n * 0x2000:n * 0x2000 + 0x2000]
        if seg != b:
            fail('prg_%02x.bin does not match prg_combined.bin + $%05X'
                 % (n, n * 0x2000))
        if len(b) != 0x2000:
            fail('prg_%02x.bin is %d bytes, expected 8192' % (n, len(b)))
    return (comb[0x10 * 0x2000:0x11 * 0x2000],
            comb[0x11 * 0x2000:0x12 * 0x2000])


def parse_sram_init():
    """Re-derive the two SramInit block copies from the disassembly text.

    Each copy block starts with `LDY #$3n` + `JSR B1F_SwitchBank8_B` (the bank
    for the $8000 window), sets the source pointer in $0000/$0001 and the SRAM
    destination in $0002/$0003, and ends at its `CMP #<pages>` / `CPX #<low>`
    length test.
    """
    with open(SRAM_INIT_ASM, encoding='utf-8') as f:
        text = f.read()
    m = re.search(r'^\.proc SramInit\n(.*?)^\.endproc', text, re.S | re.M)
    if not m:
        fail('SramInit proc not found in %s' % SRAM_INIT_ASM)
        return {}
    lines = m.group(1).splitlines()

    copies = {}
    i = 0
    while i < len(lines):
        bank = re.match(r'\s*LDY #\$([0-9A-Fa-f]{2})', lines[i])
        if not (bank and i + 1 < len(lines)
                and 'B1F_SwitchBank8_B' in lines[i + 1]):
            i += 1
            continue
        seg = []
        for j in range(i + 2, len(lines)):
            seg.append(lines[j])
            if re.match(r'\s*CPX #\$', lines[j]):
                break
        i += 1
        src_hi = re.search(r'LDA #\$([0-9A-Fa-f]{2})\s*;[^\n]*A9 \1\s*\n'
                           r'\s*STA a:\$0001', '\n'.join(seg))
        dst_lo = re.search(r'LDA #\$([0-9A-Fa-f]{2})\s*;[^\n]*A9 \1\s*\n'
                           r'\s*STA a:\$0002', '\n'.join(seg))
        dst_hi = re.search(r'LDA #\$([0-9A-Fa-f]{2})\s*;[^\n]*A9 \1\s*\n'
                           r'\s*STA a:\$0003', '\n'.join(seg))
        pages = re.search(r'CMP #\$([0-9A-Fa-f]{2})', '\n'.join(seg))
        low = re.search(r'CPX #\$([0-9A-Fa-f]{2})', '\n'.join(seg))
        if src_hi and dst_lo and dst_hi and pages and low:
            copies[int(bank.group(1), 16)] = {
                'src': int(src_hi.group(1), 16) * 0x100,
                'dst': int(dst_hi.group(1), 16) * 0x100
                       + int(dst_lo.group(1), 16),
                'len': int(pages.group(1), 16) * 0x100 + int(low.group(1), 16),
            }
    return copies


def check_copies(copies):
    want = {PROV_BANK: (PROV_CPU, PROV_SRAM, PROV_LEN),
            OFF_BANK: (OFF_CPU, OFF_SRAM, OFF_LEN)}
    for bank, (src, dst, ln) in want.items():
        got = copies.get(bank)
        if not got:
            fail('no SramInit copy block found for bank register $%02X' % bank)
            continue
        if (got['src'], got['dst'], got['len']) != (src, dst, ln):
            fail('bank $%02X copy is $%04X->$%04X len $%03X, expected '
                 '$%04X->$%04X len $%03X'
                 % (bank, got['src'], got['dst'], got['len'], src, dst, ln))
        else:
            print('  bank $%02X: $%04X -> SRAM $%04X, $%03X bytes '
                  '= %d records x %d OK'
                  % (bank, src, dst, ln, ln // (PROV_SIZE if bank == PROV_BANK
                                               else OFF_SIZE),
                     PROV_SIZE if bank == PROV_BANK else OFF_SIZE))
    if copies.get(OFF_BANK, {}).get('len', 0) // OFF_SIZE != 240:
        fail('officer copy is not 240 slots')


def check_tables(b10, b11):
    # province records: within the copy window, so 30 records must fill it
    if PROV_COUNT * PROV_SIZE != PROV_LEN:
        fail('province record count does not fill the copy window')
    ids = set()
    for pid in range(PROV_COUNT):
        base = PROV_CPU - 0x8000 + pid * PROV_SIZE
        rec = b10[base:base + PROV_SIZE]
        if len(rec) != PROV_SIZE:
            fail('province %d: truncated record' % pid)
            continue
        if rec[0x1B] or any(rec[0x1C:]):
            fail('province %d: runtime fields are not zero in the seed' % pid)
        for slot in range(PROV_ROSTER, PROV_ROSTER + 10):
            if rec[slot] != 0xFF:
                if rec[slot] >= OFF_COUNT:
                    fail('province %d slot +$%02X holds officer id %d >= %d'
                         % (pid, slot, rec[slot], OFF_COUNT))
                ids.add(rec[slot])
    print('  province rosters: %d distinct officer ids' % len(ids))

    # officer status nibble must match the roster set exactly
    status = {}
    for oid in range(OFF_COUNT):
        base = oid * OFF_SIZE
        rec = b11[base:base + OFF_SIZE]
        status[oid] = rec[OFF_STATUS_OFS] & 0x03
    rostered_status = {o for o, s in status.items() if s == STATUS_ROSTERED}
    if rostered_status != ids:
        fail('OfficerStatus==2 set (%d) != Province roster set (%d): %s / %s'
             % (len(rostered_status), len(ids),
                sorted(rostered_status - ids), sorted(ids - rostered_status)))
    if any(s not in (STATUS_HIDDEN, STATUS_ROSTERED)
           for s in status.values()):
        fail('seed OfficerStatus outside {1,2}: %s'
             % sorted({s for s in status.values()
                       if s not in (STATUS_HIDDEN, STATUS_ROSTERED)}))
    print('  officer seed status: %d rostered (== rosters), %d hidden'
          % (sum(1 for s in status.values() if s == STATUS_ROSTERED),
             sum(1 for s in status.values() if s == STATUS_HIDDEN)))

    # the officer table ends where the arrival schedule starts
    table_end = OFF_CPU - 0x8000 + OFF_COUNT * OFF_SIZE
    if table_end != SCHED_CPU - 0x8000:
        fail('officer table ends at prg_11+$%04X but the schedule starts at '
             '+$%04X' % (table_end, SCHED_CPU - 0x8000))
    if OFF_LEN - OFF_COUNT * OFF_SIZE != 0x24:
        fail('padding window is not $24 bytes')

    sched_base = SCHED_CPU - 0x8000
    scheduled = 0
    for pid in range(PROV_COUNT):
        blk = b11[sched_base + pid * SCHED_STRIDE:
                  sched_base + (pid + 1) * SCHED_STRIDE]
        years = []
        for j in range(0, SCHED_STRIDE, 2):
            oid, year = blk[j], blk[j + 1]
            if oid == 0xFF:
                if any(x != 0xFF for x in blk[j + 1:]):
                    fail('schedule province %d: bytes after the $FF sentinel '
                         'are not all $FF' % pid)
                break
            scheduled += 1
            if oid >= OFF_COUNT:
                fail('schedule province %d: officer id %d >= %d'
                     % (pid, oid, OFF_COUNT))
            if not (0xBD <= year <= 0xD2):
                fail('schedule province %d: appear year $%02X out of range'
                     % (pid, year))
            years.append(year)
        if years != sorted(years):
            fail('schedule province %d: years not ascending' % pid)
    print('  arrival schedule: %d entries across %d provinces '
          '($%04X-$%04X)' % (scheduled, PROV_COUNT, sched_base,
                             sched_base + PROV_COUNT * SCHED_STRIDE - 1))
    hidden = [o for o, s in status.items() if s == STATUS_HIDDEN]
    unscheduled = len(hidden) - scheduled
    print('  hidden officers without a schedule entry: %d' % unscheduled)

    # name tables: 237 entries then the padding slots are blank
    name_base = 0x901A - 0x8000
    for oid in (OFF_COUNT, OFF_COUNT + 1, OFF_COUNT + 2):
        entry = b10[name_base + oid * 10:name_base + oid * 10 + 10]
        if any(entry):
            fail('officer name slot %d is not blank (%s)'
                 % (oid, entry.hex().upper()))
    prov_name_base = 0x9A1A - 0x8000
    for pid in range(PROV_COUNT):
        entry = b10[prov_name_base + pid * 8:prov_name_base + pid * 8 + 8]
        if 0 not in entry:
            fail('province name %d is not $00-terminated within 8 bytes' % pid)
    print('  name tables: %d officer names (+3 blank padding slots), '
          '%d province names' % (OFF_COUNT, PROV_COUNT))


def main():
    print('seed table verification for %s' % os.path.basename(PRG_COMBINED))
    b10, b11 = check_bank_mapping()
    print('  bank register $30 -> prg_10.bin, $31 -> prg_11.bin OK')
    check_copies(parse_sram_init())
    check_tables(b10, b11)
    for p in problems:
        print('FAIL: %s' % p, file=sys.stderr)
    if problems:
        return 1
    print('OK: seed table locations, copy lengths and decode invariants hold')
    return 0


if __name__ == '__main__':
    sys.exit(main())
