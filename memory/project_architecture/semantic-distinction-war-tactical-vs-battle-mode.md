# Semantic distinction: war/tactical layer vs Battle Mode in prg_08_09.asm

- **Category:** project_architecture
- **Memory ID:** 85b3ad14-e3cd-49fa-ae07-f59aee85fe4d
- **Keywords:** war tactical layer, Battle Mode, prg_08_09.asm, semantic distinction, naming convention
- **Usage scenarios:**
  - Deciding whether to rename Battle* labels in tactical mode code
  - Determining which procedures belong to Battle Mode vs war layer
  - Planning large-scale label refactoring across multiple files

## Content

The prg_08_09.asm file handles the war/tactical layer (戦術モード), not Battle Mode (戦闘モード). The war layer includes army-level operations on the tactical map: officer movement, AI decision-making, province management, war engagement setup/resolution, and post-war result screens. Battle Mode is a separate piece-based sub-game with Infantry/Archers/Cavalry units, formations (Serpent/Goose/Wedge/FishScale), commands (Advance/Withdraw/Hold/Surround), and TacticPoints system. This distinction requires renaming all "Battle*" prefixed labels to "War*" in prg_08_09.asm to align with the glossary terminology. The file contains RAM equates at $04xx-$05FF for war scene state, procedures like WarSetup, WarPhaseProcess, WarResultDispatch, and data tables for post-war result scenes. Cross-bank entry points are registered in functions.h with B08_09_War* prefix pattern.
