# Phase 4 battle-result handlers decoded in prg_0e_0f.asm ($A3BC-$A4F6)

- **Category:** task_summary_experience
- **Memory ID:** 77df66db-1683-4e73-8e77-0c00790057d2
- **Keywords:** Phase4Result, battle result dispatch, defeat retreat resolution, damage roll, BattleBothPadsStateFetch

## Content

## Task description
Decoded Loc_A3BC in asm/banks/prg_0e_0f.asm: the phase-4 handler of BattleOverlayDispatch ($A3BC-$A4F6), previously raw .byte. It is the battle-result (defeat/retreat resolution) sub-state machine.

## Execution process
1. Verified bytes from rom/prg/prg_0e.bin: $A3BC = LDA $0541 / JSR $EADE (B1F_CallbackDispatcher) + inline 7-entry table at $A3C4; entries $A3D0, $A3D4, $A3F2, $A407, $A488, $A4B5, $A3F2 (sub 6 reuses sub 2 handler). The old tool disassembly had mis-split these bytes as BNE/table.
2. Semantics: entered at sub 0 by BattleDefeatEventCheck and sub 3 by BattleRetreatEventCheck (both from Phase1NextActorSelect). New procs: Phase4ResultSubDispatch ($A3BC), Phase4ResultAdvance ($A3D0), Phase4ResultDefeatInputWait ($A3D4), Phase4ResultFlashTrigger ($A3F2, waits $0087 bit7 then arms flash $0500=$0B/$007A=3), Phase4ResultRetreatInputWait ($A407, anim-idle $B870 + $CCA8 + A/B-edge gate; B1F_RandomBelowThreshold roll [0,100) <32 retries to sub 2, else damage=rand[0,10)+5 into $0548/$042F, SFX $7E, drains side A strength $05AC or side B $05B7 per scan column $0545 with underflow clamp), Phase4ResultDamageApply ($A488), Phase4ResultConfirmInput ($A4B5), helpers Phase4ResultColumnDamageSelect ($A4D8) and Phase4ResultColumnStripSelect ($A4E6, sets $0515/$0517 <- 2).
3. $CD22 became BattleBothPadsStateFetch (.proc $CD22-$CD42): merges both pads' mode-filtered edge/raw states into $0000/$0001 via BattlePadStateFetch.
4. Cross-bank calls use functions.h names: B1F_CallbackDispatcher, B1F_RandomBelowThreshold, B1F_PaletteCopyBuffer ($ECEE). Still raw in-bank: $B870, $CCA8, $CA3F (overlay total refresh), $F28B.
5. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches). Pre-existing full-make symbol collisions in prg_17_18/prg_0c_0d/prg_0a_0b are unrelated.

## Notes
- Pitfall hit: ROM order places the two helpers ($A4D8-$A4F6) AFTER Phase4ResultConfirmInput, so nesting them inside the parent procs shifted assembly (helpers landed at $A4B5); fix = independent procs in ROM order. Dispatch targets and their late helpers must follow physical ROM layout, not logical ownership.
- Harness only stubs raw absolute JSR/JMP operands lacking Loc_ labels; semantic cross-bank names must come from functions.h.
- Remaining roadmap: decode phase handlers 2,3,5-$A ($A4F7 partly analyzed, $AA23, $CD43, $CE25, $CF67, $ACC5, $B1EC, $D6BA).
