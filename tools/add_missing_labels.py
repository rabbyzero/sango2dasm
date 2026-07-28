#!/usr/bin/env python3
"""Add missing @ADDR labels for dispatch table entries."""
import re

filepath = '/home/zero/project/sango2dasm/asm/banks/prg_0c_0d.asm'

with open(filepath, 'r') as f:
    content = f.read()
    lines = content.split('\n')

# Find all undefined @ADDR symbols from dispatch tables
undefined = set()
for line in lines:
    m = re.search(r'\.word\s+(@[A-F0-9]{4})\b', line)
    if m:
        undefined.add(m.group(1))
    # Also check for JMP/JSR references
    m = re.search(r'(?:JMP|JSR|BEQ|BNE|BCC|BCS|BMI|BPL|BVC|BVS)\s+(@[A-F0-9]{4})\b', line)
    if m:
        undefined.add(m.group(1))

# Find all defined @ADDR labels
defined = set()
for line in lines:
    m = re.match(r'^(@[A-F0-9]{4}):', line)
    if m:
        defined.add(m.group(1))

# Find missing labels
missing = undefined - defined
print(f"Undefined @ADDR symbols: {len(undefined)}")
print(f"Defined @ADDR labels: {len(defined)}")
print(f"Missing labels: {len(missing)}")

# For each missing label, find the line with the matching address comment and add the label
for label in sorted(missing):
    addr = label[1:]  # Remove @ prefix
    pattern = f'; ${addr}:'
    found = False
    for i, line in enumerate(lines):
        if pattern in line and not line.strip().startswith(';'):
            # Check if this line already has a label (at start, ignoring leading spaces)
            stripped = line.lstrip()
            if not re.match(r'^[@\w]+:', stripped):
                # Add the label before this line, preserving indentation
                indent = line[:len(line) - len(stripped)]
                lines[i] = f'{indent}{label}:\n{line}'
                print(f"Added {label} at line {i+1}")
                found = True
                break
    if not found:
        print(f"Could not find location for {label}")

with open(filepath, 'w') as f:
    f.write('\n'.join(lines))

print("Done!")
