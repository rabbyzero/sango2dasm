# Sangokushi 2 terminology update: Ruler/Country/Province model and game mode hierarchy

- **Category:** task_summary_experience
- **Memory ID:** 910a58e7-4f65-497a-94af-a9a17d33450a
- **Keywords:** Sangokushi 2 disassembly, terminology correction, Ruler Country Province, game mode hierarchy, byte drift verification, state handler rename

## Content

## Task description
- Core requirement: Update Sangokushi 2 disassembly terminology to match user-confirmed domain model and game mode hierarchy
- Task background: Previous terminology updates had incorrect names for province/country concepts and game modes; user clarified that "DomesticAffairs" is Strategy Mode, "BattlePhase" is Tactical Mode, and established the nesting hierarchy (Strategy > Tactical > Battle > Duel); also clarified Ruler rules Country, Country has Provinces, and 城 means City not Castle except in castle command context

## Execution process
1. prg_1f.asm: Reverted GetCountryRecordAddr → GetProvinceRecordAddr ($F2AF); renamed GetRulerDataPtr → GetCountryDataPtr ($F368), RulerDataPtrTable → CountryDataPtrTable; updated header comment and all related comments about province records
2. prg_1f.asm: Renamed State_DomesticAffairs → State_StrategyMode ($E22F); State_BattlePhase → State_TacticalMode ($E2E8); DomesticActionLookup → StrategyCommandLookup ($E29C); updated vector table entries and inline comments
3. functions.h: Updated B1F state block to canonical names (B1F_State_StrategyMode, B1F_State_TacticalMode, B1F_GetProvinceRecordAddr, B1F_GetCountryDataPtr, B1F_StrategyCommand*); renamed B17_18_DomesticDisplay and B17_18_DomesticActionDispatch references where only used as equates
4. prg_08_09.asm/prg_0c_0d.asm/prg_17_18.asm: Updated ~35 call sites of B1F_GetRulerDataPtr → B1F_GetCountryDataPtr and related comments ("ruler's record" → "country's record")
5. terminology.md: Added Province (州) entry; split 城 into City/Castle distinction; added "Domain model: Ruler / Country / Province" section; added "Game mode hierarchy" section documenting Strategy > Tactical > Battle > Duel nesting
6. Verification: grep confirmed no stale references to old names; ca65 assembly + ld65 link successful; byte parity unchanged (7890 diff bytes / 40 checker mismatches identical to pre-edit state)

## Related files
- asm/banks/prg_1f.asm
- include/functions.h
- docs/manual_kb/terminology.md
- asm/banks/prg_08_09.asm
- asm/banks/prg_0c_0d.asm
- asm/banks/prg_17_18.asm

## Notes
- Bank $17's internal Domestic* names (B17_18_DomesticDisplay, B17_18_DomesticActionDispatch, domestic_* RAM map) were left unchanged as they're tied together across that bank; renaming them would require a separate bank-wide refactoring task
- Pre-existing standalone assembly failures in prg_08_09/prg_0c_0d/prg_17_18 are unrelated to this change (identical errors at HEAD)
- Renames are byte-neutral; verification harness comparing mismatch sets before/after confirms zero drift

## Corrections (2026-08)
- The deferred bank-wide Domestic* refactoring of prg_17_18.asm was completed in a later task: DomesticAffairsDispatch/DomesticAffairs_* → StrategyModeDispatch/StrategyMode_*; DomesticActionDispatch/DomAction_* → StrategyCommandDispatch/StrategyCommand_*; DomesticDisplay → StrategyModeDisplay; domestic_*/dom_* RAM → strategy_*/strat_*; SingleCombat* → Duel*; sram_kingdom_* → sram_country_*. functions.h B17_18_* equates were renamed accordingly (B17_18_StrategyModeDisplay, B17_18_StrategyCommandDispatch, B17_18_StrategyMode*, B17_18_Duel*) and the two prg_1f.asm call sites updated. So this note's "left unchanged" statement no longer applies.

## Corrections (2026-09) — the state-7 mode attribution in step 2 was wrong
- `State_BattlePhase` → `State_TacticalMode` ($E2E8, state 7) mis-assigned the
  state: it stores addr_sub_state = 5, so its frames run NmiState5_Duel ($F9A0) →
  B17_18_DuelModeDispatch ($F9CD: strike resolution, flee/pursuit, surrender,
  persuade/insult, duel intros, spoils), it uploads the duel base nametable bank
  $10 $8400, and the only writer of addr_game_state = 7 in the ROM is
  Phase5SideEventPanelSetup $CD66 (Battle Mode phase 5 side event). It is now
  `State_DuelSceneLaunch`. Tactical Mode (the war/field layer) is states 3 and 4
  (State_WarSceneLaunch $E18B, State_WarAiTurnFrame $E221). The hierarchy itself
  (Strategy > Tactical > Battle > Duel) still stands; only this state's slot in
  it was wrong.
- Method lesson (now in docs/manual_kb/terminology.md and
  code/initial_data_tables.md §9): attribute a state proc to a mode from the
  bytes — the addr_sub_state it stores (which NMI handler runs) plus every writer
  of addr_game_state — not from manual terminology alone. Enumerate them with
  `python tools/scan_ram_writers.py --addr 007A` (or 0078).
- The same evidence also renamed $E0DA `State_NewGameInit` →
  `State_StrategyMapLaunch` (it re-runs on every return to the strategy map; the
  new-game re-seed is Entry 11 State_NewGameSetup).

## Task overview
Completed terminology corrections across six files: established correct Ruler/Country/Province domain model with GetProvinceRecordAddr ($F2AF) and GetCountryDataPtr ($F368) identifiers; updated game mode hierarchy from flat naming to nested Structure (Strategy > Tactical > Battle > Duel); verified byte-exactness maintained through mismatch set comparison; recorded both domain models in project memory for future reference.
