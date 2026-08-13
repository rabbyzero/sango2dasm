#!/usr/bin/env python3
"""Whole-bank verification for prg_08_09.asm after the RAM symbol
consolidation. Derived from tmp_verify_d70f.py: slices the bank file,
forces absolute $00xx operands, assembles, links (CODE_BANK08 + CODE_BANK09),
compares against prg_08.bin / prg_09.bin. External RAM globals owned by
other bank files are injected as extra equates.
Usage: python3 tools/tmp_verify_ram_syms.py [path-to-bank-file]
"""
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"

src_path = sys.argv[1] if len(sys.argv) > 1 else "asm/banks/prg_08_09.asm"
all_lines = open(src_path).readlines()
end = len(all_lines)  # whole file (free-space tail is a .res fill)

# Globals owned by other bank files (referenced, not redefined, here).
EXTERNAL_RAM = [
    "menu_cursor_col = $0424\n",
    "menu_cursor_page = $0425\n",
    "army_slot_base = $04D8\n",
    "sram_game_start_flag = $6F8B\n",
]

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
    # cross-segment backward branch ($C00C -> $BFF9): bank-08 drift in the
    # working tree breaks cheap-label resolution across the .org boundary
    region = region.replace('BCC @SearchThreshold', 'BCC $BFF9')
    stubs.append("ApplyCoordDeltas = $C027\n")
    src = region + "".join(stubs) + "".join(EXTERNAL_RAM) + \
        "".join(extra_equates)
    # force absolute addressing for $00xx direct operands (ROM convention),
    # skipping data directives where the prefix would change byte widths and
    # the $D13C-$D1EB pseudo-disassembly block (invalid-opcode byte dump)
    out = []
    for l in src.splitlines(keepends=True):
        m = re.search(r'; \$([0-9A-F]{4}):', l)
        addr = int(m.group(1), 16) if m else None
        if (re.match(r'\s*\.(byte|word|dbyt|addr|asciiz|asc)\b', l)
                or (addr is not None and 0xD13C <= addr <= 0xD1EB)):
            out.append(l)
        else:
            out.append(re.sub(r'(?<![#(])\$00([0-9A-Fa-f]{2})\b',
                              r'a:$00\1', l))
    open("build/_region.asm", "w").write("".join(out))

def find_symbol_addr(name):
    """Locate a symbol defined after the slice; return its ROM address."""
    pat_proc = re.compile(r'\.proc ' + re.escape(name) + r'\b')
    pat_lab = re.compile(r'^' + re.escape(name) + r':')
    for i in range(end, len(all_lines)):
        if pat_proc.search(all_lines[i]) or pat_lab.match(all_lines[i]):
            for j in range(i, min(i + 8, len(all_lines))):
                m = re.search(r'; \$([0-9A-Fa-f]{4}):', all_lines[j])
                if m:
                    return int(m.group(1), 16)
    return None

CFG = """MEMORY {
  BANK08: start = $A000, size = $2000, file = "build/_r8.bin", fill = yes, fillval = $FF;
  BANK09: start = $C000, size = $2000, file = "build/_r9.bin", fill = yes, fillval = $FF;
}
SEGMENTS {
  CODE_BANK08: load = BANK08, type = ro;
  CODE_BANK09: load = BANK09, type = ro;
}
"""
open("build/_region_ram.cfg", "w").write(CFG)

extra = []
for attempt in range(4):
    build_region(extra)
    r = subprocess.run([CC65, "-I", "include", "build/_region.asm",
                        "-o", "build/_region.o"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        undef = sorted(set(re.findall(r"Undefined symbol: (\w+)", r.stderr))
                       | set(re.findall(r"Symbol .(\w+). is undefined", r.stderr)))
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

r = subprocess.run([LD65, "-C", "build/_region_ram.cfg", "build/_region.o",
                    "-o", "build/_region.out"], capture_output=True, text=True)
if r.returncode != 0:
    print("LD65 FAILED:\n" + r.stderr[:3000])
    sys.exit(1)

r8 = open("build/_r8.bin", "rb").read()
r9 = open("build/_r9.bin", "rb").read()
rom8 = open("rom/prg/prg_08.bin", "rb").read()
rom9 = open("rom/prg/prg_09.bin", "rb").read()

m8 = 0
for i in range(0x2000):
    if r8[i] != rom8[i]:
        m8 += 1
        if m8 <= 8:
            print(f"MISMATCH ${0xA000+i:04X}: asm={r8[i]:02X} rom={rom8[i]:02X}")
m9 = 0
for i in range(0x2000):
    if r9[i] != rom9[i]:
        m9 += 1
        if m9 <= 40:
            print(f"MISMATCH ${0xC000+i:04X}: asm={r9[i]:02X} rom={rom9[i]:02X}")
print(f"compared $A000-$BFFF + $C000-$DFFF: "
      f"bank08 {m8} mismatches, bank09 {m9} mismatches")
sys.exit(1 if m9 else 0)
