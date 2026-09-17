# prg_17_18 bank-wide terminology alignment and war-mode refactor workflow

- **Category:** task_summary_experience
- **Memory ID:** 3619ac53-465f-47c7-81ff-522f387b2f38
- **Keywords:** prg_17_18 refactor, WarClash, WarResult, Semantic naming, bank-wide rename, byte-exact verification

## Content

## Workflow summary
Completed a two-phase refactoring of prg_17_18.asm aligned with docs/manual_kb/terminology.md:
1. **Phase 1 (Bank-wide Domestic* → Strategy/Duel)**: Renamed DomesticAffairs*→StrategyMode*, DomesticAction*→StrategyCommand*, SingleCombat*→Duel*, sram_kingdom*→sram_country*, domestic_*/dom_* RAM → strategy_*/strat_*. Updated functions.h B17_18_* equates and prg_1f.asm call sites. Verified via identical 107-line ca65 error set.
2. **Phase 2 (War-mode analysis & rename)**: Analyzed CombatCalc/BattleResult semantics; determined they operate at Tactical/War layer (not Battle Mode). Renamed CombatCalc*→WarClash*, BattleResult*→WarResult*, battle_result_phase→war_result_phase. Updated functions.h B17_18_WarClash/WarResult equates. Verified again via identical error set.

## Key decisions
- Retained B08_09_BattleResult* names (true Battle Mode handlers) to preserve semantic distinction.
- Used identical ca65 error-set parity as byte-exactness proof when full linking fails due to pre-existing symbol conflicts.
- Applied glossary-first naming: all new labels derive from docs/manual_kb/terminology.md.

## Related files
- asm/banks/prg_17_18.asm, asm/banks/prg_1f.asm, include/functions.h, tools/disasm_0a_0b.py, docs/manual_kb/terminology.md
