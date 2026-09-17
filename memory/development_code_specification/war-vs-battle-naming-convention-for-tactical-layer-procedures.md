# War* vs Battle* naming convention for tactical layer procedures

- **Category:** development_code_specification
- **Memory ID:** 80566bf3-d55b-4563-bd1b-26dc60ae0da9
- **Keywords:** naming convention, War* prefix, Battle* prefix, prg_08_09, tactical layer, Battle Mode

## Content

Naming convention for prg_08_09.asm: procedures and RAM equates handling the Tactical/War layer (army-level operations) must use the War* prefix (e.g., WarSetup, WarPhaseProcess, WarResultDispatch, war_rice, war_gold). The Battle* prefix is reserved exclusively for genuine Battle Mode content in banks $0E-$0F (e.g., BattleOverlayDispatch, BattleCellRedraw). This semantic distinction aligns with the game mode hierarchy defined in docs/manual_kb/terminology.md: Strategy > Tactical > Battle > Duel. Cross-bank entry points in functions.h follow B08_09_War* pattern for tactical layer procedures.
