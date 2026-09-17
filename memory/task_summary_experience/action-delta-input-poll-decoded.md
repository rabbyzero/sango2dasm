# Action delta input poll decoded in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** c73e523a-f149-413b-8da5-eccf21dd732a
- **Keywords:** ActionDeltaInputPoll, war scene delta input, prg_1b_1c, AiOfficerActionDispatch caller, digit cursor rendering

## Content

## Task description
- Core requirement: analyze and refactor the war-scene action delta input handler at Loc_DA02 in prg_1b_1c.asm ($DA02-$DB71), converting Loc_ labels to @-style locals and aligning naming with terminology.md / 04-strategy-commands.md.
- Task background: The region was previously documented with generic Loc_XXXX labels as raw disassembly; user requested full code analysis workflow execution (Verify → Replace → Rename → Fix → Explain) followed by source application.

## Execution process
1. Verified entry point: Loc_DA02 reached via stub $A003 (JMP target), called from prg_08_09 AiOfficerActionDispatch State1_GrowStatA/State2_GrowStatB via banked callback trampoline Y=$3B. Identified behavior as war-scene action delta input editing 4-digit action_delta ($048E/$048F).
2. Renamed procedure: wrapped $DA02-$DB71 as `.proc ActionDeltaInputPoll` with full header documentation; updated stub from `JMP $DA02` to `JMP ActionDeltaInputPoll`.
3. Converted local labels: all branch targets (`BCC $DA24`, etc.) renamed to @-prefixed semantic names (@CursorLeftCheck, @DeltaDownCheck, @DeltaUpCheck, @ClampDelta, @RenderDigits, @ExitPoll, @BcdDigitsDraw, @BcdLowDigit).
4. Renamed helpers: $DB09 → @GetDigitStep, $DB35 → @DigitTileWrite (plus @DigitBlank/@CursorBlinkCheck/@DigitAdvance matching OfficerTroopPoolAssignPoll idiom); inlined unreferenced Loc_DA04 artifact label.
5. Updated symbolic refs: `JSR $E9BA` → `B1F_MathBinToBcd` (functions.h equate); left $DB72/$DB87/$DB99 global (external callers).
6. Fixed documentation: corrected code/bank_switch_map.md (3 spots) where $A003 was wrongly labeled "PPU raw copy helper".
7. Verification: ran tools/verify_1b_1c.py - 16,384 bytes compared, 0 mismatches.

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_1b_1c.asm
- /home/zero/project/sango2dasm/code/bank_switch_map.md

## Notes
- The two trailing tile-stream tiles derived from cursor byte $048B (high nibble 0, low nibble = cursor index) are factual; their on-screen purpose is unconfirmed but documented.
- Harness (tools/verify_1b_1c.py) only recognizes Loc_[0-9A-F]{4} labels as defined-in-bank; renaming to @-labels would break its defined-set tracking if used externally, but internal @-locals don't affect harness.

## Task overview
Successfully completed full 5-step code analysis workflow: wrapped procedure in .proc block, renamed all Loc_ labels to semantic @-prefixed names, updated all references, fixed outdated documentation. Byte-exact verification passed with 0 mismatches across both banks 1B+1C.
