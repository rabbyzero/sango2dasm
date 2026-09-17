# Avoid disassembling banks 00-07 which are data-only terrain/tile/sprite assets

- **Category:** common_pitfalls_experience
- **Memory ID:** 54da40c5-765d-4890-b206-5935faf486ae
- **Keywords:** data-only banks, bank classification error, .incbin stubs, tile/sprite data, disassembly misclassification

## Content

## Bug class: Misclassifying data-only PRG banks as code for disassembly

## Root cause
PRG banks $00-$07 contain terrain detail maps, battle scene tiles, and sprite/animation frames — pure data assets. The disasm_prg.py tool classified 72.6% of bank 00/01 as "code" based on byte patterns, but this was a false positive from tile/sprite data resembling instruction opcodes.

## Fix pattern
Do not initialize banks $00-$07 as combined bank-pair disassemblies. Keep them as `.incbin` stubs in asm/banks/ pointing to rom/prg/prg_XX.bin files. Linker entries for BANK00/BANK01 must remain at `$8000` stub addresses, never mapped to `$A000/$C000`.

## Reusable lesson
Don't attempt bank-pair disassembly initialization on banks $00-$07 because they are data-only assets (terrain/tiles/sprites), not executable code; instead keep them as `.incbin` stubs. Applies when planning remaining bank conversions or reviewing bank classifications; does not apply to banks $08-$1F which contain actual game logic code.
