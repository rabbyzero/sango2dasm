#!/usr/bin/env python3
"""Analyze prg_17_18.asm to build address-to-line mapping and identify function boundaries."""

import re
import sys
from pathlib import Path

def main():
    asm_path = Path(__file__).parent.parent / "asm" / "banks" / "prg_17_18.asm"
    lines = asm_path.read_text().splitlines()

    # Build address -> line_number map from inline byte comments
    addr_re = re.compile(r';\s+\$([0-9A-Fa-f]{4}):')
    label_re = re.compile(r'^(L[A-Fa-f0-9]{4}|B17_18_\w+):')
    rts_re = re.compile(r'^\s+RTS\b')
    jmp_re = re.compile(r'^\s+JMP\s+(\S+)')
    jsr_re = re.compile(r'^\s+JSR\s+(\S+)')
    byte_re = re.compile(r'^\s+\.byte\b')
    word_re = re.compile(r'^\s+\.word\b')
    segment_re = re.compile(r'^\.segment\s+"(\w+)"')

    addr_to_line = {}  # cpu_address -> line_number (0-based)
    labels = {}        # label_name -> line_number
    label_addrs = {}   # label_name -> cpu_address

    for i, line in enumerate(lines):
        # Extract address
        m = addr_re.search(line)
        if m:
            addr = int(m.group(1), 16)
            addr_to_line[addr] = i

        # Extract label
        m = label_re.match(line)
        if m:
            lbl = m.group(1)
            labels[lbl] = i

    # Now find the address of each label by looking at the next line's address
    for lbl, line_idx in labels.items():
        # Check subsequent lines for an address
        for j in range(line_idx, min(line_idx + 3, len(lines))):
            m = addr_re.search(lines[j])
            if m:
                label_addrs[lbl] = int(m.group(1), 16)
                break

    # Print summary
    print(f"Total lines: {len(lines)}")
    print(f"Labeled addresses: {len(label_addrs)}")
    print(f"Address-to-line entries: {len(addr_to_line)}")

    # Find all entry point targets
    entry_targets = {}
    # Parse jump table at $A000-$A029
    for i in range(len(lines)):
        m = jmp_re.match(lines[i])
        if m and i < 50:  # Jump table is in the first 50 lines
            target = m.group(1)
            m_addr = addr_re.search(lines[i])
            if m_addr:
                jmp_addr = int(m_addr.group(1), 16)
                entry_targets[jmp_addr] = target

    print("\n=== Jump Table Entry Targets ===")
    for addr in sorted(entry_targets.keys()):
        target = entry_targets[addr]
        target_addr = label_addrs.get(target, "???")
        if isinstance(target_addr, int):
            print(f"  ${addr:04X} -> {target} (${target_addr:04X}, line {labels.get(target, '?')})")
        else:
            print(f"  ${addr:04X} -> {target} (unknown addr)")

    # For each entry target, trace to find function extent
    print("\n=== Function Boundary Analysis ===")
    # Get sorted list of all label addresses
    sorted_label_addrs = sorted(label_addrs.items(), key=lambda x: x[1])

    for addr in sorted(entry_targets.keys()):
        target = entry_targets[addr]
        target_addr = label_addrs.get(target)
        if target_addr is None:
            continue

        # Find all labels and their addresses after this target
        subsequent = [(l, a) for l, a in sorted_label_addrs if a >= target_addr]

        # Find first RTS after target_addr
        first_rts_addr = None
        first_rts_line = None
        for i in range(len(lines)):
            if rts_re.match(lines[i]):
                m = addr_re.search(lines[i])
                if m:
                    rts_addr = int(m.group(1), 16)
                    if rts_addr >= target_addr:
                        first_rts_addr = rts_addr
                        first_rts_line = i
                        break

        print(f"\n  {target} (${target_addr:04X}):")
        print(f"    First RTS at ${first_rts_addr:04X}" if first_rts_addr else "    No RTS found")

        # Count JSR and JMP within this range
        if first_rts_addr:
            jsr_count = 0
            jmp_count = 0
            for i in range(addr_to_line.get(target_addr, 0), first_rts_line + 1):
                if jsr_re.match(lines[i]):
                    jsr_count += 1
                if jmp_re.match(lines[i]):
                    jmp_count += 1
            print(f"    JSR count: {jsr_count}, JMP count: {jmp_count}")
            print(f"    Size: {first_rts_addr - target_addr + 1} bytes")

if __name__ == "__main__":
    main()
