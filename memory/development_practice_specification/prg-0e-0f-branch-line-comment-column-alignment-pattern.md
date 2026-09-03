# prg_0e_0f.asm branch line comment column alignment pattern

- **Category:** development_practice_specification
- **Memory ID:** 10951dce-f9f8-40c4-b69b-fd056bb43efc
- **Keywords:** SearchReplace, whitespace alignment, branch comments, column alignment, transform_branches.py
- **Usage scenarios:**
  - Performing text replacement in prg_0e_0f.asm with fixed-column formatting
  - Debugging SearchReplace failures due to whitespace mismatches
  - Working on assembly files with transform_branches.py legacy padding

## Content

Branch instruction lines in prg_0e_0f.asm align comments at column 61 (not 42 like normal instructions), a legacy padding from transform_branches.py. When performing SearchReplace on this file, anchors for branch lines must include sufficient trailing spaces to reach column 61 before the semicolon, while normal instructions use column 42. Failure to account for this difference causes SearchReplace failures due to whitespace mismatch. This applies specifically to prg_0e_0f.asm and files with similar transform_branches.py history.
