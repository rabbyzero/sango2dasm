# Remove obsolete PRG bank assembly files after consolidation

- **Category:** task_summary_experience
- **Memory ID:** 85259360-5563-413d-8208-00a3f88c8698
- **Keywords:** assembly files, PRG bank consolidation, file cleanup, bank replacement

## Content

## Task description
- Core requirement: remove obsolete assembly files (prg_19.asm, prg_1a.asm, prg_1b.asm, prg_1c.asm) that were replaced by combined bank files
- Task background: the project consolidated PRG bank pairs into single files (prg_19_1a.asm replaces prg_19.asm + prg_1a.asm; prg_1b_1c.asm replaces prg_1b.asm + prg_1c.asm); old individual bank files needed removal to clean up the codebase

## Execution process
1. Verified existence of all four old files and their combined replacements using search_file tool
2. Searched codebase with grep for any references to old filenames - found 0 matches
3. Checked Makefile, linker.cfg, and main.asm for build-system references - found 0 matches
4. Confirmed no references existed in any configuration or source files
5. Deleted all four obsolete files: prg_19.asm, prg_1a.asm, prg_1b.asm, prg_1c.asm

## Related files
- /asm/banks/prg_19.asm (deleted)
- /asm/banks/prg_1a.asm (deleted)
- /asm/banks/prg_1b.asm (deleted)
- /asm/banks/prg_1c.asm (deleted)

## Notes
- None

## Task overview
Successfully removed four obsolete assembly files. All files had been replaced by combined bank pairs (prg_19_1a.asm and prg_1b_1c.asm). No references to the old files existed in main.asm, Makefile, or linker.cfg, so no additional updates were required.
