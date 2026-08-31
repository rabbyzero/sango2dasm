#!/usr/bin/env python3
"""Dump top-level proc label addresses for asm/banks/prg_0e_0f.asm.

Reuses the standalone verify_0e_0f.py harness (external refs stubbed,
.org-fixed segments) and asks ld65 for a VICE label file, then prints
every global label that matches a top-level .proc name, in address order.
"""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

src = open("asm/banks/prg_0e_0f.asm").read()
src = src.replace('.segment "CODE_BANK0E"',
                  '.segment "CODE_BANK0E"\n.org $A000', 1)
src = src.replace('.segment "CODE_BANK0F"',
                  '.segment "CODE_BANK0F"\n.org $C000', 1)

defined = set(re.findall(r"^(Loc_[0-9A-F]{4}):", src, re.M))

refs = set()
for m in re.finditer(r"(?:JSR|JMP)\s+\$([0-9A-F]{4})", src):
    refs.add(int(m.group(1), 16))
for m in re.finditer(r"(?:JSR|JMP)\s+a:\$([0-9A-F]{4})", src):
    refs.add(int(m.group(1), 16))

external = sorted(a for a in refs
                  if 0xA000 <= a < 0xE000 and "Loc_{:04X}".format(a) not in defined)
stubs = "".join("ext_{:04X} = ${:04X}\n".format(a, a) for a in external)
for a in external:
    src = re.sub(r"(JSR|JMP)(\s+)a:\${:04X}\b".format(a),
                 r"\1\2ext_{:04X}".format(a), src)
    src = re.sub(r"(JSR|JMP)(\s+)\${:04X}\b".format(a),
                 r"\1\2ext_{:04X}".format(a), src)

external_ram = [
    "menu_cursor_col = $0424\n",
    "menu_cursor_page = $0425\n",
    "war_scene_id = $0500\n",
    "war_scene_phase = $0501\n",
]
proc_names = set(re.findall(r"^\.proc (\w+)", src, re.M))
entry_names = set(re.findall(r"^(\w+_Entry):", src, re.M))
wanted = proc_names | entry_names
exports = ".export " + ", ".join(sorted(wanted)) + "\n"
open("build/_region.asm", "w").write(src + "\n" + stubs + "\n" +
                                     "".join(external_ram) + exports)

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
r = subprocess.run([LD65, "-C", "build/_region.cfg", "build/_region.o",
                    "-o", "build/_region.out",
                    "-Ln", "build/_labels_0e0f.txt"],
                   capture_output=True, text=True)
if r.returncode != 0:
    print("LD65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)

proc_names = set(re.findall(r"^\.proc (\w+)", src, re.M))
entry_names = set(re.findall(r"^(\w+_Entry):", src, re.M))
wanted = proc_names | entry_names

labels = {}
for line in open("build/_labels_0e0f.txt"):
    # VICE format: "al 00A16E .Phase1CycleInit"
    m = re.match(r"al ([0-9A-F]+) \.(\w+)\s*$", line)
    if m and m.group(2) in wanted:
        labels[m.group(2)] = int(m.group(1), 16)

missing = sorted(wanted - set(labels))
for name in sorted(labels, key=lambda n: labels[n]):
    print("${:04X}  {}".format(labels[name], name))
print("total:", len(labels))
if missing:
    print("MISSING:", missing)
