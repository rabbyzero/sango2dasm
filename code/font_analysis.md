# Menu Font & CHR Analysis — Working Notes

Status: font pages IDENTIFIED; per-glyph char mapping still in progress.

## CHR hardware chain (verified in code)

1. `OfficerParamDisp` ($DE7E, prg_1d_1e): copies 48 bytes from bank $21 table
   `$946C + A*48` (phys bank $01, file ofs 0x346C in prg_combined.bin) to
   `$00AE-$00DD`. A = display-mode index.
2. First 8 bytes ($00AE-$00B5) = 1KB CHR page numbers for NAMCO163 slots 0-7.
3. `ChrBankSwitch` ($F206, prg_1f) pushes $00AE-$00B5 to $8000-$B800.
4. PPUCTRL mirror $008B = $10 -> BG pattern table = PPU $1000 -> NAMCO slots 4-7:
   - tiles $00-$3F -> $00B2 (record byte 4)
   - tiles $40-$7F -> $00B3 (record byte 5)
   - tiles $80-$BF -> $00B4 (record byte 6)
   - tiles $C0-$FF -> $00B5 (record byte 7)
5. Page value V: file = V//8 (chr_XX.bin), offset = (V%8)*0x400.
6. CHR-RAM disabled (ORA #$C0 -> NAMCO_PRG_A000) => all glyphs live in CHR-ROM.

## Display modes (DisplayInit @ $E370, prg_1f)

- mode 0 (sub_state 2), mode 1 (sub_state 3)
- State_StrategyMode ($E230): mode = action_type ($0544) + 2
- mode 10 tactical, 11 country map, 12 advisor, 13 report

## Record table (bank $21 @ $946C, 48 bytes/record; first 8 = CHR pages)

```
rec  0: 04 04 04 04 00 01 02 10   (title/intro?)
rec  1: 04 8C 04 04 88 89 8A 88
rec  2: 7C 7D 7D 04 95 78 78 18   <- strategy MenuAction 0
rec  3: 7C 7D 7D 04 95 78 78 18   <- MenuAction 1
rec  4: 7C 7D 7D 04 95 78 78 18   <- MenuAction 2
rec  5: 7E 7F 7D 04 95 7A 78 18   <- MenuAction 3
rec  6: 7C 7D 7D 04 95 78 78 18   <- MenuAction 4
rec  7: 7C 7D 7D 04 97 78 78 18   <- MenuAction 5
rec  8: 7C 7D 7D 04 97 78 78 18   <- MenuAction 6
rec  9: 7C 7D 7D 04 95 78 78 90   <- MenuAction 7
rec 10: 80 81 82 85 8D 8E 8F 90   (tactical)
rec 11: B0 A3 B3 A3 A0 A1 A2 A3   (country map)
rec 12: 04 76 04 04 00 75 09 00
rec 13: A7 A8 A9 00 02 A5 A6 A7
rec 14: 16 97 63 97 70 97 91 97   (slot4=page $70 = officer-list kana font)
rec 15: 00 9D 20 2D 00 A5 28 09
```

## CONFIRMED text font pages

### Strategy command menus (MenuAction00-07, records 2-9)

- tiles $00-$3F: page $95 = chr_12.bin @ $1400 (dense kanji)
- tiles $40-$7F: page $78 = chr_0f.bin @ $0000 (kanji + digits)
- Digits VERIFIED visually at $76-$7F (page $78): $76=0 ... $7F=9
  (matches CmdDrawNumber/CmdDrawFormattedNumber: tile = nibble + $76)
- $01 = space (CmdDrawNameFromData/@pad loops store #$01)

### Officer list screens (record 14)

- tiles $00-$3F: page $70 = chr_0e.bin @ $0000 (pure kana font, ASCII-verified)

## Code anchors (certain)

- StoreTileByte ($A1E8): tile = byte + tile_base_offset; $39/$3A -> indirect buf $034B
- CmdDrawNumber ($A3B1): tile = nibble + $76
- CmdDrawFormattedNumber ($A53E): same +$76, DigitTileOffsetTable @ $A607
- $01 = space padding
- CmdDrawName ($A32D): name = bank $30 table $901A + idx*10 (file ofs 0x2101A),
  $00-terminated bytes drawn directly as tiles

## Officer name encoding @ $901A (bank $30) — VERIFIED serial gojuon

240 entries x 10 bytes, $00-terminated (237 named + ids 237-239 blank);
entry index = officer id
(id = (sram_addr - $63C0)/12, cf. GetOfficerRecordAddr; name addr =
id*10 + $901A, cf. GetNameDisplayScale). Anchors: id222 Liubei
2B 36 06 1E 39 = リュウビ; id38 Guanyu 09 31 06 = カンウ; id153 Zhangfei
14 37 06 1E = チョウヒ; id109 Zhugeliang 0F 37 09 15 2B 37 06 = ショカツリョウ;
id121 = 11 38 12 06 = セッソウ; id26 = 09 39 0B 0F 31 = ガクシン.

Table extent is pinned from both ends: entries 240/241 are the resource
labels キン/コメ (drawn through the same id*10+$901A formula), and the ROM
master stat table in bank $31 at $8000 (12 B/record) stops after record 236,
so 237 officers are defined in ROM while SRAM/name space holds 240 slots.
All 240 entries use only codes $04-$3A, i.e. the map below is complete for
officer names; longest name is 7 glyphs (NameScaleTable has 9 slots).
Extractor: `tools/extract_officer_names.py` ->
`docs/officer_names.txt` / `.csv` and `include/officer_ids.inc`.
The font has no kanji, so the ROM stores only the katakana reading; the kanji
and Chinese forms of each name live in `tools/data/officer_kanji.tsv`
(`tools/map_officer_kanji.py` -> `docs/officer_names_kanji.md` / `.csv`).

Code space is SERIAL gojuon: $04=ア..$31=ン (46), $32-34=ァィゥ (guess,
unused), $35=ャ $36=ュ $37=ョ $38=ッ, $39=゛ $3A=゜ postfix combining marks
(DisplayScaledName routes them to the dakuten overlay; GetNameDisplayScale
counts them as width-only). $01 = space tile. Digits are NOT in this code
space; drawn tile-level as nibble+$76 (page $78). Full map + decoder:
tools/charmap_kana.py. (Supersedes the earlier "not officer names" guess.)

## Remaining problem

Per-glyph identification for ~110 kanji/kana tiles (pages $95/$78).
8x8 ASCII reading is ambiguous; prior Noto-bitmap matching scored ~0.3-0.45
(unreliable). Two viable routes:
1. Constraint solve: decode streams against manual-KB command vocabulary
   (土地の開墾/出陣/偵察/徴兵/任命/与える/物資を運ぶ...). Tools:
   tools/solve_charmap.py (seeded), output/menu_streams.txt (53 streams).
2. Runtime dump via Mesen (tools/mesen_chr_dump.lua) reading $00AE-$00B5 and
   PPU $1000+ on a live strategy screen.

## Tool inventory (this session)

- tools/render_font_chunks.py, render_font_big.py, dump_font_ascii.py
- tools/dump_all_records.py (32-record CHR dump + stats)
- tools/dump_record_fonts.py, find_text_font.py, find_font_final.py,
  dump_font_pages.py, scan_triple.py, digit_test.py
- tools/dump_strategy_font.py -> output/strategy_font_ascii.txt
- tools/tmp_name_xref.py -> output/name_xref.txt (dictionary entries)
- output/menu_streams.txt (all 53 decoded PPUTileRender streams)

## Corrections to prior-session conclusions

- "Register $40 -> CHR bank 8 (chr_08.bin)" was WRONG (SubStateChrTiles data
  is officer param data; chr_08 is not the menu font).
- chr_00.bin @ $0400 is NOT the menu font (record 0 = title/intro config);
  its $40-$4F tiles are half-height window graphics.
