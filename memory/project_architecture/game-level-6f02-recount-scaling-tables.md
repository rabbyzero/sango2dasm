# $6F02 is game level indexing recount scaling tables

- **Category:** project_architecture
- **Memory ID:** 48a19023-41a8-4262-ab3e-fb5a0871336f
- **Keywords:** $6F02, game level, difficulty, attract demo RAM, prg_19_1a

## Content

Attract-demo RAM in prg_19_1a.asm: $6F02 is the game level (0-2). It indexes the recount scaling tables @TroopRecountScaleBaseTable ($A524: $64,$3C,$3C) and @TroopRecountScaleDivTable ($A527: $03,$03,$04) in ProvinceTroopRecount, and the identical tables at $A6E9 in ProvinceGoldRecount. Higher game level lowers the per-province troop/gold reinforcement base (100 -> 60) and raises the divisor (3 -> 4). Stated by the user; adjacent demo RAM: $6F00 demo year counter, $6F01 rotation step, $6F03 focused Country slot.
