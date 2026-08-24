#!/usr/bin/env python3
"""Dump ASCII art of the three menu font chunks (chr_00.bin @ 0/0x400/0x800)."""

with open('rom/chr/chr_00.bin', 'rb') as f:
    data = f.read()


def dump_chunk(ofs, base, out):
    chunk = data[ofs:ofs + 0x400]
    for t in range(64):
        p0 = chunk[t * 16:t * 16 + 8]
        p1 = chunk[t * 16 + 8:t * 16 + 16]
        if not any(p0) and not any(p1):
            out.append("$%02X: <blank>" % (base + t))
            continue
        out.append("$%02X:" % (base + t))
        for row in range(8):
            line = ''
            for col in range(8):
                bit = 7 - col
                px = (p0[row] >> bit) & 1 | (((p1[row] >> bit) & 1) << 1)
                line += ' .o@'[px]
            out.append('   |%s|' % line)


out = []
for ofs, base in ((0x0000, 0x00), (0x0400, 0x40), (0x0800, 0x80)):
    out.append("=== chunk @ $%04X (tiles $%02X-$%02X) ===" % (ofs, base, base + 0x3F))
    dump_chunk(ofs, base, out)
    out.append('')

with open('output/font_ascii.txt', 'w') as f:
    f.write('\n'.join(out))
print('ok', len(out), 'lines')
