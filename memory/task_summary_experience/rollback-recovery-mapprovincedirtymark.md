# Rollback recovery of MapProvinceDirtyMark changes in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** 7ff9a326-65fb-4b46-9dc6-1fdd63d1032b
- **Keywords:** rollback recovery, prg_19_1a.asm, MapProvinceDirtyMark, re-apply changes, byte verification

## Content

## Task description
- Core requirement: Re-apply changes to prg_19_1a.asm that were rolled back by another quest
- Task background: The MapProvinceDirtyMark procedure ($BBDE-$BC01) had been previously refactored with semantic naming, .proc encapsulation, and cross-scope reference fixes. Another quest reverted prg_19_1a.asm to its raw state while leaving cross-references in prg_1b_1c.asm and bank_switch_map.md intact.

## Execution process
1. Read current state of prg_19_1a.asm to confirm rollback status (file was 6594 lines, showing raw Loc_ labels)
2. Grep for MapProvinceDirtyMark references to verify file was reverted and cross-references survived in other files
3. Re-apply all changes: stub JMP at $A02A, JSR at $A988 with Proc::ByZone syntax, and full .proc block with header comment at line 3189
4. Run verification harness (tools/verify_19_1a.py) to confirm byte-exact integrity

## Related files
- /asm/banks/prg_19_1a.asm

## Notes
- Cross-references in prg_1b_1c.asm and bank_switch_map.md were not rolled back, so no re-application was needed there
- File line count changed from 6710 to 6594 before edits, indicating prior modifications existed
- Verification confirmed 16384 bytes compared, 0 mismatches after re-application

## Task overview
Successfully re-applied MapProvinceDirtyMark semantic renaming, .proc encapsulation, and cross-scope reference fixes to prg_19_1a.asm; verified byte-exact integrity with 16384 bytes, 0 mismatches (ca65 assembly succeeded).
