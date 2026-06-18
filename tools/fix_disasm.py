#!/usr/bin/env python3
"""Fix the disasm script to add cross-bank equates."""

with open('/home/zero/project/sango2dasm/tools/disasm_17_18.py', 'r') as f:
    lines = f.readlines()

# Find where to insert cross_refs computation (after "all_labels.update(KNOWN_FUNCS)")
insert_after = None
for i, line in enumerate(lines):
    if 'all_labels.update(KNOWN_FUNCS)' in line:
        insert_after = i
        break

if insert_after is None:
    print("ERROR: couldn't find insertion point")
    exit(1)

# Insert cross-refs computation
cross_refs_lines = [
    "\n",
    "    # Collect cross-bank label references\n",
    "    cross_refs_17 = {}  # labels in $C000-$DFFF referenced from bank 17\n",
    "    cross_refs_18 = {}  # labels in $A000-$BFFF referenced from bank 18\n",
    "    for addr, label in dis.labels.items():\n",
    "        if 0xC000 <= addr <= 0xDFFF:\n",
    "            cross_refs_17[label] = addr\n",
    "        elif 0xA000 <= addr <= 0xBFFF:\n",
    "            cross_refs_18[label] = addr\n",
    "\n",
]

for j, cl in enumerate(cross_refs_lines):
    lines.insert(insert_after + 1 + j, cl)

# Now find "; Jump Table" line in bank 17 output and insert equates before it
new_lines = []
for i, line in enumerate(lines):
    if '; Jump Table - Public entry points ($A000-$A029)' in line:
        # Check it's in the out_17 context
        if i > 0 and 'out_17' in lines[i-1]:
            # Insert equates section before this append
            new_lines.append('    out_17.append(";===============================================================================")\n')
            new_lines.append('    out_17.append("; Cross-bank references to bank $18 ($C000-$DFFF)")\n')
            new_lines.append('    out_17.append(";===============================================================================")\n')
            new_lines.append('    for label in sorted(cross_refs_17.keys()):\n')
            new_lines.append('        addr = cross_refs_17[label]\n')
            new_lines.append('        out_17.append(f"{label:<24}= ${addr:04X}")\n')
            new_lines.append('    out_17.append("")\n')
            new_lines.append('    out_17.append(";===============================================================================")\n')
    new_lines.append(line)

with open('/home/zero/project/sango2dasm/tools/disasm_17_18.py', 'w') as f:
    f.writelines(new_lines)

print("Done - added cross_refs computation and bank 17 equates")
