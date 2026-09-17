# Trampoline target bank must be decoded from LDY, not caller context

- **Category:** common_pitfalls_experience
- **Memory ID:** e15f68f1-19d0-4fbf-99de-7d5a96cd3311
- **Keywords:** BankedCallbackTrampoline, LDY bank decode, prg_19_1a, stub table, wrong bank annotation

## Content

## Pitfall
BankedCallbackTrampoline target comments in prg_19_1a.asm were annotated with the caller's own bank ($19) instead of decoding the LDY bank parameter. All `LDY #$3D` sites in prg_19_1a.asm actually target the bank $1D/$1E stub table at $A000 (e.g. $A021 = B1D_1E_SlowPeriodic, $A01E = YearDisplaySetup, $A015 = LoadScenarioData), NOT the bank $19 stubs at the same offsets. Three inline comments (at $A0BB, $A163, $AFFF) plus three `LDY #$3D ; banks $19+$1A (self)` comments and dependent proc headers (OverlayPoll, CountrySelect, RosterLoadInit, ProvinceOfficerRosterDispatch) were corrected on 2026-08-31.

## Root cause
Annotation was copied from the visual context (caller lives in bank $19) instead of decoding Y through B1F_BankedCallbackTrampoline: Y is stored to addr_trampoline_bank_param and passed to SwitchBankAC_B, so target bank = Y & $1F. Both bank pairs place parallel stub tables at the same $A000 offsets, making the mistake invisible without checking Y.

## Fix pattern
When resolving any BankedCallbackTrampoline .word target: decode LDY #$XX first (XX & $1F = target bank), then look up the stub at that address in the target bank pair's entry table (verify against include/functions.h BXX_YY_* names). Never assume the caller's bank. Note ~22 more `LDY #$3D` sites in prg_19_1a.asm still have their inline .word targets encoded as un-annotated .byte rows.
