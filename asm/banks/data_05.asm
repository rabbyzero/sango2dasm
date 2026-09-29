;===============================================================================
; DATA Bank 05 (PRG $05) - 8KB data bank, mapped into $8000-$9FFF by SwitchBank8;
; no code lives here (see code/bank_switch_map.md 5.2).
;===============================================================================

.segment "CODE_BANK05"

; Raw slice of the stock ROM until its data tables are decoded.
; Original binary: rom/prg/prg_05.bin

.incbin "rom/prg/prg_05.bin"

