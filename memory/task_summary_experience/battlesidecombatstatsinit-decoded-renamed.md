# BattleSideCombatStatsInit decoded and renamed in prg_0e_0f.asm ($C926-$CA3E)

- **Category:** task_summary_experience
- **Memory ID:** cced9c1e-31a2-4202-8256-4117f13a60a7
- **Keywords:** BattleSideCombatStatsInit, BattleAttackValueRoll, prg_0e_0f, edge column, point budget, ROM verification

## Content

## Goal
Decode, rename, and document Loc_C926/Loc_C991 in prg_0e_0f.asm following the Verify-Replace-Rename-Fix-Explain workflow.

## Steps / Result
1. Verified all 281 ROM bytes $C926-$CA3E against rom/prg/prg_0f.bin (offset $0926): exact match; tables at $CA1F/$CA37 are genuine data.
2. Renamed: Loc_C926 -> BattleSideCombatStatsInit (.proc wrapping main + helper + both tables), Loc_C991 -> BattleAttackValueRoll (nested label), Loc_CA1F -> BattleEdgeBonusLowTable, Loc_CA37 -> BattleEdgeDefenseHighTable. Removed stray Loc_C94D label; converted branch targets Loc_C9C0/Loc_C9EA/Loc_CA04 to @TierPctSelected/@RollLoop/@RollStore.
3. Semantics documented: outputs are per-side attack value $056A/$056B (record[1] tier 45-70% + 9-rand(0..8) roll, floor 1; mirrored to $04C1/$04C2), edge-column bonus $0570/$0571 (record[$0A]&$1F table), edge-column defense $056E/$056F (record[$0A]>>5 table), tactic point budget $0572/$0573 = record[2]*13/100. Sole caller: BattleOverlayIntroSkipCheck $A0CF (intro-skip path).
4. Verified with python3 tools/verify_0e_0f.py: 16384 bytes, 0 mismatches.

## Notes
- `make all` currently fails on PRE-EXISTING duplicate-symbol errors in prg_0a_0b.asm/prg_17_18.asm and a missing prg_0b.asm include; prg_0e_0f.asm contributes zero errors. Bank-pair byte-exactness must be proven via tools/verify_0e_0f.py instead of make verify until those are fixed.
- Open question: BattleEdgeBonusLowTable has 24 real entries but is indexed & $1F (0-31); indices $18-$1F alias the defense table bytes. Flagged in a comment; would need officer record[$0A] data dumps to resolve.
- Branch lines in this file align comments at column 61 (not 42 like normal instructions) - transform_branches.py legacy padding.
