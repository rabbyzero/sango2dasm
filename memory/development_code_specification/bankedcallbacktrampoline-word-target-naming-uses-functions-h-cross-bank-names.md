# BankedCallbackTrampoline .word target naming uses functions.h cross-bank names

- **Category:** development_code_specification
- **Memory ID:** e4cbc128-797a-49ed-abe9-05812d49edbf
- **Keywords:** BankedCallbackTrampoline, .word target, cross-bank naming, functions.h, trampoline target

## Content

## BankedCallbackTrampoline .word Target Naming Convention

When annotating `.word` lines that serve as targets for `BankedCallbackTrampoline`:

### Naming Rule
- **Must use cross-bank reference names** defined in `functions.h` (e.g., `B39_BattleResultScene`, `B3D_OfficerDisplay_Lookup`)
- **Do NOT use local assembly names** from the same bank file (e.g., avoid `BattleSetup_Entry`, `BattleSlotClear_Entry` which are local labels in prg_08_09.asm)

### Rationale
The `BankedCallbackTrampoline` mechanism switches PRG banks based on the Y register value and jumps to the target address. Since the target resides in a different bank than the caller, the name must reflect the cross-bank reference convention used in `functions.h` for consistency and clarity.

### Example
```asm
; CORRECT: Cross-bank name from functions.h
.word $A003 ; B39_BattleResultScene

; INCORRECT: Local assembly name
.word $A003 ; BattleSetup_Entry
```

### Application
This applies to all inline `.word` targets following `JSR B1F_BankedCallbackTrampoline` calls, where the target address points to entry points in various PRG banks ($19, $1D, $1E, $39, $3B, $3D, etc.).
