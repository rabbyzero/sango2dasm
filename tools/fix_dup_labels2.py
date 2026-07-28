#!/usr/bin/env python3
"""Fix duplicate @labels by renaming them back to @ADDR format."""
import re
import sys

filepath = sys.argv[1] if len(sys.argv) > 1 else '/home/zero/project/sango2dasm/asm/banks/prg_0c_0d.asm'

with open(filepath, 'r') as f:
    lines = f.readlines()

# Find duplicate @labels per proc and rename them back to @ADDR format
in_proc = False
proc_name = None
label_counts = {}
renames = []  # (line_idx, old_label, new_label)

for i, line in enumerate(lines):
    m = re.match(r'^\.proc\s+(\w+)', line)
    if m:
        in_proc = True
        proc_name = m.group(1)
        label_counts = {}
        continue
    if line.strip() == '.endproc':
        in_proc = False
        continue
    if not in_proc:
        continue
    
    m = re.match(r'^(@\w+):', line)
    if m:
        label = m.group(1)
        label_counts[label] = label_counts.get(label, 0) + 1
        if label_counts[label] > 1:
            # Try to extract address from same line first
            addr_match = re.search(r';\s*\$([A-F0-9]{4}):', line)
            if not addr_match and i + 1 < len(lines):
                # Try next line
                addr_match = re.search(r';\s*\$([A-F0-9]{4}):', lines[i + 1])
            if addr_match:
                addr = addr_match.group(1)
                new_label = f'@{addr}'
                renames.append((i, label, new_label))
                print(f'Line {i+1}: {label} -> {new_label}')
            else:
                print(f'Line {i+1}: {label} -> NO ADDRESS FOUND')

print(f'\nTotal renames needed: {len(renames)}')

# Apply renames to definitions
for line_idx, old_label, new_label in renames:
    lines[line_idx] = lines[line_idx].replace(f'{old_label}:', f'{new_label}:', 1)

# Now update references within the same proc
# For each rename, find references between this definition and the next definition of the same label
in_proc = False
proc_name = None
active_renames = {}  # old_label -> new_label (currently active)
label_def_count = {}  # label -> count of definitions seen

for i, line in enumerate(lines):
    m = re.match(r'^\.proc\s+(\w+)', line)
    if m:
        in_proc = True
        proc_name = m.group(1)
        active_renames = {}
        label_def_count = {}
        continue
    if line.strip() == '.endproc':
        in_proc = False
        active_renames = {}
        label_def_count = {}
        continue
    if not in_proc:
        continue
    
    # Check if this is a label definition
    m = re.match(r'^(@\w+):', line)
    if m:
        label = m.group(1)
        label_def_count[label] = label_def_count.get(label, 0) + 1
        # Check if this definition was renamed
        for line_idx, old_label, new_label in renames:
            if line_idx == i:
                active_renames[old_label] = new_label
                break
    
    # Apply active renames to references in this line
    for old_label, new_label in list(active_renames.items()):
        # Replace references like "BEQ @Done" but not the definition "@Done:"
        if f' {old_label}' in line and not line.startswith(f'{old_label}:'):
            lines[i] = lines[i].replace(f' {old_label}', f' {new_label}')
            print(f'Line {i+1}: ref {old_label} -> {new_label}')

with open(filepath, 'w') as f:
    f.writelines(lines)

print('Done!')
