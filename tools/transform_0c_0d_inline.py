#!/usr/bin/env python3
"""Transform prg_0c_0d.asm: convert .byte data regions following
BankedCallbackTrampoline and CallbackDispatcher calls into proper
.word directives + disassembled code.

BankedCallbackTrampoline ($EE07): always 1 .word (2 bytes) inline target.
CallbackDispatcher ($EADE): variable-length .word table (size determined per-site).
"""
import struct
import re
import sys

BASE = 0xA000

# 6502 opcode table: opcode -> (mnemonic, mode, length)
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

# Known cross-bank function names from functions.h
KNOWN_FUNCS = {
    0xEE07: "B1F_BankedCallbackTrampoline",
    0xEADE: "B1F_CallbackDispatcher",
    0xF283: "B1F_SetUI5",
    0xF368: "B1F_GetRulerDataPtr",
    0xF237: "B1F_SwitchPrgBank",
    0xF2D7: "B1F_GetOfficerRecordAddr",
    0xF1AD: "B1F_SpriteOamWriterSimple",
    0xEDF5: "B1F_PointerTableLookup",
    0xE70E: "B1F_PaletteUpload",
}

def disasm_one(data, offset, addr):
    """Disassemble one instruction. Returns (text, length) or (None, 1) for unknown."""
    if offset < 0 or offset >= len(data):
        return None, 1
    op = data[offset]
    if op not in OPCODES:
        return None, 1
    mnemonic, mode, length = OPCODES[op]
    if offset + length > len(data):
        return None, 1

    def w16(off):
        return struct.unpack_from("<H", data, off)[0]

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
        w = w16(offset+1)
        name = KNOWN_FUNCS.get(w)
        if name and mnemonic in ("JSR", "JMP"):
            return f"{mnemonic} {name}", length
        return f"{mnemonic} ${w:04X}", length
    elif mode == "abx":
        return f"{mnemonic} ${w16(offset+1):04X},X", length
    elif mode == "aby":
        return f"{mnemonic} ${w16(offset+1):04X},Y", length
    elif mode == "ind":
        return f"{mnemonic} (${w16(offset+1):04X})", length
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


def format_instruction(data, offset, addr):
    """Format a single instruction line with comment showing address and bytes."""
    text, length = disasm_one(data, offset, addr)
    if text is None:
        # Unknown opcode - emit as .byte
        byte_val = data[offset]
        return f"  .byte ${byte_val:02X}                                  ; ${addr:04X}: {byte_val:02X}", 1
    
    # Build the byte hex string for the comment
    raw = data[offset:offset+length]
    hex_str = " ".join(f"{b:02X}" for b in raw)
    
    # Format: "  MNEMONIC OPERAND                    ; $ADDR: XX YY ZZ"
    code_part = f"  {text}"
    comment = f"; ${addr:04X}: {hex_str}"
    # Pad to align comments at column 46
    padded = code_part.ljust(46)
    return f"{padded}{comment}", length


def main():
    # Load binary
    data_0c = open("/home/zero/project/sango2dasm/rom/prg/prg_0c.bin", "rb").read()
    data_0d = open("/home/zero/project/sango2dasm/rom/prg/prg_0d.bin", "rb").read()
    data = data_0c + data_0d

    # Load ASM file
    asm_path = "/home/zero/project/sango2dasm/asm/banks/prg_0c_0d.asm"
    with open(asm_path, "r") as f:
        lines = f.readlines()

    # Build a map of address -> line index for lines with address comments
    addr_to_line = {}
    for i, line in enumerate(lines):
        m = re.search(r';\s*\$([0-9A-F]{4}):', line)
        if m:
            addr = int(m.group(1), 16)
            addr_to_line[addr] = i

    # Find all labels
    labels_at = {}  # addr -> label text (full line prefix)
    for i, line in enumerate(lines):
        m = re.match(r'^(Loc_([0-9A-F]{4}))\s*:', line)
        if m:
            addr = int(m.group(2), 16)
            labels_at[addr] = i

    # CallbackDispatcher table sizes (manually verified)
    # JSR_addr -> number of .word entries in inline table
    dispatcher_tables = {
        0xA02B: 16,
        0xA051: 5,
        0xA21E: 3,
        0xA29C: 4,   # NOT 5 - entry[4] $C3A9 is LDA#$C3 code
        0xA45F: 7,   # NOT 8 - entry[7] $C6A9 is LDA#$C6 code
        0xA885: 11,
        0xADA9: 16,
        0xB03F: 18,
        0xB955: 6,   # NOT 7 - entry[6] $D6A9 is LDA#$D6 code
        0xBCA0: 8,
        0xBE81: 17,
        0xC207: 7,
        0xC694: 4,
        0xC784: 8,
        0xC98F: 6,
        0xCD19: 7,
        0xD2D0: 7,
    }

    # Find all trampoline and dispatcher call sites in the ASM
    # We need to find lines with "JSR B1F_BankedCallbackTrampoline" or "JSR B1F_CallbackDispatcher"
    # and then fix the data region that follows

    # Strategy: find each call site line, then find the "; --- Data Region ---" + .byte lines
    # that follow, and replace them with proper .word + disassembled code.

    changes = []  # list of (start_line_idx, end_line_idx, replacement_lines)

    for i, line in enumerate(lines):
        # Check for trampoline call
        tramp_match = re.search(r'JSR B1F_BankedCallbackTrampoline\s*;\s*\$([0-9A-F]{4}):', line)
        disp_match = re.search(r'JSR B1F_CallbackDispatcher\s*;\s*\$([0-9A-F]{4}):', line)

        if not tramp_match and not disp_match:
            continue

        if tramp_match:
            jsr_addr = int(tramp_match.group(1), 16)
            inline_start = jsr_addr + 3  # address of inline data
            inline_count = 2  # 1 word = 2 bytes
            call_type = "trampoline"
        else:
            jsr_addr = int(disp_match.group(1), 16)
            inline_start = jsr_addr + 3
            if jsr_addr not in dispatcher_tables:
                print(f"WARNING: No table size for dispatcher at ${jsr_addr:04X}", file=sys.stderr)
                continue
            inline_count = dispatcher_tables[jsr_addr] * 2  # N words
            call_type = "dispatcher"

        # Find the data region lines that follow
        # Look for "; --- Data Region ---" comment and .byte lines
        j = i + 1
        data_start = None
        data_end = None

        # Skip blank lines
        while j < len(lines) and lines[j].strip() == "":
            j += 1

        # Check for "; --- Data Region ---" or "; --- BankedCallbackTrampoline target ---"
        if j < len(lines) and ("; --- Data Region ---" in lines[j] or "; --- BankedCallbackTrampoline target ---" in lines[j]):
            data_start = j
            j += 1
        else:
            # Maybe the .byte lines start directly
            if j < len(lines) and ".byte" in lines[j]:
                data_start = j
            else:
                # No data region found - might already be fixed
                continue

        # Collect all .byte lines in this data region
        byte_lines_start = j if data_start == j else j
        while j < len(lines):
            stripped = lines[j].strip()
            if stripped.startswith(".byte") or stripped.startswith(".word"):
                j += 1
            elif stripped.startswith("; ---") and "Data Region" in stripped:
                # Another data region marker - include it
                j += 1
            elif stripped == "":
                # blank line might be between .byte lines
                if j + 1 < len(lines) and lines[j+1].strip().startswith(".byte"):
                    j += 1
                else:
                    break
            else:
                break
        data_end = j  # exclusive

        if data_start is None:
            continue

        # Now determine what address the data region starts at
        # Look at the first .byte line for its address comment
        first_byte_line = None
        for k in range(data_start, data_end):
            if ".byte" in lines[k] or ".word" in lines[k]:
                first_byte_line = k
                break

        if first_byte_line is None:
            continue

        # Get the start address from the comment
        addr_m = re.search(r';\s*\$([0-9A-F]{4}):', lines[first_byte_line])
        if not addr_m:
            print(f"WARNING: No address in .byte line at line {first_byte_line+1}", file=sys.stderr)
            continue

        region_start_addr = int(addr_m.group(1), 16)

        # Verify this matches our expected inline_start
        if region_start_addr != inline_start:
            print(f"WARNING: Address mismatch at line {i+1}: expected ${inline_start:04X}, got ${region_start_addr:04X}", file=sys.stderr)
            # Still proceed but use the actual address
            inline_start = region_start_addr

        # Calculate the offset in binary
        bin_offset = inline_start - BASE

        # Build replacement lines
        new_lines = []

        if call_type == "trampoline":
            # Emit: ; --- BankedCallbackTrampoline target ---
            new_lines.append("; --- BankedCallbackTrampoline target ---\n")
            # Emit .word for the target
            target = struct.unpack_from("<H", data, bin_offset)[0]
            word_hex = f"${data[bin_offset]:02X} {data[bin_offset+1]:02X}"
            new_lines.append(f"  .word ${target:04X}                               ; ${inline_start:04X}: {word_hex}\n")
        else:
            # Emit: ; --- CallbackDispatcher table ---
            n_entries = dispatcher_tables[jsr_addr]
            new_lines.append(f"; --- CallbackDispatcher table ({n_entries} entries) ---\n")
            for e in range(n_entries):
                off = bin_offset + e * 2
                target = struct.unpack_from("<H", data, off)[0]
                addr = inline_start + e * 2
                word_hex = f"${data[off]:02X} {data[off+1]:02X}"
                new_lines.append(f"  .word ${target:04X}                               ; ${addr:04X}: {word_hex}\n")

        # Now disassemble any remaining bytes after the inline data
        code_start_addr = inline_start + inline_count
        code_bin_offset = code_start_addr - BASE

        # Find where the existing code resumes (next label or existing code line)
        # Look at what's after the data region in the original file
        resume_line = data_end
        # Skip blank lines
        while resume_line < len(lines) and lines[resume_line].strip() == "":
            resume_line += 1

        # Check if there's a label at the resume address
        next_code_addr = None
        if resume_line < len(lines):
            # Check for label
            lbl_m = re.match(r'^(Loc_([0-9A-F]{4}))\s*:', lines[resume_line])
            if lbl_m:
                next_code_addr = int(lbl_m.group(2), 16)
            else:
                # Check for code with address comment
                addr_m2 = re.search(r';\s*\$([0-9A-F]{4}):', lines[resume_line])
                if addr_m2:
                    next_code_addr = int(addr_m2.group(1), 16)

        # Disassemble bytes from code_start_addr up to next_code_addr (or a few instructions)
        if next_code_addr and next_code_addr > code_start_addr:
            # Disassemble from code_start_addr to next_code_addr
            addr = code_start_addr
            while addr < next_code_addr:
                off = addr - BASE
                if off >= len(data):
                    break
                # Check if there's a label at this address
                if addr in labels_at and addr != code_start_addr:
                    break  # Stop before hitting another label
                line_text, length = format_instruction(data, off, addr)
                new_lines.append(line_text + "\n")
                addr += length
        elif next_code_addr == code_start_addr:
            pass  # Code resumes exactly where we expect - no gap to fill
        else:
            # Can't determine where code resumes - just emit the inline data
            pass

        changes.append((data_start, data_end, new_lines))

    # Apply changes in reverse order to preserve line numbers
    print(f"Applying {len(changes)} changes...")
    for start, end, new_lines in reversed(changes):
        lines[start:end] = new_lines

    # Write output
    out_path = "/home/zero/project/sango2dasm/asm/banks/prg_0c_0d.asm"
    with open(out_path, "w") as f:
        f.writelines(lines)

    print(f"Written to {out_path}")
    print(f"Total lines: {len(lines)}")


if __name__ == "__main__":
    main()
