# PRG banks 0E-0F consolidation into combined disassembly

- **Category:** task_summary_experience
- **Memory ID:** 0375438b-3ed4-40f2-bc46-dad3f5bcb7b2
- **Keywords:** PRG bank consolidation, disassembly, bank mapping, linker configuration, NES disassembly

## Content

## Task description
- Core requirement: consolidate PRG banks 0E and 0F into a single combined disassembly file following the existing pattern of prg_08_09.asm and prg_0c_0d.asm
- Task background: the Sangokushi 2 NES disassembly project uses paired bank files for contiguous memory regions; banks 0E/0F were previously separate stub files mapped at $8000, but needed to be consolidated and mapped to their actual addresses ($A000/$C000) as part of ongoing disassembly progress

## Execution process
1. Created prg_0e_0f.asm with combined disassembly for banks 0E and 0F, mapped at $A000 (bank 0E) and $C000 (bank 0F)
2. Deleted obsolete individual stub files prg_08.asm through prg_0f.asm (all replaced by combined pair files: prg_08_09.asm, prg_0a_0b.asm, prg_0c_0d.asm, prg_0e_0f.asm)
3. Updated linker.cfg to change banks 0E/0F mapping from $8000 stubs to $A000/$C000 actual addresses
4. Updated all_banks.asm to include prg_0e_0f.asm instead of separate 0e/0f entries
5. Added verification tools: init_0e_0f.py, verify_0e_0f.py, scan_bank_links.py for bank initialization and linkage validation
6. Added temporary verification scripts for specific battle routines (tmp_verify_*.py) for b130, b536, c0bb, cfa2, d1ed, d390, d57b, d70f
7. Added bank switch analysis documentation (bank_switch_map.md, bank_switch_scan_raw.txt)
8. Updated repowiki documentation with new disassembly progress
9. Committed all changes via git commit with descriptive message

## Related files
- asm/banks/prg_0e_0f.asm (new combined disassembly)
- asm/banks/all_banks.asm (updated to include prg_0e_0f.asm)
- linker.cfg (updated bank 0E/0F addresses)
- tools/init_0e_0f.py (new bank initialization tool)
- tools/verify_0e_0f.py (new verification tool)
- tools/scan_bank_links.py (new linkage scanning tool)
- code/bank_switch_map.md (new documentation)
- code/bank_switch_scan_raw.txt (new analysis data)
- .qoder/repowiki/* (documentation updates)

## Notes
- None - the task proceeded smoothly without errors or detours
- The commit initially timed out due to multiline message escaping issues in fish shell; resolved by writing message to temp file and using -F flag

## Task overview
Completed successfully: consolidated PRG banks 0E-0F into prg_0e_0f.asm with proper memory mapping at $A000/$C000, removed 8 obsolete stub files, updated build configuration and documentation, added verification tools. Final commit: 35 files changed, 19,068 insertions, 394 deletions.
