# Plan: Restructure MenuUpdate Dispatcher ($A153-$A247) in prg_1d_1e.asm

## Context

The range $A153-$A247 in `asm/banks/prg_1d_1e.asm` is a menu rendering dispatcher (`MenuUpdate` proc), but two issues exist in the current disassembly:

1. **Proc boundary error**: The `RTS` at $A153 (`MenuUpdate_Exit`) is placed inside `.proc VRAMBufferWrite` (lines 230-231), but it belongs to `MenuUpdate` as the "RTS-at-head" exit point that `CheckInputAndProcess` branches to via `BEQ`/`BNE`.

2. **Mis-disassembled dispatch table**: The bytes at $A208-$A247 are disassembled as `PHA` + `.byte` directives, but they are actually a 32-entry inline dispatch target table of 16-bit addresses. The `$48` at $A208 is NOT a `PHA` opcode — it is the low byte of the first address ($A248). The `B1F_CallbackDispatcher` at $EADE reads this table via the JSR return address (which is $A207 due to the 6502's `JSR` pushing PC-1), and its `INY` instruction compensates for the -1 offset, making reads start at $A208.

## Files to Modify

- `asm/banks/prg_1d_1e.asm` (primary)

## Changes

### 1. Fix Proc Boundary (lines 228-235)

Move `MenuUpdate_Exit: RTS` ($A153) from VRAMBufferWrite into MenuUpdate.

**Before:**
```asm
@vram_done:
  RTS                                     ; $A152: 60
MenuUpdate_Exit:
  RTS                                     ; $A153: 60

.endproc

.proc MenuUpdate
MenuUpdate:
```

**After:**
```asm
@vram_done:
  RTS                                     ; $A152: 60

.endproc

.proc MenuUpdate
MenuUpdate_Exit:
  RTS                                     ; $A153: 60
MenuUpdate:
```

This places the exit RTS at the head of `MenuUpdate`, which is the intended pattern — `CheckInputAndProcess` branches to `MenuUpdate_Exit` for early exit.

### 2. Convert Data Region to .word Dispatch Table (lines 323-330)

Replace the `PHA` + `.byte` directives at $A208-$A247 with a properly labeled `.word` table. The table has 32 entries (command bytes $80-$9F), each a 16-bit address pointing to a handler within this bank.

**Before (lines 323-330):**
```asm
  JSR B1F_CallbackDispatcher              ; $A205: 20 DE EA
  PHA                                     ; $A208: 48
; --- Data Region: CallbackData_Entry01 ---
  .byte $A2,$81,$A2,$A3,...               ; $A209-$A247
```

**After:**
```asm
  JSR B1F_CallbackDispatcher              ; $A205: 20 DE EA
;-------------------------------------------------------------------------------
; Inline dispatch table (32 entries, 16-bit addresses)
; CallbackDispatcher reads this via JSR return addr ($A207) + INY = $A208
; Index = command_byte - $80 (range $00-$1F, commands $80-$9F)
;-------------------------------------------------------------------------------
MenuDispatchTable:
  .word CmdEndMenu              ; $80: Terminate rendering, shift pos buffer
  .word CmdAdvanceRow           ; $81: Advance VRAM position by one row ($40)
  .word CmdPushPosition         ; $82: Save VRAM pos + data ptr, read new pos
  .word CmdPopPosition          ; $83: Restore saved VRAM pos + data ptr
  .word CmdSetOverlayMode       ; $84: Set overlay_flag = $80
  .word CmdClearOverlayMode     ; $85: Set overlay_flag = $00
  .word CmdSetVramPos           ; $86: Read 2 bytes, set VRAM addr + render flag
  .word CmdEnableIndirect       ; $87: Set indirect_flag = $01
  .word CmdDisableIndirect      ; $88: Set indirect_flag = $00
  .word CmdSetTileOffset        ; $89: Read 1 byte, set tile_base_offset
  .word CmdSetVramPos           ; $8A: (same as $86)
  .word CmdSetVramPos           ; $8B: (same as $86)
  .word CmdSetVramPos           ; $8C: (same as $86)
  .word CmdSetVramPos           ; $8D: (same as $86)
  .word CmdSetVramPos           ; $8E: (same as $86)
  .word CmdSetVramPos           ; $8F: (same as $86)
  .word CmdDrawName             ; $90: Name from $042C table, index = cmd-$90
  .word CmdDrawName             ; $91: (same, index 1)
  .word CmdDrawName             ; $92: (same, index 2)
  .word CmdDrawName             ; $93: (same, index 3)
  .word CmdDrawName             ; $94: (same, index 4)
  .word CmdDrawName             ; $95: (same, index 5)
  .word CmdDrawName             ; $96: (same, index 6)
  .word CmdDrawName             ; $97: (same, index 7)
  .word CmdDrawNumber           ; $98: BCD number, index = cmd-$98
  .word CmdDrawNumber           ; $99: (same, index 1)
  .word CmdDrawNumber           ; $9A: (same, index 2)
  .word CmdDrawNumber           ; $9B: (same, index 3)
  .word CmdDrawNameFromData     ; $9C: Read index from data, 6-char name
  .word CmdDrawNameFixed7       ; $9D: Read index from data, 7-char name
  .word CmdDrawFormattedNumber  ; $9E: Read index, formatted number from $044C
  .word CmdDrawNameFromParam    ; $9F: Read index from data, name lookup
```

### 3. Add Labels to Handler Entry Points

Add a label at the start of each handler code block. These are currently unlabeled code reached only via the dispatch table. Labels to add (all inside `.proc MenuUpdate`):

| Label | Address | Current Line |
|-------|---------|-------------|
| `CmdEndMenu` | $A248 | 331 |
| `CmdAdvanceRow` | $A281 | 354 |
| `CmdPushPosition` | $A2A3 | 368 |
| `CmdPopPosition` | $A2C2 | 379 |
| `CmdSetOverlayMode` | $A2DD | 388 |
| `CmdClearOverlayMode` | $A2E5 | 391 |
| `CmdSetVramPos` | $A2ED | 394 |
| `CmdEnableIndirect` | $A310 | 408 |
| `CmdDisableIndirect` | $A318 | 411 |
| `CmdSetTileOffset` | $A320 | 414 |
| `CmdDrawName` | $A32D | 419 |
| `CmdDrawNameFromParam` | $A397 | 470 |
| `CmdDrawNumber` | $A3B1 | 482 |
| `CmdDrawNameFromData` | $A426 | 541 |
| `CmdDrawNameFixed7` | $A4B0 | 617 |
| `CmdDrawFormattedNumber` | $A53E | 687 |

### 4. Define Symbolic Names for Params ($03xx and Zero-Page)

Add file-level equates (outside any `.proc`) near the top of `prg_1d_1e.asm`, after the `.include` directives and before the first `.proc`. These cover the RAM variables used by the MenuUpdate dispatcher and its handlers.

**$03xx menu/display state variables:**
```asm
menu_status       = $0300  ; $FF=done/inactive, $00=need init, $01=active
overlay_flag      = $0303  ; $00=direct render, $80=overlay mode
tile_col_idx      = $0304  ; current tile column being rendered
render_bitmask    = $0305  ; bitmask checked against $005E for render skip
vram_pos_hi       = $0306  ; VRAM address high byte for current tile row
vram_pos_lo       = $0307  ; VRAM address low byte
input_flag        = $0308  ; input pending flag (set when $0081 bit 0 set)
saved_pos_hi      = $0309  ; saved VRAM pos hi (for push/pop position)
saved_ptr_lo      = $030A  ; saved data ptr lo (for push/pop position)
saved_ptr_hi      = $030B  ; saved data ptr hi (for push/pop position)
indirect_flag     = $030C  ; $00=direct tiles, $01=indirect/overlay tiles
tile_base_offset  = $030F  ; base offset added to tile values in StoreTileByte
pos_buf_0         = $0310  ; VRAM position buffer (4-entry circular)
pos_buf_1         = $0311
pos_buf_2         = $0312
pos_buf_3         = $0313
tile_row1_hi      = $031C  ; tile buffer row 1: VRAM hi/lo/data
tile_row1_lo      = $031D
tile_row1_data    = $031E  ; start of row 1 tile data (indexed by tile_col_idx)
tile_row2_hi      = $034C  ; tile buffer row 2: VRAM hi/lo/data
tile_row2_lo      = $034D
tile_row2_data    = $034E  ; start of row 2 tile data
```

**Zero-page variables:**
```asm
cmd_byte          = $0012  ; current command byte from data stream
data_ptr_lo       = $00A6  ; menu data stream pointer (16-bit)
data_ptr_hi       = $00A7
frame_flags       = $007E  ; bit 0 = render request flag
input_flags       = $0081  ; controller input flags
ppu_ctrl_mirror   = $008B  ; mirror of PPU_CTRL ($2000)
cur_bank_8000     = $00E1  ; current PRG bank mapped at $8000-$9FFF
```

After defining these, update references throughout the MenuUpdate proc to use the symbolic names instead of raw addresses. This is a mechanical find-and-replace within the proc scope (lines 235-862).

## Verification

1. **Binary correctness**: After changes, assemble with `ca65` and verify the output bytes at $A208-$A247 are identical to the original (same 64 bytes, same order). The `.word` directives must produce exactly: `48 A2 81 A2 A3 A2 C2 A2 DD A2 E5 A2 ED A2 10 A3 18 A3 20 A3 ED A2 ED A2 ED A2 ED A2 ED A2 ED A2 2D A3 2D A3 2D A3 2D A3 2D A3 2D A3 2D A3 2D A3 B1 A3 B1 A3 B1 A3 B1 A3 26 A4 B0 A4 3E A5 97 A3`

2. **Proc boundary**: Verify `VRAMBufferWrite` ends at $A152 and `MenuUpdate` starts at $A153 by checking the assembled addresses.

3. **Build**: Run `make` to assemble the full ROM and verify no errors.

4. **Byte-compare**: Use `verify_rom.py` or equivalent tool to confirm the assembled ROM matches the original byte-for-byte.
