#!/usr/bin/env python3
"""
Complete disassembly of prg_1d.bin ($A000-$BFFF).
Produces ca65-compatible assembly with proper code/data identification.
"""
import sys

with open("/home/zero/project/sango2dasm/rom/prg/prg_1d.bin", "rb") as f:
    data = f.read()

BASE = 0xA000
SIZE = len(data)

OPCODE_TABLE = {
    0x69: ("ADC", "imm"), 0x65: ("ADC", "zp"), 0x75: ("ADC", "zpx"), 0x6D: ("ADC", "abs"),
    0x7D: ("ADC", "abx"), 0x79: ("ADC", "aby"), 0x61: ("ADC", "izx"), 0x71: ("ADC", "izy"),
    0x29: ("AND", "imm"), 0x25: ("AND", "zp"), 0x35: ("AND", "zpx"), 0x2D: ("AND", "abs"),
    0x3D: ("AND", "abx"), 0x39: ("AND", "aby"), 0x21: ("AND", "izx"), 0x31: ("AND", "izy"),
    0x0A: ("ASL", "acc"), 0x06: ("ASL", "zp"), 0x16: ("ASL", "zpx"), 0x0E: ("ASL", "abs"), 0x1E: ("ASL", "abx"),
    0x90: ("BCC", "rel"), 0xB0: ("BCS", "rel"), 0xF0: ("BEQ", "rel"), 0xD0: ("BNE", "rel"),
    0x30: ("BMI", "rel"), 0x10: ("BPL", "rel"), 0x50: ("BVC", "rel"), 0x70: ("BVS", "rel"),
    0x24: ("BIT", "zp"), 0x2C: ("BIT", "abs"), 0x00: ("BRK", "imp"),
    0xC9: ("CMP", "imm"), 0xC5: ("CMP", "zp"), 0xD5: ("CMP", "zpx"), 0xCD: ("CMP", "abs"),
    0xDD: ("CMP", "abx"), 0xD9: ("CMP", "aby"), 0xC1: ("CMP", "izx"), 0xD1: ("CMP", "izy"),
    0xE0: ("CPX", "imm"), 0xE4: ("CPX", "zp"), 0xEC: ("CPX", "abs"),
    0xC0: ("CPY", "imm"), 0xC4: ("CPY", "zp"), 0xCC: ("CPY", "abs"),
    0xC6: ("DEC", "zp"), 0xD6: ("DEC", "zpx"), 0xCE: ("DEC", "abs"), 0xDE: ("DEC", "abx"),
    0x49: ("EOR", "imm"), 0x45: ("EOR", "zp"), 0x55: ("EOR", "zpx"), 0x4D: ("EOR", "abs"),
    0x5D: ("EOR", "abx"), 0x59: ("EOR", "aby"), 0x41: ("EOR", "izx"), 0x51: ("EOR", "izy"),
    0x18: ("CLC", "imp"), 0x38: ("SEC", "imp"), 0x58: ("CLI", "imp"), 0x78: ("SEI", "imp"),
    0xB8: ("CLV", "imp"), 0xD8: ("CLD", "imp"), 0xF8: ("SED", "imp"),
    0xE6: ("INC", "zp"), 0xF6: ("INC", "zpx"), 0xEE: ("INC", "abs"), 0xFE: ("INC", "abx"),
    0x4C: ("JMP", "abs"), 0x6C: ("JMP", "ind"), 0x20: ("JSR", "abs"),
    0xA9: ("LDA", "imm"), 0xA5: ("LDA", "zp"), 0xB5: ("LDA", "zpx"), 0xAD: ("LDA", "abs"),
    0xBD: ("LDA", "abx"), 0xB9: ("LDA", "aby"), 0xA1: ("LDA", "izx"), 0xB1: ("LDA", "izy"),
    0xA2: ("LDX", "imm"), 0xA6: ("LDX", "zp"), 0xB6: ("LDX", "zpy"), 0xAE: ("LDX", "abs"), 0xBE: ("LDX", "aby"),
    0xA0: ("LDY", "imm"), 0xA4: ("LDY", "zp"), 0xB4: ("LDY", "zpx"), 0xAC: ("LDY", "abs"), 0xBC: ("LDY", "abx"),
    0x4A: ("LSR", "acc"), 0x46: ("LSR", "zp"), 0x56: ("LSR", "zpx"), 0x4E: ("LSR", "abs"), 0x5E: ("LSR", "abx"),
    0xEA: ("NOP", "imp"),
    0x09: ("ORA", "imm"), 0x05: ("ORA", "zp"), 0x15: ("ORA", "zpx"), 0x0D: ("ORA", "abs"),
    0x1D: ("ORA", "abx"), 0x19: ("ORA", "aby"), 0x01: ("ORA", "izx"), 0x11: ("ORA", "izy"),
    0x48: ("PHA", "imp"), 0x68: ("PLA", "imp"), 0x08: ("PHP", "imp"), 0x28: ("PLP", "imp"),
    0x2A: ("ROL", "acc"), 0x26: ("ROL", "zp"), 0x36: ("ROL", "zpx"), 0x2E: ("ROL", "abs"), 0x3E: ("ROL", "abx"),
    0x6A: ("ROR", "acc"), 0x66: ("ROR", "zp"), 0x76: ("ROR", "zpx"), 0x6E: ("ROR", "abs"), 0x7E: ("ROR", "abx"),
    0x40: ("RTI", "imp"), 0x60: ("RTS", "imp"),
    0xE9: ("SBC", "imm"), 0xE5: ("SBC", "zp"), 0xF5: ("SBC", "zpx"), 0xED: ("SBC", "abs"),
    0xFD: ("SBC", "abx"), 0xF9: ("SBC", "aby"), 0xE1: ("SBC", "izx"), 0xF1: ("SBC", "izy"),
    0x85: ("STA", "zp"), 0x95: ("STA", "zpx"), 0x8D: ("STA", "abs"), 0x9D: ("STA", "abx"),
    0x99: ("STA", "aby"), 0x81: ("STA", "izx"), 0x91: ("STA", "izy"),
    0x86: ("STX", "zp"), 0x96: ("STX", "zpy"), 0x8E: ("STX", "abs"),
    0x84: ("STY", "zp"), 0x94: ("STY", "zpx"), 0x8C: ("STY", "abs"),
    0xAA: ("TAX", "imp"), 0x8A: ("TXA", "imp"), 0x9A: ("TXS", "imp"), 0xBA: ("TSX", "imp"),
    0xA8: ("TAY", "imp"), 0x98: ("TYA", "imp"),
    0xE8: ("INX", "imp"), 0xCA: ("DEX", "imp"), 0xC8: ("INY", "imp"), 0x88: ("DEY", "imp"),
}
SIZES = {'imp':1,'acc':1,'imm':2,'zp':2,'zpx':2,'zpy':2,'abs':3,'abx':3,'aby':3,'ind':3,'izx':2,'izy':2,'rel':2}

B1F_NAMES = {
    0xE9BA: "B1F_MathBinToBcd", 0xEADE: "B1F_CallbackDispatcher",
    0xEBE9: "B1F_MathMul24x8", 0xEE07: "B1F_BankedCallbackTrampoline",
    0xF237: "B1F_SwitchBankAC_B", 0xF24B: "B1F_SwitchBankAC_A",
    0xF25F: "B1F_SwitchBank8_B", 0xF266: "B1F_SwitchBank8_A",
    0xF2AF: "B1F_GetProvinceRecordAddr", 0xF2D7: "B1F_GetOfficerRecordAddr",
    0xF308: "B1F_GetNameDisplayScale",
}

# Data regions (offset, end_offset_exclusive, label)
DATA_REGIONS = [
    (0x0209, 0x0248, "CallbackData_Entry01"),
    (0x0607, 0x060F, "OffsetTable_0607"),
    (0x0672, 0x0690, "OffsetWordTable_0672"),
    (0x06A7, 0x06B6, "BankSelectTable_06A7"),
    (0x0D81, 0x0D92, "PointerTable_AD81"),
    (0x1222, 0x123D, "DataTable_B222"),
    (0x1305, 0x1989, "TileMapData_B305"),
]

def is_data(offset):
    for s, e, _ in DATA_REGIONS:
        if s <= offset < e:
            return True
    return False

def get_data_label(offset):
    for s, e, name in DATA_REGIONS:
        if offset == s:
            return name
    return None

# First pass: collect code targets
targets = set()
offset = 0
while offset < SIZE:
    if is_data(offset):
        offset += 1
        continue
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
            if BASE <= target < BASE + SIZE and not is_data(target - BASE):
                targets.add(target)
        elif mode == 'abs' and mn in ('JMP', 'JSR'):
            target = data[offset+1] | (data[offset+2] << 8)
            if BASE <= target < BASE + SIZE and not is_data(target - BASE):
                targets.add(target)
        offset += sz
    else:
        offset += 1

label_map = {t: f"Loc_{t:04X}" for t in sorted(targets)}

# Second pass: generate output
lines = []

def emit(label, instr, addr, byte_hex):
    lines.append((label, instr, addr, byte_hex))

offset = 0
while offset < SIZE:
    addr = BASE + offset
    label = label_map.get(addr)
    dl = get_data_label(offset)
    
    if dl:
        if label:
            emit(label, None, None, None)
        emit(None, f"; --- Data Region: {dl} ---", None, None)
    
    if is_data(offset):
        start = offset
        while offset < SIZE and is_data(offset):
            offset += 1
        for i in range(start, offset, 16):
            chunk = data[i:min(i+16, offset)]
            hex_bytes = ','.join(f'${b:02X}' for b in chunk)
            raw_hex = ' '.join(f'{b:02X}' for b in chunk)
            a = BASE + i
            emit(None, f".byte {hex_bytes}", a, raw_hex)
        continue
    
    op = data[offset]
    if op not in OPCODE_TABLE:
        emit(label, f".byte ${op:02X}", addr, f"{op:02X}")
        offset += 1
        continue
    
    mn, mode = OPCODE_TABLE[op]
    sz = SIZES[mode]
    if offset + sz > SIZE:
        emit(label, f".byte ${op:02X}", addr, f"{op:02X}")
        offset += 1
        continue
    
    ob = data[offset+1:offset+sz]
    byte_hex = ' '.join(f'{data[offset+i]:02X}' for i in range(sz))
    
    if mode == 'imp': ot = ""
    elif mode == 'acc': ot = "A"
    elif mode == 'imm': ot = f"#{ob[0]:02X}"
    elif mode == 'zp': ot = f"${ob[0]:02X}"
    elif mode == 'zpx': ot = f"${ob[0]:02X},X"
    elif mode == 'zpy': ot = f"${ob[0]:02X},Y"
    elif mode == 'abs':
        val = ob[0] | (ob[1] << 8)
        if mn == 'JSR':
            ot = B1F_NAMES.get(val, f"${val:04X}")
        elif mn == 'JMP':
            ot = label_map.get(val, f"${val:04X}")
        else:
            ot = f"${val:04X}"
    elif mode == 'abx': ot = f"${(ob[0] | (ob[1] << 8)):04X},X"
    elif mode == 'aby': ot = f"${(ob[0] | (ob[1] << 8)):04X},Y"
    elif mode == 'ind': ot = f"(${(ob[0] | (ob[1] << 8)):04X})"
    elif mode == 'izx': ot = f"(${ob[0]:02X},X)"
    elif mode == 'izy': ot = f"(${ob[0]:02X}),Y"
    elif mode == 'rel':
        b_off = ob[0]
        if b_off >= 0x80: b_off -= 256
        target = addr + 2 + b_off
        ot = label_map.get(target, f"${target:04X}")
    else: ot = "???"
    
    instr = f"{mn} {ot}" if ot else mn
    emit(label, instr, addr, byte_hex)
    offset += sz

# Write output
for label, instr, addr, byte_hex in lines:
    if label:
        print(f"{label}:")
    if instr is None:
        continue
    if instr.startswith(";"):
        print(instr)
        continue
    if addr is not None:
        padded = f"  {instr}"
        print(f"{padded:<42s}; ${addr:04X}: {byte_hex}")
    else:
        print(instr)
