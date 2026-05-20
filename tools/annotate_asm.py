#!/usr/bin/env python3
"""Annotate ca65 assembly file with ROM addresses and opcode bytes.

Tracks a running address through the ROM address space. For each asm
instruction, looks up the binary at the current address. If the mnemonic
matches, annotates with verified address + opcode bytes from the binary.
If it doesn't match (asm diverges from ROM), annotates address-only.
Section headers ('; $XXXX:') resync the address exactly.

Usage:
    python3 tools/annotate_asm.py [--in-place] [--verify]

By default writes to asm/banks/prg_1f_annotated.asm.
With --in-place, overwrites the original (with .bak backup).
With --verify, runs ca65 to check the output still assembles.
"""

import re
import os
import sys
import shutil
import subprocess

BASE_ADDR = 0xE000

# Branch instructions (always 2 bytes, relative addressing)
BRANCHES = {'BPL', 'BMI', 'BVC', 'BVS', 'BCC', 'BCS', 'BNE', 'BEQ'}

# ── Inline OPCODES table for binary mnemonic lookup ──
OPCODES = {
    0x00: ('BRK', 1), 0x01: ('ORA', 2), 0x05: ('ORA', 2),
    0x06: ('ASL', 2), 0x08: ('PHP', 1), 0x09: ('ORA', 2),
    0x0A: ('ASL', 1), 0x0D: ('ORA', 3), 0x0E: ('ASL', 3),
    0x10: ('BPL', 2), 0x11: ('ORA', 2), 0x15: ('ORA', 2),
    0x16: ('ASL', 2), 0x18: ('CLC', 1), 0x19: ('ORA', 3),
    0x1D: ('ORA', 3), 0x1E: ('ASL', 3),
    0x20: ('JSR', 3), 0x21: ('AND', 2), 0x24: ('BIT', 2),
    0x25: ('AND', 2), 0x26: ('ROL', 2), 0x28: ('PLP', 1),
    0x29: ('AND', 2), 0x2A: ('ROL', 1), 0x2C: ('BIT', 3),
    0x2D: ('AND', 3), 0x2E: ('ROL', 3),
    0x30: ('BMI', 2), 0x31: ('AND', 2), 0x35: ('AND', 2),
    0x36: ('ROL', 2), 0x38: ('SEC', 1), 0x39: ('AND', 3),
    0x3D: ('AND', 3), 0x3E: ('ROL', 3),
    0x40: ('RTI', 1), 0x41: ('EOR', 2), 0x45: ('EOR', 2),
    0x46: ('LSR', 2), 0x48: ('PHA', 1), 0x49: ('EOR', 2),
    0x4A: ('LSR', 1), 0x4C: ('JMP', 3), 0x4D: ('EOR', 3),
    0x4E: ('LSR', 3),
    0x50: ('BVC', 2), 0x51: ('EOR', 2), 0x55: ('EOR', 2),
    0x56: ('LSR', 2), 0x58: ('CLI', 1), 0x59: ('EOR', 3),
    0x5D: ('EOR', 3), 0x5E: ('LSR', 3),
    0x60: ('RTS', 1), 0x61: ('ADC', 2), 0x65: ('ADC', 2),
    0x66: ('ROR', 2), 0x68: ('PLA', 1), 0x69: ('ADC', 2),
    0x6A: ('ROR', 1), 0x6C: ('JMP', 3), 0x6D: ('ADC', 3),
    0x6E: ('ROR', 3),
    0x70: ('BVS', 2), 0x71: ('ADC', 2), 0x75: ('ADC', 2),
    0x76: ('ROR', 2), 0x78: ('SEI', 1), 0x79: ('ADC', 3),
    0x7D: ('ADC', 3), 0x7E: ('ROR', 3),
    0x81: ('STA', 2), 0x84: ('STY', 2), 0x85: ('STA', 2),
    0x86: ('STX', 2), 0x88: ('DEY', 1), 0x8A: ('TXA', 1),
    0x8C: ('STY', 3), 0x8D: ('STA', 3), 0x8E: ('STX', 3),
    0x90: ('BCC', 2), 0x91: ('STA', 2), 0x94: ('STY', 2),
    0x95: ('STA', 2), 0x96: ('STX', 2), 0x98: ('TYA', 1),
    0x99: ('STA', 3), 0x9A: ('TXS', 1), 0x9D: ('STA', 3),
    0xA0: ('LDY', 2), 0xA1: ('LDA', 2), 0xA2: ('LDX', 2),
    0xA4: ('LDY', 2), 0xA5: ('LDA', 2), 0xA6: ('LDX', 2),
    0xA8: ('TAY', 1), 0xA9: ('LDA', 2), 0xAA: ('TAX', 1),
    0xAC: ('LDY', 3), 0xAD: ('LDA', 3), 0xAE: ('LDX', 3),
    0xB0: ('BCS', 2), 0xB1: ('LDA', 2), 0xB4: ('LDY', 2),
    0xB5: ('LDA', 2), 0xB6: ('LDX', 2), 0xB8: ('CLV', 1),
    0xB9: ('LDA', 3), 0xBA: ('TSX', 1), 0xBC: ('LDY', 3),
    0xBD: ('LDA', 3), 0xBE: ('LDX', 3),
    0xC0: ('CPY', 2), 0xC1: ('CMP', 2), 0xC4: ('CPY', 2),
    0xC5: ('CMP', 2), 0xC6: ('DEC', 2), 0xC8: ('INY', 1),
    0xC9: ('CMP', 2), 0xCA: ('DEX', 1), 0xCC: ('CPY', 3),
    0xCD: ('CMP', 3), 0xCE: ('DEC', 3),
    0xD0: ('BNE', 2), 0xD1: ('CMP', 2), 0xD5: ('CMP', 2),
    0xD6: ('DEC', 2), 0xD8: ('CLD', 1), 0xD9: ('CMP', 3),
    0xDD: ('CMP', 3), 0xDE: ('DEC', 3),
    0xE0: ('CPX', 2), 0xE1: ('SBC', 2), 0xE4: ('CPX', 2),
    0xE5: ('SBC', 2), 0xE6: ('INC', 2), 0xE8: ('INX', 1),
    0xE9: ('SBC', 2), 0xEA: ('NOP', 1), 0xEC: ('CPX', 3),
    0xED: ('SBC', 3), 0xEE: ('INC', 3),
    0xF0: ('BEQ', 2), 0xF1: ('SBC', 2), 0xF5: ('SBC', 2),
    0xF6: ('INC', 2), 0xF8: ('SED', 1), 0xF9: ('SBC', 3),
    0xFD: ('SBC', 3), 0xFE: ('INC', 3),
}

# Set of all 6502 mnemonics for instruction detection
MNEMONICS = set(v[0] for v in OPCODES.values())


# ── Symbol table ──

def build_symbol_table(asm_path, include_dirs):
    """Build a symbol table from = definitions in the asm file and includes."""
    symbols = {}
    for inc_dir in include_dirs:
        if not os.path.isdir(inc_dir):
            continue
        for fname in os.listdir(inc_dir):
            fpath = os.path.join(inc_dir, fname)
            if os.path.isfile(fpath) and fname.endswith('.h'):
                with open(fpath) as f:
                    for line in f:
                        _parse_symbol_line(line, symbols)
    with open(asm_path) as f:
        for line in f:
            _parse_symbol_line(line, symbols)
    return symbols


def _parse_symbol_line(line, symbols):
    stripped = line.strip()
    m = re.match(r'^(\w+)\s*=\s*\$([0-9A-Fa-f]+)\b', stripped)
    if m:
        symbols[m.group(1)] = int(m.group(2), 16)


def resolve_operand_value(operand, symbols):
    """Try to resolve an operand to a numeric address."""
    # Direct hex
    m = re.match(r'^\$([0-9A-Fa-f]+)$', operand)
    if m:
        return int(m.group(1), 16)
    # Symbol
    if operand in symbols:
        return symbols[operand]
    # Symbol+N
    m = re.match(r'^(\w+)\s*\+\s*(\d+)$', operand)
    if m and m.group(1) in symbols:
        return symbols[m.group(1)] + int(m.group(2))
    m = re.match(r'^(\w+)\s*\+\s*\$([0-9A-Fa-f]+)$', operand)
    if m and m.group(1) in symbols:
        return symbols[m.group(1)] + int(m.group(2), 16)
    # Symbol-N
    m = re.match(r'^(\w+)\s*-\s*(\d+)$', operand)
    if m and m.group(1) in symbols:
        return symbols[m.group(1)] - int(m.group(2))
    return None


# ── Instruction size estimation ──

def estimate_instruction_size(mnemonic, operand, symbols):
    """Estimate the byte size of a 6502 instruction from its asm text."""
    operand = operand.strip()

    if mnemonic in BRANCHES:
        return 2
    if mnemonic == 'JSR':
        return 3
    if mnemonic == 'JMP':
        return 3
    if not operand:
        return 1
    if operand.startswith('#'):
        return 2
    if operand.startswith('('):
        if '),Y' in operand or '), Y' in operand:
            return 2
        if ',X)' in operand or ', X)' in operand:
            return 2
        return 3  # JMP ($xxxx)

    # Strip indexed suffix
    base = operand
    if ',X' in operand:
        base = operand.split(',')[0].strip()
    elif ',Y' in operand:
        base = operand.split(',')[0].strip()

    value = resolve_operand_value(base, symbols)
    if value is not None:
        return 2 if value < 0x100 else 3

    # Raw hex patterns
    if re.match(r'^\$[0-9A-Fa-f]{1,2}$', base):
        return 2
    if re.match(r'^\$[0-9A-Fa-f]{3,4}$', base):
        return 3

    # Heuristics for unresolved symbols
    if base.startswith('addr_') or base.startswith('sound_'):
        return 2
    if re.match(r'^[A-Z][A-Z_0-9]*$', base):
        return 3  # Hardware register
    if base.startswith('@'):
        return 2
    return 3  # Default: absolute


def extract_mnemonic_and_operand(line):
    """Extract mnemonic and operand from an instruction line."""
    m = re.match(r'^\s+([A-Z]{3})\s*(.*?)\s*$', line)
    if m:
        mnemonic = m.group(1)
        operand = m.group(2).strip()
        comment_pos = operand.find(';')
        if comment_pos >= 0:
            operand = operand[:comment_pos].strip()
        return mnemonic, operand
    return "", ""


# ── Line classifiers ──

INSTR_RE = re.compile(r'^(\s+)([A-Z]{3})\b')
ADDR_HINT_RE = re.compile(r';\s+\$([0-9A-Fa-f]{4})\s*:')
RANGE_HINT_RE = re.compile(r';\s+\$([0-9A-Fa-f]{4})-\$([0-9A-Fa-f]{4})\s*:')
BYTE_RE = re.compile(r'^\s+\.byte\b')
ADDR_DIR_RE = re.compile(r'^\s+\.addr\b')
WORD_RE = re.compile(r'^\s+\.word\b')
RES_RE = re.compile(r'^\s+\.res\b')
INCBIN_RE = re.compile(r'^\s+\.incbin\b')


def is_instruction(line):
    m = INSTR_RE.match(line)
    return bool(m and m.group(2) in MNEMONICS)


def is_section_header(line):
    """Check if a line is a section header comment (not an instruction annotation)."""
    # Section headers are comment-only lines starting with ';'
    # Instruction annotations are on lines with code before the ';'
    stripped = line.strip()
    return stripped.startswith(';') and not stripped.startswith(';;')


def parse_address_hint(line):
    """Extract ROM address offset from section header comments.

    Handles both '; $XXXX:' and '; $XXXX-$YYYY:' range formats.
    Only matches on comment-only lines (section headers), not instruction
    annotations which also contain '; $XXXX:'.

    Returns the offset from BASE_ADDR, or None.
    """
    # Only process section header lines (comments, not code lines)
    if not is_section_header(line):
        return None

    # Try range format first
    m = RANGE_HINT_RE.search(line)
    if m:
        addr = int(m.group(1), 16)
        offset = addr - BASE_ADDR
        if 0 <= offset < 8192:
            return offset
    # Try single address format
    m = ADDR_HINT_RE.search(line)
    if m:
        addr = int(m.group(1), 16)
        offset = addr - BASE_ADDR
        if 0 <= offset < 8192:
            return offset
    return None


def count_byte_values(line):
    m = re.match(r'\s+\.byte\s+(.*)', line)
    if not m:
        return 0
    values = m.group(1)
    cp = values.find(';')
    if cp >= 0:
        values = values[:cp]
    return len([p for p in values.split(',') if p.strip()])


def count_addr_values(line):
    m = re.match(r'\s+\.(addr|word)\s+(.*)', line)
    if not m:
        return 0
    values = m.group(2)
    cp = values.find(';')
    if cp >= 0:
        values = values[:cp]
    return len([p for p in values.split(',') if p.strip()])


def evaluate_res_size(line):
    m = re.match(r'\s+\.res\s+(.*?),', line)
    if not m:
        m = re.match(r'\s+\.res\s+(.*)', line)
        if not m:
            return 0
    expr = m.group(1).strip()
    m2 = re.match(r'\$([0-9A-Fa-f]+)\s*-\s*\$([0-9A-Fa-f]+)', expr)
    if m2:
        return int(m2.group(1), 16) - int(m2.group(2), 16)
    m3 = re.match(r'\$([0-9A-Fa-f]+)', expr)
    if m3:
        return int(m3.group(1), 16)
    m4 = re.match(r'(\d+)', expr)
    if m4:
        return int(m4.group(1))
    return 0


def parse_incbin_size(line):
    m = re.match(
        r'\s+\.incbin\s+"[^"]*"\s*,\s*\$([0-9A-Fa-f]+)\s*,\s*\$([0-9A-Fa-f]+)',
        line
    )
    if m:
        return int(m.group(2), 16)
    return 0


# ── Pre-disassembly ──

def predisassemble_binary(binary_data, base_addr):
    """Disassemble entire binary into instruction tuples.

    Returns:
        instructions: list of (address, mnemonic, size, bytes_list)
        addr_to_idx: dict mapping address -> index in instructions list
    """
    instructions = []
    addr_to_idx = {}
    offset = 0
    while offset < len(binary_data):
        addr = base_addr + offset
        idx = len(instructions)
        addr_to_idx[addr] = idx
        opcode = binary_data[offset]
        if opcode in OPCODES:
            mnemonic, size = OPCODES[opcode]
            end = min(offset + size, len(binary_data))
            bytes_list = list(binary_data[offset:end])
            instructions.append((addr, mnemonic, size, bytes_list))
            offset += size
        else:
            # Unknown/illegal opcode
            instructions.append((addr, '???', 1, [opcode]))
            offset += 1
    return instructions, addr_to_idx


# ── Annotation formatting ──

# Regex to strip existing annotation prefix from instruction comments
ANNOTATION_RE = re.compile(
    r'^\s+\$[0-9A-Fa-f]{4}'
    r'(?::\s*[0-9A-Fa-f]{2}(?:\s+[0-9A-Fa-f]{2})*)?'
    r'(?:\s{2}(.*))?$'
)


def strip_annotation(line):
    """Strip address/opcode annotation from an instruction line.

    Preserves any original comment that existed before annotation.
    Only processes instruction lines (detected by INSTR_RE).
    """
    if not is_instruction(line):
        return line

    comment_pos = line.find(';')
    if comment_pos < 0:
        return line

    code = line[:comment_pos].rstrip()
    comment = line[comment_pos + 1:]

    m = ANNOTATION_RE.match(comment)
    if m:
        existing = m.group(1)
        if existing and existing.strip():
            return f"{code}  ; {existing.strip()}"
        else:
            return code
    else:
        # Not an annotation comment, keep as-is
        return line


def annotate_line(line, addr_str, bytes_str):
    """Annotate an instruction line with address and opcode bytes."""
    comment_pos = line.find(';')
    if comment_pos >= 0:
        code = line[:comment_pos].rstrip()
        existing = line[comment_pos + 1:].lstrip()
        annotation = f"{addr_str}: {bytes_str}"
        if existing:
            return f"{code}  ; {annotation}  {existing}"
        else:
            return f"{code}  ; {annotation}"
    else:
        code = line.rstrip()
        return f"{code}  ; {addr_str}: {bytes_str}"


def annotate_line_addr_only(line, addr_str):
    """Add only the address comment (no opcode bytes) when no match found."""
    comment_pos = line.find(';')
    if comment_pos >= 0:
        code = line[:comment_pos].rstrip()
        existing = line[comment_pos + 1:].lstrip()
        if existing:
            return f"{code}  ; {addr_str}  {existing}"
        else:
            return f"{code}  ; {addr_str}"
    else:
        code = line.rstrip()
        return f"{code}  ; {addr_str}"


# ── Main ──

def main():
    project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    binary_path = os.path.join(project_dir, "rom/prg/prg_1f.bin")
    asm_path = os.path.join(project_dir, "asm/banks/prg_1f.asm")
    bak_path = asm_path + ".bak"
    include_dir = os.path.join(project_dir, "include")

    in_place = '--in-place' in sys.argv
    verify = '--verify' in sys.argv

    if in_place:
        output_path = asm_path
    else:
        output_path = os.path.join(project_dir, "asm/banks/prg_1f_annotated.asm")

    # 1. Read binary
    with open(binary_path, 'rb') as f:
        binary_data = f.read()
    assert len(binary_data) == 8192

    # 2. Pre-disassemble binary
    instructions, addr_to_idx = predisassemble_binary(binary_data, BASE_ADDR)
    print(f"Binary disassembled: {len(instructions)} instruction tuples")

    # 3. Build symbol table
    symbol_source = bak_path if os.path.isfile(bak_path) else asm_path
    symbols = build_symbol_table(symbol_source, [include_dir])
    print(f"Symbol table: {len(symbols)} entries")

    # 4. Read asm file - prefer .bak (un-annotated) as input
    input_path = bak_path if os.path.isfile(bak_path) else asm_path
    print(f"Input: {input_path}")
    with open(input_path) as f:
        asm_lines = f.readlines()

    # 5. Process lines with direct address-based lookup + section header resync
    #
    # Track current_addr through the ROM address space. For each asm
    # instruction, look up the binary at current_addr. If the mnemonic
    # matches, annotate with verified opcodes from the binary and advance
    # by the binary's instruction size. If it doesn't match (asm diverges
    # from ROM), annotate address-only and advance by the asm's estimated
    # size. Section headers resync current_addr exactly via addr_to_idx.
    #
    current_addr = BASE_ADDR
    annotated_lines = []
    warnings = []
    instruction_count = 0
    full_count = 0
    addr_only_count = 0
    resync_count = 0
    data_bytes_skipped = 0

    for line_num, raw_line in enumerate(asm_lines, 1):
        line = raw_line.rstrip('\n')

        # Strip any existing annotations from instruction lines
        line = strip_annotation(line)

        # ── Address hint resync (section headers only) ──
        hint_offset = parse_address_hint(line)
        if hint_offset is not None:
            hint_addr = BASE_ADDR + hint_offset
            if hint_addr in addr_to_idx:
                resync_count += 1
                current_addr = hint_addr
            else:
                # Address falls inside a multi-byte instruction;
                # find nearest instruction at or before hint_addr
                for search_addr in range(hint_addr, BASE_ADDR - 1, -1):
                    if search_addr in addr_to_idx:
                        resync_count += 1
                        current_addr = hint_addr
                        break

        # ── CPU instruction ──
        if is_instruction(line):
            mnemonic, operand = extract_mnemonic_and_operand(line)
            est_size = estimate_instruction_size(mnemonic, operand, symbols)

            matched = False
            if current_addr in addr_to_idx:
                idx = addr_to_idx[current_addr]
                # Try current binary instruction and the next few (forward search)
                # to handle cases where the ROM has 1-2 instructions the asm doesn't
                for skip in range(3):
                    check_idx = idx + skip
                    if check_idx >= len(instructions):
                        break
                    bin_addr, bin_mnemonic, bin_size, bin_bytes = instructions[check_idx]
                    if bin_mnemonic == mnemonic:
                        # Match — annotate with verified address + opcode bytes
                        bytes_str = " ".join(f"{b:02X}" for b in bin_bytes)
                        addr_str = f"${bin_addr:04X}"
                        annotated_lines.append(annotate_line(line, addr_str, bytes_str))
                        current_addr = bin_addr + bin_size
                        full_count += 1
                        matched = True
                        break

            if not matched:
                # Divergence — annotate address-only
                addr_str = f"${current_addr:04X}"
                annotated_lines.append(annotate_line_addr_only(line, addr_str))
                current_addr += est_size
                addr_only_count += 1

            instruction_count += 1

        # ── Data directives ──
        elif BYTE_RE.match(line):
            size = count_byte_values(line)
            current_addr += size
            data_bytes_skipped += size
            annotated_lines.append(line)
        elif ADDR_DIR_RE.match(line) or WORD_RE.match(line):
            count = count_addr_values(line)
            size = count * 2
            current_addr += size
            data_bytes_skipped += size
            annotated_lines.append(line)
        elif RES_RE.match(line):
            size = evaluate_res_size(line)
            current_addr += size
            data_bytes_skipped += size
            annotated_lines.append(line)
        elif INCBIN_RE.match(line):
            size = parse_incbin_size(line)
            current_addr += size
            data_bytes_skipped += size
            annotated_lines.append(line)
        else:
            annotated_lines.append(line)

    # 6. Validation
    expected_end = BASE_ADDR + len(binary_data)
    if current_addr != expected_end:
        warnings.append(
            f"Final addr ${current_addr:04X} != expected ${expected_end:04X} "
            f"(diff={expected_end - current_addr})"
        )

    # 7. Write output
    if in_place:
        # Backup current file before overwriting
        shutil.copy2(asm_path, bak_path)
        print(f"Backup written to {bak_path}")

    with open(output_path, 'w') as f:
        f.write('\n'.join(annotated_lines))
        if annotated_lines and annotated_lines[-1] != '':
            f.write('\n')

    print(f"Output written to {output_path}")
    print(f"Instructions annotated: {instruction_count}")
    print(f"  Full (addr + opcodes): {full_count} ({100*full_count//max(instruction_count,1)}%)")
    print(f"  Address-only:          {addr_only_count} ({100*addr_only_count//max(instruction_count,1)}%)")
    print(f"Data bytes skipped: {data_bytes_skipped}")
    print(f"Resync events: {resync_count}")
    print(f"Symbols: {len(symbols)}")
    print(f"Warnings: {len(warnings)}")
    for w in warnings[:30]:
        print(f"  {w}")
    if len(warnings) > 30:
        print(f"  ... and {len(warnings) - 30} more")

    # 8. Verification
    if verify:
        ca65_path = os.path.expanduser("~/.local/bin/ca65")
        obj_path = os.path.join(project_dir, "build/prg_1f_annotated.o")
        print(f"\nRunning ca65 verification...")
        result = subprocess.run(
            [ca65_path, "-I", include_dir, output_path, "-o", obj_path],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            print("ca65: Assembly succeeded")
        else:
            print(f"ca65: FAILED (rc={result.returncode})")
            print(result.stderr)
        if os.path.exists(obj_path):
            os.remove(obj_path)


if __name__ == "__main__":
    main()
