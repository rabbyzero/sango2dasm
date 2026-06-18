#!/usr/bin/env python3
"""
Disassembler for PRG banks $17 and $18 (paired 16KB block at $A000-$DFFF).
Uses recursive descent to distinguish code from data.
Produces ca65-compatible assembly with inline byte comments.
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

# Known functions in bank $1F
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


class RecursiveDescentDisassembler:
    """Recursive descent disassembler for 6502 code."""
    
    def __init__(self, combined_data, base_addr_17=0xA000, base_addr_18=0xC000):
        self.data_17 = combined_data[:8192]
        self.data_18 = combined_data[8192:]
        self.base_17 = base_addr_17
        self.base_18 = base_addr_18
        # Track which bytes are code vs unknown
        self.code_bytes_17 = set()  # set of offsets that are code
        self.code_bytes_18 = set()
        # Inline tables (addr -> size in bytes)
        self.inline_tables_17 = {}  # addr -> end_addr
        self.inline_tables_18 = {}
        # Labels
        self.labels = {}
    
    def get_byte(self, addr):
        """Get byte at given address from appropriate bank."""
        if 0xA000 <= addr <= 0xBFFF:
            return self.data_17[addr - 0xA000]
        elif 0xC000 <= addr <= 0xDFFF:
            return self.data_18[addr - 0xC000]
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
                self.code_bytes_17.add(a - 0xA000)
            elif 0xC000 <= a <= 0xDFFF:
                self.code_bytes_18.add(a - 0xC000)
    
    def is_in_range(self, addr):
        """Check if address is within our banks."""
        return 0xA000 <= addr <= 0xBFFF or 0xC000 <= addr <= 0xDFFF
    
    def is_already_code(self, addr):
        """Check if address is already marked as code."""
        if 0xA000 <= addr <= 0xBFFF:
            return (addr - 0xA000) in self.code_bytes_17
        elif 0xC000 <= addr <= 0xDFFF:
            return (addr - 0xC000) in self.code_bytes_18
        return False
    
    def trace_code(self, entry_points):
        """Recursive descent code tracing from entry points."""
        queue = deque(entry_points)
        visited_starts = set()
        
        while queue:
            addr = queue.popleft()
            
            if addr in visited_starts:
                continue
            if not self.is_in_range(addr):
                continue
            
            visited_starts.add(addr)
            
            # Trace linearly from this point
            pc = addr
            while self.is_in_range(pc):
                if self.is_already_code(pc):
                    break  # Already traced
                
                byte_val = self.get_byte(pc)
                if byte_val is None or byte_val not in OPCODES:
                    break  # Hit invalid opcode = likely data
                
                mnemonic, mode, length = OPCODES[byte_val]
                
                # Check we can read the full instruction
                instr_bytes = self.get_bytes(pc, length)
                if instr_bytes is None:
                    break
                
                # Mark as code
                self.mark_code(pc, length)
                
                # Handle branches
                if mode == "REL":
                    offset = instr_bytes[1]
                    if offset >= 0x80:
                        offset -= 0x100
                    target = pc + 2 + offset
                    if self.is_in_range(target):
                        queue.append(target)
                    # Branches also fall through
                    pc += length
                    continue
                
                # Handle JSR
                if mnemonic == "JSR" and mode == "ABS":
                    target = instr_bytes[1] | (instr_bytes[2] << 8)
                    if self.is_in_range(target):
                        queue.append(target)
                    
                    # Check for CallbackDispatcher pattern
                    if target == 0xEADE:
                        # After JSR $EADE, inline pointer table follows
                        table_start = pc + 3
                        table_size = self._find_callback_table_size(table_start)
                        if table_size > 0:
                            if 0xA000 <= table_start <= 0xBFFF:
                                self.inline_tables_17[table_start] = table_start + table_size
                            else:
                                self.inline_tables_18[table_start] = table_start + table_size
                            # Add all pointer targets as entry points
                            for i in range(0, table_size, 2):
                                ptr_bytes = self.get_bytes(table_start + i, 2)
                                if ptr_bytes:
                                    ptr = ptr_bytes[0] | (ptr_bytes[1] << 8)
                                    if self.is_in_range(ptr):
                                        queue.append(ptr)
                            # Skip past the table
                            pc = table_start + table_size
                            continue
                    
                    # Check for BankedCallbackTrampoline pattern
                    if target == 0xEE07:
                        # After JSR $EE07, 2-byte inline .word target follows
                        inline_start = pc + 3
                        ptr_bytes = self.get_bytes(inline_start, 2)
                        if ptr_bytes:
                            # Mark as inline table
                            if 0xA000 <= inline_start <= 0xBFFF:
                                self.inline_tables_17[inline_start] = inline_start + 2
                            else:
                                self.inline_tables_18[inline_start] = inline_start + 2
                            # The ptr target is in another bank (not ours), skip it
                            # Code resumes after the 2-byte inline
                            pc = inline_start + 2
                            continue
                    
                    # JSR falls through
                    pc += length
                    continue
                
                # Handle JMP absolute
                if mnemonic == "JMP" and mode == "ABS":
                    target = instr_bytes[1] | (instr_bytes[2] << 8)
                    if self.is_in_range(target):
                        queue.append(target)
                    break  # JMP doesn't fall through
                
                # Handle JMP indirect
                if mnemonic == "JMP" and mode == "IND":
                    break  # Can't follow indirect jumps
                
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
            
            # Valid pointers should be in $A000-$DFFF range
            if not (0xA000 <= ptr <= 0xDFFF):
                break
            
            entries += 1
            if ptr < min_ptr:
                min_ptr = ptr
            addr += 2
            
            # Table ends when we've reached the minimum pointer
            if addr >= min_ptr:
                break
            
            # Safety: max 32 entries
            if entries >= 32:
                break
        
        return entries * 2
    
    def build_labels(self):
        """Build label dictionary from traced code."""
        # Collect all targets
        targets_17 = set()
        targets_18 = set()
        
        # From code instructions
        for bank_data, base, code_bytes in [
            (self.data_17, self.base_17, self.code_bytes_17),
            (self.data_18, self.base_18, self.code_bytes_18)
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
                
                if mode == "REL":
                    off_val = operand[0]
                    if off_val >= 0x80:
                        off_val -= 0x100
                    target = addr + 2 + off_val
                    if 0xA000 <= target <= 0xBFFF:
                        targets_17.add(target)
                    elif 0xC000 <= target <= 0xDFFF:
                        targets_18.add(target)
                
                if mode == "ABS" and mnemonic in ("JMP", "JSR"):
                    target = operand[0] | (operand[1] << 8)
                    if 0xA000 <= target <= 0xBFFF:
                        targets_17.add(target)
                    elif 0xC000 <= target <= 0xDFFF:
                        targets_18.add(target)
                
                offset += length
        
        # From inline tables
        for tables, data, base in [
            (self.inline_tables_17, self.data_17, self.base_17),
            (self.inline_tables_18, self.data_18, self.base_18)
        ]:
            for tbl_start, tbl_end in tables.items():
                off = tbl_start - base
                while base + off < tbl_end:
                    lo = data[off]
                    hi = data[off+1]
                    ptr = lo | (hi << 8)
                    if 0xA000 <= ptr <= 0xBFFF:
                        targets_17.add(ptr)
                    elif 0xC000 <= ptr <= 0xDFFF:
                        targets_18.add(ptr)
                    off += 2
        
        # Build label dict
        # Jump table entries for bank 17
        for i in range(14):
            addr = 0xA000 + i * 3
            self.labels[addr] = f"B17_Entry{i:02X}"
        
        # Known entry points in bank 18
        self.labels[0xD693] = "B18_Entry0A"
        self.labels[0xDE25] = "B18_Entry0B"
        self.labels[0xDF15] = "B18_Entry0C"
        
        # Auto labels
        for target in sorted(targets_17):
            if target not in self.labels and 0xA000 <= target <= 0xBFFF:
                self.labels[target] = f"L{target:04X}"
        for target in sorted(targets_18):
            if target not in self.labels and 0xC000 <= target <= 0xDFFF:
                self.labels[target] = f"L{target:04X}"


def format_operand(mode, operand_bytes, addr, labels):
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
        if target in labels:
            return labels[target]
        return f"${target:04X}"
    elif mode == "ABS":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        if val in labels:
            return labels[val]
        if val in KNOWN_FUNCS:
            return KNOWN_FUNCS[val]
        # Force absolute addressing for zero-page addresses (prevent ca65 optimization)
        if val <= 0x00FF:
            return f"a:${val:04X}"
        return f"${val:04X}"
    elif mode == "ABX":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        if val in labels:
            return f"{labels[val]},X"
        # Force absolute addressing for zero-page addresses
        if val <= 0x00FF:
            return f"a:${val:04X},X"
        return f"${val:04X},X"
    elif mode == "ABY":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        if val in labels:
            return f"{labels[val]},Y"
        # Force absolute addressing for zero-page addresses
        if val <= 0x00FF:
            return f"a:${val:04X},Y"
        return f"${val:04X},Y"
    elif mode == "IND":
        val = operand_bytes[0] | (operand_bytes[1] << 8)
        if val in labels:
            return f"({labels[val]})"
        return f"(${val:04X})"
    elif mode == "IZX":
        return f"(${operand_bytes[0]:02X},X)"
    elif mode == "IZY":
        return f"(${operand_bytes[0]:02X}),Y"
    return ""


def emit_bank(data, base_addr, code_bytes, inline_tables, labels, all_labels):
    """Emit assembly for a bank."""
    lines = []
    offset = 0
    
    while offset < len(data):
        addr = base_addr + offset
        
        # Emit label if present
        if addr in all_labels:
            lines.append(f"{all_labels[addr]}:")
        
        # Check if this is an inline table
        if addr in inline_tables:
            table_end = inline_tables[addr]
            table_size = table_end - addr
            num_entries = table_size // 2
            is_trampoline = (table_size == 2)  # BankedCallbackTrampoline = 1 entry
            if is_trampoline:
                lines.append(f"; --- BankedCallbackTrampoline target ---")
            else:
                lines.append(f"; --- Inline pointer table ({num_entries} entries) ---")
            while addr < table_end and offset + 1 < len(data):
                lo = data[offset]
                hi = data[offset+1]
                ptr = lo | (hi << 8)
                if is_trampoline:
                    # Trampoline targets are in OTHER banks, use raw address
                    line = f"  .word ${ptr:04X}"
                else:
                    # CallbackDispatcher targets are in our bank pair, use labels
                    ptr_label = all_labels.get(ptr, KNOWN_FUNCS.get(ptr, f"${ptr:04X}"))
                    line = f"  .word {ptr_label}"
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
                    
                    operand_str = format_operand(mode, operand_bytes, addr, all_labels)
                    
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
        
        # Data byte
        # Try to group consecutive data bytes
        data_start = offset
        while offset < len(data) and offset not in code_bytes:
            next_addr = base_addr + offset
            if next_addr in inline_tables:
                break
            if next_addr in all_labels and offset != data_start:
                break
            offset += 1
        
        # Emit data in chunks of 16
        pos = data_start
        while pos < offset:
            chunk_addr = base_addr + pos
            # Check for label in middle of data
            if pos != data_start and chunk_addr in all_labels:
                lines.append(f"{all_labels[chunk_addr]}:")
            
            chunk_size = min(16, offset - pos)
            # Don't cross a label boundary
            for i in range(1, chunk_size):
                if (base_addr + pos + i) in all_labels:
                    chunk_size = i
                    break
            
            chunk = data[pos:pos+chunk_size]
            hex_bytes = ",".join(f"${b:02X}" for b in chunk)
            raw_bytes_str = " ".join(f"{b:02X}" for b in chunk)
            line = f"  .byte {hex_bytes}"
            comment = f"; ${chunk_addr:04X}: {raw_bytes_str}"
            lines.append(f"{line:<54}{comment}")
            pos += chunk_size
    
    return lines


def main():
    # Read binaries
    with open("/home/zero/project/sango2dasm/rom/prg/prg_17.bin", "rb") as f:
        data_17 = f.read()
    with open("/home/zero/project/sango2dasm/rom/prg/prg_18.bin", "rb") as f:
        data_18 = f.read()
    
    assert len(data_17) == 8192
    assert len(data_18) == 8192
    
    combined = data_17 + data_18
    
    # Create disassembler
    dis = RecursiveDescentDisassembler(combined)
    
    # Entry points for bank $17 (each JMP in jump table + their targets)
    entry_points = []
    for i in range(0, 0x2A, 3):
        entry_points.append(0xA000 + i)  # The JMP instruction itself
        if data_17[i] == 0x4C:  # JMP
            target = data_17[i+1] | (data_17[i+2] << 8)
            entry_points.append(target)
    
    # Additional code entry points discovered by inspection
    # (unreached code after RTS that starts valid instruction sequences)
    entry_points.append(0xA0E4)  # Code after LA0D2 RTS
    entry_points.append(0xB7C2)  # Code subroutine
    entry_points.append(0xBC72)  # Code after BankedCallbackTrampoline inline
    
    # Entry points for bank $18 (targets from bank $17)
    entry_points.extend([0xD693, 0xDE25, 0xDF15])
    # Also $C08A (first code after data)
    entry_points.append(0xC08A)
    
    print(f"Starting with {len(entry_points)} entry points")
    
    # Trace code
    dis.trace_code(entry_points)
    
    code_17_count = len(dis.code_bytes_17)
    code_18_count = len(dis.code_bytes_18)
    print(f"Bank $17: {code_17_count}/8192 bytes traced as code ({100*code_17_count/8192:.1f}%)")
    print(f"Bank $18: {code_18_count}/8192 bytes traced as code ({100*code_18_count/8192:.1f}%)")
    print(f"Inline tables: bank17={len(dis.inline_tables_17)}, bank18={len(dis.inline_tables_18)}")
    
    # Build labels
    dis.build_labels()
    
    # Merge all labels
    all_labels = dict(dis.labels)
    all_labels.update(KNOWN_FUNCS)

    # Collect cross-bank label references
    cross_refs_17 = {}  # labels in $C000-$DFFF referenced from bank 17
    cross_refs_18 = {}  # labels in $A000-$BFFF referenced from bank 18
    for addr, label in dis.labels.items():
        if 0xC000 <= addr <= 0xDFFF:
            cross_refs_17[label] = addr
        elif 0xA000 <= addr <= 0xBFFF:
            cross_refs_18[label] = addr

    
    # Emit bank $17
    print("\n=== Generating prg_17.asm ===")
    out_17 = []
    out_17.append(";===============================================================================")
    out_17.append("; PRG Bank $17 - $A000-$BFFF")
    out_17.append("; Sangokushi 2 - Haou no Tairiku (J)")
    out_17.append("; Namco-163 Mapper 19")
    out_17.append(";")
    out_17.append("; Paired with bank $18 ($C000-$DFFF). Loaded together via SwitchBankAC_A/B.")
    out_17.append("; Y=$37 -> bank $17@$A000, bank $18@$C000")
    out_17.append(";===============================================================================")
    out_17.append("")
    out_17.append('.include "6502_registers.h"')
    out_17.append('.include "namco163.h"')
    out_17.append('.include "functions.h"')
    out_17.append("")
    out_17.append('.segment "CODE_BANK17"')
    out_17.append("")
    out_17.append(";===============================================================================")
    out_17.append(";===============================================================================")
    out_17.append("; Cross-bank references to bank $18 ($C000-$DFFF)")
    out_17.append(";===============================================================================")
    for label in sorted(cross_refs_17.keys()):
        addr = cross_refs_17[label]
        out_17.append(f"{label:<24}= ${addr:04X}")
    out_17.append("")
    out_17.append(";===============================================================================")
    out_17.append("; Jump Table - Public entry points ($A000-$A029)")
    out_17.append(";===============================================================================")
    
    asm_17 = emit_bank(data_17, 0xA000, dis.code_bytes_17, dis.inline_tables_17, dis.labels, all_labels)
    out_17.extend(asm_17)
    
    with open("/home/zero/project/sango2dasm/asm/banks/prg_17.asm", "w") as f:
        f.write("\n".join(out_17) + "\n")
    print(f"  Written {len(out_17)} lines")
    
    # Emit bank $18
    print("=== Generating prg_18.asm ===")
    out_18 = []
    out_18.append(";===============================================================================")
    out_18.append("; PRG Bank $18 - $C000-$DFFF")
    out_18.append("; Sangokushi 2 - Haou no Tairiku (J)")
    out_18.append("; Namco-163 Mapper 19")
    out_18.append(";")
    out_18.append("; Paired with bank $17 ($A000-$BFFF). Loaded together via SwitchBankAC_A/B.")
    out_18.append("; Y=$37 -> bank $17@$A000, bank $18@$C000")
    out_18.append(";")
    out_18.append("; $C000-$C089: DATA (tile/map tables)")
    out_18.append("; $C08A+: CODE")
    out_18.append(";===============================================================================")
    out_18.append("")
    out_18.append('.include "6502_registers.h"')
    out_18.append('.include "namco163.h"')
    out_18.append('.include "functions.h"')
    out_18.append("")
    out_18.append('.segment "CODE_BANK18"')
    out_18.append("")
    out_18.append(";===============================================================================")
    out_18.append("; Cross-bank references to bank $17 ($A000-$BFFF)")
    out_18.append(";===============================================================================")
    for label in sorted(cross_refs_18.keys()):
        addr = cross_refs_18[label]
        out_18.append(f"{label:<24}= ${addr:04X}")
    out_18.append("")
    out_18.append(";===============================================================================")
    out_18.append("; Data Region ($C000-$C089) - Tile/map lookup table")
    out_18.append(";===============================================================================")
    
    asm_18 = emit_bank(data_18, 0xC000, dis.code_bytes_18, dis.inline_tables_18, dis.labels, all_labels)
    out_18.extend(asm_18)
    
    with open("/home/zero/project/sango2dasm/asm/banks/prg_18.asm", "w") as f:
        f.write("\n".join(out_18) + "\n")
    print(f"  Written {len(out_18)} lines")
    
    print("\nDone!")


if __name__ == "__main__":
    main()
