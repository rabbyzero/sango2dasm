#!/usr/bin/env python3
"""Disassemble prg_1e.bin ($C000-$DFFF) - Sangokushi 2 Bank $1E.

Two-pass disassembler with procedure detection and data region identification.
"""

import sys

BASE = 0xC000
with open("rom/prg/prg_1e.bin", "rb") as f:
    data = f.read()
SIZE = len(data)

# === 6502 Opcode Table ===
OPCODES = {
    0x00:("BRK","imp"),0x01:("ORA","izx"),0x05:("ORA","zp"),0x06:("ASL","zp"),
    0x08:("PHP","imp"),0x09:("ORA","imm"),0x0A:("ASL","acc"),
    0x0B:("NOP","imm"),0x0D:("ORA","abs"),0x0E:("ASL","abs"),
    0x10:("BPL","rel"),0x11:("ORA","izy"),0x15:("ORA","zpx"),0x16:("ASL","zpx"),
    0x18:("CLC","imp"),0x19:("ORA","aby"),0x1A:("NOP","imp"),0x1D:("ORA","abx"),0x1E:("ASL","abx"),
    0x20:("JSR","abs"),0x21:("AND","izx"),0x24:("BIT","zp"),0x25:("AND","zp"),0x26:("ROL","zp"),
    0x28:("PLP","imp"),0x29:("AND","imm"),0x2A:("ROL","acc"),
    0x2B:("NOP","imm"),0x2C:("BIT","abs"),0x2D:("AND","abs"),0x2E:("ROL","abs"),
    0x30:("BMI","rel"),0x31:("AND","izy"),0x35:("AND","zpx"),0x36:("ROL","zpx"),
    0x38:("SEC","imp"),0x39:("AND","aby"),0x3A:("NOP","imp"),0x3D:("AND","abx"),0x3E:("ROL","abx"),
    0x40:("RTI","imp"),0x41:("EOR","izx"),0x45:("EOR","zp"),0x46:("LSR","zp"),
    0x48:("PHA","imp"),0x49:("EOR","imm"),0x4A:("LSR","acc"),
    0x4B:("NOP","imm"),0x4C:("JMP","abs"),0x4D:("EOR","abs"),0x4E:("LSR","abs"),
    0x50:("BVC","rel"),0x51:("EOR","izy"),0x55:("EOR","zpx"),0x56:("LSR","zpx"),
    0x58:("CLI","imp"),0x59:("EOR","aby"),0x5A:("NOP","imp"),0x5D:("EOR","abx"),0x5E:("LSR","abx"),
    0x60:("RTS","imp"),0x61:("ADC","izx"),0x65:("ADC","zp"),0x66:("ROR","zp"),
    0x68:("PLA","imp"),0x69:("ADC","imm"),0x6A:("ROR","acc"),
    0x6B:("NOP","imm"),0x6C:("JMP","ind"),0x6D:("ADC","abs"),0x6E:("ROR","abs"),
    0x70:("BVS","rel"),0x71:("ADC","izy"),0x75:("ADC","zpx"),0x76:("ROR","zpx"),
    0x78:("SEI","imp"),0x79:("ADC","aby"),0x7A:("NOP","imp"),0x7D:("ADC","abx"),0x7E:("ROR","abx"),
    0x80:("NOP","imm"),0x81:("STA","izx"),0x82:("NOP","imm"),
    0x84:("STY","zp"),0x85:("STA","zp"),0x86:("STX","zp"),
    0x88:("DEY","imp"),0x89:("NOP","imm"),0x8A:("TXA","imp"),
    0x8B:("NOP","imm"),0x8C:("STY","abs"),0x8D:("STA","abs"),0x8E:("STX","abs"),
    0x90:("BCC","rel"),0x91:("STA","izy"),0x94:("STY","zpx"),0x95:("STA","zpx"),0x96:("STX","zpy"),
    0x98:("TYA","imp"),0x99:("STA","aby"),
    0x9A:("TXS","imp"),0x9B:("NOP","aby"),0x9C:("NOP","abx"),0x9D:("STA","abx"),0x9E:("NOP","abx"),0x9F:("NOP","aby"),
    0xA0:("LDY","imm"),0xA1:("LDA","izx"),0xA2:("LDX","imm"),
    0xA4:("LDY","zp"),0xA5:("LDA","zp"),0xA6:("LDX","zp"),
    0xA8:("TAY","imp"),0xA9:("LDA","imm"),0xAA:("TAX","imp"),
    0xAB:("NOP","imm"),0xAC:("LDY","abs"),0xAD:("LDA","abs"),0xAE:("LDX","abs"),
    0xB0:("BCS","rel"),0xB1:("LDA","izy"),0xB4:("LDY","zpx"),0xB5:("LDA","zpx"),0xB6:("LDX","zpy"),
    0xB8:("CLV","imp"),0xB9:("LDA","aby"),0xBA:("TSX","imp"),
    0xBB:("NOP","aby"),0xBC:("LDY","abx"),0xBD:("LDA","abx"),0xBE:("LDX","aby"),0xBF:("NOP","aby"),
    0xC0:("CPY","imm"),0xC1:("CMP","izx"),0xC2:("NOP","imm"),
    0xC4:("CPY","zp"),0xC5:("CMP","zp"),0xC6:("DEC","zp"),
    0xC8:("INY","imp"),0xC9:("CMP","imm"),0xCA:("DEX","imp"),
    0xCB:("NOP","imm"),0xCC:("CPY","abs"),0xCD:("CMP","abs"),0xCE:("DEC","abs"),
    0xD0:("BNE","rel"),0xD1:("CMP","izy"),0xD5:("CMP","zpx"),0xD6:("DEC","zpx"),
    0xD8:("CLD","imp"),0xD9:("CMP","aby"),
    0xDA:("NOP","imp"),0xDB:("NOP","aby"),0xDD:("CMP","abx"),0xDE:("DEC","abx"),0xDF:("NOP","aby"),
    0xE0:("CPX","imm"),0xE1:("SBC","izx"),0xE2:("NOP","imm"),
    0xE4:("CPX","zp"),0xE5:("SBC","zp"),0xE6:("INC","zp"),
    0xE8:("INX","imp"),0xE9:("SBC","imm"),0xEA:("NOP","imp"),
    0xEB:("NOP","imm"),0xEC:("CPX","abs"),0xED:("SBC","abs"),0xEE:("INC","abs"),
    0xF0:("BEQ","rel"),0xF1:("SBC","izy"),0xF5:("SBC","zpx"),0xF6:("INC","zpx"),
    0xF8:("SED","imp"),0xF9:("SBC","aby"),
    0xFA:("NOP","imp"),0xFB:("NOP","aby"),0xFD:("SBC","abx"),0xFE:("INC","abx"),0xFF:("NOP","aby"),
}

def mode_size(mode):
    return {"imp":1,"acc":1,"imm":2,"zp":2,"zpx":2,"zpy":2,"abs":3,"abx":3,"aby":3,"ind":3,"izx":2,"izy":2,"rel":2}[mode]

# Bank $1F function names
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

# ===== PASS 1: Linear sweep =====
# Decode every instruction, building list of (offset, size, is_code)
instructions = []  # list of (offset, size)
pos = 0
while pos < SIZE:
    opbyte = data[pos]
    if opbyte in OPCODES:
        mn, mode = OPCODES[opbyte]
        sz = mode_size(mode)
        if pos + sz > SIZE:
            instructions.append((pos, 1, False))
            pos += 1
        else:
            instructions.append((pos, sz, True))
            pos += sz
    else:
        instructions.append((pos, 1, False))
        pos += 1

# Build offset->(size,is_code) map
instr_map = {}
for (off, sz, is_code) in instructions:
    instr_map[off] = (sz, is_code)

# ===== PASS 2: Find targets and build label map =====
labels = {}

def add_label(addr, prefix="L"):
    if addr not in labels:
        labels[addr] = f"{prefix}_{addr:04X}"
    return labels[addr]

for (off, sz, is_code) in instructions:
    if not is_code:
        continue
    addr = BASE + off
    opbyte = data[off]
    mn, mode = OPCODES[opbyte]
    
    if mode == "rel":
        offset = data[off+1]
        if offset >= 0x80:
            offset -= 0x100
        target = addr + 2 + offset
        if BASE <= target < BASE + SIZE:
            add_label(target, "L")
    elif mode == "abs" and opbyte in (0x4C, 0x20):
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE:
            add_label(target, "L")

# Add entry point
add_label(BASE, "Entry")

# ===== PASS 3: Identify procedures =====
# A procedure is a block of code that starts at a JSR target (or entry) and ends at RTS or JMP
# We trace execution flow to find procedure boundaries

proc_starts = set()
proc_starts.add(BASE)

# Add all JSR targets within this bank
for (off, sz, is_code) in instructions:
    if not is_code:
        continue
    opbyte = data[off]
    if opbyte == 0x20:  # JSR
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE:
            proc_starts.add(target)

# Find procedure ends (RTS or unconditional JMP)
# For each proc start, find its end
def find_proc_end(start_off):
    """Find the end offset (inclusive, last byte) of a procedure starting at start_off."""
    pos = start_off
    while pos < SIZE:
        if pos not in instr_map:
            pos += 1
            continue
        sz, is_code = instr_map[pos]
        if is_code:
            opbyte = data[pos]
            if opbyte == 0x60:  # RTS
                return pos + sz - 1
            if opbyte == 0x4C:  # JMP abs
                target = data[pos+1] | (data[pos+2] << 8)
                # If jumping to a different proc, this is the end
                if target != BASE + pos:  # not self-loop
                    return pos + sz - 1
        pos += sz
    return SIZE - 1

proc_ranges = []
for start in sorted(proc_starts):
    start_off = start - BASE
    end_off = find_proc_end(start_off)
    proc_ranges.append((start_off, end_off))

# Mark code coverage
code_bytes = set()
for (start_off, end_off) in proc_ranges:
    pos = start_off
    while pos <= end_off and pos < SIZE:
        if pos not in instr_map:
            code_bytes.add(pos)
            pos += 1
            continue
        sz, is_code = instr_map[pos]
        for i in range(sz):
            code_bytes.add(pos + i)
        pos += sz

# ===== Name the procedures =====
# Analyze each procedure for naming
def get_jsr_targets(start_off, end_off):
    targets = []
    pos = start_off
    while pos <= end_off and pos < SIZE:
        if pos not in instr_map:
            pos += 1
            continue
        sz, is_code = instr_map[pos]
        if is_code and data[pos] == 0x20:  # JSR
            target = data[pos+1] | (data[pos+2] << 8)
            targets.append(target)
        pos += sz
    return targets

def get_stores(start_off, end_off):
    stores = []
    pos = start_off
    while pos <= end_off and pos < SIZE:
        if pos not in instr_map:
            pos += 1
            continue
        sz, is_code = instr_map[pos]
        if is_code and data[pos] == 0x8D:  # STA abs
            addr = data[pos+1] | (data[pos+2] << 8)
            stores.append(addr)
        pos += sz
    return stores

PROC_NAMES = {}
proc_idx = 0

# Specific analysis for each procedure
for (start_off, end_off) in proc_ranges:
    addr = BASE + start_off
    jsrs = get_jsr_targets(start_off, end_off)
    stores = get_stores(start_off, end_off)
    
    has_switch8b = 0xF25F in jsrs
    has_switch8a = 0xF266 in jsrs
    has_callback = 0xEADE in jsrs
    has_trampoline = 0xEE07 in jsrs
    has_mul = 0xEBE9 in jsrs
    has_bcd = 0xE9BA in jsrs
    has_province = 0xF2AF in jsrs
    has_officer = 0xF2D7 in jsrs
    
    if addr == 0xC000:
        name = "InitDomesticState"
    elif addr == 0xC010:
        name = "DomAction_01_DisplaySetup"
    elif addr == 0xC05E:
        name = "DomAction_02_LandDevelop"
    elif addr == 0xC090:
        name = "DomAction_03_Commerce"
    elif addr == 0xC09E:
        name = "DomAction_04_FloodControl"
    elif addr == 0xC0F4:
        name = "DomAction_05_RoadBuild"
    elif addr == 0xC138:
        name = "DomAction_06_CastleRepair"
    elif addr == 0xC169:
        name = "DomAction_07_TaxRate"
    elif addr == 0xC18F:
        name = "DomAction_08_GoldDistribution"
    elif addr == 0xC1C0:
        name = "DomAction_09_FoodDistribution"
    elif addr == 0xC252:
        name = "DomAction_0A_Recruit"
    elif addr == 0xC2E6:
        name = "DomAction_0B_HireOfficer"
    elif addr == 0xC340:
        name = "DomAction_0C_TransferOfficer"
    elif addr == 0xC38F:
        name = "DomAction_0D_ExecuteOfficer"
    elif addr == 0xC3E6:
        name = "DomAction_0E_ExileOfficer"
    elif addr == 0xC440:
        name = "DomAction_0F_GiveItem"
    elif addr == 0xC497:
        name = "DomAction_10_MoveCapital"
    elif addr == 0xC4EB:
        name = "DomAction_11_Diplomacy"
    elif addr == 0xC549:
        name = "DomAction_12_War"
    elif addr == 0xC59C:
        name = "DomAction_13_SpyDispatch"
    elif addr == 0xC5B2:
        name = "DomAction_14_Accounting"
    elif addr == 0xC5DE:
        name = "DomAction_15_Exchange"
    elif addr == 0xC638:
        name = "DomAction_16_Trade"
    elif addr == 0xC66E:
        name = "DomAction_17_SearchOfficer"
    elif addr == 0xC6C8:
        name = "DomAction_18_SearchItem"
    elif addr == 0xC71F:
        name = "DomAction_19_InspectLand"
    elif addr == 0xC739:
        name = "DomAction_1A_PersonalAffairs"
    elif addr == 0xC749:
        name = "DomAction_1B_Resign"
    elif addr == 0xC759:
        name = "DomesticActionDispatch"
    elif addr == 0xC790:
        name = "DispatchTileData"
    elif addr == 0xC7B9:
        name = "SaveStateAndReturn"
    elif addr == 0xC7E1:
        name = "SetupActionDisplay"
    elif addr == 0xC81E:
        name = "CopyTileRow"
    elif addr == 0xC844:
        name = "ActionDisplaySetup2"
    elif addr == 0xC885:
        name = "ActionDisplaySetup3"
    elif addr == 0xC8C8:
        name = "ActionParamCalc"
    elif addr == 0xC910:
        name = "LoadSramData"
    elif addr == 0xC94E:
        name = "SetupSaveRegion1"
    elif addr == 0xC9A7:
        name = "SetupSaveRegion2"
    elif addr == 0xC9D7:
        name = "ComputeChecksum"
    elif addr == 0xC9F7:
        name = "LookupAndDispatch"
    elif addr == 0xCA0F:
        name = "OfficerParamLookup"
    elif addr == 0xCA45:
        name = "ProvinceParamLookup"
    else:
        proc_idx += 1
        name = f"Proc_{addr:04X}"
    
    PROC_NAMES[start_off] = name

# ===== OUTPUT =====
output = []
output.append(";===============================================================================")
output.append("; PRG Bank $1E - $C000-$DFFF")
output.append("; Sangokushi 2 - Haou no Tairiku (J)")
output.append("; Namco-163 Mapper 19")
output.append(";")
output.append("; Domestic affairs action dispatch and tile data setup.")
output.append("; Called from bank $1D via cross-bank JSR to $C000-$DFFF.")
output.append(";===============================================================================")
output.append("")
output.append('.segment "CODE_BANK1E"')
output.append("")

# Build a set of data region offsets (not covered by any procedure)
data_offsets = set(range(SIZE)) - code_bytes

def format_line(off, sz, text):
    """Format an assembly line with inline byte comment."""
    addr = BASE + off
    bs = " ".join(f"{data[off+i]:02X}" for i in range(sz))
    pad = max(1, 56 - len(text))
    return f"{text}{' ' * pad}; ${addr:04X}: {bs}"

def format_data_line(off, count):
    """Format .byte data line with up to 16 bytes."""
    addr = BASE + off
    bs = " ".join(f"{data[off+i]:02X}" for i in range(count))
    vals = ",".join(f"${data[off+i]:02X}" for i in range(count))
    text = f"  .byte {vals}"
    pad = max(1, 56 - len(text))
    return f"{text}{' ' * pad}; ${addr:04X}: {bs}"

# Generate output
current_proc = None
pos = 0

while pos < SIZE:
    addr = BASE + pos
    
    # Check for procedure start
    if pos in PROC_NAMES:
        if current_proc is not None:
            output.append(".endproc")
            output.append("")
        name = PROC_NAMES[pos]
        output.append(f";===============================================================================")
        output.append(f"; ${addr:04X}: {name}")
        output.append(f";===============================================================================")
        output.append(f".proc {name}")
        current_proc = pos
    
    # Check for label (branch/jump target within a procedure)
    if addr in labels and pos not in PROC_NAMES:
        output.append(f"{labels[addr]}:")
    
    # Data region
    if pos not in code_bytes:
        # Collect consecutive data bytes (up to 16)
        count = 0
        while pos + count < SIZE and (pos + count) not in code_bytes and count < 16:
            # Stop if next byte starts a label
            if count > 0 and (BASE + pos + count) in labels:
                break
            if count > 0 and (pos + count) in PROC_NAMES:
                break
            count += 1
        output.append(format_data_line(pos, count))
        pos += count
        continue
    
    # Code instruction
    if pos in instr_map:
        sz, is_code = instr_map[pos]
        if is_code:
            opbyte = data[pos]
            mn, mode = OPCODES[opbyte]
            
            # Build operand string
            operand = ""
            if mode == "imp":
                operand = ""
            elif mode == "acc":
                operand = "A"
            elif mode == "imm":
                operand = f"#${data[pos+1]:02X}"
            elif mode == "zp":
                operand = f"${data[pos+1]:02X}"
            elif mode == "zpx":
                operand = f"${data[pos+1]:02X},X"
            elif mode == "zpy":
                operand = f"${data[pos+1]:02X},Y"
            elif mode == "abs":
                target = data[pos+1] | (data[pos+2] << 8)
                # Use label if intra-bank
                if BASE <= target < BASE + SIZE and target in labels:
                    operand = labels[target]
                elif BASE <= target < BASE + SIZE and target in [BASE + p for p in PROC_NAMES]:
                    # Find proc name
                    for p, n in PROC_NAMES.items():
                        if BASE + p == target:
                            operand = n
                            break
                    else:
                        operand = f"${target:04X}"
                elif opbyte == 0x20 and target in B1F_NAMES:
                    operand = B1F_NAMES[target]
                else:
                    operand = f"${target:04X}"
            elif mode == "abx":
                target = data[pos+1] | (data[pos+2] << 8)
                operand = f"${target:04X},X"
            elif mode == "aby":
                target = data[pos+1] | (data[pos+2] << 8)
                operand = f"${target:04X},Y"
            elif mode == "ind":
                target = data[pos+1] | (data[pos+2] << 8)
                operand = f"(${target:04X})"
            elif mode == "izx":
                operand = f"(${data[pos+1]:02X},X)"
            elif mode == "izy":
                operand = f"(${data[pos+1]:02X}),Y"
            elif mode == "rel":
                offset = data[pos+1]
                if offset >= 0x80:
                    offset -= 0x100
                target = addr + 2 + offset
                if BASE <= target < BASE + SIZE and target in labels:
                    operand = labels[target]
                elif BASE <= target < BASE + SIZE:
                    # Check if target is a proc start
                    for p, n in PROC_NAMES.items():
                        if BASE + p == target:
                            operand = n
                            break
                    else:
                        operand = f"${target:04X}"
                else:
                    operand = f"${target:04X}"
            
            if operand:
                text = f"  {mn} {operand}"
            else:
                text = f"  {mn}"
            
            output.append(format_line(pos, sz, text))
            pos += sz
        else:
            # Single unknown byte
            output.append(format_data_line(pos, 1))
            pos += 1
    else:
        output.append(format_data_line(pos, 1))
        pos += 1

if current_proc is not None:
    output.append(".endproc")

# Print result
result = "\n".join(output)

# Verify byte count
total_bytes = 0
for line in output:
    if "; $" in line and ":" in line.split("; $")[1]:
        parts = line.split("; $")[1]
        addr_hex = parts.split(":")[0]
        byte_str = parts.split(":")[1].strip()
        total_bytes += len(byte_str.split())

print(f"; Total bytes covered: {total_bytes} / {SIZE}", file=sys.stderr)
if total_bytes != SIZE:
    print(f"WARNING: Byte count mismatch!", file=sys.stderr)

print(result)
