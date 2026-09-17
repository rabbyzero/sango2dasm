# OfficerCardRender decoded and refactored in prg_19_1a.asm ($CE1F)

- **Category:** task_summary_experience
- **Memory ID:** 907d7832-3808-43fc-8551-1b9449f73517
- **Keywords:** OfficerCardRender, sprite overlay, OAM writer, bank 01 tables, portrait tile table, mid-entry label

## Content

## Task description
- Core requirement: Code Analysis Workflow (Verify/Replace/Rename/Fix/Explain) on prg_19_1a.asm $CE1F-$CED5, the sprite overlay card renderer.
- Task background: The region contained raw disassembly with generic Loc_ labels; user requested full semantic renaming, scope boundaries, and documentation.

## Execution process
1. Verified code/data: confirmed valid code region; identified JMP $F1B7 as mid-entry call to fixed-bank SpriteOamWriterSimple; verified bank $01 tables ($99A0/$9AA0/$9BAC/$9D64) via LDY #$21/SwitchBank8_B.
2. Wrapped region in .proc OfficerCardRender / .endproc; renamed all Loc_ labels to @-prefixed semantic names (@OverrideBit3/@BankIn/@Strip0/@SlotCalc/@RowParamSet/@FrameSetDefault/@FrameSetAnimated).
3. Converted 9 in-bank JSR $CE1F + $A000 stub JMP to symbols; updated stale comment "OfficerCardShow" → OfficerCardRender.
4. Cross-bank: added B1F_SpriteOamWriterSimple_NoInit = $F1B7 to functions.h and matching bare global label + mid-entry doc inside .proc SpriteOamWriterSimple in prg_1f.asm.
5. User request: nested @PortraitTileTable ($CED6-$CFD5, 256 bytes) inside proc (verified repo-wide only referenced by this routine); moved .endproc after table rows.
6. Re-alignment: fixed 15 over-long .byte rows to use standard two-space separator before hex comments (per align_comments.py rule).
7. Verified byte-exact with tools/verify_19_1a.py: 16384 bytes, 0 mismatches.

## Related files
- asm/banks/prg_19_1a.asm
- include/functions.h
- asm/banks/prg_1f.asm

## Notes
- Read tool rendered one .byte row ($CFC7) with 16 bytes while file has 15 — always re-verify .byte rows with sed/cat -A before SearchReplace.
- Bank table data for $99A0/$9AA0/$9BAC/$9D64 lives in physical bank $01 (rom/prg/prg_01.bin), dumped via offset addr-$8000.
- Pre-existing harness issue in tmp_verify_1f.py (7791 diffs at HEAD) unrelated to edits.

## Task overview
Completed: Decoded OfficerCardRender into semantic procedure with @-locals, symbolized branches, named data tables, nested portrait tile table per user request, added cross-bank mid-entry label; byte-exact verification passed with 0 mismatches across both banks.
