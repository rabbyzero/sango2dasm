#!/usr/bin/env python3
"""Complete 6502 disassembler for prg_1d.bin ($A000-$BFFF)."""
import sys

with open("/home/zero/project/sango2dasm/rom/prg/prg_1d.bin", "rb") as f:
    data = f.read()

BASE = 0xA000
SIZE = len(data)

# COMPLETE 6502 opcode table
OPCODE_TABLE = {
    # ADC
    0x69: ("ADC", "imm"), 0x65: ("ADC", "zp"), 0x75: ("ADC", "zpx"), 0x6D: ("ADC", "abs"),
    0x7D: ("ADC", "abx"), 0x79: ("ADC", "aby"), 0x61: ("ADC", "izx"), 0x71: ("ADC", "izy"),
    # AND
    0x29: ("AND", "imm"), 0x25: ("AND", "zp"), 0x35: ("AND", "zpx"), 0x2D: ("AND", "abs"),
    0x3D: ("AND", "abx"), 0x39: ("AND", "aby"), 0x21: ("AND", "izx"), 0x31: ("AND", "izy"),
    # ASL
    0x0A: ("ASL", "acc"), 0x06: ("ASL", "zp"), 0x16: ("ASL", "zpx"), 0x0E: ("ASL", "abs"), 0x1E: ("ASL", "abx"),
    # Branch
    0x90: ("BCC", "rel"), 0xB0: ("BCS", "rel"), 0xF0: ("BEQ", "rel"), 0xD0: ("BNE", "rel"),
    0x30: ("BMI", "rel"), 0x10: ("BPL", "rel"), 0x50: ("BVC", "rel"), 0x70: ("BVS", "rel"),
    # BIT
    0x24: ("BIT", "zp"), 0x2C: ("BIT", "abs"),
    # BRK
    0x00: ("BRK", "imp"),
    # CMP
    0xC9: ("CMP", "imm"), 0xC5: ("CMP", "zp"), 0xD5: ("CMP", "zpx"), 0xCD: ("CMP", "abs"),
    0xDD: ("CMP", "abx"), 0xD9: ("CMP", "aby"), 0xC1: ("CMP", "izx"), 0xD1: ("CMP", "izy"),
    # CPX, CPY
    0xE0: ("CPX", "imm"), 0xE4: ("CPX", "zp"), 0xEC: ("CPX", "abs"),
    0xC0: ("CPY", "imm"), 0xC4: ("CPY", "zp"), 0xCC: ("CPY", "abs"),
    # DEC
    0xC6: ("DEC", "zp"), 0xD6: ("DEC", "zpx"), 0xCE: ("DEC", "abs"), 0xDE: ("DEC", "abx"),
    # EOR
    0x49: ("EOR", "imm"), 0x45: ("EOR", "zp"), 0x55: ("EOR", "zpx"), 0x4D: ("EOR", "abs"),
    0x5D: ("EOR", "abx"), 0x59: ("EOR", "aby"), 0x41: ("EOR", "izx"), 0x51: ("EOR", "izy"),
    # Flags
    0x18: ("CLC", "imp"), 0x38: ("SEC", "imp"), 0x58: ("CLI", "imp"), 0x78: ("SEI", "imp"),
    0xB8: ("CLV", "imp"), 0xD8: ("CLD", "imp"), 0xF8: ("SED", "imp"),
    # INC
    0xE6: ("INC", "zp"), 0xF6: ("INC", "zpx"), 0xEE: ("INC", "abs"), 0xFE: ("INC", "abx"),
    # JMP, JSR
    0x4C: ("JMP", "abs"), 0x6C: ("JMP", "ind"), 0x20: ("JSR", "abs"),
    # LDA
    0xA9: ("LDA", "imm"), 0xA5: ("LDA", "zp"), 0xB5: ("LDA", "zpx"), 0xAD: ("LDA", "abs"),
    0xBD: ("LDA", "abx"), 0xB9: ("LDA", "aby"), 0xA1: ("LDA", "izx"), 0xB1: ("LDA", "izy"),
    # LDX
    0xA2: ("LDX", "imm"), 0xA6: ("LDX", "zp"), 0xB6: ("LDX", "zpy"), 0xAE: ("LDX", "abs"), 0xBE: ("LDX", "aby"),
    # LDY
    0xA0: ("LDY", "imm"), 0xA4: ("LDY", "zp"), 0xB4: ("LDY", "zpx"), 0xAC: ("LDY", "abs"), 0xBC: ("LDY", "abx"),
    # LSR
    0x4A: ("LSR", "acc"), 0x46: ("LSR", "zp"), 0x56: ("LSR", "zpx"), 0x4E: ("LSR", "abs"), 0x5E: ("LSR", "abx"),
    # NOP
    0xEA: ("NOP", "imp"),
    # ORA
    0x09: ("ORA", "imm"), 0x05: ("ORA", "zp"), 0x15: ("ORA", "zpx"), 0x0D: ("ORA", "abs"),
    0x1D: ("ORA", "abx"), 0x19: ("ORA", "aby"), 0x01: ("ORA", "izx"), 0x11: ("ORA", "izy"),
    # Stack
    0x48: ("PHA", "imp"), 0x68: ("PLA", "imp"), 0x08: ("PHP", "imp"), 0x28: ("PLP", "imp"),
    # ROL
    0x2A: ("ROL", "acc"), 0x26: ("ROL", "zp"), 0x36: ("ROL", "zpx"), 0x2E: ("ROL", "abs"), 0x3E: ("ROL", "abx"),
    # ROR
    0x6A: ("ROR", "acc"), 0x66: ("ROR", "zp"), 0x76: ("ROR", "zpx"), 0x6E: ("ROR", "abs"), 0x7E: ("ROR", "abx"),
    # RTI, RTS
    0x40: ("RTI", "imp"), 0x60: ("RTS", "imp"),
    # SBC
    0xE9: ("SBC", "imm"), 0xE5: ("SBC", "zp"), 0xF5: ("SBC", "zpx"), 0xED: ("SBC", "abs"),
    0xFD: ("SBC", "abx"), 0xF9: ("SBC", "aby"), 0xE1: ("SBC", "izx"), 0xF1: ("SBC", "izy"),
    # STA - ALL modes
    0x85: ("STA", "zp"), 0x95: ("STA", "zpx"), 0x8D: ("STA", "abs"), 0x9D: ("STA", "abx"),
    0x99: ("STA", "aby"), 0x81: ("STA", "izx"), 0x91: ("STA", "izy"),
    # STX, STY
    0x86: ("STX", "zp"), 0x96: ("STX", "zpy"), 0x8E: ("STX", "abs"),
    0x84: ("STY", "zp"), 0x94: ("STY", "zpx"), 0x8C: ("STY", "abs"),
    # Transfer
    0xAA: ("TAX", "imp"), 0x8A: ("TXA", "imp"), 0x9A: ("TXS", "imp"), 0xBA: ("TSX", "imp"),
    0xA8: ("TAY", "imp"), 0x98: ("TYA", "imp"),
    # Register inc/dec (MISSING before!)
    0xE8: ("INX", "imp"), 0xCA: ("DEX", "imp"), 0xC8: ("INY", "imp"), 0x88: ("DEY", "imp"),
}

SIZES = {'imp':1,'acc':1,'imm':2,'zp':2,'zpx':2,'zpy':2,'abs':3,'abx':3,'aby':3,'ind':3,'izx':2,'izy':2,'rel':2}

# Verify we have all 151 legal opcodes
assert len(OPCODE_TABLE) == 151, f"Expected 151 opcodes, got {len(OPCODE_TABLE)}"

B1F_NAMES = {
    0xE9BA: "B1F_MathBinToBcd",
    0xEADE: "B1F_CallbackDispatcher",
    0xEBE9: "B1F_MathMul24x8",
    0xEE07: "B1F_BankedCallbackTrampoline",
    0xF237: "B1F_SwitchBankAC_B",
    0xF24B: "B1F_SwitchBankAC_A",
    0xF25F: "B1F_SwitchBank8_B",
    0xF266: "B1F_SwitchBank8_A",
    0xF2AF: "B1F_GetProvinceRecordAddr",
    0xF2D7: "B1F_GetOfficerRecordAddr",
    0xF308: "B1F_GetNameDisplayScale",
}

# First pass: collect all branch/jump targets within bank
targets = set()
offset = 0
while offset < SIZE:
    addr = BASE + offset
    op = data[offset]
    if op in OPCODE_TABLE:
        mn, mode = OPCODE_TABLE[op]
        sz = SIZES[mode]
        if offset + sz > SIZE:
            offset += 1
            continue
        if mode == 'rel':
            b_off = data[offset+1]
            if b_off >= 0x80: b_off -= 256
            target = addr + 2 + b_off
            if BASE <= target < BASE + SIZE:
                targets.add(target)
        elif mode == 'abs' and mn in ('JMP', 'JSR'):
            target = data[offset+1] | (data[offset+2] << 8)
            if BASE <= target < BASE + SIZE:
                targets.add(target)
        offset += sz
    else:
        offset += 1

# Generate label names
label_map = {}
for t in sorted(targets):
    label_map[t] = f"Loc_{t:04X}"

# Second pass: linear disassembly
results = []  # (addr, label_or_none, instruction_text, byte_hex)
offset = 0
while offset < SIZE:
    addr = BASE + offset
    op = data[offset]
    
    has_label = addr in label_map
    
    if op not in OPCODE_TABLE:
        byte_hex = f"{op:02X}"
        results.append((addr, label_map.get(addr), f".byte ${op:02X}", byte_hex))
        offset += 1
        continue
    
    mn, mode = OPCODE_TABLE[op]
    sz = SIZES[mode]
    
    if offset + sz > SIZE:
        byte_hex = f"{op:02X}"
        results.append((addr, label_map.get(addr), f".byte ${op:02X}", byte_hex))
        offset += 1
        continue
    
    operand_bytes = data[offset+1:offset+sz]
    byte_hex = ' '.join(f'{data[offset+i]:02X}' for i in range(sz))
    
    if mode == 'imp':
        operand_text = ""
    elif mode == 'acc':
        operand_text = "A"
    elif mode == 'imm':
        operand_text = f"#{operand_bytes[0]:02X}"
    elif mode == 'zp':
        operand_text = f"${operand_bytes[0]:02X}"
    elif mode == 'zpx':
        operand_text = f"${operand_bytes[0]:02X},X"
    elif mode == 'zpy':
        operand_text = f"${operand_bytes[0]:02X},Y"
    elif mode == 'abs':
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        if mn == 'JSR':
            name = B1F_NAMES.get(val)
            operand_text = name if name else f"${val:04X}"
        elif mn == 'JMP':
            operand_text = label_map.get(val, f"${val:04X}")
        else:
            operand_text = f"${val:04X}"
    elif mode == 'abx':
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        operand_text = f"${val:04X},X"
    elif mode == 'aby':
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        operand_text = f"${val:04X},Y"
    elif mode == 'ind':
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        operand_text = f"(${val:04X})"
    elif mode == 'izx':
        operand_text = f"(${operand_bytes[0]:02X},X)"
    elif mode == 'izy':
        operand_text = f"(${operand_bytes[0]:02X}),Y"
    elif mode == 'rel':
        b_off = operand_bytes[0]
        if b_off >= 0x80: b_off -= 256
        target = addr + 2 + b_off
        operand_text = label_map.get(target, f"${target:04X}")
    else:
        operand_text = "???"
    
    instr = f"{mn} {operand_text}" if operand_text else mn
    results.append((addr, label_map.get(addr), instr, byte_hex))
    offset += sz

# Output
for addr, label, instr, byte_hex in results:
    if label:
        print(f"{label}:")
    # Pad instruction to 40 chars
    padded = f"  {instr}"
    print(f"{padded:<42s}; ${addr:04X}: {byte_hex}")
