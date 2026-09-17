# OfficerExchangeDispatch procedure end address constraint

- **Category:** development_code_specification
- **Memory ID:** 26328ea0-ec84-40e4-8ae7-62d1098ed5f9
- **Keywords:** OfficerExchangeDispatch, $C765, procedure boundary, memory layout

## Content

The `OfficerExchangeDispatch` procedure in `prg_0c_0d.asm` must end exactly at address `$C765`, meaning its final instruction occupies `$C765` and `.endproc` must be placed immediately after it. This ensures correct memory layout and prevents overlap with the subsequent procedure starting at `$C766`.
