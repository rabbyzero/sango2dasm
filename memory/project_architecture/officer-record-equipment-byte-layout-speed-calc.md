# Officer record equipment byte layout and speed calculation semantics

- **Category:** project_architecture
- **Memory ID:** b81d7697-9306-4a9b-b787-760d29e3e597
- **Keywords:** officer record, equipment byte, weapon armor encoding, initiative speed calculation, StrategyMode_CalcEquipSpeed

## Content

Officer record byte +$0A (decimal 10) encodes equipped weapon and armor: bits 0-4 contain weapon id (0-31), bits 5-7 contain armor id (0-7). The equipment catalog has exactly 24 weapons (ids 0-23) and 8 armors (ids 24-31), matching the bit fields. StrategyMode_CalcEquipSpeed ($B230-$B2BF in prg_17_18.asm) calculates per-commander initiative speed using this equipment data: speed = (record+0 Vitality + record+1 Might)/10 + $14 − (weapon weight + armor weight), where weights are looked up from StrategyMode_EquipWeightTable (32 entries, $00-$17 for weapons, $18-$1F for armors). The result is stored to player_random_offset_0,X and later reused by WarClash_DetermineOutcome and Duel_RandomEvent; a random 0-10 roll per side elects the faster side as active_player_slot (first actor). This speed calculation occurs in the war/tactical layer (prg_17_18.asm), not Battle Mode (banks $08-$0F).
