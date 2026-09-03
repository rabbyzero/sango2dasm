# Menu font CHR pages, display records, and verified serial kana name encoding

- **Category:** project_architecture
- **Memory ID:** a7d5c77f-12d3-445b-ae11-67f4ba577abf
- **Keywords:** CHR page mapping, kana charmap, serial gojuon, officer name table, $901A, dakuten postfix
- **Usage scenarios:**
  - Decoding officer name strings or menu text streams
  - Analyzing CHR bank switching or PPU setup
  - Building or extending the kana/digit char map

## Content

Menu/text rendering CHR chain: OfficerParamDisp ($DE7E, prg_1d_1e) copies 48 bytes from bank $21 table $946C+A*48 (phys $01, file ofs 0x346C) to $00AE-$00DD; first 8 bytes are 1KB CHR pages pushed by ChrBankSwitch ($F206, prg_1f) to NAMCO163 $8000-$B800. PPUCTRL mirror $008B=$10 -> BG pattern table PPU $1000 -> slots 4-7 ($00B2-$00B5) serve tiles $00-$3F/$40-$7F/$80-$BF/$C0-$FF. Page V -> chr_(V/8).bin @ (V%8)*$400. CHR-RAM disabled, all glyphs in CHR-ROM. State_StrategyMode uses display mode = action_type($0544)+2, so strategy menus (MenuAction00-07) use records 2-9: tiles $00-$3F = page $95 (chr_12 @ $1400, kanji), tiles $40-$7F = page $78 (chr_0f @ $0000, kanji + digits 0-9 verified at $76-$7F). Record 14 (officer lists) uses kana font page $70 (chr_0e @ $0000) for tiles $00-$3F. Anchors: $01=space, tile=nibble+$76 for digits.

OFFICER NAME ENCODING (VERIFIED, supersedes "not officer names" guess): bank $30 $901A (file 0x2101A) = 237 entries x 10 bytes, $00-terminated, indexed by officer id (id=(sram-$63C0)/12; addr=id*10+$901A per GetNameDisplayScale). Code space is SERIAL gojuon katakana: $04=ア..$31=ン, $32-34=ァィゥ(unused guess), $35=ャ $36=ュ $37=ョ $38=ッ, $39=゛ $3A=゜ postfix dakuten/handakuten. Anchors: id222=リュウビ, id38=カンウ, id153=チョウヒ, id109=ショカツリョウ, id121=セッソウ. Decoder + full map: tools/charmap_kana.py; notes in code/font_analysis.md.
