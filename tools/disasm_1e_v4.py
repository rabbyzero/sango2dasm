#!/usr/bin/env python3
"""
Final disassembler for prg_1e.bin ($C000-$DFFF).
Strategy: Disassemble everything as code UNLESS it's a known data table.
Data tables appear after JMP $C934 and are identified by NOT starting with the
callback pattern AD A1 04 (LDA $04A1).
$FF padding at end is also data.
"""
import sys

BASE = 0xC000
with open("rom/prg/prg_1e.bin", "rb") as f:
    data = bytearray(f.read())
SIZE = len(data)

# ===== 6502 Opcode Table =====
OPTAB = {}
def _build():
    t = {
        "imp": [0x00,0x08,0x18,0x28,0x38,0x40,0x48,0x58,0x60,0x68,0x78,
                0x88,0x8A,0x98,0x9A,0xA8,0xAA,0xB8,0xBA,0xC8,0xCA,0xD8,
                0xE8,0xEA,0xF8,0x0A,0x2A,0x4A,0x6A,
                0x1A,0x3A,0x5A,0x7A,0xDA,0xFA],
        "imm": [0x09,0x29,0x49,0x69,0xA9,0xC9,0xE9,0xA0,0xC0,0xE0,0xA2,
                0x80,0x82,0xC2,0xE2,0x89,0x0B,0x2B,0x4B,0x6B,0x8B,0xAB,0xCB,0xEB],
        "zp": [0x05,0x25,0x45,0x65,0x85,0xA5,0xC5,0xE5,0x06,0x26,0x46,0x66,
               0x86,0xA6,0xC6,0xE6,0x24,0x84,0xA4,0xC4,0xE4],
        "zpx": [0x15,0x35,0x55,0x75,0x95,0xB5,0xD5,0xF5,0x16,0x36,0x56,0x76,
                0xD6,0xF6,0x94,0xB4],
        "zpy": [0x96,0xB6],
        "abs": [0x0D,0x2D,0x4D,0x6D,0x8D,0xAD,0xCD,0xED,0x0E,0x2E,0x4E,0x6E,
                0x8E,0xAE,0xCE,0xEE,0x2C,0x8C,0xAC,0xCC,0xEC,0x20,0x4C],
        "abx": [0x1D,0x3D,0x5D,0x7D,0x9D,0xBD,0xDD,0xFD,0x1E,0x3E,0x5E,0x7E,
                0xDE,0xFE,0xBC,0x9C,0x9E],
        "aby": [0x19,0x39,0x59,0x79,0x99,0xB9,0xD9,0xF9,0xBE,
                0x9B,0x9F,0xBB,0xBF,0xDB,0xFB,0xFF],
        "ind": [0x6C],
        "izx": [0x01,0x21,0x41,0x61,0x81,0xA1,0xC1,0xE1],
        "izy": [0x11,0x31,0x51,0x71,0x91,0xB1,0xD1,0xF1],
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
        sz = {"imp":1,"imm":2,"zp":2,"zpx":2,"zpy":2,"abs":3,"abx":3,"aby":3,"ind":3,"izx":2,"izy":2,"rel":2}[mode]
        for o in ops:
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
data_regions = set()

# 1. $FF padding at end ($DF6E-$DFFF)
for i in range(0x1F6E, SIZE):
    data_regions.add(i)

# 2. Lookup tables after JMP $C934 (only where bytes are NOT callback code)
# Find all JMP $C934 positions
for i in range(SIZE - 2):
    if data[i] == 0x4C and data[i+1] == 0x34 and data[i+2] == 0xC9:
        after = i + 3
        # Check if this is callback code (starts with AD A1 04)
        if after + 2 < SIZE and data[after] == 0xAD and data[after+2] == 0x04:
            # This is callback CODE, not data
            continue
        # Also check for other code patterns: EE xx 04 (INC $04xx)
        if after + 2 < SIZE and data[after] == 0xEE and data[after+2] == 0x04:
            continue
        # This is a data table - find where it ends
        # It ends at the next code pattern or next action start
        table_end = after
        for j in range(after, min(after + 64, SIZE - 4)):
            # Next action: A9 xx 8D 10 00
            if data[j] == 0xA9 and data[j+2] == 0x8D and data[j+3] == 0x10 and data[j+4] == 0x00:
                table_end = j
                break
            # Callback code start: AD xx 04 D0
            if data[j] == 0xAD and data[j+2] == 0x04 and data[j+3] == 0xD0:
                table_end = j
                break
            # INC $04xx: EE xx 04
            if data[j] == 0xEE and data[j+2] == 0x04:
                table_end = j
                break
        else:
            table_end = after + 64  # shouldn't happen
        for j in range(after, table_end):
            data_regions.add(j)

# 3. Data tables after other RTS positions that are followed by data
# Looking at the analysis: after $C673 RTS, there's code (INC $04A5 etc.)
# After $C436 there's a table (data_region already covers this from JMP detection)
# After $C4BE there's a table
# Let's also check for tables referenced by B9 xx xx instructions

# 4. The pointer table at $DF1A-$DF6D
# This region has 16-bit pointers to bank $1F routines
# Detected as: the bytes after RTS at $DF19 are 40 E9 14 F2...
# Actually the table starts at $DF1A (offset 0x1F1A)
# The code before it is: 8D 61 00 60 (STA $0061, RTS at $DF19)
# So $DF1A-$DF6D is a pointer/data table
for i in range(0x1F1A, 0x1F6E):
    data_regions.add(i)

# 5. String/data tables embedded in code after $C934
# The region after CommonReturn ($C934) starts at $C96D with more code
# Check if there are embedded data tables in the C9xx-CFxx range
# Looking at RTS positions, after many RTS the next bytes are tile data patterns
# (61 62 63 64... which are PPU tile indices)
# These are tile data blocks referenced by the display routines

# After each RTS, check if the following bytes are data (tile indices)
# Tile data typically starts with values in range $40-$FF and doesn't decode as valid code
rts_offsets = sorted([i for i in range(SIZE) if data[i] == 0x60])

# For RTS in the $CAxx-$DExx range, check what follows
for rts_off in rts_offsets:
    if rts_off < 0x0A00 or rts_off > 0x1F00:  # $CA00-$DF00 range
        continue
    after = rts_off + 1
    if after >= SIZE:
        continue
    # Check if next bytes are tile data (not a code pattern)
    # Code patterns: A9 (LDA #), AD (LDA abs), 8D (STA abs), A2 (LDX #), etc.
    # Tile data: starts with values like 61, 62, 63, 40, 53, etc.
    next_byte = data[after]
    if next_byte in OPTAB and OPTAB[next_byte][0] not in ("NOP",):
        # Likely code
        continue
    if next_byte == 0xFF:
        # Padding
        continue
    # Check if this is a tile data block
    # Tile data blocks are sequences of byte values used as PPU tile indices
    # They typically end with 00 or are followed by code
    # Let's find the extent
    block_start = after
    block_end = after
    for j in range(after, min(after + 256, SIZE)):
        b = data[j]
        # Check if this byte starts a code pattern
        if j > after and b in (0xA9, 0xAD, 0x8D, 0xA2, 0xAC, 0xAE, 0x20, 0x4C, 0x60, 0xA0):
            # Check if the next byte makes a valid instruction
            if b == 0xA9 and j + 1 < SIZE:  # LDA #imm
                block_end = j
                break
            if b == 0xAD and j + 2 < SIZE and data[j+2] in (0x04, 0x00, 0x01):
                block_end = j
                break
            if b == 0x8D and j + 2 < SIZE:
                block_end = j
                break
            if b == 0x20 and j + 2 < SIZE:
                block_end = j
                break
            if b == 0x4C:
                block_end = j
                break
            if b == 0x60:  # RTS
                block_end = j
                break
            if b == 0xA0 and j + 1 < SIZE:  # LDY #imm
                block_end = j
                break
            if b == 0xA2 and j + 1 < SIZE:  # LDX #imm
                block_end = j
                break
            if b == 0xAC and j + 2 < SIZE:  # LDY abs
                block_end = j
                break
            if b == 0xAE and j + 2 < SIZE:  # LDX abs
                block_end = j
                break
        block_end = j + 1
    
    if block_end > block_start:
        for j in range(block_start, block_end):
            data_regions.add(j)

# ===== Build instruction map (linear sweep, skipping data) =====
instrs = []  # (offset, size, is_code)
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
            # Check if instruction overlaps data
            overlap = any((pos + j) in data_regions for j in range(1, sz))
            if overlap:
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

# Collect branch/jump targets
for (off, sz, is_code) in instrs:
    if not is_code:
        continue
    addr = BASE + off
    opbyte = data[off]
    _, _, mode = OPTAB[opbyte]
    if mode == "rel":
        delta = data[off+1]
        if delta >= 128: delta -= 256
        target = addr + 2 + delta
        if BASE <= target < BASE + SIZE:
            set_label(target)
    elif opbyte in (0x4C, 0x20) and mode == "abs":
        target = data[off+1] | (data[off+2] << 8)
        if BASE <= target < BASE + SIZE:
            set_label(target)

# ===== Define procedures =====
# Based on analysis: each action runs from entry to RTS, including embedded tables
PROCS = [
    (0x0000, "Bank1E_Init"),
    (0x0010, "Action01_DisplaySetup"),
    (0x005E, "Action02_LandDevelop"),
    (0x0090, "Action03_Check"),
    (0x009E, "Action04_FloodControl"),
    (0x00E7, "Action05_RoadBuild"),
    (0x0136, "Action06_CastleRepair"),
    (0x017B, "Action07_TaxRate"),
    (0x01CA, "Action08_GoldDist"),
    (0x0218, "Action09_FoodDist"),
    (0x0252, "Action0A_Recruit"),
    (0x028A, "Action0B_HireOfficer"),
    (0x02F0, "Action0C_TransferOfficer"),
    (0x0350, "Action0D_ExecuteOfficer"),
    (0x03BA, "Action0E_ExileOfficer"),
    (0x0414, "Action0F_GiveItem"),
    (0x047A, "Action10_MoveCapital"),
    (0x04EE, "Action11_Diplomacy"),
    (0x0524, "Action12_War"),
    (0x0579, "Action13_Spy"),
    (0x05C4, "Action14_Accounting"),
    (0x060A, "Action15_Exchange"),
    (0x0644, "Action16_Trade"),
    (0x0674, "Action17_SearchOfficer"),
    (0x069B, "Action18_SearchItem"),
    (0x06FD, "Action19_InspectLand"),
    (0x078C, "Action1A_PersonalAffairs"),
    (0x07DF, "DomActionDispatch"),
    (0x080E, "CopyTileDataRow"),
    (0x0843, "SetupActionDisplay"),
    (0x088B, "ActionCalcParams"),
    (0x08C7, "ActionCalcParams2"),
    (0x0904, "ActionCalcParams3"),
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
    (0x10F2, "OfficerParamDispatch"),
    (0x10F8, "OfficerParamTable"),
    (0x1168, "ProvinceParamTable"),
    (0x11D4, "BattleParamTable"),
    (0x12B9, "ActionLookupData"),
    (0x12F4, "StringLookupData"),
    (0x138A, "OfficerNameLookup"),
    (0x13E4, "NameLookupTable"),
    (0x147E, "MiscTable1"),
    (0x14C6, "MiscTable2"),
    (0x1597, "MiscTable3"),
    (0x160D, "MiscTable4"),
    (0x166C, "MiscTable5"),
    (0x16E4, "MiscTable6"),
    (0x175E, "MiscTable7"),
    (0x17A0, "MiscTable8"),
    (0x182C, "MiscTable9"),
    (0x1870, "MiscTable10"),
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
    (0x1F1A, "PointerTable"),
]

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
    if mode == "imp": return ""
    if mode == "imm": return f"#${data[off+1]:02X}"
    if mode == "zp": return f"${data[off+1]:02X}"
    if mode == "zpx": return f"${data[off+1]:02X},X"
    if mode == "zpy": return f"${data[off+1]:02X},Y"
    if mode == "abs":
        target = data[off+1] | (data[off+2] << 8)
        if data[off] == 0x20 and target in B1F: return B1F[target]
        if BASE <= target < BASE + SIZE and target in labels: return labels[target]
        return f"${target:04X}"
    if mode == "abx":
        target = data[off+1] | (data[off+2] << 8)
        return f"${target:04X},X"
    if mode == "aby":
        target = data[off+1] | (data[off+2] << 8)
        return f"${target:04X},Y"
    if mode == "ind":
        target = data[off+1] | (data[off+2] << 8)
        return f"(${target:04X})"
    if mode == "izx": return f"(${data[off+1]:02X},X)"
    if mode == "izy": return f"(${data[off+1]:02X}),Y"
    if mode == "rel":
        delta = data[off+1]
        if delta >= 128: delta -= 256
        target = (BASE + off) + 2 + delta
        if BASE <= target < BASE + SIZE and target in labels: return labels[target]
        return f"${target:04X}"
    return ""

in_proc = False
pos_idx = 0

while pos_idx < len(instrs):
    off, sz, is_code = instrs[pos_idx]
    addr = BASE + off
    
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
    
    if addr in labels and off not in proc_map:
        out.append(f"{labels[addr]}:")
    
    if is_code:
        opbyte = data[off]
        mn, _, mode = OPTAB[opbyte]
        operand = fmt_op(off, sz, mn, mode)
        bs = hx(off, sz)
        text = f"  {mn} {operand}" if operand else f"  {mn}"
        pad = max(1, 56 - len(text))
        out.append(f"{text}{' ' * pad}; ${addr:04X}: {bs}")
    else:
        count = 0
        while pos_idx + count < len(instrs):
            noff, nsz, ncode = instrs[pos_idx + count]
            if ncode: break
            if count > 0 and (noff in proc_map or (BASE + noff) in labels): break
            count += 1
        if count == 0: count = 1
        vals = ", ".join(f"${data[off+i]:02X}" for i in range(count))
        bs = hx(off, count)
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
    # Find missing bytes
    covered = set()
    for line in out:
        m = line.find("; $")
        if m >= 0:
            rest = line[m+3:]
            c = rest.find(":")
            if c >= 0:
                addr_str = rest[:c]
                addr = int(addr_str, 16)
                bs = rest[c+1:].strip()
                for j, b in enumerate(bs.split()):
                    covered.add(addr - BASE + j)
    missing = sorted(set(range(SIZE)) - covered)
    if missing:
        print(f"; Missing offsets: {[f'${BASE+m:04X}' for m in missing[:20]]}", file=sys.stderr)

print("\n".join(out))
