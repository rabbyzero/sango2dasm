#!/usr/bin/env python3
"""Comprehensive disassembler for Sangokushi 2 PRG bank 1F.
Outputs a full ca65-compatible .asm file with named functions and scoped parameter names."""

import sys

# 6502 instruction table: (mnemonic, mode, size)
# mode: imp=implied, imm=immediate, zp=zero page, zpx=zero page X, zpy=zero page Y
#       izx=indirect X, izy=indirect Y, abs=absolute, abx=absolute X, aby=absolute Y
#       ind=indirect, rel=relative
OPCODES = {
    0x00: ('BRK', 'imp', 1), 0x01: ('ORA', 'izx', 2), 0x05: ('ORA', 'zp', 2),
    0x06: ('ASL', 'zp', 2), 0x08: ('PHP', 'imp', 1), 0x09: ('ORA', 'imm', 2),
    0x0A: ('ASL', 'acc', 1), 0x0D: ('ORA', 'abs', 3), 0x0E: ('ASL', 'abs', 3),
    0x10: ('BPL', 'rel', 2), 0x11: ('ORA', 'izy', 2), 0x15: ('ORA', 'zpx', 2),
    0x16: ('ASL', 'zpx', 2), 0x18: ('CLC', 'imp', 1), 0x19: ('ORA', 'aby', 3),
    0x1D: ('ORA', 'abx', 3), 0x1E: ('ASL', 'abx', 3),
    0x20: ('JSR', 'abs', 3), 0x21: ('AND', 'izx', 2), 0x24: ('BIT', 'zp', 2),
    0x25: ('AND', 'zp', 2), 0x26: ('ROL', 'zp', 2), 0x28: ('PLP', 'imp', 1),
    0x29: ('AND', 'imm', 2), 0x2A: ('ROL', 'acc', 1), 0x2C: ('BIT', 'abs', 3),
    0x2D: ('AND', 'abs', 3), 0x2E: ('ROL', 'abs', 3),
    0x30: ('BMI', 'rel', 2), 0x31: ('AND', 'izy', 2), 0x35: ('AND', 'zpx', 2),
    0x36: ('ROL', 'zpx', 2), 0x38: ('SEC', 'imp', 1), 0x39: ('AND', 'aby', 3),
    0x3D: ('AND', 'abx', 3), 0x3E: ('ROL', 'abx', 3),
    0x40: ('RTI', 'imp', 1), 0x41: ('EOR', 'izx', 2), 0x45: ('EOR', 'zp', 2),
    0x46: ('LSR', 'zp', 2), 0x48: ('PHA', 'imp', 1), 0x49: ('EOR', 'imm', 2),
    0x4A: ('LSR', 'acc', 1), 0x4C: ('JMP', 'abs', 3), 0x4D: ('EOR', 'abs', 3),
    0x4E: ('LSR', 'abs', 3),
    0x50: ('BVC', 'rel', 2), 0x51: ('EOR', 'izy', 2), 0x55: ('EOR', 'zpx', 2),
    0x56: ('LSR', 'zpx', 2), 0x58: ('CLI', 'imp', 1), 0x59: ('EOR', 'aby', 3),
    0x5D: ('EOR', 'abx', 3), 0x5E: ('LSR', 'abx', 3),
    0x60: ('RTS', 'imp', 1), 0x61: ('ADC', 'izx', 2), 0x65: ('ADC', 'zp', 2),
    0x66: ('ROR', 'zp', 2), 0x68: ('PLA', 'imp', 1), 0x69: ('ADC', 'imm', 2),
    0x6A: ('ROR', 'acc', 1), 0x6C: ('JMP', 'ind', 3), 0x6D: ('ADC', 'abs', 3),
    0x6E: ('ROR', 'abs', 3),
    0x70: ('BVS', 'rel', 2), 0x71: ('ADC', 'izy', 2), 0x75: ('ADC', 'zpx', 2),
    0x76: ('ROR', 'zpx', 2), 0x78: ('SEI', 'imp', 1), 0x79: ('ADC', 'aby', 3),
    0x7D: ('ADC', 'abx', 3), 0x7E: ('ROR', 'abx', 3),
    0x81: ('STA', 'izx', 2), 0x84: ('STY', 'zp', 2), 0x85: ('STA', 'zp', 2),
    0x86: ('STX', 'zp', 2), 0x88: ('DEY', 'imp', 1), 0x8A: ('TXA', 'imp', 1),
    0x8C: ('STY', 'abs', 3), 0x8D: ('STA', 'abs', 3), 0x8E: ('STX', 'abs', 3),
    0x90: ('BCC', 'rel', 2), 0x91: ('STA', 'izy', 2), 0x94: ('STY', 'zpx', 2),
    0x95: ('STA', 'zpx', 2), 0x96: ('STX', 'zpy', 2), 0x98: ('TYA', 'imp', 1),
    0x99: ('STA', 'aby', 3), 0x9A: ('TXS', 'imp', 1), 0x9D: ('STA', 'abx', 3),
    0xA0: ('LDY', 'imm', 2), 0xA1: ('LDA', 'izx', 2), 0xA2: ('LDX', 'imm', 2),
    0xA4: ('LDY', 'zp', 2), 0xA5: ('LDA', 'zp', 2), 0xA6: ('LDX', 'zp', 2),
    0xA8: ('TAY', 'imp', 1), 0xA9: ('LDA', 'imm', 2), 0xAA: ('TAX', 'imp', 1),
    0xAC: ('LDY', 'abs', 3), 0xAD: ('LDA', 'abs', 3), 0xAE: ('LDX', 'abs', 3),
    0xB0: ('BCS', 'rel', 2), 0xB1: ('LDA', 'izy', 2), 0xB4: ('LDY', 'zpx', 2),
    0xB5: ('LDA', 'zpx', 2), 0xB6: ('LDX', 'zpy', 2), 0xB8: ('CLV', 'imp', 1),
    0xB9: ('LDA', 'aby', 3), 0xBA: ('TSX', 'imp', 1), 0xBC: ('LDY', 'abx', 3),
    0xBD: ('LDA', 'abx', 3), 0xBE: ('LDX', 'aby', 3),
    0xC0: ('CPY', 'imm', 2), 0xC1: ('CMP', 'izx', 2), 0xC4: ('CPY', 'zp', 2),
    0xC5: ('CMP', 'zp', 2), 0xC6: ('DEC', 'zp', 2), 0xC8: ('INY', 'imp', 1),
    0xC9: ('CMP', 'imm', 2), 0xCA: ('DEX', 'imp', 1), 0xCC: ('CPY', 'abs', 3),
    0xCD: ('CMP', 'abs', 3), 0xCE: ('DEC', 'abs', 3),
    0xD0: ('BNE', 'rel', 2), 0xD1: ('CMP', 'izy', 2), 0xD5: ('CMP', 'zpx', 2),
    0xD6: ('DEC', 'zpx', 2), 0xD8: ('CLD', 'imp', 1), 0xD9: ('CMP', 'aby', 3),
    0xDD: ('CMP', 'abx', 3), 0xDE: ('DEC', 'abx', 3),
    0xE0: ('CPX', 'imm', 2), 0xE1: ('SBC', 'izx', 2), 0xE4: ('CPX', 'zp', 2),
    0xE5: ('SBC', 'zp', 2), 0xE6: ('INC', 'zp', 2), 0xE8: ('INX', 'imp', 1),
    0xE9: ('SBC', 'imm', 2), 0xEA: ('NOP', 'imp', 1), 0xEC: ('CPX', 'abs', 3),
    0xED: ('SBC', 'abs', 3), 0xEE: ('INC', 'abs', 3),
    0xF0: ('BEQ', 'rel', 2), 0xF1: ('SBC', 'izy', 2), 0xF5: ('SBC', 'zpx', 2),
    0xF6: ('INC', 'zpx', 2), 0xF8: ('SED', 'imp', 1), 0xF9: ('SBC', 'aby', 3),
    0xFD: ('SBC', 'abx', 3), 0xFE: ('INC', 'abx', 3),
}

def read_binary(path):
    with open(path, 'rb') as f:
        return f.read()

def sign_extend_byte(val):
    if val & 0x80:
        return val - 256
    return val

def disassemble_one(data, offset, base_addr):
    """Disassemble one instruction at offset, return (mnemonic_str, next_offset)."""
    if offset >= len(data):
        return None, offset
    opcode = data[offset]
    if opcode not in OPCODES:
        return f"  .byte ${opcode:02X}", offset + 1
    mnem, mode, size = OPCODES[opcode]
    if offset + size > len(data):
        return f"  .byte ${opcode:02X}", offset + 1

    if mode == 'imp' or mode == 'acc':
        return f"  {mnem}", offset + size
    elif mode == 'imm':
        val = data[offset + 1]
        return f"  {mnem} #${val:02X}", offset + size
    elif mode == 'zp':
        val = data[offset + 1]
        return f"  {mnem} ${val:02X}", offset + size
    elif mode == 'zpx':
        val = data[offset + 1]
        return f"  {mnem} ${val:02X},X", offset + size
    elif mode == 'zpy':
        val = data[offset + 1]
        return f"  {mnem} ${val:02X},Y", offset + size
    elif mode == 'izx':
        val = data[offset + 1]
        return f"  {mnem} (${val:02X},X)", offset + size
    elif mode == 'izy':
        val = data[offset + 1]
        return f"  {mnem} (${val:02X}),Y", offset + size
    elif mode == 'abs':
        lo = data[offset + 1]
        hi = data[offset + 2]
        addr = (hi << 8) | lo
        return f"  {mnem} ${addr:04X}", offset + size
    elif mode == 'abx':
        lo = data[offset + 1]
        hi = data[offset + 2]
        addr = (hi << 8) | lo
        return f"  {mnem} ${addr:04X},X", offset + size
    elif mode == 'aby':
        lo = data[offset + 1]
        hi = data[offset + 2]
        addr = (hi << 8) | lo
        return f"  {mnem} ${addr:04X},Y", offset + size
    elif mode == 'ind':
        lo = data[offset + 1]
        hi = data[offset + 2]
        addr = (hi << 8) | lo
        return f"  {mnem} (${addr:04X})", offset + size
    elif mode == 'rel':
        val = data[offset + 1]
        offset_val = sign_extend_byte(val)
        target = (base_addr + offset + 2 + offset_val) & 0xFFFF
        return f"  {mnem} ${target:04X}", offset + size
    return f"  .byte ${opcode:02X}", offset + 1

# Full function/table definitions for bank 1F
# Each entry: (start_addr, end_addr_exclusive, name, type)
# type: 'func', 'data', 'table', 'padding'
FUNCTIONS = [
    # Reset handler
    (0xE000, 0xE079, "Reset", "func"),
    # Vector dispatch table
    (0xE07C, 0xE09A, "VectorTable", "table"),
    # Entry 0: System Init
    (0xE09A, 0xE0D9, "State_SystemInit", "func"),
    # Entry 1: New Game Init
    (0xE0DA, 0xE17C, "State_NewGameInit", "func"),
    # Entry 2: Random + Display (Y=$2A)
    (0xE17D, 0xE18A, "State_RandomDisplay2A", "func"),
    # Entry 3: Kingdom Select
    (0xE18B, 0xE220, "State_KingdomSelect", "func"),
    # Entry 4: Random + Display (Y=$28)
    (0xE221, 0xE22E, "State_RandomDisplay28", "func"),
    # Entry 5: Domestic Affairs
    (0xE22F, 0xE2C1, "State_DomesticAffairs", "func"),
    # Sub-function: Domestic action display lookup
    (0xE29C, 0xE2C1, "DomesticActionLookup", "func"),
    # Domestic action data tables
    (0xE2C2, 0xE2DE, "DomesticGraphicPtrs", "table"),
    (0xE2D0, 0xE2DE, "DomesticBaseDataPtrs", "table"),
    (0xE2DE, 0xE2E2, "DomesticSpriteYPos", "table"),
    # Entry 6: Random Seed Advance
    (0xE2E2, 0xE2E7, "State_RandomAdvance1", "func"),
    # Entry 7: Battle Phase
    (0xE2E8, 0xE369, "State_BattlePhase", "func"),
    # Entry 8: Random Seed Advance
    (0xE36A, 0xE36F, "State_RandomAdvance2", "func"),
    # Display Init Helper
    (0xE370, 0xE37B, "DisplayInit", "func"),
    # Entry 9: Territory / Map View
    (0xE37C, 0xE3EA, "State_TerritoryView", "func"),
    # Entry 10/12/14: Idle / Wait State
    (0xE3EB, 0xE3ED, "State_IdleWait", "func"),
    # Entry 11: Advisor / Council
    (0xE3EE, 0xE469, "State_AdvisorCouncil", "func"),
    # Entry 13: Turn Summary
    (0xE46A, 0xE4D9, "State_TurnSummary", "func"),
    # Frame Init Helper
    (0xE4DA, 0xE51E, "FrameInit", "func"),
    # Bank Switch
    (0xE51F, 0xE566, "BankSwitch", "func"),
    # Bank switch data table
    (0xE567, 0xE57E, "BankSwitchTable", "table"),
    # Bank+PPU init + JMP patch
    (0xE57F, 0xE58F, "BankPpuInit", "func"),
    # Sound init + IRQ timer
    (0xE590, 0xE5F9, "SoundInit", "func"),
    # Wavetable write delay
    (0xE5FA, 0xE608, "WavetableWriteDelay", "func"),
    # Sound note player
    (0xE609, 0xE666, "SoundNotePlayer", "func"),
    # Sound channel table
    (0xE667, 0xE66A, "SoundChannelTable", "table"),
    # Sound wrappers
    (0xE66B, 0xE673, "SoundWrapper0", "func"),
    (0xE673, 0xE67B, "SoundWrapperA", "func"),
    (0xE67B, 0xE683, "SoundWrapperB", "func"),
    (0xE683, 0xE6A5, "SoundWrappersC", "func"),
    # Wavetable init data
    (0xE6A6, 0xE6C5, "WavetableInitData", "table"),
    # Controller read
    (0xE6C6, 0xE70D, "ControllerRead", "func"),
    # Palette upload
    (0xE70E, 0xE748, "PaletteUpload", "func"),
    # PPU mask helper
    (0xE749, 0xE752, "PpuMaskHelper", "func"),
    # PPU ctrl/NMI helpers
    (0xE753, 0xE773, "PpuCtrlNmiHelpers", "func"),
    # Nametable fill mode 1
    (0xE774, 0xE7DE, "NametableFill1", "func"),
    # Nametable fill mode 2
    (0xE7DF, 0xE822, "NametableFill2", "func"),
    # Sprite buffer init
    (0xE823, 0xE842, "SpriteBufferInit", "func"),
    # RNG helpers
    (0xE843, 0xE84A, "RandomBelow100", "func"),
    (0xE84B, 0xE84F, "RandomDiv2", "func"),
    (0xE850, 0xE861, "RandomModPow2", "func"),
    (0xE862, 0xE879, "RandomBelowThreshold", "func"),
    # RNG core
    (0xE87A, 0xE889, "RandomByte", "func"),
    # RNG variants
    (0xE88A, 0xE8B9, "RandomVariants", "func"),
    # RNG table
    (0xE8BA, 0xE9B9, "RandomTable", "table"),
    # Math: Binary to BCD
    (0xE9BA, 0xEA7B, "MathBinToBcd", "func"),
    # Math: 16-bit division
    (0xEA7C, 0xEAA4, "MathDiv16", "func"),
    # Math: 24-bit division
    (0xEAA5, 0xEADD, "MathDiv24", "func"),
    # Callback dispatcher
    (0xEADE, 0xEAF6, "CallbackDispatcher", "func"),
    # Scroll + PPU helpers
    (0xEAF7, 0xEB02, "ScrollSet", "func"),
    (0xEB03, 0xEB19, "PpuCtrlNametableUpdate", "func"),
    (0xEB1A, 0xEB2C, "WindowReset", "func"),
    # Math: BCD to Binary
    (0xEB2D, 0xEBB0, "MathBcdToBin", "func"),
    # Math: Extract upper nibble
    (0xEBB1, 0xEBB5, "MathExtractUpperNibble", "func"),
    # Math: 24-bit accumulate
    (0xEBB6, 0xEBC9, "MathAccumulate24", "func"),
    # Math: Multiply/Div100
    (0xEBCA, 0xEBE8, "MathMulDiv100", "func"),
    # Math: 24x8 multiply
    (0xEBE9, 0xEC21, "MathMul24x8", "func"),
    # Math: 24x16 multiply
    (0xEC22, 0xEC66, "MathMul24x16", "func"),
    # Palette animation
    (0xEC67, 0xECEE, "PaletteAnimation", "func"),
    # Menu cursor system (8 entry points + handler)
    (0xED19, 0xEDEC, "MenuCursorSystem", "func"),
    # Menu string lookup
    (0xEDDD, 0xEDF4, "MenuItemLookup", "func"),
    # Pointer table lookup
    (0xEDF5, 0xEE06, "PointerTableLookup", "func"),
    # Banked callback trampoline
    (0xEE07, 0xEE4C, "BankedCallbackTrampoline", "func"),
    # Trampoline return stub
    (0xEE4D, 0xEE52, "BankedCallbackReturn", "func"),
    # NMI sub-dispatch
    (0xEE53, 0xEF0A, "NmiSubDispatch", "func"),
    # PPU BG tile write
    (0xEF0B, 0xEF70, "PpuBgTileWrite", "func"),
    # PPU sprite tile write
    (0xEF71, 0xEFC0, "PpuSpriteTileWrite", "func"),
    # PPU attr tile write
    (0xEFC0, 0xF027, "PpuAttrTileWrite", "func"),
    # PPU attr tile write (alt)
    (0xF028, 0xF076, "PpuAttrTileWriteAlt", "func"),
    # Namco-163 sound reg read
    (0xF077, 0xF091, "NamcoSoundRegRead", "func"),
    # Sprite OAM writer (scroll)
    (0xF092, 0xF1AC, "SpriteOamWriterScroll", "func"),
    # Sprite OAM writer (simple)
    (0xF1AD, 0xF205, "SpriteOamWriterSimple", "func"),
    # CHR bank switch
    (0xF206, 0xF236, "ChrBankSwitch", "func"),
    # Window/display setup
    (0xF237, 0xF25E, "WindowDisplaySetup", "func"),
    (0xF25F, 0xF265, "WindowSetup2", "func"),
    (0xF266, 0xF2AE, "WindowSetupHelpers", "func"),
    # Data access: Hero address
    (0xF2AF, 0xF2D6, "GetHeroAddr", "func"),
    # Data access: City address
    (0xF2D7, 0xF307, "GetCityAddr", "func"),
    # Data access: Hero kata name
    (0xF308, 0xF35E, "GetHeroKataName", "func"),
    # Data access: width table
    (0xF35F, 0xF367, "KataNameWidthTable", "table"),
    # Data access: Kingdom address
    (0xF368, 0xF386, "GetKingdomAddr", "func"),
    # Kingdom pointer table
    (0xF379, 0xF386, "KingdomPtrTable", "table"),
    # Data access: Hero initial data
    (0xF387, 0xF3BC, "GetHeroInitialData", "func"),
    # Mapper init + controller check
    (0xF3BD, 0xF421, "MapperInitCtrlCheck", "func"),
    # RAM integrity test
    (0xF422, 0xF476, "RamIntegrityTest", "func"),
    # Sound/music data
    (0xF477, 0xF676, "SoundMusicData", "data"),
    # Padding
    (0xF677, 0xF7FF, "Padding1", "padding"),
    # NMI handler
    (0xF800, 0xFAA8, "NmiHandler", "func"),
    # Palette swap A
    (0xFAA9, 0xFABE, "PaletteSwapA", "func"),
    # Palette swap B
    (0xFABF, 0xFAD4, "PaletteSwapB", "func"),
    # NMI scroll mode
    (0xFAD5, 0xFB0A, "NmiScrollMode", "func"),
    # Controller read + bank restore
    (0xFB0B, 0xFB2C, "ControllerReadBankRestore", "func"),
    # IRQ handler
    (0xFB2D, 0xFF5F, "IrqHandler", "func"),
    # Scroll calc A
    (0xFF62, 0xFF9A, "ScrollCalcA", "func"),
    # Scroll calc B
    (0xFF9B, 0xFFD6, "ScrollCalcB", "func"),
    # Padding before vectors
    (0xFFD7, 0xFFFA, "Padding2", "padding"),
]

def format_addr(addr):
    return f"${addr:04X}"

def disassemble_range(data, start_offset, end_offset, base_addr):
    """Disassemble a range of bytes into ca65 assembly lines."""
    lines = []
    offset = start_offset
    while offset < end_offset:
        addr = base_addr + offset
        result = disassemble_one(data, offset, base_addr)
        if result[0] is None:
            break
        asm_str, next_offset = result
        # Emit raw bytes as comment
        raw = data[offset:next_offset]
        raw_str = " ".join(f"{b:02X}" for b in raw)
        lines.append((addr, asm_str, raw_str))
        offset = next_offset
    return lines

def format_data_bytes(data, start_offset, end_offset, base_addr, per_line=16):
    """Format a data region as .byte directives with inline addr+bytes comment."""
    lines = []
    offset = start_offset
    while offset < end_offset:
        addr = base_addr + offset
        chunk = data[offset:min(offset + per_line, end_offset)]
        byte_str = ", ".join(f"${b:02X}" for b in chunk)
        raw_str  = " ".join(f"{b:02X}" for b in chunk)
        asm_str  = f"  .byte {byte_str}"
        lines.append((addr, asm_str, raw_str))
        offset += per_line
    return lines

def format_padding(size):
    return f"  .res {size}, $FF"

def build_asm(data, base_addr=0xE000):
    """Build the complete assembly file."""
    # Sort functions by address
    regions = sorted(FUNCTIONS, key=lambda x: x[0])

    # Find gaps
    covered = set()
    for start, end, _, _ in regions:
        for i in range(start, end):
            covered.add(i)

    output = []

    # Header
    output.append(";===============================================================================")
    output.append("; PRG Bank 1F - $E000-$FFFF")
    output.append("; Sangokushi 2 - Haou no Tairiku (J)")
    output.append("; Namco-163 Mapper 19")
    output.append(";")
    output.append("; Boot bank: Reset handler, state dispatch, NMI/IRQ handlers,")
    output.append("; sound engine, PPU utilities, math routines, controller I/O, data tables")
    output.append(";===============================================================================")
    output.append("")
    output.append(".include \"6502_registers.h\"")
    output.append(".include \"namco163.h\"")
    output.append("")
    output.append(".segment \"CODE_BANK1F\"")
    output.append("")

    for start, end, name, rtype in regions:
        start_offset = start - base_addr
        end_offset = end - base_addr

        if start_offset < 0 or end_offset > len(data):
            continue

        output.append(f";-------------------------------------------------------------------------------")
        output.append(f"; {name} (${start:04X}-${end-1:04X})")
        output.append(f";-------------------------------------------------------------------------------")

        if rtype == "func":
            output.append(f"{name}:")
            lines = disassemble_range(data, start_offset, end_offset, base_addr)
            for addr, asm_str, raw_str in lines:
                if raw_str:
                    comment = f"; ${addr:04X}: {raw_str}"
                    output.append(f"{asm_str:<28}{comment}")
                else:
                    output.append(asm_str)
        elif rtype == "table":
            output.append(f"{name}:")
            lines = format_data_bytes(data, start_offset, end_offset, base_addr)
            for addr, asm_str, raw_str in lines:
                comment = f"; ${addr:04X}: {raw_str}"
                output.append(f"{asm_str:<28}{comment}")
        elif rtype == "data":
            output.append(f"{name}:")
            lines = format_data_bytes(data, start_offset, end_offset, base_addr)
            for addr, asm_str, raw_str in lines:
                comment = f"; ${addr:04X}: {raw_str}"
                output.append(f"{asm_str:<28}{comment}")
        elif rtype == "padding":
            size = end - start
            output.append(f"{name}:")
            output.append(format_padding(size))

        output.append("")

    # Vectors
    vec_offset = 0xFFFA - base_addr
    output.append(";-------------------------------------------------------------------------------")
    output.append("; Interrupt Vectors ($FFFA-$FFFF)")
    output.append(";-------------------------------------------------------------------------------")
    output.append("Vectors:")
    output.append(f"  .addr NmiHandler    ; $FFFA - NMI")
    output.append(f"  .addr Reset         ; $FFFC - RESET")
    output.append(f"  .addr IrqHandler    ; $FFE - IRQ")
    output.append("")

    return "\n".join(output)

def build_function_table():
    """Build a markdown function table."""
    lines = []
    lines.append("# Bank 0x1F Function Table")
    lines.append("")
    lines.append("| Address | End | Name | Type | Size | Description |")
    lines.append("|---------|-----|------|------|------|-------------|")

    entries = [
        (0xE000, 0xE079, "Reset", "func", 121, "Reset handler: init PPU, RAM, mapper, dispatch state"),
        (0xE07C, 0xE09A, "VectorTable", "table", 30, "State dispatch table (15 entries, 2 bytes each)"),
        (0xE09A, 0xE0D9, "State_SystemInit", "func", 63, "Entry 0: System init, PPU setup, transition to state 9"),
        (0xE0DA, 0xE17C, "State_NewGameInit", "func", 162, "Entry 1: New game init, display, SRAM init, music $81"),
        (0xE17D, 0xE18A, "State_RandomDisplay2A", "func", 13, "Entry 2: Random + display (Y=$2A), brief transition"),
        (0xE18B, 0xE220, "State_KingdomSelect", "func", 150, "Entry 3: Kingdom select, scenario/normal mode"),
        (0xE221, 0xE22E, "State_RandomDisplay28", "func", 13, "Entry 4: Random + display (Y=$28), brief transition"),
        (0xE22F, 0xE2C1, "State_DomesticAffairs", "func", 146, "Entry 5: Domestic affairs, action selection"),
        (0xE29C, 0xE2C1, "DomesticActionLookup", "func", 37, "Domestic action display lookup by $0544"),
        (0xE2C2, 0xE2DE, "DomesticGraphicPtrs", "table", 28, "7 graphic pointers for domestic actions"),
        (0xE2DE, 0xE2E2, "DomesticSpriteYPos", "table", 4, "Sprite Y position table (4 bytes)"),
        (0xE2E2, 0xE2E7, "State_RandomAdvance1", "func", 5, "Entry 6: Pure RNG advance, no display"),
        (0xE2E8, 0xE369, "State_BattlePhase", "func", 225, "Entry 7: Battle phase, army status check"),
        (0xE36A, 0xE36F, "State_RandomAdvance2", "func", 5, "Entry 8: Pure RNG advance, no display"),
        (0xE370, 0xE37B, "DisplayInit", "func", 11, "Display init helper: window clear + bank display"),
        (0xE37C, 0xE3EA, "State_TerritoryView", "func", 110, "Entry 9: Territory/map view"),
        (0xE3EB, 0xE3ED, "State_IdleWait", "func", 3, "Entry 10/12/14: Idle wait, JMP dispatch"),
        (0xE3EE, 0xE469, "State_AdvisorCouncil", "func", 123, "Entry 11: Advisor/council dialogue"),
        (0xE46A, 0xE4D9, "State_TurnSummary", "func", 111, "Entry 13: Turn summary/report"),
        (0xE4DA, 0xE51E, "FrameInit", "func", 68, "Per-frame setup: PPU, bank, clear working RAM"),
        (0xE51F, 0xE566, "BankSwitch", "func", 71, "8-byte config bank switch (Namco-163 PRG)"),
        (0xE567, 0xE57E, "BankSwitchTable", "table", 23, "Bank switch configuration table"),
        (0xE57F, 0xE58F, "BankPpuInit", "func", 16, "Bank + PPU init + JMP patch"),
        (0xE590, 0xE5F9, "SoundInit", "func", 105, "Sound init: APU, RAM clear, wavetable upload"),
        (0xE5FA, 0xE608, "WavetableWriteDelay", "func", 14, "Wavetable write timing delay"),
        (0xE609, 0xE666, "SoundNotePlayer", "func", 93, "Sound note player from banked ROM"),
        (0xE667, 0xE66A, "SoundChannelTable", "table", 3, "Sound channel table (4 bytes)"),
        (0xE66B, 0xE6A5, "SoundWrappers", "func", 58, "Sound wrapper functions (8 variants)"),
        (0xE6A6, 0xE6C5, "WavetableInitData", "table", 32, "Namco-163 wavetable init data"),
        (0xE6C6, 0xE70D, "ControllerRead", "func", 71, "Controller read from $4016/$4017"),
        (0xE70E, 0xE748, "PaletteUpload", "func", 58, "Upload palette $0100-$011F to PPU"),
        (0xE749, 0xE752, "PpuMaskHelper", "func", 9, "PPU mask helper ($1E or $00)"),
        (0xE753, 0xE773, "PpuCtrlNmiHelpers", "func", 32, "PPU ctrl/NMI helpers"),
        (0xE774, 0xE7DE, "NametableFill1", "func", 106, "Nametable fill mode 1"),
        (0xE7DF, 0xE822, "NametableFill2", "func", 68, "Nametable fill mode 2"),
        (0xE823, 0xE842, "SpriteBufferInit", "func", 31, "Fill sprite buffer $0200-$02FF with $F0"),
        (0xE843, 0xE84A, "RandomBelow100", "func", 7, "Random byte < 100"),
        (0xE84B, 0xE84F, "RandomDiv2", "func", 4, "Random byte / 2"),
        (0xE850, 0xE861, "RandomModPow2", "func", 17, "Random mod 4/8/16"),
        (0xE862, 0xE879, "RandomBelowThreshold", "func", 23, "Random below threshold"),
        (0xE87A, 0xE889, "RandomByte", "func", 15, "RNG core: table lookup at $E8BA"),
        (0xE88A, 0xE8B9, "RandomVariants", "func", 47, "RNG variants ($0052/$0054/$0055)"),
        (0xE8BA, 0xE9B9, "RandomTable", "table", 256, "Pre-computed random data"),
        (0xE9BA, 0xEA7B, "MathBinToBcd", "func", 193, "24-bit binary to 6-digit packed BCD"),
        (0xEA7C, 0xEAA4, "MathDiv16", "func", 40, "16-bit unsigned division (16 iterations)"),
        (0xEAA5, 0xEADD, "MathDiv24", "func", 56, "24-bit unsigned division (24 iterations)"),
        (0xEADE, 0xEAF6, "CallbackDispatcher", "func", 24, "Inline pointer table callback dispatcher"),
        (0xEAF7, 0xEB02, "ScrollSet", "func", 11, "PPU scroll register write"),
        (0xEB03, 0xEB19, "PpuCtrlNametableUpdate", "func", 22, "PPU ctrl nametable bit update"),
        (0xEB1A, 0xEB2C, "WindowReset", "func", 18, "Window/reset PPU helper"),
        (0xEB2D, 0xEBB0, "MathBcdToBin", "func", 131, "6-digit packed BCD to 24-bit binary"),
        (0xEBB1, 0xEBB5, "MathExtractUpperNibble", "func", 4, "Extract upper nibble (4x LSR)"),
        (0xEBB6, 0xEBC9, "MathAccumulate24", "func", 19, "24-bit accumulate add"),
        (0xEBCA, 0xEBE8, "MathMulDiv100", "func", 30, "16-bit * 8-bit / 100"),
        (0xEBE9, 0xEC21, "MathMul24x8", "func", 56, "24x8 multiply (32-bit result)"),
        (0xEC22, 0xEC66, "MathMul24x16", "func", 68, "24x16 multiply (40-bit result)"),
        (0xEC67, 0xECEE, "PaletteAnimation", "func", 40, "Palette color rotation/animation"),
        (0xED19, 0xEDEC, "MenuCursorSystem", "func", 212, "Menu cursor engine (8 entry points)"),
        (0xEDDD, 0xEDF4, "MenuItemLookup", "func", 23, "Menu item lookup by page*step+column"),
        (0xEDF5, 0xEE06, "PointerTableLookup", "func", 17, "Pointer table lookup + sprite write"),
        (0xEE07, 0xEE4C, "BankedCallbackTrampoline", "func", 69, "Banked call with stack manipulation"),
        (0xEE4D, 0xEE52, "BankedCallbackReturn", "func", 5, "Return stub: restore bank, return"),
        (0xEE53, 0xEF0A, "NmiSubDispatch", "func", 183, "NMI sub-dispatch by $007E flags"),
        (0xEF0B, 0xEF70, "PpuBgTileWrite", "func", 102, "PPU BG tile write from buffer"),
        (0xEF71, 0xEFC0, "PpuSpriteTileWrite", "func", 78, "PPU sprite tile write from buffer"),
        (0xEFC0, 0xF027, "PpuAttrTileWrite", "func", 103, "PPU attribute tile write"),
        (0xF028, 0xF076, "PpuAttrTileWriteAlt", "func", 78, "PPU attribute tile write (alt)"),
        (0xF077, 0xF091, "NamcoSoundRegRead", "func", 26, "Namco-163 sound register read"),
        (0xF092, 0xF1AC, "SpriteOamWriterScroll", "func", 186, "Sprite OAM writer with scroll offset"),
        (0xF1AD, 0xF205, "SpriteOamWriterSimple", "func", 88, "Sprite OAM writer direct placement"),
        (0xF206, 0xF236, "ChrBankSwitch", "func", 48, "CHR bank switch (8 registers)"),
        (0xF237, 0xF25E, "WindowDisplaySetup", "func", 39, "Window/display setup variant 1"),
        (0xF25F, 0xF265, "WindowSetup2", "func", 6, "Window setup variant 2"),
        (0xF266, 0xF2AE, "WindowSetupHelpers", "func", 72, "Window setup helper functions"),
        (0xF2AF, 0xF2D6, "GetHeroAddr", "func", 39, "Hero address: id*32+$6000"),
        (0xF2D7, 0xF307, "GetCityAddr", "func", 48, "City address: id*12+$63C0"),
        (0xF308, 0xF35E, "GetHeroKataName", "func", 86, "Hero kata name: id*10+$901A"),
        (0xF35F, 0xF367, "KataNameWidthTable", "table", 8, "Kata name character width table"),
        (0xF368, 0xF386, "GetKingdomAddr", "func", 30, "Kingdom address from pointer table"),
        (0xF379, 0xF386, "KingdomPtrTable", "table", 13, "7 kingdom SRAM pointers"),
        (0xF387, 0xF3BC, "GetHeroInitialData", "func", 53, "Hero initial data: id*12+$8000"),
        (0xF3BD, 0xF421, "MapperInitCtrlCheck", "func", 102, "Mapper init + controller validation"),
        (0xF422, 0xF476, "RamIntegrityTest", "func", 84, "RAM integrity test ($AA write/verify)"),
        (0xF477, 0xF676, "SoundMusicData", "data", 512, "Sound/music instrument data"),
        (0xF677, 0xF7FF, "Padding1", "padding", 392, "Unused ROM padding ($FF)"),
        (0xF800, 0xFAA8, "NmiHandler", "func", 680, "NMI handler (8 sub-states)"),
        (0xFAA9, 0xFABE, "PaletteSwapA", "func", 21, "Palette swap (if $6F44!=0)"),
        (0xFABF, 0xFAD4, "PaletteSwapB", "func", 21, "Palette swap reverse"),
        (0xFAD5, 0xFB0A, "NmiScrollMode", "func", 53, "NMI scroll mode with CHR restore"),
        (0xFB0B, 0xFB2C, "ControllerReadBankRestore", "func", 33, "Controller read + bank restore"),
        (0xFB2D, 0xFF5F, "IrqHandler", "func", 990, "IRQ handler (14+ sub-states for raster)"),
        (0xFF62, 0xFF9A, "ScrollCalcA", "func", 56, "Scroll calc: $009A/$009B from $0098"),
        (0xFF9B, 0xFFD6, "ScrollCalcB", "func", 59, "Scroll calc variant B"),
        (0xFFD7, 0xFFFA, "Padding2", "padding", 35, "Unused ROM padding ($FF)"),
    ]

    for addr, end, name, rtype, size, desc in entries:
        lines.append(f"| ${addr:04X} | ${end-1:04X} | {name} | {rtype} | {size} | {desc} |")

    return "\n".join(lines)

if __name__ == "__main__":
    bin_path = sys.argv[1] if len(sys.argv) > 1 else "rom/prg/prg_1f.bin"
    data = read_binary(bin_path)
    base_addr = 0xE000

    # Build function table
    table = build_function_table()
    with open("code/bank_1f_function_table.md", "w") as f:
        f.write(table)
    print(f"Function table written to code/bank_1f_function_table.md")

    # Build disassembly
    asm = build_asm(data, base_addr)
    out_path = "asm/banks/prg_1f.asm"
    with open(out_path, "w") as f:
        f.write(asm)
    print(f"Disassembly written to {out_path}")
