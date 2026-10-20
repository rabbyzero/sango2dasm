#!/usr/bin/env python3
"""Render PRG bank $15 (the battle-sprite / country-map bank) as annotated asm.

Bank $15 is pure data: it is mapped into the $8000-$9FFF window by SwitchBank8
and read by two consumers:

  - prg_17_18_duel_and_display DrawSpriteFromBank ($CEA5): A with bit 7 set selects bank $35.
    Y = (A & $7F) * 2 indexes the .word table at $8000; the stored pointer
    high byte is $20 above the real page (the code does SEC/SBC #$20), so
    blob address = stored word - $2000. The blob is handed to
    B1F_SpriteOamWriterSimple (prg_1f_boot $F1AD), which renders 4-byte entries
    [y_off, tile, attr, x_off] until an entry whose FIRST byte is $80:
      OAM Y    = y_off + $000A   ($000A was loaded from $04BA = Y base)
      OAM tile = tile + $0003    (bias $00 on this path)
      OAM attr = attr EOR $0002  (caller flip flags)
      OAM X    = x_off + $000C   ($000C was loaded from $04BB = X base)
    Entries whose computed Y is below $0004 are skipped. The $000A = Y /
    $000C = X polarity is fixed by the OAM byte layout (writer stores
    b0 -> $0200,X = Y and b3 -> $0203,X = X); several prg_17_18_duel_and_display comments
    name $04BA "X" - they are reversed.
  - prg_1f_boot State_CountryMapView ($E37C): LDY #$35 / SwitchBank8_B ($E38B),
    then B17_18_PpuCopyRaw copies 1 KB from $9A90 to PPU $2000 (the country
    map base nametable image, 960 tile bytes + 64 attribute bytes).

Layout (coverage proof: this generator asserts every region tiles exactly):

  $8000-$80B7  SpriteBlobPtrTable - 92 x .word, index = A & $7F of
               DrawSpriteFromBank; stored word = blob address + $2000;
               strictly increasing, no duplicates
  $80B8-$9A8F  SpriteBlobArea     - the 92 OAM blobs, packed back to back;
               every blob is n x 4 bytes + one $80 terminator (n = 1..40),
               so all 92 boundaries land exactly on terminators
  $9A90-$9E8F  CountryMapScreen   - 1 KB nametable image -> PPU $2000
  $9E90-$9FFF  $FF filler

Usage:
    python tools/gen_data_bank_15_asm.py            # preview on stdout
    python tools/gen_data_bank_15_asm.py --write    # update asm/banks/data_15_sprite_set_b.asm
"""
import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK = 0x15
BANK_BIN = os.path.join('rom', 'prg', 'prg_%02x.bin' % BANK)
from bank_asm_names import data_asm_path               # noqa: E402
ASM_PATH = data_asm_path(BANK, ROOT)

WINDOW_CPU = 0x8000
BANK_SIZE = 0x2000
PTR_BIAS = 0x2000          # stored word = blob address + $2000
TABLE_END = 0x0B8          # 92 entries
SCREEN_OFS = 0x1A90        # exclusive end of the blob area / screen start
SCREEN_END = 0x1E90        # exclusive
ROW_BYTES = 16
COMMENT_COL = 43


def read_bank():
    with open(os.path.join(ROOT, BANK_BIN), 'rb') as f:
        return f.read()


def cpu_ofs(ofs):
    return WINDOW_CPU + ofs


def hexb(v):
    return '$%02X' % v


def hexw(v):
    return '$%04X' % v


def build_plan(data):
    """Read the pointer table and split the blob area.

    Returns (ptrs, blobs): ptrs[i] = file offset of blob i (0x80B8 + ...);
    blobs[i] = dict(ofs, end, entries). Asserts the structural proof the
    decode rests on: strictly increasing pointers, every blob n x 4 + 1
    bytes, exactly one $80 terminator in the first-byte position, and the
    92 blobs tiling $80B8-$9A8F exactly."""
    ptrs = []
    for i in range(TABLE_END // 2):
        lo, hi = data[i * 2], data[i * 2 + 1]
        ptrs.append((lo | (hi << 8)) - PTR_BIAS - WINDOW_CPU)
    for a, b in zip(ptrs, ptrs[1:]):
        assert b > a, 'pointer table not strictly increasing at %04X' % cpu_ofs(b)
    assert ptrs[0] == TABLE_END, (
        'first blob %04X does not start at the table end %04X'
        % (cpu_ofs(ptrs[0]), cpu_ofs(TABLE_END)))
    blobs = []
    for i, ofs in enumerate(ptrs):
        end = ptrs[i + 1] if i + 1 < len(ptrs) else SCREEN_OFS
        seg = data[ofs:end]
        assert len(seg) % 4 == 1, (
            'blob %d len %d at %04X is not n x 4 + 1' % (i, len(seg), cpu_ofs(ofs)))
        assert seg[-1] == 0x80, 'blob %d at %04X does not end in $80' % (i, cpu_ofs(ofs))
        for p in range(0, len(seg) - 1, 4):
            assert seg[p] != 0x80, (
                'blob %d: stray $80 in y position at %04X' % (i, cpu_ofs(ofs + p)))
        blobs.append(dict(ofs=ofs, end=end, entries=(len(seg) - 1) // 4))
    assert blobs[-1]['end'] == SCREEN_OFS
    return ptrs, blobs


def emit_ptr_table(ptrs, blobs):
    out = ['',
           '; --- $8000-$80B7  SpriteBlobPtrTable: 92 x .word, indexed by',
           ';     Y = (A & $7F) * 2 from DrawSpriteFromBank (prg_17_18_duel_and_display $CEA5) with',
           ';     bit 7 of A set; stored word = blob address + $2000 (the code',
           ';     subtracts $20 from the high byte); no index bit 7 clear ever',
           ';     reaches this bank - those read bank $14 ---']
    out.append('SpriteBlobPtrTable:')
    for i in range(len(ptrs)):
        a = i * 2
        body = '  .word SpriteBlob_%02X+$%04X' % (i, PTR_BIAS)
        note = 'idx %02X  word %s -> %s  %d entries' % (
            0x80 + i, hexw(cpu_ofs(ptrs[i]) + PTR_BIAS), hexw(cpu_ofs(ptrs[i])),
            blobs[i]['entries'])
        out.append('%s%s; %s  %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                     hexw(cpu_ofs(i * 2)), note))
    return out


def emit_blobs(data, blobs):
    out = ['',
           '; --- $80B8-$9A8F  SpriteBlobArea: the 92 OAM blobs, packed back to',
           ';     back. Each blob is n x 4-byte sprite entries',
           ';     [y_off, tile, attr, x_off] followed by a $80 terminator in the',
           ';     y position. SpriteOamWriterSimple (prg_1f_boot $F1AD) emits',
           ';     OAM Y = y_off + $000A, OAM tile = tile + $0003,',
           ';     OAM attr = attr EOR $0002 (caller flip flags),',
           ';     OAM X = x_off + $000C; the bases come from $04BA (Y) and',
           ';     $04BB (X) via DrawSpriteFromBank, and entries whose computed Y',
           ';     is below $0004 are skipped ---']
    out.append('SpriteBlobArea:')
    for i, bl in enumerate(blobs):
        out.append('')
        out.append('; --- SpriteBlob_%02X: %s-%s (%d B), %d sprite entries ---' % (
            i, hexw(cpu_ofs(bl['ofs'])), hexw(cpu_ofs(bl['end']) - 1),
            bl['end'] - bl['ofs'], bl['entries']))
        out.append('SpriteBlob_%02X:' % i)
        for e in range(bl['entries']):
            a = bl['ofs'] + e * 4
            body = '  .byte ' + ', '.join(hexb(v) for v in data[a:a + 4])
            out.append('%s%s; %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                     hexw(cpu_ofs(a))))
        out.append('%s%s; %s  terminator' % (
            '  .byte $80', ' ' * (COMMENT_COL - 11),
            hexw(cpu_ofs(bl['end']) - 1)))
    return out


def emit_screen(data):
    out = ['',
           '; --- $9A90-$9E8F  CountryMapScreen: 1 KB nametable image streamed to',
           ';     PPU $2000 by State_CountryMapView (prg_1f_boot $E37C, mapped by',
           ';     LDY #$35 at $E38B) via B17_18_PpuCopyRaw: 960 tile bytes then',
           ';     64 attribute bytes ---']
    out.append('CountryMapScreen:')
    for r in range(30):
        a = SCREEN_OFS + r * 32
        vals = data[a:a + 32]
        body = '  .byte ' + ', '.join(hexb(v) for v in vals)
        out.append('%s%s; %s  row %d' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                         hexw(cpu_ofs(a)), r))
    for r in range(2):
        a = SCREEN_OFS + 960 + r * 32
        vals = data[a:a + 32]
        body = '  .byte ' + ', '.join(hexb(v) for v in vals)
        out.append('%s%s; %s  attr' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                       hexw(cpu_ofs(a))))
    return out


def emit_filler(data):
    out = ['',
           '; --- $9E90-$9FFF  unused ($FF filler) ---']
    for a in range(SCREEN_END, BANK_SIZE, ROW_BYTES):
        chunk = data[a:min(a + ROW_BYTES, BANK_SIZE)]
        body = '  .byte ' + ', '.join(hexb(v) for v in chunk)
        out.append('%s%s; %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                 hexw(cpu_ofs(a))))
    out.append('')
    return out


BANNER = """\
;===============================================================================
; DATA Bank 15 (PRG $15) - 8KB data bank, mapped into $8000-$9FFF by SwitchBank8;
; no code lives here (see code/bank_switch_map.md 5.2).
;
; GENERATED by tools/gen_data_bank_15_asm.py --write; byte-exactness is enforced
; by tools/verify_data_bank_15.py. Raw source: rom/prg/prg_15.bin (read-only) -
; do not hand-edit the rendered records.
;
; Read from two consumers:
;   prg_17_18_duel_and_display  DrawSpriteFromBank $CEA5: A with bit 7 set selects this bank as
;              $35; Y = (A & $7F) * 2 indexes the pointer table at $8000 and
;              the code subtracts $20 from the pointer high byte, so blob
;              address = stored word - $2000 (indices with bit 7 clear read
;              bank $14 instead, whose words are stored unbiased). The blob is
;              rendered by B1F_SpriteOamWriterSimple (prg_1f_boot $F1AD); callers
;              pass the base coordinates in $04BA (Y) / $04BB (X) and the flip
;              flags in $0002.
;   prg_1f_boot     State_CountryMapView $E37C: LDY #$35 / SwitchBank8_B ($E38B),
;              then B17_18_PpuCopyRaw copies 1 KB from $9A90 to PPU $2000.
;
; Regions:
;   $8000-$80B7  SpriteBlobPtrTable   92 x .word, stored word = blob + $2000
;   $80B8-$9A8F  SpriteBlobArea       92 OAM blobs, n x [y,tile,attr,x] + $80
;   $9A90-$9E8F  CountryMapScreen     1 KB nametable image -> PPU $2000
;   $9E90-$9FFF  $FF filler
;
; OAM blob entry format (4 bytes): [y_off, tile, attr, x_off]. The writer adds
; y_off to the $000A Y base, tile to the $0003 tile bias ($00 here), x_off to
; the $000C X base, and EORs attr with the $0002 flip flags; an entry whose
; FIRST byte is $80 terminates the blob (a $80 in byte 1 is a legitimate tile
; id - the terminator is only checked in the y position). The $000A = Y /
; $000C = X polarity follows from the OAM byte layout the writer stores
; (b0 -> $0200,X = Y, b3 -> $0203,X = X); some prg_17_18_duel_and_display comments name $04BA
; "X base" - those are reversed.
;===============================================================================

.segment "CODE_BANK15"
"""


def render(data):
    assert len(data) == BANK_SIZE
    ptrs, blobs = build_plan(data)
    out = [BANNER.rstrip('\n')]
    out.extend(emit_ptr_table(ptrs, blobs))
    out.extend(emit_blobs(data, blobs))
    out.extend(emit_screen(data))
    out.extend(emit_filler(data))
    return '\n'.join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--write', action='store_true', help='overwrite asm/banks/data_15_sprite_set_b.asm')
    args = ap.parse_args()
    text = render(read_bank())
    if args.write:
        with open(ASM_PATH, 'w', encoding='utf-8') as f:
            f.write(text)
        print('wrote %s (%d lines)' % (os.path.relpath(ASM_PATH, ROOT), text.count('\n')))
    else:
        print(text)


if __name__ == '__main__':
    main()
