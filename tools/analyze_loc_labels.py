#!/usr/bin/env python3
"""Analyze Loc_ labels in prg_1d_1e.asm, group by proc, show context."""
import re
from collections import defaultdict

FILE = '/home/zero/project/sango2dasm/asm/banks/prg_1d_1e.asm'

with open(FILE) as f:
    lines = f.readlines()

# Parse procs and Loc_ labels
procs = []  # list of (name, start_line, end_line)
current_proc = None
current_proc_start = None

loc_labels = defaultdict(list)  # label -> list of (line_num, is_definition, line_text)

for i, line in enumerate(lines, 1):
    stripped = line.strip()
    
    # Track procs
    m = re.match(r'\.proc\s+(\w+)', stripped)
    if m:
        current_proc = m.group(1)
        current_proc_start = i
    elif stripped == '.endproc' and current_proc:
        procs.append((current_proc, current_proc_start, i))
        current_proc = None
    
    # Find Loc_ labels
    for m in re.finditer(r'Loc_([0-9A-Fa-f]+)', stripped):
        addr = m.group(1)
        label = f"Loc_{addr}"
        # Determine if this is a definition (label at start of line, possibly with colon)
        is_def = bool(re.match(rf'\s*{label}\s*:', line))
        loc_labels[label].append((i, is_def, line.rstrip(), current_proc))

# Print analysis grouped by proc
for proc_name, proc_start, proc_end in procs:
    # Find Loc_ labels in this proc
    proc_labels = set()
    for label, entries in loc_labels.items():
        for line_num, is_def, line_text, pname in entries:
            if proc_start <= line_num <= proc_end:
                proc_labels.add(label)
    
    if not proc_labels:
        continue
    
    print(f"\n{'='*70}")
    print(f"PROC: {proc_name} (lines {proc_start}-{proc_end})")
    print(f"  {len(proc_labels)} Loc_ labels")
    print(f"{'='*70}")
    
    for label in sorted(proc_labels):
        entries = loc_labels[label]
        defs = [e for e in entries if e[1]]
        refs = [e for e in entries if not e[1]]
        
        if defs:
            def_line = defs[0][0]
            # Show context: 2 lines before, the label line, and 5 lines after
            ctx_start = max(0, def_line - 3)
            ctx_end = min(len(lines), def_line + 5)
            print(f"\n  {label} (defined at line {def_line}, {len(refs)} refs)")
            for j in range(ctx_start, ctx_end):
                marker = ">>>" if j + 1 == def_line else "   "
                print(f"    {marker} {j+1:5d}: {lines[j].rstrip()}")
            
            # Show first few references
            for ref in refs[:3]:
                print(f"      ref@{ref[0]}: {ref[2].strip()}")
            if len(refs) > 3:
                print(f"      ... and {len(refs)-3} more refs")

# Also show the 3 bank 1E equates
print(f"\n{'='*70}")
print("BANK 1E EQUATES")
print(f"{'='*70}")
for label, entries in loc_labels.items():
    for line_num, is_def, line_text, pname in entries:
        if line_num > 3444:
            print(f"  Line {line_num}: {line_text.strip()}")
