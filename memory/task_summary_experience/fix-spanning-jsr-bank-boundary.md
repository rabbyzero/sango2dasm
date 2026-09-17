# Fix spanning JSR across bank boundary in 6502 assembly

- **Category:** task_summary_experience
- **Memory ID:** dbd72b88-8a32-417e-8e9b-46fd03ff4f37
- **Keywords:** JSR, bank boundary, linker.cfg, segment switch

## Content

## Task Description
Fix a JSR instruction at $BFFF that spans into the next bank ($C000) by properly splitting it and adding missing linker segments.

## Execution Process
```mermaid
graph TD
    A[Identify JSR at $BFFF straddling bank boundary] --> B[Check prg_1d_1e.asm for segment declaration]
    B --> C[Find missing .segment "CODE_BANK1E"]
    C --> D[Inspect linker.cfg for bank definitions]
    D --> E[Discover CODE_BANK1D/1E missing]
    E --> F[Add CODE_BANK1D/1E to linker.cfg with PRG_SLOT1/2]
    F --> G[Split JSR into .byte $20 and .word ResetDispatchState]
    G --> H[Insert .segment "CODE_BANK1E" between opcode and operand]
```

## Task Summary
Successfully resolved cross-bank JSR: added CODE_BANK1D/1E in linker.cfg and split the instruction in prg_1d_1e.asm using .byte and .word directives with correct segment switching.
