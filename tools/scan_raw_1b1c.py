import re, collections

path = "asm/banks/prg_1b_1c.asm"
# absolute-mode operand pattern: MNEMONIC a:$XXXX or MNEMONIC $XXXX, and .word $XXXX
abs_instr = re.compile(r'^(\s*)((?:JSR|JMP|LDA|STA|ADC|AND|BIT|CMP|EOR|LDX|LDY|ORA|SBC|STX|STY|INC|DEC|ASL|LSR|ROL|ROR)\s+)(a:\$)?(\$[EFCDAB][0-9A-Fa-f]{3})\b(.*)$')
word_dir  = re.compile(r'^(\s*)\.word\s+(\$[EFCDAB][0-9A-Fa-f]{3})\b(.*)$')

hits = []
with open(path) as f:
    for i, line in enumerate(f, 1):
        stripped = line.strip()
        if stripped.startswith(';'):
            continue
        if stripped.startswith('.') and not stripped.startswith('.word'):
            continue
        m = abs_instr.match(line)
        if m:
            hits.append((i, 'instr', m.group(2).strip(), m.group(4).upper(), stripped))
            continue
        m = word_dir.match(line)
        if m:
            hits.append((i, 'word', '.word', m.group(2).upper(), stripped))

by_addr = collections.defaultdict(list)
for h in hits:
    by_addr[h[3]].append(h)

print(f"total raw operand sites: {len(hits)}, unique targets: {len(by_addr)}")
for addr in sorted(by_addr):
    lst = by_addr[addr]
    ops = sorted(set(h[2] for h in lst))
    print(f"\n{addr}  ({len(lst)} sites, ops={ops})")
    for h in lst[:6]:
        print(f"  L{h[0]}: {h[4]}")
    if len(lst) > 6:
        print(f"  ... +{len(lst)-6} more")
