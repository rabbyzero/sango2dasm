# Phase 3 command-selection handlers decoded in prg_0e_0f.asm ($AA23-$ACC4)

- **Category:** task_summary_experience
- **Memory ID:** c88fd950-e722-4ef1-a1fa-af2b1b2ee041
- **Keywords:** Phase3CommandSubDispatch, command selection, resume latch, action slot, overlay strip

## Content

## Task description
Decoded Loc_AA23 in asm/banks/prg_0e_0f.asm: phase 3 (acting-unit command selection) of BattleOverlayDispatch, $AA23-$ACC4, previously raw .byte + bare Loc_ labels.

## Execution process
1. Pre-existing corruption found first: a redundant `JMP $A915` ($A912: 4C 15 A9, ROM artifact jumping to the next instruction) had been deleted from Phase2AttackDamageCompute, shifting all code after $A912 by -3 bytes (5425 mismatches, 170 drifted labels). Restored it; also restored shared RTS tails via global labels outside procs (Phase2AnimWaitExit $A653, Phase2DamageAnimExit $A7B1, Phase2DamageSurvived $A7B2) and corrected swapped DEC/INC operands in Phase2CursorStep/Phase2CursorStepFast (side 0/1 -> $054B row, side 2/3 -> $054A column).
2. Phase 3 structure: Phase3CommandSubDispatch ($AA23) redraws acting side's overlay strip (bank $19, X=0, ptr lo $0560[$0549], hi $A5 at $000A) then dispatches on $0541 via B1F_CallbackDispatcher inline 5-entry table ($AA40): sub0 Phase3CommandPanelInit ($AA4A, fills panel fields $044C-$0457 from officer record via B1F_GetOfficerRecordAddr, $00BD<-6), sub1 Phase3CommandAnimStep ($AABD, $B870/$007E bit2 gates, marker steps via Phase3CommandMarkerUpdate while $0548<4, then banked B1D_1E_OfficerDisplay_Render ($A030, NOT DataFormatter $A03C)), sub2 Phase3CommandInput ($AAF0: B toggles $008F; A on action slot $0550[$0549*4+$0548]==4 with no pending $0574-$0577 nibble commits phase 8 sub0 slot<-2, else sub3 with $E8/$E9 anim via $CBF1 when resume latch $054B==1), sub3 Phase3CommandConfirmWait ($AB75, $00BD<-6 then $00BB<-9 + B1D_1E_DataFormatter $0560/0), sub4 Phase3CommandResultWait ($AB9A, $007E gate then DataFormatter $0561/1) falling through to Phase3CommandResumeHandoff ($ABB1: $008F<-0, $0540<-[$054B], $0541<-[$054C]; player-request entry latches 1/1 -> back to Phase1NextActorSelect sub1).
3. Helpers: Phase3CommandDirInput ($ABC3: right $80/left $40 adjust slot value 0-3, extended cap/wrap 4-5 at step 0 when $054B==1; down $20/up $10 cycle step $0548 0-3), Phase3CommandArrowDraw ($AC73, tail-call B1F_SpriteOamWriterSimple, tile table Phase3CommandArrowTiles $AC9B: $A6/$B6/$C6/$D6 x2), Phase3CommandMarkerUpdate ($ACA8, $C839).
4. Pitfalls hit: (a) ca65 rejects `Proc::@cheap` cross-proc refs and global-label-inside-proc refs failed too — shared entry/exit labels must live OUTSIDE any .proc; (b) ROM wait-loop branches in sub1 target the TRAILING RTS ($AAEF), not the mid-proc one — @Done placement must follow ROM operand bytes; (c) trampoline .word target $A030 = B1D_1E_OfficerDisplay_Render, verified from ROM not assumption.
5. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches) and dbg-file label audit (0 drifted of 553).

## Notes
- Roadmap remaining for prg_0e_0f phase handlers: 5=$CD43, 6=$CE25, 7=$CF67, 8=$ACC5, 9=$B1EC, $A=$D6BA.
- During the session the file was concurrently edited/corrupted by an external writer; re-verify baseline (verify_0e_0f.py) before starting edits.
