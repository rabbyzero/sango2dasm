# PPUTileRender stream architecture decoding and menu font CHR analysis

- **Category:** task_summary_experience
- **Memory ID:** c108043b-ee0d-4db8-b148-c7478a4fa2f3
- **Keywords:** PPUTileRender, stream decoding, menu font, CHR banks, Sangokushi 2, tile indices, Namco-163

## Content

## Task description
- Core requirement: Decode PPUTileRender stream format and identify menu font CHR banks for Sangokushi 2 strategy mode menu rendering
- Task background: The game uses a bytecode-based tile stream format (PPUTileRender) to render menu text via tile indices from CHR pattern tables; previous work had identified MenuAction handlers but not the underlying stream format or name data encoding

## Execution process
1. Analyzed PPUTileRender infrastructure functions: SetupDisplayPtrs, DisplayTileData, ResetDispatchState, and CmdDrawName/CmdDrawNumber implementations in prg_1d_1e.asm
2. Decoded complete PPUTileRender command set (32 commands $80-$9F) with semantics including CMD_END_MENU, CMD_OVERLAY_ON/OFF, CMD_SET_VRAM_*, CMD_ADVANCE_ROW, CMD_DRAW_TILE_*
3. Identified name data location at bank $30 offset $901A with formula entry * 10 + $901A; extracted 50+ officer name entries showing tile index patterns ($04-$09 primary bytes, $31/$36/$37/$39/$3A secondary bytes)
4. Discovered @draw_name_scaled transformation: name bytes $39/$3A are skipped, all other bytes have $80 added before rendering
5. Extracted actual pos_buf_0 values for MenuAction handlers 0D-1B from code analysis (many differed from estimates)
6. Created decode_menu_streams.py tool to extract and decode tile streams from PRG banks $32/$33 (physical $12/$13) using BankPageOffsetTable pointer resolution
7. Analyzed CHR bank mapping: SubStateChrTiles setup uses register $40 → CHR bank 8 (chr_08.bin) for PPU $0000-$03FF; Namco-163 bank switching writes Y directly to NAMCO_PRG_8000 ($E000)
8. Created render_chr_font.py tool to visualize CHR tiles as ASCII art; identified chr_08.bin tiles $04-$09 as font candidates with low density metrics
9. Documented complete architecture in code/pputilerender_stream_architecture.md

## Related files
- /home/zero/project/sango2dasm/tools/decode_menu_streams.py (created)
- /home/zero/project/sango2dasm/tools/render_chr_font.py (created)
- /home/zero/project/sango2dasm/code/pputilerender_stream_architecture.md (created)
- /home/zero/project/sango2dasm/tools/extract_names.py (used)

## Notes
- Initial bank offset calculation error: used 0x30 instead of 0x20000 for bank $30; corrected to 0x10 * 0x2000 = 0x20000 (bank $30 maps to physical bank $18 via Namco-163 register masking $30 & $3F = $30, then $30 >> 1 = $18)
- CHR bank $30 is out-of-range for direct ROM access; actual name data lives in bank $10 (prg_10.bin) due to register value transformation
- Tile stream data requires bank selection logic based on pos_buf_0 >= $20 condition; both banks $32 and $33 contain valid but different stream data

## Task overview
Partially completed: Fully decoded PPUTileRender stream architecture and created working decoder tools; identified name data structure and CHR bank mapping; however, final step of building complete char-code mapping for kanji font remains unresolved due to multi-byte encoding complexity and lack of manual KB cross-reference for 408 officer names. Next steps require either visual tile rendering to identify characters or manual name-to-tile mapping against known officer roster.
