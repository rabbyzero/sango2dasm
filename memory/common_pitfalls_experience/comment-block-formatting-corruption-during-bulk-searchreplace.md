# Comment block formatting corruption during bulk SearchReplace refactoring

- **Category:** common_pitfalls_experience
- **Memory ID:** 4650c10e-7e9b-43ce-9b9e-ac4250c24b4c
- **Keywords:** SearchReplace, comment formatting, bulk refactoring, NES disassembly, stray blank lines
- **Usage scenarios:**
  - Applying semantic renaming with header comments to assembly procedures
  - Performing bulk code changes with embedded documentation
  - Refactoring raw disassembly into named procedures

## Content

## Bug class: Comment block formatting corruption during bulk SearchReplace operations

## Root cause
When performing multiple SearchReplace operations on a single file (especially for semantic renaming and comment updates), each replacement is applied independently without global context awareness; trailing newlines or awkward line breaks in the replacement text can introduce stray blank lines or break line wraps in comment blocks.

## Fix pattern
After completing all SearchReplace operations, re-read the affected regions and manually fix any formatting issues: remove stray blank lines that were introduced between comment paragraphs, reconnect broken line wraps where words were split across lines incorrectly, and ensure consistent indentation throughout the comment block.

## Reusable lesson
Don't assume bulk SearchReplace operations preserve comment formatting automatically because each operation is context-independent and may introduce stray whitespace or broken line wraps; instead, always re-read the modified region after replacements and apply targeted cleanup fixes. Applies when performing semantic renaming with header comments in assembly files; does not apply to simple code-only changes without embedded documentation.
