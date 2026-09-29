#!/usr/bin/env python3
"""Scan a bank asm file for bare (non-@) labels eligible for @-local conversion.

A label qualifies when:
  - it is defined at column 0 (or indented) as `Name:` without the @ prefix,
  - it is NOT a .proc name itself,
  - its definition and EVERY reference to it (repo-wide, in asm/ and include/)
    fall inside the same single .proc/.endproc range,
  - it is not referenced from C-style headers outside the asm tree.

Reports candidates grouped by defining proc so conversion can preserve
ca65 cheap-local group semantics (nearest-preceding-global scoping).
"""
import re, sys, glob

TARGET = sys.argv[1] if len(sys.argv) > 1 else "asm/banks/prg_19_1a.asm"

lines = open(TARGET).read().splitlines()

# --- .proc ranges ---
proc_ranges, cur = [], None
for i, ln in enumerate(lines, 1):
    m = re.match(r"\.proc\s+(\S+)", ln)
    if m:
        cur = (i, m.group(1))
    elif re.match(r"\.endproc\b", ln.strip()) and cur:
        proc_ranges.append((cur[0], i, cur[1])); cur = None

def proc_of(n):
    for s, e, name in proc_ranges:
        if s <= n <= e:
            return name
    return None

# --- collect bare label definitions ---
# column-0 or any-start `Name:` that is not @-prefixed, not a ca65 directive
label_def = {}          # name -> line number (first definition)
label_def_lines = {}    # name -> [line numbers]
for i, ln in enumerate(lines, 1):
    if ln.startswith("."):
        continue
    m = re.match(r"([A-Za-z_]\w*):", ln)
    if m:
        name = m.group(1)
        label_def.setdefault(name, i)
        label_def_lines.setdefault(name, []).append(i)

# .proc names are never conversion candidates
proc_names = {n for _, _, n in proc_ranges}
# also treat top-level bare subroutine labels that ARE proc entry points:
# names that appear as `.proc Name` are excluded above.

# --- strip comments for reference scanning ---
def strip_comment(ln):
    in_str = False
    for j, ch in enumerate(ln):
        if ch == '"':
            in_str = not in_str
        elif ch == ';' and not in_str:
            return ln[:j]
    return ln

code_lines = [(i, strip_comment(ln)) for i, ln in enumerate(lines, 1)]

# --- repo-wide references in other files (asm tree + include) ---
other_files = sorted(set(glob.glob("asm/**/*.asm", recursive=True)
                         + glob.glob("include/*")) - {TARGET})
other_refs = {name: [] for name in label_def}
for f in other_files:
    ftext = open(f).read().splitlines()
    for i, ln in enumerate(ftext, 1):
        for name in list(label_def):
            if re.search(r"(?<![\w@])" + re.escape(name) + r"(?![\w@])", ln):
                other_refs[name].append((f, i, ln.strip()))

# --- references inside TARGET ---
print("Convertible candidates (all refs inside defining proc, no external refs):\n")
n_ok = n_block_ext = n_block_out = 0
for name, defline in sorted(label_def.items(), key=lambda kv: kv[1]):
    if name in proc_names:
        continue
    def_proc = proc_of(defline)
    if def_proc is None:
        continue  # top-level label outside any proc
    # multiple column-0 definitions of same name = redefinition, skip
    if len(label_def_lines[name]) > 1:
        print(f"  SKIP {name}: multiple column-0 definitions "
              f"{label_def_lines[name]}")
        continue
    ext = other_refs[name]
    outside = []
    inside = 0
    for i, ln in code_lines:
        if re.search(r"(?<![\w@])" + re.escape(name) + r"(?![\w@])", ln):
            p = proc_of(i)
            if p == def_proc and i != defline:
                inside += 1
            elif i != defline:
                outside.append((i, p, ln.strip()))
    if ext:
        n_block_ext += 1
        print(f"  BLOCKED (external) {name} @L{defline} in {def_proc}:")
        for f, i, txt in ext[:6]:
            print(f"      {f}:{i} {txt[:90]}")
    elif outside:
        n_block_out += 1
        print(f"  BLOCKED (cross-proc in-file) {name} @L{defline} in {def_proc}:")
        for i, p, txt in outside[:6]:
            print(f"      L{i} [{p}] {txt[:90]}")
    elif inside == 0:
        print(f"  UNUSED? {name} @L{defline} in {def_proc} — no refs found")
    else:
        n_ok += 1
        print(f"  OK {name} @L{defline} in {def_proc} ({inside} in-proc refs)")

print(f"\nsummary: {n_ok} convertible, {n_block_ext} blocked-external, "
      f"{n_block_out} blocked-cross-proc")
