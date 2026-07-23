#!/usr/bin/env python3
"""
General-purpose proc wrapper for prg_0c_0d.asm.
Processes a handler region and wraps it in .proc/.endproc.

Usage: python3 tools/proc_wrap_general.py <start_label> <end_label> [internal_labels...]
"""
import re
import os
import sys

os.chdir('/home/zero/project/sango2dasm')
ASM_FILE = "asm/banks/prg_0c_0d.asm"

# Known external helpers that should remain as global references
EXTERNAL_HELPERS = ['Loc_A1DE', 'Loc_A1F7', 'Loc_A20C']

def find_label_line(lines, label):
    """Find line index where label is defined."""
    pattern = re.compile(r'^' + re.escape(label) + r':')
    for i, line in enumerate(lines):
        if pattern.match(line):
            return i
    return None

def extract_internal_labels(lines, start_idx, end_idx):
    """Extract all Loc_XXXX labels within a range."""
    labels = []
    for i in range(start_idx, end_idx):
        m = re.match(r'^Loc_([0-9A-Fa-f]+):', lines[i])
        if m:
            labels.append(m.group(1))
    return labels

def process_handler(start_label, end_label, extra_internal=None):
    with open(ASM_FILE, 'r') as f:
        lines = f.readlines()

    start_idx = find_label_line(lines, start_label)
    end_idx = find_label_line(lines, end_label) if end_label else len(lines)

    if start_idx is None:
        print(f"ERROR: Start label {start_label} not found")
        return False
    if end_idx is None and end_label:
        print(f"ERROR: End label {end_label} not found")
        return False

    print(f"Processing {start_label}: lines {start_idx+1}-{end_idx}")

    # Extract internal labels
    internal_labels = extract_internal_labels(lines, start_idx + 1, end_idx)
    if extra_internal:
        internal_labels.extend(extra_internal)
    # Remove the start label from internal (it becomes the proc name)
    start_addr = start_label.replace('Loc_', '')
    internal_labels = [l for l in internal_labels if l != start_addr]

    print(f"  Internal labels: {internal_labels}")

    def transform_line(line):
        result = line

        # 1. Replace label definitions
        for addr in internal_labels:
            if result.startswith(f'Loc_{addr}:'):
                m = re.match(r'^Loc_' + addr + r':\s*(;.*)?$', result.rstrip('\n'))
                if m and m.group(1):
                    return f'@{addr}:  {m.group(1)}\n'
                else:
                    return f'@{addr}:\n'

        # 2. Replace branch/jump targets to internal labels
        for addr in internal_labels:
            result = re.sub(
                r'\b(BNE|BEQ|BMI|BPL|BCC|BCS|BVC|BVS)\s+\$' + addr + r'\b',
                lambda m: m.group(1) + ' @' + addr,
                result
            )
            result = re.sub(
                r'\b(JMP|JSR)\s+\$' + addr + r'\b',
                lambda m: m.group(1) + ' @' + addr,
                result
            )

        # 3. Replace .word $XXXX -> .word @XXXX (dispatch table)
        for addr in internal_labels:
            result = re.sub(
                r'\.word\s+\$' + addr + r'\b',
                '.word @' + addr,
                result
            )

        # 4. Replace external helper references
        for helper in EXTERNAL_HELPERS:
            addr = helper.replace('Loc_', '')
            result = re.sub(r'\bJSR \$' + addr + r'\b', f'JSR {helper}', result)
            result = re.sub(r'\bJMP \$' + addr + r'\b', f'JMP {helper}', result)

        return result

    # Build new content
    section = lines[start_idx:end_idx]
    new_content = [f'.proc {start_label}\n']

    for line in section:
        if line.startswith(f'{start_label}:'):
            m = re.search(r';.*$', line.rstrip('\n'))
            if m:
                new_content.append(f'  {m.group(0)}\n')
            continue
        new_content.append(transform_line(line))

    new_content.append('.endproc\n')
    new_content.append('\n')

    # Replace
    new_lines = lines[:start_idx] + new_content + lines[end_idx:]

    with open(ASM_FILE, 'w') as f:
        f.writelines(new_lines)

    print(f"Done! Replaced {end_idx - start_idx} lines with {len(new_content)} new lines")
    return True

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python3 proc_wrap_general.py <start_label> <end_label>")
        print("Example: python3 proc_wrap_general.py Loc_A293 Loc_A44D")
        sys.exit(1)

    start_label = sys.argv[1]
    end_label = sys.argv[2] if sys.argv[2] != 'EOF' else None
    extra = sys.argv[3:] if len(sys.argv) > 3 else None

    process_handler(start_label, end_label, extra)
