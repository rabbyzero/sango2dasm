;===============================================================================
; Main.asm - Main entry point for Sangokushi 2 - Haou no Tairiku disassembly
; Namco-163 (Mapper 19)
;
; This file includes all PRG bank sources. Each bank outputs to its own 8KB
; binary via the linker config. The Makefile concatenates them into the
; full 256KB PRG ROM.
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"

;===============================================================================
; Include all PRG bank files (stubs + disassembled banks)
;===============================================================================

.include "banks/all_banks.asm"
