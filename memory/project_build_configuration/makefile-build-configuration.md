# Makefile Build Configuration

- **Category:** project_build_configuration
- **Memory ID:** 17046208-039a-4b70-85d5-e4e494b99abc
- **Keywords:** Makefile, build targets, ROM build, disasm, verify
- **Usage scenarios:**
  - Learning how to build, disassemble, or analyze the ROM using available Make targets
  - Understanding the build flow and output structure

## Content

Build Tool: Makefile

Key Targets:
- `make all`: Assemble and build final .nes ROM
- `make split`: Split original ROM into bank files
- `make banks`: Generate assembly stubs for PRG banks
- `make disasm`: Disassemble a binary segment (requires FILE, ADDR, LEN)
- `make analyze`: Analyze ROM structure
- `make verify`: Compare built ROM with original
- `make clean` / `make distclean`: Remove build artifacts or all generated files

Output: `build/sango2.nes` with 262144-byte PRG
