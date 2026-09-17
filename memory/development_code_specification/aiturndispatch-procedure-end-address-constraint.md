# AiAction_DomesticTurn (formerly AiTurnDispatch) procedure end address constraint

- **Category:** development_code_specification
- **Memory ID:** 05ae9772-b452-487e-9fa9-5ef22d7c8148
- **Keywords:** AiAction_DomesticTurn, $C50E, procedure boundary, ca65 scope, memory layout

## Content

The `AiAction_DomesticTurn` procedure (renamed from `AiTurnDispatch` in prg_0a_0b.asm) must end exactly at address `$C50E`, meaning its final instruction occupies `$C50D` and `.endproc` must be placed immediately before `.proc Proc_C50E`. This ensures correct memory layout, avoids overlap with the next procedure, and satisfies ca65's scope and linking requirements.
