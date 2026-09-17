# Segment split for JSR spanning $BFFF/$C000 in prg_1d_1e.asm

- **Category:** project_scm_configuration
- **Memory ID:** 9e6a49b1-3716-465f-a6f0-47787ee14480
- **Keywords:** JSR split, bank boundary, .segment directive, opcode span

## Content

In prg_1d_1e.asm, the JSR instruction at $BFFF that spans to $C000-$C001 is split into:
- `.byte $20` in CODE_BANK1D (for the opcode)
- `.segment "CODE_BANK1E"`
- `.word ResetDispatchState` (for the operand)
This ensures correct physical placement in ROM across bank boundaries.
