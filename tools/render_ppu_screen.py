#!/usr/bin/env python3
"""Render a pre-baked PPU screen (nametable image) from a PRG data bank to PNG.

The data banks reachable only through the $8000 window (`SwitchBank8_A/B`,
mapper registers $30-$37) hold whole 1KB nametable images: 960 tile bytes
(30 rows x 32 cols) followed by 64 attribute bytes. `PpuCopyRaw` ($A212,
prg_17_18_display.asm) and `ScenePageCopy` ($BC9B, prg_1d_1e_menu_screens.asm) stream exactly that
many bytes to PPUDATA - see code/initial_data_tables.md §9.

A screen is only recognisable with the CHR pages *and* the palette the game had
loaded for it:

  CHR   `DisplayInit` -> `MenuFontRecordLoad` ($DE7E): bank $21 record table at
        $946C, 48 B/record, bytes 4-7 = NAMCO-163 CHR slots 4-7 = BG tile groups
        $00-3F / $40-7F / $80-BF / $C0-FF (BG pattern table $1000, PPUCTRL mirror
        $008B = $10). Page value V = chr file V//8 at offset (V%8)*$400.
  color `PaletteRecordLoad` ($DBB1, prg_1d_1e_menu_screens.asm) copies a 32-byte palette record
        to $0100, which `PaletteUpload` ($E70E) sends to PPU $3F00. The records
        live in bank $1E at $DBEB (14 entries, index 9 repeats 8).

Usage:
    # the three bank $10 screens (see code/initial_data_tables.md section 9)
    python tools/render_ppu_screen.py --bank 10 --addr 8000 --pages 00 01 02 10 --palette 0
    python tools/render_ppu_screen.py --bank 10 --addr 8400 --pages 8d 8e 8f 90 --palette a
    python tools/render_ppu_screen.py --bank 10 --addr 8800 --pages 88 89 8a 88 --palette 0

    # title screen lives in bank $15 and uses display record 11, palette record $0B
    python tools/render_ppu_screen.py --bank 15 --addr 9a90 --pages a0 a1 a2 a3 --palette b

    # only the $40-7F group matters here, so override just that one page
    python tools/render_ppu_screen.py --bank 10 --addr 8800 --page 89 --group 40

Which CHR record / palette a screen uses is decided by the state proc that
launches it, not by the screen's own name - see tools/scan_ram_writers.py for
finding those callers.

Without --palette the output is grayscale (2bpp levels only), which is still
enough to tell picture from noise while hunting for the right CHR page.
"""
import argparse
import os
import struct
import sys
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CHR_DIR = os.path.join(ROOT, 'rom', 'chr')
WINDOW_CPU = 0x8000
TILE_ROWS = 30
TILE_COLS = 32
TILE_BYTES = TILE_ROWS * TILE_COLS      # 960
ATTR_BYTES = 64                         # 8 rows x 8 cols
LUM = (255, 175, 95, 25)                # 2bpp colour index -> gray

# NES $3F00-$3F3F as RGB (2C02 generic palette).
NES_RGB = (
    (0x60, 0x60, 0x60), (0x00, 0x32, 0x98), (0x00, 0x1a, 0xac), (0x28, 0x00, 0x98),
    (0x54, 0x00, 0x70), (0x74, 0x00, 0x28), (0x68, 0x20, 0x00), (0x44, 0x3c, 0x00),
    (0x1c, 0x50, 0x00), (0x00, 0x5c, 0x00), (0x00, 0x50, 0x28), (0x00, 0x38, 0x58),
    (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xb2, 0xb2, 0xb2), (0x14, 0x80, 0xdb), (0x28, 0x60, 0xff), (0x5c, 0x3c, 0xff),
    (0xa0, 0x28, 0xdc), (0xd0, 0x1c, 0x74), (0xe8, 0x30, 0x28), (0xc0, 0x60, 0x00),
    (0x8c, 0x8c, 0x00), (0x4c, 0xb0, 0x00), (0x14, 0xc8, 0x30), (0x00, 0xc8, 0x78),
    (0x00, 0xb8, 0xd8), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xf0, 0xf4, 0xf8), (0x44, 0xc4, 0xff), (0x68, 0xa8, 0xff), (0xb4, 0x88, 0xff),
    (0xfc, 0x74, 0xf8), (0xfc, 0x74, 0xa0), (0xfc, 0x94, 0x58), (0xe8, 0xb4, 0x00),
    (0xbc, 0xd4, 0x00), (0x88, 0xfc, 0x10), (0x40, 0xfc, 0x4c), (0x00, 0xf8, 0x8c),
    (0x00, 0xe8, 0xe8), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0xf8, 0x00),
    (0xf8, 0xf8, 0xf8), (0xa8, 0xf0, 0xf8), (0xc0, 0xdc, 0xf8), (0xd8, 0xc8, 0xf8),
    (0xf8, 0xb8, 0xf8), (0xf8, 0xb4, 0xd8), (0xf8, 0xc8, 0xb8), (0xf8, 0xd8, 0x78),
    (0xe8, 0xe8, 0x60), (0xc0, 0xf8, 0x78), (0xa8, 0xf8, 0x9c), (0xa8, 0xf8, 0xd8),
    (0xa8, 0xf0, 0xf8), (0xa8, 0xa8, 0xa8), (0xfc, 0xfc, 0xfc), (0x00, 0x00, 0x00),
)

# PaletteRecordLoad @PalRecordPtrTable ($DBCF, prg_1d_1e_menu_screens.asm): CPU address of each
# 32-byte palette record. Bank $1E holds $C000-$FFFF, so file offset = cpu-$C000.
PALETTE_CPU = (
    0xDBEB, 0xDC0B, 0xDC2B, 0xDC4B, 0xDC6B, 0xDC8B, 0xDCAB, 0xDCCB,
    0xDCEB, 0xDCEB, 0xDD0B, 0xDD2B, 0xDD4B, 0xDD6B,
)


def load_palette(index):
    """32 NES colour bytes for palette record index (the $0100 buffer)."""
    path = os.path.join(ROOT, 'rom', 'prg', 'prg_1e.bin')
    with open(path, 'rb') as f:
        f.seek(PALETTE_CPU[index] - 0xC000)
        return f.read(32)


def load_tile(page, idx):
    """8x8 grid of 2-bit colour values for one BG tile of a 1KB CHR page."""
    path = os.path.join(CHR_DIR, 'chr_%02x.bin' % (page // 8))
    with open(path, 'rb') as f:
        f.seek((page % 8) * 0x400 + idx * 16)
        plane0 = f.read(8)
        plane1 = f.read(8)
    return [[((plane0[y] >> (7 - x)) & 1) | (((plane1[y] >> (7 - x)) & 1) << 1)
             for x in range(8)] for y in range(8)]


def render(tiles, attrs, pages, scale, pal):
    cache = {}
    w, h = TILE_COLS * 8 * scale, TILE_ROWS * 8 * scale
    img = [[(255, 255, 255)] * w for _ in range(h)] if pal else \
           [[255] * w for _ in range(h)]
    for row in range(TILE_ROWS):
        for col in range(TILE_COLS):
            t = tiles[row * TILE_COLS + col]
            key = (pages[t >> 6], t & 0x3F)
            bmp = cache.get(key)
            if bmp is None:
                bmp = cache[key] = load_tile(*key)
            # attribute byte: one 2-bit BG palette index per 2x2 tile block
            bgpal = (attrs[(row >> 2) * 8 + (col >> 2)]
                     >> ((row & 2) * 2 + ((col & 2) >> 1) * 2)) & 3
            for y in range(8):
                for x in range(8):
                    ci = bmp[y][x]
                    if pal is None:
                        px = LUM[ci]
                    elif ci == 0:
                        px = NES_RGB[pal[0] & 0x3F]
                    else:
                        px = NES_RGB[pal[1 + 4 * bgpal + ci - 1] & 0x3F]
                    for sy in range(scale):
                        for sx in range(scale):
                            img[(row * 8 + y) * scale + sy][
                                (col * 8 + x) * scale + sx] = px
    return img


def write_png(path, img):
    h, w = len(img), len(img[0])
    rgb = isinstance(img[0][0], tuple)
    rows = []
    for row in img:
        if rgb:
            rows.append(b'\x00' + b''.join(bytes(px) for px in row))
        else:
            rows.append(b'\x00' + bytes(row))

    def chunk(tag, data):
        return (struct.pack('>I', len(data)) + tag + data +
                struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF))
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2 if rgb else 0,
                                      0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(b''.join(rows), 9))
    png += chunk(b'IEND', b'')
    with open(path, 'wb') as f:
        f.write(png)
    return w, h


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--bank', required=True, help='PRG bank number, hex (e.g. 10)')
    ap.add_argument('--addr', required=True, help='CPU address of the tile bytes')
    ap.add_argument('--pages', nargs=4, metavar=('P0', 'P1', 'P2', 'P3'),
                    default=None, help='CHR page per 64-tile BG group')
    ap.add_argument('--page', help='override the CHR page of --group')
    ap.add_argument('--group', default='00', help='tile group the override applies to')
    ap.add_argument('--palette', default=None,
                    help='PaletteRecordLoad palette record index, hex (0-d)')
    ap.add_argument('--scale', type=int, default=3)
    ap.add_argument('--out', default=None,
                    help='output png (default build/screen_<bank>_<addr>.png)')
    args = ap.parse_args()

    bank = int(args.bank, 16)
    addr = int(args.addr, 16)
    pages = [int(p, 16) for p in args.pages] if args.pages else [0] * 4
    if args.page is not None:
        pages[int(args.group, 16) >> 6] = int(args.page, 16)
    pal = None
    if args.palette is not None:
        index = int(args.palette, 16)
        if not 0 <= index < len(PALETTE_CPU):
            raise SystemExit('palette index %s out of range 0-%X'
                             % (args.palette, len(PALETTE_CPU) - 1))
        pal = load_palette(index)

    path = os.path.join(ROOT, 'rom', 'prg', 'prg_%02x.bin' % bank)
    with open(path, 'rb') as f:
        data = f.read()
    off = addr - WINDOW_CPU
    if off + TILE_BYTES + ATTR_BYTES > len(data):
        raise SystemExit('%s: $%04X + 1KB runs past the bank end' % (path, addr))
    out = args.out or os.path.join(ROOT, 'build',
                                   'screen_%02x_%04x%s.png' % (
                                       bank, addr,
                                       '_pal%s' % args.palette if args.palette else ''))
    os.makedirs(os.path.dirname(out), exist_ok=True)
    w, h = write_png(out, render(data[off:off + TILE_BYTES],
                                 data[off + TILE_BYTES:
                                      off + TILE_BYTES + ATTR_BYTES],
                                 pages, args.scale, pal))
    print('%s  %dx%d  bank $%02x $%04X  pages %s  palette %s' % (
        out, w, h, bank, addr, ' '.join('%02X' % p for p in pages),
        args.palette if args.palette is not None else 'gray'))
    return 0


if __name__ == '__main__':
    sys.exit(main())
