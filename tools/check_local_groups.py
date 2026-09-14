#!/usr/bin/env python3
"""Verify ca65 cheap-local (@) reference/definition group consistency.

ca65 resolves @name against the definition whose group parent (nearest
preceding global symbol within the enclosing scope; .proc opens a new
scope) matches the reference's group parent. Two passes: defs first,
then refs.
"""
import re, sys

PATH = "asm/banks/prg_19_1a.asm" if len(sys.argv) < 2 else sys.argv[1]
lines = open(PATH).read().splitlines()

def scan(record_defs=False, check_refs=False, groups=None, errors=None):
    cur_global = "<scope-start>"
    for i, ln in enumerate(lines, 1):
        code = ln.partition(";")[0]
        if re.match(r"\s*\.proc\b", code):
            cur_global = "<scope-start>"
            continue
        m = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_]*):", code)
        if m:
            cur_global = m.group(1)
            continue
        m = re.match(r"^\s*@([A-Za-z0-9_]+):", code)
        if m:
            if record_defs:
                key = (cur_global, m.group(1))
                if key in groups:
                    errors.append(f"line {i}: DUP def @{m.group(1)} (group {cur_global}, first at {groups[key]})")
                groups[key] = i
            continue
        if check_refs:
            for m in re.finditer(r"(?<![\w@])@([A-Za-z0-9_]+)", code):
                name = m.group(1)
                if (cur_global, name) not in groups:
                    errors.append(f"line {i}: ref @{name} UNDEFINED in group '{cur_global}'")

groups, errors = {}, []
scan(record_defs=True, groups=groups, errors=errors)
scan(check_refs=True, groups=groups, errors=errors)

if errors:
    print("\n".join(errors))
    print(f"\n{len(errors)} group error(s)")
    sys.exit(1)
print("all @ references/definitions group-consistent")
