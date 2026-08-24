#!/usr/bin/env python3
"""Temp: byte-exact verification harness for prg_1f.asm.

The ROM mixes zero-page and absolute encodings for $00xx operands; each
source line carries the original ROM bytes in its trailing comment. This
harness reads those expected bytes, decides per instruction whether ca65
needs an a:-forced absolute operand, transforms a copy of the source
accordingly, assembles it standalone at $E000 and compares against
rom/prg/prg_1f.bin. Any remaining difference is genuine source drift.
"""
import re
import subprocess
import sys

CA65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

# Opcodes that have distinct zero-page forms (direct / ,X / ,Y).
ZP_OPCODES = {
    0xA5, 0x85, 0xB5, 0x95,            # LDA/STA zp[,X]
    0xA6, 0x86, 0xB6, 0x96,            # LDX/STX zp[,Y]
    0xA4, 0x84, 0xB4, 0x94,            # LDY/STY zp[,X]
    0xE6, 0xC6, 0xEE, 0xCE,            # INC/DEC
    0x06, 0x46, 0x26, 0x66,            # ASL/LSR/ROL/ROR
    0x0E, 0x4E, 0x2E, 0x6E,
    0xE5, 0xC5, 0x65, 0x25, 0x05, 0x45, 0x24,  # ADC/CMP/SBC/AND/ORA/EOR/BIT
    0xED, 0xCD, 0x6D, 0x2D, 0x0D, 0x4D, 0x2C,
}

rom = open("rom/prg/prg_1f.bin", "rb").read()
src = open("asm/banks/prg_1f.asm").read().splitlines()

line_pat = re.compile(r";\s*\$([0-9A-Fa-f]{4}):\s*([0-9A-Fa-f ]+?)\s*(?:;|$)")
lit_pat = re.compile(r"(?<![#(:a-zA-Z0-9_])\$00([0-9A-Fa-f]{2})(?![0-9A-Fa-f])")

# Collect zp-valued symbol names (equates with value <= $FF).
zp_names = set()
eq_pat = re.compile(r"^\s*([A-Za-z_]\w*)\s*=\s*\$([0-9A-Fa-f]{1,2})\s*(?:;.*)?$")
for line in src:
    m = eq_pat.match(line)
    if m:
        zp_names.add(m.group(1))
zp_sym = re.compile(
    r"(?<![(#:\w.])(" + "|".join(sorted(zp_names, key=len, reverse=True)) + r")(?!\w)")

# Pass 1: decide per source address whether the ROM instruction is absolute.
abs_addr = set()
zpg_addr = set()
for line in src:
    if ";" not in line:
        continue
    code, comment = line.split(";", 1)
    if not code.strip() or code.strip().startswith((".byte", ".word", ".addr")):
        continue
    m = line_pat.search(";" + comment)
    if not m:
        continue
    addr = int(m.group(1), 16)
    try:
        rom_bytes = [int(x, 16) for x in m.group(2).split()]
    except ValueError:
        continue
    if not rom_bytes:
        continue
    op = rom_bytes[0]
    if op in ZP_OPCODES:
        if len(rom_bytes) >= 3:
            abs_addr.add(addr)
        else:
            zpg_addr.add(addr)

print("instructions forced absolute: %d, kept zp: %d" % (len(abs_addr), len(zpg_addr)))

# Pass 2: transform the source copy.
out = []
for line in src:
    if ";" in line:
        code, comment = line.split(";", 1)
        comment = ";" + comment
    else:
        code, comment = line, ""
    stripped = code.strip()
    if stripped.startswith((".byte", ".word", ".addr", ".include", ".segment")):
        out.append(line)
        continue
    if "=" in code and stripped[:4] not in ("LDA ", "LDX ", "LDY "):
        out.append(line)  # symbol/equate definition
        continue
    m = line_pat.search(comment)
    addr = int(m.group(1), 16) if m else None
    if addr in abs_addr:
        new_code = lit_pat.sub(lambda mm: "a:$00" + mm.group(1), code)

        def sym_sub(sm):
            start = sm.start()
            if new_code.count("(", 0, start) > new_code.count(")", 0, start):
                return sm.group(0)
            if start > 0 and new_code[start - 1] in "#:(.":
                return sm.group(0)
            return "a:" + sm.group(0)

        new_code = zp_sym.sub(sym_sub, new_code)
        out.append(new_code + comment)
    else:
        out.append(line)

open("build/prg_1f_abs.asm", "w").write("\n".join(out) + "\n")
open("build/test_1f_abs.asm", "w").write(
    "BattleVBlankFrameUpdate_Entry = $A000\n"
    '.include "prg_1f_abs.asm"\n'
)

r = subprocess.run(
    [CA65, "-I", "include", "-I", "build", "build/test_1f_abs.asm",
     "-o", "build/test_1f_abs.o"],
    capture_output=True, text=True)
if r.returncode != 0:
    print(r.stdout)
    print(r.stderr)
    sys.exit(1)
r = subprocess.run(
    [LD65, "-C", "test_linker.cfg", "build/test_1f_abs.o",
     "-o", "build/test_1f_abs.bin"],
    capture_output=True, text=True)
if r.returncode != 0:
    print(r.stdout)
    print(r.stderr)
    sys.exit(1)

a = open("build/test_1f_abs.bin", "rb").read()
b = rom
diffs = [(i, a[i], b[i]) for i in range(min(len(a), len(b))) if a[i] != b[i]]
print("sizes: built=%d rom=%d, differing bytes: %d" % (len(a), len(b), len(diffs)))
for i, x, y in diffs[:80]:
    print("$%04X: built=%02X rom=%02X" % (0xE000 + i, x, y))
if not diffs:
    print("BYTE-EXACT MATCH")
