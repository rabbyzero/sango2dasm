# CPU RAM map consolidation for $0000-$7FF and $6000-$7FFF across all banks

- **Category:** task_summary_experience
- **Memory ID:** db27d1a0-3486-41ed-8f9a-b43b8fa0f480
- **Keywords:** RAM map consolidation, Sangokushi 2, cpu memory, zero page, WRAM, save checksum, OAM DMA

## Content

## Task description
- Core requirement: consolidate CPU memory meanings for $000-$7FF (zero page + stack/NES RAM) and $6000-$7FFF (WRAM) from existing analyzed asm files and document
- Task background: Sangokushi 2 disassembly project has 9 analyzed bank files (prg_08_09, 0a_0b, 0c_0d, 0e_0f, 17_18, 19_1a, 1b_1c, 1d_1e, 1f) with scattered RAM definitions; no consolidated document existed covering all banks

## Execution process
1. Created tools/extract_ram_equates.py to extract all NAME = $XXXX equates from bank files, filtered to ranges $00xx-$07xx and $6xxx-$7Fxx
2. Ran extraction script producing 1,243 lines of equate inventory in /tmp/ram_equates.txt
3. Discovered prg_19_1a.asm and prg_1b_1c.asm had no equates (use raw addresses with comments); created tools/scan_raw_ram_refs.py to scan their raw address operands
4. Scanned raw references producing 284 lines of usage clusters for the two comment-only banks
5. Verified OAM DMA page $02 by grepping for STA $4014 pattern in prg_1f.asm
6. Discovered save magic "ID" at $6FFC-$6FFD and 16-bit checksum routine at $BC02-$BC75 in prg_19_1a.asm by examining code around $BC0C
7. Identified false positives from .byte data ($6160, $7170) and excluded them from final documentation
8. Wrote code/cpu_ram_map.md with full coverage: hardware layout, zero page sections ($00-$FF through $0600-$07FF), WRAM $6000-$7FFF persistent layout including country records, map camera, AI scratch, mailbox protocol
9. Copied /tmp/ram_equates.txt to code/ram_equates_full.txt as appendix inventory

## Related files
- /tools/extract_ram_equates.py — new script for extracting RAM equates from bank files
- /tools/scan_raw_ram_refs.py — new script for scanning raw address references in comment-only banks
- /code/cpu_ram_map.md — newly created consolidated RAM map document (1,549 lines total)
- /code/ram_equates_full.txt — newly created full equate inventory appendix (1,243 lines)

## Notes
- prg_19_1a and prg_1b_1c use raw addresses with semantic comments instead of equates, requiring different extraction approach
- Multi-alias cells documented explicitly: $6F44 (battle outcome/province field 3/player swap), $042C-$042E (menu_fmt_data), $6F00-$6F06 (dual-use attract-demo scratch vs game level/player ID)
- Save magic/signature discovery: $6FFC=$49 ('I'), $6FFD=$44 ('D') with checksum over $6000-$7FFD stored at $7FFE-$7FFF

## Task overview
Completed: successfully consolidated CPU RAM map covering $0000-$07FF and $6000-$7FFF from all 9 analyzed bank files. Documented OAM DMA page $02, stack page scratch reuse, frame-engine slot headers at $0300/$0304, shared scene/menu handshake region $0400-$04FF, mode state machines in $0500-$05FF, war unit arrays vs tile grids in $0600-$07FF, and full SRAM persistent layout in $6Fxx. Two generator scripts enable future regeneration when new banks are analyzed.
