#!/usr/bin/env python3
"""
Assemble the final prg_1d_1e.asm with:
- Bank $1D: Full disassembly (replacing .incbin)
- Bank $1E: Placeholder with .incbin (still pending disassembly)
"""

# Read the bank $1D disassembly
with open('/tmp/prg_1d_final.asm') as f:
    bank_1d = f.read()

# Build the combined file
# The bank $1D disassembly already has its own header, includes, and .segment
# We need to add the bank $1E section after it

bank_1e_section = """
;===============================================================================
; Bank $1E - $C000-$DFFF
;===============================================================================

.segment "CODE_BANK1E"

; TODO: Disassemble code here
; Original binary: rom/prg/prg_1e.bin

.incbin "rom/prg/prg_1e.bin"
"""

# The bank_1d content already has .include and .segment directives
# We just append the bank $1E section
combined = bank_1d.rstrip() + '\n' + bank_1e_section

with open('/home/zero/project/sango2dasm/asm/banks/prg_1d_1e.asm', 'w') as f:
    f.write(combined)

import os
size = os.path.getsize('/home/zero/project/sango2dasm/asm/banks/prg_1d_1e.asm')
with open('/home/zero/project/sango2dasm/asm/banks/prg_1d_1e.asm') as f:
    lines = len(f.readlines())
print(f"Written prg_1d_1e.asm: {lines} lines, {size} bytes")
