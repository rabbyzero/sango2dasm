# AiTurnProcess single proc spans $A02D-$B12F in prg_08_09.asm

- **Category:** project_introduction
- **Memory ID:** 7643c9a3-f753-4d4c-b8d7-3843f5355226
- **Keywords:** nested helper label, AI budget gate, adjacent enemy scan, AiTurnProcess scope

## Content

In prg_08_09.asm, `.proc AiTurnProcess` now spans $A02D-$B12F as a single proc (one .endproc after the final `JMP Mul24x8` at $B12D). All AI routines are plain labels nested inside it: @AiOfficerActionDecide, Action_* handlers, GetOrderedDestination, AiExecuteMove, AiScanAdjacentOfficers, AiCheckAttackNearby, AiFindNearbyOfficers, AiCheckFaction ($A944), AiCheckMove, AiCheckAttackFeasible, AiCheckRecruit (with AiRecruitClassTable), AiCheckActionFeasible (with Cond_Act* labels), AiSortNearbyOfficers, AiCheckFlee, AiComputeArmyStats, AiComputeBattleStats. The only external caller is $CB74, which uses `JSR AiTurnProcess::AiCheckFaction`. Verified byte-exact ($A000-$B12F, 4400 bytes, 0 mismatches) via tools/tmp_verify_b130.py harness (forces a: absolute $00xx operands).
