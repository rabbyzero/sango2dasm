# Document shared-exit label pattern rationale in inline comments

- **Category:** task_summary_experience
- **Memory ID:** 961ab3bd-3077-44c3-8eb1-4d846b757fc8
- **Keywords:** shared exit labels, ca65 scoping, .proc, bare global labels, inline documentation
- **Usage scenarios:**
  - When documenting ca65 label scoping constraints in assembly files
  - When adding inline explanations for bare-global label patterns

## Task description

- Core requirement: document the shared-exit label pattern in inline comments within the assembly file, explaining why labels must sit outside .proc due to ca65 scoping constraints.
- Task background: three shared RTS exit sites exist in prg_0e_0f.asm ($A61C Phase2WalkExit, $A653 Phase2AnimWaitExit, $A7B1 Phase2DamageAnimExit). Existing separator comments did not explain the necessity of bare-global placement for cross-proc branches.

## Execution process

1. Read current comment state at the three shared-exit sites using grep to locate labels.
2. Add concise rationale lines to each separator comment explaining that ca65 scopes labels inside .proc, so a shared RTS branched to from another proc must be a bare global between procs; wrapping in its own .proc would duplicate the byte and break byte-exactness.
3. Use SearchReplace to update all three comment blocks with the rationale, keeping them compact (one line per site).
4. Run tools/verify_0e_0f.py to verify byte-exactness: 16384 bytes compared, 0 mismatches.

## Related files

- asm/banks/prg_0e_0f.asm

## Notes

- None

## Task overview

Completed: documented the shared-exit label pattern rationale inline at all three occurrence sites ($A61C, $A653, $A7B1) with compact separator comments explaining ca65 scoping constraints; verification passed with 0 byte mismatches.
