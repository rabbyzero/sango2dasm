# ca65: Explicit label required after removing .proc

- **Category:** common_pitfalls_experience
- **Memory ID:** 6fcd0719-6a88-4a36-b585-7ce74e82355c
- **Keywords:** ca65, .proc, undefined symbol, JMP label

## Content

In ca65 assembly, removing `.proc Proc_B136` deletes the global symbol `Proc_B136`, breaking existing `JMP Proc_B136` instructions. To preserve the jump target while merging procedures, insert an explicit label `Proc_B136:` at the exact instruction address (e.g., `$B136`). This avoids undefined symbol errors during assembly. (Source: Bash/ca65)
