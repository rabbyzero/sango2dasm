# Data table mis-splitting causes ROM overflow during disassembly refactoring

- **Category:** common_pitfalls_experience
- **Memory ID:** d249ef3e-b69a-4cc5-9276-346255416be9
- **Keywords:** data table split, ROM overflow, table boundary, verification harness, NES disassembly

## Content

Bug class: Data table mis-splitting causing ROM size overflow during disassembly refactoring
Root cause: When splitting multi-table regions, assuming filler bytes or misidentifying table boundaries causes incorrect .org placements; e.g., pattern table entry 0 at $8000 was mistaken for map table filler, and highlight table offset miscalculated by 1 byte.
Fix pattern: Always verify table splits against ROM bytes using the verification harness (tools/verify_*.py); cross-check code index ranges to confirm table entry counts match expected phase ranges; generate .byte rows programmatically from ROM instead of manual transcription.
Reusable lesson: Don't assume filler bytes or guess table boundaries because a single-byte offset error causes segment overflow and cascading label drift; instead verify each table's byte count against ROM using the verification harness and generate data rows programmatically. Applies when splitting raw .byte blobs into structured tables in NES disassembly; does not apply when adding new code regions.
