#!/usr/bin/env python3
"""Region verification for $A000-$D38F of prg_08_09.asm (through
DrawStratagemTargetMarkers). Slices the bank file through the routine,
forces absolute $00xx operands, assembles, links (both CODE_BANK08 and
CODE_BANK09 segments), compares against prg_08.bin / prg_09.bin."""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"
END_MARKS = ["; ValidateSpecialOfficer -", "Loc_D390:"]

# default: working tree; pass 'HEAD' (or any git rev) to slice the original
if len(sys.argv) > 1:
    all_lines = subprocess.run(
        ['git', 'show', f'{sys.argv[1]}:asm/banks/prg_08_09.asm'],
        capture_output=True, text=True).stdout.splitlines(keepends=True)
else:
    all_lines = open("asm/banks/prg_08_09.asm").readlines()
end = None
for mark in END_MARKS:
    for i, l in enumerate(all_lines):
        if l.startswith(mark):
            end = i
            break
    if end is not None:
        break
assert end is not None, 'end marker not found'
# back up over the banner/comment block preceding the next routine
while end > 0 and all_lines[end - 1].startswith(';'):
    end -= 1

def build_region(extra_equates):
    region = "".join(all_lines[8:end])
    region = region.replace('.segment "CODE_BANK08"',
                            '.segment "CODE_BANK08"\n.org $A000', 1)
    region = region.replace('.segment "CODE_BANK09"',
                            '.segment "CODE_BANK09"\n.org $C000', 1)
    # stubs: only symbols defined later in the bank (drop ones slice defines)
    defined = set(re.findall(r'\.proc (\w+)', region))
    defined |= set(re.findall(r'^(\w+):', region, re.M))
    stubs = []
    for l in open("build/_stubs.asm").readlines():
        m = re.match(r'(\w+) = ', l)
        if m and m.group(1) in defined:
            continue
        stubs.append(l)
    # Slice truncation breaks ca65 cheap-label zone resolution for four
    # @-references that DO resolve in full-file builds. Substitute the
    # operands with their absolute ROM addresses (harness copy only).
    region = region.replace('JSR @ComputeAverageStats', 'JSR $CCAA')
    region = region.replace('JSR @PushY', 'JSR $BFB3')
    region = region.replace('BCC @PopCount', 'BCC $BEED')
    region = region.replace('BEQ @SwapFound', 'BEQ $BC30')
    stubs.append("ApplyCoordDeltas = $C027\n")
    # routines after the slice (addresses stable in ROM)
    stubs.append("ValidateSpecialOfficer = $D390\n")
    stubs.append("BuildCommandList = $D3EE\n")
    src = region + "".join(stubs) + "".join(extra_equates)
    # force absolute addressing for $00xx direct operands (ROM convention),
    # skipping data directives where the prefix would change byte widths and
    # the $D13C-$D1EB pseudo-disassembly block (invalid-opcode byte dump)
    out = []
    for l in src.splitlines(keepends=True):
        m = re.search(r'; \$([0-9A-F]{4}):', l)
        addr = int(m.group(1), 16) if m else None
        if (re.match(r'\s*\.(byte|word|dbyt|addr|asciiz|asc)\b', l)
                or (addr is not None and 0xD13C <= addr <= 0xD1EC)):
            out.append(l)
        else:
            out.append(re.sub(r'(?<![#(])\$00([0-9A-Fa-f]{2})\b',
                              r'a:$00\1', l))
    open("build/_d1ed_region.asm", "w").write("".join(out))

def find_symbol_addr(name):
    """Locate a symbol defined after the slice; return its ROM address."""
    pat_proc = re.compile(r'\.proc ' + re.escape(name) + r'\b')
    pat_lab = re.compile(r'^' + re.escape(name) + r':')
    for i in range(end, len(all_lines)):
        if pat_proc.search(all_lines[i]) or pat_lab.match(all_lines[i]):
            for j in range(i, min(i + 6, len(all_lines))):
                m = re.search(r'; \$([0-9A-Fa-F]{4}):', all_lines[j])
                if m:
                    return int(m.group(1), 16)
    return None

CFG = """MEMORY {
  BANK08: start = $A000, size = $2000, file = "build/_d1ed_r8.bin", fill = yes, fillval = $FF;
  BANK09: start = $C000, size = $2000, file = "build/_d1ed_r9.bin", fill = yes, fillval = $FF;
}
SEGMENTS {
  CODE_BANK08: load = BANK08, type = ro;
  CODE_BANK09: load = BANK09, type = ro;
}
"""
open("build/_d1ed_link.cfg", "w").write(CFG)

extra = []
for attempt in range(4):
    build_region(extra)
    r = subprocess.run([CC65, "-I", "include", "build/_d1ed_region.asm",
                        "-o", "build/_d1ed_region.o"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        undef = sorted(set(re.findall(r"Undefined symbol: (\w+)", r.stderr)))
        added = False
        for name in undef:
            addr = find_symbol_addr(name)
            if addr is not None:
                extra.append(f"{name} = ${addr:04X}\n")
                added = True
        if added:
            continue
        print("CA65 FAILED:\n" + r.stderr[:3000])
        sys.exit(1)
    break
else:
    print("CA65 FAILED after stub iterations")
    sys.exit(1)

r = subprocess.run([LD65, "-C", "build/_d1ed_link.cfg", "build/_d1ed_region.o",
                    "-o", "build/_d1ed_region.out"], capture_output=True, text=True)
if r.returncode != 0:
    print("LD65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)
r8 = open("build/_d1ed_r8.bin", "rb").read()
r9 = open("build/_d1ed_r9.bin", "rb").read()
rom8 = open("rom/prg/prg_08.bin", "rb").read()
rom9 = open("rom/prg/prg_09.bin", "rb").read()

mismatch = 0
for i in range(0x2000):
    if r8[i] != rom8[i]:
        mismatch += 1
        if mismatch <= 30:
            print(f"MISMATCH ${0xA000+i:04X}: asm={r8[i]:02X} rom={rom8[i]:02X}")
n9 = 0xD390 - 0xC000
for i in range(n9):
    if r9[i] != rom9[i]:
        mismatch += 1
        if mismatch <= 30:
            print(f"MISMATCH ${0xC000+i:04X}: asm={r9[i]:02X} rom={rom9[i]:02X}")
total = 0x2000 + n9
print(f"compared {total} bytes ($A000-$BFFF, $C000-$D38F), {mismatch} mismatches")
sys.exit(1 if mismatch else 0)
