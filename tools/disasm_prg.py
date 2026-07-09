#!/usr/bin/env python3
"""
Disassemble combined 16KB PRG banks ($A000-$DFFF) with code/data identification.

Combines two 8KB PRG bank binaries, performs multi-pass analysis to distinguish
code from data, and outputs ca65-compatible assembly.

Code identification:
  1. Branch (Bxx), JMP, JSR targets within the bank
  2. Inline dispatch tables after JSR CallbackDispatcher ($EADE)
     or JSR BankedCallbackTrampoline ($EE07) -- .word entries are callback targets

Execution tracing stops at JMP (abs/ind), RTS, or RTI.
"""

import argparse
import os
import sys

BASE_ADDR = 0xA000
BANK_SIZE = 0x2000  # 8KB per bank, 16KB combined
COMBINED_SIZE = 0x4000  # 16KB
MAX_DISPATCH_ENTRIES = 64

# Dispatcher JSR targets with inline .word callback tables
CB_DISPATCHER = 0xEADE    # CallbackDispatcher
CB_TRAMPOLINE = 0xEE07    # BankedCallbackTrampoline
DISPATCHER_TARGETS = {CB_DISPATCHER, CB_TRAMPOLINE}

# OPCODE_TABLE placeholder - will be filled below
OPCODE_TABLE = [None] * 256

def _build_opcode_table():
    ot = {
        0x00: ("imp","BRK",1,7),  0x01: ("izx","ORA",2,6),
        0x04: ("zp","NOP",2,3),   0x05: ("zp","ORA",2,3),
        0x06: ("zp","ASL",2,5),   0x08: ("imp","PHP",1,3),
        0x09: ("imm","ORA",2,2),  0x0A: ("acc","ASL",1,2),
        0x0C: ("abs","NOP",3,4),  0x0D: ("abs","ORA",3,4),
        0x0E: ("abs","ASL",3,6),  0x10: ("rel","BPL",2,2),
        0x11: ("izy","ORA",2,5),  0x14: ("zpx","NOP",2,4),
        0x15: ("zpx","ORA",2,4),  0x16: ("zpx","ASL",2,6),
        0x18: ("imp","CLC",1,2),  0x19: ("aby","ORA",3,4),
        0x1A: ("acc","NOP",1,2),  0x1C: ("abx","NOP",3,4),
        0x1D: ("abx","ORA",3,4),  0x1E: ("abx","ASL",3,7),
        0x20: ("abs","JSR",3,6),  0x21: ("izx","AND",2,6),
        0x24: ("zp","BIT",2,3),   0x25: ("zp","AND",2,3),
        0x26: ("zp","ROL",2,5),   0x28: ("imp","PLP",1,4),
        0x29: ("imm","AND",2,2),  0x2A: ("acc","ROL",1,2),
        0x2C: ("abs","BIT",3,4),  0x2D: ("abs","AND",3,4),
        0x2E: ("abs","ROL",3,6),  0x30: ("rel","BMI",2,2),
        0x31: ("izy","AND",2,5),  0x34: ("zpx","NOP",2,4),
        0x35: ("zpx","AND",2,4),  0x36: ("zpx","ROL",2,6),
        0x38: ("imp","SEC",1,2),  0x39: ("aby","AND",3,4),
        0x3A: ("imp","NOP",1,2),  0x3C: ("abx","NOP",3,4),
        0x3D: ("abx","AND",3,4),  0x3E: ("abx","ROL",3,7),
        0x40: ("imp","RTI",1,6),  0x41: ("izx","EOR",2,6),
        0x44: ("zp","NOP",2,3),   0x45: ("zp","EOR",2,3),
        0x46: ("zp","LSR",2,5),   0x48: ("imp","PHA",1,3),
        0x49: ("imm","EOR",2,2),  0x4A: ("acc","LSR",1,2),
        0x4C: ("abs","JMP",3,3),  0x4D: ("abs","EOR",3,4),
        0x4E: ("abs","LSR",3,6),  0x50: ("rel","BVC",2,2),
        0x51: ("izy","EOR",2,5),  0x54: ("zpx","NOP",2,4),
        0x55: ("zpx","EOR",2,4),  0x56: ("zpx","LSR",2,6),
        0x58: ("imp","CLI",1,2),  0x59: ("aby","EOR",3,4),
        0x5A: ("imp","NOP",1,2),  0x5C: ("abx","NOP",3,4),
        0x5D: ("abx","EOR",3,4),  0x5E: ("abx","LSR",3,7),
        0x60: ("imp","RTS",1,6),  0x61: ("izx","ADC",2,6),
        0x64: ("zp","NOP",2,3),   0x65: ("zp","ADC",2,3),
        0x66: ("zp","ROR",2,5),   0x68: ("imp","PLA",1,4),
        0x69: ("imm","ADC",2,2),  0x6A: ("acc","ROR",1,2),
        0x6C: ("ind","JMP",3,5),  0x6D: ("abs","ADC",3,4),
        0x6E: ("abs","ROR",3,6),  0x70: ("rel","BVS",2,2),
        0x71: ("izy","ADC",2,5),  0x74: ("zpx","NOP",2,4),
        0x75: ("zpx","ADC",2,4),  0x76: ("zpx","ROR",2,6),
        0x78: ("imp","SEI",1,2),  0x79: ("aby","ADC",3,4),
        0x7A: ("imp","NOP",1,2),  0x7C: ("abx","NOP",3,4),
        0x7D: ("abx","ADC",3,4),  0x7E: ("abx","ROR",3,7),
        0x80: ("imm","NOP",2,2),  0x81: ("izx","STA",2,6),
        0x82: ("imm","NOP",2,2),  0x84: ("zp","STY",2,3),
        0x85: ("zp","STA",2,3),   0x86: ("zp","STX",2,3),
        0x88: ("imp","DEY",1,2),  0x89: ("imm","NOP",2,2),
        0x8A: ("imp","TXA",1,2),  0x8C: ("abs","STY",3,4),
        0x8D: ("abs","STA",3,4),  0x8E: ("abs","STX",3,4),
        0x90: ("rel","BCC",2,2),  0x91: ("izy","STA",2,6),
        0x94: ("zpx","STY",2,4),  0x95: ("zpx","STA",2,4),
        0x96: ("zpy","STX",2,4),  0x98: ("imp","TYA",1,2),
        0x99: ("aby","STA",3,5),  0x9A: ("imp","TXS",1,2),
        0x9D: ("abx","STA",3,5),  0xA0: ("imm","LDY",2,2),
        0xA1: ("izx","LDA",2,6),  0xA2: ("imm","LDX",2,2),
        0xA4: ("zp","LDY",2,3),   0xA5: ("zp","LDA",2,3),
        0xA6: ("zp","LDX",2,3),   0xA8: ("imp","TAY",1,2),
        0xA9: ("imm","LDA",2,2),  0xAA: ("imp","TAX",1,2),
        0xAC: ("abs","LDY",3,4),  0xAD: ("abs","LDA",3,4),
        0xAE: ("abs","LDX",3,4),  0xB0: ("rel","BCS",2,2),
        0xB1: ("izy","LDA",2,5),  0xB4: ("zpx","LDY",2,4),
        0xB5: ("zpx","LDA",2,4),  0xB6: ("zpy","LDX",2,4),
        0xB8: ("imp","CLV",1,2),  0xB9: ("aby","LDA",3,4),
        0xBA: ("imp","TSX",1,2),  0xBC: ("abx","LDY",3,4),
        0xBD: ("abx","LDA",3,4),  0xBE: ("aby","LDX",3,4),
        0xC0: ("imm","CPY",2,2),  0xC1: ("izx","CMP",2,6),
        0xC2: ("imm","NOP",2,2),  0xC4: ("zp","CPY",2,3),
        0xC5: ("zp","CMP",2,3),   0xC6: ("zp","DEC",2,5),
        0xC8: ("imp","INY",1,2),  0xC9: ("imm","CMP",2,2),
        0xCA: ("imp","DEX",1,2),  0xCC: ("abs","CPY",3,4),
        0xCD: ("abs","CMP",3,4),  0xCE: ("abs","DEC",3,6),
        0xD0: ("rel","BNE",2,2),  0xD1: ("izy","CMP",2,5),
        0xD4: ("zpx","NOP",2,4),  0xD5: ("zpx","CMP",2,4),
        0xD6: ("zpx","DEC",2,6),  0xD8: ("imp","CLD",1,2),
        0xD9: ("aby","CMP",3,4),  0xDA: ("imp","NOP",1,2),
        0xDC: ("abx","NOP",3,4),  0xDD: ("abx","CMP",3,4),
        0xDE: ("abx","DEC",3,7),  0xE0: ("imm","CPX",2,2),
        0xE1: ("izx","SBC",2,6),  0xE2: ("imm","NOP",2,2),
        0xE4: ("zp","CPX",2,3),   0xE5: ("zp","SBC",2,3),
        0xE6: ("zp","INC",2,5),   0xE8: ("imp","INX",1,2),
        0xE9: ("imm","SBC",2,2),  0xEA: ("imp","NOP",1,2),
        0xEB: ("imm","SBC",2,2),  0xEC: ("abs","CPX",3,4),
        0xED: ("abs","SBC",3,4),  0xEE: ("abs","INC",3,6),
        0xF0: ("rel","BEQ",2,2),  0xF1: ("izy","SBC",2,5),
        0xF4: ("zpx","NOP",2,4),  0xF5: ("zpx","SBC",2,4),
        0xF6: ("zpx","INC",2,6),  0xF8: ("imp","SED",1,2),
        0xF9: ("aby","SBC",3,4),  0xFA: ("imp","NOP",1,2),
        0xFC: ("abx","NOP",3,4),  0xFD: ("abx","SBC",3,4),
        0xFE: ("abx","INC",3,7),
    }
    # Undocumented / illegal 6502 opcodes (completes full 256-entry table)
    undoc = {
        0x02: ("imp","JAM",1,0),  0x03: ("izx","SLO",2,8),
        0x07: ("zp", "SLO",2,5),  0x0B: ("imm","ANC",2,2),
        0x0F: ("abs","SLO",3,6),  0x12: ("imp","JAM",1,0),
        0x13: ("izy","SLO",2,8),  0x17: ("zpx","SLO",2,6),
        0x1B: ("aby","SLO",3,7),  0x1F: ("abx","SLO",3,7),
        0x22: ("imp","JAM",1,0),  0x23: ("izx","RLA",2,8),
        0x27: ("zp", "RLA",2,5),  0x2B: ("imm","ANC",2,2),
        0x2F: ("abs","RLA",3,6),  0x32: ("imp","JAM",1,0),
        0x33: ("izy","RLA",2,8),  0x37: ("zpx","RLA",2,6),
        0x3B: ("aby","RLA",3,7),  0x3F: ("abx","RLA",3,7),
        0x42: ("imp","JAM",1,0),  0x43: ("izx","SRE",2,8),
        0x47: ("zp", "SRE",2,5),  0x4B: ("imm","ALR",2,2),
        0x4F: ("abs","SRE",3,6),  0x52: ("imp","JAM",1,0),
        0x53: ("izy","SRE",2,8),  0x57: ("zpx","SRE",2,6),
        0x5B: ("aby","SRE",3,7),  0x5F: ("abx","SRE",3,7),
        0x62: ("imp","JAM",1,0),  0x63: ("izx","RRA",2,8),
        0x67: ("zp", "RRA",2,5),  0x6B: ("imm","ARR",2,2),
        0x6F: ("abs","RRA",3,6),  0x72: ("imp","JAM",1,0),
        0x73: ("izy","RRA",2,8),  0x77: ("zpx","RRA",2,6),
        0x7B: ("aby","RRA",3,7),  0x7F: ("abx","RRA",3,7),
        0x83: ("izx","SAX",2,6),  0x87: ("zp", "SAX",2,3),
        0x8B: ("imm","XAA",2,2),  0x8F: ("abs","SAX",3,4),
        0x92: ("imp","JAM",1,0),  0x93: ("izy","AHX",2,6),
        0x97: ("zpy","SAX",2,4),  0x9B: ("aby","TAS",3,5),
        0x9C: ("abx","SHY",3,5),  0x9E: ("aby","SHX",3,5),
        0x9F: ("aby","AHX",3,5),  0xA3: ("izx","LAX",2,6),
        0xA7: ("zp", "LAX",2,3),  0xAB: ("imm","LAX",2,2),
        0xAF: ("abs","LAX",3,4),  0xB2: ("izy","LAX",2,5),
        0xB3: ("izy","LAX",2,5),  0xB7: ("zpy","LAX",2,4),
        0xBB: ("aby","LAS",3,4),  0xBF: ("aby","LAX",3,4),
        0xC3: ("izx","DCP",2,8),  0xC7: ("zp", "DCP",2,5),
        0xCB: ("imm","AXS",2,2),  0xCF: ("abs","DCP",3,6),
        0xD2: ("imp","JAM",1,0),  0xD3: ("izy","DCP",2,8),
        0xD7: ("zpx","DCP",2,6),  0xDB: ("aby","DCP",3,7),
        0xDF: ("abx","DCP",3,7),  0xE3: ("izx","ISB",2,8),
        0xE7: ("zp", "ISB",2,5),  0xEF: ("abs","ISB",3,6),
        0xF2: ("imp","JAM",1,0),  0xF3: ("izy","ISB",2,8),
        0xF7: ("zpx","ISB",2,6),  0xFB: ("aby","ISB",3,7),
        0xFF: ("abx","ISB",3,7),
    }
    ot.update(undoc)
    for c, (m, n, s, cy) in ot.items():
        OPCODE_TABLE[c] = (m, n, s, cy)

_build_opcode_table()


# =============================================================================
# Decode a single instruction at given offset
# Returns (mode, mnemonic, size, target_addr_or_None) or None if invalid
# =============================================================================
def decode_instruction(data, offset, addr):
    """Decode one instruction. Returns dict or None."""
    if offset >= len(data):
        return None
    opcode = data[offset]
    entry = OPCODE_TABLE[opcode]
    if entry is None:
        return None
    mode, mn, sz, cy = entry
    if offset + sz > len(data):
        return None

    target = None
    if mode == "rel":
        b_off = data[offset + 1]
        if b_off >= 0x80:
            b_off -= 256
        target = addr + 2 + b_off
    elif mode == "abs" and mn in ("JMP", "JSR"):
        target = data[offset + 1] | (data[offset + 2] << 8)
    elif mode == "ind" and mn == "JMP":
        target = data[offset + 1] | (data[offset + 2] << 8)

    return {"mode": mode, "mn": mn, "sz": sz, "opcode": opcode, "target": target}


def is_terminator(mn):
    """Check if mnemonic terminates execution flow."""
    return mn in ("JMP", "RTS", "RTI")


def in_range(addr):
    """Check if address is within our $A000-$DFFF range."""
    return BASE_ADDR <= addr < BASE_ADDR + COMBINED_SIZE


# =============================================================================
# Pass 1: Seed code entry points
# =============================================================================
def pass1_collect_targets(data):
    """Linear scan to collect all branch/jump/jsr targets + dispatch table entries."""
    targets = set()
    dispatch_tables = []  # list of (jsr_addr, [target_addrs])
    offset = 0
    size = len(data)
    data_offsets = set()  # offsets that are dispatch table data (forced non-code)

    while offset < size:
        addr = BASE_ADDR + offset
        instr = decode_instruction(data, offset, addr)
        if instr is None:
            offset += 1
            continue

        # Collect branch/jump/jsr targets within range
        if instr["target"] is not None and in_range(instr["target"]):
            targets.add(instr["target"])

        # Detect dispatcher pattern: JSR to known dispatcher
        if instr["mn"] == "JSR" and instr["target"] in DISPATCHER_TARGETS:
            # Read inline .word table after the JSR instruction
            table_start = offset + instr["sz"]
            table_addrs = []
            pos = table_start
            for _ in range(MAX_DISPATCH_ENTRIES):
                if pos + 2 > size:
                    break
                lo = data[pos]
                hi = data[pos + 1]
                word_val = lo | (hi << 8)
                if not in_range(word_val):
                    break
                table_addrs.append(word_val)
                targets.add(word_val)
                pos += 2
            if table_addrs:
                dispatch_tables.append((addr, table_addrs))
                # Mark the table byte range (offsets) as forced-data
                for tb in range(table_start, pos):
                    data_offsets.add(tb)

        offset += instr["sz"]

    # Check for jump-table patterns: sequences of JMP abs (opcode 0x4C)
    # at the start of the bank or after known targets
    off = 0
    while off < size - 2:
        if data[off] == 0x4C:  # JMP abs
            jmp_target = data[off + 1] | (data[off + 2] << 8)
            if in_range(jmp_target):
                # This JMP abs is at this offset -- mark it as a target
                # so it gets traced as code
                targets.add(BASE_ADDR + off)
                targets.add(jmp_target)
                off += 3
                # Check if next instruction is also JMP abs (jump table pattern)
                continue
        break  # stop once we hit a non-JMP-abs

    # Also seed offset 0 (bank entry point, commonly a jump table)
    targets.add(BASE_ADDR)

    return targets, dispatch_tables, data_offsets


# =============================================================================
# Pass 2: Trace execution regions from seed entries
# =============================================================================
def pass2_trace_code(data, entry_points, data_offsets):
    """Trace from each entry point, marking bytes as code until terminator.
    data_offsets: set of byte offsets that are dispatch table data (must not be code)."""
    is_code = bytearray(len(data))  # 0 = unknown, 1 = code
    worklist = list(entry_points)

    while worklist:
        addr = worklist.pop()
        if not in_range(addr):
            continue
        offset = addr - BASE_ADDR
        if offset < 0 or offset >= len(data):
            continue
        if is_code[offset]:
            continue  # already traced

        # Trace forward from this entry
        pos = offset
        while pos < len(data):
            if is_code[pos]:
                break  # already traced this path
            if pos in data_offsets:
                break  # hit a dispatch table -- stop tracing

            cur_addr = BASE_ADDR + pos
            instr = decode_instruction(data, pos, cur_addr)
            if instr is None:
                # Unknown opcode -- mark single byte as code and stop
                is_code[pos] = 1
                break

            # Mark all bytes of this instruction as code
            for i in range(instr["sz"]):
                if pos + i < len(data):
                    is_code[pos + i] = 1

            if is_terminator(instr["mn"]):
                break  # execution stops here

            # Dispatcher JSR: treat as terminator (execution continues in table)
            if instr["mn"] == "JSR" and instr["target"] in DISPATCHER_TARGETS:
                break

            # Continue to next instruction (fall-through)
            pos += instr["sz"]

    return is_code


# =============================================================================
# Pass 3: Generate output
# =============================================================================
def format_operand(mode, operand_bytes, addr):
    """Format operand string based on addressing mode."""
    if mode in ("imp", "acc"):
        return ""
    elif mode == "imm":
        return "#${:02X}".format(operand_bytes[0])
    elif mode == "zp":
        return "${:02X}".format(operand_bytes[0])
    elif mode == "zpx":
        return "${:02X},X".format(operand_bytes[0])
    elif mode == "zpy":
        return "${:02X},Y".format(operand_bytes[0])
    elif mode == "abs":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        return "${:04X}".format(val)
    elif mode == "abx":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        return "${:04X},X".format(val)
    elif mode == "aby":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        return "${:04X},Y".format(val)
    elif mode == "ind":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        return "(${:04X})".format(val)
    elif mode == "izx":
        return "(${:02X},X)".format(operand_bytes[0])
    elif mode == "izy":
        return "(${:02X}),Y".format(operand_bytes[0])
    elif mode == "rel":
        b_off = operand_bytes[0]
        if b_off >= 0x80:
            b_off -= 256
        target = addr + 2 + b_off
        return "${:04X}".format(target)
    return ""


def pass3_generate_output(data, is_code, targets, dispatch_tables):
    """Generate ca65-compatible assembly output."""
    # Build label map for all targets that are in-range code
    label_map = {}
    for t in sorted(targets):
        if in_range(t):
            off = t - BASE_ADDR
            if off < len(is_code) and is_code[off]:
                label_map[t] = "Loc_{:04X}".format(t)

    # Build dispatch table address sets for annotation
    dispatch_table_addrs = set()
    for jsr_addr, addrs in dispatch_tables:
        for a in addrs:
            dispatch_table_addrs.add(a)

    lines = []
    offset = 0
    size = len(data)
    prev_was_code = None

    while offset < size:
        addr = BASE_ADDR + offset

        # Emit label if this is a target
        if addr in label_map:
            if addr in dispatch_table_addrs:
                lines.append("{}:  ; (dispatch callback target)".format(label_map[addr]))
            else:
                lines.append("{}:".format(label_map[addr]))

        if is_code[offset]:
            # Transition from data to code
            if prev_was_code is False:
                lines.append("; --- Code Region ---")

            instr = decode_instruction(data, offset, addr)
            if instr is None:
                raw = data[offset]
                lines.append("  .byte ${:02X}                              ; ${:04X}: {:02X}".format(
                    raw, addr, raw))
                offset += 1
                prev_was_code = True
                continue

            op_bytes = data[offset + 1: offset + instr["sz"]]
            operand = format_operand(instr["mode"], op_bytes, addr)
            instr_str = "{} {}".format(instr["mn"], operand).strip()
            byte_hex = " ".join("{:02X}".format(data[offset + i]) for i in range(instr["sz"]))
            padded = "  {:<38s}".format(instr_str)
            lines.append("{}; ${:04X}: {}".format(padded, addr, byte_hex))
            offset += instr["sz"]
            prev_was_code = True
        else:
            # Transition from code to data
            if prev_was_code is True or prev_was_code is None:
                lines.append("; --- Data Region ---")

            # Emit up to 16 bytes per line
            start = offset
            end = min(offset + 16, size)
            # Stop at next code byte
            while offset < end and not is_code[offset]:
                offset += 1
            chunk = data[start:offset]
            hex_bytes = ",".join("${:02X}".format(b) for b in chunk)
            raw_hex = " ".join("{:02X}".format(b) for b in chunk)
            padded = "  .byte {:<34s}".format(hex_bytes)
            lines.append("{}; ${:04X}: {}".format(padded, BASE_ADDR + start, raw_hex))
            prev_was_code = False

    return lines


# =============================================================================
# Main
# =============================================================================
def main():
    parser = argparse.ArgumentParser(
        description="Disassemble combined 16KB PRG banks ($A000-$DFFF)")
    parser.add_argument("bank_lo", help="Low bank number (e.g. 0x1D)")
    parser.add_argument("bank_hi", help="High bank number (e.g. 0x1E)")
    parser.add_argument("--output", "-o", help="Output file (default: stdout)")
    parser.add_argument("--rom-dir", default="rom/prg",
                        help="Directory containing PRG bank binaries")
    args = parser.parse_args()

    bank_lo = int(args.bank_lo, 0)
    bank_hi = int(args.bank_hi, 0)

    # Load and combine banks
    lo_path = os.path.join(args.rom_dir, "prg_{:02x}.bin".format(bank_lo))
    hi_path = os.path.join(args.rom_dir, "prg_{:02x}.bin".format(bank_hi))

    for p in (lo_path, hi_path):
        if not os.path.exists(p):
            print("Error: {} not found".format(p), file=sys.stderr)
            sys.exit(1)

    with open(lo_path, "rb") as f:
        lo_data = f.read()
    with open(hi_path, "rb") as f:
        hi_data = f.read()

    if len(lo_data) != BANK_SIZE:
        print("Warning: {} is {} bytes (expected {})".format(
            lo_path, len(lo_data), BANK_SIZE), file=sys.stderr)
    if len(hi_data) != BANK_SIZE:
        print("Warning: {} is {} bytes (expected {})".format(
            hi_path, len(hi_data), BANK_SIZE), file=sys.stderr)

    # Combine into 16KB image
    combined = lo_data + hi_data

    print("Combining bank ${:02X} ($A000-$BFFF) + bank ${:02X} ($C000-$DFFF)".format(
        bank_lo, bank_hi), file=sys.stderr)
    print("Combined size: {} bytes".format(len(combined)), file=sys.stderr)

    # Pass 1: Collect targets
    targets, dispatch_tables, data_offsets = pass1_collect_targets(combined)
    print("Pass 1: {} code targets, {} dispatch tables, {} data-table bytes".format(
        len(targets), len(dispatch_tables), len(data_offsets)), file=sys.stderr)

    # Pass 2: Trace execution
    is_code = pass2_trace_code(combined, targets, data_offsets)
    code_bytes = sum(1 for b in is_code if b)
    data_bytes = len(is_code) - code_bytes
    print("Pass 2: {} code bytes, {} data bytes ({:.1f}% code)".format(
        code_bytes, data_bytes, 100.0 * code_bytes / len(is_code)), file=sys.stderr)

    # Pass 3: Generate output
    output_lines = pass3_generate_output(combined, is_code, targets, dispatch_tables)

    # Write output
    if args.output:
        os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
        with open(args.output, "w") as f:
            for line in output_lines:
                f.write(line + "\n")
        print("Output: {}".format(args.output), file=sys.stderr)
    else:
        for line in output_lines:
            print(line)


if __name__ == "__main__":
    main()
