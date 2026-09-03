# Combined PRG bank pair architecture and linker layout pattern

- **Category:** project_architecture
- **Memory ID:** 60dc689b-8ca3-492f-97c5-5fd3f34480a3
- **Keywords:** combined PRG banks, linker layout, CODE_BANK segments, 16K bank pairs
- **Usage scenarios:**
  - Implementing combined bank disassembly for adjacent PRG banks
  - Configuring linker segments for 16K bank pair layouts
  - Creating verification harnesses for combined bank pairs

## Content

The Sangokushi 2 disassembly project uses a combined PRG bank pair pattern where banks $19+$1A and $1B+$1C are merged into single assembly files (prg_19_1a.asm, prg_1b_1c.asm) covering the 16K address space $A000-$DFFF. The linker.cfg defines CODE_BANK segments with start=$A000 for the first bank and start=$C000 for the second bank within each pair, replacing previous $8000 stub configurations. This combined layout allows unified verification harnesses that assemble both banks together and compare against concatenated ROM binaries (prg_XX.bin + prg_YY.bin). The all_banks.asm file includes these combined bank files instead of individual stub files.
