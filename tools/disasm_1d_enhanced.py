#!/usr/bin/env python3
"""
Complete enhanced disassembly of prg_1d.bin ($A000-$BFFF).
Generates ca65-compatible assembly with:
- Entry labels on jump table
- Section markers for entry procedures
- Meaningful subroutine names
- Complete byte coverage of all 8192 bytes
"""
import sys

# =============================================================================
# Load binary
# =============================================================================
with open("/home/zero/project/sango2dasm/rom/prg/prg_1d.bin", "rb") as f:
    data = f.read()

BASE = 0xA000
SIZE = len(data)
assert SIZE == 8192, f"Expected 8192 bytes, got {SIZE}"

# =============================================================================
# 6502 opcode table (all 151 legal opcodes)
# =============================================================================
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
assert len(OPCODE_TABLE) == 151, f"Expected 151 opcodes, got {len(OPCODE_TABLE)}"
SIZES = {'imp':1,'acc':1,'imm':2,'zp':2,'zpx':2,'zpy':2,'abs':3,'abx':3,'aby':3,'ind':3,'izx':2,'izy':2,'rel':2}

# =============================================================================
# Symbolic names for bank $1F functions
# =============================================================================
B1F_NAMES = {
    0xE9BA: "B1F_MathBinToBcd", 0xEADE: "B1F_CallbackDispatcher",
    0xEBE9: "B1F_MathMul24x8", 0xEE07: "B1F_BankedCallbackTrampoline",
    0xF237: "B1F_SwitchBankAC_B", 0xF24B: "B1F_SwitchBankAC_A",
    0xF25F: "B1F_SwitchBank8_B", 0xF266: "B1F_SwitchBank8_A",
    0xF2AF: "B1F_GetProvinceRecordAddr", 0xF2D7: "B1F_GetOfficerRecordAddr",
    0xF308: "B1F_GetNameDisplayScale",
}

# =============================================================================
# Data regions (offset, end_offset_exclusive, label)
# =============================================================================
DATA_REGIONS = [
    (0x0209, 0x0248, "CallbackData_Entry01"),   # $A209-$A247
    (0x0607, 0x060F, "OffsetTable_0607"),        # $A607-$A60E
    (0x0672, 0x0690, "OffsetWordTable_0672"),    # $A672-$A68F
    (0x06A7, 0x06B6, "BankSelectTable_06A7"),    # $A6A7-$A6B5
    (0x0D81, 0x0D92, "PointerTable_AD81"),       # $AD81-$AD91
    (0x1222, 0x123D, "DataTable_B222"),          # $B222-$B23C
    (0x1305, 0x1989, "TileMapData_B305"),        # $B305-$B988
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

# =============================================================================
# Jump table definition (24 entries)
# =============================================================================
JUMP_TABLE_ENTRIES = [
    (0,  0xA048, "Entry00_PPUTileRender"),
    (1,  0xA154, "Entry01_MenuUpdate"),
    (2,  0xA11B, "Entry02_VRAMBufferWrite"),
    (3,  0xABD2, "Entry03_StateHandler"),
    (4,  0xB29F, "Entry04_MapDisplaySetup"),
    (5,  0xB989, "Entry05_OfficerListHandler"),
    (6,  0xBC41, "Entry06_Unknown"),
    (7,  0xDBB1, None),  # bank $1E
    (8,  0xDD8B, None),  # bank $1E
    (9,  0xDE7E, None),  # bank $1E
    (10, 0xA6B6, "Entry10_NumberDisplaySetup"),
    (11, 0xA77F, "Entry11_FrameCounterCheck"),
    (12, 0xA7B2, "Entry12_BcdDisplayHandler"),
    (13, 0xA830, "Entry13_ProvinceDataHandler"),
    (14, 0xA890, "Entry14_OfficerLookup"),
    (15, 0xA78A, "Entry15_FrameCounterAlt"),
    (16, 0xA8A4, "Entry16_NameDisplay"),
    (17, 0xA8FD, "Entry17_RecordProcessor"),
    (18, 0xBC66, "Entry18_SmallRoutineA"),
    (19, 0xBC71, "Entry19_SmallRoutineB"),
    (20, 0xA991, "Entry20_DataFormatter"),
    (21, 0xBE36, "Entry21_MenuRenderer"),
    (22, 0xAA37, "Entry22_BankedDataHandler"),
    (23, 0xDEB9, None),  # bank $1E
]

# Build maps for jump table targets
jt_targets = {}  # addr -> (entry_idx, name)
for idx, target, name in JUMP_TABLE_ENTRIES:
    jt_targets[target] = (idx, name)

# =============================================================================
# Subroutine names (non-entry-point subroutines called by JSR)
# =============================================================================
SUB_NAMES = {
    0xA158: "CheckInputAndProcess",
    0xA1DF: "AdvanceReadPtr",
    0xA1E8: "StoreTileByte",
    0xA60F: "ClearTileBuffers",
    0xA61D: "CalcMenuDataPtr",
    0xA690: "SwitchDataBank",
    0xA96F: "FormatNumberPair",
    0xA9C3: "ProcessItemEntry",
    0xB0AB: "DrawOfficerName",
    0xB14C: "RenderSubState",
    0xB23E: "SetupMapTileRow",
    0xB9CF: "InitOfficerListState",
    0xBA0E: "ProcessOfficerListScroll",
    0xBB28: "DrawOfficerRecord",
    0xBC28: "SetMenuVRAMAddr",
}

# Merge all named labels
all_names = {}
for addr, (idx, name) in jt_targets.items():
    if name and BASE <= addr < BASE + SIZE:
        all_names[addr] = name
all_names.update(SUB_NAMES)

# =============================================================================
# First pass: collect branch/jump targets (excluding data regions)
# =============================================================================
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

# Add named addresses to targets
for addr in all_names:
    if BASE <= addr < BASE + SIZE:
        targets.add(addr)

# Build label map: prefer meaningful names, fall back to Loc_XXXX
label_map = {}
for t in sorted(targets):
    if t in all_names:
        label_map[t] = all_names[t]
    else:
        label_map[t] = f"Loc_{t:04X}"

# =============================================================================
# Second pass: generate assembly output
# =============================================================================
out = []

def emit_line(text):
    out.append(text)

def emit_instruction(instr, addr, byte_hex):
    padded = f"  {instr}"
    out.append(f"{padded:<42s}; ${addr:04X}: {byte_hex}")

def emit_data_row(chunk, addr):
    hex_bytes = ','.join(f'${b:02X}' for b in chunk)
    raw_hex = ' '.join(f'{b:02X}' for b in chunk)
    padded = f"  .byte {hex_bytes}"
    out.append(f"{padded:<42s}; ${addr:04X}: {raw_hex}")

def emit_label(addr):
    lbl = label_map.get(addr)
    if lbl:
        out.append(f"{lbl}:")

def emit_comment(text):
    out.append(f"; {text}")

def emit_blank():
    out.append("")

# =============================================================================
# File header
# =============================================================================
emit_line(";===============================================================================")
emit_line("; PRG Bank $1D - $A000-$BFFF (8KB)")
emit_line("; Sangokushi 2 - Haou no Tairiku (J)")
emit_line("; Namco-163 Mapper 19")
emit_line(";")
emit_line("; Jump table at $A000-$A047 (24 entries dispatched by game state)")
emit_line("; Code: $A048-$B304 (with inline data tables)")
emit_line("; Data: $B305-$B988 (tile/map data, ~1636 bytes)")
emit_line("; Code: $B989-$BFFF (menu/UI handler routines)")
emit_line(";")
emit_line("; Part of combined 16KB: prg_1d_1e.asm ($A000-$DFFF)")
emit_line(";===============================================================================")
emit_blank()
emit_line('.include "6502_registers.h"')
emit_line('.include "namco163.h"')
emit_line('.include "functions.h"')
emit_blank()
emit_line('.segment "CODE_BANK1D"')
emit_blank()

# =============================================================================
# Jump Table ($A000-$A047)
# =============================================================================
emit_line(";===============================================================================")
emit_line("; Jump Table ($A000-$A047) - 24 entries dispatched by game state")
emit_line(";===============================================================================")
emit_blank()

# Emit jump table entries
for idx, target, name in JUMP_TABLE_ENTRIES:
    addr = BASE + idx * 3
    offset = idx * 3
    entry_label = f"Entry{idx:02d}"

    # Entry label
    if name:
        emit_line(f"{entry_label}:")
        emit_line(f"  ; {entry_label} = {name}")
    elif target >= 0xC000:
        emit_line(f"{entry_label}:")
        emit_line(f"  ; {entry_label} -> ${target:04X} (bank $1E)")
    else:
        emit_line(f"{entry_label}:")

    # JMP instruction
    b0 = data[offset]
    b1 = data[offset+1]
    b2 = data[offset+2]
    raw_hex = f"{b0:02X} {b1:02X} {b2:02X}"

    if BASE <= target < BASE + SIZE:
        tgt_label = label_map.get(target, f"${target:04X}")
        emit_instruction(f"JMP {tgt_label}", addr, raw_hex)
    else:
        emit_instruction(f"JMP ${target:04X}", addr, raw_hex)

emit_blank()

# =============================================================================
# Code Region ($A048-$BFFF)
# =============================================================================
emit_line(";===============================================================================")
emit_line("; Code Region ($A048-$B304)")
emit_line(";===============================================================================")
emit_blank()

# Track whether we've emitted section headers for entry regions
emitted_sections = set()

def maybe_emit_section(addr):
    """Emit a section header if this address is an entry point target."""
    if addr in jt_targets and addr not in emitted_sections:
        idx, name = jt_targets[addr]
        emitted_sections.add(addr)
        if name:
            emit_blank()
            emit_line(f";-----------------------------------------------------------------------------")
            emit_line(f"; Entry{idx:02d}: {name}")
            emit_line(f"; Jump table entry {idx} at $A{idx*3:03X}")
            emit_line(f";-----------------------------------------------------------------------------")

# Main disassembly loop
offset = 0x0048  # Start after jump table
while offset < SIZE:
    addr = BASE + offset

    # Check for section headers
    maybe_emit_section(addr)

    # Check for data region label
    dl = get_data_label(offset)
    if dl:
        emit_blank()
        emit_line(f"; --- Data Region: {dl} ---")

    # Data region handling
    if is_data(offset):
        start = offset
        region_end = offset
        for s, e, _ in DATA_REGIONS:
            if s <= offset < e:
                region_end = e
                break
        while offset < region_end:
            chunk = data[offset:min(offset+16, region_end)]
            emit_data_row(chunk, BASE + offset)
            offset += len(chunk)
        continue

    # Check for label
    if addr in label_map:
        emit_label(addr)

    # Decode instruction
    op = data[offset]
    if op not in OPCODE_TABLE:
        emit_instruction(f".byte ${op:02X}", addr, f"{op:02X}")
        offset += 1
        continue

    mn, mode = OPCODE_TABLE[op]
    sz = SIZES[mode]
    if offset + sz > SIZE:
        emit_instruction(f".byte ${op:02X}", addr, f"{op:02X}")
        offset += 1
        continue

    ob = data[offset+1:offset+sz]
    byte_hex = ' '.join(f'{data[offset+i]:02X}' for i in range(sz))

    # Format operand
    if mode == 'imp': operand = ""
    elif mode == 'acc': operand = "A"
    elif mode == 'imm': operand = f"#${ob[0]:02X}"
    elif mode == 'zp': operand = f"${ob[0]:02X}"
    elif mode == 'zpx': operand = f"${ob[0]:02X},X"
    elif mode == 'zpy': operand = f"${ob[0]:02X},Y"
    elif mode == 'abs':
        val = ob[0] | (ob[1] << 8)
        if mn == 'JSR':
            operand = B1F_NAMES.get(val, label_map.get(val, f"${val:04X}"))
        elif mn == 'JMP':
            operand = label_map.get(val, f"${val:04X}")
        else:
            operand = f"${val:04X}"
    elif mode == 'abx': operand = f"${(ob[0] | (ob[1] << 8)):04X},X"
    elif mode == 'aby': operand = f"${(ob[0] | (ob[1] << 8)):04X},Y"
    elif mode == 'ind': operand = f"(${(ob[0] | (ob[1] << 8)):04X})"
    elif mode == 'izx': operand = f"(${ob[0]:02X},X)"
    elif mode == 'izy': operand = f"(${ob[0]:02X}),Y"
    elif mode == 'rel':
        b_off = ob[0]
        if b_off >= 0x80: b_off -= 256
        target = addr + 2 + b_off
        operand = label_map.get(target, f"${target:04X}")
    else: operand = "???"

    instr = f"{mn} {operand}" if operand else mn

    # Add section separator before major entry point transitions
    if mn == 'RTS':
        emit_instruction(instr, addr, byte_hex)
        offset += sz
        continue

    emit_instruction(instr, addr, byte_hex)
    offset += sz

# =============================================================================
# Write output
# =============================================================================
result = '\n'.join(out) + '\n'
with open('/tmp/prg_1d_final.asm', 'w') as f:
    f.write(result)

print(f"Generated {len(out)} lines to /tmp/prg_1d_final.asm")

# =============================================================================
# Verification: count bytes covered
# =============================================================================
total_bytes = 0
in_code = False
for line in out:
    line = line.strip()
    if '; $' in line and ':' in line:
        comment_part = line.split(';')[-1].strip()
        # Extract byte count from the hex bytes after the colon
        if ': ' in comment_part:
            hex_part = comment_part.split(': ', 1)[1]
            byte_count = len(hex_part.split())
            total_bytes += byte_count

print(f"Total bytes covered: {total_bytes} / {SIZE}")
if total_bytes != SIZE:
    print(f"WARNING: Coverage mismatch! Missing {SIZE - total_bytes} bytes")
else:
    print("SUCCESS: All 8192 bytes covered!")
