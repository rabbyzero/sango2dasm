# Data table restructure must preserve physical byte order

- **Category:** common_pitfalls_experience
- **Memory ID:** 0447754b-c08b-406f-81e1-82e85953c923
- **Keywords:** ROM byte drift, data table restructuring, byte-exact verification, tile ID ordering
- **Usage scenarios:**
  - Refactoring data tables in NES disassembly projects
  - When byte-exact verification fails after code changes
  - Restructuring icon/sprite tile tables with non-monotonic IDs

## Content

Bug class: ROM byte drift during data table restructuring
Root cause: The Phase3CommandMarkerTiles data ($C8CB) has non-monotonic tile ID ordering (v0, v1, v2, v3, v4 stored in scrambled physical order); assuming ascending or logical ordering and reshuffling bytes causes byte-exact verification failures.
Fix pattern: Preserve the exact physical byte layout from the ROM; only add semantic annotations (value labels) as comments without changing the .byte/.word directive content. Use hex comments for traceability.
Reusable lesson: Don't reorder data rows based on assumed value semantics because the ROM's physical layout may be intentionally scrambled; instead preserve the original byte sequence exactly and annotate with comments. Applies when refactoring data tables in NES disassembly projects with byte-exact verification; does not apply when the data is newly generated or known to be monotonic.
