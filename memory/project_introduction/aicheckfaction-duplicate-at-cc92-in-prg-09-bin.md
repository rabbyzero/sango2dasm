# AiCheckFaction duplicate at $CC92 in prg_09.bin

- **Category:** project_introduction
- **Memory ID:** 5bbfdad5-f467-4385-a737-92f6de47ca56
- **Keywords:** AiCheckFaction, duplicate routine, $CC92, faction check, officer targeting

## Content

The AiCheckFaction function has a byte-identical duplicate at $CC92 in prg_09.bin (prg_08_09.asm). The original at $A944-$A95B determines if an officer (indexed by Y) is enemy or ally by XORing bit7 of $0504 (acting side) with bit7 of $0628,Y (officer faction), returning A=$80 (enemy, N=1) or A=$00 (ally, N=0) with Y preserved. The duplicate at $CC92 is called from multiple locations including Loc_C983 Phase 1 ($C983+$) for filtering ally officers during damage accumulation. Both copies must be retained for ROM compatibility. Call sites of the original include $A04D (AiTurnProcess), $A893 (AiScanAdjacentOfficers), $A935 (AiFindNearbyOfficers), $B098 (coordinate accumulation), and $CB74 (ally scan).
