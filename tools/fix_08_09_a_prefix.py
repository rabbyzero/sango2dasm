#!/usr/bin/env python3
"""Fix prg_08_09.asm zero-page encoding drift: add `a:` force-absolute prefixes.

The ROM uses absolute encoding (8D/AD/8E/...) for all direct $00xx operands,
but ca65 auto-selects zero-page encoding for operands that fit in one byte
(literals like `$0020` and equate symbols valued `$00xx`), shifting every
later byte. This rewrites instruction operands in place, matching the
convention already used in prg_0e_0f.asm / prg_1b_1c.asm (e.g. `a:btl_pad1_lo`).

Only instruction lines are touched; equates, .byte/.word data, and comments
are left unchanged. Immediate (#), indirect (( ), and indexed-indirect forms
are excluded by lookbehind checks.
"""
import re
import sys

PATH = "asm/banks/prg_08_09.asm"

MNEMONICS = (
    "ADC|AND|ASL|BCC|BCS|BEQ|BIT|BMI|BNE|BPL|BRK|BVC|BVS|CLC|CLD|CLI|CLV|"
    "CMP|CPX|CPY|DEC|DEX|DEY|EOR|INC|INX|INY|JMP|JSR|LDA|LDX|LDY|LSR|NOP|"
    "ORA|PHA|PHP|PLA|PLP|ROL|ROR|RTI|RTS|SBC|SEC|SED|SEI|STA|STX|STY|TAX|"
    "TAY|TSX|TXA|TXS|TYA"
)
IS_INSTR = re.compile(r"\s*(?:" + MNEMONICS + r")\s+")
LIT = re.compile(r"(?<![#($])\$00[0-9A-Fa-f]{2}\b")

src = open(PATH).read()

# zp-valued equate symbols used as direct operands
zp_syms = re.findall(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\$00[0-9A-Fa-f]{2}\b",
                     src, re.M)
sym_pat = re.compile(r"(?<![#($A-Za-z0-9_])(" + "|".join(zp_syms) + r")\b")

lit_n = sym_n = 0
out = []
for line in src.split("\n"):
    if IS_INSTR.match(line):
        line, k = LIT.subn(lambda m: "a:" + m.group(0), line)
        lit_n += k
        if zp_syms:
            line, k = sym_pat.subn(r"a:\1", line)
            sym_n += k
    out.append(line)

open(PATH, "w").write("\n".join(out))
print("forced absolute on {} literal and {} symbol operands ({} zp symbols)".format(
    lit_n, sym_n, len(zp_syms)))
