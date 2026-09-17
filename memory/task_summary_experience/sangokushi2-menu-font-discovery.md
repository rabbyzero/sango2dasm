# Sangokushi 2 menu font discovery: OfficerParamDisp chain and strategy menu CHR page mapping

- **Category:** task_summary_experience
- **Memory ID:** 22d34cfc-425d-4fab-90e2-6396da0bba15
- **Keywords:** font discovery, OfficerParamDisp, Namco-163 CHR pages, strategy menu records, digit anchor, sorted dictionary, PPUTileRender

## Content

## Task description
Decoded PPUTileRender stream format and identified menu font CHR banks for Sangokushi 2 strategy mode menu rendering; resolved prior session's incorrect chr_08 conclusion.

## Execution process
1. **Architecture tracing**: Discovered OfficerParamDisp ($DE7E, prg_1d_1e) copies 48-byte records from bank-$21 table at `$946C+A*48` (file offset 0x346C) to `$00AE-$00DD`; first 8 bytes are 1KB CHR pages pushed by ChrBankSwitch ($F206, prg_1f) to NAMCO163 registers $8000-$B800.
2. **PPU mapping verification**: PPUCTRL mirror `$008B=$10` → BG pattern table = PPU `$1000` → slots 4-7 (`$00B2-$00B5`) serve tiles `$00-$3F/$40-$7F/$80-$BF/$C0-$FF`. Page V → `chr_(V/8).bin @ (V%8)*$400`. CHR-RAM disabled (`ORA #$C0`), all glyphs in CHR-ROM.
3. **Strategy menu state identification**: State_StrategyMode uses display mode = `action_type($0544)+2`, so MenuAction00-07 use records 2-9.
4. **Font page confirmation**: Records 2-9 have slot 4 = page `$95` (chr_12 @ $1400, kanji + frames), slot 5 = page `$78` (chr_0f @ $0000, kanji + digits 0-9 verified at $76-$7F). Record 14 (officer lists) uses kana font page `$70` (chr_0e @ $0000) for tiles $00-$3F.
5. **Code anchors**: `$01`=space, digits = nibble+`$76` (verified visually), `$39/$3A` = indirect markers.
6. **Dictionary discovery**: Bank-$30 `$901A` table (file 0x2101A) is a sorted string dictionary (40 entries × 10 bytes, byte `$31` dominant), not officer names as previously hypothesized.
7. **Tool creation**: Created decode_menu_streams.py, render_chr_font.py, solve_charmap.py, dump_strategy_font.py, and dump_all_records.py for systematic extraction and glyph analysis.
8. **Documentation**: Saved complete notes in code/font_analysis.md, ASCII dumps in output/strategy_font_ascii.txt, decoded streams in output/menu_streams.txt.

## Key findings
- **Confirmed font pages**: 
  - Strategy menus: tiles $00-$3F = chr_12@0x1400 (kanji), tiles $40-$7F = chr_0f@0x0000 (kanji + digits 0-9)
  - Officer lists: tiles $00-$3F = chr_0e@0x0000 (kana)
- **Byte-to-tile mapping**: Partially solved via constraint solver; remaining ~110 kanji glyphs need per-glyph identification or Mesen runtime dump.
- **Open issue**: Which specific records map to each strategy command screen (MenuAction00-1B); requires either deeper code tracing or emulator runtime inspection.

## Related files
- /home/zero/project/sango2dasm/tools/decode_menu_streams.py
- /home/zero/project/sango2dasm/tools/render_chr_font.py
- /home/zero/project/sango2dasm/tools/solve_charmap.py
- /home/zero/project/sango2dasm/tools/dump_strategy_font.py
- /home/zero/project/sango2dasm/code/font_analysis.md
- /home/zero/project/sango2dasm/output/strategy_font_ascii.txt
- /home/zero/project/sango2dasm/output/menu_streams.txt

## Notes
- Prior session's chr_08 conclusion was wrong due to misidentified OfficerParamDisp chain and display mode mapping.
- Font is static in CHR-ROM (no runtime loading), but requires correct record-to-screen mapping to identify active pages.
- Next steps: Solve character-code mapping using manual-KB command vocabulary (土地の開墾, 出陣, 徴兵…) or run Mesen script (mesen_chr_dump.lua) to capture runtime CHR state.
