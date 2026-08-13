#!/usr/bin/env python3
"""Region verification for $C0BB-$C982 (AiOfficerActionDispatch) of
prg_08_09.asm. Slices the proc out of the bank file, forces absolute $00xx
operands on instruction lines, assembles, links at $C0BB, and compares
against prg_09.bin."""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

START, END = 0xC0BB, 0xC983  # [start, end)

# 1. slice: includes + segment + the proc block
lines = open("asm/banks/prg_08_09.asm").readlines()
start = next(i for i, l in enumerate(lines)
             if l.strip() == ".proc AiOfficerActionDispatch")
# back up over the banner comment lines
while start > 0 and lines[start - 1].startswith(";"):
    start -= 1
end = next(i for i, l in enumerate(lines)
           if l.startswith(".endproc  ; AiOfficerActionDispatch")) + 1
region = "".join(lines[start:end])
header = ('.include "6502_registers.h"\n'
          '.include "namco163.h"\n'
          '.include "functions.h"\n'
          '.segment "CODE_BANK09"\n')
src = header + region

# 2. force absolute addressing for $00xx direct operands (ROM convention);
#    skip data directives where $00xx values are plain words/bytes
out = []
for l in src.splitlines(keepends=True):
    if not re.match(r'\s*\.(word|byte)', l):
        l = re.sub(r'(?<![#(])\$00([0-9A-Fa-f]{2})\b', r'a:$00\1', l)
    out.append(l)
src = "".join(out)
open("build/_region09.asm", "w").write(src)

# 3. linker config placing the slice at $C0BB
cfg = ("MEMORY { BANK09: start = $C0BB, size = $%X, file = %%O, "
       "fill = yes, fillval = $00; }\n"
       "SEGMENTS { CODE_BANK09: load = BANK09, type = ro; }\n"
       % (END - START))
open("build/_region09.cfg", "w").write(cfg)

# 4. assemble + link
r = subprocess.run([CC65, "-I", "include", "build/_region09.asm",
                    "-o", "build/_region09.o"], capture_output=True, text=True)
if r.returncode != 0:
    print("CA65 FAILED:\n" + r.stderr[:4000])
    sys.exit(1)
r = subprocess.run([LD65, "-C", "build/_region09.cfg", "build/_region09.o",
                    "-o", "build/_region09.bin"], capture_output=True, text=True)
if r.returncode != 0:
    print("LD65 FAILED:\n" + r.stderr[:4000])
    sys.exit(1)

# 5. compare against prg_09.bin (bank 9 mapped at $C000)
assembled = open("build/_region09.bin", "rb").read()
rom = open("rom/prg/prg_09.bin", "rb").read()
off = START - 0xC000
n = END - START
if len(assembled) < n:
    print("ASSEMBLED TOO SHORT: %d < %d" % (len(assembled), n))
    sys.exit(1)
mismatch = 0
for i in range(n):
    if assembled[i] != rom[off + i]:
        mismatch += 1
        if mismatch <= 30:
            print("MISMATCH $%04X: asm=%02X rom=%02X"
                  % (START + i, assembled[i], rom[off + i]))
print("compared %d bytes ($%04X-$%04X), %d mismatches"
      % (n, START, END - 1, mismatch))
sys.exit(1 if mismatch else 0)
