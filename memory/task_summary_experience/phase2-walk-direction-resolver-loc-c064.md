# Phase 2 walk-direction resolver Loc_C064 decoded and refactored

- **Category:** task_summary_experience
- **Memory ID:** 5067520a-d986-4a6b-9e7f-da3759de3df5
- **Keywords:** Phase2WalkDirectionResolve, Phase2StepTileProbe, BattleSlotSideCompare, selection gate, walk direction, tile probe, prg_0e_0f.asm

## Content

## Task description
- Core requirement: analyze and refactor Loc_C064 in prg_0e_0f.asm (phase-2 selection-gate walk-direction resolver)
- Task background: Loc_C064 ($C064-$C1CC) was raw code called by Phase2ActionGate @Select ($A5AF); it resolves a single step direction into $0549 based on command objective, axis priority from column status, and tile-probe validation. Two shared helpers Loc_C1CD and Loc_C827 were also raw.

## Execution process
1. Read prg_0e_0f.asm around $C064–$C1CC to identify the routine boundaries and call sites
2. Analyzed semantics: objective selection (command $054F), axis priority from $05C2[$0545]&$0F, step validation via Phase2StepTileProbe ($C1CD) and terrain check ($CAF9)
3. Identified helper routines: Loc_C1CD ($C1CD-$C20E) for tile occupancy probe, Loc_C827 ($C827-$C838) for faction side comparison
4. Renamed Loc_C064 → .proc Phase2WalkDirectionResolve with 22 semantic local labels and full header comment
5. Renamed Loc_C1CD → .proc Phase2StepTileProbe and Loc_C827 → .proc BattleSlotSideCompare
6. Updated all 38 call sites of JSR $C1CD symbolically; updated Phase2ActionGate context comment
7. Fixed BCC trampoline issue: branch targets at $C0F9/$C106 must not merge JMP targets at $C123; verifier caught two operand mismatches (20 vs 23) which were corrected
8. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches)

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_0e_0f.asm

## Notes
- Pitfall: BCC trampolines at $C0F9/$C106 are branch-range hops; adjacent JMPs target $C123 directly. Initially routing both through the trampoline label changed two operand bytes ($C0F7/$C107: 20 vs 23) caught by the verifier; keep branch targets and JMP targets as separate labels.
- Tool limitation: Read tool display can strip leading whitespace on some lines; verify exact indentation via awk/cat -A before building SearchReplace originals.

## Task overview
Completed: refactored Loc_C064 into Phase2WalkDirectionResolve with semantic naming, renamed helpers Phase2StepTileProbe and BattleSlotSideCompare, updated all 38 call sites symbolically, fixed BCC trampoline addressing issue, and verified byte-exact match. Remaining roadmap: phases 5 ($CD43), 6 ($CE25), 7 ($CF67), $A ($D6BA); route setups $C20F (move) and $C30F (attack) next candidates; $CAF9 terrain check still raw.
