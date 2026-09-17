# MenuCursorReset $DD70 and hidden call sites decoded in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** ac3d2f9c-ffad-4abe-a3a8-f0d797791a25
- **Keywords:** MenuCursorReset, prg_1b_1c, bank boundary split, BankedCallbackTrampoline, byte verification

## Content

MenuCursorReset ($DD70-$DD78) decoded in prg_1b_1c.asm, wrapped as .proc MenuCursorReset / .endproc (the .proc name doubles as the entry label; plain cross-scope JSR references from other .procs resolve it). The data row at $DD6D was actually: inline .word target $A000 for JSR B1F_BankedCallbackTrampoline (Y=$39 -> bank $19, B19_1A_OverlayStripRender_Entry, X=strip index), then RTS at $DD6F ending the Loc_DD5E proc, then MenuCursorReset: LDA #$00 / STA $0424 / STA $0425 / RTS, returning A=$00 for callers to propagate (e.g. $0470, $046C stores). 52 call sites total (51 JSR + 1 JMP tail call at $A339), all renamed symbolically. Three hidden call sites were buried in misclassified data rows: $A55B and $CD67 (each preceded by LDY #$3D / JSR B1F_BankedCallbackTrampoline / .word B1D_1E_ImmediateOverlay — bank $1D immediate overlay refresh) and $BFFC. The $BFED-$C023 region was converted to code: gates on $0140/$0304, INC $0401, JSR MenuCursorReset, then STA $0473 whose opcode $8D sits at $BFFF (bank 1B) with operand .word $0473 at $C000 (bank 1C) per the cross-boundary segmentation rule; continues through $0150 |= $04, scroll anim counter table $C025,Y -> $0470, UI mode table $C043,Y -> $F26D. Zero-page writes in this file must use the a: prefix (STA a:$00BD) to emit absolute encoding. Verified byte-exact (0 mismatches) with tools/verify_1b_1c.py.
