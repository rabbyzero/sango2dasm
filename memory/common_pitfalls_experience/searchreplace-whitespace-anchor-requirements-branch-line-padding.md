# SearchReplace whitespace anchor requirements for assembly files with branch line padding

- **Category:** common_pitfalls_experience
- **Memory ID:** 4ecf05ed-e8da-4a65-91bc-428e93b8350d
- **Keywords:** SearchReplace, whitespace mismatch, branch comments, column alignment, transform_branches.py
- **Usage scenarios:**
  - Performing text replacement in assembly files with fixed-column formatting
  - Debugging SearchReplace failures due to whitespace mismatches
  - Working on assembly files with transform_branches.py legacy padding

## Content

Bug class: SearchReplace whitespace anchor mismatch in assembly files with transform_branches.py legacy padding
Root cause: Branch instruction lines in prg_0e_0f.asm align comments at column 61 (not 42 like normal instructions), a legacy padding from transform_branches.py; using column 42 anchors for branch lines causes pattern mismatch and SearchReplace failure.
Fix pattern: Always re-read the exact current file content before large block replacements; compute whitespace anchors precisely using repr() or character counting; branch lines require trailing spaces to reach column 61 before semicolon.
Reusable lesson: Don't assume uniform comment column alignment across all instruction types in assembly files because transform_branches.py may have padded branch lines differently; instead read the file's actual formatting first and use full-line anchors that capture the complete indentation. Applies when performing SearchReplace on assembly files with mixed instruction types; does not apply to files without transform_branches.py history.
