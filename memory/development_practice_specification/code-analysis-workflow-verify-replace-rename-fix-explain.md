# Code Analysis Workflow: Verify, Replace, Rename, Fix, Explain

- **Category:** development_practice_specification
- **Memory ID:** 7bd13e28-816c-4786-bfd9-5f8f2ef8867d
- **Keywords:** code analysis, verify, .byte, .word, data verification, mnemonic replacement, rename, meaningful names, fix comments, explain logic
- **Usage scenarios:**
  - Analyzing disassembled bank code to verify and improve naming, references, and comments
  - Reviewing and refining .proc scope boundaries and label accuracy
  - Performing semantic renaming of auto-generated labels during reverse engineering

## Content

When analyzing code or performing code analysis in this disassembly project, follow this full workflow:

1. **Verify**: Check that function names, labels, parameters, data references, and scope boundaries (.proc/.endproc) are correct and consistent with the actual code behavior and binary. Additionally, verify all `.byte` and `.word` data lines — determine whether each is genuine data or actually code encoded as raw bytes. Look for opcode patterns (e.g., $D0=BNE, $F0=BEQ, $B0=BCS, $4C=JMP, $20=JSR, $60=RTS, $A9=LDA#) in `.byte` lines, and check `.word` entries that might be unlabeled code addresses.
2. **Replace**: If a `.byte`/`.word` line is actually code, replace it with proper disassembled mnemonics. For branches, compute the target address (next_instruction_address + signed_offset) and use a proper label (add one if none exists). For other instructions, use the correct mnemonic and operand format.
3. **Rename**: Replace generic or auto-generated names (e.g., Loc_XXXX, SmallRoutineX, LXXXX) with meaningful, semantically accurate names that describe the function's purpose or behavior.
4. **Fix**: Correct comments, cross-references, and documentation that are outdated or inconsistent with the verified code.
5. **Explain**: When logic is non-trivial (e.g., state machines, dispatch tables, bit manipulation), add or improve inline explanations of the logic and control flow.

This workflow applies to all bank assembly files, header files, and analysis scripts in the project.
