# Per-bank verification harness and linker segment configuration

- **Category:** project_build_configuration
- **Memory ID:** c51e49b5-7f40-4bb0-9854-bb8ecda7705b
- **Keywords:** Makefile, per-bank verification, linker configuration, CODE_BANK segments
- **Usage scenarios:**
  - When building PRG banks with per-bank harness approach
  - Configuring linker segment addresses for combined bank pairs
  - Verifying ROM byte-exactness when full build is broken

## Content

The Sangokushi 2 disassembly project uses a Makefile-based build system with per-bank verification harnesses. When full build fails due to pre-existing duplicate-symbol errors, byte-exact verification is performed using standalone Python harnesses (e.g., tools/verify_19_1a.py) that assemble only target banks and compare against ROM binaries. The linker.cfg defines CODE_BANK segments with specific start addresses: BANK19=$A000, BANK1A=$C000, BANK1B=$A000, BANK1C=$C000 for combined 16K bank pairs covering the $A000-$DFFF address space.
