#!/usr/bin/env python3
"""Scan prg_0e_0f.asm for direct $A000-$FFFF accesses lacking reference names,
and report candidate labels for each address."""
import re, sys

path = 'asm/banks/prg_0e_0f.asm'
lines = open(path).read().splitlines()

label_at = {}            # addr -> list of (name, line_no)
pc_re = re.compile(r';\s*\$([0-9A-F]{4}):')
lbl_re = re.compile(r'^(@?[A-Za-z_][A-Za-z0-9_]*):')
proc_of = {}             # label name -> enclosing proc name
cur_proc = None
cur_label = None

for i, l in enumerate(lines):
    pm = re.match(r'\.proc\s+(\w+)', l)
    if pm:
        cur_proc = pm.group(1)
        continue
    if re.match(r'\.endproc', l):
        cur_proc = None
        continue
    m = lbl_re.match(l)
    if m:
        name = m.group(1)
        cur_label = (name, i)
        proc_of[name] = cur_proc
        continue
    m = pc_re.search(l)
    if m and cur_label and i - cur_label[1] <= 3:
        addr = int(m.group(1), 16)
        label_at.setdefault(addr, []).append((cur_label[0], cur_label[1]))
        cur_label = None  # only attach to first address following the label

ops_re = re.compile(r'^\s*(JSR|JMP|LDA|STA|LDX|STX|LDY|STY|CMP|AND|ORA|ADC|SBC|BIT|INC|DEC|ASL|LSR|ROL|ROR|EOR)\s+(\(\$[0-9A-F]{4}\)|\$[0-9A-F]{4})')

hits = []
for i, l in enumerate(lines):
    if pc_re.search(l) is None and ';$' not in l:
        # still allow lines without pc comments? require operand match anyway
        pass
    m = ops_re.match(l)
    if not m:
        continue
    op, oper = m.group(1), m.group(2).strip('()')
    addr_s = oper[1:]
    if not ('F' >= addr_s[0] >= 'A'):
        continue
    hits.append((i + 1, l, op, addr_s))

print(f"total direct-access lines: {len(hits)}")
for ln, l, op, a in hits:
    a_i = int(a, 16)
    lbl = label_at.get(a_i, [])
    p = [f"{n} (in {'outside' if proc_of.get(n) is None else proc_of[n]})" for n, _ in lbl]
    print(f"L{ln:5d} {op:3s} ${a}  -> {', '.join(p) if p else 'NO LABEL'}")
