#!/usr/bin/env python3
"""One-shot region verification for AiFindNearbyOfficers ($A8D3-$A943):
slice prg_08_09.asm through AiFindNearbyOfficers' .endproc, force absolute
$00xx operands, assemble, link, compare $A000-$A943 against prg_08.bin."""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

# 1. regenerate harness source: bank file through AiFindNearbyOfficers' .endproc
lines = open("asm/banks/prg_08_09.asm").readlines()
start = next(i for i, l in enumerate(lines)
             if l.startswith(".proc AiFindNearbyOfficers"))
end = next(i for i in range(start, len(lines))
           if lines[i].startswith(".endproc")) + 1
region = "".join(lines[8:end])
region = region.replace('.segment "CODE_BANK08"',
                        '.segment "CODE_BANK08"\n.org $A000', 1)
stubs = open("build/_stubs.asm").read()
stubs = "".join(l for l in stubs.splitlines(True)
                if not l.startswith(("AiExecuteMove", "AiScanAdjacentOfficers",
                                     "AiFindNearbyOfficers")))
src = region + stubs
# 2. force absolute addressing for $00xx direct operands (ROM convention)
src = re.sub(r'(?<![#(])\$00([0-9A-Fa-f]{2})\b', r'a:$00\1', src)
open("build/_region.asm", "w").write(src)
print("patched operands:", src.count("a:$00"))

# 3. assemble + link
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

# 4. compare $A000-$A943 against prg_08.bin
assembled = open("build/_region.bin", "rb").read()
rom = open("rom/prg/prg_08.bin", "rb").read()
n = 0x944
mismatch = 0
for i in range(n):
    if assembled[i] != rom[i]:
        mismatch += 1
        if mismatch <= 20:
            print(f"MISMATCH ${0xA000+i:04X}: asm={assembled[i]:02X} rom={rom[i]:02X}")
print(f"compared {n} bytes, {mismatch} mismatches")
sys.exit(1 if mismatch else 0)
