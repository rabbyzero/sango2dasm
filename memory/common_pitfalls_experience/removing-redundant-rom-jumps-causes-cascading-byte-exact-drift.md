# Removing redundant ROM jumps causes cascading byte-exact drift

- **Category:** common_pitfalls_experience
- **Memory ID:** 10e5ca89-783f-4209-8f8e-f91e18cc31f4
- **Keywords:** byte-exact drift, redundant jump, label drift, verifier mismatch
- **Usage scenarios:**
  - Editing byte-exact disassembly files
  - Diagnosing scattered verifier mismatches
  - Cleaning up decoded routines

## Content

Bug class: byte-exact disassembly drift after "cleanup" edits.
Root cause: original game code contains redundant jumps (e.g., a JMP whose target is the immediately following instruction). Removing such an instruction as "dead code" silently shifts every subsequent label/branch operand by the instruction size while the instruction stream otherwise still looks plausible — verification then shows hundreds of scattered 1-3 byte operand mismatches plus label drift, not one contiguous block.
Fix pattern: restore the exact ROM bytes (keep the redundant instruction, annotated as ROM artifact); locate the drift start from the first verifier mismatch and compare assembled-vs-ROM streams there.
Reusable lesson: in byte-exact disassembly work, never optimize away or reorder any instruction, branch target placement, or RTS-tail sharing; always re-run the byte verifier after every edit, and audit symbol addresses (debug-info label values vs address comments) when mismatches look scattered.
