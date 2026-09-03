# Nested game mode hierarchy: Strategy > Tactical > Battle > Duel

- **Category:** project_introduction
- **Memory ID:** ec8408a5-4bd9-4f06-90e7-5ebca486eed2
- **Keywords:** Game mode hierarchy, Strategy Mode, Tactical Mode, Battle Mode nesting, Duel Mode
- **Usage scenarios:**
  - Naming state handlers and mode-related labels
  - Writing comments about game flow transitions
  - Translating Japanese mode terms in manual KB

## Content

Sangokushi 2 game modes nest, they are not peers (user-confirmed, recorded in docs/manual_kb/terminology.md): Strategy Mode (戦略モード) is the map-level affairs loop — what older code named "DomesticAffairs" is Strategy Mode (renamed State_StrategyMode, state 5, $E22F). Tactical Mode (戦術モード) is the field/army layer — what older code named "BattlePhase" is actually Tactical Mode (renamed State_TacticalMode, state 7, $E2E8). Battle Mode (戦闘モード) is a sub-scenario of Tactical Mode, and Duel Mode (一騎討ちモード) is a sub-scenario of Battle Mode. Avoid "domestic affairs"/"battle phase" in new labels and comments; use strategy/tactical accordingly.
