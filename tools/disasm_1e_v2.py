#!/usr/bin/env python3
"""
Complete disassembler for prg_1e.bin ($C000-$DFFF)
Sangokushi 2 - Haou no Tairiku (J), Bank $1E

Strategy:
1. Linear sweep to decode all instructions
2. Collect branch/jump targets for labels
3. Identify procedures by RTS/JMP patterns
4. Trace code reachability from known entry points
5. Output code with proper labels, data as .byte
"""
import sys

BASE = 0xC000
with open("rom/prg/prg_1e.bin", "rb") as f:
    data = f.read()
SIZE = len(data)

# ===== 6502 Opcode Table =====
OP = {
    0x00:("BRK",1),0x01:("ORA",2),0x05:("ORA",2),0x06:("ASL",2),
    0x08:("PHP",1),0x09:("ORA",2),0x0A:("ASL",1),0x0B:("NOP",2),
    0x0D:("ORA",3),0x0E:("ASL",3),0x10:("BPL",2),0x11:("ORA",2),
    0x15:("ORA",2),0x16:("ASL",2),0x18:("CLC",1),0x19:("ORA",3),
    0x1A:("NOP",1),0x1D:("ORA",3),0x1E:("ASL",3),
    0x20:("JSR",3),0x21:("AND",2),0x24:("BIT",2),0x25:("AND",2),
    0x26:("ROL",2),0x28:("PLP",1),0x29:("AND",2),0x2A:("ROL",1),
    0x2B:("NOP",2),0x2C:("BIT",3),0x2D:("AND",3),0x2E:("ROL",3),
    0x30:("BMI",2),0x31:("AND",2),0x35:("AND",2),0x36:("ROL",2),
    0x38:("SEC",1),0x39:("AND",3),0x3A:("NOP",1),0x3D:("AND",3),
    0x3E:("ROL",3),0x40:("RTI",1),0x41:("EOR",2),0x45:("EOR",2),
    0x46:("LSR",2),0x48:("PHA",1),0x49:("EOR",2),0x4A:("LSR",1),
    0x4B:("NOP",2),0x4C:("JMP",3),0x4D:("EOR",3),0x4E:("LSR",3),
    0x50:("BVC",2),0x51:("EOR",2),0x55:("EOR",2),0x56:("LSR",2),
    0x58:("CLI",1),0x59:("EOR",3),0x5A:("NOP",1),0x5D:("EOR",3),
    0x5E:("LSR",3),0x60:("RTS",1),0x61:("ADC",2),0x65:("ADC",2),
    0x66:("ROR",2),0x68:("PLA",1),0x69:("ADC",2),0x6A:("ROR",1),
    0x6B:("NOP",2),0x6C:("JMP",3),0x6D:("ADC",3),0x6E:("ROR",3),
    0x70:("BVS",2),0x71:("ADC",2),0x75:("ADC",2),0x76:("ROR",2),
    0x78:("SEI",1),0x79:("ADC",3),0x7A:("NOP",1),0x7D:("ADC",3),
    0x7E:("ROR",3),0x80:("NOP",2),0x81:("STA",2),0x82:("NOP",2),
    0x84:("STY",2),0x85:("STA",2),0x86:("STX",2),0x88:("DEY",1),
    0x89:("NOP",2),0x8A:("TXA",1),0x8B:("NOP",2),0x8C:("STY",3),
    0x8D:("STA",3),0x8E:("STX",3),0x90:("BCC",2),0x91:("STA",2),
    0x94:("STY",2),0x95:("STA",2),0x96:("STX",2),0x98:("TYA",1),
    0x99:("STA",3),0x9A:("TXS",1),0x9B:("NOP",3),0x9C:("NOP",3),
    0x9D:("STA",3),0x9E:("NOP",3),0x9F:("NOP",3),
    0xA0:("LDY",2),0xA1:("LDA",2),0xA2:("LDX",2),0xA4:("LDY",2),
    0xA5:("LDA",2),0xA6:("LDX",2),0xA8:("TAY",1),0xA9:("LDA",2),
    0xAA:("TAX",1),0xAB:("NOP",2),0xAC:("LDY",3),0xAD:("LDA",3),
    0xAE:("LDX",3),0xB0:("BCS",2),0xB1:("LDA",2),0xB4:("LDY",2),
    0xB5:("LDA",2),0xB6:("LDX",2),0xB8:("CLV",1),0xB9:("LDA",3),
    0xBA:("TSX",1),0xBB:("NOP",3),0xBC:("LDY",3),0xBD:("LDA",3),
    0xBE:("LDX",3),0xBF:("NOP",3),0xC0:("CPY",2),0xC1:("CMP",2),
    0xC2:("NOP",2),0xC4:("CPY",2),0xC5:("CMP",2),0xC6:("DEC",2),
    0xC8:("INY",1),0xC9:("CMP",2),0xCA:("DEX",1),0xCB:("NOP",2),
    0xCC:("CPY",3),0xCD:("CMP",3),0xCE:("DEC",3),
    0xD0:("BNE",2),0xD1:("CMP",2),0xD5:("CMP",2),0xD6:("DEC",2),
    0xD8:("CLD",1),0xD9:("CMP",3),0xDA:("NOP",1),0xDB:("NOP",3),
    0xDD:("CMP",3),0xDE:("DEC",3),0xDF:("NOP",3),
    0xE0:("CPX",2),0xE1:("SBC",2),0xE2:("NOP",2),0xE4:("CPX",2),
    0xE5:("SBC",2),0xE6:("INC",2),0xE8:("INX",1),0xE9:("SBC",2),
    0xEA:("NOP",1),0xEB:("NOP",2),0xEC:("CPX",3),0xED:("SBC",3),
    0xEE:("INC",3),0xF0:("BEQ",2),0xF1:("SBC",2),0xF5:("SBC",2),
    0xF6:("INC",2),0xF8:("SED",1),0xF9:("SBC",3),0xFA:("NOP",1),
    0xFB:("NOP",3),0xFD:("SBC",3),0xFE:("INC",3),0xFF:("NOP",3),
}

# Addressing modes by opcode (for operand formatting)
def get_mode(opbyte):
    """Return addressing mode string for operand formatting."""
    modes = {
        # Implied
        0x00:"imp",0x08:"imp",0x10:"rel",0x18:"imp",0x28:"imp",0x30:"rel",
        0x38:"imp",0x40:"imp",0x48:"imp",0x50:"rel",0x58:"imp",0x60:"imp",
        0x68:"imp",0x70:"rel",0x78:"imp",0x88:"imp",0x8A:"imp",0x90:"rel",
        0x98:"imp",0xA8:"imp",0xAA:"imp",0xB0:"rel",0xB8:"imp",0xC8:"imp",
        0xCA:"imp",0xD0:"rel",0xD8:"imp",0xE8:"imp",0xEA:"imp",0xF0:"rel",
        0xF8:"imp",0x0A:"acc",0x2A:"acc",0x4A:"acc",0x6A:"acc",
        0x9A:"imp",0xBA:"imp",
        # NOPs
        0x1A:"imp",0x3A:"imp",0x5A:"imp",0x7A:"imp",0xDA:"imp",0xFA:"imp",
        # Immediate
        0x09:"imm",0x29:"imm",0x49:"imm",0x69:"imm",0xA9:"imm",0xC9:"imm",0xE9:"imm",
        0xA0:"imm",0xC0:"imm",0xE0:"imm",0xA2:"imm",
        0x80:"imm",0x82:"imm",0xC2:"imm",0xE2:"imm",0x89:"imm",
        0x0B:"imm",0x2B:"imm",0x4B:"imm",0x6B:"imm",0x8B:"imm",0xAB:"imm",0xCB:"imm",0xEB:"imm",
        # Zero page
        0x05:"zp",0x25:"zp",0x45:"zp",0x65:"zp",0x85:"zp",0xA5:"zp",0xC5:"zp",0xE5:"zp",
        0x06:"zp",0x26:"zp",0x46:"zp",0x66:"zp",0x86:"zp",0xA6:"zp",0xC6:"zp",0xE6:"zp",
        0x24:"zp",0x84:"zp",0xA4:"zp",0xC4:"zp",0xE4:"zp",
        # ZP,X
        0x15:"zpx",0x35:"zpx",0x55:"zpx",0x75:"zpx",0x95:"zpx",0xB5:"zpx",0xD5:"zpx",0xF5:"zpx",
        0x16:"zpx",0x36:"zpx",0x56:"zpx",0x76:"zpx",0xD6:"zpx",0xF6:"zpx",
        0x94:"zpx",0xB4:"zpx",
        # ZP,Y
        0x96:"zpy",0xB6:"zpy",
        # Absolute
        0x0D:"abs",0x2D:"abs",0x4D:"abs",0x6D:"abs",0x8D:"abs",0xAD:"abs",0xCD:"abs",0xED:"abs",
        0x0E:"abs",0x2E:"abs",0x4E:"abs",0x6E:"abs",0x8E:"abs",0xAE:"abs",0xCE:"abs",0xEE:"abs",
        0x2C:"abs",0x8C:"abs",0xAC:"abs",0xCC:"abs",0xEC:"abs",
        0x20:"abs",0x4C:"abs",
        # ABS,X
        0x1D:"abx",0x3D:"abx",0x5D:"abx",0x7D:"abx",0x9D:"abx",0xBD:"abx",0xDD:"abx",0xFD:"abx",
        0x1E:"abx",0x3E:"abx",0x5E:"abx",0x7E:"abx",0xDE:"abx",0xFE:"abx",
        0xBC:"abx",0x9C:"abx",0x9E:"abx",
        0x9B:"aby",0x9F:"aby",0xBB:"aby",0xBF:"aby",0xDB:"aby",0xFB:"aby",0xFF:"aby",
        # ABS,Y
        0x19:"aby",0x39:"aby",0x59:"aby",0x79:"aby",0x99:"aby",0xB9:"aby",0xD9:"aby",0xF9:"aby",
        0xBE:"aby",
        # Indirect
        0x6C:"ind",
        # (Ind,X)
        0x01:"izx",0x21:"izx",0x41:"izx",0x61:"izx",0x81:"izx",0xA1:"izx",0xC1:"izx",0xE1:"izx",
        # (Ind),Y
        0x11:"izy",0x31:"izy",0x51:"izy",0x71:"izy",0x91:"izy",0xB1:"izy",0xD1:"izy",0xF1:"izy",
    }
    return modes.get(opbyte, "unk")

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

# ===== STEP 1: Decode all instructions =====
instrs = []  # (offset, size, valid)
pos = 0
while pos < SIZE:
    opbyte = data[pos]
    if opbyte in OP:
        mn, sz = OP[opbyte]
        if pos + sz > SIZE:
            instrs.append((pos, 1, False))
            pos += 1
        else:
            instrs.append((pos, sz, True))
            pos += sz
    else:
        instrs.append((pos, 1, False))
        pos += 1

# Build offset map
imap = {}  # offset -> (size, valid)
for (off, sz, valid) in instrs:
    imap[off] = (sz, valid)

# ===== STEP 2: Collect targets and labels =====
labels = {}  # addr -> label_name

def set_label(addr, name=None):
    if addr not in labels:
        if name:
            labels[addr] = name
        else:
            labels[addr] = f"L_{addr:04X}"

# Pre-define key labels
set_label(0xC000, "Bank1E_Init")
set_label(0xC934, "CommonReturn")
set_label(0xC96D, "SetupDisplayPtrs")
set_label(0xC98A, "ResetDispatchState")
set_label(0xC994, "DisplayTileData")
set_label(0xC996, "DisplayTileDataAlt")

# Collect branch/jump targets
for (off, sz, valid) in instrs:
    if not valid:
        continue
    addr = BASE + off
    opbyte = data[off]
    mode = get_mode(opbyte)
    
    if mode == "rel":
        delta = data[off+1]
        if delta >= 0x80:
            delta -= 0x256
            delta = data[off+1] - 256
        target = addr + 2 + (data[off+1] - 256 if data[off+1] >= 128 else data[off+1])
        if BASE <= target < BASE + SIZE:
            set_label(target)
    elif opbyte in (0x4C, 0x20) and mode == "abs":
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE:
            set_label(target)

# ===== STEP 3: Trace code reachability =====
# Start from known entry points and trace forward
reachable = set()

def trace(start_off, stop_at_rts=True, stop_at_jmp=True):
    """Trace code from start_off, marking reachable bytes."""
    pos = start_off
    while pos < SIZE:
        if pos not in imap:
            pos += 1
            continue
        sz, valid = imap[pos]
        if not valid:
            # Hit invalid opcode - stop
            break
        
        for i in range(sz):
            reachable.add(pos + i)
        
        opbyte = data[pos]
        if opbyte == 0x60 and stop_at_rts:  # RTS
            pos += sz
            break
        if opbyte == 0x4C and stop_at_jmp:  # JMP
            pos += sz
            break
        pos += sz

# Trace each procedure
# A procedure starts at an entry point and ends at RTS or JMP
proc_entries = sorted([off for off in range(SIZE) if (BASE + off) in labels and labels[BASE + off].startswith(("Bank1E_", "L_", "Common", "Setup", "Reset", "Display")) or (BASE + off) in [0xC000]])

# Better: trace from every label address that's a code start
for addr in sorted(labels.keys()):
    off = addr - BASE
    if 0 <= off < SIZE and off in imap:
        sz, valid = imap[off]
        if valid:
            trace(off)

# Also trace from all procedure-like starts (addresses targeted by JSR)
jsr_targets = set()
for (off, sz, valid) in instrs:
    if valid and data[off] == 0x20:
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE:
            jsr_targets.add(target)

for target in jsr_targets:
    off = target - BASE
    trace(off)

# Also trace all code that's between known code regions
# Find contiguous code blocks
code_blocks = []
in_code = False
block_start = 0
for (off, sz, valid) in instrs:
    if valid and off in reachable:
        if not in_code:
            block_start = off
            in_code = True
    else:
        if in_code:
            code_blocks.append((block_start, off - 1))
            in_code = False
if in_code:
    code_blocks.append((block_start, SIZE - 1))

# ===== STEP 4: Identify procedure boundaries =====
# Procedures: start at entry/label, end at RTS or JMP $C934
# Build list of (start_off, end_off, name)
procedures = []

# Named procedure starts based on analysis
PROC_DEFS = [
    (0x0000, "Bank1E_Init"),           # $C000: Init code, RTS at $C00F
    (0x0010, "Action01_DisplaySetup"), # $C010: Action 01
    (0x005E, "Action02_LandDevelop"),  # $C05E: Action 02
    (0x0090, "Action03_CheckAction"),  # $C090: Action 03
    (0x009E, "Action04_FloodControl"), # $C09E: Action 04
    (0x00F4, "Action05_RoadBuild"),    # $C0F4: Action 05
    (0x0138, "Action06_CastleRepair"), # $C138: Action 06
    (0x017B, "Action07_TaxRate"),      # $C17B: Action 07
    (0x01CA, "Action08_GoldDist"),     # $C1CA: Action 08
    (0x0218, "Action09_FoodDist"),     # $C218: Action 09
    (0x0252, "Action0A_Recruit"),      # $C252: Action 0A
    (0x028A, "Action0B_HireOfficer"),  # $C28A: Action 0B
    (0x02F0, "Action0C_TransferOfficer"), # $C2F0: Action 0C
    (0x0350, "Action0D_ExecuteOfficer"),   # $C350: Action 0D
    (0x03BA, "Action0E_ExileOfficer"),     # $C3BA: Action 0E
    (0x0414, "Action0F_GiveItem"),         # $C414: Action 0F
    (0x047A, "Action10_MoveCapital"),      # $C47A: Action 10
    (0x04AC, "Action10_MoveCapital2"),     # $C4AC: Action 10 cont
    (0x04EE, "Action11_Diplomacy"),        # $C4EE: Action 11
    (0x0524, "Action12_War"),              # $C524: Action 12
    (0x0579, "Action13_SpyDispatch"),      # $C579: Action 13
    (0x05C4, "Action14_Accounting"),       # $C5C4: Action 14
    (0x060A, "Action15_Exchange"),         # $C60A: Action 15
    (0x0644, "Action16_Trade"),            # $C644: Action 16
    (0x0674, "Action17_SearchOfficer"),    # $C674: Action 17
    (0x069B, "Action18_SearchItem"),       # $C69B: Action 18
    (0x06FD, "Action19_InspectLand"),      # $C6FD: Action 19
    (0x078C, "Action1A_PersonalAffairs"),  # $C78C: Action 1A
    (0x07DF, "DomesticActionDispatch"),    # $C7DF: Main dispatch
    (0x080E, "TileDataCopy"),              # $C80E: Tile copy
    (0x0843, "SetupDisplayAndCopy"),       # $C843: Setup + copy
    (0x088B, "CalcActionParams"),          # $C88B: Calc params
    (0x08C7, "ActionParamCalc2"),          # $C8C7: More params
    (0x0904, "ActionParamCalc3"),          # $C904: More params
    (0x0934, "CommonReturn"),              # $C934: Common return handler
    (0x096D, "SetupDisplayPtrs"),          # $C96D: Setup display
    (0x098A, "ResetDispatchState"),        # $C98A: Reset state
    (0x0994, "DisplayTileData"),           # $C994: Display tiles
    (0x09E8, "SaveSramRegion"),            # $C9E8: SRAM save
    (0x0A4E, "LoadSramRegion"),            # $CA4E: SRAM load
    (0x0AC5, "ComputeChecksum"),           # $CAC5: Checksum
    (0x0B52, "OfficerRecordLookup"),       # $CB52: Officer lookup
    (0x0C09, "ProvinceRecordLookup"),      # $CC09: Province lookup
    (0x0CEA, "DataCopyLoop"),             # $CCEA: Copy loop
    (0x0DA0, "MultiRecordLookup"),         # $CDA0: Multi lookup
    (0x0E17, "BattleSetup"),              # $CE17: Battle setup
    (0x0E7F, "DiplomacySetup"),           # $CE7F: Diplomacy
    (0x0EE4, "WarSetup"),                 # $CEE4: War setup
    (0x0F54, "SpyActionSetup"),           # $CF54: Spy action
    (0x0FC7, "TradeSetup"),               # $CFC7: Trade
    (0x1020, "SearchSetup"),              # $D020: Search
    (0x107D, "ItemSetup"),                # $D07D: Item
    (0x10F8, "OfficerParamTable"),        # $D0F8: Table
    (0x1168, "ProvinceDataTable"),        # $D168: Table
    (0x11D4, "BattleDataTable"),          # $D1D4: Table
    (0x12B9, "ActionLookupTable"),        # $D2B9: Table
    (0x12F4, "DisplayStringData"),        # $D2F4: Data
    (0x138A, "OfficerNameLookup"),        # $D38A: Name lookup
    (0x13E4, "NameLookupData"),           # $D3E4: Data
    (0x147E, "MiscData1"),                # $D47E: Data
    (0x14C6, "MiscData2"),                # $D4C6: Data
    (0x1597, "MiscData3"),                # $D597: Data
    (0x160D, "MiscData4"),                # $D60D: Data
    (0x166C, "MiscData5"),                # $D66C: Data
    (0x16E4, "MiscData6"),                # $D6E4: Data
    (0x175E, "MiscData7"),                # $D75E: Data
    (0x17A0, "MiscData8"),                # $D7A0: Data
    (0x182C, "MiscData9"),                # $D82C: Data
    (0x1870, "MiscData10"),               # $D870: Data
    (0x19C6, "SaveGameHandler"),          # $D9C6: Save handler
    (0x1AB2, "LoadGameHandler"),          # $DAB2: Load handler
    (0x1B73, "NewGameInit"),              # $DB73: New game init
    (0x1BCF, "InitKingdomData"),          # $DBCF: Init kingdoms
    (0x1D91, "SramInitRoutine"),          # $DD91: SRAM init
    (0x1DE3, "SramCopyLoop"),             # $DDE3: Copy loop
    (0x1E7E, "OfficerParamDispatch"),     # $DE7E: Officer dispatch
    (0x1EB9, "OfficerParamLookup"),       # $DEB9: Lookup
    (0x1F1B, "PointerTables"),            # $DF1B: Tables
]

# ===== STEP 5: Generate output =====
output = []
output.append(";===============================================================================")
output.append("; PRG Bank $1E - $C000-$DFFF")
output.append("; Sangokushi 2 - Haou no Tairiku (J)")
output.append("; Namco-163 Mapper 19")
output.append(";")
output.append("; Domestic affairs action dispatch, tile data, and SRAM management.")
output.append("; Called from bank $1D via cross-bank JSR to $C000-$DFFF.")
output.append(";===============================================================================")
output.append("")
output.append('.segment "CODE_BANK1E"')
output.append("")

def fmt_bytes(off, count):
    return " ".join(f"{data[off+i]:02X}" for i in range(count))

def fmt_operand(off, sz, opbyte, mode):
    addr = BASE + off
    if mode == "imp":
        return ""
    elif mode == "acc":
        return "A"
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
        # Check for B1F name
        if opbyte == 0x20 and target in B1F:
            return B1F[target]
        # Check for label
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
        target = addr + 2 + delta
        if BASE <= target < BASE + SIZE and target in labels:
            return labels[target]
        return f"${target:04X}"
    return ""

# Build a proc start map
proc_map = {}  # offset -> proc_name
for (off, name) in PROC_DEFS:
    proc_map[off] = name

# Output all bytes
pos = 0
in_proc = False
current_proc_name = None

while pos < SIZE:
    addr = BASE + pos
    
    # Check for procedure start
    if pos in proc_map:
        if in_proc:
            output.append(".endproc")
            output.append("")
        name = proc_map[pos]
        output.append(f";===============================================================================")
        output.append(f"; ${addr:04X}: {name}")
        output.append(f";===============================================================================")
        output.append(f".proc {name}")
        in_proc = True
        current_proc_name = name
    
    # Label (non-procedure)
    if addr in labels and pos not in proc_map:
        output.append(f"{labels[addr]}:")
    
    # Determine if code or data
    if pos in reachable and pos in imap:
        sz, valid = imap[pos]
        if valid and sz > 0:
            opbyte = data[pos]
            mode = get_mode(opbyte)
            mn = OP[opbyte][0]
            operand = fmt_operand(pos, sz, opbyte, mode)
            bs = fmt_bytes(pos, sz)
            
            if operand:
                text = f"  {mn} {operand}"
            else:
                text = f"  {mn}"
            
            pad = max(1, 56 - len(text))
            output.append(f"{text}{' ' * pad}; ${addr:04X}: {bs}")
            pos += sz
            continue
    
    # Data: collect up to 16 bytes
    count = 0
    while pos + count < SIZE and count < 16:
        next_off = pos + count
        next_addr = BASE + next_off
        # Stop if next byte starts a proc or label
        if count > 0 and (next_off in proc_map or next_addr in labels):
            break
        # Stop if next byte is reachable code
        if count > 0 and next_off in reachable and next_off in imap and imap[next_off][1]:
            break
        count += 1
    
    if count == 0:
        count = 1  # At least 1 byte
    
    bs = fmt_bytes(pos, count)
    vals = ", ".join(f"${data[pos+i]:02X}" for i in range(count))
    text = f"  .byte {vals}"
    pad = max(1, 56 - len(text))
    output.append(f"{text}{' ' * pad}; ${addr:04X}: {bs}")
    pos += count

if in_proc:
    output.append(".endproc")

# Output result
result = "\n".join(output)

# Verify
total = 0
for line in output:
    if "; $" in line:
        comment = line.split("; $")[1]
        if ":" in comment:
            byte_part = comment.split(":",1)[1].strip()
            total += len(byte_part.split())

print(f"; Bytes covered: {total} / {SIZE}", file=sys.stderr)
if total != SIZE:
    print(f"WARNING: Mismatch! Diff = {SIZE - total}", file=sys.stderr)

print(result)
