# ROM bank boundary fix for JSR at $BFFF and segment configuration

- **Category:** task_summary_experience
- **Memory ID:** e8cc8daa-4f51-46f4-a361-f57b07b75708
- **Keywords:** ROM bank, JSR split, linker config, 6502 assembly

## Content

## Task Description
Apply fixes for ROM bank management: add CODE_BANK1D and CODE_BANK1E in linker.cfg, split a JSR spanning $BFFF–$C000 in prg_1d_1e.asm, ensure hex byte comments, and insert missing .segment in prg_0c_0d.asm.

## Execution Process
```mermaid
graph TD
    A[Add CODE_BANK1D/CODE_BANK1E to linker.cfg] --> B[Split JSR at $BFFF in prg_1d_1e.asm]
    B --> C[Use .byte $20 in CODE_BANK1D]
    C --> D[Switch .segment to CODE_BANK1E]
    D --> E[Place .word ResetDispatchState at $C000]
    E --> F[Add hex byte comments for traceability]
    F --> G[Insert .segment "CODE_BANK0D" in prg_0c_0d.asm]
```

## Task Summary
Successfully resolved bank boundary issues: configured new segments in linker.cfg, split a cross-bank JSR correctly, added detailed hex comments, and inserted missing segment directive in prg_0c_0d.asm to maintain bank integrity.
