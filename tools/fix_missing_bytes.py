#!/usr/bin/env python3
"""Fix missing byte opcodes in assembly comment annotations.

Scans an annotated assembly file for lines that have an address comment
(; $XXXX) but are missing the opcode bytes. Reads the correct bytes from
the binary ROM file and rewrites the comment as ; $ADDR: XX XX [XX].

Usage:
    python3 tools/fix_missing_bytes.py [--asm FILE] [--bin FILE] [--base ADDR] [--in-place]
"""

import re
import sys
import argparse
import os

# ── Complete 6502 opcode length table (opcode -> byte length) ──
# Standard NMOS 6502 opcodes with well-known lengths.
# Undefined/illegal opcodes default to 1 byte.
OPCODE_LENGTHS = [1] * 256  # Default all to 1

# Populate known opcode lengths based on addressing mode
_OPCODE_DATA = {
    # 0x0X
    0x00: 1, 0x01: 2, 0x02: 1, 0x03: 2, 0x04: 2, 0x05: 2, 0x06: 2, 0x07: 2,
    0x08: 1, 0x09: 2, 0x0A: 1, 0x0B: 2, 0x0C: 3, 0x0D: 3, 0x0E: 3, 0x0F: 3,
    # 0x1X
    0x10: 2, 0x11: 2, 0x12: 1, 0x13: 2, 0x14: 2, 0x15: 2, 0x16: 2, 0x17: 2,
    0x18: 1, 0x19: 3, 0x1A: 1, 0x1B: 3, 0x1C: 3, 0x1D: 3, 0x1E: 3, 0x1F: 3,
    # 0x2X
    0x20: 3, 0x21: 2, 0x22: 1, 0x23: 2, 0x24: 2, 0x25: 2, 0x26: 2, 0x27: 2,
    0x28: 1, 0x29: 2, 0x2A: 1, 0x2B: 2, 0x2C: 3, 0x2D: 3, 0x2E: 3, 0x2F: 3,
    # 0x3X
    0x30: 2, 0x31: 2, 0x32: 1, 0x33: 2, 0x34: 2, 0x35: 2, 0x36: 2, 0x37: 2,
    0x38: 1, 0x39: 3, 0x3A: 1, 0x3B: 3, 0x3C: 3, 0x3D: 3, 0x3E: 3, 0x3F: 3,
    # 0x4X
    0x40: 1, 0x41: 2, 0x42: 1, 0x43: 2, 0x44: 2, 0x45: 2, 0x46: 2, 0x47: 2,
    0x48: 1, 0x49: 2, 0x4A: 1, 0x4B: 2, 0x4C: 3, 0x4D: 3, 0x4E: 3, 0x4F: 3,
    # 0x5X
    0x50: 2, 0x51: 2, 0x52: 1, 0x53: 2, 0x54: 2, 0x55: 2, 0x56: 2, 0x57: 2,
    0x58: 1, 0x59: 3, 0x5A: 1, 0x5B: 3, 0x5C: 3, 0x5D: 3, 0x5E: 3, 0x5F: 3,
    # 0x6X
    0x60: 1, 0x61: 2, 0x62: 1, 0x63: 2, 0x64: 2, 0x65: 2, 0x66: 2, 0x67: 2,
    0x68: 1, 0x69: 2, 0x6A: 1, 0x6B: 2, 0x6C: 3, 0x6D: 3, 0x6E: 3, 0x6F: 3,
    # 0x7X
    0x70: 2, 0x71: 2, 0x72: 1, 0x73: 2, 0x74: 2, 0x75: 2, 0x76: 2, 0x77: 2,
    0x78: 1, 0x79: 3, 0x7A: 1, 0x7B: 3, 0x7C: 3, 0x7D: 3, 0x7E: 3, 0x7F: 3,
    # 0x8X
    0x80: 2, 0x81: 2, 0x82: 2, 0x83: 2, 0x84: 2, 0x85: 2, 0x86: 2, 0x87: 2,
    0x88: 1, 0x89: 2, 0x8A: 1, 0x8B: 2, 0x8C: 3, 0x8D: 3, 0x8E: 3, 0x8F: 3,
    # 0x9X
    0x90: 2, 0x91: 2, 0x92: 1, 0x93: 2, 0x94: 2, 0x95: 2, 0x96: 2, 0x97: 2,
    0x98: 1, 0x99: 3, 0x9A: 1, 0x9B: 3, 0x9C: 3, 0x9D: 3, 0x9E: 3, 0x9F: 3,
    # 0xAX
    0xA0: 2, 0xA1: 2, 0xA2: 2, 0xA3: 2, 0xA4: 2, 0xA5: 2, 0xA6: 2, 0xA7: 2,
    0xA8: 1, 0xA9: 2, 0xAA: 1, 0xAB: 2, 0xAC: 3, 0xAD: 3, 0xAE: 3, 0xAF: 3,
    # 0xBX
    0xB0: 2, 0xB1: 2, 0xB2: 1, 0xB3: 2, 0xB4: 2, 0xB5: 2, 0xB6: 2, 0xB7: 2,
    0xB8: 1, 0xB9: 3, 0xBA: 1, 0xBB: 3, 0xBC: 3, 0xBD: 3, 0xBE: 3, 0xBF: 3,
    # 0xCX
    0xC0: 2, 0xC1: 2, 0xC2: 2, 0xC3: 2, 0xC4: 2, 0xC5: 2, 0xC6: 2, 0xC7: 2,
    0xC8: 1, 0xC9: 2, 0xCA: 1, 0xCB: 2, 0xCC: 3, 0xCD: 3, 0xCE: 3, 0xCF: 3,
    # 0xDX
    0xD0: 2, 0xD1: 2, 0xD2: 1, 0xD3: 2, 0xD4: 2, 0xD5: 2, 0xD6: 2, 0xD7: 2,
    0xD8: 1, 0xD9: 3, 0xDA: 1, 0xDB: 3, 0xDC: 3, 0xDD: 3, 0xDE: 3, 0xDF: 3,
    # 0xEX
    0xE0: 2, 0xE1: 2, 0xE2: 2, 0xE3: 2, 0xE4: 2, 0xE5: 2, 0xE6: 2, 0xE7: 2,
    0xE8: 1, 0xE9: 2, 0xEA: 1, 0xEB: 2, 0xEC: 3, 0xED: 3, 0xEE: 3, 0xEF: 3,
    # 0xFX
    0xF0: 2, 0xF1: 2, 0xF2: 1, 0xF3: 2, 0xF4: 2, 0xF5: 2, 0xF6: 2, 0xF7: 2,
    0xF8: 1, 0xF9: 3, 0xFA: 1, 0xFB: 3, 0xFC: 3, 0xFD: 3, 0xFE: 3, 0xFF: 3,
}

for opcode, length in _OPCODE_DATA.items():
    OPCODE_LENGTHS[opcode] = length


# ── Regex patterns ──

# Matches a line that has an instruction/directive before `;` and a comment
# with address like `; $XXXX` or `; $XXXX:` but NO hex bytes following
# Group 1: everything before the comment (code portion + spaces + ';')
# Group 2: the address (4 hex digits)
RE_MISSING_BYTES = re.compile(
    r'^(.*\S.*;\s*)\$([0-9A-Fa-f]{4}):?\s*$'
)

# Matches a line that already has bytes: `; $XXXX: XX XX` (at least one byte)
RE_HAS_BYTES = re.compile(
    r';\s*\$[0-9A-Fa-f]{4}:\s+[0-9A-Fa-f]{2}'
)

# Detects pure comment lines (no instruction before `;`)
RE_PURE_COMMENT = re.compile(r'^\s*;')

# Detect .byte directive
RE_BYTE_DIRECTIVE = re.compile(r'^\s+\.byte\b\s*(.*)', re.IGNORECASE)

# Detect .word directive
RE_WORD_DIRECTIVE = re.compile(r'^\s+\.word\b\s*(.*)', re.IGNORECASE)

# Detect .addr directive
RE_ADDR_DIRECTIVE = re.compile(r'^\s+\.addr\b\s*(.*)', re.IGNORECASE)


def count_byte_entries(operand_str):
    """Count the number of byte values in a .byte directive operand."""
    # Strip any trailing comment
    cp = operand_str.find(';')
    if cp >= 0:
        operand_str = operand_str[:cp]
    entries = [p.strip() for p in operand_str.split(',') if p.strip()]
    return len(entries)


def count_word_entries(operand_str):
    """Count the number of word/addr values (each is 2 bytes)."""
    cp = operand_str.find(';')
    if cp >= 0:
        operand_str = operand_str[:cp]
    entries = [p.strip() for p in operand_str.split(',') if p.strip()]
    return len(entries)


def get_directive_byte_count(line):
    """Determine how many bytes a data directive line represents.

    Returns (num_bytes, directive_type) or (0, None) if not a data directive.
    """
    m = RE_BYTE_DIRECTIVE.match(line)
    if m:
        return count_byte_entries(m.group(1)), 'byte'

    m = RE_WORD_DIRECTIVE.match(line)
    if m:
        return count_word_entries(m.group(1)) * 2, 'word'

    m = RE_ADDR_DIRECTIVE.match(line)
    if m:
        return count_word_entries(m.group(1)) * 2, 'addr'

    return 0, None


def format_bytes(binary_data, offset, num_bytes):
    """Format num_bytes from binary_data at offset as 'XX XX XX'."""
    end = min(offset + num_bytes, len(binary_data))
    return ' '.join(f'{b:02X}' for b in binary_data[offset:end])


def process_line(line, binary_data, base_addr):
    """Process a single line and return (fixed_line, was_modified).

    Returns the line unchanged if:
    - It's a pure comment line (no code before ;)
    - It already has byte annotations
    - It doesn't match the missing-bytes pattern
    """
    # Skip pure comment lines (entire line is a comment)
    if RE_PURE_COMMENT.match(line):
        return line, False

    # Skip lines that already have bytes annotated
    if RE_HAS_BYTES.search(line):
        return line, False

    # Check if this line has a missing-bytes address comment
    m = RE_MISSING_BYTES.match(line)
    if not m:
        return line, False

    prefix = m.group(1)  # Everything up to and including '; '
    addr_hex = m.group(2)
    addr = int(addr_hex, 16)
    offset = addr - base_addr

    # Validate offset is within binary bounds
    if offset < 0 or offset >= len(binary_data):
        return line, False

    # Determine how many bytes to read
    # Check if it's a data directive
    # We need the code portion (before the comment)
    comment_pos = line.find(';')
    code_part = line[:comment_pos].rstrip() if comment_pos >= 0 else line.rstrip()

    byte_count, directive_type = get_directive_byte_count(code_part)
    if directive_type:
        # Data directive - use the counted bytes
        num_bytes = byte_count
    else:
        # CPU instruction - use opcode length table
        opcode = binary_data[offset]
        num_bytes = OPCODE_LENGTHS[opcode]

    # Validate we have enough data
    if offset + num_bytes > len(binary_data):
        num_bytes = len(binary_data) - offset

    # Format the bytes
    bytes_str = format_bytes(binary_data, offset, num_bytes)

    # Rebuild the line: preserve everything before the comment, then new annotation
    # prefix already ends with '; ' or similar - reconstruct cleanly
    # We want: <code_part>  ; $ADDR: XX XX
    # The prefix captured includes the '; ' and '$', so let's reconstruct
    fixed_comment = f'${ addr_hex.upper()}: {bytes_str}'

    # Reconstruct: code + spacing + ; + space + address:bytes
    # Find where the comment starts in the original line
    # and preserve the spacing between code and comment
    before_comment = line[:comment_pos]
    fixed_line = f'{before_comment}; {fixed_comment}'

    return fixed_line, True


def main():
    parser = argparse.ArgumentParser(
        description='Fix missing byte opcodes in assembly comment annotations.'
    )
    parser.add_argument(
        '--asm',
        default='asm/banks/prg_1f.asm',
        help='Path to assembly file (default: asm/banks/prg_1f.asm)'
    )
    parser.add_argument(
        '--bin',
        default='rom/prg/prg_1f.bin',
        help='Path to binary file (default: rom/prg/prg_1f.bin)'
    )
    parser.add_argument(
        '--base',
        default='0xE000',
        help='Base address as hex (default: 0xE000)'
    )
    parser.add_argument(
        '--in-place',
        action='store_true',
        help='Modify the file in place (otherwise print to stdout)'
    )

    args = parser.parse_args()

    # Resolve paths relative to project root if not absolute
    project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    asm_path = args.asm if os.path.isabs(args.asm) else os.path.join(project_dir, args.asm)
    bin_path = args.bin if os.path.isabs(args.bin) else os.path.join(project_dir, args.bin)
    base_addr = int(args.base, 16)

    # Load binary
    with open(bin_path, 'rb') as f:
        binary_data = f.read()

    # Read assembly file
    with open(asm_path, 'r') as f:
        lines = f.readlines()

    # Process each line
    output_lines = []
    fix_count = 0
    for line in lines:
        line_stripped = line.rstrip('\n')
        fixed, modified = process_line(line_stripped, binary_data, base_addr)
        output_lines.append(fixed)
        if modified:
            fix_count += 1

    # Output
    result = '\n'.join(output_lines)
    if not result.endswith('\n'):
        result += '\n'

    if args.in_place:
        with open(asm_path, 'w') as f:
            f.write(result)
        print(f"Fixed {fix_count} lines in-place: {asm_path}", file=sys.stderr)
    else:
        sys.stdout.write(result)
        print(f"Fixed {fix_count} lines (dry run)", file=sys.stderr)


if __name__ == '__main__':
    main()
