# Initialize prg_1b_1c.asm combined PRG bank pair with byte-exact verification

- **Category:** task_summary_experience
- **Memory ID:** 7a911110-32c0-4954-aced-4444b00cdcee
- **Keywords:** prg_1b_1c, bank initialization, byte verification, combined PRG bank, Namco-163

## Content

## Task description
Initialize combined PRG bank pair prg_1b_1c.asm for banks $1B ($A000-$BFFF) and $1C ($C000-$DFFF) in the Sangokushi 2 NES disassembly project.

## Execution process
1. Generated raw disassembly: tools/disasm_prg.py 0x1B 0x1C --output output/prg_1b_1c_raw.asm (7080 lines, 88.9% code, 48 dispatch tables).
2. Created tools/init_1b_1c.py to transform raw output:
   - Converted 7 contiguous instruction runs containing ca65-unsupported opcodes (SLO, JAM, RRA, NOP #imm) or straddling $BFFF/$C000 boundary into .byte data.
   - Applied a: prefix to direct $00xx operands where ROM uses 3-byte absolute encoding.
   - Split data rows crossing the $C000 boundary.
   - Emitted .segment "CODE_BANK1B" and .segment "CODE_BANK1C".
3. Updated linker.cfg: BANK1B start=$A000, BANK1C start=$C000.
4. Updated all_banks.asm: replaced prg_1b.asm + prg_1c.asm stubs with prg_1b_1c.asm.
5. Created tools/verify_1b_1c.py standalone harness with .org $A000/$C000 directives.
6. Verified byte-exact match: 16384 bytes, 0 mismatches vs ROM.

## Related files
- asm/banks/prg_1b_1c.asm (created, 7000 lines)
- output/prg_1b_1c_raw.asm (created, 7080 lines)
- tools/init_1b_1c.py (created)
- tools/verify_1b_1c.py (created)
- linker.cfg (modified: BANK1B/BANK1C addresses)
- asm/banks/all_banks.asm (modified: include prg_1b_1c.asm)

## Notes
- 4 external in-range JSR/JMP targets stubbed in verify harness ($D472, $D628, $DCD0, $DD70).
- 27 out-of-range refs to $E000+ (bank-1F fixed engine) use raw addresses.
- Illegal opcodes found: 5x SLO, 1x JAM, 1x RRA; plus 4x NOP #imm.
