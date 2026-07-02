#!/usr/bin/env python3
"""Fix prg_1d_1e.asm: remove .proc/.endproc scoping issues and add missing labels."""
import re

asm_file = 'asm/banks/prg_1d_1e.asm'
lines = open(asm_file).readlines()

# Step 1: Remove all .proc and .endproc lines
new_lines = []
for line in lines:
    stripped = line.strip()
    if stripped.startswith('.proc ') or stripped == '.endproc':
        continue
    new_lines.append(line)
lines = new_lines

# Step 2: Find all referenced L_XXXX and Loc_XXXX labels
referenced = set()
for line in lines:
    stripped = line.strip()
    if stripped.startswith(';'):
        continue
    # Find label references in instructions
    for m in re.finditer(r'(?:JMP|JSR|BNE|BEQ|BCC|BCS|BMI|BPL|BVC|BVS)\s+([\w]+)', stripped):
        ref = m.group(1)
        if re.match(r'^L_[0-9A-Fa-f]{4}$|^Loc_[0-9A-Fa-f]{4}$', ref):
            referenced.add(ref)

# Step 3: Find all defined labels
defined = set()
for line in lines:
    stripped = line.strip()
    m = re.match(r'^([\w]+):', stripped)
    if m:
        defined.add(m.group(1))

undefined = referenced - defined
print(f"Referenced: {len(referenced)}, Defined: {len(defined)}, Undefined: {len(undefined)}")

# Step 4: Build address -> label mapping for undefined labels
undef_addrs = {}
for label in undefined:
    m = re.match(r'^L_([0-9A-Fa-f]{4})$|^Loc_([0-9A-Fa-f]{4})$', label)
    if m:
        addr_str = m.group(1) or m.group(2)
        undef_addrs[int(addr_str, 16)] = label

# Step 5: For each instruction/data line, check if its address matches an undefined label
# Parse address from inline comment "; $ADDR:"
result = []
for line in lines:
    stripped = line.strip()
    m = re.search(r';\s*\$([0-9A-Fa-f]{4}):', stripped)
    if m:
        addr = int(m.group(1), 16)
        if addr in undef_addrs:
            label = undef_addrs.pop(addr)
            indent = len(line) - len(line.lstrip())
            result.append(' ' * indent + label + ':\n')
    result.append(line)

with open(asm_file, 'w') as f:
    f.writelines(result)

remaining = len(undef_addrs)
print(f"Added labels, {remaining} still undefined")
if undef_addrs:
    for addr, label in sorted(undef_addrs.items()):
        print(f"  ${addr:04X}: {label}")
