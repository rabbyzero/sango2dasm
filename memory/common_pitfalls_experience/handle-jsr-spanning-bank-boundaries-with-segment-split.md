# Handle JSR spanning bank boundaries with segment split

- **Category:** common_pitfalls_experience
- **Memory ID:** 44db742a-2975-4991-a062-5ad477576097
- **Keywords:** JSR, bank boundary, segment split, 6502 assembly
- **Usage scenarios:**
  - Disassembling ROMs where control flow crosses bank boundaries
  - Fixing incorrect code placement due to unsplit cross-bank jumps
  - Reconstructing proper segment layout from raw binary dumps

## Content

When a JSR instruction spans a ROM bank boundary (e.g., opcode at $BFFF, operand at $C000), it must be split across segments. Use `.byte $20` for the JSR opcode at the end of the current bank, insert `.segment "NEXT_BANK"`, then place the `.word TargetLabel` operand in the new bank. This ensures correct assembly and linking.

(Source: Analysis of prg_1d_1e.asm and linker behavior)
