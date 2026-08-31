#!/usr/bin/env python3
"""Fix numeric branch targets in prg_0e_0f.asm.

Branches written as `BNE $C920` make ca65 fail with
"Range error (Address size 2 does not match fragment size 1)" because the
numeric literal is a 16-bit expression but branch operands are 8-bit.

For every numeric branch target:
  - if an existing label sits at the target address, rewrite the operand to
    that label;
  - else insert a new label before the target line: `Loc_XXXX:` at file
    scope, `@loc_XXXX:` when the target lies inside a .proc (cheap local).
Adapted from transform_branches.py (which fixed prg_1f.asm the same way).
"""

import re
import sys

FILE = 'asm/banks/prg_0e_0f.asm'

BRANCH_OPS = r'BCC|BCS|BEQ|BMI|BNE|BPL|BVC|BVS'
BRANCH_HEX_PAT = re.compile(r'((?:' + BRANCH_OPS + r')\s+)(\$[0-9A-F]{4})(\s+;)')
ADDR_PAT = re.compile(r';\s*\$([0-9A-F]{4}):')
LABEL_DEF_PAT = re.compile(r'^(\s*)(@?[A-Za-z_][A-Za-z0-9_]*):(\s|$)')


def main():
    with open(FILE) as f:
        lines = f.readlines()

    # --- address -> line index (first occurrence) ---
    addr_to_line = {}
    for i, line in enumerate(lines):
        m = ADDR_PAT.search(line)
        if m:
            addr = '$' + m.group(1)
            if addr not in addr_to_line:
                addr_to_line[addr] = i

    # --- existing label sitting at each address ---
    label_at = {}  # addr -> label name
    for i, line in enumerate(lines):
        m = LABEL_DEF_PAT.match(line)
        if m:
            label = m.group(2)
            # label binds to the next line that carries an address comment
            for j in range(i, min(i + 4, len(lines))):
                am = ADDR_PAT.search(lines[j])
                if am:
                    addr = '$' + am.group(1)
                    if addr not in label_at:
                        label_at[addr] = label
                    break

    # --- proc scope map: line index -> enclosing proc name (or None) ---
    scope = []
    cur = None
    for line in lines:
        m = re.match(r'\.proc\s+(\w+)', line)
        if m:
            cur = m.group(1)
        elif re.match(r'\.endproc', line):
            cur = None
        scope.append(cur)

    # --- collect numeric branch targets ---
    targets = set()
    for line in lines:
        m = BRANCH_HEX_PAT.search(line)
        if m:
            targets.add(m.group(2).upper())

    # --- decide new labels ---
    new_label = {}  # addr -> (label, insert_line_idx)
    problems = []
    for addr in sorted(targets):
        if addr in label_at:
            continue
        if addr not in addr_to_line:
            problems.append(f'no line with address {addr}')
            continue
        idx = addr_to_line[addr]
        proc = scope[idx]
        if proc is not None:
            new_label[addr] = ('@loc_' + addr[1:].lower(), idx)
        else:
            new_label[addr] = ('Loc_' + addr[1:], idx)

    # --- insert labels in reverse line order ---
    for addr, (label, idx) in sorted(new_label.items(), key=lambda kv: -kv[1][1]):
        lines.insert(idx, label + ':\n')

    # rebuild scope map and label_at after insertion
    scope = []
    cur = None
    for line in lines:
        m = re.match(r'\.proc\s+(\w+)', line)
        if m:
            cur = m.group(1)
        elif re.match(r'\.endproc', line):
            cur = None
        scope.append(cur)

    # --- rewrite operands ---
    def label_for(addr):
        if addr in label_at:
            return label_at[addr]
        if addr in new_label:
            return new_label[addr][0]
        return None

    out = []
    for i, line in enumerate(lines):
        def repl(m):
            addr = m.group(2).upper()
            lbl = label_for(addr)
            if lbl is None:
                return m.group(0)
            # cheap locals only visible inside the same scope
            if lbl.startswith('@') and scope[i] is None:
                return m.group(0)
            return f'{m.group(1)}{lbl:<24s}{m.group(3)}'
        out.append(BRANCH_HEX_PAT.sub(repl, line))

    with open(FILE, 'w') as f:
        f.writelines(out)

    print(f'numeric branch targets: {len(targets)}')
    print(f'labels inserted: {len(new_label)}')
    print(f'operands rewritten to existing labels: '
          f'{len([a for a in targets if a in label_at])}')
    for p in problems:
        print('  PROBLEM:', p)
    remaining = sum(1 for l in out if BRANCH_HEX_PAT.search(l))
    print(f'remaining numeric branch operands: {remaining}')
    return 1 if problems or remaining else 0


if __name__ == '__main__':
    sys.exit(main())
