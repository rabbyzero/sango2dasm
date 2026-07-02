#!/usr/bin/env python3
"""Check address continuity and find gaps/misalignments in prg_1d_1e.asm."""
import re

asm_file = 'asm/banks/prg_1d_1e.asm'
lines = open(asm_file).readlines()

# Track address coverage per segment
current_segment = None
last_addr = None
last_end = None
gaps = []
overlaps = []

for i, line in enumerate(lines):
    stripped = line.strip()
    
    # Track segment changes
    m = re.match(r'\.segment\s+"(\w+)"', stripped)
    if m:
        current_segment = m.group(1)
        last_addr = None
        last_end = None
        continue
    
    if not current_segment:
        continue
    
    # Extract address from inline comment
    m = re.search(r';\s*\$([0-9A-Fa-f]{4}):', stripped)
    if not m:
        continue
    
    addr = int(m.group(1), 16)
    
    # Calculate bytes on this line
    if stripped.startswith('.byte'):
        # Count bytes in .byte directive
        bm = re.match(r'\.byte\s+(.*?)\s*;', stripped)
        if bm:
            byte_vals = [b.strip() for b in bm.group(1).split(',') if b.strip()]
            num_bytes = len(byte_vals)
        else:
            num_bytes = 0
    else:
        # Count bytes from the hex bytes in the comment after the address
        cm = re.search(r';\s*\$[0-9A-Fa-f]{4}:\s+([0-9A-Fa-f\s]+)', stripped)
        if cm:
            num_bytes = len(cm.group(1).strip().split())
        else:
            num_bytes = 0
    
    if num_bytes == 0:
        continue
    
    end_addr = addr + num_bytes
    
    if last_end is not None and addr != last_end:
        if addr > last_end:
            gap_size = addr - last_end
            gaps.append((last_end, addr, gap_size, i+1, current_segment))
        else:
            overlap = last_end - addr
            overlaps.append((addr, last_end, overlap, i+1, current_segment))
    
    last_addr = addr
    last_end = end_addr

print(f"=== GAPS ({len(gaps)}) ===")
for start, end, size, line, seg in gaps:
    print(f"  ${start:04X}-${end:04X} ({size} bytes) at line {line} [{seg}]")

print(f"\n=== OVERLAPS ({len(overlaps)}) ===")
for start, end, size, line, seg in overlaps:
    print(f"  ${start:04X}-${end:04X} ({size} bytes) at line {line} [{seg}]")

# Check undefined label addresses against coverage
print(f"\n=== Total lines: {len(lines)} ===")
