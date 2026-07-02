#!/usr/bin/env python3
"""
Definitive disassembler for prg_1e.bin ($C000-$DFFF).
Uses RTS/JMP positions to find procedure boundaries, then linearly disassembles.
"""
import sys

BASE = 0xC000
with open("rom/prg/prg_1e.bin", "rb") as f:
    data = bytearray(f.read())
SIZE = len(data)

# ===== 6502 Opcode Table =====
# (mnemonic, size)
OPTAB = {}
def _build():
    imp = [0x00,0x08,0x18,0x28,0x38,0x40,0x48,0x58,0x60,0x68,0x78,0x88,0x8A,
           0x98,0x9A,0xA8,0xAA,0xB8,0xBA,0xC8,0xCA,0xD8,0xE8,0xEA,0xF8,
           0x0A,0x2A,0x4A,0x6A,  # acc (same as imp for size)
           0x1A,0x3A,0x5A,0x7A,0xDA,0xFA]  # illegal NOPs
    imm = [0x09,0x29,0x49,0x69,0xA9,0xC9,0xE9,0xA0,0xC0,0xE0,0xA2,
           0x80,0x82,0xC2,0xE2,0x89,0x0B,0x2B,0x4B,0x6B,0x8B,0xAB,0xCB,0xEB]
    zp  = [0x05,0x25,0x45,0x65,0x85,0xA5,0xC5,0xE5,0x06,0x26,0x46,0x66,
           0x86,0xA6,0xC6,0xE6,0x24,0x84,0xA4,0xC4,0xE4]
    zpx = [0x15,0x35,0x55,0x75,0x95,0xB5,0xD5,0xF5,0x16,0x36,0x56,0x76,
           0xD6,0xF6,0x94,0xB4]
    zpy = [0x96,0xB6]
    abso= [0x0D,0x2D,0x4D,0x6D,0x8D,0xAD,0xCD,0xED,0x0E,0x2E,0x4E,0x6E,
           0x8E,0xAE,0xCE,0xEE,0x2C,0x8C,0xAC,0xCC,0xEC,0x20,0x4C]
    abx = [0x1D,0x3D,0x5D,0x7D,0x9D,0xBD,0xDD,0xFD,0x1E,0x3E,0x5E,0x7E,
           0xDE,0xFE,0xBC,0x9C,0x9E]
    aby = [0x19,0x39,0x59,0x79,0x99,0xB9,0xD9,0xF9,0xBE,
           0x9B,0x9F,0xBB,0xBF,0xDB,0xFB,0xFF]
    ind = [0x6C]
    izx = [0x01,0x21,0x41,0x61,0x81,0xA1,0xC1,0xE1]
    izy = [0x11,0x31,0x51,0x71,0x91,0xB1,0xD1,0xF1]
    rel = [0x10,0x30,0x50,0x70,0x90,0xB0,0xD0,0xF0]
    
    names = {
        0x00:"BRK",0x01:"ORA",0x05:"ORA",0x06:"ASL",0x08:"PHP",0x09:"ORA",
        0x0A:"ASL",0x0B:"NOP",0x0D:"ORA",0x0E:"ASL",0x10:"BPL",0x11:"ORA",
        0x15:"ORA",0x16:"ASL",0x18:"CLC",0x19:"ORA",0x1A:"NOP",0x1D:"ORA",
        0x1E:"ASL",0x20:"JSR",0x21:"AND",0x24:"BIT",0x25:"AND",0x26:"ROL",
        0x28:"PLP",0x29:"AND",0x2A:"ROL",0x2B:"NOP",0x2C:"BIT",0x2D:"AND",
        0x2E:"ROL",0x30:"BMI",0x31:"AND",0x35:"AND",0x36:"ROL",0x38:"SEC",
        0x39:"AND",0x3A:"NOP",0x3D:"AND",0x3E:"ROL",0x40:"RTI",0x41:"EOR",
        0x45:"EOR",0x46:"LSR",0x48:"PHA",0x49:"EOR",0x4A:"LSR",0x4B:"NOP",
        0x4C:"JMP",0x4D:"EOR",0x4E:"LSR",0x50:"BVC",0x51:"EOR",0x55:"EOR",
        0x56:"LSR",0x58:"CLI",0x59:"EOR",0x5A:"NOP",0x5D:"EOR",0x5E:"LSR",
        0x60:"RTS",0x61:"ADC",0x65:"ADC",0x66:"ROR",0x68:"PLA",0x69:"ADC",
        0x6A:"ROR",0x6B:"NOP",0x6C:"JMP",0x6D:"ADC",0x6E:"ROR",0x70:"BVS",
        0x71:"ADC",0x75:"ADC",0x76:"ROR",0x78:"SEI",0x79:"ADC",0x7A:"NOP",
        0x7D:"ADC",0x7E:"ROR",0x80:"NOP",0x81:"STA",0x82:"NOP",0x84:"STY",
        0x85:"STA",0x86:"STX",0x88:"DEY",0x89:"NOP",0x8A:"TXA",0x8B:"NOP",
        0x8C:"STY",0x8D:"STA",0x8E:"STX",0x90:"BCC",0x91:"STA",0x94:"STY",
        0x95:"STA",0x96:"STX",0x98:"TYA",0x99:"STA",0x9A:"TXS",0x9B:"NOP",
        0x9C:"NOP",0x9D:"STA",0x9E:"NOP",0x9F:"NOP",0xA0:"LDY",0xA1:"LDA",
        0xA2:"LDX",0xA4:"LDY",0xA5:"LDA",0xA6:"LDX",0xA8:"TAY",0xA9:"LDA",
        0xAA:"TAX",0xAB:"NOP",0xAC:"LDY",0xAD:"LDA",0xAE:"LDX",0xB0:"BCS",
        0xB1:"LDA",0xB4:"LDY",0xB5:"LDA",0xB6:"LDX",0xB8:"CLV",0xB9:"LDA",
        0xBA:"TSX",0xBB:"NOP",0xBC:"LDY",0xBD:"LDA",0xBE:"LDX",0xBF:"NOP",
        0xC0:"CPY",0xC1:"CMP",0xC2:"NOP",0xC4:"CPY",0xC5:"CMP",0xC6:"DEC",
        0xC8:"INY",0xC9:"CMP",0xCA:"DEX",0xCB:"NOP",0xCC:"CPY",0xCD:"CMP",
        0xCE:"DEC",0xD0:"BNE",0xD1:"CMP",0xD5:"CMP",0xD6:"DEC",0xD8:"CLD",
        0xD9:"CMP",0xDA:"NOP",0xDB:"NOP",0xDD:"CMP",0xDE:"DEC",0xDF:"NOP",
        0xE0:"CPX",0xE1:"SBC",0xE2:"NOP",0xE4:"CPX",0xE5:"SBC",0xE6:"INC",
        0xE8:"INX",0xE9:"SBC",0xEA:"NOP",0xEB:"NOP",0xEC:"CPX",0xED:"SBC",
        0xEE:"INC",0xF0:"BEQ",0xF1:"SBC",0xF5:"SBC",0xF6:"INC",0xF8:"SED",
        0xF9:"SBC",0xFA:"NOP",0xFB:"NOP",0xFD:"SBC",0xFE:"INC",0xFF:"NOP",
    }
    
    for o in imp:
        OPTAB[o] = (names.get(o,"???"), 1, "imp")
    for o in rel:
        OPTAB[o] = (names.get(o,"???"), 2, "rel")
    for o in imm:
        OPTAB[o] = (names.get(o,"???"), 2, "imm")
    for o in zp:
        OPTAB[o] = (names.get(o,"???"), 2, "zp")
    for o in zpx:
        OPTAB[o] = (names.get(o,"???"), 2, "zpx")
    for o in zpy:
        OPTAB[o] = (names.get(o,"???"), 2, "zpy")
    for o in abso:
        OPTAB[o] = (names.get(o,"???"), 3, "abs")
    for o in abx:
        OPTAB[o] = (names.get(o,"???"), 3, "abx")
    for o in aby:
        OPTAB[o] = (names.get(o,"???"), 3, "aby")
    for o in ind:
        OPTAB[o] = (names.get(o,"???"), 3, "ind")
    for o in izx:
        OPTAB[o] = (names.get(o,"???"), 2, "izx")
    for o in izy:
        OPTAB[o] = (names.get(o,"???"), 2, "izy")

_build()

# Bank $1F symbols
B1F = {
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

# ===== Find all RTS positions (procedure ends) =====
rts_positions = set()
for i in range(SIZE):
    if data[i] == 0x60:
        rts_positions.add(i)

# ===== Decode instructions linearly =====
# Build instruction map: offset -> (mnemonic, size, mode, valid)
imap = {}
pos = 0
while pos < SIZE:
    opbyte = data[pos]
    if opbyte in OPTAB:
        mn, sz, mode = OPTAB[opbyte]
        if pos + sz <= SIZE:
            imap[pos] = (mn, sz, mode, True)
            pos += sz
        else:
            imap[pos] = ("???", 1, "data", False)
            pos += 1
    else:
        imap[pos] = ("???", 1, "data", False)
        pos += 1

# ===== Find procedure boundaries =====
# A procedure: starts at some entry, runs until RTS or JMP-to-different-proc
# We identify procedures by scanning for patterns:
#   - Entry at $C000
#   - Each section that starts with LDA #$xx / STA $0010 (tile pointer setup)
#   - Ends at RTS or JMP $C934

# Collect all JMP $C934 positions
jmp_common = set()
for off, (mn, sz, mode, valid) in imap.items():
    if valid and mn == "JMP" and mode == "abs":
        target = data[off+1] | (data[off+2] << 8)
        if target == 0xC934:
            jmp_common.add(off)

# Now identify procedure boundaries
# Procedure ends at: RTS or JMP $C934 (whichever comes first after the start)
# Data tables may appear between JMP $C934 and the next procedure

# Sort all "terminators": RTS positions and JMP $C934 positions
terminators = sorted(rts_positions | jmp_common)

# For each known procedure start, find its terminator
# Known starts: $C000 (entry), and every address that appears as a target of JSR from outside
# Plus addresses that follow a known pattern

# Collect JSR targets within bank
jsr_targets_in_bank = set()
for off, (mn, sz, mode, valid) in imap.items():
    if valid and mn == "JSR":
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE:
            jsr_targets_in_bank.add(target - BASE)

# Also JMP targets within bank (that aren't $C934)
jmp_targets_in_bank = set()
for off, (mn, sz, mode, valid) in imap.items():
    if valid and mn == "JMP" and mode == "abs":
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE and target != 0xC934:
            jmp_targets_in_bank.add(target - BASE)

# All potential entry points
entry_points = set([0])  # $C000
entry_points |= jsr_targets_in_bank
entry_points |= jmp_targets_in_bank

# Also add entries based on the "LDA #$xx / STA $0010" pattern
for off in range(SIZE - 5):
    if data[off] == 0xA9 and data[off+2] == 0x8D and data[off+3] == 0x10 and data[off+4] == 0x00:
        entry_points.add(off)

# Now build procedure list: (start_off, end_off_inclusive)
procedures = []
sorted_entries = sorted(entry_points)

for i, start in enumerate(sorted_entries):
    # Find the first terminator at or after start
    end = None
    for t in terminators:
        if t >= start:
            end = t
            break
    if end is None:
        end = SIZE - 1
    
    # Check if this start is actually within a previous procedure
    if procedures and start <= procedures[-1][1]:
        # It's inside a previous proc, might be a sub-label
        continue
    
    procedures.append((start, end))

# Now build code coverage: mark all bytes within procedures as code
code_bytes = set()
for (start, end) in procedures:
    pos = start
    while pos <= end and pos < SIZE:
        if pos in imap:
            mn, sz, mode, valid = imap[pos]
            if valid:
                for j in range(sz):
                    code_bytes.add(pos + j)
                pos += sz
            else:
                pos += 1
        else:
            pos += 1

# ===== Build labels =====
labels = {}

def set_label(addr, name=None):
    if addr not in labels:
        labels[addr] = name if name else f"L_{addr:04X}"

# Pre-define important labels
set_label(0xC000, "Bank1E_Init")
set_label(0xC934, "CommonReturn")
set_label(0xC96D, "SetupDisplayPtrs")
set_label(0xC98A, "ResetDispatchState")
set_label(0xC994, "DisplayTileData")

# Collect branch targets
for off, (mn, sz, mode, valid) in imap.items():
    if valid and mode == "rel":
        addr = BASE + off
        delta = data[off+1]
        if delta >= 128:
            delta -= 256
        target = addr + 2 + delta
        if BASE <= target < BASE + SIZE:
            set_label(target)

# Collect JMP/JSR targets within bank
for off, (mn, sz, mode, valid) in imap.items():
    if valid and mn in ("JMP", "JSR") and mode == "abs":
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE:
            if target not in labels:
                set_label(target)

# ===== Name procedures based on analysis =====
PROC_NAMES = {}

# Analyze each procedure
for (start, end) in procedures:
    addr = BASE + start
    
    # Look at first few bytes for pattern identification
    first_bytes = data[start:start+min(10, SIZE-start)]
    
    # Collect JSR targets
    jsrs = []
    p = start
    while p <= end and p < SIZE:
        if p in imap:
            mn, sz, mode, valid = imap[p]
            if valid and mn == "JSR":
                target = data[p+1] | (data[p+2] << 8)
                jsrs.append(target)
            p += sz
        else:
            p += 1
    
    # Collect STA targets
    stas = []
    p = start
    while p <= end and p < SIZE:
        if p in imap:
            mn, sz, mode, valid = imap[p]
            if valid and mn == "STA" and mode == "abs":
                target = data[p+1] | (data[p+2] << 8)
                stas.append(target)
            p += sz
        else:
            p += 1
    
    # Assign name based on address and patterns
    if addr == 0xC000:
        name = "Bank1E_Init"
    elif addr == 0xC934:
        name = "CommonReturn"
    elif addr == 0xC96D:
        name = "SetupDisplayPtrs"
    elif addr == 0xC98A:
        name = "ResetDispatchState"
    elif addr == 0xC994:
        name = "DisplayTileData"
    elif 0xF25F in jsrs:
        name = f"Action_{addr:04X}_BankSwitch"
    elif 0x0010 in stas and 0x0011 in stas:
        name = f"DomAction_{addr:04X}"
    elif len(jsrs) == 0 and end - start < 20:
        name = f"ShortProc_{addr:04X}"
    else:
        name = f"Proc_{addr:04X}"
    
    PROC_NAMES[start] = name
    set_label(addr, name)

# Override specific procedure names based on manual analysis
OVERRIDES = {
    0x0000: "Bank1E_Init",
    0x0010: "Action01_Init",
    0x0049: "Action01_Callback",
    0x005E: "Action02_LandDevelop",
    0x0090: "Action03_Callback",
    0x009E: "Action04_FloodControl",
    0x00C8: "Action04_Callback",
    0x00E7: "Action05_RoadBuild",
    0x011A: "Action05_Callback",
    0x0136: "Action06_CastleRepair",
    0x017B: "Action07_TaxRate",
    0x01CA: "Action08_GoldDist",
    0x0218: "Action09_FoodDist",
    0x0252: "Action0A_Recruit",
    0x028A: "Action0B_HireOfficer",
    0x02F0: "Action0C_TransferOfficer",
    0x0350: "Action0D_ExecuteOfficer",
    0x03BA: "Action0E_ExileOfficer",
    0x0414: "Action0F_GiveItem",
    0x047A: "Action10_MoveCapital",
    0x049E: "Action10_Callback",
    0x04AC: "Action10_Continue",
    0x04EE: "Action11_Diplomacy",
    0x0524: "Action12_War",
    0x0579: "Action13_Spy",
    0x05C4: "Action14_Accounting",
    0x060A: "Action15_Exchange",
    0x0644: "Action16_Trade",
    0x0674: "Action17_SearchOfficer",
    0x069B: "Action18_SearchItem",
    0x06FD: "Action19_InspectLand",
    0x0739: "Action1A_Callback",
    0x0759: "Action1B_Callback",
    0x0769: "Action1C_Callback",
    0x078C: "DomesticActionDispatch",
    0x07E1: "CopyTileRow",
    0x080E: "SetupActionDisplay",
    0x0843: "ActionCalcParams",
    0x088B: "ActionCalcParams2",
    0x08C7: "ActionCalcParams3",
    0x0904: "ActionCalcParams4",
    0x0934: "CommonReturn",
    0x096D: "SetupDisplayPtrs",
    0x098A: "ResetDispatchState",
    0x0994: "DisplayTileData",
    0x09E8: "SaveSramBlock",
    0x0A4E: "LoadSramBlock",
    0x0AC5: "VerifyChecksum",
    0x0B52: "OfficerRecordCalc",
    0x0C09: "ProvinceRecordCalc",
    0x0CEA: "CopyBlockLoop",
    0x0DA0: "MultiRecordCalc",
    0x0E17: "BattleParamSetup",
    0x0E7F: "DiplomacyParamSetup",
    0x0EE4: "WarParamSetup",
    0x0F54: "SpyParamSetup",
    0x0FC7: "TradeParamSetup",
    0x1020: "SearchParamSetup",
    0x107D: "ItemParamSetup",
    0x10F8: "OfficerParamTable",
    0x1168: "ProvinceParamTable",
    0x11D4: "BattleParamTable",
    0x12B9: "ActionLookupData",
    0x12F4: "StringData",
    0x138A: "OfficerNameLookup",
    0x13E4: "NameLookupTable",
    0x147E: "MiscTable1",
    0x14C6: "MiscTable2",
    0x1597: "MiscTable3",
    0x160D: "MiscTable4",
    0x166C: "MiscTable5",
    0x16E4: "MiscTable6",
    0x175E: "MiscTable7",
    0x17A0: "MiscTable8",
    0x182C: "MiscTable9",
    0x1870: "MiscTable10",
    0x1876: "SramReadWrite",
    0x19C6: "SaveGameMain",
    0x1AB2: "LoadGameMain",
    0x1B73: "NewGameInit",
    0x1BCF: "InitKingdomDefaults",
    0x1D88: "SramStoreLoop",
    0x1D91: "SramInitMain",
    0x1DE3: "SramCopyBlock",
    0x1E76: "SramClearFlags",
    0x1E7E: "OfficerParamDispatch",
    0x1EB9: "OfficerRecordLookup",
    0x1F1B: "VectorTable",
}

for off, name in OVERRIDES.items():
    PROC_NAMES[off] = name
    set_label(BASE + off, name)

# ===== Generate Output =====
out = []
out.append(";===============================================================================")
out.append("; PRG Bank $1E - $C000-$DFFF")
out.append("; Sangokushi 2 - Haou no Tairiku (J)")
out.append("; Namco-163 Mapper 19")
out.append(";")
out.append("; Domestic affairs action dispatch, tile data, SRAM save/load.")
out.append("; Called from bank $1D via cross-bank JSR to $C000-$DFFF.")
out.append(";===============================================================================")
out.append("")
out.append('.segment "CODE_BANK1E"')
out.append("")

def hexbytes(off, count):
    return " ".join(f"{data[off+i]:02X}" for i in range(count))

def format_operand(off, sz, mn, mode):
    if mode == "imp":
        return ""
    elif mode == "acc":
        return "A"  # won't actually be used, we handle it via mn
    elif mode == "imm":
        return f"#${data[off+1]:02X}"
    elif mode == "zp":
        return f"${data[off+1]:02X}"
    elif mode == "zpx":
        return f"${data[off+1]:02X},X"
    elif mode == "zpy":
        return f"${data[off+1]:02X},Y"
    elif mode == "abs":
        target = data[off+1] | (data[off+2] << 8)
        opbyte = data[off]
        if opbyte == 0x20 and target in B1F:
            return B1F[target]
        if BASE <= target < BASE + SIZE and target in labels:
            return labels[target]
        return f"${target:04X}"
    elif mode == "abx":
        target = data[off+1] | (data[off+2] << 8)
        return f"${target:04X},X"
    elif mode == "aby":
        target = data[off+1] | (data[off+2] << 8)
        return f"${target:04X},Y"
    elif mode == "ind":
        target = data[off+1] | (data[off+2] << 8)
        return f"(${target:04X})"
    elif mode == "izx":
        return f"(${data[off+1]:02X},X)"
    elif mode == "izy":
        return f"(${data[off+1]:02X}),Y"
    elif mode == "rel":
        delta = data[off+1]
        if delta >= 128:
            delta -= 256
        target = (BASE + off) + 2 + delta
        if BASE <= target < BASE + SIZE and target in labels:
            return labels[target]
        return f"${target:04X}"
    return ""

def emit_instr(off):
    mn, sz, mode, valid = imap[off]
    addr = BASE + off
    bs = hexbytes(off, sz)
    
    if not valid:
        return None
    
    # Handle accumulator ops
    if mode == "imp" and mn in ("ASL","ROL","LSR","ROR"):
        mode = "acc"
    
    operand = format_operand(off, sz, mn, mode)
    
    if operand:
        text = f"  {mn} {operand}"
    else:
        text = f"  {mn}"
    
    pad = max(1, 56 - len(text))
    return f"{text}{' ' * pad}; ${addr:04X}: {bs}"

def emit_data(off, count):
    addr = BASE + off
    bs = hexbytes(off, count)
    vals = ", ".join(f"${data[off+i]:02X}" for i in range(count))
    text = f"  .byte {vals}"
    pad = max(1, 56 - len(text))
    return f"{text}{' ' * pad}; ${addr:04X}: {bs}"

# Output all bytes
pos = 0
in_proc = False
current_proc_off = None

while pos < SIZE:
    addr = BASE + pos
    
    # Procedure start
    if pos in PROC_NAMES:
        if in_proc:
            out.append(".endproc")
            out.append("")
        name = PROC_NAMES[pos]
        out.append(f";===============================================================================")
        out.append(f"; ${addr:04X}: {name}")
        out.append(f";===============================================================================")
        out.append(f".proc {name}")
        in_proc = True
        current_proc_off = pos
    
    # Label (non-proc)
    if addr in labels and pos not in PROC_NAMES:
        out.append(f"{labels[addr]}:")
    
    # Code or data
    if pos in code_bytes and pos in imap:
        mn, sz, mode, valid = imap[pos]
        if valid:
            line = emit_instr(pos)
            if line:
                out.append(line)
                pos += sz
                continue
    
    # Data: emit up to 16 bytes
    count = 0
    while pos + count < SIZE and count < 16:
        nxt = pos + count
        nxt_addr = BASE + nxt
        if count > 0:
            if nxt in PROC_NAMES or nxt_addr in labels:
                break
            if nxt in code_bytes and nxt in imap and imap[nxt][3]:
                break
        count += 1
    
    if count == 0:
        count = 1
    
    out.append(emit_data(pos, count))
    pos += count

if in_proc:
    out.append(".endproc")

# Verify byte count
total = 0
for line in out:
    m = line.find("; $")
    if m >= 0:
        rest = line[m+3:]
        colon = rest.find(":")
        if colon >= 0:
            byte_str = rest[colon+1:].strip()
            total += len(byte_str.split())

print(f"; Total bytes: {total} / {SIZE}", file=sys.stderr)
if total != SIZE:
    print(f"; WARNING: off by {SIZE - total}", file=sys.stderr)

print("\n".join(out))
