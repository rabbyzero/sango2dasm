#!/usr/bin/env python3
"""Add missing label definitions as equates at the top of bank $1E section."""
import re

asm_file = 'asm/banks/prg_1d_1e.asm'

# First, find all undefined labels by attempting to parse
lines = open(asm_file).readlines()

# Find all referenced labels matching L_XXXX or Loc_XXXX
referenced = set()
for line in lines:
    stripped = line.strip()
    if stripped.startswith(';'):
        continue
    for m in re.finditer(r'(?:JMP|JSR|BNE|BEQ|BCC|BCS|BMI|BPL|BVC|BVS)\s+([\w]+)', stripped):
        ref = m.group(1)
        if re.match(r'^L_[0-9A-Fa-f]{4}$|^Loc_[0-9A-Fa-f]{4}$', ref):
            referenced.add(ref)

# Find all defined labels
defined = set()
for line in lines:
    stripped = line.strip()
    m = re.match(r'^([\w]+):', stripped)
    if m:
        defined.add(m.group(1))

undefined = sorted(referenced - defined)

# Extract addresses and create equate definitions
equate_lines = []
for label in undefined:
    m = re.match(r'^L_([0-9A-Fa-f]{4})$|^Loc_([0-9A-Fa-f]{4})$', label)
    if m:
        addr_str = m.group(1) or m.group(2)
        addr = int(addr_str, 16)
        equate_lines.append(f"{label} = ${addr:04X}")

if equate_lines:
    # Find the line with .segment "CODE_BANK1E" and insert after it
    for i, line in enumerate(lines):
        if line.strip() == '.segment "CODE_BANK1E"':
            insert_point = i + 1
            break
    else:
        print("Could not find .segment CODE_BANK1E")
        exit(1)
    
    # Insert equates
    header = ["\n; Forward-referenced labels defined as equates\n"]
    for eq in equate_lines:
        header.append(f"  {eq}\n")
    header.append("\n")
    
    lines[insert_point:insert_point] = header
    
    with open(asm_file, 'w') as f:
        f.writelines(lines)
    
    print(f"Added {len(equate_lines)} label equates")
else:
    print("No undefined labels found")
