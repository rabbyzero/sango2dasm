# Endproc directive lines must not carry inline address comments

- **Category:** development_code_specification
- **Memory ID:** 3fcfd6b7-eeee-4f5f-8941-26bfe7f0e5a9
- **Keywords:** endproc, inline comments, address, directive style, ca65

## Content

Directive lines such as `.endproc` must be written bare, without inline comments containing addresses (e.g., write `.endproc`, not `.endproc  ; $A045`). Ending addresses are already documented in the proc's header comment block, so the inline address comment is redundant. Applies to all ca65 disassembly bank files in this project when wrapping procedures or creating new ones.
