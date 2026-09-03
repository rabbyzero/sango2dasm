# Use disasm_prg.py for new PRG bank disassembly

- **Category:** development_practice_specification
- **Memory ID:** eb686c7f-3a85-47cb-b7fa-8c1a8a502cee
- **Keywords:** disasm_prg, PRG bank, disassembly, tool, first step
- **Usage scenarios:**
  - Starting disassembly of a new PRG bank pair
  - Need initial code/data identification for a bank
  - Creating raw disassembly output for analysis

## Content

When disassembling a new PRG bank, always use tools/disasm_prg.py first. It combines two 8KB bank binaries into a 16KB image at $A000-$DFFF, performs multi-pass code/data analysis (branch/jump/JSR targets, dispatcher table detection for $EADE and $EE07), and outputs ca65-compatible assembly with Loc_XXXX labels. Usage: python3 tools/disasm_prg.py 0xNN 0xMM --output output/prg_NN_MM_raw.asm
