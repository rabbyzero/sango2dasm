#!/usr/bin/env python3
"""update_jsr_labels.py - Update JSR/JMP operands using functions.h address map.

Reads include/functions.h to build an address→symbol map for $E000-$FFFF,
then rewrites JSR/JMP operands in asm/banks/prg_1f.aligned.asm to use the
correct symbolic names based on the target address decoded from inline byte comments.

Idempotent: running multiple times produces the same output.
"""

import re
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)

FUNCTIONS_H = os.path.join(PROJECT_DIR, "include", "functions.h")
ASM_FILE = os.path.join(PROJECT_DIR, "asm", "banks", "prg_1f.aligned.asm")

# Column where ';' comment should be aligned (0-indexed)
COMMENT_COLUMN = 48


def parse_functions_h(path):
    """Parse functions.h and return {address_int: symbol_name} for $E000-$FFFF."""
    addr_map = {}
    pattern = re.compile(r'^(\w+)\s*=\s*\$([0-9A-Fa-f]{4})')
    with open(path, 'r') as f:
        for line in f:
            m = pattern.match(line)
            if m:
                name = m.group(1)
                addr = int(m.group(2), 16)
                if 0xE000 <= addr <= 0xFFFF:
                    addr_map[addr] = name
    return addr_map


def process_asm(asm_path, addr_map):
    """Process the ASM file, replacing JSR/JMP operands where applicable."""
    # Pattern to match JSR/JMP lines with inline byte comments
    # Groups: 1=indent+mnemonic, 2=mnemonic(JSR|JMP), 3=operand, 4=comment start (; $XXXX:),
    #         5=opcode byte, 6=low byte, 7=high byte, 8=rest of comment
    line_pattern = re.compile(
        r'^(\s+(JSR|JMP)\s+)(\S+)(\s+;.*?:\s*)(20|4C)\s+([0-9A-Fa-f]{2})\s+([0-9A-Fa-f]{2})(.*)'
    )

    with open(asm_path, 'r') as f:
        lines = f.readlines()

    changed_count = 0
    used_addrs = set()
    new_lines = []

    for line in lines:
        m = line_pattern.match(line)
        if m:
            prefix = m.group(1)       # e.g. "  JSR "
            mnemonic = m.group(2)     # JSR or JMP
            operand = m.group(3)      # current label/address
            comment_mid = m.group(4)  # spacing + ; $XXXX:
            opcode = m.group(5)       # 20 or 4C
            lo_byte = m.group(6)      # low byte hex
            hi_byte = m.group(7)      # high byte hex
            rest = m.group(8)         # remaining comment text

            # Decode target address (little-endian)
            target_addr = int(hi_byte, 16) * 256 + int(lo_byte, 16)

            # Check if target is in our map and operand is not @local or ::scoped
            if (target_addr in addr_map and
                    not operand.startswith('@') and
                    '::' not in operand):
                new_label = addr_map[target_addr]

                # Only change if different
                if operand != new_label:
                    # Rebuild the line with proper alignment
                    # prefix already includes the indentation and mnemonic with trailing space
                    code_part = prefix + new_label

                    # Extract the comment portion (from ; onwards)
                    # comment_mid contains the spacing before ; and the ; $XXXX: part
                    # We need to reconstruct: code_part + padding + ; $XXXX: opcode lo hi rest
                    # Find the actual comment content
                    comment_content = comment_mid.lstrip()  # starts with '; $XXXX: '
                    comment_text = comment_content + opcode + " " + lo_byte + " " + hi_byte + rest

                    # Pad to align ; at COMMENT_COLUMN
                    code_len = len(code_part)
                    if code_len < COMMENT_COLUMN:
                        padding = ' ' * (COMMENT_COLUMN - code_len)
                    else:
                        padding = ' '  # minimum 1 space

                    new_line = code_part + padding + comment_text + '\n'
                    new_lines.append(new_line)
                    changed_count += 1
                    used_addrs.add(target_addr)
                    continue

        new_lines.append(line)

    return new_lines, changed_count, used_addrs


def main():
    if not os.path.isfile(FUNCTIONS_H):
        print(f"Error: {FUNCTIONS_H} not found", file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(ASM_FILE):
        print(f"Error: {ASM_FILE} not found", file=sys.stderr)
        sys.exit(1)

    # Step 1: Parse functions.h
    addr_map = parse_functions_h(FUNCTIONS_H)
    print(f"Loaded {len(addr_map)} address mappings from functions.h")

    # Step 2-4: Process ASM file
    new_lines, changed_count, used_addrs = process_asm(ASM_FILE, addr_map)

    # Step 5: Write back
    with open(ASM_FILE, 'w') as f:
        f.writelines(new_lines)

    # Step 6: Summary
    print(f"Lines changed: {changed_count}")
    print(f"Unique address mappings used: {len(used_addrs)}")
    if used_addrs:
        for addr in sorted(used_addrs):
            print(f"  ${addr:04X} -> {addr_map[addr]}")


if __name__ == '__main__':
    main()
