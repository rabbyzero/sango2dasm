# Duplicate .endproc bug in multi-part proc replacement workflow

- **Category:** common_pitfalls_experience
- **Memory ID:** 53284a58-4225-4460-a7ef-d27ba330bfcd
- **Keywords:** ca65 assembly, .endproc, duplicate marker, proc scope, multi-part replacement

## Content

## Usage Scenario
Description: When refactoring large code regions into multiple .proc blocks via sequential SearchReplace operations, especially when parts are replaced in multiple calls
Examples: Splitting a monolithic region into 5+ procedures, renaming and restructuring existing procs with helper subroutines

## Usage Method
SearchReplace: After each part replacement, verify .proc/.endproc balance before proceeding. Check for duplicate .endproc markers that may indicate overlapping replacements or partial application of previous edits. Use grep to count .proc and .endproc occurrences; if unbalanced, inspect the region where the last edit was applied.

## Notes
- Duplicate .endproc markers cause ca65 cascade errors ("undefined symbol", nested proc issues); must detect and remove duplicates before verification
- Sequential part replacements risk overlapping content; always re-grep the modified region to confirm exact boundaries before applying subsequent parts
