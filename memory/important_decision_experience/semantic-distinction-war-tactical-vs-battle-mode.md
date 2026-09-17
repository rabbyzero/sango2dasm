# Semantic distinction: war/tactical layer vs Battle Mode in prg_08_09.asm

- **Category:** important_decision_experience
- **Memory ID:** 19852f62-c751-46c4-9bae-864f8f449149
- **Keywords:** battle war distinction, Tactical Mode, Battle Mode, naming semantics, prg_08_09.asm, label refactoring

## Content

## Semantic Analysis: prg_08_09.asm "Battle" vs "War" Distinction

**Core finding**: The file spans two distinct game layers, but labels conflate them. Per glossary hierarchy (Strategy > Tactical > Battle > Duel):
- **Tactical Mode / War layer**: Army-level operations on field map (army movement, officer stats, faction pairs, province indices) — NOT Battle Mode
- **Battle Mode**: Piece-based sub-game with formations, TacticPoints, Infantry/Archers/Cavalry units

### Labels requiring `battle_*` → `war_*` rename (RAM equates, $04xx-$05FF):
| Current | Suggested | Address | Justification |
|---|---|---|---|
| battle_scene_id | war_scene_id | $0500 | War scene/state machine index |
| battle_scene_phase | war_scene_phase | $0501 | War phase index |
| battle_side_flag | war_side_flag | $0504 | Used heavily in AiTurnProcess (tactical AI) |
| battle_action_points | war_action_points | $0505 | War action budget |
| battle_round_counter | war_round_counter | $0506 | War day counter |
| battle_faction_pair | war_faction_pair | $0507 | War faction pair |
| battle_officer_slot | war_officer_slot | $0509 | War officer slot |
| battle_scene_index | war_scene_index | $050A | War scene index |
| battle_province_idx | war_province_idx | $050E | War province index |
| battle_attacker_code | war_attacker_code | $050F | War attacker code |
| battle_side_selector | war_side_selector | $0514 | War side selector |
| battle_stat_a_lo/hi | war_stat_a_lo/hi | $0522-27 | War stat pairs |
| battle_stat_b_lo/hi | war_stat_b_lo/hi | $0526-27 | War stat pairs |
| battle_target_province | war_target_province | $052A | War target province |
| battle_target_officer | war_target_officer | $052B | War target officer |
| battle_target_param | war_target_param | $052C | War target param |
| battle_overlay_flag | war_overlay_flag | $04C8 | War overlay flag |
| battle_outcome_flag | war_outcome_flag | $6F44 | War outcome flag |

### Procedures requiring `Battle*` → `War*` rename:
| Current | Suggested | Range | Justification |
|---|---|---|---|
| BattleSetup | WarSetup | - | Sets up war engagement |
| BattlePhaseProcess | WarPhaseProcess | - | War phase dispatcher |
| BattleAttackerSetup | WarAttackerSetup | - | War attacker config |
| BattleDefenderSetup | WarDefenderSetup | - | War defender config |
| BattleExecute | WarExecute | - | War execution (populate arrays) |
| BattlePostProcess | WarPostProcess | - | Post-war updates |
| SetupPostBattleState | SetupPostWarState | - | Post-war state setup |
| BattleResultProcess | WarClashResolve | - | War clash resolution |
| BattleMapScrollUpdate | WarMapScrollUpdate | - | Tactical map scroll |
| BattleResultSceneInit | WarResultSceneInit | - | Post-war scene setup |
| BattleResultDispatch | WarResultDispatch | - | Post-war result state machine |
| BattleResult_* (7 phase procs) | WarResult_* | - | Post-war phases |
| BattleResultMenuPoll etc. | WarResultMenuPoll etc. | - | Post-war UI |
| BattleSlotClear | WarSlotClear | - | War slot clear |

### Genuinely Battle Mode (retain `Battle*` prefix):
- **BattleCasualtyResolution**: Morale/damage with formation slots, stat pairs
- **BattleAttritionRound**: Per-round attrition with formation slot values
- **BattleStatusPanelDraw**: Draws battle panel with $0505 counter

### Borderline / needs judgment:
- **AiOfficerActionDispatch**: State machine with formation setup, tile effects, stat transfers — this is the **Battle Mode presentation** layer. Name is OK, but header comment "(battle)" should be explicit.

### Cross-file impact:
- **prg_08_09.asm**: ~60+ labels (RAM equates, procs, data labels, comments)
- **functions.h**: 15 `B08_09_*` entry names need update
- **prg_1f.asm**: 3 references (`B08_09_BattleSetup_Entry`, `B08_09_AiTurnProcess_Entry`, `B08_09_BattleResultDispatch_Entry`)

### Decision principle:
When renaming creates cross-bank ambiguity (e.g., BattleResult vs WarResult), prefer distinct names to preserve semantic clarity. Retain existing BattleResult* names in battle banks only when they genuinely handle piece-level Battle Mode logic; otherwise rename to WarResult*.
