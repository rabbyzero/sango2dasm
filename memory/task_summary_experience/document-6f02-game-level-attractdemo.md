# Document $6F02 game level in prg_19_1a.asm AttractDemoDispatch comments

- **Category:** task_summary_experience
- **Memory ID:** 75e9c14e-02dc-4969-b2ed-3b6c5a01d40c
- **Keywords:** prg_19_1a, game level, $6F02, AttractDemoDispatch, comment update, RAM documentation

## Content

## Task description
- Core requirement: Document $6F02 as the game level indicator (values 0-2) in prg_19_1a.asm attract demo code
- Task background: The user clarified that $6F02 represents the game difficulty level selected at new game start; existing comments in the AttractDemoDispatch RAM list omitted $6F02, and the troop/gold recount scaling tables lacked explicit linkage to the game level index

## Execution process
1. Updated AttractDemoDispatch header comment (lines 62-64 in prg_19_1a.asm): inserted "$6F02 game level (0-2)" between the rotation step ($6F01) and focused Country slot ($6F03) in the demo RAM list
2. Updated @TroopRecountScaleBaseTable/@TroopRecountScaleDivTable comment: changed "indexed by $6F02 (0-2)" to "indexed by game level $6F02 (0-2)" to clarify the semantic meaning
3. Ran verification harness (tools/verify_19_1a.py): compared 16384 bytes, 0 mismatches - confirmed byte-exact edits with no drift

## Related files
- asm/banks/prg_19_1a.asm

## Notes
None

## Task overview
Successfully documented $6F02 as game level (0-2) in two locations within prg_19_1a.asm: the AttractDemoDispatch header RAM list now includes $6F02 alongside adjacent demo RAM addresses, and the recount scaling table comment explicitly references the game level index. Verification confirmed zero byte drift.
