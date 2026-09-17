# bank_switch_map.md terminology correction: war/tactical vs Battle Mode

- **Category:** task_summary_experience
- **Memory ID:** c49e1d1f-5f37-4af8-a455-2712a7ad765f
- **Keywords:** bank switch map, terminology correction, tactical war layer, Battle Mode distinction, prg_08_09.asm, label refactoring

## Content

## Task description
- Core requirement: Correct bank_switch_map.md to reflect that prg_08_09.asm handles the Tactical/War layer (army-level operations), not Battle Mode (piece-based sub-game)
- Task background: The file incorrectly labeled $08+$09 as "battle/AI" and used stale Battle* procedure names; terminology.md explicitly states the strategy-map engagement layer is Tactical Mode, with Battle Mode only being the piece-based sub-scenario

## Execution process
1. Read bank_switch_map.md to identify all "battle" references related to $08+$09
2. Verified terminology.md line 48: "code called 'BattlePhase' is actually Tactical Mode"
3. Confirmed prg_08_09.asm procedures already renamed to War*: WarSetup, WarPhaseProcess, WarAttritionRound, WarResultDispatch, etc.
4. Updated Section 2 & 3 matrices: "**$08+$09** (battle/AI)" → "(tactical war/AI)"
5. Updated Section 4.2 header to "Banks $08+$09 (prg_08_09.asm — tactical war layer)" with terminology citation
6. Renamed stale Battle* proc names to War* throughout Section 4.2: BattleAttritionRound→WarAttritionRound, BattleResult_*→WarResult_*, BattleSetup→WarSetup, BattlePhaseProcess→WarPhaseProcess, SetupPostBattleState→SetupPostWarState, BattleCasualtyResolution→WarCasualtyResolution
7. Updated Section 5.1 bank role: "battle engine" → "tactical war engine"
8. Updated Section 6 mermaid graphs: "$08+$09 battle" → "$08+$09 tactical war"
9. Updated Section 4.4 inline descriptions for consistency: $A012 (battle status panel)→(war status panel), $A027 (result scene init)→(war result scene init), $A006 (battle phase process)→(war phase process)
10. Deliberately left unchanged: NmiState3_Battle (bank $1F state name), $17+$18 row's "battle scene" (genuine Battle Mode content), $19 stubs "shared with battle overlay usage"

## Related files
- /home/zero/project/sango2dasm/code/bank_switch_map.md

## Notes
- None

## Task overview
Completed: Updated bank_switch_map.md to correctly characterize prg_08_09.asm as the tactical war layer across all sections (matrices, headers, procedure names, mermaid graphs). All stale Battle* labels replaced with current War* names verified against prg_08_09.asm. Terminology alignment confirmed with docs/manual_kb/terminology.md.
