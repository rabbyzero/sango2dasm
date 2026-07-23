#!/usr/bin/env python3
"""Analyze inline data following BankedCallbackTrampoline and CallbackDispatcher calls in bank 0C/0D.

For BankedCallbackTrampoline ($EE07): always 1 .word target after JSR.
For CallbackDispatcher ($EADE): variable-length .word table; determine size from caller's A register max value.
"""
import struct
import sys

def read_word(data, offset):
    if offset + 1 < len(data):
        return struct.unpack_from("<H", data, offset)[0]
    return None

def find_trampoline_sites(data, base):
    """Find JSR $EE07 sites. Each has exactly 1 inline .word target."""
    sites = []
    for i in range(len(data) - 4):
        if data[i] == 0x20 and data[i+1] == 0x07 and data[i+2] == 0xEE:
            jsr_addr = base + i
            inline_offset = i + 3
            target = read_word(data, inline_offset)
            # Code resumes at jsr_addr + 5
            resume_addr = jsr_addr + 5
            sites.append({
                'jsr_addr': jsr_addr,
                'inline_offset': inline_offset,
                'target': target,
                'resume_addr': resume_addr,
            })
    return sites

def find_dispatcher_sites(data, base):
    """Find JSR $EADE sites. Table length determined by tracing max A index."""
    sites = []
    for i in range(len(data) - 4):
        if data[i] == 0x20 and data[i+1] == 0xDE and data[i+2] == 0xEA:
            jsr_addr = base + i
            inline_offset = i + 3
            # Look backwards for LDA #imm (A9 xx) to determine max index
            # Search up to 20 bytes back for LDA # patterns
            max_index = None
            for back in range(1, 30):
                pos = i - back
                if pos < 0:
                    break
                # LDA #imm = A9 xx
                if data[pos] == 0xA9:
                    max_index = data[pos + 1]
                    break
                # Also check for TAX/transfer patterns or LDA from memory
            sites.append({
                'jsr_addr': jsr_addr,
                'inline_offset': inline_offset,
                'max_index': max_index,
                'table_entries': (max_index + 1) if max_index is not None else None,
            })
    return sites

def disassemble_one(data, offset, addr):
    """Disassemble a single 6502 instruction, return (mnemonic, operand_str, length)."""
    # Minimal 6502 disassembler for common opcodes
    opcodes = {
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
    
    if offset >= len(data) or offset < 0:
        return None, None, 0
    
    opcode = data[offset]
    if opcode not in opcodes:
        return None, None, 1  # Unknown opcode
    
    mnemonic, mode, length = opcodes[opcode]
    
    if mode == "imp" or mode == "acc":
        operand = "A" if mode == "acc" else ""
    elif mode == "imm":
        operand = f"#{data[offset+1]:02X}"
    elif mode == "zp":
        operand = f"${data[offset+1]:02X}"
    elif mode == "zpx":
        operand = f"${data[offset+1]:02X},X"
    elif mode == "zpy":
        operand = f"${data[offset+1]:02X},Y"
    elif mode == "abs":
        w = read_word(data, offset + 1)
        operand = f"${w:04X}" if w is not None else "?"
    elif mode == "abx":
        w = read_word(data, offset + 1)
        operand = f"${w:04X},X" if w is not None else "?"
    elif mode == "aby":
        w = read_word(data, offset + 1)
        operand = f"${w:04X},Y" if w is not None else "?"
    elif mode == "ind":
        w = read_word(data, offset + 1)
        operand = f"(${w:04X})" if w is not None else "?"
    elif mode == "izx":
        operand = f"(${data[offset+1]:02X},X)"
    elif mode == "izy":
        operand = f"(${data[offset+1]:02X}),Y"
    elif mode == "rel":
        signed_offset = data[offset + 1]
        if signed_offset >= 0x80:
            signed_offset -= 256
        target = addr + 2 + signed_offset
        operand = f"${target:04X}"
    else:
        operand = ""
    
    return mnemonic, operand, length

def main():
    # Bank 0C: $A000-$BFFF, Bank 0D: $C000-$DFFF
    data_0c = open("/home/zero/project/sango2dasm/rom/prg/prg_0c.bin", "rb").read()
    data_0d = open("/home/zero/project/sango2dasm/rom/prg/prg_0d.bin", "rb").read()
    data = data_0c + data_0d
    base = 0xA000
    
    print("=" * 70)
    print("B1F_BankedCallbackTrampoline sites (JSR $EE07)")
    print("  Pattern: LDY #bank; JSR $EE07; .word target")
    print("  Always exactly 1 inline .word (2 bytes)")
    print("=" * 70)
    
    tramp_sites = find_trampoline_sites(data, base)
    for s in tramp_sites:
        jsr = s['jsr_addr']
        target = s['target']
        resume = s['resume_addr']
        # Look back for LDY #bank
        offset = jsr - base
        bank_str = "?"
        if offset >= 2 and data[offset-2] == 0xA0:
            bank_str = f"${data[offset-1]:02X}"
        print(f"  ${jsr:04X}: LDY #{bank_str}; JSR Trampoline; .word ${target:04X}  (resume at ${resume:04X})")
    
    print()
    print("=" * 70)
    print("B1F_CallbackDispatcher sites (JSR $EADE)")
    print("  Pattern: LDA #index; LDY #param; JSR $EADE; .word h0, h1, ...")
    print("  Table length = max_index + 1 (from LDA # before JSR)")
    print("=" * 70)
    
    disp_sites = find_dispatcher_sites(data, base)
    for s in disp_sites:
        jsr = s['jsr_addr']
        inline_off = s['inline_offset']
        max_idx = s['max_index']
        n_entries = s['table_entries']
        
        # Look back for context (LDA #, LDY #)
        offset = jsr - base
        context_bytes = data[max(0,offset-6):offset]
        ctx_str = " ".join(f"{b:02X}" for b in context_bytes)
        
        print(f"\n  ${jsr:04X}: (context: {ctx_str})")
        if n_entries is not None:
            print(f"    Max index = {max_idx} -> {n_entries} table entries:")
            for e in range(n_entries):
                w = read_word(data, inline_off + e * 2)
                if w is not None:
                    print(f"      [{e}] ${w:04X}")
            table_end = inline_off + n_entries * 2
            table_end_addr = base + table_end
            print(f"    Table ends at ${table_end_addr:04X}, code resumes there")
            # Disassemble a few instructions after table
            print(f"    Code after table:")
            pos = table_end
            addr = table_end_addr
            for _ in range(4):
                rel = pos - base
                if rel < 0 or rel >= len(data):
                    break
                mnem, oper, length = disassemble_one(data, rel, addr)
                if mnem is None:
                    print(f"      ${addr:04X}: .byte ${data[rel]:02X}")
                    pos += 1
                    addr += 1
                else:
                    if oper:
                        print(f"      ${addr:04X}: {mnem} {oper}")
                    else:
                        print(f"      ${addr:04X}: {mnem}")
                    pos += length
                    addr += length
        else:
            print(f"    Could not determine table size from immediate (index from memory)")
            # Show words - list those that look like valid code addresses in bank
            print(f"    Words at ${base+inline_off:04X} (potential table entries):")
            for e in range(16):
                off = inline_off + e * 2
                if off + 1 >= len(data):
                    break
                w = read_word(data, off)
                if w is not None:
                    # Mark likely addresses (in $A000-$DFFF range for this bank)
                    marker = " <-- addr" if 0xA000 <= w <= 0xDFFF else ""
                    print(f"      [{e:2d}] ${w:04X}{marker}")

if __name__ == "__main__":
    main()
