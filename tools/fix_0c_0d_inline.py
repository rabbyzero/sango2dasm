#!/usr/bin/env python3
"""Fix inline data following BankedCallbackTrampoline and CallbackDispatcher in prg_0c_0d.asm.

BankedCallbackTrampoline ($EE07): always 1 .word target after JSR (2 bytes).
CallbackDispatcher ($EADE): variable-length .word table after JSR.
"""
import struct
import re
import sys

BASE = 0xA000

def read_word(data, offset):
    if 0 <= offset and offset + 1 < len(data):
        return struct.unpack_from("<H", data, offset)[0]
    return None

# Minimal 6502 opcode table: opcode -> (mnemonic, mode, length)
OPCODES = {
    0x00: ("BRK", "imp", 1), 0x01: ("ORA", "izx", 2), 0x05: ("ORA", "zp", 2),
    0x06: ("ASL", "zp", 2), 0x08: ("PHP", "imp", 1), 0x09: ("ORA", "imm", 2),
    0x0A: ("ASL", "acc", 1), 0x0D: ("ORA", "abs", 3), 0x0E: ("ASL", "abs", 3),
    0x10: ("BPL", "rel", 2), 0x11: ("ORA", "izy", 2), 0x15: ("ORA", "zpx", 2),
    0x16: ("ASL", "zpx", 2), 0x18: ("CLC", "imp", 1), 0x19: ("ORA", "aby", 3),
    0x1D: ("ORA", "abx", 3), 0x1E: ("ASL", "abx", 3),
    0x20: ("JSR", "abs", 3), 0x21: ("AND", "izx", 2), 0x24: ("BIT", "zp", 2),
    0x25: ("AND", "zp", 2), 0x26: ("ROL", "zp", 2), 0x28: ("PLP", "imp", 1),
    0x29: ("AND", "imm", 2), 0x2A: ("ROL", "acc", 1), 0x2C: ("BIT", "abs", 3),
    0x2D: ("AND", "abs", 3), 0x2E: ("ROL", "abs", 3),
    0x30: ("BMI", "rel", 2), 0x31: ("AND", "izy", 2), 0x35: ("AND", "zpx", 2),
    0x36: ("ROL", "zpx", 2), 0x38: ("SEC", "imp", 1), 0x39: ("AND", "aby", 3),
    0x3D: ("AND", "abx", 3), 0x3E: ("ROL", "abx", 3),
    0x40: ("RTI", "imp", 1), 0x41: ("EOR", "izx", 2), 0x45: ("EOR", "zp", 2),
    0x46: ("LSR", "zp", 2), 0x48: ("PHA", "imp", 1), 0x49: ("EOR", "imm", 2),
    0x4A: ("LSR", "acc", 1), 0x4C: ("JMP", "abs", 3), 0x4D: ("EOR", "abs", 3),
    0x4E: ("LSR", "abs", 3),
    0x50: ("BVC", "rel", 2), 0x51: ("EOR", "izy", 2), 0x55: ("EOR", "zpx", 2),
    0x56: ("LSR", "zpx", 2), 0x58: ("CLI", "imp", 1), 0x59: ("EOR", "aby", 3),
    0x5D: ("EOR", "abx", 3), 0x5E: ("LSR", "abx", 3),
    0x60: ("RTS", "imp", 1), 0x61: ("ADC", "izx", 2), 0x65: ("ADC", "zp", 2),
    0x66: ("ROR", "zp", 2), 0x68: ("PLA", "imp", 1), 0x69: ("ADC", "imm", 2),
    0x6A: ("ROR", "acc", 1), 0x6C: ("JMP", "ind", 3), 0x6D: ("ADC", "abs", 3),
    0x6E: ("ROR", "abs", 3),
    0x70: ("BVS", "rel", 2), 0x71: ("ADC", "izy", 2), 0x75: ("ADC", "zpx", 2),
    0x76: ("ROR", "zpx", 2), 0x78: ("SEI", "imp", 1), 0x79: ("ADC", "aby", 3),
    0x7D: ("ADC", "abx", 3), 0x7E: ("ROR", "abx", 3),
    0x81: ("STA", "izx", 2), 0x84: ("STY", "zp", 2), 0x85: ("STA", "zp", 2),
    0x86: ("STX", "zp", 2), 0x88: ("DEY", "imp", 1), 0x8A: ("TXA", "imp", 1),
    0x8C: ("STY", "abs", 3), 0x8D: ("STA", "abs", 3), 0x8E: ("STX", "abs", 3),
    0x90: ("BCC", "rel", 2), 0x91: ("STA", "izy", 2), 0x94: ("STY", "zpx", 2),
    0x95: ("STA", "zpx", 2), 0x96: ("STX", "zpy", 2), 0x98: ("TYA", "imp", 1),
    0x99: ("STA", "aby", 3), 0x9A: ("TXS", "imp", 1), 0x9D: ("STA", "abx", 3),
    0xA0: ("LDY", "imm", 2), 0xA1: ("LDA", "izx", 2), 0xA2: ("LDX", "imm", 2),
    0xA4: ("LDY", "zp", 2), 0xA5: ("LDA", "zp", 2), 0xA6: ("LDX", "zp", 2),
    0xA8: ("TAY", "imp", 1), 0xA9: ("LDA", "imm", 2), 0xAA: ("TAX", "imp", 1),
    0xAC: ("LDY", "abs", 3), 0xAD: ("LDA", "abs", 3), 0xAE: ("LDX", "abs", 3),
    0xB0: ("BCS", "rel", 2), 0xB1: ("LDA", "izy", 2), 0xB4: ("LDY", "zpx", 2),
    0xB5: ("LDA", "zpx", 2), 0xB6: ("LDX", "zpy", 2), 0xB8: ("CLV", "imp", 1),
    0xB9: ("LDA", "aby", 3), 0xBA: ("TSX", "imp", 1), 0xBC: ("LDY", "abx", 3),
    0xBD: ("LDA", "abx", 3), 0xBE: ("LDX", "aby", 3),
    0xC0: ("CPY", "imm", 2), 0xC1: ("CMP", "izx", 2), 0xC4: ("CPY", "zp", 2),
    0xC5: ("CMP", "zp", 2), 0xC6: ("DEC", "zp", 2), 0xC8: ("INY", "imp", 1),
    0xC9: ("CMP", "imm", 2), 0xCA: ("DEX", "imp", 1), 0xCC: ("CPY", "abs", 3),
    0xCD: ("CMP", "abs", 3), 0xCE: ("DEC", "abs", 3),
    0xD0: ("BNE", "rel", 2), 0xD1: ("CMP", "izy", 2), 0xD5: ("CMP", "zpx", 2),
    0xD6: ("DEC", "zpx", 2), 0xD8: ("CLD", "imp", 1), 0xD9: ("CMP", "aby", 3),
    0xDD: ("CMP", "abx", 3), 0xDE: ("DEC", "abx", 3),
    0xE0: ("CPX", "imm", 2), 0xE1: ("SBC", "izx", 2), 0xE4: ("CPX", "zp", 2),
    0xE5: ("SBC", "zp", 2), 0xE6: ("INC", "zp", 2), 0xE8: ("INX", "imp", 1),
    0xE9: ("SBC", "imm", 2), 0xEA: ("NOP", "imp", 1), 0xEC: ("CPX", "abs", 3),
    0xED: ("SBC", "abs", 3), 0xEE: ("INC", "abs", 3),
    0xF0: ("BEQ", "rel", 2), 0xF1: ("SBC", "izy", 2), 0xF5: ("SBC", "zpx", 2),
    0xF6: ("INC", "zpx", 2), 0xF8: ("SED", "imp", 1), 0xF9: ("SBC", "aby", 3),
    0xFD: ("SBC", "abx", 3), 0xFE: ("INC", "abx", 3),
}

def disasm_one(data, offset, addr):
    """Disassemble one instruction. Returns (text, length) or None."""
    if offset < 0 or offset >= len(data):
        return None, 0
    op = data[offset]
    if op not in OPCODES:
        return None, 1
    mnemonic, mode, length = OPCODES[op]
    if offset + length > len(data):
        return None, 1
    
    if mode == "imp":
        return mnemonic, length
    elif mode == "acc":
        return f"{mnemonic} A", length
    elif mode == "imm":
        return f"{mnemonic} #${data[offset+1]:02X}", length
    elif mode == "zp":
        return f"{mnemonic} ${data[offset+1]:02X}", length
    elif mode == "zpx":
        return f"{mnemonic} ${data[offset+1]:02X},X", length
    elif mode == "zpy":
        return f"{mnemonic} ${data[offset+1]:02X},Y", length
    elif mode == "abs":
        w = read_word(data, offset+1)
        return f"{mnemonic} ${w:04X}", length
    elif mode == "abx":
        w = read_word(data, offset+1)
        return f"{mnemonic} ${w:04X},X", length
    elif mode == "aby":
        w = read_word(data, offset+1)
        return f"{mnemonic} ${w:04X},Y", length
    elif mode == "ind":
        w = read_word(data, offset+1)
        return f"{mnemonic} (${w:04X})", length
    elif mode == "izx":
        return f"{mnemonic} (${data[offset+1]:02X},X)", length
    elif mode == "izy":
        return f"{mnemonic} (${data[offset+1]:02X}),Y", length
    elif mode == "rel":
        s = data[offset+1]
        if s >= 0x80:
            s -= 256
        target = addr + 2 + s
        return f"{mnemonic} ${target:04X}", length
    return None, 1

def format_hex_bytes(data, offset, count):
    """Format bytes as $XX,$YY,..."""
    return ",".join(f"${data[offset+i]:02X}" for i in range(count))

def main():
    # Load binary
    data_0c = open("/home/zero/project/sango2dasm/rom/prg/prg_0c.bin", "rb").read()
    data_0d = open("/home/zero/project/sango2dasm/rom/prg/prg_0d.bin", "rb").read()
    data = data_0c + data_0d
    
    # Load ASM file
    asm_path = "/home/zero/project/sango2dasm/asm/banks/prg_0c_0d.asm"
    with open(asm_path, "r") as f:
        lines = f.readlines()
    
    # Find all labels in the ASM file and their addresses
    label_addrs = {}  # addr -> label_name
    for line in lines:
        # Match Loc_XXXX labels (address embedded in name)
        m = re.match(r'^(Loc_([0-9A-F]{4}))\s*:', line)
        if m:
            label = m.group(1)
            addr = int(m.group(2), 16)
            label_addrs[addr] = label
            continue
        # Match other labels with address in comment on same line
        m = re.match(r'^([A-Za-z_]\w*):', line)
        if m:
            label = m.group(1)
            am = re.search(r';\s*\$([0-9A-F]{4}):', line)
            if am:
                addr = int(am.group(1), 16)
                label_addrs[addr] = label
    
    print(f"Found {len(label_addrs)} labeled addresses")
    
    # Find trampoline sites in binary
    tramp_sites = []
    for i in range(len(data) - 4):
        if data[i] == 0x20 and data[i+1] == 0x07 and data[i+2] == 0xEE:
            jsr_addr = BASE + i
            target = read_word(data, i + 3)
            tramp_sites.append((jsr_addr, target))
    
    # Find dispatcher sites in binary
    disp_sites = []
    for i in range(len(data) - 4):
        if data[i] == 0x20 and data[i+1] == 0xDE and data[i+2] == 0xEA:
            jsr_addr = BASE + i
            disp_sites.append(jsr_addr)
    
    print(f"Found {len(tramp_sites)} BankedCallbackTrampoline sites")
    print(f"Found {len(disp_sites)} CallbackDispatcher sites")
    print()
    
    # For each dispatcher site, determine table size
    # Strategy: table entries are words that match labeled addresses in the ASM
    print("=== CallbackDispatcher table analysis ===")
    for jsr_addr in disp_sites:
        inline_start = jsr_addr + 3 - BASE  # offset in data
        inline_addr = jsr_addr + 3
        
        # Read words and check against known labels
        entries = []
        for e in range(32):  # max 32 entries
            off = inline_start + e * 2
            if off + 1 >= len(data):
                break
            w = read_word(data, off)
            if w in label_addrs:
                entries.append((w, label_addrs[w]))
            else:
                break
        
        if entries:
            table_bytes = len(entries) * 2
            end_addr = inline_addr + table_bytes
            print(f"  ${jsr_addr:04X}: {len(entries)} entries (table ${inline_addr:04X}-${end_addr-1:04X})")
            for w, lbl in entries:
                print(f"    .word ${w:04X}  ; {lbl}")
            # What's after the table?
            off = inline_start + table_bytes
            if off < len(data):
                text, length = disasm_one(data, off, end_addr)
                if text:
                    print(f"    ; after table: ${end_addr:04X}: {text}")
                else:
                    print(f"    ; after table: ${end_addr:04X}: .byte ${data[off]:02X}")
        else:
            # No labeled entries found - show raw words
            print(f"  ${jsr_addr:04X}: NO labeled entries found! Raw words:")
            for e in range(8):
                off = inline_start + e * 2
                if off + 1 >= len(data):
                    break
                w = read_word(data, off)
                marker = " <-- in labels" if w in label_addrs else ""
                print(f"    [{e}] ${w:04X}{marker}")
        print()

if __name__ == "__main__":
    main()
