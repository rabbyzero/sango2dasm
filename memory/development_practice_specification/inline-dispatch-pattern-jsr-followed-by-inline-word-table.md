# Inline dispatch pattern: JSR followed by inline .word table

- **Category:** development_practice_specification
- **Memory ID:** ad82a4de-9c42-480d-a44b-f14068540add
- **Keywords:** inline dispatch, JSR .word table, disassembly correction, control flow recovery

## Content

When analyzing disassembled 6502 code, recognize that `JSR $B517` (or similar) followed immediately by a `.word` table of addresses implements an **inline dispatch mechanism**. In this pattern:
- The return address points to the start of the inline table
- The dispatcher uses `A` as index to jump to one of the targets via `JMP (table[A])`
- After the handler executes `RTS`, control returns to the instruction *after* the table
- Any such sequence previously disassembled as opcodes must be replaced with `.word` directives pointing to labeled handlers
- The actual code at the resumption address (e.g., $A0B1, $ACCE) must be re-disassembled correctly

This pattern must be identified and corrected during the Verify phase of the analysis workflow to prevent misinterpretation of data as code.
