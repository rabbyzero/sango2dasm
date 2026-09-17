# ProvinceZoneOriginGet decoded in prg_1b_1c.asm ($DF25-$DF34)

- **Category:** task_summary_experience
- **Memory ID:** 4105f816-b3cc-4949-afd3-e3b123a6d72d
- **Keywords:** ProvinceZoneOriginGet, MapZoneOriginXTable, map zone origin, trampoline entry A009, map-half flag, prg_1b_1c

## Content

Code analysis of prg_1b_1c.asm Loc_DF25 ($DF25-$DF34), executed via the Verify/Replace/Rename/Fix/Explain workflow.

Verified semantics: ProvinceZoneOriginGet resolves the Province id in $000A (0-$1D, 30 map zones) to its map zone origin — X from table $DEE9 into $000B, Y from table $DF07 into $000C. Reached only via jump-table entry $A009 (stub JMP $DF25) from banks $19+$1A through B1F_BankedCallbackTrampoline (Y=$3B) at two sites: the annual-event handler ($AC2A-$AC4A) and MapHalfFlagByProvince ($CA2A-$CA41); both consume bit 7 of the X origin, inverted, as the map-half flag into $0150.

Changes applied:
1. Renamed Loc_DF25 -> ProvinceZoneOriginGet with a full header comment block.
2. Renamed stub Loc_A009 -> ProvinceZoneOriginGet_Entry (prg_1b_1c.asm).
3. Added functions.h SECTION 9 (Combined Banks $1B+$1C) with cross-bank equate B1B_1C_ProvinceZoneOriginGet_Entry = $A009.
4. Replaced both raw .word $A009 trampoline targets in prg_19_1a.asm ($AC32, $CA35) with the functions.h name; fixed the $AC32 comment that misattributed the target as MapHalfFlagByProvince (that is the caller wrapper, not the target).
5. Data region fix: the Y-origin table is $DF07-$DF24 (30 bytes); the spurious Loc_DF18 label split it. Merged rows under new labels MapZoneOriginXTable ($DEE9, 30 bytes) and MapZoneOriginYTable ($DF07, 30 bytes) with per-row index comments; updated all indexed references (hit test $DED1/$DEDC, sprite refresh $DFAE/$DFB4).
6. Folded unreferenced mid-proc label Loc_DF2B.

Verification: tools/verify_1b_1c.py and tools/verify_19_1a.py both report "compared 16384 bytes, 0 mismatches".
