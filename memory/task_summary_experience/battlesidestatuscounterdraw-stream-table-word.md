# BattleSideStatusCounterDraw stream table converted to .word and decoded in prg_0e_0f.asm

- **Category:** task_summary_experience
- **Memory ID:** 522b5194-b713-4523-b0e9-245ede1b4574
- **Keywords:** counter digit streams, PerCounterStreamPtrTable, word pointer table, segment boundary data

## Content

## Task description
In asm/banks/prg_0e_0f.asm, converted BattleSideStatusCounterDraw's $BFCF table from raw .byte pairs to a symbolic .word pointer table (@PerCounterStreamPtrTable inside the .proc) and decoded its four digit PPU stream targets. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches, 10 stubs).

## Key findings
1. @PerCounterStreamPtrTable $BFCF (4 words, Y = counter*2) -> BattleSideStatusCounterStream0-3 at $BFD7/$BFE8/$BFF9/$C00A. Each stream is 17 bytes: four [relY,tile,attr,relX] records (a 2x2 digit pair, two digits side by side at relX 0/8) + $80 terminator, submitted via B1F_SpriteOamWriterScroll ($F092).
2. Stream tiles: counter 0 = $69/$6A/$79/$7A, counter 1 = $70-$73, counter 2 = $6B/$6C/$7B/$7C, counter 3 = $6D/$6E/$7D/$7E with attr $02 (others attr $00).
3. BattleSideStatusCounterStream2 spans the $BFFF/$C000 segment boundary (7 bytes in CODE_BANK0E, 10-byte tail in CODE_BANK0F); stream 3 sits entirely in CODE_BANK0F ($C00A-$C01A). Labels for cross-segment data referenced by a .word table are fine since ca65 resolves them at link time.
4. Removed stale unreferenced mid-data label Loc_BFEB (old disassembler artifact inside stream 1).

## Notes
- Pointer tables holding 16-bit addresses must use .word with symbolic targets per project convention, not .byte pairs; hex comments stay little-endian.
- When splitting merged .byte rows at true stream boundaries, recompute every address comment (e.g. $BFDF row split into $BFDF+$BFF0 rows; $C001 row split into $C001+$C00A+$C012).
