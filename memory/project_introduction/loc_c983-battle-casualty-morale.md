# Loc_C983 battle casualty morale resolution data structures

- **Category:** project_introduction
- **Memory ID:** 124c4366-1c08-466e-ab0e-e107dfc4a570
- **Keywords:** battle casualty, morale resolution, officer state, reinforcement table, $9BA4, stat comparison, phase logic

## Content

The Sangokushi 2 NES game implements a battle casualty/morale resolution routine at Loc_C983 ($C983-$CD77) in prg_08_09.asm, entered via bank stub JMP $A00C. Key data structures: officer state array at $6FA1,Y (20 officers, Y=0..19; high nibble=sub-state, low nibble=status code where 5=retreat, 6=casualty, 7=dismissed), side stat pairs at $0522/$0523 (stat A) and $0526/$0527 (stat B), damage accumulator at $0010/$0011, reinforcement table at $9BA4 (3-byte entries, $FF-terminated). The routine processes 6 phases: Phase 1 accumulates damage from officer states (state 5→+50, state 6→+100), Phase 2 subtracts from stat B with underflow check, Phase 3 recursively removes officers by descending threshold (6→5) and restarts from Phase 1, Phase 4 checks opponent viability via averaged stats, Phase 5 performs first reinforcement table lookup and morale collapse checks, Phase 6 performs second reinforcement table lookup and final stat threshold comparisons ($03E8/$1388). Helper routines include SetFleeingOfficers ($CB4D), MarkOfficerByType ($CB6A), CountAndDecrementStates ($CB9A), DecrementOfficerState ($CBDF), ResetAllyStates ($CBFE), TransformOfficerToState6 ($CC19), ComputeAverageStats ($CCAA), ComputeScaledStats ($CD00), and TransformStatPair ($CD43).
