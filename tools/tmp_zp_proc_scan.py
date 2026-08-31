#!/usr/bin/env python3
"""List every line in prg_0e_0f.asm referencing the zero-page call-register
cells (zp_* symbols or raw $00xx-$001F operands), grouped by innermost proc
(nested .proc aware). Output: per proc, the scope chain, then each reference
line with line number, so local names can be designed per function.
"""
import re
import sys

SRC = "asm/banks/prg_0e_0f.asm"
ZP = re.compile(r"\bzp_[a-z0-9_]+\b")
RAW = re.compile(r"(?<![#\w$+])(a:)?\$00[0-9A-Fa-f]{2}\b")
PROC = re.compile(r"^\.proc\s+(\w+)")

stack = []
groups = {}   # proc key -> list of (lineno, line)
order = []

for lineno, raw in enumerate(open(SRC), 1):
    line = raw.rstrip("\n")
    m = PROC.match(line)
    if m:
        stack.append(m.group(1))
        continue
    if line.strip() == ".endproc":
        if stack:
            stack.pop()
        continue
    code = line.partition(";")[0]
    hits = ZP.findall(code) or RAW.findall(code)
    if not hits:
        continue
    key = "/".join(stack) if stack else "(file-top)"
    if key not in groups:
        groups[key] = []
        order.append(key)
    groups[key].append((lineno, line))

for key in order:
    refs = groups[key]
    print("=" * 90)
    print("PROC %s   (%d refs)" % (key, len(refs)))
    for lineno, line in refs:
        print("  %5d  %s" % (lineno, line.strip()))
