#!/usr/bin/env python3
"""
Step 1: Remove all gap byte insertions from the previous session and verify baseline.
"""
import re

SOURCE = 'asm/banks/prg_1f.asm'

with open(SOURCE) as f:
    lines = f.readlines()

addr_pat = re.compile(r';\s*\$([0-9A-Fa-f]{4}):\s*((?:[0-9A-Fa-f]{2}\s*)+)')
pad_label_pat = re.compile(r'^pad_[0-9a-f]{4}:')

# Step 1: Identify ALL pad_ labels and their associated .byte directives
remove_indices = set()

for i, line in enumerate(lines):
    stripped = line.strip()
    # Remove pad_ label lines
    if pad_label_pat.match(stripped):
        remove_indices.add(i)
        continue
    # Remove .byte directives that are gap byte insertions
    # (single-byte .byte with address comment, preceded by blank/pad label)
    if stripped.startswith('.byte') and ';' in stripped:
        m = addr_pat.search(line)
        if m:
            hexbytes = m.group(2).split()
            # Check preceding lines for context
            prev_nonblank = ''
            for j in range(i-1, max(i-5, 0), -1):
                if lines[j].strip():
                    prev_nonblank = lines[j].strip()
                    break
            # If preceded by pad_ label or blank line, it's a gap byte
            if pad_label_pat.match(prev_nonblank) or prev_nonblank == '':
                remove_indices.add(i)
            # If preceded by instruction (not data label), single byte = spurious
            elif len(hexbytes) == 1:
                # Check if prev line is an instruction (not a label or directive)
                prev_stripped = prev_nonblank.split(';')[0].strip()
                if any(prev_stripped.startswith(op) for op in 
                       ['BNE', 'BPL', 'BMI', 'BEQ', 'BCC', 'BCS', 'BVC', 'BVS',
                        'RTS', 'JMP', 'JSR', 'STA', 'STX', 'STY', 'LDA', 'LDX',
                        'LDY', 'ADC', 'SBC', 'AND', 'ORA', 'EOR', 'CMP', 'CPX',
                        'CPY', 'INC', 'DEC', 'INX', 'INY', 'DEX', 'DEY', 'ASL',
                        'LSR', 'ROL', 'ROR', 'CLC', 'SEC', 'CLI', 'SEI', 'CLV',
                        'CLD', 'SED', 'NOP', 'BRK', 'PHA', 'PLA', 'PHP', 'PLP',
                        'TAX', 'TXA', 'TAY', 'TYA', 'TSX', 'TXS', 'BIT']):
                    remove_indices.add(i)

# Also remove blank lines immediately before pad_ labels
for i in sorted(remove_indices):
    if i > 0 and lines[i-1].strip() == '':
        # Check if this blank line is between a pad_ block and preceding code
        if i+1 in remove_indices or (i < len(lines)-1 and pad_label_pat.match(lines[i+1].strip())):
            remove_indices.add(i-1)

# Remove identified lines
cleaned = []
for i, line in enumerate(lines):
    if i not in remove_indices:
        cleaned.append(line)

# Step 2: Verify address alignment in cleaned source
print(f"Removed {len(remove_indices)} lines")
print(f"Cleaned source: {len(cleaned)} lines")

# Parse addresses and check for gaps/overlaps
prev_end = 0xE000
prev_line = 0
gaps = []
overlaps = []
byte_count = 0

for i, line in enumerate(cleaned):
    m = addr_pat.search(line)
    if m:
        addr = int(m.group(1), 16)
        hexbytes = m.group(2).split()
        nbytes = len(hexbytes)
        
        if addr > prev_end:
            gap = addr - prev_end
            gaps.append((prev_end, addr, gap, prev_line, i))
        elif addr < prev_end:
            overlap = prev_end - addr
            overlaps.append((addr, prev_end, overlap, i))
        
        prev_end = addr + nbytes
        prev_line = i
        byte_count += nbytes

print(f"\nTotal instruction/data bytes: {byte_count} (expected: 8192 = $2000)")
print(f"\nGaps ({len(gaps)}):")
for start, end, size, pline, cline in gaps:
    print(f"  ${start:04X}-${end-1:04X} ({size}B) between lines {pline+1} and {cline+1}")

print(f"\nOverlaps ({len(overlaps)}):")
for addr, prev_end, overlap, line_num in overlaps:
    print(f"  ${addr:04X} overlaps with prev ending at ${prev_end:04X} ({overlap}B) at line {line_num+1}")
    print(f"    Line content: {cleaned[line_num].rstrip()}")
