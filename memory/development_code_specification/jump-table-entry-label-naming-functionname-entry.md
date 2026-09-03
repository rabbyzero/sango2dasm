# Jump table entry label naming: (FunctionName)_Entry

- **Category:** development_code_specification
- **Memory ID:** ead63306-29b6-4c08-875f-1b3eaf9d9cd9
- **Keywords:** Entry, label, naming, jump table, Function_Entry
- **Usage scenarios:**
  - Naming jump table entry labels in bank asm files
  - Commenting equates in functions.h for bank entry points

## Content

Jump table entry labels use the naming convention `(FunctionName)_Entry`, where FunctionName is the target function the entry jumps to. For example, the entry that jumps to `PPUTileRender` is labeled `PPUTileRender_Entry:`. This applies across all bank files (prg_0a_0b.asm, prg_17_18.asm, prg_1d_1e.asm) and their corresponding comments in functions.h.
