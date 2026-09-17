# BattleOverlayDispatch refactor in prg_0e_0f.asm ($A030-$A15E)

- **Category:** task_summary_experience
- **Memory ID:** 69a27d3e-997f-433b-9509-ed05fe1ffcc1
- **Keywords:** BattleOverlayDispatch, overlay phase machine, intro sub-states, inline dispatch table, bank $19 trampoline

## Content

Refactored Loc_A030 in asm/banks/prg_0e_0f.asm via the Verify/Replace/Rename/Fix/Explain workflow. Loc_A030 is BattleOverlayDispatch (.proc $A030-$A084): battle overlay state machine run each VBlank from BattleVBlankFrameUpdate. Phases 0-2 first redraw two overlay strips via banked calls to bank $19 $A000 (Y=$39; X=0 ptr $0560, X=1 ptr $0561 + $04BC=$D0; inline .word $A000 targets, second resumes into dispatch); all phases then dispatch via B1F_CallbackDispatcher inline 11-entry table at $A06F indexed by $0540 (targets: phase0=Phase0IntroSubDispatch $A085, 1=$A15F, 2=$A4F7, 3=$AA23, 4=$A3BC, 5=$CD43, 6=$CE25, 7=$CF67, 8=$ACC5, 9=$B1EC, $A=$D6BA — the latter ten still raw .byte, given Loc_ labels). Both previously misclassified data regions ($A050-$A068, $A06F-$A094) re-coded. Phase 0 (intro) sub-dispatch at $A085 on $0541 has 5 handlers now .proc'd: BattleOverlayIntroSkipCheck ($A095, $0087 bit7 -> phase 6), BattleOverlayIntroRosterWalk ($A0D3, walks $0580x22 via $B882 gated by $B870 anim-queue-idle check), BattleOverlayIntroAnimQueue ($A0F9, enqueues $E8/$E9 anim), BattleOverlayIntroDataFormatTop ($A119) and BattleOverlayIntroDataFormatBottomAndAdvance ($A137) — both banked-call B1D_1E_DataFormatter (bank $1D, Y=$3D) and sub-4 advances to phase 1 clearing $0568/$0569. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches). Remaining: decode phase handlers 1-$A and their sub-tables.

Corrections: BattleOverlayDispatch .proc spans only $A030-$A084; the phase-0 entry at $A085-$A094 is a separate .proc Phase0IntroSubDispatch (dispatch targets must be independent procs, not nested in the dispatcher). The original body's "$A030-$A094" proc span was wrong.
