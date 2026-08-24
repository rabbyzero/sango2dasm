#!/usr/bin/env python3
"""
Decode MenuAction tile stream data from the PPUTileRender bytecode format.

The display engine (MenuUpdate/PPUTileRender at $A153-$A394 in prg_1d_1e.asm) reads
a bytecode stream from banked PRG ROM. This script:
1. Resolves the pointer table for each pos_buf_0 value
2. Reads the tile stream bytecode
3. Decodes commands and literal tile bytes
4. Outputs a summary of tile indices and name references per handler

PRG bank mapping for Namco-163:
  SwitchBank8_B writes to $E000, bits D4-D0 select the 8KB bank.
  PosDataBankTable values $32/$33 → physical banks $12/$13 (& $1F).
  Each bank is 8KB at offset bank_index * $2000 in prg_combined.bin.
"""

import struct
import os
import sys

ROM_DIR = os.path.join(os.path.dirname(__file__), '..', 'rom')
PRG_COMBINED = os.path.join(ROM_DIR, 'prg_combined.bin')

# Handler → pos_buf_0 parameter (passed to SetupDisplayPtrs)
HANDLERS = {
    0x00: ("MenuAction00_InitialSetup", 0xE8),
    0x01: ("MenuAction01_DisplaySetup", 0xDC),
    0x02: ("MenuAction02_LandReclamation", 0xE1),
    0x03: ("MenuAction03_DisasterPreventionSetup", 0xC6),
    0x04: ("MenuAction04_DisasterPrevention", None),  # shared code with 07
    0x05: ("MenuAction05_UnidentifiedCmdSetup", 0xC6),
    0x06: ("MenuAction06_UnidentifiedCmd", 0xEA),
    0x07: ("MenuAction07_CountryEnd", 0xB7),
    0x08: ("MenuAction08_GoldDistribution", 0xCA),
    0x09: ("MenuAction09_RiceDistribution", 0xF1),
    0x0A: ("MenuAction0A_Conscription", 0xF0),
    0x0B: ("MenuAction0B_HireOfficer", 0xE9),
    0x0C: ("MenuAction0C_TransferOfficer", 0xF8),
    0x0D: ("MenuAction0D_UnidentifiedCmd", 0xF7),
    0x0E: ("MenuAction0E_UnidentifiedCmd", 0xF3),
    0x0F: ("MenuAction0F_GiveItem", 0xF0),
    0x10: ("MenuAction10_SuccessorSelection", 0xD0),
    0x11: ("MenuAction11_Intrigue", 0xF5),
    0x12: ("MenuAction12_Sortie", 0xF8),
    0x13: ("MenuAction13_Reconnaissance", 0xE7),
    0x14: ("MenuAction14_Market", 0xFB),
    0x15: ("MenuAction15_Exchange", 0xEA),
    0x16: ("MenuAction16_Trade", 0xF6),
    0x17: ("MenuAction17_SearchOfficer", 0xF7),
    0x18: ("MenuAction18_SearchItem", 0xC5),
    0x19: ("MenuAction19_UnidentifiedCmd", 0xF4),
    0x1A: ("MenuAction1A_OfficerDeath", 0xC1),
    0x1B: ("MenuAction1B_StrategyCmdDispatch", 0xFC),
}

# PosDataBankTable at $A6A7 (15 entries)
POS_DATA_BANK_TABLE = [
    0x33, 0x33, 0x33,  # pos 0-2
    0x32, 0x32, 0x32, 0x32, 0x32, 0x32,  # pos 3-8
    0x33, 0x33, 0x33, 0x33, 0x33, 0x33,  # pos 9-14
]

# BankPageOffsetTable at $A672: all entries are $8000
BANK_PAGE_OFFSET = 0x8000


def bank_to_file_offset(bank_reg_value, local_addr):
    """Convert a Namco-163 bank register value + local address to file offset."""
    physical_bank = bank_reg_value & 0x1F
    return physical_bank * 0x2000 + (local_addr - 0x8000)


def read_pointer_table(prg_data, pos_value):
    """
    Given a pos_buf_0 value, compute the pointer table address and read
    the 2-byte pointer + bank adjustment.
    
    Returns (stream_ptr_lo, stream_bank_adjust, table_addr)
    """
    # SelectDataBankByPos: if pos >= $20, use $007A; else use 0
    # For all our handlers, pos >= $20, so bank selection depends on $007A
    # We'll try both bank $32 and $33
    
    # CalcMenuDataPtr logic:
    # $0000 = pos * 2
    doubled = (pos_value * 2) & 0xFFFF
    
    # table_offset = BankPageOffsetTable[doubled] = $8000
    table_base = doubled + BANK_PAGE_OFFSET  # = doubled + $8000
    
    # The table_base is an address in banked ROM ($8000-$9FFF window)
    # We need to read from both possible banks
    results = {}
    for bank_val in [0x32, 0x33]:
        file_ofs = bank_to_file_offset(bank_val, table_base)
        if file_ofs + 2 <= len(prg_data):
            ptr_lo = prg_data[file_ofs]
            ptr_hi_raw = prg_data[file_ofs + 1]
            results[bank_val] = (ptr_lo, ptr_hi_raw, table_base)
    
    return results


def decode_stream(prg_data, stream_addr, bank_val, max_bytes=256):
    """
    Decode a PPUTileRender bytecode stream.
    
    Stream format:
    - $00-$7F: literal tile byte (stored with tile_base_offset)
    - $39/$3A: special (indirect offset marker)
    - $80: CmdEndMenu
    - $81: CmdAdvanceRow
    - $82: CmdPushPosition
    - $83: CmdPopPosition
    - $84: CmdSetOverlayMode
    - $85: CmdClearOverlayMode
    - $86,$8A-$8F: CmdSetVramPos (reads 2 bytes)
    - $87: CmdEnableIndirect
    - $88: CmdDisableIndirect
    - $89: CmdSetTileOffset (reads 1 byte)
    - $90-$97: CmdDrawName (index = cmd - $90)
    - $98-$9B: CmdDrawNumber (index = cmd - $98)
    - $9C: CmdDrawNameFromData (reads 1 byte index)
    - $9D: CmdDrawNameFixed7 (reads 1 byte index)
    - $9E: CmdDrawFormattedNumber (reads 1 byte index)
    - $9F: CmdDrawNameFromParam (reads 1 byte index)
    
    Returns list of decoded tokens and the raw bytes.
    """
    file_ofs = bank_to_file_offset(bank_val, stream_addr)
    tokens = []
    raw_bytes = []
    i = 0
    
    while i < max_bytes and file_ofs + i < len(prg_data):
        b = prg_data[file_ofs + i]
        raw_bytes.append(b)
        
        if b <= 0x7F:
            # Literal tile byte
            if b == 0x39 or b == 0x3A:
                tokens.append(f"TILE_SPECIAL_${b:02X}")
            else:
                tokens.append(f"TILE_${b:02X}")
            i += 1
        elif b == 0x80:
            tokens.append("CMD_END_MENU")
            i += 1
            break  # End of stream
        elif b == 0x81:
            tokens.append("CMD_ADVANCE_ROW")
            i += 1
        elif b == 0x82:
            tokens.append("CMD_PUSH_POS")
            i += 1
        elif b == 0x83:
            tokens.append("CMD_POP_POS")
            i += 1
        elif b == 0x84:
            tokens.append("CMD_OVERLAY_ON")
            i += 1
        elif b == 0x85:
            tokens.append("CMD_OVERLAY_OFF")
            i += 1
        elif b == 0x86 or (0x8A <= b <= 0x8F):
            # CmdSetVramPos: read 2 bytes
            if file_ofs + i + 2 < len(prg_data):
                hi = prg_data[file_ofs + i + 1]
                lo = prg_data[file_ofs + i + 2]
                tokens.append(f"CMD_SET_VRAM_${hi:02X}{lo:02X}")
                raw_bytes.extend([hi, lo])
                i += 3
            else:
                tokens.append(f"CMD_SET_VRAM(??)")
                i += 1
        elif b == 0x87:
            tokens.append("CMD_INDIRECT_ON")
            i += 1
        elif b == 0x88:
            tokens.append("CMD_INDIRECT_OFF")
            i += 1
        elif b == 0x89:
            # CmdSetTileOffset: read 1 byte
            if file_ofs + i + 1 < len(prg_data):
                ofs = prg_data[file_ofs + i + 1]
                tokens.append(f"CMD_TILE_OFS_${ofs:02X}")
                raw_bytes.append(ofs)
                i += 2
            else:
                tokens.append("CMD_TILE_OFS(??)")
                i += 1
        elif 0x90 <= b <= 0x97:
            idx = b - 0x90
            tokens.append(f"CMD_DRAW_NAME[{idx}]")
            i += 1
        elif 0x98 <= b <= 0x9B:
            idx = b - 0x98
            tokens.append(f"CMD_DRAW_NUM[{idx}]")
            i += 1
        elif b == 0x9C:
            if file_ofs + i + 1 < len(prg_data):
                idx = prg_data[file_ofs + i + 1]
                tokens.append(f"CMD_DRAW_NAME_DATA[${idx:02X}]")
                raw_bytes.append(idx)
                i += 2
            else:
                tokens.append("CMD_DRAW_NAME_DATA(??)")
                i += 1
        elif b == 0x9D:
            if file_ofs + i + 1 < len(prg_data):
                idx = prg_data[file_ofs + i + 1]
                tokens.append(f"CMD_DRAW_NAME7[${idx:02X}]")
                raw_bytes.append(idx)
                i += 2
            else:
                tokens.append("CMD_DRAW_NAME7(??)")
                i += 1
        elif b == 0x9E:
            if file_ofs + i + 1 < len(prg_data):
                idx = prg_data[file_ofs + i + 1]
                tokens.append(f"CMD_DRAW_FMT_NUM[${idx:02X}]")
                raw_bytes.append(idx)
                i += 2
            else:
                tokens.append("CMD_DRAW_FMT_NUM(??)")
                i += 1
        elif b == 0x9F:
            if file_ofs + i + 1 < len(prg_data):
                idx = prg_data[file_ofs + i + 1]
                tokens.append(f"CMD_DRAW_NAME_PARAM[${idx:02X}]")
                raw_bytes.append(idx)
                i += 2
            else:
                tokens.append("CMD_DRAW_NAME_PARAM(??)")
                i += 1
        else:
            tokens.append(f"UNKNOWN_${b:02X}")
            i += 1
    
    return tokens, raw_bytes


def collect_tile_indices(tokens):
    """Extract literal tile indices from decoded tokens."""
    tiles = []
    for tok in tokens:
        if tok.startswith("TILE_$"):
            val = int(tok.split("$")[1], 16)
            tiles.append(val)
    return tiles


def main():
    with open(PRG_COMBINED, 'rb') as f:
        prg_data = f.read()
    
    print(f"PRG ROM size: {len(prg_data)} bytes ({len(prg_data) // 8192} banks)")
    print(f"=" * 80)
    
    for handler_id in sorted(HANDLERS.keys()):
        name, pos_val = HANDLERS[handler_id]
        if pos_val is None:
            print(f"\n${handler_id:02X}: {name} (no direct stream - shared code)")
            continue
        
        print(f"\n${handler_id:02X}: {name} (pos=${pos_val:02X})")
        
        # Try to find the pointer table for this pos value
        ptr_results = read_pointer_table(prg_data, pos_val)
        
        for bank_val, (ptr_lo, ptr_hi_raw, table_addr) in ptr_results.items():
            physical_bank = bank_val & 0x1F
            print(f"  Bank ${bank_val:02X} (phys ${physical_bank:02X}): "
                  f"table@${table_addr:04X} → ptr ${ptr_hi_raw:02X}{ptr_lo:02X}")
            
            # Try both hi adjustments: +$20 and +$40
            for hi_adj, label in [(0x20, "+$20"), (0x40, "+$40")]:
                stream_hi = (ptr_hi_raw + hi_adj) & 0xFF
                stream_addr = (stream_hi << 8) | ptr_lo
                
                if not (0x8000 <= stream_addr <= 0x9FFF):
                    continue
                
                tokens, raw = decode_stream(prg_data, stream_addr, bank_val, max_bytes=128)
                tiles = collect_tile_indices(tokens)
                
                # Count non-trivial tiles (not $00 or $01)
                meaningful = [t for t in tiles if t > 1]
                
                if meaningful:
                    print(f"    {label}: addr=${stream_addr:04X}, "
                          f"{len(raw)} bytes, {len(tiles)} tiles")
                    tile_str = " ".join(f"${t:02X}" for t in tiles[:32])
                    if len(tiles) > 32:
                        tile_str += "..."
                    print(f"      Tiles: {tile_str}")
                    
                    # Show commands
                    cmds = [t for t in tokens if t.startswith("CMD_")]
                    if cmds:
                        cmd_str = " ".join(cmds[:16])
                        if len(cmds) > 16:
                            cmd_str += "..."
                        print(f"      Cmds:  {cmd_str}")
                    print()


if __name__ == '__main__':
    main()
