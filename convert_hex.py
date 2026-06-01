#!/usr/bin/env python3
"""
Convert all JSR/JMP/branch hex targets to named labels.
Builds address map by tracking label definitions and assigning them
the address of the next instruction.
"""
import re

SOURCE = 'asm/banks/prg_1f.asm'
OUTPUT = 'asm/banks/prg_1f.asm'

with open(SOURCE) as f:
    lines = f.readlines()

addr_pat = re.compile(r';\s*\$([0-9A-Fa-f]{4}):')
proc_pat = re.compile(r'^\.proc\s+(\w+)')
label_def_pat = re.compile(r'^([A-Za-z_]\w*):\s*$')
at_label_def_pat = re.compile(r'^(@[A-Za-z_]\w*):\s*$')

SKIP_NAMES = {'byte', 'word', 'addr', 'res', 'proc', 'endproc', 'segment',
              'org', 'include', 'if', 'endif', 'else', 'elseif', 'ifdef',
              'ifndef', 'macro', 'endmacro', 'repeat', 'endrep', 'scope',
              'endscope', 'define', 'undef', 'import', 'export', 'global'}

# Pass 1: Build address -> label map
addr_to_label = {}
pending_labels = []

for i, line in enumerate(lines):
    stripped = line.strip()
    
    # Check for .proc declaration
    pm = proc_pat.match(stripped)
    if pm:
        pending_labels.append(pm.group(1))
        continue
    
    # Check for standalone label definition
    lm = label_def_pat.match(stripped)
    if lm:
        name = lm.group(1)
        if name.lower() not in SKIP_NAMES:
            pending_labels.append(name)
            continue
    
    # Check for standalone @label definition
    alm = at_label_def_pat.match(stripped)
    if alm:
        pending_labels.append(alm.group(1))
        continue
    
    # Check for label on same line as instruction (e.g., "FuncName: LDA #$00  ; $XXXX: ...")
    # Pattern: label followed by instruction
    inline_lm = re.match(r'^([A-Za-z_]\w*):\s+(LDA|LDX|LDY|STA|STX|STY|JSR|JMP|RTS|NOP|BRK|SEC|CLC|SEI|CLI|CLD|SED|CLV|PHA|PLA|PHP|PLP|TAX|TXA|TAY|TYA|TSX|TXS|INX|INY|DEX|DEY|ASL|LSR|ROL|ROR|INC|DEC|ADC|SBC|AND|ORA|EOR|CMP|CPX|CPY|BIT|BNE|BEQ|BPL|BMI|BCC|BCS|BVC|BVS)\b', stripped)
    if inline_lm:
        name = inline_lm.group(1)
        if name.lower() not in SKIP_NAMES:
            pending_labels.append(name)
    
    # If this line has an address comment, assign pending labels
    am = addr_pat.search(line)
    if am and pending_labels:
        addr = int(am.group(1), 16)
        for label in pending_labels:
            if addr not in addr_to_label:
                addr_to_label[addr] = label
            # Later labels at same address override earlier ones for conversion
            # but we keep the first one (usually the .proc name)
        pending_labels = []

# Also parse global aliases (= $XXXX) 
for line in lines:
    am = re.match(r'(\w+)\s*=\s*\$([0-9A-Fa-f]{4})', line.strip())
    if am:
        name = am.group(1)
        addr = int(am.group(2), 16)
        if addr not in addr_to_label:
            addr_to_label[addr] = name

print(f"Address map: {len(addr_to_label)} entries")

# Show sample entries
for addr in sorted(addr_to_label.keys())[:15]:
    print(f"  ${addr:04X} -> {addr_to_label[addr]}")
print("  ...")

# Pass 2: Convert hex targets
instr_pat = re.compile(
    r'^(\s+)(JSR|JMP|BNE|BEQ|BPL|BMI|BCC|BCS|BVC|BVS)\s+\$([0-9A-Fa-f]{4})(\s*;.*)$'
)

conversions = 0
unconverted = []

for i, line in enumerate(lines):
    m = instr_pat.match(line)
    if m:
        indent = m.group(1)
        opcode = m.group(2)
        target = int(m.group(3), 16)
        comment = m.group(4)
        
        if target in addr_to_label:
            label = addr_to_label[target]
            lines[i] = f"{indent}{opcode} {label:<40s}{comment}\n"
            conversions += 1
        else:
            unconverted.append((i+1, line.rstrip()))

print(f"\nConversions: {conversions}")
print(f"Unconverted: {len(unconverted)}")
for ln, text in unconverted[:20]:
    print(f"  Line {ln}: {text}")
if len(unconverted) > 20:
    print(f"  ... and {len(unconverted)-20} more")

with open(OUTPUT, 'w') as f:
    f.writelines(lines)

print(f"\nWrote {len(lines)} lines to {OUTPUT}")
