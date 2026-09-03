# ca65 shared-exit labels must be bare globals between procs

- **Category:** common_pitfalls_experience
- **Memory ID:** 1851c9dc-0aea-4f97-8434-fff1b2a99bb8
- **Keywords:** ca65, label scoping, .proc, cross-proc reference, cheap-local labels, shared exit
- **Usage scenarios:**
  - Refactoring raw .byte regions into semantic procs with shared RTS
  - Debugging undefined symbol errors for cross-proc label references
  - Resolving cheap-local label scope truncation by bare labels

## Content

Bug class: ca65 label scoping failures when wiring shared RTS exits or cross-proc branch targets during disassembly refactors. Root causes verified: (1) labels inside .proc are scoped — plain cross-proc references fail and Proc::Label forward references fail; (2) cheap-local (@) scope is terminated by ANY non-cheap label; (3) anonymous labels (: / :-) do NOT resolve across .proc boundaries; (4) .global Name does NOT export a proc-internal label — it silently creates a separate undefined global causing 'Range error (Address size 2 does not match fragment size 1)' on branches, and .global Proc::Label is invalid syntax; (5) wrapping a shared RTS in its own single-RTS .proc duplicates the byte and breaks byte-exactness. Fix pattern: the ONLY working pattern is a bare global label outside any .proc — hoist .endproc above the shared label and document it with a compact separator comment (e.g. Phase2WalkExit $A61C, Phase2AnimWaitExit $A653, Phase2DamageAnimExit $A7B1 in prg_0e_0f.asm). Reusable lesson: for shared exits branched to from other procs, always place the label at top level between procs; verify with the byte-exact harness after any restructure.
