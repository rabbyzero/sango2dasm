#!/usr/bin/env python3
"""Repair the B17_18_* alias block in include/functions.h.

For every `B17_18_<name> = $ADDR` line, recompute the expected new name from
HEAD's alias (by address) run through the rename mapping; rewrite the line
only when it differs, preserving original spacing.
"""
import re
import subprocess

MAPPING = []
for line in open("/home/zero/project/sango2dasm/tools/rename_duel_procs.py"):
    s = line.strip()
    if s.startswith('"') and ":" in s:
        old, new = s.strip('",').split(":")
        MAPPING.append((old, new))
MAPPING.sort(key=lambda p: -len(p[0]))

def map_name(old_base):
    for old_key, new in MAPPING:
        if old_base == old_key:
            return new
        if old_base.startswith(old_key):
            return new + old_base[len(old_key):]
    return old_base

head = subprocess.run(
    ["git", "-C", "/home/zero/project/sango2dasm", "show", "HEAD:include/functions.h"],
    capture_output=True, text=True, check=True).stdout
addr_to_expected = {}
for m in re.finditer(r"^(B17_18_[A-Za-z0-9_]+) = (\$[0-9A-Fa-f]+)", head, re.M):
    addr_to_expected[m.group(2)] = "B17_18_" + map_name(m.group(1)[len("B17_18_"):])

path = "/home/zero/project/sango2dasm/include/functions.h"
out = []
fixed, unknown_addr = 0, []
for line in open(path):
    m = re.match(r"^(B17_18_[A-Za-z0-9_]+)(\s*=\s*)(\$[0-9A-Fa-f]+)(.*)$", line)
    if m:
        alias, sep, addr, tail = m.groups()
        expected = addr_to_expected.get(addr)
        if expected is None:
            unknown_addr.append(line.rstrip())
            out.append(line)
            continue
        if alias != expected:
            out.append(f"{expected}{sep}{addr}{tail}\n")
            fixed += 1
            continue
    out.append(line)

open(path, "w").writelines(out)
print(f"fixed lines: {fixed}; addresses not in HEAD (left untouched): {len(unknown_addr)}")
for u in unknown_addr:
    print("  ?", u.strip())
