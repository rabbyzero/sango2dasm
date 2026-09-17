# Battle casualty morale resolution routine Loc_C983 documentation

- **Category:** task_summary_experience
- **Memory ID:** 5ee43417-9c99-47d5-a7a9-6de88e296ffd
- **Keywords:** battle casualty, morale resolution, prg_08_09, Loc_C983, phase documentation, reinforcement table, $9BA4, officer states

## Content

## Task description
- Core requirement: Add detailed comments to the Loc_C983 routine ($C983-$CD77) in prg_08_09.asm explaining each phase of the battle casualty/morale resolution logic
- Task background: The routine handles post-action battle resolution, processing damage accumulation, officer state changes, stat comparisons, and reinforcement checks. Existing disassembly lacked inline documentation for the complex multi-phase flow.

## Execution process
1. Read prg_08_09.asm lines 5490-6050 to analyze the full Loc_C983 routine structure ($C983-$CD77)
2. Identified entry point via bank stub JMP $A00C → $C983 and verified code boundaries before Loc_CD78
3. Added 31-line header block documenting routine purpose, officer state semantics (low nibble 0-7), side stat pairs ($0522/$0523 stat A, $0526/$0527 stat B), reinforcement table layout at $9BA4, and key zero-page temporaries
4. Added Phase 1 comment ($C98B): damage accumulation from officer states 5/6/7 (state 5→+50, state 6→+100, state 7→dismiss)
5. Added Phase 2 comment ($C9C4): Stat B subtraction with underflow check triggering Phase 3
6. Added Phase 3 comment ($C9DE): Recursive officer removal by descending threshold (6→5), restarting from Phase 1 on removal
7. Added Phase 4 comment ($CA10): Opponent viability check via averaged stats computation ($CCAA/$CD00), own-side stat A comparison
8. Added Phase 5 comment ($CA5F): First reinforcement table lookup ($9BA4 entry+0), stat B sustain check (≥100), state-5 officer search
9. Added Phase 5b comment ($CAA8): Morale collapse path when no reinforcement ($FF), timer setup, opponent check, rally/reset
10. Added Phase 6 comment ($CAC2): Second reinforcement table lookup (entry+4), state-6 officer count, final averaged stat thresholds ($03E8/$1388)
11. Added 10 helper routine headers: SetFleeingOfficers ($CB4D), MarkOfficerByType ($CB6A), CountAndDecrementStates ($CB9A), DecrementOfficerState ($CBDF), ResetAllyStates ($CBFE), TransformOfficerToState6 ($CC19), ComputeAverageStats ($CCAA), ComputeScaledStats ($CD00), TransformStatPair ($CD43), OfficerTypePriority table ($CB96)
12. Verified build integrity: make command showed no errors in modified region (lines 5497-6148); all errors pre-existing in other file regions

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm

## Notes
- None significant; build errors existed prior to modifications and were unrelated to the annotated region

## Task overview
Completed: Successfully added comprehensive inline documentation to the battle casualty/morale resolution routine spanning 6 phases and 10 helper routines. All comments follow project conventions with detailed explanations of officer state thresholds, stat comparison logic, and reinforcement table usage. Build verification confirmed no syntax errors introduced in the modified region.
