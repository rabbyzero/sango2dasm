# Cross-boundary instruction segmentation rule

- **Category:** development_practice_specification
- **Memory ID:** 224b0070-4e6d-4e9a-ae5d-970137a154be
- **Keywords:** segment boundary, cross-bank instruction, .segment placement, 6502 assembly, ROM layout

## Content

When a single instruction straddles the $BFFF/$C000 boundary (opcode at $BFFF, operand at $C000-$C001), the `.segment "CODE_BANK09"` directive must be placed between the opcode and its operand. The opcode byte remains in `CODE_BANK08`, while the operand bytes are emitted in `CODE_BANK09` using a `.word` directive to ensure correct physical placement in ROM.
