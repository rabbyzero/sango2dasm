# Inline dispatch table recognition and banked callback trampoline decoding pitfalls

- **Category:** common_pitfalls_experience
- **Memory ID:** e82d6c19-6ef0-459a-ba70-414174fd66e9
- **Keywords:** inline dispatch table, JSR + .word pattern, banked callback trampoline, Y & $1F mask, byte drift prevention, code/data misclassification
- **Usage scenarios:**
  - Decoding frame state handler sub-state tables
  - Identifying bank-switched function calls via trampoline
  - Fixing byte drift from misclassified .word data

## Content

Inline dispatch pattern: JSR followed immediately by .word table at fixed offset (e.g., $CBD6 JSR $EADE, $CBD9-.word table). The table entries point to sub-state handlers; code resumes at the first entry address. This pattern appears repeatedly in frame state handlers (sub-states 0-15) and must be recognized as CODE not DATA to avoid byte drift during disassembly.

BankedCallbackTrampoline decoding: LDY #$XX / JSR $EE07 (B1F_BankedCallbackTrampoline) / .word $AAAA. Target bank = Y & $1F (5-bit mask per Namco-163 spec). Example: LDY #$3D -> bank $1D ($3D & $1F = $1D), target $A042 = BankedDataHandler. LDY #$3B -> bank $1B ($3B & $1F = $1B), target $A009 = JMP $DF25.

Critical pitfall: Raw .byte blobs in disassembly often contain actual 6502 code interrupted by inline .word tables. When the disassembler encounters .word at an unexpected location, it treats subsequent bytes as data until re-syncing at a known label or branch target. This causes cascading byte drift. Solution: identify JSR patterns followed by .word tables, recognize them as dispatch targets, and manually reconstruct the control flow with proper .proc boundaries.

Verification workflow: After restructuring raw .byte regions into semantic .proc blocks with correct inline table handling, run verify_19_1a.py to confirm zero-byte drift before committing.
