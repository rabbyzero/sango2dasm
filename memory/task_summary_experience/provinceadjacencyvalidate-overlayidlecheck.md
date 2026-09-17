# ProvinceAdjacencyValidate and OverlayIdleCheck decoded in prg_1b_1c.asm ($DD79-$DDBE)

- **Category:** task_summary_experience
- **Memory ID:** 7a6db5f6-58e5-4b6a-9696-5720ba30d998
- **Keywords:** ProvinceAdjacencyValidate, OverlayIdleCheck, adjacency table, prg_1b_1c, bank $10

## Content

Loc_DD79 chunk ($DD79-$DDBE) of prg_1b_1c.asm decoded into two .procs, byte parity re-verified 0 mismatches via tools/verify_1b_1c.py (external stubs 13->12).

1. ProvinceAdjacencyValidate ($DD79-$DDAC, bank $1C): validates the castle-move candidate target. Switches the $8000 window to bank pair $10+$11 via B1F_SwitchBank8_B (Y=$30, $30&$1F=$10) and scans the per-province province adjacency table at $9D72 in bank $10 (8-byte $FF-terminated slot per province id; slot offset = source*8; bank $10 still undecoded, referenced by raw address). Source province $0470 vs candidate target $0402: target==source or not in source's adjacency slot -> $0402 <- $80 sentinel (caller tests BMI). Valid -> B1F_GetProvinceRecordAddr (input register is A, not X; A = matched table entry) fetches the target record and stores owner Country id (record byte 0 & $07) into $0010. Side effect: $8000 window stays on $10/$11 after return (callers only use in-bank and fixed-bank $1F code afterwards). 3 call sites, all after the $DEBA map-cursor->province hit test: CastleMoveTargetSelect $A704 (owner must be own/unclaimed), attack target pick $AF42 (owner must NOT be own), transport destination pick $B849 (owner must be own). Fixed stale caller comment "road id 7" -> Country 7 = unclaimed (UnclaimedLand).

2. OverlayIdleCheck ($DDAD-$DDBE, bank $1C): returns C=1 only while both overlay/animation queue slot headers $0300/$0304 (anim_queue_hdr0/hdr1, prg_0e_0f equates) are $FF; C=0 while either overlay busy. 59 call sites renamed JSR $DDAD -> JSR OverlayIdleCheck via SearchReplace; 3 prose comment references updated to name+address.

Pitfall reinforced: SearchReplace replace_all failed twice with "Failed to match" on a string grep could see ("JSR $DDAD"); retrying with two leading spaces included in original_text ("  JSR $DDAD") succeeded immediately — include indentation context when a short replace_all pattern fails. Also: earlier caller greps were truncated at 25 matches and missed 2 of 3 call sites — always re-grep with count before writing "sole caller" headers.
