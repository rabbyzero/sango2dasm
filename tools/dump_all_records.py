#!/usr/bin/env python3
"""Dump CHR configs + font stats for all officer-param records ($946C, bank $21)."""

data = open('rom/prg_combined.bin', 'rb').read()
base = 0x346C


def page_stats(page):
    fidx = page // 8
    ofs = (page % 8) * 0x400
    with open('rom/chr/chr_%02x.bin' % fidx, 'rb') as f:
        f.seek(ofs)
        ch = f.read(0x400)
    dens = []
    for t in range(64):
        n = sum(bin(b).count('1') for b in ch[t * 16:t * 16 + 16])
        if n:
            dens.append(n)
    solid = sum(1 for n in dens if n >= 56)
    avg = sum(dens) / len(dens) if dens else 0
    return len(dens), avg, solid


for rec in range(32):
    row = data[base + rec * 48:base + rec * 48 + 8]
    hexs = ' '.join('%02X' % b for b in row)
    bg = row[4:8]
    notes = []
    for slot, page in enumerate(bg):
        n, avg, solid = page_stats(page)
        kind = 'FONT' if (n >= 60 and solid <= 6 and avg < 30) else (
               'FRAME' if solid >= 20 else '?')
        notes.append('s%d:$%02X(%s n%d a%.0f b%d)' % (slot, page, kind, n, avg, solid))
    print('rec %2d: %s | %s' % (rec, hexs, ' '.join(notes)))
