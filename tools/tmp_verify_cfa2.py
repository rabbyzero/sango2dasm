#!/usr/bin/env python3
"""Byte-exact verification of the BattleStatusPanelDraw proc (CFA2-D1EC)
extracted from prg_08_09.asm. Assembles the proc standalone at $CFA2 and
compares against prg_09.bin."""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

lines = open("asm/banks/prg_08_09.asm").readlines()
start = next(i for i, l in enumerate(lines)
             if "; BattleStatusPanelDraw - battle status panel" in l) - 1
end = next(i for i, l in enumerate(lines)
           if l.strip() == ".endproc  ; BattleStatusPanelDraw")
proc = "".join(lines[start:end + 1])
# force absolute addressing for $00xx operands (ROM uses 3-byte absolutes)
proc = re.sub(r'(?<![#(<a-zA-Z:])\$00([0-9A-Fa-f]{2})\b', r'a:$00\1', proc)

src = ('.include "functions.h"\n'
       '.segment "CODE_BANK09"\n'
       '.org $CFA2\n' + proc)
open("build/_proc_cfa2.asm", "w").write(src)

cfg = ('MEMORY { B09: start = $CFA2, size = $024B, file = %O, '
       'fill = yes, fillval = $FF; }\n'
       'SEGMENTS { CODE_BANK09: load = B09, type = ro; }\n')
open("build/_proc_cfa2.cfg", "w").write(cfg)

r = subprocess.run([CC65, "-I", "include", "build/_proc_cfa2.asm",
                    "-o", "build/_proc_cfa2.o"], capture_output=True, text=True)
if r.returncode != 0:
    print("CA65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)
r = subprocess.run([LD65, "-C", "build/_proc_cfa2.cfg", "build/_proc_cfa2.o",
                    "-o", "build/_proc_cfa2.bin"], capture_output=True, text=True)
if r.returncode != 0:
    print("LD65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)

assembled = open("build/_proc_cfa2.bin", "rb").read()
rom = open("rom/prg/prg_09.bin", "rb").read()
base = 0xCFA2 - 0xC000
n = 0xD1ED - 0xCFA2
mismatch = 0
for i in range(n):
    if assembled[i] != rom[base + i]:
        mismatch += 1
        if mismatch <= 30:
            print("MISMATCH $%04X: asm=%02X rom=%02X"
                  % (0xCFA2 + i, assembled[i], rom[base + i]))
print("compared $CFA2-$D1EC (%d bytes): %d mismatches" % (n, mismatch))
sys.exit(1 if mismatch else 0)
