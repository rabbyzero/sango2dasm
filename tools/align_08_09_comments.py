#!/usr/bin/env python3
"""Align prg_08_09.asm inline traceability comments to column 40.

After the a: force-absolute rewrite the padded comment columns drifted by
2 chars per insertion. This re-pads instruction-line comments to the file's
dominant column (40). Lines whose code already reaches col 40 are untouched.
"""
import re

PATH = "asm/banks/prg_08_09.asm"
COMMENT_COL = 40

MNEMONICS = (
    "ADC|AND|ASL|BCC|BCS|BEQ|BIT|BMI|BNE|BPL|BRK|BVC|BVS|CLC|CLD|CLI|CLV|"
    "CMP|CPX|CPY|DEC|DEX|DEY|EOR|INC|INX|INY|JMP|JSR|LDA|LDX|LDY|LSR|NOP|"
    "ORA|PHA|PHP|PLA|PLP|ROL|ROR|RTI|RTS|SBC|SEC|SED|SEI|STA|STX|STY|TAX|"
    "TAY|TSX|TXA|TXS|TYA"
)
IS_INSTR = re.compile(r"\s*(?:" + MNEMONICS + r")\s+\S")

n = 0
out = []
for line in open(PATH).read().split("\n"):
    if IS_INSTR.match(line) and ";" in line:
        semi = line.index(";")
        code = line[:semi].rstrip()
        rest = line[semi:]
        if len(code) < COMMENT_COL:
            line = code + " " * (COMMENT_COL - len(code)) + rest
            n += 1
    out.append(line)

open(PATH, "w").write("\n".join(out))
print("realigned {} comment columns".format(n))
