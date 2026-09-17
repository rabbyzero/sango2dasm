# Inline dispatch pattern must not be treated as raw data

- **Category:** common_pitfalls_experience
- **Memory ID:** fd4a3783-0e8f-48e0-82ab-f382c041d7a6
- **Keywords:** inline dispatch, misidentified code, .byte vs .word, control flow recovery

## Content

Bug class: Inline dispatch table misidentified as raw data
Root cause: The pattern `JSR $B517` followed immediately by `.word` addresses is disassembled as `JSR` opcode + data bytes, when it's actually an inline dispatch mechanism where the dispatcher uses A as index to jump via `JMP (table[A])`. The return address points to the start of the inline table, and after the handler executes RTS, control returns to the instruction after the table.
Fix pattern: Replace raw .byte sequences at these locations with `.word` directives pointing to labeled sub-procedures; add `.proc` wrapper around the entry point; ensure shared exit labels are bare globals between procs.
Reusable lesson: Don't treat JSR followed by .word sequences as data because they implement inline dispatch control flow; instead decode them as procedure entry points with inline tables. Applies when analyzing battle overlay state machines and other phase-driven logic in prg_0e_0f.asm; does not apply to genuine data tables that follow actual code blocks (not immediately after JSR).
