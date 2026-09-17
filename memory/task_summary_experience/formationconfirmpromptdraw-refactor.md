# FormationConfirmPromptDraw refactor: RTS at $C920 and named sprite record inside proc

- **Category:** task_summary_experience
- **Memory ID:** 1715c8ad-ac93-42a2-8839-da8c47ba3926
- **Keywords:** FormationConfirmPromptDraw, FormationConfirmPromptSprite, $C920, $C921, OAM record, RTS, inline data, byte parity

## Content

Refactored FormationConfirmPromptDraw in prg_0e_0f.asm: changed the proc to end with a real RTS instruction at $C920 (branch target @Skip), removed the previous inline .byte $60,$00,$04 from within the proc body, and moved the OAM sprite record ($C921-$C925) inside the proc immediately after @Skip:RTS. Renamed the anonymous Loc_C923 region to FormationConfirmPromptSprite, documenting it as a B1F_SpriteOamWriterSimple-format record ([y_off, tile, attr, x_off], $80-terminated) identical to the twin BattleInputPromptSprite at $CCD9. Byte-level verification confirmed ROM bytes at $C920-$C925 remain 60 00 04 00 00 80 (no drift). ca65 pass over asm/main.asm reported zero diagnostics from prg_0e_0f.asm.
