#!/usr/bin/env python3
"""Dump PPUTileRender streams for pos 0-14 (PosDataBankTable low range)."""
import os

ROM = os.path.join(os.path.dirname(__file__), '..', 'rom', 'prg_combined.bin')
data = open(ROM, 'rb').read()


def bank_ofs(bank_val, addr):
    return (bank_val & 0x1F) * 0x2000 + (addr - 0x8000)


for pos in range(15):
    tbl = pos * 2 + 0x8000
    for bank_val in (0x32, 0x33):
        o = bank_ofs(bank_val, tbl)
        lo, hi_raw = data[o], data[o + 1]
        for adj in (0x20, 0x40):
            addr = ((hi_raw + adj) & 0xFF) << 8 | lo
            if not (0x8000 <= addr <= 0x9FFF):
                continue
            fo = bank_ofs(bank_val, addr)
            out = []
            i = 0
            while i < 200 and fo + i < len(data):
                b = data[fo + i]
                if b == 0x80:
                    out.append('END')
                    break
                if b == 0x81:
                    out.append('|')
                    i += 1
                elif b == 0x89:
                    out.append(f'<ofs {data[fo+i+1]:02X}>')
                    i += 2
                elif 0x82 <= b <= 0x8F:
                    if b in (0x86,) or 0x8A <= b <= 0x8F:
                        out.append(f'<vram {data[fo+i+1]:02X}{data[fo+i+2]:02X}>')
                        i += 3
                    else:
                        out.append(f'<{b:02X}>')
                        i += 1
                elif 0x90 <= b <= 0x9F:
                    out.append(f'<cmd{b:02X}>')
                    i += 2 if b >= 0x9C else 1
                else:
                    out.append(f'{b:02X}')
                    i += 1
            tiles = [t for t in out if len(t) == 2]
            if tiles:
                print(f'pos {pos:2d} bank{bank_val:X}+{adj:X} ${addr:04X}: '
                      + ' '.join(out))
                print()
