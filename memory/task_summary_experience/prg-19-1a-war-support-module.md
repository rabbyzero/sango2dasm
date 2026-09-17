# prg_19_1a.asm $B7D9-$BBDD war support module decoded and refactored

- **Category:** task_summary_experience
- **Memory ID:** c66a0814-12e1-45cf-a966-0bf3c6df8800
- **Keywords:** SortieWarCommit, TransferCapacityCalc, OfficerArrivalScan, CastleDevResultRoll, GoodsSendPrepare, GoodsSendApply, war pools, prg_19_1a, code analysis workflow

## Content

## Task description
- Core requirement: Code analysis workflow (Verify/Replace/Rename/Fix/Explain) on prg_19_1a.asm $B7D9-$BBDD, the raw region between ProvinceOfficerRosterDispatch ($B7D8) and MapProvinceDirtyMark ($BBDE).
- Task background: Six entry stubs ($A015-$A030) called only from prg_1b_1c via LDY #$39 trampolines; all Loc_ labels needed semantic renaming, branches symbolized, and data tables named.

## Execution process
1. Verified semantics of each stub caller in prg_1b_1c: SortieWarCommit ($A015) from SortieWarRequestGate, TransferCapacityCalc ($A018) from WarehouseDestProvinceSelect @DestAccepted, OfficerArrivalScan ($A01B) from undisclosed flow, CastleDevResultRoll ($A024) from CastleDevAnimWait, GoodsSendPrepare/GoodsSendApply ($A027/$A030) from intrigue payment flow.
2. Wrapped region in 5 .proc blocks: SortieWarCommit ($B7D9-$B8D6), TransferCapacityCalc ($B8D7-$B963), OfficerArrivalScan ($B964-$BA4F), CastleDevResultRoll ($BA70-$BB02), GoodsSendPrepare ($BB03-$BB72) + GoodsSendApply ($BB73-$BBDD).
3. Renamed all Loc_XXXX labels to @-prefixed semantic names; updated branch targets from hex addresses to label names.
4. Added full proc headers with RAM documentation, per-sub-state comments, and inline explanations for complex logic (war pool seizure, capacity min computation, officer arrival scan quirk, intrigue payment bias).
5. Named data tables: ArrivalParamTable ($BA50), DevIncrementTable ($BADF), DevResultIndexTable ($BAE8).
6. Updated functions.h with 6 new B19_1A_* equates; symbolized trampoline .word targets at $B25A/$A4C9 in prg_1b_1c; added JSR-line comments at $B86B/$CE4C/$D291/$DC18.
7. Fixed missing .endproc after OfficerArrivalScan (ca65 cascade error); re-ran verify harness.
8. Verified byte-exact with tools/verify_19_1a.py and tools/verify_1b_1c.py: 16384 bytes, 0 mismatches each.

## Related files
- asm/banks/prg_19_1a.asm
- include/functions.h
- asm/banks/prg_1b_1c.asm

## Notes
- Initial SearchReplace batch failed at replacement #17 due to incorrect original_text (BEQ $B870 followed directly by Loc_B865, but actual order has INY/JMP in between); tool applied partial edits before failing, requiring targeted fixes for remaining two labels.
- Spurious "save file failed" errors occurred on multiple SearchReplace calls but edits landed correctly; likely environment artifact.
- Missing .endproc after OfficerArrivalScan caused ca65 cascade of "undefined symbol" errors (nested proc symbols); inserting .endproc before CastleDevResultRoll header resolved all issues.
- Read tool can strip leading indentation of asm lines; verified exact whitespace with `sed | cat -A` before SearchReplace on this file.

## Task overview
Completed: Decoded 6 entry stubs into 5 semantic procedures with full headers, @-locals, symbolized branches, named data tables; updated functions.h and caller annotations; byte-exact verification passed with 0 mismatches across both banks.
