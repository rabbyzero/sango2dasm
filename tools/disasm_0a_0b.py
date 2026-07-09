#!/usr/bin/env python3
"""
Disassembler for PRG banks $0A and $0B (paired 16KB block at $A000-$DFFF).
Uses recursive descent to distinguish code from data.
Produces ca65-compatible assembly with inline byte comments.

Bank $0A at $A000-$BFFF (rom/prg/prg_0a.bin)
Bank $0B at $C000-$DFFF (rom/prg/prg_0b.bin)
"""

import sys
from collections import deque

# 6502 opcode table: opcode -> (mnemonic, addressing_mode, byte_length)
OPCODES = {
    0x00: ("BRK", "IMP", 1), 0x01: ("ORA", "IZX", 2), 0x05: ("ORA", "ZP", 2),
    0x06: ("ASL", "ZP", 2), 0x08: ("PHP", "IMP", 1), 0x09: ("ORA", "IMM", 2),
    0x0A: ("ASL", "ACC", 1), 0x0D: ("ORA", "ABS", 3), 0x0E: ("ASL", "ABS", 3),
    0x10: ("BPL", "REL", 2), 0x11: ("ORA", "IZY", 2), 0x15: ("ORA", "ZPX", 2),
    0x16: ("ASL", "ZPX", 2), 0x18: ("CLC", "IMP", 1), 0x19: ("ORA", "ABY", 3),
    0x1D: ("ORA", "ABX", 3), 0x1E: ("ASL", "ABX", 3),
    0x20: ("JSR", "ABS", 3), 0x21: ("AND", "IZX", 2), 0x24: ("BIT", "ZP", 2),
    0x25: ("AND", "ZP", 2), 0x26: ("ROL", "ZP", 2), 0x28: ("PLP", "IMP", 1),
    0x29: ("AND", "IMM", 2), 0x2A: ("ROL", "ACC", 1), 0x2C: ("BIT", "ABS", 3),
    0x2D: ("AND", "ABS", 3), 0x2E: ("ROL", "ABS", 3),
    0x30: ("BMI", "REL", 2), 0x31: ("AND", "IZY", 2), 0x35: ("AND", "ZPX", 2),
    0x36: ("ROL", "ZPX", 2), 0x38: ("SEC", "IMP", 1), 0x39: ("AND", "ABY", 3),
    0x3D: ("AND", "ABX", 3), 0x3E: ("ROL", "ABX", 3),
    0x40: ("RTI", "IMP", 1), 0x41: ("EOR", "IZX", 2), 0x45: ("EOR", "ZP", 2),
    0x46: ("LSR", "ZP", 2), 0x48: ("PHA", "IMP", 1), 0x49: ("EOR", "IMM", 2),
    0x4A: ("LSR", "ACC", 1), 0x4C: ("JMP", "ABS", 3), 0x4D: ("EOR", "ABS", 3),
    0x4E: ("LSR", "ABS", 3),
    0x50: ("BVC", "REL", 2), 0x51: ("EOR", "IZY", 2), 0x55: ("EOR", "ZPX", 2),
    0x56: ("LSR", "ZPX", 2), 0x58: ("CLI", "IMP", 1), 0x59: ("EOR", "ABY", 3),
    0x5D: ("EOR", "ABX", 3), 0x5E: ("LSR", "ABX", 3),
    0x60: ("RTS", "IMP", 1), 0x61: ("ADC", "IZX", 2), 0x65: ("ADC", "ZP", 2),
    0x66: ("ROR", "ZP", 2), 0x68: ("PLA", "IMP", 1), 0x69: ("ADC", "IMM", 2),
    0x6A: ("ROR", "ACC", 1), 0x6C: ("JMP", "IND", 3), 0x6D: ("ADC", "ABS", 3),
    0x6E: ("ROR", "ABS", 3),
    0x70: ("BVS", "REL", 2), 0x71: ("ADC", "IZY", 2), 0x75: ("ADC", "ZPX", 2),
    0x76: ("ROR", "ZPX", 2), 0x78: ("SEI", "IMP", 1), 0x79: ("ADC", "ABY", 3),
    0x7D: ("ADC", "ABX", 3), 0x7E: ("ROR", "ABX", 3),
    0x81: ("STA", "IZX", 2), 0x84: ("STY", "ZP", 2), 0x85: ("STA", "ZP", 2),
    0x86: ("STX", "ZP", 2), 0x88: ("DEY", "IMP", 1), 0x8A: ("TXA", "IMP", 1),
    0x8C: ("STY", "ABS", 3), 0x8D: ("STA", "ABS", 3), 0x8E: ("STX", "ABS", 3),
    0x90: ("BCC", "REL", 2), 0x91: ("STA", "IZY", 2), 0x94: ("STY", "ZPX", 2),
    0x95: ("STA", "ZPX", 2), 0x96: ("STX", "ZPY", 2), 0x98: ("TYA", "IMP", 1),
    0x99: ("STA", "ABY", 3), 0x9A: ("TXS", "IMP", 1), 0x9D: ("STA", "ABX", 3),
    0xA0: ("LDY", "IMM", 2), 0xA1: ("LDA", "IZX", 2), 0xA2: ("LDX", "IMM", 2),
    0xA4: ("LDY", "ZP", 2), 0xA5: ("LDA", "ZP", 2), 0xA6: ("LDX", "ZP", 2),
    0xA8: ("TAY", "IMP", 1), 0xA9: ("LDA", "IMM", 2), 0xAA: ("TAX", "IMP", 1),
    0xAC: ("LDY", "ABS", 3), 0xAD: ("LDA", "ABS", 3), 0xAE: ("LDX", "ABS", 3),
    0xB0: ("BCS", "REL", 2), 0xB1: ("LDA", "IZY", 2), 0xB4: ("LDY", "ZPX", 2),
    0xB5: ("LDA", "ZPX", 2), 0xB6: ("LDX", "ZPY", 2), 0xB8: ("CLV", "IMP", 1),
    0xB9: ("LDA", "ABY", 3), 0xBA: ("TSX", "IMP", 1), 0xBC: ("LDY", "ABX", 3),
    0xBD: ("LDA", "ABX", 3), 0xBE: ("LDX", "ABY", 3),
    0xC0: ("CPY", "IMM", 2), 0xC1: ("CMP", "IZX", 2), 0xC4: ("CPY", "ZP", 2),
    0xC5: ("CMP", "ZP", 2), 0xC6: ("DEC", "ZP", 2), 0xC8: ("INY", "IMP", 1),
    0xC9: ("CMP", "IMM", 2), 0xCA: ("DEX", "IMP", 1), 0xCC: ("CPY", "ABS", 3),
    0xCD: ("CMP", "ABS", 3), 0xCE: ("DEC", "ABS", 3),
    0xD0: ("BNE", "REL", 2), 0xD1: ("CMP", "IZY", 2), 0xD5: ("CMP", "ZPX", 2),
    0xD6: ("DEC", "ZPX", 2), 0xD8: ("CLD", "IMP", 1), 0xD9: ("CMP", "ABY", 3),
    0xDD: ("CMP", "ABX", 3), 0xDE: ("DEC", "ABX", 3),
    0xE0: ("CPX", "IMM", 2), 0xE1: ("SBC", "IZX", 2), 0xE4: ("CPX", "ZP", 2),
    0xE5: ("SBC", "ZP", 2), 0xE6: ("INC", "ZP", 2), 0xE8: ("INX", "IMP", 1),
    0xE9: ("SBC", "IMM", 2), 0xEA: ("NOP", "IMP", 1), 0xEC: ("CPX", "ABS", 3),
    0xED: ("SBC", "ABS", 3), 0xEE: ("INC", "ABS", 3),
    0xF0: ("BEQ", "REL", 2), 0xF1: ("SBC", "IZY", 2), 0xF5: ("SBC", "ZPX", 2),
    0xF6: ("INC", "ZPX", 2), 0xF8: ("SED", "IMP", 1), 0xF9: ("SBC", "ABY", 3),
    0xFD: ("SBC", "ABX", 3), 0xFE: ("INC", "ABX", 3),
}

# Known functions in bank $1F (cross-bank calls)
KNOWN_FUNCS = {
    0xE51F: "B1F_BankSwitch", 0xE57F: "B1F_BankPpuInit",
    0xE590: "B1F_SoundInit", 0xE609: "B1F_SoundNotePlayer",
    0xE683: "B1F_SoundWrapperC", 0xE693: "B1F_SoundWrapperE",
    0xE6C6: "B1F_ControllerRead",
    0xE70E: "B1F_PaletteUpload", 0xE749: "B1F_PpuMaskEnable",
    0xE74D: "B1F_PpuMaskDisable", 0xE753: "B1F_NmiEnable",
    0xE768: "B1F_NmiDisable",
    0xE774: "B1F_NametableFill1", 0xE7DF: "B1F_NametableFill2",
    0xE823: "B1F_SpriteBufferInit", 0xE825: "B1F_SpriteBufferInitAll",
    0xE830: "B1F_SpriteClearFromIndex",
    0xE843: "B1F_RandomBelow100", 0xE84B: "B1F_RandomDiv2",
    0xE850: "B1F_RandomMod4", 0xE856: "B1F_RandomMod8",
    0xE85C: "B1F_RandomMod16", 0xE862: "B1F_RandomBelowThreshold",
    0xE87A: "B1F_RandomByte", 0xE88A: "B1F_RandomByte2",
    0xE89A: "B1F_RandomByte3", 0xE8AA: "B1F_RandomByte4",
    0xE9BA: "B1F_MathBinToBcd", 0xEA7C: "B1F_MathDiv16",
    0xEAA5: "B1F_MathDiv24", 0xEADE: "B1F_CallbackDispatcher",
    0xEAF7: "B1F_ScrollSet", 0xEB1A: "B1F_WindowReset",
    0xEB2D: "B1F_MathBcdToBin", 0xEBB1: "B1F_MathExtractUpperNibble",
    0xEBB6: "B1F_MathAccumulate24", 0xEBCA: "B1F_MathMulDiv100",
    0xEBE9: "B1F_MathMul24x8", 0xEC22: "B1F_MathMul24x16",
    0xEC67: "B1F_PaletteAnimation", 0xECBF: "B1F_PaletteFadeInit",
    0xECEE: "B1F_PaletteCopyBuffer",
    0xED19: "B1F_MenuStep1", 0xED1E: "B1F_MenuStep2",
    0xED23: "B1F_MenuStep3", 0xED28: "B1F_MenuStep4",
    0xED2D: "B1F_MenuStep5", 0xED32: "B1F_MenuStep6",
    0xED37: "B1F_MenuStep7", 0xED3C: "B1F_MenuStep8",
    0xED41: "B1F_MenuMain", 0xEDDD: "B1F_MenuItemLookup",
    0xEDF5: "B1F_PointerTableLookup",
    0xEE07: "B1F_BankedCallbackTrampoline", 0xEE4D: "B1F_BankedCallbackReturn",
    0xEE53: "B1F_NmiSubDispatch", 0xEEE6: "B1F_NmiSubDispatchAlt",
    0xEF0B: "B1F_PpuBgTileWrite", 0xEF71: "B1F_PpuSpriteTileWrite",
    0xEFC0: "B1F_PpuAttrTileWrite", 0xF028: "B1F_PpuAttrTileWriteAlt",
    0xF077: "B1F_NamcoSoundRegRead",
    0xF092: "B1F_SpriteOamWriterScroll", 0xF1AD: "B1F_SpriteOamWriterSimple",
    0xF206: "B1F_ChrBankSwitch",
    0xF237: "B1F_SwitchBankAC_B", 0xF24B: "B1F_SwitchBankAC_A",
    0xF25F: "B1F_SwitchBank8_B", 0xF266: "B1F_SwitchBank8_A",
    0xF26D: "B1F_SetUI0", 0xF283: "B1F_SetUI2",
    0xF28B: "B1F_SetUI4", 0xF293: "B1F_SetUI5", 0xF29B: "B1F_ClearUI",
    0xF2AF: "B1F_GetProvinceRecordAddr", 0xF2D7: "B1F_GetOfficerRecordAddr",
    0xF308: "B1F_GetNameDisplayScale", 0xF368: "B1F_GetRulerDataPtr",
    0xF387: "B1F_GetOfficerRomRecordAddr",
    0xF3BD: "B1F_CopyProtectionCheck",
    0xF477: "B1F_MetaTileData",
    0xF800: "B1F_NmiHandler", 0xFB0B: "B1F_SetupChrBanksAndWait",
    0xFB28: "B1F_WaitVBlank", 0xFB2D: "B1F_IrqHandler",
    0xFF62: "B1F_CalcScrollAddr", 0xFF9B: "B1F_CalcScrollAddrAlt",
}

# Proc name overrides for bank $0A/$0B
PROC_NAMESS = {
    # Jump table entry targets
    0xA00F: "B0A_MainDispatch",
    0xD717: "B0B_SubStateDispatch",
    0xCF3F: "B0B_ArmyValueCalc",
    0xCF7C: "B0B_DataRecordLookup",
    0xD00C: "B0B_DistanceClamp",
    # Key bank 0A procs
    0xA043: "B0A_InitWorkAreas",
    0xA0D3: "B0A_ScanMatchData",
    0xA19C: "B0A_SumAndCompare",
    0xA1C1: "B0B_StateMachine",
    0xA23D: "B0B_JumpToBEC7",
    0xA240: "B0A_FindMinMax",
    0xA2D3: "B0A_BitMaskLookup",
    0xA303: "B0A_ProvinceSearch",
    0xA3D6: "B0A_CompareValues",
    0xA416: "B0A_TableInterp",
    0xA444: "B0A_CalcOffset",
    0xA461: "B0A_MathHelper",
    0xA476: "B0A_DivStep",
    0xA481: "B0A_ArmyDispatch",
    0xA4B2: "B0A_ArmyLoop",
    0xA4CE: "B0A_ArmyCalc2",
    0xA512: "B0A_SpriteSetup",
    0xA52E: "B0A_PpuWriteHelper",
    0xA55C: "B0A_TileRender",
    0xA571: "B0A_RowProcess",
    0xA59F: "B0A_ColLoop",
    0xA5B1: "B0A_TileAttr",
    0xA5D5: "B0A_SpriteCalc",
    0xA5E9: "B0A_PaletteSetup",
    0xA60C: "B0A_NameTable",
    0xA621: "B0A_AttrTable",
    0xA64F: "B0A_ScrollInit",
    0xA661: "B0A_WindowSetup",
    0xA685: "B0A_MenuInit",
    0xA699: "B0A_DisplaySetup",
    # Key bank 0B procs
    0xC000: "B0B_Init",
    0xD03A: "B0B_LoadRecord",
    0xD72A: "B0B_CallDomesticDisplay",
    0xD732: "B0B_StackFill",
    0xD73C: "B0B_FillStackLoop",
    0xD74F: "B0B_OverlayHandler",
    0xD99C: "B0B_RenderOverlay",
    0xDA7E: "B0B_ClearOverlay",
    0xDE5F: "B0B_SoundDispatch",
    0xDEAF: "B0B_SpriteSetup2",
    0xDF4C: "B0B_PaletteCheck",
}

# Logic comments for complex procedures
PROC_COMMENTS = {
    0xA00F: "Main dispatch: routes to sub-states based on game mode",
    0xA043: "Initialize work areas and counters for province scanning",
    0xA0D3: "Scan and match province data against search criteria",
    0xA19C: "Sum values and compare against thresholds",
    0xA1C1: "State machine: handles turn progression and phase transitions",
    0xA240: "Find minimum/maximum values in province data tables",
    0xA303: "Search provinces by criteria (type, owner, conditions)",
    0xA3D6: "Compare multiple values and set result flags",
    0xA416: "Interpret table data for display/calculation",
    0xA461: "Math helper: division and multiplication setup",
    0xA481: "Army dispatch: route army operations",
    0xA512: "Setup sprite OAM entries for display",
    0xA55C: "Render tile row to PPU",
    0xA5D5: "Calculate sprite positions and attributes",
    0xA699: "Setup display windows and scrolling",
    0xC000: "Bank 0B initialization: setup registers and jump to main loop",
    0xCF3F: "Calculate total army value from officer/troop data",
    0xCF7C: "Lookup data records by index (province/officer info)",
    0xD00C: "Clamp distance values to valid range",
    0xD03A: "Load province/officer record into work buffer",
    0xD717: "Sub-state dispatch: route to specific game phases",
    0xD74F: "Handle overlay rendering (menus, dialogs, status)",
    0xD99C: "Render overlay tiles to name table",
    0xDA7E: "Clear overlay region from name table",
    0xDE5F: "Sound dispatch: route to NMC sound routines",
    0xDF4C: "Check and update palette animation state",
}

# RAM/Zero-Page address names for local parameter aliases
RAM_NAMES = {
    # Work area ($0036-$0045)
    0x0036: "work_outer_idx",
    0x0037: "work_inner_idx",
    0x0038: "work_inner_idx2",
    0x0039: "work_sub_idx",
    0x003A: "work_limit_a",
    0x003B: "work_limit_b",
    0x003C: "work_temp_0",
    0x003D: "work_temp_1",
    0x003E: "work_temp_2",
    0x003F: "work_record_idx",
    0x0040: "work_record_val",
    0x0041: "work_search_result",
    0x0045: "work_search_max",
    # Math workspace ($20-$27)
    0x0020: "math_acc_lo",
    0x0021: "math_acc_mlo",
    0x0022: "math_acc_mhi",
    0x0023: "math_acc_hi",
    0x0024: "math_ext",
    0x0025: "math_temp1",
    0x0026: "math_temp2",
    0x0027: "math_temp3",
    # Game state ($05xx)
    0x0540: "state_sub_dispatch",
    0x0541: "state_display_idx",
    0x0545: "state_overlay_param",
    0x0547: "state_palette_mode",
    # SRAM ($6Fxx)
    0x6F02: "sram_kingdom_index",
    0x6F03: "sram_player_id",
    0x6F5B: "sram_counter",
    0x6F5F: "sram_work_0",
    0x6F60: "sram_work_1",
    0x6F61: "sram_work_2",
    0x6F8B: "sram_game_start_flag",
}

# Also known bank $17/$18 functions that might be called
KNOWN_17_18_FUNCS = {
    0xA000: "B17_18_PpuWriteRle",
    0xA003: "B17_18_PpuCopyRaw",
    0xA006: "B17_18_PpuWriteTileOffset",
    0xA009: "B17_18_DisplayScrollLoop",
    0xA00C: "B17_18_DisplayAndChrSetup",
    0xA00F: "B17_18_BattleEffects",
    0xA012: "B17_18_BattleDispatch",
    0xA015: "B17_18_OverlayWindow",
    0xA018: "B17_18_SetupAdvisorTiles",
    0xA01B: "B17_18_MainGameDispatch",
    0xA01E: "B17_18_DomesticActionDispatch",
    0xA021: "B17_18_AnimationDispatch",
    0xA024: "B17_18_DomesticDisplay",
    0xA027: "B17_18_DataRecordLoader",
}


class RecursiveDescentDisassembler:
    """Recursive descent disassembler for 6502 code."""

    def __init__(self, data_0a, data_0b):
        self.data_0a = data_0a  # $A000-$BFFF
        self.data_0b = data_0b  # $C000-$DFFF
        self.base_0a = 0xA000
        self.base_0b = 0xC000
        # Track which bytes are code vs unknown
        self.code_bytes_0a = set()
        self.code_bytes_0b = set()
        # Inline tables (addr -> end_addr)
        self.inline_tables_0a = {}
        self.inline_tables_0b = {}
        # Labels
        self.labels = {}
        # Procedure starts (addresses that begin a new proc)
        self.proc_starts = set()
        # Fallthrough entry points (not real proc boundaries)
        self.fallthrough_starts = set()
        # Branch targets (addresses targeted by branches from traced code)
        self.branch_targets = set()

    def get_byte(self, addr):
        """Get byte at given address from appropriate bank."""
        if 0xA000 <= addr <= 0xBFFF:
            return self.data_0a[addr - 0xA000]
        elif 0xC000 <= addr <= 0xDFFF:
            return self.data_0b[addr - 0xC000]
        return None

    def get_bytes(self, addr, count):
        """Get multiple bytes starting at addr."""
        result = []
        for i in range(count):
            b = self.get_byte(addr + i)
            if b is None:
                return None
            result.append(b)
        return result

    def mark_code(self, addr, length):
        """Mark bytes as code."""
        for i in range(length):
            a = addr + i
            if 0xA000 <= a <= 0xBFFF:
                self.code_bytes_0a.add(a - 0xA000)
            elif 0xC000 <= a <= 0xDFFF:
                self.code_bytes_0b.add(a - 0xC000)

    def is_in_range(self, addr):
        """Check if address is within our banks."""
        return (0xA000 <= addr <= 0xBFFF) or (0xC000 <= addr <= 0xDFFF)

    def is_already_code(self, addr):
        """Check if address is already marked as code."""
        if 0xA000 <= addr <= 0xBFFF:
            return (addr - 0xA000) in self.code_bytes_0a
        elif 0xC000 <= addr <= 0xDFFF:
            return (addr - 0xC000) in self.code_bytes_0b
        return False

    def trace_code(self, entry_points, is_fallthrough=False):
        """Recursive descent code tracing from entry points."""
        # Queue entries: (addr, is_proc_entry) - is_proc_entry means it should be a .proc start
        queue = deque()
        for ep in entry_points:
            queue.append((ep, True))
        visited_starts = set()

        while queue:
            addr, is_proc_entry = queue.popleft()

            if addr in visited_starts:
                continue
            if not self.is_in_range(addr):
                continue

            visited_starts.add(addr)
            if is_proc_entry:
                self.proc_starts.add(addr)

            # Trace linearly from this point
            pc = addr
            while self.is_in_range(pc):
                if self.is_already_code(pc):
                    break

                byte_val = self.get_byte(pc)
                if byte_val is None or byte_val not in OPCODES:
                    break

                mnemonic, mode, length = OPCODES[byte_val]

                # Check we can read the full instruction
                instr_bytes = self.get_bytes(pc, length)
                if instr_bytes is None:
                    break

                # Mark as code
                self.mark_code(pc, length)

                # Handle branches - target stays in current proc (not a new proc_start)
                if mode == "REL":
                    offset = instr_bytes[1]
                    if offset >= 0x80:
                        offset -= 0x100
                    target = pc + 2 + offset
                    if self.is_in_range(target):
                        queue.append((target, False))  # branch target, NOT a proc start
                        self.branch_targets.add(target)
                    pc += length
                    continue

                # Handle JSR
                if mnemonic == "JSR" and mode == "ABS":
                    target = instr_bytes[1] | (instr_bytes[2] << 8)
                    if self.is_in_range(target):
                        queue.append((target, True))  # JSR target IS a proc start

                    # Check for CallbackDispatcher pattern
                    if target == 0xEADE:
                        table_start = pc + 3
                        table_size = self._find_callback_table_size(table_start)
                        if table_size > 0:
                            if 0xA000 <= table_start <= 0xBFFF:
                                self.inline_tables_0a[table_start] = table_start + table_size
                            else:
                                self.inline_tables_0b[table_start] = table_start + table_size
                            for i in range(0, table_size, 2):
                                ptr_bytes = self.get_bytes(table_start + i, 2)
                                if ptr_bytes:
                                    ptr = ptr_bytes[0] | (ptr_bytes[1] << 8)
                                    if self.is_in_range(ptr):
                                        queue.append((ptr, True))  # callback target IS proc start
                            pc = table_start + table_size
                            continue

                    # Check for BankedCallbackTrampoline pattern
                    if target == 0xEE07:
                        inline_start = pc + 3
                        ptr_bytes = self.get_bytes(inline_start, 2)
                        if ptr_bytes:
                            if 0xA000 <= inline_start <= 0xBFFF:
                                self.inline_tables_0a[inline_start] = inline_start + 2
                            else:
                                self.inline_tables_0b[inline_start] = inline_start + 2
                            pc = inline_start + 2
                            continue

                    pc += length
                    continue

                # Handle JMP absolute
                if mnemonic == "JMP" and mode == "ABS":
                    target = instr_bytes[1] | (instr_bytes[2] << 8)
                    if self.is_in_range(target):
                        queue.append((target, True))  # JMP target IS a proc start
                    break  # JMP doesn't fall through

                # Handle JMP indirect
                if mnemonic == "JMP" and mode == "IND":
                    break

                # Handle RTS/RTI/BRK
                if mnemonic in ("RTS", "RTI", "BRK"):
                    break

                # Normal instruction - continue linearly
                pc += length

    def _find_callback_table_size(self, table_start):
        """Determine the size of a CallbackDispatcher inline pointer table."""
        min_ptr = 0xFFFF
        entries = 0
        addr = table_start

        while True:
            ptr_bytes = self.get_bytes(addr, 2)
            if ptr_bytes is None:
                break
            ptr = ptr_bytes[0] | (ptr_bytes[1] << 8)

            if not (0xA000 <= ptr <= 0xDFFF):
                break

            entries += 1
            if ptr < min_ptr:
                min_ptr = ptr
            addr += 2

            if addr >= min_ptr:
                break
            if entries >= 32:
                break

        return entries * 2

    def compute_proc_ranges(self):
        """Compute address ranges for each procedure."""
        ranges = {}  # proc_start -> (start_addr, end_addr)
        sorted_starts = sorted(self.proc_starts)
        
        # Walk from each proc_start to the next proc_start.
        # Skip non-code bytes (data between code blocks).
        for i, start in enumerate(sorted_starts):
            next_start = sorted_starts[i + 1] if i + 1 < len(sorted_starts) else 0xFFFF
            bank_end = 0xC000 if start <= 0xBFFF else 0xE000
            pc = start
            while pc < next_start and pc < bank_end:
                byte_val = self.get_byte(pc)
                if byte_val is None:
                    break
                if byte_val not in OPCODES:
                    pc += 1
                    continue
                mnemonic, mode, length = OPCODES[byte_val]
                if pc + length > bank_end:
                    break
                pc += length
            ranges[start] = (start, pc)
        
        self.proc_ranges = ranges

    def build_labels(self):
        """Build label dictionary from traced code, separating global and local."""
        targets_0a = set()
        targets_0b = set()
        # Track which procs reference which targets (for local vs global decision)
        target_referrers = {}  # target_addr -> set of proc_starts that reference it

        # Scan all code for branch/JMP/JSR targets
        for bank_data, base, code_bytes in [
            (self.data_0a, self.base_0a, self.code_bytes_0a),
            (self.data_0b, self.base_0b, self.code_bytes_0b)
        ]:
            offset = 0
            while offset < len(bank_data):
                if offset not in code_bytes:
                    offset += 1
                    continue
                byte_val = bank_data[offset]
                if byte_val not in OPCODES:
                    offset += 1
                    continue
                mnemonic, mode, length = OPCODES[byte_val]
                if offset + length > len(bank_data):
                    break
                addr = base + offset
                operand = bank_data[offset+1:offset+length]
                
                # Find which proc this instruction belongs to
                containing_proc = self._find_containing_proc(addr)

                if mode == "REL":
                    off_val = operand[0]
                    if off_val >= 0x80:
                        off_val -= 0x100
                    target = addr + 2 + off_val
                    if 0xA000 <= target <= 0xBFFF:
                        targets_0a.add(target)
                    elif 0xC000 <= target <= 0xDFFF:
                        targets_0b.add(target)
                    if containing_proc is not None:
                        target_referrers.setdefault(target, set()).add(containing_proc)

                if mode == "ABS" and mnemonic in ("JMP", "JSR"):
                    target = operand[0] | (operand[1] << 8)
                    if 0xA000 <= target <= 0xBFFF:
                        targets_0a.add(target)
                    elif 0xC000 <= target <= 0xDFFF:
                        targets_0b.add(target)
                    if containing_proc is not None:
                        target_referrers.setdefault(target, set()).add(containing_proc)

                offset += length

        # From inline tables
        for tables, data, base in [
            (self.inline_tables_0a, self.data_0a, self.base_0a),
            (self.inline_tables_0b, self.data_0b, self.base_0b)
        ]:
            for tbl_start, tbl_end in tables.items():
                off = tbl_start - base
                containing_proc = self._find_containing_proc(tbl_start)
                while base + off < tbl_end:
                    if off + 1 >= len(data):
                        break
                    lo = data[off]
                    hi = data[off+1]
                    ptr = lo | (hi << 8)
                    if 0xA000 <= ptr <= 0xBFFF:
                        targets_0a.add(ptr)
                    elif 0xC000 <= ptr <= 0xDFFF:
                        targets_0b.add(ptr)
                    if containing_proc is not None:
                        target_referrers.setdefault(ptr, set()).add(containing_proc)
                    off += 2

        # Jump table entries for bank 0A
        jt_entries = self._scan_jump_table()
        for idx, (entry_addr, target) in enumerate(jt_entries):
            self.labels[entry_addr] = f"B0A_Entry{idx:02X}"

        # All labels are global to avoid ca65 @ scope issues with proc_internal_labels.
        # .proc/.endproc provides structural grouping.
        # Labels inside .proc are exposed as global aliases after .endproc.
        self.local_labels = set()

        # Add proc names to labels dict for all proc_starts that are targets
        # This ensures get_label_for_addr returns proc names instead of Lxxxxx
        all_targets = targets_0a | targets_0b
        for target in all_targets:
            if target in self.proc_starts:
                self.labels[target] = get_proc_name(target, self.labels)

        # Also add PROC_NAMESS entries for non-proc_start targets
        # These are branch targets that have meaningful names
        for addr, name in PROC_NAMESS.items():
            if addr in all_targets and addr not in self.labels:
                self.labels[addr] = name

        # Assign global labels (skip proc_starts and local_labels)
        for target in sorted(targets_0a):
            if 0xA000 <= target <= 0xBFFF:
                if target in self.local_labels:
                    continue
                if target in self.proc_starts:
                    continue
                if target not in self.labels:
                    self.labels[target] = f"L{target:04X}"
        for target in sorted(targets_0b):
            if 0xC000 <= target <= 0xDFFF:
                if target in self.local_labels:
                    continue
                if target in self.proc_starts:
                    continue
                if target not in self.labels:
                    self.labels[target] = f"L{target:04X}"

    def _find_containing_proc(self, addr):
        """Find which proc contains the given address."""
        if not hasattr(self, 'proc_ranges'):
            return None
        for proc_start, (start, end) in self.proc_ranges.items():
            if start <= addr < end:
                return proc_start
        return None

    def _scan_jump_table(self):
        """Scan the jump table at the start of bank 0A."""
        entries = []
        i = 0
        while i < len(self.data_0a):
            if self.data_0a[i] == 0x4C:  # JMP abs
                target = self.data_0a[i+1] | (self.data_0a[i+2] << 8)
                entries.append((0xA000 + i, target))
                i += 3
            else:
                break
        return entries


def get_label_for_addr(addr, labels, known_funcs, local_labels, current_proc=None, proc_overrides=None):
    """Get the best label for an address."""
    if proc_overrides and addr in proc_overrides:
        return proc_overrides[addr]
    if addr in labels:
        return labels[addr]
    if addr in known_funcs:
        return known_funcs[addr]
    if addr in local_labels:
        return f"@L{addr:04X}"
    return None


def format_operand(mode, operand_bytes, addr, labels, local_labels, current_proc=None, proc_overrides=None):
    """Format the operand string."""
    if mode == "IMP":
        return ""
    elif mode == "ACC":
        return "A"
    elif mode == "IMM":
        return f"#${operand_bytes[0]:02X}"
    elif mode == "ZP":
        return f"${operand_bytes[0]:02X}"
    elif mode == "ZPX":
        return f"${operand_bytes[0]:02X},X"
    elif mode == "ZPY":
        return f"${operand_bytes[0]:02X},Y"
    elif mode == "REL":
        offset = operand_bytes[0]
        if offset >= 0x80:
            offset -= 0x100
        target = addr + 2 + offset
        lbl = get_label_for_addr(target, labels, KNOWN_FUNCS, local_labels, current_proc, proc_overrides)
        if lbl:
            return lbl
        return f"${target:04X}"
    elif mode == "ABS":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        lbl = get_label_for_addr(val, labels, KNOWN_FUNCS, local_labels, current_proc, proc_overrides)
        if lbl:
            return lbl
        if val <= 0x00FF:
            return f"a:${val:04X}"
        return f"${val:04X}"
    elif mode == "ABX":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        lbl = get_label_for_addr(val, labels, KNOWN_FUNCS, local_labels, current_proc, proc_overrides)
        if lbl:
            return f"{lbl},X"
        if val <= 0x00FF:
            return f"a:${val:04X},X"
        return f"${val:04X},X"
    elif mode == "ABY":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        lbl = get_label_for_addr(val, labels, KNOWN_FUNCS, local_labels, current_proc, proc_overrides)
        if lbl:
            return f"{lbl},Y"
        if val <= 0x00FF:
            return f"a:${val:04X},Y"
        return f"${val:04X},Y"
    elif mode == "IND":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        lbl = get_label_for_addr(val, labels, KNOWN_FUNCS, local_labels, current_proc, proc_overrides)
        if lbl:
            return f"({lbl})"
        return f"(${val:04X})"
    elif mode == "IZX":
        return f"(${operand_bytes[0]:02X},X)"
    elif mode == "IZY":
        return f"(${operand_bytes[0]:02X}),Y"
    return ""


def get_proc_name(addr, labels):
    """Get a proc name for the given address."""
    if addr in PROC_NAMESS:
        return PROC_NAMESS[addr]
    if addr in labels:
        name = labels[addr]
        if name.startswith("B0A_") or name.startswith("B0B_"):
            return name
    return f"Proc_{addr:04X}"


def compute_valid_emit_offsets(data, base_addr, code_bytes, inline_tables):
    """Compute which offsets emit_bank will emit as instruction/data starts.
    This mimics emit_bank's linear scan logic."""
    valid = set()
    offset = 0
    while offset < len(data):
        valid.add(base_addr + offset)
        addr = base_addr + offset
        # Inline table
        if addr in inline_tables:
            table_end = inline_tables[addr]
            while addr < table_end and offset + 1 < len(data):
                offset += 2
                addr = base_addr + offset
            continue
        # Code instruction
        if offset in code_bytes:
            byte_val = data[offset]
            if byte_val in OPCODES:
                mnemonic, mode, length = OPCODES[byte_val]
                if offset + length <= len(data):
                    offset += length
                    continue
        # Data byte - skip to next label/proc/inline-table boundary
        data_start = offset
        while offset < len(data) and offset not in code_bytes:
            next_addr = base_addr + offset
            if next_addr in inline_tables:
                break
            if next_addr in valid and offset != data_start:
                break
            offset += 1
        if offset == data_start:
            offset += 1
    return valid


def emit_bank(data, base_addr, code_bytes, inline_tables, labels, all_labels,
              local_labels, proc_ranges, dis):
    """Emit assembly for a single bank with .proc/.endproc and labeled sections."""
    lines = []
    offset = 0
    current_section = None
    current_proc_start = None
    in_proc = False  # Are we currently inside a .proc block?
    
    # Build sorted proc starts and compute proc end offsets
    bank_proc_starts = sorted([s for s in proc_ranges if (base_addr <= s < base_addr + len(data))])
    proc_at_offset = {}
    proc_end_offset = {}  # offset -> True if .endproc should be emitted before this offset
    for i, ps in enumerate(bank_proc_starts):
        proc_at_offset[ps - base_addr] = ps
        # The proc ends just before the next proc starts (or at end of bank)
        if i + 1 < len(bank_proc_starts):
            next_ps_off = bank_proc_starts[i + 1] - base_addr
        else:
            next_ps_off = len(data)
        # Store the proc end for cross-proc branch detection
        proc_end_offset[ps - base_addr] = next_ps_off

    # Track labels defined inside current proc (to expose after .endproc)
    proc_internal_labels = {}  # addr -> label name

    def analyze_proc_ram_usage(proc_start_addr, proc_end_offset):
        """Analyze which RAM/ZP addresses a proc accesses."""
        ram_addrs = set()
        proc_start_offset = proc_start_addr - base_addr
        off = proc_start_offset
        while off < proc_end_offset and off < len(data):
            if off not in code_bytes:
                off += 1
                continue
            byte_val = data[off]
            if byte_val not in OPCODES:
                off += 1
                continue
            mn, mode, length = OPCODES[byte_val]
            if off + length > len(data):
                break
            # Check if this instruction accesses a RAM address
            if mode in ("ZP", "ZPX", "ZPY", "IZX", "IZY"):
                zp_addr = data[off + 1]
                if zp_addr in RAM_NAMES:
                    ram_addrs.add(zp_addr)
            elif mode in ("ABS", "ABX", "ABY", "IND"):
                abs_addr = data[off + 1] | (data[off + 2] << 8)
                if abs_addr in RAM_NAMES:
                    ram_addrs.add(abs_addr)
            off += length
        return sorted(ram_addrs)

    def emit_endproc_if_needed():
        """Emit .endproc and expose internal labels as globals."""
        nonlocal in_proc
        if in_proc:
            lines.append(".endproc")
            # Expose internal labels as global aliases
            for laddr in sorted(proc_internal_labels.keys()):
                lname = proc_internal_labels[laddr]
                lines.append(f"{lname} = ${laddr:04X}")
            if proc_internal_labels:
                lines.append("")
            proc_internal_labels.clear()
            lines.append("")
            in_proc = False

    while offset < len(data):
        addr = base_addr + offset

        # Check if we're entering a new proc
        if offset in proc_at_offset:
            emit_endproc_if_needed()
            current_section = proc_at_offset[offset]
            current_proc_start = current_section
            proc_name = get_proc_name(current_section, labels)
            # Emit section header comment
            lines.append(";" + "=" * 79)
            lines.append(f"; ${current_section:04X}: {proc_name}")
            # Add logic comment if available
            if current_section in PROC_COMMENTS:
                lines.append(f"; {PROC_COMMENTS[current_section]}")
            lines.append(";" + "=" * 79)
            # Emit .proc directive
            lines.append(f".proc {proc_name}")
            # Emit local parameter aliases for RAM/ZP addresses used in this proc
            proc_end_off = proc_end_offset.get(offset, len(data))
            ram_usage = analyze_proc_ram_usage(current_section, proc_end_off)
            if ram_usage:
                for ram_addr in ram_usage:
                    ram_name = RAM_NAMES[ram_addr]
                    lines.append(f"  {ram_name:<24} = ${ram_addr:04X}")
            lines.append("")
            in_proc = True

        # Emit label if present (skip proc name at proc start - .proc already declares it)
        if addr in all_labels:
            if not (offset in proc_at_offset):
                lines.append(f"{all_labels[addr]}:")
                if in_proc:
                    proc_internal_labels[addr] = all_labels[addr]
        elif addr in local_labels:
            lines.append(f"@L{addr:04X}:")


        # Check if this is an inline table
        if addr in inline_tables:
            table_end = inline_tables[addr]
            table_size = table_end - addr
            is_trampoline = (table_size == 2)
            if is_trampoline:
                lines.append(f"  ; --- BankedCallbackTrampoline target ---")
            else:
                num_entries = table_size // 2
                lines.append(f"  ; --- Inline pointer table ({num_entries} entries) ---")
            while addr < table_end and offset + 1 < len(data):
                lo = data[offset]
                hi = data[offset+1]
                ptr = lo | (hi << 8)
                if is_trampoline:
                    line = f"  .addr ${ptr:04X}"
                else:
                    ptr_label = all_labels.get(ptr, KNOWN_FUNCS.get(ptr, f"${ptr:04X}"))
                    line = f"  .addr {ptr_label}"
                comment = f"; ${addr:04X}: {lo:02X} {hi:02X}"
                lines.append(f"{line:<54}{comment}")
                offset += 2
                addr = base_addr + offset
            continue

        # Check if this byte is code
        if offset in code_bytes:
            byte_val = data[offset]
            if byte_val in OPCODES:
                mnemonic, mode, length = OPCODES[byte_val]
                if offset + length <= len(data):
                    operand_bytes = data[offset+1:offset+length]
                    raw_bytes = data[offset:offset+length]
                    raw_hex = " ".join(f"{b:02X}" for b in raw_bytes)

                    operand_str = format_operand(mode, operand_bytes, addr, all_labels,
                                               local_labels, current_proc_start, None)

                    # Check for branches that ca65 can't resolve
                    if mode == "REL":
                        rel_offset = operand_bytes[0]
                        if rel_offset >= 0x80:
                            rel_offset -= 0x100
                        target = addr + 2 + rel_offset
                        src_bank = 0x0A if addr <= 0xBFFF else 0x0B
                        tgt_bank = 0x0A if target <= 0xBFFF else 0x0B
                        # Check if target is outside current proc (cross-proc branch)
                        is_cross_proc = False
                        if current_proc_start is not None and current_proc_start in proc_ranges:
                            ps, pe = proc_ranges[current_proc_start]
                            if not (ps <= target < pe):
                                is_cross_proc = True
                        target_has_label = (target in all_labels or target in KNOWN_FUNCS or target in local_labels)
                        if src_bank != tgt_bank or not target_has_label or is_cross_proc:
                            hex_bytes = ",".join(f"${b:02X}" for b in raw_bytes)
                            line = f"  .byte {hex_bytes}"
                            if src_bank != tgt_bank:
                                reason = "cross-bank"
                            elif is_cross_proc:
                                reason = "cross-proc"
                            else:
                                reason = "mid-instruction target"
                            comment = f"; ${addr:04X}: {raw_hex} ({mnemonic} {reason})"
                            lines.append(f"{line:<54}{comment}")
                            offset += length
                            continue

                    if mode == "ACC":
                        line = f"  {mnemonic} A"
                    elif operand_str:
                        line = f"  {mnemonic} {operand_str}"
                    else:
                        line = f"  {mnemonic}"

                    comment = f"; ${addr:04X}: {raw_hex}"
                    lines.append(f"{line:<54}{comment}")
                    offset += length
                    continue

        # Data byte - group consecutive data bytes
        data_start = offset
        while offset < len(data) and offset not in code_bytes:
            next_addr = base_addr + offset
            if next_addr in inline_tables:
                break
            if next_addr in all_labels and offset != data_start:
                break
            if next_addr in local_labels and offset != data_start:
                break
            if next_addr in proc_at_offset and offset != data_start:
                break
            offset += 1
        if offset == data_start:
            offset += 1

        # Emit data in chunks of 16
        pos = data_start
        while pos < offset:
            chunk_addr = base_addr + pos
            if pos != data_start:
                if chunk_addr in all_labels:
                    lines.append(f"{all_labels[chunk_addr]}:")
                elif chunk_addr in local_labels:
                    lines.append(f"@L{chunk_addr:04X}:")


            chunk_size = min(16, offset - pos)
            for i in range(1, chunk_size):
                if (base_addr + pos + i) in all_labels or (base_addr + pos + i) in local_labels:
                    chunk_size = i
                    break

            chunk = data[pos:pos+chunk_size]
            hex_bytes = ",".join(f"${b:02X}" for b in chunk)
            raw_bytes_str = " ".join(f"{b:02X}" for b in chunk)
            line = f"  .byte {hex_bytes}"
            comment = f"; ${chunk_addr:04X}: {raw_bytes_str}"
            lines.append(f"{line:<54}{comment}")
            pos += chunk_size

    emit_endproc_if_needed()
    return lines


def find_fallthrough_entry_points(dis, data_0a, data_0b):
    """Find code addresses that follow RTS/JMP instructions (unreached code).
    Uses proper instruction boundary tracking to avoid mid-instruction addresses."""
    new_entries = set()

    for bank_data, base, code_bytes in [
        (data_0a, 0xA000, dis.code_bytes_0a),
        (data_0b, 0xC000, dis.code_bytes_0b)
    ]:
        # Walk through code bytes following instruction boundaries
        offset = 0
        while offset < len(bank_data):
            if offset not in code_bytes:
                offset += 1
                continue
            byte_val = bank_data[offset]
            if byte_val not in OPCODES:
                offset += 1
                continue
            mnemonic, mode, length = OPCODES[byte_val]
            if offset + length > len(bank_data):
                break

            # After RTS or JMP (terminators), the next byte might be a new procedure
            if mnemonic in ("RTS", "JMP"):
                next_off = offset + length
                if next_off < len(bank_data):
                    next_addr = base + next_off
                    next_byte = bank_data[next_off]
                    # Only add if it looks like valid code and isn't already traced
                    if next_byte in OPCODES and next_off not in code_bytes:
                        new_entries.add(next_addr)

            # For branches, also check fallthrough (branch not taken)
            if mode == "REL":
                next_off = offset + length
                if next_off < len(bank_data):
                    next_addr = base + next_off
                    next_byte = bank_data[next_off]
                    if next_byte in OPCODES and next_off not in code_bytes:
                        new_entries.add(next_addr)

            offset += length

    return new_entries


def main():
    # Read binaries
    with open("/home/zero/project/sango2dasm/rom/prg/prg_0a.bin", "rb") as f:
        data_0a = f.read()
    with open("/home/zero/project/sango2dasm/rom/prg/prg_0b.bin", "rb") as f:
        data_0b = f.read()

    assert len(data_0a) == 8192, f"Bank 0A size: {len(data_0a)}"
    assert len(data_0b) == 8192, f"Bank 0B size: {len(data_0b)}"

    # Create disassembler
    dis = RecursiveDescentDisassembler(data_0a, data_0b)

    # Entry points from jump table
    entry_points = []
    jt_entries = dis._scan_jump_table()
    for entry_addr, target in jt_entries:
        entry_points.append(entry_addr)
        entry_points.append(target)

    # First code after jump table
    entry_points.append(0xA00F)

    # Bank 0B starts with code
    entry_points.append(0xC000)

    entry_points = sorted(set(entry_points))
    print(f"Starting with {len(entry_points)} entry points")

    # Iterative tracing: trace, find new entry points (fallthrough + JSR targets), re-trace
    for iteration in range(10):
        dis.trace_code(entry_points, is_fallthrough=(iteration > 0))

        # Find fallthrough entry points (after RTS/JMP)
        new_entries = find_fallthrough_entry_points(dis, data_0a, data_0b)

        new_entries -= set(entry_points)
        if not new_entries:
            print(f"Iteration {iteration}: no new entry points, converged")
            break
        print(f"Iteration {iteration}: found {len(new_entries)} new entry points")
        entry_points.extend(sorted(new_entries))

    code_0a_count = len(dis.code_bytes_0a)
    code_0b_count = len(dis.code_bytes_0b)
    print(f"Bank $0A: {code_0a_count}/8192 bytes traced as code ({100*code_0a_count/8192:.1f}%)")
    print(f"Bank $0B: {code_0b_count}/8192 bytes traced as code ({100*code_0b_count/8192:.1f}%)")
    print(f"Inline tables: bank0a={len(dis.inline_tables_0a)}, bank0b={len(dis.inline_tables_0b)}")

    # Build labels
    # Remove jump table entries from proc_starts (they're just JMP stubs, not real procs)
    jt_addrs = {addr for addr, _ in jt_entries}
    dis.proc_starts -= jt_addrs

    # Remove proc_starts at mid-instruction addresses
    # An address is mid-instruction if a code byte at a lower offset
    # has an instruction that spans across it
    invalid_ps = set()
    for ps in sorted(dis.proc_starts):
        for bank_data, base, code_bytes_set in [
            (data_0a, 0xA000, dis.code_bytes_0a),
            (data_0b, 0xC000, dis.code_bytes_0b)
        ]:
            if not (base <= ps < base + len(bank_data)):
                continue
            ps_off = ps - base
            # Check if any instruction starting before ps_off spans across ps_off
            for check_off in range(max(0, ps_off - 4), ps_off):
                if check_off not in code_bytes_set:
                    continue
                bv = bank_data[check_off]
                if bv not in OPCODES:
                    continue
                mn, mo, ln = OPCODES[bv]
                if check_off < ps_off < check_off + ln:
                    # ps_off is within an instruction starting at check_off
                    invalid_ps.add(ps)
    dis.proc_starts -= invalid_ps
    print(f"Removed {len(invalid_ps)} mid-instruction proc_starts")

    dis.compute_proc_ranges()
    dis.build_labels()

    # Merge all labels
    all_labels = dict(dis.labels)
    all_labels.update(KNOWN_FUNCS)
    all_labels.update(PROC_NAMESS)
    local_labels = dis.local_labels

    # Filter out labels at mid-instruction addresses only
    # (labels at addresses that are inside a multi-byte instruction's operand bytes)
    mid_instr_labels = set()
    for bank_data, base, cb in [
        (data_0a, 0xA000, dis.code_bytes_0a),
        (data_0b, 0xC000, dis.code_bytes_0b)
    ]:
        for off in sorted(cb):
            bv = bank_data[off]
            if bv not in OPCODES:
                continue
            mn, mo, ln = OPCODES[bv]
            if ln <= 1:
                continue
            # Mark operand bytes as mid-instruction
            for j in range(1, ln):
                if off + j in cb:  # operand byte is also code
                    mid_instr_labels.add(base + off + j)
    for addr in list(all_labels.keys()):
        if addr in mid_instr_labels:
            del all_labels[addr]

    # Generate combined output file
    out = []
    out.append(";===============================================================================")
    out.append("; PRG Banks $0A+$0B - Combined 16KB ($A000-$DFFF)")
    out.append("; Sangokushi 2 - Haou no Tairiku (J)")
    out.append("; Namco-163 Mapper 19")
    out.append(";")
    out.append("; Bank $0A at $A000-$BFFF, Bank $0B at $C000-$DFFF")
    out.append(";===============================================================================")
    out.append("")
    out.append('.include "6502_registers.h"')
    out.append('.include "namco163.h"')
    out.append('.include "functions.h"')
    out.append("")

    # .global directives for ALL labels (ca65 .proc makes labels inside it local)
    # This ensures all labels are visible across .proc boundaries
    all_global_names = set()
    for ps in dis.proc_starts:
        all_global_names.add(get_proc_name(ps, dis.labels))
    for addr, name in all_labels.items():
        if dis.is_in_range(addr):
            all_global_names.add(name)
    for addr, name in KNOWN_FUNCS.items():
        if dis.is_in_range(addr):
            all_global_names.add(name)
    if all_global_names:
        out.append("; Global label declarations (ca65 .proc creates local scope)")
        for name in sorted(all_global_names):
            out.append(f".global {name}")
        out.append("")

    # Global RAM definitions
    out.append(";===============================================================================")
    out.append("; Global RAM Address Definitions")
    out.append(";===============================================================================")
    out.append("; These addresses have consistent meaning across the bank pair.")
    out.append("")
    out.append("; --- Battery SRAM ($6Fxx) ---")
    out.append("sram_kingdom_index     = $6F02  ; Kingdom/region index")
    out.append("sram_player_id         = $6F03  ; Current player ID / slot")
    out.append("sram_game_start_flag   = $6F8B  ; Game start flag ($FF = new game)")
    out.append("sram_work_0            = $6F5F  ; Computed work value 0")
    out.append("sram_work_1            = $6F60  ; Computed work value 1")
    out.append("sram_work_2            = $6F61  ; Computed work value 2")
    out.append("sram_counter           = $6F5B  ; Iteration counter")
    out.append("")
    out.append("; --- Work Area ($0036-$0045) ---")
    out.append("work_outer_idx         = $0036  ; Outer loop index")
    out.append("work_inner_idx         = $0037  ; Inner loop index")
    out.append("work_inner_idx2        = $0038  ; Inner loop index 2")
    out.append("work_sub_idx           = $0039  ; Sub-loop index")
    out.append("work_limit_a           = $003A  ; Comparison limit A")
    out.append("work_limit_b           = $003B  ; Comparison limit B")
    out.append("work_temp_0            = $003C  ; Temporary storage 0")
    out.append("work_temp_1            = $003D  ; Temporary storage 1")
    out.append("work_temp_2            = $003E  ; Temporary storage 2")
    out.append("work_record_idx        = $003F  ; Record index")
    out.append("work_record_val        = $0040  ; Record value")
    out.append("work_search_result     = $0041  ; Search/comparison result")
    out.append("work_search_max        = $0045  ; Search max value")
    out.append("")
    out.append("; --- Math Workspace ($20-$27) ---")
    out.append("math_acc_lo            = $20    ; Accumulator low byte")
    out.append("math_acc_mlo           = $21    ; Accumulator mid-low")
    out.append("math_acc_mhi           = $22    ; Accumulator mid-high")
    out.append("math_acc_hi            = $23    ; Accumulator high byte")
    out.append("math_ext               = $24    ; Extension byte")
    out.append("math_temp1             = $25    ; Math temporary 1")
    out.append("math_temp2             = $26    ; Math temporary 2")
    out.append("math_temp3             = $27    ; Math temporary 3")
    out.append("")
    out.append("; --- Game State ($05xx) ---")
    out.append("state_sub_dispatch     = $0540  ; Sub-state dispatch index")
    out.append("state_display_idx      = $0541  ; Display state index")
    out.append("state_overlay_param    = $0545  ; Overlay/menu parameter")
    out.append("state_palette_mode     = $0547  ; Palette animation mode")
    out.append("")

    # Emit bank $0A
    out.append('.segment "CODE_BANK0A"')
    out.append("")

    # Jump table
    out.append(";===============================================================================")
    out.append("; Jump Table - Public entry points ($A000-$A00E)")
    out.append(";===============================================================================")

    asm_0a = emit_bank(data_0a, 0xA000, dis.code_bytes_0a, dis.inline_tables_0a,
                        dis.labels, all_labels, local_labels, dis.proc_ranges, dis)
    out.extend(asm_0a)

    out.append("")

    # Emit bank $0B
    out.append(';===============================================================================')
    out.append('; Bank $0B - $C000-$DFFF')
    out.append(';===============================================================================')
    out.append("")
    out.append('.segment "CODE_BANK0B"')
    out.append("")

    asm_0b = emit_bank(data_0b, 0xC000, dis.code_bytes_0b, dis.inline_tables_0b,
                        dis.labels, all_labels, local_labels, dis.proc_ranges, dis)
    out.extend(asm_0b)

    # Write output
    output_path = "/home/zero/project/sango2dasm/asm/banks/prg_0a_0b.asm"
    with open(output_path, "w") as f:
        f.write("\n".join(out) + "\n")

    total_lines = len(out)
    print(f"\nWritten {total_lines} lines to {output_path}")
    print("Done!")


if __name__ == "__main__":
    main()
