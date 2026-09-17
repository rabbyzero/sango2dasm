# prg_1b_1c.asm raw direct-address symbolization pass

- **Category:** task_summary_experience
- **Memory ID:** c22aaff0-4f32-41a0-a842-78aa60674fbe
- **Keywords:** prg_1b_1c, raw address symbolization, BankedCallbackTrampoline, multi-entry procedure, byte parity verification

## Content

## Task description
- Core requirement: scan and symbolize all raw direct address operands in $A000-$FFFF range in asm/banks/prg_1b_1c.asm
- Task background: bank disassembly contained 326 sites using raw hex addresses (JSR/JMP/LDA/STA operands and .word directives) instead of symbolic names; all targets pointed to disassembled banks (bank $1F via B1F_* symbols, bank $19 via B19_1A_* symbols, or within-file labels)

## Execution process
1. Scanned prg_1b_1c.asm for raw absolute addressing operands targeting $A000-$FFFF: found 326 sites across 37 unique targets
2. Mapped bank-$1F targets ($E000-$FFFF): 24 targets replaced with B1F_* symbols from include/functions.h (B1F_RandomMod4, B1F_MathDiv16, B1F_ClearUI, B1F_GetOfficerRecordAddr, etc.)
3. Mapped trampoline .word $A018: replaced with B19_1A_TransferCapacityCalc after verifying Y=$3B & $1F = $19 target bank
4. Mapped within-file targets ($A000-$DFFF): 12 targets replaced with existing labels (MapCursorArrowDraw, ActionDeltaInputPoll, ProvinceOfficerCount, CountryRulerIdGet, @AcademyTierSet, etc.)
5. Created new multi-entry label: added ActionDeltaInputPoll_CapInA at $DA04 (inner entry skipping LDA #$03 init) with file-scope alias `ActionDeltaInputPoll_CapInA = ActionDeltaInputPoll::ActionDeltaInputPoll_CapInA` per prg_0a_0b pattern
6. Fixed Python regex bug: initial script dropped trailing newlines when rebuilding lines; corrected by explicit body/newline handling
7. Verified byte-exact integrity: tools/verify_1b_1c.py reported 16384 bytes, 0 mismatches; ca65+ld65 assembly clean
8. Re-scanned: confirmed 0 raw operand sites remain (harness "external stubs: 1" was false positive from comment mentioning JMP $C773)

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_1b_1c.asm
- /home/zero/project/sango2dasm/tools/fix_raw_addrs_1b1c.py

## Notes
- ca65 .proc-internal labels are scope-local; .global inside proc does NOT make bare outer-scope references resolve; must use Proc::Inner syntax or file-scope alias pattern
- Python regex (.*)$ on lines read with newline drops trailing newline when rebuilding; always split body/newline explicitly
- SearchReplace tool failed to save large files reliably multiple times; fell back to Python transform scripts (project-established pattern)
- Harness external-stub counter can be inflated by address references in comments, not just code

## Task overview
Successfully completed raw-address symbolization: replaced 326 operand sites with symbolic names across 37 targets; verified byte-exact integrity (16384 bytes, 0 mismatches); created one new multi-entry label following project conventions; all changes compile cleanly with no build errors introduced.
