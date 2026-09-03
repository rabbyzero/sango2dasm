# Project architecture and cross-bank calling convention

- **Category:** project_introduction
- **Memory ID:** 7f8e7f83-fc0f-4abb-a025-2ffa5f3f7431
- **Keywords:** bank-switching, trampoline, functions.h, entry equate, ROM verification
- **Usage scenarios:**
  - Renaming jump targets or trampoline addresses in banked assembly code
  - Adding or updating cross-bank function references in functions.h
  - Verifying assembly changes against original ROM using standalone scripts

## Content

The project is a disassembled ROM organized into memory banks (e.g., prg_0e_0f.asm) with bank-switching logic. Cross-bank jumps use trampolines targeting entry points named with the `<Bank>_<Target>_Entry` convention (e.g., B19_OverlayStripRender_Entry). Entry equates are defined in functions.h under respective bank subsections in Section 2, including load context details. Standalone verification scripts (e.g., verify_0e_0f.py) confirm byte parity post-modification.
