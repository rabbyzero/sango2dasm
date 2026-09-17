# Inline trampoline target word can poison following code into .byte data

- **Category:** common_pitfalls_experience
- **Memory ID:** c1b1547f-84bf-49ce-9b2d-002d193b795e
- **Keywords:** trampoline inline data, illegal opcode run, data misclassification, .byte reclassification, verify harness

## Content

Bug class: code after an inline trampoline target misclassified as .byte data. Root cause: the init pipeline converts any contiguous instruction run containing an illegal opcode into .byte data; the inline .word target following JSR BankedCallbackTrampoline ($EE07) can begin with a byte that is itself an illegal opcode (e.g. $A003's low byte $03 = SLO), so the target word plus the genuine code after it (PLA/STA/RTS continuation) gets emitted as a data blob. Fix pattern: whenever a "--- Data Region ---" blob immediately follows a JSR $EE07, decode it manually: first 2 bytes are the .word target (symbolize via functions.h cross-bank names), remaining bytes are continuation code; reclassify and re-run the byte-exact verify harness. Reusable lesson: data-region markers near inline-data call patterns (JSR followed by inline .word) must be manually re-checked before analysis, since illegal-opcode-based data detection cannot distinguish inline data words from instructions.
