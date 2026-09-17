# Symbolize $E000-$FFFF cross-bank calls to bank 1F; revert $A000-$DFFF .word targets targeting other banks

- **Category:** task_summary_experience
- **Memory ID:** a772099f-31b8-46d1-a7c8-0f1f48d29509
- **Keywords:** BankedCallbackTrampoline, target banks, Y masking, cross-bank naming, bank 1F, function symbols, revert changes

## Content

## Task description
Replace all raw direct address accesses in prg_08_09.asm targeting $E000-$FFFF with symbolic names from functions.h, then verify assembly integrity.

## Execution process
1. Scanned prg_08_09.asm for raw JSR/JMP/LDA/STA operands in $E000-$EFFF range: found 10 instruction sites (7 unique targets) all pointing to bank 1F fixed engine routines
2. Verified all 7 targets ($ECEE, $E856, $E87A, $EBE9, $EA7C, $EAA5) have B1F_* symbols in functions.h
3. Replaced all 10 sites with symbolic names: JSR/JMP operands changed from raw hex to B1F_PaletteCopyBuffer, B1F_RandomMod8, B1F_RandomByte, B1F_MathMul24x8, B1F_MathDiv16, B1F_MathDiv24
4. Verified with standalone ca65: zero errors introduced by new symbols
5. Scanned $F000-$FFFF range: found 21 instruction sites (5 unique targets) also pointing to bank 1F
6. Verified all 5 targets ($F266, $F25F, $F2D7, $F368, $F387) have B1F_* symbols in functions.h
7. Replaced all 21 sites with symbolic names: B1F_SwitchBank8_A (14 sites), B1F_SwitchBank8_B (3 sites), B1F_GetOfficerRecordAddr (2 sites), B1F_GetRulerDataPtr (1 site), B1F_GetOfficerRomRecordAddr (1 site)
8. Verified with ca65: zero errors from new symbols
9. Scanned $A000-$DFFF range: found 7 .word directives (BankedCallbackTrampoline targets) using raw addresses $A000, $A003, $A006, $A012
10. Attempted replacement with B08_09_* symbols from functions.h SECTION 7
11. User corrected: these .word targets point to OTHER banks (Y=$3B→$1B+$1C, Y=$2E→$0E+$0F, Y=$39→$19+$1A), not banks $08+$09; revert changes
12. Reverted all 7 .word targets back to raw addresses; confirmed they remain unchanged

## Key learnings
- BankedCallbackTrampoline .word targets point to entry points in OTHER PRG banks based on Y register value masked with $1F, NOT to addresses within the current file's loaded range
- Only replace raw addresses when the target bank exists in functions.h and the mapping formula confirms the bank pair
- All cross-bank calls to bank 1F (fixed engine bank) can be symbolized with B1F_* prefix once those functions are documented in functions.h
- Comment-only lines containing address references should be left unchanged

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm
- /home/zero/project/sango2dasm/include/functions.h

## Verification
- ca65 standalone checks: zero errors introduced in all phases
- Final state: 31 raw addresses replaced (10 in $E000-$EFFF, 21 in $F000-$FFFF), 7 .word targets reverted to raw addresses
