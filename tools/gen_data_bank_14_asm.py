#!/usr/bin/env python3
"""Render PRG bank $14 (Duel Mode scene sprite set A) as annotated asm.

Bank $14 is pure data: it is mapped into the $8000-$9FFF window by SwitchBank8
and read by exactly one routine, DrawSpriteFromBank ($CEA5,
prg_17_18_duel_and_display.asm):

  - A = sprite id; bit 7 selects the bank (clear -> $34 = this bank, set ->
    $35 = bank $15), bits 6-0 index a 122-entry .word pointer table at $8000
    (Y = id*2).
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

PPUCTRL mirror $008B is $10 from boot (bit 4 set, bit 3 clear), so the sprite
pattern table is PPU $0000-$0FFF. DisplayInit($0A) at State_DuelSceneLaunch
($E2F2) loads font/CHR record 10, whose bytes 0-3 are $80/$81/$82/$85: those
are the four 1 KB pages behind OAM tiles $00-$3F/$40-$7F/$80-$BF/$C0-$FF.
Bytes 4-7 ($8D/$8E/$8F/$90) are the BG pattern table ($1000-$1FFF) for the
flat DuelBaseScreen. Palette record $0A supplies the sprite palettes; the
caller flip flags EOR the attr byte, so a flag of $01/$02/$03 also selects
sprite palette 1/2/3.

Every record in this bank is one metasprite: 1-37 entries, all attr bytes
$00 or $40 (OAM bit 6 = horizontal flip). Most attr-$40 records are the
position-mirrored copy of an attr-$00 record, pre-built for the other player.
A record can be addressed by more than one scene layer; the aliases are
emitted as extra labels and listed in the record comment.

Call-site evidence (all in prg_17_18_duel_and_display.asm):

  $00-$21  MapScroll_UpdatePosition $CEE1, the duel-window slide: three
           sprites per frame at one base ($04BA/$04BB). Backward path draws
           frame id 0-7, then ScrollSpriteMidTable ($CF9B) $0D/$0E (+2 for a
           sword officer, name_tile_index $04AF+slot = 2 -> $0F/$10), then
           ScrollSpriteTopTable ($CF93) $08-$0C. Forward path ($CF61) redraws
           the same stack at ids +$11 with flip flags $40/$41+slot. The
           composite is a mounted duelist: horse body, rider, hooves.
  $22-$3F  StrikeScene_Animate $C773 (攻撃): sprite 1 = horse frames $22-$25,
           sprite 2 = rider frames $25-$28, sprite 3 = weapon frames
           $28/$2B/$2E +4 frames per weapon category. The category is
           name_tile_index ($04AF), set by DuelScene_InitOfficers @CalcNameTile
           Variant $B188 from officer record +0A & $1F: >=$10 spear (1),
           >=$08 blade (0), else sword (2). active_player_slot 0 adds $0F,
           selecting the mirrored P0 copies $31-$40.
  $40-$5D  StrikeScene_Extra $C884: sprite 1 = mount at $40-$42 (spear
           officers use $4C-$4E), sprite 2 = impact frames $43/$46/$49 +3 per
           weapon category; P0 copies at +$0F ($4F-$5D).
  $5E-$69  FeintScene_Finalize $C5D2 (牽制): effect frames $5E + 2*category
           + frame; P0 copies at +6 ($64-$69).
  $6A-$75  MapFade_DrawColumn $C2CC: rider frames $6A + 2*category + frame;
           P1 copies at +6 ($70-$75).
  $76-$79  DrawCompletionSprite $D235 fixed-position marks: $76 =
           FeintScene_Finalize, $77/$78 = StrikeScene_Extra, $79 =
           DesperateScene_Extra (bank $15 sprite).

Layout (coverage proof: this generator asserts every region tiles exactly):

  $8000-$80F3  DuelSpriteSetAPtrTable - 122 x .word, index = sprite id; stored
               word = absolute record address in the $8000 window
  $80F4-$9F31  DuelSpriteSetARecords  - 122 metasprites in the
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

SCROLL_TOP = [0x08, 0x09, 0x0A, 0x0A, 0x0B, 0x0C, 0x0B, 0x0B]
SCROLL_MID = [0x0D, 0x0E, 0x0E, 0x0E, 0x0D, 0x0D, 0x0D, 0x0D]
WEAPONS = ('Blade', 'Spear', 'Sword')

# sprite id -> [(label, caller note), ...]. The first entry is the primary
# name (used by the pointer table); further entries are aliases for records
# that a second scene layer also addresses.
ROLES = {}


def add(idx, label, note):
    ROLES.setdefault(idx, []).append((label, note))


def phases_of(table, rec):
    return ', '.join(str(p) for p in range(8) if table[p] == rec)


def promote(idx, label):
    roles = ROLES[idx]
    for n, (lbl, _) in enumerate(roles):
        if lbl == label:
            ROLES[idx] = [roles[n]] + roles[:n] + roles[n + 1:]
            return
    raise KeyError('%s not a role of $%02X' % (label, idx))


def build_roles():
    # --- Map scroll / duel-window slide ($00-$21) ---
    for p in range(8):
        add(0x00 + p, 'DuelScrollBackHorse%d' % p,
            'MapScroll_UpdatePosition backward sprite 1, frame %d' % p)
    for i in range(5):
        add(0x08 + i, 'DuelScrollBackRider%d' % i,
            'MapScroll_UpdatePosition backward sprite 3 (ScrollSpriteTopTable), '
            'frames %s' % phases_of(SCROLL_TOP, 0x08 + i))
    for i in range(2):
        add(0x0D + i, 'DuelScrollBackHoof%d' % i,
            'MapScroll_UpdatePosition backward sprite 2 (ScrollSpriteMidTable), '
            'frames %s' % phases_of(SCROLL_MID, 0x0D + i))
        add(0x0F + i, 'DuelScrollBackHoofSword%d' % i,
            'MapScroll_UpdatePosition backward sprite 2 for sword officers '
            '(ScrollSpriteMidTable + 2 when name_tile_index is 2), frames %s'
            % phases_of(SCROLL_MID, 0x0D + i))
    for p in range(8):
        add(0x11 + p, 'DuelScrollForwardHorse%d' % p,
            'MapScroll_UpdatePosition forward sprite 1, frame %d (flip $40/$41+slot)' % p)
    for i in range(5):
        add(0x19 + i, 'DuelScrollForwardRider%d' % i,
            'MapScroll_UpdatePosition forward sprite 3 (ScrollSpriteTopTable + $11), '
            'frames %s' % phases_of(SCROLL_TOP, 0x08 + i))
    for i in range(2):
        add(0x1E + i, 'DuelScrollForwardHoof%d' % i,
            'MapScroll_UpdatePosition forward sprite 2 (ScrollSpriteMidTable + $11), '
            'frames %s' % phases_of(SCROLL_MID, 0x0D + i))
        add(0x20 + i, 'DuelScrollForwardHoofSword%d' % i,
            'MapScroll_UpdatePosition forward sprite 2 for sword officers '
            '(ScrollSpriteMidTable + $13 when name_tile_index is 2), frames %s'
            % phases_of(SCROLL_MID, 0x0D + i))

    # --- Strike scene, player 1 and player 0 ($22-$3F) ---
    for p in range(4):
        add(0x22 + p, 'StrikeP1Horse%d' % p,
            'StrikeScene_Animate sprite 1 (horse), frame %d' % p)
    for p in range(4):
        add(0x25 + p, 'StrikeP1Rider%d' % p,
            'StrikeScene_Animate sprite 2 (rider), frame %d' % p)
    for p in range(4):
        add(0x31 + p, 'StrikeP0Horse%d' % p,
            'StrikeScene_Animate sprite 1 (horse), active_player_slot 0 base +$0F, frame %d' % p)
    for p in range(4):
        add(0x34 + p, 'StrikeP0Rider%d' % p,
            'StrikeScene_Animate sprite 2 (rider), active_player_slot 0 base +$0F, frame %d' % p)
    for cat, weapon in enumerate(WEAPONS):
        for p in range(4):
            add(0x28 + 3 * cat + p, 'StrikeP1%s%d' % (weapon, p),
                'StrikeScene_Animate sprite 3 (%s frames), frame %d' % (weapon.lower(), p))
            add(0x37 + 3 * cat + p, 'StrikeP0%s%d' % (weapon, p),
                'StrikeScene_Animate sprite 3 (%s frames), active_player_slot 0 base +$0F, frame %d'
                % (weapon.lower(), p))

    # --- Strike scene extra ($40-$5D) ---
    for p in range(3):
        add(0x40 + p, 'StrikeExtraP1Mount%d' % p,
            'StrikeScene_Extra sprite 1 (mount), blade/sword officers, frame %d' % p)
        add(0x4F + p, 'StrikeExtraP0Mount%d' % p,
            'StrikeScene_Extra sprite 1 (mount), active_player_slot 0 base +$0F, frame %d' % p)
        add(0x4C + p, 'StrikeExtraP1MountSpear%d' % p,
            'StrikeScene_Extra sprite 1 (mount), spear officers, frame %d' % p)
        add(0x5B + p, 'StrikeExtraP0MountSpear%d' % p,
            'StrikeScene_Extra sprite 1 (mount), spear officers, active_player_slot 0 base +$0F, frame %d' % p)
    for cat, weapon in enumerate(WEAPONS):
        for p in range(3):
            add(0x43 + 3 * cat + p, 'StrikeExtraP1%s%d' % (weapon, p),
                'StrikeScene_Extra sprite 2 (%s impact), frame %d' % (weapon.lower(), p))
            add(0x52 + 3 * cat + p, 'StrikeExtraP0%s%d' % (weapon, p),
                'StrikeScene_Extra sprite 2 (%s impact), active_player_slot 0 base +$0F, frame %d'
                % (weapon.lower(), p))
    promote(0x40, 'StrikeExtraP1Mount0')   # also P0 Sword3

    # --- Feint finalize ($5E-$69) ---
    for slot, base in (('P1', 0x5E), ('P0', 0x64)):
        for cat, weapon in enumerate(WEAPONS):
            for p in range(2):
                add(base + 2 * cat + p, 'Feint%s%s%d' % (slot, weapon, p),
                    'FeintScene_Finalize effect (%s), frame %d, active_player_slot %s'
                    % (weapon.lower(), p, slot[1]))

    # --- Map fade ($6A-$75) ---
    for slot, base in (('P0', 0x6A), ('P1', 0x70)):
        for cat, weapon in enumerate(WEAPONS):
            for p in range(2):
                add(base + 2 * cat + p, 'MapFade%s%s%d' % (slot, weapon, p),
                    'MapFade_DrawColumn rider (%s), frame %d, active_player_slot %s'
                    % (weapon.lower(), p, slot[1]))

    # --- Completion marks ($76-$79) ---
    add(0x76, 'DuelCompletionMarkFeint', 'DrawCompletionSprite from FeintScene_Finalize')
    add(0x77, 'DuelCompletionMarkStrike0',
        'DrawCompletionSprite from StrikeScene_Extra, blade/sword officers')
    add(0x78, 'DuelCompletionMarkStrike1',
        'DrawCompletionSprite from StrikeScene_Extra, spear officers')
    add(0x79, 'DuelCompletionMarkDesperate',
        'DrawCompletionSprite from DesperateScene_Extra (bank $15 sprite)')

    missing = [i for i in range(0x7A) if i not in ROLES]
    assert not missing, 'unlabelled sprite ids: %s' % missing
    assert max(ROLES) == 0x79


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


def ptr_label(i):
    return ROLES[i][0][0]


def emit_ptr_table(ptrs):
    out = ['',
           '; --- $8000-$80F3  DuelSpriteSetAPtrTable: 122 x .word, index =',
           ';     sprite id (bits 6-0 of DrawSpriteFromBank\'s A); stored word =',
           ';     absolute record address in the $8000 window, used as-is',
           ';     (HI_OFFSET_A = $00; bank $15 instead stores hi + $20) ---']
    out.append('DuelSpriteSetAPtrTable:')
    for i, p in enumerate(ptrs):
        body = '  .word %s' % ptr_label(i)
        note = 'id %02X -> %s  %s' % (i, hexw(p), ROLES[i][0][1])
        out.append('%s%s; %s' % (body, ' ' * max(1, 43 - len(body)), note))
    return out


def emit_records(data, ptrs, records, rec_end, twins, seq):
    out = ['',
           '; --- $80F4-$9F31  DuelSpriteSetARecords: 122 metasprites, one per',
           ';     pointer, packed back to back; entry = [y_off, tile, attr, x_off],',
           ';     $80 terminates (B1F_SpriteOamWriterSimple format, see banner) ---']
    out.append('DuelSpriteSetARecords:')
    for i, ents in enumerate(records):
        off = ptrs[i] - WINDOW_CPU
        end = ptrs[i + 1] - WINDOW_CPU if i + 1 < len(ptrs) else rec_end
        ys = [e[0] for e in ents]
        xs = [e[3] for e in ents]
        ts = [e[1] for e in ents]
        roles = ROLES[i]
        head = '; --- id %s %s-%s (%d B) %d entries: y %s..%s x %s..%s tiles %s..%s' % (
            hexb(i), hexw(ptrs[i]), hexw(WINDOW_CPU + end - 1), end - off,
            len(ents), hexb(min(ys)), hexb(max(ys)), hexb(min(xs)),
            hexb(max(xs)), hexb(min(ts)), hexb(max(ts)))
        out.append(head)
        out.append(';     %s' % roles[0][1])
        for label, note in roles[1:]:
            out.append(';     also %s: %s' % (label, note))
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
        for label, _ in roles:
            out.append('%s:' % label)
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
    build_roles()
    out = [BANNER.rstrip('\n')]
    out.extend(emit_ptr_table(ptrs))
    out.extend(emit_records(data, ptrs, records, rec_end, twins, seq))
    out.extend(emit_filler(data, rec_end))
    return '\n'.join(out)


BANNER = """\
;===============================================================================
; DATA Bank 14 (PRG $14) - 8KB Duel Mode scene sprite bank (set A), mapped
; into $8000-$9FFF by SwitchBank8; no code lives here (see
; code/bank_switch_map.md 5.2).
;
; GENERATED by tools/gen_data_bank_14_asm.py --write; byte-exactness is enforced
; by tools/verify_data_bank_14.py. Raw source: rom/prg/prg_14.bin (read-only) -
; do not hand-edit the rendered records.
;
; Selected as $34 by DrawSpriteFromBank ($CEA5, prg_17_18_duel_and_display):
; A = sprite id, bit 7 picks the bank (clear = $34 / this bank, set = $35 /
; bank $15) and bits 6-0 index the .word table at $8000 (Y = id * 2). The
; stored pointer high byte is used unchanged for this bank (the routine SBCs
; HI_OFFSET_A = $00; bank $15 stores its pointers with hi + $20). The record
; pointer goes to $00/$01 and B1F_SpriteOamWriterSimple ($F1AD, prg_1f_boot)
; expands it to OAM:
;
;   record = repeated 4-byte entries [y_off, tile, attr, x_off], $80 ends;
;     y_off  + $000A (from $04BA) -> OAM Y   ($0200)
;     tile   + $0003 (bias $00)   -> OAM tile ($0201)
;     attr   EOR $0002 (flip)     -> OAM attr ($0202)
;     x_off  + $000C (from $04BB) -> OAM X   ($0203)
;
; PPUCTRL mirror $008B is $10 from boot: bit 4 set = BG pattern table $1000,
; bit 3 clear = SPRITE pattern table $0000. DisplayInit($0A) at
; State_DuelSceneLaunch ($E2F2) loads menu/CHR record 10, bytes 0-3 =
; $80/$81/$82/$85 (sprites, OAM tiles $00-$3F/$40-$7F/$80-$BF/$C0-$FF) and
; bytes 4-7 = $8D/$8E/$8F/$90 (BG for DuelBaseScreen). Palette record $0A
; supplies the sprite palettes; caller flip flags EOR the attr byte, so
; $01/$02/$03 also select sprite palette 1/2/3.
;
; Every scene layer draws at one base ($04BA/$04BB). The families below name
; the composite parts; the record comments list all addressing layers.
; Weapon categories come from name_tile_index ($04AF), set by
; DuelScene_InitOfficers @CalcNameTileVariant ($B188) from officer record +0A
; & $1F: >= $10 spear (1), >= $08 blade (0), else sword (2).
;
;   $00-$21  MapScroll_UpdatePosition ($CEE1) duel-window slide: horse body,
;            rider and hooves, backward (ids $00-$10) and forward (+$11,
;            flip $40/$41+slot) stacks.
;   $22-$3F  StrikeScene_Animate ($C773, attack): horse, rider and per-weapon
;            frames; active_player_slot 0 adds $0F (P0 copies $31-$3F).
;   $40-$5D  StrikeScene_Extra ($C884): mount + per-weapon impact frames, P0
;            copies at +$0F.
;   $5E-$69  FeintScene_Finalize ($C5D2): per-weapon effect frames; P0 copies
;            at +6.
;   $6A-$75  MapFade_DrawColumn ($C2CC): per-weapon rider frames; P1 copies
;            at +6.
;   $76-$79  DrawCompletionSprite ($D235) fixed-position marks.
;
; Regions:
;   $8000-$80F3  DuelSpriteSetAPtrTable   122 x .word, index = sprite id
;   $80F4-$9F31  DuelSpriteSetARecords    122 metasprites, packed
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
