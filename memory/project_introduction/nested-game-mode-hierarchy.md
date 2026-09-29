# Nested game mode hierarchy: Strategy > Tactical > Battle > Duel

- **Category:** project_introduction
- **Memory ID:** ec8408a5-4bd9-4f06-90e7-5ebca486eed2
- **Keywords:** Game mode hierarchy, Strategy Mode, Tactical Mode, Battle Mode nesting, Duel Mode

## Content

Sangokushi 2 game modes nest, they are not peers (user-confirmed, recorded in docs/manual_kb/terminology.md): Strategy Mode (戦略モード) is the map-level affairs loop — what older code named "DomesticAffairs" is Strategy Mode (State_StrategyMode, state 5, $E22F; the map screen is launched by State_StrategyMapLaunch, state 1, $E0DA). Tactical Mode (戦術モード) is the field/army layer = this codebase's "war" scene: states 3 and 4 (State_WarSceneLaunch $E18B, State_WarAiTurnFrame $E221, AI in bank $08+$09 AiTurnProcess). Battle Mode (戦闘モード) is a sub-scenario of Tactical Mode (bank $0E+$0F phase machine). Duel Mode (一騎討ちモード) is a sub-scenario of Battle Mode: game state 7 $E2E8, entered only from Battle Mode phase 5 (Phase5SideEventPanelSetup $CD66), sub-state 5 -> NmiState5_Duel -> bank $17+$18 DuelModeDispatch. Correction to an earlier claim here: state 7 was renamed State_BattlePhase -> State_TacticalMode on terminology grounds, but that was wrong; it is now State_DuelSceneLaunch. Lesson: attribute a state proc to a mode by the addr_sub_state it stores (which NMI handler runs) and by every writer of addr_game_state (tools/scan_ram_writers.py), not by manual terminology alone. Avoid "domestic affairs"/"battle phase" in new labels.
