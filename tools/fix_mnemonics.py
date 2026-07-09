#!/usr/bin/env python3
"""Fix mnemonic-opcode mismatches in prg_1f.asm.

The mismatched lines have address-only comments ("; $XXXX" without opcode bytes).
We look up the correct instruction from pbank31.cdl.asm reference, fix the mnemonic,
construct the correct operand from opcode bytes, and add opcode bytes to the comment.
"""

import re
import sys
from pathlib import Path

# Full 6502 opcode table: opcode_byte -> (mnemonic, addressing_mode, byte_count)
OPCODE_TABLE = {
    0x00: ('BRK', 'imp', 1), 0x01: ('ORA', 'inx', 2), 0x05: ('ORA', 'zpg', 2), 0x06: ('ASL', 'zpg', 2),
    0x08: ('PHP', 'imp', 1), 0x09: ('ORA', 'imm', 2), 0x0A: ('ASL', 'acc', 1), 0x0D: ('ORA', 'abs', 3),
    0x0E: ('ASL', 'abs', 3), 0x10: ('BPL', 'rel', 2), 0x11: ('ORA', 'iny', 2), 0x15: ('ORA', 'zpx', 2),
    0x16: ('ASL', 'zpx', 2), 0x18: ('CLC', 'imp', 1), 0x19: ('ORA', 'aby', 3), 0x1D: ('ORA', 'abx', 3),
    0x1E: ('ASL', 'abx', 3), 0x20: ('JSR', 'abs', 3), 0x21: ('AND', 'inx', 2), 0x24: ('BIT', 'zpg', 2),
    0x25: ('AND', 'zpg', 2), 0x26: ('ROL', 'zpg', 2), 0x28: ('PLP', 'imp', 1), 0x29: ('AND', 'imm', 2),
    0x2A: ('ROL', 'acc', 1), 0x2C: ('BIT', 'abs', 3), 0x2D: ('AND', 'abs', 3), 0x2E: ('ROL', 'abs', 3),
    0x30: ('BMI', 'rel', 2), 0x31: ('AND', 'iny', 2), 0x35: ('AND', 'zpx', 2), 0x36: ('ROL', 'zpx', 2),
    0x38: ('SEC', 'imp', 1), 0x39: ('AND', 'aby', 3), 0x3D: ('AND', 'abx', 3), 0x3E: ('ROL', 'abx', 3),
    0x40: ('RTI', 'imp', 1), 0x41: ('EOR', 'inx', 2), 0x45: ('EOR', 'zpg', 2), 0x46: ('LSR', 'zpg', 2),
    0x48: ('PHA', 'imp', 1), 0x49: ('EOR', 'imm', 2), 0x4A: ('LSR', 'acc', 1), 0x4C: ('JMP', 'abs', 3),
    0x4D: ('EOR', 'abs', 3), 0x4E: ('LSR', 'abs', 3), 0x50: ('BVC', 'rel', 2), 0x51: ('EOR', 'iny', 2),
    0x55: ('EOR', 'zpx', 2), 0x56: ('LSR', 'zpx', 2), 0x58: ('CLI', 'imp', 1), 0x59: ('EOR', 'aby', 3),
    0x5D: ('EOR', 'abx', 3), 0x5E: ('LSR', 'abx', 3), 0x60: ('RTS', 'imp', 1), 0x61: ('ADC', 'inx', 2),
    0x65: ('ADC', 'zpg', 2), 0x66: ('ROR', 'zpg', 2), 0x68: ('PLA', 'imp', 1), 0x69: ('ADC', 'imm', 2),
    0x6A: ('ROR', 'acc', 1), 0x6C: ('JMP', 'ind', 3), 0x6D: ('ADC', 'abs', 3), 0x6E: ('ROR', 'abs', 3),
    0x70: ('BVS', 'rel', 2), 0x71: ('ADC', 'iny', 2), 0x75: ('ADC', 'zpx', 2), 0x76: ('ROR', 'zpx', 2),
    0x78: ('SEI', 'imp', 1), 0x79: ('ADC', 'aby', 3), 0x7D: ('ADC', 'abx', 3), 0x7E: ('ROR', 'abx', 3),
    0x81: ('STA', 'inx', 2), 0x84: ('STY', 'zpg', 2), 0x85: ('STA', 'zpg', 2), 0x86: ('STX', 'zpg', 2),
    0x88: ('DEY', 'imp', 1), 0x8A: ('TXA', 'imp', 1), 0x8C: ('STY', 'abs', 3), 0x8D: ('STA', 'abs', 3),
    0x8E: ('STX', 'abs', 3), 0x90: ('BCC', 'rel', 2), 0x91: ('STA', 'iny', 2), 0x94: ('STY', 'zpx', 2),
    0x95: ('STA', 'zpx', 2), 0x96: ('STX', 'zpy', 2), 0x98: ('TYA', 'imp', 1), 0x99: ('STA', 'aby', 3),
    0x9A: ('TXS', 'imp', 1), 0x9D: ('STA', 'abx', 3), 0xA0: ('LDY', 'imm', 2), 0xA1: ('LDA', 'inx', 2),
    0xA2: ('LDX', 'imm', 2), 0xA4: ('LDY', 'zpg', 2), 0xA5: ('LDA', 'zpg', 2), 0xA6: ('LDX', 'zpg', 2),
    0xA8: ('TAY', 'imp', 1), 0xA9: ('LDA', 'imm', 2), 0xAA: ('TAX', 'imp', 1), 0xAC: ('LDY', 'abs', 3),
    0xAD: ('LDA', 'abs', 3), 0xAE: ('LDX', 'abs', 3), 0xB0: ('BCS', 'rel', 2), 0xB1: ('LDA', 'iny', 2),
    0xB4: ('LDY', 'zpx', 2), 0xB5: ('LDA', 'zpx', 2), 0xB6: ('LDX', 'zpy', 2), 0xB8: ('CLV', 'imp', 1),
    0xB9: ('LDA', 'aby', 3), 0xBA: ('TSX', 'imp', 1), 0xBC: ('LDY', 'abx', 3), 0xBD: ('LDA', 'abx', 3),
    0xBE: ('LDX', 'aby', 3), 0xC0: ('CPY', 'imm', 2), 0xC1: ('CMP', 'inx', 2), 0xC4: ('CPY', 'zpg', 2),
    0xC5: ('CMP', 'zpg', 2), 0xC6: ('DEC', 'zpg', 2), 0xC8: ('INY', 'imp', 1), 0xC9: ('CMP', 'imm', 2),
    0xCA: ('DEX', 'imp', 1), 0xCC: ('CPY', 'abs', 3), 0xCD: ('CMP', 'abs', 3), 0xCE: ('DEC', 'abs', 3),
    0xD0: ('BNE', 'rel', 2), 0xD1: ('CMP', 'iny', 2), 0xD5: ('CMP', 'zpx', 2), 0xD6: ('DEC', 'zpx', 2),
    0xD8: ('CLD', 'imp', 1), 0xD9: ('CMP', 'aby', 3), 0xDD: ('CMP', 'abx', 3), 0xDE: ('DEC', 'abx', 3),
    0xE0: ('CPX', 'imm', 2), 0xE1: ('SBC', 'inx', 2), 0xE4: ('CPX', 'zpg', 2), 0xE5: ('SBC', 'zpg', 2),
    0xE6: ('INC', 'zpg', 2), 0xE8: ('INX', 'imp', 1), 0xE9: ('SBC', 'imm', 2), 0xEA: ('NOP', 'imp', 1),
    0xEC: ('CPX', 'abs', 3), 0xED: ('SBC', 'abs', 3), 0xEE: ('INC', 'abs', 3), 0xF0: ('BEQ', 'rel', 2),
    0xF1: ('SBC', 'iny', 2), 0xF5: ('SBC', 'zpx', 2), 0xF6: ('INC', 'zpx', 2), 0xF8: ('SED', 'imp', 1),
    0xF9: ('SBC', 'aby', 3), 0xFD: ('SBC', 'abx', 3), 0xFE: ('INC', 'abx', 3),
}

MACRO_TO_MNEMONIC = {
    'sta_abs': 'STA', 'lda_abs': 'LDA', 'ora_abs': 'ORA', 'inc_abs': 'INC',
    'stx_abs': 'STX', 'sty_abs': 'STY', 'dec_abs': 'DEC', 'ldx_abs': 'LDX',
    'ldy_abs': 'LDY', 'asl_abs': 'ASL', 'bit_abs': 'BIT', 'and_abs': 'AND',
    'rol_abs': 'ROL', 'eor_abs': 'EOR', 'adc_abs': 'ADC', 'ror_abs': 'ROR',
    'cpy_abs': 'CPY', 'cmp_abs': 'CMP', 'sbc_abs': 'SBC',
    'lda_absx': 'LDA', 'cmp_absx': 'CMP',
}


def parse_reference_file(filepath):
    """Parse pbank31.cdl.asm: address -> (mnemonic, addr_mode, opcode_bytes)."""
    ref_map = {}
    line_re = re.compile(
        r'^[A-Za-z0-9_+-]*\s+'
        r'([a-z_]+)'
        r'(?:\s+(.+?))?'
        r'\s*;\s*([0-9a-f]{4}):\s*'
        r'([0-9a-f]{2}(?:\s+[0-9a-f]{2})*)'
    )

    with open(filepath, 'r') as f:
        for line in f:
            m = line_re.match(line.rstrip())
            if m:
                instr = m.group(1).lower()
                addr = int(m.group(3), 16)
                opcode_bytes = [int(b, 16) for b in m.group(4).split()]

                if instr in ('hex', 'db', 'org', 'equ'):
                    continue

                if instr in MACRO_TO_MNEMONIC:
                    mnemonic = MACRO_TO_MNEMONIC[instr]
                else:
                    mnemonic = instr.upper()

                first_byte = opcode_bytes[0]
                if first_byte in OPCODE_TABLE:
                    _, addr_mode, _ = OPCODE_TABLE[first_byte]
                else:
                    addr_mode = 'unknown'

                ref_map[addr] = (mnemonic, addr_mode, opcode_bytes)

    return ref_map


def construct_operand(opcode_bytes, addr_mode, current_addr):
    """Construct operand string from opcode bytes and addressing mode."""
    if addr_mode in ('imp', 'acc'):
        return ''
    if len(opcode_bytes) < 2:
        return ''

    if addr_mode == 'imm':
        return f'#${opcode_bytes[1]:02X}'
    if addr_mode == 'rel':
        offset = opcode_bytes[1]
        if offset >= 0x80:
            offset -= 0x100
        target = current_addr + 2 + offset
        return f'${target:04X}'
    if addr_mode == 'zpg':
        return f'${opcode_bytes[1]:02X}'
    if addr_mode == 'zpx':
        return f'${opcode_bytes[1]:02X},X'
    if addr_mode == 'zpy':
        return f'${opcode_bytes[1]:02X},Y'
    if addr_mode == 'inx':
        return f'(${opcode_bytes[1]:02X},X)'
    if addr_mode == 'iny':
        return f'(${opcode_bytes[1]:02X}),Y'

    if len(opcode_bytes) >= 3:
        full_addr = opcode_bytes[1] | (opcode_bytes[2] << 8)
        if addr_mode == 'abs':
            return f'${full_addr:04X}'
        if addr_mode == 'abx':
            return f'${full_addr:04X},X'
        if addr_mode == 'aby':
            return f'${full_addr:04X},Y'
        if addr_mode == 'ind':
            return f'(${full_addr:04X})'

    return ''


def format_opcode_bytes(opcode_bytes):
    """Format opcode bytes as uppercase hex string."""
    return ' '.join(f'{b:02X}' for b in opcode_bytes)


def fix_aligned_file(ref_map, aligned_path):
    """Fix mismatches in the aligned file."""
    with open(aligned_path, 'r') as f:
        lines = f.readlines()

    changes = []
    new_lines = []

    # Match instruction lines with address comments (with or without opcode bytes)
    # Group 1: leading whitespace
    # Group 2: mnemonic (3-letter uppercase)
    # Group 3: everything between mnemonic and semicolon (operand + spacing)
    # Group 4: the address hex digits
    # After match, we check for opcode bytes separately
    instr_line_re = re.compile(
        r'^(\s*)([A-Z]{2,3})((?:\s+\S.*?)?\s*)(;\s*\$([0-9A-Fa-f]{4}))(.*?)$'
    )

    for line_num, line in enumerate(lines, 1):
        orig_line = line.rstrip('\n')
        m = instr_line_re.match(orig_line)
        if not m:
            new_lines.append(line)
            continue

        leading_ws = m.group(1)
        mnemonic = m.group(2)
        mid_section = m.group(3)  # operand + spacing before comment
        addr_comment = m.group(4)  # "; $XXXX"
        addr_str = m.group(5)
        after_addr = m.group(6)  # everything after the address: could be ": XX XX  desc" or "  desc" or ""

        addr = int(addr_str, 16)

        # Check if this line already has opcode bytes (format: ": XX XX XX")
        bytes_match = re.match(r'^:\s*([0-9A-Fa-f]{2}(?:\s+[0-9A-Fa-f]{2})*)(.*)', after_addr)
        has_bytes = bytes_match is not None

        if has_bytes:
            # Line already has bytes - check if mnemonic matches
            shown_bytes = [int(b, 16) for b in bytes_match.group(1).split()]
            first_byte = shown_bytes[0]
            if first_byte in OPCODE_TABLE:
                correct_mnem = OPCODE_TABLE[first_byte][0]
                if mnemonic == correct_mnem:
                    new_lines.append(line)
                    continue
                # Rare case: mnemonic wrong even with bytes shown
                # (shouldn't happen based on our analysis, but handle anyway)
            else:
                new_lines.append(line)
                continue

        # No bytes in comment - look up reference
        if addr not in ref_map:
            new_lines.append(line)
            continue

        ref_mnem, ref_mode, ref_bytes = ref_map[addr]

        if mnemonic == ref_mnem:
            new_lines.append(line)
            continue

        # MNEMONIC MISMATCH - fix it!
        # Extract the current operand (strip trailing whitespace before comment)
        operand_match = re.match(r'^(\s*)(.*?)(\s*)$', mid_section)
        if operand_match:
            operand = operand_match.group(2).strip()
        else:
            operand = ''

        # Determine the old addressing mode category
        BRANCH_MNEMONICS = {'BPL', 'BMI', 'BVC', 'BVS', 'BCC', 'BCS', 'BNE', 'BEQ'}
        old_was_branch = mnemonic in BRANCH_MNEMONICS

        # Determine new operand based on reference addressing mode
        if ref_mode in ('imp', 'acc'):
            new_operand = ''
        elif ref_mode == 'rel':
            # Branch: keep existing label ONLY if old was also a branch
            # and the label looks like a code label (starts with @)
            if old_was_branch and operand and operand.startswith('@'):
                new_operand = operand
            else:
                new_operand = construct_operand(ref_bytes, ref_mode, addr)
        else:
            # For all other modes: construct operand from reference bytes
            new_operand = construct_operand(ref_bytes, ref_mode, addr)

        # Build instruction text
        if new_operand:
            instr_part = f'{ref_mnem} {new_operand}'
        else:
            instr_part = ref_mnem

        # Build the comment with opcode bytes
        bytes_str = format_opcode_bytes(ref_bytes)

        # Preserve any trailing description
        if has_bytes:
            description = bytes_match.group(2).strip()
        else:
            description = after_addr.strip()

        if description:
            new_comment = f'; ${addr_str.upper()}: {bytes_str}  {description}'
        else:
            new_comment = f'; ${addr_str.upper()}: {bytes_str}'

        # Calculate alignment - try to keep comment at same column
        comment_idx = orig_line.find('; $')
        new_instr = leading_ws + instr_part
        if comment_idx > len(new_instr):
            padding = ' ' * (comment_idx - len(new_instr))
        else:
            # Minimum padding
            padding = ' ' * max(2, 50 - len(new_instr))

        new_line = new_instr + padding + new_comment + '\n'
        new_lines.append(new_line)
        changes.append({
            'line_num': line_num,
            'address': f'${addr:04X}',
            'old': f'{mnemonic} {operand}'.strip(),
            'new': f'{ref_mnem} {new_operand}'.strip(),
            'bytes': bytes_str,
        })

    # Write back
    with open(aligned_path, 'w') as f:
        f.writelines(new_lines)

    return changes


def main():
    base_dir = Path(__file__).parent.parent
    ref_path = base_dir / 'asm' / 'banks' / 'pbank31.cdl.asm'
    aligned_path = base_dir / 'asm' / 'banks' / 'prg_1f.asm'

    print(f"Reading reference: {ref_path}")
    ref_map = parse_reference_file(ref_path)
    print(f"  Found {len(ref_map)} address entries in reference")

    print(f"\nFixing: {aligned_path}")
    changes = fix_aligned_file(ref_map, aligned_path)

    print(f"\n{'='*80}")
    print(f"SUMMARY: Fixed {len(changes)} mnemonic mismatches")
    print(f"{'='*80}")

    if changes:
        print(f"\n{'Line':<6} {'Addr':<7} {'Bytes':<12} {'Old':<30} {'New':<30}")
        print(f"{'-'*6} {'-'*7} {'-'*12} {'-'*30} {'-'*30}")
        for c in changes:
            print(f"{c['line_num']:<6} {c['address']:<7} {c['bytes']:<12} {c['old']:<30} {c['new']:<30}")

    return len(changes)


if __name__ == '__main__':
    n = main()
    sys.exit(0 if n > 0 else 1)
