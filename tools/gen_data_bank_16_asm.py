#!/usr/bin/env python3
"""Render PRG bank $16 (the command-menu OAM blob bank) as annotated asm.

Bank $16 is pure data: it is mapped into the $8000-$9FFF window by SwitchBank8_B
and read by two consumers:

  - prg_1d_1e_menu_screens @render_menu ($BE6A): LDY #$36 / B1F_SwitchBank8_B, then
    B1F_CallbackDispatcher on $04A2 through @menu_dispatch_table ($BE75, 35
    entries MenuAction00_SortieResult .. MenuAction22_WindowTeardown). Each handler's
    load phase sets tile_ptr ($0010/$0011) to one of the 34 .word tables in
    this bank, loads an index into Y from $04A1 (or $04A4 for the second of a
    two-pointer handler), and calls DisplayTileData ($C994, prg_1d_1e_menu_screens):
    DEY / ASL, word at ($10),Y -> $0000 (lo), high byte SEC/SBC #$40 -> $0001,
    i.e. blob address = stored word - $4000 (the stored word is blob + $4000 -
    the OPPOSITE polarity of bank $12, whose CalcMenuDataPtr ADDS $40 to a word
    stored as addr - $4000). DisplayTileData then sets $000A = $2F (OAM Y
    base), $000C = X base ($20, or $90 when $0150 bit 7 is set) and $0002 = 3
    (flip/attr EOR) and JMPs B1F_SpriteOamWriterSimple ($F1AD, prg_1f_boot), which
    walks [y,tile,attr,x] quads (OAM Y $0200,X = y + $000A; X $0203,X =
    x + $000C; attr EOR $0002; tile bias $0003 = 0) up to a leading $80 byte.
  - prg_1f_boot State_EventMessageScene ($E477): LDY #$36 / SwitchBank8_B, then
    B17_18_PpuCopyRaw streams 1 KB from $9B92 to PPU $2000 (the event-message
    scene background nametable image, 960 tile bytes + 64 attribute bytes).

Layout (coverage proof: this generator asserts every region tiles exactly):

  $8000-$9B91  34 per-handler .word pointer tables interleaved with their 130
               $80-terminated OAM sprite blobs, back to back with no gaps;
               entry counts 1-6 per table (index = $04A1/$04A4 - 1)
  $9B92-$9F91  EventMessageSceneScreen - 1 KB nametable image for PPU $2000
  $9F92-$9FFF  $FF filler

Usage:
    python tools/gen_data_bank_16_asm.py            # preview on stdout
    python tools/gen_data_bank_16_asm.py --write    # update asm/banks/data_16_menu_oam.asm
"""
import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK = 0x16
BANK_BIN = os.path.join('rom', 'prg', 'prg_%02x.bin' % BANK)
from bank_asm_names import data_asm_path               # noqa: E402
ASM_PATH = data_asm_path(BANK, ROOT)

WINDOW_CPU = 0x8000
BANK_SIZE = 0x2000
PTR_BIAS = 0x4000          # blob address = stored word - $4000
DATA_END = 0x9B92          # exclusive: last blob terminator byte at $9B91
SCREEN_CPU = 0x9B92
SCREEN_END = 0x9F92        # exclusive
FILLER_CPU = 0x9F92
ROW_BYTES = 16
COMMENT_COL = 74

# table address -> enclosing dispatch entry (menu_dispatch_table $BE75 entry id).
# Entry counts are DERIVED from the binary (count = (first blob - table)/2) and
# cross-checked against the handler index bounds in prg_1d_1e_menu_screens.asm where the
# index source is static (e.g. MenuAction02 LDY #$01; MenuAction03's
# $04A1 = 1-2 / $04A4 = 3-4; MenuAction01's @MenuAction01_RowTable 1-4;
# MenuAction08's $04A4 = 3-5). The exact-tile assertion below rejects any wrong
# count, since a wrong count leaves a gap or an overlap.
TABLES = [
    ('MenuAction00_SortieResult', 0x8000, 2),
    ('MenuAction01_AcademyResult', 0x80F6, 4),
    ('MenuAction02_SaveGameResult', 0x8172, 1),
    ('MenuAction03_DiscordResult', 0x81CD, 4),
    ('MenuAction04_WarRulerCard', 0x8239, 2),
    ('MenuAction05_WarRivalRulerCard', 0x82A7, 4),
    ('MenuAction06_DisasterPreventionResult', 0x8383, 3),
    ('MenuAction07_ArmoryResult', 0x8454, 3),
    ('MenuAction08_WarOutbreakNotice', 0x8559, 5),
    ('MenuAction09_LandReclamationResult0A', 0x863C, 4),
    ('MenuAction0A_LandReclamationResult0B', 0x8760, 3),
    ('MenuAction0B_CivilianReliefResult', 0x87D1, 4),
    ('MenuAction0C_HospitalResult', 0x88D5, 6),
    ('MenuAction0D_LandReclamationResult0E', 0x89B7, 5),
    ('MenuAction0E_TownDevelopmentResult0F', 0x8A52, 5),
    ('MenuAction0F_IndustryAndTownResult10', 0x8B55, 6),
    ('MenuAction10_OfficerTransferResult', 0x8C03, 5),
    ('MenuAction11_IndustryDevelopmentResult12', 0x8D2E, 3),
    ('MenuAction12_PoachingResult', 0x8E37, 6),
    ('MenuAction13_IndustryDevelopmentResult14', 0x8EDD, 2),
    ('MenuAction14_LandAndIndustryResult15', 0x8F6B, 4),
    ('MenuAction15_IndustryAndTownResult16', 0x9077, 3),
    ('MenuAction16_OfficerGiftResult', 0x9140, 4),
    ('MenuAction17_IndustryAndTownResult18', 0x91DC, 4),
    ('MenuAction18_AllianceResult', 0x92A0, 6),
    ('MenuAction19_ConscriptionResult', 0x9342, 3),
    ('MenuAction1A_IntelligenceGatheringResult', 0x9477, 6),
    ('MenuAction1B_DroughtDamageWindow', 0x9691, 6),
    ('MenuAction1C_RiceHarvestWindow', 0x9733, 2),
    ('MenuAction1D_FloodDamageWindow', 0x9769, 2),
    ('MenuAction1E_RebellionWindow', 0x981F, 4),
    ('MenuAction1F_TaxCollectionWindow', 0x9893, 4),
    ('MenuAction20_MarketPanel', 0x99DF, 3),
    ('MenuAction21_SupplyTransportResult', 0x9AE4, 2),
]
BLOB_RECORD_BYTES = 4
BLOB_TERMINATOR = 0x80


def read_bank():
    with open(os.path.join(ROOT, BANK_BIN), 'rb') as f:
        return f.read()


def cpu_ofs(ofs):
    return WINDOW_CPU + ofs


def hexb(v):
    return '$%02X' % v


def hexw(v):
    return '$%04X' % v


def word(data, ofs):
    return data[ofs] | (data[ofs + 1] << 8)


def walk_blob(data, ofs):
    """One $80-terminated blob -> ([4-byte records], end offset (exclusive))."""
    recs = []
    i = ofs
    while True:
        if i >= BANK_SIZE:
            raise AssertionError('blob at %s never terminates' % hexw(cpu_ofs(ofs)))
        if data[i] == BLOB_TERMINATOR:
            return recs, i + 1
        recs.append(tuple(data[i:i + BLOB_RECORD_BYTES]))
        i += BLOB_RECORD_BYTES


def build_plan(data):
    """Chase every table word to its blob; assert the tables + blobs tile
    $8000-$9B92 exactly. Returns entries = [(handler, tab, [(word, recs,
    start, end), ...]), ...]."""
    covered = bytearray(BANK_SIZE)
    entries = []
    for name, tab, count in TABLES:
        tofs = tab - WINDOW_CPU
        w0 = word(data, tofs)
        b0 = w0 - PTR_BIAS
        derived = (b0 - tab) // 2
        assert (b0 - tab) % 2 == 0 and derived == count, (
            '%s: derived entry count %d != expected %d' % (name, derived, count))
        blobs = []
        for e in range(count):
            w = word(data, tofs + 2 * e)
            start = w - PTR_BIAS
            assert WINDOW_CPU <= start < DATA_END, (
                '%s entry %d: word %s -> out-of-window blob %s'
                % (name, e, hexw(w), hexw(start)))
            recs, end = walk_blob(data, start - WINDOW_CPU)
            blobs.append(dict(word=w, recs=recs, start=start, end=cpu_ofs(end)))
            for i in range(start - WINDOW_CPU, end):
                assert not covered[i], 'overlap at %s' % hexw(cpu_ofs(i))
                covered[i] = 1
        for i in range(tofs, tofs + 2 * count):
            assert not covered[i], 'overlap at %s' % hexw(cpu_ofs(i))
            covered[i] = 1
        entries.append(dict(name=name, tab=tab, count=count, blobs=blobs))
    for i in range(0, DATA_END - WINDOW_CPU):
        assert covered[i], 'gap at %s' % hexw(cpu_ofs(i))
    return entries


def line(directive, operands, addr, emitted, note=None):
    head = '  %s %s' % (directive, operands)
    comment = '; %s: %s' % (hexw(addr), ' '.join('%02X' % b for b in emitted))
    if note:
        comment += '  ; ' + note
    return head + ' ' * max(1, COMMENT_COL - len(head)) + comment


def byte_line(addr, bs, note=None):
    return line('.byte', ', '.join(hexb(b) for b in bs), addr, bs, note)


def span_of(values):
    vals = list(values)
    return '%s-%s' % (hexb(min(vals)), hexb(max(vals)))


def emit_tables(data, entries):
    out = ['',
           '; --- $8000-$9B91  MenuOam area: 34 x .word pointer tables (one per',
           ';     MenuAction dispatch entry) interleaved with their 130 blobs;',
           ';     stored word = blob address + $4000 (DisplayTileData\'s SEC/SBC #$40',
           ';     on the high byte undoes it; bank $12 biases the other way) ---']
    all_recs = [r for e in entries for b in e['blobs'] for r in b['recs']]
    out.append(';     Blob geometry over all %d records: y_off %s (screen Y = y_off +'
               % (len(all_recs), span_of(r[0] for r in all_recs)))
    out.append(';     $2F), x_off %s (screen X = x_off + $20 left panel / $90 right'
               % span_of(r[3] for r in all_recs))
    out.append(';     panel), tile %s, attr %s (EOR $03 flip/flags).'
               % (span_of(r[1] for r in all_recs),
                  ', '.join(hexb(a) for a in sorted(set(r[2] for r in all_recs)))))
    for e in entries:
        out.append('')
        out.append('; --- %s: %d x .word @ %s, indexed via DisplayTileData'
                   % (e['name'], e['count'], hexw(e['tab'])))
        out.append(';     (Y = $04A1 or $04A4, table index = Y - 1) ---')
        out.append('MenuOamPtrTable_%02X:' % (int(e['name'][10:12], 16),))
        for i, b in enumerate(e['blobs']):
            out.append(line('.word', 'MenuOam_%02X_%d+$%04X'
                            % (int(e['name'][10:12], 16), i, PTR_BIAS),
                            e['tab'] + 2 * i,
                            [b['word'] & 0xFF, b['word'] >> 8],
                            'entry %d -> blob %s, %d records'
                            % (i, hexw(b['start']), len(b['recs']))))
        for i, b in enumerate(e['blobs']):
            term = b['end'] - 1
            bs = data[b['start'] - WINDOW_CPU:term - WINDOW_CPU + 1]
            out.append('')
            out.append('; blob entry %d (@%s): %d [y,tile,attr,x] records, %s terminator @ %s'
                       % (i, hexw(b['start']), len(b['recs']),
                          hexb(BLOB_TERMINATOR), hexw(term)))
            out.append('MenuOam_%02X_%d:' % (int(e['name'][10:12], 16), i))
            for off in range(0, len(bs), ROW_BYTES):
                chunk = bs[off:off + ROW_BYTES]
                note = ('terminator %s' % hexb(BLOB_TERMINATOR)
                        if off and chunk[-1] == BLOB_TERMINATOR else None)
                out.append(byte_line(b['start'] + off, chunk, note))
    return out


def emit_screen(data):
    out = ['',
           '; --- $9B92-$9F91  EventMessageSceneScreen: 1 KB nametable image streamed',
           ';     to PPU $2000 by State_EventMessageScene (prg_1f_boot $E477) via',
           ';     B17_18_PpuCopyRaw: 960 tile bytes then 64 attribute bytes.',
           ';     No decodable text: display mode 13 (DisplayInit $E474) loads font',
           ';     record 13, whose slots map tiles to chr_00/$0400 and chr_14 window',
           ';     graphics, and every row is window frame/interior tiles (the few',
           ';     $95-$9A tiles on rows 14-15 are frame ornaments). The actual event',
           ';     message prose is VM stream text in banks $12/$13 (DroughtNewsMsg,',
           ';     FloodOutbreakMsg, RebellionNewsMsg, ... there) ---']
    out.append('EventMessageSceneScreen:')
    for r in range(30):
        a = SCREEN_CPU + r * 32 - WINDOW_CPU
        vals = data[a:a + 32]
        out.append(byte_line(cpu_ofs(a), vals, 'tile row %d' % r))
    out.append('EventMessageSceneScreenAttr:')
    for r in range(8):
        a = SCREEN_CPU + 960 + r * 8 - WINDOW_CPU
        vals = data[a:a + 8]
        out.append(byte_line(cpu_ofs(a), vals,
                             'attr row %d (tile rows %d-%d)'
                             % (r, r * 4, min(r * 4 + 3, 29))))
    return out


def emit_filler(data):
    out = ['',
           '; --- $9F92-$9FFF  unused ($FF filler, %d B) ---' % (BANK_SIZE - 0x1F92)]
    out.append('  .res $%04X, $FF' % (BANK_SIZE - (FILLER_CPU - WINDOW_CPU)))
    out.append('')
    return out


def render(data):
    assert len(data) == BANK_SIZE
    assert all(b == 0xFF for b in data[FILLER_CPU - WINDOW_CPU:]), \
        'tail $9F92-$9FFF is not uniform $FF'
    entries = build_plan(data)
    n_words = sum(e['count'] for e in entries)
    n_blobs = sum(len(e['blobs']) for e in entries)
    n_recs = sum(len(b['recs']) for e in entries for b in e['blobs'])
    out = [BANNER % dict(words=n_words, blobs=n_blobs, recs=n_recs)]
    out.extend(emit_tables(data, entries))
    out.append('')
    out.append('.endproc')
    out.extend(emit_screen(data))
    out.extend(emit_filler(data))
    return '\n'.join(out)


BANNER = """\
;===============================================================================
; DATA Bank 16 (PRG $16) - 8KB command-menu OAM blob bank, mapped into
; $8000-$9FFF by SwitchBank8; no code lives here (see code/bank_switch_map.md 5.2).
;
; GENERATED by tools/gen_data_bank_16_asm.py --write; byte-exactness and the
; exact-tile coverage are enforced by tools/verify_data_bank_16.py. Raw source:
; rom/prg/prg_16.bin (read-only) - do not hand-edit the rendered records.
;
; Selected as $36 from two consumers:
;   prg_1d_1e_menu_screens  @render_menu $BE6A: LDY #$36 / B1F_SwitchBank8_B, then
;              B1F_CallbackDispatcher on $04A2 through @menu_dispatch_table
;              $BE75 (35 entries MenuAction00_SortieResult ..
;              MenuAction22_WindowTeardown). Each load phase sets tile_ptr
;              ($0010/$0011) to one of the 34 .word tables below, loads Y from
;              $04A1 (or $04A4 for the second pointer of a two-pointer
;              handler) and calls DisplayTileData ($C994): DEY/ASL, word at
;              ($10),Y -> $0000 lo, high byte SEC/SBC #$40 -> $0001, so blob
;              address = stored word - $4000 (stored word = blob + $4000; the
;              OPPOSITE polarity of bank $12, whose CalcMenuDataPtr ADDS $40 to
;              a word stored as addr - $4000). DisplayTileData then sets
;              $000A = $2F (OAM Y base), $000C = $20 X base ($90 when $0150
;              bit 7 is set - right-panel render) and $0002 = 3 (attr EOR) and
;              JMPs B1F_SpriteOamWriterSimple ($F1AD, prg_1f_boot), which walks
;              [y,tile,attr,x] quads (OAM Y $0200,X = y + $000A; X $0203,X =
;              x + $000C; attr EOR $0002; tile bias $0003 = 0) up to a leading
;              $80 terminator.
;   prg_1f_boot     State_EventMessageScene $E477: LDY #$36 / SwitchBank8_B, then
;              B17_18_PpuCopyRaw copies 1 KB from $9B92 to PPU $2000.
;
; Regions:
;   $8000-$9B91  MenuOam area: %(words)d x .word in 34 per-handler tables
;                (1-6 entries each) interleaved with %(blobs)d
;                $80-terminated blobs (%(recs)d [y,tile,attr,x] records)
;   $9B92-$9F91  EventMessageSceneScreen  1 KB nametable image -> PPU $2000
;   $9F92-$9FFF  $FF filler
;
; The 34 tables and their blobs tile $8000-$9B92 with no gaps or overlaps:
; each table's first blob starts immediately after its last .word, each blob
; terminates on $80, and the last blob ends exactly at the screen. Entry
; counts are derived from that tiling and match the handler index bounds
; wherever they are statically checkable in prg_1d_1e_menu_screens.asm (MenuAction02's
; LDY #$01, MenuAction01's @MenuAction01_RowTable 1-4, MenuAction03/05's
; $04A1 = 1-2 + $04A4 = 3-4, MenuAction08's $04A4 = 3-5).
;
; Blob geometry over all records: y_off $00-$48 (screen OAM Y $2F-$77),
; x_off $00-$48 (screen X $20-$68 on the left panel, $B0-$D8 when the X base
; is $90), tile $40-$FF, attr $00/$01/$28 (EOR'd with the caller's $02 = 3).
; Sprites are always 8x8: no writer ever sets PPUCTRL bit 5 ($008B is only
; ever $10, ORA #$80 / AND #$7F / scroll-bit updates). Tile decode pages:
; the MenuActions run under State_StrategyMode (prg_1f_boot $E27E), whose
; DisplayInit A=$04 loads font record 4 (7C 7D 7D 04 ...), so sprite slots
; 0-3 = pages $7C/$7D/$7D/$04: tiles $40-$BF land on $7D (chr_0f @ $1400,
; the command-scene icon sheet - carts, structures, banners, cursors,
; rendered coherently with color 0 transparent); the sparse tiles $C0-$FF
; (37 records) land on $04 (chr_00 @ $1000, the equipment-kanji page, whose
; glyph cells store strokes in color 0 = transparent for sprites).
; No text: no record's sprite slots ever map to a kana page ($70/$78), and
; the 1 KB screen at the end of the bank is a window frame (see below).
;===============================================================================

.segment "CODE_BANK16"

; Bank-16 labels are scoped: the generated files of the other data banks must
; stay free to reuse the generic MenuOam* vocabulary (cf. data_13_menu_display.asm's
; Bank13MenuStreams scope).

.proc Bank16MenuOamData
"""


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--write', action='store_true', help='overwrite asm/banks/data_16_menu_oam.asm')
    args = ap.parse_args()
    text = render(read_bank())
    if args.write:
        with open(ASM_PATH, 'w', encoding='utf-8') as f:
            f.write(text)
        print('wrote %s (%d lines)' % (os.path.relpath(ASM_PATH, ROOT), text.count('\n')))
    else:
        print(text)


if __name__ == '__main__':
    sys.exit(main())
