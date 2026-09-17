# ConfirmDialogPoll decoded and renamed at $D5BD in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** 91430639-fb40-4065-a027-4e1648ea6047
- **Keywords:** ConfirmDialogPoll, yes no dialog, D5BD, 046C countdown, trampoline targets, menu item table

## Content

## Task
Code analysis of prg_1b_1c.asm $D5BD (previously left untouched after the $D568 MapTransitionStateSave/Restore decode).

## Result
- Renamed Loc_D5BD -> ConfirmDialogPoll (.proc, $D5BD-$D63C): shared yes/no confirm-dialog poll for the command-apply frame states (18 call sites).
- Protocol: $046C == 0 -> open dialog: B1F_MenuStep2 ($ED1E) drives a 2-column cursor over item table $D63D ($00 = yes, $01 = no, $FF = disabled); B1F_PointerTableLookup ($EDF5) draws arrow sprite (data $D645, one sprite tile 07, $80 sentinel) at cursor position table $D641 (yes = X $C8/Y $60, no = X $C8/Y $A0). Result $0013 <- $00. $DDAD = overlay idle gate (C=1 when $0300/$0304 both $FF); busy -> return pending.
- Pad edges $0081: A on "no" ($0012 != 0) or B -> $0013 = $FF (cancel, immediate); A on "yes" -> $046C <- $80 starts close countdown.
- $046C != 0 -> closing: B1D_1E_FastPeriodic ($A02D via LDY #$3D trampoline, $3D&$1F = $1D) each frame; at $40 exactly once DEC $6F05 (SRAM game-state flag); at $01 latch $0013 <- $80 (confirm) + B1D_1E_ImmediateOverlay ($A024 trampoline). $046C stays $01 until a caller clears it (callers clear via A=$00 leftover from MenuCursorReset).
- Fixed prior misclassification: $D625-$D638 marked ".byte data" was actually code: $D625 .word $A024 (inline trampoline target), $D627 RTS, $D628-$D62C LDY #$3D + JSR $EE07, $D62D .word $A02D, $D62F-$D63C timer code. Both trampoline targets verified against prg_1d_1e.asm entry stubs and functions.h.
- Converted internal labels to @-locals (@CancelResult, @PollExit, @AcceptCheck, @ClosingEntry, @ClosingTick, @DecrementTimer); symbolic B1F_MenuStep2/B1F_PointerTableLookup/B1F_BankedCallbackTrampoline; 18 call sites JSR $D5BD -> JSR ConfirmDialogPoll with comments realigned to column 42; 12 comment refs updated.

## Verification
tools/verify_1b_1c.py: "compared 16384 bytes, 0 mismatches".

## Notes
- $6F05 semantics per cpu_ram_map (SRAM game-state flag / AI budget seed) do not obviously explain the per-confirm DEC; left factually commented as "SRAM game-state flag tick".
- Do not delete the trailing data $D63D-$D649 - it is the dialog's item/position/sprite tables consumed via pointers $D63D/$D641/$D645.
