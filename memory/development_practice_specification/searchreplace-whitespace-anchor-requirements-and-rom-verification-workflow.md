# SearchReplace whitespace anchor requirements and ROM verification workflow

- **Category:** development_practice_specification
- **Memory ID:** 9c70774c-58b2-4091-90c7-e2169d4184ca
- **Keywords:** SearchReplace, whitespace handling, ROM verification, assembly documentation
- **Usage scenarios:**
  - Performing text replacement in assembly files with fixed-column formatting
  - Debugging SearchReplace failures due to whitespace mismatches
  - Verifying disassembly accuracy against original ROM bytes

## Content

Code and data that are exclusively used by a single procedure should be encapsulated within that procedure. This includes subroutines and constant tables that have no external references, promoting locality and reducing global namespace pollution.

**SearchReplace Whitespace Anchor Requirement:**
When performing text replacement in assembly source files where indentation and whitespace are significant:
- Always include leading whitespace in the original_text anchor; use full-line anchors that capture the complete line including indentation rather than partial matches
- Omitting leading whitespace in original_text causes SearchReplace to fail because the pattern doesn't match the actual file content; must include exact whitespace including leading spaces/tabs in the search anchor

**SearchReplace File Content Re-reading Requirement:**
Before attempting large block replacements, always re-read the exact current file content to verify indentation and whitespace match; if the original_text doesn't match despite appearing correct, check for hidden formatting inconsistencies like missing leading spaces on some lines. Large block replacements are fragile when source files have inconsistent indentation; prefer multi-step smaller replacements or fix formatting first.

**ROM Verification Workflow for Disassembly Accuracy:**
Step 1: Bash - Calculate bank offset mapping using `python3 -c "data = open('rom.bin','rb').read(); seg = data[bank*0x2000:(bank+1)*0x2000]; print(seg[offset:offset+size].hex())"` to dump raw bytes at target address; input: bank number, address offset, output: hex byte sequence
Step 2: Grep - Search for opcode patterns (e.g., AD 01 05 20 DE EA) across all banks to locate exact position; input: byte pattern from disassembly, output: matching bank/offset or "not found"
Step 3: Bash - Extract full handler region bytes (table + handlers) for comparison; input: start address, end address, output: complete hex dump
Step 4: Phase check - Confirm ROM bytes match disassembly claims; when mismatches are found, compare with existing labels in file to identify missing handlers; if no labels exist, create new ones based on handler functionality; skip Step 5 only if ROM matches perfectly
Step 5: SearchReplace - Update disassembly with verified bytes, symbolic references, and corrected comments; input: verified byte sequences, symbolic label names, output: corrected disassembly file

**Notes:**
- Reading only partial sections causes missing context about entry/exit boundaries; must read the full code region first
- Adding comments without verifying build integrity can introduce syntax errors; must compile after each batch of changes
- Not mapping data structures leaves undocumented zero-page usage; must identify all variables referenced in the routine
- Assuming default $8000 bank window causes incorrect byte extraction; must verify bank mapping empirically via hex dump
- Relying solely on disassembly comments without ROM verification allows fabricated code blocks to persist; always cross-check against original binary
- Not verifying table entry count leads to miscounting (claimed 14 entries but ROM shows 10); must decode actual .word entries byte-by-byte
