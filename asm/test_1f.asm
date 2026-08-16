; Temporary test file for standalone prg_1f.asm verification.
; Stub for the bank $0E/$0F jump-table entry defined as a global label in
; prg_0e_0f.asm (not assembled in this standalone harness); it sits at the
; start of CODE_BANK0E ($A000).
BattleVBlankFrameUpdate_Entry = $A000

.include "banks/prg_1f.asm"
