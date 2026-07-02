#!/usr/bin/env python3
"""Generate the final prg_1d.asm with headers and disassembly."""
import subprocess
import sys

# Get the raw disassembly
with open('/tmp/disasm_1d_final.txt') as f:
    disasm = f.read()

header = """\
;===============================================================================
; PRG Bank $1D - $A000-$BFFF (8KB)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Jump table at $A000-$A047 (24 entries)
; Code: $A048-$B304 (with inline data tables)
; Data: $B305-$B988 (tile/map data, ~1636 bytes)
; Code: $B989-$BFFF (menu/UI handler code)
;
; Part of combined 16KB: prg_1d_1e.asm ($A000-$DFFF)
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

.segment "CODE_BANK1D"

;===============================================================================
; Jump Table ($A000-$A047) - 24 entries dispatched by game state
;===============================================================================
"""

print(header)
print(disasm.rstrip())
