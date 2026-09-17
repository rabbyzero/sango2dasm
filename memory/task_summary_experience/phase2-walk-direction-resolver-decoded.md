# Phase 2 walk-direction resolver decoded in prg_0e_0f.asm ($C064-$C1CC)

- **Category:** task_summary_experience
- **Memory ID:** 043c27b2-f77c-479e-8ff8-85a7000b31f1
- **Keywords:** Phase2WalkDirectionResolve, Phase2StepTileProbe, BattleSlotSideCompare, selection gate, walk direction, tile probe

## Content

## Task description
Decoded Loc_C064 in asm/banks/prg_0e_0f.asm: the phase-2 selection-gate walk-direction resolver ($C064-$C1CC), plus its two shared helpers Loc_C1CD ($C1CD-$C20E) and Loc_C827 ($C827-$C838). Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches, 10 stubs).

## Key findings
1. Phase2WalkDirectionResolve ($C064, called by Phase2ActionGate @Select $A5AF with Y=$0545): picks one step direction into $0549 (0=up,1=down,2=left,3=right,$FF=none -> gate passes turn). Objective: command $054F==1 aims past the enemy edge (col $FF for slots <$0B, col $20 for slots >=$0B, on the enemy commander's row), other commands aim at the enemy commander (slot $0B col/row $058B/$05A1 for side-A actors, slot 0 $0580/$0596 for side-B). Signed deltas live in $0010 (col) / $0011 (row), abs distances in $0000/$0001.
2. Axis priority from column status low nibble $05C2[$0545]&$0F: 0/3 balanced -> step along larger distance axis, ties via B1F_RandomByte bit0; code 2 biases row steps unless row-aligned (<2); others bias column steps unless column-aligned. Preferred axis steps one tile when Phase2StepTileProbe returns carry (empty) AND terrain check $CAF9 returns 0; failures retry the other axis once via zp flag $0012, then $0549<-$FF. Direction codes match phase-9 semantics (0/1/2/3 = row-/row+/col-/col+).
3. Phase2StepTileProbe ($C1CD, 38 call sites updated symbolically): applies signed delta ($0000 col, $0001 row) to actor $0545 position ($0580/$0596), bounds col<$10 row<$0A, scans 22 slots $15..0 for occupant. Returns: carry set = empty; carry clear A=$01 = enemy occupant (X=slot); carry clear A=$00 = same-side occupant or out of bounds.
4. BattleSlotSideCompare ($C827): A=actor slot, X=other slot; slots 0-$0A side A vs $0B-$15 side B; returns A=1 opposing sides, A=0 same side.
5. Phase2ActionGate context clarified: attack route = JSR $C30F, move route = JSR $C20F, selection gate = JSR $C064; $0549 holds the resolved direction (not a unit id) when entering sub 1 cursor walk.

## Notes
- Pitfall: the BCC trampolines at $C0F9/$C106 are branch-range hops; the adjacent JMPs at $C0F6/$C106 target $C123 directly. Initially routing both through the trampoline label changed two operand bytes ($C0F7/$C107: 20 vs 23) caught by the verifier; keep branch targets and JMP targets as separate labels.
- tools/verify_0e_0f.py Read-tool display can strip leading whitespace on some lines; verify exact indentation via awk/cat -A before building SearchReplace originals.
- Remaining roadmap: phases 5 ($CD43), 6 ($CE25), 7 ($CF67), $A ($D6BA); route setups $C20F (move) and $C30F (attack) next candidates; $CAF9 terrain check still raw.
