#!/usr/bin/env python3
"""
Simple linear-sweep disassembler for prg_1e.bin ($C000-$DFFF).
Disassembles ALL valid instructions, only uses .byte for known data tables
and padding ($FF at end).
"""
import sys

BASE = 0xC000
with open("rom/prg/prg_1e.bin", "rb") as f:
    data = bytearray(f.read())
SIZE = len(data)

# ===== 6502 Opcode Table: opbyte -> (mnemonic, size, mode) =====
OPTAB = {}
def _build():
    t = {
        # 1-byte: implied/accumulator
        "imp": [0x00,0x08,0x18,0x28,0x38,0x40,0x48,0x58,0x60,0x68,0x78,
                0x88,0x8A,0x98,0x9A,0xA8,0xAA,0xB8,0xBA,0xC8,0xCA,0xD8,
                0xE8,0xEA,0xF8,
                0x0A,0x2A,0x4A,0x6A,  # accumulator (treated as imp for format)
                0x1A,0x3A,0x5A,0x7A,0xDA,0xFA],  # illegal NOPs
        # 2-byte: immediate
        "imm": [0x09,0x29,0x49,0x69,0xA9,0xC9,0xE9,0xA0,0xC0,0xE0,0xA2,
                0x80,0x82,0xC2,0xE2,0x89,
                0x0B,0x2B,0x4B,0x6B,0x8B,0xAB,0xCB,0xEB],
        # 2-byte: zero page
        "zp": [0x05,0x25,0x45,0x65,0x85,0xA5,0xC5,0xE5,
               0x06,0x26,0x46,0x66,0x86,0xA6,0xC6,0xE6,
               0x24,0x84,0xA4,0xC4,0xE4],
        # 2-byte: zero page,X
        "zpx": [0x15,0x35,0x55,0x75,0x95,0xB5,0xD5,0xF5,
                0x16,0x36,0x56,0x76,0xD6,0xF6,0x94,0xB4],
        # 2-byte: zero page,Y
        "zpy": [0x96,0xB6],
        # 3-byte: absolute
        "abs": [0x0D,0x2D,0x4D,0x6D,0x8D,0xAD,0xCD,0xED,
                0x0E,0x2E,0x4E,0x6E,0x8E,0xAE,0xCE,0xEE,
                0x2C,0x8C,0xAC,0xCC,0xEC,0x20,0x4C],
        # 3-byte: absolute,X
        "abx": [0x1D,0x3D,0x5D,0x7D,0x9D,0xBD,0xDD,0xFD,
                0x1E,0x3E,0x5E,0x7E,0xDE,0xFE,0xBC,0x9C,0x9E],
        # 3-byte: absolute,Y
        "aby": [0x19,0x39,0x59,0x79,0x99,0xB9,0xD9,0xF9,0xBE,
                0x9B,0x9F,0xBB,0xBF,0xDB,0xFB,0xFF],
        # 3-byte: indirect
        "ind": [0x6C],
        # 2-byte: (indirect,X)
        "izx": [0x01,0x21,0x41,0x61,0x81,0xA1,0xC1,0xE1],
        # 2-byte: (indirect),Y
        "izy": [0x11,0x31,0x51,0x71,0x91,0xB1,0xD1,0xF1],
        # 2-byte: relative
        "rel": [0x10,0x30,0x50,0x70,0x90,0xB0,0xD0,0xF0],
    }
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
    for mode, ops in t.items():
        for o in ops:
            sz = {"imp":1,"imm":2,"zp":2,"zpx":2,"zpy":2,"abs":3,"abx":3,"aby":3,"ind":3,"izx":2,"izy":2,"rel":2}[mode]
            OPTAB[o] = (names[o], sz, mode)
_build()

# Bank $1F symbols
B1F = {
    0xE9BA:"B1F_MathBinToBcd", 0xEADE:"B1F_CallbackDispatcher",
    0xEBE9:"B1F_MathMul24x8", 0xEE07:"B1F_BankedCallbackTrampoline",
    0xF237:"B1F_SwitchBankAC_B", 0xF24B:"B1F_SwitchBankAC_A",
    0xF25F:"B1F_SwitchBank8_B", 0xF266:"B1F_SwitchBank8_A",
    0xF2AF:"B1F_GetProvinceRecordAddr", 0xF2D7:"B1F_GetOfficerRecordAddr",
    0xF308:"B1F_GetNameDisplayScale",
}

# ===== Identify data regions =====
# Data regions are: lookup tables after JMP, and $FF padding at end
# Find all JMP $xxxx positions where the next bytes are a data table
# (not a valid instruction flow)

# First, find the $FF padding region at the end
ff_start = SIZE
for i in range(SIZE-1, -1, -1):
    if data[i] != 0xFF:
        ff_start = i + 1
        break

# Find data tables: regions between a JMP target and the next known code start
# Strategy: find all "JMP $C934" positions, then the data table is from JMP_end to next proc start
data_regions = set()

# Add $FF padding
for i in range(ff_start, SIZE):
    data_regions.add(i)

# Find lookup tables: they appear after JMP $C934 instructions
# The pattern is: JMP $C934 at addr, then data bytes until next code
jmp_common_positions = []
pos = 0
while pos < SIZE:
    opbyte = data[pos]
    if opbyte in OPTAB:
        mn, sz, mode = OPTAB[opbyte]
        if mn == "JMP" and mode == "abs":
            target = data[pos+1] | (data[pos+2] << 8)
            if target == 0xC934:
                jmp_common_positions.append((pos, pos+sz))  # (jmp_start, after_jmp)
        pos += sz
    else:
        pos += 1

# For each JMP $C934, check if data follows (lookup table)
# Data ends when we hit a pattern like LDA #$xx, STA $0010 (next procedure)
for (jmp_start, after_jmp) in jmp_common_positions:
    # Check if there's data after the JMP
    scan = after_jmp
    table_start = scan
    # Look for next procedure pattern: A9 xx 8D 10 00 (LDA #imm / STA $0010)
    found_next = False
    while scan < SIZE:
        if (scan + 4 < SIZE and data[scan] == 0xA9 and 
            data[scan+2] == 0x8D and data[scan+3] == 0x10 and data[scan+4] == 0x00):
            # Found next procedure
            for i in range(table_start, scan):
                data_regions.add(i)
            found_next = True
            break
        # Also check for AD xx 04 D0 xx (LDA abs / BNE pattern - callback start)
        if (scan + 3 < SIZE and data[scan] == 0xAD and
            data[scan+2] == 0x04 and data[scan+3] == 0xD0):
            for i in range(table_start, scan):
                data_regions.add(i)
            found_next = True
            break
        # Also check for EE xx 04 (INC abs pattern)
        if (scan + 2 < SIZE and data[scan] == 0xEE and data[scan+2] == 0x04):
            for i in range(table_start, scan):
                data_regions.add(i)
            found_next = True
            break
        scan += 1

# Also mark specific known data regions from analysis:
# Table after $C2C5 JMP (data at $C2C8-$C2DC)
# These are already covered by the auto-detection above

# ===== Linear sweep disassembly =====
# Build instruction map
instrs = []  # list of (offset, size, is_code)
pos = 0
while pos < SIZE:
    if pos in data_regions:
        instrs.append((pos, 1, False))
        pos += 1
        continue
    
    opbyte = data[pos]
    if opbyte in OPTAB:
        mn, sz, mode = OPTAB[opbyte]
        if pos + sz <= SIZE:
            # Check if any byte of this instruction is in a data region
            in_data = any((pos + j) in data_regions for j in range(sz))
            if in_data:
                instrs.append((pos, 1, False))
                pos += 1
            else:
                instrs.append((pos, sz, True))
                pos += sz
        else:
            instrs.append((pos, 1, False))
            pos += 1
    else:
        instrs.append((pos, 1, False))
        pos += 1

# ===== Build labels =====
labels = {}

def set_label(addr, name=None):
    if addr not in labels:
        labels[addr] = name if name else f"L_{addr:04X}"

# Pre-defined labels
set_label(0xC000, "Bank1E_Init")
set_label(0xC934, "CommonReturn")
set_label(0xC96D, "SetupDisplayPtrs")
set_label(0xC98A, "ResetDispatchState")
set_label(0xC994, "DisplayTileData")

# Collect all branch/jump targets
for (off, sz, is_code) in instrs:
    if not is_code:
        continue
    addr = BASE + off
    opbyte = data[off]
    mn, _, mode = OPTAB[opbyte]
    
    if mode == "rel":
        delta = data[off+1]
        if delta >= 128:
            delta -= 256
        target = addr + 2 + delta
        if BASE <= target < BASE + SIZE:
            set_label(target)
    elif mn in ("JMP", "JSR") and mode == "abs":
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE:
            set_label(target)

# ===== Define procedures =====
# Manually define procedure boundaries based on analysis
PROCS = [
    (0x0000, "Bank1E_Init"),
    (0x0010, "Action01_Setup"),
    (0x0046, "Action01_PostJmp"),     # After JMP $C934 at $C043, continues at $C046
    (0x005E, "Action02_LandDevelop"),
    (0x0090, "Action03_Check"),
    (0x009E, "Action04_FloodCtrl"),
    (0x00C8, "Action04_PostBeq"),
    (0x00E7, "Action05_RoadBuild"),
    (0x011A, "Action05_PostJmp"),
    (0x0136, "Action06_CastleRep"),
    (0x017B, "Action07_TaxRate"),
    (0x01CA, "Action08_GoldDist"),
    (0x0218, "Action09_FoodDist"),
    (0x0252, "Action0A_Recruit"),
    (0x028A, "Action0B_HireOfficer"),
    (0x02EE, "Action0B_PostJmp"),
    (0x02F0, "Action0C_TransferOff"),
    (0x034D, "Action0C_PostBeq"),
    (0x0350, "Action0D_ExecuteOff"),
    (0x03B7, "Action0D_PostJmp"),
    (0x03BA, "Action0E_ExileOff"),
    (0x0411, "Action0E_PostBeq"),
    (0x0414, "Action0F_GiveItem"),
    (0x0477, "Action0F_PostBeq"),
    (0x047A, "Action10_MoveCapital"),
    (0x0494, "Action10_Inc"),
    (0x049E, "Action10_Check"),
    (0x04AC, "Action10_Cont"),
    (0x04EE, "Action11_Diplomacy"),
    (0x0524, "Action12_War"),
    (0x0579, "Action13_Spy"),
    (0x05C4, "Action14_Accounting"),
    (0x060A, "Action15_Exchange"),
    (0x0644, "Action16_Trade"),
    (0x0674, "Action17_SearchOff"),
    (0x069B, "Action18_SearchItem"),
    (0x06FD, "Action19_InspectLand"),
    (0x0739, "Action1A_Callback"),
    (0x0749, "Action1B_Callback"),
    (0x0759, "Action1C_Callback"),
    (0x0769, "DomActionDispatch"),
    (0x0790, "CopyTileDataRow"),
    (0x07B9, "StoreAndReturn"),
    (0x07E1, "CopyTileRow"),
    (0x080E, "SetupActionDisplay"),
    (0x0843, "ActionCalcParams"),
    (0x088B, "ActionCalcParams2"),
    (0x08C7, "ActionCalcParams3"),
    (0x0904, "ActionCalcParams4"),
    (0x0934, "CommonReturn"),
    (0x096D, "SetupDisplayPtrs"),
    (0x098A, "ResetDispatchState"),
    (0x0994, "DisplayTileData"),
    (0x09E8, "SramSaveBlock"),
    (0x0A4E, "SramLoadBlock"),
    (0x0AC5, "VerifyChecksum"),
    (0x0B52, "OfficerRecCalc"),
    (0x0C09, "ProvinceRecCalc"),
    (0x0CEA, "CopyBlockLoop"),
    (0x0DA0, "MultiRecCalc"),
    (0x0E17, "BattleParamSetup"),
    (0x0E7F, "DiplomacyParamSetup"),
    (0x0EE4, "WarParamSetup"),
    (0x0F54, "SpyParamSetup"),
    (0x0FC7, "TradeParamSetup"),
    (0x1020, "SearchParamSetup"),
    (0x107D, "ItemParamSetup"),
    (0x10F8, "OfficerParamTbl"),
    (0x1168, "ProvinceParamTbl"),
    (0x11D4, "BattleParamTbl"),
    (0x12B9, "ActionLookupTbl"),
    (0x12F4, "StringLookupTbl"),
    (0x138A, "OfficerNameLookup"),
    (0x13E4, "NameLookupTbl"),
    (0x147E, "MiscTbl1"),
    (0x14C6, "MiscTbl2"),
    (0x1597, "MiscTbl3"),
    (0x160D, "MiscTbl4"),
    (0x166C, "MiscTbl5"),
    (0x16E4, "MiscTbl6"),
    (0x175E, "MiscTbl7"),
    (0x17A0, "MiscTbl8"),
    (0x182C, "MiscTbl9"),
    (0x1870, "MiscTbl10"),
    (0x1876, "SramReadWrite"),
    (0x19C6, "SaveGameMain"),
    (0x1AB2, "LoadGameMain"),
    (0x1B73, "NewGameInit"),
    (0x1BCF, "InitKingdomDefaults"),
    (0x1D88, "SramStoreLoop"),
    (0x1D91, "SramInitMain"),
    (0x1DE3, "SramCopyBlock"),
    (0x1E76, "SramClearFlags"),
    (0x1E7E, "OfficerParamDisp"),
    (0x1EB9, "OfficerRecLookup"),
    (0x1F1B, "VectorTable"),
]

# Build proc map
proc_map = {}
for (off, name) in PROCS:
    proc_map[off] = name
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

def hx(off, count):
    return " ".join(f"{data[off+i]:02X}" for i in range(count))

def fmt_op(off, sz, mn, mode):
    if mode == "imp":
        return ""
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

in_proc = False
pos_idx = 0

while pos_idx < len(instrs):
    off, sz, is_code = instrs[pos_idx]
    addr = BASE + off
    
    # Procedure start?
    if off in proc_map:
        if in_proc:
            out.append(".endproc")
            out.append("")
        name = proc_map[off]
        out.append(f";===============================================================================")
        out.append(f"; ${addr:04X}: {name}")
        out.append(f";===============================================================================")
        out.append(f".proc {name}")
        in_proc = True
    
    # Label (non-proc)?
    if addr in labels and off not in proc_map:
        out.append(f"{labels[addr]}:")
    
    if is_code:
        opbyte = data[off]
        mn, _, mode = OPTAB[opbyte]
        
        # Handle accumulator ops (ASL A, etc.)
        actual_mode = mode
        if mode == "imp" and mn in ("ASL","ROL","LSR","ROR"):
            actual_mode = "imp"  # ca65 uses "ASL" without "A" or "ASL A" - both valid
        
        operand = fmt_op(off, sz, mn, actual_mode)
        bs = hx(off, sz)
        
        if operand:
            text = f"  {mn} {operand}"
        else:
            text = f"  {mn}"
        
        pad = max(1, 56 - len(text))
        out.append(f"{text}{' ' * pad}; ${addr:04X}: {bs}")
    else:
        # Collect consecutive data bytes
        count = 0
        start_idx = pos_idx
        while pos_idx + count < len(instrs):
            noff, nsz, ncode = instrs[pos_idx + count]
            if ncode:
                break
            if count > 0:
                naddr = BASE + noff
                if noff in proc_map or naddr in labels:
                    break
            count += 1
        
        if count == 0:
            count = 1
        
        # Emit data
        data_off = off
        vals = ", ".join(f"${data[data_off+i]:02X}" for i in range(count))
        bs = hx(data_off, count)
        text = f"  .byte {vals}"
        pad = max(1, 56 - len(text))
        out.append(f"{text}{' ' * pad}; ${addr:04X}: {bs}")
        pos_idx += count
        continue
    
    pos_idx += 1

if in_proc:
    out.append(".endproc")

# Verify
total = 0
for line in out:
    m = line.find("; $")
    if m >= 0:
        rest = line[m+3:]
        c = rest.find(":")
        if c >= 0:
            bs = rest[c+1:].strip()
            total += len(bs.split())

print(f"; Total bytes: {total} / {SIZE}", file=sys.stderr)
if total != SIZE:
    print(f"; WARNING: off by {SIZE - total}", file=sys.stderr)

print("\n".join(out))
