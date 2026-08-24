#!/usr/bin/env python3
"""Dump ASCII art of BG font chunks for candidate display-mode records.

BG pattern table = PPU $1000 -> NAMCO163 slots 4-7 ($00B2-$00B5).
Register page V -> file chr_(V//8).bin @ (V%8)*0x400.
"""
import sys

PRG = open('rom/prg_combined.bin', 'rb').read()

RECORDS = {
    10: [0x8D, 0x8E, 0x8F, 0x90],
    11: [0xA0, 0xA1, 0xA2, 0xA3],
    12: [0x00, 0x75, 0x09, 0x00],
    13: [0x02, 0xA5, 0xA6, 0xA7],
    14: [0x70, 0x97, 0x91, 0x97],
    15: [0x00, 0xA5, 0x28, 0x09],
}


def load_page(page):
    fidx = page // 8
    ofs = (page % 8) * 0x400
    with open('rom/chr/chr_%02x.bin' % fidx, 'rb') as f:
        f.seek(ofs)
        return f.read(0x400)


def tile_rows(chunk, t):
    p0 = chunk[t * 16:t * 16 + 8]
    p1 = chunk[t * 16 + 8:t * 16 + 16]
    rows = []
    for row in range(8):
        line = ''
        for col in range(8):
            bit = 7 - col
            px = (p0[row] >> bit) & 1 | (((p1[row] >> bit) & 1) << 1)
            line += ' .o@'[px]
        rows.append(line)
    return rows, any(p0) or any(p1)


only = sys.argv[1] if len(sys.argv) > 1 else ''
out = []
for rec, pages in RECORDS.items():
    if only and str(rec) != only:
        continue
    for slot, page in enumerate(pages):
        chunk = load_page(page)
        base = 0x40 * slot
        out.append("### rec %d slot %d page $%02X (chr_%02x @ $%04X) tiles $%02X-$%02X"
                   % (rec, slot, page, page // 8, (page % 8) * 0x400, base, base + 0x3F))
        for t in range(64):
            rows, nz = tile_rows(chunk, t)
            if not nz:
                continue
            out.append("$%02X:" % (base + t))
            for r in rows:
                out.append('   |%s|' % r)
        out.append('')

with open('output/font_candidate_records.txt', 'w') as f:
    f.write('\n'.join(out))
print('ok', len(out))
