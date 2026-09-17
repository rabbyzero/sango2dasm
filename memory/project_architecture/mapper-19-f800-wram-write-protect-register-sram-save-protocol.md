# Mapper-19 $F800 WRAM write-protect register and SRAM save protocol

- **Category:** project_architecture
- **Memory ID:** df508a07-3f28-4e5b-8578-e4045f9f2a76
- **Keywords:** mapper-19, $F800, WRAM write-protect, SRAM layout, checksum protocol, NAMCO_WRAM_WRITE_PROTECT

## Content

Mapper-19 $F800 register has dual role based on write value: writes of $40-$4E (upper nybble $4) are the WRAM write-protect register where low bits 0-3 protect each 2KB window ($6000-$67FF=A, $6800-$6FFF=B, $7000-$77FF=C, $7800-$7FFF=D; 1=protected); any other value is the sound RAM address port. The zero-page address $00A5 serves as the software mirror of the write-protect state, written at boot (prg_1f $E0B7/$E589 with value $4C to protect upper half $7000-$7FFF), saved/restored around NMI bank switches. SRAM layout: $6000-$6FFF = live working game state (country records, gold/rice pools, map camera, AI scratch space); $7000-$7FFF = battery-backed snapshot with "ID" magic at $7FFC/$7FFD and 16-bit additive checksum at $7FFE/$7FFF computed over copied bytes $6000-$6FFD. Save protocol: SramSaveCommit ($BC02 in prg_19_1a.asm) writes $40 (unprotect all), stamps "ID", copies $6000-$6FFD -> $7000-$7FFD with checksum, stores checksum at $7FFE/$7FFF, writes $4C (protect upper half). Counterparts: VerifySramChecksum ($DC2F in prg_0a_0b.asm) checks "ID" and verifies checksum; CopySramToWork ($DC97 in prg_0a_0b.asm) restores from backup by writing $4C and copying $7000-$7FFF -> $6000-$6FFF. Legacy equates fixed: functions.h B1F_NmiHandler = $F800 removed; namco163.h NAMCO_WRAM_WRITE_PROTECT = $F800 added with NAMCO_PROTECT_NONE=$40 / NAMCO_PROTECT_UPPER=$4C constants; NAMCO_CTRL kept for sound address port only.
