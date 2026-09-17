# PRG bank 0F code/data region boundaries

- **Category:** project_architecture
- **Memory ID:** bd70b98b-b1bc-441c-86c4-6b0d4dc503e4
- **Keywords:** PRG bank 0F, memory layout, code/data boundaries, $DFB5, $DD5E-$DF6D

## Content

PRG bank 0F (prg_0e_0f.asm) memory layout:
- $DFB5-$DFBE: Code region - SoundPlayAltDirect routine (LDY $07F5, LDA $0706,X, STA $4000,Y, RTS)
- $DD5E-$DF6D: Data region - Contains lookup tables (channel initialization parameters, delta offsets, threshold values, approach tables, volume scaling, frequency lookup tables). All bytes in this range are data, not executable code. Any apparent 6502 instructions in this range are misinterpretations of data bytes.
- $DFBF-$DFFF: Bank fill with $FF padding bytes
