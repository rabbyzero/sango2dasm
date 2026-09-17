# Hex transcription errors in large data tables require programmatic generation

- **Category:** common_pitfalls_experience
- **Memory ID:** 124ff6df-0472-496c-be8e-861922678b8a
- **Keywords:** hex transcription, data table, ROM verification, programmatic generation

## Content

Bug class: Assembly data table transcription error causing ROM mismatch
Root cause: Manually transcribing large data blocks (e.g., 166-byte frame pointer table at $B349-$B3EE) from xxd dumps into .byte directives introduces byte-level errors due to visual miscounting or dropped pairs. In this task, 2 bytes were wrong in the table, causing mismatches at $B36D-$B370 and cascading offsets downstream.
Fix pattern: Always generate .byte rows programmatically from the ROM file using a script that reads raw bytes at offset (addr-$A000) and outputs formatted lines with correct hex comments. Example Python one-liner: `data = open('rom/prg/prg_0e.bin','rb').read(); start, end = 0xB349-0xA000, 0xB3EF-0xA000; b = data[start:end]; ...`
Reusable lesson: Don't manually transcribe multi-row data tables from hex dumps because visual counting errors drop bytes or shift addresses; instead generate .byte rows programmatically from rom/prg/*.bin files using offset = addr-$A000. Applies when rewriting large data regions (≥50 bytes) in disassembly; does not apply to small tables (≤8 bytes) where manual transcription is reliable.
