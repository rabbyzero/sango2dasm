#!/usr/bin/env python3
"""Render PRG bank $14 (battle-scene sprite set A) as annotated asm.

Bank $14 is pure data: it is mapped into the $8000-$9FFF window by SwitchBank8
and read by exactly one routine, DrawSpriteFromBank ($CEA5, prg_17_18_duel_and_display.asm):

  - A = sprite id; bit 7 selects the bank (clear -> $34 = this bank, set ->
    $35 = bank $15, the palette/layout mirror), bits 6-0 index a 122-entry
    .word pointer table at $8000 (Y = id*2).
  - For this bank the stored pointer high byte is used as-is
    (HI_OFFSET_A = $00; DrawSpriteFromBank SBCs $00 at $CECC). Bank $15
    stores its pointers with hi + $20 instead.
  - The record pointer lands in $00/$01 and B1F_SpriteOamWriterSimple
    ($F1AD, prg_1f_boot.asm) walks it: 4-byte OAM entries [y_off, tile, attr,
    x_off] until a byte equal to $80. y_off + $000A -> OAM Y, tile +
    $0003 (bias $00) -> OAM tile, attr EOR $0002 (caller flip flags) ->
    OAM attr, x_off + $000C -> OAM X. The writer is entered fresh, so
    $0003 = $00 and the X-clip minimum $0004 = $00 (nothing clipped).
    $000A/$000C are loaded from $04BA/$04BB just before the call.

Every record in this bank is one metasprite: 1-37 entries, all attr bytes
$00 or $40 (OAM palette-select bit). Most attr-$00 families have a
tile-identical attr-$40 sibling record next to them - a second palette of
the same image that callers reach directly instead of through the writer's
flip-flag EOR.

Call-site evidence for the ids (all in prg_17_18_duel_and_display.asm; bases are added to
runtime values, so the ids listed are the fixed bases, not exhaustive):

  $00-$10   MapScroll_UpdatePosition $CEE1 backward scroll: phase 0-7 from
            the frame counter, top pieces from ScrollSpriteTopTable ($CF93:
            $08-$0C), mid pieces from ScrollSpriteMidTable ($CF9B: $0D/$0E)
            plus a player-state offset of 0 or 2
  $11-$21   the same routine's forward scroll: same tables + $11, drawn with
            flip flags $40/$41 + player slot
  $22/$25/$28  StrikeScene_Animate bases
  $43/$4C   StrikeScene_Extra bases
  $5E       FeintScene_Finalize base (+ name_tile_index * 2)
  $6A       MapFade_DrawColumn base (+ name_tile_index * 2)
  (DrawCompletionSprite $D235 draws a dynamic id from $0010; Surrender's
  DrawOfficerCards and the DesperateScene routines use bases >= $80, which
  resolve to bank $15, not this bank.)

Layout (coverage proof: this generator asserts every region tiles exactly):

  $8000-$80F3  SpritePtrTable   - 122 x .word, index = sprite id; stored
               word = absolute record address in the $8000 window
  $80F4-$9F31  SpriteRecords    - 122 metasprites in the
               B1F_SpriteOamWriterSimple format, packed back to back
  $9F32-$9FFF  $FF filler

Usage:
    python tools/gen_data_bank_14_asm.py            # preview on stdout
    python tools/gen_data_bank_14_asm.py --write    # update asm/banks/data_14_sprite_set_a.asm
"""
import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK = 0x14
BANK_BIN = os.path.join('rom', 'prg', 'prg_%02x.bin' % BANK)
from bank_asm_names import data_asm_path               # noqa: E402
ASM_PATH = data_asm_path(BANK, ROOT)

WINDOW_CPU = 0x8000
BANK_SIZE = 0x2000
ROW_BYTES = 16
COMMENT_COL = 43

# sprite id -> caller evidence (fixed bases only; see module docstring)
ID_NOTES = {}
for _i in range(0x00, 0x08):
    ID_NOTES[_i] = 'MapScroll_UpdatePosition backward scroll phase %d' % _i
for _i in range(0x08, 0x0D):
    ID_NOTES[_i] = 'MapScroll backward top piece (ScrollSpriteTopTable $CF93)'
for _i in (0x0D, 0x0E):
    ID_NOTES[_i] = 'MapScroll backward mid piece (ScrollSpriteMidTable $CF9B)'
ID_NOTES[0x0F] = 'MapScroll backward mid piece + player offset 2'
ID_NOTES[0x10] = 'MapScroll backward mid piece + player offset 2'
for _i in range(0x11, 0x19):
    ID_NOTES[_i] = 'MapScroll forward scroll phase %d (backward id $%02X + $11; flip $40/$41+slot)' % (
        _i - 0x11, _i - 0x11)
for _i in range(0x19, 0x1E):
    ID_NOTES[_i] = 'MapScroll forward top piece (ScrollSpriteTopTable + $11)'
for _i in (0x1E, 0x1F):
    ID_NOTES[_i] = 'MapScroll forward mid piece (ScrollSpriteMidTable + $11)'
ID_NOTES[0x20] = 'MapScroll forward mid piece + player offset 2'
ID_NOTES[0x21] = 'MapScroll forward mid piece + player offset 2'
ID_NOTES[0x22] = 'StrikeScene_Animate base +$22'
ID_NOTES[0x25] = 'StrikeScene_Animate base +$25'
ID_NOTES[0x28] = 'StrikeScene_Animate base +$28'
ID_NOTES[0x43] = 'StrikeScene_Extra base +$43'
ID_NOTES[0x4C] = 'StrikeScene_Extra base +$4C'
ID_NOTES[0x5E] = 'FeintScene_Finalize base +$5E (+ name_tile_index * 2)'
ID_NOTES[0x6A] = 'MapFade_DrawColumn base +$6A (+ name_tile_index * 2)'


def read_bank():
    with open(os.path.join(ROOT, BANK_BIN), 'rb') as f:
        return f.read()


def hexb(v):
    return '$%02X' % v


def hexw(v):
    return '$%04X' % v


def parse(data):
    """Split the bank into (ptrs, records). Asserts full coverage."""
    first = data[0] | data[1] << 8
    n = (first - WINDOW_CPU) // 2
    ptrs = [data[2 * i] | data[2 * i + 1] << 8 for i in range(n)]
    for i in range(1, n):
        assert ptrs[i] > ptrs[i - 1], 'ptr %d not increasing' % i
    rec_end = ptrs[-1] - WINDOW_CPU
    off = rec_end
    while data[off] != 0x80:
        off += 4
        assert off < BANK_SIZE, 'last record has no terminator'
    rec_end = off + 1            # first filler offset
    records = []
    for i, p in enumerate(ptrs):
        off = p - WINDOW_CPU
        end = ptrs[i + 1] - WINDOW_CPU if i + 1 < n else rec_end
        ents = []
        while data[off] != 0x80:
            ents.append(tuple(data[off:off + 4]))
            off += 4
            assert off < end, 'record %d overruns next pointer' % i
        assert data[off] == 0x80 and off + 1 == end, (
            'record %d terminator not at next pointer' % i)
        records.append(ents)
    # everything after the last terminator must be $FF filler
    assert all(b == 0xFF for b in data[rec_end:]), 'unexpected tail bytes'
    return ptrs, records, rec_end


def tile_seq(records):
    """sprite id -> list of ids with the same tile sequence (layout twins)."""
    groups = {}
    for i, ents in enumerate(records):
        key = tuple(e[1] for e in ents)
        groups.setdefault(key, []).append(i)
    return {i: g for g in groups.values() if len(g) > 1 for i in g}


def attr40_twin(records):
    """sprite id -> id of the tile-identical attr-$40 sibling, if any."""
    out = {}
    for i, ents in enumerate(records):
        if not all(e[2] == 0x00 for e in ents):
            continue
        for k, q in enumerate(records):
            if len(q) != len(ents):
                continue
            if ([e[1] for e in q] == [e[1] for e in ents]
                    and all(e[2] == 0x40 for e in q)):
                out[i] = k
                break
    return out


def emit_ptr_table(ptrs):
    out = ['',
           '; --- $8000-$80F3  SpritePtrTable: 122 x .word, index = sprite id',
           ';     (bits 6-0 of DrawSpriteFromBank\'s A); stored word = absolute',
           ';     record address in the $8000 window, used as-is (HI_OFFSET_A =',
           ';     $00; bank $15 instead stores its pointers with hi + $20) ---']
    out.append('Bank14SpritePtrTable:')
    for i, p in enumerate(ptrs):
        body = '  .word %s' % ptr_label(i)
        note = 'id %02X -> %s' % (i, hexw(p))
        if i in ID_NOTES:
            note += '  ' + ID_NOTES[i]
        out.append('%s%s; %s' % (body, ' ' * max(1, 43 - len(body)), note))
    return out


def ptr_label(i):
    return 'Bank14Sprite_%02X' % i


def emit_records(data, ptrs, records, rec_end, twins, seq):
    out = ['',
           '; --- $80F4-$9F31  SpriteRecords: 122 metasprites, one per pointer,',
           ';     packed back to back; entry = [y_off, tile, attr, x_off], $80',
           ';     terminates (B1F_SpriteOamWriterSimple format, see banner) ---']
    out.append('Bank14SpriteRecords:')
    for i, ents in enumerate(records):
        off = ptrs[i] - WINDOW_CPU
        end = ptrs[i + 1] - WINDOW_CPU if i + 1 < len(ptrs) else rec_end
        ys = [e[0] for e in ents]
        xs = [e[3] for e in ents]
        ts = [e[1] for e in ents]
        head = '; --- id %s %s-%s (%d B) %d entries: y %s..%s x %s..%s tiles %s..%s' % (
            hexb(i), hexw(ptrs[i]), hexw(WINDOW_CPU + end - 1), end - off,
            len(ents), hexb(min(ys)), hexb(max(ys)), hexb(min(xs)),
            hexb(max(xs)), hexb(min(ts)), hexb(max(ts)))
        if i in ID_NOTES:
            head += '  ' + ID_NOTES[i]
        out.append(head)
        others = [k for k in seq.get(i, []) if k != i]
        if i in twins:
            out.append(';     attr-$40 twin of record %s (same tile sequence)'
                       % ptr_label(twins[i]))
        elif any(all(e[2] == 0x40 for e in records[k]) for k in others):
            out.append(';     attr-$40 sibling(s): %s' %
                       ', '.join(ptr_label(k) for k in others
                                 if all(e[2] == 0x40 for e in records[k])))
        elif others:
            out.append(';     same tile sequence: %s (different x layout)' %
                       ', '.join(ptr_label(k) for k in others))
        out.append('%s:' % ptr_label(i))
        for a in range(off, end, ROW_BYTES):
            vals = data[a:min(a + ROW_BYTES, end)]
            body = '  .byte ' + ', '.join(hexb(v) for v in vals)
            tags = []
            for k in range(0, len(vals), 4):
                if k + 4 <= len(vals):
                    y, t, at, x = vals[k:k + 4]
                    tags.append('y+%02X t%02X a%02X x+%02X' % (y, t, at, x))
                else:
                    tags.append('$80 terminator' if vals[k] == 0x80
                                else 'trailing %02X' % vals[k])
            out.append('%s%s; %s  %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                         hexw(WINDOW_CPU + a), ' | '.join(tags)))
    return out


def emit_filler(data, rec_end):
    out = ['',
           '; --- $9F32-$9FFF  unused ($FF filler) ---']
    for a in range(rec_end, BANK_SIZE, ROW_BYTES):
        chunk = data[a:a + ROW_BYTES]
        body = '  .byte ' + ', '.join(hexb(v) for v in chunk)
        out.append('%s%s; %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                 hexw(WINDOW_CPU + a)))
    return out


def render(data):
    assert len(data) == BANK_SIZE
    ptrs, records, rec_end = parse(data)
    seq = tile_seq(records)
    twins = attr40_twin(records)
    out = [BANNER.rstrip('\n')]
    out.extend(emit_ptr_table(ptrs))
    out.extend(emit_records(data, ptrs, records, rec_end, twins, seq))
    out.extend(emit_filler(data, rec_end))
    return '\n'.join(out)


BANNER = """\
;===============================================================================
; DATA Bank 14 (PRG $14) - 8KB sprite bank (battle-scene set A), mapped into
; $8000-$9FFF by SwitchBank8; no code lives here (see code/bank_switch_map.md
; 5.2).
;
; GENERATED by tools/gen_data_bank_14_asm.py --write; byte-exactness is enforced
; by tools/verify_data_bank_14.py. Raw source: rom/prg/prg_14.bin (read-only) -
; do not hand-edit the rendered records.
;
; Selected as $34 by DrawSpriteFromBank ($CEA5, prg_17_18_duel_and_display): A = sprite id,
; bit 7 picks the bank (clear = $34 / this bank, set = $35 / bank $15) and
; bits 6-0 index the .word table at $8000 (Y = id * 2). The stored pointer
; high byte is used unchanged for this bank (the routine SBCs HI_OFFSET_A =
; $00; bank $15 stores its pointers with hi + $20). The record pointer goes
; to $00/$01 and B1F_SpriteOamWriterSimple ($F1AD, prg_1f_boot) expands it to OAM:
;
;   record = repeated 4-byte entries [y_off, tile, attr, x_off], $80 ends;
;     y_off  + $000A (from $04BA) -> OAM Y   ($0200)
;     tile   + $0003 (bias $00)   -> OAM tile ($0201)
;     attr   EOR $0002 (flip)     -> OAM attr ($0202)
;     x_off  + $000C (from $04BB) -> OAM X   ($0203)
;
; (fresh entry, so the X-clip minimum $0004 is $00 and nothing clips). Every
; attr byte in this bank is $00 or $40 (OAM palette-select bit). Most attr-$00
; families have a tile-identical attr-$40 sibling record - the same image in a
; second palette; callers that flip instead pass flip flags ($0002) and the
; writer's EOR supplies the palette bit at run time (MapScroll's forward path
; passes $40/$41 + player slot).
;
; Caller evidence for the ids (prg_17_18_duel_and_display; fixed bases - runtime adds may reach
; further ids of the same family): $00-$10 MapScroll_UpdatePosition backward
; scroll (phase 0-7 / ScrollSpriteTopTable $CF93 / ScrollSpriteMidTable $CF9B
; + player offset 0/2), $11-$21 its forward scroll (same tables + $11, flip
; $40/$41 + slot), $22/$25/$28 StrikeScene_Animate, $43/$4C StrikeScene_Extra,
; $5E FeintScene_Finalize, $6A MapFade_DrawColumn. DrawCompletionSprite
; ($D235) draws a dynamic id. Bases >= $80 (Surrender's DrawOfficerCards
; $A8/$AD/$C2, the DesperateScene routines $80/$81/$85/$86) carry bit 7 set
; and resolve to bank $15, not this bank.
;
; Regions:
;   $8000-$80F3  Bank14SpritePtrTable   122 x .word, index = sprite id
;   $80F4-$9F31  Bank14SpriteRecords    122 metasprites, packed
;   $9F32-$9FFF  $FF filler
;===============================================================================

.segment "CODE_BANK14"

"""


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--write', action='store_true', help='overwrite asm/banks/data_14_sprite_set_a.asm')
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
