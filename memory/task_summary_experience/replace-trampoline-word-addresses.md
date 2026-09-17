# Replace trampoline .word addresses with functions.h cross-bank names

- **Category:** task_summary_experience
- **Memory ID:** fc24b67c-bdee-44f2-88ae-b93bb01402ce
- **Keywords:** symbolic references, functions.h, cross-bank names, BankedCallbackTrampoline, .word targets, byte-exact verification

## Content

## Task description
- Core requirement: Replace 3 confirmed `.word` direct address references in prg_19_1a.asm with symbolic names from functions.h
- Task background: BankedCallbackTrampoline targets use LDY-based bank selection; the three `.word` entries at $A0BB, $A163, and $AFFF point to bank $1D/$1E stub table entries that should use cross-bank function names instead of raw addresses

## Execution process
1. Verified functions.h is included in prg_19_1a.asm and cross-bank names exist (B1D_1E_LoadScenarioData=$A015, B1D_1E_YearDisplaySetup=$A01E, B1D_1E_SlowPeriodic=$A021)
2. Applied SearchReplace to replace `.word $A01E` with `B1D_1E_YearDisplaySetup` at address $A0BB
3. Applied SearchReplace to replace `.word $A021` with `B1D_1E_SlowPeriodic` at address $A163
4. Applied SearchReplace to replace `.word $A015` with `B1D_1E_LoadScenarioData` at address $AFFF
5. Ran full build (`make`) which failed due to pre-existing duplicate `Loc_*` symbol errors between prg_1b_1c.asm and prg_19_1a.asm (unrelated to this change)
6. Verified byte-exactness using per-bank harness: `python3 tools/verify_19_1a.py` → "compared 16384 bytes, 0 mismatches"

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_19_1a.asm

## Notes
- Full build failure was due to pre-existing duplicate symbols in work-in-progress files, not caused by this change
- Per-bank verification harness is necessary when full build is broken but individual bank changes need validation

## Task overview
Completed: Successfully replaced 3 `.word` targets with cross-bank function names from functions.h; byte-exactness verified with per-bank harness (0 mismatches). The hex-byte comments were preserved as they document emitted bytes which remain unchanged.
