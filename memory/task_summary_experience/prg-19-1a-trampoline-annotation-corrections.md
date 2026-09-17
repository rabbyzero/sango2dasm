# prg_19_1a.asm BankedCallbackTrampoline annotation corrections and systematic pattern discovery

- **Category:** task_summary_experience
- **Memory ID:** 3c8a5df9-bfb1-4710-a63c-b2434fff7f2c
- **Keywords:** prg_19_1a, BankedCallbackTrampoline fix, LDY bank decode, annotation error, SlowPeriodic, YearDisplaySetup, LoadScenarioData

## Content

## Task Summary
Fixed BankedCallbackTrampoline annotation errors in prg_19_1a.asm where inline comments incorrectly assumed caller's bank ($19) instead of decoding LDY parameter.

### User Correction
User reported: "$A163 inline comment is wrong. It is prg bank $1d $a021, because of LDY #$3D."

### Verification Chain
1. Confirmed B1F_BankedCallbackTrampoline stores Y to addr_trampoline_bank_param → SwitchBankAC_B uses it as target bank
2. Verified Y & $1F mask: LDY #$3D → bank $1D (not caller's $19)
3. Cross-checked functions.h: B1D_1E_SlowPeriodic = $A021 in bank $1D
4. Verified bank $1D stub at $A021 → JMP $A77F (PeriodicOverlayRefresh::SlowPeriodic)

### Fixes Applied
**Flagged site ($A163):**
- Inline comment: "(bank $1D $A021 -> JMP $A77F: PeriodicOverlayRefresh::SlowPeriodic)"
- LDY comment: "; target banks $1D+$1E" (was "banks $19+$1A (self)")
- OverlayPoll header: Updated to describe bank $1D SlowPeriodic call

**Sibling sites with identical error pattern:**
- $A0BB: ".word $A01E" → "(bank $1D $A01E -> JMP $A6B6: YearDisplaySetup)"
- $AFFF: ".word $A015" → "(bank $1D $A015 -> JMP $DBB1: LoadScenarioData)"
- ProvinceOfficerRosterDispatch header: Removed false claim about attract demo driving it

### Follow-up Note
~22 additional LDY #$3D sites in prg_19_1a.asm have their .word targets encoded as un-annotated .byte rows (e.g., $A853 → $A02A OfficerDisplay_Lookup). Consistent with bank-$1D pattern but not yet symbolized.

### Outcome
All corrections verified; file now accurately reflects bank $1D/$1E stub table usage pattern.
