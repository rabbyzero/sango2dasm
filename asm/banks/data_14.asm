;===============================================================================
; DATA Bank 14 (PRG $14) - 8KB data bank, mapped into $8000-$9FFF by SwitchBank8;
; no code lives here (see code/bank_switch_map.md 5.2).
;===============================================================================

.segment "CODE_BANK14"

; Raw slice of the stock ROM until its data tables are decoded.
; Original binary: rom/prg/prg_14.bin

.incbin "rom/prg/prg_14.bin"

