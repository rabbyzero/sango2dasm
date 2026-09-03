# Verification harness must exclude pseudo-disassembly lines from absolute-addressing transformation

- **Category:** common_pitfalls_experience
- **Memory ID:** 3809c7df-61d0-4b0a-8f00-8fd824021ddb
- **Keywords:** verification harness, ROM byte-exact match, pseudo-disassembly, illegal opcodes, ca65 addressing mode
- **Usage scenarios:**
  - When creating ROM verification harnesses for NES disassembly projects
  - When troubleshooting ca65 'Illegal addressing mode' errors in verification scripts

## Content

Bug class: Verification harness regex incorrectly transforms pseudo-disassembly lines with illegal opcodes
Root cause: The regex pattern `r'([0-9A-Fa-f]{2})\s+([0-9A-Fa-f]{4}):'` used to force absolute addressing mode (`a:` prefix) matches any line containing a 2-char opcode followed by an address comment, including pseudo-disassembly regions where bytes are shown as mnemonics like `SRE $0000,Y`, `NOP #$00`, `JMP $0000`. These are unofficial opcodes that ca65 does not support in absolute addressing mode, causing "Illegal addressing mode" assembler errors when transformed to `SRE a:$0000,Y`, etc.
Fix pattern: Before applying the absolute-addressing transformation, filter out lines that contain known illegal/opinionated opcodes (SRE, NOP #$xx, ISB, etc.) or lines that appear in pseudo-disassembly regions (identified by context or by checking if the mnemonic is not a standard 6502 instruction). Alternatively, scan the assembled output for "Illegal addressing mode" errors and manually exclude those lines from the transformation.
Reusable lesson: Don't blindly apply absolute-addressing transformations to all lines with address comments because pseudo-disassembly regions contain illegal opcodes that don't support absolute mode; instead, pre-filter lines by checking if the mnemonic is a valid 6502 instruction or post-filter by catching assembler errors and excluding those specific lines. Applies when creating ROM verification harnesses for NES disassembly projects using ca65; does not apply to standard assembly code that doesn't include pseudo-disassembly regions.
