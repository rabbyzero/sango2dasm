# Replace .byte/.word data lines with disassembled code if they are actually code

- **Category:** development_code_specification
- **Memory ID:** cd6e92bd-ff6c-4df9-a1e7-76b15cac841e
- **Keywords:** .byte, .word, branch instruction, 6502 assembly, mnemonic replacement, data verification, disassembly
- **Usage scenarios:**
  - Editing 6502 assembly code containing hand-encoded branches or instructions as .byte/.word data
  - Reviewing .byte/.word data lines to verify whether they are code or genuine data
  - Refactoring legacy branch logic or hidden instructions for clarity
  - Enforcing assembly hygiene during code review

## Content

During code analysis, verify all `.byte` and `.word` data lines to determine whether they are actually code (instructions encoded as raw bytes). If they are code, replace them with proper disassembled mnemonics. This includes but is not limited to:

1. **Branch instructions** encoded as `.byte` (e.g., `.byte $F0,$12` -> `BEQ @Label`, `.byte $D0,$13` -> `BNE @Label`, `.byte $B0,$06` -> `BCS @Label`). Compute the branch target from the address and relative offset, then use a proper label.
2. **Other instructions** encoded as `.byte` (e.g., `.byte $4C,$00,$A0` -> `JMP $A000`, `.byte $A9,$05` -> `LDA #$05`).
3. **`.word` entries** that are actually jump tables or code addresses — verify they reference valid code labels, not just raw hex values.

For each replacement:
- Compute the instruction's address from the comment (e.g., `$A104: D0 13`).
- Determine the operand/target (branch targets use relative addressing: target = next_instruction_address + signed_offset).
- If the target address has no existing label, add one with a meaningful semantic name.
- Preserve the address comment for traceability.

This ensures readability, maintainability, and correctness of the disassembly. Applies to all bank .asm files in the project.
