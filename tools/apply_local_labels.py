#!/usr/bin/env python3
"""Incrementally convert qualifying bare labels to @-local style, one at a
time, using the byte-exact bank verifier as the ground-truth oracle.

For each label that passes the "definition + all repo-wide refs inside a
single .proc" screen, the driver:
  1. prefixes the label (definition + in-file code references) with @,
  2. runs tools/verify_19_1a.py (ca65 assemble + 16384-byte compare),
  3. keeps the edit only on "0 mismatches", otherwise reverts.

This respects ca65 cheap-local group-parent semantics: labels whose @-form
would break a cross-group .word reference (e.g. an intervening externally-
referenced global) simply fail to assemble and are auto-reverted.

Usage: apply_local_labels.py [TARGET]
"""
import re, sys, glob, subprocess

TARGET = sys.argv[1] if len(sys.argv) > 1 else "asm/banks/prg_19_1a.asm"
VERIFY = "tools/verify_19_1a.py"

orig_text = open(TARGET).read()
lines = orig_text.splitlines()

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

def strip_comment(ln):
    in_str = False
    for j, ch in enumerate(ln):
        if ch == '"':
            in_str = not in_str
        elif ch == ';' and not in_str:
            return ln[:j]
    return ln

label_def, label_def_multi = {}, set()
for i, ln in enumerate(lines, 1):
    if ln.startswith("."):
        continue
    m = re.match(r"([A-Za-z_]\w*):", ln)
    if m:
        n = m.group(1)
        if n in label_def:
            label_def_multi.add(n)
        else:
            label_def[n] = i

proc_names = {n for _, _, n in proc_ranges}

other_files = sorted(set(glob.glob("asm/**/*.asm", recursive=True)
                         + glob.glob("include/*")) - {TARGET})
other_refs = {n: 0 for n in label_def}
for f in other_files:
    for ln in open(f).read().splitlines():
        for n in other_refs:
            if re.search(r"(?<![\w@])" + re.escape(n) + r"(?![\w@])", ln):
                other_refs[n] += 1

code_lines = [(i, strip_comment(ln)) for i, ln in enumerate(lines, 1)]

candidates = []
for name, defline in sorted(label_def.items(), key=lambda kv: kv[1]):
    if name in proc_names or name in label_def_multi:
        continue
    dp = proc_of(defline)
    if dp is None or other_refs[name]:
        continue
    ok = True
    for i, ln in code_lines:
        if i != defline and re.search(r"(?<![\w@])" + re.escape(name) + r"(?![\w@])", ln):
            if proc_of(i) != dp:
                ok = False; break
    if ok:
        candidates.append((name, dp))

def verify():
    r = subprocess.run([sys.executable, VERIFY], capture_output=True, text=True)
    return r.returncode == 0 and "0 mismatches" in (r.stdout + r.stderr), (r.stdout + r.stderr)

kept, skipped = [], []
text = orig_text
for name, dp in candidates:
    prev = text
    pat = re.compile(r"(?<![\w@])(" + re.escape(name) + r")(?![\w@])")
    new_lines = []
    changed = False
    for ln in text.splitlines():
        if pat.search(strip_comment(ln)):
            ln = pat.sub(r"@\1", ln); changed = True
        new_lines.append(ln)
    if not changed:
        continue
    text = "\n".join(new_lines) + "\n"
    open(TARGET, "w").write(text)
    good, out = verify()
    if good:
        kept.append((name, dp))
        print(f"  KEEP  @{name:<40} ({dp})")
    else:
        text = prev
        open(TARGET, "w").write(text)
        reason = "assemble-error" if "Error" in out else "byte-mismatch"
        skipped.append((name, dp, reason))
        print(f"  SKIP  {name:<41} ({dp}) -> {reason}")

# final safety: ensure file matches a 0-mismatch state
open(TARGET, "w").write(text)
good, out = verify()
print(f"\nkept {len(kept)}, skipped {len(skipped)}")
print("final verify:", "OK 0 mismatches" if good else "FAILED\n" + out)
if skipped:
    print("\nskipped (must stay bare):")
    for n, p, r in skipped:
        print(f"  {n} ({p}) {r}")
