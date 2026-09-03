# Misclassified .byte/.word data containing actual 6502 code

- **Category:** common_pitfalls_experience
- **Memory ID:** 6f8810e2-7c27-4810-92e2-f16f4fbc14ea
- **Keywords:** .byte/.word misclassification, opcode detection, code/data boundary, branch instruction encoding, ROM verification
- **Usage scenarios:**
  - Editing 6502 assembly code containing hand-encoded branches or instructions as .byte/.word data
  - Reviewing .byte/.word data lines to verify whether they are code or genuine data
  - Refactoring legacy branch logic or hidden instructions for clarity

## Content

Bug class: Misclassified data region where .byte/.word lines contain actual 6502 code

Root cause: Disassemblers or manual disassembly may interpret valid instruction bytes as raw data, especially in sound engine regions with lookup tables that happen to have byte values matching opcodes. Branch instructions encoded as .byte (e.g., $F0=$BEQ, $D0=$BNE) and other instructions ($4C=$JMP, $20=$JSR, $60=$RTS, $A9=$LDA#) are particularly easily misclassified.

Fix pattern: When encountering .byte/.word lines, check for opcode patterns: branch instructions (offsets), immediate loads ($A9 XX), jumps ($4C XX XX), returns ($60), stack operations. Compute branch targets from address + signed offset. Replace with proper mnemonics and add semantic labels if needed. Verify against ROM bytes before and after replacement.

Reusable lesson: Don't assume .byte/.word lines are genuine data because they look like hex values; instead verify whether bytes decode as valid 6502 instructions by checking for opcode patterns. Applies when analyzing bank assembly files, especially sound engine regions with lookup tables; does not apply when data is explicitly confirmed as non-code (e.g., CHR graphics, tile maps).
