# Bank entry point label naming convention

- **Category:** development_code_specification
- **Memory ID:** 4226dbe7-a8e8-4ae7-9e0f-0e470f74545b
- **Keywords:** bank entry, _Entry, Loc_ADDR, jump table, internal labels

## Content

Bank entry point labels (e.g., at $A000 range) should be renamed from `Loc_ADDR` to semantic names ending with `_Entry` (e.g., `ExchangeFrameUpdate_Entry`). Only true entry points (JMP stubs at 3-byte intervals in the jump table) get `_Entry` names. Internal code addresses within a routine that are merely trampoline return targets or loop points should NOT receive their own labels — they are part of the enclosing function body. The actual function body reached by the entry stub gets the bare function name (e.g., `ExchangeFrameUpdate:` at $A009, with `ExchangeFrameUpdate_Entry:` at $A000 doing JMP $A009).
