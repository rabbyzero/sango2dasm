#!/usr/bin/env python3
"""Insert labels at branch target addresses that don't have labels yet.
For each branch hex target, find the instruction at that address and insert
a descriptive @label before it."""

import re

BRANCH_OPS = r'BCC|BCS|BEQ|BMI|BNE|BPL|BVC|BVS'
BRANCH_HEX_PAT = re.compile(r'((?:' + BRANCH_OPS + r')\s+)(\$[0-9A-Fa-f]{4})(\s+;)')

# Common naming patterns based on context
def make_label(addr, prev_context):
    """Generate a descriptive label for a branch target."""
    # Use address-based naming as fallback
    addr_num = addr[1:]  # Remove $
    return f'@loc_{addr_num}'


def main():
    filepath = '/home/zero/project/sango2dasm/asm/banks/prg_1f.asm'
    with open(filepath, 'r') as f:
        lines = f.readlines()

    # Step 1: Collect all branch hex targets
    branch_targets = set()
    for line in lines:
        m = BRANCH_HEX_PAT.search(line)
        if m:
            addr = m.group(2).upper()
            branch_targets.add(addr)

    # Step 2: Build address -> line index map
    addr_to_line = {}
    for i, line in enumerate(lines):
        m = re.search(r';\s*\$([0-9A-Fa-f]{4}):', line)
        if m:
            addr = '$' + m.group(1).upper()
            if addr not in addr_to_line:
                addr_to_line[addr] = i

    # Step 3: Build existing label -> address map
    existing_labels_at = set()
    for line in lines:
        stripped = line.rstrip('\n')
        if stripped and not stripped[0].isspace() and stripped.endswith(':'):
            label = stripped[:-1].strip()
            if label.startswith('@') or label.startswith('loc_'):
                # Find address of next instruction line
                idx = lines.index(line)
                for j in range(idx, min(idx+3, len(lines))):
                    m = re.search(r';\s*\$([0-9A-Fa-f]{4}):', lines[j])
                    if m:
                        existing_labels_at.add('$' + m.group(1).upper())
                        break

    # Step 4: Find targets that need new labels
    targets_needing_labels = {}
    for addr in sorted(branch_targets):
        if addr in existing_labels_at:
            continue
        if addr in addr_to_line:
            line_idx = addr_to_line[addr]
            # Check if previous line is already a label for this address
            if line_idx > 0:
                prev = lines[line_idx - 1].rstrip('\n')
                if prev.endswith(':') and not prev[0].isspace():
                    # There's already a label here
                    existing_labels_at.add(addr)
                    continue
            targets_needing_labels[addr] = line_idx

    # Step 5: Generate labels
    # Group targets by function (proc) context for naming
    current_proc = None
    proc_targets = {}
    for i, line in enumerate(lines):
        stripped = line.rstrip('\n')
        m = re.match(r'\.proc\s+(\w+)', stripped)
        if m:
            current_proc = m.group(1)
        elif stripped.strip() == '.endproc':
            current_proc = None
        if i in targets_needing_labels.values():
            addr = [a for a, idx in targets_needing_labels.items() if idx == i][0]
            if current_proc not in proc_targets:
                proc_targets[current_proc] = []
            proc_targets[current_proc].append((addr, i))

    # Generate unique labels per proc
    label_map = {}  # addr -> label_name
    for proc, targets in proc_targets.items():
        counter = 0
        for addr, line_idx in sorted(targets, key=lambda x: x[0]):
            # Check context for descriptive naming
            line = lines[line_idx].rstrip('\n')
            # Try to use a descriptive name based on nearby code
            addr_num = addr[1:].lower()
            label = f'@loc_{addr_num}'
            label_map[addr] = label

    # Step 6: Insert labels (process in reverse order to maintain line indices)
    insertions = sorted(targets_needing_labels.items(), key=lambda x: x[1], reverse=True)
    for addr, line_idx in insertions:
        label = label_map.get(addr, make_label(addr, ''))
        lines.insert(line_idx, label + ':\n')

    # Step 7: Replace branch hex targets with label names
    new_lines = []
    for line in lines:
        stripped = line.rstrip('\n')

        def branch_repl(m):
            prefix = m.group(1)
            addr = m.group(2).upper()
            suffix = m.group(3)
            if addr in label_map:
                return f'{prefix}{label_map[addr]:<24s}{suffix}'
            # Check existing labels
            if addr in addr_to_line:
                target_idx = addr_to_line[addr]
                # Look for label at this address
                if target_idx > 0:
                    prev = lines[target_idx - 1].rstrip('\n') if target_idx > 0 else ''
                    if prev.endswith(':') and not prev[0].isspace():
                        label_name = prev[:-1].strip()
                        return f'{prefix}{label_name:<24s}{suffix}'
                curr = lines[target_idx].rstrip('\n')
                if curr.endswith(':') and not curr[0].isspace():
                    label_name = curr[:-1].strip()
                    return f'{prefix}{label_name:<24s}{suffix}'
            return m.group(0)

        result = BRANCH_HEX_PAT.sub(branch_repl, stripped)
        new_lines.append(result + '\n')

    with open(filepath, 'w') as f:
        f.writelines(new_lines)

    print(f"Targets needing labels: {len(targets_needing_labels)}")
    print(f"Labels inserted: {len(insertions)}")
    print(f"Total lines: {len(new_lines)}")

    # Count remaining
    remaining = 0
    with open(filepath, 'r') as f:
        for lineno, line in enumerate(f, 1):
            if BRANCH_HEX_PAT.search(line):
                remaining += 1
                if remaining <= 5:
                    print(f"  Remaining branch at line {lineno}: {line.rstrip()}")
    print(f"Remaining branch hex targets: {remaining}")


if __name__ == '__main__':
    main()
