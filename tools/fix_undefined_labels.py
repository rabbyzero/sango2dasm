#!/usr/bin/env python3
"""Fix undefined L_XXXX labels by inserting label definitions at the correct positions."""
import re
import sys

asm_file = sys.argv[1]

# Parse the file to find:
# 1. All label references (used in JMP/JSR/branch instructions)
# 2. All label definitions (labels followed by :)
# 3. All .byte lines with their address ranges

lines = open(asm_file).readlines()

# Track all defined labels
defined_labels = set()
# Track all referenced labels
referenced_labels = set()
# Track .byte lines with their starting address and byte count
byte_lines = []  # (line_index, start_addr, num_bytes)

for i, line in enumerate(lines):
    stripped = line.strip()
    
    # Check for label definition
    m = re.match(r'^(\w+):', stripped)
    if m:
        defined_labels.add(m.group(1))
    
    # Check for label references in instructions
    for m in re.finditer(r'(?:JMP|JSR|BNE|BEQ|BCC|BCS|BMI|BPL|BVC|BVS)\s+(\w+)', stripped):
        referenced_labels.add(m.group(1))
    # Also check for label in LDA/STA/etc with label operands
    for m in re.finditer(r'(?:LDA|STA|LDX|STX|LDY|STY|CMP|CPX|CPY|ADC|SBC|AND|ORA|EOR|BIT)\s+(\w+)', stripped):
        ref = m.group(1)
        if ref.startswith('L_') or ref.startswith('Loc_'):
            referenced_labels.add(ref)
    
    # Parse .byte lines for address info
    m = re.match(r'\s*\.byte\s+(.*?)\s*;\s*\$([0-9A-Fa-f]+):', stripped)
    if m:
        byte_data = m.group(1)
        addr_str = m.group(2)
        addr = int(addr_str, 16)
        # Count bytes
        num_bytes = len([b.strip() for b in byte_data.split(',') if b.strip()])
        byte_lines.append((i, addr, num_bytes))

# Find undefined labels
undefined = referenced_labels - defined_labels
# Filter to L_XXXX and Loc_XXXX patterns
label_pattern = re.compile(r'^L_([0-9A-Fa-f]{4})$|^Loc_([0-9A-Fa-f]{4})$')
undefined_addrs = {}
for label in undefined:
    m = label_pattern.match(label)
    if m:
        addr_str = m.group(1) or m.group(2)
        addr = int(addr_str, 16)
        undefined_addrs[label] = addr

print(f"Found {len(undefined_addrs)} undefined labels with addresses")

# Build address-to-byte-line mapping
# For each .byte line, compute which byte offset corresponds to which address
addr_to_line_offset = {}  # addr -> (line_index, byte_offset_within_line)
for line_idx, start_addr, num_bytes in byte_lines:
    for offset in range(num_bytes):
        addr_to_line_offset[start_addr + offset] = (line_idx, offset)

# Group undefined labels by their target .byte line
# label_at_addr needs to be inserted before the byte at that offset
fixes = {}  # line_idx -> list of (byte_offset, label_name)
for label, addr in sorted(undefined_addrs.items()):
    if addr in addr_to_line_offset:
        line_idx, byte_offset = addr_to_line_offset[addr]
        if line_idx not in fixes:
            fixes[line_idx] = []
        fixes[line_idx].append((byte_offset, label))
    else:
        print(f"  WARNING: Address ${addr:04X} for label {label} not found in any .byte line")

# Apply fixes in reverse order to preserve line numbers
for line_idx in sorted(fixes.keys(), reverse=True):
    entries = sorted(fixes[line_idx], reverse=True)
    original_line = lines[line_idx]
    
    # Parse the .byte line
    m = re.match(r'(\s*)\.byte\s+(.*?)\s*;\s*(\$[0-9A-Fa-f]+:\s*[0-9A-Fa-f\s]+)\s*$', original_line.rstrip())
    if not m:
        print(f"  Cannot parse line {line_idx+1}: {original_line.rstrip()}")
        continue
    
    indent = m.group(1)
    byte_data_str = m.group(2)
    comment = m.group(3)
    byte_vals = [b.strip() for b in byte_data_str.split(',') if b.strip()]
    
    # Split the .byte line at label positions
    new_lines = []
    current_bytes = []
    
    # Process bytes in order, inserting labels
    label_at_offset = {}
    for byte_offset, label_name in entries:
        label_at_offset[byte_offset] = label_name
    
    for i, bv in enumerate(byte_vals):
        if i in label_at_offset:
            # Output accumulated bytes first
            if current_bytes:
                # Calculate the address for these bytes
                addr_m = re.search(r'\$([0-9A-Fa-f]+):', comment)
                if addr_m:
                    base = int(addr_m.group(1), 16)
                    # Find offset of first current_byte in byte_vals
                    first_idx = i - len(current_bytes)
                    addr = base + first_idx
                    byte_str = ', '.join(current_bytes)
                    raw_bytes = ' '.join([b.replace('$', '') for b in current_bytes])
                    new_lines.append(f"{indent}.byte {byte_str} ; ${addr:04X}: {raw_bytes}\n")
                    current_bytes = []
            # Insert label
            new_lines.append(f"{label_at_offset[i]}:\n")
        current_bytes.append(bv)
    
    # Output remaining bytes
    if current_bytes:
        addr_m = re.search(r'\$([0-9A-Fa-f]+):', comment)
        if addr_m:
            base = int(addr_m.group(1), 16)
            first_idx = len(byte_vals) - len(current_bytes)
            addr = base + first_idx
            byte_str = ', '.join(current_bytes)
            raw_bytes = ' '.join([b.replace('$', '') for b in current_bytes])
            new_lines.append(f"{indent}.byte {byte_str} ; ${addr:04X}: {raw_bytes}\n")
    
    # Replace the original line with the new lines
    lines[line_idx:line_idx+1] = new_lines

with open(asm_file, 'w') as f:
    f.writelines(lines)

print(f"Applied fixes to {len(fixes)} lines")
