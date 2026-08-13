#!/usr/bin/env python3
"""Region verification for merged AiTurnProcess ($A000-$B12F):
slice prg_08_09.asm through the merged .endproc, force absolute
$00xx operands, assemble, link, compare $A000-$B130 against prg_08.bin."""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

# 1. harness source: bank file through the merged AiTurnProcess .endproc
lines = open("asm/banks/prg_08_09.asm").readlines()
start = next(i for i, l in enumerate(lines)
             if "JMP Mul24x8" in l and "$B12D" in l)
end = next(i for i in range(start, len(lines))
           if lines[i].startswith(".endproc")) + 1
region = "".join(lines[8:end])
region = region.replace('.segment "CODE_BANK08"',
                        '.segment "CODE_BANK08"\n.org $A000', 1)
# 2. stubs: only symbols defined later in the bank (drop ones the slice defines)
defined = set(re.findall(r'\.proc (\w+)', region))
defined |= set(re.findall(r'^(\w+):', region, re.M))
stubs = []
for l in open("build/_stubs.asm").readlines():
    m = re.match(r'(\w+) = ', l)
    if m and m.group(1) in defined:
        continue
    stubs.append(l)
src = region + "".join(stubs)
# 3. force absolute addressing for $00xx direct operands (ROM convention)
src = re.sub(r'(?<![#(])\$00([0-9A-Fa-f]{2})\b', r'a:$00\1', src)
open("build/_region.asm", "w").write(src)
print("patched operands:", src.count("a:$00"))

# 4. assemble + link
r = subprocess.run([CC65, "-I", "include", "build/_region.asm",
                    "-o", "build/_region.o"], capture_output=True, text=True)
if r.returncode != 0:
    print("CA65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)
r = subprocess.run([LD65, "-C", "build/_region.cfg", "build/_region.o",
                    "-o", "build/_region.bin"], capture_output=True, text=True)
if r.returncode != 0:
    print("LD65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)

# 5. compare $A000-$B130 against prg_08.bin
assembled = open("build/_region.bin", "rb").read()
rom = open("rom/prg/prg_08.bin", "rb").read()
n = 0xB130 - 0xA000
mismatch = 0
for i in range(n):
    if assembled[i] != rom[i]:
        mismatch += 1
        if mismatch <= 30:
            print(f"MISMATCH ${0xA000+i:04X}: asm={assembled[i]:02X} rom={rom[i]:02X}")
print(f"compared {n} bytes, {mismatch} mismatches")
sys.exit(1 if mismatch else 0)
