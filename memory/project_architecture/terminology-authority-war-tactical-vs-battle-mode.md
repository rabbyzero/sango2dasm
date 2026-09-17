# Terminology authority for war/tactical vs Battle Mode distinction

- **Category:** project_architecture
- **Memory ID:** 9af68d5e-65a6-47bb-9a01-81253ae34097
- **Keywords:** terminology.md, game mode hierarchy, Tactical Mode, Battle Mode, War* naming convention, prg_08_09.asm

## Content

## Terminology Authority and Game Mode Hierarchy

**Authoritative source**: docs/manual_kb/terminology.md defines the game mode hierarchy as Strategy > Tactical > Battle > Duel.

**Key distinction**: The strategy-map engagement layer is **Tactical Mode** (army-level operations: officer movement, AI decision-making, province management, war engagement setup/resolution). Battle Mode is a separate piece-based sub-game with formations, TacticPoints, Infantry/Archers/Cavalry units.

**Naming convention verification**: 
- prg_08_09.asm procedures use `War*` prefix for tactical layer (WarSetup, WarPhaseProcess, WarAttritionRound, WarResultDispatch, etc.)
- `Battle*` prefix reserved for genuine Battle Mode content in battle banks ($17+$18)
- bank_switch_map.md must reflect "$08+$09 (tactical war/AI)" not "battle"

**Cross-file consistency**: functions.h entry names follow B08_09_War* pattern; all documentation must align with this semantic distinction to avoid conflating army-level tactical operations with piece-based battle scenarios.
