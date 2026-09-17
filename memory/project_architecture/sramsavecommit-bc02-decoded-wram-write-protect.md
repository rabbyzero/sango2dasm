# SramSaveCommit $BC02 decoded; mapper-19 WRAM write-protect register semantics

- **Category:** project_architecture
- **Memory ID:** 3c46cc3e-be50-449c-850d-b0c49109354f
- **Keywords:** SramSaveCommit, WRAM write-protect, $F800, SRAM checksum, NAMCO_CTRL

## Content

## Goal
Decode the bare-label region $BC02-$BC7F in prg_19_1a.asm via the Verify/Replace/Rename/Fix/Explain workflow.

## Steps
1. Verified the caller: prg_1b_1c CastleSaveExecute $AC38 -> LDY #$39 trampoline -> banks $19+$1A stub $A02D (JMP $BC02).
2. Decoded the mapper-19 $F800 register semantics from NESdev: writes of $40-$4E are the WRAM write-protect register (upper nybble $4 enables writes; low bits 0-3 write-protect the four 2KB windows $6000-$67FF/$6800-$6FFF/$7000-$77FF/$7800-$7FFF); any value outside $40-$4E is the sound RAM address port. $00A5 (zp) is the software mirror of the write-protect state (written at boot $E0B7/$E589, saved/restored around NMI bank switches as $A5).
3. Established SRAM protocol: $6000-$6FFF = live working half; $7000-$7FFF = battery backup half. SramSaveCommit ($BC02) write-enables all windows ($40), stamps "ID" magic ($49/$44) at $6FFC/$6FFD, copies $6000-$6FFD -> $7000-$7FFD accumulating a 16-bit additive checksum into zp $0004/$0005, stores it at $7FFE/$7FFF, then re-protects the upper half ($4C). Counterparts: VerifySramChecksum (prg_0a_0b $DC2F) and CopySramToWork (prg_0a_0b $DC97).

## Notes
- Legacy mislabels fixed: functions.h B1F_NmiHandler = $F800 ("NMI handler") and namco163.h NAMCO_CTRL "Sound/IRQ control" were wrong; replaced with NAMCO_WRAM_WRITE_PROTECT + NAMCO_PROTECT_NONE $40 / NAMCO_PROTECT_UPPER $4C; NAMCO_CTRL kept as sound address port only. All 9 prg_1f NAMCO_PRG_8000_ALT sites (writing $4C or the $A5 mirror in NMI handlers/anti-piracy) renamed to NAMCO_WRAM_WRITE_PROTECT.
- Full `make` build fails with pre-existing cross-bank duplicate symbols (Loc_D601/Loc_D93D/... between prg_1b_1c and prg_19_1a; also within prg_0a_0b) — confirmed identical failure on HEAD versions; per-bank harnesses are the standard.

## Result
Region wrapped in .proc SramSaveCommit with zp aliases (src_ptr/dst_ptr/checksum) and @PageLoop/@CopyByte/@TailCopy; stub renamed SramSaveCommit_Entry; B19_1A_SramSaveCommit = $A02D added to functions.h; trampoline .word at $AC3B symbolized. verify_19_1a.py and verify_1b_1c.py: 16384 bytes, 0 mismatches each.
