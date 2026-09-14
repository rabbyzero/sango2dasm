#!/usr/bin/env python3
"""Scan asm/banks/*.asm for LDY #$xx / JSR SwitchBankAC_A|B|BankedCallbackTrampoline
patterns, resolve the effective target bank (Y & $1F), and report call sites that
target banks which are NOT yet disassembled (still stubs)."""
import re, os, glob
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANKS = os.path.join(ROOT, "asm", "banks")

# Disassembled (combined) bank pairs present as real asm files
DISASSEMBLED = {0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
                0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F}

TARGET_RE = re.compile(r"^\s*JSR\s+(SwitchBankAC_A|SwitchBankAC_B|SwitchBank8_A|SwitchBank8_B|B1F_BankedCallbackTrampoline)\b", re.I)
LDY_RE = re.compile(r"^\s*LDY\s+#\$([0-9A-F]{2})\b", re.I)
WORD_RE = re.compile(r"^\s*\.word\s+\$([0-9A-F]{4})", re.I)

results = []  # (file, line_no, yval, bank, jsr_name, target_addr, window, proc)

PROC_RE = re.compile(r"^\s*\.proc\s+(\w+)", re.I)
YWRITE_RE = re.compile(r"^\s*(LDY\s+(?!#)|TAY|PLY)\b", re.I)

for path in sorted(glob.glob(os.path.join(BANKS, "prg_*.asm"))):
    fname = os.path.basename(path)
    if fname.endswith((".bak", ".new")):
        continue
    with open(path, encoding="utf-8", errors="replace") as f:
        lines = f.readlines()
    proc = None
    for i, line in enumerate(lines):
        mp = PROC_RE.match(line)
        if mp:
            proc = mp.group(1)
            continue
        m = TARGET_RE.match(line)
        if not m:
            continue
        jsr = m.group(1)
        # scan backwards up to 8 lines for LDY #$xx
        yval = None
        for j in range(i - 1, max(-1, i - 9), -1):
            my = LDY_RE.match(lines[j])
            if my:
                yval = int(my.group(1), 16)
                break
            # stop at a non-immediate write to Y (dynamic bank param) or another JSR/JMP
            if re.match(r"^\s*(JSR|JMP|@?\w+:)", lines[j]):
                break
            if YWRITE_RE.match(lines[j]):
                break
        if yval is None:
            continue
        bank = yval & 0x1F
        window = "$8000" if "SwitchBank8" in jsr else "$A000/$C000"
        target_addr = None
        if "Trampoline" in jsr and i + 1 < len(lines):
            mw = WORD_RE.match(lines[i + 1])
            if mw:
                target_addr = "$" + mw.group(1)
        results.append((fname, i + 1, yval, bank, jsr, target_addr, window, proc))

undis = defaultdict(list)
allbanks = defaultdict(int)
for fname, line, yval, bank, jsr, tgt, window, proc in results:
    allbanks[bank] += 1
    if bank not in DISASSEMBLED:
        undis[bank].append((fname, line, yval, jsr, tgt, window, proc))

print(f"Total bank-switch call sites: {len(results)}")
print("\n=== Target bank distribution (Y & $1F) ===")
for bank in sorted(allbanks):
    mark = "" if bank in DISASSEMBLED else "   <-- UN-DISASSEMBLED"
    print(f"  ${bank:02X}: {allbanks[bank]:4d} sites{mark}")
print("\n=== Call sites targeting UN-DISASSEMBLED banks ===")
for bank in sorted(undis):
    print(f"\nBank ${bank:02X}  ({len(undis[bank])} call sites)")
    for fname, line, yval, jsr, tgt, window, proc in undis[bank]:
        t = f" -> {tgt}" if tgt else ""
        p = f"  [{proc}]" if proc else ""
        print(f"  {fname}:{line}{p}  LDY #${yval:02X}  JSR {jsr}  [{window}]{t}")
print("\n=== Summary ===")
for bank in sorted(undis):
    files = sorted(set(f for f, *_ in undis[bank]))
    print(f"${bank:02X}: {len(undis[bank])} sites in {', '.join(files)}")
