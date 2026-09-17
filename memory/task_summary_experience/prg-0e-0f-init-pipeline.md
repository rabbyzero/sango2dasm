# prg_0e_0f.asm initialization pipeline and verification

- **Category:** task_summary_experience
- **Memory ID:** b457d9a6-d6f3-43f4-adbf-7bcad0ab4f0d
- **Keywords:** prg_0e_0f, bank init pipeline, illegal opcode runs, a: prefix, standalone verify harness

## Content

Initialized asm/banks/prg_0e_0f.asm (banks $0E $A000-$BFFF + $0F $C000-$DFFF, 86.7% code). Pipeline: tools/disasm_prg.py 0x0E 0x0F -> output/prg_0e_0f_raw.asm, then tools/init_0e_0f.py which (1) converts every contiguous instruction run containing a ca65-unsupported opcode (SLO/JAM/RRA/ARR/NOP-with-operand) or an instruction straddling $BFFF/$C000 into .byte data (49 runs), (2) prefixes a: to direct $00xx operands whose ROM encoding is absolute 3-byte, (3) regenerates Code/Data region markers, (4) emits .segment CODE_BANK0E/CODE_BANK0F with labels placed AFTER the segment switch and data rows split at $C000. linker.cfg BANK0E/BANK0F moved to $A000/$C000; all_banks.asm now includes prg_0e_0f.asm (stubs prg_0e/0f.asm kept on disk, unused). Verified with tools/verify_0e_0f.py: standalone ca65+ld65 harness inserting .org $A000/.org $C000 (needed or numeric branch targets give Range errors), 16384 bytes, 0 mismatches vs ROM.
