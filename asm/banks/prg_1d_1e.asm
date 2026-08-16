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

;-------------------------------------------------------------------------------
; Zero-page scratch / workspace ($0000-$001F)
;-------------------------------------------------------------------------------
zp_ptr_lo         = $0000  ; general-purpose ZP pointer lo (used by 28+ procs)
zp_ptr_hi         = $0001  ; general-purpose ZP pointer hi (used by 17+ procs)
work2_lo          = $0002  ; secondary workspace lo (OfficerRecCalc, StateHandler, etc.)
work2_hi          = $0003  ; secondary workspace hi
copy_bank_ctr     = $0004  ; bank copy counter (SramInit, StateHandler)
state_tmp         = $0006  ; StateHandler temp / VerifyChecksum workspace
bcd_digit2        = $0007  ; BCD result byte 2 (PeriodicOverlayRefresh, YearDisplaySetup)
bcd_digit1        = $0008  ; BCD result byte 1 (YearDisplaySetup, MenuUpdate)
bcd_digit0        = $0009  ; BCD result byte 0 (MenuUpdate)
banked_work0      = $000A  ; BankedDataHandler / DisplayTileData workspace
banked_work1      = $000B
banked_work2      = $000C  ; (also used by DisplayTileData)
tile_ptr_lo       = $0010  ; tilemap data pointer lo (DisplayTileData, StateHandler)
tile_ptr_hi       = $0011  ; tilemap data pointer hi
; cmd_byte         = $0012  ; (already defined) current command byte from data stream
vram_tmp_lo       = $0013  ; VRAM position temp lo (StateHandler, OfficerListHandler)
; 0014: OfficerListHandler local (officer list workspace)
; cmd_byte         = $0012  ; (already defined) current command byte from data stream
; 0015: not found in code
; 0016: StateHandler local (officer record index temp)
prov_data_ptr_lo  = $0017  ; province/officer data ptr lo (StateHandler, OfficerListHandler)
; 0018: StateHandler local (province data ptr hi)
; officer_list_tmp  = 0019  ; (OfficerListHandler local)
; officer_src_lo    = 001A  ; (OfficerListHandler local)
; officer_src_hi    = 001B  ; (OfficerListHandler local)
; officer_dst_lo    = 001C  ; (OfficerListHandler local)
; officer_dst_hi    = 001D  ; (OfficerListHandler local)
; province_tmp      = 0020  ; (ProvinceDataHandler local)

;-------------------------------------------------------------------------------
; Zero-page display / render state ($005E-$0074)
;-------------------------------------------------------------------------------
frame_tick_ctr    = $005E  ; frame tick counter (PPUTileRender, PeriodicOverlayRefresh)
disp_row_count    = $0061  ; display row count / visible rows (OfficerListHandler, SceneRenderer)
scene_param0      = $0068  ; SceneRenderer / OfficerRecLookup param 0
scene_param1      = $0069  ; SceneRenderer / OfficerRecLookup param 1
scene_param2      = $006A  ; SceneRenderer / OfficerRecLookup param 2
scene_param3      = $006B  ; SceneRenderer / OfficerRecLookup param 3
scene_param4      = $006C  ; SceneRenderer / OfficerRecLookup param 4
scene_param5      = $006D  ; SceneRenderer / OfficerRecLookup param 5
scene_param6      = $006E  ; SceneRenderer / OfficerRecLookup param 6
scene_param7      = $006F  ; SceneRenderer / OfficerRecLookup param 7
scene_param8      = $0070  ; SceneRenderer / OfficerRecLookup param 8
scene_param9      = $0071  ; SceneRenderer / OfficerRecLookup param 9
; officer_lookup_x  = 0072  ; (OfficerRecLookup local)
; officer_lookup_y  = 0073  ; (OfficerRecLookup local)
; scene_file_ref    = 0074  ; (OfficerRecLookup local)

;-------------------------------------------------------------------------------
; Zero-page state handler workspace ($00AE-$00DC)
;-------------------------------------------------------------------------------
officer_param_ofs = $00AE  ; officer param data offset (OfficerParamDisp, StateHandler)
state_row_ofs1    = $00B2  ; StateHandler row offset 1
tile_row_count    = $00B3  ; tile row count (StateHandler, SceneRenderer)
state_row_ofs2    = $00B4  ; StateHandler row offset 2
; setup_disp_tmp    = 00B9  ; (SetupBankedData local)
state_vram_cnt_lo = $00C1  ; StateHandler VRAM counter lo (paired with $00C2)
state_vram_cnt_hi = $00C2  ; StateHandler VRAM counter hi
state_row_cnt1_lo = $00C3  ; StateHandler row counter 1 lo (paired with $00C4)
state_row_cnt1_hi = $00C4  ; StateHandler row counter 1 hi
; setup_disp_b      = 00BF  ; (SetupDisplayPtrs local)
; setup_disp_c      = 00C0  ; (ResetDispatchState local)
; setup_disp_a      = 00C7  ; (SetupDisplayPtrs local)
; setup_disp_d      = 00C8  ; (ResetDispatchState local)
state_row_cnt2_lo = $00C9  ; StateHandler row counter 2 lo (paired with $00CA)
state_row_cnt2_hi = $00CA  ; StateHandler row counter 2 hi
; setup_disp_e      = 00CF  ; (SetupDisplayPtrs local)
state_vram_cnt2_lo = $00CB ; StateHandler VRAM counter 2 lo
state_vram_cnt2_hi = $00CC ; StateHandler VRAM counter 2 hi
state_row_cnt3_lo = $00D1  ; StateHandler row counter 3 lo (paired with $00D2)
state_row_cnt3_hi = $00D2  ; StateHandler row counter 3 hi
state_row_cnt4_lo = $00D3  ; StateHandler row counter 4 lo
state_row_cnt4_hi = $00D4  ; StateHandler row counter 4 hi
; state_vram_cnt3_lo = 00D6 ; (StateHandler local)
; state_vram_cnt3_hi = 00DA ; (StateHandler local)
state_row_cnt5_lo = $00DB  ; StateHandler row counter 5 lo
state_row_cnt5_hi = $00DC  ; StateHandler row counter 5 hi

;-------------------------------------------------------------------------------
; Page $01: State handler workspace / display buffers ($0100-$0190)
;-------------------------------------------------------------------------------
disp_ptr_table    = $0100  ; display pointer table (SetupDisplayPtrs, MenuRenderer_SecondaryDispatch, LoadScenarioData)
disp_ptr_src_lo   = $0110  ; display ptr source lo (SetupDisplayPtrs copies to $0100)
disp_ptr_src_hi   = $0120  ; display ptr source hi (SetupDisplayPtrs copies to $0110)
tile_buf_base     = $0140  ; state dispatch control / tile buffer base
state_scroll_x    = $0141  ; scroll X offset (StateHandler, MapDisplaySetup)
state_vram_hi     = $0142  ; VRAM addr hi (StateHandler, MapDisplaySetup)
state_vram_pos_lo = $0143  ; VRAM position lo (StateHandler scroll)
state_vram_pos_hi = $0144  ; VRAM position hi (StateHandler scroll)
state_disp_lo     = $0145  ; display VRAM addr lo (StateHandler)
state_disp_hi     = $0146  ; display VRAM addr hi (StateHandler)
state_attr_lo     = $0147  ; attr block addr lo (StateHandler)
state_attr_hi     = $0148  ; attr block addr hi (StateHandler)
tilemap_src_lo    = $0149  ; tilemap source ptr lo (StateHandler)
tilemap_src_hi    = $014A  ; tilemap source ptr hi (StateHandler)
state_scroll_y    = $014B  ; scroll Y / attr merge buffer (StateHandler)
officer_idx_buf   = $0150  ; state mode flags / officer index buffer
officer_list_idx  = $0151  ; OfficerListHandler index entry
state_name_vram_lo = $0152 ; name VRAM pos lo (StateHandler)
state_name_vram_hi = $0153 ; name VRAM pos hi (StateHandler)
state_row_limit   = $0154  ; row limit / total rows (StateHandler, MapDisplaySetup)
state_buf_end     = $0160  ; tile row buffer start (56 bytes, StateHandler)
state_officer_tmp = $0183  ; StateHandler / OfficerListHandler shared temp
; state_buf_extra   = 0166  ; (StateHandler local)
; state_buf_ext2    = 016F  ; (StateHandler local)
; state_buf_ext3    = 0175  ; (StateHandler local)
; state_buf_ext4    = 017D  ; (StateHandler local)
; state_work_area   = 0190  ; (StateHandler local)

;-------------------------------------------------------------------------------
; Page $02: OAM sprite data
;-------------------------------------------------------------------------------
oam_buf_lo        = $0200  ; OAM sprite buffer lo (SceneRenderer, SetupBankedData, StateHandler)
oam_buf_hi        = $0201  ; OAM sprite buffer hi
oam_buf_idx       = $0202  ; OAM sprite buffer index
oam_buf_extra     = $0203  ; OAM sprite buffer extra
; oam_extra         = 0204  ; (SceneRenderer local)

;-------------------------------------------------------------------------------
; Page $03: Display / render buffer ($037C-$03C3)
;-------------------------------------------------------------------------------
sub_state_main    = $037C  ; sub-state dispatch: main (StateHandler)
sub_state_prov    = $037D  ; sub-state dispatch: province timer (StateHandler)
sub_state_officer = $037E  ; sub-state dispatch: officer (StateHandler)
disp_buf_base     = $0380  ; display/render buffer base (14+ procs)
disp_buf_ofs1     = $0381  ; display buffer offset 1 (SceneRenderer, YearDisplaySetup, BankedDataHandler)
disp_buf_ofs2     = $0382  ; display buffer offset 2 (SceneRenderer, YearDisplaySetup, BankedDataHandler)
disp_buf_ofs3     = $0383  ; display buffer offset 3 (SceneRenderer, YearDisplaySetup)
disp_buf_ofs4     = $0389  ; display buffer offset 4 (YearDisplaySetup, BankedDataHandler)
disp_buf_ofs5     = $038A  ; display buffer offset 5 (YearDisplaySetup, BankedDataHandler)
disp_buf_ofs6     = $038D  ; display buffer offset 6 (YearDisplaySetup, BankedDataHandler)
disp_buf_ofs7     = $038E  ; display buffer offset 7 (YearDisplaySetup, BankedDataHandler)
disp_buf_ofs8     = $038F  ; display buffer offset 8 (YearDisplaySetup, BankedDataHandler)
disp_buf_ofs9     = $0390  ; display buffer offset 9 (YearDisplaySetup, BankedDataHandler)
disp_buf_ofsA     = $0391  ; display buffer offset A (YearDisplaySetup, BankedDataHandler)
disp_buf_ofsB     = $0392  ; display buffer offset B (YearDisplaySetup, BankedDataHandler)
disp_buf_ofsC     = $0393  ; display buffer offset C (YearDisplaySetup, BankedDataHandler)
disp_buf_ofsD     = $0394  ; display buffer offset D (YearDisplaySetup, BankedDataHandler)
; scaled_name_tmp   = $03A5  ; (DisplayScaledName/BankedDataHandler local)
; overlay_bcd_hi    = 03AA  ; (PeriodicOverlayRefresh local)
; overlay_bcd_lo    = 03AB  ; (PeriodicOverlayRefresh local)
; overlay_buf_end   = 03BA  ; (PeriodicOverlayRefresh local)
; scene_render_flag = 03C3  ; (SceneRenderer local)

;-------------------------------------------------------------------------------
; Page $04: Menu system / officer data / scene state ($0400-$04D6)
;-------------------------------------------------------------------------------
scene_callback_id = $0400  ; scene callback ID (SramInit, SceneRenderer)
scene_callback_st = $0401  ; scene callback state counter (SceneRenderer, StateHandler)
province_idx      = $0402  ; current province index (StateHandler, OfficerListHandler)
; officer_param_base = 040C ; (OfficerListHandler local)
menu_scroll_state = $0420  ; menu scroll / render state (StateHandler, MenuRenderer)
; officer_list_flag = 0424  ; (OfficerListHandler local)
; officer_list_tmp2 = 0425  ; (OfficerListHandler local)
; menu_fmt_data0    = 042C  ; (MenuUpdate local)
; menu_fmt_data1    = 042D  ; (MenuUpdate local)
; menu_fmt_data2    = 042E  ; (MenuUpdate local)
; menu_fmt_num0     = 044C  ; (MenuUpdate local)
; menu_fmt_num1     = 044D  ; (MenuUpdate local)
; menu_fmt_num2     = 044E  ; (MenuUpdate local)
; officer_list_st   = 0470  ; (SceneRenderer local)
; officer_list_st1  = 0471  ; (SceneRenderer local)
; officer_list_st2  = 0472  ; (SceneRenderer local)
; officer_list_st3  = 0473  ; (SceneRenderer local)
officer_list_ctrl = $0478  ; officer list control/state (OfficerListHandler)
officer_list_cnt  = $0479  ; officer list scroll count (OfficerListHandler)
officer_list_idx2 = $047A  ; officer list index counter (OfficerListHandler)
officer_list_max  = $047B  ; officer list max entries (OfficerListHandler)
; officer_list_col  = 047C  ; (OfficerListHandler local)
; officer_list_row  = 047D  ; (not found)
; officer_list_sel  = 047E  ; (not found)
; officer_list_scr  = 047F  ; (not found)
officer_name_buf  = $0480  ; officer name buffer ($0B bytes, OfficerListHandler, FlushTileBuffer)
officer_name_len  = $0481  ; officer name length / data (OfficerListHandler, FlushTileBuffer)
; officer_name_ext  = 0482  ; (OfficerListHandler local)
; officer_name_ext2 = 0483  ; (OfficerListHandler local)
; officer_name_ext3 = 0486  ; (OfficerListHandler local)
menu_dispatch_flg = $04A0  ; menu dispatch flag (MenuRenderer, MenuAction procs)
menu_row_step     = $04A1  ; menu row step counter (152 refs! core menu state)
menu_dispatch_idx = $04A2  ; menu dispatch index / phase (MenuRenderer, OfficerRecCalc)
menu_row_inc      = $04A3  ; menu row increment counter (MenuRenderer, OfficerRecCalc)
menu_action_param = $04A4  ; menu action parameter (various MenuAction procs)
menu_action_param2 = $04A5 ; menu action parameter 2 (various MenuAction procs)
; officer_name_disp = 04AE  ; (OfficerNameDisplay local)
menu_row_limit    = $04CC  ; menu row limit (MenuRenderer, OfficerRecCalc)
menu_disp_row_ctr = $04D0  ; menu display row counter (MenuRenderer, DomesticMenu_Return)
officer_rec_src_lo = $04D2 ; officer record source ptr lo (OfficerRecCalc)
officer_rec_src_hi = $04D3 ; officer record source ptr hi (OfficerRecCalc)
officer_rec_dst_lo = $04D4 ; officer record dest ptr lo (OfficerRecCalc)
officer_rec_dst_hi = $04D5 ; officer record dest ptr hi (OfficerRecCalc)
menu_action_extra = $04D6  ; menu action extra param (MenuAction08, ProvinceRecCalc)

;-------------------------------------------------------------------------------
; Page $05-$06: Province data (ProvinceDataHandler local)
;-------------------------------------------------------------------------------
; 0509: ProvinceDataHandler local (province data reference)
; 0664: ProvinceDataHandler local (province data reference 2)

;-------------------------------------------------------------------------------
; Previously defined variables (file-scope)
;-------------------------------------------------------------------------------

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

PPUTileRender_Entry:
  ; PPUTileRender
  JMP PPUTileRender               ; $A000: 4C 48 A0
MenuUpdate_Entry:
  ; MenuUpdate
  JMP MenuUpdate                  ; $A003: 4C 54 A1
VRAMBufferWrite_Entry:
  ; VRAMBufferWrite
  JMP VRAMBufferWrite             ; $A006: 4C 1B A1
StateHandler_Entry:
  ; StateHandler
  JMP StateHandler                ; $A009: 4C D2 AB
MapDisplaySetup_Entry:
  ; MapDisplaySetup
  JMP MapDisplaySetup             ; $A00C: 4C 9F B2
OfficerListHandler_Entry:
  ; OfficerListHandler
  JMP OfficerListHandler          ; $A00F: 4C 89 B9
FlushTileBuffer_Entry:
  ; FlushTileBuffer - upload 64-byte $0160 tile buffer to VRAM at $0480/$0481
  JMP FlushTileBuffer             ; $A012: 4C 41 BC
LoadScenarioData_Entry:
  ; LoadScenarioData
  JMP LoadScenarioData                      ; $A015: 4C B1 DB
SramInit_Entry:
  ; SramInit -> $DD8B (bank $1E)
  JMP SramInit                                ; $A018: 4C 8B DD
OfficerParamDisp_Entry:
  ; OfficerParamDisp
  JMP OfficerParamDisp                        ; $A01B: 4C 7E DE
YearDisplaySetup_Entry:
  ; YearDisplaySetup
  JMP YearDisplaySetup          ; $A01E: 4C B6 A6
SlowPeriodic_Entry:
  ; PeriodicOverlayRefresh
  JMP SlowPeriodic              ; $A021: 4C 7F A7
ImmediateOverlay_Entry:
  ; PeriodicOverlayRefresh
  JMP ImmediateOverlay            ; $A024: 4C B2 A7
ProvinceDataHandler_Entry:
  ; ProvinceDataHandler
  JMP ProvinceDataHandler         ; $A027: 4C 30 A8
OfficerDisplay_Lookup_Entry:
  ; OfficerDisplay_Lookup
  JMP OfficerDisplay_Lookup         ; $A02A: 4C 90 A8
FastPeriodic_Entry:
  ; PeriodicOverlayRefresh
  JMP FastPeriodic              ; $A02D: 4C 8A A7
OfficerDisplay_Render_Entry:
  ; OfficerDisplay_Render
  JMP OfficerDisplay_Render       ; $A030: 4C A4 A8
OfficerNameDisplay_Entry:
  ; OfficerNameDisplay
  JMP OfficerNameDisplay            ; $A033: 4C FD A8
ClearWorkBuffer_Entry:
  ; ClearWorkBuffer
  JMP ClearWorkBuffer             ; $A036: 4C 66 BC
SceneRenderer_Entry:
  ; SceneRenderer
  JMP SceneRenderer               ; $A039: 4C 71 BC
DataFormatter_Entry:
  ; DataFormatter
  JMP DataFormatter               ; $A03C: 4C 91 A9
MenuRenderer_Entry:
  ; MenuRenderer
  JMP MenuRenderer                ; $A03F: 4C 36 BE
BankedDataHandler_Entry:
  ; BankedDataHandler
  JMP BankedDataHandler           ; $A042: 4C 37 AA
OfficerRecLookup_Entry:
  ; OfficerRecLookup
  JMP OfficerRecLookup                      ; $A045: 4C B9 DE

;===============================================================================
; Code Region ($A048-$B304)
;===============================================================================


.proc PPUTileRender
PPUTileRender:
  LDA a:frame_flags                       ; $A048: AD 7E 00
  AND #$04                                ; $A04B: 29 04
  BEQ @check_flag2                            ; $A04D: F0 01
  RTS                                     ; $A04F: 60
@check_flag2:
  LDA overlay_flag                        ; $A050: AD 03 03
  BEQ @check_flag3                            ; $A053: F0 03
  JMP @render_row1                            ; $A055: 4C C4 A0
@check_flag3:
  LDA input_flag                          ; $A058: AD 08 03
  BEQ @check_mask                            ; $A05B: F0 03
  JMP @render_row1                            ; $A05D: 4C C4 A0
@check_mask:
  LDA frame_tick_ctr                      ; $A060: AD 5E 00
  AND render_bitmask                      ; $A063: 2D 05 03
  BEQ @render_single                            ; $A066: F0 03
  JMP B1F_NmiPaletteUpload                      ; $A068: 4C 72 EE
@render_single:
  LDY tile_col_idx                        ; $A06B: AC 04 03
  LDA tile_row2_data,Y                    ; $A06E: B9 4E 03
  CMP #$80                                ; $A071: C9 80
  BEQ @reset_tile                            ; $A073: F0 41
  LDA $2002                               ; $A075: AD 02 20
  LDA tile_row1_lo                        ; $A078: AD 1D 03
  STA $2006                               ; $A07B: 8D 06 20
  LDA tile_row1_hi                        ; $A07E: AD 1C 03
  CLC                                     ; $A081: 18
  ADC tile_col_idx                        ; $A082: 6D 04 03
  STA $2006                               ; $A085: 8D 06 20
  LDY tile_col_idx                        ; $A088: AC 04 03
  LDA tile_row1_data,Y                    ; $A08B: B9 1E 03
  STA $2007                               ; $A08E: 8D 07 20
  LDA indirect_flag                       ; $A091: AD 0C 03
  BNE @inc_and_exit                            ; $A094: D0 1C
  LDA $2002                               ; $A096: AD 02 20
  LDA tile_row2_lo                        ; $A099: AD 4D 03
  STA $2006                               ; $A09C: 8D 06 20
  LDA tile_row2_hi                        ; $A09F: AD 4C 03
  CLC                                     ; $A0A2: 18
  ADC tile_col_idx                        ; $A0A3: 6D 04 03
  STA $2006                               ; $A0A6: 8D 06 20
  LDY tile_col_idx                        ; $A0A9: AC 04 03
  LDA tile_row2_data,Y                    ; $A0AC: B9 4E 03
  STA $2007                               ; $A0AF: 8D 07 20
@inc_and_exit:
  INC tile_col_idx                        ; $A0B2: EE 04 03
  RTS                                     ; $A0B5: 60
@reset_tile:
  LDA #$FF                                ; $A0B6: A9 FF
  STA tile_col_idx                        ; $A0B8: 8D 04 03
  LDA a:frame_flags                       ; $A0BB: AD 7E 00
  AND #$FE                                ; $A0BE: 29 FE
  STA a:frame_flags                       ; $A0C0: 8D 7E 00
  RTS                                     ; $A0C3: 60
@render_row1:
  LDA $2002                               ; $A0C4: AD 02 20
  LDA tile_row1_lo                        ; $A0C7: AD 1D 03
  STA $2006                               ; $A0CA: 8D 06 20
  LDA tile_row1_hi                        ; $A0CD: AD 1C 03
  STA $2006                               ; $A0D0: 8D 06 20
  LDY #$00                                ; $A0D3: A0 00
@row1_loop:
  LDA tile_row1_data,Y                    ; $A0D5: B9 1E 03
  CMP #$80                                ; $A0D8: C9 80
  BEQ @check_row2                            ; $A0DA: F0 07
  STA $2007                               ; $A0DC: 8D 07 20
  INY                                     ; $A0DF: C8
  JMP @row1_loop                            ; $A0E0: 4C D5 A0
@check_row2:
  LDA indirect_flag                       ; $A0E3: AD 0C 03
  BNE @render_done                            ; $A0E6: D0 1F
  LDA $2002                               ; $A0E8: AD 02 20
  LDA tile_row2_lo                        ; $A0EB: AD 4D 03
  STA $2006                               ; $A0EE: 8D 06 20
  LDA tile_row2_hi                        ; $A0F1: AD 4C 03
  STA $2006                               ; $A0F4: 8D 06 20
  LDY #$00                                ; $A0F7: A0 00
@row2_loop:
  LDA tile_row2_data,Y                    ; $A0F9: B9 4E 03
  CMP #$80                                ; $A0FC: C9 80
  BEQ @render_done                            ; $A0FE: F0 07
  STA $2007                               ; $A100: 8D 07 20
  INY                                     ; $A103: C8
  JMP @row2_loop                            ; $A104: 4C F9 A0
@render_done:
  JMP @reset_tile                            ; $A107: 4C B6 A0
  LDA #$FF                                ; $A10A: A9 FF
  STA menu_status                         ; $A10C: 8D 00 03
  STA tile_col_idx                        ; $A10F: 8D 04 03
  LDA a:frame_flags                       ; $A112: AD 7E 00
  AND #$FE                                ; $A115: 29 FE
  STA a:frame_flags                       ; $A117: 8D 7E 00
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
  ; Proc-local RAM variables
  menu_fmt_data0    = $042C  ; formatted number data 0
  menu_fmt_data1    = $042D  ; formatted number data 1
  menu_fmt_data2    = $042E  ; formatted number data 2
  menu_fmt_num0     = $044C  ; formatted number 0
  menu_fmt_num1     = $044D  ; formatted number 1
  menu_fmt_num2     = $044E  ; formatted number 2
  menu_tile_tmp     = $034B  ; tile temp
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
  ; Proc-local RAM variables
  year_disp_84      = $0384  ; year display buffer 84
  year_disp_85      = $0385  ; year display buffer 85
  year_disp_86      = $0386  ; year display buffer 86
  year_disp_87      = $0387  ; year display buffer 87
  year_disp_88      = $0388  ; year display buffer 88
  year_disp_8B      = $038B  ; year display buffer 8B
  year_disp_8C      = $038C  ; year display buffer 8C
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
  ; Proc-local RAM variables
  overlay_bcd_hi    = $03AA  ; overlay BCD high digit tile
  overlay_bcd_lo    = $03AB  ; overlay BCD low digit tile
  overlay_buf_end   = $03BA  ; overlay buffer end
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
  ; Proc-local RAM variables
  province_tmp      = $0020  ; province data temp
  province_data_ref = $0509  ; province data reference
  province_data_ref2 = $0664 ; province data reference 2
ProvinceDataHandler:
  LDY #$3A                                ; $A830: A0 3A
@prov_copy_loop:
  LDA ProvinceDisplayTilemap,Y               ; $A832: B9 56 A8
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
; ProvinceDisplayTilemap - 59 bytes, overlay tilemap for province info display
; Format: cmd ($04=4 data bytes, $08=8 data bytes), VRAM hi, VRAM lo, tile data
; VRAM addresses increment by $0020 per row
ProvinceDisplayTilemap:                       ; $A856
  .byte $04, $22, $00, $00, $00, $00, $00   ; $A856: row 0 - blank, VRAM $2200
  .byte $04, $24, $00, $00, $00, $00, $00   ; $A85D: row 1 - blank, VRAM $2400
  .byte $04, $24, $20, $00, $00, $00, $00   ; $A864: row 2 - blank, VRAM $2420
  .byte $04, $24, $40, $00, $00, $00, $00   ; $A86B: row 3 - blank, VRAM $2440
  .byte $04, $24, $60, $00, $00, $00, $00   ; $A872: row 4 - blank, VRAM $2460
  .byte $04, $24, $80, $00, $00, $00, $00   ; $A879: row 5 - blank, VRAM $2480
  .byte $08, $24, $A0, $01, $01, $01, $01   ; $A880: row 6 - filled, VRAM $24A0
  .byte $01, $01, $01, $01                  ; $A885:   (cont row 6)
  .byte $08, $24, $C0, $01, $01, $01, $01   ; $A889: row 7 - filled, VRAM $24C0
  .byte $01, $01, $01, $01                  ; $A88E:   (cont row 7)
  .byte $FF                                 ; $A88F: sentinel

.endproc

.proc OfficerDisplay_Lookup
OfficerDisplay_Lookup:
  LDA $0000                               ; $A890: AD 00 00
  PHA                                     ; $A893: 48
  LDA #$00                                ; $A894: A9 00
  STA $0000                               ; $A896: 8D 00 00
  LDY #$3D                                ; $A899: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $A89B: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A015                               ; $A89E: 15 A0  -> LoadScenarioData_Entry ($DBB1)
  PLA                                       ; $A8A0: 68
  STA $0000                                 ; $A8A1: 8D 00 00
; Entry: copy name tilemap and render
::OfficerDisplay_Render:
  LDY #$3A                                ; $A8A4: A0 3A
@name_copy_loop:
  LDA OfficerDisplayTilemap,Y              ; $A8A6: B9 C3 A8
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
; OfficerDisplayTilemap - overlay tilemap for officer name display
; Format: cmd ($04=4 data bytes, $08=8 data bytes), VRAM hi, VRAM lo, tile data
OfficerDisplayTilemap:
  .byte $04, $22, $00, $00, $00, $00, $00   ; $A8C3: row 0 - blank, VRAM $2200
  .byte $04, $22, $C2, $00, $00, $00, $00   ; $A8CA: row 1 - blank, VRAM $22C2
  .byte $04, $22, $E2, $00, $00, $00, $00   ; $A8D1: row 2 - blank, VRAM $22E2
  .byte $04, $23, $02, $00, $00, $00, $00   ; $A8D8: row 3 - blank, VRAM $2302
  .byte $04, $23, $22, $00, $00, $00, $00   ; $A8DF: row 4 - blank, VRAM $2322
  .byte $08, $23, $42, $01, $01, $01, $01   ; $A8E6: row 5 - filled, VRAM $2342
  .byte $01, $01, $01, $01                  ; $A8EB:   (cont row 5)
  .byte $08, $23, $62, $01, $01, $01, $01   ; $A8EF: row 6 - filled, VRAM $2362
  .byte $01, $01, $01, $01                  ; $A8F4:   (cont row 6)
  .byte $FF                                 ; $A8FC: sentinel

.endproc

.proc OfficerNameDisplay
  ; Proc-local RAM variable
  officer_name_disp = $04AE  ; officer name display temp
OfficerNameDisplay:
  LDY #$3A                                ; $A8FD: A0 3A
@rec_copy_loop:
  LDA OfficerNameTilemap,Y                ; $A8FF: B9 1D A9
  STA $0380,Y                             ; $A902: 99 80 03
  DEY                                     ; $A905: 88
  BPL @rec_copy_loop                      ; $A906: 10 F7
  LDA $04AE                               ; $A908: AD AE 04
  JSR DisplayScaledName                   ; $A90B: 20 57 A9
  LDA $04AE                               ; $A90E: AD AE 04
  JSR DisplayScaledNumber                 ; $A911: 20 76 A9
  LDA $007E                               ; $A914: AD 7E 00
  ORA #$04                                ; $A917: 09 04
  STA $007E                               ; $A919: 8D 7E 00
  RTS                                     ; $A91C: 60
; OfficerNameTilemap - overlay tilemap for officer name display
; Format: cmd ($04=4 data bytes, $08=8 data bytes), VRAM hi, VRAM lo, tile data
OfficerNameTilemap:
  .byte $04, $22, $00, $00, $00, $00, $00   ; $A91D: row 0 - blank, VRAM $2200
  .byte $04, $22, $C2, $00, $00, $00, $00   ; $A924: row 1 - blank, VRAM $22C2
  .byte $04, $22, $E2, $00, $00, $00, $00   ; $A92B: row 2 - blank, VRAM $22E2
  .byte $04, $23, $02, $00, $00, $00, $00   ; $A932: row 3 - blank, VRAM $2302
  .byte $04, $23, $22, $00, $00, $00, $00   ; $A939: row 4 - blank, VRAM $2322
  .byte $08, $23, $57, $01, $01, $01, $01   ; $A940: row 5 - filled, VRAM $2357
  .byte $01, $01, $01, $01                  ; $A948:   (cont row 5)
  .byte $08, $23, $77, $01, $01, $01, $01   ; $A94B: row 6 - filled, VRAM $2377
  .byte $01, $01, $01, $01                  ; $A953:   (cont row 6)
  .byte $FF                                 ; $A956: sentinel

.endproc

.proc DisplayScaledName
  ; Proc-local RAM variable
  scaled_name_tmp   = $03A5  ; scaled name temp
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

.endproc

.proc DisplayScaledNumber
  ; Proc-local RAM variable
  disp_scaled_num   = $03B1  ; scaled number temp
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
  LDA DataFormatter_Table2,Y                ; $A998: B9 FD A9
  STA $0380,Y                             ; $A99B: 99 80 03
  DEY                                     ; $A99E: 88
  BPL @fmt_copy_loop1                            ; $A99F: 10 F7
  JMP @fmt_process                            ; $A9A1: 4C AF A9
@fmt_setup2:
  LDY #$3A                                ; $A9A4: A0 3A
@fmt_copy_loop2:
  LDA DataFormatter_Table1,Y                ; $A9A6: B9 C3 A9
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
; ---- Display template table 1 (mode ≠ 0), copied to $0380 ----
; Variable-length records: type $04 = 7 bytes, type $08 = 11 bytes
; Record format: type, data_count, PPU_addr_hi, PPU_addr_lo, data[count]
; Total: 5×7 + 2×11 + 1(terminator) = 58 bytes
; $A9C3
DataFormatter_Table1:
  .byte $04, $22, $BA, $00, $00, $00, $00              ; record 1: PPU $22BA, 3 data bytes
  .byte $04, $22, $DA, $00, $00, $00, $00              ; record 2: PPU $22DA, 3 data bytes
  .byte $04, $22, $FA, $00, $00, $00, $00              ; record 3: PPU $22FA, 3 data bytes
  .byte $04, $23, $1A, $00, $00, $00, $00              ; record 4: PPU $231A, 3 data bytes
  .byte $04, $23, $3A, $00, $00, $00, $00              ; record 5: PPU $233A, 3 data bytes
  .byte $08, $23, $58, $01, $01, $01, $01, $01, $01, $01, $01  ; record 6: PPU $2358, 7 static tiles
  .byte $FF                                           ; terminator

; ---- Display template table 2 (mode = 0), copied to $0380 ----
; Same structure as Table 1, 58 bytes
; $A9FD
DataFormatter_Table2:
  .byte $04, $22, $A2, $00, $00, $00, $00              ; record 1: PPU $22A2, 3 data bytes
  .byte $04, $22, $C2, $00, $00, $00, $00              ; record 2: PPU $22C2, 3 data bytes
  .byte $04, $22, $E2, $00, $00, $00, $00              ; record 3: PPU $22E2, 3 data bytes
  .byte $04, $23, $02, $00, $00, $00, $00              ; record 4: PPU $2302, 3 data bytes
  .byte $04, $23, $22, $00, $00, $00, $00              ; record 5: PPU $2322, 3 data bytes
  .byte $08, $23, $40, $01, $01, $01, $01, $01, $01, $01, $01  ; record 6: PPU $2340, 7 static tiles
  .byte $FF                                           ; terminator

.endproc

.proc BankedDataHandler
  ; Proc-local RAM variables
  scaled_name_tmp   = $03A5  ; scaled name temp
  banked_bd_lo      = $00BD  ; banked data temp lo
  banked_395        = $0395  ; banked data temp
  banked_39C        = $039C  ; banked data temp C
  banked_39D        = $039D  ; banked data temp D
  banked_3A0        = $03A0  ; banked data temp E0
  banked_3A1        = $03A1  ; banked data temp E1
  banked_3A2        = $03A2  ; banked data temp E2
  banked_3A3        = $03A3  ; banked data temp E3
  banked_3A4        = $03A4  ; banked data temp E4
  banked_3A6        = $03A6  ; banked data temp E6
  LDA $000A                               ; $AA37: AD 0A 00
  PHA                                     ; $AA3A: 48
  LDA $000B                               ; $AA3B: AD 0B 00
  PHA                                     ; $AA3E: 48
  LDA $000C                               ; $AA3F: AD 0C 00
  PHA                                     ; $AA42: 48
  LDA $000B                               ; $AA43: AD 0B 00
  CMP #$FF                                ; $AA46: C9 FF
  BEQ @skip_jsr                            ; $AA48: F0 03
  JSR SetupBankedData                       ; $AA4A: 20 38 AB
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
; 5x6 display data table (5 bytes x 6 records + terminator)
DisplayData_Table:
  .byte $C2, $C3, $C4, $C5, $C6             ; $AB08: record 1
  .byte $C7, $D2, $D3, $D4, $D5             ; $AB0D: record 2
  .byte $D6, $D7, $C8, $C9, $CA             ; $AB12: record 3
  .byte $CB, $01, $01, $D8, $D9             ; $AB17: record 4
  .byte $DA, $DB, $01, $01, $C2             ; $AB1C: record 5
  .byte $C3, $CC, $CD, $C6, $C7             ; $AB21: record 6
  .byte $D2                                   ; $AB26: terminator
; 17-byte data region
  .byte $D3, $DC, $DD, $D6, $D7             ; $AB27
  .byte $CE, $CF, $E0, $E1, $01             ; $AB2C
  .byte $01, $DE, $DF, $F0, $F1             ; $AB31
  .byte $01, $01                              ; $AB36

.endproc

;-------------------------------------------------------------------------------
; SetupBankedData - Switch bank and copy display/name data
;-------------------------------------------------------------------------------
.proc SetupBankedData
  ; Proc-local RAM variable
  setup_disp_tmp    = $00B9  ; setup temp
  LDY #$31                                  ; $AB38: select bank $31
  JSR B1F_SwitchBank8_B                     ; $AB3A: 20 5F F2
  LDA $000B                                 ; $AB3D: AD 0B 00
  STA $0000                                 ; $AB40: 8D 00 00
  LDA #$00                                  ; $AB43: A9 00
  STA $0001                                 ; $AB45: 8D 01 00
  STA $0002                                 ; $AB48: 8D 02 00
  LDA #$0D                                  ; $AB4B: A9 0D
  STA $0003                                 ; $AB4D: 8D 03 00
  JSR B1F_MathMul24x8                       ; $AB50: 20 E9 EB
  LDA $0006                                 ; $AB53: AD 06 00
  CLC                                       ; $AB56: 18
  ADC #$B4                                  ; $AB57: 69 B4
  STA $0000                                 ; $AB59: 8D 00 00
  LDA $0007                                 ; $AB5C: AD 07 00
  ADC #$8D                                  ; $AB5F: 69 8D
  STA $0001                                 ; $AB61: 8D 01 00
  LDY #$00                                  ; $AB64: A0 00
  LDA ($00),Y                               ; $AB66: B1 00
  STA $00B9                                 ; $AB68: 8D B9 00
  LDX #$30                                  ; $AB6B: A2 30
  LDY #$01                                  ; $AB6D: A0 01
@copy_data_loop:
  LDA ($00),Y                               ; $AB6F: B1 00
  CMP #$FF                                  ; $AB71: C9 FF
  BEQ @copy_data_done                       ; $AB73: F0 0D
  TXA                                       ; $AB75: 8A
  SEC                                       ; $AB76: 38
  SBC #$10                                  ; $AB77: E9 10
  TAX                                       ; $AB79: AA
  INY                                       ; $AB7A: C8
  INY                                       ; $AB7B: C8
  INY                                       ; $AB7C: C8
  INY                                       ; $AB7D: C8
  CPY #$0D                                  ; $AB7E: C0 0D
  BCC @copy_data_loop                       ; $AB80: 90 ED
@copy_data_done:
  STX $0002                                 ; $AB82: 8E 02 00
  LDX $007C                                 ; $AB85: AE 7C 00
  LDY #$01                                  ; $AB88: A0 01
@copy_name_loop:
  LDA ($00),Y                               ; $AB8A: B1 00
  CMP #$FF                                  ; $AB8C: C9 FF
  BEQ @copy_name_done                       ; $AB8E: F0 24
  CLC                                       ; $AB90: 18
  ADC #$C0                                  ; $AB91: 69 C0
  STA $0201,X                               ; $AB93: 9D 01 02
  LDA SpriteX_Table,Y                       ; $AB96: B9 B8 AB
  STA $0200,X                               ; $AB99: 9D 00 02
  LDA SpriteY_Table,Y                       ; $AB9C: B9 C5 AB
  CLC                                       ; $AB9F: 18
  ADC $0002                                 ; $ABA0: 6D 02 00
  STA $0203,X                               ; $ABA3: 9D 03 02
  LDA #$01                                  ; $ABA6: A9 01
  STA $0202,X                               ; $ABA8: 9D 02 02
  INX                                       ; $ABAB: E8
  INX                                       ; $ABAC: E8
  INX                                       ; $ABAD: E8
  INX                                       ; $ABAE: E8
  INY                                       ; $ABAF: C8
  CPY #$0D                                  ; $ABB0: C0 0D
  BCC @copy_name_loop                       ; $ABB2: 90 D6
@copy_name_done:
  STX $007C                                 ; $ABB4: 8E 7C 00
  RTS                                       ; $ABB7: 60
; Sprite coordinate tables (13 bytes each, index 0 unused, indices 1-12 used)
SpriteX_Table:
  .byte $F0, $AF, $AF, $B7, $B7            ; $ABB8
  .byte $AF, $AF, $B7, $B7, $AF            ; $ABBD
  .byte $AF, $B7, $B7                       ; $ABC2
SpriteY_Table:
  .byte $F0, $38, $40, $38, $40            ; $ABC5
  .byte $48, $50, $48, $50, $58            ; $ABCA
  .byte $60                                 ; $ABCF
.endproc

; Remainder of BankedDataHandler
.proc BankedDataHandler_tail
  CLI                                       ; $ABD0: 58
  RTS                                       ; $ABD1: 60
.endproc

.proc StateHandler
  ; Proc-local RAM variables
  state_scale_mode  = $0015  ; scale mode flag for officer name rendering
  officer_rec_idx   = $0016  ; officer record index temp
  prov_data_ptr_hi  = $0018  ; province data pointer hi
  state_vram_cnt3_lo = $00D6 ; VRAM counter 3 lo
  state_vram_cnt3_hi = $00DA ; VRAM counter 3 hi
  state_tmp2        = $0005  ; StateHandler temp 2
  state_bcd_mode    = $000F  ; BCD/scale mode temp
  state_be          = $00BE  ; StateHandler temp
  state_c6          = $00C6  ; StateHandler temp
  state_ce          = $00CE  ; StateHandler temp
  state_buf_extra   = $0166  ; state buffer extra data
  state_buf_ext2    = $016F  ; state buffer extension 2
  state_buf_ext3    = $0175  ; state buffer extension 3
  state_buf_ext4    = $017D  ; state buffer extension 4
  state_work_area   = $0190  ; StateHandler work area
StateHandler:
  LDA $037C                               ; $ABD2: AD 7C 03
  BEQ @check_main_state                            ; $ABD5: F0 1D
  LDY #$31                                ; $ABD7: A0 31
  JSR B1F_SwitchBank8_B                   ; $ABD9: 20 5F F2
  LDA $037D                               ; $ABDC: AD 7D 03
  CMP #$FF                                ; $ABDF: C9 FF
  BEQ @check_officer_sub                            ; $ABE1: F0 05
  LDA #$01                                ; $ABE3: A9 01
  JSR RenderSubState                      ; $ABE5: 20 4C B1
@check_officer_sub:
  LDA $037E                               ; $ABE8: AD 7E 03
  CMP #$FF                                ; $ABEB: C9 FF
  BEQ @check_main_state                            ; $ABED: F0 05
  LDA #$02                                ; $ABEF: A9 02
  JSR RenderSubState                      ; $ABF1: 20 4C B1
@check_main_state:
  LDA $0140                               ; $ABF4: AD 40 01
  BEQ @rts                            ; $ABF7: F0 3F
  LDA $0140                               ; $ABF9: AD 40 01
  BMI @init                            ; $ABFC: 30 3B
  AND #$0F                                ; $ABFE: 29 0F
  CMP #$01                                ; $AC00: C9 01
  BEQ @cleanup_state                            ; $AC02: F0 14
  LDA $007E                               ; $AC04: AD 7E 00
  AND #$08                                ; $AC07: 29 08
  BNE @rts                            ; $AC09: D0 2D
  LDA $0150                               ; $AC0B: AD 50 01
  AND #$0F                                ; $AC0E: 29 0F
  BNE @goto_advance                            ; $AC10: D0 03
  JMP @advance_draw                            ; $AC12: 4C C9 AE
@goto_advance:
  JMP @advance_state                            ; $AC15: 4C F3 AD
@cleanup_state:
  LDA #$00                                ; $AC18: A9 00
  STA $0140                               ; $AC1A: 8D 40 01
  LDA $0150                               ; $AC1D: AD 50 01
  AND #$0F                                ; $AC20: 29 0F
  BNE @check_mode_cleanup                            ; $AC22: D0 03
  STA $0420                               ; $AC24: 8D 20 04
@check_mode_cleanup:
  CMP #$01                                ; $AC27: C9 01
  BNE @preserve_mode_flags                            ; $AC29: D0 05
  LDA #$FF                                ; $AC2B: A9 FF
  STA $037C                               ; $AC2D: 8D 7C 03
@preserve_mode_flags:
  LDA $0150                               ; $AC30: AD 50 01
  AND #$80                                ; $AC33: 29 80
  STA $0150                               ; $AC35: 8D 50 01
@rts:
  RTS                                     ; $AC38: 60
@init:
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
  BNE @setup_name_coords                            ; $AC57: D0 03
  JMP @init_window_mode                            ; $AC59: 4C 92 AD
@setup_name_coords:
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
  BPL @set_scroll_dir                            ; $AC7C: 10 02
  LDY #$40                                ; $AC7E: A0 40
@set_scroll_dir:
  STY $0420                               ; $AC80: 8C 20 04
  AND #$0F                                ; $AC83: 29 0F
  CMP #$01                                ; $AC85: C9 01
  BEQ @setup_province_detail                            ; $AC87: F0 44
  CMP #$02                                ; $AC89: C9 02
  BEQ @setup_stats_panel_a                            ; $AC8B: F0 08
  CMP #$03                                ; $AC8D: C9 03
  BEQ @setup_stats_panel_b                            ; $AC8F: F0 1E
  CMP #$04                                ; $AC91: C9 04
  BEQ @setup_stats_panel_c                            ; $AC93: F0 29
@setup_stats_panel_a:
  LDA #$E5                                ; $AC95: A9 E5
  STA $0149                               ; $AC97: 8D 49 01
  LDA #$B3                                ; $AC9A: A9 B3
  STA $014A                               ; $AC9C: 8D 4A 01
  LDA #$01                                ; $AC9F: A9 01
  STA $00B3                               ; $ACA1: 8D B3 00
  STA $00C3                               ; $ACA4: 8D C3 00
  STA $00CB                               ; $ACA7: 8D CB 00
  LDA #$05                                ; $ACAA: A9 05
  JMP @store_counter_hi                            ; $ACAC: 4C 1F AD
@setup_stats_panel_b:
  LDA #$C1                                ; $ACAF: A9 C1
  STA $0149                               ; $ACB1: 8D 49 01
  LDA #$B4                                ; $ACB4: A9 B4
  STA $014A                               ; $ACB6: 8D 4A 01
  LDA #$05                                ; $ACB9: A9 05
  JMP @store_counter_lo                            ; $ACBB: 4C 16 AD
@setup_stats_panel_c:
  LDA #$9C                                ; $ACBE: A9 9C
  STA $0149                               ; $ACC0: 8D 49 01
  LDA #$B5                                ; $ACC3: A9 B5
  STA $014A                               ; $ACC5: 8D 4A 01
  LDA #$05                                ; $ACC8: A9 05
  JMP @store_counter_lo                            ; $ACCA: 4C 16 AD
@setup_province_detail:
  LDA #<ProvinceDetailTilemap             ; $ACCD: A9 05
  STA $0149                               ; $ACCF: 8D 49 01  ; ptr lo → ProvinceDetailTilemap
  LDA #>ProvinceDetailTilemap             ; $ACD2: A9 B3
  STA $014A                               ; $ACD4: 8D 4A 01  ; ptr hi
  LDA $0402                               ; $ACD7: AD 02 04
  JSR B1F_GetProvinceRecordAddr           ; $ACDA: 20 AF F2
  LDY #$11                                ; $ACDD: A0 11
  LDA ($00),Y                             ; $ACDF: B1 00
  STA $037E                               ; $ACE1: 8D 7E 03
  LDY #$00                                ; $ACE4: A0 00
  LDA ($00),Y                             ; $ACE6: B1 00
  CMP #$07                                ; $ACE8: C9 07
  BNE @load_kingdom_template                            ; $ACEA: D0 05
  LDA #$FF                                ; $ACEC: A9 FF
  JMP @init_province_timer                            ; $ACEE: 4C 03 AD
@load_kingdom_template:
  ASL A                                   ; $ACF1: 0A
  TAY                                     ; $ACF2: A8
  LDA KingdomTemplatePtrs,Y                  ; $ACF3: B9 84 AD
  STA $0000                               ; $ACF6: 8D 00 00
  LDA KingdomTemplatePtrs+1,Y                ; $ACF9: B9 85 AD
  STA $0001                               ; $ACFC: 8D 01 00
  LDY #$00                                ; $ACFF: A0 00
  LDA ($00),Y                             ; $AD01: B1 00
@init_province_timer:
  STA $037D                               ; $AD03: 8D 7D 03
  LDA #$08                                ; $AD06: A9 08
  STA $00B4                               ; $AD08: 8D B4 00
  STA $00C4                               ; $AD0B: 8D C4 00
  STA $00CC                               ; $AD0E: 8D CC 00
  STA $00D4                               ; $AD11: 8D D4 00
  LDA #$01                                ; $AD14: A9 01
@store_counter_lo:
  STA $00B3                               ; $AD16: 8D B3 00
  STA $00C3                               ; $AD19: 8D C3 00
  STA $00CB                               ; $AD1C: 8D CB 00
@store_counter_hi:
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
  BPL @setup_scroll_pos                            ; $AD43: 10 16
  LDA #$C4                                ; $AD45: A9 C4
  STA $0147                               ; $AD47: 8D 47 01
  LDA #$7F                                ; $AD4A: A9 7F
  STA $0145                               ; $AD4C: 8D 45 01
  LDA #$B6                                ; $AD4F: A9 B6
  STA $0146                               ; $AD51: 8D 46 01
  LDX #$10                                ; $AD54: A2 10
  LDY #$CC                                ; $AD56: A0 CC
  JMP @apply_scroll_offset                            ; $AD58: 4C 6E AD
@setup_scroll_pos:
  LDA #$C0                                ; $AD5B: A9 C0
  STA $0147                               ; $AD5D: 8D 47 01
  LDA #$7B                                ; $AD60: A9 7B
  STA $0145                               ; $AD62: 8D 45 01
  LDA #$B6                                ; $AD65: A9 B6
  STA $0146                               ; $AD67: 8D 46 01
  LDX #$02                                ; $AD6A: A2 02
  LDY #$C8                                ; $AD6C: A0 C8
@apply_scroll_offset:
  STX $0141                               ; $AD6E: 8E 41 01
  TYA                                     ; $AD71: 98
  CLC                                     ; $AD72: 18
  ADC $0143                               ; $AD73: 6D 43 01
  STA $0143                               ; $AD76: 8D 43 01
  LDA #$03                                ; $AD79: A9 03
  ADC $0144                               ; $AD7B: 6D 44 01
  STA $0144                               ; $AD7E: 8D 44 01
  JMP @advance_state                          ; $AD81: 4C F3 AD
; --- Data Region: KingdomTemplatePtrs ---
KingdomTemplatePtrs:
  .word $6F07, $6F0F, $6F17, $6F1F          ; $AD84: template pointers by kingdom type (0-3)
  .word $6F27, $6F2F, $6F37                   ; $AD8C: template pointers by kingdom type (4-6)
@init_window_mode:
  LDA #$22                                ; $AD92: A9 22
  STA $0142                               ; $AD94: 8D 42 01
  LDA #$03                                ; $AD97: A9 03
  STA $0146                               ; $AD99: 8D 46 01
  LDA #$23                                ; $AD9C: A9 23
  STA $0148                               ; $AD9E: 8D 48 01
  LDA #$00                                ; $ADA1: A9 00
  STA $037C                               ; $ADA3: 8D 7C 03
  LDA $0150                               ; $ADA6: AD 50 01
  BPL @setup_window_pos                            ; $ADA9: 10 11
  LDA #$E4                                ; $ADAB: A9 E4
  STA $0145                               ; $ADAD: 8D 45 01
  LDA #$EC                                ; $ADB0: A9 EC
  STA $0147                               ; $ADB2: 8D 47 01
  LDX #$90                                ; $ADB5: A2 90
  LDY #$10                                ; $ADB7: A0 10
  JMP @apply_window_offset                            ; $ADB9: 4C CA AD
@setup_window_pos:
  LDA #$E0                                ; $ADBC: A9 E0
  STA $0145                               ; $ADBE: 8D 45 01
  LDA #$E8                                ; $ADC1: A9 E8
  STA $0147                               ; $ADC3: 8D 47 01
  LDX #$82                                ; $ADC6: A2 82
  LDY #$02                                ; $ADC8: A0 02
@apply_window_offset:
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
@copy_template_loop:
  LDA ($10),Y                             ; $AE0B: B1 10
  CMP #$F0                                ; $AE0D: C9 F0
  BCS @process_ctrl_code                            ; $AE0F: B0 08
  STA $0160,X                             ; $AE11: 9D 60 01
  INY                                     ; $AE14: C8
  INX                                     ; $AE15: E8
  JMP @check_buf_full                            ; $AE16: 4C 1C AE
@process_ctrl_code:
  JSR @process_template_ctrl                            ; $AE19: 20 77 AF
@check_buf_full:
  CPX #$38                                ; $AE1C: E0 38
  BCC @copy_template_loop                            ; $AE1E: 90 EB
  TYA                                     ; $AE20: 98
  LDY #$09                                ; $AE21: A0 09
  JSR @add_addr_offset                            ; $AE23: 20 66 AF
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
@merge_attr_bytes:
  LDA ($10),Y                             ; $AE4A: B1 10
  STA $014B,Y                             ; $AE4C: 99 4B 01
  INY                                     ; $AE4F: C8
  CPY #$03                                ; $AE50: C0 03
  BCC @merge_attr_bytes                            ; $AE52: 90 F6
  LDA ($12),Y                             ; $AE54: B1 12
  AND #$CC                                ; $AE56: 29 CC
  ORA ($10),Y                             ; $AE58: 11 10
  STA $014B,Y                             ; $AE5A: 99 4B 01
  LDA #$08                                ; $AE5D: A9 08
  LDY #$07                                ; $AE5F: A0 07
  JSR @add_addr_offset                            ; $AE61: 20 66 AF
  LDA #$08                                ; $AE64: A9 08
  LDY #$03                                ; $AE66: A0 03
  JSR @add_addr_offset                            ; $AE68: 20 66 AF
  LDA #$80                                ; $AE6B: A9 80
  LDY #$01                                ; $AE6D: A0 01
  JSR @add_addr_offset                            ; $AE6F: 20 66 AF
  LDA $0150                               ; $AE72: AD 50 01
  AND #$0F                                ; $AE75: 29 0F
  CMP #$01                                ; $AE77: C9 01
  BNE @state_done                            ; $AE79: D0 45
  LDA $0140                               ; $AE7B: AD 40 01
  CMP #$04                                ; $AE7E: C9 04
  BNE @skip_province_type7                            ; $AE80: D0 03
  JSR DrawOfficerName                     ; $AE82: 20 AB B0
@skip_province_type7:
  LDA $0402                               ; $AE85: AD 02 04
  JSR B1F_GetProvinceRecordAddr           ; $AE88: 20 AF F2
  LDY #$00                                ; $AE8B: A0 00
  LDA ($00),Y                             ; $AE8D: B1 00
  CMP #$07                                ; $AE8F: C9 07
  BEQ @state_done                            ; $AE91: F0 2D
  LDA $0140                               ; $AE93: AD 40 01
  CMP #$04                                ; $AE96: C9 04
  BEQ @apply_province_base                            ; $AE98: F0 0B
  CMP #$03                                ; $AE9A: C9 03
  BEQ @apply_officer_portrait                            ; $AE9C: F0 0F
  CMP #$02                                ; $AE9E: C9 02
  BEQ @apply_officer_scaled                            ; $AEA0: F0 16
  JMP @state_done                            ; $AEA2: 4C C0 AE
@apply_province_base:
  LDA #$00                                ; $AEA5: A9 00
  JSR LoadOfficerNameInfo                    ; $AEA7: 20 3A B2
  JMP @state_done                            ; $AEAA: 4C C0 AE
@apply_officer_portrait:
  LDA #$01                                ; $AEAD: A9 01
  JSR LoadOfficerNameInfo                    ; $AEAF: 20 3A B2
  JSR @draw_name_scaled                            ; $AEB2: 20 7A B2
  JMP @state_done                            ; $AEB5: 4C C0 AE
@apply_officer_scaled:
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
@copy_tile_row:
  LDY #$00                                ; $AEDF: A0 00
@copy_tile_row_loop:
  LDA ($10),Y                             ; $AEE1: B1 10
  STA $0160,X                             ; $AEE3: 9D 60 01
  INY                                     ; $AEE6: C8
  INX                                     ; $AEE7: E8
  CPY #$0E                                ; $AEE8: C0 0E
  BCC @copy_tile_row_loop                            ; $AEEA: 90 F5
  LDA $0010                               ; $AEEC: AD 10 00
  CLC                                     ; $AEEF: 18
  ADC #$20                                ; $AEF0: 69 20
  STA $0010                               ; $AEF2: 8D 10 00
  LDA $0011                               ; $AEF5: AD 11 00
  ADC #$00                                ; $AEF8: 69 00
  STA $0011                               ; $AEFA: 8D 11 00
  CPX #$38                                ; $AEFD: E0 38
  BCC @copy_tile_row                            ; $AEFF: 90 DE
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
@copy_attr_block:
  LDA ($10),Y                             ; $AF20: B1 10
  STA $014B,Y                             ; $AF22: 99 4B 01
  INY                                     ; $AF25: C8
  CPY #$04                                ; $AF26: C0 04
  BCC @copy_attr_block                            ; $AF28: 90 F6
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
@add_addr_offset:
  CLC                                     ; $AF66: 18
  ADC $0140,Y                             ; $AF67: 79 40 01
  STA $0140,Y                             ; $AF6A: 99 40 01
  INY                                     ; $AF6D: C8
  LDA #$00                                ; $AF6E: A9 00
  ADC $0140,Y                             ; $AF70: 79 40 01
  STA $0140,Y                             ; $AF73: 99 40 01
  RTS                                     ; $AF76: 60
@process_template_ctrl:
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
  BEQ @extract_count                            ; $AFA4: F0 2D
  CMP #$F1                                ; $AFA6: C9 F1
  BEQ @extract_value16                            ; $AFA8: F0 16
  CMP #$F3                                ; $AFAA: C9 F3
  BEQ @sum_officer_stats                            ; $AFAC: F0 41
  LDY #$00                                ; $AFAE: A0 00
  LDA ($17),Y                             ; $AFB0: B1 17
  STA $0001                               ; $AFB2: 8D 01 00
  LDA #$00                                ; $AFB5: A9 00
  STA $0002                               ; $AFB7: 8D 02 00
  STA $0003                               ; $AFBA: 8D 03 00
  JMP @convert_and_format                            ; $AFBD: 4C 32 B0
@extract_value16:
  LDY #$00                                ; $AFC0: A0 00
  STY $0003                               ; $AFC2: 8C 03 00
  LDA ($17),Y                             ; $AFC5: B1 17
  STA $0001                               ; $AFC7: 8D 01 00
  INY                                     ; $AFCA: C8
  LDA ($17),Y                             ; $AFCB: B1 17
  STA $0002                               ; $AFCD: 8D 02 00
  JMP @convert_and_format                            ; $AFD0: 4C 32 B0
@extract_count:
  LDY #$00                                ; $AFD3: A0 00
  STY $0003                               ; $AFD5: 8C 03 00
  STY $0002                               ; $AFD8: 8C 02 00
  STY $0001                               ; $AFDB: 8C 01 00
@count_loop:
  LDA ($17),Y                             ; $AFDE: B1 17
  CMP #$FF                                ; $AFE0: C9 FF
  BEQ @count_next                            ; $AFE2: F0 03
  INC $0001                               ; $AFE4: EE 01 00
@count_next:
  INY                                     ; $AFE7: C8
  CPY #$0A                                ; $AFE8: C0 0A
  BCC @count_loop                            ; $AFEA: 90 F2
  JMP @convert_and_format                            ; $AFEC: 4C 32 B0
@sum_officer_stats:
  LDY #$00                                ; $AFEF: A0 00
  STY $0002                               ; $AFF1: 8C 02 00
  STY $0003                               ; $AFF4: 8C 03 00
  STY $0004                               ; $AFF7: 8C 04 00
@officer_loop:
  LDA ($17),Y                             ; $AFFA: B1 17
  CMP #$FF                                ; $AFFC: C9 FF
  BEQ @officer_done                            ; $AFFE: F0 21
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
  BCC @officer_loop                            ; $B01F: 90 D9
@officer_done:
  LDA $0002                               ; $B021: AD 02 00
  STA $0001                               ; $B024: 8D 01 00
  LDA $0003                               ; $B027: AD 03 00
  STA $0002                               ; $B02A: 8D 02 00
  LDA #$00                                ; $B02D: A9 00
  STA $0003                               ; $B02F: 8D 03 00
@convert_and_format:
  TXA                                     ; $B032: 8A
  PHA                                     ; $B033: 48
  JSR B1F_MathBinToBcd                    ; $B034: 20 BA E9
  PLA                                     ; $B037: 68
  TAX                                     ; $B038: AA
  PLA                                     ; $B039: 68
  TAY                                     ; $B03A: A8
  LDA #$B6                                ; $B03B: A9 B6
  STA $0017                               ; $B03D: 8D 17 00
@extract_digits:
  LDA #$01                                ; $B040: A9 01
  STA $0016                               ; $B042: 8D 16 00
  LDA $0013                               ; $B045: AD 13 00
  CMP #$02                                ; $B048: C9 02
  BEQ @digit_ten_thousands                            ; $B04A: F0 30
  CMP #$03                                ; $B04C: C9 03
  BEQ @digit_tens                            ; $B04E: F0 24
  CMP #$04                                ; $B050: C9 04
  BEQ @digit_hundreds                            ; $B052: F0 16
  CMP #$05                                ; $B054: C9 05
  BEQ @digit_thousands                            ; $B056: F0 0A
  LDA $0009                               ; $B058: AD 09 00
  LSR A                                   ; $B05B: 4A
  LSR A                                   ; $B05C: 4A
  LSR A                                   ; $B05D: 4A
  LSR A                                   ; $B05E: 4A
  JSR @emit_digit                            ; $B05F: 20 91 B0
@digit_thousands:
  LDA $0009                               ; $B062: AD 09 00
  AND #$0F                                ; $B065: 29 0F
  JSR @emit_digit                            ; $B067: 20 91 B0
@digit_hundreds:
  LDA $0008                               ; $B06A: AD 08 00
  LSR A                                   ; $B06D: 4A
  LSR A                                   ; $B06E: 4A
  LSR A                                   ; $B06F: 4A
  LSR A                                   ; $B070: 4A
  JSR @emit_digit                            ; $B071: 20 91 B0
@digit_tens:
  LDA $0008                               ; $B074: AD 08 00
  AND #$0F                                ; $B077: 29 0F
  JSR @emit_digit                            ; $B079: 20 91 B0
@digit_ten_thousands:
  LDA $0007                               ; $B07C: AD 07 00
  LSR A                                   ; $B07F: 4A
  LSR A                                   ; $B080: 4A
  LSR A                                   ; $B081: 4A
  LSR A                                   ; $B082: 4A
  JSR @emit_digit                            ; $B083: 20 91 B0
  LDA $0017                               ; $B086: AD 17 00
  STA $0016                               ; $B089: 8D 16 00
  LDA $0007                               ; $B08C: AD 07 00
  AND #$0F                                ; $B08F: 29 0F
@emit_digit:
  BNE @emit_nonzero                            ; $B091: D0 09
  LDA $0016                               ; $B093: AD 16 00
  STA $0160,X                             ; $B096: 9D 60 01
  JMP @advance_index                            ; $B099: 4C A9 B0
@emit_nonzero:
  CLC                                     ; $B09C: 18
  ADC $0017                               ; $B09D: 6D 17 00
  STA $0160,X                             ; $B0A0: 9D 60 01
  LDA $0017                               ; $B0A3: AD 17 00
  STA $0016                               ; $B0A6: 8D 16 00
@advance_index:
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
  LDA #<SubStateChrTiles                     ; $B1C2: A9 22
  STA $0002                               ; $B1C4: 8D 02 00
  LDA #>SubStateChrTiles                     ; $B1C7: A9 B2
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
; --- Data Region: SubStateChrTiles ---
SubStateChrTiles:
  .byte $40,$48, $48,$48, $40,$50, $48,$50 ; $B222: tile pairs 0-3
  .byte $50,$48, $58,$48, $50,$50, $58,$50 ; $B22A: tile pairs 4-7
  .byte $60,$48, $68,$48, $60,$50, $68,$50 ; $B232: tile pairs 8-11
LoadOfficerNameInfo:                        ; A=0: ruler ($037D), A=1: governor ($037E)
  STA $000F                               ; $B23A: 8D 0F 00
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

; --- Data Region: ProvinceDetailTilemap ---
; Accessed by StateHandler via @setup_province_detail:
;   LDA #$05 / STA $0149 ; LDA #$B3 / STA $014A  → ptr = $B305
;   Pointer copied to $0010/$0011, read via LDA ($10),Y
;   in @copy_template_loop ($AE0B); bytes >= $F0 are
;   control codes handled by @process_template_ctrl.
; Layout: 16 bytes/row, tile-map for province detail scroll panel.
ProvinceDetailTilemap:                      ; $B305
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
  ; Proc-local RAM variables
  officer_list_wrk  = $0014  ; officer list workspace
  officer_src_lo    = $001A  ; officer record source ptr lo
  officer_src_hi    = $001B  ; officer record source ptr hi
  officer_dst_lo    = $001C  ; officer record dest ptr lo
  officer_dst_hi    = $001D  ; officer record dest ptr hi
  officer_flag_zp   = $008F  ; officer flag (zero-page)
  officer_list_col  = $047C  ; officer list column count
  officer_list_flag = $0424  ; officer list flag
  officer_list_tmp2 = $0425  ; officer list temp 2
  officer_param_base = $040C ; officer parameter base
  officer_name_ext  = $0482  ; officer name extension data
  officer_name_ext2 = $0483  ; officer name extension data 2
  officer_name_ext3 = $0486  ; officer name extension data 3
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
  JSR @extract_digits                            ; $BB86: 20 40 B0
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
  JSR @extract_digits                            ; $BBB0: 20 40 B0
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
  JSR @extract_digits                            ; $BBEB: 20 40 B0
  JMP @advance_list2                            ; $BBEE: 4C 15 BC
@format_extra:
  JSR @extract_digits                            ; $BBF1: 20 40 B0
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
  JSR @extract_digits                            ; $BC12: 20 40 B0
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

;-------------------------------------------------------------------------------
; FlushTileBuffer - Upload the 64-byte tile buffer at $0160 to VRAM.
; Sets VRAM increment to +1, targets PPUADDR from $0480/$0481, then streams
; $40 bytes from $0160 to PPUDATA. Multiple handlers fill $0160; this commits it.
;-------------------------------------------------------------------------------
.proc FlushTileBuffer
FlushTileBuffer:
  LDA $008B                               ; $BC41: AD 8B 00 (ppu_ctrl_mirror: force VRAM increment +1)
  AND #$FB                                ; $BC44: 29 FB (clear bit 2)
  STA $2000                               ; $BC46: 8D 00 20 (PPUCTRL)
  LDA $2002                               ; $BC49: AD 02 20 (PPUSTATUS: reset PPUADDR latch)
  LDA $0481                               ; $BC4C: AD 81 04 (VRAM dest addr hi)
  STA $2006                               ; $BC4F: 8D 06 20 (PPUADDR hi)
  LDA $0480                               ; $BC52: AD 80 04 (VRAM dest addr lo)
  STA $2006                               ; $BC55: 8D 06 20 (PPUADDR lo)
  LDY #$00                                ; $BC58: A0 00
@vram_fill_loop:
  LDA $0160,Y                             ; $BC5A: B9 60 01 (tile buffer)
  STA $2007                               ; $BC5D: 8D 07 20 (PPUDATA)
  INY                                     ; $BC60: C8
  CPY #$40                                ; $BC61: C0 40 (64 bytes)
  BCC @vram_fill_loop                            ; $BC63: 90 F5
  RTS                                     ; $BC65: 60

.endproc

.proc ClearWorkBuffer
ClearWorkBuffer:
  LDY #$3F                                ; $BC66: A0 3F
  LDA #$00                                ; $BC68: A9 00
@clear_0140_loop:
  STA $0140,Y                             ; $BC6A: 99 40 01
  DEY                                     ; $BC6D: 88
  BPL @clear_0140_loop                            ; $BC6E: 10 FA
  RTS                                     ; $BC70: 60

.endproc

.proc SceneRenderer
  ; Proc-local RAM variables
  officer_list_st   = $0470  ; officer list state 0
  officer_list_st1  = $0471  ; officer list state 1
  officer_list_st2  = $0472  ; officer list state 2
  officer_list_st3  = $0473  ; officer list state 3
  oam_extra         = $0204  ; OAM sprite data extra byte
  scene_render_flag = $03C3  ; scene render flag
SceneRenderer:
  LDA $0401                               ; $BC71: AD 01 04
  JSR B1F_CallbackDispatcher              ; $BC74: 20 DE EA
;-------------------------------------------------------------------------------
; Inline dispatch table (6 entries, 16-bit addresses)
; CallbackDispatcher reads via return addr ($BC76) + idx*2 + 1
; Index = $0401 value (0-5)
;-------------------------------------------------------------------------------
SceneRendererDispatch:
  .word SceneOfficerListInit              ; $BC77: 83 BC -> callback 0
  .word ScenePageCopy                     ; $BC79: 9B BC -> callback 1
  .word SceneRenderSetup                  ; $BC7B: 03 BD -> callback 2
  .word SceneSpriteSetup                  ; $BC7D: 38 BD -> callback 3
  .word SceneRenderExit3                  ; $BC7F: 60 BD -> callback 4
  .word SceneBufferFill                   ; $BC81: 92 BD -> callback 5
.endproc

;-------------------------------------------------------------------------------
; SceneOfficerListInit ($BC83-$BC9A)
; Callback 0: Initialize officer list state registers
;-------------------------------------------------------------------------------
.proc SceneOfficerListInit
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
.endproc

;-------------------------------------------------------------------------------
; ScenePageCopy ($BC9B-$BD02)
; Callback 1: Copy scene page data with bank switch and palette update
;-------------------------------------------------------------------------------
.proc ScenePageCopy
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
.endproc

;-------------------------------------------------------------------------------
; SceneRenderSetup ($BD03-$BD37)
; Callback 2: Scenario render setup - load data, init timer, palette fade
;-------------------------------------------------------------------------------
.proc SceneRenderSetup
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
  JSR LoadScenarioData                      ; $BD2B: 20 B1 DB
  INC $0401                               ; $BD2E: EE 01 04
  JSR SceneInitTimer                            ; $BD31: 20 FE BD
  JMP B1F_PaletteFadeInit                   ; $BD34: 4C BF EC
@render_exit1:
  RTS                                     ; $BD37: 60
.endproc

;-------------------------------------------------------------------------------
; SceneSpriteSetup ($BD38-$BD5F)
; Callback 3: Sprite OAM setup and input-driven palette copy
;-------------------------------------------------------------------------------
.proc SceneSpriteSetup
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
  JSR SceneCheckGameState                            ; $BD56: 20 F1 BD
@inc_and_jmp:
  INC $0401                               ; $BD59: EE 01 04
  JMP B1F_PaletteCopyBuffer                 ; $BD5C: 4C EE EC
@render_exit2:
  RTS                                     ; $BD5F: 60
.endproc

;-------------------------------------------------------------------------------
; SceneRenderExit3 ($BD60-$BD91)
; Callback 4: Alternate render exit - load scenario data, palette fade
;-------------------------------------------------------------------------------
.proc SceneRenderExit3
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
  JSR LoadScenarioData                      ; $BD88: 20 B1 DB
  INC $0401                               ; $BD8B: EE 01 04
  JMP B1F_PaletteFadeInit                   ; $BD8E: 4C BF EC
@render_exit3:
  RTS                                     ; $BD91: 60
.endproc

;-------------------------------------------------------------------------------
; SceneBufferFill ($BD92-$BDF0)
; Callback 5: Fill VRAM buffer page with $AA, set up data pointers, clear state
;-------------------------------------------------------------------------------
.proc SceneBufferFill
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
.endproc

;-------------------------------------------------------------------------------
; SceneCheckGameState ($BDF1-$BDFD)
; Ensure SRAM game state flag is at least $01
;-------------------------------------------------------------------------------
.proc SceneCheckGameState
  LDA $6F05                               ; $BDF1: AD 05 6F
  CMP #$02                                ; $BDF4: C9 02
  BCC @rts2                            ; $BDF6: 90 05
  LDA #$01                                ; $BDF8: A9 01
  STA $6F05                               ; $BDFA: 8D 05 6F
@rts2:
  RTS                                     ; $BDFD: 60
.endproc

;-------------------------------------------------------------------------------
; SceneInitTimer ($BDFE-$BE35)
; Initialize timer data pointers for scene rendering
;-------------------------------------------------------------------------------
.proc SceneInitTimer
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
@menu_dispatch_table:
  .word MenuAction00_InitialSetup         ; $BE75: -> $BEBB
  .word MenuAction01_DisplaySetup         ; $BE77: -> $BEEB
  .word MenuAction02_LandDevelop          ; $BE79: -> $BF2F
  .word MenuAction03_FloodControlSetup     ; $BE7B: -> $BF70
  .word MenuAction04_FloodControl          ; $BE7D: -> $BFBF
  .word MenuAction05_CastleRepairSetup     ; $BE7F: -> $BFF3
  .word MenuAction06_CastleRepair          ; $BE81: -> $C046
  .word MenuAction07_TaxRate               ; $BE83: -> $C090
  .word MenuAction08_GoldDistribution      ; $BE85: -> $C0C8
  .word MenuAction09_FoodDistribution      ; $BE87: -> $C123
  .word MenuAction0A_RecruitSoldiers       ; $BE89: -> $C168
  .word MenuAction0B_HireOfficer           ; $BE8B: -> $C1AC
  .word MenuAction0C_TransferOfficer       ; $BE8D: -> $C1FA
  .word MenuAction0D_ExecuteOfficer        ; $BE8F: -> $C25D
  .word MenuAction0E_ExileOfficer          ; $BE91: -> $C2DD
  .word MenuAction0F_GiveItem              ; $BE93: -> $C33D
  .word MenuAction10_MoveCapital           ; $BE95: -> $C3A2
  .word MenuAction11_Intrigue             ; $BE97: -> $C3F6
  .word MenuAction12_War                   ; $BE99: -> $C43E
  .word MenuAction13_Spy                   ; $BE9B: -> $C4E1
  .word MenuAction14_Accounting            ; $BE9D: -> $C511
  .word MenuAction15_Exchange              ; $BE9F: -> $C556
  .word MenuAction16_Trade                 ; $BEA1: -> $C5B1
  .word MenuAction17_SearchOfficer         ; $BEA3: -> $C5F7
  .word MenuAction18_SearchItem            ; $BEA5: -> $C636
  .word MenuAction19_InspectLand           ; $BEA7: -> $C67D
  .word MenuAction1A_PersonalAffairs       ; $BEA9: -> $C6C6
  .word MenuAction1B_DomesticDispatch      ; $BEAB: -> $C75F
  .word MenuAction1C_CopyTileData          ; $BEAD: -> $C7D1
  .word MenuAction1D_SetupActionDisplay    ; $BEAF: -> $C800
  .word MenuAction1E_CalcParams            ; $BEB1: -> $C830
  .word MenuAction1F_CalcParams2           ; $BEB3: -> $C87D
  .word MenuAction20_CalcParams3           ; $BEB5: -> $C8B4
  .word MenuAction21_Finalize              ; $BEB7: -> $C8F1
  .word MenuAction22_Cleanup               ; $BEB9: -> $C926
.endproc

.proc MenuAction00_InitialSetup
MenuAction00_InitialSetup:
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
  JMP DomesticMenu_Return                        ; $BEE8: 4C 34 C9
.endproc

.proc MenuAction01_DisplaySetup
MenuAction01_DisplaySetup:
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
  JMP DomesticMenu_Return                        ; $BF26: 4C 34 C9
@MenuAction01_RowTable:
  .byte $01, $02                          ; $BF29: 01 02
  .byte $03                               ; $BF2B: 03
  .byte $04                               ; $BF2C: 04
  .byte $03                               ; $BF2D: 03
  .byte $02                               ; $BF2E: 02
.endproc

.proc MenuAction02_LandDevelop
MenuAction02_LandDevelop:
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
  JMP DomesticMenu_Return                        ; $BF6D: 4C 34 C9
.endproc

.proc MenuAction03_FloodControlSetup
MenuAction03_FloodControlSetup:
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
  JMP DomesticMenu_Return                        ; $BFBC: 4C 34 C9
.endproc

.proc MenuAction04_FloodControl
MenuAction04_FloodControl:
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
  JMP DomesticMenu_Return                        ; $BFF0: 4C 34 C9
.endproc

.proc MenuAction05_CastleRepairSetup
MenuAction05_CastleRepairSetup:
  LDA $04A1                               ; $BFF3: AD A1 04
  .byte $D0, $18                          ; $BFF6: D0 18 (BNE $C010 = MenuAction05_LoadRows)
  LDA #$C6                                ; $BFF8: A9 C6
  JSR SetupDisplayPtrs                    ; $BFFA: 20 6D C9
  LDA #$CF                                ; $BFFD: A9 CF
  .byte $20                               ; $BFFF: 20 (JSR opcode, spans bank boundary)
.segment "CODE_BANK1E"
  .word ResetDispatchState                ; $C000: 8A C9 (operand)
  INC $04A1                                             ; $C002: EE A1 04
  LDA #$03                                              ; $C005: A9 03
  STA $04A4                                             ; $C007: 8D A4 04
  LDA #$80                                              ; $C00A: A9 80
  STA $04CC                                             ; $C00C: 8D CC 04
  RTS                                                   ; $C00F: 60
.endproc

;===============================================================================
; $C010: MenuAction05 load-rows phase
;===============================================================================
.proc MenuAction05_LoadRows
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
  JMP DomesticMenu_Return                                      ; $C043: 4C 34 C9
.endproc

.proc MenuAction06_CastleRepair
MenuAction06_CastleRepair:
  LDA $04A1                                             ; $C046: AD A1 04
  BNE MenuAction06_LoadRows                                 ; $C049: D0 13
  LDA #$EA                                              ; $C04B: A9 EA
  JSR SetupDisplayPtrs                                  ; $C04D: 20 6D C9
  LDA #$EB                                              ; $C050: A9 EB
  JSR ResetDispatchState                                ; $C052: 20 8A C9
  INC $04A1                                             ; $C055: EE A1 04
  LDA #$78                                              ; $C058: A9 78
  STA $04A3                                             ; $C05A: 8D A3 04
  RTS                                                   ; $C05D: 60
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
  JMP DomesticMenu_Return                                      ; $C07D: 4C 34 C9
@MenuAction06_RowTable:
  .byte $01, $02, $03, $03, $03, $03, $03, $02, $02, $02, $02, $01, $01, $01, $01, $01 ; $C080: 01 02 03 03 03 03 03 02 02 02 02 01 01 01 01 01
.endproc

.proc MenuAction07_TaxRate
MenuAction07_TaxRate:
  LDA $04A1                                             ; $C090: AD A1 04
  BNE MenuAction07_LoadRows                                 ; $C093: D0 09
  LDA #$B7                                              ; $C095: A9 B7
  JSR SetupDisplayPtrs                                  ; $C097: 20 6D C9
  INC $04A1                                             ; $C09A: EE A1 04
  RTS                                                   ; $C09D: 60

;===============================================================================
MenuAction07_LoadRows:
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
  BEQ @floodControlDone                                    ; $C0B3: F0 10
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
@floodControlDone:
  JMP DomesticMenu_Return                                      ; $C0C5: 4C 34 C9
.endproc

.proc MenuAction08_GoldDistribution
MenuAction08_GoldDistribution:
  LDA $04A1                                             ; $C0C8: AD A1 04
  BNE MenuAction08_LoadRows                                 ; $C0CB: D0 1A
  LDA #$CA                                              ; $C0CD: A9 CA
  JSR SetupDisplayPtrs                                  ; $C0CF: 20 6D C9
  INC $04A1                                             ; $C0D2: EE A1 04
  LDA #$03                                              ; $C0D5: A9 03
  STA $04A4                                             ; $C0D7: 8D A4 04
  LDA $04D6                                             ; $C0DA: AD D6 04
  CMP #$47                                              ; $C0DD: C9 47
  BEQ @skipPpuInit                                       ; $C0DF: F0 05
  LDA #$80                                              ; $C0E1: A9 80
  STA $04CC                                             ; $C0E3: 8D CC 04
@skipPpuInit:
  RTS                                                   ; $C0E6: 60
.endproc

.proc MenuAction08_LoadRows
MenuAction08_LoadRows:
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
  BNE @addThree                                          ; $C116: D0 02
  LDA #$01                                              ; $C118: A9 01
@addThree:
  CLC                                                   ; $C11A: 18
  ADC #$03                                              ; $C11B: 69 03
  STA $04A4                                             ; $C11D: 8D A4 04
  JMP DomesticMenu_Return                                      ; $C120: 4C 34 C9
.endproc

.proc MenuAction09_FoodDistribution
MenuAction09_FoodDistribution:
  LDA $04A1                                             ; $C123: AD A1 04
  BNE MenuAction09_LoadRows                                 ; $C126: D0 0E
  LDA #$F1                                              ; $C128: A9 F1
  JSR SetupDisplayPtrs                                  ; $C12A: 20 6D C9
  LDA #$F2                                              ; $C12D: A9 F2
  JSR ResetDispatchState                                ; $C12F: 20 8A C9
  INC $04A1                                             ; $C132: EE A1 04
  RTS                                                   ; $C135: 60

;===============================================================================
MenuAction09_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C155: 4C 34 C9
@MenuAction09_RowTable:
  .byte $01, $02, $03, $03, $03, $04, $04, $04, $03, $03, $03, $04, $04, $04, $02, $01 ; $C158: 01 02 03 03 03 04 04 04 03 03 03 04 04 04 02 01
.endproc

.proc MenuAction0A_RecruitSoldiers
MenuAction0A_RecruitSoldiers:
  LDA $04A1                                             ; $C168: AD A1 04
  BNE MenuAction0A_LoadRows                                 ; $C16B: D0 0E
  LDA #$F0                                              ; $C16D: A9 F0
  JSR SetupDisplayPtrs                                  ; $C16F: 20 6D C9
  INC $04A1                                             ; $C172: EE A1 04
  LDA #$28                                              ; $C175: A9 28
  STA $04A3                                             ; $C177: 8D A3 04
  RTS                                                   ; $C17A: 60

;===============================================================================
MenuAction0A_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C199: 4C 34 C9
@MenuAction0A_RowTable:
  .byte $01, $02, $03, $03, $03, $03, $03, $03, $02, $02, $02, $02, $01, $01, $01, $01 ; $C19C: 01 02 03 03 03 03 03 03 02 02 02 02 01 01 01 01
.endproc

.proc MenuAction0B_HireOfficer
MenuAction0B_HireOfficer:
  LDA $04A1                                             ; $C1AC: AD A1 04
  BNE MenuAction0B_LoadRows                                 ; $C1AF: D0 19
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
MenuAction0B_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C1EF: 4C 34 C9
@MenuAction0B_RowTable:
  .byte $02, $03, $02, $03, $01, $01, $01, $01          ; $C1F2: 02 03 02 03 01 01 01 01
.endproc

.proc MenuAction0C_TransferOfficer
MenuAction0C_TransferOfficer:
  LDA $04A1                                             ; $C1FA: AD A1 04
  BNE MenuAction0C_LoadRows                                 ; $C1FD: D0 19
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
MenuAction0C_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C24F: 4C 34 C9

;===============================================================================
; $C252: Action0A_Recruit
;===============================================================================
@MenuAction0C_RowTable:
  .byte $01, $02, $03, $04, $04, $03, $04, $04, $03, $02, $01 ; $C252: 01 02 03 04 04 03 04 04 03 02 01
.endproc

.proc MenuAction0D_ExecuteOfficer
MenuAction0D_ExecuteOfficer:
  LDA $04A1                                             ; $C25D: AD A1 04
  BNE MenuAction0D_LoadRows                                 ; $C260: D0 28
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
MenuAction0D_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C2C0: 4C 34 C9
@MenuAction0D_SpriteData:
  .byte $03, $23, $D1, $0F, $0F, $8B, $03, $23, $D9, $00, $00, $88, $FF, $03, $23, $D4 ; $C2C3: 03 23 D1 0F 0F 8B 03 23 D9 00 00 88 FF 03 23 D4
  .byte $2E, $0F, $0F, $03, $23, $DC, $22, $00, $00, $FF ; $C2D3: 2E 0F 0F 03 23 DC 22 00 00 FF
.endproc

.proc MenuAction0E_ExileOfficer
MenuAction0E_ExileOfficer:
  LDA $04A1                                             ; $C2DD: AD A1 04
  BNE MenuAction0E_LoadRows                                 ; $C2E0: D0 0E
  LDA #$F3                                              ; $C2E2: A9 F3
  JSR SetupDisplayPtrs                                  ; $C2E4: 20 6D C9
  LDA #$F4                                              ; $C2E7: A9 F4
  JSR ResetDispatchState                                ; $C2E9: 20 8A C9
  INC $04A1                                             ; $C2EC: EE A1 04
  RTS                                                   ; $C2EF: 60

;===============================================================================
MenuAction0E_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C32F: 4C 34 C9
@MenuAction0E_RowTable:
  .byte $03, $03, $03, $03, $03, $03, $04, $05, $05, $04, $03 ; $C332: 03 03 03 03 03 03 04 05 05 04 03
.endproc

.proc MenuAction0F_GiveItem
MenuAction0F_GiveItem:
  LDA $04A1                                             ; $C33D: AD A1 04
  BNE MenuAction0F_LoadRows                                 ; $C340: D0 0E
  LDA #$F0                                              ; $C342: A9 F0
  JSR SetupDisplayPtrs                                  ; $C344: 20 6D C9
  INC $04A1                                             ; $C347: EE A1 04
  LDA #$20                                              ; $C34A: A9 20
  STA $04A4                                             ; $C34C: 8D A4 04
  RTS                                                   ; $C34F: 60

;===============================================================================
MenuAction0F_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C39F: 4C 34 C9
.endproc

.proc MenuAction10_MoveCapital
MenuAction10_MoveCapital:
  LDA $04A1                                             ; $C3A2: AD A1 04
  BNE MenuAction10_LoadRows                                 ; $C3A5: D0 13
  LDA #$D0                                              ; $C3A7: A9 D0
  JSR SetupDisplayPtrs                                  ; $C3A9: 20 6D C9
  LDA #$D1                                              ; $C3AC: A9 D1
  JSR ResetDispatchState                                ; $C3AE: 20 8A C9
  INC $04A1                                             ; $C3B1: EE A1 04
  LDA #$20                                              ; $C3B4: A9 20
  STA $04A5                                             ; $C3B6: 8D A5 04
  RTS                                                   ; $C3B9: 60

;===============================================================================
MenuAction10_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C3F3: 4C 34 C9
.endproc

.proc MenuAction11_Intrigue
MenuAction11_Intrigue:
  LDA $04A1                                             ; $C3F6: AD A1 04
  BNE MenuAction11_LoadRows                                 ; $C3F9: D0 19
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
MenuAction11_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C433: 4C 34 C9
@MenuAction11_RowTable:
  .byte $01, $02, $03, $03, $03, $03, $02, $01          ; $C436: 01 02 03 03 03 03 02 01
.endproc

.proc MenuAction12_War
MenuAction12_War:
  LDA $04A1                                             ; $C43E: AD A1 04
  BNE MenuAction12_LoadRows                                 ; $C441: D0 37
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
MenuAction12_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C4BE: 4C 34 C9
@MenuAction12_SpriteData:
  .byte $02, $23, $C9, $AA, $FA, $02, $23, $D1, $AF, $FF, $02, $23, $D9, $AA, $FF, $FF ; $C4C1: 02 23 C9 AA FA 02 23 D1 AF FF 02 23 D9 AA FF FF
  .byte $02, $23, $CC, $AA, $EA, $02, $23, $D4, $AE, $EF, $02, $23, $DC, $AA, $EE, $FF ; $C4D1: 02 23 CC AA EA 02 23 D4 AE EF 02 23 DC AA EE FF
.endproc

.proc MenuAction13_Spy
MenuAction13_Spy:
  LDA $04A1                                             ; $C4E1: AD A1 04
  BNE L_C4EF                                            ; $C4E4: D0 09
  LDA #$E7                                              ; $C4E6: A9 E7
  JSR SetupDisplayPtrs                                  ; $C4E8: 20 6D C9
  INC $04A1                                             ; $C4EB: EE A1 04

;===============================================================================
; $C4EE: Action11_Intrigue
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
  JMP DomesticMenu_Return                                      ; $C50E: 4C 34 C9
.endproc

.proc MenuAction14_Accounting
MenuAction14_Accounting:
  LDA $04A1                                             ; $C511: AD A1 04
    BNE MenuAction14_LoadRows                                 ; $C514: D0 0E
  LDA #$FB                                              ; $C516: A9 FB
  JSR SetupDisplayPtrs                                  ; $C518: 20 6D C9
  LDA #$FC                                              ; $C51B: A9 FC
  JSR ResetDispatchState                                ; $C51D: 20 8A C9
  INC $04A1                                             ; $C520: EE A1 04
  RTS                                                   ; $C523: 60

;===============================================================================
MenuAction14_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C543: 4C 34 C9
@MenuAction14_RowTable:
  .byte $01, $03, $01, $03, $02, $03, $01, $03, $02, $01, $01, $04, $04, $04, $04, $04 ; $C546: 01 03 01 03 02 03 01 03 02 01 01 04 04 04 04 04
.endproc

.proc MenuAction15_Exchange
MenuAction15_Exchange:
  LDA $04A1                                             ; $C556: AD A1 04
  BNE MenuAction15_LoadRows                                 ; $C559: D0 1E
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
MenuAction15_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C5AE: 4C 34 C9
.endproc

.proc MenuAction16_Trade
MenuAction16_Trade:
  LDA $04A1                                             ; $C5B1: AD A1 04
  BNE MenuAction16_LoadRows                                 ; $C5B4: D0 0E
  LDA #$F6                                              ; $C5B6: A9 F6
  JSR SetupDisplayPtrs                                  ; $C5B8: 20 6D C9
  INC $04A1                                             ; $C5BB: EE A1 04
  LDA #$03                                              ; $C5BE: A9 03
  STA $04A4                                             ; $C5C0: 8D A4 04
  RTS                                                   ; $C5C3: 60

;===============================================================================
MenuAction16_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C5F4: 4C 34 C9
.endproc

.proc MenuAction17_SearchOfficer
MenuAction17_SearchOfficer:
  LDA $04A1                                             ; $C5F7: AD A1 04
  BNE MenuAction17_LoadRows                                 ; $C5FA: D0 0E
  LDA #$F7                                              ; $C5FC: A9 F7
  JSR SetupDisplayPtrs                                  ; $C5FE: 20 6D C9
  LDA #$DF                                              ; $C601: A9 DF
  JSR ResetDispatchState                                ; $C603: 20 8A C9
  INC $04A1                                             ; $C606: EE A1 04
  RTS                                                   ; $C609: 60

;===============================================================================
MenuAction17_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C633: 4C 34 C9
.endproc

.proc MenuAction18_SearchItem
MenuAction18_SearchItem:
  LDA $04A1                                             ; $C636: AD A1 04
  BNE MenuAction18_LoadRows                                 ; $C639: D0 09
  LDA #$C5                                              ; $C63B: A9 C5
  JSR SetupDisplayPtrs                                  ; $C63D: 20 6D C9
  INC $04A1                                             ; $C640: EE A1 04
  RTS                                                   ; $C643: 60

;===============================================================================
MenuAction18_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C67A: 4C 34 C9
.endproc

.proc MenuAction19_InspectLand
MenuAction19_InspectLand:
  LDA $04A1                                             ; $C67D: AD A1 04
  BNE MenuAction19_LoadRows                                 ; $C680: D0 19
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
MenuAction19_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C6BB: 4C 34 C9
@MenuAction19_RowTable:
  .byte $01, $02, $01, $02, $01, $03, $03, $03          ; $C6BE: 01 02 01 02 01 03 03 03
.endproc

.proc MenuAction1A_PersonalAffairs
MenuAction1A_PersonalAffairs:
  LDA $04A1                                             ; $C6C6: AD A1 04
  BNE MenuAction1A_LoadRows                                 ; $C6C9: D0 32
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
MenuAction1A_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C72E: 4C 34 C9
@MenuAction1A_RowAndSpriteData:
  .byte $01, $02, $03, $04, $01, $02, $05, $06, $03, $23, $C9, $FA, $FA, $BA, $03, $23 ; $C731: 01 02 03 04 01 02 05 06 03 23 C9 FA FA BA 03 23
  .byte $D1, $0F, $0F, $8B, $03, $23, $D9, $50, $50, $98, $FF, $03, $23, $CC, $EA, $FA ; $C741: D1 0F 0F 8B 03 23 D9 50 50 98 FF 03 23 CC EA FA
  .byte $FA, $03, $23, $D4, $2E, $0F, $0F, $03, $23, $DC, $62, $50, $50, $FF ; $C751: FA 03 23 D4 2E 0F 0F 03 23 DC 62 50 50 FF
.endproc

.proc MenuAction1B_DomesticDispatch
MenuAction1B_DomesticDispatch:
  LDA $04A1                                             ; $C75F: AD A1 04
  BNE MenuAction1B_LoadRows                                 ; $C762: D0 28
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
MenuAction1B_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C7B4: 4C 34 C9
@MenuAction1B_SpriteData:
  .byte $03, $23, $C9, $0A, $0A, $8A, $03, $23, $D1, $F0, $F0, $B8, $FF, $03, $23, $CC ; $C7B7: 03 23 C9 0A 0A 8A 03 23 D1 F0 F0 B8 FF 03 23 CC
  .byte $2A, $0A, $0A, $03, $23, $D4, $E2, $F0, $F0, $FF ; $C7C7: 2A 0A 0A 03 23 D4 E2 F0 F0 FF
.endproc

.proc MenuAction1C_CopyTileData
MenuAction1C_CopyTileData:
  LDA $04A1                                             ; $C7D1: AD A1 04
  BNE MenuAction1C_LoadRows                                 ; $C7D4: D0 09
  LDA #$C2                                              ; $C7D6: A9 C2
  JSR SetupDisplayPtrs                                  ; $C7D8: 20 6D C9
  INC $04A1                                             ; $C7DB: EE A1 04
  RTS                                                   ; $C7DE: 60

;===============================================================================
MenuAction1C_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C7FD: 4C 34 C9
.endproc

.proc MenuAction1D_SetupActionDisplay
MenuAction1D_SetupActionDisplay:
  LDA $04A1                                             ; $C800: AD A1 04
  BNE MenuAction1D_LoadRows                                 ; $C803: D0 09
  LDA #$D1                                              ; $C805: A9 D1
  JSR SetupDisplayPtrs                                  ; $C807: 20 6D C9
  INC $04A1                                             ; $C80A: EE A1 04
  RTS                                                   ; $C80D: 60

;===============================================================================
MenuAction1D_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C82D: 4C 34 C9
.endproc

.proc MenuAction1E_CalcParams
MenuAction1E_CalcParams:
  LDA $04A1                                             ; $C830: AD A1 04
  BNE MenuAction1E_LoadRows                                 ; $C833: D0 0E
  LDA #$C6                                              ; $C835: A9 C6
  JSR SetupDisplayPtrs                                  ; $C837: 20 6D C9
  INC $04A1                                             ; $C83A: EE A1 04
  LDA #$03                                              ; $C83D: A9 03
  STA $04A4                                             ; $C83F: 8D A4 04
  RTS                                                   ; $C842: 60

;===============================================================================
MenuAction1E_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C87A: 4C 34 C9
.endproc

.proc MenuAction1F_CalcParams2
MenuAction1F_CalcParams2:
  LDA $04A1                                             ; $C87D: AD A1 04
  BNE MenuAction1F_LoadRows                                 ; $C880: D0 09
  LDA #$BD                                              ; $C882: A9 BD
  JSR SetupDisplayPtrs                                  ; $C884: 20 6D C9
  INC $04A1                                             ; $C887: EE A1 04
  RTS                                                   ; $C88A: 60

;===============================================================================
MenuAction1F_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C8B1: 4C 34 C9
.endproc

.proc MenuAction20_CalcParams3
MenuAction20_CalcParams3:
  LDA $04A1                                             ; $C8B4: AD A1 04
  BNE MenuAction20_LoadRows                                 ; $C8B7: D0 0E
  LDA #$B7                                              ; $C8B9: A9 B7
  JSR SetupDisplayPtrs                                  ; $C8BB: 20 6D C9
  LDA #$B7                                              ; $C8BE: A9 B7
  JSR ResetDispatchState                                ; $C8C0: 20 8A C9
  INC $04A1                                             ; $C8C3: EE A1 04
  RTS                                                   ; $C8C6: 60

;===============================================================================
MenuAction20_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C8EE: 4C 34 C9
.endproc

.proc MenuAction21_Finalize
MenuAction21_Finalize:
  LDA $04A1                                             ; $C8F1: AD A1 04
  BNE MenuAction21_LoadRows                                 ; $C8F4: D0 0E
  LDA #$AA                                              ; $C8F6: A9 AA
  JSR SetupDisplayPtrs                                  ; $C8F8: 20 6D C9
  LDA #$AB                                              ; $C8FB: A9 AB
  JSR ResetDispatchState                                ; $C8FD: 20 8A C9
  INC $04A1                                             ; $C900: EE A1 04
  RTS                                                   ; $C903: 60

;===============================================================================
MenuAction21_LoadRows:
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
  JMP DomesticMenu_Return                                      ; $C923: 4C 34 C9
.endproc

.proc MenuAction22_Cleanup
MenuAction22_Cleanup:
  LDA $0140                                             ; $C926: AD 40 01
  BNE MenuAction22_Continue                                 ; $C929: D0 08
  LDA #$00                                              ; $C92B: A9 00
  STA $04A0                                             ; $C92D: 8D A0 04
  STA $04A2                                             ; $C930: 8D A2 04
MenuAction22_Continue:
  RTS                                                   ; $C933: 60
.endproc

;===============================================================================
; $C934: DomesticMenu_Return
;===============================================================================
.proc DomesticMenu_Return
  ; Proc-local RAM variable
  domestic_trigger  = $007D  ; domestic menu trigger
DomesticMenu_Return:
  LDA $04D0                                             ; $C934: AD D0 04
  CMP $04CC                                             ; $C937: CD CC 04
  BCC @EarlyReturn                                            ; $C93A: 90 30
  LDA $04A2                                             ; $C93C: AD A2 04
  BEQ @InitPpuAndSound                                            ; $C93F: F0 10
  CMP #$04                                              ; $C941: C9 04
  BEQ @InitPpuAndSound                                            ; $C943: F0 0C
  CMP #$08                                              ; $C945: C9 08
  BEQ @InitPpuAndSound                                            ; $C947: F0 08
  JSR B1F_BankPpuInit                                         ; $C949: 20 7F E5
  LDA #$81                                              ; $C94C: A9 81
  JSR B1F_SoundWrapperA                                       ; $C94E: 20 73 E6
@InitPpuAndSound:
  LDA #$01                                              ; $C951: A9 01
  STA $007D                                             ; $C953: 8D 7D 00
  LDA #$00                                              ; $C956: A9 00
  STA $0000                                             ; $C958: 8D 00 00
  LDY #$3D                                              ; $C95B: A0 3D
  JSR B1F_BankedCallbackTrampoline                      ; $C95D: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A015                                           ; $C960: 15 A0  -> LoadScenarioData_Entry ($DBB1)
  LDA #$80                                              ; $C962: A9 80
  STA $0140                                             ; $C964: 8D 40 01
  LDA #$22                                              ; $C967: A9 22
  STA $04A2                                             ; $C969: 8D A2 04
@EarlyReturn:
  RTS                                                   ; $C96C: 60
.endproc

;===============================================================================
; $C96D: SetupDisplayPtrs
;===============================================================================
.proc SetupDisplayPtrs
  ; Proc-local RAM variables
  setup_disp_b      = $00BF  ; display ptr temp B
  setup_disp_a      = $00C7  ; display ptr temp A
  setup_disp_e      = $00CF  ; display ptr temp E
  setup_disp_src    = $0130  ; display ptr source
SetupDisplayPtrs:
  STA $00BF                                             ; $C96D: 8D BF 00
  STA $00C7                                             ; $C970: 8D C7 00
  STA $00CF                                             ; $C973: 8D CF 00
  LDY #$0C                                              ; $C976: A0 0C
@CopyPtrsLoop:
  LDA $0120,Y                                           ; $C978: B9 20 01
  STA $0100,Y                                           ; $C97B: 99 00 01
  LDA $0130,Y                                           ; $C97E: B9 30 01
  STA $0110,Y                                           ; $C981: 99 10 01
  INY                                                   ; $C984: C8
  CPY #$10                                              ; $C985: C0 10
  BCC @CopyPtrsLoop                                            ; $C987: 90 EF
  RTS                                                   ; $C989: 60
.endproc

;===============================================================================
; $C98A: ResetDispatchState
;===============================================================================
.proc ResetDispatchState
  ; Proc-local RAM variables
  setup_disp_c      = $00C0  ; dispatch reset temp C
  setup_disp_d      = $00C8  ; dispatch reset temp D
  setup_disp_f      = $00D0  ; dispatch reset temp F
ResetDispatchState:
  STA $00C0                                             ; $C98A: 8D C0 00
  STA $00C8                                             ; $C98D: 8D C8 00
  STA $00D0                                             ; $C990: 8D D0 00
  RTS                                                   ; $C993: 60
.endproc

;===============================================================================
; $C994: DisplayTileData
;===============================================================================
.proc DisplayTileData
DisplayTileData:
  LDX #$20                                              ; $C994: A2 20
@DisplayTileDataWithX:
@DisplayTileDataWithParams:
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
  BPL @SkipXOffset                                            ; $C9AB: 10 05
  TXA                                                   ; $C9AD: 8A
  CLC                                                   ; $C9AE: 18
  ADC #$70                                              ; $C9AF: 69 70
  TAX                                                   ; $C9B1: AA
@SkipXOffset:
  STX $000C                                             ; $C9B2: 8E 0C 00
  LDA #$2F                                              ; $C9B5: A9 2F
  STA $000A                                             ; $C9B7: 8D 0A 00
  LDA #$03                                              ; $C9BA: A9 03
  STA $0002                                             ; $C9BC: 8D 02 00
  JMP B1F_SpriteOamWriterSimple                               ; $C9BF: 4C AD F1
.endproc

.proc MenuRenderer_SecondaryDispatch
  LDA $04A1                                             ; $C9C2: AD A1 04
  JSR B1F_CallbackDispatcher                            ; $C9C5: 20 DE EA
  INX                                                   ; $C9C8: E8
  CMP #$D0                                              ; $C9C9: C9 D0
  CMP #$4E                                              ; $C9CB: C9 4E
  DEX                                                   ; $C9CD: CA
  .byte $52                                             ; $C9CE: 52
  .byte $CB, $A9                                        ; $C9CF: CB A9
  .byte $01, $8D                                        ; $C9D1: 01 8D
  .byte $7D, $00, $A0                                   ; $C9D3: 7D 00 A0
  .byte $0C                                             ; $C9D6: 0C
  LDA #$0F                                              ; $C9D7: A9 0F
@FillLoop:
  STA $0100,Y                                           ; $C9D9: 99 00 01
  STA $0110,Y                                           ; $C9DC: 99 10 01
  INY                                                   ; $C9DF: C8
  CPY #$10                                              ; $C9E0: C0 10
  BCC @FillLoop                                            ; $C9E2: 90 F5
  INC $04A1                                             ; $C9E4: EE A1 04
  RTS                                                   ; $C9E7: 60
.endproc

;===============================================================================
; $C9E8: SramSaveBlock
;===============================================================================
.proc SramSaveBlock
SramSaveBlock:
  LDA #$40                                              ; $C9E8: A9 40
  STA $0000                                             ; $C9EA: 8D 00 00
  LDA #$CC                                              ; $C9ED: A9 CC
  STA $0001                                             ; $C9EF: 8D 01 00
  LDA $0150                                             ; $C9F2: AD 50 01
  BPL @SaveEntry                                            ; $C9F5: 10 11
  LDA $0000                                             ; $C9F7: AD 00 00
  CLC                                                   ; $C9FA: 18
  ADC #$1C                                              ; $C9FB: 69 1C
  STA $0000                                             ; $C9FD: 8D 00 00
  LDA $0001                                             ; $CA00: AD 01 00
  ADC #$00                                              ; $CA03: 69 00
  STA $0001                                             ; $CA05: 8D 01 00
@SaveEntry:
  LDY #$00                                              ; $CA08: A0 00
@CopySaveLoop:
  LDA ($00),Y                                           ; $CA0A: B1 00
  STA $0380,Y                                           ; $CA0C: 99 80 03
  INY                                                   ; $CA0F: C8
  CPY #$1C                                              ; $CA10: C0 1C
  BCC @CopySaveLoop                                            ; $CA12: 90 F6
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
  BPL @SetBlockOffset                                            ; $CA30: 10 02
  LDX #$10                                              ; $CA32: A2 10
@SetBlockOffset:
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
.endproc

;===============================================================================
; $CA4E: SramLoadBlock
;===============================================================================
.proc SramLoadBlock
SramLoadBlock:
  DEC $04A3                                             ; $CA4E: CE A3 04
  LDA $04A3                                             ; $CA51: AD A3 04
  BPL @LoadEntry                                            ; $CA54: 10 03
  JMP VerifyChecksum                                            ; $CA56: 4C C5 CA
@LoadEntry:
  LDA $04D4                                             ; $CA59: AD D4 04
  STA $0000                                             ; $CA5C: 8D 00 00
  LDA $04D5                                             ; $CA5F: AD D5 04
  STA $0001                                             ; $CA62: 8D 01 00
  LDY #$00                                              ; $CA65: A0 00
  LDX #$00                                              ; $CA67: A2 00
@ProcessRecordLoop:
  LDA #$0E                                              ; $CA69: A9 0E
  STA $0380,X                                           ; $CA6B: 9D 80 03
  INX                                                   ; $CA6E: E8
  LDA ($00),Y                                           ; $CA6F: B1 00
  CMP #$FF                                              ; $CA71: C9 FF
  BNE @NotTerminated                                            ; $CA73: D0 07
  DEX                                                   ; $CA75: CA
  STA $0380,X                                           ; $CA76: 9D 80 03
  JMP @FinalizeLoad                                            ; $CA79: 4C BC CA
@NotTerminated:
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
@CopyTileDataLoop:
  LDA ($00),Y                                           ; $CA91: B1 00
  STA $0380,X                                           ; $CA93: 9D 80 03
  INX                                                   ; $CA96: E8
  INY                                                   ; $CA97: C8
  INC $0002                                             ; $CA98: EE 02 00
  LDA $0002                                             ; $CA9B: AD 02 00
  CMP #$0E                                              ; $CA9E: C9 0E
  BCC @CopyTileDataLoop                                            ; $CAA0: 90 EF
  CPY #$50                                              ; $CAA2: C0 50
  BCC @ProcessRecordLoop                                            ; $CAA4: 90 C3
  LDA #$FF                                              ; $CAA6: A9 FF
  STA $0380,X                                           ; $CAA8: 9D 80 03
  LDA $0000                                             ; $CAAB: AD 00 00
  CLC                                                   ; $CAAE: 18
  ADC #$50                                              ; $CAAF: 69 50
  STA $04D4                                             ; $CAB1: 8D D4 04
  LDA $0001                                             ; $CAB4: AD 01 00
  ADC #$00                                              ; $CAB7: 69 00
  STA $04D5                                             ; $CAB9: 8D D5 04
@FinalizeLoad:
  LDA $007E                                             ; $CABC: AD 7E 00
  ORA #$04                                              ; $CABF: 09 04
  STA $007E                                             ; $CAC1: 8D 7E 00
  RTS                                                   ; $CAC4: 60
.endproc

;===============================================================================
; $CAC5: VerifyChecksum
;===============================================================================
.proc VerifyChecksum
  ; Proc-local RAM variables
  vfy_chk_10C       = $010C  ; checksum temp 10C
  vfy_chk_11C       = $011C  ; checksum temp 11C
VerifyChecksum:
  LDA #$20                                              ; $CAC5: A9 20
  STA $04D3                                             ; $CAC7: 8D D3 04
  LDX #$C4                                              ; $CACA: A2 C4
  LDA $0150                                             ; $CACC: AD 50 01
  BPL @SelectPlayerBlock                                            ; $CACF: 10 02
  LDX #$D2                                              ; $CAD1: A2 D2
@SelectPlayerBlock:
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
@LoadDisplayPtrsA:
  LDA ($00),Y                                           ; $CB19: B1 00
  STA $0120,X                                           ; $CB1B: 9D 20 01
  INX                                                   ; $CB1E: E8
  INY                                                   ; $CB1F: C8
  CPY #$05                                              ; $CB20: C0 05
  BCC @LoadDisplayPtrsA                                            ; $CB22: 90 F5
  LDX #$1D                                              ; $CB24: A2 1D
@LoadDisplayPtrsB:
  LDA ($00),Y                                           ; $CB26: B1 00
  STA $0120,X                                           ; $CB28: 9D 20 01
  INX                                                   ; $CB2B: E8
  INY                                                   ; $CB2C: C8
  CPY #$08                                              ; $CB2D: C0 08
  BCC @LoadDisplayPtrsB                                            ; $CB2F: 90 F5
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
.endproc

;===============================================================================
; $CB52: OfficerRecCalc
;===============================================================================
.proc OfficerRecCalc
OfficerRecCalc:
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
@ProcessRecLoop:
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
@CopyRecDataLoop:
  LDA ($00),Y                                           ; $CB84: B1 00
  STA $0380,X                                           ; $CB86: 9D 80 03
  INX                                                   ; $CB89: E8
  INY                                                   ; $CB8A: C8
  CPY #$0A                                              ; $CB8B: C0 0A
  BCC @CopyRecDataLoop                                            ; $CB8D: 90 F5
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
  BCC @ProcessRecLoop                                            ; $CBB3: 90 B9
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
  BPL @ExitFinalize                                            ; $CBD8: 10 26
  LDA $04A2                                             ; $CBDA: AD A2 04
  CMP #$04                                              ; $CBDD: C9 04
  BEQ @ExitResetState                                            ; $CBDF: F0 0A
  CMP #$05                                              ; $CBE1: C9 05
  BEQ @ExitResetState                                            ; $CBE3: F0 06
  JSR B1F_BankPpuInit                                         ; $CBE5: 20 7F E5
  JSR ProvinceRecCalc                                            ; $CBE8: 20 09 CC
@ExitResetState:
  LDA #$81                                              ; $CBEB: A9 81
  STA $04A0                                             ; $CBED: 8D A0 04
  LDA #$FF                                              ; $CBF0: A9 FF
  STA $04CC                                             ; $CBF2: 8D CC 04
  LDA #$00                                              ; $CBF5: A9 00
  STA $04A1                                             ; $CBF7: 8D A1 04
  STA $04A3                                             ; $CBFA: 8D A3 04
  STA $04D0                                             ; $CBFD: 8D D0 04
@ExitFinalize:
  LDA $007E                                             ; $CC00: AD 7E 00
  ORA #$04                                              ; $CC03: 09 04
  STA $007E                                             ; $CC05: 8D 7E 00
  RTS                                                   ; $CC08: 60
.endproc

;===============================================================================
; $CC09: ProvinceRecCalc
;===============================================================================
.proc ProvinceRecCalc
ProvinceRecCalc:
  LDA $04D6                                             ; $CC09: AD D6 04
  CMP #$32                                              ; $CC0C: C9 32
  BEQ @SoundB                                            ; $CC0E: F0 2D
  CMP #$47                                              ; $CC10: C9 47
  BEQ @SoundB                                            ; $CC12: F0 29
  CMP #$2E                                              ; $CC14: C9 2E
  BEQ @SoundD                                            ; $CC16: F0 22
  CMP #$3E                                              ; $CC18: C9 3E
  BEQ @SoundD                                            ; $CC1A: F0 1E
  CMP #$52                                              ; $CC1C: C9 52
  BEQ @SoundD                                            ; $CC1E: F0 1A
  CMP #$A2                                              ; $CC20: C9 A2
  BEQ @SoundD                                            ; $CC22: F0 16
  CMP #$A6                                              ; $CC24: C9 A6
  BEQ @SoundD                                            ; $CC26: F0 12
  CMP #$38                                              ; $CC28: C9 38
  BEQ @SoundE                                            ; $CC2A: F0 0B
  CMP #$3B                                              ; $CC2C: C9 3B
  BEQ @SoundE                                            ; $CC2E: F0 07
  CMP #$9F                                              ; $CC30: C9 9F
  BEQ @SoundE                                            ; $CC32: F0 03
  JMP B1F_SoundWrapperC                                       ; $CC34: 4C 83 E6
@SoundE:
  JMP B1F_SoundWrapperE                                       ; $CC37: 4C 93 E6
@SoundD:
  JMP B1F_SoundWrapperD                                       ; $CC3A: 4C 8B E6
@SoundB:
  JMP B1F_SoundWrapperB                                       ; $CC3D: 4C 7B E6

.endproc

;===============================================================================
; MenuTilemapStream ($CC40-$DBB0) - 3953 bytes
;
; PPU tilemap command stream read by PPUTileRender dispatch ($A1C8).
; Accessed via bank-switching: bank $1E is loaded at $8000-$9FFF,
; then CalcMenuDataPtr ($A61D) computes data_ptr ($A6/$A7) from
; pos_buf_0 and BankPageOffsetTable.
;
; Stream format (parsed byte-by-byte):
;   $00-$7F : tile index (direct, stored via StoreTileByte)
;   $80-$9F : command byte (dispatched via MenuDispatchTable at $A208)
;     $80 = EndMenu        - terminate rendering for this section
;     $81 = AdvanceRow     - advance VRAM position by $40 (one nametable row)
;     $82 = PushPosition   - save VRAM pos + data ptr, read 2 new pos bytes
;     $83 = PopPosition    - restore saved VRAM pos + data ptr
;     $84 = OverlayOn      - set overlay_flag = $80
;     $85 = OverlayOff     - set overlay_flag = $00
;     $86-$8F = SetVramPos - read 2 bytes, set VRAM address
;     $90-$97 = DrawName   - draw character name (index = cmd - $90)
;     $98-$9B = DrawNumber - draw BCD number (index = cmd - $98)
;     $9C = DrawNameData   - read index, 6-char name from data
;     $9D = DrawNameFixed7 - read index, 7-char name from data
;     $9E = DrawFmtNumber  - read index, formatted number
;     $9F = DrawNameParam  - read index, name lookup
;   $C0-$FF : tile index (with high bit, for alternate tile page)
;
; Sections (separated by $80 EndMenu):
;   $CC40-$CC79  : Section 0  - header/ornament tiles (54 tiles)
;   $CC7A-$CCF9  : Section 1  - frame/border tiles (77 tiles)
;   $CCFA-$D565  : Section 2  - main screen tilemap (2139 tiles, largest)
;   $D566-$D589  : Sections 3-18 - small tile fragments (transitions)
;   $D58A-$D956  : Section 19 - secondary screen tilemap (972 tiles)
;   $D957-$D96B  : Sections 20-24 - small tile fragments
;   $D96C-$DBB0  : Section 25 - final tilemap section (581 tiles)
;===============================================================================
MenuTilemapStream:
  .byte $04, $23, $C8, $99, $FA, $FA, $BA, $04, $23, $D0, $99, $FF, $FF, $BB, $04, $23 ; $CC40: 04 23 C8 99 FA FA BA 04 23 D0 99 FF FF BB 04 23
  .byte $D8, $99, $FF, $FF, $BB, $04, $23, $E0, $59, $5A, $5A, $0A, $04, $23, $CC, $EA ; $CC50: D8 99 FF FF BB 04 23 E0 59 5A 5A 0A 04 23 CC EA
  .byte $FA, $FA, $22, $04, $23, $D4, $EE, $FF, $FF, $22, $04, $23, $DC, $EE, $FF, $FF ; $CC60: FA FA 22 04 23 D4 EE FF FF 22 04 23 DC EE FF FF
  .byte $22, $04, $23, $E4, $0A, $0A, $0A, $02, $20, $80, $9B, $9C, $BE, $BF, $84, $84 ; $CC70: 22 04 23 E4 0A 0A 0A 02 20 |80| 9B 9C BE BF 84 84  ; $80=EndMenu Section 0 ($CC40-$CC79)
  .byte $84, $84, $84, $84, $85, $86, $87, $88, $20, $A0, $89, $8A, $8B, $8C, $8C, $8C ; $CC80: 84 84 84 84 85 86 87 88 20 A0 89 8A 8B 8C 8C 8C
  .byte $8C, $8C, $8C, $8C, $8C, $8D, $8E, $8F, $20, $C0, $90, $91, $00, $00, $00, $00 ; $CC90: 8C 8C 8C 8C 8C 8D 8E 8F 20 C0 90 91 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $92, $93, $20, $E0, $94, $91, $00, $00, $00, $00 ; $CCA0: 00 00 00 00 00 00 92 93 20 E0 94 91 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $92, $95, $21, $00, $96, $97, $00, $00, $00, $00 ; $CCB0: 00 00 00 00 00 00 92 95 21 00 96 97 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $98, $99, $21, $20, $96, $97, $00, $00, $00, $00 ; $CCC0: 00 00 00 00 00 00 98 99 21 20 96 97 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $98, $99, $21, $40, $96, $97, $00, $00, $00, $00 ; $CCD0: 00 00 00 00 00 00 98 99 21 40 96 97 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $98, $99, $21, $60, $96, $97, $00, $00, $00, $00 ; $CCE0: 00 00 00 00 00 00 98 99 21 60 96 97 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $98, $99, $21, $80, $96, $97, $00, $00, $00, $00 ; $CCF0: 00 00 00 00 00 00 98 99 21 |80| 96 97 00 00 00 00  ; $80=EndMenu Section 1 ($CC7A-$CCF9)
  ; Section 2 ($CCFA-$D565): Main screen tilemap - 2139 tile bytes, largest section
  .byte $00, $00, $00, $00, $00, $00, $98, $99, $21, $A0, $96, $97, $00, $00, $00, $00 ; $CD00: 00 00 00 00 00 00 98 99 21 A0 96 97 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $98, $99, $21, $C0, $9A, $97, $00, $00, $00, $00 ; $CD10: 00 00 00 00 00 00 98 99 21 C0 9A 97 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $98, $9D, $21, $E0, $9E, $97, $00, $00, $00, $00 ; $CD20: 00 00 00 00 00 00 98 9D 21 E0 9E 97 00 00 00 00
  .byte $00, $00, $00, $00, $00, $00, $98, $9F, $22, $00, $A0, $A1, $A2, $A3, $A3, $A3 ; $CD30: 00 00 00 00 00 00 98 9F 22 00 A0 A1 A2 A3 A3 A3
  .byte $A3, $A3, $A3, $A3, $A3, $A4, $A5, $A6, $22, $20, $A7, $A8, $A9, $AA, $AB, $AB ; $CD40: A3 A3 A3 A3 A3 A4 A5 A6 22 20 A7 A8 A9 AA AB AB
  .byte $AB, $AB, $AB, $AB, $AC, $AD, $AE, $AF, $FF, $C4, $00, $36, $26, $17, $16, $07 ; $CD50: AB AB AB AB AC AD AE AF FF C4 00 36 26 17 16 07
  .byte $17, $7E, $7E, $7E, $7E, $7E, $7E, $7E, $7E, $7E, $7E, $7E, $7E, $7E, $40, $41 ; $CD60: 17 7E 7E 7E 7E 7E 7E 7E 7E 7E 7E 7E 7E 7E 40 41
  .byte $42, $7E, $7E, $7E, $7E, $7E, $7E, $7E, $43, $44, $45, $46, $47, $48, $7E, $7E ; $CD70: 42 7E 7E 7E 7E 7E 7E 7E 43 44 45 46 47 48 7E 7E
  .byte $7E, $7E, $49, $4A, $4B, $4C, $4D, $4E, $7E, $7E, $4F, $50, $51, $52, $53, $54 ; $CD80: 7E 7E 49 4A 4B 4C 4D 4E 7E 7E 4F 50 51 52 53 54
  .byte $55, $56, $7E, $7E, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $7E, $7E, $7E, $60 ; $CD90: 55 56 7E 7E 58 59 5A 5B 5C 5D 5E 5F 7E 7E 7E 60
  .byte $61, $62, $63, $64, $65, $66, $7E, $7E, $7E, $67, $68, $69, $6A, $6B, $6C, $6D ; $CDA0: 61 62 63 64 65 66 7E 7E 7E 67 68 69 6A 6B 6C 6D
  .byte $6E, $7E, $7E, $6F, $70, $71, $72, $73, $74, $75, $7E, $7E, $7E, $76, $77, $78 ; $CDB0: 6E 7E 7E 6F 70 71 72 73 74 75 7E 7E 7E 76 77 78
  .byte $79, $7A, $7B, $7C, $7D, $C9, $00, $36, $16, $26, $36, $16, $26, $01, $01, $01 ; $CDC0: 79 7A 7B 7C 7D C9 00 36 16 26 36 16 26 01 01 01
  .byte $01, $40, $41, $52, $53, $01, $01, $01, $01, $01, $01, $67, $6B, $00, $71, $01 ; $CDD0: 01 40 41 52 53 01 01 01 01 01 01 67 6B 00 71 01
  .byte $01, $01, $01, $01, $01, $00, $00, $72, $73, $42, $01, $01, $01, $01, $43, $00 ; $CDE0: 01 01 01 01 01 00 00 72 73 42 01 01 01 01 43 00
  .byte $00, $00, $44, $45, $46, $01, $47, $48, $49, $00, $00, $4A, $02, $02, $02, $4C ; $CDF0: 00 00 44 45 46 01 47 48 49 00 00 4A 02 02 02 4C
  .byte $4D, $4E, $4F, $50, $02, $02, $02, $02, $54, $55, $56, $57, $58, $59, $4B, $02 ; $CE00: 4D 4E 4F 50 02 02 02 02 54 55 56 57 58 59 4B 02
  .byte $5A, $5B, $5C, $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $03, $5D, $68 ; $CE10: 5A 5B 5C 5D 5E 5F 60 61 62 63 64 65 66 03 5D 68
  .byte $69, $6A, $03, $6C, $6D, $6E, $6F, $03, $03, $70, $03, $03, $03, $74, $51, $75 ; $CE20: 69 6A 03 6C 6D 6E 6F 03 03 70 03 03 03 74 51 75
  .byte $76, $E0, $00, $30, $10, $17, $16, $10, $17, $40, $40, $40, $40, $40, $40, $40 ; $CE30: 76 E0 00 30 10 17 16 10 17 40 40 40 40 40 40 40
  .byte $40, $40, $40, $41, $42, $40, $40, $40, $40, $40, $40, $40, $40, $43, $44, $45 ; $CE40: 40 40 40 41 42 40 40 40 40 40 40 40 40 43 44 45
  .byte $75, $75, $46, $47, $48, $40, $40, $53, $49, $4A, $4B, $53, $53, $53, $4C, $4D ; $CE50: 75 75 46 47 48 40 40 53 49 4A 4B 53 53 53 4C 4D
  .byte $4E, $53, $4F, $50, $51, $52, $53, $53, $53, $53, $53, $53, $53, $54, $55, $56 ; $CE60: 4E 53 4F 50 51 52 53 53 53 53 53 53 53 54 55 56
  .byte $57, $58, $53, $53, $53, $53, $53, $59, $5A, $5B, $5C, $5D, $5E, $5F, $60, $53 ; $CE70: 57 58 53 53 53 53 53 59 5A 5B 5C 5D 5E 5F 60 53
  .byte $53, $53, $61, $62, $63, $64, $65, $66, $67, $53, $53, $53, $68, $69, $6A, $6B ; $CE80: 53 53 61 62 63 64 65 66 67 53 53 53 68 69 6A 6B
  .byte $6C, $6D, $6E, $53, $53, $53, $6F, $70, $71, $72, $73, $74, $75, $C7, $C5, $30 ; $CE90: 6C 6D 6E 53 53 53 6F 70 71 72 73 74 75 C7 C5 30
  .byte $16, $36, $30, $16, $36, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41 ; $CEA0: 16 36 30 16 36 41 41 41 41 41 41 41 41 41 41 41
  .byte $40, $40, $40, $41, $41, $42, $43, $44, $41, $41, $40, $40, $40, $41, $41, $45 ; $CEB0: 40 40 40 41 41 42 43 44 41 41 40 40 40 41 41 45
  .byte $46, $47, $41, $41, $40, $40, $40, $48, $49, $40, $4A, $4B, $41, $4C, $4D, $40 ; $CEC0: 46 47 41 41 40 40 40 48 49 40 4A 4B 41 4C 4D 40
  .byte $40, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C ; $CED0: 40 4E 4F 50 51 52 53 54 55 56 57 58 59 5A 5B 5C
  .byte $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C ; $CEE0: 5D 5E 5F 60 61 62 63 64 65 66 67 68 69 6A 6B 6C
  .byte $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $41 ; $CEF0: 6D 6E 6F 70 71 72 73 74 75 76 77 78 79 7A 7B 41
  .byte $7C, $7D, $7E, $7F, $39, $3A, $3B, $3C, $3D, $B8, $00, $10, $36, $17, $10, $36 ; $CF00: 7C 7D 7E 7F 39 3A 3B 3C 3D B8 00 10 36 17 10 36
  .byte $17, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40 ; $CF10: 17 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40
  .byte $40, $42, $43, $40, $40, $40, $44, $40, $40, $40, $40, $45, $46, $47, $48, $00 ; $CF20: 40 42 43 40 40 40 44 40 40 40 40 45 46 47 48 00
  .byte $49, $4A, $00, $00, $00, $4B, $4C, $00, $4D, $00, $4E, $00, $4F, $00, $00, $00 ; $CF30: 49 4A 00 00 00 4B 4C 00 4D 00 4E 00 4F 00 00 00
  .byte $50, $51, $52, $00, $00, $00, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C ; $CF40: 50 51 52 00 00 00 53 54 55 56 57 58 59 5A 5B 5C
  .byte $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C ; $CF50: 5D 5E 5F 60 61 62 63 64 65 66 67 68 69 6A 6B 6C
  .byte $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $41, $41, $78, $79, $7A ; $CF60: 6D 6E 6F 70 71 72 73 74 75 76 77 41 41 78 79 7A
  .byte $7B, $41, $7C, $7D, $7E, $C3, $00, $31, $36, $17, $31, $36, $17, $41, $41, $42 ; $CF70: 7B 41 7C 7D 7E C3 00 31 36 17 31 36 17 41 41 42
  .byte $43, $44, $40, $40, $40, $40, $41, $41, $41, $45, $46, $40, $40, $40, $40, $40 ; $CF80: 43 44 40 40 40 40 41 41 41 45 46 40 40 40 40 40
  .byte $41, $41, $47, $48, $49, $40, $40, $40, $40, $40, $41, $4A, $4B, $4C, $4D, $40 ; $CF90: 41 41 47 48 49 40 40 40 40 40 41 4A 4B 4C 4D 40
  .byte $40, $40, $40, $40, $41, $4E, $4F, $50, $51, $52, $40, $40, $40, $40, $41, $53 ; $CFA0: 40 40 40 40 41 4E 4F 50 51 52 40 40 40 40 41 53
  .byte $41, $54, $55, $56, $57, $58, $40, $40, $41, $41, $41, $59, $5A, $5B, $5C, $5D ; $CFB0: 41 54 55 56 57 58 40 40 41 41 41 59 5A 5B 5C 5D
  .byte $5E, $41, $41, $41, $41, $5F, $60, $61, $62, $40, $63, $41, $41, $41, $41, $41 ; $CFC0: 5E 41 41 41 41 5F 60 61 62 40 63 41 41 41 41 41
  .byte $64, $65, $66, $67, $68, $69, $41, $41, $41, $41, $6A, $6B, $6C, $6D, $6E, $6F ; $CFD0: 64 65 66 67 68 69 41 41 41 41 6A 6B 6C 6D 6E 6F
  .byte $70, $CC, $00, $30, $21, $27, $16, $09, $36, $40, $40, $40, $41, $42, $43, $40 ; $CFE0: 70 CC 00 30 21 27 16 09 36 40 40 40 41 42 43 40
  .byte $40, $44, $45, $46, $46, $46, $46, $46, $46, $46, $46, $47, $48, $49, $4A, $4B ; $CFF0: 40 44 45 46 46 46 46 46 46 46 46 47 48 49 4A 4B
  .byte $4C, $4D, $4E, $4F, $40, $62, $40, $50, $51, $52, $53, $54, $62, $40, $55, $56 ; $D000: 4C 4D 4E 4F 40 62 40 50 51 52 53 54 62 40 55 56
  .byte $40, $57, $58, $59, $5A, $62, $40, $5B, $40, $5C, $5D, $5E, $5F, $62, $40, $60 ; $D010: 40 57 58 59 5A 62 40 5B 40 5C 5D 5E 5F 62 40 60
  .byte $40, $61, $62, $40, $63, $64, $65, $66, $6A, $67, $68, $69, $40, $40, $6A, $6B ; $D020: 40 61 62 40 63 64 65 66 6A 67 68 69 40 40 6A 6B
  .byte $6C, $6D, $6E, $6F, $70, $71, $6A, $72, $72, $73, $74, $75, $76, $77, $78, $62 ; $D030: 6C 6D 6E 6F 70 71 6A 72 72 73 74 75 76 77 78 62
  .byte $79, $7A, $7A, $7B, $7C, $6E, $6E, $62, $40, $40, $7D, $7E, $7F, $B6, $B7, $30 ; $D040: 79 7A 7A 7B 7C 6E 6E 62 40 40 7D 7E 7F B6 B7 30
  .byte $36, $17, $30, $36, $17, $41, $42, $43, $44, $41, $41, $45, $46, $47, $48, $41 ; $D050: 36 17 30 36 17 41 42 43 44 41 41 45 46 47 48 41
  .byte $49, $4A, $4B, $41, $41, $4C, $4D, $4E, $4F, $41, $50, $51, $52, $41, $41, $53 ; $D060: 49 4A 4B 41 41 4C 4D 4E 4F 41 50 51 52 41 41 53
  .byte $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $60, $61, $62, $63 ; $D070: 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F 60 61 62 63
  .byte $64, $65, $40, $40, $40, $66, $67, $68, $69, $6A, $6B, $6C, $40, $40, $40, $6D ; $D080: 64 65 40 40 40 66 67 68 69 6A 6B 6C 40 40 40 6D
  .byte $6E, $6F, $70, $71, $72, $40, $40, $40, $40, $41, $73, $74, $75, $76, $40, $40 ; $D090: 6E 6F 70 71 72 40 40 40 40 41 73 74 75 76 40 40
  .byte $40, $40, $40, $77, $78, $79, $7A, $7B, $40, $40, $7C, $7D, $7E, $41, $40, $7F ; $D0A0: 40 40 40 77 78 79 7A 7B 40 40 7C 7D 7E 41 40 7F
  .byte $00, $01, $40, $40, $02, $41, $41, $41, $40, $C8, $00, $16, $36, $17, $16, $36 ; $D0B0: 00 01 40 40 02 41 41 41 40 C8 00 16 36 17 16 36
  .byte $17, $40, $40, $40, $41, $41, $41, $41, $41, $42, $43, $41, $40, $40, $41, $41 ; $D0C0: 17 40 40 40 41 41 41 41 41 42 43 41 40 40 41 41
  .byte $44, $45, $46, $41, $41, $47, $48, $40, $40, $49, $4A, $4B, $4C, $4D, $41, $41 ; $D0D0: 44 45 46 41 41 47 48 40 40 49 4A 4B 4C 4D 41 41
  .byte $4E, $4F, $40, $40, $50, $51, $52, $53, $54, $55, $56, $57, $41, $40, $58, $59 ; $D0E0: 4E 4F 40 40 50 51 52 53 54 55 56 57 41 40 58 59
  .byte $5A, $5B, $41, $5C, $5D, $5E, $5F, $60, $61, $62, $63, $64, $41, $65, $66, $67 ; $D0F0: 5A 5B 41 5C 5D 5E 5F 60 61 62 63 64 41 65 66 67
  .byte $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77 ; $D100: 68 69 6A 6B 6C 6D 6E 6F 70 71 72 73 74 75 76 77
  .byte $78, $41, $40, $79, $40, $40, $7A, $40, $40, $40, $7B, $41, $40, $7C, $7D, $7E ; $D110: 78 41 40 79 40 40 7A 40 40 40 7B 41 40 7C 7D 7E
  .byte $7F, $40, $40, $40, $40, $D2, $00, $2A, $21, $16, $30, $25, $27, $40, $40, $40 ; $D120: 7F 40 40 40 40 D2 00 2A 21 16 30 25 27 40 40 40
  .byte $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $42 ; $D130: 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 42
  .byte $43, $44, $45, $46, $47, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $41, $4E, $4F ; $D140: 43 44 45 46 47 46 47 48 49 4A 4B 4C 4D 41 4E 4F
  .byte $50, $51, $52, $53, $54, $55, $56, $57, $41, $41, $41, $41, $41, $58, $59, $5A ; $D150: 50 51 52 53 54 55 56 57 41 41 41 41 41 58 59 5A
  .byte $41, $5B, $41, $41, $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68 ; $D160: 41 5B 41 41 5D 5E 5F 60 61 62 63 64 65 66 67 68
  .byte $41, $69, $6A, $41, $41, $6B, $41, $41, $6C, $6D, $6E, $6E, $70, $71, $72, $73 ; $D170: 41 69 6A 41 41 6B 41 41 6C 6D 6E 6E 70 71 72 73
  .byte $74, $75, $76, $41, $41, $77, $41, $41, $78, $79, $7A, $7B, $7C, $7D, $41, $7E ; $D180: 74 75 76 41 41 77 41 41 78 79 7A 7B 7C 7D 41 7E
  .byte $7F, $CE, $00, $10, $18, $26, $10, $18, $26, $41, $42, $43, $44, $45, $46, $47 ; $D190: 7F CE 00 10 18 26 10 18 26 41 42 43 44 45 46 47
  .byte $48, $49, $4A, $4B, $4C, $43, $4D, $4E, $40, $7D, $4F, $50, $51, $41, $42, $43 ; $D1A0: 48 49 4A 4B 4C 43 4D 4E 40 7D 4F 50 51 41 42 43
  .byte $44, $40, $40, $40, $4F, $52, $53, $41, $4C, $43, $4D, $40, $40, $40, $54, $55 ; $D1B0: 44 40 40 40 4F 52 53 41 4C 43 4D 40 40 40 54 55
  .byte $56, $41, $42, $58, $59, $40, $40, $40, $5A, $5B, $4A, $5C, $5D, $5E, $40, $40 ; $D1C0: 56 41 42 58 59 40 40 40 5A 5B 4A 5C 5D 5E 40 40
  .byte $40, $40, $5F, $60, $56, $61, $62, $63, $64, $40, $40, $65, $66, $67, $4A, $40 ; $D1D0: 40 40 5F 60 56 61 62 63 64 40 40 65 66 67 4A 40
  .byte $40, $40, $40, $40, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $40, $71, $72 ; $D1E0: 40 40 40 40 68 69 6A 6B 6C 6D 6E 6F 70 40 71 72
  .byte $73, $74, $75, $76, $77, $78, $79, $40, $40, $40, $7A, $7B, $7C, $CD, $00, $30 ; $D1F0: 73 74 75 76 77 78 79 40 40 40 7A 7B 7C CD 00 30
  .byte $17, $36, $30, $17, $36, $40, $41, $03, $03, $03, $03, $03, $03, $03, $03, $00 ; $D200: 17 36 30 17 36 40 41 03 03 03 03 03 03 03 03 00
  .byte $42, $03, $03, $03, $00, $00, $00, $03, $03, $43, $44, $03, $03, $03, $00, $00 ; $D210: 42 03 03 03 00 00 00 03 03 43 44 03 03 03 00 00
  .byte $00, $03, $03, $45, $46, $03, $03, $00, $00, $00, $00, $00, $03, $47, $48, $49 ; $D220: 00 03 03 45 46 03 03 00 00 00 00 00 03 47 48 49
  .byte $03, $00, $00, $00, $00, $00, $4B, $00, $00, $4C, $4D, $4E, $4A, $00, $02, $02 ; $D230: 03 00 00 00 00 00 4B 00 00 4C 4D 4E 4A 00 02 02
  .byte $4F, $00, $00, $4C, $50, $51, $52, $53, $02, $54, $55, $00, $00, $4C, $56, $57 ; $D240: 4F 00 00 4C 50 51 52 53 02 54 55 00 00 4C 56 57
  .byte $58, $59, $02, $54, $55, $00, $00, $4C, $00, $00, $00, $5B, $5C, $5D, $5E, $00 ; $D250: 58 59 02 54 55 00 00 4C 00 00 00 5B 5C 5D 5E 00
  .byte $00, $4C, $00, $00, $00, $00, $00, $5F, $02, $D9, $00, $30, $36, $17, $30, $36 ; $D260: 00 4C 00 00 00 00 00 5F 02 D9 00 30 36 17 30 36
  .byte $17, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41 ; $D270: 17 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41
  .byte $40, $40, $40, $41, $41, $42, $43, $44, $41, $41, $40, $40, $40, $41, $41, $45 ; $D280: 40 40 40 41 41 42 43 44 41 41 40 40 40 41 41 45
  .byte $46, $47, $41, $41, $40, $40, $40, $48, $41, $49, $4A, $4B, $41, $41, $40, $40 ; $D290: 46 47 41 41 40 40 40 48 41 49 4A 4B 41 41 40 40
  .byte $40, $4C, $4D, $4E, $40, $40, $4F, $41, $50, $51, $52, $53, $54, $55, $56, $57 ; $D2A0: 40 4C 4D 4E 40 40 4F 41 50 51 52 53 54 55 56 57
  .byte $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67 ; $D2B0: 58 59 5A 5B 5C 5D 5E 5F 60 61 62 63 64 65 66 67
  .byte $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77 ; $D2C0: 68 69 6A 6B 6C 6D 6E 6F 70 71 72 73 74 75 76 77
  .byte $78, $79, $7A, $7B, $7C, $DC, $00, $31, $21, $11, $30, $36, $18, $56, $57, $58 ; $D2D0: 78 79 7A 7B 7C DC 00 31 21 11 30 36 18 56 57 58
  .byte $59, $57, $59, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5B, $5D, $5A, $5B, $5C ; $D2E0: 59 57 59 56 57 58 59 5A 5B 5C 5D 5B 5D 5A 5B 5C
  .byte $5D, $5E, $5F, $60, $61, $5F, $61, $5E, $5F, $60, $61, $62, $62, $62, $62, $62 ; $D2F0: 5D 5E 5F 60 61 5F 61 5E 5F 60 61 62 62 62 62 62
  .byte $62, $62, $62, $62, $62, $63, $63, $63, $63, $63, $63, $63, $63, $63, $63, $64 ; $D300: 62 62 62 62 62 63 63 63 63 63 63 63 63 63 63 64
  .byte $64, $64, $64, $64, $64, $64, $64, $64, $64, $65, $65, $65, $65, $65, $65, $65 ; $D310: 64 64 64 64 64 64 64 64 64 65 65 65 65 65 65 65
  .byte $65, $65, $65, $66, $66, $66, $66, $66, $66, $66, $66, $66, $66, $67, $68, $67 ; $D320: 65 65 65 66 66 66 66 66 66 66 66 66 66 67 68 67
  .byte $68, $67, $68, $67, $68, $67, $68, $69, $6A, $69, $6A, $69, $6A, $69, $6A, $69 ; $D330: 68 67 68 67 68 67 68 69 6A 69 6A 69 6A 69 6A 69
  .byte $6A, $D4, $D5, $31, $36, $17, $31, $36, $17, $42, $40, $43, $44, $41, $41, $45 ; $D340: 6A D4 D5 31 36 17 31 36 17 42 40 43 44 41 41 45
  .byte $46, $47, $48, $40, $40, $40, $49, $4A, $41, $4B, $4C, $4C, $4C, $40, $4D, $4E ; $D350: 46 47 48 40 40 40 49 4A 41 4B 4C 4C 4C 40 4D 4E
  .byte $4F, $50, $41, $41, $41, $41, $41, $51, $40, $40, $40, $52, $53, $41, $00, $00 ; $D360: 4F 50 41 41 41 41 41 51 40 40 40 52 53 41 00 00
  .byte $00, $54, $55, $40, $56, $57, $58, $00, $00, $00, $00, $40, $59, $40, $40, $5A ; $D370: 00 54 55 40 56 57 58 00 00 00 00 40 59 40 40 5A
  .byte $5B, $00, $00, $00, $00, $5C, $5D, $5E, $5F, $60, $61, $00, $00, $00, $00, $62 ; $D380: 5B 00 00 00 00 5C 5D 5E 5F 60 61 00 00 00 00 62
  .byte $63, $41, $41, $64, $65, $66, $00, $00, $67, $68, $69, $6A, $6B, $00, $00, $6C ; $D390: 63 41 41 64 65 66 00 00 67 68 69 6A 6B 00 00 6C
  .byte $6D, $6E, $6F, $70, $71, $72, $73, $00, $00, $00, $74, $75, $76, $CF, $00, $30 ; $D3A0: 6D 6E 6F 70 71 72 73 00 00 00 74 75 76 CF 00 30
  .byte $16, $27, $30, $16, $27, $41, $42, $43, $44, $45, $46, $47, $40, $40, $40, $48 ; $D3B0: 16 27 30 16 27 41 42 43 44 45 46 47 40 40 40 48
  .byte $49, $4A, $4B, $4C, $4D, $4E, $40, $40, $40, $4F, $50, $51, $52, $53, $54, $55 ; $D3C0: 49 4A 4B 4C 4D 4E 40 40 40 4F 50 51 52 53 54 55
  .byte $40, $56, $57, $58, $59, $5A, $40, $40, $40, $40, $40, $5B, $5C, $58, $59, $5A ; $D3D0: 40 56 57 58 59 5A 40 40 40 40 40 5B 5C 58 59 5A
  .byte $5D, $5E, $5F, $60, $40, $40, $40, $58, $59, $5A, $61, $62, $63, $64, $40, $40 ; $D3E0: 5D 5E 5F 60 40 40 40 58 59 5A 61 62 63 64 40 40
  .byte $40, $58, $59, $5A, $40, $40, $65, $66, $40, $40, $40, $58, $59, $67, $40, $40 ; $D3F0: 40 58 59 5A 40 40 65 66 40 40 40 58 59 67 40 40
  .byte $40, $68, $69, $6A, $6B, $74, $75, $40, $40, $40, $40, $6C, $6D, $6E, $6F, $74 ; $D400: 40 68 69 6A 6B 74 75 40 40 40 40 6C 6D 6E 6F 74
  .byte $75, $40, $40, $40, $40, $70, $71, $72, $73, $D0, $00, $16, $26, $17, $35, $07 ; $D410: 75 40 40 40 40 70 71 72 73 D0 00 16 26 17 35 07
  .byte $06, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41 ; $D420: 06 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41
  .byte $41, $41, $41, $41, $41, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $43 ; $D430: 41 41 41 41 41 42 42 42 42 42 42 42 42 42 42 43
  .byte $43, $43, $43, $43, $43, $43, $43, $43, $44, $45, $46, $47, $48, $49, $4A, $4B ; $D440: 43 43 43 43 43 43 43 43 44 45 46 47 48 49 4A 4B
  .byte $4C, $4D, $4E, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $50, $54, $54 ; $D450: 4C 4D 4E 55 56 57 58 59 5A 5B 5C 5D 5E 50 54 54
  .byte $54, $54, $54, $54, $54, $54, $54, $54, $54, $51, $52, $53, $54, $54, $54, $54 ; $D460: 54 54 54 54 54 54 54 54 54 51 52 53 54 54 54 54
  .byte $54, $54, $54, $54, $54, $54, $54, $54, $54, $54, $54, $4F, $5F, $60, $54, $54 ; $D470: 54 54 54 54 54 54 54 54 54 54 54 4F 5F 60 54 54
  .byte $54, $54, $54, $54, $54, $D6, $00, $10, $17, $07, $36, $17, $07, $41, $42, $43 ; $D480: 54 54 54 54 54 D6 00 10 17 07 36 17 07 41 42 43
  .byte $44, $45, $46, $47, $48, $49, $4A, $51, $52, $53, $54, $55, $56, $57, $58, $59 ; $D490: 44 45 46 47 48 49 4A 51 52 53 54 55 56 57 58 59
  .byte $5A, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $78, $79, $40, $79, $79 ; $D4A0: 5A 61 62 63 64 65 66 67 68 69 6A 78 79 40 79 79
  .byte $78, $7A, $4B, $4C, $4D, $40, $40, $40, $40, $40, $40, $78, $5B, $5C, $5D, $40 ; $D4B0: 78 7A 4B 4C 4D 40 40 40 40 40 40 78 5B 5C 5D 40
  .byte $40, $40, $40, $40, $40, $60, $6B, $6C, $6D, $75, $76, $77, $40, $40, $40, $40 ; $D4C0: 40 40 40 40 40 60 6B 6C 6D 75 76 77 40 40 40 40
  .byte $7B, $7C, $7D, $40, $40, $40, $40, $40, $40, $40, $4E, $4F, $6E, $70, $71, $40 ; $D4D0: 7B 7C 7D 40 40 40 40 40 40 40 4E 4F 6E 70 71 40
  .byte $40, $40, $40, $40, $5E, $5F, $7E, $72, $73, $74, $40, $40, $40, $7B, $6F, $7F ; $D4E0: 40 40 40 40 5E 5F 7E 72 73 74 40 40 40 7B 6F 7F
  .byte $50, $D8, $00, $30, $36, $26, $30, $36, $26, $00, $00, $00, $00, $02, $02, $02 ; $D4F0: 50 D8 00 30 36 26 30 36 26 00 00 00 00 02 02 02
  .byte $02, $02, $02, $00, $00, $00, $00, $02, $02, $02, $02, $02, $02, $00, $00, $00 ; $D500: 02 02 02 00 00 00 00 02 02 02 02 02 02 00 00 00
  .byte $02, $02, $02, $42, $43, $44, $02, $00, $00, $00, $02, $02, $02, $45, $46, $47 ; $D510: 02 02 02 42 43 44 02 00 00 00 02 02 02 45 46 47
  .byte $02, $00, $00, $00, $01, $02, $02, $49, $4A, $4B, $02, $4C, $4C, $4D, $01, $02 ; $D520: 02 00 00 00 01 02 02 49 4A 4B 02 4C 4C 4D 01 02
  .byte $4E, $4F, $00, $00, $50, $4C, $4C, $53, $01, $02, $54, $55, $00, $00, $56, $4C ; $D530: 4E 4F 00 00 50 4C 4C 53 01 02 54 55 00 00 56 4C
  .byte $4C, $59, $01, $5A, $5B, $5C, $5D, $5E, $02, $4C, $4C, $62, $63, $64, $65, $66 ; $D540: 4C 59 01 5A 5B 5C 5D 5E 02 4C 4C 62 63 64 65 66
  .byte $67, $68, $69, $4C, $4C, $72, $73, $74, $75, $76, $77, $78, $79, $E6, $E7, $36 ; $D550: 67 68 69 4C 4C 72 73 74 75 76 77 78 79 E6 E7 36
  .byte $16, $10, $36, $16, $10, $80, $40, $41, $80, $80, $42, $80, $80, $43, $44, $80 ; $D560: 16 10 36 16 10 |80| 40 41 |80|80| 42 |80|80| 43 44 |80|  ; $80=End Sec2-5-6-8 (Sections 3-18: small fragments)
  .byte $45, $46, $80, $80, $47, $80, $80, $48, $49, $4A, $4B, $4C, $80, $80, $80, $80 ; $D570: 45 46 80 80 47 80 80 48 49 4A 4B 4C 80 80 80 80
  .byte $80, $4D, $4E, $4F, $50, $51, $52, $53, $80, $80, $54, $55, $56, $57, $58, $59 ; $D580: |80| 4D 4E 4F 50 51 52 53 |80|80| 54 55 56 57 58 59  ; $80=End Sec16-18; Sec19 starts $D58A
  .byte $5A, $5B, $5C, $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69 ; $D590: 5A 5B 5C 5D 5E 5F 60 61 62 63 64 65 66 67 68 69  ; Section 19 ($D58A-$D956): Secondary screen tilemap
  .byte $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79 ; $D5A0: 6A 6B 6C 6D 6E 6F 70 71 72 73 74 75 76 77 78 79
  .byte $7A, $7B, $7C, $7D, $7E, $7F, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09 ; $D5B0: 7A 7B 7C 7D 7E 7F 00 01 02 03 04 05 06 07 08 09
  .byte $09, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10, $DD, $00, $30, $36, $18, $30, $36 ; $D5C0: 09 09 0A 0B 0C 0D 0E 0F 10 DD 00 30 36 18 30 36
  .byte $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $41, $42, $43 ; $D5D0: 18 00 00 00 00 00 00 00 00 00 00 00 00 41 42 43
  .byte $44, $00, $00, $00, $00, $00, $45, $46, $47, $48, $49, $4A, $00, $00, $00, $4B ; $D5E0: 44 00 00 00 00 00 45 46 47 48 49 4A 00 00 00 4B
  .byte $4C, $4D, $4E, $4F, $50, $51, $00, $00, $00, $52, $53, $54, $55, $56, $57, $58 ; $D5F0: 4C 4D 4E 4F 50 51 00 00 00 52 53 54 55 56 57 58
  .byte $00, $00, $00, $00, $59, $5A, $5B, $5C, $5D, $5E, $5F, $00, $60, $40, $61, $62 ; $D600: 00 00 00 00 59 5A 5B 5C 5D 5E 5F 00 60 40 61 62
  .byte $63, $64, $65, $66, $67, $68, $69, $75, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71 ; $D610: 63 64 65 66 67 68 69 75 6A 6B 6C 6D 6E 6F 70 71
  .byte $72, $00, $73, $74, $6C, $76, $77, $78, $79, $7A, $7B, $00, $73, $74, $6C, $76 ; $D620: 72 00 73 74 6C 76 77 78 79 7A 7B 00 73 74 6C 76
  .byte $77, $7C, $7D, $7E, $7F, $E1, $E3, $36, $16, $31, $17, $07, $0F, $42, $43, $44 ; $D630: 77 7C 7D 7E 7F E1 E3 36 16 31 17 07 0F 42 43 44
  .byte $44, $45, $42, $42, $42, $43, $44, $46, $47, $48, $48, $49, $4A, $4B, $46, $47 ; $D640: 44 45 42 42 42 43 44 46 47 48 48 49 4A 4B 46 47
  .byte $48, $4C, $4D, $4E, $4F, $50, $51, $52, $4C, $4D, $4E, $53, $54, $55, $55, $56 ; $D650: 48 4C 4D 4E 4F 50 51 52 4C 4D 4E 53 54 55 55 56
  .byte $57, $58, $59, $5A, $55, $5B, $5C, $41, $5D, $5E, $5F, $60, $61, $62, $63, $64 ; $D660: 57 58 59 5A 55 5B 5C 41 5D 5E 5F 60 61 62 63 64
  .byte $65, $41, $41, $66, $67, $68, $41, $69, $6A, $41, $41, $41, $41, $41, $41, $41 ; $D670: 65 41 41 66 67 68 41 69 6A 41 41 41 41 41 41 41
  .byte $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41 ; $D680: 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41
  .byte $41, $41, $41, $41, $41, $41, $41, $41, $6B, $13, $14, $41, $41, $15, $16, $17 ; $D690: 41 41 41 41 41 41 41 41 6B 13 14 41 41 15 16 17
  .byte $18, $DE, $DC, $10, $36, $17, $10, $36, $17, $40, $40, $41, $41, $41, $41, $42 ; $D6A0: 18 DE DC 10 36 17 10 36 17 40 40 41 41 41 41 42
  .byte $43, $44, $41, $40, $40, $40, $40, $41, $41, $45, $46, $47, $48, $40, $40, $40 ; $D6B0: 43 44 41 40 40 40 40 41 41 45 46 47 48 40 40 40
  .byte $40, $41, $41, $49, $40, $4A, $4B, $40, $40, $40, $40, $41, $4C, $4D, $4E, $4F ; $D6C0: 40 41 41 49 40 4A 4B 40 40 40 40 41 4C 4D 4E 4F
  .byte $50, $40, $40, $40, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C ; $D6D0: 50 40 40 40 51 52 53 54 55 56 57 58 59 5A 5B 5C
  .byte $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C ; $D6E0: 5D 5E 5F 60 61 62 63 64 65 66 67 68 69 6A 6B 6C
  .byte $6D, $6E, $6F, $70, $71, $72, $73, $00, $01, $02, $03, $04, $05, $06, $07, $08 ; $D6F0: 6D 6E 6F 70 71 72 73 00 01 02 03 04 05 06 07 08
  .byte $09, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $DF, $00, $30 ; $D700: 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 DF 00 30
  .byte $36, $17, $30, $36, $17, $02, $02, $02, $02, $02, $02, $02, $42, $43, $43, $02 ; $D710: 36 17 30 36 17 02 02 02 02 02 02 02 42 43 43 02
  .byte $02, $42, $43, $43, $43, $44, $45, $46, $46, $02, $47, $45, $46, $46, $46, $48 ; $D720: 02 42 43 43 43 44 45 46 46 02 47 45 46 46 46 48
  .byte $49, $4A, $4B, $4C, $4D, $49, $4A, $4E, $4A, $4F, $50, $51, $00, $52, $53, $50 ; $D730: 49 4A 4B 4C 4D 49 4A 4E 4A 4F 50 51 00 52 53 50
  .byte $51, $00, $51, $54, $00, $00, $00, $00, $55, $00, $56, $57, $00, $58, $00, $00 ; $D740: 51 00 51 54 00 00 00 00 55 00 56 57 00 58 00 00
  .byte $00, $59, $5A, $5B, $00, $00, $00, $5C, $00, $5D, $5E, $5F, $00, $60, $61, $62 ; $D750: 00 59 5A 5B 00 00 00 5C 00 5D 5E 5F 00 60 61 62
  .byte $00, $00, $63, $00, $64, $65, $66, $67, $68, $00, $00, $00, $00, $00, $69, $6A ; $D760: 00 00 63 00 64 65 66 67 68 00 00 00 00 00 69 6A
  .byte $6B, $6C, $00, $00, $00, $00, $00, $6D, $6E, $B5, $00, $30, $36, $17, $30, $36 ; $D770: 6B 6C 00 00 00 00 00 6D 6E B5 00 30 36 17 30 36
  .byte $17, $00, $00, $00, $00, $00, $00, $00, $53, $54, $55, $40, $41, $00, $00, $00 ; $D780: 17 00 00 00 00 00 00 00 53 54 55 40 41 00 00 00
  .byte $00, $00, $63, $64, $65, $50, $51, $52, $00, $00, $00, $00, $73, $74, $75, $60 ; $D790: 00 00 63 64 65 50 51 52 00 00 00 00 73 74 75 60
  .byte $61, $62, $00, $00, $00, $00, $45, $00, $46, $70, $00, $72, $00, $00, $00, $00 ; $D7A0: 61 62 00 00 00 00 45 00 46 70 00 72 00 00 00 00
  .byte $56, $66, $76, $42, $71, $43, $44, $00, $00, $48, $49, $4A, $4B, $00, $00, $00 ; $D7B0: 56 66 76 42 71 43 44 00 00 48 49 4A 4B 00 00 00
  .byte $00, $00, $57, $58, $59, $5A, $5B, $00, $00, $00, $00, $00, $67, $68, $69, $6A ; $D7C0: 00 00 57 58 59 5A 5B 00 00 00 00 00 67 68 69 6A
  .byte $6B, $00, $00, $00, $00, $00, $77, $78, $79, $7A, $7B, $00, $00, $00, $00, $00 ; $D7D0: 6B 00 00 00 00 00 77 78 79 7A 7B 00 00 00 00 00
  .byte $4C, $4D, $4E, $4F, $47, $D5, $00, $10, $36, $17, $10, $36, $17, $41, $40, $40 ; $D7E0: 4C 4D 4E 4F 47 D5 00 10 36 17 10 36 17 41 40 40
  .byte $41, $42, $43, $41, $41, $41, $41, $44, $40, $40, $40, $45, $46, $47, $48, $41 ; $D7F0: 41 42 43 41 41 41 41 44 40 40 40 45 46 47 48 41
  .byte $41, $49, $41, $40, $40, $4A, $4B, $4C, $4D, $4E, $41, $4F, $50, $40, $40, $40 ; $D800: 41 49 41 40 40 4A 4B 4C 4D 4E 41 4F 50 40 40 40
  .byte $40, $40, $51, $52, $53, $54, $55, $40, $40, $40, $40, $40, $56, $57, $58, $59 ; $D810: 40 40 51 52 53 54 55 40 40 40 40 40 56 57 58 59
  .byte $5A, $40, $40, $40, $40, $40, $5B, $5C, $5D, $5E, $5F, $60, $40, $40, $40, $61 ; $D820: 5A 40 40 40 40 40 5B 5C 5D 5E 5F 60 40 40 40 61
  .byte $62, $63, $64, $65, $66, $40, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70 ; $D830: 62 63 64 65 66 40 67 68 69 6A 6B 6C 6D 6E 6F 70
  .byte $71, $72, $73, $40, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $40, $7D, $7E ; $D840: 71 72 73 40 74 75 76 77 78 79 7A 7B 7C 40 7D 7E
  .byte $7F, $DC, $00, $30, $31, $21, $0F, $10, $15, $56, $57, $58, $59, $57, $59, $56 ; $D850: 7F DC 00 30 31 21 0F 10 15 56 57 58 59 57 59 56
  .byte $57, $58, $59, $5A, $5B, $5C, $5D, $5B, $5D, $5A, $5B, $5C, $5D, $5E, $5F, $60 ; $D860: 57 58 59 5A 5B 5C 5D 5B 5D 5A 5B 5C 5D 5E 5F 60
  .byte $61, $5F, $61, $5E, $5F, $60, $61, $62, $62, $62, $62, $62, $62, $62, $62, $62 ; $D870: 61 5F 61 5E 5F 60 61 62 62 62 62 62 62 62 62 62
  .byte $62, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E ; $D880: 62 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E
  .byte $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6E, $6F ; $D890: 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6E 6F
  .byte $70, $71, $6F, $70, $71, $6F, $70, $71, $6F, $6B, $6C, $6D, $6B, $6C, $6D, $6B ; $D8A0: 70 71 6F 70 71 6F 70 71 6F 6B 6C 6D 6B 6C 6D 6B
  .byte $6C, $6D, $6B, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $E3, $00, $36 ; $D8B0: 6C 6D 6B 01 01 01 01 01 01 01 01 01 01 E3 00 36
  .byte $27, $17, $36, $27, $17, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01 ; $D8C0: 27 17 36 27 17 01 01 01 01 01 01 01 01 01 01 01
  .byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01 ; $D8D0: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $42, $42, $42 ; $D8E0: 01 01 01 01 01 01 01 01 01 01 01 01 01 42 42 42
  .byte $42, $42, $42, $42, $42, $42, $42, $41, $61, $62, $63, $41, $41, $41, $41, $41 ; $D8F0: 42 42 42 42 42 42 42 41 61 62 63 41 41 41 41 41
  .byte $41, $43, $71, $72, $73, $74, $43, $43, $43, $43, $43, $44, $00, $00, $00, $66 ; $D900: 41 43 71 72 73 74 43 43 43 43 43 44 00 00 00 66
  .byte $67, $68, $45, $46, $47, $6A, $70, $00, $75, $76, $77, $48, $49, $4A, $4B, $79 ; $D910: 67 68 45 46 47 6A 70 00 75 76 77 48 49 4A 4B 79
  .byte $7A, $7B, $7C, $7D, $7E, $4C, $4D, $51, $52, $BD, $BE, $20, $17, $36, $20, $17 ; $D920: 7A 7B 7C 7D 7E 4C 4D 51 52 BD BE 20 17 36 20 17
  .byte $36, $70, $71, $72, $73, $74, $75, $76, $77, $78, $70, $70, $71, $72, $73, $74 ; $D930: 36 70 71 72 73 74 75 76 77 78 70 70 71 72 73 74
  .byte $75, $76, $77, $78, $79, $70, $7A, $7B, $7C, $7D, $7E, $7F, $00, $01, $02, $03 ; $D940: 75 76 77 78 79 70 7A 7B 7C 7D 7E 7F 00 01 02 03
  .byte $03, $04, $05, $06, $07, $08, $80, $80, $09, $39, $39, $0A, $0B, $0C, $0D, $0E ; $D950: 03 04 05 06 07 08 |80|80| 09 39 39 0A 0B 0C 0D 0E  ; $80=End Sec19-20
  .byte $80, $80, $0F, $10, $11, $12, $13, $14, $15, $16, $80, $80, $17, $18, $19, $1A ; $D960: |80|80| 0F 10 11 12 13 14 15 16 |80|80| 17 18 19 1A  ; $80=End Sec21-24; Sec25 starts $D96C
  .byte $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A ; $D970: 1B 1C 1D 1E 1F 20 21 22 23 24 25 26 27 28 29 2A  ; Section 25 ($D96C-$DBB0): Final tilemap section
  .byte $2B, $39, $2C, $2D, $2E, $2F, $30, $31, $32, $39, $39, $39, $33, $34, $35, $36 ; $D980: 2B 39 2C 2D 2E 2F 30 31 32 39 39 39 33 34 35 36
  .byte $37, $38, $39, $39, $39, $D3, $00, $10, $17, $11, $10, $17, $11, $42, $43, $41 ; $D990: 37 38 39 39 39 D3 00 10 17 11 10 17 11 42 43 41
  .byte $44, $45, $46, $47, $41, $41, $48, $49, $4A, $41, $4B, $4C, $4D, $4E, $4F, $50 ; $D9A0: 44 45 46 47 41 41 48 49 4A 41 4B 4C 4D 4E 4F 50
  .byte $51, $52, $53, $54, $55, $56, $57, $40, $40, $58, $59, $5A, $5B, $40, $5C, $5D ; $D9B0: 51 52 53 54 55 56 57 40 40 58 59 5A 5B 40 5C 5D
  .byte $40, $40, $40, $5E, $5F, $60, $61, $62, $63, $64, $40, $65, $66, $67, $68, $69 ; $D9C0: 40 40 40 5E 5F 60 61 62 63 64 40 65 66 67 68 69
  .byte $6A, $6B, $6C, $40, $6E, $40, $40, $6F, $70, $40, $6E, $40, $6E, $71, $72, $73 ; $D9D0: 6A 6B 6C 40 6E 40 40 6F 70 40 6E 40 6E 71 72 73
  .byte $40, $40, $40, $6E, $40, $6E, $40, $74, $75, $75, $76, $77, $78, $40, $6E, $40 ; $D9E0: 40 40 40 6E 40 6E 40 74 75 75 76 77 78 40 6E 40
  .byte $6E, $40, $75, $75, $79, $7A, $7B, $6E, $40, $6E, $6E, $40, $6D, $7C, $7D, $7E ; $D9F0: 6E 40 75 75 79 7A 7B 6E 40 6E 6E 40 6D 7C 7D 7E
  .byte $7F, $CA, $CB, $16, $36, $17, $16, $36, $17, $71, $72, $73, $74, $74, $74, $74 ; $DA00: 7F CA CB 16 36 17 16 36 17 71 72 73 74 74 74 74
  .byte $75, $76, $74, $77, $78, $79, $74, $74, $74, $74, $7A, $7B, $7C, $7D, $7E, $74 ; $DA10: 75 76 74 77 78 79 74 74 74 74 7A 7B 7C 7D 7E 74
  .byte $7F, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $74 ; $DA20: 7F 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 74
  .byte $0E, $0F, $10, $11, $12, $3D, $3D, $13, $14, $15, $74, $16, $17, $18, $19, $3D ; $DA30: 0E 0F 10 11 12 3D 3D 13 14 15 74 16 17 18 19 3D
  .byte $3D, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28 ; $DA40: 3D 1A 1B 1C 1D 1E 1F 20 21 22 23 24 25 26 27 28
  .byte $29, $2A, $2B, $2C, $2D, $2E, $2F, $3D, $3D, $30, $3D, $3D, $31, $32, $33, $34 ; $DA50: 29 2A 2B 2C 2D 2E 2F 3D 3D 30 3D 3D 31 32 33 34
  .byte $35, $3D, $3D, $3D, $3D, $3D, $36, $37, $38, $39, $3A, $3B, $3C, $BC, $00, $36 ; $DA60: 35 3D 3D 3D 3D 3D 36 37 38 39 3A 3B 3C BC 00 36
  .byte $27, $17, $36, $27, $17, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $00 ; $DA70: 27 17 36 27 17 44 44 44 44 44 44 44 44 44 44 00
  .byte $00, $01, $00, $00, $00, $45, $01, $46, $47, $00, $00, $01, $00, $00, $00, $48 ; $DA80: 00 01 00 00 00 45 01 46 47 00 00 01 00 00 00 48
  .byte $49, $4A, $4B, $00, $00, $00, $00, $00, $00, $4C, $4D, $4E, $4F, $50, $00, $00 ; $DA90: 49 4A 4B 00 00 00 00 00 00 4C 4D 4E 4F 50 00 00
  .byte $00, $00, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E ; $DAA0: 00 00 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E
  .byte $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $01 ; $DAB0: 5F 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 01
  .byte $6E, $6F, $70, $01, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C ; $DAC0: 6E 6F 70 01 71 72 73 74 75 76 77 78 79 7A 7B 7C
  .byte $7D, $7C, $7D, $7E, $7F, $40, $41, $42, $43, $B6, $B7, $30, $36, $17, $30, $36 ; $DAD0: 7D 7C 7D 7E 7F 40 41 42 43 B6 B7 30 36 17 30 36
  .byte $17, $41, $42, $43, $44, $41, $41, $41, $41, $41, $41, $41, $49, $4A, $4B, $41 ; $DAE0: 17 41 42 43 44 41 41 41 41 41 41 41 49 4A 4B 41
  .byte $41, $41, $41, $41, $41, $41, $50, $51, $52, $41, $41, $41, $41, $41, $41, $57 ; $DAF0: 41 41 41 41 41 41 50 51 52 41 41 41 41 41 41 57
  .byte $58, $59, $5A, $5B, $5C, $41, $41, $41, $41, $61, $62, $63, $64, $65, $40, $40 ; $DB00: 58 59 5A 5B 5C 41 41 41 41 61 62 63 64 65 40 40
  .byte $40, $41, $41, $68, $69, $6A, $6B, $6C, $40, $40, $40, $41, $41, $6F, $70, $71 ; $DB10: 40 41 41 68 69 6A 6B 6C 40 40 40 41 41 6F 70 71
  .byte $72, $40, $40, $40, $40, $41, $73, $74, $75, $76, $40, $40, $40, $40, $40, $77 ; $DB20: 72 40 40 40 40 41 73 74 75 76 40 40 40 40 40 77
  .byte $78, $79, $7A, $7B, $40, $40, $7C, $7D, $7E, $41, $40, $7F, $00, $01, $40, $40 ; $DB30: 78 79 7A 7B 40 40 7C 7D 7E 41 40 7F 00 01 40 40
  .byte $02, $41, $41, $41, $40, $AA, $00, $36, $10, $16, $10, $06, $17, $40, $41, $42 ; $DB40: 02 41 41 41 40 AA 00 36 10 16 10 06 17 40 41 42
  .byte $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52 ; $DB50: 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F 50 51 52
  .byte $53, $00, $54, $55, $56, $72, $72, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $72 ; $DB60: 53 00 54 55 56 72 72 57 58 59 5A 5B 5C 5D 5E 72
  .byte $72, $5F, $60, $61, $62, $63, $64, $65, $72, $00, $00, $72, $66, $67, $68, $69 ; $DB70: 72 5F 60 61 62 63 64 65 72 00 00 72 66 67 68 69
  .byte $6A, $72, $72, $00, $00, $72, $6B, $6C, $6D, $6E, $6F, $72, $00, $00, $00, $72 ; $DB80: 6A 72 72 00 00 72 6B 6C 6D 6E 6F 72 00 00 00 72
  .byte $72, $72, $72, $70, $71, $72, $00, $00, $00, $00, $72, $72, $72, $72, $72, $72 ; $DB90: 72 72 72 70 71 72 00 00 00 00 72 72 72 72 72 72
  .byte $00, $00, $00, $00, $72, $72, $72, $72, $72, $00, $00, $00, $00, $00, $00, $72 ; $DBA0: 00 00 00 00 72 72 72 72 72 00 00 00 00 00 00 72
  .byte $72                                                              ; $DBB0: 72  ; End of MenuTilemapStream (last byte of Section 25)

;===============================================================================
; $DBB1: LoadScenarioData - copy 32 bytes from scenario table to $0100
;===============================================================================
.proc LoadScenarioData
LoadScenarioData:
  LDA $0000                                             ; $DBB1: AD 00 00
  ASL                                                   ; $DBB4: 0A
  TAY                                                   ; $DBB5: A8
  LDA ScenarioDataTable,Y                                 ; $DBB6: B9 CF DB
  STA $000A                                             ; $DBB9: 8D 0A 00
  LDA ScenarioDataTable+1,Y                               ; $DBBC: B9 D0 DB
  STA $000B                                             ; $DBBF: 8D 0B 00
  LDY #$00                                              ; $DBC2: A0 00
@copy_loop:
  LDA ($0A),Y                                           ; $DBC4: B1 0A
  STA $0100,Y                                           ; $DBC6: 99 00 01
  INY                                                   ; $DBC9: C8
  CPY #$20                                              ; $DBCA: C0 20
  BCC @copy_loop                                        ; $DBCC: 90 F6
  RTS                                                   ; $DBCE: 60
.endproc

; ScenarioDataTable - 16-bit pointer table for scenario data records
ScenarioDataTable:

;===============================================================================
; $DBCF-$DD8A: Data block (ScenarioDataTable / kingdom defaults)
;===============================================================================
  .byte $EB, $DB, $0B, $DC, $2B, $DC, $4B, $DC, $6B, $DC, $8B, $DC, $AB, $DC, $CB, $DC ; $DBCF: EB DB 0B DC 2B DC 4B DC 6B DC 8B DC AB DC CB DC
  .byte $EB, $DC, $EB, $DC, $0B, $DD, $2B, $DD, $4B, $DD, $6B, $DD, $0F, $12, $1A, $2A ; $DBDF: EB DC EB DC 0B DD 2B DD 4B DD 6B DD 0F 12 1A 2A
  .byte $0F, $27, $16, $2A, $0F, $36, $30, $16, $0F, $36, $30, $16, $0F, $0F, $20, $16 ; $DBEF: 0F 27 16 2A 0F 36 30 16 0F 36 30 16 0F 0F 20 16
  .byte $0F, $0F, $2B, $28, $0F, $36, $30, $16, $0F, $20, $27, $17, $0F, $27, $19, $0A ; $DBFF: 0F 0F 2B 28 0F 36 30 16 0F 20 27 17 0F 27 19 0A
  .byte $0F, $19, $12, $02, $0F, $36, $20, $16, $0F, $20, $20, $20, $0F, $0F, $20, $16 ; $DC0F: 0F 19 12 02 0F 36 20 16 0F 20 20 20 0F 0F 20 16
  .byte $0F, $0F, $27, $17, $0F, $20, $27, $17, $0F, $20, $27, $17, $0F, $29, $1A, $09 ; $DC1F: 0F 0F 27 17 0F 20 27 17 0F 20 27 17 0F 29 1A 09
  .byte $0F, $29, $36, $06, $0F, $36, $20, $16, $0F, $29, $36, $14, $0F, $0F, $36, $06 ; $DC2F: 0F 29 36 06 0F 36 20 16 0F 29 36 14 0F 0F 36 06
  .byte $0F, $0F, $36, $14, $0F, $0F, $20, $16, $0F, $20, $27, $17, $0F, $27, $17, $18 ; $DC3F: 0F 0F 36 14 0F 0F 20 16 0F 20 27 17 0F 27 17 18
  .byte $0F, $27, $36, $06, $0F, $36, $20, $16, $0F, $27, $36, $14, $0F, $0F, $36, $06 ; $DC4F: 0F 27 36 06 0F 36 20 16 0F 27 36 14 0F 0F 36 06
  .byte $0F, $0F, $36, $14, $0F, $0F, $20, $16, $0F, $20, $27, $17, $0F, $37, $29, $19 ; $DC5F: 0F 0F 36 14 0F 0F 20 16 0F 20 27 17 0F 37 29 19
  .byte $0F, $37, $36, $06, $0F, $36, $20, $16, $0F, $37, $36, $14, $0F, $0F, $36, $06 ; $DC6F: 0F 37 36 06 0F 36 20 16 0F 37 36 14 0F 0F 36 06
  .byte $0F, $0F, $36, $14, $0F, $0F, $20, $16, $0F, $20, $27, $17, $0F, $21, $20, $12 ; $DC7F: 0F 0F 36 14 0F 0F 20 16 0F 20 27 17 0F 21 20 12
  .byte $0F, $21, $36, $06, $0F, $36, $20, $16, $0F, $21, $36, $14, $0F, $0F, $36, $06 ; $DC8F: 0F 21 36 06 0F 36 20 16 0F 21 36 14 0F 0F 36 06
  .byte $0F, $0F, $36, $14, $0F, $0F, $20, $16, $0F, $20, $27, $17, $0F, $39, $29, $19 ; $DC9F: 0F 0F 36 14 0F 0F 20 16 0F 20 27 17 0F 39 29 19
  .byte $0F, $39, $36, $06, $0F, $36, $20, $16, $0F, $39, $36, $14, $0F, $0F, $36, $06 ; $DCAF: 0F 39 36 06 0F 36 20 16 0F 39 36 14 0F 0F 36 06
  .byte $0F, $0F, $36, $14, $0F, $0F, $20, $16, $0F, $20, $27, $17, $0F, $10, $00, $20 ; $DCBF: 0F 0F 36 14 0F 0F 20 16 0F 20 27 17 0F 10 00 20
  .byte $0F, $10, $36, $06, $0F, $36, $20, $16, $0F, $10, $36, $14, $0F, $0F, $36, $06 ; $DCCF: 0F 10 36 06 0F 36 20 16 0F 10 36 14 0F 0F 36 06
  .byte $0F, $0F, $36, $14, $0F, $0F, $20, $16, $0F, $20, $27, $17, $0F, $29, $1A, $09 ; $DCDF: 0F 0F 36 14 0F 0F 20 16 0F 20 27 17 0F 29 1A 09
  .byte $0F, $29, $36, $06, $0F, $36, $20, $16, $0F, $29, $36, $14, $0F, $0F, $36, $06 ; $DCEF: 0F 29 36 06 0F 36 20 16 0F 29 36 14 0F 0F 36 06
  .byte $0F, $0F, $36, $14, $0F, $0F, $20, $16, $0F, $20, $27, $17, $0F, $17, $18, $36 ; $DCFF: 0F 0F 36 14 0F 0F 20 16 0F 20 27 17 0F 17 18 36
  .byte $0F, $17, $20, $36, $0F, $36, $20, $16, $0F, $17, $16, $36, $0F, $17, $18, $36 ; $DD0F: 0F 17 20 36 0F 36 20 16 0F 17 16 36 0F 17 18 36
  .byte $0F, $17, $20, $36, $0F, $17, $16, $36, $0F, $20, $27, $17, $0F, $10, $0F, $00 ; $DD1F: 0F 17 20 36 0F 17 16 36 0F 20 27 17 0F 10 0F 00
  .byte $0F, $16, $0F, $30, $0F, $17, $07, $21, $0F, $17, $10, $21, $0F, $0F, $30, $0A ; $DD2F: 0F 16 0F 30 0F 17 07 21 0F 17 10 21 0F 0F 30 0A
  .byte $0F, $16, $28, $0F, $0F, $30, $30, $30, $0F, $06, $07, $21, $0F, $36, $30, $16 ; $DD3F: 0F 16 28 0F 0F 30 30 30 0F 06 07 21 0F 36 30 16
  .byte $0F, $27, $16, $2A, $0F, $36, $30, $16, $0F, $36, $30, $16, $0F, $0F, $20, $16 ; $DD4F: 0F 27 16 2A 0F 36 30 16 0F 36 30 16 0F 0F 20 16
  .byte $0F, $0F, $2B, $28, $0F, $36, $30, $16, $0F, $20, $27, $17, $0F, $0F, $0F, $0F ; $DD5F: 0F 0F 2B 28 0F 36 30 16 0F 20 27 17 0F 0F 0F 0F
  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F ; $DD6F: 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F
  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F       ; $DD7F: 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F

.proc SramInit
  LDA $6F43                                             ; $DD8B: AD 43 6F
  PHA                                                   ; $DD8E: 48
  LDA #$60                                              ; $DD8F: A9 60
  STA $0001                                             ; $DD91: 8D 01 00
  LDA #$00                                              ; $DD94: A9 00
  STA $0000                                             ; $DD96: 8D 00 00
  TAY                                                   ; $DD99: A8
@ClearLoop:
  STA ($00),Y                                           ; $DD9A: 91 00
  INY                                                   ; $DD9C: C8
  BNE @ClearLoop                                        ; $DD9D: D0 FB
  INC $0001                                             ; $DD9F: EE 01 00
  LDX $0001                                             ; $DDA2: AE 01 00
  CPX #$70                                              ; $DDA5: E0 70
  BCC @ClearLoop                                        ; $DDA7: 90 F1
  PLA                                                   ; $DDA9: 68
  STA $6F43                                             ; $DDAA: 8D 43 6F
@RandLoop:
  JSR B1F_RandomByte                                    ; $DDAD: 20 7A E8
  AND #$07                                              ; $DDB0: 29 07
  CMP #$05                                              ; $DDB2: C9 05
  BCS @RandLoop                                         ; $DDB4: B0 F7
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
  STA $0003                                             ; $DDE3: 8D 03 00
  LDY #$00                                              ; $DDE6: A0 00
  LDX #$00                                              ; $DDE8: A2 00
  STX $0004                                             ; $DDEA: 8E 04 00
@Copy1Loop:
  LDA ($00),Y                                           ; $DDED: B1 00
  STA ($02),Y                                           ; $DDEF: 91 02
  INC $0000                                             ; $DDF1: EE 00 00
  BNE @Copy1PageOk                                      ; $DDF4: D0 03
  INC $0001                                             ; $DDF6: EE 01 00
@Copy1PageOk:
  INC $0002                                             ; $DDF9: EE 02 00
  BNE @Copy1HiOk                                        ; $DDFC: D0 03
  INC $0003                                             ; $DDFE: EE 03 00
@Copy1HiOk:
  INX                                                   ; $DE01: E8
  BNE @Copy1BankOk                                      ; $DE02: D0 03
  INC $0004                                             ; $DE04: EE 04 00
@Copy1BankOk:
  LDA $0004                                             ; $DE07: AD 04 00
  CMP #$03                                              ; $DE0A: C9 03
  BCC @Copy1Loop                                        ; $DE0C: 90 DF
  CPX #$C0                                              ; $DE0E: E0 C0
  BCC @Copy1Loop                                        ; $DE10: 90 DB
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
@Copy2Loop:
  LDA ($00),Y                                           ; $DE32: B1 00
  STA ($02),Y                                           ; $DE34: 91 02
  INC $0000                                             ; $DE36: EE 00 00
  BNE @Copy2PageOk                                      ; $DE39: D0 03
  INC $0001                                             ; $DE3B: EE 01 00
@Copy2PageOk:
  INC $0002                                             ; $DE3E: EE 02 00
  BNE @Copy2HiOk                                        ; $DE41: D0 03
  INC $0003                                             ; $DE43: EE 03 00
@Copy2HiOk:
  INX                                                   ; $DE46: E8
  BNE @Copy2BankOk                                      ; $DE47: D0 03
  INC $0004                                             ; $DE49: EE 04 00
@Copy2BankOk:
  LDA $0004                                             ; $DE4C: AD 04 00
  CMP #$0B                                              ; $DE4F: C9 0B
  BCC @Copy2Loop                                        ; $DE51: 90 DF
  CPX #$40                                              ; $DE53: E0 40
  BCC @Copy2Loop                                        ; $DE55: 90 DB
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
.endproc

;===============================================================================
; $DE7E: OfficerParamDisp
; Copies 48 bytes of officer parameter data from bank $21 table to $00AE.
; Input: A = officer index
;===============================================================================
.proc OfficerParamDisp
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
@CopyLoop:
  LDA ($02),Y                                           ; $DEAE: B1 02
  STA $00AE,Y                                           ; $DEB0: 99 AE 00
  INY                                                   ; $DEB3: C8
  CPY #$30                                              ; $DEB4: C0 30
  BCC @CopyLoop                                         ; $DEB6: 90 F6
  RTS                                                   ; $DEB8: 60
.endproc

;===============================================================================
; $DEB9: OfficerRecLookup
; Assembles a 14-byte officer record from column-oriented tables into $0061-$0074.
; Input: A = officer index
;===============================================================================
.proc OfficerRecLookup
  ; Proc-local RAM variables
  officer_lookup_x  = $0072  ; officer lookup X coord
  officer_lookup_y  = $0073  ; officer lookup Y coord
  scene_file_ref    = $0074  ; scene file reference
  STA $0000                                             ; $DEB9: 8D 00 00
  TAX                                                   ; $DEBC: AA
  ASL                                                   ; $DEBD: 0A
  ASL                                                   ; $DEBE: 0A
  CLC                                                   ; $DEBF: 18
  ADC $0000                                             ; $DEC0: 6D 00 00
  ASL                                                   ; $DEC3: 0A
  TAY                                                   ; $DEC4: A8
  LDA OfficerRecordTable,Y                              ; $DEC5: B9 1A DF
  STA $0068                                             ; $DEC8: 8D 68 00
  LDA OfficerRecordTable+1,Y                            ; $DECB: B9 1B DF
  STA $0069                                             ; $DECE: 8D 69 00
  LDA OfficerRecordTable+2,Y                            ; $DED1: B9 1C DF
  STA $006A                                             ; $DED4: 8D 6A 00
  LDA OfficerRecordTable+3,Y                            ; $DED7: B9 1D DF
  STA $006B                                             ; $DEDA: 8D 6B 00
  LDA OfficerRecordTable+4,Y                            ; $DEDD: B9 1E DF
  STA $006C                                             ; $DEE0: 8D 6C 00
  LDA OfficerRecordTable+5,Y                            ; $DEE3: B9 1F DF
  STA $006D                                             ; $DEE6: 8D 6D 00
  LDA OfficerRecordTable+6,Y                            ; $DEE9: B9 20 DF
  STA $006E                                             ; $DEEC: 8D 6E 00
  LDA OfficerRecordTable+7,Y                            ; $DEEF: B9 21 DF
  STA $006F                                             ; $DEF2: 8D 6F 00
  LDA OfficerRecordTable+8,Y                            ; $DEF5: B9 22 DF
  STA $0070                                             ; $DEF8: 8D 70 00
  LDA OfficerRecordTable+9,Y                            ; $DEFB: B9 23 DF
  STA $0071                                             ; $DEFE: 8D 71 00
  LDA OfficerAttrTable,X                                ; $DF01: BD 56 DF
  STA $0072                                             ; $DF04: 8D 72 00
  LDA OfficerAttrTable+6,X                              ; $DF07: BD 5C DF
  STA $0073                                             ; $DF0A: 8D 73 00
  LDA OfficerAttrTable+12,X                             ; $DF0D: BD 62 DF
  STA $0074                                             ; $DF10: 8D 74 00
  LDA OfficerAttrTable+18,X                             ; $DF13: BD 68 DF
  STA $0061                                             ; $DF16: 8D 61 00
  RTS                                                   ; $DF19: 60

;-------------------------------------------------------------------------------
; Officer record data tables (10 bytes per officer, interleaved columns)
;-------------------------------------------------------------------------------
OfficerRecordTable:
  .byte $40, $E9, $14, $F2, $1E, $F2, $20, $F2, $FA, $F1, $6C, $B0, $20, $F2, $20, $F2 ; $DF1A
  .byte $20, $F2, $D0, $F1, $50, $E9, $40, $F2, $BA, $D5, $20, $F2, $80, $F1, $40, $E9 ; $DF2A
  .byte $30, $F2, $A0, $F2, $F0, $F8, $20, $EA, $A0, $E9, $1E, $F2, $14, $F2, $20, $F2 ; $DF3A
  .byte $8B, $F1, $F0, $EF, $70, $F2, $20, $F2, $10, $F2, $D0, $EA, $2F, $0F, $0F, $0F ; $DF4A
  .byte $29, $0F, $0E, $14, $14, $14, $0E, $14, $0F, $14, $14, $14, $0F, $14, $03, $0A ; $DF5A

;-------------------------------------------------------------------------------
; Officer attribute tables (1 byte per officer, stride 6)
;-------------------------------------------------------------------------------
OfficerAttrTable:
  .byte $0B, $08, $03, $03, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DF6A
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DF7A
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DF8A
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DF9A
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFAA
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFBA
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFCA
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFDA
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; $DFEA
  .byte $FF, $FF, $FF, $FF, $FF, $FF                                    ; $DFFA
.endproc
