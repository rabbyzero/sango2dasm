#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_0c_0d.asm.

Assembles the bank file in isolation: external references are stubbed with
equates, both segments are laid out back-to-back at $A000, and the 16KB
output is compared against rom/prg/prg_0c.bin + rom/prg/prg_0d.bin.
"""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

src = open("asm/banks/prg_0c_0d.asm").read()
# Fix the PC at the bank bases so relative branches resolve as in the real layout
src = src.replace('.segment "CODE_BANK0C"',
                  '.segment "CODE_BANK0C"\n.org $A000', 1)
src = src.replace('.segment "CODE_BANK0D"',
                  '.segment "CODE_BANK0D"\n.org $C000', 1)

stubs = """\
; RAM globals owned by other bank files (addresses per prg_0c_0d.asm header)
"""
for attempt in range(10):
    open("build/_region0c_0d.asm", "w").write(src + "\n" + stubs)
    r = subprocess.run([CC65, "-I", "include", "build/_region0c_0d.asm",
                        "-o", "build/_region0c_0d.o"],
                       capture_output=True, text=True)
    if r.returncode == 0:
        break
    missing = sorted(set(re.findall(r"Symbol '([A-Za-z_][A-Za-z0-9_]*)' is undefined",
                                    r.stderr)))
    if not missing:
        print("CA65 FAILED:\n" + r.stderr[:3000])
        sys.exit(1)
    print("stubbing undefined symbols:", ", ".join(missing))
    stubs += "".join("{} = 0\n".format(s) for s in missing)
if r.returncode != 0:
    print("CA65 FAILED after stubbing:\n" + r.stderr[:3000])
    sys.exit(1)
if r.stderr.strip():
    print("ca65 warnings:\n" + r.stderr[:1000])

cfg = """
MEMORY {
    BANK0C: start = $A000, size = $2000, type = ro, fill = yes, fillval = $FF,
            file = "build/_bank0c.bin";
    BANK0D: start = $C000, size = $2000, type = ro, fill = yes, fillval = $FF,
            file = "build/_bank0d.bin";
}
SEGMENTS {
    CODE_BANK0C: load = BANK0C, type = ro;
    CODE_BANK0D: load = BANK0D, type = ro;
}
"""
open("build/_region0c_0d.cfg", "w").write(cfg)

r = subprocess.run([LD65, "-C", "build/_region0c_0d.cfg", "build/_region0c_0d.o",
                    "-o", "build/_region0c_0d.out"], capture_output=True, text=True)
if r.returncode != 0:
    print("LD65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)

assembled = (open("build/_bank0c.bin", "rb").read() +
             open("build/_bank0d.bin", "rb").read())
rom = (open("rom/prg/prg_0c.bin", "rb").read() +
       open("rom/prg/prg_0d.bin", "rb").read())
if len(assembled) != len(rom):
    print("length mismatch: {} vs {}".format(len(assembled), len(rom)))
    sys.exit(1)
mismatch = 0
for i, (a, b) in enumerate(zip(assembled, rom)):
    if a != b:
        mismatch += 1
        if mismatch <= 30:
            print("MISMATCH ${:04X}: asm={:02X} rom={:02X}".format(
                0xA000 + i, a, b))
print("compared {} bytes, {} mismatches".format(len(rom), mismatch))
sys.exit(1 if mismatch else 0)
