#!/usr/bin/env python3
"""
Disassemble 6502 binary to ca65 assembly format.
Basic disassembler for initial code analysis.
"""

import sys
import os

# 6502 Opcode table (mode, mnemonic, bytes, cycles)
OPCODES = {
    0x00: ("imp", "BRK", 1, 7),
    0x01: ("izx", "ORA", 2, 6),
    0x05: ("zp",  "ORA", 2, 3),
    0x06: ("zp",  "ASL", 2, 5),
    0x08: ("imp", "PHP", 1, 3),
    0x09: ("imm", "ORA", 2, 2),
    0x0A: ("acc", "ASL", 1, 2),
    0x0D: ("abs", "ORA", 3, 4),
    0x0E: ("abs", "ASL", 3, 6),
    0x10: ("rel", "BPL", 2, 2),
    0x11: ("izy", "ORA", 2, 5),
    0x15: ("zpx", "ORA", 2, 4),
    0x16: ("zpx", "ASL", 2, 6),
    0x18: ("imp", "CLC", 1, 2),
    0x19: ("aby", "ORA", 3, 4),
    0x1D: ("abx", "ORA", 3, 4),
    0x1E: ("abx", "ASL", 3, 7),
    0x20: ("abs", "JSR", 3, 6),
    0x24: ("zp",  "BIT", 2, 3),
    0x28: ("imp", "PLP", 1, 4),
    0x29: ("imm", "AND", 2, 2),
    0x2A: ("acc", "ROL", 1, 2),
    0x2C: ("abs", "BIT", 3, 4),
    0x30: ("rel", "BMI", 2, 2),
    0x38: ("imp", "SEC", 1, 2),
    0x3A: ("imp", "NOP", 1, 2),  # 65C02
    0x40: ("imp", "RTI", 1, 6),
    0x48: ("imp", "PHA", 1, 3),
    0x49: ("imm", "EOR", 2, 2),
    0x4A: ("acc", "LSR", 1, 2),
    0x4C: ("abs", "JMP", 3, 3),
    0x50: ("rel", "BVC", 2, 2),
    0x58: ("imp", "CLI", 1, 2),
    0x60: ("imp", "RTS", 1, 6),
    0x68: ("imp", "PLA", 1, 4),
    0x69: ("imm", "ADC", 2, 2),
    0x6A: ("acc", "ROR", 1, 2),
    0x70: ("rel", "BVS", 2, 2),
    0x78: ("imp", "SEI", 1, 2),
    0x81: ("izx", "STA", 2, 6),
    0x84: ("zp",  "STY", 2, 3),
    0x85: ("zp",  "STA", 2, 3),
    0x86: ("zp",  "STX", 2, 3),
    0x88: ("imp", "DEY", 1, 2),
    0x8A: ("imp", "TXA", 1, 2),
    0x90: ("rel", "BCC", 2, 2),
    0x98: ("imp", "TYA", 1, 2),
    0x99: ("aby", "STA", 3, 5),
    0xA0: ("imm", "LDY", 2, 2),
    0xA1: ("izx", "LDA", 2, 6),
    0xA2: ("imm", "LDX", 2, 2),
    0xA4: ("zp",  "LDY", 2, 3),
    0xA5: ("zp",  "LDA", 2, 3),
    0xA6: ("zp",  "LDX", 2, 3),
    0xA8: ("imp", "TAY", 1, 2),
    0xA9: ("imm", "LDA", 2, 2),
    0xAA: ("imp", "TAX", 1, 2),
    0xB0: ("rel", "BCS", 2, 2),
    0xB8: ("imp", "CLV", 1, 2),
    0xBA: ("imp", "TSX", 1, 2),
    0xC0: ("imm", "CPY", 2, 2),
    0xC4: ("zp",  "CPY", 2, 3),
    0xC6: ("zp",  "DEC", 2, 5),
    0xC8: ("imp", "INY", 1, 2),
    0xC9: ("imm", "CMP", 2, 2),
    0xCA: ("imp", "DEX", 1, 2),
    0xD0: ("rel", "BNE", 2, 2),
    0xD6: ("zpx", "DEC", 2, 6),
    0xE0: ("imm", "CPX", 2, 2),
    0xE4: ("zp",  "CPX", 2, 3),
    0xE6: ("zp",  "INC", 2, 5),
    0xE8: ("imp", "INX", 1, 2),
    0xEA: ("imp", "NOP", 1, 2),
    0xF0: ("rel", "BEQ", 2, 2),
    0xF6: ("zpx", "INC", 2, 6),
}

# Fill in missing opcodes
OPCODE_TABLE = [None] * 256
for code, (mode, mnemonic, bytes, cycles) in OPCODES.items():
    OPCODE_TABLE[code] = (mode, mnemonic, bytes, cycles)

# Add missing common opcodes
missing = {
    0x04: ("zp", "NOP", 2, 3),  # 65C02
    0x0C: ("abs", "NOP", 3, 4), # 65C02
    0x0F: ("abs", "ORA", 3, 4), # undoc
    0x12: ("izy", "ORA", 2, 5), # 65C02
    0x14: ("zpx", "NOP", 2, 4), # 65C02
    0x1A: ("acc", "NOP", 1, 2), # 65C02
    0x1F: ("abx", "ORA", 3, 4), # undoc
    0x21: ("izx", "AND", 2, 6),
    0x22: ("abs", "JAM", 1, 0), # KIL
    0x25: ("zp", "AND", 2, 3),
    0x26: ("zp", "ROL", 2, 5),
    0x2E: ("abs", "ROL", 3, 6),
    0x31: ("izy", "AND", 2, 5),
    0x34: ("zpx", "NOP", 2, 4), # 65C02
    0x35: ("zpx", "AND", 2, 4),
    0x36: ("zpx", "ROL", 2, 6),
    0x39: ("aby", "AND", 3, 4),
    0x3C: ("abx", "NOP", 3, 4), # 65C02
    0x3D: ("abx", "AND", 3, 4),
    0x3E: ("abx", "ROL", 3, 7),
    0x40: ("imp", "RTI", 1, 6),
    0x41: ("izx", "EOR", 2, 6),
    0x44: ("zp", "NOP", 2, 3),  # 65C02
    0x45: ("zp", "EOR", 2, 3),
    0x46: ("zp", "LSR", 2, 5),
    0x4E: ("abs", "LSR", 3, 6),
    0x51: ("izy", "EOR", 2, 5),
    0x52: ("izy", "EOR", 2, 5), # 65C02
    0x54: ("zpx", "NOP", 2, 4), # 65C02
    0x55: ("zpx", "EOR", 2, 4),
    0x56: ("zpx", "LSR", 2, 6),
    0x59: ("aby", "EOR", 3, 4),
    0x5C: ("abx", "NOP", 3, 4), # 65C02
    0x5D: ("abx", "EOR", 3, 4),
    0x5E: ("abx", "LSR", 3, 7),
    0x61: ("izx", "ADC", 2, 6),
    0x64: ("zp", "NOP", 2, 3),  # 65C02
    0x65: ("zp", "ADC", 2, 3),
    0x66: ("zp", "ROR", 2, 5),
    0x6C: ("ind", "JMP", 3, 5),
    0x6D: ("abs", "ADC", 3, 4),
    0x6E: ("abs", "ROR", 3, 6),
    0x71: ("izy", "ADC", 2, 5),
    0x72: ("izy", "ADC", 2, 5), # 65C02
    0x74: ("zpx", "NOP", 2, 4), # 65C02
    0x75: ("zpx", "ADC", 2, 4),
    0x76: ("zpx", "ROR", 2, 6),
    0x79: ("aby", "ADC", 3, 4),
    0x7C: ("abx", "NOP", 3, 4), # 65C02
    0x7D: ("abx", "ADC", 3, 4),
    0x7E: ("abx", "ROR", 3, 7),
    0x80: ("imm", "NOP", 2, 2), # 65C02
    0x82: ("imm", "NOP", 2, 2), # undoc
    0x87: ("zp", "SAX", 2, 3),  # undoc
    0x89: ("imm", "NOP", 2, 2), # 65C02
    0x8C: ("abs", "STY", 3, 4),
    0x8D: ("abs", "STA", 3, 4),
    0x8E: ("abs", "STX", 3, 4),
    0x91: ("izy", "STA", 2, 6),
    0x92: ("izy", "STA", 2, 5), # 65C02
    0x93: ("aby", "SAX", 3, 5), # undoc
    0x94: ("zpx", "STY", 2, 4),
    0x95: ("zpx", "STA", 2, 4),
    0x96: ("zpy", "STX", 2, 4),
    0x97: ("zpy", "SAX", 2, 4), # undoc
    0x9A: ("imp", "TXS", 1, 2),
    0x9B: ("aby", "SAX", 3, 5), # undoc
    0x9C: ("abx", "STY", 3, 5), # undoc
    0x9D: ("abx", "STA", 3, 5),
    0x9E: ("abx", "STX", 3, 5), # undoc
    0x9F: ("aby", "SAX", 3, 5), # undoc
    0xA3: ("izx", "LAX", 2, 6), # undoc
    0xA7: ("zp", "LAX", 2, 3),  # undoc
    0xAB: ("imm", "LAX", 2, 2), # undoc
    0xAC: ("abs", "LDY", 3, 4),
    0xAD: ("abs", "LDA", 3, 4),
    0xAE: ("abs", "LDX", 3, 4),
    0xAF: ("abs", "LAX", 3, 4), # undoc
    0xB1: ("izy", "LDA", 2, 5),
    0xB2: ("izy", "LDA", 2, 5), # 65C02
    0xB3: ("izy", "LAX", 2, 5), # undoc
    0xB4: ("zpx", "LDY", 2, 4),
    0xB5: ("zpx", "LDA", 2, 4),
    0xB6: ("zpy", "LDX", 2, 4),
    0xB7: ("zpy", "LAX", 2, 4), # undoc
    0xB9: ("aby", "LDA", 3, 4),
    0xBB: ("aby", "LAS", 3, 4), # undoc
    0xBC: ("abx", "LDY", 3, 4),
    0xBD: ("abx", "LDA", 3, 4),
    0xBE: ("aby", "LDX", 3, 4),
    0xBF: ("aby", "LAX", 3, 4), # undoc
    0xC1: ("izx", "CMP", 2, 6),
    0xC2: ("imm", "NOP", 2, 2), # undoc
    0xC5: ("zp", "CMP", 2, 3),
    0xC7: ("zp", "DCP", 2, 5),  # undoc
    0xC8: ("imp", "INY", 1, 2),
    0xCB: ("imm", "SAX", 2, 2), # undoc
    0xCC: ("abs", "CPY", 3, 4),
    0xCD: ("abs", "CMP", 3, 4),
    0xCE: ("abs", "DEC", 3, 6),
    0xCF: ("abs", "DCP", 3, 6), # undoc
    0xD1: ("izy", "CMP", 2, 5),
    0xD2: ("izy", "CMP", 2, 5), # 65C02
    0xD4: ("zpx", "NOP", 2, 4), # 65C02
    0xD5: ("zpx", "CMP", 2, 4),
    0xD7: ("zpx", "DCP", 2, 6), # undoc
    0xD8: ("imp", "CLD", 1, 2),
    0xD9: ("aby", "CMP", 3, 4),
    0xDA: ("imp", "NOP", 1, 2), # 65C02
    0xDC: ("abx", "NOP", 3, 4), # 65C02
    0xDD: ("abx", "CMP", 3, 4),
    0xDE: ("abx", "DEC", 3, 7),
    0xDF: ("abx", "DCP", 3, 7), # undoc
    0xE1: ("izx", "SBC", 2, 6),
    0xE2: ("imm", "NOP", 2, 2), # undoc
    0xE3: ("izx", "ISB", 2, 6), # undoc
    0xE5: ("zp", "SBC", 2, 3),
    0xE7: ("zp", "ISB", 2, 5),  # undoc
    0xE9: ("imm", "SBC", 2, 2),
    0xEB: ("imm", "SBC", 2, 2), # undoc
    0xEC: ("abs", "CPX", 3, 4),
    0xED: ("abs", "SBC", 3, 4),
    0xEE: ("abs", "INC", 3, 6),
    0xEF: ("abs", "ISB", 3, 6), # undoc
    0xF1: ("izy", "SBC", 2, 5),
    0xF2: ("izy", "SBC", 2, 5), # 65C02
    0xF3: ("izy", "ISB", 2, 5), # undoc
    0xF4: ("zpx", "NOP", 2, 4), # 65C02
    0xF5: ("zpx", "SBC", 2, 4),
    0xF7: ("zpx", "ISB", 2, 6), # undoc
    0xF8: ("imp", "SED", 1, 2),
    0xF9: ("aby", "SBC", 3, 4),
    0xFA: ("imp", "NOP", 1, 2), # 65C02
    0xFB: ("imp", "ISB", 1, 2), # undoc
    0xFC: ("abx", "NOP", 3, 4), # 65C02
    0xFD: ("abx", "SBC", 3, 4),
    0xFE: ("abx", "INC", 3, 7),
    0xFF: ("abx", "ISB", 3, 7), # undoc
}

for code, (mode, mnemonic, bytes, cycles) in missing.items():
    OPCODE_TABLE[code] = (mode, mnemonic, bytes, cycles)

def format_operand(opcode, mode, data, addr):
    """Format the operand based on addressing mode."""
    if mode == "imp" or mode == "acc":
        return ""
    elif mode == "imm":
        if len(data) < 1: return ""
        return f"#${data[0]:02X}"
    elif mode == "zp":
        if len(data) < 1: return ""
        return f"${data[0]:02X}"
    elif mode == "zpx":
        if len(data) < 1: return ""
        return f"${data[0]:02X},X"
    elif mode == "zpy":
        if len(data) < 1: return ""
        return f"${data[0]:02X},Y"
    elif mode == "abs":
        if len(data) < 2: return ""
        val = data[0] | (data[1] << 8)
        return f"${val:04X}"
    elif mode == "abx":
        if len(data) < 2: return ""
        val = data[0] | (data[1] << 8)
        return f"${val:04X},X"
    elif mode == "aby":
        if len(data) < 2: return ""
        val = data[0] | (data[1] << 8)
        return f"${val:04X},Y"
    elif mode == "ind":
        if len(data) < 2: return ""
        val = data[0] | (data[1] << 8)
        return f"(${val:04X})"
    elif mode == "izx":
        if len(data) < 1: return ""
        return f"(${data[0]:02X},X)"
    elif mode == "izy":
        if len(data) < 1: return ""
        return f"(${data[0]:02X}),Y"
    elif mode == "rel":
        if len(data) < 1: return ""
        offset = data[0]
        if offset > 127:
            offset -= 256
        target = addr + 2 + offset
        return f"${target:04X}"
    return ""

def disassemble(data, start_addr=0x8000, length=None, base_addr=None):
    """Disassemble 6502 binary data.

    start_addr: CPU address to begin disassembly at (display address)
    base_addr: CPU address where the binary data starts in memory.
               Used to map CPU addresses to file offsets.
               Defaults to start_addr (old behavior).
    """
    if length is None:
        length = len(data)
    if base_addr is None:
        base_addr = start_addr

    addr = start_addr
    end = start_addr + length
    lines = []

    while addr < end:
        offset = addr - base_addr
        if offset >= len(data):
            break

        opcode = data[offset]
        entry = OPCODE_TABLE[opcode]

        if entry is None:
            lines.append(f"${addr:04X}:  {opcode:02X}        .byte ${opcode:02X}")
            addr += 1
            continue

        mode, mnemonic, num_bytes, cycles = entry
        raw_bytes = data[offset:offset + num_bytes]

        if len(raw_bytes) < num_bytes:
            # Truncated instruction
            lines.append(f"${addr:04X}:  {' '.join(f'{b:02X}' for b in raw_bytes):<10} .byte ${raw_bytes[0]:02X} ; truncated")
            addr += len(raw_bytes)
            continue

        operand = format_operand(opcode, mode, raw_bytes[1:], addr)
        instr = f"{mnemonic} {operand}".strip()

        # Format: $ADDR:  BYTES       MNEMONIC
        byte_str = ' '.join(f'{b:02X}' for b in raw_bytes)
        lines.append(f"${addr:04X}:  {byte_str:<10} {instr}")

        addr += num_bytes

    return lines

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <binary.bin> [start_addr] [length] [base_addr]")
        print(f"  start_addr: hex CPU address to begin disassembly (default: 8000)")
        print(f"  length: number of bytes to disassemble (default: all)")
        print(f"  base_addr: hex CPU address where file starts in memory (default: start_addr)")
        print(f"  Example: disasm bank_1f.bin E87A 20 E000")
        sys.exit(1)

    filepath = sys.argv[1]
    start_addr = int(sys.argv[2], 16) if len(sys.argv) > 2 else 0x8000
    length = int(sys.argv[3], 16) if len(sys.argv) > 3 else None
    base_addr = int(sys.argv[4], 16) if len(sys.argv) > 4 else None

    with open(filepath, 'rb') as f:
        data = f.read()

    if length is None:
        length = len(data)

    lines = disassemble(data, start_addr, length, base_addr)

    for line in lines:
        print(line)

if __name__ == '__main__':
    main()
