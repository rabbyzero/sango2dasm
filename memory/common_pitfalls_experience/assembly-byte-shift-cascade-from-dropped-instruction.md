# Assembly byte-shift cascade from dropped instruction during refactoring

- **Category:** common_pitfalls_experience
- **Memory ID:** 0b694a9c-ea29-4a4a-9ac6-309204dc1dc5
- **Keywords:** assembly byte shift, instruction removal, cascade mismatch, verification harness
- **Usage scenarios:**
  - When refactoring assembly procedures and removing instructions
  - Debugging widespread byte mismatches after code changes

## Content

Bug class: Assembly byte-shift cascade from dropped instruction
Root cause: During procedure refactoring, accidentally removing a 2-byte instruction pair (LDA #$00 / STA $0545) causes all subsequent labels to shift by -2 bytes; this cascades through phase tables, branch targets, and cross-bank references, producing hundreds of mismatches. Verified in prg_0e_0f.asm at $A34F where the missing instruction caused 6941 total mismatches.
Fix pattern: Always verify byte count before/after edits; when mismatches appear, check for recent multi-byte instruction removals first; use hex dump comparison to pinpoint drift origin.
Reusable lesson: Don't remove or merge instructions without counting bytes because even a single 2-byte omission shifts all downstream symbols and breaks verification. Applies when refactoring assembly procedures with inline data tables; does not apply to pure comment updates or whitespace changes.
