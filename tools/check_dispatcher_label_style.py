#!/usr/bin/env python3
"""Verify B1F_CallbackDispatcher inline-table target label styles in
prg_19_1a.asm.

Full style rule (ca65-aware):
  @-style    : target defined in the same proc AND same cheap-local group
               (no intervening global label between the .word reference and
               the definition).
  bare global: cross-proc/cross-file targets, or same-proc targets whose
               definition lies in a different cheap-local group (ca65 cannot
               resolve @-references across a global label boundary).
"""
import re

PATH = "asm/banks/prg_19_1a.asm"
lines = open(PATH).read().splitlines()

# --- proc ranges + group parents -------------------------------------------
# group parent of a line: nearest preceding global label inside the current
# .proc scope (<scope-start> if none yet).
proc_ranges, cur = [], None
for i, ln in enumerate(lines, 1):
    m = re.match(r"\.proc\s+(\S+)", ln)
    if m:
        cur = (i, m.group(1))
    elif ln.strip().startswith(".endproc") and cur:
        proc_ranges.append((cur[0], i, cur[1])); cur = None

def proc_of(n):
    for s, e, name in proc_ranges:
        if s <= n <= e:
            return name
    return None

group_of = {}          # line -> group parent string
gdefs = {}             # global name -> first def line
ldefs = {}             # (proc, @name) -> def line
procnames = set()      # .proc names (cross-proc dispatch targets)
for i, ln in enumerate(lines, 1):
    code = ln.partition(";")[0]
    if re.match(r"\s*\.proc\s+(\S+)", code):
        group_of[i] = "<scope-start>"
        procnames.add(re.match(r"\s*\.proc\s+(\S+)", code).group(1))
        continue
    m = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_]*):", code)
    if m:
        group_of[i] = m.group(1)
        gdefs.setdefault(m.group(1), i)
        continue
    m = re.match(r"^\s*@([A-Za-z0-9_]+):", code)
    if m:
        group_of[i] = group_of.get(i - 1, "<scope-start>")
        p = proc_of(i)
        if p:
            ldefs.setdefault((p, m.group(1)), i)
        continue
    group_of[i] = group_of.get(i - 1, "<scope-start>")

# walk group parents forward properly (labels set the parent for later lines)
parent = "<scope-start>"
for i, ln in enumerate(lines, 1):
    code = ln.partition(";")[0]
    if re.match(r"\s*\.proc\b", code):
        parent = "<scope-start>"
    m = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_]*):", code)
    if m:
        parent = m.group(1)
    group_of[i] = parent

def group_parent(line_no):
    return group_of.get(line_no, "<scope-start>")

# --- collect dispatcher tables ----------------------------------------------
problems = []
i = 0
while i < len(lines):
    i += 1
    if "JSR B1F_CallbackDispatcher" not in lines[i - 1]:
        continue
    proc = proc_of(i)
    j = i
    while j < len(lines):
        j += 1
        t = lines[j - 1]
        if t.strip().startswith(".word"):
            name = re.match(r"\.word\s+([@\w]+)", t.strip()).group(1)
            if name.startswith("@"):
                if (proc, name[1:]) not in ldefs:
                    problems.append((j, name, "@ target not defined in proc"))
                elif group_parent(j) != group_parent(ldefs[(proc, name[1:])]):
                    problems.append((j, name, "@ ref/def group mismatch"))
            else:
                dl = gdefs.get(name)
                if dl is None:
                    if name in procnames:
                        continue  # cross-proc .proc target: OK bare
                    problems.append((j, name, "undefined in file"))
                elif proc_of(dl) == proc:
                    if group_parent(j) == group_parent(dl):
                        problems.append((j, name,
                            f"same proc+group (def line {dl}) but non-@ style"))
                    # else: same proc, different group -> bare required, OK
                # else: cross-proc data/code label -> OK bare
        elif t.strip().startswith(";") or t.strip() == "":
            continue
        else:
            break

if problems:
    for ln_no, name, why in problems:
        print(f"line {ln_no}: {name}  [{why}]")
    print(f"{len(problems)} problem(s)")
    raise SystemExit(1)
print("all dispatcher target label styles consistent")
