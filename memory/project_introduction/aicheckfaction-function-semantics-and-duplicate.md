# AiCheckFaction function semantics and duplicate

- **Category:** project_introduction
- **Memory ID:** 9c859667-e792-48dc-a35c-880dfa4058f5
- **Keywords:** AiCheckFaction, faction check, bit7 XOR, Y register, duplicate routine

## Content

In prg_08_09.asm, `AiCheckFaction` ($A944–$A95B) determines if an officer (indexed by Y) is enemy or ally by XORing bit7 of `$0504` (acting side) with bit7 of `$0628,Y` (officer faction). Output: A=$80 (enemy, N=1), A=$00 (ally, N=0); Y preserved. Used in AI turn processing for filtering and classification. Call sites: $A04D (AiTurnProcess), $A893 (AiScanAdjacentOfficers), $A935 (AiFindNearbyOfficers), $B098 (coordinate accumulation), $CB74 (ally scan). A byte-identical duplicate exists at $CC92 in prg_09.bin, used by 10 civil routine call sites; both copies must be retained for ROM compatibility.
