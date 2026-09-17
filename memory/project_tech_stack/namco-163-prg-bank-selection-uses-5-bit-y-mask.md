# Namco-163 PRG bank selection uses 5-bit Y mask

- **Category:** project_tech_stack
- **Memory ID:** 5e7ed971-4779-4e5d-9e44-b7017642ffcd
- **Keywords:** Namco-163, PRG bank, Y register, bank selection, 32 banks

## Content

The Namco-163 (Mapper 19) in this project uses 32 PRG banks (256KB total). Bank selection via Y register follows the formula: `effective_bank = Y & $1F` (5-bit mask). When SwitchBankAC_B writes Y to NAMCO_PRG_A000 ($E800), it masks to 5 bits, so Y=$37 → bank $17, Y=$3B → bank $1B, Y=$3D → bank $1D. The high bits (bit 5 and above) are ignored or used for other purposes (e.g., CHR-RAM control via ORA #$C0). This applies to both $A000-$BFFF and $C000-$DFFF bank windows.
