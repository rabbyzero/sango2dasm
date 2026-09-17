#!/usr/bin/env python3
"""Regenerate memory/README.md index from the dumped memory files."""
import os
import re

MEM = "/home/zero/project/sango2dasm/memory"
OUT = os.path.join(MEM, "README.md")

HEADER = """# Memory Dump

Complete dump of all memory contents retrievable from the memory system,
organized by category into subdirectories. Each file preserves the full
original memory content plus metadata (category, memory ID, keywords).

Regenerated from the on-disk dump by tools/regen_memory_readme.py.

## Index
"""

def entry(category, fname):
    path = os.path.join(MEM, category, fname)
    title = None
    mid = None
    with open(path, encoding="utf-8") as f:
        for line in f:
            if line.startswith("# ") and title is None:
                title = line[2:].strip()
            m = re.match(r"- \*\*Memory ID:\*\* (.+)", line)
            if m and mid is None:
                mid = m.group(1).strip()
            if title is not None and mid is not None:
                break
    if title is None:
        title = fname[:-3]
    if mid is None:
        mid = "(ID not recorded)"
    link = f"{category}/{fname}"
    return f"- [{title}]({link}) — `{mid}`"

def main():
    cats = sorted(
        d for d in os.listdir(MEM)
        if os.path.isdir(os.path.join(MEM, d)) and not d.startswith(".")
    )
    lines = [HEADER]
    total = 0
    for cat in cats:
        files = sorted(f for f in os.listdir(os.path.join(MEM, cat)) if f.endswith(".md"))
        total += len(files)
        lines.append(f"\n### {cat} ({len(files)})\n")
        for f in files:
            lines.append(entry(cat, f))
    lines.append(f"\n## Totals\n\n- Categories: {len(cats)}\n- Memory files: {total}\n")
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Wrote {OUT}: {len(cats)} categories, {total} files")

if __name__ == "__main__":
    main()
