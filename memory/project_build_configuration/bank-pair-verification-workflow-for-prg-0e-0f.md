# Bank-pair verification workflow for prg_0e_0f.asm

- **Category:** project_build_configuration
- **Memory ID:** 99822cea-0f28-4eaa-98c5-5cdc85f47db8
- **Keywords:** verify_0e_0f.py, bank pair verification, byte-exact check, build verification

## Content

When make all fails due to pre-existing duplicate-symbol errors in other banks, use tools/verify_0e_0f.py for byte-exact verification of PRG banks $0E+$0F. This script assembles prg_0e_0f.asm into build/_bank0e.bin and build/_bank0f.bin (16384 bytes total) and compares against rom/prg/prg_0e.bin and rom/prg/prg_0f.bin. Success is indicated by "compared 16384 bytes, 0 mismatches". This per-bank harness approach is necessary when the full build is broken but individual bank changes need verification.
