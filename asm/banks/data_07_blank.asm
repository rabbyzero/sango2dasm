;===============================================================================
; DATA Bank 07 (PRG $07) - 8KB data bank, mapped into $8000-$9FFF by SwitchBank8;
; no code lives here (see code/bank_switch_map.md 5.2).
;
; Entirely blank: all 8192 bytes are $FF. Evidence (2026-10-10):
;   - rom/prg/prg_07.bin is a uniform $FF fill (8192 x $FF, md5
;     84d04c9d6cc8ef35bf825d51a5277699).
;   - No code site selects it. Every SwitchBank8_A/B call site and every
;     dynamic $8000-window bank table carries only banks $00-$05/$10-$16:
;     TileBankTable $B8BB (prg_08_09_tactical_war: $20/$23/$24/$25), FieldMapCropBankTable $A822
;     (prg_17_18_duel_and_display: same), @PosDataBankTable $A6A7 (prg_1d_1e_menu_screens: $32/$33),
;     DrawSpriteFromBank (prg_17_18_duel_and_display: $34/$35). The only `LDY #$27` immediate
;     in the code (prg_0c_0d_tactical_commands $DD25) is a RAM-clear loop bound, not a bank
;     select; all other `#$27` immediates are SBC/CMP arithmetic operands.
;
; The linker maps CODE_BANK07 to BANK07 (fillval $FF), so the .res below
; reproduces prg_07.bin byte-exactly. Original binary: rom/prg/prg_07.bin
;===============================================================================

.segment "CODE_BANK07"

  .res $2000, $FF
