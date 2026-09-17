# Segment directive required at clean bank boundary in prg_0c_0d.asm

- **Category:** project_scm_configuration
- **Memory ID:** 64517df3-c8c5-41e1-ab15-bb9f0040c74d
- **Keywords:** .segment directive, bank boundary, CODE_BANK0D, 6502 assembly

## Content

In prg_0c_0d.asm, a `.segment "CODE_BANK0D"` directive is required after the final instruction in CODE_BANK0C (ending at $BFFF) and before the first instruction in CODE_BANK0D (starting at $C000), even when no instruction spans the boundary. This ensures correct bank separation in ROM.
