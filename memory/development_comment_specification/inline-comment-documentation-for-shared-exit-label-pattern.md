# Inline comment documentation for shared-exit label pattern

- **Category:** development_comment_specification
- **Memory ID:** 4aab0515-b6f0-4d7e-a8c5-f1955b65b333
- **Keywords:** inline comments, label scoping, shared exit, ca65, documentation
- **Usage scenarios:**
  - Documenting ca65 label scoping constraints in assembly files
  - Adding inline explanations for bare-global label patterns

## Content

When documenting ca65 label scoping constraints for shared RTS exits, add a concise rationale line in the separator comment at each occurrence site explaining that ca65 scopes labels inside .proc, so a shared RTS branched to from another proc must be a bare global between procs; wrapping in its own .proc would duplicate the byte and break byte-exactness. Keep it compact (one line per site). Example sites: Phase2WalkExit ($A61C), Phase2AnimWaitExit ($A653), Phase2DamageAnimExit ($A7B1) in prg_0e_0f.asm.
