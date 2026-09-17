# AiOfficerActionDispatch inline jump table fix and ROM verification

- **Category:** task_summary_experience
- **Memory ID:** 6439cb66-9d8d-49d7-8c09-0a95d1702fea
- **Keywords:** AiOfficerActionDispatch, state machine, dispatch table, CallbackDispatcher, inline jump table, ROM verification, prg_08_09

## Content

## Task description
- Core requirement: Replace the dispatcher reference at $C0BE with a semantic name and convert the inline jump table at $C0C1-$C0D4 from .byte data to symbolic .word references in prg_08_09.asm
- Task background: The AiOfficerActionDispatch state machine ($C0BB-$C982) uses B1F_CallbackDispatcher for dispatching to 10 state handlers. The original disassembly had errors: claimed 14 entries (actually 10), embedded State 0 handler code inside .byte lines, and contained fabricated code blocks not present in ROM.

## Execution process
1. Verified ROM bytes at bank 9 offset $00BB using Python script; confirmed table structure is 10 little-endian .word entries ($C0C1-$C0D4) pointing to handlers at $C0D5, $C1EB, $C2C0, $C392, $C3E9, $C4B8, $C543, $C62E, $C7B0, $C7C8
2. Replaced JSR $EADE with JSR B1F_CallbackDispatcher (cross-bank naming convention per functions.h)
3. Converted two .byte lines into 10 symbolic .word entries with proper labels
4. Extracted the genuine State 0 handler code ($C0D5-$C117) from the embedded .byte region and replaced the fabricated $C0DD block that didn't exist in ROM
5. Updated comments to reflect correct 10-entry table instead of erroneous 14-entry claim
6. Verified build: remaining errors are pre-existing illegal-opcode regions ($C8B8+) unrelated to edited region

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm

## Notes
- Critical discovery: ROM verification revealed the original disassembly was corrupted - the "Loc_C0DD" block matched no bytes anywhere in ROM, and the State 0 handler was incorrectly swallowed by .byte data
- Table entry count discrepancy: comment claimed 14 entries (states $00-$0D) but ROM shows exactly 10 entries (states $00-$09); code begins immediately after table at $C0D5
- Cross-bank naming: used B1F_ prefix for CallbackDispatcher following established convention for bank 1F references

## Task overview
Completed: Successfully fixed the AiOfficerActionDispatch inline jump table. Replaced raw address with semantic cross-bank reference, converted .byte to 10 symbolic .word entries, restored genuine State 0 handler code, and corrected documentation. Build errors persist but are pre-existing issues in unrelated code regions.
