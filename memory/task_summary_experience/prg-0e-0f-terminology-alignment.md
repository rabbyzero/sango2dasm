# prg_0e_0f.asm terminology alignment with glossary and zero drift verification

- **Category:** task_summary_experience
- **Memory ID:** 34909cdb-3836-4841-ac9e-9e10ceb2766e
- **Keywords:** prg_0e_0f, terminology alignment, troop count, army affinity, Battle Mode, zero drift verification

## Content

## Task description
- Core requirement: Align prg_0e_0f.asm terminology with docs/manual_kb/terminology.md glossary
- Task background: The battle overlay bank contained non-glossary terms including "battle scene", "strength" (for troop count), "HP" (misused for troop count), "troop type", and related labels that needed standardization to match the consolidated semantic English glossary

## Execution process
1. Identified misaligned terms via grep searches: "battle scene" (14 occurrences), "strength" (~16), "HP" (~38), "troop type" (5), "BattleTroopTerrainTableA/B", "BattleCellHpDigitOverlay", local @Side*Hp* labels
2. Captured baseline ca65 error set: 218 lines, md5sum a659680229ebd27046b0e8757876c756
3. Applied bulk SearchReplace operations: BattleTroopTerrainTable → BattleArmyAffinityTerrainTable, Battle-scene → Battle Mode, battle scene phase → battle phase, strength → troop count, HP → troop count, troop type → army affinity, full-strength → full-troop-count, Hp → TroopCount in labels
4. Re-applied partial replacements that didn't fully apply on first pass (battle scene phase, strength, HP)
5. Verified zero stale terms remained via grep for all old tokens
6. Verified byte-exactness: ca65 error set identical to baseline (218 lines, same md5sum)

## Related files
- asm/banks/prg_0e_0f.asm

## Notes
- SearchReplace replace_all can leave stragglers when processing many occurrences; re-running the replacement after initial pass ensured complete coverage
- All renamed labels (BattleArmyAffinityTerrainTableA/B, BattleCellTroopCountDigitOverlay, @SideATroopCountFill/Tail/etc.) are local to prg_0e_0f.asm with no cross-file references
- Terminology distinction: HP in glossary = Vitality (officer stat); troop count = 兵数 (army/unit personnel); using "HP" for troop count was misleading and corrected

## Task overview
Successfully completed terminology alignment: eliminated ~100+ non-glossary terms across comments, labels, and procedure names; replaced with glossary-aligned terminology (battle, troop count, army affinity, Battle Mode); verified byte-exact zero drift via identical ca65 error set (218 pre-existing errors unchanged).
