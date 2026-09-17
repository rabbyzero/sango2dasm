# TownFacilityMenuLayoutSelect decoded in prg_1b_1c.asm ($DCD0-$DD24)

- **Category:** task_summary_experience
- **Memory ID:** 30202c11-e0f9-4739-a4ee-68b1d2b2d6aa
- **Keywords:** TownFacilityMenuLayoutSelect, prg_1b_1c, data to code, facility menu, nested data tables, byte parity verification

## Content

Reclassified the raw byte block $DCD0-$DCF1 in asm/banks/prg_1b_1c.asm as code and merged it with the already-decoded $DCF2-$DD24 tail into a new proc TownFacilityMenuLayoutSelect ($DCD0-$DD24, bank $1C). Function: called only from @TownFacilityMenuInput ($C04D, TownCommandDispatch sub-state 1); routes on facility set id $0470 (sets 0-5 -> 2-item menu, 6-8 -> 3-item, 9 -> 4-item), loads item-index table into $10/$11 and cursor-row table into $13/$14, clears menu read index $12, tail-jumps into menu window engine $ED28 (still undecoded). Former bare labels Loc_DCF2/Loc_DD09/Loc_DD1D became @-locals @TwoItemLayout/@ThreeItemLayout/@MenuEngineEntry. The data region $DD25-$DD4E is nested inside the proc as @-labeled tables: item id tables @MenuItemIdTable2 ($DD25, ids 0-1)/@MenuItemIdTable3 ($DD2D, 0-2)/@MenuItemIdTable4 ($DD35, 0-3), each $FF-padded to 8 bytes; cursor-row tables (2-byte entries $C0,screen-Y) @MenuRowYTable2 ($DD3D, rows 78,A8 for 2-item menu)/@MenuRowYTable3 ($DD41, rows 60,90,C0 for 3-item)/@MenuRowYTable4 ($DD47, rows 60,80,A0,C0 for 4-item) - note the row-table numbering follows the item count of the menu that uses it, which is the reverse of address order. Caller JSR and TownCommandDispatch header doc use the symbolic name. Verified with tools/verify_1b_1c.py: compared 16384 bytes, 0 mismatches.
