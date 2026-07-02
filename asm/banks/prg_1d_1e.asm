;===============================================================================
; PRG Banks $1D+$1E - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $1D at $A000-$BFFF, Bank $1E at $C000-$DFFF
;
; Bank $1D: Jump table ($A000-$A047), code, tile data, menu handlers
; Bank $1E: Domestic affairs dispatch, tile data, SRAM save/load
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

.segment "CODE_BANK1D"

;===============================================================================
; RAM Variable Definitions (file-scope)
;===============================================================================

; $03xx menu/display state variables
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

; Zero-page variables
cmd_byte          = $0012  ; current command byte from data stream
data_ptr_lo       = $00A6  ; menu data stream pointer (16-bit)
data_ptr_hi       = $00A7
frame_flags       = $007E  ; bit 0 = render request flag
input_flags       = $0081  ; controller input flags
ppu_ctrl_mirror   = $008B  ; mirror of PPU_CTRL ($2000)
cur_bank_8000     = $00E1  ; current PRG bank mapped at $8000-$9FFF

;===============================================================================
; Jump Table ($A000-$A047) - 24 entries dispatched by game state
;===============================================================================

Entry00:
  ; PPUTileRender
  JMP PPUTileRender               ; $A000: 4C 48 A0
Entry01:
  ; MenuUpdate
  JMP MenuUpdate                  ; $A003: 4C 54 A1
Entry02:
  ; VRAMBufferWrite
  JMP VRAMBufferWrite             ; $A006: 4C 1B A1
Entry03:
  ; StateHandler
  JMP StateHandler                ; $A009: 4C D2 AB
Entry04:
  ; MapDisplaySetup
  JMP MapDisplaySetup             ; $A00C: 4C 9F B2
Entry05:
  ; OfficerListHandler
  JMP OfficerListHandler          ; $A00F: 4C 89 B9
Entry06:
  ; Unknown
  JMP Unknown                     ; $A012: 4C 41 BC
Entry07:
  ; Entry07 -> $DBB1 (bank $1E)
  JMP $DBB1                               ; $A015: 4C B1 DB
Entry08:
  ; Entry08 -> $DD8B (bank $1E)
  JMP $DD8B                               ; $A018: 4C 8B DD
Entry09:
  ; Entry09 -> $DE7E (bank $1E)
  JMP $DE7E                               ; $A01B: 4C 7E DE
Entry10:
  ; YearDisplaySetup
  JMP YearDisplaySetup          ; $A01E: 4C B6 A6
Entry11:
  ; PeriodicOverlayRefresh
  JMP SlowPeriodic              ; $A021: 4C 7F A7
Entry12:
  ; PeriodicOverlayRefresh
  JMP ImmediateOverlay            ; $A024: 4C B2 A7
Entry13:
  ; ProvinceDataHandler
  JMP ProvinceDataHandler         ; $A027: 4C 30 A8
Entry14:
  ; OfficerLookup
  JMP OfficerLookup               ; $A02A: 4C 90 A8
Entry15:
  ; PeriodicOverlayRefresh
  JMP FastPeriodic              ; $A02D: 4C 8A A7
Entry16:
  ; NameDisplay
  JMP NameDisplay                 ; $A030: 4C A4 A8
Entry17:
  ; RecordProcessor
  JMP RecordProcessor             ; $A033: 4C FD A8
Entry18:
  ; SmallRoutineA
  JMP SmallRoutineA               ; $A036: 4C 66 BC
Entry19:
  ; SmallRoutineB
  JMP SmallRoutineB               ; $A039: 4C 71 BC
Entry20:
  ; DataFormatter
  JMP DataFormatter               ; $A03C: 4C 91 A9
Entry21:
  ; MenuRenderer
  JMP MenuRenderer                ; $A03F: 4C 36 BE
Entry22:
  ; BankedDataHandler
  JMP BankedDataHandler           ; $A042: 4C 37 AA
Entry23:
  ; Entry23 -> $DEB9 (bank $1E)
  JMP $DEB9                               ; $A045: 4C B9 DE

;===============================================================================
; Code Region ($A048-$B304)
;===============================================================================


.proc PPUTileRender
PPUTileRender:
  LDA $007E                               ; $A048: AD 7E 00
  AND #$04                                ; $A04B: 29 04
  BEQ @check_flag2                            ; $A04D: F0 01
  RTS                                     ; $A04F: 60
@check_flag2:
  LDA $0303                               ; $A050: AD 03 03
  BEQ @check_flag3                            ; $A053: F0 03
  JMP @render_row1                            ; $A055: 4C C4 A0
@check_flag3:
  LDA $0308                               ; $A058: AD 08 03
  BEQ @check_mask                            ; $A05B: F0 03
  JMP @render_row1                            ; $A05D: 4C C4 A0
@check_mask:
  LDA $005E                               ; $A060: AD 5E 00
  AND $0305                               ; $A063: 2D 05 03
  BEQ @render_single                            ; $A066: F0 03
  JMP B1F_NmiPaletteUpload                      ; $A068: 4C 72 EE
@render_single:
  LDY $0304                               ; $A06B: AC 04 03
  LDA $034E,Y                             ; $A06E: B9 4E 03
  CMP #$80                                ; $A071: C9 80
  BEQ @reset_tile                            ; $A073: F0 41
  LDA $2002                               ; $A075: AD 02 20
  LDA $031D                               ; $A078: AD 1D 03
  STA $2006                               ; $A07B: 8D 06 20
  LDA $031C                               ; $A07E: AD 1C 03
  CLC                                     ; $A081: 18
  ADC $0304                               ; $A082: 6D 04 03
  STA $2006                               ; $A085: 8D 06 20
  LDY $0304                               ; $A088: AC 04 03
  LDA $031E,Y                             ; $A08B: B9 1E 03
  STA $2007                               ; $A08E: 8D 07 20
  LDA $030C                               ; $A091: AD 0C 03
  BNE @inc_and_exit                            ; $A094: D0 1C
  LDA $2002                               ; $A096: AD 02 20
  LDA $034D                               ; $A099: AD 4D 03
  STA $2006                               ; $A09C: 8D 06 20
  LDA $034C                               ; $A09F: AD 4C 03
  CLC                                     ; $A0A2: 18
  ADC $0304                               ; $A0A3: 6D 04 03
  STA $2006                               ; $A0A6: 8D 06 20
  LDY $0304                               ; $A0A9: AC 04 03
  LDA $034E,Y                             ; $A0AC: B9 4E 03
  STA $2007                               ; $A0AF: 8D 07 20
@inc_and_exit:
  INC $0304                               ; $A0B2: EE 04 03
  RTS                                     ; $A0B5: 60
@reset_tile:
  LDA #$FF                                ; $A0B6: A9 FF
  STA $0304                               ; $A0B8: 8D 04 03
  LDA $007E                               ; $A0BB: AD 7E 00
  AND #$FE                                ; $A0BE: 29 FE
  STA $007E                               ; $A0C0: 8D 7E 00
  RTS                                     ; $A0C3: 60
@render_row1:
  LDA $2002                               ; $A0C4: AD 02 20
  LDA $031D                               ; $A0C7: AD 1D 03
  STA $2006                               ; $A0CA: 8D 06 20
  LDA $031C                               ; $A0CD: AD 1C 03
  STA $2006                               ; $A0D0: 8D 06 20
  LDY #$00                                ; $A0D3: A0 00
@row1_loop:
  LDA $031E,Y                             ; $A0D5: B9 1E 03
  CMP #$80                                ; $A0D8: C9 80
  BEQ @check_row2                            ; $A0DA: F0 07
  STA $2007                               ; $A0DC: 8D 07 20
  INY                                     ; $A0DF: C8
  JMP @row1_loop                            ; $A0E0: 4C D5 A0
@check_row2:
  LDA $030C                               ; $A0E3: AD 0C 03
  BNE @render_done                            ; $A0E6: D0 1F
  LDA $2002                               ; $A0E8: AD 02 20
  LDA $034D                               ; $A0EB: AD 4D 03
  STA $2006                               ; $A0EE: 8D 06 20
  LDA $034C                               ; $A0F1: AD 4C 03
  STA $2006                               ; $A0F4: 8D 06 20
  LDY #$00                                ; $A0F7: A0 00
@row2_loop:
  LDA $034E,Y                             ; $A0F9: B9 4E 03
  CMP #$80                                ; $A0FC: C9 80
  BEQ @render_done                            ; $A0FE: F0 07
  STA $2007                               ; $A100: 8D 07 20
  INY                                     ; $A103: C8
  JMP @row2_loop                            ; $A104: 4C F9 A0
@render_done:
  JMP @reset_tile                            ; $A107: 4C B6 A0
  LDA #$FF                                ; $A10A: A9 FF
  STA $0300                               ; $A10C: 8D 00 03
  STA $0304                               ; $A10F: 8D 04 03
  LDA $007E                               ; $A112: AD 7E 00
  AND #$FE                                ; $A115: 29 FE
  STA $007E                               ; $A117: 8D 7E 00
  RTS                                     ; $A11A: 60

.endproc

.proc VRAMBufferWrite
VRAMBufferWrite:
  LDA $008B                               ; $A11B: AD 8B 00
  AND #$FB                                ; $A11E: 29 FB
  STA $2000                               ; $A120: 8D 00 20
  LDA #$80                                ; $A123: A9 80
  STA $0000                               ; $A125: 8D 00 00
  LDA #$03                                ; $A128: A9 03
  STA $0001                               ; $A12A: 8D 01 00
  LDA $2002                               ; $A12D: AD 02 20
  LDY #$00                                ; $A130: A0 00
@vram_loop:
  LDA ($00),Y                             ; $A132: B1 00
  CMP #$FF                                ; $A134: C9 FF
  BEQ @vram_done                            ; $A136: F0 1A
  INY                                     ; $A138: C8
  TAX                                     ; $A139: AA
  LDA ($00),Y                             ; $A13A: B1 00
  STA $2006                               ; $A13C: 8D 06 20
  INY                                     ; $A13F: C8
  LDA ($00),Y                             ; $A140: B1 00
  STA $2006                               ; $A142: 8D 06 20
  INY                                     ; $A145: C8
@vram_write_loop:
  LDA ($00),Y                             ; $A146: B1 00
  STA $2007                               ; $A148: 8D 07 20
  INY                                     ; $A14B: C8
  DEX                                     ; $A14C: CA
  BNE @vram_write_loop                            ; $A14D: D0 F7
  JMP @vram_loop                            ; $A14F: 4C 32 A1
@vram_done:
  RTS                                     ; $A152: 60

.endproc

.proc MenuUpdate
MenuUpdate_Exit:
  RTS                                     ; $A153: 60
MenuUpdate:
  JSR CheckInputAndProcess                ; $A154: 20 58 A1
  RTS                                     ; $A157: 60
CheckInputAndProcess:
  LDA a:input_flags                       ; $A158: AD 81 00
  AND #$01                                ; $A15B: 29 01
  BEQ @check_cmd                            ; $A15D: F0 05
  LDA #$01                                ; $A15F: A9 01
  STA input_flag                           ; $A161: 8D 08 03
@check_cmd:
  LDA menu_status                         ; $A164: AD 00 03
  CMP #$FF                                ; $A167: C9 FF
  BEQ MenuUpdate_Exit                            ; $A169: F0 E8
  LDA a:frame_flags                       ; $A16B: AD 7E 00
  AND #$01                                ; $A16E: 29 01
  BNE MenuUpdate_Exit                            ; $A170: D0 E1
  LDA #$00                                ; $A172: A9 00
  STA tile_col_idx                         ; $A174: 8D 04 03
  JSR SelectDataBankByPos                      ; $A177: 20 90 A6
  LDA menu_status                         ; $A17A: AD 00 03
  BNE @init_render                            ; $A17D: D0 2D
  JSR CalcMenuDataPtr                     ; $A17F: 20 1D A6
  LDY #$00                                ; $A182: A0 00
  LDA ($A6),Y                             ; $A184: B1 A6
  STA vram_pos_hi                         ; $A186: 8D 06 03
  JSR AdvanceReadPtr                      ; $A189: 20 DF A1
  LDA ($A6),Y                             ; $A18C: B1 A6
  STA vram_pos_lo                         ; $A18E: 8D 07 03
  JSR AdvanceReadPtr                      ; $A191: 20 DF A1
  LDA #$01                                ; $A194: A9 01
  STA menu_status                         ; $A196: 8D 00 03
  LDA #$00                                ; $A199: A9 00
  STA overlay_flag                         ; $A19B: 8D 03 03
  STA input_flag                           ; $A19E: 8D 08 03
  STA indirect_flag                        ; $A1A1: 8D 0C 03
  STA tile_base_offset                     ; $A1A4: 8D 0F 03
  LDA #$03                                ; $A1A7: A9 03
  STA render_bitmask                               ; $A1A9: 8D 05 03
@init_render:
  JSR ClearTileBuffers                    ; $A1AC: 20 0F A6
  LDA vram_pos_hi                         ; $A1AF: AD 06 03
  STA tile_row1_hi                         ; $A1B2: 8D 1C 03
  SEC                                     ; $A1B5: 38
  SBC #$20                                ; $A1B6: E9 20
  STA tile_row2_hi                         ; $A1B8: 8D 4C 03
  LDA vram_pos_lo                         ; $A1BB: AD 07 03
  STA tile_row1_lo                         ; $A1BE: 8D 1D 03
  SBC #$00                                ; $A1C1: E9 00
  STA tile_row2_lo                         ; $A1C3: 8D 4D 03
  LDX #$02                                ; $A1C6: A2 02
dispatch:
  LDY #$00                                ; $A1C8: A0 00
  LDA ($A6),Y                             ; $A1CA: B1 A6
  JSR AdvanceReadPtr                      ; $A1CC: 20 DF A1
  STA a:cmd_byte                          ; $A1CF: 8D 12 00
  TAY                                     ; $A1D2: A8
  BPL @store_tile                            ; $A1D3: 10 04
  CMP #$C0                                ; $A1D5: C9 C0
  BCC dispatch_cmd                             ; $A1D7: 90 29
@store_tile:
  JSR StoreTileByte                       ; $A1D9: 20 E8 A1
  JMP dispatch                             ; $A1DC: 4C C8 A1
AdvanceReadPtr:
  INC a:data_ptr_lo                       ; $A1DF: EE A6 00
  BNE @adv_ptr_done                            ; $A1E2: D0 03
  INC a:data_ptr_hi                       ; $A1E4: EE A7 00
@adv_ptr_done:
  RTS                                     ; $A1E7: 60
StoreTileByte:
  LDY indirect_flag                       ; $A1E8: AC 0C 03
  BNE @store_offset                            ; $A1EB: D0 08
  CMP #$39                                ; $A1ED: C9 39
  BEQ @store_indirect                            ; $A1EF: F0 0D
  CMP #$3A                                ; $A1F1: C9 3A
  BEQ @store_indirect                            ; $A1F3: F0 09
@store_offset:
  CLC                                     ; $A1F5: 18
  ADC tile_base_offset                    ; $A1F6: 6D 0F 03
  STA tile_row1_hi,X                      ; $A1F9: 9D 1C 03
  INX                                     ; $A1FC: E8
  RTS                                     ; $A1FD: 60
@store_indirect:
  STA $034B,X                             ; $A1FE: 9D 4B 03
  RTS                                     ; $A201: 60
dispatch_cmd:
  SEC                                     ; $A202: 38
  SBC #$80                                ; $A203: E9 80
  JSR B1F_CallbackDispatcher              ; $A205: 20 DE EA
;-------------------------------------------------------------------------------
; Inline dispatch table (32 entries, 16-bit addresses)
; CallbackDispatcher reads this via JSR return addr ($A207) + INY = $A208
; Index = command_byte - $80 (range $00-$1F, commands $80-$9F)
;-------------------------------------------------------------------------------
MenuDispatchTable:
  .word CmdEndMenu              ; $A208: 48 A2 | $80: Terminate rendering, shift pos buffer
  .word CmdAdvanceRow           ; $A20A: 81 A2 | $81: Advance VRAM position by one row ($40)
  .word CmdPushPosition         ; $A20C: A3 A2 | $82: Save VRAM pos + data ptr, read new pos
  .word CmdPopPosition          ; $A20E: C2 A2 | $83: Restore saved VRAM pos + data ptr
  .word CmdSetOverlayMode       ; $A210: DD A2 | $84: Set overlay_flag = $80
  .word CmdClearOverlayMode     ; $A212: E5 A2 | $85: Set overlay_flag = $00
  .word CmdSetVramPos           ; $A214: ED A2 | $86: Read 2 bytes, set VRAM addr + render flag
  .word CmdEnableIndirect       ; $A216: 10 A3 | $87: Set indirect_flag = $01
  .word CmdDisableIndirect      ; $A218: 18 A3 | $88: Set indirect_flag = $00
  .word CmdSetTileOffset        ; $A21A: 20 A3 | $89: Read 1 byte, set tile_base_offset
  .word CmdSetVramPos           ; $A21C: ED A2 | $8A: (same as $86)
  .word CmdSetVramPos           ; $A21E: ED A2 | $8B: (same as $86)
  .word CmdSetVramPos           ; $A220: ED A2 | $8C: (same as $86)
  .word CmdSetVramPos           ; $A222: ED A2 | $8D: (same as $86)
  .word CmdSetVramPos           ; $A224: ED A2 | $8E: (same as $86)
  .word CmdSetVramPos           ; $A226: ED A2 | $8F: (same as $86)
  .word CmdDrawName             ; $A228: 2D A3 | $90: Name from $042C table, index = cmd-$90
  .word CmdDrawName             ; $A22A: 2D A3 | $91: (same, index 1)
  .word CmdDrawName             ; $A22C: 2D A3 | $92: (same, index 2)
  .word CmdDrawName             ; $A22E: 2D A3 | $93: (same, index 3)
  .word CmdDrawName             ; $A230: 2D A3 | $94: (same, index 4)
  .word CmdDrawName             ; $A232: 2D A3 | $95: (same, index 5)
  .word CmdDrawName             ; $A234: 2D A3 | $96: (same, index 6)
  .word CmdDrawName             ; $A236: 2D A3 | $97: (same, index 7)
  .word CmdDrawNumber           ; $A238: B1 A3 | $98: BCD number, index = cmd-$98
  .word CmdDrawNumber           ; $A23A: B1 A3 | $99: (same, index 1)
  .word CmdDrawNumber           ; $A23C: B1 A3 | $9A: (same, index 2)
  .word CmdDrawNumber           ; $A23E: B1 A3 | $9B: (same, index 3)
  .word CmdDrawNameFromData     ; $A240: 26 A4 | $9C: Read index from data, 6-char name
  .word CmdDrawNameFixed7       ; $A242: B0 A4 | $9D: Read index from data, 7-char name
  .word CmdDrawFormattedNumber  ; $A244: 3E A5 | $9E: Read index, formatted number from $044C
  .word CmdDrawNameFromParam    ; $A246: 97 A3 | $9F: Read index from data, name lookup
  
CmdEndMenu:
  LDA #$FF                                ; $A248: A9 FF
  STA menu_status                         ; $A24A: 8D 00 03
  LDA #$80                                ; $A24D: A9 80
  STA tile_row1_hi,X                      ; $A24F: 9D 1C 03
  STA tile_row2_hi,X                      ; $A252: 9D 4C 03
  LDA a:frame_flags                       ; $A255: AD 7E 00
  ORA #$01                                ; $A258: 09 01
  STA a:frame_flags                       ; $A25A: 8D 7E 00
  LDA pos_buf_1                           ; $A25D: AD 11 03
  STA pos_buf_0                           ; $A260: 8D 10 03
  LDA pos_buf_2                           ; $A263: AD 12 03
  STA pos_buf_1                           ; $A266: 8D 11 03
  LDA pos_buf_3                           ; $A269: AD 13 03
  STA pos_buf_2                           ; $A26C: 8D 12 03
  LDA #$FF                                ; $A26F: A9 FF
  STA pos_buf_3                           ; $A271: 8D 13 03
  LDA pos_buf_0                           ; $A274: AD 10 03
  CMP #$FF                                ; $A277: C9 FF
  BEQ @clear_exit                            ; $A279: F0 05
  LDA #$00                                ; $A27B: A9 00
  STA menu_status                         ; $A27D: 8D 00 03
@clear_exit:
  RTS                                     ; $A280: 60
CmdAdvanceRow:
  LDA #$80                                ; $A281: A9 80
  STA tile_row1_hi,X                     ; $A283: 9D 1C 03
  STA tile_row2_hi,X                     ; $A286: 9D 4C 03
  LDA vram_pos_hi                        ; $A289: AD 06 03
  CLC                                     ; $A28C: 18
  ADC #$40                                ; $A28D: 69 40
  STA vram_pos_hi                        ; $A28F: 8D 06 03
  LDA vram_pos_lo                        ; $A292: AD 07 03
  ADC #$00                                ; $A295: 69 00
  STA vram_pos_lo                        ; $A297: 8D 07 03
  LDA a:frame_flags                      ; $A29A: AD 7E 00
  ORA #$01                                ; $A29D: 09 01
  STA a:frame_flags                      ; $A29F: 8D 7E 00
  RTS                                     ; $A2A2: 60
CmdPushPosition:
  LDA pos_buf_0                          ; $A2A3: AD 10 03
  STA saved_pos_hi                       ; $A2A6: 8D 09 03
  LDA a:data_ptr_lo                      ; $A2A9: AD A6 00
  STA saved_ptr_lo                       ; $A2AC: 8D 0A 03
  LDA a:data_ptr_hi                      ; $A2AF: AD A7 00
  STA saved_ptr_hi                       ; $A2B2: 8D 0B 03
  LDY #$00                                ; $A2B5: A0 00
  LDA ($A6),Y                             ; $A2B7: B1 A6
  STA pos_buf_0                          ; $A2B9: 8D 10 03
  JSR CalcMenuDataPtr                     ; $A2BC: 20 1D A6
  JMP dispatch                             ; $A2BF: 4C C8 A1
CmdPopPosition:
  LDA saved_pos_hi                       ; $A2C2: AD 09 03
  STA pos_buf_0                          ; $A2C5: 8D 10 03
  JSR CalcMenuDataPtr                     ; $A2C8: 20 1D A6
  LDA saved_ptr_lo                       ; $A2CB: AD 0A 03
  STA a:data_ptr_lo                      ; $A2CE: 8D A6 00
  LDA saved_ptr_hi                       ; $A2D1: AD 0B 03
  STA a:data_ptr_hi                      ; $A2D4: 8D A7 00
  JSR AdvanceReadPtr                      ; $A2D7: 20 DF A1
  JMP dispatch                             ; $A2DA: 4C C8 A1
CmdSetOverlayMode:
  LDA #$80                                ; $A2DD: A9 80
  STA overlay_flag                       ; $A2DF: 8D 03 03
  JMP dispatch                             ; $A2E2: 4C C8 A1
CmdClearOverlayMode:
  LDA #$00                                ; $A2E5: A9 00
  STA overlay_flag                       ; $A2E7: 8D 03 03
  JMP dispatch                             ; $A2EA: 4C C8 A1
CmdSetVramPos:
  LDY #$00                                ; $A2ED: A0 00
  LDA ($A6),Y                             ; $A2EF: B1 A6
  STA vram_pos_hi                        ; $A2F1: 8D 06 03
  JSR AdvanceReadPtr                      ; $A2F4: 20 DF A1
  LDA ($A6),Y                             ; $A2F7: B1 A6
  STA vram_pos_lo                        ; $A2F9: 8D 07 03
  JSR AdvanceReadPtr                      ; $A2FC: 20 DF A1
  LDA #$80                                ; $A2FF: A9 80
  STA tile_row1_hi,X                     ; $A301: 9D 1C 03
  STA tile_row2_hi,X                     ; $A304: 9D 4C 03
  LDA a:frame_flags                      ; $A307: AD 7E 00
  ORA #$01                                ; $A30A: 09 01
  STA a:frame_flags                      ; $A30C: 8D 7E 00
  RTS                                     ; $A30F: 60
CmdEnableIndirect:
  LDA #$01                                ; $A310: A9 01
  STA indirect_flag                      ; $A312: 8D 0C 03
  JMP dispatch                             ; $A315: 4C C8 A1
CmdDisableIndirect:
  LDA #$00                                ; $A318: A9 00
  STA indirect_flag                      ; $A31A: 8D 0C 03
  JMP dispatch                             ; $A31D: 4C C8 A1
CmdSetTileOffset:
  LDY #$00                                ; $A320: A0 00
  LDA ($A6),Y                             ; $A322: B1 A6
  STA tile_base_offset                    ; $A324: 8D 0F 03
  JSR AdvanceReadPtr                      ; $A327: 20 DF A1
  JMP dispatch                             ; $A32A: 4C C8 A1
CmdDrawName:
  LDA a:cur_bank_8000                    ; $A32D: AD E1 00
  PHA                                     ; $A330: 48
  LDY #$30                                ; $A331: A0 30
  JSR B1F_SwitchBank8_B                   ; $A333: 20 5F F2
  LDA #$00                                ; $A336: A9 00
  STA $0001                               ; $A338: 8D 01 00
  LDA a:cmd_byte                         ; $A33B: AD 12 00
  SEC                                     ; $A33E: 38
  SBC #$90                                ; $A33F: E9 90
process_entry:
  TAY                                     ; $A341: A8
  LDA #$00                                ; $A342: A9 00
  STA $0001                               ; $A344: 8D 01 00
  LDA $042C,Y                             ; $A347: B9 2C 04
  ASL A                                   ; $A34A: 0A
  ROL $0001                               ; $A34B: 2E 01 00
  ASL A                                   ; $A34E: 0A
  ROL $0001                               ; $A34F: 2E 01 00
  CLC                                     ; $A352: 18
  ADC $042C,Y                             ; $A353: 79 2C 04
  STA $0000                               ; $A356: 8D 00 00
  LDA $0001                               ; $A359: AD 01 00
  ADC #$00                                ; $A35C: 69 00
  STA $0001                               ; $A35E: 8D 01 00
  ASL $0000                               ; $A361: 0E 00 00
  ROL $0001                               ; $A364: 2E 01 00
  LDA $0000                               ; $A367: AD 00 00
  CLC                                     ; $A36A: 18
  ADC #$1A                                ; $A36B: 69 1A
  STA $0000                               ; $A36D: 8D 00 00
  LDA $0001                               ; $A370: AD 01 00
  ADC #$90                                ; $A373: 69 90
  STA $0001                               ; $A375: 8D 01 00
  LDY #$00                                ; $A378: A0 00
@scan_loop:
  LDA ($00),Y                             ; $A37A: B1 00
  BEQ @scan_done                            ; $A37C: F0 11
  STA $0002                               ; $A37E: 8D 02 00
  TYA                                     ; $A381: 98
  PHA                                     ; $A382: 48
  LDA $0002                               ; $A383: AD 02 00
  JSR StoreTileByte                       ; $A386: 20 E8 A1
  PLA                                     ; $A389: 68
  TAY                                     ; $A38A: A8
  INY                                     ; $A38B: C8
  JMP @scan_loop                            ; $A38C: 4C 7A A3
@scan_done:
  PLA                                     ; $A38F: 68
  TAY                                     ; $A390: A8
  JSR B1F_SwitchBank8_B                   ; $A391: 20 5F F2
  JMP dispatch                             ; $A394: 4C C8 A1
CmdDrawNameFromParam:
  LDA a:cur_bank_8000                    ; $A397: AD E1 00
  PHA                                     ; $A39A: 48
  LDY #$00                                ; $A39B: A0 00
  LDA ($A6),Y                             ; $A39D: B1 A6
  PHA                                     ; $A39F: 48
  JSR AdvanceReadPtr                      ; $A3A0: 20 DF A1
  LDY #$30                                ; $A3A3: A0 30
  JSR B1F_SwitchBank8_B                   ; $A3A5: 20 5F F2
  LDA #$00                                ; $A3A8: A9 00
  STA $0001                               ; $A3AA: 8D 01 00
  PLA                                     ; $A3AD: 68
  JMP process_entry                             ; $A3AE: 4C 41 A3
CmdDrawNumber:
  LDA a:cmd_byte                         ; $A3B1: AD 12 00
  SEC                                     ; $A3B4: 38
  SBC #$98                                ; $A3B5: E9 98
  STA $0000                               ; $A3B7: 8D 00 00
  ASL A                                   ; $A3BA: 0A
  CLC                                     ; $A3BB: 18
  ADC $0000                               ; $A3BC: 6D 00 00
  TAY                                     ; $A3BF: A8
  LDA $042C,Y                             ; $A3C0: B9 2C 04
  STA $0001                               ; $A3C3: 8D 01 00
  LDA $042D,Y                             ; $A3C6: B9 2D 04
  STA $0002                               ; $A3C9: 8D 02 00
  LDA $042E,Y                             ; $A3CC: B9 2E 04
  STA $0003                               ; $A3CF: 8D 03 00
  TXA                                     ; $A3D2: 8A
  PHA                                     ; $A3D3: 48
  JSR B1F_MathBinToBcd                    ; $A3D4: 20 BA E9
  PLA                                     ; $A3D7: 68
  TAX                                     ; $A3D8: AA
  LDA #$00                                ; $A3D9: A9 00
  STA $0000                               ; $A3DB: 8D 00 00
  LDA $0009                               ; $A3DE: AD 09 00
  LSR A                                   ; $A3E1: 4A
  LSR A                                   ; $A3E2: 4A
  LSR A                                   ; $A3E3: 4A
  LSR A                                   ; $A3E4: 4A
  JSR @tile_convert                            ; $A3E5: 20 11 A4
  LDA $0009                               ; $A3E8: AD 09 00
  JSR @tile_convert                            ; $A3EB: 20 11 A4
  LDA $0008                               ; $A3EE: AD 08 00
  LSR A                                   ; $A3F1: 4A
  LSR A                                   ; $A3F2: 4A
  LSR A                                   ; $A3F3: 4A
  LSR A                                   ; $A3F4: 4A
  JSR @tile_convert                            ; $A3F5: 20 11 A4
  LDA $0008                               ; $A3F8: AD 08 00
  JSR @tile_convert                            ; $A3FB: 20 11 A4
  LDA $0007                               ; $A3FE: AD 07 00
  LSR A                                   ; $A401: 4A
  LSR A                                   ; $A402: 4A
  LSR A                                   ; $A403: 4A
  LSR A                                   ; $A404: 4A
  JSR @tile_convert                            ; $A405: 20 11 A4
  LDA $0007                               ; $A408: AD 07 00
  JSR @tile_write                            ; $A40B: 20 1A A4
  JMP dispatch                             ; $A40E: 4C C8 A1
@tile_convert:
  LDY $0000                               ; $A411: AC 00 00
  BNE @tile_write                            ; $A414: D0 04
  AND #$0F                                ; $A416: 29 0F
  BEQ @tile_done                            ; $A418: F0 0B
@tile_write:
  AND #$0F                                ; $A41A: 29 0F
  CLC                                     ; $A41C: 18
  ADC #$76                                ; $A41D: 69 76
  JSR StoreTileByte                       ; $A41F: 20 E8 A1
  INC $0000                               ; $A422: EE 00 00
@tile_done:
  RTS                                     ; $A425: 60
CmdDrawNameFromData:
  LDA a:cur_bank_8000                    ; $A426: AD E1 00
  PHA                                     ; $A429: 48
  LDY #$00                                ; $A42A: A0 00
  LDA ($A6),Y                             ; $A42C: B1 A6
  PHA                                     ; $A42E: 48
  JSR AdvanceReadPtr                      ; $A42F: 20 DF A1
  LDY #$30                                ; $A432: A0 30
  JSR B1F_SwitchBank8_B                   ; $A434: 20 5F F2
  LDA #$00                                ; $A437: A9 00
  STA $0001                               ; $A439: 8D 01 00
  PLA                                     ; $A43C: 68
  TAY                                     ; $A43D: A8
  LDA #$00                                ; $A43E: A9 00
  STA $0001                               ; $A440: 8D 01 00
  LDA $042C,Y                             ; $A443: B9 2C 04
  BPL @process_large                            ; $A446: 10 18
  LDA #$00                                ; $A448: A9 00
@write_zero_loop:
  PHA                                     ; $A44A: 48
  LDA #$01                                ; $A44B: A9 01
  JSR StoreTileByte                       ; $A44D: 20 E8 A1
  PLA                                     ; $A450: 68
  CLC                                     ; $A451: 18
  ADC #$01                                ; $A452: 69 01
  CMP #$06                                ; $A454: C9 06
  BCC @write_zero_loop                            ; $A456: 90 F2
  PLA                                     ; $A458: 68
  TAY                                     ; $A459: A8
  JSR B1F_SwitchBank8_B                   ; $A45A: 20 5F F2
  JMP dispatch                             ; $A45D: 4C C8 A1
@process_large:
  ASL A                                   ; $A460: 0A
  ASL A                                   ; $A461: 0A
  ASL A                                   ; $A462: 0A
  CLC                                     ; $A463: 18
  ADC #$1A                                ; $A464: 69 1A
  STA $0000                               ; $A466: 8D 00 00
  LDA #$00                                ; $A469: A9 00
  ADC #$9A                                ; $A46B: 69 9A
  STA $0001                               ; $A46D: 8D 01 00
  LDY #$00                                ; $A470: A0 00
  STY $0003                               ; $A472: 8C 03 00
@tile_loop:
  LDA ($00),Y                             ; $A475: B1 00
  BNE @tile_store                            ; $A477: D0 02
  LDA #$01                                ; $A479: A9 01
@tile_store:
  STA $0002                               ; $A47B: 8D 02 00
  TYA                                     ; $A47E: 98
  PHA                                     ; $A47F: 48
  LDA $0002                               ; $A480: AD 02 00
  CMP #$39                                ; $A483: C9 39
  BEQ @inc_offset                            ; $A485: F0 04
  CMP #$3A                                ; $A487: C9 3A
  BNE @tile_next                            ; $A489: D0 03
@inc_offset:
  INC $0003                               ; $A48B: EE 03 00
@tile_next:
  JSR StoreTileByte                       ; $A48E: 20 E8 A1
  PLA                                     ; $A491: 68
  TAY                                     ; $A492: A8
  INY                                     ; $A493: C8
  CPY #$06                                ; $A494: C0 06
  BCC @tile_loop                            ; $A496: 90 DD
@pad_loop:
  LDA $0003                               ; $A498: AD 03 00
  BEQ @pad_done                            ; $A49B: F0 0B
  LDA #$01                                ; $A49D: A9 01
  JSR StoreTileByte                       ; $A49F: 20 E8 A1
  DEC $0003                               ; $A4A2: CE 03 00
  JMP @pad_loop                            ; $A4A5: 4C 98 A4
@pad_done:
  PLA                                     ; $A4A8: 68
  TAY                                     ; $A4A9: A8
  JSR B1F_SwitchBank8_B                   ; $A4AA: 20 5F F2
  JMP dispatch                             ; $A4AD: 4C C8 A1
CmdDrawNameFixed7:
  LDA a:cur_bank_8000                    ; $A4B0: AD E1 00
  PHA                                     ; $A4B3: 48
  LDY #$00                                ; $A4B4: A0 00
  LDA ($A6),Y                             ; $A4B6: B1 A6
  PHA                                     ; $A4B8: 48
  JSR AdvanceReadPtr                      ; $A4B9: 20 DF A1
  LDY #$30                                ; $A4BC: A0 30
  JSR B1F_SwitchBank8_B                   ; $A4BE: 20 5F F2
  LDA #$00                                ; $A4C1: A9 00
  STA $0001                               ; $A4C3: 8D 01 00
  PLA                                     ; $A4C6: 68
  TAY                                     ; $A4C7: A8
  LDA #$00                                ; $A4C8: A9 00
  STA $0001                               ; $A4CA: 8D 01 00
  LDA $042C,Y                             ; $A4CD: B9 2C 04
  ASL A                                   ; $A4D0: 0A
  ROL $0001                               ; $A4D1: 2E 01 00
  ASL A                                   ; $A4D4: 0A
  ROL $0001                               ; $A4D5: 2E 01 00
  CLC                                     ; $A4D8: 18
  ADC $042C,Y                             ; $A4D9: 79 2C 04
  STA $0000                               ; $A4DC: 8D 00 00
  LDA $0001                               ; $A4DF: AD 01 00
  ADC #$00                                ; $A4E2: 69 00
  STA $0001                               ; $A4E4: 8D 01 00
  ASL $0000                               ; $A4E7: 0E 00 00
  ROL $0001                               ; $A4EA: 2E 01 00
  LDA $0000                               ; $A4ED: AD 00 00
  CLC                                     ; $A4F0: 18
  ADC #$1A                                ; $A4F1: 69 1A
  STA $0000                               ; $A4F3: 8D 00 00
  LDA $0001                               ; $A4F6: AD 01 00
  ADC #$90                                ; $A4F9: 69 90
  STA $0001                               ; $A4FB: 8D 01 00
  LDY #$00                                ; $A4FE: A0 00
  STY $0003                               ; $A500: 8C 03 00
@tile2_loop:
  LDA ($00),Y                             ; $A503: B1 00
  BNE @tile2_store                            ; $A505: D0 02
  LDA #$01                                ; $A507: A9 01
@tile2_store:
  STA $0002                               ; $A509: 8D 02 00
  TYA                                     ; $A50C: 98
  PHA                                     ; $A50D: 48
  LDA $0002                               ; $A50E: AD 02 00
  CMP #$39                                ; $A511: C9 39
  BEQ @inc2_offset                            ; $A513: F0 04
  CMP #$3A                                ; $A515: C9 3A
  BNE @tile2_next                            ; $A517: D0 03
@inc2_offset:
  INC $0003                               ; $A519: EE 03 00
@tile2_next:
  JSR StoreTileByte                       ; $A51C: 20 E8 A1
  PLA                                     ; $A51F: 68
  TAY                                     ; $A520: A8
  INY                                     ; $A521: C8
  CPY #$07                                ; $A522: C0 07
  BCC @tile2_loop                            ; $A524: 90 DD
@pad2_loop:
  LDA $0003                               ; $A526: AD 03 00
  BEQ @pad2_done                            ; $A529: F0 0B
  LDA #$01                                ; $A52B: A9 01
  JSR StoreTileByte                       ; $A52D: 20 E8 A1
  DEC $0003                               ; $A530: CE 03 00
  JMP @pad2_loop                            ; $A533: 4C 26 A5
@pad2_done:
  PLA                                     ; $A536: 68
  TAY                                     ; $A537: A8
  JSR B1F_SwitchBank8_B                   ; $A538: 20 5F F2
  JMP dispatch                             ; $A53B: 4C C8 A1
CmdDrawFormattedNumber:
  LDA #$00                                ; $A53E: A9 00
  STA $0010                               ; $A540: 8D 10 00
  LDY #$00                                ; $A543: A0 00
  LDA ($A6),Y                             ; $A545: B1 A6
  PHA                                     ; $A547: 48
  JSR AdvanceReadPtr                      ; $A548: 20 DF A1
  PLA                                     ; $A54B: 68
  STA $0000                               ; $A54C: 8D 00 00
  ASL A                                   ; $A54F: 0A
  CLC                                     ; $A550: 18
  ADC $0000                               ; $A551: 6D 00 00
  TAY                                     ; $A554: A8
  LDA $044C,Y                             ; $A555: B9 4C 04
  STA $0001                               ; $A558: 8D 01 00
  LDA $044D,Y                             ; $A55B: B9 4D 04
  STA $0002                               ; $A55E: 8D 02 00
  LDA $044E,Y                             ; $A561: B9 4E 04
  CMP #$FE                                ; $A564: C9 FE
  BNE @check_ff                            ; $A566: D0 15
  LDA #$01                                ; $A568: A9 01
  JSR StoreTileByte                       ; $A56A: 20 E8 A1
  LDA #$6F                                ; $A56D: A9 6F
  JSR StoreTileByte                       ; $A56F: 20 E8 A1
  LDA #$6F                                ; $A572: A9 6F
  JSR StoreTileByte                       ; $A574: 20 E8 A1
  JSR AdvanceReadPtr                      ; $A577: 20 DF A1
  JMP dispatch                             ; $A57A: 4C C8 A1
@check_ff:
  CMP #$FF                                ; $A57D: C9 FF
  BNE @format_num                            ; $A57F: D0 0B
  INC $0010                               ; $A581: EE 10 00
  LDA #$00                                ; $A584: A9 00
  STA $0001                               ; $A586: 8D 01 00
  STA $0002                               ; $A589: 8D 02 00
@format_num:
  STA $0003                               ; $A58C: 8D 03 00
  TXA                                     ; $A58F: 8A
  PHA                                     ; $A590: 48
  JSR B1F_MathBinToBcd                    ; $A591: 20 BA E9
  PLA                                     ; $A594: 68
  TAX                                     ; $A595: AA
  LDY #$00                                ; $A596: A0 00
  LDA ($A6),Y                             ; $A598: B1 A6
  PHA                                     ; $A59A: 48
  JSR AdvanceReadPtr                      ; $A59B: 20 DF A1
  PLA                                     ; $A59E: 68
  TAY                                     ; $A59F: A8
  LDA DigitTileOffsetTable,Y                ; $A5A0: B9 07 A6
  STA $0001                               ; $A5A3: 8D 01 00
  LDA #$00                                ; $A5A6: A9 00
  STA $0000                               ; $A5A8: 8D 00 00
  LDA $0009                               ; $A5AB: AD 09 00
  LSR A                                   ; $A5AE: 4A
  LSR A                                   ; $A5AF: 4A
  LSR A                                   ; $A5B0: 4A
  LSR A                                   ; $A5B1: 4A
  JSR @dec_counter                            ; $A5B2: 20 DE A5
  LDA $0009                               ; $A5B5: AD 09 00
  JSR @dec_counter                            ; $A5B8: 20 DE A5
  LDA $0008                               ; $A5BB: AD 08 00
  LSR A                                   ; $A5BE: 4A
  LSR A                                   ; $A5BF: 4A
  LSR A                                   ; $A5C0: 4A
  LSR A                                   ; $A5C1: 4A
  JSR @dec_counter                            ; $A5C2: 20 DE A5
  LDA $0008                               ; $A5C5: AD 08 00
  JSR @dec_counter                            ; $A5C8: 20 DE A5
  LDA $0007                               ; $A5CB: AD 07 00
  LSR A                                   ; $A5CE: 4A
  LSR A                                   ; $A5CF: 4A
  LSR A                                   ; $A5D0: 4A
  LSR A                                   ; $A5D1: 4A
  JSR @dec_counter                            ; $A5D2: 20 DE A5
  LDA $0007                               ; $A5D5: AD 07 00
  JSR @write_tile_off                            ; $A5D8: 20 F4 A5
  JMP dispatch                             ; $A5DB: 4C C8 A1
@dec_counter:
  DEC $0001                               ; $A5DE: CE 01 00
  LDY $0000                               ; $A5E1: AC 00 00
  BNE @write_tile_off                            ; $A5E4: D0 0E
  AND #$0F                                ; $A5E6: 29 0F
  BNE @write_tile_off                            ; $A5E8: D0 0A
  LDY $0001                               ; $A5EA: AC 01 00
  BPL @dec_return                            ; $A5ED: 10 17
  LDA #$01                                ; $A5EF: A9 01
  JMP StoreTileByte                       ; $A5F1: 4C E8 A1
@write_tile_off:
  AND #$0F                                ; $A5F4: 29 0F
  CLC                                     ; $A5F6: 18
  ADC #$76                                ; $A5F7: 69 76
  LDY $0010                               ; $A5F9: AC 10 00
  BEQ @write_and_inc                            ; $A5FC: F0 02
  LDA #$01                                ; $A5FE: A9 01
@write_and_inc:
  JSR StoreTileByte                       ; $A600: 20 E8 A1
  INC $0000                               ; $A603: EE 00 00
@dec_return:
  RTS                                     ; $A606: 60
; --- Data Region ---
DigitTileOffsetTable:                       ; $A607
  .byte $05,$05,$04,$03,$02,$01,$00,$00   ; $A607: 05 05 04 03 02 01 00 00
ClearTileBuffers:
  LDY #$28                                ; $A60F: A0 28
  LDA #$01                                ; $A611: A9 01
@clear_buf_loop:
  STA tile_row1_hi,Y                     ; $A613: 99 1C 03
  STA tile_row2_hi,Y                     ; $A616: 99 4C 03
  DEY                                     ; $A619: 88
  BNE @clear_buf_loop                            ; $A61A: D0 F7
  RTS                                     ; $A61C: 60
CalcMenuDataPtr:
  LDA pos_buf_0                          ; $A61D: AD 10 03
  STA $0000                               ; $A620: 8D 00 00
  LDA #$00                                ; $A623: A9 00
  STA $0001                               ; $A625: 8D 01 00
  ASL $0000                               ; $A628: 0E 00 00
  ROL $0001                               ; $A62B: 2E 01 00
  JSR SelectDataBankByPos                      ; $A62E: 20 90 A6
  PHA                                     ; $A631: 48
  ASL A                                   ; $A632: 0A
  TAY                                     ; $A633: A8
  LDA $0000                               ; $A634: AD 00 00
  CLC                                     ; $A637: 18
  ADC BankPageOffsetTable,Y                 ; $A638: 79 72 A6
  STA $0000                               ; $A63B: 8D 00 00
  LDA $0001                               ; $A63E: AD 01 00
  ADC BankPageOffsetTable+1,Y               ; $A641: 79 73 A6
  STA $0001                               ; $A644: 8D 01 00
  PLA                                     ; $A647: 68
  CMP #$09                                ; $A648: C9 09
  BCS @load_ptr_lo                            ; $A64A: B0 04
  CMP #$03                                ; $A64C: C9 03
  BCS @load_ptr_hi                            ; $A64E: B0 11
@load_ptr_lo:
  LDY #$00                                ; $A650: A0 00
  LDA ($00),Y                             ; $A652: B1 00
  STA a:data_ptr_lo                      ; $A654: 8D A6 00
  INY                                     ; $A657: C8
  LDA ($00),Y                             ; $A658: B1 00
  CLC                                     ; $A65A: 18
  ADC #$20                                ; $A65B: 69 20
  STA a:data_ptr_hi                      ; $A65D: 8D A7 00
  RTS                                     ; $A660: 60
@load_ptr_hi:
  LDY #$00                                ; $A661: A0 00
  LDA ($00),Y                             ; $A663: B1 00
  STA a:data_ptr_lo                      ; $A665: 8D A6 00
  INY                                     ; $A668: C8
  LDA ($00),Y                             ; $A669: B1 00
  CLC                                     ; $A66B: 18
  ADC #$40                                ; $A66C: 69 40
  STA a:data_ptr_hi                      ; $A66E: 8D A7 00
  RTS                                     ; $A671: 60
; --- Data Region ---
BankPageOffsetTable:                        ; $A672
  .word $8000,$8000,$8000,$8000,$8000,$8000,$8000,$8000; $A672: 00 80 00 80 00 80 00 80 00 80 00 80 00 80 00 80
  .word $8000,$8000,$8000,$8000,$8000,$8000,$8000; $A682: 00 80 00 80 00 80 00 80 00 80 00 80 00 80
SelectDataBankByPos:
  LDA #$00                                ; $A690: A9 00
  LDY pos_buf_0                          ; $A692: AC 10 03
  CPY #$20                                ; $A695: C0 20
  BCC @switch_bank                            ; $A697: 90 03
  LDA $007A                               ; $A699: AD 7A 00
@switch_bank:
  PHA                                     ; $A69C: 48
  TAY                                     ; $A69D: A8
  LDA PosDataBankTable,Y                    ; $A69E: B9 A7 A6
  TAY                                     ; $A6A1: A8
  JSR B1F_SwitchBank8_B                   ; $A6A2: 20 5F F2
  PLA                                     ; $A6A5: 68
  RTS                                     ; $A6A6: 60
; --- Data Region: PosDataBankTable ---
PosDataBankTable:
  .byte $33,$33,$33,$32,$32,$32,$32,$32,$32,$33,$33,$33,$33,$33,$33; $A6A7: 33 33 33 32 32 32 32 32 32 33 33 33 33 33 33

.endproc

.proc YearDisplaySetup
YearDisplaySetup:
  LDA $6F00                               ; $A6B6: AD 00 6F
  CLC                                     ; $A6B9: 18
  ADC #$64                                ; $A6BA: 69 64
  STA $0001                               ; $A6BC: 8D 01 00
  LDA #$00                                ; $A6BF: A9 00
  ADC #$00                                ; $A6C1: 69 00
  STA $0002                               ; $A6C3: 8D 02 00
  LDA #$00                                ; $A6C6: A9 00
  STA $0003                               ; $A6C8: 8D 03 00
  JSR B1F_MathBinToBcd                    ; $A6CB: 20 BA E9
  LDA $0008                               ; $A6CE: AD 08 00
  AND #$0F                                ; $A6D1: 29 0F
  CLC                                     ; $A6D3: 18
  ADC #$04                                ; $A6D4: 69 04
  STA $0383                               ; $A6D6: 8D 83 03
  CLC                                     ; $A6D9: 18
  ADC #$10                                ; $A6DA: 69 10
  STA $038D                               ; $A6DC: 8D 8D 03
  LDA $0007                               ; $A6DF: AD 07 00
  LSR A                                   ; $A6E2: 4A
  LSR A                                   ; $A6E3: 4A
  LSR A                                   ; $A6E4: 4A
  LSR A                                   ; $A6E5: 4A
  CLC                                     ; $A6E6: 18
  ADC #$04                                ; $A6E7: 69 04
  STA $0384                               ; $A6E9: 8D 84 03
  CLC                                     ; $A6EC: 18
  ADC #$10                                ; $A6ED: 69 10
  STA $038E                               ; $A6EF: 8D 8E 03
  LDA $0007                               ; $A6F2: AD 07 00
  AND #$0F                                ; $A6F5: 29 0F
  CLC                                     ; $A6F7: 18
  ADC #$04                                ; $A6F8: 69 04
  STA $0385                               ; $A6FA: 8D 85 03
  CLC                                     ; $A6FD: 18
  ADC #$10                                ; $A6FE: 69 10
  STA $038F                               ; $A700: 8D 8F 03
  LDA $6F01                               ; $A703: AD 01 6F
  CLC                                     ; $A706: 18
  ADC #$01                                ; $A707: 69 01
  STA $0001                               ; $A709: 8D 01 00
  LDA #$00                                ; $A70C: A9 00
  STA $0002                               ; $A70E: 8D 02 00
  STA $0003                               ; $A711: 8D 03 00
  JSR B1F_MathBinToBcd                    ; $A714: 20 BA E9
  LDA $0007                               ; $A717: AD 07 00
  LSR A                                   ; $A71A: 4A
  LSR A                                   ; $A71B: 4A
  LSR A                                   ; $A71C: 4A
  LSR A                                   ; $A71D: 4A
  BNE @calc_offset                            ; $A71E: D0 02
  LDA #$0E                                ; $A720: A9 0E
@calc_offset:
  CLC                                     ; $A722: 18
  ADC #$04                                ; $A723: 69 04
  STA $0388                               ; $A725: 8D 88 03
  CLC                                     ; $A728: 18
  ADC #$10                                ; $A729: 69 10
  STA $0392                               ; $A72B: 8D 92 03
  LDA $0007                               ; $A72E: AD 07 00
  AND #$0F                                ; $A731: 29 0F
  CLC                                     ; $A733: 18
  ADC #$04                                ; $A734: 69 04
  STA $0389                               ; $A736: 8D 89 03
  CLC                                     ; $A739: 18
  ADC #$10                                ; $A73A: 69 10
  STA $0393                               ; $A73C: 8D 93 03
  LDA #$07                                ; $A73F: A9 07
  STA $0380                               ; $A741: 8D 80 03
  LDA #$20                                ; $A744: A9 20
  STA $0381                               ; $A746: 8D 81 03
  LDA #$43                                ; $A749: A9 43
  STA $0382                               ; $A74B: 8D 82 03
  LDA #$07                                ; $A74E: A9 07
  STA $038A                               ; $A750: 8D 8A 03
  LDA #$20                                ; $A753: A9 20
  STA $038B                               ; $A755: 8D 8B 03
  LDA #$63                                ; $A758: A9 63
  STA $038C                               ; $A75A: 8D 8C 03
  LDA #$12                                ; $A75D: A9 12
  STA $0387                               ; $A75F: 8D 87 03
  LDA #$22                                ; $A762: A9 22
  STA $0391                               ; $A764: 8D 91 03
  LDA #$0E                                ; $A767: A9 0E
  STA $0386                               ; $A769: 8D 86 03
  LDA #$1E                                ; $A76C: A9 1E
  STA $0390                               ; $A76E: 8D 90 03
  LDA #$FF                                ; $A771: A9 FF
  STA $0394                               ; $A773: 8D 94 03
  LDA $007E                               ; $A776: AD 7E 00
  ORA #$04                                ; $A779: 09 04
  STA $007E                               ; $A77B: 8D 7E 00
  RTS                                     ; $A77E: 60

.endproc

.proc PeriodicOverlayRefresh
; Entry: fires every 16th tick (tick ≡ 11 mod 16), delegates to BCD overlay
::SlowPeriodic:
  LDA $005E                               ; $A77F: AD 5E 00
  CLC                                     ; $A782: 18
  ADC #$05                                ; $A783: 69 05
  AND #$0F                                ; $A785: 29 0F
  BEQ ImmediateOverlay            ; $A787: F0 29
  RTS                                     ; $A789: 60

; Entry: every 4th tick copies template; every 8th tick also overlays BCD digits
::FastPeriodic:
  LDA $005E                               ; $A78A: AD 5E 00
  CLC                                     ; $A78D: 18
  ADC #$01                                ; $A78E: 69 01
  AND #$03                                ; $A790: 29 03
  BNE @frame_exit                            ; $A792: D0 1D
  LDA $005E                               ; $A794: AD 5E 00
  CLC                                     ; $A797: 18
  ADC #$01                                ; $A798: 69 01
  AND #$04                                ; $A79A: 29 04
  BNE ImmediateOverlay            ; $A79C: D0 14
  LDY #$3A                                ; $A79E: A0 3A
@copy_table_loop:
  LDA OverlayTemplate,Y                   ; $A7A0: B9 F6 A7
  STA $0380,Y                             ; $A7A3: 99 80 03
  DEY                                     ; $A7A6: 88
  BPL @copy_table_loop                            ; $A7A7: 10 F7
  LDA $007E                               ; $A7A9: AD 7E 00
  ORA #$04                                ; $A7AC: 09 04
  STA $007E                               ; $A7AE: 8D 7E 00
@frame_exit:
  RTS                                     ; $A7B1: 60

; Entry: always converts $6F05 to BCD, copies template, overlays digits
::ImmediateOverlay:
  LDA #$00                                ; $A7B2: A9 00
  STA $0002                               ; $A7B4: 8D 02 00
  LDA $6F05                               ; $A7B7: AD 05 6F
  STA $0001                               ; $A7BA: 8D 01 00
  LDA #$00                                ; $A7BD: A9 00
  STA $0002                               ; $A7BF: 8D 02 00
  STA $0003                               ; $A7C2: 8D 03 00
  JSR B1F_MathBinToBcd                    ; $A7C5: 20 BA E9
  LDY #$3A                                ; $A7C8: A0 3A
@bcd_copy_loop:
  LDA OverlayTemplate,Y                   ; $A7CA: B9 F6 A7
  STA $0380,Y                             ; $A7CD: 99 80 03
  DEY                                     ; $A7D0: 88
  BPL @bcd_copy_loop                            ; $A7D1: 10 F7
  LDA $0007                               ; $A7D3: AD 07 00
  LSR A                                   ; $A7D6: 4A
  LSR A                                   ; $A7D7: 4A
  LSR A                                   ; $A7D8: 4A
  LSR A                                   ; $A7D9: 4A
  BEQ @bcd_low_digit                            ; $A7DA: F0 06
  CLC                                     ; $A7DC: 18
  ADC #$76                                ; $A7DD: 69 76
  STA $03AA                               ; $A7DF: 8D AA 03
@bcd_low_digit:
  LDA $0007                               ; $A7E2: AD 07 00
  AND #$0F                                ; $A7E5: 29 0F
  CLC                                     ; $A7E7: 18
  ADC #$76                                ; $A7E8: 69 76
  STA $03AB                               ; $A7EA: 8D AB 03
  LDA $007E                               ; $A7ED: AD 7E 00
  ORA #$04                                ; $A7F0: 09 04
  STA $007E                               ; $A7F2: 8D 7E 00
  RTS                                     ; $A7F5: 60
; Overlay template - 59 bytes copied to display buffer $0380-$03BA
OverlayTemplate:
  .byte $04, $22, $01, $01, $01, $04, $01, $01  ; $A7F6
  .byte $22, $C2, $01, $01, $04, $22, $E2, $01  ; $A7FE
  .byte $01, $04, $23, $02, $01, $01, $04, $23  ; $A806
  .byte $22, $01, $01, $08, $23, $01, $01, $01  ; $A80E
  .byte $A7, $01, $01, $A8, $01, $01, $01, $23  ; $A816
  .byte $01, $01, $A8, $01, $01, $23, $01, $01  ; $A81E
  .byte $A8, $01, $01, $A8, $01, $01, $23, $FF  ; $A826

.endproc

.proc ProvinceDataHandler
ProvinceDataHandler:
  LDY #$3A                                ; $A830: A0 3A
@prov_copy_loop:
  LDA $A856,Y                             ; $A832: B9 56 A8
  STA $0380,Y                             ; $A835: 99 80 03
  DEY                                     ; $A838: 88
  BPL @prov_copy_loop                            ; $A839: 10 F7
  LDY $0509                               ; $A83B: AC 09 05
  LDA $0664,Y                             ; $A83E: B9 64 06
  JSR DisplayScaledName                            ; $A841: 20 57 A9
  LDY $0509                               ; $A844: AC 09 05
  LDA $0664,Y                             ; $A847: B9 64 06
  JSR DisplayScaledNumber                            ; $A84A: 20 76 A9
  LDA $007E                               ; $A84D: AD 7E 00
  ORA #$04                                ; $A850: 09 04
  STA $007E                               ; $A852: 8D 7E 00
  RTS                                     ; $A855: 60
  .byte $04                               ; $A856: 04
  BIT $22                                 ; $A857: 24 22
  BRK                                     ; $A859: 00
  BRK                                     ; $A85A: 00
  BRK                                     ; $A85B: 00
  BRK                                     ; $A85C: 00
  .byte $04                               ; $A85D: 04
  BIT $42                                 ; $A85E: 24 42
  BRK                                     ; $A860: 00
  BRK                                     ; $A861: 00
  BRK                                     ; $A862: 00
  BRK                                     ; $A863: 00
  .byte $04                               ; $A864: 04
  BIT $62                                 ; $A865: 24 62
  BRK                                     ; $A867: 00
  BRK                                     ; $A868: 00
  BRK                                     ; $A869: 00
  BRK                                     ; $A86A: 00
  .byte $04                               ; $A86B: 04
  BIT $82                                 ; $A86C: 24 82
  BRK                                     ; $A86E: 00
  BRK                                     ; $A86F: 00
  BRK                                     ; $A870: 00
  BRK                                     ; $A871: 00
  .byte $04                               ; $A872: 04
  BIT $A2                                 ; $A873: 24 A2
  BRK                                     ; $A875: 00
  BRK                                     ; $A876: 00
  BRK                                     ; $A877: 00
  BRK                                     ; $A878: 00
  PHP                                     ; $A879: 08
  BIT $C0                                 ; $A87A: 24 C0
  ORA ($01,X)                             ; $A87C: 01 01
  ORA ($01,X)                             ; $A87E: 01 01
  ORA ($01,X)                             ; $A880: 01 01
  ORA ($01,X)                             ; $A882: 01 01
  PHP                                     ; $A884: 08
  BIT $E0                                 ; $A885: 24 E0
  ORA ($01,X)                             ; $A887: 01 01
  ORA ($01,X)                             ; $A889: 01 01
  ORA ($01,X)                             ; $A88B: 01 01
  ORA ($01,X)                             ; $A88D: 01 01
  .byte $FF                               ; $A88F: FF

.endproc

.proc OfficerLookup
OfficerLookup:
  LDA $0000                               ; $A890: AD 00 00
  PHA                                     ; $A893: 48
  LDA #$00                                ; $A894: A9 00
  STA $0000                               ; $A896: 8D 00 00
  LDY #$3D                                ; $A899: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $A89B: 20 07 EE
  ORA $A0,X                               ; $A89E: 15 A0
  PLA                                     ; $A8A0: 68
  STA $0000                               ; $A8A1: 8D 00 00

.endproc

.proc NameDisplay
NameDisplay:
  LDY #$3A                                ; $A8A4: A0 3A
@name_copy_loop:
  LDA $A8C3,Y                             ; $A8A6: B9 C3 A8
  STA $0380,Y                             ; $A8A9: 99 80 03
  DEY                                     ; $A8AC: 88
  BPL @name_copy_loop                            ; $A8AD: 10 F7
  LDA $0000                               ; $A8AF: AD 00 00
  PHA                                     ; $A8B2: 48
  JSR DisplayScaledName                            ; $A8B3: 20 57 A9
  PLA                                     ; $A8B6: 68
  JSR DisplayScaledNumber                            ; $A8B7: 20 76 A9
  LDA $007E                               ; $A8BA: AD 7E 00
  ORA #$04                                ; $A8BD: 09 04
  STA $007E                               ; $A8BF: 8D 7E 00
  RTS                                     ; $A8C2: 60
  .byte $04                               ; $A8C3: 04
  .byte $22                               ; $A8C4: 22
  LDX #$00                                ; $A8C5: A2 00
  BRK                                     ; $A8C7: 00
  BRK                                     ; $A8C8: 00
  BRK                                     ; $A8C9: 00
  .byte $04                               ; $A8CA: 04
  .byte $22                               ; $A8CB: 22
  .byte $C2                               ; $A8CC: C2
  BRK                                     ; $A8CD: 00
  BRK                                     ; $A8CE: 00
  BRK                                     ; $A8CF: 00
  BRK                                     ; $A8D0: 00
  .byte $04                               ; $A8D1: 04
  .byte $22                               ; $A8D2: 22
  .byte $E2                               ; $A8D3: E2
  BRK                                     ; $A8D4: 00
  BRK                                     ; $A8D5: 00
  BRK                                     ; $A8D6: 00
  BRK                                     ; $A8D7: 00
  .byte $04                               ; $A8D8: 04
  .byte $23                               ; $A8D9: 23
  .byte $02                               ; $A8DA: 02
  BRK                                     ; $A8DB: 00
  BRK                                     ; $A8DC: 00
  BRK                                     ; $A8DD: 00
  BRK                                     ; $A8DE: 00
  .byte $04                               ; $A8DF: 04
  .byte $23                               ; $A8E0: 23
  .byte $22                               ; $A8E1: 22
  BRK                                     ; $A8E2: 00
  BRK                                     ; $A8E3: 00
  BRK                                     ; $A8E4: 00
  BRK                                     ; $A8E5: 00
  PHP                                     ; $A8E6: 08
  .byte $23                               ; $A8E7: 23
  RTI                                     ; $A8E8: 40
  ORA ($01,X)                             ; $A8E9: 01 01
  ORA ($01,X)                             ; $A8EB: 01 01
  ORA ($01,X)                             ; $A8ED: 01 01
  ORA ($01,X)                             ; $A8EF: 01 01
  PHP                                     ; $A8F1: 08
  .byte $23                               ; $A8F2: 23
  RTS                                     ; $A8F3: 60
  ORA ($01,X)                             ; $A8F4: 01 01
  ORA ($01,X)                             ; $A8F6: 01 01
  ORA ($01,X)                             ; $A8F8: 01 01
  ORA ($01,X)                             ; $A8FA: 01 01
  .byte $FF                               ; $A8FC: FF

.endproc

.proc RecordProcessor
RecordProcessor:
  LDY #$3A                                ; $A8FD: A0 3A
@rec_copy_loop:
  LDA $A91D,Y                             ; $A8FF: B9 1D A9
  STA $0380,Y                             ; $A902: 99 80 03
  DEY                                     ; $A905: 88
  BPL @rec_copy_loop                            ; $A906: 10 F7
  LDA $04AE                               ; $A908: AD AE 04
  JSR DisplayScaledName                            ; $A90B: 20 57 A9
  LDA $04AE                               ; $A90E: AD AE 04
  JSR DisplayScaledNumber                            ; $A911: 20 76 A9
  LDA $007E                               ; $A914: AD 7E 00
  ORA #$04                                ; $A917: 09 04
  STA $007E                               ; $A919: 8D 7E 00
  RTS                                     ; $A91C: 60
  .byte $04                               ; $A91D: 04
  .byte $22                               ; $A91E: 22
  LDA $0000,Y                             ; $A91F: B9 00 00
  BRK                                     ; $A922: 00
  BRK                                     ; $A923: 00
  .byte $04                               ; $A924: 04
  .byte $22                               ; $A925: 22
  CMP $0000,Y                             ; $A926: D9 00 00
  BRK                                     ; $A929: 00
  BRK                                     ; $A92A: 00
  .byte $04                               ; $A92B: 04
  .byte $22                               ; $A92C: 22
  SBC $0000,Y                             ; $A92D: F9 00 00
  BRK                                     ; $A930: 00
  BRK                                     ; $A931: 00
  .byte $04                               ; $A932: 04
  .byte $23                               ; $A933: 23
  ORA $0000,Y                             ; $A934: 19 00 00
  BRK                                     ; $A937: 00
  BRK                                     ; $A938: 00
  .byte $04                               ; $A939: 04
  .byte $23                               ; $A93A: 23
  AND $0000,Y                             ; $A93B: 39 00 00
  BRK                                     ; $A93E: 00
  BRK                                     ; $A93F: 00
  PHP                                     ; $A940: 08
  .byte $23                               ; $A941: 23
  .byte $57                               ; $A942: 57
  ORA ($01,X)                             ; $A943: 01 01
  ORA ($01,X)                             ; $A945: 01 01
  ORA ($01,X)                             ; $A947: 01 01
  ORA ($01,X)                             ; $A949: 01 01
  PHP                                     ; $A94B: 08
  .byte $23                               ; $A94C: 23
  .byte $77                               ; $A94D: 77
  ORA ($01,X)                             ; $A94E: 01 01
  ORA ($01,X)                             ; $A950: 01 01
  ORA ($01,X)                             ; $A952: 01 01
  ORA ($01,X)                             ; $A954: 01 01
  .byte $FF                               ; $A956: FF
DisplayScaledName:
  JSR B1F_GetNameDisplayScale             ; $A957: 20 08 F3
  TAX                                     ; $A95A: AA
  LDY #$00                                ; $A95B: A0 00
@name_scan_loop:
  LDA ($00),Y                             ; $A95D: B1 00
  BEQ @name_scan_done                            ; $A95F: F0 0D
  CMP #$39                                ; $A961: C9 39
  BEQ FormatNumberPair                    ; $A963: F0 0A
  CMP #$3A                                ; $A965: C9 3A
  BEQ FormatNumberPair                    ; $A967: F0 06
  INY                                     ; $A969: C8
  INX                                     ; $A96A: E8
  JMP @name_scan_loop                            ; $A96B: 4C 5D A9
@name_scan_done:
  RTS                                     ; $A96E: 60
FormatNumberPair:
  STA $03A5,X                             ; $A96F: 9D A5 03
  INY                                     ; $A972: C8
  JMP @name_scan_loop                            ; $A973: 4C 5D A9
DisplayScaledNumber:
  JSR B1F_GetNameDisplayScale             ; $A976: 20 08 F3
  TAX                                     ; $A979: AA
  LDY #$00                                ; $A97A: A0 00
@num_scan_loop:
  LDA ($00),Y                             ; $A97C: B1 00
  BEQ @num_scan_done                            ; $A97E: F0 10
  CMP #$39                                ; $A980: C9 39
  BEQ @num_scan_next                            ; $A982: F0 08
  CMP #$3A                                ; $A984: C9 3A
  BEQ @num_scan_next                            ; $A986: F0 04
  STA $03B1,X                             ; $A988: 9D B1 03
  INX                                     ; $A98B: E8
@num_scan_next:
  INY                                     ; $A98C: C8
  JMP @num_scan_loop                            ; $A98D: 4C 7C A9
@num_scan_done:
  RTS                                     ; $A990: 60

.endproc

.proc DataFormatter
DataFormatter:
  LDA $0001                               ; $A991: AD 01 00
  BNE @fmt_setup2                            ; $A994: D0 0E
  LDY #$3A                                ; $A996: A0 3A
@fmt_copy_loop1:
  LDA $A9FD,Y                             ; $A998: B9 FD A9
  STA $0380,Y                             ; $A99B: 99 80 03
  DEY                                     ; $A99E: 88
  BPL @fmt_copy_loop1                            ; $A99F: 10 F7
  JMP @fmt_process                            ; $A9A1: 4C AF A9
@fmt_setup2:
  LDY #$3A                                ; $A9A4: A0 3A
@fmt_copy_loop2:
  LDA $A9C3,Y                             ; $A9A6: B9 C3 A9
  STA $0380,Y                             ; $A9A9: 99 80 03
  DEY                                     ; $A9AC: 88
  BPL @fmt_copy_loop2                            ; $A9AD: 10 F7
@fmt_process:
  LDA $0000                               ; $A9AF: AD 00 00
  PHA                                     ; $A9B2: 48
  JSR DisplayScaledName                            ; $A9B3: 20 57 A9
  PLA                                     ; $A9B6: 68
  JSR DisplayScaledNumber                            ; $A9B7: 20 76 A9
  LDA $007E                               ; $A9BA: AD 7E 00
  ORA #$04                                ; $A9BD: 09 04
  STA $007E                               ; $A9BF: 8D 7E 00
  RTS                                     ; $A9C2: 60
ProcessItemEntry:
  .byte $04                               ; $A9C3: 04
  .byte $22                               ; $A9C4: 22
  TSX                                     ; $A9C5: BA
  BRK                                     ; $A9C6: 00
  BRK                                     ; $A9C7: 00
  BRK                                     ; $A9C8: 00
  BRK                                     ; $A9C9: 00
  .byte $04                               ; $A9CA: 04
  .byte $22                               ; $A9CB: 22
  .byte $DA                               ; $A9CC: DA
  BRK                                     ; $A9CD: 00
  BRK                                     ; $A9CE: 00
  BRK                                     ; $A9CF: 00
  BRK                                     ; $A9D0: 00
  .byte $04                               ; $A9D1: 04
  .byte $22                               ; $A9D2: 22
  .byte $FA                               ; $A9D3: FA
  BRK                                     ; $A9D4: 00
  BRK                                     ; $A9D5: 00
  BRK                                     ; $A9D6: 00
  BRK                                     ; $A9D7: 00
  .byte $04                               ; $A9D8: 04
  .byte $23                               ; $A9D9: 23
  .byte $1A                               ; $A9DA: 1A
  BRK                                     ; $A9DB: 00
  BRK                                     ; $A9DC: 00
  BRK                                     ; $A9DD: 00
  BRK                                     ; $A9DE: 00
  .byte $04                               ; $A9DF: 04
  .byte $23                               ; $A9E0: 23
  .byte $3A                               ; $A9E1: 3A
  BRK                                     ; $A9E2: 00
  BRK                                     ; $A9E3: 00
  BRK                                     ; $A9E4: 00
  BRK                                     ; $A9E5: 00
  PHP                                     ; $A9E6: 08
  .byte $23                               ; $A9E7: 23
  CLI                                     ; $A9E8: 58
  ORA ($01,X)                             ; $A9E9: 01 01
  ORA ($01,X)                             ; $A9EB: 01 01
  ORA ($01,X)                             ; $A9ED: 01 01
  ORA ($01,X)                             ; $A9EF: 01 01
  PHP                                     ; $A9F1: 08
  .byte $23                               ; $A9F2: 23
  SEI                                     ; $A9F3: 78
  ORA ($01,X)                             ; $A9F4: 01 01
  ORA ($01,X)                             ; $A9F6: 01 01
  ORA ($01,X)                             ; $A9F8: 01 01
  ORA ($01,X)                             ; $A9FA: 01 01
  .byte $FF                               ; $A9FC: FF
  .byte $04                               ; $A9FD: 04
  .byte $22                               ; $A9FE: 22
  LDX #$00                                ; $A9FF: A2 00
  BRK                                     ; $AA01: 00
  BRK                                     ; $AA02: 00
  BRK                                     ; $AA03: 00
  .byte $04                               ; $AA04: 04
  .byte $22                               ; $AA05: 22
  .byte $C2                               ; $AA06: C2
  BRK                                     ; $AA07: 00
  BRK                                     ; $AA08: 00
  BRK                                     ; $AA09: 00
  BRK                                     ; $AA0A: 00
  .byte $04                               ; $AA0B: 04
  .byte $22                               ; $AA0C: 22
  .byte $E2                               ; $AA0D: E2
  BRK                                     ; $AA0E: 00
  BRK                                     ; $AA0F: 00
  BRK                                     ; $AA10: 00
  BRK                                     ; $AA11: 00
  .byte $04                               ; $AA12: 04
  .byte $23                               ; $AA13: 23
  .byte $02                               ; $AA14: 02
  BRK                                     ; $AA15: 00
  BRK                                     ; $AA16: 00
  BRK                                     ; $AA17: 00
  BRK                                     ; $AA18: 00
  .byte $04                               ; $AA19: 04
  .byte $23                               ; $AA1A: 23
  .byte $22                               ; $AA1B: 22
  BRK                                     ; $AA1C: 00
  BRK                                     ; $AA1D: 00
  BRK                                     ; $AA1E: 00
  BRK                                     ; $AA1F: 00
  PHP                                     ; $AA20: 08
  .byte $23                               ; $AA21: 23
  RTI                                     ; $AA22: 40
  ORA ($01,X)                             ; $AA23: 01 01
  ORA ($01,X)                             ; $AA25: 01 01
  ORA ($01,X)                             ; $AA27: 01 01
  ORA ($01,X)                             ; $AA29: 01 01
  PHP                                     ; $AA2B: 08
  .byte $23                               ; $AA2C: 23
  RTS                                     ; $AA2D: 60
  ORA ($01,X)                             ; $AA2E: 01 01
  ORA ($01,X)                             ; $AA30: 01 01
  ORA ($01,X)                             ; $AA32: 01 01
  ORA ($01,X)                             ; $AA34: 01 01
  .byte $FF                               ; $AA36: FF

.endproc

.proc BankedDataHandler
BankedDataHandler:
  LDA $000A                               ; $AA37: AD 0A 00
  PHA                                     ; $AA3A: 48
  LDA $000B                               ; $AA3B: AD 0B 00
  PHA                                     ; $AA3E: 48
  LDA $000C                               ; $AA3F: AD 0C 00
  PHA                                     ; $AA42: 48
  LDA $000B                               ; $AA43: AD 0B 00
  CMP #$FF                                ; $AA46: C9 FF
  BEQ @skip_jsr                            ; $AA48: F0 03
  JSR @setup_bank_data                            ; $AA4A: 20 38 AB
@skip_jsr:
  PLA                                     ; $AA4D: 68
  STA $000C                               ; $AA4E: 8D 0C 00
  PLA                                     ; $AA51: 68
  STA $000B                               ; $AA52: 8D 0B 00
  PLA                                     ; $AA55: 68
  STA $000A                               ; $AA56: 8D 0A 00
  LDA $000C                               ; $AA59: AD 0C 00
  BEQ @clear_display                            ; $AA5C: F0 01
  RTS                                     ; $AA5E: 60
@clear_display:
  LDY #$30                                ; $AA5F: A0 30
  LDA #$01                                ; $AA61: A9 01
@clear_loop:
  STA $0380,Y                             ; $AA63: 99 80 03
  DEY                                     ; $AA66: 88
  BPL @clear_loop                            ; $AA67: 10 FA
  LDA $000A                               ; $AA69: AD 0A 00
  CMP #$FF                                ; $AA6C: C9 FF
  BNE @calc_index                            ; $AA6E: D0 03
  JMP @init_display                            ; $AA70: 4C DE AA
@calc_index:
  ASL A                                   ; $AA73: 0A
  CLC                                     ; $AA74: 18
  ADC $000A                               ; $AA75: 6D 0A 00
  ASL A                                   ; $AA78: 0A
  ASL A                                   ; $AA79: 0A
  TAY                                     ; $AA7A: A8
  LDA $AB08,Y                             ; $AA7B: B9 08 AB
  STA $038D                               ; $AA7E: 8D 8D 03
  LDA $AB09,Y                             ; $AA81: B9 09 AB
  STA $038E                               ; $AA84: 8D 8E 03
  LDA $AB0A,Y                             ; $AA87: B9 0A AB
  STA $038F                               ; $AA8A: 8D 8F 03
  LDA $AB0B,Y                             ; $AA8D: B9 0B AB
  STA $0390                               ; $AA90: 8D 90 03
  LDA $AB0C,Y                             ; $AA93: B9 0C AB
  STA $0391                               ; $AA96: 8D 91 03
  LDA $AB0D,Y                             ; $AA99: B9 0D AB
  STA $0392                               ; $AA9C: 8D 92 03
  LDA $AB0E,Y                             ; $AA9F: B9 0E AB
  STA $03A0                               ; $AAA2: 8D A0 03
  LDA $AB0F,Y                             ; $AAA5: B9 0F AB
  STA $03A1                               ; $AAA8: 8D A1 03
  LDA $AB10,Y                             ; $AAAB: B9 10 AB
  STA $03A2                               ; $AAAE: 8D A2 03
  LDA $AB11,Y                             ; $AAB1: B9 11 AB
  STA $03A3                               ; $AAB4: 8D A3 03
  LDA $AB12,Y                             ; $AAB7: B9 12 AB
  STA $03A4                               ; $AABA: 8D A4 03
  LDA $AB13,Y                             ; $AABD: B9 13 AB
  STA $03A5                               ; $AAC0: 8D A5 03
  LDA #$76                                ; $AAC3: A9 76
  STA $00BD                               ; $AAC5: 8D BD 00
  LDA #$C0                                ; $AAC8: A9 C0
  STA $0389                               ; $AACA: 8D 89 03
  LDA #$C1                                ; $AACD: A9 C1
  STA $038A                               ; $AACF: 8D 8A 03
  LDA #$D0                                ; $AAD2: A9 D0
  STA $039C                               ; $AAD4: 8D 9C 03
  LDA #$D1                                ; $AAD7: A9 D1
  STA $039D                               ; $AAD9: 8D 9D 03
  LDA #$FF                                ; $AADC: A9 FF
@init_display:
  LDA #$10                                ; $AADE: A9 10
  STA $0380                               ; $AAE0: 8D 80 03
  STA $0393                               ; $AAE3: 8D 93 03
  LDA #$22                                ; $AAE6: A9 22
  STA $0381                               ; $AAE8: 8D 81 03
  LDA #$C8                                ; $AAEB: A9 C8
  STA $0382                               ; $AAED: 8D 82 03
  LDA #$22                                ; $AAF0: A9 22
  STA $0394                               ; $AAF2: 8D 94 03
  LDA #$E8                                ; $AAF5: A9 E8
  STA $0395                               ; $AAF7: 8D 95 03
  LDA #$FF                                ; $AAFA: A9 FF
  STA $03A6                               ; $AAFC: 8D A6 03
  LDA $007E                               ; $AAFF: AD 7E 00
  ORA #$04                                ; $AB02: 09 04
  STA $007E                               ; $AB04: 8D 7E 00
  RTS                                     ; $AB07: 60
  .byte $C2                               ; $AB08: C2
  .byte $C3                               ; $AB09: C3
  CPY $C5                                 ; $AB0A: C4 C5
  DEC $C7                                 ; $AB0C: C6 C7
  .byte $D2                               ; $AB0E: D2
  .byte $D3                               ; $AB0F: D3
  .byte $D4                               ; $AB10: D4
  CMP $D6,X                               ; $AB11: D5 D6
  .byte $D7                               ; $AB13: D7
  INY                                     ; $AB14: C8
  CMP #$CA                                ; $AB15: C9 CA
  .byte $CB                               ; $AB17: CB
  ORA ($01,X)                             ; $AB18: 01 01
  CLD                                     ; $AB1A: D8
  CMP $DBDA,Y                             ; $AB1B: D9 DA DB
  ORA ($01,X)                             ; $AB1E: 01 01
  .byte $C2                               ; $AB20: C2
  .byte $C3                               ; $AB21: C3
  CPY $C6CD                               ; $AB22: CC CD C6
  .byte $C7                               ; $AB25: C7
  .byte $D2                               ; $AB26: D2
@data_bytes:
  .byte $D3                               ; $AB27: D3
  .byte $DC                               ; $AB28: DC
  CMP $D7D6,X                             ; $AB29: DD D6 D7
  DEC $E0CF                               ; $AB2C: CE CF E0
  SBC ($01,X)                             ; $AB2F: E1 01
  ORA ($DE,X)                             ; $AB31: 01 DE
  .byte $DF                               ; $AB33: DF
  BEQ @data_bytes                            ; $AB34: F0 F1
  ORA ($01,X)                             ; $AB36: 01 01
@setup_bank_data:
  LDY #$31                                ; $AB38: A0 31
  JSR B1F_SwitchBank8_B                   ; $AB3A: 20 5F F2
  LDA $000B                               ; $AB3D: AD 0B 00
  STA $0000                               ; $AB40: 8D 00 00
  LDA #$00                                ; $AB43: A9 00
  STA $0001                               ; $AB45: 8D 01 00
  STA $0002                               ; $AB48: 8D 02 00
  LDA #$0D                                ; $AB4B: A9 0D
  STA $0003                               ; $AB4D: 8D 03 00
  JSR B1F_MathMul24x8                     ; $AB50: 20 E9 EB
  LDA $0006                               ; $AB53: AD 06 00
  CLC                                     ; $AB56: 18
  ADC #$B4                                ; $AB57: 69 B4
  STA $0000                               ; $AB59: 8D 00 00
  LDA $0007                               ; $AB5C: AD 07 00
  ADC #$8D                                ; $AB5F: 69 8D
  STA $0001                               ; $AB61: 8D 01 00
  LDY #$00                                ; $AB64: A0 00
  LDA ($00),Y                             ; $AB66: B1 00
  STA $00B9                               ; $AB68: 8D B9 00
  LDX #$30                                ; $AB6B: A2 30
  LDY #$01                                ; $AB6D: A0 01
@copy_data_loop:
  LDA ($00),Y                             ; $AB6F: B1 00
  CMP #$FF                                ; $AB71: C9 FF
  BEQ @copy_data_done                            ; $AB73: F0 0D
  TXA                                     ; $AB75: 8A
  SEC                                     ; $AB76: 38
  SBC #$10                                ; $AB77: E9 10
  TAX                                     ; $AB79: AA
  INY                                     ; $AB7A: C8
  INY                                     ; $AB7B: C8
  INY                                     ; $AB7C: C8
  INY                                     ; $AB7D: C8
  CPY #$0D                                ; $AB7E: C0 0D
  BCC @copy_data_loop                            ; $AB80: 90 ED
@copy_data_done:
  STX $0002                               ; $AB82: 8E 02 00
  LDX $007C                               ; $AB85: AE 7C 00
  LDY #$01                                ; $AB88: A0 01
@copy_name_loop:
  LDA ($00),Y                             ; $AB8A: B1 00
  CMP #$FF                                ; $AB8C: C9 FF
  BEQ @copy_name_done                            ; $AB8E: F0 24
  CLC                                     ; $AB90: 18
  ADC #$C0                                ; $AB91: 69 C0
  STA $0201,X                             ; $AB93: 9D 01 02
  LDA $ABB8,Y                             ; $AB96: B9 B8 AB
  STA $0200,X                             ; $AB99: 9D 00 02
  LDA $ABC5,Y                             ; $AB9C: B9 C5 AB
  CLC                                     ; $AB9F: 18
  ADC $0002                               ; $ABA0: 6D 02 00
  STA $0203,X                             ; $ABA3: 9D 03 02
  LDA #$01                                ; $ABA6: A9 01
  STA $0202,X                             ; $ABA8: 9D 02 02
  INX                                     ; $ABAB: E8
  INX                                     ; $ABAC: E8
  INX                                     ; $ABAD: E8
  INX                                     ; $ABAE: E8
  INY                                     ; $ABAF: C8
  CPY #$0D                                ; $ABB0: C0 0D
  BCC @copy_name_loop                            ; $ABB2: 90 D6
@copy_name_done:
  STX $007C                               ; $ABB4: 8E 7C 00
  RTS                                     ; $ABB7: 60
  .byte $F0, $AF ; $ABB8: F0 AF
  .byte $AF                               ; $ABBA: AF
  .byte $B7                               ; $ABBB: B7
  .byte $B7                               ; $ABBC: B7
  .byte $AF                               ; $ABBD: AF
  .byte $AF                               ; $ABBE: AF
  .byte $B7                               ; $ABBF: B7
  .byte $B7                               ; $ABC0: B7
  .byte $AF                               ; $ABC1: AF
  .byte $AF                               ; $ABC2: AF
  .byte $B7                               ; $ABC3: B7
  .byte $B7                               ; $ABC4: B7
  .byte $F0, $38 ; $ABC5: F0 38
  RTI                                     ; $ABC7: 40
  SEC                                     ; $ABC8: 38
  RTI                                     ; $ABC9: 40
  PHA                                     ; $ABCA: 48
  BVC @jmp_dispatch                            ; $ABCB: 50 48
  BVC @check_val                            ; $ABCD: 50 58
  RTS                                     ; $ABCF: 60
  CLI                                     ; $ABD0: 58
  RTS                                     ; $ABD1: 60

.endproc

.proc StateHandler
StateHandler:
  LDA $037C                               ; $ABD2: AD 7C 03
  BEQ @check_state                            ; $ABD5: F0 1D
  LDY #$31                                ; $ABD7: A0 31
  JSR B1F_SwitchBank8_B                   ; $ABD9: 20 5F F2
  LDA $037D                               ; $ABDC: AD 7D 03
  CMP #$FF                                ; $ABDF: C9 FF
  BEQ @check_sub1                            ; $ABE1: F0 05
  LDA #$01                                ; $ABE3: A9 01
  JSR RenderSubState                      ; $ABE5: 20 4C B1
@check_sub1:
  LDA $037E                               ; $ABE8: AD 7E 03
  CMP #$FF                                ; $ABEB: C9 FF
  BEQ @check_state                            ; $ABED: F0 05
  LDA #$02                                ; $ABEF: A9 02
  JSR RenderSubState                      ; $ABF1: 20 4C B1
@check_state:
  LDA $0140                               ; $ABF4: AD 40 01
  BEQ @state_rts                            ; $ABF7: F0 3F
  LDA $0140                               ; $ABF9: AD 40 01
  BMI @init_state5                            ; $ABFC: 30 3B
  AND #$0F                                ; $ABFE: 29 0F
  CMP #$01                                ; $AC00: C9 01
  BEQ @clear_state                            ; $AC02: F0 14
  LDA $007E                               ; $AC04: AD 7E 00
  AND #$08                                ; $AC07: 29 08
  BNE @state_rts                            ; $AC09: D0 2D
  LDA $0150                               ; $AC0B: AD 50 01
  AND #$0F                                ; $AC0E: 29 0F
  BNE @jmp_dispatch                            ; $AC10: D0 03
  JMP @advance_draw                            ; $AC12: 4C C9 AE
@jmp_dispatch:
  JMP @advance_state                            ; $AC15: 4C F3 AD
@clear_state:
  LDA #$00                                ; $AC18: A9 00
  STA $0140                               ; $AC1A: 8D 40 01
  LDA $0150                               ; $AC1D: AD 50 01
  AND #$0F                                ; $AC20: 29 0F
  BNE @check_val                            ; $AC22: D0 03
  STA $0420                               ; $AC24: 8D 20 04
@check_val:
  CMP #$01                                ; $AC27: C9 01
  BNE @store_flags                            ; $AC29: D0 05
  LDA #$FF                                ; $AC2B: A9 FF
  STA $037C                               ; $AC2D: 8D 7C 03
@store_flags:
  LDA $0150                               ; $AC30: AD 50 01
  AND #$80                                ; $AC33: 29 80
  STA $0150                               ; $AC35: 8D 50 01
@state_rts:
  RTS                                     ; $AC38: 60
@init_state5:
  LDA #$00                                ; $AC39: A9 00
  STA $037C                               ; $AC3B: 8D 7C 03
  LDA #$05                                ; $AC3E: A9 05
  STA $0140                               ; $AC40: 8D 40 01
  LDA #$00                                ; $AC43: A9 00
  STA $0143                               ; $AC45: 8D 43 01
  LDA #$80                                ; $AC48: A9 80
  STA $0144                               ; $AC4A: 8D 44 01
  LDA #$38                                ; $AC4D: A9 38
  STA $0154                               ; $AC4F: 8D 54 01
  LDA $0150                               ; $AC52: AD 50 01
  AND #$0F                                ; $AC55: 29 0F
  BNE @setup_coords1                            ; $AC57: D0 03
  JMP @init_window                            ; $AC59: 4C 92 AD
@setup_coords1:
  LDA #$83                                ; $AC5C: A9 83
  STA $0152                               ; $AC5E: 8D 52 01
  LDA #$B6                                ; $AC61: A9 B6
  STA $0153                               ; $AC63: 8D 53 01
  LDA #$09                                ; $AC66: A9 09
  STA $00B4                               ; $AC68: 8D B4 00
  STA $00C4                               ; $AC6B: 8D C4 00
  STA $00CC                               ; $AC6E: 8D CC 00
  STA $00D4                               ; $AC71: 8D D4 00
  STA $00DC                               ; $AC74: 8D DC 00
  LDY #$80                                ; $AC77: A0 80
  LDA $0150                               ; $AC79: AD 50 01
  BPL @set_scroll                            ; $AC7C: 10 02
  LDY #$40                                ; $AC7E: A0 40
@set_scroll:
  STY $0420                               ; $AC80: 8C 20 04
  AND #$0F                                ; $AC83: 29 0F
  CMP #$01                                ; $AC85: C9 01
  BEQ @setup_case1                            ; $AC87: F0 44
  CMP #$02                                ; $AC89: C9 02
  BEQ @setup_case3                            ; $AC8B: F0 08
  CMP #$03                                ; $AC8D: C9 03
  BEQ @setup_case5                            ; $AC8F: F0 1E
  CMP #$04                                ; $AC91: C9 04
  BEQ @setup_case4                            ; $AC93: F0 29
@setup_case3:
  LDA #$E5                                ; $AC95: A9 E5
  STA $0149                               ; $AC97: 8D 49 01
  LDA #$B3                                ; $AC9A: A9 B3
  STA $014A                               ; $AC9C: 8D 4A 01
  LDA #$01                                ; $AC9F: A9 01
  STA $00B3                               ; $ACA1: 8D B3 00
  STA $00C3                               ; $ACA4: 8D C3 00
  STA $00CB                               ; $ACA7: 8D CB 00
  LDA #$05                                ; $ACAA: A9 05
  JMP @set_counters2                            ; $ACAC: 4C 1F AD
@setup_case5:
  LDA #$C1                                ; $ACAF: A9 C1
  STA $0149                               ; $ACB1: 8D 49 01
  LDA #$B4                                ; $ACB4: A9 B4
  STA $014A                               ; $ACB6: 8D 4A 01
  LDA #$05                                ; $ACB9: A9 05
  JMP @set_counters1                            ; $ACBB: 4C 16 AD
@setup_case4:
  LDA #$9C                                ; $ACBE: A9 9C
  STA $0149                               ; $ACC0: 8D 49 01
  LDA #$B5                                ; $ACC3: A9 B5
  STA $014A                               ; $ACC5: 8D 4A 01
  LDA #$05                                ; $ACC8: A9 05
  JMP @set_counters1                            ; $ACCA: 4C 16 AD
@setup_case1:
  LDA #$05                                ; $ACCD: A9 05
  STA $0149                               ; $ACCF: 8D 49 01
  LDA #$B3                                ; $ACD2: A9 B3
  STA $014A                               ; $ACD4: 8D 4A 01
  LDA $0402                               ; $ACD7: AD 02 04
  JSR B1F_GetProvinceRecordAddr           ; $ACDA: 20 AF F2
  LDY #$11                                ; $ACDD: A0 11
  LDA ($00),Y                             ; $ACDF: B1 00
  STA $037E                               ; $ACE1: 8D 7E 03
  LDY #$00                                ; $ACE4: A0 00
  LDA ($00),Y                             ; $ACE6: B1 00
  CMP #$07                                ; $ACE8: C9 07
  BNE @load_table_addr                            ; $ACEA: D0 05
  LDA #$FF                                ; $ACEC: A9 FF
  JMP @init_timers                            ; $ACEE: 4C 03 AD
@load_table_addr:
  ASL A                                   ; $ACF1: 0A
  TAY                                     ; $ACF2: A8
  LDA $AD84,Y                             ; $ACF3: B9 84 AD
  STA $0000                               ; $ACF6: 8D 00 00
  LDA $AD85,Y                             ; $ACF9: B9 85 AD
  STA $0001                               ; $ACFC: 8D 01 00
  LDY #$00                                ; $ACFF: A0 00
  LDA ($00),Y                             ; $AD01: B1 00
@init_timers:
  STA $037D                               ; $AD03: 8D 7D 03
  LDA #$08                                ; $AD06: A9 08
  STA $00B4                               ; $AD08: 8D B4 00
  STA $00C4                               ; $AD0B: 8D C4 00
  STA $00CC                               ; $AD0E: 8D CC 00
  STA $00D4                               ; $AD11: 8D D4 00
  LDA #$01                                ; $AD14: A9 01
@set_counters1:
  STA $00B3                               ; $AD16: 8D B3 00
  STA $00C3                               ; $AD19: 8D C3 00
  STA $00CB                               ; $AD1C: 8D CB 00
@set_counters2:
  STA $00D3                               ; $AD1F: 8D D3 00
  STA $00DB                               ; $AD22: 8D DB 00
  LDA #$00                                ; $AD25: A9 00
  STA $00C2                               ; $AD27: 8D C2 00
  STA $00CA                               ; $AD2A: 8D CA 00
  STA $00D2                               ; $AD2D: 8D D2 00
  STA $00DA                               ; $AD30: 8D DA 00
  LDA $0150                               ; $AD33: AD 50 01
  LDA #$20                                ; $AD36: A9 20
  STA $0142                               ; $AD38: 8D 42 01
  LDA #$23                                ; $AD3B: A9 23
  STA $0148                               ; $AD3D: 8D 48 01
  LDA $0150                               ; $AD40: AD 50 01
  BPL @setup_pos1                            ; $AD43: 10 16
  LDA #$C4                                ; $AD45: A9 C4
  STA $0147                               ; $AD47: 8D 47 01
  LDA #$7F                                ; $AD4A: A9 7F
  STA $0145                               ; $AD4C: 8D 45 01
  LDA #$B6                                ; $AD4F: A9 B6
  STA $0146                               ; $AD51: 8D 46 01
  LDX #$10                                ; $AD54: A2 10
  LDY #$CC                                ; $AD56: A0 CC
  JMP @update_pos                            ; $AD58: 4C 6E AD
@setup_pos1:
  LDA #$C0                                ; $AD5B: A9 C0
  STA $0147                               ; $AD5D: 8D 47 01
  LDA #$7B                                ; $AD60: A9 7B
  STA $0145                               ; $AD62: 8D 45 01
  LDA #$B6                                ; $AD65: A9 B6
  STA $0146                               ; $AD67: 8D 46 01
  LDX #$02                                ; $AD6A: A2 02
  LDY #$C8                                ; $AD6C: A0 C8
@update_pos:
  STX $0141                               ; $AD6E: 8E 41 01
  TYA                                     ; $AD71: 98
  CLC                                     ; $AD72: 18
  ADC $0143                               ; $AD73: 6D 43 01
  STA $0143                               ; $AD76: 8D 43 01
  LDA #$03                                ; $AD79: A9 03
  ADC $0144                               ; $AD7B: 6D 44 01
  STA $0144                               ; $AD7E: 8D 44 01

; --- Data Region: PointerTable_AD81 ---
  .byte $4C,$F3,$AD,$07,$6F,$0F,$6F,$17,$6F,$1F,$6F,$27,$6F,$2F,$6F,$37; $AD81: 4C F3 AD 07 6F 0F 6F 17 6F 1F 6F 27 6F 2F 6F 37
  .byte $6F                               ; $AD91: 6F
@init_window:
  LDA #$22                                ; $AD92: A9 22
  STA $0142                               ; $AD94: 8D 42 01
  LDA #$03                                ; $AD97: A9 03
  STA $0146                               ; $AD99: 8D 46 01
  LDA #$23                                ; $AD9C: A9 23
  STA $0148                               ; $AD9E: 8D 48 01
  LDA #$00                                ; $ADA1: A9 00
  STA $037C                               ; $ADA3: 8D 7C 03
  LDA $0150                               ; $ADA6: AD 50 01
  BPL @setup_pos2                            ; $ADA9: 10 11
  LDA #$E4                                ; $ADAB: A9 E4
  STA $0145                               ; $ADAD: 8D 45 01
  LDA #$EC                                ; $ADB0: A9 EC
  STA $0147                               ; $ADB2: 8D 47 01
  LDX #$90                                ; $ADB5: A2 90
  LDY #$10                                ; $ADB7: A0 10
  JMP @update_pos2                            ; $ADB9: 4C CA AD
@setup_pos2:
  LDA #$E0                                ; $ADBC: A9 E0
  STA $0145                               ; $ADBE: 8D 45 01
  LDA #$E8                                ; $ADC1: A9 E8
  STA $0147                               ; $ADC3: 8D 47 01
  LDX #$82                                ; $ADC6: A2 82
  LDY #$02                                ; $ADC8: A0 02
@update_pos2:
  STX $0141                               ; $ADCA: 8E 41 01
  LDA $0143                               ; $ADCD: AD 43 01
  CLC                                     ; $ADD0: 18
  ADC $0145                               ; $ADD1: 6D 45 01
  STA $0145                               ; $ADD4: 8D 45 01
  LDA $0146                               ; $ADD7: AD 46 01
  ADC $0144                               ; $ADDA: 6D 44 01
  STA $0146                               ; $ADDD: 8D 46 01
  TYA                                     ; $ADE0: 98
  CLC                                     ; $ADE1: 18
  ADC $0143                               ; $ADE2: 6D 43 01
  STA $0143                               ; $ADE5: 8D 43 01
  LDA $0144                               ; $ADE8: AD 44 01
  ADC #$02                                ; $ADEB: 69 02
  STA $0144                               ; $ADED: 8D 44 01
  JMP @advance_draw                            ; $ADF0: 4C C9 AE
@advance_state:
  DEC $0140                               ; $ADF3: CE 40 01
  LDY #$30                                ; $ADF6: A0 30
  JSR B1F_SwitchBank8_B                   ; $ADF8: 20 5F F2
  LDA $0149                               ; $ADFB: AD 49 01
  STA $0010                               ; $ADFE: 8D 10 00
  LDA $014A                               ; $AE01: AD 4A 01
  STA $0011                               ; $AE04: 8D 11 00
  LDY #$00                                ; $AE07: A0 00
  LDX #$00                                ; $AE09: A2 00
@copy_buf_loop:
  LDA ($10),Y                             ; $AE0B: B1 10
  CMP #$F0                                ; $AE0D: C9 F0
  BCS @handle_special                            ; $AE0F: B0 08
  STA $0160,X                             ; $AE11: 9D 60 01
  INY                                     ; $AE14: C8
  INX                                     ; $AE15: E8
  JMP @check_copy_done                            ; $AE16: 4C 1C AE
@handle_special:
  JSR @store_extra                            ; $AE19: 20 77 AF
@check_copy_done:
  CPX #$38                                ; $AE1C: E0 38
  BCC @copy_buf_loop                            ; $AE1E: 90 EB
  TYA                                     ; $AE20: 98
  LDY #$09                                ; $AE21: A0 09
  JSR @add_offset                            ; $AE23: 20 66 AF
  LDA $0145                               ; $AE26: AD 45 01
  STA $0010                               ; $AE29: 8D 10 00
  LDA $0146                               ; $AE2C: AD 46 01
  STA $0011                               ; $AE2F: 8D 11 00
  LDA $0143                               ; $AE32: AD 43 01
  STA $0012                               ; $AE35: 8D 12 00
  LDA $0144                               ; $AE38: AD 44 01
  STA $0013                               ; $AE3B: 8D 13 00
  LDY #$00                                ; $AE3E: A0 00
  LDA ($12),Y                             ; $AE40: B1 12
  AND #$33                                ; $AE42: 29 33
  ORA ($10),Y                             ; $AE44: 11 10
  STA $014B,Y                             ; $AE46: 99 4B 01
  INY                                     ; $AE49: C8
@copy_3bytes:
  LDA ($10),Y                             ; $AE4A: B1 10
  STA $014B,Y                             ; $AE4C: 99 4B 01
  INY                                     ; $AE4F: C8
  CPY #$03                                ; $AE50: C0 03
  BCC @copy_3bytes                            ; $AE52: 90 F6
  LDA ($12),Y                             ; $AE54: B1 12
  AND #$CC                                ; $AE56: 29 CC
  ORA ($10),Y                             ; $AE58: 11 10
  STA $014B,Y                             ; $AE5A: 99 4B 01
  LDA #$08                                ; $AE5D: A9 08
  LDY #$07                                ; $AE5F: A0 07
  JSR @add_offset                            ; $AE61: 20 66 AF
  LDA #$08                                ; $AE64: A9 08
  LDY #$03                                ; $AE66: A0 03
  JSR @add_offset                            ; $AE68: 20 66 AF
  LDA #$80                                ; $AE6B: A9 80
  LDY #$01                                ; $AE6D: A0 01
  JSR @add_offset                            ; $AE6F: 20 66 AF
  LDA $0150                               ; $AE72: AD 50 01
  AND #$0F                                ; $AE75: 29 0F
  CMP #$01                                ; $AE77: C9 01
  BNE @state_done                            ; $AE79: D0 45
  LDA $0140                               ; $AE7B: AD 40 01
  CMP #$04                                ; $AE7E: C9 04
  BNE @check_province                            ; $AE80: D0 03
  JSR DrawOfficerName                     ; $AE82: 20 AB B0
@check_province:
  LDA $0402                               ; $AE85: AD 02 04
  JSR B1F_GetProvinceRecordAddr           ; $AE88: 20 AF F2
  LDY #$00                                ; $AE8B: A0 00
  LDA ($00),Y                             ; $AE8D: B1 00
  CMP #$07                                ; $AE8F: C9 07
  BEQ @state_done                            ; $AE91: F0 2D
  LDA $0140                               ; $AE93: AD 40 01
  CMP #$04                                ; $AE96: C9 04
  BEQ @action_0                            ; $AE98: F0 0B
  CMP #$03                                ; $AE9A: C9 03
  BEQ @action_1                            ; $AE9C: F0 0F
  CMP #$02                                ; $AE9E: C9 02
  BEQ @action_2                            ; $AEA0: F0 16
  JMP @state_done                            ; $AEA2: 4C C0 AE
@action_0:
  LDA #$00                                ; $AEA5: A9 00
  JSR $B23A                               ; $AEA7: 20 3A B2
  JMP @state_done                            ; $AEAA: 4C C0 AE
@action_1:
  LDA #$01                                ; $AEAD: A9 01
  JSR $B23A                               ; $AEAF: 20 3A B2
  JSR @draw_name_scaled                            ; $AEB2: 20 7A B2
  JMP @state_done                            ; $AEB5: 4C C0 AE
@action_2:
  LDA #$02                                ; $AEB8: A9 02
  STA $000F                               ; $AEBA: 8D 0F 00
  JSR @draw_name_scaled                            ; $AEBD: 20 7A B2
@state_done:
  LDA $007E                               ; $AEC0: AD 7E 00
  ORA #$08                                ; $AEC3: 09 08
  STA $007E                               ; $AEC5: 8D 7E 00
  RTS                                     ; $AEC8: 60
@advance_draw:
  DEC $0140                               ; $AEC9: CE 40 01
  LDY #$30                                ; $AECC: A0 30
  JSR B1F_SwitchBank8_B                   ; $AECE: 20 5F F2
  LDA $0143                               ; $AED1: AD 43 01
  STA $0010                               ; $AED4: 8D 10 00
  LDA $0144                               ; $AED7: AD 44 01
  STA $0011                               ; $AEDA: 8D 11 00
  LDX #$00                                ; $AEDD: A2 00
@copy_row:
  LDY #$00                                ; $AEDF: A0 00
@copy_row_loop:
  LDA ($10),Y                             ; $AEE1: B1 10
  STA $0160,X                             ; $AEE3: 9D 60 01
  INY                                     ; $AEE6: C8
  INX                                     ; $AEE7: E8
  CPY #$0E                                ; $AEE8: C0 0E
  BCC @copy_row_loop                            ; $AEEA: 90 F5
  LDA $0010                               ; $AEEC: AD 10 00
  CLC                                     ; $AEEF: 18
  ADC #$20                                ; $AEF0: 69 20
  STA $0010                               ; $AEF2: 8D 10 00
  LDA $0011                               ; $AEF5: AD 11 00
  ADC #$00                                ; $AEF8: 69 00
  STA $0011                               ; $AEFA: 8D 11 00
  CPX #$38                                ; $AEFD: E0 38
  BCC @copy_row                            ; $AEFF: 90 DE
  LDA $0143                               ; $AF01: AD 43 01
  SEC                                     ; $AF04: 38
  SBC #$80                                ; $AF05: E9 80
  STA $0143                               ; $AF07: 8D 43 01
  LDA $0144                               ; $AF0A: AD 44 01
  SBC #$00                                ; $AF0D: E9 00
  STA $0144                               ; $AF0F: 8D 44 01
  LDA $0145                               ; $AF12: AD 45 01
  STA $0010                               ; $AF15: 8D 10 00
  LDA $0146                               ; $AF18: AD 46 01
  STA $0011                               ; $AF1B: 8D 11 00
  LDY #$00                                ; $AF1E: A0 00
@copy_4bytes:
  LDA ($10),Y                             ; $AF20: B1 10
  STA $014B,Y                             ; $AF22: 99 4B 01
  INY                                     ; $AF25: C8
  CPY #$04                                ; $AF26: C0 04
  BCC @copy_4bytes                            ; $AF28: 90 F6
  LDA $0145                               ; $AF2A: AD 45 01
  SEC                                     ; $AF2D: 38
  SBC #$08                                ; $AF2E: E9 08
  STA $0145                               ; $AF30: 8D 45 01
  LDA $0146                               ; $AF33: AD 46 01
  SBC #$00                                ; $AF36: E9 00
  STA $0146                               ; $AF38: 8D 46 01
  LDA $0147                               ; $AF3B: AD 47 01
  SEC                                     ; $AF3E: 38
  SBC #$08                                ; $AF3F: E9 08
  STA $0147                               ; $AF41: 8D 47 01
  LDA $0148                               ; $AF44: AD 48 01
  SBC #$00                                ; $AF47: E9 00
  STA $0148                               ; $AF49: 8D 48 01
  LDA $0141                               ; $AF4C: AD 41 01
  SEC                                     ; $AF4F: 38
  SBC #$80                                ; $AF50: E9 80
  STA $0141                               ; $AF52: 8D 41 01
  LDA $0142                               ; $AF55: AD 42 01
  SBC #$00                                ; $AF58: E9 00
  STA $0142                               ; $AF5A: 8D 42 01
  LDA $007E                               ; $AF5D: AD 7E 00
  ORA #$08                                ; $AF60: 09 08
  STA $007E                               ; $AF62: 8D 7E 00
  RTS                                     ; $AF65: 60
@add_offset:
  CLC                                     ; $AF66: 18
  ADC $0140,Y                             ; $AF67: 79 40 01
  STA $0140,Y                             ; $AF6A: 99 40 01
  INY                                     ; $AF6D: C8
  LDA #$00                                ; $AF6E: A9 00
  ADC $0140,Y                             ; $AF70: 79 40 01
  STA $0140,Y                             ; $AF73: 99 40 01
  RTS                                     ; $AF76: 60
@store_extra:
  STA $0012                               ; $AF77: 8D 12 00
  INY                                     ; $AF7A: C8
  LDA ($10),Y                             ; $AF7B: B1 10
  STA $0013                               ; $AF7D: 8D 13 00
  INY                                     ; $AF80: C8
  TYA                                     ; $AF81: 98
  PHA                                     ; $AF82: 48
  LDA $0402                               ; $AF83: AD 02 04
  JSR B1F_GetProvinceRecordAddr           ; $AF86: 20 AF F2
  PLA                                     ; $AF89: 68
  TAY                                     ; $AF8A: A8
  LDA ($10),Y                             ; $AF8B: B1 10
  INY                                     ; $AF8D: C8
  CLC                                     ; $AF8E: 18
  ADC $0000                               ; $AF8F: 6D 00 00
  STA $0017                               ; $AF92: 8D 17 00
  LDA $0001                               ; $AF95: AD 01 00
  ADC #$00                                ; $AF98: 69 00
  STA $0018                               ; $AF9A: 8D 18 00
  TYA                                     ; $AF9D: 98
  PHA                                     ; $AF9E: 48
  LDA $0012                               ; $AF9F: AD 12 00
  CMP #$F0                                ; $AFA2: C9 F0
  BEQ @init_ptrs2                            ; $AFA4: F0 2D
  CMP #$F1                                ; $AFA6: C9 F1
  BEQ @init_ptrs1                            ; $AFA8: F0 16
  CMP #$F3                                ; $AFAA: C9 F3
  BEQ @init_ptrs3                            ; $AFAC: F0 41
  LDY #$00                                ; $AFAE: A0 00
  LDA ($17),Y                             ; $AFB0: B1 17
  STA $0001                               ; $AFB2: 8D 01 00
  LDA #$00                                ; $AFB5: A9 00
  STA $0002                               ; $AFB7: 8D 02 00
  STA $0003                               ; $AFBA: 8D 03 00
  JMP @format_bcd                            ; $AFBD: 4C 32 B0
@init_ptrs1:
  LDY #$00                                ; $AFC0: A0 00
  STY $0003                               ; $AFC2: 8C 03 00
  LDA ($17),Y                             ; $AFC5: B1 17
  STA $0001                               ; $AFC7: 8D 01 00
  INY                                     ; $AFCA: C8
  LDA ($17),Y                             ; $AFCB: B1 17
  STA $0002                               ; $AFCD: 8D 02 00
  JMP @format_bcd                            ; $AFD0: 4C 32 B0
@init_ptrs2:
  LDY #$00                                ; $AFD3: A0 00
  STY $0003                               ; $AFD5: 8C 03 00
  STY $0002                               ; $AFD8: 8C 02 00
  STY $0001                               ; $AFDB: 8C 01 00
@scan_entries:
  LDA ($17),Y                             ; $AFDE: B1 17
  CMP #$FF                                ; $AFE0: C9 FF
  BEQ @scan_next                            ; $AFE2: F0 03
  INC $0001                               ; $AFE4: EE 01 00
@scan_next:
  INY                                     ; $AFE7: C8
  CPY #$0A                                ; $AFE8: C0 0A
  BCC @scan_entries                            ; $AFEA: 90 F2
  JMP @format_bcd                            ; $AFEC: 4C 32 B0
@init_ptrs3:
  LDY #$00                                ; $AFEF: A0 00
  STY $0002                               ; $AFF1: 8C 02 00
  STY $0003                               ; $AFF4: 8C 03 00
  STY $0004                               ; $AFF7: 8C 04 00
@scan_officers:
  LDA ($17),Y                             ; $AFFA: B1 17
  CMP #$FF                                ; $AFFC: C9 FF
  BEQ @scan_done2                            ; $AFFE: F0 21
  JSR B1F_GetOfficerRecordAddr            ; $B000: 20 D7 F2
  LDY #$08                                ; $B003: A0 08
  LDA ($00),Y                             ; $B005: B1 00
  CLC                                     ; $B007: 18
  ADC $0002                               ; $B008: 6D 02 00
  STA $0002                               ; $B00B: 8D 02 00
  INY                                     ; $B00E: C8
  LDA ($00),Y                             ; $B00F: B1 00
  ADC $0003                               ; $B011: 6D 03 00
  STA $0003                               ; $B014: 8D 03 00
  INC $0004                               ; $B017: EE 04 00
  LDY $0004                               ; $B01A: AC 04 00
  CPY #$0A                                ; $B01D: C0 0A
  BCC @scan_officers                            ; $B01F: 90 D9
@scan_done2:
  LDA $0002                               ; $B021: AD 02 00
  STA $0001                               ; $B024: 8D 01 00
  LDA $0003                               ; $B027: AD 03 00
  STA $0002                               ; $B02A: 8D 02 00
  LDA #$00                                ; $B02D: A9 00
  STA $0003                               ; $B02F: 8D 03 00
@format_bcd:
  TXA                                     ; $B032: 8A
  PHA                                     ; $B033: 48
  JSR B1F_MathBinToBcd                    ; $B034: 20 BA E9
  PLA                                     ; $B037: 68
  TAX                                     ; $B038: AA
  PLA                                     ; $B039: 68
  TAY                                     ; $B03A: A8
  LDA #$B6                                ; $B03B: A9 B6
  STA $0017                               ; $B03D: 8D 17 00
@format_digits:
  LDA #$01                                ; $B040: A9 01
  STA $0016                               ; $B042: 8D 16 00
  LDA $0013                               ; $B045: AD 13 00
  CMP #$02                                ; $B048: C9 02
  BEQ @digit_thousands                            ; $B04A: F0 30
  CMP #$03                                ; $B04C: C9 03
  BEQ @digit_lo                            ; $B04E: F0 24
  CMP #$04                                ; $B050: C9 04
  BEQ @digit_hi                            ; $B052: F0 16
  CMP #$05                                ; $B054: C9 05
  BEQ @digit_ones                            ; $B056: F0 0A
  LDA $0009                               ; $B058: AD 09 00
  LSR A                                   ; $B05B: 4A
  LSR A                                   ; $B05C: 4A
  LSR A                                   ; $B05D: 4A
  LSR A                                   ; $B05E: 4A
  JSR @write_digit                            ; $B05F: 20 91 B0
@digit_ones:
  LDA $0009                               ; $B062: AD 09 00
  AND #$0F                                ; $B065: 29 0F
  JSR @write_digit                            ; $B067: 20 91 B0
@digit_hi:
  LDA $0008                               ; $B06A: AD 08 00
  LSR A                                   ; $B06D: 4A
  LSR A                                   ; $B06E: 4A
  LSR A                                   ; $B06F: 4A
  LSR A                                   ; $B070: 4A
  JSR @write_digit                            ; $B071: 20 91 B0
@digit_lo:
  LDA $0008                               ; $B074: AD 08 00
  AND #$0F                                ; $B077: 29 0F
  JSR @write_digit                            ; $B079: 20 91 B0
@digit_thousands:
  LDA $0007                               ; $B07C: AD 07 00
  LSR A                                   ; $B07F: 4A
  LSR A                                   ; $B080: 4A
  LSR A                                   ; $B081: 4A
  LSR A                                   ; $B082: 4A
  JSR @write_digit                            ; $B083: 20 91 B0
  LDA $0017                               ; $B086: AD 17 00
  STA $0016                               ; $B089: 8D 16 00
  LDA $0007                               ; $B08C: AD 07 00
  AND #$0F                                ; $B08F: 29 0F
@write_digit:
  BNE @write_offset_digit                            ; $B091: D0 09
  LDA $0016                               ; $B093: AD 16 00
  STA $0160,X                             ; $B096: 9D 60 01
  JMP @inc_index                            ; $B099: 4C A9 B0
@write_offset_digit:
  CLC                                     ; $B09C: 18
  ADC $0017                               ; $B09D: 6D 17 00
  STA $0160,X                             ; $B0A0: 9D 60 01
  LDA $0017                               ; $B0A3: AD 17 00
  STA $0016                               ; $B0A6: 8D 16 00
@inc_index:
  INX                                     ; $B0A9: E8
  RTS                                     ; $B0AA: 60
DrawOfficerName:
  LDA #$00                                ; $B0AB: A9 00
  STA $0000                               ; $B0AD: 8D 00 00
  STA $0001                               ; $B0B0: 8D 01 00
  LDA $0402                               ; $B0B3: AD 02 04
  ASL A                                   ; $B0B6: 0A
  CLC                                     ; $B0B7: 18
  ADC $0402                               ; $B0B8: 6D 02 04
  ASL A                                   ; $B0BB: 0A
  ASL A                                   ; $B0BC: 0A
  ROL $0001                               ; $B0BD: 2E 01 00
  CLC                                     ; $B0C0: 18
  ADC $0402                               ; $B0C1: 6D 02 04
  STA $0000                               ; $B0C4: 8D 00 00
  LDA $0001                               ; $B0C7: AD 01 00
  ADC #$00                                ; $B0CA: 69 00
  STA $0001                               ; $B0CC: 8D 01 00
  LDA $0000                               ; $B0CF: AD 00 00
  CLC                                     ; $B0D2: 18
  ADC $0152                               ; $B0D3: 6D 52 01
  STA $0000                               ; $B0D6: 8D 00 00
  LDA $0001                               ; $B0D9: AD 01 00
  ADC $0153                               ; $B0DC: 6D 53 01
  STA $0001                               ; $B0DF: 8D 01 00
  LDY #$00                                ; $B0E2: A0 00
  LDA ($00),Y                             ; $B0E4: B1 00
  STA $00B2                               ; $B0E6: 8D B2 00
  STA $00C2                               ; $B0E9: 8D C2 00
  STA $00CA                               ; $B0EC: 8D CA 00
  STA $00D2                               ; $B0EF: 8D D2 00
  STA $00DA                               ; $B0F2: 8D DA 00
  INY                                     ; $B0F5: C8
  LDX #$00                                ; $B0F6: A2 00
@copy_name7:
  LDA ($00),Y                             ; $B0F8: B1 00
  STA $016F,X                             ; $B0FA: 9D 6F 01
  INY                                     ; $B0FD: C8
  INX                                     ; $B0FE: E8
  CPY #$07                                ; $B0FF: C0 07
  BCC @copy_name7                            ; $B101: 90 F5
  LDX #$00                                ; $B103: A2 00
@copy_name12:
  LDA ($00),Y                             ; $B105: B1 00
  STA $017D,X                             ; $B107: 9D 7D 01
  INY                                     ; $B10A: C8
  INX                                     ; $B10B: E8
  CPY #$0D                                ; $B10C: C0 0D
  BCC @copy_name12                            ; $B10E: 90 F5
  LDY #$30                                ; $B110: A0 30
  JSR B1F_SwitchBank8_B                   ; $B112: 20 5F F2
  LDA $0402                               ; $B115: AD 02 04
  ASL A                                   ; $B118: 0A
  ASL A                                   ; $B119: 0A
  ASL A                                   ; $B11A: 0A
  CLC                                     ; $B11B: 18
  ADC #$1A                                ; $B11C: 69 1A
  STA $0000                               ; $B11E: 8D 00 00
  LDA #$9A                                ; $B121: A9 9A
  ADC #$00                                ; $B123: 69 00
  STA $0001                               ; $B125: 8D 01 00
  LDY #$00                                ; $B128: A0 00
  LDX #$00                                ; $B12A: A2 00
@process_chars:
  LDA ($00),Y                             ; $B12C: B1 00
  BEQ @char_done                            ; $B12E: F0 1B
  CLC                                     ; $B130: 18
  ADC #$80                                ; $B131: 69 80
  CMP #$B9                                ; $B133: C9 B9
  BEQ @store_back                            ; $B135: F0 0A
  CMP #$BA                                ; $B137: C9 BA
  BEQ @store_back                            ; $B139: F0 06
  STA $0183,X                             ; $B13B: 9D 83 01
  JMP @inc_char_idx                            ; $B13E: 4C 45 B1
@store_back:
  DEX                                     ; $B141: CA
  STA $0175,X                             ; $B142: 9D 75 01
@inc_char_idx:
  INY                                     ; $B145: C8
  INX                                     ; $B146: E8
  CPY #$08                                ; $B147: C0 08
  BCC @process_chars                            ; $B149: 90 E1
@char_done:
  RTS                                     ; $B14B: 60
RenderSubState:
  STA $0006                               ; $B14C: 8D 06 00
  LDX #$00                                ; $B14F: A2 00
  LDA $0150                               ; $B151: AD 50 01
  BPL @setup_render                            ; $B154: 10 02
  LDX #$70                                ; $B156: A2 70
@setup_render:
  STX $0005                               ; $B158: 8E 05 00
  LDY $0006                               ; $B15B: AC 06 00
  LDX $0006                               ; $B15E: AE 06 00
  LDA #$40                                ; $B161: A9 40
  STA $0007                               ; $B163: 8D 07 00
  LDA #$00                                ; $B166: A9 00
  CPY #$01                                ; $B168: C0 01
  BEQ @load_tile_addr                            ; $B16A: F0 07
  LDA #$80                                ; $B16C: A9 80
  STA $0007                               ; $B16E: 8D 07 00
  LDA #$20                                ; $B171: A9 20
@load_tile_addr:
  STA $0006                               ; $B173: 8D 06 00
  LDA $037C,Y                             ; $B176: B9 7C 03
  STA $0000                               ; $B179: 8D 00 00
  LDA #$00                                ; $B17C: A9 00
  STA $0001                               ; $B17E: 8D 01 00
  LDA $0000                               ; $B181: AD 00 00
  ASL A                                   ; $B184: 0A
  ROL $0001                               ; $B185: 2E 01 00
  CLC                                     ; $B188: 18
  ADC $037C,Y                             ; $B189: 79 7C 03
  STA $0000                               ; $B18C: 8D 00 00
  LDA $0001                               ; $B18F: AD 01 00
  ADC #$00                                ; $B192: 69 00
  STA $0001                               ; $B194: 8D 01 00
  LDA $0000                               ; $B197: AD 00 00
  ASL A                                   ; $B19A: 0A
  ROL $0001                               ; $B19B: 2E 01 00
  ASL A                                   ; $B19E: 0A
  ROL $0001                               ; $B19F: 2E 01 00
  CLC                                     ; $B1A2: 18
  ADC $037C,Y                             ; $B1A3: 79 7C 03
  STA $0000                               ; $B1A6: 8D 00 00
  LDA $0001                               ; $B1A9: AD 01 00
  ADC #$00                                ; $B1AC: 69 00
  STA $0001                               ; $B1AE: 8D 01 00
  LDA #$B4                                ; $B1B1: A9 B4
  CLC                                     ; $B1B3: 18
  ADC $0000                               ; $B1B4: 6D 00 00
  STA $0000                               ; $B1B7: 8D 00 00
  LDA #$8D                                ; $B1BA: A9 8D
  ADC $0001                               ; $B1BC: 6D 01 00
  STA $0001                               ; $B1BF: 8D 01 00
  LDA #$22                                ; $B1C2: A9 22
  STA $0002                               ; $B1C4: 8D 02 00
  LDA #$B2                                ; $B1C7: A9 B2
  STA $0003                               ; $B1C9: 8D 03 00
  LDY #$00                                ; $B1CC: A0 00
  STY $0004                               ; $B1CE: 8C 04 00
  LDA ($00),Y                             ; $B1D1: B1 00
  STA $00AE,X                             ; $B1D3: 9D AE 00
  STA $00BE,X                             ; $B1D6: 9D BE 00
  STA $00C6,X                             ; $B1D9: 9D C6 00
  STA $00CE,X                             ; $B1DC: 9D CE 00
  STA $00D6,X                             ; $B1DF: 9D D6 00
  LDX $007C                               ; $B1E2: AE 7C 00
@copy_officer_data:
  INY                                     ; $B1E5: C8
  LDA ($00),Y                             ; $B1E6: B1 00
  CMP #$FF                                ; $B1E8: C9 FF
  BEQ @officer_done                            ; $B1EA: F0 32
  CLC                                     ; $B1EC: 18
  ADC $0007                               ; $B1ED: 6D 07 00
  STA $0201,X                             ; $B1F0: 9D 01 02
  LDA #$01                                ; $B1F3: A9 01
  STA $0202,X                             ; $B1F5: 9D 02 02
  TYA                                     ; $B1F8: 98
  PHA                                     ; $B1F9: 48
  LDY $0004                               ; $B1FA: AC 04 00
  LDA ($02),Y                             ; $B1FD: B1 02
  CLC                                     ; $B1FF: 18
  ADC $0005                               ; $B200: 6D 05 00
  STA $0203,X                             ; $B203: 9D 03 02
  INY                                     ; $B206: C8
  LDA ($02),Y                             ; $B207: B1 02
  CLC                                     ; $B209: 18
  ADC $0006                               ; $B20A: 6D 06 00
  STA $0200,X                             ; $B20D: 9D 00 02
  INY                                     ; $B210: C8
  STY $0004                               ; $B211: 8C 04 00
  INX                                     ; $B214: E8
  INX                                     ; $B215: E8
  INX                                     ; $B216: E8
  INX                                     ; $B217: E8
  PLA                                     ; $B218: 68
  TAY                                     ; $B219: A8
  CPY #$0C                                ; $B21A: C0 0C
  BCC @copy_officer_data                            ; $B21C: 90 C7
@officer_done:
  STX $007C                               ; $B21E: 8E 7C 00
  RTS                                     ; $B221: 60

; --- Data Region: DataTable_B222 ---
  .byte $40,$48,$48,$48,$40,$50,$48,$50,$50,$48,$58,$48,$50,$50,$58,$50; $B222: 40 48 48 48 40 50 48 50 50 48 58 48 50 50 58 50
  .byte $60,$48,$68,$48,$60,$50,$68,$50,$8D,$0F,$00; $B232: 60 48 68 48 60 50 68 50 8D 0F 00
  LDA $0402                               ; $B23D: AD 02 04
  JSR B1F_GetProvinceRecordAddr           ; $B240: 20 AF F2
  LDY #$00                                ; $B243: A0 00
  LDA ($00),Y                             ; $B245: B1 00
  CMP #$07                                ; $B247: C9 07
  BEQ @name_rts                            ; $B249: F0 2E
  LDY #$01                                ; $B24B: A0 01
  LDA $000F                               ; $B24D: AD 0F 00
  BEQ @load_name_scale                            ; $B250: F0 02
  LDY #$02                                ; $B252: A0 02
@load_name_scale:
  LDA $037C,Y                             ; $B254: B9 7C 03
  JSR B1F_GetNameDisplayScale             ; $B257: 20 08 F3
  LDY #$00                                ; $B25A: A0 00
  LDX #$00                                ; $B25C: A2 00
@name_scan2:
  LDA ($00),Y                             ; $B25E: B1 00
  BEQ @name_rts                            ; $B260: F0 17
  CMP #$39                                ; $B262: C9 39
  BEQ @name_adjust                            ; $B264: F0 07
  CMP #$3A                                ; $B266: C9 3A
  BEQ @name_adjust                            ; $B268: F0 03
  JMP @name_next                            ; $B26A: 4C 74 B2
@name_adjust:
  DEX                                     ; $B26D: CA
  CLC                                     ; $B26E: 18
  ADC #$80                                ; $B26F: 69 80
  STA $0190,X                             ; $B271: 9D 90 01
@name_next:
  INX                                     ; $B274: E8
  INY                                     ; $B275: C8
  JMP @name_scan2                            ; $B276: 4C 5E B2
@name_rts:
  RTS                                     ; $B279: 60
@draw_name_scaled:
  LDY $000F                               ; $B27A: AC 0F 00
  LDA $037C,Y                             ; $B27D: B9 7C 03
  JSR B1F_GetNameDisplayScale             ; $B280: 20 08 F3
  LDY #$00                                ; $B283: A0 00
  LDX #$00                                ; $B285: A2 00
@name_scan3:
  LDA ($00),Y                             ; $B287: B1 00
  BEQ @name_rts2                            ; $B289: F0 13
  CMP #$39                                ; $B28B: C9 39
  BEQ @name_next3                            ; $B28D: F0 0B
  CMP #$3A                                ; $B28F: C9 3A
  BEQ @name_next3                            ; $B291: F0 07
  CLC                                     ; $B293: 18
  ADC #$80                                ; $B294: 69 80
  STA $0166,X                             ; $B296: 9D 66 01
  INX                                     ; $B299: E8
@name_next3:
  INY                                     ; $B29A: C8
  JMP @name_scan3                            ; $B29B: 4C 87 B2
@name_rts2:
  RTS                                     ; $B29E: 60

.endproc

.proc MapDisplaySetup
MapDisplaySetup:
  LDA $008B                               ; $B29F: AD 8B 00
  AND #$FB                                ; $B2A2: 29 FB
  STA $2000                               ; $B2A4: 8D 00 20
  LDA $2002                               ; $B2A7: AD 02 20
  LDA $0142                               ; $B2AA: AD 42 01
  STA $2006                               ; $B2AD: 8D 06 20
  STA $0001                               ; $B2B0: 8D 01 00
  LDA $0141                               ; $B2B3: AD 41 01
  STA $2006                               ; $B2B6: 8D 06 20
  STA $0000                               ; $B2B9: 8D 00 00
  LDX #$00                                ; $B2BC: A2 00
@write_row:
  LDY #$00                                ; $B2BE: A0 00
@write_row_loop:
  LDA $0160,X                             ; $B2C0: BD 60 01
  STA $2007                               ; $B2C3: 8D 07 20
  INY                                     ; $B2C6: C8
  INX                                     ; $B2C7: E8
  CPY #$0E                                ; $B2C8: C0 0E
  BCC @write_row_loop                            ; $B2CA: 90 F4
  LDA $0000                               ; $B2CC: AD 00 00
  CLC                                     ; $B2CF: 18
  ADC #$20                                ; $B2D0: 69 20
  STA $0000                               ; $B2D2: 8D 00 00
  LDA $0001                               ; $B2D5: AD 01 00
  ADC #$00                                ; $B2D8: 69 00
  STA $0001                               ; $B2DA: 8D 01 00
  STA $2006                               ; $B2DD: 8D 06 20
  LDA $0000                               ; $B2E0: AD 00 00
  STA $2006                               ; $B2E3: 8D 06 20
  CPX $0154                               ; $B2E6: EC 54 01
  BCC @write_row                            ; $B2E9: 90 D3
  LDA $0148                               ; $B2EB: AD 48 01
  STA $2006                               ; $B2EE: 8D 06 20
  LDA $0147                               ; $B2F1: AD 47 01
  STA $2006                               ; $B2F4: 8D 06 20
  LDY #$00                                ; $B2F7: A0 00
@write_4bytes:
  LDA $014B,Y                             ; $B2F9: B9 4B 01
  STA $2007                               ; $B2FC: 8D 07 20
  INY                                     ; $B2FF: C8
  CPY #$04                                ; $B300: C0 04
  BCC @write_4bytes                            ; $B302: 90 F5
  RTS                                     ; $B304: 60

; --- Data Region: TileMapData_B305 ---
  .byte $10,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$11,$13,$01; $B305: 10 12 12 12 12 12 12 12 12 12 12 12 12 11 13 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01; $B315: 01 01 01 01 01 01 01 01 01 01 01 23 13 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01,$01,$01; $B325: 01 01 01 01 01 01 01 01 01 23 13 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01,$01,$01,$01,$01; $B335: 01 01 01 01 01 01 01 23 13 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$23,$13,$60,$61,$62,$63,$01,$01,$01,$01,$01; $B345: 01 01 01 01 01 23 13 60 61 62 63 01 01 01 01 01
  .byte $01,$01,$01,$23,$13,$70,$71,$72,$73,$01,$01,$01,$01,$01,$01,$01; $B355: 01 01 01 23 13 70 71 72 73 01 01 01 01 01 01 01
  .byte $01,$23,$13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23; $B365: 01 23 13 01 01 01 01 01 01 01 01 01 01 01 01 23
  .byte $13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$64; $B375: 13 01 01 01 01 01 01 01 01 01 01 01 01 23 13 64
  .byte $65,$66,$67,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$74,$75,$76; $B385: 65 66 67 01 01 01 01 01 01 01 01 23 13 74 75 76
  .byte $77,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01,$01,$01; $B395: 77 01 01 01 01 01 01 01 01 23 13 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01,$01,$01,$01,$01; $B3A5: 01 01 01 01 01 01 01 23 13 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$23,$13,$68,$69,$6A,$6B,$6C,$6D,$01,$01,$01; $B3B5: 01 01 01 01 01 23 13 68 69 6A 6B 6C 6D 01 01 01
  .byte $01,$01,$01,$23,$13,$78,$79,$7A,$7B,$7C,$7D,$01,$01,$01,$F2,$03; $B3C5: 01 01 01 23 13 78 79 7A 7B 7C 7D 01 01 01 F2 03
  .byte $0B,$23,$20,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$21; $B3D5: 0B 23 20 22 22 22 22 22 22 22 22 22 22 22 22 21
  .byte $10,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$11,$13,$40; $B3E5: 10 12 12 12 12 12 12 12 12 12 12 12 12 11 13 40
  .byte $41,$01,$01,$01,$01,$42,$43,$01,$01,$01,$01,$23,$13,$50,$51,$F1; $B3F5: 41 01 01 01 01 42 43 01 01 01 01 23 13 50 51 F1
  .byte $04,$02,$52,$53,$F1,$04,$04,$23,$13,$44,$45,$46,$47,$01,$01,$01; $B405: 04 02 52 53 F1 04 04 23 13 44 45 46 47 01 01 01
  .byte $01,$01,$01,$01,$01,$23,$13,$54,$55,$56,$57,$01,$01,$01,$01,$01; $B415: 01 01 01 01 01 23 13 54 55 56 57 01 01 01 01 01
  .byte $F1,$03,$08,$23,$13,$48,$49,$4A,$4B,$01,$01,$01,$01,$01,$01,$01; $B425: F1 03 08 23 13 48 49 4A 4B 01 01 01 01 01 01 01
  .byte $01,$23,$13,$58,$59,$5A,$5B,$01,$01,$01,$01,$01,$F1,$03,$0E,$23; $B435: 01 23 13 58 59 5A 5B 01 01 01 01 01 F1 03 0E 23
  .byte $13,$4C,$4D,$4E,$4F,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$64; $B445: 13 4C 4D 4E 4F 01 01 01 01 01 01 01 01 23 13 64
  .byte $65,$74,$75,$01,$F1,$05,$06,$B6,$B6,$23,$13,$60,$61,$62,$63,$01; $B455: 65 74 75 01 F1 05 06 B6 B6 23 13 60 61 62 63 01
  .byte $01,$01,$01,$01,$01,$01,$01,$23,$13,$70,$71,$72,$73,$01,$01,$01; $B465: 01 01 01 01 01 01 01 23 13 70 71 72 73 01 01 01
  .byte $01,$01,$01,$F2,$02,$0A,$23,$13,$44,$45,$46,$47,$01,$01,$01,$01; $B475: 01 01 01 F2 02 0A 23 13 44 45 46 47 01 01 01 01
  .byte $01,$01,$01,$01,$23,$13,$54,$55,$56,$57,$01,$01,$01,$01,$01,$01; $B485: 01 01 01 01 23 13 54 55 56 57 01 01 01 01 01 01
  .byte $F0,$02,$11,$23,$13,$48,$49,$4A,$4B,$01,$01,$01,$01,$01,$01,$01; $B495: F0 02 11 23 13 48 49 4A 4B 01 01 01 01 01 01 01
  .byte $01,$23,$13,$58,$59,$5A,$5B,$01,$01,$01,$F3,$05,$11,$23,$20,$22; $B4A5: 01 23 13 58 59 5A 5B 01 01 01 F3 05 11 23 20 22
  .byte $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$21,$10,$12,$12,$12; $B4B5: 22 22 22 22 22 22 22 22 22 22 22 21 10 12 12 12
  .byte $12,$12,$12,$12,$12,$12,$12,$12,$12,$11,$13,$40,$41,$01,$01,$01; $B4C5: 12 12 12 12 12 12 12 12 12 11 13 40 41 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$23,$13,$50,$51,$01,$01,$01,$01,$01; $B4D5: 01 01 01 01 01 01 01 23 13 50 51 01 01 01 01 01
  .byte $01,$F1,$04,$02,$23,$13,$42,$43,$01,$01,$01,$01,$01,$01,$01,$01; $B4E5: 01 F1 04 02 23 13 42 43 01 01 01 01 01 01 01 01
  .byte $01,$01,$23,$13,$52,$53,$01,$01,$01,$01,$01,$01,$F1,$04,$04,$23; $B4F5: 01 01 23 13 52 53 01 01 01 01 01 01 F1 04 04 23
  .byte $13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$44; $B505: 13 01 01 01 01 01 01 01 01 01 01 01 01 23 13 44
  .byte $45,$46,$47,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$54,$55,$56; $B515: 45 46 47 01 01 01 01 01 01 01 01 23 13 54 55 56
  .byte $57,$01,$01,$01,$01,$01,$01,$F0,$02,$11,$23,$13,$01,$01,$01,$01; $B525: 57 01 01 01 01 01 01 F0 02 11 23 13 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$48,$49,$4A,$4B,$4C,$4D; $B535: 01 01 01 01 01 01 01 01 23 13 48 49 4A 4B 4C 4D
  .byte $01,$01,$01,$01,$01,$01,$23,$13,$58,$59,$5A,$5B,$5C,$5D,$01,$01; $B545: 01 01 01 01 01 01 23 13 58 59 5A 5B 5C 5D 01 01
  .byte $01,$01,$01,$01,$23,$13,$69,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B555: 01 01 01 01 23 13 69 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$23,$13,$68,$6A,$6B,$6C,$01,$01,$01,$F3,$05,$11,$23,$13; $B565: 01 01 23 13 68 6A 6B 6C 01 01 01 F3 05 11 23 13
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$6D,$6E; $B575: 01 01 01 01 01 01 01 01 01 01 01 01 23 13 6D 6E
  .byte $6F,$01,$01,$01,$01,$F1,$05,$0C,$23,$20,$22,$22,$22,$22,$22,$22; $B585: 6F 01 01 01 01 F1 05 0C 23 20 22 22 22 22 22 22
  .byte $22,$22,$22,$22,$22,$22,$21,$10,$12,$12,$12,$12,$12,$12,$12,$12; $B595: 22 22 22 22 22 22 21 10 12 12 12 12 12 12 12 12
  .byte $12,$12,$12,$12,$11,$13,$40,$41,$01,$01,$01,$01,$01,$01,$01,$01; $B5A5: 12 12 12 12 11 13 40 41 01 01 01 01 01 01 01 01
  .byte $01,$01,$23,$13,$50,$51,$01,$01,$01,$01,$01,$01,$F1,$04,$02,$23; $B5B5: 01 01 23 13 50 51 01 01 01 01 01 01 F1 04 02 23
  .byte $13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$42; $B5C5: 13 01 01 01 01 01 01 01 01 01 01 01 01 23 13 42
  .byte $43,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$52,$53,$01; $B5D5: 43 01 01 01 01 01 01 01 01 01 01 23 13 52 53 01
  .byte $01,$01,$01,$01,$01,$F1,$04,$04,$23,$13,$01,$01,$01,$01,$01,$01; $B5E5: 01 01 01 01 01 F1 04 04 23 13 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$23,$13,$4E,$4F,$01,$01,$01,$01,$01,$01; $B5F5: 01 01 01 01 01 01 23 13 4E 4F 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$23,$13,$5E,$5F,$01,$01,$01,$01,$01,$01,$01,$01; $B605: 01 01 01 01 23 13 5E 5F 01 01 01 01 01 01 01 01
  .byte $F2,$02,$10,$23,$13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B615: F2 02 10 23 13 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$23,$13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23; $B625: 01 23 13 01 01 01 01 01 01 01 01 01 01 01 01 23
  .byte $13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$01; $B635: 13 01 01 01 01 01 01 01 01 01 01 01 01 23 13 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01; $B645: 01 01 01 01 01 01 01 01 01 01 01 23 13 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01,$01,$01; $B655: 01 01 01 01 01 01 01 01 01 23 13 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$23,$20,$22,$22,$22,$22,$22,$22,$22; $B665: 01 01 01 01 01 01 01 23 20 22 22 22 22 22 22 22
  .byte $22,$22,$22,$22,$22,$21,$88,$AA,$AA,$AA,$AA,$AA,$AA,$22,$5C,$28; $B675: 22 22 22 22 22 21 88 AA AA AA AA AA AA 22 5C 28
  .byte $29,$2A,$2B,$01,$01,$38,$39,$3A,$3B,$01,$01,$00,$24,$25,$26,$27; $B685: 29 2A 2B 01 01 38 39 3A 3B 01 01 00 24 25 26 27
  .byte $01,$01,$34,$35,$36,$37,$01,$01,$00,$28,$29,$26,$27,$01,$01,$38; $B695: 01 01 34 35 36 37 01 01 00 28 29 26 27 01 01 38
  .byte $39,$36,$37,$01,$01,$00,$2A,$2B,$26,$27,$01,$01,$3A,$3B,$36,$37; $B6A5: 39 36 37 01 01 00 2A 2B 26 27 01 01 3A 3B 36 37
  .byte $01,$01,$00,$2C,$2D,$26,$27,$01,$01,$3C,$3D,$36,$37,$01,$01,$59; $B6B5: 01 01 00 2C 2D 26 27 01 01 3C 3D 36 37 01 01 59
  .byte $24,$25,$26,$27,$28,$29,$34,$35,$36,$37,$38,$39,$00,$2E,$2F,$26; $B6C5: 24 25 26 27 28 29 34 35 36 37 38 39 00 2E 2F 26
  .byte $27,$01,$01,$3E,$3F,$36,$37,$01,$01,$59,$26,$27,$2A,$2B,$01,$01; $B6D5: 27 01 01 3E 3F 36 37 01 01 59 26 27 2A 2B 01 01
  .byte $36,$37,$3A,$3B,$01,$01,$59,$2E,$2F,$26,$27,$01,$01,$3E,$3F,$36; $B6E5: 36 37 3A 3B 01 01 59 2E 2F 26 27 01 01 3E 3F 36
  .byte $37,$01,$01,$5A,$24,$25,$26,$27,$28,$29,$34,$35,$36,$37,$38,$39; $B6F5: 37 01 01 5A 24 25 26 27 28 29 34 35 36 37 38 39
  .byte $58,$28,$29,$26,$27,$01,$01,$38,$39,$36,$37,$01,$01,$58,$2A,$2B; $B705: 58 28 29 26 27 01 01 38 39 36 37 01 01 58 2A 2B
  .byte $26,$27,$01,$01,$3A,$3B,$36,$37,$01,$01,$5B,$24,$25,$26,$27,$01; $B715: 26 27 01 01 3A 3B 36 37 01 01 5B 24 25 26 27 01
  .byte $01,$34,$35,$36,$37,$01,$01,$5C,$2C,$2D,$2E,$2F,$01,$01,$3C,$3D; $B725: 01 34 35 36 37 01 01 5C 2C 2D 2E 2F 01 01 3C 3D
  .byte $3E,$3F,$01,$01,$58,$2C,$2D,$26,$27,$01,$01,$3C,$3D,$36,$37,$01; $B735: 3E 3F 01 01 58 2C 2D 26 27 01 01 3C 3D 36 37 01
  .byte $01,$59,$2C,$2D,$30,$31,$01,$01,$3C,$3D,$32,$33,$01,$01,$00,$30; $B745: 01 59 2C 2D 30 31 01 01 3C 3D 32 33 01 01 00 30
  .byte $31,$26,$27,$01,$01,$32,$33,$36,$37,$01,$01,$59,$2C,$2D,$26,$27; $B755: 31 26 27 01 01 32 33 36 37 01 01 59 2C 2D 26 27
  .byte $01,$01,$3C,$3D,$36,$37,$01,$01,$58,$24,$25,$26,$27,$01,$01,$34; $B765: 01 01 3C 3D 36 37 01 01 58 24 25 26 27 01 01 34
  .byte $35,$36,$37,$01,$01,$5A,$2A,$2B,$2C,$2D,$01,$01,$3A,$3B,$3C,$3D; $B775: 35 36 37 01 01 5A 2A 2B 2C 2D 01 01 3A 3B 3C 3D
  .byte $01,$01,$5A,$2E,$2F,$30,$31,$01,$01,$3E,$3F,$32,$33,$01,$01,$58; $B785: 01 01 5A 2E 2F 30 31 01 01 3E 3F 32 33 01 01 58
  .byte $2E,$2F,$26,$27,$01,$01,$3E,$3F,$36,$37,$01,$01,$5B,$28,$29,$26; $B795: 2E 2F 26 27 01 01 3E 3F 36 37 01 01 5B 28 29 26
  .byte $27,$01,$01,$38,$39,$36,$37,$01,$01,$5C,$24,$25,$26,$27,$01,$01; $B7A5: 27 01 01 38 39 36 37 01 01 5C 24 25 26 27 01 01
  .byte $34,$35,$36,$37,$01,$01,$5B,$2E,$2F,$2C,$2D,$01,$01,$3E,$3F,$3C; $B7B5: 34 35 36 37 01 01 5B 2E 2F 2C 2D 01 01 3E 3F 3C
  .byte $3D,$01,$01,$5D,$24,$25,$26,$27,$01,$01,$34,$35,$36,$37,$01,$01; $B7C5: 3D 01 01 5D 24 25 26 27 01 01 34 35 36 37 01 01
  .byte $5D,$28,$29,$2A,$2B,$01,$01,$38,$39,$3A,$3B,$01,$01,$5B,$2A,$2B; $B7D5: 5D 28 29 2A 2B 01 01 38 39 3A 3B 01 01 5B 2A 2B
  .byte $2C,$2D,$01,$01,$3A,$3B,$3C,$3D,$01,$01,$5D,$2E,$2F,$30,$31,$01; $B7E5: 2C 2D 01 01 3A 3B 3C 3D 01 01 5D 2E 2F 30 31 01
  .byte $01,$3E,$3F,$32,$33,$01,$01,$5E,$24,$25,$26,$27,$01,$01,$34,$35; $B7F5: 01 3E 3F 32 33 01 01 5E 24 25 26 27 01 01 34 35
  .byte $36,$37,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B805: 36 37 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B815: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B825: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B835: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$80; $B845: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 80
  .byte $81,$01,$84,$85,$01,$82,$83,$01,$88,$89,$01,$01,$8A,$8B,$01,$01; $B855: 81 01 84 85 01 82 83 01 88 89 01 01 8A 8B 01 01
  .byte $A6,$A7,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$90; $B865: A6 A7 01 01 01 01 01 01 01 01 01 01 01 01 01 90
  .byte $91,$01,$94,$95,$01,$92,$93,$01,$98,$99,$01,$01,$9A,$9B,$01,$01; $B875: 91 01 94 95 01 92 93 01 98 99 01 01 9A 9B 01 01
  .byte $A8,$A9,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B885: A8 A9 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B895: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$48,$6F,$6B,$01,$01,$01,$01,$01,$01; $B8A5: 01 01 01 01 01 01 01 48 6F 6B 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B8B5: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B8C5: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B8D5: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B8E5: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B8F5: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$80; $B905: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 80
  .byte $81,$01,$84,$85,$01,$82,$83,$01,$88,$89,$01,$86,$87,$01,$01,$8A; $B915: 81 01 84 85 01 82 83 01 88 89 01 86 87 01 01 8A
  .byte $8B,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$90; $B925: 8B 01 01 01 01 01 01 01 01 01 01 01 01 01 01 90
  .byte $91,$01,$94,$95,$01,$92,$93,$01,$98,$99,$01,$96,$97,$01,$01,$9A; $B935: 91 01 94 95 01 92 93 01 98 99 01 96 97 01 01 9A
  .byte $9B,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B945: 9B 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B955: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$48,$6F,$6B,$01,$01,$01,$01,$01,$01; $B965: 01 01 01 01 01 01 01 48 6F 6B 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B975: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01                   ; $B985: 01 01 01 01

.endproc

.proc OfficerListHandler
OfficerListHandler:
  LDA $0140                               ; $B989: AD 40 01
  BNE @officer_exit                            ; $B98C: D0 40
  LDA $007E                               ; $B98E: AD 7E 00
  AND #$02                                ; $B991: 29 02
  BNE @officer_exit                            ; $B993: D0 39
  LDA $0478                               ; $B995: AD 78 04
  BEQ @officer_exit                            ; $B998: F0 34
  BPL @check_sub_state                            ; $B99A: 10 03
  JMP ProcessOfficerListScroll            ; $B99C: 4C 0E BA
@check_sub_state:
  CMP #$10                                ; $B99F: C9 10
  BEQ InitOfficerListState                ; $B9A1: F0 2C
  CMP #$02                                ; $B9A3: C9 02
  BCC @goto_scroll                            ; $B9A5: 90 24
  CMP #$0C                                ; $B9A7: C9 0C
  BCS @goto_scroll                            ; $B9A9: B0 20
  LDY $047A                               ; $B9AB: AC 7A 04
  INC $047A                               ; $B9AE: EE 7A 04
  LDA $0151,Y                             ; $B9B1: B9 51 01
  CMP #$FF                                ; $B9B4: C9 FF
  BEQ @goto_scroll                            ; $B9B6: F0 13
  TAX                                     ; $B9B8: AA
  JSR B1F_GetOfficerRecordAddr            ; $B9B9: 20 D7 F2
  LDA $0000                               ; $B9BC: AD 00 00
  STA $001C                               ; $B9BF: 8D 1C 00
  LDA $0001                               ; $B9C2: AD 01 00
  STA $001D                               ; $B9C5: 8D 1D 00
  JMP DrawOfficerRecord                   ; $B9C8: 4C 28 BB
@goto_scroll:
  JMP @list_dispatch                            ; $B9CB: 4C 9D BA
@officer_exit:
  RTS                                     ; $B9CE: 60
InitOfficerListState:
  LDA #$00                                ; $B9CF: A9 00
  STA $0478                               ; $B9D1: 8D 78 04
  STA $047A                               ; $B9D4: 8D 7A 04
  STA $0480                               ; $B9D7: 8D 80 04
  STA $0424                               ; $B9DA: 8D 24 04
  STA $0425                               ; $B9DD: 8D 25 04
  LDA $047C                               ; $B9E0: AD 7C 04
  CMP #$0F                                ; $B9E3: C9 0F
  BNE @scroll_update                            ; $B9E5: D0 03
  DEC $047B                               ; $B9E7: CE 7B 04
@scroll_update:
  LDA #$06                                ; $B9EA: A9 06
  STA $0061                               ; $B9EC: 8D 61 00
  LDA #$08                                ; $B9EF: A9 08
  STA $00B2                               ; $B9F1: 8D B2 00
  LDA #$09                                ; $B9F4: A9 09
  STA $00B3                               ; $B9F6: 8D B3 00
  LDA #$06                                ; $B9F9: A9 06
  STA $00B4                               ; $B9FB: 8D B4 00
  LDY #$01                                ; $B9FE: A0 01
  STY $008F                               ; $BA00: 8C 8F 00
  LDA #$FF                                ; $BA03: A9 FF
@fill_ff_loop:
  STA $0480,Y                             ; $BA05: 99 80 04
  INY                                     ; $BA08: C8
  CPY #$0B                                ; $BA09: C0 0B
  BCC @fill_ff_loop                            ; $BA0B: 90 F8
  RTS                                     ; $BA0D: 60
ProcessOfficerListScroll:
  LDA $0478                               ; $BA0E: AD 78 04
  AND #$0F                                ; $BA11: 29 0F
  STA $0479                               ; $BA13: 8D 79 04
  LDA #$00                                ; $BA16: A9 00
  STA $0478                               ; $BA18: 8D 78 04
  STA $047A                               ; $BA1B: 8D 7A 04
  STA $047B                               ; $BA1E: 8D 7B 04
  STA $0486                               ; $BA21: 8D 86 04
  LDA #$C0                                ; $BA24: A9 C0
  STA $0480                               ; $BA26: 8D 80 04
  LDA #$23                                ; $BA29: A9 23
  STA $0481                               ; $BA2B: 8D 81 04
  LDY #$30                                ; $BA2E: A0 30
  JSR B1F_SwitchBank8_B                   ; $BA30: 20 5F F2
  LDA $047C                               ; $BA33: AD 7C 04
  CMP #$FF                                ; $BA36: C9 FF
  BNE @check_selection                            ; $BA38: D0 19
  AND #$0F                                ; $BA3A: 29 0F
  STA $047C                               ; $BA3C: 8D 7C 04
  LDY #$00                                ; $BA3F: A0 00
@count_officers:
  LDA $0151,Y                             ; $BA41: B9 51 01
  CMP #$FF                                ; $BA44: C9 FF
  BEQ @count_next                            ; $BA46: F0 03
  INC $047B                               ; $BA48: EE 7B 04
@count_next:
  INY                                     ; $BA4B: C8
  CPY #$0A                                ; $BA4C: C0 0A
  BCC @count_officers                            ; $BA4E: 90 F1
  JMP @update_display                            ; $BA50: 4C 7E BA
@check_selection:
  LDA $0402                               ; $BA53: AD 02 04
  LDY $0479                               ; $BA56: AC 79 04
  CPY #$02                                ; $BA59: C0 02
  BNE @load_province                            ; $BA5B: D0 08
  LDA #$00                                ; $BA5D: A9 00
  STA $0479                               ; $BA5F: 8D 79 04
  LDA $040C                               ; $BA62: AD 0C 04
@load_province:
  JSR B1F_GetProvinceRecordAddr           ; $BA65: 20 AF F2
  LDY #$11                                ; $BA68: A0 11
  LDX #$00                                ; $BA6A: A2 00
@copy_province:
  LDA ($00),Y                             ; $BA6C: B1 00
  STA $0151,X                             ; $BA6E: 9D 51 01
  CMP #$FF                                ; $BA71: C9 FF
  BEQ @copy_prov_next                            ; $BA73: F0 03
  INC $047B                               ; $BA75: EE 7B 04
@copy_prov_next:
  INX                                     ; $BA78: E8
  INY                                     ; $BA79: C8
  CPX #$0A                                ; $BA7A: E0 0A
  BCC @copy_province                            ; $BA7C: 90 EE
@update_display:
  LDA $0479                               ; $BA7E: AD 79 04
  BEQ @no_selection                            ; $BA81: F0 0D
  LDA #$09                                ; $BA83: A9 09
  STA $0482                               ; $BA85: 8D 82 04
  LDA #$B8                                ; $BA88: A9 B8
  STA $0483                               ; $BA8A: 8D 83 04
  JMP @list_dispatch                            ; $BA8D: 4C 9D BA
@no_selection:
  LDA #$C9                                ; $BA90: A9 C9
  STA $0482                               ; $BA92: 8D 82 04
  LDA #$B8                                ; $BA95: A9 B8
  STA $0483                               ; $BA97: 8D 83 04
  JMP @list_dispatch                            ; $BA9A: 4C 9D BA
@list_dispatch:
  LDA $0478                               ; $BA9D: AD 78 04
  CMP #$0F                                ; $BAA0: C9 0F
  BEQ @fill_aa                            ; $BAA2: F0 5F
  CMP #$02                                ; $BAA4: C9 02
  BCC @copy_tile_data                            ; $BAA6: 90 0F
  LDA $0486                               ; $BAA8: AD 86 04
  BNE @fill_ones                            ; $BAAB: D0 36
  INC $0486                               ; $BAAD: EE 86 04
  LDA $047C                               ; $BAB0: AD 7C 04
  CMP #$0F                                ; $BAB3: C9 0F
  BEQ @fill_ones                            ; $BAB5: F0 2C
@copy_tile_data:
  LDA $0482                               ; $BAB7: AD 82 04
  STA $001A                               ; $BABA: 8D 1A 00
  LDA $0483                               ; $BABD: AD 83 04
  STA $001B                               ; $BAC0: 8D 1B 00
  LDY #$00                                ; $BAC3: A0 00
@copy_64bytes:
  LDA ($1A),Y                             ; $BAC5: B1 1A
  STA $0160,Y                             ; $BAC7: 99 60 01
  INY                                     ; $BACA: C8
  CPY #$40                                ; $BACB: C0 40
  BCC @copy_64bytes                            ; $BACD: 90 F6
  LDA $0482                               ; $BACF: AD 82 04
  CLC                                     ; $BAD2: 18
  ADC #$40                                ; $BAD3: 69 40
  STA $0482                               ; $BAD5: 8D 82 04
  LDA $0483                               ; $BAD8: AD 83 04
  ADC #$00                                ; $BADB: 69 00
  STA $0483                               ; $BADD: 8D 83 04
  JMP @advance_list                            ; $BAE0: 4C EF BA
@fill_ones:
  LDA #$01                                ; $BAE3: A9 01
  LDY #$00                                ; $BAE5: A0 00
@fill_loop:
  STA $0160,Y                             ; $BAE7: 99 60 01
  INY                                     ; $BAEA: C8
  CPY #$40                                ; $BAEB: C0 40
  BCC @fill_loop                            ; $BAED: 90 F8
@advance_list:
  LDA $0480                               ; $BAEF: AD 80 04
  CLC                                     ; $BAF2: 18
  ADC #$40                                ; $BAF3: 69 40
  STA $0480                               ; $BAF5: 8D 80 04
  LDA $0481                               ; $BAF8: AD 81 04
  ADC #$00                                ; $BAFB: 69 00
  STA $0481                               ; $BAFD: 8D 81 04
  JMP @finish_list                            ; $BB00: 4C 1C BB
@fill_aa:
  LDY #$00                                ; $BB03: A0 00
  LDA #$AA                                ; $BB05: A9 AA
@fill_aa_loop:
  STA $0160,Y                             ; $BB07: 99 60 01
  INY                                     ; $BB0A: C8
  CPY #$40                                ; $BB0B: C0 40
  BCC @fill_aa_loop                            ; $BB0D: 90 F8
  LDA #$C0                                ; $BB0F: A9 C0
  STA $0480                               ; $BB11: 8D 80 04
  LDA #$27                                ; $BB14: A9 27
  STA $0481                               ; $BB16: 8D 81 04
  JMP @finish_list                            ; $BB19: 4C 1C BB
@finish_list:
  INC $0478                               ; $BB1C: EE 78 04
  LDA $007E                               ; $BB1F: AD 7E 00
  ORA #$02                                ; $BB22: 09 02
  STA $007E                               ; $BB24: 8D 7E 00
  RTS                                     ; $BB27: 60
DrawOfficerRecord:
  LDA #$01                                ; $BB28: A9 01
  LDY #$00                                ; $BB2A: A0 00
@fill_value_loop:
  STA $0160,Y                             ; $BB2C: 99 60 01
  INY                                     ; $BB2F: C8
  CPY #$40                                ; $BB30: C0 40
  BCC @fill_value_loop                            ; $BB32: 90 F8
  TXA                                     ; $BB34: 8A
  JSR B1F_GetNameDisplayScale             ; $BB35: 20 08 F3
  LDY #$00                                ; $BB38: A0 00
  LDX #$00                                ; $BB3A: A2 00
@format_officer:
  LDA ($00),Y                             ; $BB3C: B1 00
  BEQ @officer_setup                            ; $BB3E: F0 17
  CMP #$39                                ; $BB40: C9 39
  BEQ @officer_adjust                            ; $BB42: F0 0A
  CMP #$3A                                ; $BB44: C9 3A
  BEQ @officer_adjust                            ; $BB46: F0 06
  STA $0183,X                             ; $BB48: 9D 83 01
  JMP @officer_next                            ; $BB4B: 4C 52 BB
@officer_adjust:
  DEX                                     ; $BB4E: CA
  STA $0163,X                             ; $BB4F: 9D 63 01
@officer_next:
  INX                                     ; $BB52: E8
  INY                                     ; $BB53: C8
  JMP @format_officer                            ; $BB54: 4C 3C BB
@officer_setup:
  LDA #$76                                ; $BB57: A9 76
  STA $0017                               ; $BB59: 8D 17 00
  LDA #$02                                ; $BB5C: A9 02
  STA $0013                               ; $BB5E: 8D 13 00
  LDA #$2B                                ; $BB61: A9 2B
  STA $0014                               ; $BB63: 8D 14 00
  LDY #$00                                ; $BB66: A0 00
@init_officer_ptr:
  LDA #$00                                ; $BB68: A9 00
  STA $0002                               ; $BB6A: 8D 02 00
  STA $0003                               ; $BB6D: 8D 03 00
  LDA ($1C),Y                             ; $BB70: B1 1C
  STA $0001                               ; $BB72: 8D 01 00
  CMP #$64                                ; $BB75: C9 64
  BNE @format_and_draw                            ; $BB77: D0 07
  CPY #$03                                ; $BB79: C0 03
  BNE @format_and_draw                            ; $BB7B: D0 03
  JMP @write_terminator                            ; $BB7D: 4C 32 BC
@format_and_draw:
  JSR B1F_MathBinToBcd                    ; $BB80: 20 BA E9
  LDX $0014                               ; $BB83: AE 14 00
  JSR @format_digits                            ; $BB86: 20 40 B0
@advance_offset:
  LDA $0014                               ; $BB89: AD 14 00
  CLC                                     ; $BB8C: 18
  ADC #$03                                ; $BB8D: 69 03
  STA $0014                               ; $BB8F: 8D 14 00
  INY                                     ; $BB92: C8
  CPY #$04                                ; $BB93: C0 04
  BCC @init_officer_ptr                            ; $BB95: 90 D1
  LDA $0479                               ; $BB97: AD 79 04
  BNE @load_extra                            ; $BB9A: D0 17
  LDA #$00                                ; $BB9C: A9 00
  STA $0002                               ; $BB9E: 8D 02 00
  STA $0003                               ; $BBA1: 8D 03 00
  LDY #$04                                ; $BBA4: A0 04
  LDA ($1C),Y                             ; $BBA6: B1 1C
  STA $0001                               ; $BBA8: 8D 01 00
  JSR B1F_MathBinToBcd                    ; $BBAB: 20 BA E9
  LDX #$37                                ; $BBAE: A2 37
  JSR @format_digits                            ; $BBB0: 20 40 B0
@load_extra:
  LDY #$06                                ; $BBB3: A0 06
  LDA ($1C),Y                             ; $BBB5: B1 1C
  STA $0001                               ; $BBB7: 8D 01 00
  INY                                     ; $BBBA: C8
  LDA ($1C),Y                             ; $BBBB: B1 1C
  STA $0002                               ; $BBBD: 8D 02 00
  LDA #$00                                ; $BBC0: A9 00
  STA $0003                               ; $BBC2: 8D 03 00
  ASL $0001                               ; $BBC5: 0E 01 00
  ROL $0002                               ; $BBC8: 2E 02 00
  ROL $0003                               ; $BBCB: 2E 03 00
  JSR B1F_MathBinToBcd                    ; $BBCE: 20 BA E9
  LDA $0008                               ; $BBD1: AD 08 00
  STA $0007                               ; $BBD4: 8D 07 00
  LDA $0009                               ; $BBD7: AD 09 00
  STA $0008                               ; $BBDA: 8D 08 00
  LDA #$03                                ; $BBDD: A9 03
  STA $0013                               ; $BBDF: 8D 13 00
  LDX #$37                                ; $BBE2: A2 37
  LDA $0479                               ; $BBE4: AD 79 04
  BNE @format_extra                            ; $BBE7: D0 08
  LDX #$3A                                ; $BBE9: A2 3A
  JSR @format_digits                            ; $BBEB: 20 40 B0
  JMP @advance_list2                            ; $BBEE: 4C 15 BC
@format_extra:
  JSR @format_digits                            ; $BBF1: 20 40 B0
  LDY #$08                                ; $BBF4: A0 08
  LDA ($1C),Y                             ; $BBF6: B1 1C
  STA $0001                               ; $BBF8: 8D 01 00
  INY                                     ; $BBFB: C8
  LDA ($1C),Y                             ; $BBFC: B1 1C
  AND #$03                                ; $BBFE: 29 03
  STA $0002                               ; $BC00: 8D 02 00
  LDA #$00                                ; $BC03: A9 00
  STA $0003                               ; $BC05: 8D 03 00
  JSR B1F_MathBinToBcd                    ; $BC08: 20 BA E9
  LDA #$04                                ; $BC0B: A9 04
  STA $0013                               ; $BC0D: 8D 13 00
  LDX #$3B                                ; $BC10: A2 3B
  JSR @format_digits                            ; $BC12: 20 40 B0
@advance_list2:
  LDA $0480                               ; $BC15: AD 80 04
  CLC                                     ; $BC18: 18
  ADC #$40                                ; $BC19: 69 40
  STA $0480                               ; $BC1B: 8D 80 04
  LDA $0481                               ; $BC1E: AD 81 04
  ADC #$00                                ; $BC21: 69 00
  STA $0481                               ; $BC23: 8D 81 04
  INC $0478                               ; $BC26: EE 78 04
  LDA $007E                               ; $BC29: AD 7E 00
  ORA #$02                                ; $BC2C: 09 02
  STA $007E                               ; $BC2E: 8D 7E 00
  RTS                                     ; $BC31: 60
@write_terminator:
  LDX $0014                               ; $BC32: AE 14 00
  LDA #$32                                ; $BC35: A9 32
  STA $0160,X                             ; $BC37: 9D 60 01
  INX                                     ; $BC3A: E8
  STA $0160,X                             ; $BC3B: 9D 60 01
  JMP @advance_offset                            ; $BC3E: 4C 89 BB

.endproc

.proc Unknown
Unknown:
  LDA $008B                               ; $BC41: AD 8B 00
  AND #$FB                                ; $BC44: 29 FB
  STA $2000                               ; $BC46: 8D 00 20
  LDA $2002                               ; $BC49: AD 02 20
  LDA $0481                               ; $BC4C: AD 81 04
  STA $2006                               ; $BC4F: 8D 06 20
  LDA $0480                               ; $BC52: AD 80 04
  STA $2006                               ; $BC55: 8D 06 20
  LDY #$00                                ; $BC58: A0 00
@vram_fill_loop:
  LDA $0160,Y                             ; $BC5A: B9 60 01
  STA $2007                               ; $BC5D: 8D 07 20
  INY                                     ; $BC60: C8
  CPY #$40                                ; $BC61: C0 40
  BCC @vram_fill_loop                            ; $BC63: 90 F5
  RTS                                     ; $BC65: 60

.endproc

.proc SmallRoutineA
SmallRoutineA:
  LDY #$3F                                ; $BC66: A0 3F
  LDA #$00                                ; $BC68: A9 00
@clear_0140_loop:
  STA $0140,Y                             ; $BC6A: 99 40 01
  DEY                                     ; $BC6D: 88
  BPL @clear_0140_loop                            ; $BC6E: 10 FA
  RTS                                     ; $BC70: 60

.endproc

.proc SmallRoutineB
SmallRoutineB:
  LDA $0401                               ; $BC71: AD 01 04
  JSR B1F_CallbackDispatcher              ; $BC74: 20 DE EA
  .byte $83                               ; $BC77: 83
  LDY $BC9B,X                             ; $BC78: BC 9B BC
  .byte $03                               ; $BC7B: 03
  LDA $BD38,X                             ; $BC7C: BD 38 BD
  RTS                                     ; $BC7F: 60
  LDA $BD92,X                             ; $BC80: BD 92 BD
  LDA #$00                                ; $BC83: A9 00
  STA $0470                               ; $BC85: 8D 70 04
  LDA #$88                                ; $BC88: A9 88
  STA $0471                               ; $BC8A: 8D 71 04
  LDA #$00                                ; $BC8D: A9 00
  STA $0472                               ; $BC8F: 8D 72 04
  LDA #$24                                ; $BC92: A9 24
  STA $0473                               ; $BC94: 8D 73 04
  INC $0401                               ; $BC97: EE 01 04
  RTS                                     ; $BC9A: 60
  LDY #$30                                ; $BC9B: A0 30
  JSR B1F_SwitchBank8_B                   ; $BC9D: 20 5F F2
  LDA #$40                                ; $BCA0: A9 40
  STA $0380                               ; $BCA2: 8D 80 03
  LDA $0473                               ; $BCA5: AD 73 04
  STA $0381                               ; $BCA8: 8D 81 03
  LDA $0472                               ; $BCAB: AD 72 04
  STA $0382                               ; $BCAE: 8D 82 03
  LDA $0470                               ; $BCB1: AD 70 04
  STA $0000                               ; $BCB4: 8D 00 00
  LDA $0471                               ; $BCB7: AD 71 04
  STA $0001                               ; $BCBA: 8D 01 00
  LDY #$00                                ; $BCBD: A0 00
@copy_page_loop:
  LDA ($00),Y                             ; $BCBF: B1 00
  STA $0383,Y                             ; $BCC1: 99 83 03
  INY                                     ; $BCC4: C8
  CPY #$40                                ; $BCC5: C0 40
  BCC @copy_page_loop                            ; $BCC7: 90 F6
  LDA #$FF                                ; $BCC9: A9 FF
  STA $0383,Y                             ; $BCCB: 99 83 03
  LDA $0470                               ; $BCCE: AD 70 04
  CLC                                     ; $BCD1: 18
  ADC #$40                                ; $BCD2: 69 40
  STA $0470                               ; $BCD4: 8D 70 04
  LDA $0471                               ; $BCD7: AD 71 04
  ADC #$00                                ; $BCDA: 69 00
  STA $0471                               ; $BCDC: 8D 71 04
  LDA $0472                               ; $BCDF: AD 72 04
  CLC                                     ; $BCE2: 18
  ADC #$40                                ; $BCE3: 69 40
  STA $0472                               ; $BCE5: 8D 72 04
  LDA $0473                               ; $BCE8: AD 73 04
  ADC #$00                                ; $BCEB: 69 00
  STA $0473                               ; $BCED: 8D 73 04
  CMP #$28                                ; $BCF0: C9 28
  BNE @set_flag_exit                            ; $BCF2: D0 06
  INC $0401                               ; $BCF4: EE 01 04
  JSR B1F_PaletteCopyBuffer                  ; $BCF7: 20 EE EC
@set_flag_exit:
  LDA $007E                               ; $BCFA: AD 7E 00
  ORA #$04                                ; $BCFD: 09 04
  STA $007E                               ; $BCFF: 8D 7E 00
  RTS                                     ; $BD02: 60
  LDA $0087                               ; $BD03: AD 87 00
  BPL @render_exit1                            ; $BD06: 10 2F
  LDA #$0A                                ; $BD08: A9 0A
  STA $00B3                               ; $BD0A: 8D B3 00
  LDA #$0B                                ; $BD0D: A9 0B
  STA $00C3                               ; $BD0F: 8D C3 00
  LDA #$0E                                ; $BD12: A9 0E
  STA $00CB                               ; $BD14: 8D CB 00
  LDA #$14                                ; $BD17: A9 14
  STA $00D3                               ; $BD19: 8D D3 00
  LDA #$15                                ; $BD1C: A9 15
  STA $00DB                               ; $BD1E: 8D DB 00
  LDA #$E1                                ; $BD21: A9 E1
  STA $00E6                               ; $BD23: 8D E6 00
  LDA #$00                                ; $BD26: A9 00
  STA $0000                               ; $BD28: 8D 00 00
  JSR $DBB1                               ; $BD2B: 20 B1 DB
  INC $0401                               ; $BD2E: EE 01 04
  JSR @init_timer                            ; $BD31: 20 FE BD
  JMP B1F_PaletteFadeInit                   ; $BD34: 4C BF EC
@render_exit1:
  RTS                                     ; $BD37: 60
  LDA #$F0                                ; $BD38: A9 F0
  STA $0200                               ; $BD3A: 8D 00 02
  STA $0204                               ; $BD3D: 8D 04 02
  LDA $0087                               ; $BD40: AD 87 00
  BPL @render_exit2                            ; $BD43: 10 1A
  LDA $0081                               ; $BD45: AD 81 00
  ORA $0082                               ; $BD48: 0D 82 00
  AND #$04                                ; $BD4B: 29 04
  BEQ @render_exit2                            ; $BD4D: F0 10
  LDA $0083                               ; $BD4F: AD 83 00
  CMP #$1C                                ; $BD52: C9 1C
  BNE @inc_and_jmp                            ; $BD54: D0 03
  JSR @check_game_state                            ; $BD56: 20 F1 BD
@inc_and_jmp:
  INC $0401                               ; $BD59: EE 01 04
  JMP B1F_PaletteCopyBuffer                 ; $BD5C: 4C EE EC
@render_exit2:
  RTS                                     ; $BD5F: 60
  LDA #$F0                                ; $BD60: A9 F0
  STA $0200                               ; $BD62: 8D 00 02
  STA $0204                               ; $BD65: 8D 04 02
  LDA $0087                               ; $BD68: AD 87 00
  BPL @render_exit3                            ; $BD6B: 10 24
  LDA #$01                                ; $BD6D: A9 01
  STA $00B3                               ; $BD6F: 8D B3 00
  STA $00C3                               ; $BD72: 8D C3 00
  STA $00CB                               ; $BD75: 8D CB 00
  STA $00D3                               ; $BD78: 8D D3 00
  STA $00DB                               ; $BD7B: 8D DB 00
  LDA #$E0                                ; $BD7E: A9 E0
  STA $00E6                               ; $BD80: 8D E6 00
  LDA #$00                                ; $BD83: A9 00
  STA $0000                               ; $BD85: 8D 00 00
  JSR $DBB1                               ; $BD88: 20 B1 DB
  INC $0401                               ; $BD8B: EE 01 04
  JMP B1F_PaletteFadeInit                   ; $BD8E: 4C BF EC
@render_exit3:
  RTS                                     ; $BD91: 60
  LDA $0087                               ; $BD92: AD 87 00
  BPL @sub_exit                            ; $BD95: 10 59
  LDA #$40                                ; $BD97: A9 40
  STA $0380                               ; $BD99: 8D 80 03
  LDA #$27                                ; $BD9C: A9 27
  STA $0381                               ; $BD9E: 8D 81 03
  LDA #$C0                                ; $BDA1: A9 C0
  STA $0382                               ; $BDA3: 8D 82 03
  LDY #$39                                ; $BDA6: A0 39
  LDA #$AA                                ; $BDA8: A9 AA
@fill_aa_page:
  STA $0383,Y                             ; $BDAA: 99 83 03
  DEY                                     ; $BDAD: 88
  BPL @fill_aa_page                            ; $BDAE: 10 FA
  LDA #$FF                                ; $BDB0: A9 FF
  STA $03C3                               ; $BDB2: 8D C3 03
  LDA $007E                               ; $BDB5: AD 7E 00
  ORA #$04                                ; $BDB8: 09 04
  STA $007E                               ; $BDBA: 8D 7E 00
  LDA #$40                                ; $BDBD: A9 40
  STA $0068                               ; $BDBF: 8D 68 00
  LDA #$14                                ; $BDC2: A9 14
  STA $006A                               ; $BDC4: 8D 6A 00
  LDA #$1E                                ; $BDC7: A9 1E
  STA $006C                               ; $BDC9: 8D 6C 00
  LDA #$20                                ; $BDCC: A9 20
  STA $006E                               ; $BDCE: 8D 6E 00
  LDA #$F2                                ; $BDD1: A9 F2
  STA $006F                               ; $BDD3: 8D 6F 00
  LDA #$0D                                ; $BDD6: A9 0D
  STA $0070                               ; $BDD8: 8D 70 00
  LDA #$F2                                ; $BDDB: A9 F2
  STA $0071                               ; $BDDD: 8D 71 00
  LDA #$00                                ; $BDE0: A9 00
  STA $0400                               ; $BDE2: 8D 00 04
  STA $0401                               ; $BDE5: 8D 01 04
  LDY #$03                                ; $BDE8: A0 03
@fill_0470:
  STA $0470,Y                             ; $BDEA: 99 70 04
  DEY                                     ; $BDED: 88
  BPL @fill_0470                            ; $BDEE: 10 FA
@sub_exit:
  RTS                                     ; $BDF0: 60
@check_game_state:
  LDA $6F05                               ; $BDF1: AD 05 6F
  CMP #$02                                ; $BDF4: C9 02
  BCC @state_rts2                            ; $BDF6: 90 05
  LDA #$01                                ; $BDF8: A9 01
  STA $6F05                               ; $BDFA: 8D 05 6F
@state_rts2:
  RTS                                     ; $BDFD: 60
@init_timer:
  LDA #$03                                ; $BDFE: A9 03
  STA $0061                               ; $BE00: 8D 61 00
  LDA #$28                                ; $BE03: A9 28
  STA $0068                               ; $BE05: 8D 68 00
  LDA #$E9                                ; $BE08: A9 E9
  STA $0069                               ; $BE0A: 8D 69 00
  LDA #$20                                ; $BE0D: A9 20
  STA $006A                               ; $BE0F: 8D 6A 00
  LDA #$F2                                ; $BE12: A9 F2
  STA $006B                               ; $BE14: 8D 6B 00
  LDA #$20                                ; $BE17: A9 20
  STA $006C                               ; $BE19: 8D 6C 00
  LDA #$F2                                ; $BE1C: A9 F2
  STA $006D                               ; $BE1E: 8D 6D 00
  LDA #$20                                ; $BE21: A9 20
  STA $006E                               ; $BE23: 8D 6E 00
  LDA #$F2                                ; $BE26: A9 F2
  STA $006F                               ; $BE28: 8D 6F 00
  LDA #$F0                                ; $BE2B: A9 F0
  STA $0070                               ; $BE2D: 8D 70 00
  LDA #$F1                                ; $BE30: A9 F1
  STA $0071                               ; $BE32: 8D 71 00
  RTS                                     ; $BE35: 60

.endproc

.proc MenuRenderer
MenuRenderer:
  LDA $04A0                               ; $BE36: AD A0 04
  BNE @menu_dispatch                            ; $BE39: D0 01
  RTS                                     ; $BE3B: 60
@menu_dispatch:
  BMI @check_low                            ; $BE3C: 30 1F
  STA $04A2                               ; $BE3E: 8D A2 04
  DEC $04A2                               ; $BE41: CE A2 04
  LDA #$00                                ; $BE44: A9 00
  STA $04A1                               ; $BE46: 8D A1 04
  LDX #$40                                ; $BE49: A2 40
  LDA $0150                               ; $BE4B: AD 50 01
  BMI @setup_menu                            ; $BE4E: 30 02
  LDX #$80                                ; $BE50: A2 80
@setup_menu:
  STX $0420                               ; $BE52: 8E 20 04
  LDA #$80                                ; $BE55: A9 80
  STA $04A0                               ; $BE57: 8D A0 04
  JMP $C9C2                               ; $BE5A: 4C C2 C9
@check_low:
  AND #$0F                                ; $BE5D: 29 0F
  BNE @render_menu                            ; $BE5F: D0 03
  JMP $C9C2                               ; $BE61: 4C C2 C9
@render_menu:
  INC $04A3                               ; $BE64: EE A3 04
  INC $04D0                               ; $BE67: EE D0 04
  LDY #$36                                ; $BE6A: A0 36
  JSR B1F_SwitchBank8_B                   ; $BE6C: 20 5F F2
  LDA $04A2                               ; $BE6F: AD A2 04
  JSR B1F_CallbackDispatcher              ; $BE72: 20 DE EA
  .byte $BB                               ; $BE75: BB
  LDX $BEEB,Y                             ; $BE76: BE EB BE
  .byte $2F                               ; $BE79: 2F
  .byte $BF                               ; $BE7A: BF
@data_bytes2:
  BVS @menu_dispatch                            ; $BE7B: 70 BF
  .byte $BF                               ; $BE7D: BF
  .byte $BF                               ; $BE7E: BF
  .byte $F3                               ; $BE7F: F3
  .byte $BF                               ; $BE80: BF
  LSR $C0                                 ; $BE81: 46 C0
  .byte $90, $C0 ; $BE83: 90 C0
  INY                                     ; $BE85: C8
  CPY #$23                                ; $BE86: C0 23
  CMP ($68,X)                             ; $BE88: C1 68
  CMP ($AC,X)                             ; $BE8A: C1 AC
  CMP ($FA,X)                             ; $BE8C: C1 FA
  CMP ($5D,X)                             ; $BE8E: C1 5D
  .byte $C2                               ; $BE90: C2
  CMP $3DC2,X                             ; $BE91: DD C2 3D
  .byte $C3                               ; $BE94: C3
  LDX #$C3                                ; $BE95: A2 C3
  INC $C3,X                               ; $BE97: F6 C3
  ROL $E1C4,X                             ; $BE99: 3E C4 E1
  CPY $11                                 ; $BE9C: C4 11
  CMP $56                                 ; $BE9E: C5 56
  CMP $B1                                 ; $BEA0: C5 B1
  CMP $F7                                 ; $BEA2: C5 F7
  CMP $36                                 ; $BEA4: C5 36
  DEC $7D                                 ; $BEA6: C6 7D
  DEC $C6                                 ; $BEA8: C6 C6
  DEC $5F                                 ; $BEAA: C6 5F
  .byte $C7                               ; $BEAC: C7
  CMP ($C7),Y                             ; $BEAD: D1 C7
  BRK                                     ; $BEAF: 00
  INY                                     ; $BEB0: C8
  BMI @data_bytes2                            ; $BEB1: 30 C8
  ADC $B4C8,X                             ; $BEB3: 7D C8 B4
  INY                                     ; $BEB6: C8
  SBC ($C8),Y                             ; $BEB7: F1 C8
  ROL $C9                                 ; $BEB9: 26 C9
  LDA $04A1                               ; $BEBB: AD A1 04
  BNE @load_row0                            ; $BEBE: D0 09
  LDA #$E8                                ; $BEC0: A9 E8
  JSR SetupDisplayPtrs                    ; $BEC2: 20 6D C9
  INC $04A1                               ; $BEC5: EE A1 04
  RTS                                     ; $BEC8: 60
@load_row0:
  LDA #$00                                ; $BEC9: A9 00
  STA $0010                               ; $BECB: 8D 10 00
  LDA #$80                                ; $BECE: A9 80
  STA $0011                               ; $BED0: 8D 11 00
  LDY $04A1                               ; $BED3: AC A1 04
  JSR DisplayTileData                     ; $BED6: 20 94 C9
  LDA $04A3                               ; $BED9: AD A3 04
  AND #$04                                ; $BEDC: 29 04
  BEQ @set_row                            ; $BEDE: F0 02
  LDA #$01                                ; $BEE0: A9 01
@set_row:
  STA $04A1                               ; $BEE2: 8D A1 04
  INC $04A1                               ; $BEE5: EE A1 04
  JMP CommonReturn                        ; $BEE8: 4C 34 C9
  LDA $04A1                               ; $BEEB: AD A1 04
  BNE @load_row1                            ; $BEEE: D0 0E
  LDA #$DC                                ; $BEF0: A9 DC
  JSR SetupDisplayPtrs                    ; $BEF2: 20 6D C9
  LDA #$DF                                ; $BEF5: A9 DF
  JSR ResetDispatchState                    ; $BEF7: 20 8A C9
  INC $04A1                               ; $BEFA: EE A1 04
  RTS                                     ; $BEFD: 60
@load_row1:
  LDA #$F6                                ; $BEFE: A9 F6
  STA $0010                               ; $BF00: 8D 10 00
  LDA #$80                                ; $BF03: A9 80
  STA $0011                               ; $BF05: 8D 11 00
  LDY $04A1                               ; $BF08: AC A1 04
  JSR DisplayTileData                     ; $BF0B: 20 94 C9
  LDA $04A3                               ; $BF0E: AD A3 04
  LSR A                                   ; $BF11: 4A
  LSR A                                   ; $BF12: 4A
  LSR A                                   ; $BF13: 4A
  AND #$07                                ; $BF14: 29 07
  CMP #$06                                ; $BF16: C9 06
  BNE @load_table                            ; $BF18: D0 05
  LDA #$00                                ; $BF1A: A9 00
  STA $04A3                               ; $BF1C: 8D A3 04
@load_table:
  TAY                                     ; $BF1F: A8
  LDA $BF29,Y                             ; $BF20: B9 29 BF
  STA $04A1                               ; $BF23: 8D A1 04
  JMP CommonReturn                        ; $BF26: 4C 34 C9
  ORA ($02,X)                             ; $BF29: 01 02
  .byte $03                               ; $BF2B: 03
  .byte $04                               ; $BF2C: 04
  .byte $03                               ; $BF2D: 03
  .byte $02                               ; $BF2E: 02
  LDA $04A1                               ; $BF2F: AD A1 04
  BNE @load_row2                            ; $BF32: D0 09
  LDA #$E1                                ; $BF34: A9 E1
  JSR SetupDisplayPtrs                    ; $BF36: 20 6D C9
  INC $04A1                               ; $BF39: EE A1 04
  RTS                                     ; $BF3C: 60
@load_row2:
  LDA #$72                                ; $BF3D: A9 72
  STA $0010                               ; $BF3F: 8D 10 00
  LDA #$81                                ; $BF42: A9 81
  STA $0011                               ; $BF44: 8D 11 00
  LDY #$01                                ; $BF47: A0 01
  JSR DisplayTileData                     ; $BF49: 20 94 C9
  LDA $04A3                               ; $BF4C: AD A3 04
  LSR A                                   ; $BF4F: 4A
  LSR A                                   ; $BF50: 4A
  LSR A                                   ; $BF51: 4A
  AND #$1F                                ; $BF52: 29 1F
  CMP #$15                                ; $BF54: C9 15
  BCS @menu_return                            ; $BF56: B0 15
  ASL A                                   ; $BF58: 0A
  ASL A                                   ; $BF59: 0A
  STA $0000                               ; $BF5A: 8D 00 00
  LDY #$54                                ; $BF5D: A0 54
  LDA #$F0                                ; $BF5F: A9 F0
@clear_sprites:
  STA $0200,Y                             ; $BF61: 99 00 02
  DEY                                     ; $BF64: 88
  DEY                                     ; $BF65: 88
  DEY                                     ; $BF66: 88
  DEY                                     ; $BF67: 88
  CPY $0000                               ; $BF68: CC 00 00
  BNE @clear_sprites                            ; $BF6B: D0 F4
@menu_return:
  JMP CommonReturn                        ; $BF6D: 4C 34 C9
  LDA $04A1                               ; $BF70: AD A1 04
  BNE @load_row3                            ; $BF73: D0 13
  LDA #$E9                                ; $BF75: A9 E9
  JSR SetupDisplayPtrs                    ; $BF77: 20 6D C9
  LDA #$EA                                ; $BF7A: A9 EA
  JSR ResetDispatchState                    ; $BF7C: 20 8A C9
  INC $04A1                               ; $BF7F: EE A1 04
  LDA #$03                                ; $BF82: A9 03
  STA $04A4                               ; $BF84: 8D A4 04
  RTS                                     ; $BF87: 60
@load_row3:
  LDA #$CD                                ; $BF88: A9 CD
  STA $0010                               ; $BF8A: 8D 10 00
  LDA #$81                                ; $BF8D: A9 81
  STA $0011                               ; $BF8F: 8D 11 00
  LDY $04A1                               ; $BF92: AC A1 04
  JSR DisplayTileData                     ; $BF95: 20 94 C9
  LDY $04A4                               ; $BF98: AC A4 04
  JSR DisplayTileData                     ; $BF9B: 20 94 C9
  LDA $04A3                               ; $BF9E: AD A3 04
  LSR A                                   ; $BFA1: 4A
  LSR A                                   ; $BFA2: 4A
  LSR A                                   ; $BFA3: 4A
  LSR A                                   ; $BFA4: 4A
  STA $0000                               ; $BFA5: 8D 00 00
  AND #$01                                ; $BFA8: 29 01
  CLC                                     ; $BFAA: 18
  ADC #$01                                ; $BFAB: 69 01
  STA $04A1                               ; $BFAD: 8D A1 04
  LDA $0000                               ; $BFB0: AD 00 00
  LSR A                                   ; $BFB3: 4A
  AND #$01                                ; $BFB4: 29 01
  CLC                                     ; $BFB6: 18
  ADC #$03                                ; $BFB7: 69 03
  STA $04A4                               ; $BFB9: 8D A4 04
  JMP CommonReturn                        ; $BFBC: 4C 34 C9
  LDA $04A1                               ; $BFBF: AD A1 04
  BNE @load_row4                            ; $BFC2: D0 0E
  LDA #$D1                                ; $BFC4: A9 D1
  JSR SetupDisplayPtrs                    ; $BFC6: 20 6D C9
  INC $04A1                               ; $BFC9: EE A1 04
  LDA #$80                                ; $BFCC: A9 80
  STA $04CC                               ; $BFCE: 8D CC 04
  RTS                                     ; $BFD1: 60
@load_row4:
  LDA #$39                                ; $BFD2: A9 39
  STA $0010                               ; $BFD4: 8D 10 00
  LDA #$82                                ; $BFD7: A9 82
  STA $0011                               ; $BFD9: 8D 11 00
  LDY $04A1                               ; $BFDC: AC A1 04
  JSR DisplayTileData                     ; $BFDF: 20 94 C9
  LDA $04A3                               ; $BFE2: AD A3 04
  LSR A                                   ; $BFE5: 4A
  LSR A                                   ; $BFE6: 4A
  LSR A                                   ; $BFE7: 4A
  AND #$01                                ; $BFE8: 29 01
  STA $04A1                               ; $BFEA: 8D A1 04
  INC $04A1                               ; $BFED: EE A1 04
  JMP CommonReturn                        ; $BFF0: 4C 34 C9
  LDA $04A1                               ; $BFF3: AD A1 04
  .byte $D0, $18 ; $BFF6: D0 18
  LDA #$C6                                ; $BFF8: A9 C6
  JSR SetupDisplayPtrs                    ; $BFFA: 20 6D C9
  LDA #$CF                                ; $BFFD: A9 CF
  .byte $20                               ; $BFFF: 20


.endproc

;===============================================================================
; PRG Bank $1E - $C000-$DFFF
; Domestic affairs action dispatch, tile data, SRAM save/load.
; Called from bank $1D via cross-bank JSR to $C000-$DFFF.
;===============================================================================

.segment "CODE_BANK1E"

; Forward-referenced labels defined as equates
  L_CBE4 = $CBE4
  L_CF0A = $CF0A
  L_CFD6 = $CFD6
  L_D05A = $D05A
  L_D0A7 = $D0A7
  L_D151 = $D151
  L_D17B = $D17B
  L_D1EF = $D1EF
  L_D3A4 = $D3A4
  L_D416 = $D416
  L_D488 = $D488
  L_D4A0 = $D4A0
  L_D5A7 = $D5A7
  L_D606 = $D606
  L_D6DE = $D6DE
  L_D766 = $D766
  L_D78D = $D78D
  L_D7B3 = $D7B3
  L_D86E = $D86E
  L_D976 = $D976
  L_D9AC = $D9AC
  L_D9B0 = $D9B0
  L_DA45 = $DA45
  L_DAC5 = $DAC5
  L_DD49 = $DD49
  L_DD57 = $DD57
  L_AB69 = $AB69
  L_ABFF = $ABFF
  L_BE45 = $BE45


;===============================================================================
; $C000: Bank1E_Init
;===============================================================================
  TXA                                                   ; $C000: 8A
  CMP #$EE                                              ; $C001: C9 EE
  LDA ($04,X)                                           ; $C003: A1 04
  LDA #$03                                              ; $C005: A9 03
  STA $04A4                                             ; $C007: 8D A4 04
  LDA #$80                                              ; $C00A: A9 80
  STA $04CC                                             ; $C00C: 8D CC 04
  RTS                                                   ; $C00F: 60

;===============================================================================
; $C010: Action01_DisplaySetup
;===============================================================================
  LDA #$A7                                              ; $C010: A9 A7
  STA $0010                                             ; $C012: 8D 10 00
  LDA #$82                                              ; $C015: A9 82
  STA $0011                                             ; $C017: 8D 11 00
  LDY $04A1                                             ; $C01A: AC A1 04
  JSR DisplayTileData                                   ; $C01D: 20 94 C9
  LDY $04A4                                             ; $C020: AC A4 04
  JSR DisplayTileData                                   ; $C023: 20 94 C9
  LDA $04A3                                             ; $C026: AD A3 04
  LSR                                                   ; $C029: 4A
  LSR                                                   ; $C02A: 4A
  LSR                                                   ; $C02B: 4A
  STA $0000                                             ; $C02C: 8D 00 00
  AND #$01                                              ; $C02F: 29 01
  CLC                                                   ; $C031: 18
  ADC #$01                                              ; $C032: 69 01
  STA $04A1                                             ; $C034: 8D A1 04
  LDA $0000                                             ; $C037: AD 00 00
  LSR                                                   ; $C03A: 4A
  AND #$01                                              ; $C03B: 29 01
  CLC                                                   ; $C03D: 18
  ADC #$03                                              ; $C03E: 69 03
  STA $04A4                                             ; $C040: 8D A4 04
  JMP CommonReturn                                      ; $C043: 4C 34 C9
  LDA $04A1                                             ; $C046: AD A1 04
  BNE L_C05E                                            ; $C049: D0 13
  LDA #$EA                                              ; $C04B: A9 EA
  JSR SetupDisplayPtrs                                  ; $C04D: 20 6D C9
  LDA #$EB                                              ; $C050: A9 EB
  JSR ResetDispatchState                                ; $C052: 20 8A C9
  INC $04A1                                             ; $C055: EE A1 04
  LDA #$78                                              ; $C058: A9 78
  STA $04A3                                             ; $C05A: 8D A3 04
  RTS                                                   ; $C05D: 60

;===============================================================================
L_C05E:
; $C05E: Action02_LandDevelop
;===============================================================================
  LDA #$83                                              ; $C05E: A9 83
  STA $0010                                             ; $C060: 8D 10 00
  LDA #$83                                              ; $C063: A9 83
  STA $0011                                             ; $C065: 8D 11 00
  LDY $04A1                                             ; $C068: AC A1 04
  JSR DisplayTileData                                   ; $C06B: 20 94 C9
  LDA $04A3                                             ; $C06E: AD A3 04
  LSR                                                   ; $C071: 4A
  LSR                                                   ; $C072: 4A
  LSR                                                   ; $C073: 4A
  AND #$0F                                              ; $C074: 29 0F
  TAY                                                   ; $C076: A8
  LDA $C080,Y                                           ; $C077: B9 80 C0
  STA $04A1                                             ; $C07A: 8D A1 04
  JMP CommonReturn                                      ; $C07D: 4C 34 C9
  .byte $01, $02, $03, $03, $03, $03, $03, $02, $02, $02, $02, $01, $01, $01, $01, $01 ; $C080: 01 02 03 03 03 03 03 02 02 02 02 01 01 01 01 01

;===============================================================================
; $C090: Action03_Check
;===============================================================================
  LDA $04A1                                             ; $C090: AD A1 04
  BNE L_C09E                                            ; $C093: D0 09
  LDA #$B7                                              ; $C095: A9 B7
  JSR SetupDisplayPtrs                                  ; $C097: 20 6D C9
  INC $04A1                                             ; $C09A: EE A1 04
  RTS                                                   ; $C09D: 60

;===============================================================================
L_C09E:
; $C09E: Action04_FloodControl
;===============================================================================
  LDA #$54                                              ; $C09E: A9 54
  STA $0010                                             ; $C0A0: 8D 10 00
  LDA #$84                                              ; $C0A3: A9 84
  STA $0011                                             ; $C0A5: 8D 11 00
  LDY $04A1                                             ; $C0A8: AC A1 04
  JSR DisplayTileData                                   ; $C0AB: 20 94 C9
  LDA $04A1                                             ; $C0AE: AD A1 04
  CMP #$03                                              ; $C0B1: C9 03
  BEQ L_C0C5                                            ; $C0B3: F0 10
  LDA $04A3                                             ; $C0B5: AD A3 04
  LSR                                                   ; $C0B8: 4A
  LSR                                                   ; $C0B9: 4A
  LSR                                                   ; $C0BA: 4A
  LSR                                                   ; $C0BB: 4A
  LSR                                                   ; $C0BC: 4A
  AND #$03                                              ; $C0BD: 29 03
  CLC                                                   ; $C0BF: 18
  ADC #$01                                              ; $C0C0: 69 01
  STA $04A1                                             ; $C0C2: 8D A1 04
L_C0C5:
  JMP CommonReturn                                      ; $C0C5: 4C 34 C9
  LDA $04A1                                             ; $C0C8: AD A1 04
  BNE L_C0E7                                            ; $C0CB: D0 1A
  LDA #$CA                                              ; $C0CD: A9 CA
  JSR SetupDisplayPtrs                                  ; $C0CF: 20 6D C9
  INC $04A1                                             ; $C0D2: EE A1 04
  LDA #$03                                              ; $C0D5: A9 03
  STA $04A4                                             ; $C0D7: 8D A4 04
  LDA $04D6                                             ; $C0DA: AD D6 04
  CMP #$47                                              ; $C0DD: C9 47
  BEQ L_C0E6                                            ; $C0DF: F0 05
  LDA #$80                                              ; $C0E1: A9 80
  STA $04CC                                             ; $C0E3: 8D CC 04
L_C0E6:
  RTS                                                   ; $C0E6: 60

;===============================================================================
L_C0E7:
; $C0E7: Action05_RoadBuild
;===============================================================================
  LDA #$59                                              ; $C0E7: A9 59
  STA $0010                                             ; $C0E9: 8D 10 00
  LDA #$85                                              ; $C0EC: A9 85
  STA $0011                                             ; $C0EE: 8D 11 00
  LDY $04A1                                             ; $C0F1: AC A1 04
  JSR DisplayTileData                                   ; $C0F4: 20 94 C9
  LDY $04A4                                             ; $C0F7: AC A4 04
  JSR DisplayTileData                                   ; $C0FA: 20 94 C9
  LDA $04A3                                             ; $C0FD: AD A3 04
  LSR                                                   ; $C100: 4A
  LSR                                                   ; $C101: 4A
  LSR                                                   ; $C102: 4A
  STA $0000                                             ; $C103: 8D 00 00
  LSR                                                   ; $C106: 4A
  AND #$01                                              ; $C107: 29 01
  CLC                                                   ; $C109: 18
  ADC #$01                                              ; $C10A: 69 01
  STA $04A1                                             ; $C10C: 8D A1 04
  LDA $0000                                             ; $C10F: AD 00 00
  AND #$03                                              ; $C112: 29 03
  CMP #$03                                              ; $C114: C9 03
  BNE L_C11A                                            ; $C116: D0 02
  LDA #$01                                              ; $C118: A9 01
L_C11A:
  CLC                                                   ; $C11A: 18
  ADC #$03                                              ; $C11B: 69 03
  STA $04A4                                             ; $C11D: 8D A4 04
  JMP CommonReturn                                      ; $C120: 4C 34 C9
  LDA $04A1                                             ; $C123: AD A1 04
  BNE L_C136                                            ; $C126: D0 0E
  LDA #$F1                                              ; $C128: A9 F1
  JSR SetupDisplayPtrs                                  ; $C12A: 20 6D C9
  LDA #$F2                                              ; $C12D: A9 F2
  JSR ResetDispatchState                                ; $C12F: 20 8A C9
  INC $04A1                                             ; $C132: EE A1 04
  RTS                                                   ; $C135: 60

;===============================================================================
L_C136:
; $C136: Action06_CastleRepair
;===============================================================================
  LDA #$3C                                              ; $C136: A9 3C
  STA $0010                                             ; $C138: 8D 10 00
  LDA #$86                                              ; $C13B: A9 86
  STA $0011                                             ; $C13D: 8D 11 00
  LDY $04A1                                             ; $C140: AC A1 04
  JSR DisplayTileData                                   ; $C143: 20 94 C9
  LDA $04A3                                             ; $C146: AD A3 04
  LSR                                                   ; $C149: 4A
  LSR                                                   ; $C14A: 4A
  LSR                                                   ; $C14B: 4A
  AND #$0F                                              ; $C14C: 29 0F
  TAY                                                   ; $C14E: A8
  LDA $C158,Y                                           ; $C14F: B9 58 C1
  STA $04A1                                             ; $C152: 8D A1 04
  JMP CommonReturn                                      ; $C155: 4C 34 C9
  .byte $01, $02, $03, $03, $03, $04, $04, $04, $03, $03, $03, $04, $04, $04, $02, $01 ; $C158: 01 02 03 03 03 04 04 04 03 03 03 04 04 04 02 01
  LDA $04A1                                             ; $C168: AD A1 04
  BNE L_C17B                                            ; $C16B: D0 0E
  LDA #$F0                                              ; $C16D: A9 F0
  JSR SetupDisplayPtrs                                  ; $C16F: 20 6D C9
  INC $04A1                                             ; $C172: EE A1 04
  LDA #$28                                              ; $C175: A9 28
  STA $04A3                                             ; $C177: 8D A3 04
  RTS                                                   ; $C17A: 60

;===============================================================================
L_C17B:
; $C17B: Action07_TaxRate
;===============================================================================
  LDA #$60                                              ; $C17B: A9 60
  STA $0010                                             ; $C17D: 8D 10 00
  LDA #$87                                              ; $C180: A9 87
  STA $0011                                             ; $C182: 8D 11 00
  LDY $04A1                                             ; $C185: AC A1 04
  JSR DisplayTileData                                   ; $C188: 20 94 C9
  LDA $04A3                                             ; $C18B: AD A3 04
  LSR                                                   ; $C18E: 4A
  LSR                                                   ; $C18F: 4A
  AND #$0F                                              ; $C190: 29 0F
  TAY                                                   ; $C192: A8
  LDA $C19C,Y                                           ; $C193: B9 9C C1
  STA $04A1                                             ; $C196: 8D A1 04
  JMP CommonReturn                                      ; $C199: 4C 34 C9
  .byte $01, $02, $03, $03, $03, $03, $03, $03, $02, $02, $02, $02, $01, $01, $01, $01 ; $C19C: 01 02 03 03 03 03 03 03 02 02 02 02 01 01 01 01
  LDA $04A1                                             ; $C1AC: AD A1 04
  BNE L_C1CA                                            ; $C1AF: D0 19
  LDA #$E9                                              ; $C1B1: A9 E9
  JSR SetupDisplayPtrs                                  ; $C1B3: 20 6D C9
  LDA #$EB                                              ; $C1B6: A9 EB
  JSR ResetDispatchState                                ; $C1B8: 20 8A C9
  LDA #$C3                                              ; $C1BB: A9 C3
  STA $00C1                                             ; $C1BD: 8D C1 00
  STA $00C9                                             ; $C1C0: 8D C9 00
  STA $00D1                                             ; $C1C3: 8D D1 00
  INC $04A1                                             ; $C1C6: EE A1 04
  RTS                                                   ; $C1C9: 60

;===============================================================================
L_C1CA:
; $C1CA: Action08_GoldDist
;===============================================================================
  LDA #$D1                                              ; $C1CA: A9 D1
  STA $0010                                             ; $C1CC: 8D 10 00
  LDA #$87                                              ; $C1CF: A9 87
  STA $0011                                             ; $C1D1: 8D 11 00
  LDY $04A1                                             ; $C1D4: AC A1 04
  JSR DisplayTileData                                   ; $C1D7: 20 94 C9
  LDY #$04                                              ; $C1DA: A0 04
  JSR DisplayTileData                                   ; $C1DC: 20 94 C9
  LDA $04A3                                             ; $C1DF: AD A3 04
  LSR                                                   ; $C1E2: 4A
  LSR                                                   ; $C1E3: 4A
  LSR                                                   ; $C1E4: 4A
  LSR                                                   ; $C1E5: 4A
  AND #$07                                              ; $C1E6: 29 07
  TAY                                                   ; $C1E8: A8
  LDA $C1F2,Y                                           ; $C1E9: B9 F2 C1
  STA $04A1                                             ; $C1EC: 8D A1 04
  JMP CommonReturn                                      ; $C1EF: 4C 34 C9
  .byte $02, $03, $02, $03, $01, $01, $01, $01          ; $C1F2: 02 03 02 03 01 01 01 01
  LDA $04A1                                             ; $C1FA: AD A1 04
  BNE L_C218                                            ; $C1FD: D0 19
  LDA #$F8                                              ; $C1FF: A9 F8
  JSR SetupDisplayPtrs                                  ; $C201: 20 6D C9
  LDA #$F9                                              ; $C204: A9 F9
  JSR ResetDispatchState                                ; $C206: 20 8A C9
  LDA #$FA                                              ; $C209: A9 FA
  STA $00C1                                             ; $C20B: 8D C1 00
  STA $00C9                                             ; $C20E: 8D C9 00
  STA $00D1                                             ; $C211: 8D D1 00
  INC $04A1                                             ; $C214: EE A1 04
  RTS                                                   ; $C217: 60

;===============================================================================
L_C218:
; $C218: Action09_FoodDist
;===============================================================================
  LDA #$D5                                              ; $C218: A9 D5
  STA $0010                                             ; $C21A: 8D 10 00
  LDA #$88                                              ; $C21D: A9 88
  STA $0011                                             ; $C21F: 8D 11 00
  LDY $04A1                                             ; $C222: AC A1 04
  JSR DisplayTileData                                   ; $C225: 20 94 C9
  LDA $04A3                                             ; $C228: AD A3 04
  LSR                                                   ; $C22B: 4A
  LSR                                                   ; $C22C: 4A
  LSR                                                   ; $C22D: 4A
  AND #$0F                                              ; $C22E: 29 0F
  TAY                                                   ; $C230: A8
  CMP #$0A                                              ; $C231: C9 0A
  BNE L_C23A                                            ; $C233: D0 05
  LDA #$00                                              ; $C235: A9 00
  STA $04A3                                             ; $C237: 8D A3 04
L_C23A:
  LDA $C252,Y                                           ; $C23A: B9 52 C2
  STA $04A1                                             ; $C23D: 8D A1 04
  LDA $04A3                                             ; $C240: AD A3 04
  LSR                                                   ; $C243: 4A
  LSR                                                   ; $C244: 4A
  LSR                                                   ; $C245: 4A
  AND #$01                                              ; $C246: 29 01
  CLC                                                   ; $C248: 18
  ADC #$05                                              ; $C249: 69 05
  TAY                                                   ; $C24B: A8
  JSR DisplayTileData                                   ; $C24C: 20 94 C9
  JMP CommonReturn                                      ; $C24F: 4C 34 C9

;===============================================================================
; $C252: Action0A_Recruit
;===============================================================================
  .byte $01, $02, $03, $04, $04, $03, $04, $04, $03, $02, $01 ; $C252: 01 02 03 04 04 03 04 04 03 02 01
  LDA $04A1                                             ; $C25D: AD A1 04
  BNE L_C28A                                            ; $C260: D0 28
  LDA #$F7                                              ; $C262: A9 F7
  JSR SetupDisplayPtrs                                  ; $C264: 20 6D C9
  INC $04A1                                             ; $C267: EE A1 04
  LDY #$00                                              ; $C26A: A0 00
  LDX #$00                                              ; $C26C: A2 00
  LDA $0150                                             ; $C26E: AD 50 01
  BPL L_C275                                            ; $C271: 10 02
  LDX #$0D                                              ; $C273: A2 0D
L_C275:
  LDA $C2C3,X                                           ; $C275: BD C3 C2
  STA $0380,Y                                           ; $C278: 99 80 03
  INX                                                   ; $C27B: E8
  INY                                                   ; $C27C: C8
  CPY #$0D                                              ; $C27D: C0 0D
  BCC L_C275                                            ; $C27F: 90 F4
  LDA $007E                                             ; $C281: AD 7E 00
  ORA #$04                                              ; $C284: 09 04
  STA $007E                                             ; $C286: 8D 7E 00
  RTS                                                   ; $C289: 60

;===============================================================================
L_C28A:
; $C28A: Action0B_HireOfficer
;===============================================================================
  LDA #$B7                                              ; $C28A: A9 B7
  STA $0010                                             ; $C28C: 8D 10 00
  LDA #$89                                              ; $C28F: A9 89
  STA $0011                                             ; $C291: 8D 11 00
  LDY $04A1                                             ; $C294: AC A1 04
  JSR DisplayTileData                                   ; $C297: 20 94 C9
  LDA $04A3                                             ; $C29A: AD A3 04
  LSR                                                   ; $C29D: 4A
  LSR                                                   ; $C29E: 4A
  LSR                                                   ; $C29F: 4A
  LSR                                                   ; $C2A0: 4A
  STA $0000                                             ; $C2A1: 8D 00 00
  AND #$03                                              ; $C2A4: 29 03
  CMP #$03                                              ; $C2A6: C9 03
  BNE L_C2AC                                            ; $C2A8: D0 02
  LDA #$01                                              ; $C2AA: A9 01
L_C2AC:
  STA $04A1                                             ; $C2AC: 8D A1 04
  INC $04A1                                             ; $C2AF: EE A1 04
  LDY #$04                                              ; $C2B2: A0 04
  LDA $0000                                             ; $C2B4: AD 00 00
  AND #$02                                              ; $C2B7: 29 02
  BEQ L_C2BD                                            ; $C2B9: F0 02
  LDY #$05                                              ; $C2BB: A0 05
L_C2BD:
  JSR DisplayTileData                                   ; $C2BD: 20 94 C9
  JMP CommonReturn                                      ; $C2C0: 4C 34 C9
  .byte $03, $23, $D1, $0F, $0F, $8B, $03, $23, $D9, $00, $00, $88, $FF, $03, $23, $D4 ; $C2C3: 03 23 D1 0F 0F 8B 03 23 D9 00 00 88 FF 03 23 D4
  .byte $2E, $0F, $0F, $03, $23, $DC, $22, $00, $00, $FF ; $C2D3: 2E 0F 0F 03 23 DC 22 00 00 FF
  LDA $04A1                                             ; $C2DD: AD A1 04
  BNE L_C2F0                                            ; $C2E0: D0 0E
  LDA #$F3                                              ; $C2E2: A9 F3
  JSR SetupDisplayPtrs                                  ; $C2E4: 20 6D C9
  LDA #$F4                                              ; $C2E7: A9 F4
  JSR ResetDispatchState                                ; $C2E9: 20 8A C9
  INC $04A1                                             ; $C2EC: EE A1 04
  RTS                                                   ; $C2EF: 60

;===============================================================================
L_C2F0:
; $C2F0: Action0C_TransferOfficer
;===============================================================================
  LDA #$52                                              ; $C2F0: A9 52
  STA $0010                                             ; $C2F2: 8D 10 00
  LDA #$8A                                              ; $C2F5: A9 8A
  STA $0011                                             ; $C2F7: 8D 11 00
  LDY $04A1                                             ; $C2FA: AC A1 04
  JSR DisplayTileData                                   ; $C2FD: 20 94 C9
  LDA $04A3                                             ; $C300: AD A3 04
  LSR                                                   ; $C303: 4A
  LSR                                                   ; $C304: 4A
  LSR                                                   ; $C305: 4A
  STA $0000                                             ; $C306: 8D 00 00
  AND #$0F                                              ; $C309: 29 0F
  TAY                                                   ; $C30B: A8
  CMP #$0A                                              ; $C30C: C9 0A
  BNE L_C315                                            ; $C30E: D0 05
  LDA #$00                                              ; $C310: A9 00
  STA $04A3                                             ; $C312: 8D A3 04
L_C315:
  LDA $C332,Y                                           ; $C315: B9 32 C3
  STA $04A1                                             ; $C318: 8D A1 04
  LDY #$01                                              ; $C31B: A0 01
  LDA $0000                                             ; $C31D: AD 00 00
  AND #$0F                                              ; $C320: 29 0F
  CMP #$05                                              ; $C322: C9 05
  BCS L_C32C                                            ; $C324: B0 06
  AND #$01                                              ; $C326: 29 01
  BEQ L_C32C                                            ; $C328: F0 02
  LDY #$02                                              ; $C32A: A0 02
L_C32C:
  JSR DisplayTileData                                   ; $C32C: 20 94 C9
  JMP CommonReturn                                      ; $C32F: 4C 34 C9
  .byte $03, $03, $03, $03, $03, $03, $04, $05, $05, $04, $03 ; $C332: 03 03 03 03 03 03 04 05 05 04 03
  LDA $04A1                                             ; $C33D: AD A1 04
  BNE L_C350                                            ; $C340: D0 0E
  LDA #$F0                                              ; $C342: A9 F0
  JSR SetupDisplayPtrs                                  ; $C344: 20 6D C9
  INC $04A1                                             ; $C347: EE A1 04
  LDA #$20                                              ; $C34A: A9 20
  STA $04A4                                             ; $C34C: 8D A4 04
  RTS                                                   ; $C34F: 60

;===============================================================================
L_C350:
; $C350: Action0D_ExecuteOfficer
;===============================================================================
  INC $04A5                                             ; $C350: EE A5 04
  LDA #$55                                              ; $C353: A9 55
  STA $0010                                             ; $C355: 8D 10 00
  LDA #$8B                                              ; $C358: A9 8B
  STA $0011                                             ; $C35A: 8D 11 00
  LDY $04A1                                             ; $C35D: AC A1 04
  LDX $04A4                                             ; $C360: AE A4 04
  JSR L_C996                                            ; $C363: 20 96 C9
  LDA $04A3                                             ; $C366: AD A3 04
  LSR                                                   ; $C369: 4A
  LSR                                                   ; $C36A: 4A
  LSR                                                   ; $C36B: 4A
  LSR                                                   ; $C36C: 4A
  STA $0000                                             ; $C36D: 8D 00 00
  AND #$03                                              ; $C370: 29 03
  CMP #$03                                              ; $C372: C9 03
  BNE L_C378                                            ; $C374: D0 02
  LDA #$01                                              ; $C376: A9 01
L_C378:
  CLC                                                   ; $C378: 18
  ADC #$01                                              ; $C379: 69 01
  CMP $04A1                                             ; $C37B: CD A1 04
  BEQ L_C383                                            ; $C37E: F0 03
  DEC $04A4                                             ; $C380: CE A4 04
L_C383:
  STA $04A1                                             ; $C383: 8D A1 04
  LDA $04A5                                             ; $C386: AD A5 04
  LSR                                                   ; $C389: 4A
  LSR                                                   ; $C38A: 4A
  LSR                                                   ; $C38B: 4A
  LSR                                                   ; $C38C: 4A
  AND #$03                                              ; $C38D: 29 03
  CMP #$03                                              ; $C38F: C9 03
  BNE L_C398                                            ; $C391: D0 05
  LDA #$00                                              ; $C393: A9 00
  STA $04A5                                             ; $C395: 8D A5 04
L_C398:
  CLC                                                   ; $C398: 18
  ADC #$04                                              ; $C399: 69 04
  TAY                                                   ; $C39B: A8
  JSR DisplayTileData                                   ; $C39C: 20 94 C9
  JMP CommonReturn                                      ; $C39F: 4C 34 C9
  LDA $04A1                                             ; $C3A2: AD A1 04
  BNE L_C3BA                                            ; $C3A5: D0 13
  LDA #$D0                                              ; $C3A7: A9 D0
  JSR SetupDisplayPtrs                                  ; $C3A9: 20 6D C9
  LDA #$D1                                              ; $C3AC: A9 D1
  JSR ResetDispatchState                                ; $C3AE: 20 8A C9
  INC $04A1                                             ; $C3B1: EE A1 04
  LDA #$20                                              ; $C3B4: A9 20
  STA $04A5                                             ; $C3B6: 8D A5 04
  RTS                                                   ; $C3B9: 60

;===============================================================================
L_C3BA:
; $C3BA: Action0E_ExileOfficer
;===============================================================================
  LDA #$03                                              ; $C3BA: A9 03
  STA $0010                                             ; $C3BC: 8D 10 00
  LDA #$8C                                              ; $C3BF: A9 8C
  STA $0011                                             ; $C3C1: 8D 11 00
  LDY $04A1                                             ; $C3C4: AC A1 04
  JSR DisplayTileData                                   ; $C3C7: 20 94 C9
  LDY #$05                                              ; $C3CA: A0 05
  LDX $04A5                                             ; $C3CC: AE A5 04
  JSR L_C996                                            ; $C3CF: 20 96 C9
  LDA $04A3                                             ; $C3D2: AD A3 04
  LSR                                                   ; $C3D5: 4A
  LSR                                                   ; $C3D6: 4A
  LSR                                                   ; $C3D7: 4A
  AND #$03                                              ; $C3D8: 29 03
  CLC                                                   ; $C3DA: 18
  ADC #$01                                              ; $C3DB: 69 01
  STA $04A1                                             ; $C3DD: 8D A1 04
  LDA $04A3                                             ; $C3E0: AD A3 04
  AND #$0F                                              ; $C3E3: 29 0F
  CMP #$08                                              ; $C3E5: C9 08
  BNE L_C3F3                                            ; $C3E7: D0 0A
  LDA $04A3                                             ; $C3E9: AD A3 04
  AND #$10                                              ; $C3EC: 29 10
  BEQ L_C3F3                                            ; $C3EE: F0 03
  DEC $04A5                                             ; $C3F0: CE A5 04
L_C3F3:
  JMP CommonReturn                                      ; $C3F3: 4C 34 C9
  LDA $04A1                                             ; $C3F6: AD A1 04
  BNE L_C414                                            ; $C3F9: D0 19
  LDA #$F5                                              ; $C3FB: A9 F5
  JSR SetupDisplayPtrs                                  ; $C3FD: 20 6D C9
  LDA #$F7                                              ; $C400: A9 F7
  JSR ResetDispatchState                                ; $C402: 20 8A C9
  LDA #$D7                                              ; $C405: A9 D7
  STA $00C1                                             ; $C407: 8D C1 00
  STA $00C9                                             ; $C40A: 8D C9 00
  STA $00D1                                             ; $C40D: 8D D1 00
  INC $04A1                                             ; $C410: EE A1 04
  RTS                                                   ; $C413: 60

;===============================================================================
L_C414:
; $C414: Action0F_GiveItem
;===============================================================================
  LDA #$2E                                              ; $C414: A9 2E
  STA $0010                                             ; $C416: 8D 10 00
  LDA #$8D                                              ; $C419: A9 8D
  STA $0011                                             ; $C41B: 8D 11 00
  LDY $04A1                                             ; $C41E: AC A1 04
  JSR DisplayTileData                                   ; $C421: 20 94 C9
  LDA $04A3                                             ; $C424: AD A3 04
  LSR                                                   ; $C427: 4A
  LSR                                                   ; $C428: 4A
  LSR                                                   ; $C429: 4A
  AND #$07                                              ; $C42A: 29 07
  TAY                                                   ; $C42C: A8
  LDA $C436,Y                                           ; $C42D: B9 36 C4
  STA $04A1                                             ; $C430: 8D A1 04
  JMP CommonReturn                                      ; $C433: 4C 34 C9
  .byte $01, $02, $03, $03, $03, $03, $02, $01          ; $C436: 01 02 03 03 03 03 02 01
  LDA $04A1                                             ; $C43E: AD A1 04
  BNE L_C47A                                            ; $C441: D0 37
  LDA #$F8                                              ; $C443: A9 F8
  JSR SetupDisplayPtrs                                  ; $C445: 20 6D C9
  LDA #$FA                                              ; $C448: A9 FA
  JSR ResetDispatchState                                ; $C44A: 20 8A C9
  LDA #$00                                              ; $C44D: A9 00
  STA $04A3                                             ; $C44F: 8D A3 04
  STA $04A4                                             ; $C452: 8D A4 04
  LDA #$05                                              ; $C455: A9 05
  STA $04A1                                             ; $C457: 8D A1 04
  LDY #$00                                              ; $C45A: A0 00
  LDX #$00                                              ; $C45C: A2 00
  LDA $0150                                             ; $C45E: AD 50 01
  BPL L_C465                                            ; $C461: 10 02
  LDX #$10                                              ; $C463: A2 10
L_C465:
  LDA $C4C1,X                                           ; $C465: BD C1 C4
  STA $0380,Y                                           ; $C468: 99 80 03
  INX                                                   ; $C46B: E8
  INY                                                   ; $C46C: C8
  CPY #$10                                              ; $C46D: C0 10
  BCC L_C465                                            ; $C46F: 90 F4
  LDA $007E                                             ; $C471: AD 7E 00
  ORA #$04                                              ; $C474: 09 04
  STA $007E                                             ; $C476: 8D 7E 00
  RTS                                                   ; $C479: 60

;===============================================================================
L_C47A:
; $C47A: Action10_MoveCapital
;===============================================================================
  LDA #$37                                              ; $C47A: A9 37
  STA $0010                                             ; $C47C: 8D 10 00
  LDA #$8E                                              ; $C47F: A9 8E
  STA $0011                                             ; $C481: 8D 11 00
  LDY $04A1                                             ; $C484: AC A1 04
  JSR DisplayTileData                                   ; $C487: 20 94 C9
  LDA $04A3                                             ; $C48A: AD A3 04
  BPL L_C494                                            ; $C48D: 10 05
  LDA #$06                                              ; $C48F: A9 06
  STA $04A1                                             ; $C491: 8D A1 04
L_C494:
  INC $04A4                                             ; $C494: EE A4 04
  LDA $04A4                                             ; $C497: AD A4 04
  BMI L_C4A1                                            ; $C49A: 30 05
  LDY #$01                                              ; $C49C: A0 01
  JMP L_C4AC                                            ; $C49E: 4C AC C4
L_C4A1:
  CMP #$85                                              ; $C4A1: C9 85
  BCC L_C4AA                                            ; $C4A3: 90 05
  LDA #$00                                              ; $C4A5: A9 00
  STA $04A4                                             ; $C4A7: 8D A4 04
L_C4AA:
  LDY #$02                                              ; $C4AA: A0 02
L_C4AC:
  JSR DisplayTileData                                   ; $C4AC: 20 94 C9
  LDA $04A3                                             ; $C4AF: AD A3 04
  LSR                                                   ; $C4B2: 4A
  LSR                                                   ; $C4B3: 4A
  LSR                                                   ; $C4B4: 4A
  AND #$01                                              ; $C4B5: 29 01
  CLC                                                   ; $C4B7: 18
  ADC #$03                                              ; $C4B8: 69 03
  TAY                                                   ; $C4BA: A8
  JSR DisplayTileData                                   ; $C4BB: 20 94 C9
  JMP CommonReturn                                      ; $C4BE: 4C 34 C9
  .byte $02, $23, $C9, $AA, $FA, $02, $23, $D1, $AF, $FF, $02, $23, $D9, $AA, $FF, $FF ; $C4C1: 02 23 C9 AA FA 02 23 D1 AF FF 02 23 D9 AA FF FF
  .byte $02, $23, $CC, $AA, $EA, $02, $23, $D4, $AE, $EF, $02, $23, $DC, $AA, $EE, $FF ; $C4D1: 02 23 CC AA EA 02 23 D4 AE EF 02 23 DC AA EE FF
  LDA $04A1                                             ; $C4E1: AD A1 04
  BNE L_C4EF                                            ; $C4E4: D0 09
  LDA #$E7                                              ; $C4E6: A9 E7
  JSR SetupDisplayPtrs                                  ; $C4E8: 20 6D C9
  INC $04A1                                             ; $C4EB: EE A1 04

;===============================================================================
; $C4EE: Action11_Diplomacy
;===============================================================================
  RTS                                                   ; $C4EE: 60
L_C4EF:
  LDA #$DD                                              ; $C4EF: A9 DD
  STA $0010                                             ; $C4F1: 8D 10 00
  LDA #$8E                                              ; $C4F4: A9 8E
  STA $0011                                             ; $C4F6: 8D 11 00
  LDY $04A1                                             ; $C4F9: AC A1 04
  JSR DisplayTileData                                   ; $C4FC: 20 94 C9
  LDA $04A3                                             ; $C4FF: AD A3 04
  LSR                                                   ; $C502: 4A
  LSR                                                   ; $C503: 4A
  LSR                                                   ; $C504: 4A
  LSR                                                   ; $C505: 4A
  AND #$01                                              ; $C506: 29 01
  CLC                                                   ; $C508: 18
  ADC #$01                                              ; $C509: 69 01
  STA $04A1                                             ; $C50B: 8D A1 04
  JMP CommonReturn                                      ; $C50E: 4C 34 C9
  LDA $04A1                                             ; $C511: AD A1 04
  BNE L_C524                                            ; $C514: D0 0E
  LDA #$FB                                              ; $C516: A9 FB
  JSR SetupDisplayPtrs                                  ; $C518: 20 6D C9
  LDA #$FC                                              ; $C51B: A9 FC
  JSR ResetDispatchState                                ; $C51D: 20 8A C9
  INC $04A1                                             ; $C520: EE A1 04
  RTS                                                   ; $C523: 60

;===============================================================================
L_C524:
; $C524: Action12_War
;===============================================================================
  LDA #$6B                                              ; $C524: A9 6B
  STA $0010                                             ; $C526: 8D 10 00
  LDA #$8F                                              ; $C529: A9 8F
  STA $0011                                             ; $C52B: 8D 11 00
  LDY $04A1                                             ; $C52E: AC A1 04
  JSR DisplayTileData                                   ; $C531: 20 94 C9
  LDA $04A3                                             ; $C534: AD A3 04
  LSR                                                   ; $C537: 4A
  LSR                                                   ; $C538: 4A
  LSR                                                   ; $C539: 4A
  AND #$0F                                              ; $C53A: 29 0F
  TAY                                                   ; $C53C: A8
  LDA $C546,Y                                           ; $C53D: B9 46 C5
  STA $04A1                                             ; $C540: 8D A1 04
  JMP CommonReturn                                      ; $C543: 4C 34 C9
  .byte $01, $03, $01, $03, $02, $03, $01, $03, $02, $01, $01, $04, $04, $04, $04, $04 ; $C546: 01 03 01 03 02 03 01 03 02 01 01 04 04 04 04 04
  LDA $04A1                                             ; $C556: AD A1 04
  BNE L_C579                                            ; $C559: D0 1E
  LDA #$EA                                              ; $C55B: A9 EA
  JSR SetupDisplayPtrs                                  ; $C55D: 20 6D C9
  LDA #$EB                                              ; $C560: A9 EB
  JSR ResetDispatchState                                ; $C562: 20 8A C9
  LDA #$ED                                              ; $C565: A9 ED
  STA $00C1                                             ; $C567: 8D C1 00
  STA $00C9                                             ; $C56A: 8D C9 00
  STA $00D1                                             ; $C56D: 8D D1 00
  INC $04A1                                             ; $C570: EE A1 04
  LDA #$20                                              ; $C573: A9 20
  STA $04A5                                             ; $C575: 8D A5 04
  RTS                                                   ; $C578: 60

;===============================================================================
L_C579:
; $C579: Action13_Spy
;===============================================================================
  LDA #$77                                              ; $C579: A9 77
  STA $0010                                             ; $C57B: 8D 10 00
  LDA #$90                                              ; $C57E: A9 90
  STA $0011                                             ; $C580: 8D 11 00
  LDX $04A5                                             ; $C583: AE A5 04
  LDY $04A1                                             ; $C586: AC A1 04
  JSR L_C996                                            ; $C589: 20 96 C9
  LDA $04A3                                             ; $C58C: AD A3 04
  LSR                                                   ; $C58F: 4A
  LSR                                                   ; $C590: 4A
  LSR                                                   ; $C591: 4A
  AND #$03                                              ; $C592: 29 03
  CMP #$03                                              ; $C594: C9 03
  BNE L_C59D                                            ; $C596: D0 05
  LDA #$00                                              ; $C598: A9 00
  STA $04A3                                             ; $C59A: 8D A3 04
L_C59D:
  CLC                                                   ; $C59D: 18
  ADC #$01                                              ; $C59E: 69 01
  STA $04A1                                             ; $C5A0: 8D A1 04
  CMP $04A4                                             ; $C5A3: CD A4 04
  BEQ L_C5AE                                            ; $C5A6: F0 06
  STA $04A4                                             ; $C5A8: 8D A4 04
  DEC $04A5                                             ; $C5AB: CE A5 04
L_C5AE:
  JMP CommonReturn                                      ; $C5AE: 4C 34 C9
  LDA $04A1                                             ; $C5B1: AD A1 04
  BNE L_C5C4                                            ; $C5B4: D0 0E
  LDA #$F6                                              ; $C5B6: A9 F6
  JSR SetupDisplayPtrs                                  ; $C5B8: 20 6D C9
  INC $04A1                                             ; $C5BB: EE A1 04
  LDA #$03                                              ; $C5BE: A9 03
  STA $04A4                                             ; $C5C0: 8D A4 04
  RTS                                                   ; $C5C3: 60

;===============================================================================
L_C5C4:
; $C5C4: Action14_Accounting
;===============================================================================
  LDA #$40                                              ; $C5C4: A9 40
  STA $0010                                             ; $C5C6: 8D 10 00
  LDA #$91                                              ; $C5C9: A9 91
  STA $0011                                             ; $C5CB: 8D 11 00
  LDY $04A1                                             ; $C5CE: AC A1 04
  JSR DisplayTileData                                   ; $C5D1: 20 94 C9
  LDY $04A4                                             ; $C5D4: AC A4 04
  JSR DisplayTileData                                   ; $C5D7: 20 94 C9
  LDA $04A3                                             ; $C5DA: AD A3 04
  LSR                                                   ; $C5DD: 4A
  LSR                                                   ; $C5DE: 4A
  LSR                                                   ; $C5DF: 4A
  AND #$01                                              ; $C5E0: 29 01
  CLC                                                   ; $C5E2: 18
  ADC #$01                                              ; $C5E3: 69 01
  STA $04A1                                             ; $C5E5: 8D A1 04
  LDA $04A3                                             ; $C5E8: AD A3 04
  AND #$40                                              ; $C5EB: 29 40
  BEQ L_C5F4                                            ; $C5ED: F0 05
  LDA #$04                                              ; $C5EF: A9 04
  STA $04A4                                             ; $C5F1: 8D A4 04
L_C5F4:
  JMP CommonReturn                                      ; $C5F4: 4C 34 C9
  LDA $04A1                                             ; $C5F7: AD A1 04
  BNE L_C60A                                            ; $C5FA: D0 0E
  LDA #$F7                                              ; $C5FC: A9 F7
  JSR SetupDisplayPtrs                                  ; $C5FE: 20 6D C9
  LDA #$DF                                              ; $C601: A9 DF
  JSR ResetDispatchState                                ; $C603: 20 8A C9
  INC $04A1                                             ; $C606: EE A1 04
  RTS                                                   ; $C609: 60

;===============================================================================
L_C60A:
; $C60A: Action15_Exchange
;===============================================================================
  LDA #$DC                                              ; $C60A: A9 DC
  STA $0010                                             ; $C60C: 8D 10 00
  LDA #$91                                              ; $C60F: A9 91
  STA $0011                                             ; $C611: 8D 11 00
  LDY $04A1                                             ; $C614: AC A1 04
  JSR DisplayTileData                                   ; $C617: 20 94 C9
  LDA $04A1                                             ; $C61A: AD A1 04
  CLC                                                   ; $C61D: 18
  ADC #$02                                              ; $C61E: 69 02
  TAY                                                   ; $C620: A8
  JSR DisplayTileData                                   ; $C621: 20 94 C9
  LDA $04A3                                             ; $C624: AD A3 04
  LSR                                                   ; $C627: 4A
  LSR                                                   ; $C628: 4A
  LSR                                                   ; $C629: 4A
  LSR                                                   ; $C62A: 4A
  AND #$01                                              ; $C62B: 29 01
  CLC                                                   ; $C62D: 18
  ADC #$01                                              ; $C62E: 69 01
  STA $04A1                                             ; $C630: 8D A1 04
  JMP CommonReturn                                      ; $C633: 4C 34 C9
  LDA $04A1                                             ; $C636: AD A1 04
  BNE L_C644                                            ; $C639: D0 09
  LDA #$C5                                              ; $C63B: A9 C5
  JSR SetupDisplayPtrs                                  ; $C63D: 20 6D C9
  INC $04A1                                             ; $C640: EE A1 04
  RTS                                                   ; $C643: 60

;===============================================================================
L_C644:
; $C644: Action16_Trade
;===============================================================================
  LDA #$A0                                              ; $C644: A9 A0
  STA $0010                                             ; $C646: 8D 10 00
  LDA #$92                                              ; $C649: A9 92
  STA $0011                                             ; $C64B: 8D 11 00
  LDY $04A1                                             ; $C64E: AC A1 04
  JSR DisplayTileData                                   ; $C651: 20 94 C9
  LDA $04A1                                             ; $C654: AD A1 04
  CLC                                                   ; $C657: 18
  ADC #$02                                              ; $C658: 69 02
  TAY                                                   ; $C65A: A8
  JSR DisplayTileData                                   ; $C65B: 20 94 C9
  LDA $04A3                                             ; $C65E: AD A3 04
  ROL                                                   ; $C661: 2A
  ROL                                                   ; $C662: 2A
  ROL                                                   ; $C663: 2A
  ROL                                                   ; $C664: 2A
  AND #$01                                              ; $C665: 29 01
  CLC                                                   ; $C667: 18
  ADC #$03                                              ; $C668: 69 03
  STA $04A1                                             ; $C66A: 8D A1 04
  LDY #$01                                              ; $C66D: A0 01
  LDA $04A3                                             ; $C66F: AD A3 04
  CMP #$60                                              ; $C672: C9 60

;===============================================================================
; $C674: Action17_SearchOfficer
;===============================================================================
  BCC L_C677                                            ; $C674: 90 01
  INY                                                   ; $C676: C8
L_C677:
  JSR DisplayTileData                                   ; $C677: 20 94 C9
  JMP CommonReturn                                      ; $C67A: 4C 34 C9
  LDA $04A1                                             ; $C67D: AD A1 04
  BNE L_C69B                                            ; $C680: D0 19
  LDA #$F4                                              ; $C682: A9 F4
  JSR SetupDisplayPtrs                                  ; $C684: 20 6D C9
  LDA #$F5                                              ; $C687: A9 F5
  JSR ResetDispatchState                                ; $C689: 20 8A C9
  LDA #$D4                                              ; $C68C: A9 D4
  STA $00C1                                             ; $C68E: 8D C1 00
  STA $00C9                                             ; $C691: 8D C9 00
  STA $00D1                                             ; $C694: 8D D1 00
  INC $04A1                                             ; $C697: EE A1 04
  RTS                                                   ; $C69A: 60

;===============================================================================
L_C69B:
; $C69B: Action18_SearchItem
;===============================================================================
  LDA #$42                                              ; $C69B: A9 42
  STA $0010                                             ; $C69D: 8D 10 00
  LDA #$93                                              ; $C6A0: A9 93
  STA $0011                                             ; $C6A2: 8D 11 00
  LDY $04A1                                             ; $C6A5: AC A1 04
  JSR DisplayTileData                                   ; $C6A8: 20 94 C9
  LDA $04A3                                             ; $C6AB: AD A3 04
  LSR                                                   ; $C6AE: 4A
  LSR                                                   ; $C6AF: 4A
  LSR                                                   ; $C6B0: 4A
  LSR                                                   ; $C6B1: 4A
  AND #$07                                              ; $C6B2: 29 07
  TAY                                                   ; $C6B4: A8
  LDA $C6BE,Y                                           ; $C6B5: B9 BE C6
  STA $04A1                                             ; $C6B8: 8D A1 04
  JMP CommonReturn                                      ; $C6BB: 4C 34 C9
  .byte $01, $02, $01, $02, $01, $03, $03, $03          ; $C6BE: 01 02 01 02 01 03 03 03
  LDA $04A1                                             ; $C6C6: AD A1 04
  BNE L_C6FD                                            ; $C6C9: D0 32
  LDA #$C1                                              ; $C6CB: A9 C1
  JSR SetupDisplayPtrs                                  ; $C6CD: 20 6D C9
  INC $04A1                                             ; $C6D0: EE A1 04
  LDA #$01                                              ; $C6D3: A9 01
  STA $04A4                                             ; $C6D5: 8D A4 04
  LDA #$20                                              ; $C6D8: A9 20
  STA $04A5                                             ; $C6DA: 8D A5 04
  LDY #$00                                              ; $C6DD: A0 00
  LDX #$00                                              ; $C6DF: A2 00
  LDA $0150                                             ; $C6E1: AD 50 01
  BPL L_C6E8                                            ; $C6E4: 10 02
  LDX #$13                                              ; $C6E6: A2 13
L_C6E8:
  LDA $C739,X                                           ; $C6E8: BD 39 C7
  STA $0380,Y                                           ; $C6EB: 99 80 03
  INX                                                   ; $C6EE: E8
  INY                                                   ; $C6EF: C8
  CPY #$13                                              ; $C6F0: C0 13
  BCC L_C6E8                                            ; $C6F2: 90 F4
  LDA $007E                                             ; $C6F4: AD 7E 00
  ORA #$04                                              ; $C6F7: 09 04
  STA $007E                                             ; $C6F9: 8D 7E 00
  RTS                                                   ; $C6FC: 60

;===============================================================================
L_C6FD:
; $C6FD: Action19_InspectLand
;===============================================================================
  LDA #$77                                              ; $C6FD: A9 77
  STA $0010                                             ; $C6FF: 8D 10 00
  LDA #$94                                              ; $C702: A9 94
  STA $0011                                             ; $C704: 8D 11 00
  LDX $04A5                                             ; $C707: AE A5 04
  LDY $04A1                                             ; $C70A: AC A1 04
  JSR L_C996                                            ; $C70D: 20 96 C9
  LDA $04A3                                             ; $C710: AD A3 04
  LSR                                                   ; $C713: 4A
  LSR                                                   ; $C714: 4A
  LSR                                                   ; $C715: 4A
  LSR                                                   ; $C716: 4A
  STA $0000                                             ; $C717: 8D 00 00
  AND #$07                                              ; $C71A: 29 07
  TAY                                                   ; $C71C: A8
  LDA $C731,Y                                           ; $C71D: B9 31 C7
  STA $04A1                                             ; $C720: 8D A1 04
  CMP $04A4                                             ; $C723: CD A4 04
  BEQ L_C72E                                            ; $C726: F0 06
  STA $04A4                                             ; $C728: 8D A4 04
  DEC $04A5                                             ; $C72B: CE A5 04
L_C72E:
  JMP CommonReturn                                      ; $C72E: 4C 34 C9
  .byte $01, $02, $03, $04, $01, $02, $05, $06, $03, $23, $C9, $FA, $FA, $BA, $03, $23 ; $C731: 01 02 03 04 01 02 05 06 03 23 C9 FA FA BA 03 23
  .byte $D1, $0F, $0F, $8B, $03, $23, $D9, $50, $50, $98, $FF, $03, $23, $CC, $EA, $FA ; $C741: D1 0F 0F 8B 03 23 D9 50 50 98 FF 03 23 CC EA FA
  .byte $FA, $03, $23, $D4, $2E, $0F, $0F, $03, $23, $DC, $62, $50, $50, $FF ; $C751: FA 03 23 D4 2E 0F 0F 03 23 DC 62 50 50 FF
  LDA $04A1                                             ; $C75F: AD A1 04
  BNE L_C78C                                            ; $C762: D0 28
  LDA #$FC                                              ; $C764: A9 FC
  JSR SetupDisplayPtrs                                  ; $C766: 20 6D C9
  INC $04A1                                             ; $C769: EE A1 04
  LDY #$00                                              ; $C76C: A0 00
  LDX #$00                                              ; $C76E: A2 00
  LDA $0150                                             ; $C770: AD 50 01
  BPL L_C777                                            ; $C773: 10 02
  LDX #$0D                                              ; $C775: A2 0D
L_C777:
  LDA $C7B7,X                                           ; $C777: BD B7 C7
  STA $0380,Y                                           ; $C77A: 99 80 03
  INX                                                   ; $C77D: E8
  INY                                                   ; $C77E: C8
  CPY #$0D                                              ; $C77F: C0 0D
  BCC L_C777                                            ; $C781: 90 F4
  LDA $007E                                             ; $C783: AD 7E 00
  ORA #$04                                              ; $C786: 09 04
  STA $007E                                             ; $C788: 8D 7E 00
  RTS                                                   ; $C78B: 60

;===============================================================================
L_C78C:
; $C78C: Action1A_PersonalAffairs
;===============================================================================
  LDA #$91                                              ; $C78C: A9 91
  STA $0010                                             ; $C78E: 8D 10 00
  LDA #$96                                              ; $C791: A9 96
  STA $0011                                             ; $C793: 8D 11 00
  LDY $04A1                                             ; $C796: AC A1 04
  JSR DisplayTileData                                   ; $C799: 20 94 C9
  LDA $04A3                                             ; $C79C: AD A3 04
  LSR                                                   ; $C79F: 4A
  LSR                                                   ; $C7A0: 4A
  LSR                                                   ; $C7A1: 4A
  LSR                                                   ; $C7A2: 4A
  AND #$03                                              ; $C7A3: 29 03
  CMP #$03                                              ; $C7A5: C9 03
  BNE L_C7AE                                            ; $C7A7: D0 05
  LDA #$00                                              ; $C7A9: A9 00
  STA $04A3                                             ; $C7AB: 8D A3 04
L_C7AE:
  CLC                                                   ; $C7AE: 18
  ADC #$01                                              ; $C7AF: 69 01
  STA $04A1                                             ; $C7B1: 8D A1 04
  JMP CommonReturn                                      ; $C7B4: 4C 34 C9
  .byte $03, $23, $C9, $0A, $0A, $8A, $03, $23, $D1, $F0, $F0, $B8, $FF, $03, $23, $CC ; $C7B7: 03 23 C9 0A 0A 8A 03 23 D1 F0 F0 B8 FF 03 23 CC
  .byte $2A, $0A, $0A, $03, $23, $D4, $E2, $F0, $F0, $FF ; $C7C7: 2A 0A 0A 03 23 D4 E2 F0 F0 FF
  LDA $04A1                                             ; $C7D1: AD A1 04
  BNE L_C7DF                                            ; $C7D4: D0 09
  LDA #$C2                                              ; $C7D6: A9 C2
  JSR SetupDisplayPtrs                                  ; $C7D8: 20 6D C9
  INC $04A1                                             ; $C7DB: EE A1 04
  RTS                                                   ; $C7DE: 60

;===============================================================================
L_C7DF:
; $C7DF: DomActionDispatch
;===============================================================================
  LDA #$33                                              ; $C7DF: A9 33
  STA $0010                                             ; $C7E1: 8D 10 00
  LDA #$97                                              ; $C7E4: A9 97
  STA $0011                                             ; $C7E6: 8D 11 00
  LDY $04A1                                             ; $C7E9: AC A1 04
  JSR DisplayTileData                                   ; $C7EC: 20 94 C9
  LDA $04A3                                             ; $C7EF: AD A3 04
  LSR                                                   ; $C7F2: 4A
  LSR                                                   ; $C7F3: 4A
  LSR                                                   ; $C7F4: 4A
  AND #$01                                              ; $C7F5: 29 01
  CLC                                                   ; $C7F7: 18
  ADC #$01                                              ; $C7F8: 69 01
  STA $04A1                                             ; $C7FA: 8D A1 04
  JMP CommonReturn                                      ; $C7FD: 4C 34 C9
  LDA $04A1                                             ; $C800: AD A1 04
  BNE L_C80E                                            ; $C803: D0 09
  LDA #$D1                                              ; $C805: A9 D1
  JSR SetupDisplayPtrs                                  ; $C807: 20 6D C9
  INC $04A1                                             ; $C80A: EE A1 04
  RTS                                                   ; $C80D: 60

;===============================================================================
L_C80E:
; $C80E: CopyTileDataRow
;===============================================================================
  LDA #$69                                              ; $C80E: A9 69
  STA $0010                                             ; $C810: 8D 10 00
  LDA #$97                                              ; $C813: A9 97
  STA $0011                                             ; $C815: 8D 11 00
  LDY $04A1                                             ; $C818: AC A1 04
  JSR DisplayTileData                                   ; $C81B: 20 94 C9
  LDA $04A3                                             ; $C81E: AD A3 04
  LSR                                                   ; $C821: 4A
  LSR                                                   ; $C822: 4A
  LSR                                                   ; $C823: 4A
  LSR                                                   ; $C824: 4A
  AND #$01                                              ; $C825: 29 01
  STA $04A1                                             ; $C827: 8D A1 04
  INC $04A1                                             ; $C82A: EE A1 04
  JMP CommonReturn                                      ; $C82D: 4C 34 C9
  LDA $04A1                                             ; $C830: AD A1 04
  BNE L_C843                                            ; $C833: D0 0E
  LDA #$C6                                              ; $C835: A9 C6
  JSR SetupDisplayPtrs                                  ; $C837: 20 6D C9
  INC $04A1                                             ; $C83A: EE A1 04
  LDA #$03                                              ; $C83D: A9 03
  STA $04A4                                             ; $C83F: 8D A4 04
  RTS                                                   ; $C842: 60

;===============================================================================
L_C843:
; $C843: SetupActionDisplay
;===============================================================================
  LDA #$1F                                              ; $C843: A9 1F
  STA $0010                                             ; $C845: 8D 10 00
  LDA #$98                                              ; $C848: A9 98
  STA $0011                                             ; $C84A: 8D 11 00
  LDY $04A1                                             ; $C84D: AC A1 04
  JSR DisplayTileData                                   ; $C850: 20 94 C9
  LDY $04A4                                             ; $C853: AC A4 04
  JSR DisplayTileData                                   ; $C856: 20 94 C9
  LDA $04A3                                             ; $C859: AD A3 04
  LSR                                                   ; $C85C: 4A
  LSR                                                   ; $C85D: 4A
  LSR                                                   ; $C85E: 4A
  STA $0000                                             ; $C85F: 8D 00 00
  AND #$01                                              ; $C862: 29 01
  STA $04A1                                             ; $C864: 8D A1 04
  INC $04A1                                             ; $C867: EE A1 04
  LDY #$03                                              ; $C86A: A0 03
  LDA $0000                                             ; $C86C: AD 00 00
  AND #$07                                              ; $C86F: 29 07
  CMP #$07                                              ; $C871: C9 07
  BNE L_C877                                            ; $C873: D0 02
  LDY #$04                                              ; $C875: A0 04
L_C877:
  STY $04A4                                             ; $C877: 8C A4 04
  JMP CommonReturn                                      ; $C87A: 4C 34 C9
  LDA $04A1                                             ; $C87D: AD A1 04
  BNE L_C88B                                            ; $C880: D0 09
  LDA #$BD                                              ; $C882: A9 BD
  JSR SetupDisplayPtrs                                  ; $C884: 20 6D C9
  INC $04A1                                             ; $C887: EE A1 04
  RTS                                                   ; $C88A: 60

;===============================================================================
L_C88B:
; $C88B: ActionCalcParams
;===============================================================================
  LDA #$93                                              ; $C88B: A9 93
  STA $0010                                             ; $C88D: 8D 10 00
  LDA #$98                                              ; $C890: A9 98
  STA $0011                                             ; $C892: 8D 11 00
  LDY $04A1                                             ; $C895: AC A1 04
  JSR DisplayTileData                                   ; $C898: 20 94 C9
  LDA $04A1                                             ; $C89B: AD A1 04
  CMP #$04                                              ; $C89E: C9 04
  BEQ L_C8B1                                            ; $C8A0: F0 0F
  LDA $04A3                                             ; $C8A2: AD A3 04
  LSR                                                   ; $C8A5: 4A
  LSR                                                   ; $C8A6: 4A
  LSR                                                   ; $C8A7: 4A
  LSR                                                   ; $C8A8: 4A
  AND #$03                                              ; $C8A9: 29 03
  CLC                                                   ; $C8AB: 18
  ADC #$01                                              ; $C8AC: 69 01
  STA $04A1                                             ; $C8AE: 8D A1 04
L_C8B1:
  JMP CommonReturn                                      ; $C8B1: 4C 34 C9
  LDA $04A1                                             ; $C8B4: AD A1 04
  BNE L_C8C7                                            ; $C8B7: D0 0E
  LDA #$B7                                              ; $C8B9: A9 B7
  JSR SetupDisplayPtrs                                  ; $C8BB: 20 6D C9
  LDA #$B7                                              ; $C8BE: A9 B7
  JSR ResetDispatchState                                ; $C8C0: 20 8A C9
  INC $04A1                                             ; $C8C3: EE A1 04
  RTS                                                   ; $C8C6: 60

;===============================================================================
L_C8C7:
; $C8C7: ActionCalcParams2
;===============================================================================
  LDA #$DF                                              ; $C8C7: A9 DF
  STA $0010                                             ; $C8C9: 8D 10 00
  LDA #$99                                              ; $C8CC: A9 99
  STA $0011                                             ; $C8CE: 8D 11 00
  LDY $04A1                                             ; $C8D1: AC A1 04
  JSR DisplayTileData                                   ; $C8D4: 20 94 C9
  LDA $04A1                                             ; $C8D7: AD A1 04
  CMP #$03                                              ; $C8DA: C9 03
  BEQ L_C8EE                                            ; $C8DC: F0 10
  LDA $04A3                                             ; $C8DE: AD A3 04
  LSR                                                   ; $C8E1: 4A
  LSR                                                   ; $C8E2: 4A
  LSR                                                   ; $C8E3: 4A
  LSR                                                   ; $C8E4: 4A
  LSR                                                   ; $C8E5: 4A
  AND #$03                                              ; $C8E6: 29 03
  CLC                                                   ; $C8E8: 18
  ADC #$01                                              ; $C8E9: 69 01
  STA $04A1                                             ; $C8EB: 8D A1 04
L_C8EE:
  JMP CommonReturn                                      ; $C8EE: 4C 34 C9
  LDA $04A1                                             ; $C8F1: AD A1 04
  BNE L_C904                                            ; $C8F4: D0 0E
  LDA #$AA                                              ; $C8F6: A9 AA
  JSR SetupDisplayPtrs                                  ; $C8F8: 20 6D C9
  LDA #$AB                                              ; $C8FB: A9 AB
  JSR ResetDispatchState                                ; $C8FD: 20 8A C9
  INC $04A1                                             ; $C900: EE A1 04
  RTS                                                   ; $C903: 60

;===============================================================================
L_C904:
; $C904: ActionCalcParams3
;===============================================================================
  LDA #$E4                                              ; $C904: A9 E4
  STA $0010                                             ; $C906: 8D 10 00
  LDA #$9A                                              ; $C909: A9 9A
  STA $0011                                             ; $C90B: 8D 11 00
  LDY $04A1                                             ; $C90E: AC A1 04
  JSR DisplayTileData                                   ; $C911: 20 94 C9
  LDA $04A3                                             ; $C914: AD A3 04
  LSR                                                   ; $C917: 4A
  LSR                                                   ; $C918: 4A
  LSR                                                   ; $C919: 4A
  LSR                                                   ; $C91A: 4A
  AND #$01                                              ; $C91B: 29 01
  STA $04A1                                             ; $C91D: 8D A1 04
  INC $04A1                                             ; $C920: EE A1 04
  JMP CommonReturn                                      ; $C923: 4C 34 C9
  LDA $0140                                             ; $C926: AD 40 01
  BNE L_C933                                            ; $C929: D0 08
  LDA #$00                                              ; $C92B: A9 00
  STA $04A0                                             ; $C92D: 8D A0 04
  STA $04A2                                             ; $C930: 8D A2 04
L_C933:
  RTS                                                   ; $C933: 60

;===============================================================================
; $C934: CommonReturn
;===============================================================================
CommonReturn:
  LDA $04D0                                             ; $C934: AD D0 04
  CMP $04CC                                             ; $C937: CD CC 04
  BCC L_C96C                                            ; $C93A: 90 30
  LDA $04A2                                             ; $C93C: AD A2 04
  BEQ L_C951                                            ; $C93F: F0 10
  CMP #$04                                              ; $C941: C9 04
  BEQ L_C951                                            ; $C943: F0 0C
  CMP #$08                                              ; $C945: C9 08
  BEQ L_C951                                            ; $C947: F0 08
  JSR B1F_BankPpuInit                                         ; $C949: 20 7F E5
  LDA #$81                                              ; $C94C: A9 81
  JSR B1F_SoundWrapperA                                       ; $C94E: 20 73 E6
L_C951:
  LDA #$01                                              ; $C951: A9 01
  STA $007D                                             ; $C953: 8D 7D 00
  LDA #$00                                              ; $C956: A9 00
  STA $0000                                             ; $C958: 8D 00 00
  LDY #$3D                                              ; $C95B: A0 3D
  JSR B1F_BankedCallbackTrampoline                      ; $C95D: 20 07 EE
  ORA $A0,X                                             ; $C960: 15 A0
  LDA #$80                                              ; $C962: A9 80
  STA $0140                                             ; $C964: 8D 40 01
  LDA #$22                                              ; $C967: A9 22
  STA $04A2                                             ; $C969: 8D A2 04
L_C96C:
  RTS                                                   ; $C96C: 60

;===============================================================================
; $C96D: SetupDisplayPtrs
;===============================================================================
SetupDisplayPtrs:
  STA $00BF                                             ; $C96D: 8D BF 00
  STA $00C7                                             ; $C970: 8D C7 00
  STA $00CF                                             ; $C973: 8D CF 00
  LDY #$0C                                              ; $C976: A0 0C
L_C978:
  LDA $0120,Y                                           ; $C978: B9 20 01
  STA $0100,Y                                           ; $C97B: 99 00 01
  LDA $0130,Y                                           ; $C97E: B9 30 01
  STA $0110,Y                                           ; $C981: 99 10 01
  INY                                                   ; $C984: C8
  CPY #$10                                              ; $C985: C0 10
  BCC L_C978                                            ; $C987: 90 EF
  RTS                                                   ; $C989: 60

;===============================================================================
; $C98A: ResetDispatchState
;===============================================================================
ResetDispatchState:
  STA $00C0                                             ; $C98A: 8D C0 00
  STA $00C8                                             ; $C98D: 8D C8 00
  STA $00D0                                             ; $C990: 8D D0 00
  RTS                                                   ; $C993: 60

;===============================================================================
; $C994: DisplayTileData
;===============================================================================
DisplayTileData:
  LDX #$20                                              ; $C994: A2 20
L_C996:
  DEY                                                   ; $C996: 88
  TYA                                                   ; $C997: 98
  ASL                                                   ; $C998: 0A
  TAY                                                   ; $C999: A8
  LDA ($10),Y                                           ; $C99A: B1 10
  STA $0000                                             ; $C99C: 8D 00 00
  INY                                                   ; $C99F: C8
  LDA ($10),Y                                           ; $C9A0: B1 10
  SEC                                                   ; $C9A2: 38
  SBC #$40                                              ; $C9A3: E9 40
  STA $0001                                             ; $C9A5: 8D 01 00
  LDA $0150                                             ; $C9A8: AD 50 01
  BPL L_C9B2                                            ; $C9AB: 10 05
  TXA                                                   ; $C9AD: 8A
  CLC                                                   ; $C9AE: 18
  ADC #$70                                              ; $C9AF: 69 70
  TAX                                                   ; $C9B1: AA
L_C9B2:
  STX $000C                                             ; $C9B2: 8E 0C 00
  LDA #$2F                                              ; $C9B5: A9 2F
  STA $000A                                             ; $C9B7: 8D 0A 00
  LDA #$03                                              ; $C9BA: A9 03
  STA $0002                                             ; $C9BC: 8D 02 00
  JMP B1F_SpriteOamWriterSimple                               ; $C9BF: 4C AD F1
  LDA $04A1                                             ; $C9C2: AD A1 04
  JSR B1F_CallbackDispatcher                            ; $C9C5: 20 DE EA
  INX                                                   ; $C9C8: E8
  CMP #$D0                                              ; $C9C9: C9 D0
  CMP #$4E                                              ; $C9CB: C9 4E
  DEX                                                   ; $C9CD: CA
  .byte $52                                             ; $C9CE: 52
  .byte $CB, $A9 ; $C9CF: CB A9
  ORA ($8D,X)                                           ; $C9D1: 01 8D
  ADC $A000,X                                           ; $C9D3: 7D 00 A0
  .byte $0C                                             ; $C9D6: 0C
  LDA #$0F                                              ; $C9D7: A9 0F
L_C9D9:
  STA $0100,Y                                           ; $C9D9: 99 00 01
  STA $0110,Y                                           ; $C9DC: 99 10 01
  INY                                                   ; $C9DF: C8
  CPY #$10                                              ; $C9E0: C0 10
  BCC L_C9D9                                            ; $C9E2: 90 F5
  INC $04A1                                             ; $C9E4: EE A1 04
  RTS                                                   ; $C9E7: 60

;===============================================================================
; $C9E8: SramSaveBlock
;===============================================================================
  LDA #$40                                              ; $C9E8: A9 40
  STA $0000                                             ; $C9EA: 8D 00 00
  LDA #$CC                                              ; $C9ED: A9 CC
  STA $0001                                             ; $C9EF: 8D 01 00
  LDA $0150                                             ; $C9F2: AD 50 01
  BPL L_CA08                                            ; $C9F5: 10 11
  LDA $0000                                             ; $C9F7: AD 00 00
  CLC                                                   ; $C9FA: 18
  ADC #$1C                                              ; $C9FB: 69 1C
  STA $0000                                             ; $C9FD: 8D 00 00
  LDA $0001                                             ; $CA00: AD 01 00
  ADC #$00                                              ; $CA03: 69 00
  STA $0001                                             ; $CA05: 8D 01 00
L_CA08:
  LDY #$00                                              ; $CA08: A0 00
L_CA0A:
  LDA ($00),Y                                           ; $CA0A: B1 00
  STA $0380,Y                                           ; $CA0C: 99 80 03
  INY                                                   ; $CA0F: C8
  CPY #$1C                                              ; $CA10: C0 1C
  BCC L_CA0A                                            ; $CA12: 90 F6
  LDA #$FF                                              ; $CA14: A9 FF
  STA $0380,Y                                           ; $CA16: 99 80 03
  LDA $007E                                             ; $CA19: AD 7E 00
  ORA #$04                                              ; $CA1C: 09 04
  STA $007E                                             ; $CA1E: 8D 7E 00
  LDA #$78                                              ; $CA21: A9 78
  STA $04D4                                             ; $CA23: 8D D4 04
  LDA #$CC                                              ; $CA26: A9 CC
  STA $04D5                                             ; $CA28: 8D D5 04
  LDX #$02                                              ; $CA2B: A2 02
  LDA $0150                                             ; $CA2D: AD 50 01
  BPL L_CA34                                            ; $CA30: 10 02
  LDX #$10                                              ; $CA32: A2 10
L_CA34:
  STX $04D2                                             ; $CA34: 8E D2 04
  LDA #$02                                              ; $CA37: A9 02
  STA $00C4                                             ; $CA39: 8D C4 00
  STA $00CC                                             ; $CA3C: 8D CC 00
  STA $00D4                                             ; $CA3F: 8D D4 00
  STA $00DC                                             ; $CA42: 8D DC 00
  LDA #$04                                              ; $CA45: A9 04
  STA $04A3                                             ; $CA47: 8D A3 04
  INC $04A1                                             ; $CA4A: EE A1 04
  RTS                                                   ; $CA4D: 60

;===============================================================================
; $CA4E: SramLoadBlock
;===============================================================================
  DEC $04A3                                             ; $CA4E: CE A3 04
  LDA $04A3                                             ; $CA51: AD A3 04
  BPL L_CA59                                            ; $CA54: 10 03
  JMP L_CAC5                                            ; $CA56: 4C C5 CA
L_CA59:
  LDA $04D4                                             ; $CA59: AD D4 04
  STA $0000                                             ; $CA5C: 8D 00 00
  LDA $04D5                                             ; $CA5F: AD D5 04
  STA $0001                                             ; $CA62: 8D 01 00
  LDY #$00                                              ; $CA65: A0 00
  LDX #$00                                              ; $CA67: A2 00
L_CA69:
  LDA #$0E                                              ; $CA69: A9 0E
  STA $0380,X                                           ; $CA6B: 9D 80 03
  INX                                                   ; $CA6E: E8
  LDA ($00),Y                                           ; $CA6F: B1 00
  CMP #$FF                                              ; $CA71: C9 FF
  BNE L_CA7C                                            ; $CA73: D0 07
  DEX                                                   ; $CA75: CA
  STA $0380,X                                           ; $CA76: 9D 80 03
  JMP L_CABC                                            ; $CA79: 4C BC CA
L_CA7C:
  STA $0380,X                                           ; $CA7C: 9D 80 03
  INX                                                   ; $CA7F: E8
  INY                                                   ; $CA80: C8
  LDA ($00),Y                                           ; $CA81: B1 00
  CLC                                                   ; $CA83: 18
  ADC $04D2                                             ; $CA84: 6D D2 04
  STA $0380,X                                           ; $CA87: 9D 80 03
  INX                                                   ; $CA8A: E8
  INY                                                   ; $CA8B: C8
  LDA #$00                                              ; $CA8C: A9 00
  STA $0002                                             ; $CA8E: 8D 02 00
L_CA91:
  LDA ($00),Y                                           ; $CA91: B1 00
  STA $0380,X                                           ; $CA93: 9D 80 03
  INX                                                   ; $CA96: E8
  INY                                                   ; $CA97: C8
  INC $0002                                             ; $CA98: EE 02 00
  LDA $0002                                             ; $CA9B: AD 02 00
  CMP #$0E                                              ; $CA9E: C9 0E
  BCC L_CA91                                            ; $CAA0: 90 EF
  CPY #$50                                              ; $CAA2: C0 50
  BCC L_CA69                                            ; $CAA4: 90 C3
  LDA #$FF                                              ; $CAA6: A9 FF
  STA $0380,X                                           ; $CAA8: 9D 80 03
  LDA $0000                                             ; $CAAB: AD 00 00
  CLC                                                   ; $CAAE: 18
  ADC #$50                                              ; $CAAF: 69 50
  STA $04D4                                             ; $CAB1: 8D D4 04
  LDA $0001                                             ; $CAB4: AD 01 00
  ADC #$00                                              ; $CAB7: 69 00
  STA $04D5                                             ; $CAB9: 8D D5 04
L_CABC:
  LDA $007E                                             ; $CABC: AD 7E 00
  ORA #$04                                              ; $CABF: 09 04
  STA $007E                                             ; $CAC1: 8D 7E 00
  RTS                                                   ; $CAC4: 60

;===============================================================================
L_CAC5:
; $CAC5: VerifyChecksum
;===============================================================================
  LDA #$20                                              ; $CAC5: A9 20
  STA $04D3                                             ; $CAC7: 8D D3 04
  LDX #$C4                                              ; $CACA: A2 C4
  LDA $0150                                             ; $CACC: AD 50 01
  BPL L_CAD3                                            ; $CACF: 10 02
  LDX #$D2                                              ; $CAD1: A2 D2
L_CAD3:
  STX $04D2                                             ; $CAD3: 8E D2 04
  LDX $04A2                                             ; $CAD6: AE A2 04
  STX $0003                                             ; $CAD9: 8E 03 00
  LDA #$6C                                              ; $CADC: A9 6C
  STA $0000                                             ; $CADE: 8D 00 00
  LDA #$00                                              ; $CAE1: A9 00
  STA $0001                                             ; $CAE3: 8D 01 00
  STA $0002                                             ; $CAE6: 8D 02 00
  JSR B1F_MathMul24x8                                   ; $CAE9: 20 E9 EB
  LDA #$59                                              ; $CAEC: A9 59
  CLC                                                   ; $CAEE: 18
  ADC $0006                                             ; $CAEF: 6D 06 00
  STA $0000                                             ; $CAF2: 8D 00 00
  LDA #$CD                                              ; $CAF5: A9 CD
  ADC $0007                                             ; $CAF7: 6D 07 00
  STA $0001                                             ; $CAFA: 8D 01 00
  LDY #$00                                              ; $CAFD: A0 00
  LDA ($00),Y                                           ; $CAFF: B1 00
  STA $00C3                                             ; $CB01: 8D C3 00
  STA $00CB                                             ; $CB04: 8D CB 00
  STA $00D3                                             ; $CB07: 8D D3 00
  INY                                                   ; $CB0A: C8
  LDA ($00),Y                                           ; $CB0B: B1 00
  STA $00C2                                             ; $CB0D: 8D C2 00
  STA $00CA                                             ; $CB10: 8D CA 00
  STA $00D2                                             ; $CB13: 8D D2 00
  INY                                                   ; $CB16: C8
  LDX #$0D                                              ; $CB17: A2 0D
L_CB19:
  LDA ($00),Y                                           ; $CB19: B1 00
  STA $0120,X                                           ; $CB1B: 9D 20 01
  INX                                                   ; $CB1E: E8
  INY                                                   ; $CB1F: C8
  CPY #$05                                              ; $CB20: C0 05
  BCC L_CB19                                            ; $CB22: 90 F5
  LDX #$1D                                              ; $CB24: A2 1D
L_CB26:
  LDA ($00),Y                                           ; $CB26: B1 00
  STA $0120,X                                           ; $CB28: 9D 20 01
  INX                                                   ; $CB2B: E8
  INY                                                   ; $CB2C: C8
  CPY #$08                                              ; $CB2D: C0 08
  BCC L_CB26                                            ; $CB2F: 90 F5
  LDA #$0F                                              ; $CB31: A9 0F
  STA $010C                                             ; $CB33: 8D 0C 01
  STA $011C                                             ; $CB36: 8D 1C 01
  TYA                                                   ; $CB39: 98
  CLC                                                   ; $CB3A: 18
  ADC $0000                                             ; $CB3B: 6D 00 00
  STA $04D4                                             ; $CB3E: 8D D4 04
  LDA #$00                                              ; $CB41: A9 00
  ADC $0001                                             ; $CB43: 6D 01 00
  STA $04D5                                             ; $CB46: 8D D5 04
  LDA #$01                                              ; $CB49: A9 01
  STA $04A3                                             ; $CB4B: 8D A3 04
  INC $04A1                                             ; $CB4E: EE A1 04
  RTS                                                   ; $CB51: 60

;===============================================================================
; $CB52: OfficerRecCalc
;===============================================================================
  LDA $04D2                                             ; $CB52: AD D2 04
  STA $0002                                             ; $CB55: 8D 02 00
  LDA $04D3                                             ; $CB58: AD D3 04
  STA $0003                                             ; $CB5B: 8D 03 00
  LDA $04D4                                             ; $CB5E: AD D4 04
  STA $0000                                             ; $CB61: 8D 00 00
  LDA $04D5                                             ; $CB64: AD D5 04
  STA $0001                                             ; $CB67: 8D 01 00
  LDX #$00                                              ; $CB6A: A2 00
  LDY #$00                                              ; $CB6C: A0 00
L_CB6E:
  LDA #$0A                                              ; $CB6E: A9 0A
  STA $0380,X                                           ; $CB70: 9D 80 03
  INX                                                   ; $CB73: E8
  LDA $0003                                             ; $CB74: AD 03 00
  STA $0380,X                                           ; $CB77: 9D 80 03
  INX                                                   ; $CB7A: E8
  LDA $0002                                             ; $CB7B: AD 02 00
  STA $0380,X                                           ; $CB7E: 9D 80 03
  INX                                                   ; $CB81: E8
  LDY #$00                                              ; $CB82: A0 00
L_CB84:
  LDA ($00),Y                                           ; $CB84: B1 00
  STA $0380,X                                           ; $CB86: 9D 80 03
  INX                                                   ; $CB89: E8
  INY                                                   ; $CB8A: C8
  CPY #$0A                                              ; $CB8B: C0 0A
  BCC L_CB84                                            ; $CB8D: 90 F5
  LDA $0000                                             ; $CB8F: AD 00 00
  CLC                                                   ; $CB92: 18
  ADC #$0A                                              ; $CB93: 69 0A
  STA $0000                                             ; $CB95: 8D 00 00
  LDA $0001                                             ; $CB98: AD 01 00
  ADC #$00                                              ; $CB9B: 69 00
  STA $0001                                             ; $CB9D: 8D 01 00
  LDA $0002                                             ; $CBA0: AD 02 00
  CLC                                                   ; $CBA3: 18
  ADC #$20                                              ; $CBA4: 69 20
  STA $0002                                             ; $CBA6: 8D 02 00
  LDA $0003                                             ; $CBA9: AD 03 00
  ADC #$00                                              ; $CBAC: 69 00
  STA $0003                                             ; $CBAE: 8D 03 00
  CPX #$41                                              ; $CBB1: E0 41
  BCC L_CB6E                                            ; $CBB3: 90 B9
  LDA #$FF                                              ; $CBB5: A9 FF
  STA $0380,X                                           ; $CBB7: 9D 80 03
  LDA $0002                                             ; $CBBA: AD 02 00
  STA $04D2                                             ; $CBBD: 8D D2 04
  LDA $0003                                             ; $CBC0: AD 03 00
  STA $04D3                                             ; $CBC3: 8D D3 04
  LDA $0000                                             ; $CBC6: AD 00 00
  STA $04D4                                             ; $CBC9: 8D D4 04
  LDA $0001                                             ; $CBCC: AD 01 00
  STA $04D5                                             ; $CBCF: 8D D5 04
  DEC $04A3                                             ; $CBD2: CE A3 04
  LDA $04A3                                             ; $CBD5: AD A3 04
  BPL L_CC00                                            ; $CBD8: 10 26
  LDA $04A2                                             ; $CBDA: AD A2 04
  CMP #$04                                              ; $CBDD: C9 04
  BEQ L_CBEB                                            ; $CBDF: F0 0A
  CMP #$05                                              ; $CBE1: C9 05
  BEQ L_CBEB                                            ; $CBE3: F0 06
  JSR B1F_BankPpuInit                                         ; $CBE5: 20 7F E5
  JSR L_CC09                                            ; $CBE8: 20 09 CC
L_CBEB:
  LDA #$81                                              ; $CBEB: A9 81
  STA $04A0                                             ; $CBED: 8D A0 04
  LDA #$FF                                              ; $CBF0: A9 FF
  STA $04CC                                             ; $CBF2: 8D CC 04
  LDA #$00                                              ; $CBF5: A9 00
  STA $04A1                                             ; $CBF7: 8D A1 04
  STA $04A3                                             ; $CBFA: 8D A3 04
  STA $04D0                                             ; $CBFD: 8D D0 04
L_CC00:
  LDA $007E                                             ; $CC00: AD 7E 00
  ORA #$04                                              ; $CC03: 09 04
  STA $007E                                             ; $CC05: 8D 7E 00
  RTS                                                   ; $CC08: 60

;===============================================================================
L_CC09:
; $CC09: ProvinceRecCalc
;===============================================================================
  LDA $04D6                                             ; $CC09: AD D6 04
  CMP #$32                                              ; $CC0C: C9 32
  BEQ L_CC3D                                            ; $CC0E: F0 2D
  CMP #$47                                              ; $CC10: C9 47
  BEQ L_CC3D                                            ; $CC12: F0 29
  CMP #$2E                                              ; $CC14: C9 2E
  BEQ L_CC3A                                            ; $CC16: F0 22
  CMP #$3E                                              ; $CC18: C9 3E
  BEQ L_CC3A                                            ; $CC1A: F0 1E
  CMP #$52                                              ; $CC1C: C9 52
  BEQ L_CC3A                                            ; $CC1E: F0 1A
  CMP #$A2                                              ; $CC20: C9 A2
  BEQ L_CC3A                                            ; $CC22: F0 16
  CMP #$A6                                              ; $CC24: C9 A6
  BEQ L_CC3A                                            ; $CC26: F0 12
  CMP #$38                                              ; $CC28: C9 38
  BEQ L_CC37                                            ; $CC2A: F0 0B
  CMP #$3B                                              ; $CC2C: C9 3B
  BEQ L_CC37                                            ; $CC2E: F0 07
  CMP #$9F                                              ; $CC30: C9 9F
  BEQ L_CC37                                            ; $CC32: F0 03
  JMP B1F_SoundWrapperC                                       ; $CC34: 4C 83 E6
L_CC37:
  JMP B1F_SoundWrapperE                                       ; $CC37: 4C 93 E6
L_CC3A:
  JMP B1F_SoundWrapperD                                       ; $CC3A: 4C 8B E6
L_CC3D:
  JMP B1F_SoundWrapperB                                       ; $CC3D: 4C 7B E6
  .byte $04, $23                                        ; $CC40: 04 23
  INY                                                   ; $CC42: C8
  STA $FAFA,Y                                           ; $CC43: 99 FA FA
  TSX                                                   ; $CC46: BA
  .byte $04, $23                                        ; $CC47: 04 23
  .byte $D0, $99 ; $CC49: D0 99
  .byte $FF, $FF, $BB ; $CC4B: FF FF BB
  .byte $04, $23                                        ; $CC4E: 04 23
  CLD                                                   ; $CC50: D8
  STA $FFFF,Y                                           ; $CC51: 99 FF FF
  .byte $BB, $04, $23 ; $CC54: BB 04 23
  CPX #$59                                              ; $CC57: E0 59
  NOP                                                   ; $CC59: 5A
  NOP                                                   ; $CC5A: 5A
  ASL                                                   ; $CC5B: 0A
  .byte $04, $23                                        ; $CC5C: 04 23
  CPY $FAEA                                             ; $CC5E: CC EA FA
  NOP                                                   ; $CC61: FA
  .byte $22, $04, $23, $D4                              ; $CC62: 22 04 23 D4
  INC $FFFF                                             ; $CC66: EE FF FF
  .byte $22, $04, $23, $DC                              ; $CC69: 22 04 23 DC
  INC $FFFF                                             ; $CC6D: EE FF FF
  .byte $22, $04, $23                                   ; $CC70: 22 04 23
  CPX $0A                                               ; $CC73: E4 0A
  ASL                                                   ; $CC75: 0A
  ASL                                                   ; $CC76: 0A
  .byte $02                                             ; $CC77: 02
  JSR $9B80                                             ; $CC78: 20 80 9B
  .byte $9C, $BE, $BF ; $CC7B: 9C BE BF
  STY $84                                               ; $CC7E: 84 84
  STY $84                                               ; $CC80: 84 84
  STY $84                                               ; $CC82: 84 84
  STA $86                                               ; $CC84: 85 86
  .byte $87                                             ; $CC86: 87
  DEY                                                   ; $CC87: 88
  JSR $89A0                                             ; $CC88: 20 A0 89
  TXA                                                   ; $CC8B: 8A
  .byte $8B, $8C ; $CC8C: 8B 8C
  STY $8C8C                                             ; $CC8E: 8C 8C 8C
  STY $8C8C                                             ; $CC91: 8C 8C 8C
  STY $8E8D                                             ; $CC94: 8C 8D 8E
  .byte $8F                                             ; $CC97: 8F
  JSR $90C0                                             ; $CC98: 20 C0 90
  STA ($00),Y                                           ; $CC9B: 91 00
  BRK                                                   ; $CC9D: 00
  BRK                                                   ; $CC9E: 00
  BRK                                                   ; $CC9F: 00
  BRK                                                   ; $CCA0: 00
  BRK                                                   ; $CCA1: 00
  BRK                                                   ; $CCA2: 00
  BRK                                                   ; $CCA3: 00
  BRK                                                   ; $CCA4: 00
  BRK                                                   ; $CCA5: 00
  .byte $92, $93                                        ; $CCA6: 92 93
  JSR $94E0                                             ; $CCA8: 20 E0 94
  STA ($00),Y                                           ; $CCAB: 91 00
  BRK                                                   ; $CCAD: 00
  BRK                                                   ; $CCAE: 00
  BRK                                                   ; $CCAF: 00
  BRK                                                   ; $CCB0: 00
  BRK                                                   ; $CCB1: 00
  BRK                                                   ; $CCB2: 00
  BRK                                                   ; $CCB3: 00
  BRK                                                   ; $CCB4: 00
  BRK                                                   ; $CCB5: 00
  .byte $92                                             ; $CCB6: 92
  STA $21,X                                             ; $CCB7: 95 21
  BRK                                                   ; $CCB9: 00
  STX $97,Y                                             ; $CCBA: 96 97
  BRK                                                   ; $CCBC: 00
  BRK                                                   ; $CCBD: 00
  BRK                                                   ; $CCBE: 00
  BRK                                                   ; $CCBF: 00
  BRK                                                   ; $CCC0: 00
  BRK                                                   ; $CCC1: 00
  BRK                                                   ; $CCC2: 00
  BRK                                                   ; $CCC3: 00
  BRK                                                   ; $CCC4: 00
  BRK                                                   ; $CCC5: 00
  TYA                                                   ; $CCC6: 98
  STA $2021,Y                                           ; $CCC7: 99 21 20
  STX $97,Y                                             ; $CCCA: 96 97
  BRK                                                   ; $CCCC: 00
  BRK                                                   ; $CCCD: 00
  BRK                                                   ; $CCCE: 00
  BRK                                                   ; $CCCF: 00
  BRK                                                   ; $CCD0: 00
  BRK                                                   ; $CCD1: 00
  BRK                                                   ; $CCD2: 00
  BRK                                                   ; $CCD3: 00
  BRK                                                   ; $CCD4: 00
  BRK                                                   ; $CCD5: 00
  TYA                                                   ; $CCD6: 98
  STA $4021,Y                                           ; $CCD7: 99 21 40
  STX $97,Y                                             ; $CCDA: 96 97
  BRK                                                   ; $CCDC: 00
  BRK                                                   ; $CCDD: 00
  BRK                                                   ; $CCDE: 00
  BRK                                                   ; $CCDF: 00
  BRK                                                   ; $CCE0: 00
  BRK                                                   ; $CCE1: 00
  BRK                                                   ; $CCE2: 00
  BRK                                                   ; $CCE3: 00
  BRK                                                   ; $CCE4: 00
  BRK                                                   ; $CCE5: 00
  TYA                                                   ; $CCE6: 98
  STA $6021,Y                                           ; $CCE7: 99 21 60

;===============================================================================
; $CCEA: CopyBlockLoop
;===============================================================================
  .byte $96, $97                                        ; $CCEA: 96 97
  BRK                                                   ; $CCEC: 00
  BRK                                                   ; $CCED: 00
  BRK                                                   ; $CCEE: 00
  BRK                                                   ; $CCEF: 00
  BRK                                                   ; $CCF0: 00
  BRK                                                   ; $CCF1: 00
  BRK                                                   ; $CCF2: 00
  BRK                                                   ; $CCF3: 00
  BRK                                                   ; $CCF4: 00
  BRK                                                   ; $CCF5: 00
  TYA                                                   ; $CCF6: 98
  STA $8021,Y                                           ; $CCF7: 99 21 80
  STX $97,Y                                             ; $CCFA: 96 97
  BRK                                                   ; $CCFC: 00
  BRK                                                   ; $CCFD: 00
  BRK                                                   ; $CCFE: 00
  BRK                                                   ; $CCFF: 00
  BRK                                                   ; $CD00: 00
  BRK                                                   ; $CD01: 00
  BRK                                                   ; $CD02: 00
  BRK                                                   ; $CD03: 00
  BRK                                                   ; $CD04: 00
  BRK                                                   ; $CD05: 00
  TYA                                                   ; $CD06: 98
  STA $A021,Y                                           ; $CD07: 99 21 A0
  STX $97,Y                                             ; $CD0A: 96 97
  BRK                                                   ; $CD0C: 00
  BRK                                                   ; $CD0D: 00
  BRK                                                   ; $CD0E: 00
  BRK                                                   ; $CD0F: 00
  BRK                                                   ; $CD10: 00
  BRK                                                   ; $CD11: 00
  BRK                                                   ; $CD12: 00
  BRK                                                   ; $CD13: 00
  BRK                                                   ; $CD14: 00
  BRK                                                   ; $CD15: 00
  TYA                                                   ; $CD16: 98
  STA $C021,Y                                           ; $CD17: 99 21 C0
  TXS                                                   ; $CD1A: 9A
  .byte $97                                             ; $CD1B: 97
  BRK                                                   ; $CD1C: 00
  BRK                                                   ; $CD1D: 00
  BRK                                                   ; $CD1E: 00
  BRK                                                   ; $CD1F: 00
  BRK                                                   ; $CD20: 00
  BRK                                                   ; $CD21: 00
  BRK                                                   ; $CD22: 00
  BRK                                                   ; $CD23: 00
  BRK                                                   ; $CD24: 00
  BRK                                                   ; $CD25: 00
  TYA                                                   ; $CD26: 98
  STA $E021,X                                           ; $CD27: 9D 21 E0
  .byte $9E, $97, $00 ; $CD2A: 9E 97 00
  BRK                                                   ; $CD2D: 00
  BRK                                                   ; $CD2E: 00
  BRK                                                   ; $CD2F: 00
  BRK                                                   ; $CD30: 00
  BRK                                                   ; $CD31: 00
  BRK                                                   ; $CD32: 00
  BRK                                                   ; $CD33: 00
  BRK                                                   ; $CD34: 00
  BRK                                                   ; $CD35: 00
  TYA                                                   ; $CD36: 98
  .byte $9F, $22, $00 ; $CD37: 9F 22 00
  LDY #$A1                                              ; $CD3A: A0 A1
  LDX #$A3                                              ; $CD3C: A2 A3
  .byte $A3, $A3, $A3, $A3, $A3, $A3, $A3               ; $CD3E: A3 A3 A3 A3 A3 A3 A3
  LDY $A5                                               ; $CD45: A4 A5
  LDX $22                                               ; $CD47: A6 22
  JSR $A8A7                                             ; $CD49: 20 A7 A8
  LDA #$AA                                              ; $CD4C: A9 AA
  .byte $AB, $AB ; $CD4E: AB AB
  .byte $AB, $AB ; $CD50: AB AB
  .byte $AB, $AB ; $CD52: AB AB
  LDY $AEAD                                             ; $CD54: AC AD AE
  .byte $AF                                             ; $CD57: AF
  .byte $FF, $C4, $00 ; $CD58: FF C4 00
  ROL $26,X                                             ; $CD5B: 36 26
  .byte $17                                             ; $CD5D: 17
  ASL $07,X                                             ; $CD5E: 16 07
  .byte $17                                             ; $CD60: 17
  ROR $7E7E,X                                           ; $CD61: 7E 7E 7E
  ROR $7E7E,X                                           ; $CD64: 7E 7E 7E
  ROR $7E7E,X                                           ; $CD67: 7E 7E 7E
  ROR $7E7E,X                                           ; $CD6A: 7E 7E 7E
  ROR $4140,X                                           ; $CD6D: 7E 40 41
  .byte $42                                             ; $CD70: 42
  ROR $7E7E,X                                           ; $CD71: 7E 7E 7E
  ROR $7E7E,X                                           ; $CD74: 7E 7E 7E
  ROR $4443,X                                           ; $CD77: 7E 43 44
  EOR $46                                               ; $CD7A: 45 46
  .byte $47                                             ; $CD7C: 47
  PHA                                                   ; $CD7D: 48
  ROR $7E7E,X                                           ; $CD7E: 7E 7E 7E
  ROR $4A49,X                                           ; $CD81: 7E 49 4A
  .byte $4B, $4C ; $CD84: 4B 4C
  EOR $7E4E                                             ; $CD86: 4D 4E 7E
  ROR $504F,X                                           ; $CD89: 7E 4F 50
  EOR ($52),Y                                           ; $CD8C: 51 52
  .byte $53, $54                                        ; $CD8E: 53 54
  EOR $56,X                                             ; $CD90: 55 56
  ROR $587E,X                                           ; $CD92: 7E 7E 58
  EOR $5B5A,Y                                           ; $CD95: 59 5A 5B
  .byte $5C                                             ; $CD98: 5C
  EOR $5F5E,X                                           ; $CD99: 5D 5E 5F
  ROR $7E7E,X                                           ; $CD9C: 7E 7E 7E
  RTS                                                   ; $CD9F: 60

;===============================================================================
; $CDA0: MultiRecCalc
;===============================================================================
  .byte $61, $62, $63, $64, $65, $66, $7E, $7E, $7E, $67 ; $CDA0: 61 62 63 64 65 66 7E 7E 7E 67
  PLA                                                   ; $CDAA: 68
  ADC #$6A                                              ; $CDAB: 69 6A
  .byte $6B, $6C ; $CDAD: 6B 6C
  ADC $7E6E                                             ; $CDAF: 6D 6E 7E
  ROR $706F,X                                           ; $CDB2: 7E 6F 70
  ADC ($72),Y                                           ; $CDB5: 71 72
  .byte $73, $74                                        ; $CDB7: 73 74
  ADC $7E,X                                             ; $CDB9: 75 7E
  ROR $767E,X                                           ; $CDBB: 7E 7E 76
  .byte $77                                             ; $CDBE: 77
  SEI                                                   ; $CDBF: 78
  ADC $7B7A,Y                                           ; $CDC0: 79 7A 7B
  .byte $7C                                             ; $CDC3: 7C
  ADC $00C9,X                                           ; $CDC4: 7D C9 00
  ROL $16,X                                             ; $CDC7: 36 16
  ROL $36                                               ; $CDC9: 26 36
  ASL $26,X                                             ; $CDCB: 16 26
  ORA ($01,X)                                           ; $CDCD: 01 01
  ORA ($01,X)                                           ; $CDCF: 01 01
  RTI                                                   ; $CDD1: 40
  EOR ($52,X)                                           ; $CDD2: 41 52
  .byte $53                                             ; $CDD4: 53
  ORA ($01,X)                                           ; $CDD5: 01 01
  ORA ($01,X)                                           ; $CDD7: 01 01
  ORA ($01,X)                                           ; $CDD9: 01 01
  .byte $67                                             ; $CDDB: 67
  .byte $6B, $00 ; $CDDC: 6B 00
  ADC ($01),Y                                           ; $CDDE: 71 01
  ORA ($01,X)                                           ; $CDE0: 01 01
  ORA ($01,X)                                           ; $CDE2: 01 01
  ORA ($00,X)                                           ; $CDE4: 01 00
  BRK                                                   ; $CDE6: 00
  .byte $72, $73, $42                                   ; $CDE7: 72 73 42
  ORA ($01,X)                                           ; $CDEA: 01 01
  ORA ($01,X)                                           ; $CDEC: 01 01
  .byte $43                                             ; $CDEE: 43
  BRK                                                   ; $CDEF: 00
  BRK                                                   ; $CDF0: 00
  BRK                                                   ; $CDF1: 00
  .byte $44                                             ; $CDF2: 44
  EOR $46                                               ; $CDF3: 45 46
  ORA ($47,X)                                           ; $CDF5: 01 47
  PHA                                                   ; $CDF7: 48
  EOR #$00                                              ; $CDF8: 49 00
  BRK                                                   ; $CDFA: 00
  LSR                                                   ; $CDFB: 4A
  .byte $02, $02, $02                                   ; $CDFC: 02 02 02
  JMP $4E4D                                             ; $CDFF: 4C 4D 4E
  .byte $4F                                             ; $CE02: 4F
  BVC L_CE07                                            ; $CE03: 50 02
  .byte $02, $02                                        ; $CE05: 02 02
L_CE07:
  .byte $02, $54                                        ; $CE07: 02 54
  EOR $56,X                                             ; $CE09: 55 56
  .byte $57                                             ; $CE0B: 57
  CLI                                                   ; $CE0C: 58
  EOR $024B,Y                                           ; $CE0D: 59 4B 02
  NOP                                                   ; $CE10: 5A
  .byte $5B, $5C                                        ; $CE11: 5B 5C
  EOR $5F5E,X                                           ; $CE13: 5D 5E 5F
  RTS                                                   ; $CE16: 60

;===============================================================================
; $CE17: BattleParamSetup
;===============================================================================
  .byte $61, $62, $63, $64, $65, $66, $03, $5D          ; $CE17: 61 62 63 64 65 66 03 5D
  PLA                                                   ; $CE1F: 68
  ADC #$6A                                              ; $CE20: 69 6A
  .byte $03                                             ; $CE22: 03
  JMP ($6E6D)                                           ; $CE23: 6C 6D 6E
  .byte $6F, $03, $03                                   ; $CE26: 6F 03 03
  BVS L_CE2E                                            ; $CE29: 70 03
  .byte $03, $03, $74                                   ; $CE2B: 03 03 74
L_CE2E:
  EOR ($75),Y                                           ; $CE2E: 51 75
  ROR $E0,X                                             ; $CE30: 76 E0
  BRK                                                   ; $CE32: 00
  BMI L_CE45                                            ; $CE33: 30 10
  .byte $17                                             ; $CE35: 17
  ASL $10,X                                             ; $CE36: 16 10
  .byte $17                                             ; $CE38: 17
  RTI                                                   ; $CE39: 40
  RTI                                                   ; $CE3A: 40
  RTI                                                   ; $CE3B: 40
  RTI                                                   ; $CE3C: 40
  RTI                                                   ; $CE3D: 40
  RTI                                                   ; $CE3E: 40
  RTI                                                   ; $CE3F: 40
  RTI                                                   ; $CE40: 40
  RTI                                                   ; $CE41: 40
  RTI                                                   ; $CE42: 40
  EOR ($42,X)                                           ; $CE43: 41 42
L_CE45:
  RTI                                                   ; $CE45: 40
  RTI                                                   ; $CE46: 40
  RTI                                                   ; $CE47: 40
  RTI                                                   ; $CE48: 40
  RTI                                                   ; $CE49: 40
  RTI                                                   ; $CE4A: 40
  RTI                                                   ; $CE4B: 40
  RTI                                                   ; $CE4C: 40
  .byte $43, $44                                        ; $CE4D: 43 44
  EOR $75                                               ; $CE4F: 45 75
  ADC $46,X                                             ; $CE51: 75 46
  .byte $47                                             ; $CE53: 47
  PHA                                                   ; $CE54: 48
  RTI                                                   ; $CE55: 40
  RTI                                                   ; $CE56: 40
  .byte $53                                             ; $CE57: 53
  EOR #$4A                                              ; $CE58: 49 4A
  .byte $4B, $53 ; $CE5A: 4B 53
  .byte $53, $53                                        ; $CE5C: 53 53
  JMP $4E4D                                             ; $CE5E: 4C 4D 4E
  .byte $53, $4F                                        ; $CE61: 53 4F
  BVC L_CEB6                                            ; $CE63: 50 51
  .byte $52, $53, $53, $53, $53, $53, $53, $53, $54     ; $CE65: 52 53 53 53 53 53 53 53 54
  EOR $56,X                                             ; $CE6E: 55 56
  .byte $57                                             ; $CE70: 57
  CLI                                                   ; $CE71: 58
  .byte $53, $53, $53, $53, $53                         ; $CE72: 53 53 53 53 53
  EOR $5B5A,Y                                           ; $CE77: 59 5A 5B
  .byte $5C                                             ; $CE7A: 5C
  EOR $5F5E,X                                           ; $CE7B: 5D 5E 5F
  RTS                                                   ; $CE7E: 60

;===============================================================================
; $CE7F: DiplomacyParamSetup
;===============================================================================
  .byte $53, $53, $53, $61, $62, $63, $64, $65, $66, $67, $53, $53, $53 ; $CE7F: 53 53 53 61 62 63 64 65 66 67 53 53 53
  PLA                                                   ; $CE8C: 68
  ADC #$6A                                              ; $CE8D: 69 6A
  .byte $6B, $6C ; $CE8F: 6B 6C
  ADC $536E                                             ; $CE91: 6D 6E 53
  .byte $53, $53, $6F                                   ; $CE94: 53 53 6F
  .byte $70, $71 ; $CE97: 70 71
  .byte $72, $73, $74                                   ; $CE99: 72 73 74
  ADC $C7,X                                             ; $CE9C: 75 C7
  CMP $30                                               ; $CE9E: C5 30
  ASL $36,X                                             ; $CEA0: 16 36
  BMI L_CEBA                                            ; $CEA2: 30 16
  ROL $41,X                                             ; $CEA4: 36 41
  EOR ($41,X)                                           ; $CEA6: 41 41
  EOR ($41,X)                                           ; $CEA8: 41 41
  EOR ($41,X)                                           ; $CEAA: 41 41
  EOR ($41,X)                                           ; $CEAC: 41 41
  EOR ($41,X)                                           ; $CEAE: 41 41
  RTI                                                   ; $CEB0: 40
  RTI                                                   ; $CEB1: 40
  RTI                                                   ; $CEB2: 40
  EOR ($41,X)                                           ; $CEB3: 41 41
  .byte $42                                             ; $CEB5: 42
L_CEB6:
  .byte $43, $44                                        ; $CEB6: 43 44
  EOR ($41,X)                                           ; $CEB8: 41 41
L_CEBA:
  RTI                                                   ; $CEBA: 40
  RTI                                                   ; $CEBB: 40
  RTI                                                   ; $CEBC: 40
  EOR ($41,X)                                           ; $CEBD: 41 41
  EOR $46                                               ; $CEBF: 45 46
  .byte $47                                             ; $CEC1: 47
  EOR ($41,X)                                           ; $CEC2: 41 41
  RTI                                                   ; $CEC4: 40
  RTI                                                   ; $CEC5: 40
  RTI                                                   ; $CEC6: 40
  PHA                                                   ; $CEC7: 48
  EOR #$40                                              ; $CEC8: 49 40
  LSR                                                   ; $CECA: 4A
  .byte $4B, $41 ; $CECB: 4B 41
  JMP $404D                                             ; $CECD: 4C 4D 40
  RTI                                                   ; $CED0: 40
  LSR $504F                                             ; $CED1: 4E 4F 50
  EOR ($52),Y                                           ; $CED4: 51 52
  .byte $53, $54                                        ; $CED6: 53 54
  EOR $56,X                                             ; $CED8: 55 56
  .byte $57                                             ; $CEDA: 57
  CLI                                                   ; $CEDB: 58
  EOR $5B5A,Y                                           ; $CEDC: 59 5A 5B
  .byte $5C                                             ; $CEDF: 5C
  EOR $5F5E,X                                           ; $CEE0: 5D 5E 5F
  RTS                                                   ; $CEE3: 60

;===============================================================================
; $CEE4: WarParamSetup
;===============================================================================
  .byte $61, $62, $63, $64, $65, $66, $67               ; $CEE4: 61 62 63 64 65 66 67
  PLA                                                   ; $CEEB: 68
  ADC #$6A                                              ; $CEEC: 69 6A
  .byte $6B, $6C ; $CEEE: 6B 6C
  ADC $6F6E                                             ; $CEF0: 6D 6E 6F
  BVS L_CF66                                            ; $CEF3: 70 71
  .byte $72, $73, $74                                   ; $CEF5: 72 73 74
  ADC $76,X                                             ; $CEF8: 75 76
  .byte $77                                             ; $CEFA: 77
  SEI                                                   ; $CEFB: 78
  ADC $7B7A,Y                                           ; $CEFC: 79 7A 7B
  EOR ($7C,X)                                           ; $CEFF: 41 7C
  ADC $7F7E,X                                           ; $CF01: 7D 7E 7F
  AND $3B3A,Y                                           ; $CF04: 39 3A 3B
  .byte $3C                                             ; $CF07: 3C
  AND $00B8,X                                           ; $CF08: 3D B8 00
  BPL L_CF43                                            ; $CF0B: 10 36
  .byte $17                                             ; $CF0D: 17
  BPL L_CF46                                            ; $CF0E: 10 36
  .byte $17                                             ; $CF10: 17
  RTI                                                   ; $CF11: 40
  RTI                                                   ; $CF12: 40
  RTI                                                   ; $CF13: 40
  RTI                                                   ; $CF14: 40
  RTI                                                   ; $CF15: 40
  RTI                                                   ; $CF16: 40
  RTI                                                   ; $CF17: 40
  RTI                                                   ; $CF18: 40
  RTI                                                   ; $CF19: 40
  RTI                                                   ; $CF1A: 40
  RTI                                                   ; $CF1B: 40
  RTI                                                   ; $CF1C: 40
  RTI                                                   ; $CF1D: 40
  RTI                                                   ; $CF1E: 40
  RTI                                                   ; $CF1F: 40
  RTI                                                   ; $CF20: 40
  .byte $42, $43                                        ; $CF21: 42 43
  RTI                                                   ; $CF23: 40
  RTI                                                   ; $CF24: 40
  RTI                                                   ; $CF25: 40
  .byte $44                                             ; $CF26: 44
  RTI                                                   ; $CF27: 40
  RTI                                                   ; $CF28: 40
  RTI                                                   ; $CF29: 40
  RTI                                                   ; $CF2A: 40
  EOR $46                                               ; $CF2B: 45 46
  .byte $47                                             ; $CF2D: 47
  PHA                                                   ; $CF2E: 48
  BRK                                                   ; $CF2F: 00
  EOR #$4A                                              ; $CF30: 49 4A
  BRK                                                   ; $CF32: 00
  BRK                                                   ; $CF33: 00
  BRK                                                   ; $CF34: 00
  .byte $4B, $4C ; $CF35: 4B 4C
  BRK                                                   ; $CF37: 00
  EOR $4E00                                             ; $CF38: 4D 00 4E
  BRK                                                   ; $CF3B: 00
  .byte $4F                                             ; $CF3C: 4F
  BRK                                                   ; $CF3D: 00
  BRK                                                   ; $CF3E: 00
  BRK                                                   ; $CF3F: 00
  BVC L_CF93                                            ; $CF40: 50 51
  .byte $52                                             ; $CF42: 52
L_CF43:
  BRK                                                   ; $CF43: 00
  BRK                                                   ; $CF44: 00
  BRK                                                   ; $CF45: 00
L_CF46:
  .byte $53, $54                                        ; $CF46: 53 54
  EOR $56,X                                             ; $CF48: 55 56
  .byte $57                                             ; $CF4A: 57
  CLI                                                   ; $CF4B: 58
  EOR $5B5A,Y                                           ; $CF4C: 59 5A 5B
  .byte $5C                                             ; $CF4F: 5C
  EOR $5F5E,X                                           ; $CF50: 5D 5E 5F
  RTS                                                   ; $CF53: 60

;===============================================================================
; $CF54: SpyParamSetup
;===============================================================================
  .byte $61, $62, $63, $64, $65, $66, $67               ; $CF54: 61 62 63 64 65 66 67
  PLA                                                   ; $CF5B: 68
  ADC #$6A                                              ; $CF5C: 69 6A
  .byte $6B, $6C ; $CF5E: 6B 6C
  ADC $6F6E                                             ; $CF60: 6D 6E 6F
  .byte $70, $71 ; $CF63: 70 71
  .byte $72                                             ; $CF65: 72
L_CF66:
  .byte $73, $74                                        ; $CF66: 73 74
  ADC $76,X                                             ; $CF68: 75 76
  .byte $77                                             ; $CF6A: 77
  EOR ($41,X)                                           ; $CF6B: 41 41
  SEI                                                   ; $CF6D: 78
  ADC $7B7A,Y                                           ; $CF6E: 79 7A 7B
  EOR ($7C,X)                                           ; $CF71: 41 7C
  ADC $C37E,X                                           ; $CF73: 7D 7E C3
  BRK                                                   ; $CF76: 00
  AND ($36),Y                                           ; $CF77: 31 36
  .byte $17                                             ; $CF79: 17
  AND ($36),Y                                           ; $CF7A: 31 36
  .byte $17                                             ; $CF7C: 17
  EOR ($41,X)                                           ; $CF7D: 41 41
  .byte $42, $43, $44                                   ; $CF7F: 42 43 44
  RTI                                                   ; $CF82: 40
  RTI                                                   ; $CF83: 40
  RTI                                                   ; $CF84: 40
  RTI                                                   ; $CF85: 40
  EOR ($41,X)                                           ; $CF86: 41 41
  EOR ($45,X)                                           ; $CF88: 41 45
  LSR $40                                               ; $CF8A: 46 40
  RTI                                                   ; $CF8C: 40
  RTI                                                   ; $CF8D: 40
  RTI                                                   ; $CF8E: 40
  RTI                                                   ; $CF8F: 40
  EOR ($41,X)                                           ; $CF90: 41 41
  .byte $47                                             ; $CF92: 47
L_CF93:
  PHA                                                   ; $CF93: 48
  EOR #$40                                              ; $CF94: 49 40
  RTI                                                   ; $CF96: 40
  RTI                                                   ; $CF97: 40
  RTI                                                   ; $CF98: 40
  RTI                                                   ; $CF99: 40
  EOR ($4A,X)                                           ; $CF9A: 41 4A
  .byte $4B, $4C ; $CF9C: 4B 4C
  EOR $4040                                             ; $CF9E: 4D 40 40
  RTI                                                   ; $CFA1: 40
  RTI                                                   ; $CFA2: 40
  RTI                                                   ; $CFA3: 40
  EOR ($4E,X)                                           ; $CFA4: 41 4E
  .byte $4F                                             ; $CFA6: 4F
  BVC L_CFFA                                            ; $CFA7: 50 51
  .byte $52                                             ; $CFA9: 52
  RTI                                                   ; $CFAA: 40
  RTI                                                   ; $CFAB: 40
  RTI                                                   ; $CFAC: 40
  RTI                                                   ; $CFAD: 40
L_CFAE:
  EOR ($53,X)                                           ; $CFAE: 41 53
  EOR ($54,X)                                           ; $CFB0: 41 54
  EOR $56,X                                             ; $CFB2: 55 56
  .byte $57                                             ; $CFB4: 57
  CLI                                                   ; $CFB5: 58
  RTI                                                   ; $CFB6: 40
  RTI                                                   ; $CFB7: 40
  EOR ($41,X)                                           ; $CFB8: 41 41
  EOR ($59,X)                                           ; $CFBA: 41 59
  NOP                                                   ; $CFBC: 5A
  .byte $5B, $5C                                        ; $CFBD: 5B 5C
  EOR $415E,X                                           ; $CFBF: 5D 5E 41
  EOR ($41,X)                                           ; $CFC2: 41 41
  EOR ($5F,X)                                           ; $CFC4: 41 5F
  RTS                                                   ; $CFC6: 60

;===============================================================================
; $CFC7: TradeParamSetup
;===============================================================================
  .byte $61, $62                                        ; $CFC7: 61 62
  RTI                                                   ; $CFC9: 40
  .byte $63                                             ; $CFCA: 63
  EOR ($41,X)                                           ; $CFCB: 41 41
  EOR ($41,X)                                           ; $CFCD: 41 41
  EOR ($64,X)                                           ; $CFCF: 41 64
  ADC $66                                               ; $CFD1: 65 66
  .byte $67                                             ; $CFD3: 67
  PLA                                                   ; $CFD4: 68
  ADC #$41                                              ; $CFD5: 69 41
  EOR ($41,X)                                           ; $CFD7: 41 41
  EOR ($6A,X)                                           ; $CFD9: 41 6A
  .byte $6B, $6C ; $CFDB: 6B 6C
  ADC $6F6E                                             ; $CFDD: 6D 6E 6F
  BVS L_CFAE                                            ; $CFE0: 70 CC
  BRK                                                   ; $CFE2: 00
  BMI L_D006                                            ; $CFE3: 30 21
  .byte $27                                             ; $CFE5: 27
  ASL $09,X                                             ; $CFE6: 16 09
  ROL $40,X                                             ; $CFE8: 36 40
  RTI                                                   ; $CFEA: 40
  RTI                                                   ; $CFEB: 40
  EOR ($42,X)                                           ; $CFEC: 41 42
  .byte $43                                             ; $CFEE: 43
  RTI                                                   ; $CFEF: 40
  RTI                                                   ; $CFF0: 40
  .byte $44                                             ; $CFF1: 44
  EOR $46                                               ; $CFF2: 45 46
  LSR $46                                               ; $CFF4: 46 46
  LSR $46                                               ; $CFF6: 46 46
  LSR $46                                               ; $CFF8: 46 46
L_CFFA:
  LSR $47                                               ; $CFFA: 46 47
  PHA                                                   ; $CFFC: 48
  EOR #$4A                                              ; $CFFD: 49 4A
  .byte $4B, $4C ; $CFFF: 4B 4C
  EOR $4F4E                                             ; $D001: 4D 4E 4F
  RTI                                                   ; $D004: 40
  .byte $62                                             ; $D005: 62
L_D006:
  RTI                                                   ; $D006: 40
  .byte $50, $51 ; $D007: 50 51
  .byte $52, $53, $54, $62                              ; $D009: 52 53 54 62
  RTI                                                   ; $D00D: 40
  EOR $56,X                                             ; $D00E: 55 56
  RTI                                                   ; $D010: 40
  .byte $57                                             ; $D011: 57
  CLI                                                   ; $D012: 58
  EOR $625A,Y                                           ; $D013: 59 5A 62
  RTI                                                   ; $D016: 40
  .byte $5B                                             ; $D017: 5B
  RTI                                                   ; $D018: 40
  .byte $5C                                             ; $D019: 5C
  EOR $5F5E,X                                           ; $D01A: 5D 5E 5F
  .byte $62                                             ; $D01D: 62
  RTI                                                   ; $D01E: 40
  RTS                                                   ; $D01F: 60

;===============================================================================
; $D020: SearchParamSetup
;===============================================================================
  RTI                                                   ; $D020: 40
  ADC ($62,X)                                           ; $D021: 61 62
  RTI                                                   ; $D023: 40
  .byte $63, $64                                        ; $D024: 63 64
  ADC $66                                               ; $D026: 65 66
  ROR                                                   ; $D028: 6A
  .byte $67                                             ; $D029: 67
  PLA                                                   ; $D02A: 68
  ADC #$40                                              ; $D02B: 69 40
  RTI                                                   ; $D02D: 40
  ROR                                                   ; $D02E: 6A
  .byte $6B, $6C ; $D02F: 6B 6C
  ADC $6F6E                                             ; $D031: 6D 6E 6F
  .byte $70, $71 ; $D034: 70 71
  ROR                                                   ; $D036: 6A
  .byte $72, $72, $73, $74                              ; $D037: 72 72 73 74
  ADC $76,X                                             ; $D03B: 75 76
  .byte $77                                             ; $D03D: 77
  SEI                                                   ; $D03E: 78
  .byte $62                                             ; $D03F: 62
  ADC $7A7A,Y                                           ; $D040: 79 7A 7A
  .byte $7B, $7C                                        ; $D043: 7B 7C
  ROR $626E                                             ; $D045: 6E 6E 62
  RTI                                                   ; $D048: 40
  RTI                                                   ; $D049: 40
  ADC $7F7E,X                                           ; $D04A: 7D 7E 7F
  LDX $B7,Y                                             ; $D04D: B6 B7
  BMI L_D087                                            ; $D04F: 30 36
  .byte $17                                             ; $D051: 17
  BMI L_D08A                                            ; $D052: 30 36
  .byte $17                                             ; $D054: 17
  EOR ($42,X)                                           ; $D055: 41 42
  .byte $43, $44                                        ; $D057: 43 44
  EOR ($41,X)                                           ; $D059: 41 41
  EOR $46                                               ; $D05B: 45 46
  .byte $47                                             ; $D05D: 47
  PHA                                                   ; $D05E: 48
  EOR ($49,X)                                           ; $D05F: 41 49
  LSR                                                   ; $D061: 4A
  .byte $4B, $41 ; $D062: 4B 41
  EOR ($4C,X)                                           ; $D064: 41 4C
  EOR $4F4E                                             ; $D066: 4D 4E 4F
  EOR ($50,X)                                           ; $D069: 41 50
  EOR ($52),Y                                           ; $D06B: 51 52
  EOR ($41,X)                                           ; $D06D: 41 41
  .byte $53, $54                                        ; $D06F: 53 54
  EOR $56,X                                             ; $D071: 55 56
  .byte $57                                             ; $D073: 57
  CLI                                                   ; $D074: 58
  EOR $5B5A,Y                                           ; $D075: 59 5A 5B
  .byte $5C                                             ; $D078: 5C
  EOR $5F5E,X                                           ; $D079: 5D 5E 5F
  RTS                                                   ; $D07C: 60

;===============================================================================
; $D07D: ItemParamSetup
;===============================================================================
  .byte $61, $62, $63, $64, $65                         ; $D07D: 61 62 63 64 65
  RTI                                                   ; $D082: 40
  RTI                                                   ; $D083: 40
  RTI                                                   ; $D084: 40
  ROR $67                                               ; $D085: 66 67
L_D087:
  PLA                                                   ; $D087: 68
  ADC #$6A                                              ; $D088: 69 6A
L_D08A:
  .byte $6B, $6C ; $D08A: 6B 6C
  RTI                                                   ; $D08C: 40
  RTI                                                   ; $D08D: 40
  RTI                                                   ; $D08E: 40
  ADC $6F6E                                             ; $D08F: 6D 6E 6F
  BVS L_D105                                            ; $D092: 70 71
  .byte $72                                             ; $D094: 72
  RTI                                                   ; $D095: 40
  RTI                                                   ; $D096: 40
  RTI                                                   ; $D097: 40
  RTI                                                   ; $D098: 40
  EOR ($73,X)                                           ; $D099: 41 73
  .byte $74                                             ; $D09B: 74
  ADC $76,X                                             ; $D09C: 75 76
  RTI                                                   ; $D09E: 40
  RTI                                                   ; $D09F: 40
  RTI                                                   ; $D0A0: 40
  RTI                                                   ; $D0A1: 40
  RTI                                                   ; $D0A2: 40
  .byte $77                                             ; $D0A3: 77
  SEI                                                   ; $D0A4: 78
  ADC $7B7A,Y                                           ; $D0A5: 79 7A 7B
  RTI                                                   ; $D0A8: 40
  RTI                                                   ; $D0A9: 40
  .byte $7C                                             ; $D0AA: 7C
  ADC $417E,X                                           ; $D0AB: 7D 7E 41
  RTI                                                   ; $D0AE: 40
  .byte $7F                                             ; $D0AF: 7F
  BRK                                                   ; $D0B0: 00
  ORA ($40,X)                                           ; $D0B1: 01 40
  RTI                                                   ; $D0B3: 40
  .byte $02                                             ; $D0B4: 02
  EOR ($41,X)                                           ; $D0B5: 41 41
  EOR ($40,X)                                           ; $D0B7: 41 40
  INY                                                   ; $D0B9: C8
  BRK                                                   ; $D0BA: 00
  ASL $36,X                                             ; $D0BB: 16 36
  .byte $17                                             ; $D0BD: 17
  ASL $36,X                                             ; $D0BE: 16 36
  .byte $17                                             ; $D0C0: 17
  RTI                                                   ; $D0C1: 40
  RTI                                                   ; $D0C2: 40
  RTI                                                   ; $D0C3: 40
  EOR ($41,X)                                           ; $D0C4: 41 41
  EOR ($41,X)                                           ; $D0C6: 41 41
  EOR ($42,X)                                           ; $D0C8: 41 42
  .byte $43                                             ; $D0CA: 43
  EOR ($40,X)                                           ; $D0CB: 41 40
  RTI                                                   ; $D0CD: 40
  EOR ($41,X)                                           ; $D0CE: 41 41
  .byte $44                                             ; $D0D0: 44
  EOR $46                                               ; $D0D1: 45 46
  EOR ($41,X)                                           ; $D0D3: 41 41
  .byte $47                                             ; $D0D5: 47
  PHA                                                   ; $D0D6: 48
  RTI                                                   ; $D0D7: 40
  RTI                                                   ; $D0D8: 40
  EOR #$4A                                              ; $D0D9: 49 4A
  .byte $4B, $4C ; $D0DB: 4B 4C
  EOR $4141                                             ; $D0DD: 4D 41 41
  LSR $404F                                             ; $D0E0: 4E 4F 40
  RTI                                                   ; $D0E3: 40
  BVC L_D137                                            ; $D0E4: 50 51
  .byte $52, $53, $54                                   ; $D0E6: 52 53 54
  EOR $56,X                                             ; $D0E9: 55 56
  .byte $57                                             ; $D0EB: 57
  EOR ($40,X)                                           ; $D0EC: 41 40
  CLI                                                   ; $D0EE: 58
  EOR $5B5A,Y                                           ; $D0EF: 59 5A 5B

;===============================================================================
; $D0F2: OfficerParamDispatch
;===============================================================================
  EOR ($5C,X)                                           ; $D0F2: 41 5C
  EOR $5F5E,X                                           ; $D0F4: 5D 5E 5F
  RTS                                                   ; $D0F7: 60
  .byte $61, $62, $63, $64, $41, $65, $66, $67          ; $D0F8: 61 62 63 64 41 65 66 67
  PLA                                                   ; $D100: 68
  ADC #$6A                                              ; $D101: 69 6A
  .byte $6B, $6C ; $D103: 6B 6C
L_D105:
  ADC $6F6E                                             ; $D105: 6D 6E 6F
  .byte $70, $71 ; $D108: 70 71
  .byte $72, $73, $74                                   ; $D10A: 72 73 74
  ADC $76,X                                             ; $D10D: 75 76
  .byte $77                                             ; $D10F: 77
  SEI                                                   ; $D110: 78
  EOR ($40,X)                                           ; $D111: 41 40
  ADC $4040,Y                                           ; $D113: 79 40 40
  NOP                                                   ; $D116: 7A
  RTI                                                   ; $D117: 40
  RTI                                                   ; $D118: 40
  RTI                                                   ; $D119: 40
  .byte $7B                                             ; $D11A: 7B
  EOR ($40,X)                                           ; $D11B: 41 40
  .byte $7C                                             ; $D11D: 7C
  ADC $7F7E,X                                           ; $D11E: 7D 7E 7F
  RTI                                                   ; $D121: 40
  RTI                                                   ; $D122: 40
  RTI                                                   ; $D123: 40
  RTI                                                   ; $D124: 40
  .byte $D2                                             ; $D125: D2
  BRK                                                   ; $D126: 00
  ROL                                                   ; $D127: 2A
  AND ($16,X)                                           ; $D128: 21 16
  .byte $30, $25 ; $D12A: 30 25
  .byte $27                                             ; $D12C: 27
  RTI                                                   ; $D12D: 40
  RTI                                                   ; $D12E: 40
  RTI                                                   ; $D12F: 40
  RTI                                                   ; $D130: 40
  RTI                                                   ; $D131: 40
  RTI                                                   ; $D132: 40
  RTI                                                   ; $D133: 40
  RTI                                                   ; $D134: 40
  RTI                                                   ; $D135: 40
  RTI                                                   ; $D136: 40
L_D137:
  RTI                                                   ; $D137: 40
  RTI                                                   ; $D138: 40
  RTI                                                   ; $D139: 40
  RTI                                                   ; $D13A: 40
  RTI                                                   ; $D13B: 40
  RTI                                                   ; $D13C: 40
  RTI                                                   ; $D13D: 40
  RTI                                                   ; $D13E: 40
  .byte $42, $43, $44                                   ; $D13F: 42 43 44
  EOR $46                                               ; $D142: 45 46
  .byte $47                                             ; $D144: 47
  LSR $47                                               ; $D145: 46 47
  PHA                                                   ; $D147: 48
  EOR #$4A                                              ; $D148: 49 4A
  .byte $4B, $4C ; $D14A: 4B 4C
  EOR $4E41                                             ; $D14C: 4D 41 4E
  .byte $4F                                             ; $D14F: 4F
  BVC L_D1A3                                            ; $D150: 50 51
  .byte $52, $53, $54                                   ; $D152: 52 53 54
  EOR $56,X                                             ; $D155: 55 56
  .byte $57                                             ; $D157: 57
  EOR ($41,X)                                           ; $D158: 41 41
  EOR ($41,X)                                           ; $D15A: 41 41
  EOR ($58,X)                                           ; $D15C: 41 58
  EOR $415A,Y                                           ; $D15E: 59 5A 41
  .byte $5B                                             ; $D161: 5B
  EOR ($41,X)                                           ; $D162: 41 41
  EOR $5F5E,X                                           ; $D164: 5D 5E 5F
  RTS                                                   ; $D167: 60

;===============================================================================
; $D168: ProvinceParamTable
;===============================================================================
  .byte $61, $62, $63, $64, $65, $66, $67               ; $D168: 61 62 63 64 65 66 67
  PLA                                                   ; $D16F: 68
  EOR ($69,X)                                           ; $D170: 41 69
  ROR                                                   ; $D172: 6A
  EOR ($41,X)                                           ; $D173: 41 41
  .byte $6B, $41 ; $D175: 6B 41
  EOR ($6C,X)                                           ; $D177: 41 6C
  ADC $6E6E                                             ; $D179: 6D 6E 6E
  .byte $70, $71 ; $D17C: 70 71
  .byte $72, $73, $74                                   ; $D17E: 72 73 74
  ADC $76,X                                             ; $D181: 75 76
  EOR ($41,X)                                           ; $D183: 41 41
  .byte $77                                             ; $D185: 77
  EOR ($41,X)                                           ; $D186: 41 41
  SEI                                                   ; $D188: 78
  ADC $7B7A,Y                                           ; $D189: 79 7A 7B
  .byte $7C                                             ; $D18C: 7C
  ADC $7E41,X                                           ; $D18D: 7D 41 7E
  .byte $7F                                             ; $D190: 7F
  DEC $1000                                             ; $D191: CE 00 10
  CLC                                                   ; $D194: 18
  ROL $10                                               ; $D195: 26 10
  CLC                                                   ; $D197: 18
  ROL $41                                               ; $D198: 26 41
  .byte $42, $43, $44                                   ; $D19A: 42 43 44
  EOR $46                                               ; $D19D: 45 46
  .byte $47                                             ; $D19F: 47
  PHA                                                   ; $D1A0: 48
  EOR #$4A                                              ; $D1A1: 49 4A
L_D1A3:
  .byte $4B, $4C ; $D1A3: 4B 4C
  .byte $43                                             ; $D1A5: 43
  EOR $404E                                             ; $D1A6: 4D 4E 40
  ADC $504F,X                                           ; $D1A9: 7D 4F 50
  EOR ($41),Y                                           ; $D1AC: 51 41
  .byte $42, $43, $44                                   ; $D1AE: 42 43 44
  RTI                                                   ; $D1B1: 40
  RTI                                                   ; $D1B2: 40
  RTI                                                   ; $D1B3: 40
  .byte $4F, $52, $53                                   ; $D1B4: 4F 52 53
  EOR ($4C,X)                                           ; $D1B7: 41 4C
  .byte $43                                             ; $D1B9: 43
  EOR $4040                                             ; $D1BA: 4D 40 40
  RTI                                                   ; $D1BD: 40
  .byte $54                                             ; $D1BE: 54
  EOR $56,X                                             ; $D1BF: 55 56
  EOR ($42,X)                                           ; $D1C1: 41 42
  CLI                                                   ; $D1C3: 58
  EOR $4040,Y                                           ; $D1C4: 59 40 40
  RTI                                                   ; $D1C7: 40
  NOP                                                   ; $D1C8: 5A
  .byte $5B                                             ; $D1C9: 5B
  LSR                                                   ; $D1CA: 4A
  .byte $5C                                             ; $D1CB: 5C
  EOR $405E,X                                           ; $D1CC: 5D 5E 40
  RTI                                                   ; $D1CF: 40
  RTI                                                   ; $D1D0: 40
  RTI                                                   ; $D1D1: 40
  .byte $5F                                             ; $D1D2: 5F
  RTS                                                   ; $D1D3: 60

;===============================================================================
; $D1D4: BattleParamTable
;===============================================================================
  .byte $56, $61, $62, $63, $64                         ; $D1D4: 56 61 62 63 64
  RTI                                                   ; $D1D9: 40
  RTI                                                   ; $D1DA: 40
  ADC $66                                               ; $D1DB: 65 66
  .byte $67                                             ; $D1DD: 67
  LSR                                                   ; $D1DE: 4A
  RTI                                                   ; $D1DF: 40
  RTI                                                   ; $D1E0: 40
  RTI                                                   ; $D1E1: 40
  RTI                                                   ; $D1E2: 40
  RTI                                                   ; $D1E3: 40
  PLA                                                   ; $D1E4: 68
  ADC #$6A                                              ; $D1E5: 69 6A
  .byte $6B, $6C ; $D1E7: 6B 6C
  ADC $6F6E                                             ; $D1E9: 6D 6E 6F
  BVS L_D22E                                            ; $D1EC: 70 40
  ADC ($72),Y                                           ; $D1EE: 71 72
  .byte $73, $74                                        ; $D1F0: 73 74
  ADC $76,X                                             ; $D1F2: 75 76
  .byte $77                                             ; $D1F4: 77
  SEI                                                   ; $D1F5: 78
  ADC $4040,Y                                           ; $D1F6: 79 40 40
  RTI                                                   ; $D1F9: 40
  NOP                                                   ; $D1FA: 7A
  .byte $7B, $7C                                        ; $D1FB: 7B 7C
  CMP $3000                                             ; $D1FD: CD 00 30
  .byte $17                                             ; $D200: 17
  ROL $30,X                                             ; $D201: 36 30
  .byte $17                                             ; $D203: 17
  ROL $40,X                                             ; $D204: 36 40
  EOR ($03,X)                                           ; $D206: 41 03
  .byte $03, $03, $03, $03, $03, $03, $03               ; $D208: 03 03 03 03 03 03 03
  BRK                                                   ; $D20F: 00
  .byte $42, $03, $03, $03                              ; $D210: 42 03 03 03
  BRK                                                   ; $D214: 00
  BRK                                                   ; $D215: 00
  BRK                                                   ; $D216: 00
  .byte $03, $03, $43, $44, $03, $03, $03               ; $D217: 03 03 43 44 03 03 03
  BRK                                                   ; $D21E: 00
  BRK                                                   ; $D21F: 00
  BRK                                                   ; $D220: 00
  .byte $03, $03                                        ; $D221: 03 03
  EOR $46                                               ; $D223: 45 46
  .byte $03, $03                                        ; $D225: 03 03
  BRK                                                   ; $D227: 00
  BRK                                                   ; $D228: 00
  BRK                                                   ; $D229: 00
  BRK                                                   ; $D22A: 00
  BRK                                                   ; $D22B: 00
  .byte $03, $47                                        ; $D22C: 03 47
L_D22E:
  PHA                                                   ; $D22E: 48
  EOR #$03                                              ; $D22F: 49 03
  BRK                                                   ; $D231: 00
  BRK                                                   ; $D232: 00
  BRK                                                   ; $D233: 00
  BRK                                                   ; $D234: 00
  BRK                                                   ; $D235: 00
  .byte $4B, $00 ; $D236: 4B 00
  BRK                                                   ; $D238: 00
  JMP $4E4D                                             ; $D239: 4C 4D 4E
  LSR                                                   ; $D23C: 4A
  BRK                                                   ; $D23D: 00
  .byte $02, $02, $4F                                   ; $D23E: 02 02 4F
  BRK                                                   ; $D241: 00
  BRK                                                   ; $D242: 00
  JMP $5150                                             ; $D243: 4C 50 51
  .byte $52, $53, $02, $54                              ; $D246: 52 53 02 54
  EOR $00,X                                             ; $D24A: 55 00
  BRK                                                   ; $D24C: 00
  JMP $5756                                             ; $D24D: 4C 56 57
  CLI                                                   ; $D250: 58
  EOR $5402,Y                                           ; $D251: 59 02 54
  EOR $00,X                                             ; $D254: 55 00
  BRK                                                   ; $D256: 00
  JMP $0000                                             ; $D257: 4C 00 00
  BRK                                                   ; $D25A: 00
  .byte $5B, $5C                                        ; $D25B: 5B 5C
  EOR $005E,X                                           ; $D25D: 5D 5E 00
  BRK                                                   ; $D260: 00
  JMP $0000                                             ; $D261: 4C 00 00
  BRK                                                   ; $D264: 00
  BRK                                                   ; $D265: 00
  BRK                                                   ; $D266: 00
  .byte $5F, $02                                        ; $D267: 5F 02
  CMP $3000,Y                                           ; $D269: D9 00 30
  ROL $17,X                                             ; $D26C: 36 17
  BMI L_D2A6                                            ; $D26E: 30 36
  .byte $17                                             ; $D270: 17
  EOR ($41,X)                                           ; $D271: 41 41
  EOR ($41,X)                                           ; $D273: 41 41
  EOR ($41,X)                                           ; $D275: 41 41
  EOR ($41,X)                                           ; $D277: 41 41
  EOR ($41,X)                                           ; $D279: 41 41
  EOR ($41,X)                                           ; $D27B: 41 41
  EOR ($41,X)                                           ; $D27D: 41 41
  EOR ($40,X)                                           ; $D27F: 41 40
  RTI                                                   ; $D281: 40
  RTI                                                   ; $D282: 40
  EOR ($41,X)                                           ; $D283: 41 41
  .byte $42, $43, $44                                   ; $D285: 42 43 44
  EOR ($41,X)                                           ; $D288: 41 41
  RTI                                                   ; $D28A: 40
  RTI                                                   ; $D28B: 40
  RTI                                                   ; $D28C: 40
  EOR ($41,X)                                           ; $D28D: 41 41
  EOR $46                                               ; $D28F: 45 46
  .byte $47                                             ; $D291: 47
  EOR ($41,X)                                           ; $D292: 41 41
  RTI                                                   ; $D294: 40
  RTI                                                   ; $D295: 40
  RTI                                                   ; $D296: 40
  PHA                                                   ; $D297: 48
  EOR ($49,X)                                           ; $D298: 41 49
  LSR                                                   ; $D29A: 4A
  .byte $4B, $41 ; $D29B: 4B 41
  EOR ($40,X)                                           ; $D29D: 41 40
  RTI                                                   ; $D29F: 40
  RTI                                                   ; $D2A0: 40
  JMP $4E4D                                             ; $D2A1: 4C 4D 4E
  RTI                                                   ; $D2A4: 40
  RTI                                                   ; $D2A5: 40
L_D2A6:
  .byte $4F                                             ; $D2A6: 4F
  EOR ($50,X)                                           ; $D2A7: 41 50
  EOR ($52),Y                                           ; $D2A9: 51 52
  .byte $53, $54                                        ; $D2AB: 53 54
  EOR $56,X                                             ; $D2AD: 55 56
  .byte $57                                             ; $D2AF: 57
  CLI                                                   ; $D2B0: 58
  EOR $5B5A,Y                                           ; $D2B1: 59 5A 5B
  .byte $5C                                             ; $D2B4: 5C
  EOR $5F5E,X                                           ; $D2B5: 5D 5E 5F
  RTS                                                   ; $D2B8: 60

;===============================================================================
; $D2B9: ActionLookupData
;===============================================================================
  .byte $61, $62, $63, $64, $65, $66, $67               ; $D2B9: 61 62 63 64 65 66 67
  PLA                                                   ; $D2C0: 68
  ADC #$6A                                              ; $D2C1: 69 6A
  .byte $6B, $6C ; $D2C3: 6B 6C
  ADC $6F6E                                             ; $D2C5: 6D 6E 6F
  BVS L_D33B                                            ; $D2C8: 70 71
  .byte $72, $73, $74                                   ; $D2CA: 72 73 74
  ADC $76,X                                             ; $D2CD: 75 76
  .byte $77                                             ; $D2CF: 77
  SEI                                                   ; $D2D0: 78
  ADC $7B7A,Y                                           ; $D2D1: 79 7A 7B
  .byte $7C, $DC                                        ; $D2D4: 7C DC
  BRK                                                   ; $D2D6: 00
  AND ($21),Y                                           ; $D2D7: 31 21
  ORA ($30),Y                                           ; $D2D9: 11 30
  ROL $18,X                                             ; $D2DB: 36 18
  LSR $57,X                                             ; $D2DD: 56 57
  CLI                                                   ; $D2DF: 58
  EOR $5957,Y                                           ; $D2E0: 59 57 59
  LSR $57,X                                             ; $D2E3: 56 57
  CLI                                                   ; $D2E5: 58
  EOR $5B5A,Y                                           ; $D2E6: 59 5A 5B
  .byte $5C                                             ; $D2E9: 5C
  EOR $5D5B,X                                           ; $D2EA: 5D 5B 5D
  NOP                                                   ; $D2ED: 5A
  .byte $5B, $5C                                        ; $D2EE: 5B 5C
  EOR $5F5E,X                                           ; $D2F0: 5D 5E 5F
  RTS                                                   ; $D2F3: 60

;===============================================================================
; $D2F4: StringLookupData
;===============================================================================
  .byte $61, $5F, $61, $5E, $5F                         ; $D2F4: 61 5F 61 5E 5F
  RTS                                                   ; $D2F9: 60
  .byte $61, $62, $62, $62, $62, $62, $62, $62, $62, $62, $62, $63, $63, $63, $63, $63 ; $D2FA: 61 62 62 62 62 62 62 62 62 62 62 63 63 63 63 63
  .byte $63, $63, $63, $63, $63, $64, $64, $64, $64, $64, $64, $64, $64, $64, $64, $65 ; $D30A: 63 63 63 63 63 64 64 64 64 64 64 64 64 64 64 65
  .byte $65, $65, $65, $65, $65, $65, $65, $65, $65, $66, $66, $66, $66, $66, $66, $66 ; $D31A: 65 65 65 65 65 65 65 65 65 66 66 66 66 66 66 66
  .byte $66, $66, $66, $67                              ; $D32A: 66 66 66 67
  PLA                                                   ; $D32E: 68
  .byte $67                                             ; $D32F: 67
  PLA                                                   ; $D330: 68
  .byte $67                                             ; $D331: 67
  PLA                                                   ; $D332: 68
  .byte $67                                             ; $D333: 67
  PLA                                                   ; $D334: 68
  .byte $67                                             ; $D335: 67
  PLA                                                   ; $D336: 68
  ADC #$6A                                              ; $D337: 69 6A
  ADC #$6A                                              ; $D339: 69 6A
L_D33B:
  ADC #$6A                                              ; $D33B: 69 6A
  ADC #$6A                                              ; $D33D: 69 6A
  ADC #$6A                                              ; $D33F: 69 6A
  .byte $D4                                             ; $D341: D4
  CMP $31,X                                             ; $D342: D5 31
  ROL $17,X                                             ; $D344: 36 17
  AND ($36),Y                                           ; $D346: 31 36
  .byte $17, $42                                        ; $D348: 17 42
  RTI                                                   ; $D34A: 40
  .byte $43, $44                                        ; $D34B: 43 44
  EOR ($41,X)                                           ; $D34D: 41 41
  EOR $46                                               ; $D34F: 45 46
  .byte $47                                             ; $D351: 47
  PHA                                                   ; $D352: 48
  RTI                                                   ; $D353: 40
  RTI                                                   ; $D354: 40
  RTI                                                   ; $D355: 40
  EOR #$4A                                              ; $D356: 49 4A
  EOR ($4B,X)                                           ; $D358: 41 4B
  JMP $4C4C                                             ; $D35A: 4C 4C 4C
  RTI                                                   ; $D35D: 40
  EOR $4F4E                                             ; $D35E: 4D 4E 4F
  .byte $50, $41 ; $D361: 50 41
  EOR ($41,X)                                           ; $D363: 41 41
  EOR ($41,X)                                           ; $D365: 41 41
  EOR ($40),Y                                           ; $D367: 51 40
  RTI                                                   ; $D369: 40
  RTI                                                   ; $D36A: 40
  .byte $52, $53                                        ; $D36B: 52 53
  EOR ($00,X)                                           ; $D36D: 41 00
  BRK                                                   ; $D36F: 00
  BRK                                                   ; $D370: 00
  .byte $54                                             ; $D371: 54
  EOR $40,X                                             ; $D372: 55 40
  LSR $57,X                                             ; $D374: 56 57
  CLI                                                   ; $D376: 58
  BRK                                                   ; $D377: 00
  BRK                                                   ; $D378: 00
  BRK                                                   ; $D379: 00
  BRK                                                   ; $D37A: 00
  RTI                                                   ; $D37B: 40
  EOR $4040,Y                                           ; $D37C: 59 40 40
  NOP                                                   ; $D37F: 5A
  .byte $5B                                             ; $D380: 5B
  BRK                                                   ; $D381: 00
  BRK                                                   ; $D382: 00
  BRK                                                   ; $D383: 00
  BRK                                                   ; $D384: 00
  .byte $5C                                             ; $D385: 5C
  EOR $5F5E,X                                           ; $D386: 5D 5E 5F
  RTS                                                   ; $D389: 60

;===============================================================================
; $D38A: OfficerNameLookup
;===============================================================================
  .byte $61                                             ; $D38A: 61
  BRK                                                   ; $D38B: 00
  BRK                                                   ; $D38C: 00
  BRK                                                   ; $D38D: 00
  BRK                                                   ; $D38E: 00
  .byte $62, $63                                        ; $D38F: 62 63
  EOR ($41,X)                                           ; $D391: 41 41
  .byte $64                                             ; $D393: 64
  ADC $66                                               ; $D394: 65 66
  BRK                                                   ; $D396: 00
  BRK                                                   ; $D397: 00
  .byte $67                                             ; $D398: 67
  PLA                                                   ; $D399: 68
  ADC #$6A                                              ; $D39A: 69 6A
  .byte $6B, $00 ; $D39C: 6B 00
  BRK                                                   ; $D39E: 00
  JMP ($6E6D)                                           ; $D39F: 6C 6D 6E
  .byte $6F                                             ; $D3A2: 6F
  .byte $70, $71 ; $D3A3: 70 71
  .byte $72, $73                                        ; $D3A5: 72 73
  BRK                                                   ; $D3A7: 00
  BRK                                                   ; $D3A8: 00
  BRK                                                   ; $D3A9: 00
  .byte $74                                             ; $D3AA: 74
  ADC $76,X                                             ; $D3AB: 75 76
  .byte $CF                                             ; $D3AD: CF
  BRK                                                   ; $D3AE: 00
  BMI L_D3C7                                            ; $D3AF: 30 16
  .byte $27                                             ; $D3B1: 27
  BMI L_D3CA                                            ; $D3B2: 30 16
  .byte $27                                             ; $D3B4: 27
  EOR ($42,X)                                           ; $D3B5: 41 42
  .byte $43, $44                                        ; $D3B7: 43 44
  EOR $46                                               ; $D3B9: 45 46
  .byte $47                                             ; $D3BB: 47
  RTI                                                   ; $D3BC: 40
  RTI                                                   ; $D3BD: 40
  RTI                                                   ; $D3BE: 40
  PHA                                                   ; $D3BF: 48
  EOR #$4A                                              ; $D3C0: 49 4A
  .byte $4B, $4C ; $D3C2: 4B 4C
  EOR $404E                                             ; $D3C4: 4D 4E 40
L_D3C7:
  RTI                                                   ; $D3C7: 40
  RTI                                                   ; $D3C8: 40
  .byte $4F                                             ; $D3C9: 4F
L_D3CA:
  BVC L_D41D                                            ; $D3CA: 50 51
  .byte $52, $53, $54                                   ; $D3CC: 52 53 54
  EOR $40,X                                             ; $D3CF: 55 40
  LSR $57,X                                             ; $D3D1: 56 57
  CLI                                                   ; $D3D3: 58
  EOR $405A,Y                                           ; $D3D4: 59 5A 40
  RTI                                                   ; $D3D7: 40
  RTI                                                   ; $D3D8: 40
  RTI                                                   ; $D3D9: 40
  RTI                                                   ; $D3DA: 40
  .byte $5B, $5C                                        ; $D3DB: 5B 5C
  CLI                                                   ; $D3DD: 58
  EOR $5D5A,Y                                           ; $D3DE: 59 5A 5D
  LSR $605F,X                                           ; $D3E1: 5E 5F 60

;===============================================================================
; $D3E4: NameLookupTable
;===============================================================================
  RTI                                                   ; $D3E4: 40
  RTI                                                   ; $D3E5: 40
  RTI                                                   ; $D3E6: 40
  CLI                                                   ; $D3E7: 58
  EOR $615A,Y                                           ; $D3E8: 59 5A 61
  .byte $62, $63, $64                                   ; $D3EB: 62 63 64
  RTI                                                   ; $D3EE: 40
  RTI                                                   ; $D3EF: 40
  RTI                                                   ; $D3F0: 40
  CLI                                                   ; $D3F1: 58
  EOR $405A,Y                                           ; $D3F2: 59 5A 40
  RTI                                                   ; $D3F5: 40
  ADC $66                                               ; $D3F6: 65 66
  RTI                                                   ; $D3F8: 40
  RTI                                                   ; $D3F9: 40
  RTI                                                   ; $D3FA: 40
  CLI                                                   ; $D3FB: 58
  EOR $4067,Y                                           ; $D3FC: 59 67 40
  RTI                                                   ; $D3FF: 40
  RTI                                                   ; $D400: 40
  PLA                                                   ; $D401: 68
  ADC #$6A                                              ; $D402: 69 6A
  .byte $6B, $74 ; $D404: 6B 74
  ADC $40,X                                             ; $D406: 75 40
  RTI                                                   ; $D408: 40
  RTI                                                   ; $D409: 40
  RTI                                                   ; $D40A: 40
  JMP ($6E6D)                                           ; $D40B: 6C 6D 6E
  .byte $6F, $74                                        ; $D40E: 6F 74
  ADC $40,X                                             ; $D410: 75 40
  RTI                                                   ; $D412: 40
  RTI                                                   ; $D413: 40
  RTI                                                   ; $D414: 40
  .byte $70, $71 ; $D415: 70 71
  .byte $72, $73                                        ; $D417: 72 73
  BNE L_D41B                                            ; $D419: D0 00
L_D41B:
  ASL $26,X                                             ; $D41B: 16 26
L_D41D:
  .byte $17                                             ; $D41D: 17
  AND $07,X                                             ; $D41E: 35 07
  ASL $41                                               ; $D420: 06 41
  EOR ($41,X)                                           ; $D422: 41 41
  EOR ($41,X)                                           ; $D424: 41 41
  EOR ($41,X)                                           ; $D426: 41 41
  EOR ($41,X)                                           ; $D428: 41 41
  EOR ($41,X)                                           ; $D42A: 41 41
  EOR ($41,X)                                           ; $D42C: 41 41
  EOR ($41,X)                                           ; $D42E: 41 41
  EOR ($41,X)                                           ; $D430: 41 41
  EOR ($41,X)                                           ; $D432: 41 41
  EOR ($42,X)                                           ; $D434: 41 42
  .byte $42, $42, $42, $42, $42, $42, $42, $42, $42, $43, $43, $43, $43, $43, $43, $43 ; $D436: 42 42 42 42 42 42 42 42 42 43 43 43 43 43 43 43
  .byte $43, $43, $44                                   ; $D446: 43 43 44
  EOR $46                                               ; $D449: 45 46
  .byte $47                                             ; $D44B: 47
  PHA                                                   ; $D44C: 48
  EOR #$4A                                              ; $D44D: 49 4A
  .byte $4B, $4C ; $D44F: 4B 4C
  EOR $554E                                             ; $D451: 4D 4E 55
  LSR $57,X                                             ; $D454: 56 57
  CLI                                                   ; $D456: 58
  EOR $5B5A,Y                                           ; $D457: 59 5A 5B
  .byte $5C                                             ; $D45A: 5C
  EOR $505E,X                                           ; $D45B: 5D 5E 50
  .byte $54, $54, $54, $54, $54, $54, $54, $54, $54, $54, $54 ; $D45E: 54 54 54 54 54 54 54 54 54 54 54
  EOR ($52),Y                                           ; $D469: 51 52
  .byte $53, $54, $54, $54, $54, $54, $54, $54, $54, $54, $54, $54, $54, $54, $54, $54 ; $D46B: 53 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54
  .byte $4F, $5F                                        ; $D47B: 4F 5F
  RTS                                                   ; $D47D: 60

;===============================================================================
; $D47E: MiscTable1
;===============================================================================
  .byte $54, $54, $54, $54, $54, $54, $54, $D6          ; $D47E: 54 54 54 54 54 54 54 D6
  BRK                                                   ; $D486: 00
  .byte $10, $17 ; $D487: 10 17
  .byte $07                                             ; $D489: 07
  ROL $17,X                                             ; $D48A: 36 17
  .byte $07                                             ; $D48C: 07
  EOR ($42,X)                                           ; $D48D: 41 42
  .byte $43, $44                                        ; $D48F: 43 44
  EOR $46                                               ; $D491: 45 46
  .byte $47                                             ; $D493: 47
  PHA                                                   ; $D494: 48
  EOR #$4A                                              ; $D495: 49 4A
  EOR ($52),Y                                           ; $D497: 51 52
  .byte $53, $54                                        ; $D499: 53 54
  EOR $56,X                                             ; $D49B: 55 56
  .byte $57                                             ; $D49D: 57
  CLI                                                   ; $D49E: 58
  EOR $615A,Y                                           ; $D49F: 59 5A 61
  .byte $62, $63, $64                                   ; $D4A2: 62 63 64
  ADC $66                                               ; $D4A5: 65 66
  .byte $67                                             ; $D4A7: 67
  PLA                                                   ; $D4A8: 68
  ADC #$6A                                              ; $D4A9: 69 6A
  SEI                                                   ; $D4AB: 78
  ADC $7940,Y                                           ; $D4AC: 79 40 79
  ADC $7A78,Y                                           ; $D4AF: 79 78 7A
  .byte $4B, $4C ; $D4B2: 4B 4C
  EOR $4040                                             ; $D4B4: 4D 40 40
  RTI                                                   ; $D4B7: 40
  RTI                                                   ; $D4B8: 40
  RTI                                                   ; $D4B9: 40
  RTI                                                   ; $D4BA: 40
  SEI                                                   ; $D4BB: 78
  .byte $5B, $5C                                        ; $D4BC: 5B 5C
  EOR $4040,X                                           ; $D4BE: 5D 40 40
  RTI                                                   ; $D4C1: 40
  RTI                                                   ; $D4C2: 40
  RTI                                                   ; $D4C3: 40
  RTI                                                   ; $D4C4: 40
  RTS                                                   ; $D4C5: 60

;===============================================================================
; $D4C6: MiscTable2
;===============================================================================
  .byte $6B, $6C, $6D, $75                              ; $D4C6: 6B 6C 6D 75
L_D4CA:
  .byte $76, $77                                        ; $D4CA: 76 77
  RTI                                                   ; $D4CC: 40
  RTI                                                   ; $D4CD: 40
  RTI                                                   ; $D4CE: 40
  RTI                                                   ; $D4CF: 40
  .byte $7B, $7C                                        ; $D4D0: 7B 7C
  ADC $4040,X                                           ; $D4D2: 7D 40 40
  RTI                                                   ; $D4D5: 40
  RTI                                                   ; $D4D6: 40
  RTI                                                   ; $D4D7: 40
  RTI                                                   ; $D4D8: 40
  RTI                                                   ; $D4D9: 40
  LSR $6E4F                                             ; $D4DA: 4E 4F 6E
  BVS L_D550                                            ; $D4DD: 70 71
  RTI                                                   ; $D4DF: 40
  RTI                                                   ; $D4E0: 40
  RTI                                                   ; $D4E1: 40
  RTI                                                   ; $D4E2: 40
  RTI                                                   ; $D4E3: 40
  LSR $7E5F,X                                           ; $D4E4: 5E 5F 7E
  .byte $72, $73, $74                                   ; $D4E7: 72 73 74
  RTI                                                   ; $D4EA: 40
  RTI                                                   ; $D4EB: 40
  RTI                                                   ; $D4EC: 40
  .byte $7B, $6F, $7F                                   ; $D4ED: 7B 6F 7F
  BVC L_D4CA                                            ; $D4F0: 50 D8
  BRK                                                   ; $D4F2: 00
  BMI L_D52B                                            ; $D4F3: 30 36
  ROL $30                                               ; $D4F5: 26 30
  ROL $26,X                                             ; $D4F7: 36 26
  BRK                                                   ; $D4F9: 00
  BRK                                                   ; $D4FA: 00
  BRK                                                   ; $D4FB: 00
  BRK                                                   ; $D4FC: 00
  .byte $02, $02, $02, $02, $02, $02                    ; $D4FD: 02 02 02 02 02 02
  BRK                                                   ; $D503: 00
  BRK                                                   ; $D504: 00
  BRK                                                   ; $D505: 00
  BRK                                                   ; $D506: 00
  .byte $02, $02, $02, $02, $02, $02                    ; $D507: 02 02 02 02 02 02
  BRK                                                   ; $D50D: 00
  BRK                                                   ; $D50E: 00
  BRK                                                   ; $D50F: 00
  .byte $02, $02, $02, $42, $43, $44, $02               ; $D510: 02 02 02 42 43 44 02
  BRK                                                   ; $D517: 00
  BRK                                                   ; $D518: 00
  BRK                                                   ; $D519: 00
  .byte $02, $02, $02                                   ; $D51A: 02 02 02
  EOR $46                                               ; $D51D: 45 46
  .byte $47, $02                                        ; $D51F: 47 02
  BRK                                                   ; $D521: 00
  BRK                                                   ; $D522: 00
  BRK                                                   ; $D523: 00
  ORA ($02,X)                                           ; $D524: 01 02
  .byte $02                                             ; $D526: 02
  EOR #$4A                                              ; $D527: 49 4A
  .byte $4B, $02 ; $D529: 4B 02
L_D52B:
  JMP $4D4C                                             ; $D52B: 4C 4C 4D
  ORA ($02,X)                                           ; $D52E: 01 02
  LSR $004F                                             ; $D530: 4E 4F 00
  BRK                                                   ; $D533: 00
  BVC L_D582                                            ; $D534: 50 4C
  JMP $0153                                             ; $D536: 4C 53 01
  .byte $02, $54                                        ; $D539: 02 54
  EOR $00,X                                             ; $D53B: 55 00
  BRK                                                   ; $D53D: 00
  LSR $4C,X                                             ; $D53E: 56 4C
  JMP $0159                                             ; $D540: 4C 59 01
  NOP                                                   ; $D543: 5A
  .byte $5B, $5C                                        ; $D544: 5B 5C
  EOR $025E,X                                           ; $D546: 5D 5E 02
  JMP $624C                                             ; $D549: 4C 4C 62
  .byte $63, $64                                        ; $D54C: 63 64
  ADC $66                                               ; $D54E: 65 66
L_D550:
  .byte $67                                             ; $D550: 67
  PLA                                                   ; $D551: 68
  ADC #$4C                                              ; $D552: 69 4C
  JMP $7372                                             ; $D554: 4C 72 73
  .byte $74                                             ; $D557: 74
  ADC $76,X                                             ; $D558: 75 76
  .byte $77                                             ; $D55A: 77
  SEI                                                   ; $D55B: 78
  ADC $E7E6,Y                                           ; $D55C: 79 E6 E7
  ROL $16,X                                             ; $D55F: 36 16
  BPL L_D599                                            ; $D561: 10 36
  ASL $10,X                                             ; $D563: 16 10
  .byte $80, $40 ; $D565: 80 40
  EOR ($80,X)                                           ; $D567: 41 80
  .byte $80, $42 ; $D569: 80 42
  .byte $80, $80 ; $D56B: 80 80
  .byte $43, $44                                        ; $D56D: 43 44
  .byte $80, $45 ; $D56F: 80 45
  LSR $80                                               ; $D571: 46 80
  .byte $80, $47 ; $D573: 80 47
  .byte $80, $80 ; $D575: 80 80
  PHA                                                   ; $D577: 48
  EOR #$4A                                              ; $D578: 49 4A
  .byte $4B, $4C ; $D57A: 4B 4C
  .byte $80, $80 ; $D57C: 80 80
  .byte $80, $80 ; $D57E: 80 80
  .byte $80, $4D ; $D580: 80 4D
L_D582:
  LSR $504F                                             ; $D582: 4E 4F 50
  EOR ($52),Y                                           ; $D585: 51 52
  .byte $53                                             ; $D587: 53
  .byte $80, $80 ; $D588: 80 80
  .byte $54                                             ; $D58A: 54
  EOR $56,X                                             ; $D58B: 55 56
  .byte $57                                             ; $D58D: 57
  CLI                                                   ; $D58E: 58
  EOR $5B5A,Y                                           ; $D58F: 59 5A 5B
  .byte $5C                                             ; $D592: 5C
  EOR $5F5E,X                                           ; $D593: 5D 5E 5F
  RTS                                                   ; $D596: 60

;===============================================================================
; $D597: MiscTable3
;===============================================================================
  .byte $61, $62                                        ; $D597: 61 62
L_D599:
  .byte $63, $64, $65, $66, $67                         ; $D599: 63 64 65 66 67
  PLA                                                   ; $D59E: 68
  ADC #$6A                                              ; $D59F: 69 6A
  .byte $6B, $6C ; $D5A1: 6B 6C
  ADC $6F6E                                             ; $D5A3: 6D 6E 6F
  BVS L_D619                                            ; $D5A6: 70 71
  .byte $72, $73, $74                                   ; $D5A8: 72 73 74
  ADC $76,X                                             ; $D5AB: 75 76
  .byte $77                                             ; $D5AD: 77
  SEI                                                   ; $D5AE: 78
  ADC $7B7A,Y                                           ; $D5AF: 79 7A 7B
  .byte $7C                                             ; $D5B2: 7C
  ADC $7F7E,X                                           ; $D5B3: 7D 7E 7F
  BRK                                                   ; $D5B6: 00
  ORA ($02,X)                                           ; $D5B7: 01 02
  .byte $03, $04                                        ; $D5B9: 03 04
  ORA $06                                               ; $D5BB: 05 06
  .byte $07                                             ; $D5BD: 07
  PHP                                                   ; $D5BE: 08
  ORA #$09                                              ; $D5BF: 09 09
  ORA #$0A                                              ; $D5C1: 09 0A
  .byte $0B, $0C ; $D5C3: 0B 0C
  ORA $0F0E                                             ; $D5C5: 0D 0E 0F
  .byte $10, $DD ; $D5C8: 10 DD
  BRK                                                   ; $D5CA: 00
  BMI L_D603                                            ; $D5CB: 30 36
  CLC                                                   ; $D5CD: 18
  .byte $30, $36 ; $D5CE: 30 36
  CLC                                                   ; $D5D0: 18
  BRK                                                   ; $D5D1: 00
  BRK                                                   ; $D5D2: 00
  BRK                                                   ; $D5D3: 00
  BRK                                                   ; $D5D4: 00
  BRK                                                   ; $D5D5: 00
  BRK                                                   ; $D5D6: 00
  BRK                                                   ; $D5D7: 00
  BRK                                                   ; $D5D8: 00
  BRK                                                   ; $D5D9: 00
  BRK                                                   ; $D5DA: 00
  BRK                                                   ; $D5DB: 00
  BRK                                                   ; $D5DC: 00
  EOR ($42,X)                                           ; $D5DD: 41 42
  .byte $43, $44                                        ; $D5DF: 43 44
  BRK                                                   ; $D5E1: 00
  BRK                                                   ; $D5E2: 00
  BRK                                                   ; $D5E3: 00
  BRK                                                   ; $D5E4: 00
  BRK                                                   ; $D5E5: 00
  EOR $46                                               ; $D5E6: 45 46
  .byte $47                                             ; $D5E8: 47
  PHA                                                   ; $D5E9: 48
  EOR #$4A                                              ; $D5EA: 49 4A
  BRK                                                   ; $D5EC: 00
  BRK                                                   ; $D5ED: 00
  BRK                                                   ; $D5EE: 00
  .byte $4B, $4C ; $D5EF: 4B 4C
  EOR $4F4E                                             ; $D5F1: 4D 4E 4F
  BVC L_D647                                            ; $D5F4: 50 51
  BRK                                                   ; $D5F6: 00
  BRK                                                   ; $D5F7: 00
  BRK                                                   ; $D5F8: 00
  .byte $52, $53, $54                                   ; $D5F9: 52 53 54
  EOR $56,X                                             ; $D5FC: 55 56
  .byte $57                                             ; $D5FE: 57
  CLI                                                   ; $D5FF: 58
  BRK                                                   ; $D600: 00
  BRK                                                   ; $D601: 00
  BRK                                                   ; $D602: 00
L_D603:
  BRK                                                   ; $D603: 00
  EOR $5B5A,Y                                           ; $D604: 59 5A 5B
  .byte $5C                                             ; $D607: 5C
  EOR $5F5E,X                                           ; $D608: 5D 5E 5F
  BRK                                                   ; $D60B: 00
  RTS                                                   ; $D60C: 60

;===============================================================================
; $D60D: MiscTable4
;===============================================================================
  RTI                                                   ; $D60D: 40
  ADC ($62,X)                                           ; $D60E: 61 62
  .byte $63, $64                                        ; $D610: 63 64
  ADC $66                                               ; $D612: 65 66
  .byte $67                                             ; $D614: 67
  PLA                                                   ; $D615: 68
  ADC #$75                                              ; $D616: 69 75
  ROR                                                   ; $D618: 6A
L_D619:
  .byte $6B, $6C ; $D619: 6B 6C
  ADC $6F6E                                             ; $D61B: 6D 6E 6F
  BVS L_D691                                            ; $D61E: 70 71
  .byte $72                                             ; $D620: 72
  BRK                                                   ; $D621: 00
  .byte $73, $74                                        ; $D622: 73 74
  JMP ($7776)                                           ; $D624: 6C 76 77
  SEI                                                   ; $D627: 78
  ADC $7B7A,Y                                           ; $D628: 79 7A 7B
  BRK                                                   ; $D62B: 00
  .byte $73, $74                                        ; $D62C: 73 74
  JMP ($7776)                                           ; $D62E: 6C 76 77
  .byte $7C                                             ; $D631: 7C
  ADC $7F7E,X                                           ; $D632: 7D 7E 7F
  SBC ($E3,X)                                           ; $D635: E1 E3
  ROL $16,X                                             ; $D637: 36 16
  AND ($17),Y                                           ; $D639: 31 17
  .byte $07, $0F, $42, $43, $44, $44                    ; $D63B: 07 0F 42 43 44 44
  EOR $42                                               ; $D641: 45 42
  .byte $42, $42, $43, $44                              ; $D643: 42 42 43 44
L_D647:
  LSR $47                                               ; $D647: 46 47
  PHA                                                   ; $D649: 48
  PHA                                                   ; $D64A: 48
  EOR #$4A                                              ; $D64B: 49 4A
  .byte $4B, $46 ; $D64D: 4B 46
  .byte $47                                             ; $D64F: 47
  PHA                                                   ; $D650: 48
  JMP $4E4D                                             ; $D651: 4C 4D 4E
  .byte $4F                                             ; $D654: 4F
  BVC L_D6A8                                            ; $D655: 50 51
  .byte $52                                             ; $D657: 52
  JMP $4E4D                                             ; $D658: 4C 4D 4E
  .byte $53, $54                                        ; $D65B: 53 54
  EOR $55,X                                             ; $D65D: 55 55
  LSR $57,X                                             ; $D65F: 56 57
  CLI                                                   ; $D661: 58
  EOR $555A,Y                                           ; $D662: 59 5A 55
  .byte $5B, $5C                                        ; $D665: 5B 5C
  EOR ($5D,X)                                           ; $D667: 41 5D
  LSR $605F,X                                           ; $D669: 5E 5F 60

;===============================================================================
; $D66C: MiscTable5
;===============================================================================
  .byte $61, $62, $63, $64, $65, $41, $41, $66, $67     ; $D66C: 61 62 63 64 65 41 41 66 67
  PLA                                                   ; $D675: 68
  EOR ($69,X)                                           ; $D676: 41 69
  ROR                                                   ; $D678: 6A
  EOR ($41,X)                                           ; $D679: 41 41
  EOR ($41,X)                                           ; $D67B: 41 41
  EOR ($41,X)                                           ; $D67D: 41 41
  EOR ($41,X)                                           ; $D67F: 41 41
  EOR ($41,X)                                           ; $D681: 41 41
  EOR ($41,X)                                           ; $D683: 41 41
  EOR ($41,X)                                           ; $D685: 41 41
  EOR ($41,X)                                           ; $D687: 41 41
  EOR ($41,X)                                           ; $D689: 41 41
  EOR ($41,X)                                           ; $D68B: 41 41
  EOR ($41,X)                                           ; $D68D: 41 41
  EOR ($41,X)                                           ; $D68F: 41 41
L_D691:
  EOR ($41,X)                                           ; $D691: 41 41
  EOR ($41,X)                                           ; $D693: 41 41
  EOR ($41,X)                                           ; $D695: 41 41
  EOR ($6B,X)                                           ; $D697: 41 6B
  .byte $13, $14                                        ; $D699: 13 14
  EOR ($41,X)                                           ; $D69B: 41 41
  ORA $16,X                                             ; $D69D: 15 16
  .byte $17                                             ; $D69F: 17
  CLC                                                   ; $D6A0: 18
  DEC $10DC,X                                           ; $D6A1: DE DC 10
  ROL $17,X                                             ; $D6A4: 36 17
  .byte $10, $36 ; $D6A6: 10 36
L_D6A8:
  .byte $17                                             ; $D6A8: 17
  RTI                                                   ; $D6A9: 40
  RTI                                                   ; $D6AA: 40
  EOR ($41,X)                                           ; $D6AB: 41 41
  EOR ($41,X)                                           ; $D6AD: 41 41
  .byte $42, $43, $44                                   ; $D6AF: 42 43 44
  EOR ($40,X)                                           ; $D6B2: 41 40
  RTI                                                   ; $D6B4: 40
  RTI                                                   ; $D6B5: 40
  RTI                                                   ; $D6B6: 40
  EOR ($41,X)                                           ; $D6B7: 41 41
  EOR $46                                               ; $D6B9: 45 46
  .byte $47                                             ; $D6BB: 47
  PHA                                                   ; $D6BC: 48
  RTI                                                   ; $D6BD: 40
  RTI                                                   ; $D6BE: 40
  RTI                                                   ; $D6BF: 40
  RTI                                                   ; $D6C0: 40
  EOR ($41,X)                                           ; $D6C1: 41 41
  EOR #$40                                              ; $D6C3: 49 40
  LSR                                                   ; $D6C5: 4A
  .byte $4B, $40 ; $D6C6: 4B 40
  RTI                                                   ; $D6C8: 40
  RTI                                                   ; $D6C9: 40
  RTI                                                   ; $D6CA: 40
  EOR ($4C,X)                                           ; $D6CB: 41 4C
  EOR $4F4E                                             ; $D6CD: 4D 4E 4F
  BVC L_D712                                            ; $D6D0: 50 40
  RTI                                                   ; $D6D2: 40
  RTI                                                   ; $D6D3: 40
  EOR ($52),Y                                           ; $D6D4: 51 52
  .byte $53, $54                                        ; $D6D6: 53 54
  EOR $56,X                                             ; $D6D8: 55 56
  .byte $57                                             ; $D6DA: 57
  CLI                                                   ; $D6DB: 58
  EOR $5B5A,Y                                           ; $D6DC: 59 5A 5B
  .byte $5C                                             ; $D6DF: 5C
  EOR $5F5E,X                                           ; $D6E0: 5D 5E 5F
  RTS                                                   ; $D6E3: 60

;===============================================================================
; $D6E4: MiscTable6
;===============================================================================
  .byte $61, $62, $63, $64, $65, $66, $67               ; $D6E4: 61 62 63 64 65 66 67
  PLA                                                   ; $D6EB: 68
  ADC #$6A                                              ; $D6EC: 69 6A
  .byte $6B, $6C ; $D6EE: 6B 6C
  ADC $6F6E                                             ; $D6F0: 6D 6E 6F
  .byte $70, $71 ; $D6F3: 70 71
  .byte $72, $73                                        ; $D6F5: 72 73
  BRK                                                   ; $D6F7: 00
  ORA ($02,X)                                           ; $D6F8: 01 02
  .byte $03, $04                                        ; $D6FA: 03 04
  ORA $06                                               ; $D6FC: 05 06
  .byte $07                                             ; $D6FE: 07
  PHP                                                   ; $D6FF: 08
  ORA #$0A                                              ; $D700: 09 0A
  .byte $0B, $0C ; $D702: 0B 0C
  ORA $0F0E                                             ; $D704: 0D 0E 0F
  BPL L_D71A                                            ; $D707: 10 11
  .byte $12, $13, $14                                   ; $D709: 12 13 14
  ORA $DF,X                                             ; $D70C: 15 DF
  BRK                                                   ; $D70E: 00
  BMI L_D747                                            ; $D70F: 30 36
  .byte $17                                             ; $D711: 17
L_D712:
  BMI L_D74A                                            ; $D712: 30 36
  .byte $17, $02, $02, $02, $02, $02                    ; $D714: 17 02 02 02 02 02
L_D71A:
  .byte $02, $02, $42, $43, $43, $02, $02, $42, $43, $43, $43, $44 ; $D71A: 02 02 42 43 43 02 02 42 43 43 43 44
  EOR $46                                               ; $D726: 45 46
  LSR $02                                               ; $D728: 46 02
  .byte $47                                             ; $D72A: 47
  EOR $46                                               ; $D72B: 45 46
  LSR $46                                               ; $D72D: 46 46
  PHA                                                   ; $D72F: 48
  EOR #$4A                                              ; $D730: 49 4A
  .byte $4B, $4C ; $D732: 4B 4C
  EOR $4A49                                             ; $D734: 4D 49 4A
  LSR $4F4A                                             ; $D737: 4E 4A 4F
  .byte $50, $51 ; $D73A: 50 51
  BRK                                                   ; $D73C: 00
  .byte $52, $53                                        ; $D73D: 52 53
  BVC L_D792                                            ; $D73F: 50 51
  BRK                                                   ; $D741: 00
  EOR ($54),Y                                           ; $D742: 51 54
  BRK                                                   ; $D744: 00
  BRK                                                   ; $D745: 00
  BRK                                                   ; $D746: 00
L_D747:
  BRK                                                   ; $D747: 00
  EOR $00,X                                             ; $D748: 55 00
L_D74A:
  LSR $57,X                                             ; $D74A: 56 57
  BRK                                                   ; $D74C: 00
  CLI                                                   ; $D74D: 58
  BRK                                                   ; $D74E: 00
  BRK                                                   ; $D74F: 00
  BRK                                                   ; $D750: 00
  EOR $5B5A,Y                                           ; $D751: 59 5A 5B
  BRK                                                   ; $D754: 00
  BRK                                                   ; $D755: 00
  BRK                                                   ; $D756: 00
  .byte $5C                                             ; $D757: 5C
  BRK                                                   ; $D758: 00
  EOR $5F5E,X                                           ; $D759: 5D 5E 5F
  BRK                                                   ; $D75C: 00
  RTS                                                   ; $D75D: 60

;===============================================================================
; $D75E: MiscTable7
;===============================================================================
  .byte $61, $62                                        ; $D75E: 61 62
  BRK                                                   ; $D760: 00
  BRK                                                   ; $D761: 00
  .byte $63                                             ; $D762: 63
  BRK                                                   ; $D763: 00
  .byte $64                                             ; $D764: 64
  ADC $66                                               ; $D765: 65 66
  .byte $67                                             ; $D767: 67
  PLA                                                   ; $D768: 68
  BRK                                                   ; $D769: 00
  BRK                                                   ; $D76A: 00
  BRK                                                   ; $D76B: 00
  BRK                                                   ; $D76C: 00
  BRK                                                   ; $D76D: 00
  ADC #$6A                                              ; $D76E: 69 6A
  .byte $6B, $6C ; $D770: 6B 6C
  BRK                                                   ; $D772: 00
  BRK                                                   ; $D773: 00
  BRK                                                   ; $D774: 00
  BRK                                                   ; $D775: 00
  BRK                                                   ; $D776: 00
  ADC $B56E                                             ; $D777: 6D 6E B5
  BRK                                                   ; $D77A: 00
  .byte $30, $36 ; $D77B: 30 36
  .byte $17                                             ; $D77D: 17
  BMI L_D7B6                                            ; $D77E: 30 36
  .byte $17                                             ; $D780: 17
  BRK                                                   ; $D781: 00
  BRK                                                   ; $D782: 00
  BRK                                                   ; $D783: 00
  BRK                                                   ; $D784: 00
  BRK                                                   ; $D785: 00
  BRK                                                   ; $D786: 00
  BRK                                                   ; $D787: 00
  .byte $53, $54                                        ; $D788: 53 54
  EOR $40,X                                             ; $D78A: 55 40
  EOR ($00,X)                                           ; $D78C: 41 00
  BRK                                                   ; $D78E: 00
  BRK                                                   ; $D78F: 00
  BRK                                                   ; $D790: 00
  BRK                                                   ; $D791: 00
L_D792:
  .byte $63, $64                                        ; $D792: 63 64
  ADC $50                                               ; $D794: 65 50
  EOR ($52),Y                                           ; $D796: 51 52
  BRK                                                   ; $D798: 00
  BRK                                                   ; $D799: 00
  BRK                                                   ; $D79A: 00
  BRK                                                   ; $D79B: 00
  .byte $73, $74                                        ; $D79C: 73 74
  ADC $60,X                                             ; $D79E: 75 60

;===============================================================================
; $D7A0: MiscTable8
;===============================================================================
  .byte $61, $62                                        ; $D7A0: 61 62
  BRK                                                   ; $D7A2: 00
  BRK                                                   ; $D7A3: 00
  BRK                                                   ; $D7A4: 00
  BRK                                                   ; $D7A5: 00
  EOR $00                                               ; $D7A6: 45 00
  LSR $70                                               ; $D7A8: 46 70
  BRK                                                   ; $D7AA: 00
  .byte $72                                             ; $D7AB: 72
  BRK                                                   ; $D7AC: 00
  BRK                                                   ; $D7AD: 00
  BRK                                                   ; $D7AE: 00
  BRK                                                   ; $D7AF: 00
  LSR $66,X                                             ; $D7B0: 56 66
  ROR $42,X                                             ; $D7B2: 76 42
  ADC ($43),Y                                           ; $D7B4: 71 43
L_D7B6:
  .byte $44                                             ; $D7B6: 44
  BRK                                                   ; $D7B7: 00
  BRK                                                   ; $D7B8: 00
  PHA                                                   ; $D7B9: 48
  EOR #$4A                                              ; $D7BA: 49 4A
  .byte $4B, $00 ; $D7BC: 4B 00
  BRK                                                   ; $D7BE: 00
  BRK                                                   ; $D7BF: 00
  BRK                                                   ; $D7C0: 00
  BRK                                                   ; $D7C1: 00
  .byte $57                                             ; $D7C2: 57
  CLI                                                   ; $D7C3: 58
  EOR $5B5A,Y                                           ; $D7C4: 59 5A 5B
  BRK                                                   ; $D7C7: 00
  BRK                                                   ; $D7C8: 00
  BRK                                                   ; $D7C9: 00
  BRK                                                   ; $D7CA: 00
  BRK                                                   ; $D7CB: 00
  .byte $67                                             ; $D7CC: 67
  PLA                                                   ; $D7CD: 68
  ADC #$6A                                              ; $D7CE: 69 6A
  .byte $6B, $00 ; $D7D0: 6B 00
  BRK                                                   ; $D7D2: 00
  BRK                                                   ; $D7D3: 00
  BRK                                                   ; $D7D4: 00
  BRK                                                   ; $D7D5: 00
  .byte $77                                             ; $D7D6: 77
  SEI                                                   ; $D7D7: 78
  ADC $7B7A,Y                                           ; $D7D8: 79 7A 7B
  BRK                                                   ; $D7DB: 00
  BRK                                                   ; $D7DC: 00
  BRK                                                   ; $D7DD: 00
  BRK                                                   ; $D7DE: 00
  BRK                                                   ; $D7DF: 00
  JMP $4E4D                                             ; $D7E0: 4C 4D 4E
  .byte $4F, $47                                        ; $D7E3: 4F 47
  CMP $00,X                                             ; $D7E5: D5 00
  BPL L_D81F                                            ; $D7E7: 10 36
  .byte $17                                             ; $D7E9: 17
  BPL L_D822                                            ; $D7EA: 10 36
  .byte $17                                             ; $D7EC: 17
  EOR ($40,X)                                           ; $D7ED: 41 40
  RTI                                                   ; $D7EF: 40
  EOR ($42,X)                                           ; $D7F0: 41 42
  .byte $43                                             ; $D7F2: 43
  EOR ($41,X)                                           ; $D7F3: 41 41
  EOR ($41,X)                                           ; $D7F5: 41 41
  .byte $44                                             ; $D7F7: 44
  RTI                                                   ; $D7F8: 40
  RTI                                                   ; $D7F9: 40
  RTI                                                   ; $D7FA: 40
  EOR $46                                               ; $D7FB: 45 46
  .byte $47                                             ; $D7FD: 47
  PHA                                                   ; $D7FE: 48
  EOR ($41,X)                                           ; $D7FF: 41 41
  EOR #$41                                              ; $D801: 49 41
  RTI                                                   ; $D803: 40
  RTI                                                   ; $D804: 40
  LSR                                                   ; $D805: 4A
  .byte $4B, $4C ; $D806: 4B 4C
  EOR $414E                                             ; $D808: 4D 4E 41
  .byte $4F                                             ; $D80B: 4F
  BVC L_D84E                                            ; $D80C: 50 40
  RTI                                                   ; $D80E: 40
  RTI                                                   ; $D80F: 40
  RTI                                                   ; $D810: 40
  RTI                                                   ; $D811: 40
  EOR ($52),Y                                           ; $D812: 51 52
  .byte $53, $54                                        ; $D814: 53 54
  EOR $40,X                                             ; $D816: 55 40
  RTI                                                   ; $D818: 40
  RTI                                                   ; $D819: 40
  RTI                                                   ; $D81A: 40
  RTI                                                   ; $D81B: 40
  LSR $57,X                                             ; $D81C: 56 57
  CLI                                                   ; $D81E: 58
L_D81F:
  EOR $405A,Y                                           ; $D81F: 59 5A 40
L_D822:
  RTI                                                   ; $D822: 40
  RTI                                                   ; $D823: 40
  RTI                                                   ; $D824: 40
  RTI                                                   ; $D825: 40
  .byte $5B, $5C                                        ; $D826: 5B 5C
  EOR $5F5E,X                                           ; $D828: 5D 5E 5F
  RTS                                                   ; $D82B: 60

;===============================================================================
; $D82C: MiscTable9
;===============================================================================
  RTI                                                   ; $D82C: 40
  RTI                                                   ; $D82D: 40
  RTI                                                   ; $D82E: 40
  ADC ($62,X)                                           ; $D82F: 61 62
  .byte $63, $64                                        ; $D831: 63 64
  ADC $66                                               ; $D833: 65 66
  RTI                                                   ; $D835: 40
  .byte $67                                             ; $D836: 67
  PLA                                                   ; $D837: 68
  ADC #$6A                                              ; $D838: 69 6A
  .byte $6B, $6C ; $D83A: 6B 6C
  ADC $6F6E                                             ; $D83C: 6D 6E 6F
  BVS L_D8B2                                            ; $D83F: 70 71
  .byte $72, $73                                        ; $D841: 72 73
  RTI                                                   ; $D843: 40
  .byte $74                                             ; $D844: 74
  ADC $76,X                                             ; $D845: 75 76
  .byte $77                                             ; $D847: 77
  SEI                                                   ; $D848: 78
  ADC $7B7A,Y                                           ; $D849: 79 7A 7B
  .byte $7C                                             ; $D84C: 7C
  RTI                                                   ; $D84D: 40
L_D84E:
  ADC $7F7E,X                                           ; $D84E: 7D 7E 7F
  .byte $DC                                             ; $D851: DC
  BRK                                                   ; $D852: 00
  BMI L_D886                                            ; $D853: 30 31
  AND ($0F,X)                                           ; $D855: 21 0F
  .byte $10, $15 ; $D857: 10 15
  LSR $57,X                                             ; $D859: 56 57
  CLI                                                   ; $D85B: 58
  EOR $5957,Y                                           ; $D85C: 59 57 59
  LSR $57,X                                             ; $D85F: 56 57
  CLI                                                   ; $D861: 58
  EOR $5B5A,Y                                           ; $D862: 59 5A 5B
  .byte $5C                                             ; $D865: 5C
  EOR $5D5B,X                                           ; $D866: 5D 5B 5D
  NOP                                                   ; $D869: 5A
  .byte $5B, $5C                                        ; $D86A: 5B 5C
  EOR $5F5E,X                                           ; $D86C: 5D 5E 5F
  RTS                                                   ; $D86F: 60

;===============================================================================
; $D870: MiscTable10
;===============================================================================
  .byte $61, $5F, $61, $5E, $5F                         ; $D870: 61 5F 61 5E 5F
  RTS                                                   ; $D875: 60

;===============================================================================
; $D876: SramReadWrite
;===============================================================================
  .byte $61, $62, $62, $62, $62, $62, $62, $62, $62, $62, $62, $6E, $6E, $6E, $6E, $6E ; $D876: 61 62 62 62 62 62 62 62 62 62 62 6E 6E 6E 6E 6E
L_D886:
  .byte $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E ; $D886: 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E
  .byte $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6F, $70, $71, $6F, $70, $71, $6F ; $D896: 6E 6E 6E 6E 6E 6E 6E 6E 6E 6F 70 71 6F 70 71 6F
  .byte $70, $71, $6F, $6B, $6C, $6D, $6B, $6C, $6D, $6B, $6C, $6D ; $D8A6: 70 71 6F 6B 6C 6D 6B 6C 6D 6B 6C 6D
L_D8B2:
  .byte $6B, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $E3 ; $D8B2: 6B 01 01 01 01 01 01 01 01 01 01 E3
  BRK                                                   ; $D8BE: 00
  ROL $27,X                                             ; $D8BF: 36 27
  .byte $17                                             ; $D8C1: 17
  ROL $27,X                                             ; $D8C2: 36 27
  .byte $17                                             ; $D8C4: 17
  ORA ($01,X)                                           ; $D8C5: 01 01
  ORA ($01,X)                                           ; $D8C7: 01 01
  ORA ($01,X)                                           ; $D8C9: 01 01
  ORA ($01,X)                                           ; $D8CB: 01 01
  ORA ($01,X)                                           ; $D8CD: 01 01
  ORA ($01,X)                                           ; $D8CF: 01 01
  ORA ($01,X)                                           ; $D8D1: 01 01
  ORA ($01,X)                                           ; $D8D3: 01 01
  ORA ($01,X)                                           ; $D8D5: 01 01
  ORA ($01,X)                                           ; $D8D7: 01 01
  ORA ($01,X)                                           ; $D8D9: 01 01
  ORA ($01,X)                                           ; $D8DB: 01 01
  ORA ($01,X)                                           ; $D8DD: 01 01
  ORA ($01,X)                                           ; $D8DF: 01 01
  ORA ($01,X)                                           ; $D8E1: 01 01
  ORA ($01,X)                                           ; $D8E3: 01 01
  ORA ($01,X)                                           ; $D8E5: 01 01
  ORA ($01,X)                                           ; $D8E7: 01 01
  ORA ($01,X)                                           ; $D8E9: 01 01
  ORA ($01,X)                                           ; $D8EB: 01 01
  .byte $42, $42, $42, $42, $42, $42, $42, $42, $42, $42 ; $D8ED: 42 42 42 42 42 42 42 42 42 42
  EOR ($61,X)                                           ; $D8F7: 41 61
  .byte $62, $63                                        ; $D8F9: 62 63
  EOR ($41,X)                                           ; $D8FB: 41 41
  EOR ($41,X)                                           ; $D8FD: 41 41
  EOR ($41,X)                                           ; $D8FF: 41 41
  .byte $43                                             ; $D901: 43
  ADC ($72),Y                                           ; $D902: 71 72
  .byte $73, $74, $43, $43, $43, $43, $43, $44          ; $D904: 73 74 43 43 43 43 43 44
  BRK                                                   ; $D90C: 00
  BRK                                                   ; $D90D: 00
  BRK                                                   ; $D90E: 00
  ROR $67                                               ; $D90F: 66 67
  PLA                                                   ; $D911: 68
  EOR $46                                               ; $D912: 45 46
  .byte $47                                             ; $D914: 47
  ROR                                                   ; $D915: 6A
  BVS L_D918                                            ; $D916: 70 00
L_D918:
  ADC $76,X                                             ; $D918: 75 76
  .byte $77                                             ; $D91A: 77
  PHA                                                   ; $D91B: 48
  EOR #$4A                                              ; $D91C: 49 4A
  .byte $4B, $79 ; $D91E: 4B 79
  NOP                                                   ; $D920: 7A
  .byte $7B, $7C                                        ; $D921: 7B 7C
  ADC $4C7E,X                                           ; $D923: 7D 7E 4C
  EOR $5251                                             ; $D926: 4D 51 52
  LDA $20BE,X                                           ; $D929: BD BE 20
  .byte $17                                             ; $D92C: 17
  ROL $20,X                                             ; $D92D: 36 20
  .byte $17                                             ; $D92F: 17
  ROL $70,X                                             ; $D930: 36 70
  ADC ($72),Y                                           ; $D932: 71 72
  .byte $73, $74                                        ; $D934: 73 74
  ADC $76,X                                             ; $D936: 75 76
  .byte $77                                             ; $D938: 77
  SEI                                                   ; $D939: 78
  .byte $70, $70 ; $D93A: 70 70
  ADC ($72),Y                                           ; $D93C: 71 72
  .byte $73, $74                                        ; $D93E: 73 74
  ADC $76,X                                             ; $D940: 75 76
  .byte $77                                             ; $D942: 77
  SEI                                                   ; $D943: 78
  ADC $7A70,Y                                           ; $D944: 79 70 7A
  .byte $7B, $7C                                        ; $D947: 7B 7C
  ADC $7F7E,X                                           ; $D949: 7D 7E 7F
  BRK                                                   ; $D94C: 00
  ORA ($02,X)                                           ; $D94D: 01 02
  .byte $03, $03, $04                                   ; $D94F: 03 03 04
  ORA $06                                               ; $D952: 05 06
  .byte $07                                             ; $D954: 07
  PHP                                                   ; $D955: 08
  .byte $80, $80 ; $D956: 80 80
  ORA #$39                                              ; $D958: 09 39
  AND $0B0A,Y                                           ; $D95A: 39 0A 0B
  .byte $0C                                             ; $D95D: 0C
  ORA $800E                                             ; $D95E: 0D 0E 80
  .byte $80, $0F ; $D961: 80 0F
  .byte $10, $11 ; $D963: 10 11
  .byte $12, $13, $14                                   ; $D965: 12 13 14
  ORA $16,X                                             ; $D968: 15 16
  .byte $80, $80 ; $D96A: 80 80
  .byte $17                                             ; $D96C: 17
  CLC                                                   ; $D96D: 18
  ORA $1B1A,Y                                           ; $D96E: 19 1A 1B
  .byte $1C                                             ; $D971: 1C
  ORA $1F1E,X                                           ; $D972: 1D 1E 1F
  JSR $2221                                             ; $D975: 20 21 22
  .byte $23                                             ; $D978: 23
  BIT $25                                               ; $D979: 24 25
  ROL $27                                               ; $D97B: 26 27
  PLP                                                   ; $D97D: 28
  AND #$2A                                              ; $D97E: 29 2A
  .byte $2B, $39 ; $D980: 2B 39
  BIT $2E2D                                             ; $D982: 2C 2D 2E
  .byte $2F                                             ; $D985: 2F
  BMI L_D9B9                                            ; $D986: 30 31
  .byte $32                                             ; $D988: 32
  AND $3939,Y                                           ; $D989: 39 39 39
  .byte $33, $34                                        ; $D98C: 33 34
  AND $36,X                                             ; $D98E: 35 36
  .byte $37                                             ; $D990: 37
  SEC                                                   ; $D991: 38
  AND $3939,Y                                           ; $D992: 39 39 39
  .byte $D3                                             ; $D995: D3
  BRK                                                   ; $D996: 00
  .byte $10, $17 ; $D997: 10 17
  ORA ($10),Y                                           ; $D999: 11 10
  .byte $17                                             ; $D99B: 17
  ORA ($42),Y                                           ; $D99C: 11 42
  .byte $43                                             ; $D99E: 43
  EOR ($44,X)                                           ; $D99F: 41 44
  EOR $46                                               ; $D9A1: 45 46
  .byte $47                                             ; $D9A3: 47
  EOR ($41,X)                                           ; $D9A4: 41 41
  PHA                                                   ; $D9A6: 48
  EOR #$4A                                              ; $D9A7: 49 4A
  EOR ($4B,X)                                           ; $D9A9: 41 4B
  JMP $4E4D                                             ; $D9AB: 4C 4D 4E
  .byte $4F                                             ; $D9AE: 4F
  BVC L_DA02                                            ; $D9AF: 50 51
  .byte $52, $53, $54                                   ; $D9B1: 52 53 54
  EOR $56,X                                             ; $D9B4: 55 56
  .byte $57                                             ; $D9B6: 57
  RTI                                                   ; $D9B7: 40
  RTI                                                   ; $D9B8: 40
L_D9B9:
  CLI                                                   ; $D9B9: 58
  EOR $5B5A,Y                                           ; $D9BA: 59 5A 5B
  RTI                                                   ; $D9BD: 40
  .byte $5C                                             ; $D9BE: 5C
  EOR $4040,X                                           ; $D9BF: 5D 40 40
  RTI                                                   ; $D9C2: 40
  LSR $605F,X                                           ; $D9C3: 5E 5F 60

;===============================================================================
; $D9C6: SaveGameMain
;===============================================================================
  .byte $61, $62, $63, $64                              ; $D9C6: 61 62 63 64
  RTI                                                   ; $D9CA: 40
  ADC $66                                               ; $D9CB: 65 66
  .byte $67                                             ; $D9CD: 67
  PLA                                                   ; $D9CE: 68
  ADC #$6A                                              ; $D9CF: 69 6A
  .byte $6B, $6C ; $D9D1: 6B 6C
  RTI                                                   ; $D9D3: 40
  ROR $4040                                             ; $D9D4: 6E 40 40
  .byte $6F                                             ; $D9D7: 6F
  BVS L_DA1A                                            ; $D9D8: 70 40
  ROR $6E40                                             ; $D9DA: 6E 40 6E
  ADC ($72),Y                                           ; $D9DD: 71 72
  .byte $73                                             ; $D9DF: 73
  RTI                                                   ; $D9E0: 40
  RTI                                                   ; $D9E1: 40
  RTI                                                   ; $D9E2: 40
  ROR $6E40                                             ; $D9E3: 6E 40 6E
  RTI                                                   ; $D9E6: 40
  .byte $74                                             ; $D9E7: 74
  ADC $75,X                                             ; $D9E8: 75 75
  ROR $77,X                                             ; $D9EA: 76 77
  SEI                                                   ; $D9EC: 78
  RTI                                                   ; $D9ED: 40
  ROR $6E40                                             ; $D9EE: 6E 40 6E
  RTI                                                   ; $D9F1: 40
  ADC $75,X                                             ; $D9F2: 75 75
  ADC $7B7A,Y                                           ; $D9F4: 79 7A 7B
  ROR $6E40                                             ; $D9F7: 6E 40 6E
  ROR $6D40                                             ; $D9FA: 6E 40 6D
  .byte $7C                                             ; $D9FD: 7C
  ADC $7F7E,X                                           ; $D9FE: 7D 7E 7F
  DEX                                                   ; $DA01: CA
L_DA02:
  .byte $CB, $16 ; $DA02: CB 16
  ROL $17,X                                             ; $DA04: 36 17
  ASL $36,X                                             ; $DA06: 16 36
  .byte $17                                             ; $DA08: 17
  ADC ($72),Y                                           ; $DA09: 71 72
  .byte $73, $74, $74, $74, $74                         ; $DA0B: 73 74 74 74 74
  ADC $76,X                                             ; $DA10: 75 76
  .byte $74, $77                                        ; $DA12: 74 77
  SEI                                                   ; $DA14: 78
  ADC $7474,Y                                           ; $DA15: 79 74 74
  .byte $74, $74                                        ; $DA18: 74 74
L_DA1A:
  NOP                                                   ; $DA1A: 7A
  .byte $7B, $7C                                        ; $DA1B: 7B 7C
  ADC $747E,X                                           ; $DA1D: 7D 7E 74
  .byte $7F                                             ; $DA20: 7F
  BRK                                                   ; $DA21: 00
  ORA ($02,X)                                           ; $DA22: 01 02
  .byte $03, $04                                        ; $DA24: 03 04
  ORA $06                                               ; $DA26: 05 06
  .byte $07                                             ; $DA28: 07
  PHP                                                   ; $DA29: 08
  ORA #$0A                                              ; $DA2A: 09 0A
  .byte $0B, $0C ; $DA2C: 0B 0C
  ORA $0E74                                             ; $DA2E: 0D 74 0E
  .byte $0F                                             ; $DA31: 0F
  .byte $10, $11 ; $DA32: 10 11
  .byte $12                                             ; $DA34: 12
  AND $133D,X                                           ; $DA35: 3D 3D 13
  .byte $14                                             ; $DA38: 14
  ORA $74,X                                             ; $DA39: 15 74
  ASL $17,X                                             ; $DA3B: 16 17
  CLC                                                   ; $DA3D: 18
  ORA $3D3D,Y                                           ; $DA3E: 19 3D 3D
  NOP                                                   ; $DA41: 1A
  .byte $1B, $1C                                        ; $DA42: 1B 1C
  ORA $1F1E,X                                           ; $DA44: 1D 1E 1F
  JSR $2221                                             ; $DA47: 20 21 22
  .byte $23                                             ; $DA4A: 23
  BIT $25                                               ; $DA4B: 24 25
  ROL $27                                               ; $DA4D: 26 27
  PLP                                                   ; $DA4F: 28
  AND #$2A                                              ; $DA50: 29 2A
  .byte $2B, $2C ; $DA52: 2B 2C
  AND $2F2E                                             ; $DA54: 2D 2E 2F
  AND $303D,X                                           ; $DA57: 3D 3D 30
  AND $313D,X                                           ; $DA5A: 3D 3D 31
  .byte $32, $33, $34                                   ; $DA5D: 32 33 34
  AND $3D,X                                             ; $DA60: 35 3D
  AND $3D3D,X                                           ; $DA62: 3D 3D 3D
  AND $3736,X                                           ; $DA65: 3D 36 37
  SEC                                                   ; $DA68: 38
  AND $3B3A,Y                                           ; $DA69: 39 3A 3B
  .byte $3C                                             ; $DA6C: 3C
  LDY $3600,X                                           ; $DA6D: BC 00 36
  .byte $27, $17                                        ; $DA70: 27 17
  ROL $27,X                                             ; $DA72: 36 27
  .byte $17, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44 ; $DA74: 17 44 44 44 44 44 44 44 44 44 44
  BRK                                                   ; $DA7F: 00
  BRK                                                   ; $DA80: 00
  ORA ($00,X)                                           ; $DA81: 01 00
  BRK                                                   ; $DA83: 00
  BRK                                                   ; $DA84: 00
  EOR $01                                               ; $DA85: 45 01
  LSR $47                                               ; $DA87: 46 47
  BRK                                                   ; $DA89: 00
  BRK                                                   ; $DA8A: 00
  ORA ($00,X)                                           ; $DA8B: 01 00
  BRK                                                   ; $DA8D: 00
  BRK                                                   ; $DA8E: 00
  PHA                                                   ; $DA8F: 48
  EOR #$4A                                              ; $DA90: 49 4A
  .byte $4B, $00 ; $DA92: 4B 00
  BRK                                                   ; $DA94: 00
  BRK                                                   ; $DA95: 00
  BRK                                                   ; $DA96: 00
  BRK                                                   ; $DA97: 00
  BRK                                                   ; $DA98: 00
  JMP $4E4D                                             ; $DA99: 4C 4D 4E
  .byte $4F                                             ; $DA9C: 4F
  BVC L_DA9F                                            ; $DA9D: 50 00
L_DA9F:
  BRK                                                   ; $DA9F: 00
  BRK                                                   ; $DAA0: 00
  BRK                                                   ; $DAA1: 00
  EOR ($52),Y                                           ; $DAA2: 51 52
  .byte $53, $54                                        ; $DAA4: 53 54
  EOR $56,X                                             ; $DAA6: 55 56
  .byte $57                                             ; $DAA8: 57
  CLI                                                   ; $DAA9: 58
  EOR $5B5A,Y                                           ; $DAAA: 59 5A 5B
  .byte $5C                                             ; $DAAD: 5C
  EOR $5F5E,X                                           ; $DAAE: 5D 5E 5F
  RTS                                                   ; $DAB1: 60

;===============================================================================
; $DAB2: LoadGameMain
;===============================================================================
  .byte $61, $62, $63, $64, $65, $66, $67               ; $DAB2: 61 62 63 64 65 66 67
  PLA                                                   ; $DAB9: 68
  ADC #$6A                                              ; $DABA: 69 6A
  .byte $6B, $6C ; $DABC: 6B 6C
  ADC $6E01                                             ; $DABE: 6D 01 6E
  .byte $6F                                             ; $DAC1: 6F
  .byte $70, $01 ; $DAC2: 70 01
  ADC ($72),Y                                           ; $DAC4: 71 72
  .byte $73, $74                                        ; $DAC6: 73 74
  ADC $76,X                                             ; $DAC8: 75 76
  .byte $77                                             ; $DACA: 77
  SEI                                                   ; $DACB: 78
  ADC $7B7A,Y                                           ; $DACC: 79 7A 7B
  .byte $7C                                             ; $DACF: 7C
  ADC $7D7C,X                                           ; $DAD0: 7D 7C 7D
  ROR $407F,X                                           ; $DAD3: 7E 7F 40
  EOR ($42,X)                                           ; $DAD6: 41 42
  .byte $43                                             ; $DAD8: 43
  LDX $B7,Y                                             ; $DAD9: B6 B7
  BMI L_DB13                                            ; $DADB: 30 36
  .byte $17                                             ; $DADD: 17
  BMI L_DB16                                            ; $DADE: 30 36
  .byte $17                                             ; $DAE0: 17
  EOR ($42,X)                                           ; $DAE1: 41 42
  .byte $43, $44                                        ; $DAE3: 43 44
  EOR ($41,X)                                           ; $DAE5: 41 41
  EOR ($41,X)                                           ; $DAE7: 41 41
  EOR ($41,X)                                           ; $DAE9: 41 41
  EOR ($49,X)                                           ; $DAEB: 41 49
  LSR                                                   ; $DAED: 4A
  .byte $4B, $41 ; $DAEE: 4B 41
  EOR ($41,X)                                           ; $DAF0: 41 41
  EOR ($41,X)                                           ; $DAF2: 41 41
  EOR ($41,X)                                           ; $DAF4: 41 41
  BVC L_DB49                                            ; $DAF6: 50 51
  .byte $52                                             ; $DAF8: 52
  EOR ($41,X)                                           ; $DAF9: 41 41
  EOR ($41,X)                                           ; $DAFB: 41 41
  EOR ($41,X)                                           ; $DAFD: 41 41
  .byte $57                                             ; $DAFF: 57
  CLI                                                   ; $DB00: 58
  EOR $5B5A,Y                                           ; $DB01: 59 5A 5B
  .byte $5C                                             ; $DB04: 5C
  EOR ($41,X)                                           ; $DB05: 41 41
  EOR ($41,X)                                           ; $DB07: 41 41
  ADC ($62,X)                                           ; $DB09: 61 62
  .byte $63, $64                                        ; $DB0B: 63 64
  ADC $40                                               ; $DB0D: 65 40
  RTI                                                   ; $DB0F: 40
  RTI                                                   ; $DB10: 40
  EOR ($41,X)                                           ; $DB11: 41 41
L_DB13:
  PLA                                                   ; $DB13: 68
  ADC #$6A                                              ; $DB14: 69 6A
L_DB16:
  .byte $6B, $6C ; $DB16: 6B 6C
  RTI                                                   ; $DB18: 40
  RTI                                                   ; $DB19: 40
  RTI                                                   ; $DB1A: 40
  EOR ($41,X)                                           ; $DB1B: 41 41
  .byte $6F                                             ; $DB1D: 6F
  BVS L_DB91                                            ; $DB1E: 70 71
  .byte $72                                             ; $DB20: 72
  RTI                                                   ; $DB21: 40
  RTI                                                   ; $DB22: 40
  RTI                                                   ; $DB23: 40
  RTI                                                   ; $DB24: 40
  EOR ($73,X)                                           ; $DB25: 41 73
  .byte $74                                             ; $DB27: 74
  ADC $76,X                                             ; $DB28: 75 76
  RTI                                                   ; $DB2A: 40
  RTI                                                   ; $DB2B: 40
  RTI                                                   ; $DB2C: 40
  RTI                                                   ; $DB2D: 40
  RTI                                                   ; $DB2E: 40
  .byte $77                                             ; $DB2F: 77
  SEI                                                   ; $DB30: 78
  ADC $7B7A,Y                                           ; $DB31: 79 7A 7B
  RTI                                                   ; $DB34: 40
  RTI                                                   ; $DB35: 40
  .byte $7C                                             ; $DB36: 7C
  ADC $417E,X                                           ; $DB37: 7D 7E 41
  RTI                                                   ; $DB3A: 40
  .byte $7F                                             ; $DB3B: 7F
  BRK                                                   ; $DB3C: 00
  ORA ($40,X)                                           ; $DB3D: 01 40
  RTI                                                   ; $DB3F: 40
  .byte $02                                             ; $DB40: 02
  EOR ($41,X)                                           ; $DB41: 41 41
  EOR ($40,X)                                           ; $DB43: 41 40
  TAX                                                   ; $DB45: AA
  BRK                                                   ; $DB46: 00
  ROL $10,X                                             ; $DB47: 36 10
L_DB49:
  ASL $10,X                                             ; $DB49: 16 10
  ASL $17                                               ; $DB4B: 06 17
  RTI                                                   ; $DB4D: 40
  EOR ($42,X)                                           ; $DB4E: 41 42
  .byte $43, $44                                        ; $DB50: 43 44
  EOR $46                                               ; $DB52: 45 46
  .byte $47                                             ; $DB54: 47
  PHA                                                   ; $DB55: 48
  EOR #$4A                                              ; $DB56: 49 4A
  .byte $4B, $4C ; $DB58: 4B 4C
  EOR $4F4E                                             ; $DB5A: 4D 4E 4F
  BVC L_DBB0                                            ; $DB5D: 50 51
  .byte $52, $53                                        ; $DB5F: 52 53
  BRK                                                   ; $DB61: 00
  .byte $54                                             ; $DB62: 54
  EOR $56,X                                             ; $DB63: 55 56
  .byte $72, $72, $57                                   ; $DB65: 72 72 57
  CLI                                                   ; $DB68: 58
  EOR $5B5A,Y                                           ; $DB69: 59 5A 5B
  .byte $5C                                             ; $DB6C: 5C
  EOR $725E,X                                           ; $DB6D: 5D 5E 72
  .byte $72, $5F                                        ; $DB70: 72 5F
  RTS                                                   ; $DB72: 60

;===============================================================================
; $DB73: NewGameInit
;===============================================================================
  .byte $61, $62, $63, $64, $65, $72                    ; $DB73: 61 62 63 64 65 72
  BRK                                                   ; $DB79: 00
  BRK                                                   ; $DB7A: 00
  .byte $72                                             ; $DB7B: 72
  ROR $67                                               ; $DB7C: 66 67
  PLA                                                   ; $DB7E: 68
  ADC #$6A                                              ; $DB7F: 69 6A
  .byte $72, $72                                        ; $DB81: 72 72
  BRK                                                   ; $DB83: 00
  BRK                                                   ; $DB84: 00
  .byte $72                                             ; $DB85: 72
  .byte $6B, $6C ; $DB86: 6B 6C
  ADC $6F6E                                             ; $DB88: 6D 6E 6F
  .byte $72                                             ; $DB8B: 72
  BRK                                                   ; $DB8C: 00
  BRK                                                   ; $DB8D: 00
  BRK                                                   ; $DB8E: 00
  .byte $72, $72                                        ; $DB8F: 72 72
L_DB91:
  .byte $72, $72                                        ; $DB91: 72 72
  BVS L_DC06                                            ; $DB93: 70 71
  .byte $72                                             ; $DB95: 72
  BRK                                                   ; $DB96: 00
  BRK                                                   ; $DB97: 00
  BRK                                                   ; $DB98: 00
  BRK                                                   ; $DB99: 00
  .byte $72, $72, $72, $72, $72, $72                    ; $DB9A: 72 72 72 72 72 72
  BRK                                                   ; $DBA0: 00
  BRK                                                   ; $DBA1: 00
  BRK                                                   ; $DBA2: 00
  BRK                                                   ; $DBA3: 00
  .byte $72, $72, $72, $72, $72                         ; $DBA4: 72 72 72 72 72
  BRK                                                   ; $DBA9: 00
  BRK                                                   ; $DBAA: 00
  BRK                                                   ; $DBAB: 00
  BRK                                                   ; $DBAC: 00
  BRK                                                   ; $DBAD: 00
  BRK                                                   ; $DBAE: 00
  .byte $72                                             ; $DBAF: 72
L_DBB0:
  .byte $72                                             ; $DBB0: 72
  LDA $0000                                             ; $DBB1: AD 00 00
  ASL                                                   ; $DBB4: 0A
  TAY                                                   ; $DBB5: A8
  LDA $DBCF,Y                                           ; $DBB6: B9 CF DB
  STA $000A                                             ; $DBB9: 8D 0A 00
  LDA $DBD0,Y                                           ; $DBBC: B9 D0 DB
  STA $000B                                             ; $DBBF: 8D 0B 00
  LDY #$00                                              ; $DBC2: A0 00
L_DBC4:
  LDA ($0A),Y                                           ; $DBC4: B1 0A
  STA $0100,Y                                           ; $DBC6: 99 00 01
  INY                                                   ; $DBC9: C8
  CPY #$20                                              ; $DBCA: C0 20
  BCC L_DBC4                                            ; $DBCC: 90 F6
  RTS                                                   ; $DBCE: 60

;===============================================================================
; $DBCF: InitKingdomDefaults
;===============================================================================
  .byte $EB, $DB, $0B, $DC, $2B, $DC, $4B, $DC, $6B, $DC, $8B, $DC, $AB, $DC, $CB, $DC ; $DBCF: EB DB 0B DC 2B DC 4B DC 6B DC 8B DC AB DC CB DC
  .byte $EB, $DC, $EB, $DC, $0B, $DD, $2B, $DD, $4B, $DD, $6B, $DD, $0F, $12, $1A, $2A ; $DBDF: EB DC EB DC 0B DD 2B DD 4B DD 6B DD 0F 12 1A 2A
  .byte $0F, $27, $16, $2A, $0F, $36, $30, $16, $0F, $36, $30, $16, $0F, $0F ; $DBEF: 0F 27 16 2A 0F 36 30 16 0F 36 30 16 0F 0F
  JSR $0F16                                             ; $DBFD: 20 16 0F
  .byte $0F                                             ; $DC00: 0F
  .byte $2B, $28 ; $DC01: 2B 28
  .byte $0F                                             ; $DC03: 0F
  ROL $30,X                                             ; $DC04: 36 30
L_DC06:
  ASL $0F,X                                             ; $DC06: 16 0F
  JSR $1727                                             ; $DC08: 20 27 17
  .byte $0F, $27                                        ; $DC0B: 0F 27
  ORA $0F0A,Y                                           ; $DC0D: 19 0A 0F
  ORA $0212,Y                                           ; $DC10: 19 12 02
  .byte $0F                                             ; $DC13: 0F
  ROL $20,X                                             ; $DC14: 36 20
  ASL $0F,X                                             ; $DC16: 16 0F
  JSR $2020                                             ; $DC18: 20 20 20
  .byte $0F, $0F                                        ; $DC1B: 0F 0F
  JSR $0F16                                             ; $DC1D: 20 16 0F
  .byte $0F, $27, $17, $0F                              ; $DC20: 0F 27 17 0F
  JSR $1727                                             ; $DC24: 20 27 17
  .byte $0F                                             ; $DC27: 0F
  JSR $1727                                             ; $DC28: 20 27 17
  .byte $0F                                             ; $DC2B: 0F
  AND #$1A                                              ; $DC2C: 29 1A
  ORA #$0F                                              ; $DC2E: 09 0F
  AND #$36                                              ; $DC30: 29 36
  ASL $0F                                               ; $DC32: 06 0F
  ROL $20,X                                             ; $DC34: 36 20
  ASL $0F,X                                             ; $DC36: 16 0F
  AND #$36                                              ; $DC38: 29 36
  .byte $14, $0F, $0F                                   ; $DC3A: 14 0F 0F
  ROL $06,X                                             ; $DC3D: 36 06
  .byte $0F, $0F                                        ; $DC3F: 0F 0F
  ROL $14,X                                             ; $DC41: 36 14
  .byte $0F, $0F                                        ; $DC43: 0F 0F
  JSR $0F16                                             ; $DC45: 20 16 0F
  JSR $1727                                             ; $DC48: 20 27 17
  .byte $0F, $27, $17                                   ; $DC4B: 0F 27 17
  CLC                                                   ; $DC4E: 18
  .byte $0F, $27                                        ; $DC4F: 0F 27
  ROL $06,X                                             ; $DC51: 36 06
  .byte $0F                                             ; $DC53: 0F
  ROL $20,X                                             ; $DC54: 36 20
  ASL $0F,X                                             ; $DC56: 16 0F
  .byte $27                                             ; $DC58: 27
  ROL $14,X                                             ; $DC59: 36 14
  .byte $0F, $0F                                        ; $DC5B: 0F 0F
  ROL $06,X                                             ; $DC5D: 36 06
  .byte $0F, $0F                                        ; $DC5F: 0F 0F
  ROL $14,X                                             ; $DC61: 36 14
  .byte $0F, $0F                                        ; $DC63: 0F 0F
  JSR $0F16                                             ; $DC65: 20 16 0F
  JSR $1727                                             ; $DC68: 20 27 17
  .byte $0F, $37                                        ; $DC6B: 0F 37
  AND #$19                                              ; $DC6D: 29 19
  .byte $0F, $37                                        ; $DC6F: 0F 37
  ROL $06,X                                             ; $DC71: 36 06
  .byte $0F                                             ; $DC73: 0F
  ROL $20,X                                             ; $DC74: 36 20
  ASL $0F,X                                             ; $DC76: 16 0F
  .byte $37                                             ; $DC78: 37
  ROL $14,X                                             ; $DC79: 36 14
  .byte $0F, $0F                                        ; $DC7B: 0F 0F
  ROL $06,X                                             ; $DC7D: 36 06
  .byte $0F, $0F                                        ; $DC7F: 0F 0F
  ROL $14,X                                             ; $DC81: 36 14
  .byte $0F, $0F                                        ; $DC83: 0F 0F
  JSR $0F16                                             ; $DC85: 20 16 0F
  JSR $1727                                             ; $DC88: 20 27 17
  .byte $0F                                             ; $DC8B: 0F
  AND ($20,X)                                           ; $DC8C: 21 20
  .byte $12, $0F                                        ; $DC8E: 12 0F
  AND ($36,X)                                           ; $DC90: 21 36
  ASL $0F                                               ; $DC92: 06 0F
  ROL $20,X                                             ; $DC94: 36 20
  ASL $0F,X                                             ; $DC96: 16 0F
  AND ($36,X)                                           ; $DC98: 21 36
  .byte $14, $0F, $0F                                   ; $DC9A: 14 0F 0F
  ROL $06,X                                             ; $DC9D: 36 06
  .byte $0F, $0F                                        ; $DC9F: 0F 0F
  ROL $14,X                                             ; $DCA1: 36 14
  .byte $0F, $0F                                        ; $DCA3: 0F 0F
  JSR $0F16                                             ; $DCA5: 20 16 0F
  JSR $1727                                             ; $DCA8: 20 27 17
  .byte $0F                                             ; $DCAB: 0F
  AND $1929,Y                                           ; $DCAC: 39 29 19
  .byte $0F                                             ; $DCAF: 0F
  AND $0636,Y                                           ; $DCB0: 39 36 06
  .byte $0F                                             ; $DCB3: 0F
  ROL $20,X                                             ; $DCB4: 36 20
  ASL $0F,X                                             ; $DCB6: 16 0F
  AND $1436,Y                                           ; $DCB8: 39 36 14
  .byte $0F, $0F                                        ; $DCBB: 0F 0F
  ROL $06,X                                             ; $DCBD: 36 06
  .byte $0F, $0F                                        ; $DCBF: 0F 0F
  ROL $14,X                                             ; $DCC1: 36 14
  .byte $0F, $0F                                        ; $DCC3: 0F 0F
  JSR $0F16                                             ; $DCC5: 20 16 0F
  JSR $1727                                             ; $DCC8: 20 27 17
  .byte $0F                                             ; $DCCB: 0F
  BPL L_DCCE                                            ; $DCCC: 10 00
L_DCCE:
  JSR $100F                                             ; $DCCE: 20 0F 10
  ROL $06,X                                             ; $DCD1: 36 06
  .byte $0F                                             ; $DCD3: 0F
  ROL $20,X                                             ; $DCD4: 36 20
  ASL $0F,X                                             ; $DCD6: 16 0F
  BPL L_DD10                                            ; $DCD8: 10 36
  .byte $14, $0F, $0F                                   ; $DCDA: 14 0F 0F
  ROL $06,X                                             ; $DCDD: 36 06
  .byte $0F, $0F                                        ; $DCDF: 0F 0F
  ROL $14,X                                             ; $DCE1: 36 14
  .byte $0F, $0F                                        ; $DCE3: 0F 0F
  JSR $0F16                                             ; $DCE5: 20 16 0F
  JSR $1727                                             ; $DCE8: 20 27 17
  .byte $0F                                             ; $DCEB: 0F
  AND #$1A                                              ; $DCEC: 29 1A
  ORA #$0F                                              ; $DCEE: 09 0F
  AND #$36                                              ; $DCF0: 29 36
  ASL $0F                                               ; $DCF2: 06 0F
  ROL $20,X                                             ; $DCF4: 36 20
  ASL $0F,X                                             ; $DCF6: 16 0F
  AND #$36                                              ; $DCF8: 29 36
  .byte $14, $0F, $0F                                   ; $DCFA: 14 0F 0F
  ROL $06,X                                             ; $DCFD: 36 06
  .byte $0F, $0F                                        ; $DCFF: 0F 0F
  ROL $14,X                                             ; $DD01: 36 14
  .byte $0F, $0F                                        ; $DD03: 0F 0F
  JSR $0F16                                             ; $DD05: 20 16 0F
  JSR $1727                                             ; $DD08: 20 27 17
  .byte $0F, $17                                        ; $DD0B: 0F 17
  CLC                                                   ; $DD0D: 18
  ROL $0F,X                                             ; $DD0E: 36 0F
L_DD10:
  .byte $17                                             ; $DD10: 17
  JSR $0F36                                             ; $DD11: 20 36 0F
  ROL $20,X                                             ; $DD14: 36 20
  ASL $0F,X                                             ; $DD16: 16 0F
  .byte $17                                             ; $DD18: 17
  ASL $36,X                                             ; $DD19: 16 36
  .byte $0F, $17                                        ; $DD1B: 0F 17
  CLC                                                   ; $DD1D: 18
  ROL $0F,X                                             ; $DD1E: 36 0F
  .byte $17                                             ; $DD20: 17
  JSR $0F36                                             ; $DD21: 20 36 0F
  .byte $17                                             ; $DD24: 17
  ASL $36,X                                             ; $DD25: 16 36
  .byte $0F                                             ; $DD27: 0F
  JSR $1727                                             ; $DD28: 20 27 17
  .byte $0F                                             ; $DD2B: 0F
  BPL L_DD3D                                            ; $DD2C: 10 0F
  BRK                                                   ; $DD2E: 00
  .byte $0F                                             ; $DD2F: 0F
  ASL $0F,X                                             ; $DD30: 16 0F
  BMI L_DD43                                            ; $DD32: 30 0F
  .byte $17, $07                                        ; $DD34: 17 07
  AND ($0F,X)                                           ; $DD36: 21 0F
  .byte $17                                             ; $DD38: 17
  BPL L_DD5C                                            ; $DD39: 10 21
  .byte $0F, $0F                                        ; $DD3B: 0F 0F
L_DD3D:
  .byte $30, $0A ; $DD3D: 30 0A
  .byte $0F                                             ; $DD3F: 0F
  ASL $28,X                                             ; $DD40: 16 28
  .byte $0F                                             ; $DD42: 0F
L_DD43:
  .byte $0F                                             ; $DD43: 0F
  BMI L_DD76                                            ; $DD44: 30 30
  .byte $30, $0F ; $DD46: 30 0F
  ASL $07                                               ; $DD48: 06 07
  AND ($0F,X)                                           ; $DD4A: 21 0F
  ROL $30,X                                             ; $DD4C: 36 30
  ASL $0F,X                                             ; $DD4E: 16 0F
  .byte $27                                             ; $DD50: 27
  ASL $2A,X                                             ; $DD51: 16 2A
  .byte $0F                                             ; $DD53: 0F
  ROL $30,X                                             ; $DD54: 36 30
  ASL $0F,X                                             ; $DD56: 16 0F
  ROL $30,X                                             ; $DD58: 36 30
  ASL $0F,X                                             ; $DD5A: 16 0F
L_DD5C:
  .byte $0F                                             ; $DD5C: 0F
  JSR $0F16                                             ; $DD5D: 20 16 0F
  .byte $0F                                             ; $DD60: 0F
  .byte $2B, $28 ; $DD61: 2B 28
  .byte $0F                                             ; $DD63: 0F
  ROL $30,X                                             ; $DD64: 36 30
  ASL $0F,X                                             ; $DD66: 16 0F
  JSR $1727                                             ; $DD68: 20 27 17
  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F ; $DD6B: 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F
L_DD76:
  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F ; $DD76: 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F
  .byte $0F, $0F                                        ; $DD86: 0F 0F

;===============================================================================
; $DD88: SramStoreLoop
;===============================================================================
  .byte $0F, $0F, $0F                                   ; $DD88: 0F 0F 0F
  LDA $6F43                                             ; $DD8B: AD 43 6F
  PHA                                                   ; $DD8E: 48
  LDA #$60                                              ; $DD8F: A9 60

;===============================================================================
; $DD91: SramInitMain
;===============================================================================
  STA $0001                                             ; $DD91: 8D 01 00
  LDA #$00                                              ; $DD94: A9 00
  STA $0000                                             ; $DD96: 8D 00 00
  TAY                                                   ; $DD99: A8
L_DD9A:
  STA ($00),Y                                           ; $DD9A: 91 00
  INY                                                   ; $DD9C: C8
  BNE L_DD9A                                            ; $DD9D: D0 FB
  INC $0001                                             ; $DD9F: EE 01 00
  LDX $0001                                             ; $DDA2: AE 01 00
  CPX #$70                                              ; $DDA5: E0 70
  BCC L_DD9A                                            ; $DDA7: 90 F1
  PLA                                                   ; $DDA9: 68
  STA $6F43                                             ; $DDAA: 8D 43 6F
L_DDAD:
  JSR B1F_RandomByte                                          ; $DDAD: 20 7A E8
  AND #$07                                              ; $DDB0: 29 07
  CMP #$05                                              ; $DDB2: C9 05
  BCS L_DDAD                                            ; $DDB4: B0 F7
  STA $6F45                                             ; $DDB6: 8D 45 6F
  LDA #$FF                                              ; $DDB9: A9 FF
  STA $6F04                                             ; $DDBB: 8D 04 6F
  LDA #$FF                                              ; $DDBE: A9 FF
  STA $6FE2                                             ; $DDC0: 8D E2 6F
  LDA #$0B                                              ; $DDC3: A9 0B
  STA $0400                                             ; $DDC5: 8D 00 04
  LDA #$00                                              ; $DDC8: A9 00
  STA $0401                                             ; $DDCA: 8D 01 04
  LDY #$30                                              ; $DDCD: A0 30
  JSR B1F_SwitchBank8_B                                 ; $DDCF: 20 5F F2
  LDA #$00                                              ; $DDD2: A9 00
  STA $0000                                             ; $DDD4: 8D 00 00
  LDA #$8C                                              ; $DDD7: A9 8C
  STA $0001                                             ; $DDD9: 8D 01 00
  LDA #$00                                              ; $DDDC: A9 00
  STA $0002                                             ; $DDDE: 8D 02 00
  LDA #$60                                              ; $DDE1: A9 60

;===============================================================================
; $DDE3: SramCopyBlock
;===============================================================================
  STA $0003                                             ; $DDE3: 8D 03 00
  LDY #$00                                              ; $DDE6: A0 00
  LDX #$00                                              ; $DDE8: A2 00
  STX $0004                                             ; $DDEA: 8E 04 00
L_DDED:
  LDA ($00),Y                                           ; $DDED: B1 00
  STA ($02),Y                                           ; $DDEF: 91 02
  INC $0000                                             ; $DDF1: EE 00 00
  BNE L_DDF9                                            ; $DDF4: D0 03
  INC $0001                                             ; $DDF6: EE 01 00
L_DDF9:
  INC $0002                                             ; $DDF9: EE 02 00
  BNE L_DE01                                            ; $DDFC: D0 03
  INC $0003                                             ; $DDFE: EE 03 00
L_DE01:
  INX                                                   ; $DE01: E8
  BNE L_DE07                                            ; $DE02: D0 03
  INC $0004                                             ; $DE04: EE 04 00
L_DE07:
  LDA $0004                                             ; $DE07: AD 04 00
  CMP #$03                                              ; $DE0A: C9 03
  BCC L_DDED                                            ; $DE0C: 90 DF
  CPX #$C0                                              ; $DE0E: E0 C0
  BCC L_DDED                                            ; $DE10: 90 DB
  LDY #$31                                              ; $DE12: A0 31
  JSR B1F_SwitchBank8_B                                 ; $DE14: 20 5F F2
  LDA #$00                                              ; $DE17: A9 00
  STA $0000                                             ; $DE19: 8D 00 00
  LDA #$80                                              ; $DE1C: A9 80
  STA $0001                                             ; $DE1E: 8D 01 00
  LDA #$C0                                              ; $DE21: A9 C0
  STA $0002                                             ; $DE23: 8D 02 00
  LDA #$63                                              ; $DE26: A9 63
  STA $0003                                             ; $DE28: 8D 03 00
  LDY #$00                                              ; $DE2B: A0 00
  LDX #$00                                              ; $DE2D: A2 00
  STX $0004                                             ; $DE2F: 8E 04 00
L_DE32:
  LDA ($00),Y                                           ; $DE32: B1 00
  STA ($02),Y                                           ; $DE34: 91 02
  INC $0000                                             ; $DE36: EE 00 00
  BNE L_DE3E                                            ; $DE39: D0 03
  INC $0001                                             ; $DE3B: EE 01 00
L_DE3E:
  INC $0002                                             ; $DE3E: EE 02 00
  BNE L_DE46                                            ; $DE41: D0 03
  INC $0003                                             ; $DE43: EE 03 00
L_DE46:
  INX                                                   ; $DE46: E8
  BNE L_DE4C                                            ; $DE47: D0 03
  INC $0004                                             ; $DE49: EE 04 00
L_DE4C:
  LDA $0004                                             ; $DE4C: AD 04 00
  CMP #$0B                                              ; $DE4F: C9 0B
  BCC L_DE32                                            ; $DE51: 90 DF
  CPX #$40                                              ; $DE53: E0 40
  BCC L_DE32                                            ; $DE55: 90 DB
  LDA #$59                                              ; $DE57: A9 59
  STA $6F00                                             ; $DE59: 8D 00 6F
  LDA #$00                                              ; $DE5C: A9 00
  STA $6F01                                             ; $DE5E: 8D 01 6F
  LDA #$FF                                              ; $DE61: A9 FF
  STA $6F83                                             ; $DE63: 8D 83 6F
  STA $6F84                                             ; $DE66: 8D 84 6F
  STA $6F85                                             ; $DE69: 8D 85 6F
  STA $6F86                                             ; $DE6C: 8D 86 6F
  STA $6F87                                             ; $DE6F: 8D 87 6F
  STA $6F88                                             ; $DE72: 8D 88 6F
  STA $6F89                                             ; $DE75: 8D 89 6F
  LDA #$00                                              ; $DE78: A9 00
  STA $6F8A                                             ; $DE7A: 8D 8A 6F
  RTS                                                   ; $DE7D: 60

;===============================================================================
; $DE7E: OfficerParamDisp
;===============================================================================
  LDY #$21                                              ; $DE7E: A0 21
  JSR B1F_SwitchBank8_B                                 ; $DE80: 20 5F F2
  LDY #$00                                              ; $DE83: A0 00
  STY $0001                                             ; $DE85: 8C 01 00
  STA $0000                                             ; $DE88: 8D 00 00
  ASL                                                   ; $DE8B: 0A
  CLC                                                   ; $DE8C: 18
  ADC $0000                                             ; $DE8D: 6D 00 00
  ASL                                                   ; $DE90: 0A
  ROL $0001                                             ; $DE91: 2E 01 00
  ASL                                                   ; $DE94: 0A
  ROL $0001                                             ; $DE95: 2E 01 00
  ASL                                                   ; $DE98: 0A
  ROL $0001                                             ; $DE99: 2E 01 00
  ASL                                                   ; $DE9C: 0A
  ROL $0001                                             ; $DE9D: 2E 01 00
  CLC                                                   ; $DEA0: 18
  ADC #$6C                                              ; $DEA1: 69 6C
  STA $0002                                             ; $DEA3: 8D 02 00
  LDA #$94                                              ; $DEA6: A9 94
  ADC $0001                                             ; $DEA8: 6D 01 00
  STA $0003                                             ; $DEAB: 8D 03 00
L_DEAE:
  LDA ($02),Y                                           ; $DEAE: B1 02
  STA $00AE,Y                                           ; $DEB0: 99 AE 00
  INY                                                   ; $DEB3: C8
  CPY #$30                                              ; $DEB4: C0 30
  BCC L_DEAE                                            ; $DEB6: 90 F6
  RTS                                                   ; $DEB8: 60

;===============================================================================
; $DEB9: OfficerRecLookup
;===============================================================================
  STA $0000                                             ; $DEB9: 8D 00 00
  TAX                                                   ; $DEBC: AA
  ASL                                                   ; $DEBD: 0A
  ASL                                                   ; $DEBE: 0A
  CLC                                                   ; $DEBF: 18
  ADC $0000                                             ; $DEC0: 6D 00 00
  ASL                                                   ; $DEC3: 0A
  TAY                                                   ; $DEC4: A8
  LDA $DF1A,Y                                           ; $DEC5: B9 1A DF
  STA $0068                                             ; $DEC8: 8D 68 00
  LDA $DF1B,Y                                           ; $DECB: B9 1B DF
  STA $0069                                             ; $DECE: 8D 69 00
  LDA $DF1C,Y                                           ; $DED1: B9 1C DF
  STA $006A                                             ; $DED4: 8D 6A 00
  LDA $DF1D,Y                                           ; $DED7: B9 1D DF
  STA $006B                                             ; $DEDA: 8D 6B 00
  LDA $DF1E,Y                                           ; $DEDD: B9 1E DF
  STA $006C                                             ; $DEE0: 8D 6C 00
  LDA $DF1F,Y                                           ; $DEE3: B9 1F DF
  STA $006D                                             ; $DEE6: 8D 6D 00
  LDA $DF20,Y                                           ; $DEE9: B9 20 DF
  STA $006E                                             ; $DEEC: 8D 6E 00
  LDA $DF21,Y                                           ; $DEEF: B9 21 DF
  STA $006F                                             ; $DEF2: 8D 6F 00
  LDA $DF22,Y                                           ; $DEF5: B9 22 DF
  STA $0070                                             ; $DEF8: 8D 70 00
  LDA $DF23,Y                                           ; $DEFB: B9 23 DF
  STA $0071                                             ; $DEFE: 8D 71 00
  LDA $DF56,X                                           ; $DF01: BD 56 DF
  STA $0072                                             ; $DF04: 8D 72 00
  LDA $DF5C,X                                           ; $DF07: BD 5C DF
  STA $0073                                             ; $DF0A: 8D 73 00
  LDA $DF62,X                                           ; $DF0D: BD 62 DF
  STA $0074                                             ; $DF10: 8D 74 00
  LDA $DF68,X                                           ; $DF13: BD 68 DF
  STA $0061                                             ; $DF16: 8D 61 00
  RTS                                                   ; $DF19: 60

;===============================================================================
; $DF1A: PointerTable
;===============================================================================
  .byte $40, $E9, $14, $F2, $1E, $F2, $20, $F2, $FA, $F1, $6C, $B0, $20, $F2, $20, $F2 ; $DF1A: 40 E9 14 F2 1E F2 20 F2 FA F1 6C B0 20 F2 20 F2
  .byte $20, $F2, $D0, $F1, $50, $E9, $40, $F2, $BA, $D5, $20, $F2, $80, $F1, $40, $E9 ; $DF2A: 20 F2 D0 F1 50 E9 40 F2 BA D5 20 F2 80 F1 40 E9
  .byte $30, $F2, $A0, $F2, $F0, $F8, $20, $EA, $A0, $E9, $1E, $F2, $14, $F2, $20, $F2 ; $DF3A: 30 F2 A0 F2 F0 F8 20 EA A0 E9 1E F2 14 F2 20 F2
  .byte $8B, $F1, $F0, $EF, $70, $F2, $20, $F2, $10, $F2, $D0, $EA, $2F, $0F, $0F, $0F ; $DF4A: 8B F1 F0 EF 70 F2 20 F2 10 F2 D0 EA 2F 0F 0F 0F
  .byte $29, $0F, $0E, $14, $14, $14, $0E, $14, $0F, $14, $14, $14, $0F, $14, $03, $0A ; $DF5A: 29 0F 0E 14 14 14 0E 14 0F 14 14 14 0F 14 03 0A
  .byte $0B, $08, $03, $03, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DF6A: 0B 08 03 03 FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DF7A: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DF8A: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DF9A: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFAA: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFBA: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFCA: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFDA: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFEA: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF, $FF, $FF, $FF, $FF, $FF                    ; $DFFA: FF FF FF FF FF FF
