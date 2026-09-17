# Re-apply AttractDemoDispatch decode and helpers after rollback

- **Category:** task_summary_experience
- **Memory ID:** 5ae9bbdf-5bcb-4802-b828-8cbed1484b6e
- **Keywords:** AttractDemoDispatch, rollback recovery, prg_19_1a.asm, .proc encapsulation, helper routines

## Content

## Task description
- Core requirement: Re-apply semantic decoding changes to the $A033-$A295 region in asm/banks/prg_19_1a.asm after it was rolled back by another quest.
- Task background: The previous session decoded Loc_A033 as AttractDemoDispatch (frame state $0B handler), converted it to a `.proc` with inner sub-state labels, and recovered misclassified code regions. The MapProvinceDirtyMark proc and $AFE5 roster decode survived the rollback, but the $A033-$A295 region was reset to raw `Loc_` labels.

## Execution process
1. Inspected current file state via grep and git log to confirm the rollback affected only the $A033-$A295 region while other changes persisted.
2. Verified no external callers had been updated to use semantic names for the helper routines ($A1C2, $A1EB) — all still used raw hex addresses (`JSR $A1C2`, `JSR $A1EB`).
3. Re-applied the full change set in two SearchReplace operations:
   - Block 1: Entry stub (`AttractDemoDispatch_Entry`), dispatch head, sub-state 0, and data tables (`CountryRecordPtrTable`, `ProvinceCountDisplayTable`, `AttractCountryOrderTable`).
   - Block 2: Sub-states 1-3, `.endproc`, and five helper routines (`ProvinceCountByOwner`, `MarkerSpriteDraw`, `FindOfficerProvince`, `DecayCountryTimers`, `AttractDemoCensusBuild`).
4. Verified byte-exactness using tools/verify_19_1a.py: compared 16384 bytes, 0 mismatches.

## Related files
- asm/banks/prg_19_1a.asm

## Notes
- External callers in other banks continue to reference helpers via raw hex addresses; this is safe because the addresses match the newly named procedures.
- The verification harness correctly stubs external JSR targets that lack `Loc_` definitions, ensuring zero drift despite semantic renaming.

## Task overview
Completed: Successfully restored the AttractDemoDispatch decode and helper routines to their final `.proc` form. Byte-exact verification passed with 0 mismatches. The region now matches the end-of-Turn-2 state from the previous session.
