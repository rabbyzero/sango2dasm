# prg_17_18.asm bank-wide terminology alignment with glossary

- **Category:** task_summary_experience
- **Memory ID:** 4a4f987f-b0e7-456e-b522-7f42a600b6bf
- **Keywords:** prg_17_18 refactor, StrategyCommandDispatch, DuelDispatch, sram_country, terminology alignment

## Content

## Task description
Align prg_17_18.asm labels, RAM symbols, and comments with docs/manual_kb/terminology.md (this was the bank-wide Domestic* refactor deferred by the earlier terminology task).

## Execution process
1. Renames in asm/banks/prg_17_18.asm: DomesticAffairsDispatch/DomesticAffairs_* → StrategyModeDispatch/StrategyMode_*; DomesticActionDispatch/DomAction_* → StrategyCommandDispatch/StrategyCommand_* (matches prg_1f's existing StrategyCommandLookup style); DomesticDisplay → StrategyModeDisplay (+_Entry labels); DomesticTilePtrTable/DomesticAttrPtrTable → StrategyMode*PtrTable; DomAnim_FrameTable → StratAnim_FrameTable; SingleCombatDispatch/SingleCombat_* → DuelDispatch/Duel_*; domestic_* RAM → strategy_*; dom_* RAM → strat_*; sram_kingdom_data/param_0/1 → sram_country_data/param_0/1
2. Comment updates: kingdom→country, "Domestic affairs display"→"Strategy Mode display", "Domestic action state N"→"Strategy command state N", "Domestic Action System"→"Strategy Command System"
3. Kept unchanged (glossary-legal or unverified semantics): CombatCalc_*, BattleResult_*, TroopAssign*, IntrigueDispatch, BattleDispatch/BattleInit*
4. Cross-file consistency: functions.h B17_18_* equates renamed to match (B17_18_StrategyMode*, B17_18_StrategyCommandDispatch, B17_18_StrategyModeDisplay, B17_18_Duel*) and the 2 prg_1f.asm call sites updated
5. Verification: full ca65 build has pre-existing failures (duplicate symbols across banks); captured the 107-line error output before and after — diff shows ERROR SET IDENTICAL, i.e. zero new errors from the renames; grep confirmed no stale Domestic/kingdom/SingleCombat tokens remain

## Related files
- asm/banks/prg_17_18.asm, asm/banks/prg_1f.asm, include/functions.h, tools/disasm_0a_0b.py

## Notes
- SearchReplace replace_all can leave stragglers when a token is a substring of another; always re-grep for the old token after bulk renames
- For symbol-only renames in this repo, byte parity is proven via identical ca65 error sets since the full build cannot link (pre-existing)
- The working tree already contained pre-existing uncommitted changes; git HEAD cannot be used as a pre-edit baseline for prg_17_18.asm

## Corrections (2026-08, later session)
- Item 3 is superseded: after analysis showed CombatCalc/BattleResult are war/tactical-layer (not Battle Mode), a follow-up rename was applied in prg_17_18.asm: CombatCalcDispatch/CombatCalc_* → WarClashDispatch/WarClash_*; BattleResultDispatch/BattleResult_* → WarResultDispatch/WarResult_*; battle_result_phase → war_result_phase ($042E). functions.h equates renamed accordingly (B17_18_WarClash*, B17_18_WarResult*). The B08_09_BattleResult* equates (true battle-phase handlers) were intentionally kept. Verified again via identical 107-line ca65 error set.
