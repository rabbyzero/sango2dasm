# BankedCallbackTrampoline .word targets point to OTHER banks, not current file's loaded range

- **Category:** common_pitfalls_experience
- **Memory ID:** 4f6f98fa-cf4a-4550-84dc-61f96183a836
- **Keywords:** BankedCallbackTrampoline, .word targets, target bank mapping, Y mask, cross-bank entry points

## Content

Bug class: BankedCallbackTrampoline .word targets misinterpreted as addresses within the current file's loaded range.

Root cause: the 2-byte .word following `JSR B1F_BankedCallbackTrampoline` ($EE07) is the ENTRY ADDRESS in the TARGET bank selected by the preceding `LDY #$XX` (effective bank = Y & $1F), not an address inside the current bank pair. For example, `.word $A000` inside prg_08_09.asm with LDY #$39 targets banks $19+$1A, not banks $08+$09.

Fix pattern: decode the LDY value first (target bank = Y & $1F), then look up the stub entry at that address in the target bank pair's entry table (verify against include/functions.h BXX_YY_* names). Only symbolize when the target bank pair exists in functions.h; otherwise leave the raw address.

Reusable lesson: don't symbolize BankedCallbackTrampoline .word targets using symbols of the caller's own bank; the numeric value alone is ambiguous because many bank pairs place entry stubs at the same $A000-$A02A offsets. Applies to all trampoline call sites in any bank file.
