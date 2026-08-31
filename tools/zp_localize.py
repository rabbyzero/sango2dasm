#!/usr/bin/env python3
"""Apply per-proc local zero-page name designs to prg_0e_0f.asm.

Driven by a JSON manifest (produced by hand, one entry per proc):
  [{"proc": "Name",
    "locals": [["name", "$00XX", "comment"], ...],
    "cells":  {"zp_arg0": "local_name", ...},          # default per token
    "lines":  {"$A1C2": {"zp_arg0": "side_id"}, ...}}  # per-line overrides
   ...]

For each entry the script:
  1. locates the .proc body (nesting-aware),
  2. aborts if any target name would collide with an existing label/equate,
  3. rewrites the zp_* tokens inside that proc only (default map, with
     per-line overrides keyed by the line's ROM-address comment),
  4. inserts the local equate block right after the .proc line.
"""
import json
import re
import sys

SRC = "asm/banks/prg_0e_0f.asm"
ROMC = re.compile(r"; (\$[0-9A-F]{4}):")
TOKEN = re.compile(r"\b(zp_[a-z0-9_]+)\b")


def proc_range(lines, name):
    start = None
    for i, l in enumerate(lines):
        if l.strip() == ".proc %s" % name:
            start = i
            break
    if start is None:
        raise SystemExit("proc not found: %s" % name)
    depth = 0
    for i in range(start, len(lines)):
        if lines[i].startswith(".proc "):
            depth += 1
        elif lines[i].strip() == ".endproc":
            depth -= 1
            if depth == 0:
                return start, i
    raise SystemExit("proc not terminated: %s" % name)


def main():
    manifest = json.load(open(sys.argv[1]))
    overrides_only = "--overrides-only" in sys.argv
    lines = open(SRC).read().splitlines()
    for entry in manifest:
        name = entry["proc"]
        s, e = proc_range(lines, name)
        body = lines[s:e + 1]

        # per-line overrides (keyed by ROM address in the comment).
        # In overrides-only mode the zp_* tokens are already replaced by the
        # default names, so map those to the override names as well.
        ident = TOKEN if not overrides_only else re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\b")
        line_map = {}
        for rom, m in entry.get("lines", {}).items():
            om = dict(m)
            if overrides_only:
                for tok, nn in m.items():
                    d = entry.get("cells", {}).get(tok)
                    if d:
                        om[d] = nn
            line_map[rom.lstrip("$")] = om
        for i in range(1, len(body)):
            m = ROMC.search(body[i])
            if m and m.group(1)[1:] in line_map:
                om = line_map[m.group(1)[1:]]
                body[i] = ident.sub(lambda t: om.get(t.group(1), t.group(1)), body[i])
        if overrides_only:
            lines[s:e + 1] = body
            print("overrides:", name)
            continue

        # collision check: names must not already exist as labels/equates
        declared = set(re.findall(r"^\s*([A-Za-z_][A-Za-z0-9_]*):", "\n".join(body), re.M))
        declared |= set(re.findall(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=", "\n".join(body), re.M))
        want = set(entry["cells"].values())
        for ov in entry.get("lines", {}).values():
            want |= set(ov.values())
        clash = want & declared
        if clash:
            raise SystemExit("%s: name clash %s" % (name, sorted(clash)))

        # default cell map for the remaining lines
        cmap = entry["cells"]
        for i in range(1, len(body)):
            m = ROMC.search(body[i])
            if m and m.group(1)[1:] in line_map:
                continue
            body[i] = TOKEN.sub(lambda t: cmap.get(t.group(1), t.group(1)), body[i])
        # raw $00XX operands (never touched in comments)
        for hexs, rn in entry.get("raw", {}).items():
            pat = re.compile(r"(?<![\w$])" + re.escape(hexs) + r"\b")
            for i in range(1, len(body)):
                code = body[i].partition(";")[0]
                if pat.search(code):
                    body[i] = pat.sub(rn, body[i], count=1)

        # local equate block
        block = ["; zero-page work cells (proc-local):"]
        for n, addr, c in entry["locals"]:
            block.append("%-14s = %s  ; %s" % (n, addr, c))
        body = [body[0]] + block + body[1:]
        lines[s:e + 1] = body
        print("done:", name)
    open(SRC, "w").write("\n".join(lines) + "\n")


main()
