# Initialize prg_0e_0f.asm combined PRG bank pair with byte-exact verification

- **Category:** task_summary_experience
- **Memory ID:** 414cab10-0e8b-4e23-8d45-63be5efc9ac5
- **Keywords:** prg_0e_0f, bank initialization, illegal opcodes, byte verification, Namco-163

## Content

## Task description
- Core requirement: initialize combined PRG bank pair prg_0e_0f.asm for banks $0E ($A000-$BFFF) and $0F ($C000-$DFFF) in the Sangokushi 2 NES disassembly project.
- Task background: following the established pattern of prg_0c_0d.asm and prg_17_18.asm, new bank pairs require raw disassembly generation, transformation of invalid instructions to data, proper segment placement, and byte-exact verification against the original ROM.

## Execution process
1. Generated raw disassembly using tools/disasm_prg.py 0x0E 0x0F --output output/prg_0e_0f_raw.asm (7341 lines, 86.7% code, 31 dispatch tables detected).
2. Created tools/init_0e_0f.py to transform raw output:
   - Converted 49 contiguous instruction runs containing ca65-unsupported opcodes (SLO, JAM, RRA, ARR, NOP #imm) or straddling instructions into .byte data rows.
   - Applied `a:` prefix to direct $00xx operands where ROM uses 3-byte absolute encoding (ca65 would otherwise shrink to zero-page).
   - Split data rows crossing the $C000 boundary into separate .byte lines for each segment.
   - Emitted `.segment "CODE_BANK0E"` and `.segment "CODE_BANK0F"` with labels placed after segment switches.
3. Updated linker.cfg: set BANK0E start=$A000, BANK0F start=$C000.
4. Updated all_banks.asm: replaced stub includes for prg_0e.asm and prg_0f.asm with prg_0e_0f.asm (stubs kept on disk unused).
5. Created tools/verify_0e_0f.py standalone harness with .org $A000/.org $C000 directives to resolve branch range errors.
6. Verified byte-exact match: 16384 bytes compared, 0 mismatches against rom/prg/prg_0e.bin + prg_0f.bin.

## Related files
- /asm/banks/prg_0e_0f.asm (created, 6719 lines)
- /output/prg_0e_0f_raw.asm (created, 7341 lines)
- /tools/init_0e_0f.py (created)
- /tools/verify_0e_0f.py (created)
- /linker.cfg (modified: BANK0E/BANK0F addresses)
- /asm/banks/all_banks.asm (modified: include prg_0e_0f.asm)

## Notes
- Pre-existing build failure discovered: full `make` fails at HEAD d74639e with 53 duplicate symbol errors in prg_0a_0b.asm and cross-file duplicates; verified that my changes add zero new errors by comparing sorted error lists between HEAD worktree and working tree.
- Branch-to-numeric-target instructions (e.g., BEQ $A040) fail with "Range error" when assembled standalone without .org directives; resolved by adding .org $A000/$C000 in verification harness.
- The garbage region at $BFEB-$C000 contained a JMP ($0800) straddling the bank boundary; correctly split into .byte rows across both segments.

## Task overview
Completed: prg_0e_0f.asm initialized and verified byte-exact match (16384 bytes, 0 mismatches). Pre-existing build breakage (53 errors) confirmed unrelated to this change; offered to fix as follow-up if desired.
