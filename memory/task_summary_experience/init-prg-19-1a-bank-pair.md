# Initialize prg_19_1a.asm combined PRG bank pair with byte-exact verification

- **Category:** task_summary_experience
- **Memory ID:** 1d31256e-473d-4cce-aba3-c0de0074d855
- **Keywords:** prg_19_1a, bank initialization, illegal NOP variant, Loc_ label collision, byte verification

## Content

## Task description
Initialize combined PRG bank pair prg_19_1a.asm for banks $19 ($A000-$BFFF) and $1A ($C000-$DFFF) in the Sangokushi 2 NES disassembly project.

## Execution process
1. Generated raw disassembly: tools/disasm_prg.py 0x19 0x1A -o output/prg_19_1a_raw.asm (6594 output lines, 84.8% code, 52 dispatch tables).
2. Created tools/init_19_1a.py (adapted from init_1b_1c.py): converted 66 bad instruction runs to .byte data, applied a: prefix for 3-byte absolute $00xx encodings, split $C000-boundary data rows, emitted .segment CODE_BANK19/CODE_BANK1A.
3. Key extra fix vs prior inits: illegal 1-byte NOP variants ($1A/$7A at $D898/$D8E2/$DDEE) were disassembled as bare NOP and ca65 emitted $EA; is_bad() now flags NOP whose byte != $EA for data conversion.
4. Updated linker.cfg: BANK19 start=$A000, BANK1A start=$C000 (were $8000 stubs); also aligned CODE_BANK19/CODE_BANK1A segment indent.
5. Updated all_banks.asm: replaced prg_19.asm + prg_1a.asm stubs with prg_19_1a.asm (stubs kept on disk, unused).
6. Created tools/verify_19_1a.py standalone harness; verified 16384 bytes, 0 mismatches vs rom/prg/prg_19.bin + prg_1a.bin.

## Related files
- asm/banks/prg_19_1a.asm (created, 6594 lines, 714 Loc_ labels)
- output/prg_19_1a_raw.asm (created)
- tools/init_19_1a.py, tools/verify_19_1a.py (created)
- linker.cfg, asm/banks/all_banks.asm (modified)

## Notes
- Full build baseline (ca65) has 107 pre-existing error lines; this change adds exactly 72 new lines = 36 Loc_XXXX duplicate-symbol pairs, all between prg_19_1a.asm and prg_1b_1c.asm (both freshly initialized banks share the $A000-$DFFF label space); zero other new errors, zero removed. These raw Loc_ labels are transient until semantic renaming.
- No external in-range JSR/JMP stubs needed by the verify harness (0 external refs).
- fish shell: $? is invalid (use $status), and process substitution <(...) unsupported — caused a chained && command to abort before sed ran; re-ran split commands.
