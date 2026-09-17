# BankedCallbackTrampoline and CallbackDispatcher inline data patterns

- **Category:** development_code_specification
- **Memory ID:** 35c6e1f5-5b7f-48bd-8017-240e2c393b51
- **Keywords:** BankedCallbackTrampoline, CallbackDispatcher, inline data, .word target, prg_0c_0d, $EE07, $EADE

## Content

Two inline-data callback mechanisms exist in bank $1F:

1. **B1F_BankedCallbackTrampoline** ($EE07): Always has exactly 1 `.word` (2 bytes) inline target address following the JSR. The trampoline reads the 2-byte target, switches PRG bank (from Y register), JMPs to target, and on RTS restores the original bank. Caller continues at JSR+5 (after the inline word). Usage: `LDY #bank / JSR B1F_BankedCallbackTrampoline / .word target_addr`.

2. **B1F_CallbackDispatcher** ($EADE): Has a variable-length inline table of `.word` target addresses following the JSR. Indexed by A register (table[A]). Does JMP (target) — the handler's RTS returns to the caller's caller (dispatcher pops return address off stack). Table length must be determined by tracing callers' max index values, NOT by the "ends before smallest addr" heuristic (unreliable). Usage: `LDA #index / LDY #param / JSR B1F_CallbackDispatcher / .word handler0, handler1, ...`

In prg_0c_0d.asm, many of these inline targets were incorrectly emitted as `.byte` data regions and need to be converted to proper `.word` directives with the subsequent bytes disassembled as code.
