# prg_0a_0b LevelActionModifiers split into 4 semantic tables, byte-neutral

- **Category:** task_summary_experience
- **Memory ID:** (ID not exposed by tooling; title-only availability)
- **Keywords:** LevelActionModifiers, semantic tables, byte-neutral, prg_0a_0b

## Content

(Content unavailable — this memory's title appears in the memory tree, but full content could not be retrieved: the fetch parser rejects the comma in the exact title and keyword search does not surface it. Title-only record preserved for completeness.)

The task split the AI modifier table @LevelActionModifiers in prg_0a_0b.asm into 4 semantic tables (one per game level 0-2 plus header, indexed by sram_game_level) without changing any ROM bytes. Corroborating dumped memories: development_code_specification "$6F02 is the game level indicator selected at new game" (e8f00569) documents that $6F02 indexes @LevelActionModifiers, @LevelTierModifiers, CalcArmyTierAndRender ThresholdTable columns, and CalcActionProb @Thresholds in prg_0a_0b.asm; project_architecture "$6F02 is game level indexing recount scaling tables" (48a19023) documents the attract-demo read side in prg_19_1a.asm.
