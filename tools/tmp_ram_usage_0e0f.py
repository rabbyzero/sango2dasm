#!/usr/bin/env python3
"""Usage report for RAM addresses $0000-$07FF in prg_0e_0f.asm.

Groups operand references by address, showing procs, mnemonics and the
inline comments, to support semantic naming of parameters/globals.
Usage: python3 tools/tmp_ram_usage_0e0f.py > code/prg_0e_0f_ram_usage.txt
"""
import re
import sys
from collections import defaultdict

SRC = "asm/banks/prg_0e_0f.asm"
# operand position: not immediate (#), preceded by space/comma/( or 'a:'
OPER = re.compile(r'(?<![#\w$])\$0([0-7])([0-9A-Fa-f]{2})\b(?!\s*[,)])')
LINE = re.compile(r'^(\s*)(?:@?[\w.]+:)?\s*([A-Za-z]{3})\s+(.*?)(?:;.*)?$')
PROC = re.compile(r'^\.proc\s+(\w+)')
SUBR = re.compile(r'^(\s*)(@?[\w]+):')

usage = defaultdict(lambda: {"count": 0, "refs": []})
cur_proc = "(file-top)"
cur_lbl = ""

for lineno, raw in enumerate(open(SRC), 1):
    line = raw.rstrip("\n")
    m = PROC.match(line)
    if m:
        cur_proc = m.group(1)
        continue
    if line.startswith(".endproc"):
        cur_proc = "(file-top)"
        continue
    sm = re.match(r'^(\s*)(@?[\w]+):\s', line)
    if sm:
        cur_lbl = sm.group(2)
    for mm in OPER.finditer(line):
        addr = "$%s%s" % (mm.group(1), mm.group(2))
        # split code vs comment
        code, _, comment = line.partition(";")
        im = re.match(r'^\s*(?:@?[\w]+:)?\s*([A-Za-z]{3})\s+([^;]*)', code)
        mnem = im.group(1) if im else "?"
        oper = im.group(2).strip() if im else ""
        cm = comment.strip() if comment else ""
        u = usage[addr]
        u["count"] += 1
        u["refs"].append((lineno, cur_proc, cur_lbl, mnem, oper, cm))

for addr in sorted(usage, key=lambda a: int(a[1:], 16)):
    u = usage[addr]
    print("=" * 78)
    print("%s  (%d refs)" % (addr, u["count"]))
    byproc = defaultdict(int)
    mnems = defaultdict(int)
    for _, proc, _, mnem, _, _ in u["refs"]:
        byproc[proc] += 1
        mnems[mnem] += 1
    print("procs: " + ", ".join("%s(%d)" % kv for kv in
                                sorted(byproc.items(), key=lambda kv: -kv[1])))
    print("mnems: " + ", ".join("%s(%d)" % kv for kv in
                                sorted(mnems.items(), key=lambda kv: -kv[1])))
    # print first comment occurrence per (proc,comment) pair, max 12
    seen = set()
    shown = 0
    for lineno, proc, lbl, mnem, oper, cm in u["refs"]:
        if not cm:
            continue
        key = (cm,)
        if key in seen:
            continue
        seen.add(key)
        print("  %6d %-28s %-3s %-14s ; %s" % (lineno, proc, mnem, oper, cm))
        shown += 1
        if shown >= 14:
            print("  ...")
            break
