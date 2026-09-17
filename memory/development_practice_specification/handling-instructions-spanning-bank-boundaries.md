# Handling instructions spanning bank boundaries

- **Category:** development_practice_specification
- **Memory ID:** 6db8881f-0c6a-4f09-8c19-3293313bcf59
- **Keywords:** bank boundary, instruction straddle, .segment placement, opcode split, ROM alignment

## Content

When a single instruction spans the $BFFF/$C000 boundary (e.g., opcode at $BFFF, operand at $C000-$C001), the opcode byte must be emitted in the current segment (e.g., CODE_BANK1D), then switch to the next segment (e.g., CODE_BANK1E) using `.segment` directive, and emit the operand as a `.word`. This ensures correct physical placement in ROM despite assembler limitations.
