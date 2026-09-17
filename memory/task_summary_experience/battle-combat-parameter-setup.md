# Battle combat parameter setup routine decoded and renamed in prg_0e_0f.asm

- **Category:** task_summary_experience
- **Memory ID:** d3520820-aa79-4a5b-b2d4-c4a323769018
- **Keywords:** BattleSideCombatStatsInit, BattleAttackValueRoll, prg_0e_0f, combat parameters, edge column, point budget, ROM verification, semantic renaming

## Content

## Task description
- Core requirement: decode, rename, and document the Loc_C926 combat parameter setup routine in prg_0e_0f.asm ($C926-$CA3E)
- Task background: The battle overlay initialization path calls Loc_C926 when intro-skip is enabled; it computes per-side attack values, edge-column bonuses/defense, and point budgets from officer records. The region contained auto-generated Loc_ labels and needed semantic renaming following the project's Verify-Replace-Rename-Fix-Explain workflow.

## Execution process
1. Verified all 281 ROM bytes $C926-$CA3E against rom/prg/prg_0f.bin (offset $0926): exact match confirmed both code and data tables (24+8 bytes at $CA1F/$CA37)
2. Performed SearchReplace renames: Loc_C926 → BattleSideCombatStatsInit (.proc wrapping main + helper + nested tables), Loc_C991 → BattleAttackValueRoll, Loc_CA1F → BattleEdgeBonusLowTable, Loc_CA37 → BattleEdgeDefenseHighTable
3. Removed stray Loc_C94D label; converted branch targets to @-locals (@TierPctSelected/@RollLoop/@RollStore)
4. Updated caller reference at $A0CF and corrected misleading comment about record pointer reloads
5. Added header documentation documenting four outputs (attack value $056A/$056B, edge bonus $0570/$0571, edge defense $056E/$056F, point budget $0572/$0573 = record[2]·13/100)
6. Encountered SearchReplace failures due to whitespace inconsistencies (branch lines use column 61 vs normal instructions column 42); re-read file and retried with corrected indentation
7. Built bank pair with tools/verify_0e_0f.py: 16384 bytes compared, 0 mismatches (zero drift)

## Related files
- asm/banks/prg_0e_0f.asm

## Notes
- make all fails on PRE-EXISTING duplicate-symbol errors in prg_0a_0b.asm/prg_17_18.asm; must use bank-pair harness instead of full build verification until those are fixed
- Branch line comments align at column 61 (transform_branches.py legacy padding) vs 42 for normal instructions - SearchReplace anchors must account for this
- Open question: BattleEdgeBonusLowTable has 24 real entries but indexed & $1F (0-31); indices $18-$1F alias defense table bytes - would need officer record[$0A] data dumps to resolve

## Task overview
Completed semantic renaming and documentation of battle combat-parameter setup routine. All changes verified byte-exact against ROM. Zero drift confirmed via bank-pair verification harness.
