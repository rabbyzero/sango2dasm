# ca65 range errors from numeric branch targets in bank disassembly

- **Category:** common_pitfalls_experience
- **Memory ID:** c712d7bc-2d87-4298-ba5a-7eed996e6871
- **Keywords:** ca65 range error, numeric branch target, bank assembly, byte-exact verify, linker config
- **Usage scenarios:**
  - Assembling prg bank files standalone for byte-exact verification
  - Decoding new raw .byte blobs into instructions in bank files
  - Fixing disassembly build errors before applying code-analysis edits

## Content

## Usage Scenario
- Assembling a prg bank .asm standalone (e.g. `ca65 -I include -I asm/banks -o out.o asm/banks/prg_XX.asm`) fails with "Range error (Address size 2 does not match fragment size 1)".
- Any bank file still containing raw branch instructions with numeric targets.

## Usage Method
- Root cause: branch operands written as `BNE $C920` are 16-bit numeric expressions but branches need 8-bit operands; ca65 cannot use a bare hex address as a relative target.
- Fix: insert a label at the target address (address is recoverable from the `; $XXXX:` hex comments) and reference the label; `Loc_XXXX:` at file scope, `@loc_XXXX:` inside a .proc. See tools/fix_numeric_branches_0e_0f.py (adapted from transform_branches.py which fixed prg_1f.asm the same way).
- Caveat: some numeric "branches" are actually data mis-disassembled as code (e.g. delta ramp tables at $DDEF in prg_0e_0f.asm where bytes are `10 20 30 40...`); convert those lines to `.byte` instead.
- Verify bank edits with a per-bank linker config (e.g. tools/test_0e_0f.cfg: PRG0E $A000/$2000 + PRG0F $C000/$2000, fill $FF) and diff the 16KB output against rom/prg/prg_0e.bin + prg_0f.bin.

## Notes
- Full `make` is still broken by pre-existing duplicate-symbol errors in prg_17_18.asm vs prg_0c_0d.asm/prg_0a_0b.asm (map_scroll_ptr_hi, sram_game_start_flag) — unrelated to per-bank verification.
- Beware stale .o masking failures: ca65 errors piped to `head` hide the exit code, and ld65 happily links the old object. Check `$status` (fish) before linking.
