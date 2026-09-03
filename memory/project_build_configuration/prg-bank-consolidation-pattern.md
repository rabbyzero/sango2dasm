# PRG bank consolidation pattern and memory mapping

- **Category:** project_build_configuration
- **Memory ID:** adf08ad0-d19c-4a62-bd46-f57ccc237b68
- **Keywords:** PRG bank consolidation, paired bank files, linker configuration, NES disassembly
- **Usage scenarios:**
  - When adding new disassembled banks to the project
  - When updating linker configuration for bank address mappings

## Content

The Sangokushi 2 NES disassembly project consolidates PRG banks into paired files following the pattern: prg_08_09.asm, prg_0a_0b.asm, prg_0c_0d.asm, prg_0e_0f.asm.

Each pair represents contiguous memory regions mapped at specific addresses in linker.cfg (e.g., banks 0E/0F mapped at $A000/$C000).

Individual stub files (prg_XX.asm) are removed once consolidated into combined files.

The build system uses a Makefile-driven workflow with segment definitions in linker.cfg specifying start addresses, sizes, and binary file paths for each bank.
