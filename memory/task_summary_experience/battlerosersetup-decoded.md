# BattleRosterSetup decoded in prg_0e_0f.asm ($B548-$B86F)

- **Category:** task_summary_experience
- **Memory ID:** 1517df63-01c2-4b22-808b-3c4c833005e4
- **Keywords:** BattleRosterSetup, formation layouts, unit class bounds, roster codes, column HP distribution

## Content

prg_0e_0f.asm $B548-$B86F decoded: BattleRosterSetup (.proc $B548-$B793, called from Loc_D054 at battle start) clears the $58-byte roster block $0580-$05D7, then per side (officer ids $0560/$0561, records via B1F_GetOfficerRecordAddr): record[0] -> side strength $05AC/$05B7; troop total = record[9]:[8], column count = ceil(troops/100) -> $0566/$0567, troops split into per-column HP $05AD/$05B8 (first troops%count columns get ceil share); unit-class roster codes $05C2/$05CD (high nibble 3/2 = side; low nibble 0 commander, 1-3 classes) composed via BattleUnitGradeLimitTable ($B7AC, 32 byte-pairs, index ((record[$B]>>4)<<2 | grade)*2, grade from record[1] vs $50/$32); placement via BattleFormationPtrTable ($B794, 12 ptrs) into 11-byte column layouts $B7EC-$B82D ($0580/$058B, side B mirrors $0F-col) and row layouts $B82E-$B86F ($0596/$05A1), index i = $056C&3 / $056D&3; battle scene phase 5 forces side B to index 4 with split layouts (entries 4/10 for class-2 slots, 5/11 otherwise) and zeroes the class-3 bound. Verified byte-exact via tools/verify_0e_0f.py.
