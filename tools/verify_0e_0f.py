#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_0e_0f.asm.

Assembles the bank file in isolation: external references ($E000-$FFFF
bank-1F helpers, etc.) are stubbed with equates, both segments are laid
out back-to-back at $A000, and the 16KB output is compared against
rom/prg/prg_0e.bin + rom/prg/prg_0f.bin.
"""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

src = open("asm/banks/prg_0e_0f.asm").read()
# Fix the PC at the bank bases so relative branches resolve as in the real layout
src = src.replace('.segment "CODE_BANK0E"',
                  '.segment "CODE_BANK0E"\n.org $A000', 1)
src = src.replace('.segment "CODE_BANK0F"',
                  '.segment "CODE_BANK0F"\n.org $C000', 1)

# Symbols defined inside the bank (Loc_ labels)
defined = set(re.findall(r"^(Loc_[0-9A-F]{4}):", src, re.M))

# All absolute $xxxx operands referenced
refs = set()
for m in re.finditer(r"(?:JSR|JMP)\s+\$([0-9A-F]{4})", src):
    refs.add(int(m.group(1), 16))
for m in re.finditer(r"(?:JSR|JMP)\s+a:\$([0-9A-F]{4})", src):
    refs.add(int(m.group(1), 16))

external = sorted(a for a in refs
                  if 0xA000 <= a < 0xE000 and "Loc_{:04X}".format(a) not in defined)
stubs = "".join("ext_{:04X} = ${:04X}\n".format(a, a) for a in external)
# Point the external absolute operands at the stub symbols
for a in external:
    src = re.sub(r"(JSR|JMP)(\s+)a:\${:04X}\b".format(a),
                 r"\1\2ext_{:04X}".format(a), src)
    src = re.sub(r"(JSR|JMP)(\s+)\${:04X}\b".format(a),
                 r"\1\2ext_{:04X}".format(a), src)

harness = src + "\n" + stubs
# RAM globals owned by other bank files (referenced, not redefined, here)
external_ram = [
    "menu_cursor_col = $0424\n",
    "menu_cursor_page = $0425\n",
    "war_scene_id = $0500\n",
    "war_scene_phase = $0501\n",
]
open("build/_region.asm", "w").write(harness + "\n" + "".join(external_ram))
print("external stubs:", len(external))

cfg = """
MEMORY {
    BANK0E: start = $A000, size = $2000, type = ro, fill = yes, fillval = $FF,
            file = "build/_bank0e.bin";
    BANK0F: start = $C000, size = $2000, type = ro, fill = yes, fillval = $FF,
            file = "build/_bank0f.bin";
}
SEGMENTS {
    CODE_BANK0E: load = BANK0E, type = ro;
    CODE_BANK0F: load = BANK0F, type = ro;
}
"""
open("build/_region.cfg", "w").write(cfg)

r = subprocess.run([CC65, "-I", "include", "build/_region.asm",
                    "-o", "build/_region.o"], capture_output=True, text=True)
if r.returncode != 0:
    print("CA65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)
if r.stderr.strip():
    print("ca65 warnings:\n" + r.stderr[:1000])
r = subprocess.run([LD65, "-C", "build/_region.cfg", "build/_region.o",
                    "-o", "build/_region.out"], capture_output=True, text=True)
if r.returncode != 0:
    print("LD65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)

assembled = (open("build/_bank0e.bin", "rb").read() +
             open("build/_bank0f.bin", "rb").read())
rom = (open("rom/prg/prg_0e.bin", "rb").read() +
       open("rom/prg/prg_0f.bin", "rb").read())
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
