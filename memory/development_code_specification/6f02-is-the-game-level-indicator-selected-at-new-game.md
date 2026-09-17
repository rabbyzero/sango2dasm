# $6F02 is the game level indicator selected at new game

- **Category:** development_code_specification
- **Memory ID:** e8f00569-616f-4180-b3a5-ace2c713dd41
- **Keywords:** $6F02, game level, sram_game_level, new game selection, per-level AI tables

## Content

SRAM address $6F02 is the game level indicator (values 0-2), selected by the player when starting a new game. It indexes per-level AI tables in prg_0a_0b.asm (@LevelTierModifiers at level*4+tier, @LevelActionModifiers, CalcArmyTierAndRender ThresholdTable columns, CalcActionProb @Thresholds) and is also read in prg_0c_0d.asm ($B81D), prg_0e_0f.asm ($D1DE+), and latched in prg_08_09.asm BattleResult_InitRecords (currently named result_kingdom_idx — stale name). The canonical equate is sram_game_level in prg_0a_0b.asm.
