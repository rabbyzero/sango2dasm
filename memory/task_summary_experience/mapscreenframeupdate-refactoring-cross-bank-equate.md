# MapScreenFrameUpdate procedure refactoring and cross-bank equate addition

- **Category:** task_summary_experience
- **Memory ID:** 6e07e276-6f30-423d-a020-f68e02c1d759
- **Keywords:** MapScreenFrameUpdate, prg_1b_1c, .proc wrapping, cross-bank equate, B19_1A_MapProvinceDirtyMark, byte-exact verification

## Content

## Task description
- Core requirement: fix raw address reference at $A017 in MapScreenFrameUpdate and wrap the procedure into .proc ending at $A044
- Task background: prg_1b_1c.asm contains MapScreenFrameUpdate ($A00C-$A044) as bare labels; the trampoline target at $A017 used raw `.word $A02A` instead of cross-bank name; the routine needed proper .proc encapsulation per assembly conventions

## Execution process
1. Added missing cross-bank equate `B19_1A_MapProvinceDirtyMark = $A02A` to functions.h line 684 following BXX_YY_* naming convention
2. Replaced `.word $A02A` with `.word B19_1A_MapProvinceDirtyMark` in prg_1b_1c.asm line 50, keeping hex-byte comment
3. Wrapped MapScreenFrameUpdate ($A00C-$A044) into `.proc MapScreenFrameUpdate` / `.endproc`, placing .endproc immediately before Loc_A045 at $A045
4. Verified scoping: internal labels MapScreenFrameStateDispatch and MapScreenFrameStateTable remain proc-local; external JMP MapScreenFrameUpdate from entry stub resolves to proc name
5. Verified byte-exactness with tools/verify_1b_1c.py: compared 16384 bytes, 0 mismatches
6. Confirmed full make failure was pre-existing (Loc_* symbol collisions between prg_1b_1c.asm and prg_19_1a.asm), unrelated to changes

## Related files
- /include/functions.h
- /asm/banks/prg_1b_1c.asm

## Notes
- Full build failure due to cross-file Loc_* symbol collisions is pre-existing and unrelated to this work; per-bank harness used for verification
- Cross-bank equate was missing from functions.h; jump-table section only covered $A000-$A024 while $A02A stub needed separate entry

## Task overview
Completed: added B19_1A_MapProvinceDirtyMark equate and replaced raw address with symbolic reference; wrapped MapScreenFrameUpdate into .proc with byte-exact verification (16384 bytes, 0 mismatches).
