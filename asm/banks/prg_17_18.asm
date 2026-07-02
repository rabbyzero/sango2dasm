;===============================================================================
; PRG Banks $17+$18 - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $17 at $A000-$BFFF, Bank $18 at $C000-$DFFF
; Loaded together via SwitchBankAC_A/B. Y=$37
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

;===============================================================================
; Global RAM Address Definitions
;===============================================================================
; These addresses have consistent meaning across the entire bank.
; Function-specific aliases are defined within .proc scopes.

; --- Game State ---
addr_game_state     = $007A                     ; State counter (0-14), indexes VectorTable
addr_sub_state      = $0078                     ; Sub-state within each major state
addr_sprite_count   = $007C                     ; Current OAM slot index

; --- PPU ---
addr_ppu_ctrl_ram   = $008B                     ; RAM copy of PPU control ($2000)
addr_ppu_mask_ram   = $008C                     ; RAM copy of PPU mask ($2001)
addr_display_mode   = $0098                     ; Display mode parameter
addr_display_mode_h = $0099                     ; Display mode parameter (high)
addr_nmi_ctrl       = $007E                     ; NMI sub-dispatch control bits

; --- Controller ---
addr_pad1_edge      = $0081                     ; Pad 1 newly-pressed buttons
addr_pad2_edge      = $0082                     ; Pad 2 newly-pressed buttons
addr_pad1_raw       = $0083                     ; Pad 1 raw button state
addr_pad1_prev      = $0084                     ; Pad 1 previous frame state
addr_pad2_raw       = $0085                     ; Pad 2 raw button state
addr_pad2_prev      = $0086                     ; Pad 2 previous frame state

; --- Animation ---
addr_anim_direction = $0087                     ; Palette animation direction
addr_anim_step      = $0088                     ; Palette animation step
addr_anim_speed     = $0089                     ; Palette animation speed
addr_anim_counter   = $008A                     ; Palette animation tick counter

; --- Scroll (actual PPU scroll) ---
addr_scroll_x       = $008E                     ; Scroll X position
addr_scroll_x_hi    = $008F                     ; Scroll X high (nametable bit)
addr_scroll_y       = $0090                     ; Scroll Y position
addr_scroll_y_hi    = $0091                     ; Scroll Y high

; --- Input State ---
addr_input_prev_x   = $0094                     ; Input prev X change flag
addr_input_prev_y   = $0095                     ; Input prev Y change flag
addr_ctrl_state_x   = $009C                     ; Controller state X
addr_ctrl_state_y   = $009D                     ; Controller state Y

; --- CHR Banks ---
addr_chr_bank_0     = $00AE                     ; CHR bank 0 ($8000)
addr_chr_bank_1     = $00AF                     ; CHR bank 1 ($8800)
addr_chr_bank_2     = $00B0                     ; CHR bank 2 ($9000)
addr_chr_bank_3     = $00B1                     ; CHR bank 3 ($9800)
addr_chr_bank_4     = $00B2                     ; CHR bank 4 ($A000)
addr_chr_bank_5     = $00B3                     ; CHR bank 5 ($A800)
addr_chr_bank_6     = $00B4                     ; CHR bank 6 ($B000)
addr_chr_bank_7     = $00B5                     ; CHR bank 7 ($B800)

; --- RNG ---
addr_rng_index      = $0050                     ; RNG table index
addr_trampoline_saved_bank = $0058              ; Trampoline saved bank

; --- Game State RAM ($04xx) ---
; Shared state variables used across main game dispatch procs.
; Domestic dispatch work ($0400-$0411)
domestic_work_ptr_lo         = $0400  ; Domestic dispatch work pointer lo
domestic_work_ptr_hi         = $0401  ; Domestic dispatch work pointer hi
; $0402 - local to DomAction_InitOfficerScroll (work_offset)
scroll_ptr_lo                = $0408  ; Scroll position index into officer list
scroll_ptr_hi                = $0409  ; Scroll vertical position
; $040A - local to DomAction_RenderOfficerEntry (scroll_done_flag)
domestic_cursor_lo           = $040C  ; Domestic dispatch cursor/index lo
domestic_cursor_hi           = $040D  ; Domestic dispatch cursor/index hi
; $040E-$040F - local to DomAction_ScrollOfficerList (scroll_src_ptr)
domestic_officer_list_lo     = $0410  ; Officer ID list for domestic dispatch
domestic_officer_list_hi     = $0411  ; Officer ID list hi (usually unused)
; Officer/Selection ($0424-$0435)
troop_assign_counter_lo      = $0424  ; Troop assignment progress counter lo
troop_assign_counter_hi      = $0425  ; Troop assignment progress counter hi
selected_officer_id          = $042C  ; Active/selected officer ID
; $042D - local to BattleResult_ApplyTroopLoss (officer_id_ext)
battle_result_phase          = $042E  ; Battle result phase (shared with domestic dispatch)
; $042F-$0431 - local to SingleCombat_ApplyDamage (damage_amount, damage_applied)
dispatch_timer               = $0435  ; Dispatch timer / countdown
menu_blink_timer             = $046C  ; Menu selection blink timer
; Map/Scroll pointers ($0470-$0473)
anim_ppu_ptr_lo              = $0470  ; Animation PPU pointer lo
anim_ppu_ptr_hi              = $0471  ; Animation PPU pointer hi
map_scroll_ptr_lo            = $0472  ; Map scroll source pointer lo
map_scroll_ptr_hi            = $0473  ; Map scroll source pointer hi
; Main game state ($04A8-$04C0)
game_state                   = $04A8  ; Major game state (0-14), indexes dispatch table
sub_state                    = $04A9  ; Sub-state within each major state
active_player_slot           = $04AA  ; Current player index (0 or 1)
player_flag_0                = $04AB  ; Player 0 flag/status byte
player_officer_id_0          = $04AD  ; Officer ID for player 0
player_officer_id_1          = $04AE  ; Officer ID for player 1
name_tile_index              = $04AF  ; Name tile / scroll tile data index
domestic_action_index        = $04B0  ; Domestic affairs action type index
player_army_value_0          = $04B1  ; Army value for player 0
player_army_value_1          = $04B2  ; Army value for player 1
player_random_offset_0       = $04B3  ; Random offset for player 0
player_action_timer_0        = $04B5  ; Action timer for player 0
anim_timer                   = $04B8  ; Animation / scroll timer
map_scroll_phase             = $04B9  ; Map scroll animation phase
scroll_row_count             = $04BA  ; Scroll row count / sprite base
slide_y_pos                  = $04BB  ; Slide Y position / state
cutscene_load_progress       = $04BC  ; Cutscene/overlay load progress
display_ptr_lo               = $04BD  ; Display/map pointer low
display_ptr_hi               = $04BE  ; Display/map pointer high
sub_action_type              = $04BF  ; Sub-action type selector
frame_counter                = $04C0  ; Frame counter
player_scene_index           = $04C1  ; Per-player scene index (array)
event_overlay_flag           = $04C3  ; Event overlay / battle formation flag
ui_state                     = $04C4  ; UI state flag
name_tile_ptr_lo             = $04C5  ; Name tile pointer lo
name_tile_ptr_hi             = $04C6  ; Name tile pointer hi
; Domestic dispatch state ($04C9-$04D5)
dispatch_step                = $04C9  ; Dispatch step / phase counter
dispatch_src_ptr_lo          = $04CA  ; Dispatch source pointer lo
dispatch_src_ptr_hi          = $04CB  ; Dispatch source pointer hi
dispatch_dst_ptr_lo          = $04CD  ; Dispatch destination pointer lo
dispatch_dst_ptr_hi          = $04CE  ; Dispatch destination pointer hi
dispatch_data_ptr_lo         = $04D2  ; Dispatch data pointer lo
dispatch_data_ptr_hi         = $04D3  ; Dispatch data pointer hi
dispatch_offset_ptr_lo       = $04D4  ; Dispatch offset pointer lo
dispatch_offset_ptr_hi       = $04D5  ; Dispatch offset pointer hi

; --- Tile Grid Buffers ($06xx) ---
; Used by InitTileGridHoriz/Vert and DispatchTileRowHoriz/Vert
tile_grid_coord_x            = $0600  ; X coordinate array (20 entries, $0600-$0613)
tile_grid_coord_y            = $0614  ; Y coordinate / grid position array (20 entries, $0614-$0627)
tile_index_grid              = $0680  ; Tile index grid (64 bytes, $0680-$06BF); $FF = empty

; --- Battery SRAM ($6Fxx) ---
; Persistent SRAM variables in the $6F00-$6FFF battery-backed region.
sram_kingdom_data            = $6F07  ; Kingdom records (7 kingdoms × 8 bytes, $6F07-$6F3E)
sram_kingdom_param_0         = $6F3F  ; Kingdom init param 0 (set to $80 on new game)
sram_kingdom_param_1         = $6F41  ; Kingdom init param 1 (set to $F0 on new game)
sram_scroll_pending          = $6F43  ; Scroll update pending flag (cleared after copy to domestic work ptr)
sram_player_swap             = $6F44  ; Player 2 / palette swap trigger (non-zero = swap active)
sram_game_start_flag         = $6F8B  ; Game start flag (set to $FF on new game)
sram_territory_event         = $6FE1  ; Territory event flag (bit 0 = capture officer)

; --- OAM / Sprite Buffer ($03xx) ---
sprite_y_buffer              = $0380  ; Sprite Y-position buffer (OAM shadow start)

; --- Display / Button Confirm State ($0300-$0313) ---
confirm_check_0              = $0300  ; Confirm check flag 0 (set by display, read by button check)
confirm_check_1              = $0304  ; Confirm check flag 1 (set by display, read by button check)
display_queue_ptr_lo         = $0310  ; PPU display queue pointer lo (consumed by NMI)
display_queue_ptr_hi         = $0311  ; PPU display queue pointer hi
display_queue_end_lo         = $0312  ; PPU display queue terminator lo ($FF)
display_queue_end_hi         = $0313  ; PPU display queue terminator hi ($FF)

; --- Map Scroll Pointers ($03B7-$03BC) ---
map_scroll_ptr_0_lo          = $03B7  ; Map scroll PPU pointer 0 lo
map_scroll_ptr_0_hi          = $03B8  ; Map scroll PPU pointer 0 hi
map_scroll_ptr_1_lo          = $03B9  ; Map scroll PPU pointer 1 lo
map_scroll_ptr_1_hi          = $03BA  ; Map scroll PPU pointer 1 hi
map_scroll_ptr_2_lo          = $03BB  ; Map scroll PPU pointer 2 lo
map_scroll_ptr_2_hi          = $03BC  ; Map scroll PPU pointer 2 hi

; --- Officer / Battle State ($050F-$0517) ---
territory_event_type         = $050F  ; Territory event type selector
player0_officer_lo           = $0514  ; Player 0 officer ID / pointer lo
player0_officer_hi           = $0515  ; Player 0 officer ID hi / battle side array
player1_officer_lo           = $0516  ; Player 1 officer ID / pointer lo
player1_officer_hi           = $0517  ; Player 1 officer ID hi / battle config

; --- Domestic Display / Scroll Work ($0541-$0544) ---
dom_scroll_param             = $0541  ; Domestic scroll / display parameter
dom_display_ptr_lo           = $0542  ; Display buffer pointer lo
dom_display_ptr_hi           = $0543  ; Display buffer pointer hi
dom_scroll_index             = $0544  ; Scroll index / wrap parameter

.segment "CODE_BANK17"

;--- $A000: Jump Table ---

;===============================================================================
; Jump Table - Public entry points ($A000-$A029)
;===============================================================================
; Entry00 ($A000):
  JMP PpuWriteRle                                           ; $A000: 4C 87 A0
; Entry01 ($A003):
  JMP PpuCopyRaw                                           ; $A003: 4C 12 A2
; Entry02 ($A006):
  JMP PpuWriteTileOffset                                           ; $A006: 4C 4E A2
; Entry03 ($A009):
  JMP DisplayScrollLoop                                           ; $A009: 4C FF A2
; Entry04 ($A00C):
  JMP DisplayAndChrSetup                                           ; $A00C: 4C 87 A3
; Entry05 ($A00F):
  JMP BattleEffects                                           ; $A00F: 4C 53 AB
; Entry06 ($A012):
  JMP BattleDispatch                                           ; $A012: 4C 1C A6
; Entry07 ($A015):
  JMP OverlayWindow                                           ; $A015: 4C F0 AE
; Entry08 ($A018):
  JMP SetupAdvisorTiles                                           ; $A018: 4C 83 A9
; Entry09 ($A01B):
  JMP MainGameDispatch                                           ; $A01B: 4C 00 B1
; Entry0A ($A01E):
  JMP DomesticActionDispatch                                    ; $A01E: 4C 93 D6
; Entry0B ($A021):
  JMP AnimationDispatch                                    ; $A021: 4C 25 DE
; Entry0C ($A024):
  JMP DomesticDisplay                                           ; $A024: 4C 2A A0
; Entry0D ($A027):
  JMP DataRecordLoader                                    ; $A027: 4C 15 DF

;===============================================================================
; $A02A: DomesticDisplay
; Entry0C: Domestic affairs display (switches bank $21)
;===============================================================================
.proc DomesticDisplay
  param_byte1     = $0000
  ppu_addr_hi     = $0001
DomesticDisplay:
  LDY #$21                                            ; $A02A: A0 21
  JSR B1F_SwitchBank8_B                               ; $A02C: 20 5F F2
  LDA #$00                                            ; $A02F: A9 00
  STA param_byte1                                     ; $A031: 8D 00 00
  LDA #$20                                            ; $A034: A9 20
  STA param_byte2                                     ; $A036: 8D 01 00
  JSR SetupDisplayPtrs                                           ; $A039: 20 4A A0
  LDA #$00                                            ; $A03C: A9 00
  STA param_byte1                                     ; $A03E: 8D 00 00
  LDA #$24                                            ; $A041: A9 24
  STA param_byte2                                     ; $A043: 8D 01 00
  JSR SetupDisplayPtrs                                           ; $A046: 20 4A A0
  RTS                                                 ; $A049: 60
.endproc

;===============================================================================
; $A04A: SetupDisplayPtrs
; Setup display pointers from $0544 index
;===============================================================================
.proc SetupDisplayPtrs
  tile_ptr_lo   = $000A
  tile_ptr_hi   = $000B
  attr_ptr_lo   = $000C
  attr_ptr_hi   = $000D
SetupDisplayPtrs:
  LDA dom_scroll_index                                     ; $A04A: AD 44 05
  ASL A                                               ; $A04D: 0A
  TAY                                                 ; $A04E: A8
  LDA DomesticTilePtrTable,Y                          ; $A04F: B9 6B A0
  STA tile_ptr_lo                                     ; $A052: 8D 0A 00
  LDA DomesticTilePtrTable+1,Y                        ; $A055: B9 6C A0
  STA tile_ptr_hi                                     ; $A058: 8D 0B 00
  LDA DomesticAttrPtrTable,Y                          ; $A05B: B9 79 A0
  STA attr_ptr_lo                                     ; $A05E: 8D 0C 00
  LDA DomesticAttrPtrTable+1,Y                        ; $A061: B9 7A A0
  STA attr_ptr_hi                                     ; $A064: 8D 0D 00
  JSR PpuWriteTileOffset                                           ; $A067: 20 4E A2
  RTS                                                 ; $A06A: 60

DomesticTilePtrTable:
  .word $8440,$8570,$86A0,$87D0,$8900,$8A30,$8B60  ; $A06B: 40 84 70 85 A0 86 D0 87 00 89 30 8A 60 8B

DomesticAttrPtrTable:
  .word $8000,$8000,$8000,$8000,$8000,$8000,$8000  ; $A079: 00 80 00 80 00 80 00 80 00 80 00 80 00 80
.endproc

;--- $A087: PPU Data Writers ---

;===============================================================================
; $A087: PpuWriteRle
; Entry00: RLE-encoded PPU data writer
;===============================================================================
.proc PpuWriteRle
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  tile_attr_byte      = $0002
  overlay_data_ptr          = $000A
PpuWriteRle:
  LDA a:$008B                                         ; $A087: AD 8B 00
  AND #$FB                                            ; $A08A: 29 FB
  STA $2000                                           ; $A08C: 8D 00 20
  LDA $2002                                           ; $A08F: AD 02 20
  LDA param_byte2                                         ; $A092: AD 01 00
  STA $2006                                           ; $A095: 8D 06 20
  LDA param_byte1                                         ; $A098: AD 00 00
  STA $2006                                           ; $A09B: 8D 06 20
  LDY #$00                                            ; $A09E: A0 00
  LDA (ptr_lo),Y                                         ; $A0A0: B1 0A
  STA rle_marker                                         ; $A0A2: 8D 02 00
  JSR AdvanceSrcPtr                                           ; $A0A5: 20 D2 A0
@process_rle:
  LDA (ptr_lo),Y                                         ; $A0A8: B1 0A
  CMP rle_marker                                         ; $A0AA: CD 02 00
  BEQ @skip                                           ; $A0AD: F0 09
  STA $2007                                           ; $A0AF: 8D 07 20
  JSR AdvanceSrcPtr                                           ; $A0B2: 20 D2 A0
  JMP @process_rle                                           ; $A0B5: 4C A8 A0
@skip:
  JSR AdvanceSrcPtr                                           ; $A0B8: 20 D2 A0
  LDA (ptr_lo),Y                                         ; $A0BB: B1 0A
  TAX                                                 ; $A0BD: AA
  BEQ @skip_2                                           ; $A0BE: F0 11
  JSR AdvanceSrcPtr                                           ; $A0C0: 20 D2 A0
  LDA (ptr_lo),Y                                         ; $A0C3: B1 0A
@loop:
  STA $2007                                           ; $A0C5: 8D 07 20
  DEX                                                 ; $A0C8: CA
  BNE @loop                                           ; $A0C9: D0 FA
  JSR AdvanceSrcPtr                                           ; $A0CB: 20 D2 A0
  JMP @process_rle                                           ; $A0CE: 4C A8 A0
@skip_2:
  RTS                                                 ; $A0D1: 60
.endproc

;===============================================================================
; $A0D2: AdvanceSrcPtr
; Advance source data pointer ($000A/$000B)
;===============================================================================
.proc AdvanceSrcPtr
  overlay_data_ptr          = $000A
  ptr_hi          = $000B
AdvanceSrcPtr:
  LDA ptr_lo                                         ; $A0D2: AD 0A 00
  CLC                                                 ; $A0D5: 18
  ADC #$01                                            ; $A0D6: 69 01
  STA ptr_lo                                         ; $A0D8: 8D 0A 00
  LDA ptr_hi                                         ; $A0DB: AD 0B 00
  ADC #$00                                            ; $A0DE: 69 00
  STA ptr_hi                                         ; $A0E0: 8D 0B 00
  RTS                                                 ; $A0E3: 60

;===============================================================================
; $A0E4: PpuWriteRawRows
; PPU raw row writer with RLE decompression
;===============================================================================
.proc PpuWriteRawRows
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  tile_attr_byte      = $0002
  col_counter_lo  = $0004
  tile_col_index  = $0005
  current_row       = $0006
  max_rows       = $0007
  overlay_data_ptr          = $000A
  ptr_001a_lo     = $001A
  ptr_001a_hi     = $001B
  ptr_001c_lo     = $001C
  ptr_001c_hi     = $001D
  ptr_001e_lo     = $001E
  ptr_001e_hi     = $001F
PpuWriteRawRows:
  LDA #$00                                            ; $A0E4: A9 00
  STA ptr_001a_lo                                         ; $A0E6: 8D 1A 00
  STA ptr_001a_hi                                         ; $A0E9: 8D 1B 00
  STA ptr_001c_lo                                         ; $A0EC: 8D 1C 00
  STA ptr_001c_hi                                         ; $A0EF: 8D 1D 00
  STA ptr_001e_lo                                         ; $A0F2: 8D 1E 00
  STA ptr_001e_hi                                         ; $A0F5: 8D 1F 00
  STA col_counter_lo                                         ; $A0F8: 8D 04 00
  STA col_counter_hi                                         ; $A0FB: 8D 05 00
  LDA a:$008B                                         ; $A0FE: AD 8B 00
  AND #$FB                                            ; $A101: 29 FB
  STA $2000                                           ; $A103: 8D 00 20
  LDA $2002                                           ; $A106: AD 02 20
  LDA param_byte2                                         ; $A109: AD 01 00
  STA $2006                                           ; $A10C: 8D 06 20
  LDA param_byte1                                         ; $A10F: AD 00 00
  STA $2006                                           ; $A112: 8D 06 20
  LDY #$00                                            ; $A115: A0 00
  LDA (ptr_lo),Y                                         ; $A117: B1 0A
  STA ptr_001a_lo                                         ; $A119: 8D 1A 00
  JSR AdvanceSrcPtr2                                           ; $A11C: 20 09 A2
  JSR ReadRleByte                                           ; $A11F: 20 A5 A1
  STA rle_marker                                         ; $A122: 8D 02 00
  LDA row_limit                                         ; $A125: AD 06 00
  BNE RleDecompressHelper                                           ; $A128: D0 3F
@rle_loop:
RleDecompressPpuData:
  JSR ReadRleByte                                           ; $A12A: 20 A5 A1
  CMP rle_marker                                         ; $A12D: CD 02 00
  BEQ @skip                                           ; $A130: F0 14
  STA $2007                                           ; $A132: 8D 07 20
  INC col_counter_lo                                         ; $A135: EE 04 00
  BNE @rle_loop                                           ; $A138: D0 F0
  INC col_counter_hi                                         ; $A13A: EE 05 00
  LDY col_counter_hi                                         ; $A13D: AC 05 00
  CPY row_count                                         ; $A140: CC 07 00
  BCC @rle_loop                                           ; $A143: 90 E5
  RTS                                                 ; $A145: 60
@skip:
  JSR ReadRleByte                                           ; $A146: 20 A5 A1
  TAX                                                 ; $A149: AA
  BEQ @done                                           ; $A14A: F0 1C
  JSR ReadRleByte                                           ; $A14C: 20 A5 A1
  STA $2007                                           ; $A14F: 8D 07 20
  INC col_counter_lo                                         ; $A152: EE 04 00
  BNE @decrement_counter                                           ; $A155: D0 0B
  INC col_counter_hi                                         ; $A157: EE 05 00
  LDY col_counter_hi                                         ; $A15A: AC 05 00
  CPY row_count                                         ; $A15D: CC 07 00
  BCS @done                                           ; $A160: B0 06
@decrement_counter:
  DEX                                                 ; $A162: CA
@write_and_check:
  BNE @skip                                           ; $A163: D0 EA
  JMP @rle_loop                                           ; $A165: 4C 2A A1
@done:
  RTS                                                 ; $A168: 60
.endproc
;===============================================================================
; $A169: RleDecompressHelper
; Helper for RLE decompression - processes literal and run-length encoded data
; Called by PpuWriteRawRows, returns via JMP to RleDecompressPpuData
;===============================================================================
.proc RleDecompressHelper
  tile_attr_byte      = $0002
  col_counter_lo  = $0004
  tile_col_index  = $0005
  current_row       = $0006
RleDecompressHelper:
  JSR ReadRleByte                                           ; $A169: 20 A5 A1
  CMP rle_marker                                         ; $A16C: CD 02 00
  BEQ @skip                                           ; $A16F: F0 13
  INC col_counter_lo                                         ; $A171: EE 04 00
  BNE RleDecompressHelper                                           ; $A174: D0 F3
  INC col_counter_hi                                         ; $A176: EE 05 00
  LDY col_counter_hi                                         ; $A179: AC 05 00
  CPY row_limit                                         ; $A17C: CC 06 00
  BCC RleDecompressHelper                                           ; $A17F: 90 E8
  JMP RleDecompressPpuData                                           ; $A181: 4C 2A A1
@skip:
  JSR ReadRleByte                                           ; $A184: 20 A5 A1
  TAX                                                 ; $A187: AA
  JSR ReadRleByte                                           ; $A188: 20 A5 A1
@loop:
  INC col_counter_lo                                         ; $A18B: EE 04 00
  BNE @skip_2                                           ; $A18E: D0 0E
  INC col_counter_hi                                         ; $A190: EE 05 00
  LDY col_counter_hi                                         ; $A193: AC 05 00
  CPY row_limit                                         ; $A196: CC 06 00
  BCC @skip_2                                           ; $A199: 90 03
  JMP Sub_A162                                           ; $A19B: 4C 62 A1
@skip_2:
  DEX                                                 ; $A19E: CA
  BNE @loop                                           ; $A19F: D0 EA
  JMP RleDecompressHelper                                           ; $A1A1: 4C 69 A1
  RTS                                                 ; $A1A4: 60
.endproc

;===============================================================================
; $A1A5: ReadRleByte
; Read next byte from RLE-encoded data stream
;===============================================================================
.proc ReadRleByte
  overlay_data_ptr          = $000A
  ptr_hi          = $000B
  ptr_001a_lo     = $001A
  ptr_001a_hi     = $001B
  ptr_001c_lo     = $001C
  ptr_001c_hi     = $001D
  ptr_001e_lo     = $001E
  ptr_001e_hi     = $001F
ReadRleByte:
  LDY #$00                                            ; $A1A5: A0 00
  LDA ptr_001a_hi                                         ; $A1A7: AD 1B 00
  BNE @skip                                           ; $A1AA: D0 49
  LDA (ptr_lo),Y                                         ; $A1AC: B1 0A
  CMP ptr_001a_lo                                         ; $A1AE: CD 1A 00
  BNE @skip_3                                           ; $A1B1: D0 50
  LDA ptr_lo                                         ; $A1B3: AD 0A 00
  STA ptr_001c_lo                                         ; $A1B6: 8D 1C 00
  LDA ptr_hi                                         ; $A1B9: AD 0B 00
  STA ptr_001c_hi                                         ; $A1BC: 8D 1D 00
  JSR AdvanceSrcPtr2                                           ; $A1BF: 20 09 A2
  LDA (ptr_lo),Y                                         ; $A1C2: B1 0A
  BEQ @skip_3                                           ; $A1C4: F0 3D
  PHA                                                 ; $A1C6: 48
  AND #$0F                                            ; $A1C7: 29 0F
  STA ptr_001e_hi                                         ; $A1C9: 8D 1F 00
  PLA                                                 ; $A1CC: 68
  LSR A                                               ; $A1CD: 4A
  LSR A                                               ; $A1CE: 4A
  LSR A                                               ; $A1CF: 4A
  LSR A                                               ; $A1D0: 4A
  CLC                                                 ; $A1D1: 18
  ADC #$03                                            ; $A1D2: 69 03
  STA ptr_001a_hi                                         ; $A1D4: 8D 1B 00
  JSR AdvanceSrcPtr2                                           ; $A1D7: 20 09 A2
  LDA (ptr_lo),Y                                         ; $A1DA: B1 0A
  STA ptr_001e_lo                                         ; $A1DC: 8D 1E 00
  JSR AdvanceSrcPtr2                                           ; $A1DF: 20 09 A2
  LDA ptr_001c_lo                                         ; $A1E2: AD 1C 00
  SEC                                                 ; $A1E5: 38
  SBC ptr_001e_lo                                         ; $A1E6: ED 1E 00
  STA ptr_001c_lo                                         ; $A1E9: 8D 1C 00
  LDA ptr_001c_hi                                         ; $A1EC: AD 1D 00
  SBC ptr_001e_hi                                         ; $A1EF: ED 1F 00
  STA ptr_001c_hi                                         ; $A1F2: 8D 1D 00
@skip:
  LDA (ptr_001c_lo),Y                                         ; $A1F5: B1 1C
  INC ptr_001c_lo                                         ; $A1F7: EE 1C 00
  BNE @skip_2                                           ; $A1FA: D0 03
  INC ptr_001c_hi                                         ; $A1FC: EE 1D 00
@skip_2:
  DEC ptr_001a_hi                                         ; $A1FF: CE 1B 00
  RTS                                                 ; $A202: 60
@skip_3:
  PHA                                                 ; $A203: 48
  JSR AdvanceSrcPtr2                                           ; $A204: 20 09 A2
  PLA                                                 ; $A207: 68
  RTS                                                 ; $A208: 60
.endproc

;===============================================================================
; $A209: AdvanceSrcPtr2
; Advance source pointer ($000A/$000B) - variant 2
;===============================================================================
.proc AdvanceSrcPtr2
  overlay_data_ptr          = $000A
  ptr_hi          = $000B
AdvanceSrcPtr2:
  INC ptr_lo                                         ; $A209: EE 0A 00
  BNE @skip                                           ; $A20C: D0 03
  INC ptr_hi                                         ; $A20E: EE 0B 00
@skip:
  RTS                                                 ; $A211: 60
.endproc

;===============================================================================
; $A212: PpuCopyRaw
; Entry01: Raw 1KB PPU data copy
;===============================================================================
.proc PpuCopyRaw
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  overlay_data_ptr          = $000A
  ptr_hi          = $000B
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
PpuCopyRaw:
  LDA a:$008B                                         ; $A212: AD 8B 00
  AND #$FB                                            ; $A215: 29 FB
  STA $2000                                           ; $A217: 8D 00 20
  LDA $2002                                           ; $A21A: AD 02 20
  LDA param_byte2                                         ; $A21D: AD 01 00
  STA $2006                                           ; $A220: 8D 06 20
  LDA param_byte1                                         ; $A223: AD 00 00
  STA $2006                                           ; $A226: 8D 06 20
  LDY #$00                                            ; $A229: A0 00
  STY attr_ptr_lo                                         ; $A22B: 8C 0C 00
  STY attr_ptr_hi                                         ; $A22E: 8C 0D 00
@loop:
  LDA (ptr_lo),Y                                         ; $A231: B1 0A
  STA $2007                                           ; $A233: 8D 07 20
  INC ptr_lo                                         ; $A236: EE 0A 00
  BNE @skip                                           ; $A239: D0 03
  INC ptr_hi                                         ; $A23B: EE 0B 00
@skip:
  INC attr_ptr_lo                                         ; $A23E: EE 0C 00
  BNE @skip_2                                           ; $A241: D0 03
  INC attr_ptr_hi                                         ; $A243: EE 0D 00
@skip_2:
  LDA attr_ptr_hi                                         ; $A246: AD 0D 00
  CMP #$04                                            ; $A249: C9 04
  BCC @loop                                           ; $A24B: 90 E4
  RTS                                                 ; $A24D: 60
.endproc

;===============================================================================
; $A24E: PpuWriteTileOffset
; Entry02: PPU tile data write with offset calculation
;===============================================================================
.proc PpuWriteTileOffset
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  tile_attr_byte      = $0002
  param_0003      = $0003
  overlay_data_ptr          = $000A
  ptr_hi          = $000B
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
PpuWriteTileOffset:
  LDA a:$008B                                         ; $A24E: AD 8B 00
  AND #$FB                                            ; $A251: 29 FB
  STA $2000                                           ; $A253: 8D 00 20
  LDA $2002                                           ; $A256: AD 02 20
  LDA param_byte2                                         ; $A259: AD 01 00
  STA $2006                                           ; $A25C: 8D 06 20
  LDA param_byte1                                         ; $A25F: AD 00 00
  STA $2006                                           ; $A262: 8D 06 20
  LDA ptr_lo                                         ; $A265: AD 0A 00
  SEC                                                 ; $A268: 38
  SBC #$40                                            ; $A269: E9 40
  PHA                                                 ; $A26B: 48
  LDA ptr_hi                                         ; $A26C: AD 0B 00
  SBC #$00                                            ; $A26F: E9 00
  PHA                                                 ; $A271: 48
  LDY #$00                                            ; $A272: A0 00
  STY rle_marker                                         ; $A274: 8C 02 00
  STY param_0003                                         ; $A277: 8C 03 00
@loop:
  LDY #$00                                            ; $A27A: A0 00
  STY param_byte2                                         ; $A27C: 8C 01 00
  LDA (ptr_lo),Y                                         ; $A27F: B1 0A
  ASL A                                               ; $A281: 0A
  ROL param_byte2                                         ; $A282: 2E 01 00
  ASL A                                               ; $A285: 0A
  ROL param_byte2                                         ; $A286: 2E 01 00
  CLC                                                 ; $A289: 18
  ADC attr_ptr_lo                                         ; $A28A: 6D 0C 00
  STA param_byte1                                         ; $A28D: 8D 00 00
  LDA param_byte2                                         ; $A290: AD 01 00
  ADC attr_ptr_hi                                         ; $A293: 6D 0D 00
  STA param_byte2                                         ; $A296: 8D 01 00
  LDA rle_marker                                         ; $A299: AD 02 00
  AND #$10                                            ; $A29C: 29 10
  BEQ @skip                                           ; $A29E: F0 02
  LDY #$02                                            ; $A2A0: A0 02
@skip:
  LDA (param_byte1),Y                                         ; $A2A2: B1 00
  STA $2007                                           ; $A2A4: 8D 07 20
  INY                                                 ; $A2A7: C8
  LDA (param_byte1),Y                                         ; $A2A8: B1 00
  STA $2007                                           ; $A2AA: 8D 07 20
  JSR AdvanceTilePtr                                           ; $A2AD: 20 E4 A2
  INC rle_marker                                         ; $A2B0: EE 02 00
  LDA rle_marker                                         ; $A2B3: AD 02 00
  AND #$0F                                            ; $A2B6: 29 0F
  BNE @skip_2                                           ; $A2B8: D0 0D
  INC param_0003                                         ; $A2BA: EE 03 00
  LDA param_0003                                         ; $A2BD: AD 03 00
  AND #$01                                            ; $A2C0: 29 01
  BEQ @skip_2                                           ; $A2C2: F0 03
  JSR RewindTilePtr16                                           ; $A2C4: 20 ED A2
@skip_2:
  LDA param_0003                                         ; $A2C7: AD 03 00
  CMP #$1E                                            ; $A2CA: C9 1E
  BCC @loop                                           ; $A2CC: 90 AC
  PLA                                                 ; $A2CE: 68
  STA ptr_hi                                         ; $A2CF: 8D 0B 00
  PLA                                                 ; $A2D2: 68
  STA ptr_lo                                         ; $A2D3: 8D 0A 00
  LDX #$40                                            ; $A2D6: A2 40
  LDY #$00                                            ; $A2D8: A0 00
@loop_2:
  LDA (ptr_lo),Y                                         ; $A2DA: B1 0A
  STA $2007                                           ; $A2DC: 8D 07 20
  INY                                                 ; $A2DF: C8
  DEX                                                 ; $A2E0: CA
  BNE @loop_2                                           ; $A2E1: D0 F7
  RTS                                                 ; $A2E3: 60
.endproc

;===============================================================================
; $A2E4: AdvanceTilePtr
; Advance tile data pointer
;===============================================================================
.proc AdvanceTilePtr
  overlay_data_ptr          = $000A
  ptr_hi          = $000B
AdvanceTilePtr:
  INC ptr_lo                                         ; $A2E4: EE 0A 00
  BNE @skip                                           ; $A2E7: D0 03
  INC ptr_hi                                         ; $A2E9: EE 0B 00
@skip:
  RTS                                                 ; $A2EC: 60
.endproc

;===============================================================================
; $A2ED: RewindTilePtr16
; Rewind tile pointer by 16 bytes
;===============================================================================
.proc RewindTilePtr16
  overlay_data_ptr          = $000A
  ptr_hi          = $000B
RewindTilePtr16:
  LDA ptr_lo                                         ; $A2ED: AD 0A 00
  SEC                                                 ; $A2F0: 38
  SBC #$10                                            ; $A2F1: E9 10
  STA ptr_lo                                         ; $A2F3: 8D 0A 00
  LDA ptr_hi                                         ; $A2F6: AD 0B 00
  SBC #$00                                            ; $A2F9: E9 00
  STA ptr_hi                                         ; $A2FB: 8D 0B 00
  RTS                                                 ; $A2FE: 60
.endproc

;--- $A2FF: Display and Scroll ---

;===============================================================================
; $A2FF: DisplayScrollLoop
; Entry03: Display scroll and render loop
;===============================================================================
.proc DisplayScrollLoop
  ptr_001e_lo     = $001E
  ptr_001e_hi     = $001F
  ptr_0092_lo     = $0092
  ptr_0092_hi     = $0093
DisplayScrollLoop:
  LDA a:$008E                                         ; $A2FF: AD 8E 00
  PHA                                                 ; $A302: 48
  LDA a:$008F                                         ; $A303: AD 8F 00
  PHA                                                 ; $A306: 48
  LDA a:$0090                                         ; $A307: AD 90 00
  STA ptr_001e_lo                                         ; $A30A: 8D 1E 00
  PHA                                                 ; $A30D: 48
  LDA a:$0091                                         ; $A30E: AD 91 00
  STA ptr_001e_hi                                         ; $A311: 8D 1F 00
  PHA                                                 ; $A314: 48
  INC a:$0091                                         ; $A315: EE 91 00
  LDA #$1E                                            ; $A318: A9 1E
@loop:
  PHA                                                 ; $A31A: 48
  JSR RenderSceneVert::SetupRenderVert                                           ; $A31B: 20 85 A4
  JSR SetScrollWorkOffset4                                           ; $A31E: 20 9F AD
@loop_2:
  JSR B1F_NmiSubDispatchAlt                           ; $A321: 20 E6 EE
  LDA a:$007E                                         ; $A324: AD 7E 00
  BNE @loop_2                                           ; $A327: D0 F8
  LDA a:$0090                                         ; $A329: AD 90 00
  SEC                                                 ; $A32C: 38
  SBC #$08                                            ; $A32D: E9 08
  STA a:$0090                                         ; $A32F: 8D 90 00
  BCS @skip                                           ; $A332: B0 09
  SEC                                                 ; $A334: 38
  SBC #$10                                            ; $A335: E9 10
  STA a:$0090                                         ; $A337: 8D 90 00
  DEC a:$0091                                         ; $A33A: CE 91 00
@skip:
  PLA                                                 ; $A33D: 68
  SEC                                                 ; $A33E: 38
  SBC #$01                                            ; $A33F: E9 01
  BPL @loop                                           ; $A341: 10 D7
  PLA                                                 ; $A343: 68
  STA a:$0091                                         ; $A344: 8D 91 00
  PLA                                                 ; $A347: 68
  STA a:$0090                                         ; $A348: 8D 90 00
  PLA                                                 ; $A34B: 68
  STA a:$008F                                         ; $A34C: 8D 8F 00
  PLA                                                 ; $A34F: 68
  STA a:$008E                                         ; $A350: 8D 8E 00
  LDA a:$0090                                         ; $A353: AD 90 00
  LSR A                                               ; $A356: 4A
  LSR A                                               ; $A357: 4A
  LSR A                                               ; $A358: 4A
  STA ptr_0092_lo                                         ; $A359: 8D 92 00
  LDA a:$0090                                         ; $A35C: AD 90 00
  CLC                                                 ; $A35F: 18
  ADC #$08                                            ; $A360: 69 08
  LSR A                                               ; $A362: 4A
  LSR A                                               ; $A363: 4A
  LSR A                                               ; $A364: 4A
  LSR A                                               ; $A365: 4A
  STA a:$0094                                         ; $A366: 8D 94 00
  LDA a:$008E                                         ; $A369: AD 8E 00
  SEC                                                 ; $A36C: 38
  SBC #$06                                            ; $A36D: E9 06
  LSR A                                               ; $A36F: 4A
  LSR A                                               ; $A370: 4A
  LSR A                                               ; $A371: 4A
  STA a:$0095                                         ; $A372: 8D 95 00
  LDA a:$008E                                         ; $A375: AD 8E 00
  LSR A                                               ; $A378: 4A
  LSR A                                               ; $A379: 4A
  LSR A                                               ; $A37A: 4A
  STA ptr_0092_hi                                         ; $A37B: 8D 93 00
  LDA #$90                                            ; $A37E: A9 90
  STA a:$009C                                         ; $A380: 8D 9C 00
  STA a:$009D                                         ; $A383: 8D 9D 00
  RTS                                                 ; $A386: 60
.endproc

;===============================================================================
; $A387: DisplayAndChrSetup
; Entry04: Display coordinate check + CHR setup
;===============================================================================
.proc DisplayAndChrSetup
  ptr_0092_lo     = $0092
  ptr_0092_hi     = $0093
DisplayAndChrSetup:
  LDA a:$008E                                         ; $A387: AD 8E 00
  CMP #$FE                                            ; $A38A: C9 FE
  BCC @skip                                           ; $A38C: 90 03
  CLC                                                 ; $A38E: 18
  ADC #$02                                            ; $A38F: 69 02
@skip:
  LSR A                                               ; $A391: 4A
  LSR A                                               ; $A392: 4A
  LSR A                                               ; $A393: 4A
  CMP ptr_0092_hi                                         ; $A394: CD 93 00
  BEQ @skip_2                                           ; $A397: F0 06
  STA ptr_0092_hi                                         ; $A399: 8D 93 00
  JSR DisplayUpdateScroll                                           ; $A39C: 20 B1 A3
@skip_2:
  LDA a:$0090                                         ; $A39F: AD 90 00
  LSR A                                               ; $A3A2: 4A
  LSR A                                               ; $A3A3: 4A
  LSR A                                               ; $A3A4: 4A
  CMP ptr_0092_lo                                         ; $A3A5: CD 92 00
  BEQ @skip_3                                           ; $A3A8: F0 06
  STA ptr_0092_lo                                         ; $A3AA: 8D 92 00
  JSR SceneRenderDispatch                                           ; $A3AD: 20 BC A3
@skip_3:
  RTS                                                 ; $A3B0: 60
.endproc

;===============================================================================
; $A3B1: DisplayUpdateScroll
; Display update scroll registers
;===============================================================================
.proc DisplayUpdateScroll
DisplayUpdateScroll:
  LDA a:$009C                                         ; $A3B1: AD 9C 00
  BPL @skip                                           ; $A3B4: 10 03
  JMP RenderSceneHoriz::AdjustScrollAndRender                                           ; $A3B6: 4C 65 A4
@skip:
  JMP RenderSceneHoriz::CopyScrollRegs                           ; $A3B9: 4C C9 A3
.endproc
;===============================================================================
; $A3BC: SceneRenderDispatch
; Entry05 dispatcher. Routes to horizontal or vertical rendering path
; based on bit 5 of controller state $009C.
;-------------------------------------------------------------------------------
; Inputs:  $009C = controller/button state
; Output:  dispatches to RenderSceneVert::SetupRenderVert (bit 5 clear) or RenderSceneVert::AdjustYAndRender (set)
;===============================================================================
.proc SceneRenderDispatch
SceneRenderDispatch:
  LDA a:$009C                                         ; $A3BC: AD 9C 00
  AND #$20                                            ; $A3BF: 29 20
  BNE @skip                                           ; $A3C1: D0 03
  JMP RenderSceneVert::SetupRenderVert                                           ; $A3C3: 4C 85 A4
@skip:
  JMP RenderSceneVert::AdjustYAndRender                                           ; $A3C6: 4C 1C A5
.endproc
;===============================================================================
; $A3C9: RenderSceneHoriz
; Main scene rendering loop for horizontal layout. Processes a 16x16 metatile
; grid. For each metatile: computes VRAM address via CopyTileRowHoriz::CalcTileAddrHoriz, copies
; tile data via CopyTileRowHoriz::CopyTileRowHoriz, then calls BattleAttrAndHelpers for attribute
; tables. Sets NMI control bit $80 on completion.
;-------------------------------------------------------------------------------
; Three entry points:
;   CopyScrollRegs ($A3C9): copies $008E-$0091 to $000C-$000F, then renders
;   @main ($A3E1): assumes $000C-$000F already set up
;   AdjustScrollAndRender ($A465): adjust scroll X by -8, set up $000C-$000F,
;                                  then JMP @main
; Inputs:  $008E-$0091 = scroll registers (via CopyScrollRegs/AdjustScrollAndRender)
;          $000C-$000F = scroll registers (via @main entry)
;          $007E = NMI control
; Output:  tile data written to PPU buffer, NMI bit $80 set
; Notes:   16 columns x 16 rows metatile grid
;===============================================================================
.proc RenderSceneHoriz
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  tile_col_index  = $0005
  current_row       = $0006
  max_rows       = $0007
  attr_base_offset      = $0008
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
  coord_ptr_lo     = $000E
  coord_ptr_hi     = $000F
  work_0010       = $0010
  ptr_0019_lo     = $0019
  ptr_0019_hi     = $001A
  bank_switch_ptr        = $00A8
CopyScrollRegs:
  LDA a:$008E                                         ; $A3C9: AD 8E 00
  STA attr_ptr_lo                                         ; $A3CC: 8D 0C 00
  LDA a:$008F                                         ; $A3CF: AD 8F 00
  STA attr_ptr_hi                                         ; $A3D2: 8D 0D 00
  LDA a:$0090                                         ; $A3D5: AD 90 00
  STA ptr_000e_lo                                         ; $A3D8: 8D 0E 00
  LDA a:$0091                                         ; $A3DB: AD 91 00
  STA ptr_000e_hi                                         ; $A3DE: 8D 0F 00
@main:
  LDA a:$007E                                         ; $A3E1: AD 7E 00
  BPL @skip                                           ; $A3E4: 10 01
  RTS                                                 ; $A3E6: 60
@skip:
  JSR BankPtrLookup                                           ; $A3E7: 20 04 A6
  STY ptr_0019_hi                                         ; $A3EA: 8C 1A 00
  JSR BattleResolve                                           ; $A3ED: 20 1F A6
  LDA ptr_0019_hi                                         ; $A3F0: AD 1A 00
  CLC                                                 ; $A3F3: 18
  ADC #$02                                            ; $A3F4: 69 02
  TAY                                                 ; $A3F6: A8
  LDA (var_00a8),Y                                         ; $A3F7: B1 A8
  STA work_0010                                         ; $A3F9: 8D 10 00
  JSR InitTileGridHoriz                               ; $A3FC: 20 3F A9
  LDX #$00                                            ; $A3FF: A2 00
  STX row_limit                                         ; $A401: 8E 06 00
  STX row_count                                         ; $A404: 8E 07 00
  LDA attr_ptr_lo                                         ; $A407: AD 0C 00
  LSR A                                               ; $A40A: 4A
  LSR A                                               ; $A40B: 4A
  LSR A                                               ; $A40C: 4A
  LSR A                                               ; $A40D: 4A
  STA param_0008                                         ; $A40E: 8D 08 00
  LDA ptr_000e_lo                                         ; $A411: AD 0E 00
  AND #$F0                                            ; $A414: 29 F0
  CLC                                                 ; $A416: 18
  ADC param_0008                                         ; $A417: 6D 08 00
  STA col_counter_hi                                         ; $A41A: 8D 05 00
@loop:
  LDY col_counter_hi                                         ; $A41D: AC 05 00
  LDA (param_byte1),Y                                         ; $A420: B1 00
  JSR CopyTileRowHoriz::CalcTileAddrHoriz                                           ; $A422: 20 45 A5
  INC ptr_0019_lo                                         ; $A425: EE 19 00
  LDA col_counter_hi                                         ; $A428: AD 05 00
  CLC                                                 ; $A42B: 18
  ADC #$10                                            ; $A42C: 69 10
  CMP #$F0                                            ; $A42E: C9 F0
  BCC @skip_2                                           ; $A430: 90 10
  AND #$0F                                            ; $A432: 29 0F
  PHA                                                 ; $A434: 48
  LDA work_0010                                         ; $A435: AD 10 00
  JSR BattleResolve                                           ; $A438: 20 1F A6
  INC row_count                                         ; $A43B: EE 07 00
  INC ptr_0019_lo                                         ; $A43E: EE 19 00
  PLA                                                 ; $A441: 68
@skip_2:
  STA col_counter_hi                                         ; $A442: 8D 05 00
  INC row_limit                                         ; $A445: EE 06 00
  LDA row_limit                                         ; $A448: AD 06 00
  CMP #$10                                            ; $A44B: C9 10
  BCC @loop                                           ; $A44D: 90 CE
  LDA #$40                                            ; $A44F: A9 40
  STA param_byte1                                         ; $A451: 8D 00 00
  LDA #$01                                            ; $A454: A9 01
  STA param_byte2                                         ; $A456: 8D 01 00
  JSR BattleAttrAndHelpers                                           ; $A459: 20 9A A8
  LDA a:$007E                                         ; $A45C: AD 7E 00
  ORA #$80                                            ; $A45F: 09 80
  STA a:$007E                                         ; $A461: 8D 7E 00
  RTS                                                 ; $A464: 60
AdjustScrollAndRender:
  LDA a:$008E                                         ; $A465: AD 8E 00
  CLC                                                 ; $A468: 18
  ADC #$F8                                            ; $A469: 69 F8
  STA attr_ptr_lo                                         ; $A46B: 8D 0C 00
  LDA a:$008F                                         ; $A46E: AD 8F 00
  ADC #$00                                            ; $A471: 69 00
  STA attr_ptr_hi                                         ; $A473: 8D 0D 00
  LDA a:$0090                                         ; $A476: AD 90 00
  STA ptr_000e_lo                                         ; $A479: 8D 0E 00
  LDA a:$0091                                         ; $A47C: AD 91 00
  STA ptr_000e_hi                                         ; $A47F: 8D 0F 00
  JMP @main                                           ; $A482: 4C E1 A3
.endproc
;===============================================================================
; $A485: RenderSceneVert
; Main scene rendering loop for vertical layout. Processes a 17-column metatile
; grid with per-row tile data. Uses CopyTileRowVert::CopyTileRowVert for tile copying.
; Sets NMI control bit $40 on completion.
;-------------------------------------------------------------------------------
; Three entry points:
;   SetupRenderVert ($A485): copies $008E-$0091 to $000C-$000F, then renders
;   @main ($A49A): assumes $000C-$000F already set up
;   AdjustYAndRender ($A51C): adjust Y by +$F0 (-16), set up $000C-$000F,
;                             then JMP @main
; Inputs:  $008E-$0091 = scroll registers (via SetupRenderVert/AdjustYAndRender)
;          $000C-$000F = scroll registers (via @main entry)
;          $007E = NMI control
; Output:  tile data written to PPU buffer, NMI bit $40 set
; Notes:   17 columns metatile grid
;===============================================================================
.proc RenderSceneVert
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  tile_col_index  = $0005
  current_row       = $0006
  attr_base_offset      = $0008
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
  coord_ptr_lo     = $000E
  coord_ptr_hi     = $000F
  work_0010       = $0010
  adjacency_ptr_offset       = $0018
  work_001a       = $001A
  bank_switch_ptr        = $00A8
SetupRenderVert:
  LDA a:$008E                                         ; $A485: AD 8E 00
  STA attr_ptr_lo                                         ; $A488: 8D 0C 00
  LDA a:$008F                                         ; $A48B: AD 8F 00
  STA attr_ptr_hi                                         ; $A48E: 8D 0D 00
  LDA a:$0091                                         ; $A491: AD 91 00
  STA ptr_000e_hi                                         ; $A494: 8D 0F 00
  LDA a:$0090                                         ; $A497: AD 90 00
  ; NOTE: falls through into @main (no RTS)
@main:
  STA ptr_000e_lo                                         ; $A49A: 8D 0E 00
  LDA a:$007E                                         ; $A49D: AD 7E 00
  ASL A                                               ; $A4A0: 0A
  BPL @skip                                           ; $A4A1: 10 01
  RTS                                                 ; $A4A3: 60
@skip:
  JSR BankPtrLookup                                           ; $A4A4: 20 04 A6
  STY work_001a                                         ; $A4A7: 8C 1A 00
  JSR BattleResolve                                           ; $A4AA: 20 1F A6
  LDY work_001a                                         ; $A4AD: AC 1A 00
  INY                                                 ; $A4B0: C8
  LDA (var_00a8),Y                                         ; $A4B1: B1 A8
  STA work_0010                                         ; $A4B3: 8D 10 00
  JSR InitTileGridVert                                ; $A4B6: 20 61 A9
  LDA attr_ptr_lo                                         ; $A4B9: AD 0C 00
  LSR A                                               ; $A4BC: 4A
  LSR A                                               ; $A4BD: 4A
  LSR A                                               ; $A4BE: 4A
  LSR A                                               ; $A4BF: 4A
  STA param_0008                                         ; $A4C0: 8D 08 00
  LDA ptr_000e_lo                                         ; $A4C3: AD 0E 00
  AND #$F0                                            ; $A4C6: 29 F0
  CLC                                                 ; $A4C8: 18
  ADC param_0008                                         ; $A4C9: 6D 08 00
  STA col_counter_hi                                         ; $A4CC: 8D 05 00
  LDX #$00                                            ; $A4CF: A2 00
  STX row_limit                                         ; $A4D1: 8E 06 00
@loop:
  LDY col_counter_hi                                         ; $A4D4: AC 05 00
  LDA (param_byte1),Y                                         ; $A4D7: B1 00
  JSR CopyTileRowVert::CalcTileAddrVert                                           ; $A4D9: 20 A5 A5
  INC temp_0018                                         ; $A4DC: EE 18 00
  LDA col_counter_hi                                         ; $A4DF: AD 05 00
  INC col_counter_hi                                         ; $A4E2: EE 05 00
  AND #$0F                                            ; $A4E5: 29 0F
  CMP #$0F                                            ; $A4E7: C9 0F
  BNE @skip_2                                           ; $A4E9: D0 11
  LDA work_0010                                         ; $A4EB: AD 10 00
  JSR BattleResolve                                           ; $A4EE: 20 1F A6
  DEC col_counter_hi                                         ; $A4F1: CE 05 00
  LDA col_counter_hi                                         ; $A4F4: AD 05 00
  AND #$F0                                            ; $A4F7: 29 F0
  STA col_counter_hi                                         ; $A4F9: 8D 05 00
@skip_2:
  INC row_limit                                         ; $A4FC: EE 06 00
  LDA row_limit                                         ; $A4FF: AD 06 00
  CMP #$11                                            ; $A502: C9 11
  BCC @loop                                           ; $A504: 90 CE
  LDA #$64                                            ; $A506: A9 64
  STA param_byte1                                         ; $A508: 8D 00 00
  LDA #$01                                            ; $A50B: A9 01
  STA param_byte2                                         ; $A50D: 8D 01 00
  JSR BattleAttrAndHelpers                                           ; $A510: 20 9A A8
  LDA a:$007E                                         ; $A513: AD 7E 00
  ORA #$40                                            ; $A516: 09 40
  STA a:$007E                                         ; $A518: 8D 7E 00
  RTS                                                 ; $A51B: 60
AdjustYAndRender:
  LDA a:$008E                                         ; $A51C: AD 8E 00
  STA attr_ptr_lo                                         ; $A51F: 8D 0C 00
  LDA a:$008F                                         ; $A522: AD 8F 00
  STA attr_ptr_hi                                         ; $A525: 8D 0D 00
  LDA a:$0091                                         ; $A528: AD 91 00
  STA ptr_000e_hi                                         ; $A52B: 8D 0F 00
  INC ptr_000e_hi                                         ; $A52E: EE 0F 00
  LDA a:$0090                                         ; $A531: AD 90 00
  CLC                                                 ; $A534: 18
  ADC #$F0                                            ; $A535: 69 F0
  BCS @skip_3                                           ; $A537: B0 06
  SEC                                                 ; $A539: 38
  SBC #$10                                            ; $A53A: E9 10
  DEC ptr_000e_hi                                         ; $A53C: CE 0F 00
@skip_3:
  STA ptr_000e_lo                                         ; $A53F: 8D 0E 00
  JMP @main                                           ; $A542: 4C 9A A4
.endproc

;===============================================================================
; $A545: CopyTileRowHoriz
; Computes VRAM tile address and copies one metatile row (2 bytes) to sprite
; buffer at $0142+X. Handles horizontal attribute mirroring based on $0006
; and $000E bit 3.
;-------------------------------------------------------------------------------
; Two entry points:
;   CalcTileAddrHoriz ($A545): computes VRAM addr from metatile index, then copies
;   CopyTileRowHoriz ($A565): assumes $0008/$0009 already set, copies directly
; Inputs:  A = metatile index, $0002/$0003 = base address (via CalcTileAddrHoriz)
;          $0008/$0009 = source tile address (via CopyTileRowHoriz)
;          X = dest buffer offset
; Output:  2 bytes written to $0142+X, X advanced by 2
; Notes:   mirroring controlled by $0006 and $000E bit 3
;===============================================================================
.proc CopyTileRowHoriz
  tile_attr_byte      = $0002
  param_0003      = $0003
  current_row       = $0006
  ptr_0008_lo     = $0008
  ptr_0008_hi     = $0009
  scene_coord_ptr     = $000C
  coord_high_bits      = $000E
  var_0142        = $0142
CalcTileAddrHoriz:
  JSR CHRDataTable                                     ; $A545: 20 FD A8
  LDY #$00                                            ; $A548: A0 00
  STY ptr_0008_hi                                         ; $A54A: 8C 09 00
  ASL A                                               ; $A54D: 0A
  ROL ptr_0008_hi                                         ; $A54E: 2E 09 00
  ASL A                                               ; $A551: 0A
  ROL ptr_0008_hi                                         ; $A552: 2E 09 00
  CLC                                                 ; $A555: 18
  ADC rle_marker                                         ; $A556: 6D 02 00
  STA ptr_0008_lo                                         ; $A559: 8D 08 00
  LDA ptr_0008_hi                                         ; $A55C: AD 09 00
  ADC param_0003                                         ; $A55F: 6D 03 00
  STA ptr_0008_hi                                         ; $A562: 8D 09 00
CopyTileRowHoriz:
  LDY #$00                                            ; $A565: A0 00
  LDA attr_ptr_lo                                         ; $A567: AD 0C 00
  AND #$08                                            ; $A56A: 29 08
  BNE @skip_3                                           ; $A56C: D0 1B
  LDA row_limit                                         ; $A56E: AD 06 00
  BNE @skip                                           ; $A571: D0 07
  LDA param_000e                                         ; $A573: AD 0E 00
  AND #$08                                            ; $A576: 29 08
  BNE @skip_2                                           ; $A578: D0 06
@skip:
  LDA (ptr_0008_lo),Y                                         ; $A57A: B1 08
  STA var_0142,X                                         ; $A57C: 9D 42 01
  INX                                                 ; $A57F: E8
@skip_2:
  INY                                                 ; $A580: C8
  INY                                                 ; $A581: C8
  LDA (ptr_0008_lo),Y                                         ; $A582: B1 08
  STA var_0142,X                                         ; $A584: 9D 42 01
  INX                                                 ; $A587: E8
  RTS                                                 ; $A588: 60
@skip_3:
  INY                                                 ; $A589: C8
  LDA row_limit                                         ; $A58A: AD 06 00
  BNE @skip_4                                           ; $A58D: D0 07
  LDA param_000e                                         ; $A58F: AD 0E 00
  AND #$08                                            ; $A592: 29 08
  BNE @skip_5                                           ; $A594: D0 06
@skip_4:
  LDA (ptr_0008_lo),Y                                         ; $A596: B1 08
  STA var_0142,X                                         ; $A598: 9D 42 01
  INX                                                 ; $A59B: E8
@skip_5:
  INY                                                 ; $A59C: C8
  INY                                                 ; $A59D: C8
  LDA (ptr_0008_lo),Y                                         ; $A59E: B1 08
  STA var_0142,X                                         ; $A5A0: 9D 42 01
  INX                                                 ; $A5A3: E8
  RTS                                                 ; $A5A4: 60
.endproc

;===============================================================================
; $A5A5: CopyTileRowVert
; Computes VRAM tile address and copies one metatile row (2 bytes) to sprite
; buffer at $0166+X. Handles vertical attribute mirroring based on $0006
; and $000C bit 3.
;-------------------------------------------------------------------------------
; Two entry points:
;   CalcTileAddrVert ($A5A5): computes VRAM addr from metatile index, then copies
;   CopyTileRowVert ($A5C5): assumes $0008/$0009 already set, copies directly
; Inputs:  A = metatile index, $0002/$0003 = base address (via CalcTileAddrVert)
;          $0008/$0009 = source tile address (via CopyTileRowVert)
;          X = dest buffer offset
; Output:  2 bytes written to $0166+X, X advanced by 2
; Notes:   mirroring controlled by $0006 and $000C bit 3
;===============================================================================
.proc CopyTileRowVert
  tile_attr_byte      = $0002
  param_0003      = $0003
  current_row       = $0006
  ptr_0008_lo     = $0008
  ptr_0008_hi     = $0009
  scene_coord_ptr     = $000C
  coord_high_bits      = $000E
  var_0166        = $0166
CalcTileAddrVert:
  JSR DispatchTileRowVert                             ; $A5A5: 20 1E A9
  LDY #$00                                            ; $A5A8: A0 00
  STY ptr_0008_hi                                         ; $A5AA: 8C 09 00
  ASL A                                               ; $A5AD: 0A
  ROL ptr_0008_hi                                         ; $A5AE: 2E 09 00
  ASL A                                               ; $A5B1: 0A
  ROL ptr_0008_hi                                         ; $A5B2: 2E 09 00
  CLC                                                 ; $A5B5: 18
  ADC rle_marker                                         ; $A5B6: 6D 02 00
  STA ptr_0008_lo                                         ; $A5B9: 8D 08 00
  LDA ptr_0008_hi                                         ; $A5BC: AD 09 00
  ADC param_0003                                         ; $A5BF: 6D 03 00
  STA ptr_0008_hi                                         ; $A5C2: 8D 09 00
CopyTileRowVert:
  LDY #$00                                            ; $A5C5: A0 00
  LDA param_000e                                         ; $A5C7: AD 0E 00
  AND #$08                                            ; $A5CA: 29 08
  BNE @skip_3                                           ; $A5CC: D0 1A
  LDA row_limit                                         ; $A5CE: AD 06 00
  BNE @skip                                           ; $A5D1: D0 07
  LDA attr_ptr_lo                                         ; $A5D3: AD 0C 00
  AND #$08                                            ; $A5D6: 29 08
  BNE @skip_2                                           ; $A5D8: D0 06
@skip:
  LDA (ptr_0008_lo),Y                                         ; $A5DA: B1 08
  STA var_0166,X                                         ; $A5DC: 9D 66 01
  INX                                                 ; $A5DF: E8
@skip_2:
  INY                                                 ; $A5E0: C8
  LDA (ptr_0008_lo),Y                                         ; $A5E1: B1 08
  STA var_0166,X                                         ; $A5E3: 9D 66 01
  INX                                                 ; $A5E6: E8
  RTS                                                 ; $A5E7: 60
@skip_3:
  INY                                                 ; $A5E8: C8
  INY                                                 ; $A5E9: C8
  LDA row_limit                                         ; $A5EA: AD 06 00
  BNE @skip_4                                           ; $A5ED: D0 07
  LDA attr_ptr_lo                                         ; $A5EF: AD 0C 00
  AND #$08                                            ; $A5F2: 29 08
  BNE @skip_5                                           ; $A5F4: D0 06
@skip_4:
  LDA (ptr_0008_lo),Y                                         ; $A5F6: B1 08
  STA var_0166,X                                         ; $A5F8: 9D 66 01
  INX                                                 ; $A5FB: E8
@skip_5:
  INY                                                 ; $A5FC: C8
  LDA (ptr_0008_lo),Y                                         ; $A5FD: B1 08
  STA var_0166,X                                         ; $A5FF: 9D 66 01
  INX                                                 ; $A602: E8
  RTS                                                 ; $A603: 60
.endproc

;===============================================================================
; $A604: BankPtrLookup
; Computes bank pointer offset: Y = ($000F << 1) + $000D, then loads byte from
; ($00A8),Y. Used for metatile-to-tile address table lookups.
;-------------------------------------------------------------------------------
; Inputs:  $000F = row index, $000D = column offset, $00A8 = table pointer
; Output:  A = looked-up byte, Y = computed offset
;===============================================================================
.proc BankPtrLookup
  work_ptr_hi     = $000D
  param_000f      = $000F
  bank_switch_ptr        = $00A8
BankPtrLookup:
  LDA param_000f                                         ; $A604: AD 0F 00
  ASL A                                               ; $A607: 0A
  CLC                                                 ; $A608: 18
  ADC attr_ptr_hi                                         ; $A609: 6D 0D 00
  TAY                                                 ; $A60C: A8
  LDA (var_00a8),Y                                         ; $A60D: B1 A8
  RTS                                                 ; $A60F: 60
.endproc
;===============================================================================
; $A610: BankPtrLookupAlt
; Alternate bank pointer lookup: Y = ($001F << 1) + $001D, then loads byte from
; ($00A8),Y. Variant using different ZP registers.
;-------------------------------------------------------------------------------
; Inputs:  $001F = row index, $001D = column offset, $00A8 = table pointer
; Output:  A = looked-up byte, Y = computed offset
;===============================================================================
.proc BankPtrLookupAlt
  var_001d        = $001D
  var_001f        = $001F
  bank_switch_ptr        = $00A8
BankPtrLookupAlt:
  LDA var_001f                                         ; $A610: AD 1F 00
  ASL A                                               ; $A613: 0A
  CLC                                                 ; $A614: 18
  ADC var_001d                                         ; $A615: 6D 1D 00
  TAY                                                 ; $A618: A8
  LDA (var_00a8),Y                                         ; $A619: B1 A8
  RTS                                                 ; $A61B: 60
.endproc

;===============================================================================
; $A61C: BattleDispatch
; Entry06: Battle dispatch (bank switch + pointer lookup)
;===============================================================================
.proc BattleDispatch
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  tile_attr_byte      = $0002
  param_0003      = $0003
BattleDispatch:
  LDA param_byte1                                         ; $A61C: AD 00 00
;-------------------------------------------------------------------------------
; Sub-entry: Battle resolve (pointer lookup + bank switch)
;-------------------------------------------------------------------------------
BattleResolve:
  PHA                                                 ; $A61F: 48
  ASL A                                               ; $A620: 0A
  TAY                                                 ; $A621: A8
  LDA BattleTilePtrTable,Y                            ; $A622: B9 42 A6
  STA param_byte1                                         ; $A625: 8D 00 00
  LDA BattleTilePtrTable+1,Y                          ; $A628: B9 43 A6
  STA param_byte2                                         ; $A62B: 8D 01 00
  LDA #$77                                            ; $A62E: A9 77
  STA rle_marker                                         ; $A630: 8D 02 00
  LDA #$F4                                            ; $A633: A9 F4
  STA param_0003                                         ; $A635: 8D 03 00
  PLA                                                 ; $A638: 68
  TAY                                                 ; $A639: A8
  LDA BattleBankTable,Y                               ; $A63A: B9 22 A8
  TAY                                                 ; $A63D: A8
  JSR B1F_SwitchBank8_B                               ; $A63E: 20 5F F2
  RTS                                                 ; $A641: 60

;-------------------------------------------------------------------------------
; $A642: BattleTilePtrTable
; Battle scene tile pointer table (32 entries)
; Used by BattleDispatch / BattleResolve for pointer lookup
;-------------------------------------------------------------------------------
BattleTilePtrTable:
  ; Bank $20 — indices 0-31
  .word $8040,$8170,$8200,$8330,$83C0,$84F0,$8580,$86B0; $A642: 40 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86
  .word $8740,$8870,$8900,$8A30,$8AC0,$8BF0,$8C80,$8DB0; $A652: 40 87 70 88 00 89 30 8A C0 8A F0 8B 80 8C B0 8D
  .word $8E40,$8F70,$9000,$9130,$91C0,$92F0,$9380,$94B0; $A662: 40 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94
  .word $9540,$9670,$9700,$9830,$98C0,$99F0,$9A80,$9BB0; $A672: 40 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B

;-------------------------------------------------------------------------------
; $A682: BattleAttrTable
; Battle scene attribute data (176 bytes)
; Interleaved attribute address pairs and pointer patterns
;-------------------------------------------------------------------------------
BattleAttrTable:
  ; Bank $23 — indices 32-55
  .byte $A6,$89,$D6,$8A,$66,$8B,$96,$8C,$26,$8D,$56,$8E,$E6,$8E,$16,$90; $A682: A6 89 D6 8A 66 8B 96 8C 26 8D 56 8E E6 8E 16 90
  .byte $A6,$90,$D6,$91,$66,$92,$96,$93,$26,$94,$56,$95,$E6,$95,$16,$97; $A692: A6 90 D6 91 66 92 96 93 26 94 56 95 E6 95 16 97
  .byte $A6,$97,$D6,$98,$66,$99,$96,$9A,$26,$9B,$56,$9C,$E6,$9C,$16,$9E; $A6A2: A6 97 D6 98 66 99 96 9A 26 9B 56 9C E6 9C 16 9E
  ; Bank $24 — indices 56-87
  .byte $40,$95,$70,$96,$00,$97,$30,$98,$C0,$98,$F0,$99,$80,$9A,$B0,$9B; $A6B2: 40 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B
  .byte $40,$80,$70,$81,$00,$82,$30,$83,$C0,$83,$F0,$84,$80,$85,$B0,$86; $A6C2: 40 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86
  .byte $40,$87,$70,$88,$00,$89,$30,$8A,$C0,$8A,$F0,$8B,$80,$8C,$B0,$8D; $A6D2: 40 87 70 88 00 89 30 8A C0 8A F0 8B 80 8C B0 8D
  .byte $40,$8E,$70,$8F,$00,$90,$30,$91,$C0,$91,$F0,$92,$80,$93,$B0,$94; $A6E2: 40 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94
  ; Bank $25 — indices 88-119
  .byte $40,$95,$70,$96,$00,$97,$30,$98,$C0,$98,$F0,$99,$80,$9A,$B0,$9B; $A6F2: 40 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B
  .byte $40,$80,$70,$81,$00,$82,$30,$83,$C0,$83,$F0,$84,$80,$85,$B0,$86; $A702: 40 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86
  .byte $40,$87,$70,$88,$00,$89,$30,$8A,$C0,$8A,$F0,$8B,$80,$8C,$B0,$8D; $A712: 40 87 70 88 00 89 30 8A C0 8A F0 8B 80 8C B0 8D
  .byte $40,$8E,$70,$8F,$00,$90,$30,$91,$C0,$91,$F0,$92,$80,$93,$B0,$94; $A722: 40 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94

;-------------------------------------------------------------------------------
; $A732: BattleOverlayPtrTable
; Battle overlay window pointer table (120 entries)
; Used by LoadOverlayPrimary and LoadOverlaySecondary for overlay dispatch
;-------------------------------------------------------------------------------
BattleOverlayPtrTable:
  ; Bank $20 — indices 0-31
  .word $8000,$8130,$81C0,$82F0,$8380,$84B0,$8540,$8670; $A732: 00 80 30 81 C0 81 F0 82 80 83 B0 84 40 85 70 86
  .word $8700,$8830,$88C0,$89F0,$8A80,$8BB0,$8C40,$8D70; $A742: 00 87 30 88 C0 88 F0 89 80 8A B0 8B 40 8C 70 8D
  .word $8E00,$8F30,$8FC0,$90F0,$9180,$92B0,$9340,$9470; $A752: 00 8E 30 8F C0 8F F0 90 80 91 B0 92 40 93 70 94
  .word $9500,$9630,$96C0,$97F0,$9880,$99B0,$9A40,$9B70; $A762: 00 95 30 96 C0 96 F0 97 80 98 B0 99 40 9A 70 9B
  ; Bank $23 — indices 32-55
  .word $8966,$8A96,$8B26,$8C56,$8CE6,$8E16,$8EA6,$8FD6; $A772: 66 89 96 8A 26 8B 56 8C E6 8C 16 8E A6 8E D6 8F
  .word $9066,$9196,$9226,$9356,$93E6,$9516,$95A6,$96D6; $A782: 66 90 96 91 26 92 56 93 E6 93 16 95 A6 95 D6 96
  .word $9766,$9896,$9926,$9A56,$9AE6,$9C16,$9CA6,$9DD6; $A792: 66 97 96 98 26 99 56 9A E6 9A 16 9C A6 9C D6 9D
  ; Bank $24 — indices 56-87
  .word $9500,$9630,$96C0,$97F0,$9880,$99B0,$9A40,$9B70; $A7A2: 00 95 30 96 C0 96 F0 97 80 98 B0 99 40 9A 70 9B
  .word $8000,$8130,$81C0,$82F0,$8380,$84B0,$8540,$8670; $A7B2: 00 80 30 81 C0 81 F0 82 80 83 B0 84 40 85 70 86
  .word $8700,$8830,$88C0,$89F0,$8A80,$8BB0,$8C40,$8D70; $A7C2: 00 87 30 88 C0 88 F0 89 80 8A B0 8B 40 8C 70 8D
  .word $8E00,$8F30,$8FC0,$90F0,$9180,$92B0,$9340,$9470; $A7D2: 00 8E 30 8F C0 8F F0 90 80 91 B0 92 40 93 70 94
  ; Bank $25 — indices 88-119
  .word $9500,$9630,$96C0,$97F0,$9880,$99B0,$9A40,$9B70; $A7E2: 00 95 30 96 C0 96 F0 97 80 98 B0 99 40 9A 70 9B
  .word $8000,$8130,$81C0,$82F0,$8380,$84B0,$8540,$8670; $A7F2: 00 80 30 81 C0 81 F0 82 80 83 B0 84 40 85 70 86
  .word $8700,$8830,$88C0,$89F0,$8A80,$8BB0,$8C40,$8D70; $A802: 00 87 30 88 C0 88 F0 89 80 8A B0 8B 40 8C 70 8D
  .word $8E00,$8F30,$8FC0,$90F0,$9180,$92B0,$9340,$9470; $A812: 00 8E 30 8F C0 8F F0 90 80 91 B0 92 40 93 70 94

;-------------------------------------------------------------------------------
; $A822: BattleBankTable
; Battle/overlay dispatch bank number table (120 entries)
; Maps dispatch index to PRG bank number for B1F_SwitchBank8_B
;-------------------------------------------------------------------------------
BattleBankTable:
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20; $A822: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20; $A832: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
  .byte $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23; $A842: 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23
  .byte $23,$23,$23,$23,$23,$23,$23,$23,$25,$25,$25,$25,$25,$25,$25,$25; $A852: 23 23 23 23 23 23 23 23 25 25 25 25 25 25 25 25
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24; $A862: 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24; $A872: 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25; $A882: 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25
  .byte $25,$25,$25,$25,$25,$25,$25,$25               ; $A892: 25 25 25 25 25 25 25 25
.endproc

;===============================================================================
; $A89A: BattleAttrAndHelpers
; Battle attribute setup + helper subroutines
;===============================================================================
.proc BattleAttrAndHelpers
  param_byte1     = $0000
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
  coord_ptr_lo     = $000E
  coord_ptr_hi     = $000F
BattleAttrAndHelpers:
  LDY #$00                                            ; $A89A: A0 00
  LDA attr_ptr_hi                                         ; $A89C: AD 0D 00
  LDX #$20                                            ; $A89F: A2 20
  LSR A                                               ; $A8A1: 4A
  BCS @skip                                           ; $A8A2: B0 02
  LDX #$20                                            ; $A8A4: A2 20
@skip:
  TXA                                                 ; $A8A6: 8A
  STA (param_byte1),Y                                         ; $A8A7: 91 00
  INY                                                 ; $A8A9: C8
  LDA attr_ptr_lo                                         ; $A8AA: AD 0C 00
  LSR A                                               ; $A8AD: 4A
  LSR A                                               ; $A8AE: 4A
  LSR A                                               ; $A8AF: 4A
  STA (param_byte1),Y                                         ; $A8B0: 91 00
  LDA #$00                                            ; $A8B2: A9 00
  STA ptr_000e_hi                                         ; $A8B4: 8D 0F 00
  LDA ptr_000e_lo                                         ; $A8B7: AD 0E 00
  AND #$F8                                            ; $A8BA: 29 F8
  ASL A                                               ; $A8BC: 0A
  ROL ptr_000e_hi                                         ; $A8BD: 2E 0F 00
  ASL A                                               ; $A8C0: 0A
  ROL ptr_000e_hi                                         ; $A8C1: 2E 0F 00
  CLC                                                 ; $A8C4: 18
  ADC (param_byte1),Y                                         ; $A8C5: 71 00
  STA (param_byte1),Y                                         ; $A8C7: 91 00
  DEY                                                 ; $A8C9: 88
  LDA (param_byte1),Y                                         ; $A8CA: B1 00
  CLC                                                 ; $A8CC: 18
  ADC ptr_000e_hi                                         ; $A8CD: 6D 0F 00
  STA (param_byte1),Y                                         ; $A8D0: 91 00
  RTS                                                 ; $A8D2: 60
.endproc
;===============================================================================
; $A8D3: ComputeAttributeByte
; In this NES context, attribute byte refers to a PPU attribute table byte — part of the NES Picture Processing Unit's memory that controls which color palette (0–3) each 16×16 pixel region of the screen uses.
; NES Attribute Table Background
; Each attribute byte controls a 32×32 pixel area (a 2×2 block of metatiles), divided into four 16×16 quadrants:
; bits 7-6: bottom-right quadrant palette
; bits 5-4: bottom-left quadrant palette
; bits 3-2: top-right quadrant palette
; bits 1-0: top-left quadrant palette
; What ComputeAttributeByte does ($A8D3)
; This routine constructs an attribute byte for a specific position on the nametable and stores it via an indirect pointer ($00),Y:
; Bits 0–1 (top-left palette): Reads $000D (likely a palette index). Uses LSR A + BCS to set X = $23 as a base, then stores TXA as the first byte.
; Bits for the header/VRAM address: Reads $000C, shifts right 5 times (extracts upper 3 bits), adds $C0 to form a base PPU attribute address, stores it.
; CHR bank/palette config: Reads $000E, masks with AND #$E0 (top 3 bits), shifts right 2, adds it to the previous value — this encodes which CHR bank/palette group the tile belongs to.
; The result is a pair of bytes written to the output buffer: a palette configuration byte and a PPU VRAM attribute address, used by the CHR decompression/rendering pipeline to correctly color the tiles being uploaded to VRAM.In short: it translates tile metadata (palette index, CHR bank) into the format the NES PPU expects in its attribute tables.
;===============================================================================
.proc ComputeAttributeByte
  param_byte1     = $0000
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
  coord_high_bits      = $000E
ComputeAttributeByte:
  LDY #$00                                            ; $A8D3: A0 00
  LDA attr_ptr_hi                                         ; $A8D5: AD 0D 00
  LDX #$23                                            ; $A8D8: A2 23
  LSR A                                               ; $A8DA: 4A
  BCS @skip                                           ; $A8DB: B0 02
  LDX #$23                                            ; $A8DD: A2 23
@skip:
  TXA                                                 ; $A8DF: 8A
  STA (param_byte1),Y                                         ; $A8E0: 91 00
  INY                                                 ; $A8E2: C8
  LDA attr_ptr_lo                                         ; $A8E3: AD 0C 00
  LSR A                                               ; $A8E6: 4A
  LSR A                                               ; $A8E7: 4A
  LSR A                                               ; $A8E8: 4A
  LSR A                                               ; $A8E9: 4A
  LSR A                                               ; $A8EA: 4A
  CLC                                                 ; $A8EB: 18
  ADC #$C0                                            ; $A8EC: 69 C0
  STA (param_byte1),Y                                         ; $A8EE: 91 00
  LDA param_000e                                         ; $A8F0: AD 0E 00
  AND #$E0                                            ; $A8F3: 29 E0
  LSR A                                               ; $A8F5: 4A
  LSR A                                               ; $A8F6: 4A
  CLC                                                 ; $A8F7: 18
  ADC (param_byte1),Y                                         ; $A8F8: 71 00
  STA (param_byte1),Y                                         ; $A8FA: 91 00
  RTS                                                 ; $A8FC: 60
.endproc

;===============================================================================
; Tile Grid Data Structures
;===============================================================================
; tile_index_grid ($0680-$06BF): Tile index grid (64 bytes)
;   - Each entry: tile index (0-255) or $FF (empty/uninitialized)
;   - Indexed by screen position (0-63)
;   - Populated by InitTileGridHoriz (horizontal) or InitTileGridVert (vertical)
;   - Queried by DispatchTileRowHoriz (horizontal) or DispatchTileRowVert (vertical)
;
; tile_grid_coord_x ($0600-$0613): X coordinate array (20 entries)
;   - Used by InitTileGridHoriz for horizontal coordinate matching
;
; tile_grid_coord_y ($0614-$0627): Y coordinate / grid position array (20 entries)
;   - Used by InitTileGridHoriz for grid position mapping
;
; $0018: Target column (for vertical dispatch and horizontal init)
; $0019: Target row (for horizontal dispatch and vertical init)
; $0008-$0009: Destination pointer (set to $01B0 before copy)
;===============================================================================

;-------------------------------------------------------------------------------
; Tile grid lookup and initialization routines
; Manages the 64-byte tile index grid (tile_index_grid) for horizontal/vertical rendering
;-------------------------------------------------------------------------------

; DispatchTileRowHoriz: Horizontal Tile Dispatch ($A8FD-$A91D)
.proc DispatchTileRowHoriz
  ptr_0008_lo     = $0008
  ptr_0008_hi     = $0009
  var_0019        = $0019
  PHA                                                 ; $A8FD: 48     ; Save A (caller's tile data)
  LDY var_0019                                         ; $A8FE: AC 19 00 ; Y = row index (horizontal mode)
  LDA tile_index_grid,Y                                         ; $A901: B9 80 06 ; Lookup tile index from grid
  CMP #$FF                                            ; $A904: C9 FF  ; Check if empty ($FF = no tile)
  BEQ @empty                                          ; $A906: F0 14  ; Branch if empty
  TAY                                                 ; $A908: A8     ; Y = tile index
  PLA                                                 ; $A909: 68     ; Discard return address (3 bytes - skip caller's RTS)
  PLA                                                 ; $A90A: 68
  PLA                                                 ; $A90B: 68
  JSR SetupAdvisorTiles                                   ; $A90C: 20 86 A9 ; Setup advisor tiles
  LDA #$B0                                            ; $A90F: A9 B0  ; Set destination pointer low byte
  STA ptr_0008_lo                                         ; $A911: 8D 08 00 ; $0008 = $B0
  LDA #$01                                            ; $A914: A9 01  ; Set destination pointer high byte
  STA ptr_0008_hi                                         ; $A916: 8D 09 00 ; $0009 = $01 → dest = $01B0
  JMP CopyTileRowHoriz                                ; $A919: 4C 65 A5 ; Jump to horizontal tile copy ($A565)
@empty:
  PLA                                                 ; $A91C: 68     ; Restore A
  RTS                                                 ; $A91D: 60     ; Return (no tile to copy)
.endproc

; DispatchTileRowVert: Vertical Tile Dispatch ($A91E-$A93E)
.proc DispatchTileRowVert
  ptr_0008_lo     = $0008
  ptr_0008_hi     = $0009
  var_0018        = $0018
  PHA                                                 ; $A91E: 48     ; Save A
  LDY var_0018                                         ; $A91F: AC 18 00 ; Y = column index (vertical mode)
  LDA tile_index_grid,Y                                         ; $A922: B9 80 06 ; Lookup tile index from grid
  CMP #$FF                                            ; $A925: C9 FF  ; Check if empty
  BEQ @empty                                          ; $A927: F0 14
  TAY                                                 ; $A929: A8     ; Y = tile index
  PLA                                                 ; $A92A: 68     ; Discard return address
  PLA                                                 ; $A92B: 68
  PLA                                                 ; $A92C: 68
  JSR SetupAdvisorTiles                                   ; $A92D: 20 86 A9 ; Setup advisor tiles
  LDA #$B0                                            ; $A930: A9 B0  ; Set destination pointer
  STA ptr_0008_lo                                         ; $A932: 8D 08 00
  LDA #$01                                            ; $A935: A9 01
  STA ptr_0008_hi                                         ; $A937: 8D 09 00 ; dest = $01B0
  JMP CopyTileRowVert                                 ; $A93A: 4C C5 A5 ; Jump to vertical tile copy ($A5C5)
@empty:
  PLA                                                 ; $A93D: 68
  RTS                                                 ; $A93E: 60
.endproc

; InitTileGridHoriz: Init Horizontal Lookup Table ($A93F-$A960)
.proc InitTileGridHoriz
  var_0018        = $0018
  JSR CalcTileGridOrigin                                  ; $A93F: 20 26 AB ; Setup routine
  LDY #$3F                                            ; $A942: A0 3F  ; Y = 63 (grid size - 1)
  LDA #$FF                                            ; $A944: A9 FF  ; Fill value = $FF (empty marker)
@fill_loop:
  STA tile_index_grid,Y                                         ; $A946: 99 80 06 ; Fill grid with $FF
  DEY                                                 ; $A949: 88
  BPL @fill_loop                                      ; $A94A: 10 FA  ; Loop until Y < 0
  ; Now populate matching entries
  LDY #$13                                            ; $A94C: A0 13  ; Y = 19 (loop 20 times, indices 0-19)
@populate_loop:
  LDA tile_grid_coord_x,Y                                         ; $A94E: B9 00 06 ; Load X coordinate
  CMP var_0018                                         ; $A951: CD 18 00 ; Compare with target column
  BNE @skip                                           ; $A954: D0 07  ; Skip if no match
  LDX tile_grid_coord_y,Y                                         ; $A956: BE 14 06 ; Load grid position
  TYA                                                 ; $A959: 98     ; A = Y (tile index)
  STA tile_index_grid,X                                         ; $A95A: 9D 80 06 ; Store tile index at grid position X
@skip:
  DEY                                                 ; $A95D: 88
  BPL @populate_loop                                  ; $A95E: 10 EE  ; Loop until Y < 0
  RTS                                                 ; $A960: 60
.endproc

; InitTileGridVert: Init Vertical Lookup Table ($A961-$A982)
.proc InitTileGridVert
  var_0019        = $0019
  JSR CalcTileGridOrigin                                  ; $A961: 20 26 AB ; Setup routine
  LDY #$3F                                            ; $A964: A0 3F
  LDA #$FF                                            ; $A966: A9 FF
@fill_loop:
  STA tile_index_grid,Y                                         ; $A968: 99 80 06 ; Fill grid with $FF
  DEY                                                 ; $A96B: 88
  BPL @fill_loop                                      ; $A96C: 10 FA
  LDY #$13                                            ; $A96E: A0 13
@populate_loop:
  LDA tile_grid_coord_y,Y                                         ; $A970: B9 14 06 ; Load Y coordinate (swapped!)
  CMP var_0019                                         ; $A973: CD 19 00 ; Compare with target row (swapped!)
  BNE @skip                                           ; $A976: D0 07
  LDX tile_grid_coord_x,Y                                         ; $A978: BE 00 06 ; Load grid position (swapped!)
  TYA                                                 ; $A97B: 98
  STA tile_index_grid,X                                         ; $A97C: 9D 80 06 ; Store tile index at grid position X
@skip:
  DEY                                                 ; $A97F: 88
  BPL @populate_loop                                  ; $A980: 10 EE
  RTS                                                 ; $A982: 60
.endproc

;===============================================================================
; $A983: SetupAdvisorTiles
; Entry08: Advisor/council dialogue tile setup system
; Takes a ruler index, fetches the ruler's dialogue type from SRAM, dispatches
; to one of three cases (type 0/1/2), and writes four CHR tile indices into the
; $01B0-$01B3 metatile buffer. Special overrides for ruler index 0 and 10.
; Sub-tile overrides based on $0628[Y] bits 0-1.
; Input:  Y = ruler index (loaded from $0000 at entry)
; Output: $01B0-$01B3 = 4 CHR tile indices for advisor metatile
;===============================================================================
.proc SetupAdvisorTiles
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  ptr_01b0_lo     = $01B0
  ptr_01b0_hi     = $01B1
  ptr_01b2_lo     = $01B2
  ptr_01b2_hi     = $01B3
  param_0507      = $0507
  var_0628        = $0628
  var_063c        = $063C
SetupAdvisorTiles:
  LDY param_byte1                                         ; $A983: AC 00 00
  TYA                                                 ; $A986: 98
  PHA                                                 ; $A987: 48
  LDA param_0507                                           ; $A988: AD 07 05
  PHA                                                 ; $A98B: 48
  LDA var_0628,Y                                         ; $A98C: B9 28 06
  BPL @no_shift                                       ; $A98F: 10 06
  PLA                                                 ; $A991: 68
  LSR A                                               ; $A992: 4A
  LSR A                                               ; $A993: 4A
  LSR A                                               ; $A994: 4A
  LSR A                                               ; $A995: 4A
  PHA                                                 ; $A996: 48
@no_shift:
  PLA                                                 ; $A997: 68
  AND #$0F                                            ; $A998: 29 0F
  JSR @GetRulerDialogueType                           ; $A99A: 20 A8 A9
  CMP #$00                                            ; $A99D: C9 00
  BEQ @type0                                          ; $A99F: F0 23
  CMP #$01                                            ; $A9A1: C9 01
  BEQ @type1                                          ; $A9A3: F0 7F
  JMP @type2                                          ; $A9A5: 4C 84 AA
@GetRulerDialogueType:
  TAY                                                 ; $A9A8: A8
  LDA param_byte1                                         ; $A9A9: AD 00 00
  PHA                                                 ; $A9AC: 48
  LDA param_byte2                                         ; $A9AD: AD 01 00
  PHA                                                 ; $A9B0: 48
  TYA                                                 ; $A9B1: 98
  JSR B1F_GetRulerDataPtr                             ; $A9B2: 20 68 F3
  LDY #$03                                            ; $A9B5: A0 03
  LDA (param_byte1),Y                                         ; $A9B7: B1 00
  TAY                                                 ; $A9B9: A8
  PLA                                                 ; $A9BA: 68
  STA param_byte2                                         ; $A9BB: 8D 01 00
  PLA                                                 ; $A9BE: 68
  STA param_byte1                                         ; $A9BF: 8D 00 00
  TYA                                                 ; $A9C2: 98
  RTS                                                 ; $A9C3: 60
@type0:
  PLA                                                 ; $A9C4: 68
  TAY                                                 ; $A9C5: A8
  PHA                                                 ; $A9C6: 48
  LDA var_063c,Y                                         ; $A9C7: B9 3C 06
  TAY                                                 ; $A9CA: A8
  LDA AdvisorTileTbl0_Lo,Y                            ; $A9CB: B9 E4 AA
  STA param_byte2B0                                           ; $A9CE: 8D B0 01
  LDA AdvisorTileTbl0_Hi,Y                            ; $A9D1: B9 EF AA
  STA param_byte2B1                                           ; $A9D4: 8D B1 01
  PLA                                                 ; $A9D7: 68
  TAY                                                 ; $A9D8: A8
  BEQ @type0_ruler_special                            ; $A9D9: F0 04
  CMP #$0A                                            ; $A9DB: C9 0A
  BNE @type0_overrides_done                           ; $A9DD: D0 16
@type0_ruler_special:
  LDA #$BB                                            ; $A9DF: A9 BB
  STA param_byte2B0                                           ; $A9E1: 8D B0 01
  LDA var_063c,Y                                         ; $A9E4: B9 3C 06
  CMP #$0A                                            ; $A9E7: C9 0A
  BNE @type0_overrides_done                           ; $A9E9: D0 0A
  LDA #$BA                                            ; $A9EB: A9 BA
  STA param_byte2B0                                           ; $A9ED: 8D B0 01
  LDA #$AB                                            ; $A9F0: A9 AB
  STA param_byte2B1                                           ; $A9F2: 8D B1 01
@type0_overrides_done:
  LDA #$AE                                            ; $A9F5: A9 AE
  STA param_byte2B2                                           ; $A9F7: 8D B2 01
  LDA #$AF                                            ; $A9FA: A9 AF
  STA param_byte2B3                                           ; $A9FC: 8D B3 01
  LDA var_0628,Y                                         ; $A9FF: B9 28 06
  AND #$03                                            ; $AA02: 29 03
  BNE @type0_subtile_not0                             ; $AA04: D0 0A
  LDA #$BD                                            ; $AA06: A9 BD
  STA param_byte2B2                                           ; $AA08: 8D B2 01
  LDA #$BE                                            ; $AA0B: A9 BE
  STA param_byte2B3                                           ; $AA0D: 8D B3 01
@type0_subtile_not0:
  LDA var_0628,Y                                         ; $AA10: B9 28 06
  AND #$03                                            ; $AA13: 29 03
  CMP #$01                                            ; $AA15: C9 01
  BNE @type0_subtile_not1                             ; $AA17: D0 0A
  LDA #$AC                                            ; $AA19: A9 AC
  STA param_byte2B2                                           ; $AA1B: 8D B2 01
  LDA #$AD                                            ; $AA1E: A9 AD
  STA param_byte2B3                                           ; $AA20: 8D B3 01
@type0_subtile_not1:
  RTS                                                 ; $AA23: 60
@type1:
  PLA                                                 ; $AA24: 68
  TAY                                                 ; $AA25: A8
  PHA                                                 ; $AA26: 48
  LDA var_063c,Y                                         ; $AA27: B9 3C 06
  TAY                                                 ; $AA2A: A8
  LDA AdvisorTileTbl1_Lo,Y                            ; $AA2B: B9 FA AA
  STA param_byte2B0                                           ; $AA2E: 8D B0 01
  LDA AdvisorTileTbl1_Hi,Y                            ; $AA31: B9 05 AB
  STA param_byte2B1                                           ; $AA34: 8D B1 01
  PLA                                                 ; $AA37: 68
  TAY                                                 ; $AA38: A8
  BEQ @type1_ruler_special                            ; $AA39: F0 04
  CPY #$0A                                            ; $AA3B: C0 0A
  BNE @type1_overrides_done                           ; $AA3D: D0 16
@type1_ruler_special:
  LDA #$B1                                            ; $AA3F: A9 B1
  STA param_byte2B0                                           ; $AA41: 8D B0 01
  LDA var_063c,Y                                         ; $AA44: B9 3C 06
  CMP #$0A                                            ; $AA47: C9 0A
  BNE @type1_overrides_done                           ; $AA49: D0 0A
  LDA #$B0                                            ; $AA4B: A9 B0
  STA param_byte2B0                                           ; $AA4D: 8D B0 01
  LDA #$8B                                            ; $AA50: A9 8B
  STA param_byte2B1                                           ; $AA52: 8D B1 01
@type1_overrides_done:
  LDA #$8C                                            ; $AA55: A9 8C
  STA param_byte2B2                                           ; $AA57: 8D B2 01
  LDA #$8D                                            ; $AA5A: A9 8D
  STA param_byte2B3                                           ; $AA5C: 8D B3 01
  LDA var_0628,Y                                         ; $AA5F: B9 28 06
  AND #$03                                            ; $AA62: 29 03
  BNE @type1_subtile_not0                             ; $AA64: D0 0A
  LDA #$B3                                            ; $AA66: A9 B3
  STA param_byte2B2                                           ; $AA68: 8D B2 01
  LDA #$B4                                            ; $AA6B: A9 B4
  STA param_byte2B3                                           ; $AA6D: 8D B3 01
@type1_subtile_not0:
  LDA var_0628,Y                                         ; $AA70: B9 28 06
  AND #$03                                            ; $AA73: 29 03
  CMP #$02                                            ; $AA75: C9 02
  BNE @type1_subtile_not2                             ; $AA77: D0 0A
  LDA #$8E                                            ; $AA79: A9 8E
  STA param_byte2B2                                           ; $AA7B: 8D B2 01
  LDA #$8F                                            ; $AA7E: A9 8F
  STA param_byte2B3                                           ; $AA80: 8D B3 01
@type1_subtile_not2:
  RTS                                                 ; $AA83: 60
@type2:
  PLA                                                 ; $AA84: 68
  TAY                                                 ; $AA85: A8
  PHA                                                 ; $AA86: 48
  LDA var_063c,Y                                         ; $AA87: B9 3C 06
  TAY                                                 ; $AA8A: A8
  LDA AdvisorTileTbl2_Lo,Y                            ; $AA8B: B9 10 AB
  STA param_byte2B0                                           ; $AA8E: 8D B0 01
  LDA AdvisorTileTbl2_Hi,Y                            ; $AA91: B9 1B AB
  STA param_byte2B1                                           ; $AA94: 8D B1 01
  PLA                                                 ; $AA97: 68
  TAY                                                 ; $AA98: A8
  BEQ @type2_ruler_special                            ; $AA99: F0 04
  CPY #$0A                                            ; $AA9B: C0 0A
  BNE @type2_overrides_done                           ; $AA9D: D0 16
@type2_ruler_special:
  LDA #$B6                                            ; $AA9F: A9 B6
  STA param_byte2B0                                           ; $AAA1: 8D B0 01
  LDA var_063c,Y                                         ; $AAA4: B9 3C 06
  CMP #$0A                                            ; $AAA7: C9 0A
  BNE @type2_overrides_done                           ; $AAA9: D0 0A
  LDA #$B5                                            ; $AAAB: A9 B5
  STA param_byte2B0                                           ; $AAAD: 8D B0 01
  LDA #$9B                                            ; $AAB0: A9 9B
  STA param_byte2B1                                           ; $AAB2: 8D B1 01
@type2_overrides_done:
  LDA #$9C                                            ; $AAB5: A9 9C
  STA param_byte2B2                                           ; $AAB7: 8D B2 01
  LDA #$9D                                            ; $AABA: A9 9D
  STA param_byte2B3                                           ; $AABC: 8D B3 01
  LDA var_0628,Y                                         ; $AABF: B9 28 06
  AND #$03                                            ; $AAC2: 29 03
  BNE @type2_subtile_not0                             ; $AAC4: D0 0A
  LDA #$B8                                            ; $AAC6: A9 B8
  STA param_byte2B2                                           ; $AAC8: 8D B2 01
  LDA #$B9                                            ; $AACB: A9 B9
  STA param_byte2B3                                           ; $AACD: 8D B3 01
@type2_subtile_not0:
  LDA var_0628,Y                                         ; $AAD0: B9 28 06
  AND #$03                                            ; $AAD3: 29 03
  CMP #$02                                            ; $AAD5: C9 02
  BNE @type2_subtile_not2                             ; $AAD7: D0 0A
  LDA #$9E                                            ; $AAD9: A9 9E
  STA param_byte2B2                                           ; $AADB: 8D B2 01
  LDA #$9F                                            ; $AADE: A9 9F
  STA param_byte2B3                                           ; $AAE0: 8D B3 01
@type2_subtile_not2:
  RTS                                                 ; $AAE3: 60
; Dialogue type 0 tile tables
AdvisorTileTbl0_Lo:                                   ; $AAE4
  .byte $BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$AA   ; $AAE4-$AAEE (11 bytes)
AdvisorTileTbl0_Hi:                                   ; $AAEF
  .byte $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AB   ; $AAEF-$AAF9 (11 bytes)
; Dialogue type 1 tile tables
AdvisorTileTbl1_Lo:                                   ; $AAFA
  .byte $B2,$B2,$B2,$B2,$B2,$B2,$B2,$B2,$B2,$B2,$8A   ; $AAFA-$AB04 (11 bytes)
AdvisorTileTbl1_Hi:                                   ; $AB05
  .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8B   ; $AB05-$AB0F (11 bytes)
; Dialogue type 2 tile tables
AdvisorTileTbl2_Lo:                                   ; $AB10
  .byte $B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$9A   ; $AB10-$AB1A (11 bytes)
AdvisorTileTbl2_Hi:                                   ; $AB1B
  .byte $90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9B   ; $AB1B-$AB25 (11 bytes)
.endproc
;===============================================================================
; $AB26: CalcTileGridOrigin
; Converts scroll coordinates to tile grid indices
;===============================================================================
.proc CalcTileGridOrigin
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
  coord_ptr_lo     = $000E
  coord_ptr_hi     = $000F
  ptr_0018_lo     = $0018
  ptr_0018_hi     = $0019
CalcTileGridOrigin:
  LDA attr_ptr_lo                                         ; $AB26: AD 0C 00
  STA ptr_0018_lo                                         ; $AB29: 8D 18 00
  LDA attr_ptr_hi                                         ; $AB2C: AD 0D 00
  LSR A                                               ; $AB2F: 4A
  ROR ptr_0018_lo                                         ; $AB30: 6E 18 00
  LSR ptr_0018_lo                                         ; $AB33: 4E 18 00
  LSR ptr_0018_lo                                         ; $AB36: 4E 18 00
  LSR ptr_0018_lo                                         ; $AB39: 4E 18 00
  LDA ptr_000e_lo                                         ; $AB3C: AD 0E 00
  STA ptr_0018_hi                                         ; $AB3F: 8D 19 00
  LDA ptr_000e_hi                                         ; $AB42: AD 0F 00
  LSR A                                               ; $AB45: 4A
  ROR ptr_0018_hi                                         ; $AB46: 6E 19 00
  LSR ptr_0018_hi                                         ; $AB49: 4E 19 00
  LSR ptr_0018_hi                                         ; $AB4C: 4E 19 00
  LSR ptr_0018_hi                                         ; $AB4F: 4E 19 00
  RTS                                                 ; $AB52: 60
.endproc

;===============================================================================
; $AB53: BattleEffects
; Entry05: Battle visual effects (animations, palette, sprites)
;-------------------------------------------------------------------------------
; Checks if the battle scene column or palette row has changed. If the scene
; column changed, dispatches to overlay reload (DispatchOverlayMode). If only the palette
; changed, dispatches to palette update (DispatchPaletteSetup).
;-------------------------------------------------------------------------------
; Inputs:  $008E-$0091 = scene coordinates (X lo/hi, Y lo/hi)
;          $0094 = cached palette index, $0095 = cached scene column
;          $009C = render mode flags (bit 7 = animated, bit 4 = palette mode)
;===============================================================================
.proc BattleEffects
BattleEffects:
  ; Compute scene column index = ($008E - 6) >> 3 and compare to cached $0095.
  LDA a:$008E                                         ; $AB53: AD 8E 00
  SEC                                                 ; $AB56: 38
  SBC #$06                                            ; $AB57: E9 06
  LSR A                                               ; $AB59: 4A
  LSR A                                               ; $AB5A: 4A
  LSR A                                               ; $AB5B: 4A
  CMP a:$0095                                         ; $AB5C: CD 95 00
  BEQ @skip                                           ; $AB5F: F0 07
  STA a:$0095                                         ; $AB61: 8D 95 00
  JSR DispatchOverlayMode                             ; $AB64: 20 7B AB
  RTS                                                 ; $AB67: 60
@skip:
  ; Compute palette row index = $0090 >> 4 and compare to cached $0094.
  LDA a:$0090                                         ; $AB68: AD 90 00
  LSR A                                               ; $AB6B: 4A
  LSR A                                               ; $AB6C: 4A
  LSR A                                               ; $AB6D: 4A
  LSR A                                               ; $AB6E: 4A
  CMP a:$0094                                         ; $AB6F: CD 94 00
  BEQ @skip_2                                         ; $AB72: F0 06
  STA a:$0094                                         ; $AB74: 8D 94 00
  JSR DispatchPaletteSetup                            ; $AB77: 20 87 AB
@skip_2:
  RTS                                                 ; $AB7A: 60
;-------------------------------------------------------------------------------
; Sub-entry: DispatchOverlayMode
; Dispatch overlay render based on bit 7 of $009C.
;   bit 7 set   → full overlay render (BattleOverlayRender)
;   bit 7 clear → simple overlay copy (BattleOverlayCopy)
;-------------------------------------------------------------------------------
DispatchOverlayMode:
  LDA a:$009C                                         ; $AB7B: AD 9C 00
  ASL A                                               ; $AB7E: 0A
  BMI @skip_3                                         ; $AB7F: 30 03
  JMP BattleOverlayCopy                               ; $AB81: 4C 69 AD
@skip_3:
  JMP BattleOverlayRender                             ; $AB84: 4C 94 AB
;-------------------------------------------------------------------------------
; Sub-entry: DispatchPaletteSetup
; Dispatch palette update based on bit 4 of $009C.
;   bit 4 set   → offset palette setup (SetScrollWorkOffset4)
;   bit 4 clear → offset palette setup with decompression (LoadBattleOverlayWithOffset)
;-------------------------------------------------------------------------------
DispatchPaletteSetup:
  LDA a:$009C                                         ; $AB87: AD 9C 00
  AND #$10                                            ; $AB8A: 29 10
  BEQ @skip_4                                         ; $AB8C: F0 03
  JMP SetScrollWorkOffset4                            ; $AB8E: 4C 9F AD
@skip_4:
  JMP LoadBattleOverlayWithOffset                                        ; $AB91: 4C B5 AE
.endproc
;===============================================================================
; $AB94: BattleOverlayRender
; Full overlay render: sets up 4 work pointers from scene coordinates, then
; iterates over overlay tiles, merging primary/secondary attributes with
; adjacency-based patching, and uploads result to PPU.
;-------------------------------------------------------------------------------
; Pointers set up:
;   ($000C-$000D) = ($008E, $008F)           primary overlay data
;   ($000E-$000F) = ($0090, $0091)           secondary overlay data
;   ($001C-$001D) = ($008E, $008F + 1)       next-row primary data
;   ($001E-$001F) = ($0090, $0091)           next-row secondary data
;-------------------------------------------------------------------------------
; ZP usage during loop:
;   $0002 = working attribute byte (primary)
;   $0003 = secondary attribute byte
;   $0005 = tile index in attribute table
;   $0006 = column counter
;   $0007 = tiles per row (8 or 9)
;   $0008 = temp: tile row component
;   $000A = primary overlay table offset
;   $001A = secondary overlay table offset
;===============================================================================
.proc BattleOverlayRender
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  tile_attr_byte      = $0002
  param_0003      = $0003
  tile_col_index  = $0005
  current_row       = $0006
  max_rows       = $0007
  attr_base_offset      = $0008
  overlay_data_ptr          = $000A
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
  coord_ptr_lo     = $000E
  coord_ptr_hi     = $000F
  var_0010        = $0010
  temp_0017       = $0017
  ptr_0019_lo     = $0019
  ptr_0019_hi     = $001A
  ptr_001c_lo     = $001C
  ptr_001c_hi     = $001D
  ptr_001e_lo     = $001E
  ptr_001e_hi     = $001F
  bank_switch_ptr        = $00A8
BattleOverlayRender:
  ; Set up 4 source pointers from scene coordinates.
  LDA a:$008E                                         ; $AB94: AD 8E 00
  STA attr_ptr_lo                                         ; $AB97: 8D 0C 00
  LDA a:$008F                                         ; $AB9A: AD 8F 00
  STA attr_ptr_hi                                         ; $AB9D: 8D 0D 00
  LDA a:$0090                                         ; $ABA0: AD 90 00
  STA ptr_000e_lo                                         ; $ABA3: 8D 0E 00
  LDA a:$0091                                         ; $ABA6: AD 91 00
  STA ptr_000e_hi                                         ; $ABA9: 8D 0F 00
  LDA a:$008E                                         ; $ABAC: AD 8E 00
  STA ptr_001c_lo                                         ; $ABAF: 8D 1C 00
  LDA a:$008F                                         ; $ABB2: AD 8F 00
  STA ptr_001c_hi                                         ; $ABB5: 8D 1D 00
  INC ptr_001c_hi                                         ; $ABB8: EE 1D 00 (next row: $008F + 1)
  LDA a:$0090                                         ; $ABBB: AD 90 00
  STA ptr_001e_lo                                         ; $ABBE: 8D 1E 00
  LDA a:$0091                                         ; $ABC1: AD 91 00
  STA ptr_001e_hi                                         ; $ABC4: 8D 1F 00
;-------------------------------------------------------------------------------
; Shared entry: BattleOverlayLoop
; Also jumped to from BattleOverlayCopy after its pointer setup.
;-------------------------------------------------------------------------------
BattleOverlayLoop:
  ; Look up primary overlay index from ($000C-$000F) via bank pointer table,
  ; then switch bank and load overlay graphics pointer into ($0000).
  JSR BankPtrLookup                                   ; $ABC7: 20 04 A6
  STY ptr_lo                                         ; $ABCA: 8C 0A 00
  JSR LoadOverlayPrimary                              ; $ABCD: 20 F3 AE
  ; Advance to next table entry (+2 bytes) and read next overlay index.
  LDA ptr_lo                                         ; $ABD0: AD 0A 00
  CLC                                                 ; $ABD3: 18
  ADC #$02                                            ; $ABD4: 69 02
  TAY                                                 ; $ABD6: A8
  LDA (var_00a8),Y                                         ; $ABD7: B1 A8
  STA ptr_lo                                         ; $ABD9: 8D 0A 00
  ; Look up secondary overlay from ($001C-$001F) and load pointer into ($0010).
  JSR BankPtrLookupAlt                                ; $ABDC: 20 10 A6
  STY ptr_0019_hi                                         ; $ABDF: 8C 1A 00
  JSR LoadOverlaySecondary                            ; $ABE2: 20 0C AF
  LDA ptr_0019_hi                                         ; $ABE5: AD 1A 00
  CLC                                                 ; $ABE8: 18
  ADC #$02                                            ; $ABE9: 69 02
  TAY                                                 ; $ABEB: A8
  LDA (var_00a8),Y                                         ; $ABEC: B1 A8
  STA ptr_0019_hi                                         ; $ABEE: 8D 1A 00
  ; Initialize column counter to 0.
  LDX #$00                                            ; $ABF1: A2 00
  STX row_limit                                         ; $ABF3: 8E 06 00
  ; Compute starting tile index:
  ;   tile_idx = ($000C >> 5) + (($000E & $E0) >> 2)
  ; Maps scene coordinates to a position in the PPU attribute table.
  LDA attr_ptr_lo                                         ; $ABF6: AD 0C 00
  LSR A                                               ; $ABF9: 4A
  LSR A                                               ; $ABFA: 4A
  LSR A                                               ; $ABFB: 4A
  LSR A                                               ; $ABFC: 4A
  LSR A                                               ; $ABFD: 4A
  STA param_0008                                         ; $ABFE: 8D 08 00
  LDA ptr_000e_lo                                         ; $AC01: AD 0E 00
  AND #$E0                                            ; $AC04: 29 E0
  LSR A                                               ; $AC06: 4A
  LSR A                                               ; $AC07: 4A
  CLC                                                 ; $AC08: 18
  ADC param_0008                                         ; $AC09: 6D 08 00
  STA col_counter_hi                                         ; $AC0C: 8D 05 00
  ; Build adjacency map: clear $0680-$06FF, then populate from sprite
  ; data in $0600-$0613 (20 OAM entries).
  JSR BuildAdjacencyMap                               ; $AC0F: 20 F9 AF
  ; Determine tiles per row: 8 normally, 9 if bit 4 of $000E is set
  ; (scene straddles a tile boundary).
  LDX #$00                                            ; $AC12: A2 00
  LDA #$08                                            ; $AC14: A9 08
  STA row_count                                         ; $AC16: 8D 07 00
  LDA ptr_000e_lo                                         ; $AC19: AD 0E 00
  AND #$10                                            ; $AC1C: 29 10
  BEQ @loop_2                                         ; $AC1E: F0 03
  INC row_count                                         ; $AC20: EE 07 00
@loop_2:
  ; Inner loop: process one tile in the current row.
  ; Load primary overlay attribute byte from ($0000),Y.
  LDY col_counter_hi                                         ; $AC23: AC 05 00
  LDA (param_byte1),Y                                         ; $AC26: B1 00
  STA rle_marker                                         ; $AC28: 8D 02 00
  ; Load secondary overlay attribute from ($0010),Y.
  LDA (var_0010),Y                                         ; $AC2B: B1 10
  STA param_0003                                         ; $AC2D: 8D 03 00
  ; Patch attribute based on adjacency map ($0680-$06FF).
  JSR PatchAttrAdjacency                              ; $AC30: 20 1B AF
  ; Advance source data pointers by 2 (next entry pair).
  INC temp_0017                                         ; $AC33: EE 17 00
  INC temp_0017                                         ; $AC36: EE 17 00
  INC ptr_0019_lo                                         ; $AC39: EE 19 00
  INC ptr_0019_lo                                         ; $AC3C: EE 19 00
  ; Write patched attribute to PPU buffer $018A+X, handling 2x2 block
  ; splitting at tile column 8.
  JSR WriteBattleAttribute                            ; $AC3F: 20 80 AC
  ; Advance tile index by 8 (next row in attribute table space).
  LDA col_counter_hi                                         ; $AC42: AD 05 00
  CLC                                                 ; $AC45: 18
  ADC #$08                                            ; $AC46: 69 08
  CMP #$40                                            ; $AC48: C9 40 (past end of attr table?)
  BCC @skip_6                                         ; $AC4A: 90 10
  ; Wrapped past $40: reload overlay data for next attribute page.
  AND #$07                                            ; $AC4C: 29 07 (keep low 3 bits)
  PHA                                                 ; $AC4E: 48
  LDA ptr_lo                                         ; $AC4F: AD 0A 00
  JSR LoadOverlayPrimary                              ; $AC52: 20 F3 AE (reload primary)
  LDA ptr_0019_hi                                         ; $AC55: AD 1A 00
  JSR LoadOverlaySecondary                            ; $AC58: 20 0C AF (reload secondary)
  PLA                                                 ; $AC5B: 68
@skip_6:
  STA col_counter_hi                                         ; $AC5C: 8D 05 00
  ; Increment column counter; continue inner loop if not done.
  INC row_limit                                         ; $AC5F: EE 06 00
  LDA row_limit                                         ; $AC62: AD 06 00
  CMP row_count                                         ; $AC65: CD 07 00
  BCC @loop_2                                         ; $AC68: 90 B9
  ; Row complete: upload attribute data to PPU at VRAM $0188.
  LDA #$88                                            ; $AC6A: A9 88
  STA param_byte1                                         ; $AC6C: 8D 00 00
  LDA #$01                                            ; $AC6F: A9 01
  STA param_byte2                                         ; $AC71: 8D 01 00
  JSR LoadCHRCompressed                               ; $AC74: 20 D3 A8
  ; Set bit 5 of $007E to flag battle overlay needs redraw.
  LDA a:$007E                                         ; $AC77: AD 7E 00
  ORA #$20                                            ; $AC7A: 09 20
  STA a:$007E                                         ; $AC7C: 8D 7E 00
  RTS                                                 ; $AC7F: 60
.endproc
;===============================================================================
; $AC80: WriteBattleAttribute
; Write patched attribute byte to PPU buffer at $018A+X.
;-------------------------------------------------------------------------------
; Bit 7 of $009C selects the attribute-masking strategy:
;   bit 7 set   → "animated" path: merge with masks $CC/$33
;   bit 7 clear → "static" path: merge with complementary masks $33/$CC
; Both paths check bit 4 of $000C (left/right half) and column-8 boundary
; to correctly split 2x2 attribute blocks.
;===============================================================================
.proc WriteBattleAttribute
  tile_attr_byte      = $0002
  param_0003      = $0003
  current_row       = $0006
  scene_coord_ptr     = $000C
  coord_high_bits      = $000E
  var_018a        = $018A
WriteBattleAttribute:
  LDA a:$009C                                         ; $AC80: AD 9C 00
  ASL A                                               ; $AC83: 0A
  BPL @static_path                                    ; $AC84: 10 6E (bit 7 clear → static)
  ; === Animated attribute path (bit 7 set) ===
  ; Check bit 4 of $000C: left or right half of attribute byte.
  LDA attr_ptr_lo                                         ; $AC86: AD 0C 00
  AND #$10                                            ; $AC89: 29 10
  BNE @anim_right                                     ; $AC8B: D0 2B
  ; Left half: at column 8 + Y boundary, merge low nibble into existing.
  LDA row_limit                                         ; $AC8D: AD 06 00
  CMP #$08                                            ; $AC90: C9 08 (at column boundary?)
  BNE @anim_simple                                    ; $AC92: D0 1C
  LDA param_000e                                         ; $AC94: AD 0E 00
  AND #$10                                            ; $AC97: 29 10 (check Y boundary)
  BEQ @anim_simple                                    ; $AC99: F0 15
  ; Merge low nibble of new attr into high nibble of existing $018A byte.
  LDA var_018a                                           ; $AC9B: AD 8A 01
  AND #$F0                                            ; $AC9E: 29 F0 (keep high nibble)
  STA var_018a                                           ; $ACA0: 8D 8A 01
  LDA rle_marker                                         ; $ACA3: AD 02 00
  AND #$0F                                            ; $ACA6: 29 0F (take low nibble)
  ORA var_018a                                           ; $ACA8: 0D 8A 01
  STA var_018a                                           ; $ACAB: 8D 8A 01
  INX                                                 ; $ACAE: E8
  RTS                                                 ; $ACAF: 60
@anim_simple:
  ; Simple write: store attribute byte directly.
  LDA rle_marker                                         ; $ACB0: AD 02 00
  STA var_018a,X                                         ; $ACB3: 9D 8A 01
  INX                                                 ; $ACB6: E8
  RTS                                                 ; $ACB7: 60
@anim_right:
  ; Right half: merge palette bits at column-8 boundary.
  LDA row_limit                                         ; $ACB8: AD 06 00
  CMP #$08                                            ; $ACBB: C9 08
  BNE @anim_masked                                    ; $ACBD: D0 20 (not at boundary)
  ; At boundary: combine bits 3-2 from primary, bits 1-0 from secondary,
  ; merge with existing high nibble of $018A.
  LDA var_018a                                           ; $ACBF: AD 8A 01
  AND #$F0                                            ; $ACC2: 29 F0 (keep high nibble)
  STA var_018a                                           ; $ACC4: 8D 8A 01
  LDA rle_marker                                         ; $ACC7: AD 02 00
  AND #$0C                                            ; $ACCA: 29 0C (bits 3-2 from primary)
  STA rle_marker                                         ; $ACCC: 8D 02 00
  LDA param_0003                                         ; $ACCF: AD 03 00
  AND #$03                                            ; $ACD2: 29 03 (bits 1-0 from secondary)
  ORA rle_marker                                         ; $ACD4: 0D 02 00
  ORA var_018a                                           ; $ACD7: 0D 8A 01
  STA var_018a                                           ; $ACDA: 8D 8A 01
  INX                                                 ; $ACDD: E8
  RTS                                                 ; $ACDE: 60
@anim_masked:
  ; Masked write: bits 7,6,3,2 from primary; bits 5,4,1,0 from secondary.
  LDA rle_marker                                         ; $ACDF: AD 02 00
  AND #$CC                                            ; $ACE2: 29 CC (mask primary)
  STA rle_marker                                         ; $ACE4: 8D 02 00
  LDA param_0003                                         ; $ACE7: AD 03 00
  AND #$33                                            ; $ACEA: 29 33 (mask secondary)
  ORA rle_marker                                         ; $ACEC: 0D 02 00
  STA var_018a,X                                         ; $ACEF: 9D 8A 01
  INX                                                 ; $ACF2: E8
  RTS                                                 ; $ACF3: 60
;-------------------------------------------------------------------------------
; Static attribute path (bit 7 clear)
; Same structure as animated path but with complementary masks ($33/$CC).
;-------------------------------------------------------------------------------
@static_path:
  LDA attr_ptr_lo                                         ; $ACF4: AD 0C 00
  AND #$10                                            ; $ACF7: 29 10
  BEQ @static_left                                    ; $ACF9: F0 2B
  ; Right half.
  LDA row_limit                                         ; $ACFB: AD 06 00
  CMP #$08                                            ; $ACFE: C9 08
  BNE @static_right_masked                            ; $AD00: D0 1C
  LDA param_000e                                         ; $AD02: AD 0E 00
  AND #$10                                            ; $AD05: 29 10
  BEQ @static_right_masked                            ; $AD07: F0 15
  ; Column-8 + Y boundary: merge low nibble.
  LDA var_018a                                           ; $AD09: AD 8A 01
  AND #$F0                                            ; $AD0C: 29 F0
  STA var_018a                                           ; $AD0E: 8D 8A 01
  LDA rle_marker                                         ; $AD11: AD 02 00
  AND #$0F                                            ; $AD14: 29 0F
  ORA var_018a                                           ; $AD16: 0D 8A 01
  STA var_018a                                           ; $AD19: 8D 8A 01
  INX                                                 ; $AD1C: E8
  RTS                                                 ; $AD1D: 60
@static_right_masked:
  ; Simple write at $018A+X.
  LDA rle_marker                                         ; $AD1E: AD 02 00
  STA var_018a,X                                         ; $AD21: 9D 8A 01
  INX                                                 ; $AD24: E8
  RTS                                                 ; $AD25: 60
@static_left:
  ; Left half: at column 8 + Y boundary, merge complementary bits.
  LDA row_limit                                         ; $AD26: AD 06 00
  CMP #$08                                            ; $AD29: C9 08
  BNE @static_left_masked                             ; $AD2B: D0 27
  LDA param_000e                                         ; $AD2D: AD 0E 00
  AND #$10                                            ; $AD30: 29 10
  BEQ @static_left_masked                             ; $AD32: F0 20
  LDA var_018a                                           ; $AD34: AD 8A 01
  AND #$F0                                            ; $AD37: 29 F0
  STA var_018a                                           ; $AD39: 8D 8A 01
  LDA rle_marker                                         ; $AD3C: AD 02 00
  AND #$03                                            ; $AD3F: 29 03 (bits 1-0 from primary)
  STA rle_marker                                         ; $AD41: 8D 02 00
  LDA param_0003                                         ; $AD44: AD 03 00
  AND #$0C                                            ; $AD47: 29 0C (bits 3-2 from secondary)
  ORA rle_marker                                         ; $AD49: 0D 02 00
  ORA var_018a                                           ; $AD4C: 0D 8A 01
  STA var_018a                                           ; $AD4F: 8D 8A 01
  INX                                                 ; $AD52: E8
  RTS                                                 ; $AD53: 60
@static_left_masked:
  ; Masked write: complementary masks ($33/$CC vs animated $CC/$33).
  LDA rle_marker                                         ; $AD54: AD 02 00
  AND #$33                                            ; $AD57: 29 33 (bits 5,4,1,0 of primary)
  STA rle_marker                                         ; $AD59: 8D 02 00
  LDA param_0003                                         ; $AD5C: AD 03 00
  AND #$CC                                            ; $AD5F: 29 CC (bits 7,6,3,2 of secondary)
  ORA rle_marker                                         ; $AD61: 0D 02 00
  STA var_018a,X                                         ; $AD64: 9D 8A 01
  INX                                                 ; $AD67: E8
  RTS                                                 ; $AD68: 60
.endproc
;===============================================================================
; $AD69: BattleOverlayCopy
; Simple overlay copy path (bit 7 of $009C clear).
;-------------------------------------------------------------------------------
; Same pointer setup as full render, but Ptr1 high byte is incremented
; (shifted copy) instead of Ptr3. Then falls into BattleOverlayLoop.
;===============================================================================
.proc BattleOverlayCopy
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
  coord_ptr_lo     = $000E
  coord_ptr_hi     = $000F
  ptr_001c_lo     = $001C
  ptr_001c_hi     = $001D
  ptr_001e_lo     = $001E
  ptr_001e_hi     = $001F
BattleOverlayCopy:
  LDA a:$008E                                         ; $AD69: AD 8E 00
  STA attr_ptr_lo                                         ; $AD6C: 8D 0C 00
  LDA a:$008F                                         ; $AD6F: AD 8F 00
  STA attr_ptr_hi                                         ; $AD72: 8D 0D 00
  INC attr_ptr_hi                                         ; $AD75: EE 0D 00 (shifted copy: $008F + 1)
  LDA a:$0090                                         ; $AD78: AD 90 00
  STA ptr_000e_lo                                         ; $AD7B: 8D 0E 00
  LDA a:$0091                                         ; $AD7E: AD 91 00
  STA ptr_000e_hi                                         ; $AD81: 8D 0F 00
  LDA a:$008E                                         ; $AD84: AD 8E 00
  STA ptr_001c_lo                                         ; $AD87: 8D 1C 00
  LDA a:$008F                                         ; $AD8A: AD 8F 00
  STA ptr_001c_hi                                         ; $AD8D: 8D 1D 00
  LDA a:$0090                                         ; $AD90: AD 90 00
  STA ptr_001e_lo                                         ; $AD93: 8D 1E 00
  LDA a:$0091                                         ; $AD96: AD 91 00
  STA ptr_001e_hi                                         ; $AD99: 8D 1F 00
  JMP BattleOverlayLoop                               ; $AD9C: 4C C7 AB
.endproc
;===============================================================================
; $AD9F: SetScrollWorkOffset4
;===============================================================================
.proc SetScrollWorkOffset4
  scene_coord_ptr     = $000C
  work_ptr_hi     = $000D
  coord_ptr_lo     = $000E
  coord_ptr_hi     = $000F
SetScrollWorkOffset4:
  LDA a:$008E                                         ; $AD9F: AD 8E 00
  CLC                                                 ; $ADA2: 18
  ADC #$04                                            ; $ADA3: 69 04
  STA attr_ptr_lo                                         ; $ADA5: 8D 0C 00
  LDA a:$008F                                         ; $ADA8: AD 8F 00
  ADC #$00                                            ; $ADAB: 69 00
  STA attr_ptr_hi                                         ; $ADAD: 8D 0D 00
  LDA a:$0090                                         ; $ADB0: AD 90 00
  STA ptr_000e_lo                                         ; $ADB3: 8D 0E 00
  LDA a:$0091                                         ; $ADB6: AD 91 00
  STA ptr_000e_hi                                         ; $ADB9: 8D 0F 00
.endproc
;===============================================================================
; $ADBC: LoadBattleOverlay
; Reads overlay index from A, switches bank, decompresses CHR data,
; and performs adjacency-based attribute patching.
;-------------------------------------------------------------------------------
; Inputs:  A = overlay index (passed through to LoadOverlayPrimary)
;          $008E-$0091 = scene coordinates (X lo/hi, Y lo/hi)
; Output:  Decompressed overlay data uploaded to PPU at $0188
; Calls:   BankPtrLookup, LoadOverlayPrimary, BuildAdjacencyMapSmall,
;          PatchSingleAdjacency, LoadCHRCompressed
;===============================================================================
.proc LoadBattleOverlay
  ppu_addr_lo     = $0000
  ppu_addr_hi     = $0001
  tile_attr_byte      = $0002
  tile_col_index  = $0005
  current_row       = $0006
  max_rows       = $0007
  attr_base_offset      = $0008
  overlay_data_ptr          = $000A
  scene_coord_ptr     = $000C
  coord_high_bits      = $000E
  data_ptr_offset       = $0016
  adjacency_ptr_offset       = $0018
  bank_switch_ptr        = $00A8
  attr_accumulator        = $019E
LoadBattleOverlay:
  JSR BankPtrLookup                                           ; $ADBC: 20 04 A6
  STY overlay_data_ptr                                         ; $ADBF: 8C 0A 00
  JSR LoadOverlayPrimary                                 ; $ADC2: 20 F3 AE
  LDY overlay_data_ptr                                         ; $ADC5: AC 0A 00
  INY                                                 ; $ADC8: C8
  LDA (var_00a8),Y                                         ; $ADC9: B1 A8
  STA overlay_data_ptr                                         ; $ADCB: 8D 0A 00
  LDA #$00                                            ; $ADCE: A9 00
  STA current_row                                         ; $ADD0: 8D 06 00
  LDA scene_coord_ptr                                         ; $ADD3: AD 0C 00
  LSR A                                               ; $ADD6: 4A
  LSR A                                               ; $ADD7: 4A
  LSR A                                               ; $ADD8: 4A
  LSR A                                               ; $ADD9: 4A
  LSR A                                               ; $ADDA: 4A
  STA attr_base_offset                                         ; $ADDB: 8D 08 00
  LDA coord_high_bits                                         ; $ADDE: AD 0E 00
  AND #$E0                                            ; $ADE1: 29 E0
  LSR A                                               ; $ADE3: 4A
  LSR A                                               ; $ADE4: 4A
  CLC                                                 ; $ADE5: 18
  ADC attr_base_offset                                         ; $ADE6: 6D 08 00
  STA tile_col_index                                         ; $ADE9: 8D 05 00
  JSR BuildAdjacencyMapSmall                             ; $ADEC: 20 55 B0
  LDX #$00                                            ; $ADEF: A2 00
  LDA #$08                                            ; $ADF1: A9 08
  STA max_rows                                         ; $ADF3: 8D 07 00
  LDA scene_coord_ptr                                         ; $ADF6: AD 0C 00
  AND #$10                                            ; $ADF9: 29 10
  BEQ @loop                                           ; $ADFB: F0 03
  INC max_rows                                         ; $ADFD: EE 07 00
@loop:
  LDY tile_col_index                                         ; $AE00: AC 05 00
  LDA (ppu_addr_lo),Y                                         ; $AE03: B1 00
  STA tile_attr_byte                                         ; $AE05: 8D 02 00
  JSR PatchSingleAdjacency                               ; $AE08: 20 B5 AF
  INC data_ptr_offset                                         ; $AE0B: EE 16 00
  INC data_ptr_offset                                         ; $AE0E: EE 16 00
  INC adjacency_ptr_offset                                         ; $AE11: EE 18 00
  INC adjacency_ptr_offset                                         ; $AE14: EE 18 00
  JSR MergeAttrBits                                           ; $AE17: 20 58 AE
  LDA tile_col_index                                         ; $AE1A: AD 05 00
  INC tile_col_index                                         ; $AE1D: EE 05 00
  AND #$07                                            ; $AE20: 29 07
  CMP #$07                                            ; $AE22: C9 07
  BNE @skip                                           ; $AE24: D0 11
  LDA overlay_data_ptr                                         ; $AE26: AD 0A 00
  JSR LoadOverlayPrimary                                 ; $AE29: 20 F3 AE
  DEC tile_col_index                                         ; $AE2C: CE 05 00
  LDA tile_col_index                                         ; $AE2F: AD 05 00
  AND #$F8                                            ; $AE32: 29 F8
  STA tile_col_index                                         ; $AE34: 8D 05 00
@skip:
  INC current_row                                         ; $AE37: EE 06 00
  LDA current_row                                         ; $AE3A: AD 06 00
  CMP max_rows                                         ; $AE3D: CD 07 00
  BCC @loop                                           ; $AE40: 90 BE
  LDA #$9C                                            ; $AE42: A9 9C
  STA ppu_addr_lo                                         ; $AE44: 8D 00 00
  LDA #$01                                            ; $AE47: A9 01
  STA ppu_addr_hi                                         ; $AE49: 8D 01 00
  JSR LoadCHRCompressed                                  ; $AE4C: 20 D3 A8
  LDA a:$007E                                         ; $AE4F: AD 7E 00
  ORA #$10                                            ; $AE52: 09 10
  STA a:$007E                                         ; $AE54: 8D 7E 00
  RTS                                                 ; $AE57: 60
MergeAttrBits:
  LDA a:$009C                                         ; $AE58: AD 9C 00
  AND #$10                                            ; $AE5B: 29 10
  BEQ @skip_3                                           ; $AE5D: F0 2B
  LDA current_row                                         ; $AE5F: AD 06 00
  CMP #$08                                            ; $AE62: C9 08
  BNE @skip_2                                           ; $AE64: D0 1C
  LDA scene_coord_ptr                                         ; $AE66: AD 0C 00
  AND #$10                                            ; $AE69: 29 10
  BEQ @skip_2                                           ; $AE6B: F0 15
  LDA attr_accumulator                                           ; $AE6D: AD 9E 01
  AND #$CC                                            ; $AE70: 29 CC
  STA attr_accumulator                                           ; $AE72: 8D 9E 01
  LDA tile_attr_byte                                         ; $AE75: AD 02 00
  AND #$33                                            ; $AE78: 29 33
  ORA attr_accumulator                                           ; $AE7A: 0D 9E 01
  STA attr_accumulator                                           ; $AE7D: 8D 9E 01
  INX                                                 ; $AE80: E8
  RTS                                                 ; $AE81: 60
@skip_2:
  LDA tile_attr_byte                                         ; $AE82: AD 02 00
  STA attr_accumulator,X                                         ; $AE85: 9D 9E 01
  INX                                                 ; $AE88: E8
  RTS                                                 ; $AE89: 60
@skip_3:
  LDA current_row                                         ; $AE8A: AD 06 00
  CMP #$08                                            ; $AE8D: C9 08
  BNE @skip_4                                           ; $AE8F: D0 1C
  LDA scene_coord_ptr                                         ; $AE91: AD 0C 00
  AND #$10                                            ; $AE94: 29 10
  BEQ @skip_4                                           ; $AE96: F0 15
  LDA attr_accumulator                                           ; $AE98: AD 9E 01
  AND #$CC                                            ; $AE9B: 29 CC
  STA attr_accumulator                                           ; $AE9D: 8D 9E 01
  LDA tile_attr_byte                                         ; $AEA0: AD 02 00
  AND #$33                                            ; $AEA3: 29 33
  ORA attr_accumulator                                           ; $AEA5: 0D 9E 01
  STA attr_accumulator                                           ; $AEA8: 8D 9E 01
  INX                                                 ; $AEAB: E8
  RTS                                                 ; $AEAC: 60
@skip_4:
  LDA tile_attr_byte                                         ; $AEAD: AD 02 00
  STA attr_accumulator,X                                         ; $AEB0: 9D 9E 01
  INX                                                 ; $AEB3: E8
  RTS                                                 ; $AEB4: 60
.endproc
;===============================================================================
; $AEB5: LoadBattleOverlayWithOffset
; Adds $04 to X coordinate ($008E-$008F) and $A0 to Y coordinate ($0090-$0091)
; to compute the overlay data pointer, then jumps to LoadBattleOverlay.
;-------------------------------------------------------------------------------
; Inputs:  A = overlay index (passed through to LoadOverlayPrimary)
;          $008E-$0091 = scene coordinates (X lo/hi, Y lo/hi)
; Output:  ($000C-$000F) = computed work pointers, then calls LoadBattleOverlay
; Calls:   LoadBattleOverlay (tail call)
;===============================================================================
.proc LoadBattleOverlayWithOffset
  work_ptr_lo     = $000C
  work_ptr_hi     = $000D
  coord_ptr_lo     = $000E
  coord_ptr_hi     = $000F
LoadBattleOverlayWithOffset:
  LDA a:$008E                                         ; $AEB5: AD 8E 00
  CLC                                                 ; $AEB8: 18
  ADC #$04                                            ; $AEB9: 69 04
  STA work_ptr_lo                                         ; $AEBB: 8D 0C 00
  LDA a:$008F                                         ; $AEBE: AD 8F 00
  ADC #$00                                            ; $AEC1: 69 00
  STA work_ptr_hi                                         ; $AEC3: 8D 0D 00
  LDA a:$0090                                         ; $AEC6: AD 90 00
  CLC                                                 ; $AEC9: 18
  ADC #$A0                                            ; $AECA: 69 A0
  STA coord_ptr_lo                                         ; $AECC: 8D 0E 00
  BCS @skip                                           ; $AECF: B0 04
  CMP #$F0                                            ; $AED1: C9 F0
  BCC @skip_2                                           ; $AED3: 90 12
@skip:
  CLC                                                 ; $AED5: 18
  ADC #$10                                            ; $AED6: 69 10
  STA coord_ptr_lo                                         ; $AED8: 8D 0E 00
  LDA a:$0091                                         ; $AEDB: AD 91 00
  STA coord_ptr_hi                                         ; $AEDE: 8D 0F 00
  INC coord_ptr_hi                                         ; $AEE1: EE 0F 00
  JMP LoadBattleOverlay                                           ; $AEE4: 4C BC AD
@skip_2:
  LDA a:$0091                                         ; $AEE7: AD 91 00
  STA coord_ptr_hi                                         ; $AEEA: 8D 0F 00
  JMP LoadBattleOverlay                                           ; $AEED: 4C BC AD
.endproc

;===============================================================================
; $AEF0: OverlayWindow / LoadOverlayPrimary
; Overlay/window rendering (bank switch + dispatch)
;-------------------------------------------------------------------------------
; Entry07 (OverlayWindow): reads pointer from ($0000) then falls through
; LoadOverlayPrimary: loads primary overlay pointer into ($0000) from
;   BattleOverlayPtrTable, then switches CHR bank via B1F_SwitchBank8_B.
;-------------------------------------------------------------------------------
; Inputs:  A = overlay index
; Output:  ($0000) = pointer to primary overlay data, bank switched
;===============================================================================
.proc OverlayWindow
  param_byte1     = $0000
  ppu_addr_hi     = $0001
OverlayWindow:
  LDA param_byte1                                         ; $AEF0: AD 00 00
LoadOverlayPrimary:
  PHA                                                 ; $AEF3: 48
  ASL A                                               ; $AEF4: 0A
  TAY                                                 ; $AEF5: A8
  LDA BattleDispatch::BattleOverlayPtrTable,Y                         ; $AEF6: B9 32 A7
  STA param_byte1                                         ; $AEF9: 8D 00 00
  LDA BattleDispatch::BattleOverlayPtrTable+1,Y                       ; $AEFC: B9 33 A7
  STA param_byte2                                         ; $AEFF: 8D 01 00
  PLA                                                 ; $AF02: 68
  TAY                                                 ; $AF03: A8
  LDA BattleDispatch::BattleBankTable,Y                               ; $AF04: B9 22 A8
  TAY                                                 ; $AF07: A8
  JSR B1F_SwitchBank8_B                               ; $AF08: 20 5F F2
  RTS                                                 ; $AF0B: 60
.endproc
;===============================================================================
; $AF0C: LoadOverlaySecondary
; Load secondary overlay pointer into ($0010) from BattleOverlayPtrTable.
;-------------------------------------------------------------------------------
; Inputs:  A = overlay index
; Output:  ($0010) = pointer to secondary overlay data
;===============================================================================
.proc LoadOverlaySecondary
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
LoadOverlaySecondary:
  ASL A                                               ; $AF0C: 0A
  TAY                                                 ; $AF0D: A8
  LDA BattleOverlayPtrTable,Y                         ; $AF0E: B9 32 A7
  STA ptr_0010_lo                                         ; $AF11: 8D 10 00
  LDA BattleOverlayPtrTable+1,Y                       ; $AF14: B9 33 A7
  STA ptr_0010_hi                                         ; $AF17: 8D 11 00
  RTS                                                 ; $AF1A: 60
.endproc
;===============================================================================
; $AF1B: PatchAttrAdjacency
; Patch attribute bytes ($0002/$0003) based on adjacency map ($0680-$06FF).
; If bit 4 of ($000C + 8) is set, also patches secondary via
; PatchSecondaryAdjacency.
;===============================================================================
.proc PatchAttrAdjacency
  scene_coord_ptr     = $000C
PatchAttrAdjacency:
  LDA attr_ptr_lo                                         ; $AF1B: AD 0C 00
  CLC                                                 ; $AF1E: 18
  ADC #$08                                            ; $AF1F: 69 08
  AND #$10                                            ; $AF21: 29 10
  BEQ @skip                                           ; $AF23: F0 07
  JSR PatchPrimaryAdjacency                              ; $AF25: 20 30 AF
  JSR PatchSecondaryAdjacency                            ; $AF28: 20 71 AF
  RTS                                                 ; $AF2B: 60
@skip:
  JSR PatchPrimaryAdjacency                              ; $AF2C: 20 30 AF
  RTS                                                 ; $AF2F: 60
.endproc
;===============================================================================
; $AF30: PatchPrimaryAdjacency
; Patch primary attribute byte ($0002) based on adjacency map ($0680/$06A0).
; Checks 4 neighbors (up, down, left, right) and forces corresponding
; attribute bits: bit 1 (up), bit 3 (down), bit 5 (left), bit 7 (right).
;===============================================================================
.proc PatchPrimaryAdjacency
  tile_attr_byte      = $0002
  var_0019        = $0019
  adj_col_right       = $06A0  ; Primary layer: left-right neighbor column (tile_index_grid+32)
PatchPrimaryAdjacency:
  LDY var_0019                                         ; $AF30: AC 19 00
  LDA tile_index_grid,Y                                         ; $AF33: B9 80 06
  BMI @skip                                           ; $AF36: 30 0A
  LDA rle_marker                                         ; $AF38: AD 02 00
  AND #$FC                                            ; $AF3B: 29 FC
  ORA #$02                                            ; $AF3D: 09 02
  STA rle_marker                                         ; $AF3F: 8D 02 00
@skip:
  LDA adj_col_right,Y                                         ; $AF42: B9 A0 06
  BMI @skip_2                                           ; $AF45: 30 0A
  LDA rle_marker                                         ; $AF47: AD 02 00
  AND #$F3                                            ; $AF4A: 29 F3
  ORA #$08                                            ; $AF4C: 09 08
  STA rle_marker                                         ; $AF4E: 8D 02 00
@skip_2:
  INY                                                 ; $AF51: C8
  LDA tile_index_grid,Y                                         ; $AF52: B9 80 06
  BMI @skip_3                                           ; $AF55: 30 0A
  LDA rle_marker                                         ; $AF57: AD 02 00
  AND #$CF                                            ; $AF5A: 29 CF
  ORA #$20                                            ; $AF5C: 09 20
  STA rle_marker                                         ; $AF5E: 8D 02 00
@skip_3:
  LDA adj_col_right,Y                                         ; $AF61: B9 A0 06
  BMI @skip_4                                           ; $AF64: 30 0A
  LDA rle_marker                                         ; $AF66: AD 02 00
  AND #$3F                                            ; $AF69: 29 3F
  ORA #$80                                            ; $AF6B: 09 80
  STA rle_marker                                         ; $AF6D: 8D 02 00
@skip_4:
  RTS                                                 ; $AF70: 60
.endproc
;===============================================================================
; $AF71: PatchSecondaryAdjacency
; Patch secondary attribute byte ($0003) based on adjacency map ($06C0/$06E0).
; Same neighbor-check logic as PatchPrimaryAdjacency but for the secondary
; overlay layer. Also decrements $0017 (source pointer adjustment).
;===============================================================================
.proc PatchSecondaryAdjacency
  param_0003      = $0003
  temp_0017       = $0017
  var_0019        = $0019
  adj_sec_col_left    = $06C0  ; Secondary layer: up-down neighbor column (tile_index_grid+64)
  adj_sec_col_right   = $06E0  ; Secondary layer: left-right neighbor column (tile_index_grid+96)
PatchSecondaryAdjacency:
  LDY var_0019                                         ; $AF71: AC 19 00
  LDA adj_sec_col_left,Y                                         ; $AF74: B9 C0 06
  BMI @skip_5                                           ; $AF77: 30 0A
  LDA param_0003                                         ; $AF79: AD 03 00
  AND #$FC                                            ; $AF7C: 29 FC
  ORA #$02                                            ; $AF7E: 09 02
  STA param_0003                                         ; $AF80: 8D 03 00
@skip_5:
  LDA adj_sec_col_right,Y                                         ; $AF83: B9 E0 06
  BMI @skip_6                                           ; $AF86: 30 0A
  LDA param_0003                                         ; $AF88: AD 03 00
  AND #$F3                                            ; $AF8B: 29 F3
  ORA #$08                                            ; $AF8D: 09 08
  STA param_0003                                         ; $AF8F: 8D 03 00
@skip_6:
  INY                                                 ; $AF92: C8
  LDA adj_sec_col_left,Y                                         ; $AF93: B9 C0 06
  BMI @skip_7                                           ; $AF96: 30 0A
  LDA param_0003                                         ; $AF98: AD 03 00
  AND #$CF                                            ; $AF9B: 29 CF
  ORA #$20                                            ; $AF9D: 09 20
  STA param_0003                                         ; $AF9F: 8D 03 00
@skip_7:
  LDA adj_sec_col_right,Y                                         ; $AFA2: B9 E0 06
  BMI @skip_8                                           ; $AFA5: 30 0A
  LDA param_0003                                         ; $AFA7: AD 03 00
  AND #$3F                                            ; $AFAA: 29 3F
  ORA #$80                                            ; $AFAC: 09 80
  STA param_0003                                         ; $AFAE: 8D 03 00
@skip_8:
  DEC temp_0017                                         ; $AFB1: CE 17 00
  RTS                                                 ; $AFB4: 60
.endproc
;===============================================================================
; $AFB5: PatchSingleAdjacency
; Single-layer adjacency patch: checks $0680/$06A0 neighbors for $0002.
; Used by LoadBattleOverlay (alternate overlay path). Also decrements $0017.
;===============================================================================
.proc PatchSingleAdjacency
  tile_attr_byte      = $0002
  ptr_0017_lo     = $0017
  ptr_0017_hi     = $0018
  adj_col_right       = $06A0  ; Primary layer: left-right neighbor column (tile_index_grid+32)
PatchSingleAdjacency:
  LDY ptr_0017_hi                                         ; $AFB5: AC 18 00
  LDA tile_index_grid,Y                                         ; $AFB8: B9 80 06
  BMI @skip_9                                           ; $AFBB: 30 0A
  LDA rle_marker                                         ; $AFBD: AD 02 00
  AND #$FC                                            ; $AFC0: 29 FC
  ORA #$02                                            ; $AFC2: 09 02
  STA rle_marker                                         ; $AFC4: 8D 02 00
@skip_9:
  LDA adj_col_right,Y                                         ; $AFC7: B9 A0 06
  BMI @skip_10                                           ; $AFCA: 30 0A
  LDA rle_marker                                         ; $AFCC: AD 02 00
  AND #$CF                                            ; $AFCF: 29 CF
  ORA #$20                                            ; $AFD1: 09 20
  STA rle_marker                                         ; $AFD3: 8D 02 00
@skip_10:
  INY                                                 ; $AFD6: C8
  LDA var_0680,Y                                         ; $AFD7: B9 80 06
  BMI @skip_11                                           ; $AFDA: 30 0A
  LDA rle_marker                                         ; $AFDC: AD 02 00
  AND #$F3                                            ; $AFDF: 29 F3
  ORA #$08                                            ; $AFE1: 09 08
  STA rle_marker                                         ; $AFE3: 8D 02 00
@skip_11:
  LDA var_06a0,Y                                         ; $AFE6: B9 A0 06
  BMI @skip_12                                           ; $AFE9: 30 0A
  LDA rle_marker                                         ; $AFEB: AD 02 00
  AND #$3F                                            ; $AFEE: 29 3F
  ORA #$80                                            ; $AFF0: 09 80
  STA rle_marker                                         ; $AFF2: 8D 02 00
@skip_12:
  DEC ptr_0017_lo                                         ; $AFF5: CE 17 00
  RTS                                                 ; $AFF8: 60
.endproc
;===============================================================================
; $AFF9: BuildAdjacencyMap
; Build adjacency map for 8x8 overlay tiles.
; Clears $0680-$06FF to $FF, then populates entries from OAM sprite data
; in $0600-$0613 (20 entries) via PopulateAdjacencyEntries.
;===============================================================================
.proc BuildAdjacencyMap
BuildAdjacencyMap:
  JSR PrepareAdjacencyPtrs                                   ; $AFF9: 20 8F B0
  LDY #$7F                                            ; $AFFC: A0 7F
  LDA #$FF                                            ; $AFFE: A9 FF
@loop:
  STA tile_index_grid,Y                                         ; $B000: 99 80 06
  DEY                                                 ; $B003: 88
  BPL @loop                                           ; $B004: 10 FA
  LDY #$13                                            ; $B006: A0 13
@loop_2:
  JSR PopulateAdjacencyEntries                           ; $B008: 20 0F B0
  DEY                                                 ; $B00B: 88
  BPL @loop_2                                           ; $B00C: 10 FA
  RTS                                                 ; $B00E: 60
.endproc
;===============================================================================
; $B00F: PopulateAdjacencyEntries
; Populate one adjacency entry: matches sprite Y/X coordinates ($0600/$0614)
; against current tile position and records OAM index in $0680/$06A0/$06C0/$06E0.
;===============================================================================
.proc PopulateAdjacencyEntries
  work_0016       = $0016
  work_0018       = $0018
  oam_y_pos        = $0600  ; OAM sprite Y position (reuses tile_grid_coord_x memory)
  oam_x_pos        = $0614  ; OAM sprite X position (reuses tile_grid_coord_y memory)
  adj_col_right     = $06A0  ; Primary layer: left-right neighbor column (tile_index_grid+32)
  adj_sec_col_left  = $06C0  ; Secondary layer: up-down neighbor column (tile_index_grid+64)
  adj_sec_col_right = $06E0  ; Secondary layer: left-right neighbor column (tile_index_grid+96)
PopulateAdjacencyEntries:
  LDA oam_y_pos,Y                                         ; $B00F: B9 00 06
  CMP work_0018                                         ; $B012: CD 18 00
  BNE @skip_13                                           ; $B015: D0 09
  PHA                                                 ; $B017: 48
  LDX oam_x_pos,Y                                         ; $B018: BE 14 06
  TYA                                                 ; $B01B: 98
  STA tile_index_grid,X                                         ; $B01C: 9D 80 06
  PLA                                                 ; $B01F: 68
@skip_13:
  INC work_0018                                         ; $B020: EE 18 00
  CMP work_0018                                         ; $B023: CD 18 00
  BNE @skip_14                                           ; $B026: D0 09
  PHA                                                 ; $B028: 48
  LDX oam_x_pos,Y                                         ; $B029: BE 14 06
  TYA                                                 ; $B02C: 98
  STA adj_col_right,X                                         ; $B02D: 9D A0 06
  PLA                                                 ; $B030: 68
@skip_14:
  CMP work_0016                                         ; $B031: CD 16 00
  BNE @skip_15                                           ; $B034: D0 09
  PHA                                                 ; $B036: 48
  LDX oam_x_pos,Y                                         ; $B037: BE 14 06
  TYA                                                 ; $B03A: 98
  STA adj_sec_col_left,X                                         ; $B03B: 9D C0 06
  PLA                                                 ; $B03E: 68
@skip_15:
  INC work_0016                                         ; $B03F: EE 16 00
  CMP work_0016                                         ; $B042: CD 16 00
  BNE @skip_16                                           ; $B045: D0 07
  LDX oam_x_pos,Y                                         ; $B047: BE 14 06
  TYA                                                 ; $B04A: 98
  STA adj_sec_col_right,X                                         ; $B04B: 9D E0 06
@skip_16:
  DEC work_0016                                         ; $B04E: CE 16 00
  DEC work_0018                                         ; $B051: CE 18 00
  RTS                                                 ; $B054: 60
.endproc
;===============================================================================
; $B055: BuildAdjacencyMapSmall
; Build adjacency map for smaller (4x4) overlay tiles.
; Clears $0680-$06BF to $FF, then populates via PopulateAdjacencyEntriesSmall.
;===============================================================================
.proc BuildAdjacencyMapSmall
BuildAdjacencyMapSmall:
  JSR PrepareAdjacencyPtrs                                   ; $B055: 20 8F B0
  LDY #$3F                                            ; $B058: A0 3F
  LDA #$FF                                            ; $B05A: A9 FF
@loop_3:
  STA tile_index_grid,Y                                         ; $B05C: 99 80 06
  DEY                                                 ; $B05F: 88
  BPL @loop_3                                           ; $B060: 10 FA
  LDY #$13                                            ; $B062: A0 13
@loop_4:
  JSR PopulateAdjacencyEntriesSmall                      ; $B064: 20 6B B0
  DEY                                                 ; $B067: 88
  BPL @loop_4                                           ; $B068: 10 FA
  RTS                                                 ; $B06A: 60
.endproc
;===============================================================================
; $B06B: PopulateAdjacencyEntriesSmall
; Populate adjacency entries for smaller overlay: matches $0614 against $0019
; and records in $0680/$06A0 only (2 maps vs 4 in full version).
;===============================================================================
.proc PopulateAdjacencyEntriesSmall
  work_0019       = $0019
  oam_x_pos        = $0600  ; OAM sprite X position (reuses tile_grid_coord_x memory)
  oam_y_pos        = $0614  ; OAM sprite Y position (reuses tile_grid_coord_y memory)
  adj_col_right     = $06A0  ; Primary layer: left-right neighbor column (tile_index_grid+32)
PopulateAdjacencyEntriesSmall:
  LDA oam_y_pos,Y                                         ; $B06B: B9 14 06
  CMP work_0019                                         ; $B06E: CD 19 00
  BNE @skip_17                                           ; $B071: D0 09
  PHA                                                 ; $B073: 48
  LDX oam_x_pos,Y                                         ; $B074: BE 00 06
  TYA                                                 ; $B077: 98
  STA tile_index_grid,X                                         ; $B078: 9D 80 06
  PLA                                                 ; $B07B: 68
@skip_17:
  INC work_0019                                         ; $B07C: EE 19 00
  CMP work_0019                                         ; $B07F: CD 19 00
  BNE @skip_18                                           ; $B082: D0 07
  LDX oam_x_pos,Y                                         ; $B084: BE 00 06
  TYA                                                 ; $B087: 98
  STA adj_col_right,X                                         ; $B088: 9D A0 06
@skip_18:
  DEC work_0019                                         ; $B08B: CE 19 00
  RTS                                                 ; $B08E: 60
.endproc
;===============================================================================
; $B08F: PrepareAdjacencyPtrs
; Extract low nibbles from three byte-pointers to derive tile-grid coordinates.
;   attr_byte_ptr ($000C/D) -> tile_attr_ptr  ($0018/19)
;   coord_byte_ptr ($000E/F) -> tile_col_ptr  ($0016/17) [overwritten]
;   scene_byte_ptr ($001C/D) -> tile_col_ptr  ($0016/17)
;===============================================================================
.proc PrepareAdjacencyPtrs
  attr_byte_ptr_lo  = $000C
  attr_byte_ptr_hi  = $000D
  coord_byte_ptr_lo = $000E
  coord_byte_ptr_hi = $000F
  tile_col_ptr_lo   = $0016
  tile_col_ptr_hi   = $0017
  tile_attr_ptr_lo  = $0018
  tile_attr_ptr_hi  = $0019
  scene_byte_ptr_lo = $001C
  scene_byte_ptr_hi = $001D
PrepareAdjacencyPtrs:
  LDA attr_byte_ptr_lo                                    ; $B08F: AD 0C 00
  STA tile_attr_ptr_lo                                    ; $B092: 8D 18 00
  LDA attr_byte_ptr_hi                                    ; $B095: AD 0D 00
  LSR A                                                   ; $B098: 4A
  ROR tile_attr_ptr_lo                                    ; $B099: 6E 18 00
  LSR tile_attr_ptr_lo                                    ; $B09C: 4E 18 00
  LSR tile_attr_ptr_lo                                    ; $B09F: 4E 18 00
  LSR tile_attr_ptr_lo                                    ; $B0A2: 4E 18 00
  LSR tile_attr_ptr_lo                                    ; $B0A5: 4E 18 00
  ASL tile_attr_ptr_lo                                    ; $B0A8: 0E 18 00
  LDA coord_byte_ptr_lo                                   ; $B0AB: AD 0E 00
  STA tile_attr_ptr_hi                                    ; $B0AE: 8D 19 00
  LDA coord_byte_ptr_hi                                   ; $B0B1: AD 0F 00
  LSR A                                                   ; $B0B4: 4A
  ROR tile_attr_ptr_hi                                    ; $B0B5: 6E 19 00
  LSR tile_attr_ptr_hi                                    ; $B0B8: 4E 19 00
  LSR tile_attr_ptr_hi                                    ; $B0BB: 4E 19 00
  LSR tile_attr_ptr_hi                                    ; $B0BE: 4E 19 00
  LSR tile_attr_ptr_hi                                    ; $B0C1: 4E 19 00
  ASL tile_attr_ptr_hi                                    ; $B0C4: 0E 19 00
  LDA scene_byte_ptr_lo                                   ; $B0C7: AD 1C 00
  STA tile_col_ptr_lo                                     ; $B0CA: 8D 16 00
  LDA scene_byte_ptr_hi                                   ; $B0CD: AD 1D 00
  LSR A                                                   ; $B0D0: 4A
  ROR tile_col_ptr_lo                                     ; $B0D1: 6E 16 00
  LSR tile_col_ptr_lo                                     ; $B0D4: 4E 16 00
  LSR tile_col_ptr_lo                                     ; $B0D7: 4E 16 00
  LSR tile_col_ptr_lo                                     ; $B0DA: 4E 16 00
  LSR tile_col_ptr_lo                                     ; $B0DD: 4E 16 00
  ASL tile_col_ptr_lo                                     ; $B0E0: 0E 16 00
  LDA coord_byte_ptr_lo                                   ; $B0E3: AD 0E 00
  STA tile_col_ptr_hi                                     ; $B0E6: 8D 17 00
  LDA coord_byte_ptr_hi                                   ; $B0E9: AD 0F 00
  LSR A                                                   ; $B0EC: 4A
  ROR tile_col_ptr_hi                                     ; $B0ED: 6E 17 00
  LSR tile_col_ptr_hi                                     ; $B0F0: 4E 17 00
  LSR tile_col_ptr_hi                                     ; $B0F3: 4E 17 00
  LSR tile_col_ptr_hi                                     ; $B0F6: 4E 17 00
  LSR tile_col_ptr_hi                                     ; $B0F9: 4E 17 00
  ASL tile_col_ptr_hi                                     ; $B0FC: 0E 17 00
  RTS                                                     ; $B0FF: 60
.endproc

;--- $B100: Main Game Dispatch ---

;===============================================================================
; $B100: MainGameDispatch
; Entry09: Main game mode dispatcher (22-entry dispatch table)
;===============================================================================
.proc MainGameDispatch
MainGameDispatch:
  LDY active_player_slot                                           ; $B100: AC AA 04
  LDA player_flag_0,Y                                         ; $B103: B9 AB 04
  BPL @skip                                           ; $B106: 10 07
  TYA                                                 ; $B108: 98
  EOR #$01                                            ; $B109: 49 01
  TAY                                                 ; $B10B: A8
  LDA player_flag_0,Y                                         ; $B10C: B9 AB 04
@skip:
  STA $6F44                                           ; $B10F: 8D 44 6F
  LDA game_state                                           ; $B112: AD A8 04
  JSR B1F_CallbackDispatcher                          ; $B115: 20 DE EA
; --- Inline pointer table (22 entries) ---
  .word DomesticAffairsDispatch                                         ; $B118: 44 B1
  .word TroopAssignmentDispatch                                         ; $B11A: 4F B3
  .word CombatCalcDispatch                                         ; $B11C: C8 B5
  .word BattleResultDispatch                                         ; $B11E: C7 B8
  .word SingleCombatDispatch                                         ; $B120: 6D BA
  .word DiplomacyDispatch                                         ; $B122: 3B BC
  .word EventCutsceneDispatch                                         ; $B124: E9 BC
  .word BattleInitDispatch                                         ; $B126: 78 BE
  .word BattleSetup_Exec                                         ; $B128: 8A C0
  .word EventCutsceneDispatch2                                         ; $B12A: 16 C1
  .word DomesticAffairsDispatch                                         ; $B12C: 44 B1
  .word DomesticAffairsDispatch                                         ; $B12E: 44 B1
  .word DomesticAffairsDispatch                                         ; $B130: 44 B1
  .word MapFadeDispatch                                         ; $B132: 1C C2
  .word TerritoryEventDispatch                                         ; $B134: F6 C2
  .word PaletteTransitionDispatch                                         ; $B136: 64 C4
  .word MapScrollDispatch_A                                         ; $B138: 98 C4
  .word MapScrollDispatch_B                                         ; $B13A: 89 C6
  .word MapScrollDispatch_C                                         ; $B13C: 49 C9
  .word MapSlideDispatch_A                                         ; $B13E: 9E CB
  .word MapSlideDispatch_B                                         ; $B140: 87 CC
  .word MapSlideDispatch_C                                         ; $B142: 3C CD
.endproc

;===============================================================================
; $B144: DomesticAffairsDispatch
; Sub-dispatcher: mode 09 (8-entry dispatch table)
;===============================================================================
.proc DomesticAffairsDispatch
DomesticAffairsDispatch:
  LDA sub_state                                           ; $B144: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $B147: 20 DE EA
; --- Inline pointer table (8 entries) ---
  .word DomesticAffairs_InitOfficers                                         ; $B14A: 5A B1
  .word DomesticAffairs_ShowMessage                                         ; $B14C: A6 B1
  .word DomesticAffairs_ShowDialog                                         ; $B14E: BB B1
  .word DomesticAffairs_LoadPortrait                                         ; $B150: D4 B1
  .word DomesticAffairs_BuildSpriteData                                         ; $B152: EE B1
  .word DomesticAffairs_FinalizeSprites                                         ; $B154: 1C B2
  .word DomesticAffairs_CalcTroopStats                                         ; $B156: 30 B2
  .word DomesticAffairs_SetupDisplay                                         ; $B158: E0 B2
.endproc
;===============================================================================
; $B15A: DomesticAffairs_InitOfficers
;===============================================================================
.proc DomesticAffairs_InitOfficers
  officer_data_ptr     = $0000
DomesticAffairs_InitOfficers:
  LDA a:$0087                                         ; $B15A: AD 87 00
  BMI @skip                                           ; $B15D: 30 01
  RTS                                                 ; $B15F: 60
@skip:
  INC sub_state                                           ; $B160: EE A9 04
  LDX #$00                                            ; $B163: A2 00
@loop:
  LDA player_officer_id_0,X                                         ; $B165: BD AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B168: 20 D7 F2
  LDY #$00                                            ; $B16B: A0 00
  LDA (officer_data_ptr),Y                                         ; $B16D: B1 00
  STA player_army_value_0,X                                         ; $B16F: 9D B1 04
  JSR LB188                                           ; $B172: 20 88 B1
  INX                                                 ; $B175: E8
  CPX #$02                                            ; $B176: E0 02
  BCC @loop                                           ; $B178: 90 EB
  LDA #$43                                            ; $B17A: A9 43
  STA officer_data_ptr                                         ; $B17C: 8D 00 00
  LDA name_tile_index                                           ; $B17F: AD AF 04
  CLC                                                 ; $B182: 18
  ADC #$01                                            ; $B183: 69 01
  JMP BuildPPUTileBuffer                                           ; $B185: 4C FD CD
LB188:
  LDY #$0A                                            ; $B188: A0 0A
  LDA (officer_data_ptr),Y                                         ; $B18A: B1 00
  AND #$1F                                            ; $B18C: 29 1F
  CMP #$10                                            ; $B18E: C9 10
  BCC @skip_2                                           ; $B190: 90 05
  LDA #$01                                            ; $B192: A9 01
  JMP DomesticAffairs_StoreOfficerSlot                                           ; $B194: 4C A2 B1
@skip_2:
  CMP #$08                                            ; $B197: C9 08
  BCC @skip_3                                           ; $B199: 90 05
  LDA #$00                                            ; $B19B: A9 00
  JMP DomesticAffairs_StoreOfficerSlot                                           ; $B19D: 4C A2 B1
@skip_3:
  LDA #$02                                            ; $B1A0: A9 02
.endproc
;===============================================================================
; $B1A2: DomesticAffairs_StoreOfficerSlot
;===============================================================================
.proc DomesticAffairs_StoreOfficerSlot
DomesticAffairs_StoreOfficerSlot:
  STA name_tile_index,X                                         ; $B1A2: 9D AF 04
  RTS                                                 ; $B1A5: 60
.endproc
;===============================================================================
; $B1A6: DomesticAffairs_ShowMessage
;===============================================================================
.proc DomesticAffairs_ShowMessage
  officer_data_ptr     = $0000
DomesticAffairs_ShowMessage:
  LDA a:$007E                                         ; $B1A6: AD 7E 00
  AND #$04                                            ; $B1A9: 29 04
  BNE @skip                                           ; $B1AB: D0 0D
  LDA #$E3                                            ; $B1AD: A9 E3
  STA officer_data_ptr                                         ; $B1AF: 8D 00 00
  LDA #$04                                            ; $B1B2: A9 04
  JSR BuildPPUTileBuffer                                           ; $B1B4: 20 FD CD
  INC sub_state                                           ; $B1B7: EE A9 04
@skip:
  RTS                                                 ; $B1BA: 60
.endproc
;===============================================================================
; $B1BB: DomesticAffairs_ShowDialog
;===============================================================================
.proc DomesticAffairs_ShowDialog
  officer_data_ptr     = $0000
DomesticAffairs_ShowDialog:
  LDA a:$007E                                         ; $B1BB: AD 7E 00
  AND #$04                                            ; $B1BE: 29 04
  BNE @skip                                           ; $B1C0: D0 11
  LDA #$55                                            ; $B1C2: A9 55
  STA officer_data_ptr                                         ; $B1C4: 8D 00 00
  LDA domestic_action_index                                           ; $B1C7: AD B0 04
  CLC                                                 ; $B1CA: 18
  ADC #$05                                            ; $B1CB: 69 05
  JSR BuildPPUTileBuffer                                           ; $B1CD: 20 FD CD
  INC sub_state                                           ; $B1D0: EE A9 04
@skip:
  RTS                                                 ; $B1D3: 60
.endproc
;===============================================================================
; $B1D4: DomesticAffairs_LoadPortrait
;===============================================================================
.proc DomesticAffairs_LoadPortrait
  officer_data_ptr     = $0000
DomesticAffairs_LoadPortrait:
  LDA a:$007E                                         ; $B1D4: AD 7E 00
  AND #$04                                            ; $B1D7: 29 04
  BNE @skip                                           ; $B1D9: D0 12
  LDA #$F5                                            ; $B1DB: A9 F5
  STA officer_data_ptr                                         ; $B1DD: 8D 00 00
  LDA #$08                                            ; $B1E0: A9 08
  JSR BuildPPUTileBuffer                                           ; $B1E2: 20 FD CD
  INC sub_state                                           ; $B1E5: EE A9 04
  LDA #$01                                            ; $B1E8: A9 01
  STA active_player_slot                                           ; $B1EA: 8D AA 04
@skip:
  RTS                                                 ; $B1ED: 60
.endproc
;===============================================================================
; $B1EE: DomesticAffairs_BuildSpriteData
;===============================================================================
.proc DomesticAffairs_BuildSpriteData
  sprite_row_count      = $0003
DomesticAffairs_BuildSpriteData:
  LDY #$31                                            ; $B1EE: A0 31
  JSR B1F_SwitchBank8_B                               ; $B1F0: 20 5F F2
  LDX #$00                                            ; $B1F3: A2 00
  LDA #$44                                            ; $B1F5: A9 44
  STA sprite_row_count                                         ; $B1F7: 8D 03 00
  LDA player_officer_id_0                                           ; $B1FA: AD AD 04
  JSR ExpandMetatileToSprites                            ; $B1FD: 20 A3 CF
  LDA #$52                                            ; $B200: A9 52
  STA sprite_row_count                                         ; $B202: 8D 03 00
  LDA player_officer_id_1                                           ; $B205: AD AE 04
  JSR ExpandMetatileToSprites                            ; $B208: 20 A3 CF
  LDA #$FF                                            ; $B20B: A9 FF
  STA sprite_y_buffer,X                                         ; $B20D: 9D 80 03
  INC sub_state                                           ; $B210: EE A9 04
  LDA a:$007E                                         ; $B213: AD 7E 00
  ORA #$04                                            ; $B216: 09 04
  STA a:$007E                                         ; $B218: 8D 7E 00
  RTS                                                 ; $B21B: 60
.endproc
;===============================================================================
; $B21C: DomesticAffairs_FinalizeSprites
;===============================================================================
.proc DomesticAffairs_FinalizeSprites
DomesticAffairs_FinalizeSprites:
  JSR FinalizeSpriteBuffer                                           ; $B21C: 20 60 D0
  LDA #$FF                                            ; $B21F: A9 FF
  STA sprite_y_buffer,X                                         ; $B221: 9D 80 03
  INC sub_state                                           ; $B224: EE A9 04
  LDA a:$007E                                         ; $B227: AD 7E 00
  ORA #$04                                            ; $B22A: 09 04
  STA a:$007E                                         ; $B22C: 8D 7E 00
  RTS                                                 ; $B22F: 60
.endproc
;===============================================================================
; $B230: DomesticAffairs_CalcTroopStats
;===============================================================================
.proc DomesticAffairs_CalcTroopStats
  officer_data_ptr     = $0000
  stat_shifted     = $0001
  tile_attr      = $0002
  div_loop_count      = $0003
  col_counter_lo  = $0004
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
DomesticAffairs_CalcTroopStats:
  LDX #$00                                            ; $B230: A2 00
@loop:
  LDA player_officer_id_0,X                                         ; $B232: BD AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B235: 20 D7 F2
  LDY #$0A                                            ; $B238: A0 0A
  LDA (officer_data_ptr),Y                                         ; $B23A: B1 00
  STA ptr_0010_lo                                         ; $B23C: 8D 10 00
  LSR A                                               ; $B23F: 4A
  LSR A                                               ; $B240: 4A
  LSR A                                               ; $B241: 4A
  LSR A                                               ; $B242: 4A
  LSR A                                               ; $B243: 4A
  CLC                                                 ; $B244: 18
  ADC #$18                                            ; $B245: 69 18
  STA ptr_0010_hi                                         ; $B247: 8D 11 00
  LDA ptr_0010_lo                                         ; $B24A: AD 10 00
  AND #$1F                                            ; $B24D: 29 1F
  STA ptr_0010_lo                                         ; $B24F: 8D 10 00
  TAY                                                 ; $B252: A8
  LDA DomesticAffairs_TroopStatAdjTable,Y                                         ; $B253: B9 C0 B2
  STA ptr_0010_lo                                         ; $B256: 8D 10 00
  LDY ptr_0010_hi                                         ; $B259: AC 11 00
  LDA DomesticAffairs_TroopStatAdjTable,Y                                         ; $B25C: B9 C0 B2
  CLC                                                 ; $B25F: 18
  ADC ptr_0010_lo                                         ; $B260: 6D 10 00
  STA ptr_0010_lo                                         ; $B263: 8D 10 00
  LDY #$00                                            ; $B266: A0 00
  LDA (officer_data_ptr),Y                                         ; $B268: B1 00
  STA work_marker                                         ; $B26A: 8D 02 00
  LDY #$01                                            ; $B26D: A0 01
  LDA (officer_data_ptr),Y                                         ; $B26F: B1 00
  CLC                                                 ; $B271: 18
  ADC work_marker                                         ; $B272: 6D 02 00
  STA stat_sum                                         ; $B275: 8D 01 00
  LDA #$00                                            ; $B278: A9 00
  STA work_marker                                         ; $B27A: 8D 02 00
  STA col_counter_lo                                         ; $B27D: 8D 04 00
  LDA #$0A                                            ; $B280: A9 0A
  STA div_loop_count                                         ; $B282: 8D 03 00
  JSR B1F_MathDiv16                                   ; $B285: 20 7C EA
  LDA stat_sum                                         ; $B288: AD 01 00
  CLC                                                 ; $B28B: 18
  ADC #$14                                            ; $B28C: 69 14
  SEC                                                 ; $B28E: 38
  SBC ptr_0010_lo                                         ; $B28F: ED 10 00
  STA player_random_offset_0,X                                         ; $B292: 9D B3 04
@loop_2:
  JSR B1F_RandomByte                                  ; $B295: 20 7A E8
  AND #$0F                                            ; $B298: 29 0F
  CMP #$0B                                            ; $B29A: C9 0B
  BCS @loop_2                                           ; $B29C: B0 F7
  ADC player_random_offset_0,X                                         ; $B29E: 7D B3 04
  STA display_ptr_lo,X                                         ; $B2A1: 9D BD 04
  INX                                                 ; $B2A4: E8
  CPX #$02                                            ; $B2A5: E0 02
  BNE @loop                                           ; $B2A7: D0 89
  LDX #$00                                            ; $B2A9: A2 00
  LDA display_ptr_lo                                           ; $B2AB: AD BD 04
  CMP display_ptr_hi                                           ; $B2AE: CD BE 04
  BCS @skip                                           ; $B2B1: B0 01
  INX                                                 ; $B2B3: E8
@skip:
  STX active_player_slot                                           ; $B2B4: 8E AA 04
  LDA #$00                                            ; $B2B7: A9 00
  STA frame_counter                                           ; $B2B9: 8D C0 04
  INC sub_state                                           ; $B2BC: EE A9 04
  RTS                                                 ; $B2BF: 60
DomesticAffairs_TroopStatAdjTable:
  .byte $04,$03,$05,$08,$09,$06,$07,$04,$04,$06,$07,$08,$07,$06,$08,$0A; $B2C0: 04 03 05 08 09 06 07 04 04 06 07 08 07 06 08 0A
  .byte $04,$05,$06,$08,$07,$08,$06,$0A,$01,$02,$04,$06,$05,$0A,$03,$07; $B2D0: 04 05 06 08 07 08 06 0A 01 02 04 06 05 0A 03 07
.endproc
;===============================================================================
; $B2E0: DomesticAffairs_SetupDisplay
;===============================================================================
.proc DomesticAffairs_SetupDisplay
  officer_data_ptr     = $0000
  ppu_tile_lo     = $0001
DomesticAffairs_SetupDisplay:
  LDY name_tile_index                                           ; $B2E0: AC AF 04
  LDA DomesticAffairs_NameTileLookup+9,Y                                         ; $B2E3: B9 4C B3
  STA officer_data_ptr                                         ; $B2E6: 8D 00 00
  LDY domestic_action_index                                           ; $B2E9: AC B0 04
  LDA DomesticAffairs_NameTileLookup+9,Y                                         ; $B2EC: B9 4C B3
  STA ppu_tile_lo                                         ; $B2EF: 8D 01 00
  LDA officer_data_ptr                                         ; $B2F2: AD 00 00
  ASL A                                               ; $B2F5: 0A
  CLC                                                 ; $B2F6: 18
  ADC officer_data_ptr                                         ; $B2F7: 6D 00 00
  CLC                                                 ; $B2FA: 18
  ADC ppu_tile_lo                                         ; $B2FB: 6D 01 00
  TAY                                                 ; $B2FE: A8
  LDA DomesticAffairs_NameTileLookup,Y                                         ; $B2FF: B9 43 B3
  STA name_tile_ptr_lo                                           ; $B302: 8D C5 04
  LDA ppu_tile_lo                                         ; $B305: AD 01 00
  ASL A                                               ; $B308: 0A
  CLC                                                 ; $B309: 18
  ADC ppu_tile_lo                                         ; $B30A: 6D 01 00
  CLC                                                 ; $B30D: 18
  ADC officer_data_ptr                                         ; $B30E: 6D 00 00
  TAY                                                 ; $B311: A8
  LDA DomesticAffairs_NameTileLookup,Y                                         ; $B312: B9 43 B3
  STA name_tile_ptr_hi                                           ; $B315: 8D C6 04
  LDA #$02                                            ; $B318: A9 02
  STA event_overlay_flag                                           ; $B31A: 8D C3 04
  STA ui_state                                           ; $B31D: 8D C4 04
  LDY active_player_slot                                           ; $B320: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B323: B9 AD 04
  STA selected_officer_id                                           ; $B326: 8D 2C 04
  LDA #$3A                                            ; $B329: A9 3A
  STA display_ptr_lo                                           ; $B32B: 8D BD 04
  LDA #$3B                                            ; $B32E: A9 3B
  STA display_ptr_hi                                           ; $B330: 8D BE 04
  LDA #$00                                            ; $B333: A9 00
  STA sub_action_type                                           ; $B335: 8D BF 04
  LDA #$09                                            ; $B338: A9 09
  STA game_state                                           ; $B33A: 8D A8 04
  LDA #$00                                            ; $B33D: A9 00
  STA sub_state                                           ; $B33F: 8D A9 04
  RTS                                                 ; $B342: 60
DomesticAffairs_NameTileLookup:
  .byte $46,$4B,$3C,$37,$3C,$46,$50,$32,$3C,$01,$02,$00; $B343: 46 4B 3C 37 3C 46 50 32 3C 01 02 00
.endproc

;===============================================================================
; $B34F: TroopAssignmentDispatch
;===============================================================================
.proc TroopAssignmentDispatch
TroopAssignmentDispatch:
  LDA sub_state                                           ; $B34F: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $B352: 20 DE EA
; --- Inline pointer table (6 entries) ---
  .word TroopAssign_SelectTarget                                         ; $B355: 61 B3
  .word TroopAssign_Execute                                         ; $B357: F0 B3
  .word TroopAssign_ShowMenu                                         ; $B359: 07 B4
  .word TroopAssign_HandleResult                                         ; $B35B: 7E B4
  .word TroopAssign_Confirm                                         ; $B35D: 52 B5
  .word TroopAssign_ShowSummary                                         ; $B35F: 69 B5
.endproc
;===============================================================================
; $B361: TroopAssign_SelectTarget
;===============================================================================
.proc TroopAssign_SelectTarget
  officer_data_ptr     = $0000
  callback_result       = $00A4
TroopAssign_SelectTarget:
  LDA frame_counter                                           ; $B361: AD C0 04
  BNE @skip                                           ; $B364: D0 08
  LDA active_player_slot                                           ; $B366: AD AA 04
  EOR #$01                                            ; $B369: 49 01
  STA active_player_slot                                           ; $B36B: 8D AA 04
@skip:
  INC frame_counter                                           ; $B36E: EE C0 04
  LDA frame_counter                                           ; $B371: AD C0 04
  CMP #$03                                            ; $B374: C9 03
  BCC @skip_2                                           ; $B376: 90 03
  JSR LB3C6                                           ; $B378: 20 C6 B3
@skip_2:
  LDA active_player_slot                                           ; $B37B: AD AA 04
  EOR #$01                                            ; $B37E: 49 01
  STA active_player_slot                                           ; $B380: 8D AA 04
  TAY                                                 ; $B383: A8
  LDA player_action_timer_0,Y                                         ; $B384: B9 B5 04
  AND #$7F                                            ; $B387: 29 7F
  BEQ @skip_3                                           ; $B389: F0 06
  SEC                                                 ; $B38B: 38
  SBC #$01                                            ; $B38C: E9 01
  STA player_action_timer_0,Y                                         ; $B38E: 99 B5 04
@skip_3:
  LDY active_player_slot                                           ; $B391: AC AA 04
  LDA player_flag_0,Y                                         ; $B394: B9 AB 04
  BPL @skip_4                                           ; $B397: 10 06
  LDA #$02                                            ; $B399: A9 02
  STA game_state                                           ; $B39B: 8D A8 04
  RTS                                                 ; $B39E: 60
@skip_4:
  LDY active_player_slot                                           ; $B39F: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B3A2: B9 AD 04
  STA officer_data_ptr                                         ; $B3A5: 8D 00 00
  LDY #$3D                                            ; $B3A8: A0 3D
  JSR B1F_BankedCallbackTrampoline                    ; $B3AA: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A030                                         ; $B3AD: 30 A0
  LDY active_player_slot                                           ; $B3AF: AC AA 04
  LDA player_action_timer_0,Y                                         ; $B3B2: B9 B5 04
  AND #$7F                                            ; $B3B5: 29 7F
  BEQ @skip_5                                           ; $B3B7: F0 02
  LDA #$02                                            ; $B3B9: A9 02
@skip_5:
  STA a:zp_a4                                         ; $B3BB: 8D A4 00
  INC sub_state                                           ; $B3BE: EE A9 04
  LDA #$2B                                            ; $B3C1: A9 2B
  JMP B1F_SetUI0                                      ; $B3C3: 4C 6D F2
LB3C6:
  LDX #$00                                            ; $B3C6: A2 00
@loop:
  JSR B1F_RandomByte                                  ; $B3C8: 20 7A E8
  AND #$0F                                            ; $B3CB: 29 0F
  CMP #$0B                                            ; $B3CD: C9 0B
  BCS @loop                                           ; $B3CF: B0 F7
  ADC player_random_offset_0,X                                         ; $B3D1: 7D B3 04
  STA display_ptr_lo,X                                         ; $B3D4: 9D BD 04
  INX                                                 ; $B3D7: E8
  CPX #$02                                            ; $B3D8: E0 02
  BCC @loop                                           ; $B3DA: 90 EC
  LDX #$00                                            ; $B3DC: A2 00
  LDA display_ptr_lo                                           ; $B3DE: AD BD 04
  CMP display_ptr_hi                                           ; $B3E1: CD BE 04
  BCC @skip_6                                           ; $B3E4: 90 01
  INX                                                 ; $B3E6: E8
@skip_6:
  STX active_player_slot                                           ; $B3E7: 8E AA 04
  LDA #$01                                            ; $B3EA: A9 01
  STA frame_counter                                           ; $B3EC: 8D C0 04
  RTS                                                 ; $B3EF: 60
.endproc
;===============================================================================
; $B3F0: TroopAssign_Execute
;===============================================================================
.proc TroopAssign_Execute
TroopAssign_Execute:
  JSR SetupMenuPtr                                           ; $B3F0: 20 66 D1
  JSR CheckButtonConfirm                                           ; $B3F3: 20 99 D2
  BCC @skip                                           ; $B3F6: 90 0E
  LDA #$00                                            ; $B3F8: A9 00
  STA troop_assign_counter_lo                                           ; $B3FA: 8D 24 04
  STA troop_assign_counter_hi                                           ; $B3FD: 8D 25 04
  INC sub_state                                           ; $B400: EE A9 04
  JMP TroopAssign_NextState                                           ; $B403: 4C 7C D1
@skip:
  RTS                                                 ; $B406: 60
.endproc
;===============================================================================
; $B407: TroopAssign_ShowMenu
;===============================================================================
.proc TroopAssign_ShowMenu
  menu_tile_offset     = $0000
  ppu_tile_hi     = $0001
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  menu_index       = $0012
TroopAssign_ShowMenu:
  JSR SetupMenuPtr                                           ; $B407: 20 66 D1
  LDA #$61                                            ; $B40A: A9 61
  STA ptr_0010_lo                                         ; $B40C: 8D 10 00
  LDA #$B4                                            ; $B40F: A9 B4
  STA ptr_0010_hi                                         ; $B411: 8D 11 00
  LDA #$00                                            ; $B414: A9 00
  STA menu_index                                         ; $B416: 8D 12 00
  JSR B1F_MenuStep2                                   ; $B419: 20 1E ED
  LDA #$6B                                            ; $B41C: A9 6B
  STA ptr_0010_lo                                         ; $B41E: 8D 10 00
  LDA #$B4                                            ; $B421: A9 B4
  STA ptr_0010_hi                                         ; $B423: 8D 11 00
  LDA #$79                                            ; $B426: A9 79
  STA menu_tile_offset                                         ; $B428: 8D 00 00
  LDA #$B4                                            ; $B42B: A9 B4
  STA menu_page_base                                         ; $B42D: 8D 01 00
  LDA menu_index                                         ; $B430: AD 12 00
  JSR B1F_PointerTableLookup                          ; $B433: 20 F5 ED
  LDA a:$0081                                         ; $B436: AD 81 00
  LSR A                                               ; $B439: 4A
  BCC @skip_2                                           ; $B43A: 90 24
  INC sub_state                                           ; $B43C: EE A9 04
  LDA menu_index                                         ; $B43F: AD 12 00
  STA sub_action_type                                           ; $B442: 8D BF 04
  CMP #$04                                            ; $B445: C9 04
  BNE @skip_2                                           ; $B447: D0 17
  LDY active_player_slot                                           ; $B449: AC AA 04
  LDA player_action_timer_0,Y                                         ; $B44C: B9 B5 04
  AND #$7F                                            ; $B44F: 29 7F
  BNE @skip                                           ; $B451: D0 08
  INC sub_state                                           ; $B453: EE A9 04
  LDA #$2C                                            ; $B456: A9 2C
  JMP B1F_SetUI0                                      ; $B458: 4C 6D F2
@skip:
  LDA #$02                                            ; $B45B: A9 02
  STA sub_state                                           ; $B45D: 8D A9 04
@skip_2:
  RTS                                                 ; $B460: 60
TroopAssign_MenuData:
; --- Menu Grid Layout (step_size=2, 2 columns x 5 pages) ---
; 7 item IDs ($00-$06), $FF = invalid/end sentinel
  .byte $00,$01,$02,$03,$04,$05,$06,$FF,$FF,$FF                ; $B461
; --- Menu Sprite Pointer Table (8 word entries, indexed by item ID) ---
  .byte $A6,$88,$A6,$C0,$B6,$88,$B6,$C0                        ; $B46B
  .byte $C6,$88,$C6,$C0,$D6,$88                        ; $B473
; --- Menu Sprite Control Data (5 bytes) ---
  .byte $00,$07,$00,$00,$80                                     ; $B479
.endproc

;===============================================================================
; $B47E: TroopAssign_HandleResult
;===============================================================================
.proc TroopAssign_HandleResult
TroopAssign_HandleResult:
  LDA sub_action_type                                           ; $B47E: AD BF 04
  BNE @skip                                           ; $B481: D0 22
  LDA #$03                                            ; $B483: A9 03
  STA display_ptr_lo                                           ; $B485: 8D BD 04
  LDA #$00                                            ; $B488: A9 00
  STA display_ptr_hi                                           ; $B48A: 8D BE 04
  LDA #$10                                            ; $B48D: A9 10
  STA game_state                                           ; $B48F: 8D A8 04
  LDA #$00                                            ; $B492: A9 00
  STA sub_state                                           ; $B494: 8D A9 04
  LDY active_player_slot                                           ; $B497: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B49A: B9 AD 04
  STA selected_officer_id                                           ; $B49D: 8D 2C 04
  LDA #$23                                            ; $B4A0: A9 23
  JMP B1F_SetUI4                                      ; $B4A2: 4C 8B F2
@skip:
  CMP #$01                                            ; $B4A5: C9 01
  BNE @skip_2                                           ; $B4A7: D0 0F
  LDA #$04                                            ; $B4A9: A9 04
  STA game_state                                           ; $B4AB: 8D A8 04
  LDA #$00                                            ; $B4AE: A9 00
  STA sub_state                                           ; $B4B0: 8D A9 04
  LDA #$00                                            ; $B4B3: A9 00
  JMP B1F_SetUI4                                      ; $B4B5: 4C 8B F2
@skip_2:
  CMP #$02                                            ; $B4B8: C9 02
  BNE @skip_3                                           ; $B4BA: D0 22
  LDA #$03                                            ; $B4BC: A9 03
  STA display_ptr_lo                                           ; $B4BE: 8D BD 04
  LDA #$00                                            ; $B4C1: A9 00
  STA display_ptr_hi                                           ; $B4C3: 8D BE 04
  LDA #$11                                            ; $B4C6: A9 11
  STA game_state                                           ; $B4C8: 8D A8 04
  LDA #$00                                            ; $B4CB: A9 00
  STA sub_state                                           ; $B4CD: 8D A9 04
  LDY active_player_slot                                           ; $B4D0: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B4D3: B9 AD 04
  STA selected_officer_id                                           ; $B4D6: 8D 2C 04
  LDA #$21                                            ; $B4D9: A9 21
  JMP B1F_SetUI4                                      ; $B4DB: 4C 8B F2
@skip_3:
  CMP #$03                                            ; $B4DE: C9 03
  BNE @skip_5                                           ; $B4E0: D0 18
  JSR CheckPlayerIsRuler                                           ; $B4E2: 20 62 D2
  BCC @skip_4                                           ; $B4E5: 90 04
  DEC sub_state                                           ; $B4E7: CE A9 04
  RTS                                                 ; $B4EA: 60
@skip_4:
  LDA #$06                                            ; $B4EB: A9 06
  STA game_state                                           ; $B4ED: 8D A8 04
  LDA #$00                                            ; $B4F0: A9 00
  STA sub_state                                           ; $B4F2: 8D A9 04
  LDA #$00                                            ; $B4F5: A9 00
  JMP B1F_SetUI4                                      ; $B4F7: 4C 8B F2
@skip_5:
  CMP #$05                                            ; $B4FA: C9 05
  BNE @skip_6                                           ; $B4FC: D0 14
  LDA #$05                                            ; $B4FE: A9 05
  STA game_state                                           ; $B500: 8D A8 04
  LDA #$00                                            ; $B503: A9 00
  STA sub_state                                           ; $B505: 8D A9 04
  LDA active_player_slot                                           ; $B508: AD AA 04
  STA display_ptr_hi                                           ; $B50B: 8D BE 04
  STA sub_action_type                                           ; $B50E: 8D BF 04
  RTS                                                 ; $B511: 60
@skip_6:
  CMP #$06                                            ; $B512: C9 06
  BNE @skip_7                                           ; $B514: D0 22
  LDA #$03                                            ; $B516: A9 03
  STA display_ptr_lo                                           ; $B518: 8D BD 04
  LDA #$00                                            ; $B51B: A9 00
  STA display_ptr_hi                                           ; $B51D: 8D BE 04
  LDA #$12                                            ; $B520: A9 12
  STA game_state                                           ; $B522: 8D A8 04
  LDA #$00                                            ; $B525: A9 00
  STA sub_state                                           ; $B527: 8D A9 04
  LDY active_player_slot                                           ; $B52A: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B52D: B9 AD 04
  STA selected_officer_id                                           ; $B530: 8D 2C 04
  LDA #$24                                            ; $B533: A9 24
  JMP B1F_SetUI4                                      ; $B535: 4C 8B F2
@skip_7:
  CMP #$07                                            ; $B538: C9 07
  BNE @skip_8                                           ; $B53A: D0 0B
  LDA #$07                                            ; $B53C: A9 07
  STA game_state                                           ; $B53E: 8D A8 04
  LDA #$00                                            ; $B541: A9 00
  STA sub_state                                           ; $B543: 8D A9 04
  RTS                                                 ; $B546: 60
@skip_8:
  LDA #$08                                            ; $B547: A9 08
  STA game_state                                           ; $B549: 8D A8 04
  LDA #$00                                            ; $B54C: A9 00
  STA sub_state                                           ; $B54E: 8D A9 04
  RTS                                                 ; $B551: 60
.endproc
;===============================================================================
; $B552: TroopAssign_Confirm
;===============================================================================
.proc TroopAssign_Confirm
TroopAssign_Confirm:
  JSR SetupMenuPtr                                           ; $B552: 20 66 D1
  JSR CheckButtonConfirm                                           ; $B555: 20 99 D2
  BCC @skip                                           ; $B558: 90 0E
  INC sub_state                                           ; $B55A: EE A9 04
  LDA #$00                                            ; $B55D: A9 00
  STA troop_assign_counter_lo                                           ; $B55F: 8D 24 04
  STA troop_assign_counter_hi                                           ; $B562: 8D 25 04
  JMP TroopAssign_NextState                                           ; $B565: 4C 7C D1
@skip:
  RTS                                                 ; $B568: 60
.endproc
;===============================================================================
; $B569: TroopAssign_ShowSummary
;===============================================================================
.proc TroopAssign_ShowSummary
  menu_tile_offset     = $0000
  ppu_tile_hi     = $0001
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  menu_index       = $0012
TroopAssign_ShowSummary:
  JSR SetupMenuPtr                                           ; $B569: 20 66 D1
  LDA #$BB                                            ; $B56C: A9 BB
  STA ptr_0010_lo                                         ; $B56E: 8D 10 00
  LDA #$B5                                            ; $B571: A9 B5
  STA ptr_0010_hi                                         ; $B573: 8D 11 00
  LDA #$00                                            ; $B576: A9 00
  STA menu_index                                         ; $B578: 8D 12 00
  JSR B1F_MenuStep2                                   ; $B57B: 20 1E ED
  LDA #$BF                                            ; $B57E: A9 BF
  STA ptr_0010_lo                                         ; $B580: 8D 10 00
  LDA #$B5                                            ; $B583: A9 B5
  STA ptr_0010_hi                                         ; $B585: 8D 11 00
  LDA #$C3                                            ; $B588: A9 C3
  STA menu_tile_offset                                         ; $B58A: 8D 00 00
  LDA #$B5                                            ; $B58D: A9 B5
  STA menu_page_base                                         ; $B58F: 8D 01 00
  LDA menu_index                                         ; $B592: AD 12 00
  JSR B1F_PointerTableLookup                          ; $B595: 20 F5 ED
  LDA a:$0081                                         ; $B598: AD 81 00
  LSR A                                               ; $B59B: 4A
  BCC @skip                                           ; $B59C: 90 0F
  LDA menu_index                                         ; $B59E: AD 12 00
  CLC                                                 ; $B5A1: 18
  ADC #$07                                            ; $B5A2: 69 07
  STA sub_action_type                                           ; $B5A4: 8D BF 04
  LDA #$03                                            ; $B5A7: A9 03
  STA sub_state                                           ; $B5A9: 8D A9 04
  RTS                                                 ; $B5AC: 60
@skip:
  LSR A                                               ; $B5AD: 4A
  BCC @skip_2                                           ; $B5AE: 90 0A
  LDA #$01                                            ; $B5B0: A9 01
  STA sub_state                                           ; $B5B2: 8D A9 04
  LDA #$2B                                            ; $B5B5: A9 2B
  JMP B1F_SetUI0                                      ; $B5B7: 4C 6D F2
@skip_2:
  RTS                                                 ; $B5BA: 60
TroopAssign_SummaryMenuData:
; --- Summary Menu Grid Layout (2 items, 2 sentinels) ---
  .byte $00,$01,$FF,$FF                                        ; $B5BB
; --- Summary Sprite Pointer Table (2 word entries) ---
  .byte $B6,$88,$B6,$C0                                        ; $B5BF
; --- Summary Sprite Control Data (5 bytes) ---
  .byte $00,$07,$00,$00,$80                                    ; $B5C3
.endproc

;===============================================================================
; $B5C8: CombatCalcDispatch
;===============================================================================
.proc CombatCalcDispatch
CombatCalcDispatch:
  LDA sub_state                                           ; $B5C8: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $B5CB: 20 DE EA
; --- Inline pointer table (5 entries) ---
  .word CombatCalc_CompareForces                                         ; $B5CE: D8 B5
  .word CombatCalc_MoraleCheck                                         ; $B5D0: 26 B6
  .word CombatCalc_DefenseCheck                                         ; $B5D2: 59 B6
  .word CombatCalc_OfficerDuel                                         ; $B5D4: 89 B6
  .word CombatCalc_DetermineOutcome                                         ; $B5D6: 19 B7
.endproc
;===============================================================================
; $B5D8: CombatCalc_CompareForces
;===============================================================================
.proc CombatCalc_CompareForces
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
CombatCalc_CompareForces:
  LDA active_player_slot                                           ; $B5D8: AD AA 04
  EOR #$01                                            ; $B5DB: 49 01
  TAY                                                 ; $B5DD: A8
  LDA player_army_value_0,Y                                         ; $B5DE: B9 B1 04
  STA ptr_0010_lo                                         ; $B5E1: 8D 10 00
  LDY active_player_slot                                           ; $B5E4: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B5E7: B9 AD 04
  JSR B1F_GetOfficerRomRecordAddr                     ; $B5EA: 20 87 F3
  LDY #$00                                            ; $B5ED: A0 00
  LDA (officer_data_ptr),Y                                         ; $B5EF: B1 00
  LSR A                                               ; $B5F1: 4A
  STA ptr_0010_hi                                         ; $B5F2: 8D 11 00
  LDY active_player_slot                                           ; $B5F5: AC AA 04
  LDA player_army_value_0,Y                                         ; $B5F8: B9 B1 04
  CMP ptr_0010_hi                                         ; $B5FB: CD 11 00
  BCS @skip                                           ; $B5FE: B0 1F
  CMP ptr_0010_lo                                         ; $B600: CD 10 00
  BCS @skip_2                                           ; $B603: B0 1D
  JSR CheckPlayerIsRuler                                           ; $B605: 20 62 D2
  BCS @skip_2                                           ; $B608: B0 18
  JSR CombatCalc_MoraleCalc                                           ; $B60A: 20 B3 B7
  CMP ptr_0010_lo                                         ; $B60D: CD 10 00
  BCS @skip_2                                           ; $B610: B0 10
  LDA ptr_0010_lo                                         ; $B612: AD 10 00
  BEQ @skip_2                                           ; $B615: F0 0B
  LDA #$03                                            ; $B617: A9 03
  STA sub_action_type                                           ; $B619: 8D BF 04
  JMP CombatCalc_SetActionResult                                           ; $B61C: 4C A8 B7
@skip:
  INC sub_state                                           ; $B61F: EE A9 04
@skip_2:
  INC sub_state                                           ; $B622: EE A9 04
  RTS                                                 ; $B625: 60
.endproc
;===============================================================================
; $B626: CombatCalc_MoraleCheck
;===============================================================================
.proc CombatCalc_MoraleCheck
  combat_threshold       = $0010
CombatCalc_MoraleCheck:
  LDA active_player_slot                                           ; $B626: AD AA 04
  EOR #$01                                            ; $B629: 49 01
  TAY                                                 ; $B62B: A8
  LDA player_army_value_0,Y                                         ; $B62C: B9 B1 04
  STA combat_threshold                                         ; $B62F: 8D 10 00
  LDY active_player_slot                                           ; $B632: AC AA 04
  LDA player_army_value_0,Y                                         ; $B635: B9 B1 04
  CLC                                                 ; $B638: 18
  ADC #$1E                                            ; $B639: 69 1E
  CMP combat_threshold                                         ; $B63B: CD 10 00
  BCS @skip                                           ; $B63E: B0 15
  JSR CombatCalc_DefenseCalc                                           ; $B640: 20 DD B7
  CMP combat_threshold                                         ; $B643: CD 10 00
  BCS @skip                                           ; $B646: B0 0D
  LDA combat_threshold                                         ; $B648: AD 10 00
  BEQ @skip                                           ; $B64B: F0 08
  LDA #$06                                            ; $B64D: A9 06
  STA sub_action_type                                           ; $B64F: 8D BF 04
  JMP CombatCalc_SetActionResult                                           ; $B652: 4C A8 B7
@skip:
  INC sub_state                                           ; $B655: EE A9 04
  RTS                                                 ; $B658: 60
.endproc
;===============================================================================
; $B659: CombatCalc_DefenseCheck
;===============================================================================
.proc CombatCalc_DefenseCheck
  combat_threshold        = $0010
CombatCalc_DefenseCheck:
  LDY active_player_slot                                           ; $B659: AC AA 04
  LDA player_army_value_0,Y                                         ; $B65C: B9 B1 04
  CMP #$1E                                            ; $B65F: C9 1E
  BCS @skip                                           ; $B661: B0 22
  LDY active_player_slot                                           ; $B663: AC AA 04
  EOR #$01                                            ; $B666: 49 01
  TAY                                                 ; $B668: A8
  LDA player_army_value_0,Y                                         ; $B669: B9 B1 04
  CMP #$32                                            ; $B66C: C9 32
  BCC @skip                                           ; $B66E: 90 15
  JSR CombatCalc_LeadershipCheck                                           ; $B670: 20 16 B8
  CMP combat_threshold                                         ; $B673: CD 10 00
  BCS @skip                                           ; $B676: B0 0D
  LDA combat_threshold                                         ; $B678: AD 10 00
  BEQ @skip                                           ; $B67B: F0 08
  LDA #$02                                            ; $B67D: A9 02
  STA sub_action_type                                           ; $B67F: 8D BF 04
  JMP CombatCalc_SetActionResult                                           ; $B682: 4C A8 B7
@skip:
  INC sub_state                                           ; $B685: EE A9 04
  RTS                                                 ; $B688: 60
.endproc
;===============================================================================
; $B689: CombatCalc_OfficerDuel
;===============================================================================
.proc CombatCalc_OfficerDuel
  officer_data_ptr     = $0000
  combat_threshold       = $0010
CombatCalc_OfficerDuel:
  LDY active_player_slot                                           ; $B689: AC AA 04
  LDA player_action_timer_0,Y                                         ; $B68C: B9 B5 04
  AND #$7F                                            ; $B68F: 29 7F
  BEQ @skip                                           ; $B691: F0 03
  JMP @skip_3                                           ; $B693: 4C 15 B7
@skip:
  LDA player_officer_id_0,Y                                         ; $B696: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B699: 20 D7 F2
  LDY #$02                                            ; $B69C: A0 02
  LDA (officer_data_ptr),Y                                         ; $B69E: B1 00
  STA combat_threshold                                         ; $B6A0: 8D 10 00
  LDA active_player_slot                                           ; $B6A3: AD AA 04
  EOR #$01                                            ; $B6A6: 49 01
  TAY                                                 ; $B6A8: A8
  LDA player_officer_id_0,Y                                         ; $B6A9: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B6AC: 20 D7 F2
  LDY #$02                                            ; $B6AF: A0 02
  LDA (officer_data_ptr),Y                                         ; $B6B1: B1 00
  CMP combat_threshold                                         ; $B6B3: CD 10 00
  BCS @skip_2                                           ; $B6B6: B0 15
  JSR CombatCalc_DuelCheck                                           ; $B6B8: 20 51 B8
  CMP combat_threshold                                         ; $B6BB: CD 10 00
  BCS @skip_2                                           ; $B6BE: B0 0D
  LDA combat_threshold                                         ; $B6C0: AD 10 00
  BEQ @skip_2                                           ; $B6C3: F0 08
  LDA #$07                                            ; $B6C5: A9 07
  STA sub_action_type                                           ; $B6C7: 8D BF 04
  JMP CombatCalc_SetActionResult                                           ; $B6CA: 4C A8 B7
@skip_2:
  LDY active_player_slot                                           ; $B6CD: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B6D0: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B6D3: 20 D7 F2
  LDY #$01                                            ; $B6D6: A0 01
  LDA (officer_data_ptr),Y                                         ; $B6D8: B1 00
  STA combat_threshold                                         ; $B6DA: 8D 10 00
  LDA active_player_slot                                           ; $B6DD: AD AA 04
  EOR #$01                                            ; $B6E0: 49 01
  TAY                                                 ; $B6E2: A8
  LDA player_officer_id_0,Y                                         ; $B6E3: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B6E6: 20 D7 F2
  LDY #$01                                            ; $B6E9: A0 01
  LDA (officer_data_ptr),Y                                         ; $B6EB: B1 00
  CMP combat_threshold                                         ; $B6ED: CD 10 00
  BCC @skip_3                                           ; $B6F0: 90 23
  JSR CombatCalc_FinalCalc                                           ; $B6F2: 20 9B B8
  CMP combat_threshold                                         ; $B6F5: CD 10 00
  BCS @skip_3                                           ; $B6F8: B0 1B
  LDY active_player_slot                                           ; $B6FA: AC AA 04
  LDA player_action_timer_0,Y                                         ; $B6FD: B9 B5 04
  BMI @skip_3                                           ; $B700: 30 13
  TYA                                                 ; $B702: 98
  EOR #$01                                            ; $B703: 49 01
  TAY                                                 ; $B705: A8
  LDA player_action_timer_0,Y                                         ; $B706: B9 B5 04
  AND #$7F                                            ; $B709: 29 7F
  BNE @skip_3                                           ; $B70B: D0 08
  LDA #$08                                            ; $B70D: A9 08
  STA sub_action_type                                           ; $B70F: 8D BF 04
  JMP CombatCalc_SetActionResult                                           ; $B712: 4C A8 B7
@skip_3:
  INC sub_state                                           ; $B715: EE A9 04
  RTS                                                 ; $B718: 60
.endproc
;===============================================================================
; $B719: CombatCalc_DetermineOutcome
;===============================================================================
.proc CombatCalc_DetermineOutcome
  random_offset     = $0000
CombatCalc_DetermineOutcome:
  LDX #$00                                            ; $B719: A2 00
  LDA active_player_slot                                           ; $B71B: AD AA 04
  EOR #$01                                            ; $B71E: 49 01
  TAY                                                 ; $B720: A8
  LDA player_army_value_0,Y                                         ; $B721: B9 B1 04
  CMP #$1F                                            ; $B724: C9 1F
  BCC @skip                                           ; $B726: 90 08
  LDX #$18                                            ; $B728: A2 18
  CMP #$3D                                            ; $B72A: C9 3D
  BCC @skip                                           ; $B72C: 90 02
  LDX #$30                                            ; $B72E: A2 30
@skip:
  LDY active_player_slot                                           ; $B730: AC AA 04
  LDA player_army_value_0,Y                                         ; $B733: B9 B1 04
  CMP #$1F                                            ; $B736: C9 1F
  BCC @skip_2                                           ; $B738: 90 11
  TXA                                                 ; $B73A: 8A
  CLC                                                 ; $B73B: 18
  ADC #$08                                            ; $B73C: 69 08
  TAX                                                 ; $B73E: AA
  LDA player_army_value_0,Y                                         ; $B73F: B9 B1 04
  CMP #$3D                                            ; $B742: C9 3D
  BCC @skip_2                                           ; $B744: 90 05
  TXA                                                 ; $B746: 8A
  CLC                                                 ; $B747: 18
  ADC #$08                                            ; $B748: 69 08
  TAX                                                 ; $B74A: AA
@skip_2:
  JSR B1F_RandomMod8                                  ; $B74B: 20 56 E8
  STA random_offset                                         ; $B74E: 8D 00 00
  TXA                                                 ; $B751: 8A
  CLC                                                 ; $B752: 18
  ADC random_offset                                         ; $B753: 6D 00 00
  TAX                                                 ; $B756: AA
  LDA CombatCalc_OutcomeTable,X                                         ; $B757: BD 60 B7
  STA sub_action_type                                           ; $B75A: 8D BF 04
  JMP CombatCalc_SetActionResult                                           ; $B75D: 4C A8 B7
CombatCalc_OutcomeTable:
  .byte $00,$00,$00,$02,$02,$02,$02,$02,$00,$00,$00,$00,$00,$02,$02,$02; $B760: 00 00 00 02 02 02 02 02 00 00 00 00 00 02 02 02
  .byte $00,$00,$00,$00,$00,$00,$02,$02,$00,$00,$02,$02,$02,$02,$02,$02; $B770: 00 00 00 00 00 00 02 02 00 00 02 02 02 02 02 02
  .byte $00,$00,$00,$00,$02,$02,$02,$02,$00,$00,$00,$00,$00,$02,$02,$02; $B780: 00 00 00 00 02 02 02 02 00 00 00 00 00 02 02 02
  .byte $00,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00,$02,$02,$02,$02,$02; $B790: 00 02 02 02 02 02 02 02 00 00 00 02 02 02 02 02
  .byte $00,$00,$00,$00,$02,$02,$02,$02               ; $B7A0: 00 00 00 00 02 02 02 02
.endproc

;===============================================================================
; $B7A8: CombatCalc_SetActionResult
;===============================================================================
.proc CombatCalc_SetActionResult
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
CombatCalc_SetActionResult:
  LDA #$01                                            ; $B7A8: A9 01
  STA game_state                                           ; $B7AA: 8D A8 04
  LDA #$03                                            ; $B7AD: A9 03
  STA sub_state                                           ; $B7AF: 8D A9 04
  RTS                                                 ; $B7B2: 60
.endproc
;===============================================================================
; $B7B3: CombatCalc_MoraleCalc
; Computes morale threshold: officer_morale + army_value, capped at $8C.
; Returns random roll via B1F_RandomBelow100.
; Note: JMP to GetOfficerRecordAddr at $B7BF may be a ROM bug (should be JSR);
;       code at $B7C2-$B7DA is unreachable via JMP.
;===============================================================================
.proc CombatCalc_MoraleCalc
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
CombatCalc_MoraleCalc:
  LDY active_player_slot                                           ; $B7B3: AC AA 04
  LDA player_army_value_0,Y                                         ; $B7B6: B9 B1 04
  STA ptr_0010_lo                                         ; $B7B9: 8D 10 00
  LDA player_officer_id_0,Y                                         ; $B7BC: B9 AD 04
  JMP B1F_GetOfficerRecordAddr                        ; $B7BF: 4C D7 F2
  LDY #$03                                            ; $B7C2: A0 03
  LDA (officer_data_ptr),Y                                         ; $B7C4: B1 00
  CLC                                                 ; $B7C6: 18
  ADC ptr_0010_lo                                         ; $B7C7: 6D 10 00
  STA ptr_0010_lo                                         ; $B7CA: 8D 10 00
  LDA #$8C                                            ; $B7CD: A9 8C
  SEC                                                 ; $B7CF: 38
  SBC ptr_0010_lo                                         ; $B7D0: ED 10 00
  BPL @skip                                           ; $B7D3: 10 02
  LDA #$00                                            ; $B7D5: A9 00
@skip:
  STA ptr_0010_lo                                         ; $B7D7: 8D 10 00
  JMP B1F_RandomBelow100                              ; $B7DA: 4C 43 E8
.endproc
;===============================================================================
; $B7DD: CombatCalc_DefenseCalc
; Computes defense threshold: min(officer_stats) + army_value, capped at $7C.
; Returns random roll via B1F_RandomBelow100.
;===============================================================================
.proc CombatCalc_DefenseCalc
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
CombatCalc_DefenseCalc:
  LDY active_player_slot                                           ; $B7DD: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B7E0: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B7E3: 20 D7 F2
  LDY #$01                                            ; $B7E6: A0 01
  LDA (officer_data_ptr),Y                                         ; $B7E8: B1 00
  STA ptr_0010_lo                                         ; $B7EA: 8D 10 00
  LDY #$02                                            ; $B7ED: A0 02
  LDA (officer_data_ptr),Y                                         ; $B7EF: B1 00
  CMP ptr_0010_lo                                         ; $B7F1: CD 10 00
  BCC @skip_2                                           ; $B7F4: 90 03
  STA ptr_0010_lo                                         ; $B7F6: 8D 10 00
@skip_2:
  LDY active_player_slot                                           ; $B7F9: AC AA 04
  LDA player_army_value_0,Y                                         ; $B7FC: B9 B1 04
  CLC                                                 ; $B7FF: 18
  ADC ptr_0010_lo                                         ; $B800: 6D 10 00
  STA ptr_0010_lo                                         ; $B803: 8D 10 00
  LDA #$7C                                            ; $B806: A9 7C
  SEC                                                 ; $B808: 38
  SBC ptr_0010_lo                                         ; $B809: ED 10 00
  BPL @skip_3                                           ; $B80C: 10 02
  LDA #$00                                            ; $B80E: A9 00
@skip_3:
  STA ptr_0010_lo                                         ; $B810: 8D 10 00
  JMP B1F_RandomBelow100                              ; $B813: 4C 43 E8
.endproc
;===============================================================================
; $B816: CombatCalc_LeadershipCheck
; Computes leadership diff: $32 - (attacker_leadership - defender_leadership).
; Returns random roll via B1F_RandomBelow100.
;===============================================================================
.proc CombatCalc_LeadershipCheck
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
CombatCalc_LeadershipCheck:
  LDA active_player_slot                                           ; $B816: AD AA 04
  EOR #$01                                            ; $B819: 49 01
  TAY                                                 ; $B81B: A8
  LDA player_officer_id_0,Y                                         ; $B81C: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B81F: 20 D7 F2
  LDY #$01                                            ; $B822: A0 01
  LDA (officer_data_ptr),Y                                         ; $B824: B1 00
  STA ptr_0010_lo                                         ; $B826: 8D 10 00
  LDY active_player_slot                                           ; $B829: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B82C: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B82F: 20 D7 F2
  LDY #$01                                            ; $B832: A0 01
  LDA (officer_data_ptr),Y                                         ; $B834: B1 00
  SEC                                                 ; $B836: 38
  SBC ptr_0010_lo                                         ; $B837: ED 10 00
  BPL @skip_4                                           ; $B83A: 10 02
  LDA #$00                                            ; $B83C: A9 00
@skip_4:
  STA ptr_0010_lo                                         ; $B83E: 8D 10 00
  LDA #$32                                            ; $B841: A9 32
  SEC                                                 ; $B843: 38
  SBC ptr_0010_lo                                         ; $B844: ED 10 00
  BPL @skip_5                                           ; $B847: 10 02
  LDA #$00                                            ; $B849: A9 00
@skip_5:
  STA ptr_0010_lo                                         ; $B84B: 8D 10 00
  JMP B1F_RandomBelow100                              ; $B84E: 4C 43 E8
.endproc
;===============================================================================
; $B851: CombatCalc_DuelCheck
; Computes duel threshold: attacker_attack - (attacker_defense + defender_morale).
; Returns random roll via B1F_RandomBelow100.
;===============================================================================
.proc CombatCalc_DuelCheck
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
CombatCalc_DuelCheck:
  LDY active_player_slot                                           ; $B851: AC AA 04
  LDA player_officer_id_0,Y                                         ; $B854: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B857: 20 D7 F2
  LDY #$02                                            ; $B85A: A0 02
  LDA (officer_data_ptr),Y                                         ; $B85C: B1 00
  STA ptr_0010_lo                                         ; $B85E: 8D 10 00
  LDY #$04                                            ; $B861: A0 04
  LDA (officer_data_ptr),Y                                         ; $B863: B1 00
  CLC                                                 ; $B865: 18
  ADC ptr_0010_lo                                         ; $B866: 6D 10 00
  STA ptr_0010_lo                                         ; $B869: 8D 10 00
  LDY #$01                                            ; $B86C: A0 01
  LDA (officer_data_ptr),Y                                         ; $B86E: B1 00
  STA ptr_0010_hi                                         ; $B870: 8D 11 00
  LDA active_player_slot                                           ; $B873: AD AA 04
  EOR #$01                                            ; $B876: 49 01
  TAY                                                 ; $B878: A8
  LDA player_officer_id_0,Y                                         ; $B879: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B87C: 20 D7 F2
  LDY #$03                                            ; $B87F: A0 03
  LDA (officer_data_ptr),Y                                         ; $B881: B1 00
  CLC                                                 ; $B883: 18
  ADC ptr_0010_hi                                         ; $B884: 6D 11 00
  STA ptr_0010_hi                                         ; $B887: 8D 11 00
  LDA ptr_0010_lo                                         ; $B88A: AD 10 00
  SEC                                                 ; $B88D: 38
  SBC ptr_0010_hi                                         ; $B88E: ED 11 00
  BPL @skip_6                                           ; $B891: 10 02
  LDA #$00                                            ; $B893: A9 00
@skip_6:
  STA ptr_0010_lo                                         ; $B895: 8D 10 00
  JMP B1F_RandomBelow100                              ; $B898: 4C 43 E8
.endproc
;===============================================================================
; $B89B: CombatCalc_FinalCalc
; Computes final threshold: (defender_defense - defender_attack) + $0A.
; Returns random roll via B1F_RandomBelow100.
;===============================================================================
.proc CombatCalc_FinalCalc
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
CombatCalc_FinalCalc:
  LDA active_player_slot                                           ; $B89B: AD AA 04
  EOR #$01                                            ; $B89E: 49 01
  TAY                                                 ; $B8A0: A8
  LDA player_officer_id_0,Y                                         ; $B8A1: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $B8A4: 20 D7 F2
  LDY #$02                                            ; $B8A7: A0 02
  LDA (officer_data_ptr),Y                                         ; $B8A9: B1 00
  STA ptr_0010_lo                                         ; $B8AB: 8D 10 00
  LDY #$01                                            ; $B8AE: A0 01
  LDA (officer_data_ptr),Y                                         ; $B8B0: B1 00
  SEC                                                 ; $B8B2: 38
  SBC ptr_0010_lo                                         ; $B8B3: ED 10 00
  BCS @skip_7                                           ; $B8B6: B0 02
  LDA #$00                                            ; $B8B8: A9 00
@skip_7:
  CLC                                                 ; $B8BA: 18
  ADC #$0A                                            ; $B8BB: 69 0A
  BPL @skip_8                                           ; $B8BD: 10 02
  LDA #$00                                            ; $B8BF: A9 00
@skip_8:
  STA ptr_0010_lo                                         ; $B8C1: 8D 10 00
  JMP B1F_RandomBelow100                              ; $B8C4: 4C 43 E8
.endproc
;===============================================================================
; $B8C7: BattleResultDispatch
;===============================================================================
.proc BattleResultDispatch
BattleResultDispatch:
  LDA sub_state                                           ; $B8C7: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $B8CA: 20 DE EA
; --- Inline pointer table (3 entries) ---
  .word BattleResult_Calculate                                         ; $B8CD: D3 B8
  .word BattleResult_CheckContinue                                         ; $B8CF: A5 B9
  .word BattleResult_Finalize                                         ; $B8D1: C8 B9
.endproc
;===============================================================================
; $B8D3: BattleResult_Calculate
;===============================================================================
.proc BattleResult_Calculate
  officer_data_ptr     = $0000
  ppu_tile_lo     = $0001
  battle_tile_attr      = $0002
  div_loop_count      = $0003
  col_counter_lo  = $0004
  work_val       = $0010
BattleResult_Calculate:
  INC sub_state                                           ; $B8D3: EE A9 04
  JSR BattleResult_ComputeDifferential                   ; $B8D6: 20 15 BA
  LDY active_player_slot                                           ; $B8D9: AC AA 04
  LDA player_action_timer_0,Y                                         ; $B8DC: B9 B5 04
  AND #$7F                                            ; $B8DF: 29 7F
  BEQ @loop_2                                           ; $B8E1: F0 26
  LDA work_val                                         ; $B8E3: AD 10 00
  CLC                                                 ; $B8E6: 18
  ADC #$14                                            ; $B8E7: 69 14
  STA work_val                                         ; $B8E9: 8D 10 00
  LDA ppu_tile_lo                                         ; $B8EC: AD 01 00
  ASL A                                               ; $B8EF: 0A
  CLC                                                 ; $B8F0: 18
  ADC ppu_tile_lo                                         ; $B8F1: 6D 01 00
  STA work_marker                                         ; $B8F4: 8D 02 00
@loop:
  LDA work_marker                                         ; $B8F7: AD 02 00
  CMP #$0A                                            ; $B8FA: C9 0A
  BCC @loop_2                                           ; $B8FC: 90 0B
  SBC #$0A                                            ; $B8FE: E9 0A
  STA work_marker                                         ; $B900: 8D 02 00
  INC ppu_tile_lo                                         ; $B903: EE 01 00
  JMP @loop                                           ; $B906: 4C F7 B8
@loop_2:
  LDA sub_action_type                                           ; $B909: AD BF 04
  BNE @skip_2                                           ; $B90C: D0 1D
  LDA work_val                                         ; $B90E: AD 10 00
  CMP #$64                                            ; $B911: C9 64
  BCC @skip                                           ; $B913: 90 03
  JMP BattleResult_ShowVictory                                           ; $B915: 4C A0 B9
@skip:
  LDA #$03                                            ; $B918: A9 03
  STA div_loop_count                                         ; $B91A: 8D 03 00
  LDA #$00                                            ; $B91D: A9 00
  STA work_marker                                         ; $B91F: 8D 02 00
  STA col_counter_lo                                         ; $B922: 8D 04 00
  JSR B1F_MathDiv16                                   ; $B925: 20 7C EA
  JMP BattleResult_ApplyTroopLoss                                           ; $B928: 4C 6D B9
@skip_2:
  CMP #$06                                            ; $B92B: C9 06
  BNE @skip_5                                           ; $B92D: D0 33
  LDA work_val                                         ; $B92F: AD 10 00
  CMP #$1E                                            ; $B932: C9 1E
  BCS @skip_3                                           ; $B934: B0 0A
  LDA ppu_tile_lo                                         ; $B936: AD 01 00
  ASL A                                               ; $B939: 0A
  STA ppu_tile_lo                                         ; $B93A: 8D 01 00
  JMP BattleResult_ApplyTroopLoss                                           ; $B93D: 4C 6D B9
@skip_3:
  JSR B1F_RandomByte                                  ; $B940: 20 7A E8
  AND #$1F                                            ; $B943: 29 1F
  CMP #$15                                            ; $B945: C9 15
  BCS @loop_2                                           ; $B947: B0 C0
  ADC #$0A                                            ; $B949: 69 0A
  STA officer_data_ptr                                         ; $B94B: 8D 00 00
  LDY active_player_slot                                           ; $B94E: AC AA 04
  LDA player_army_value_0,Y                                         ; $B951: B9 B1 04
  SEC                                                 ; $B954: 38
  SBC officer_data_ptr                                         ; $B955: ED 00 00
  BPL @skip_4                                           ; $B958: 10 02
  LDA #$00                                            ; $B95A: A9 00
@skip_4:
  STA player_army_value_0,Y                                         ; $B95C: 99 B1 04
  JMP BattleResult_ShowVictory                                           ; $B95F: 4C A0 B9
@skip_5:
  LDY active_player_slot                                           ; $B962: AC AA 04
  LDA work_val                                         ; $B965: AD 10 00
  CMP name_tile_ptr_lo,Y                                         ; $B968: D9 C5 04
  BCS BattleResult_ShowVictory                                           ; $B96B: B0 33
.endproc
;===============================================================================
; $B96D: BattleResult_ApplyTroopLoss
;===============================================================================
.proc BattleResult_ApplyTroopLoss
  officer_id_ext     = $042D
  ppu_tile_lo     = $0001
BattleResult_ApplyTroopLoss:
  LDA ppu_tile_lo                                         ; $B96D: AD 01 00
  BEQ @skip_2                                           ; $B970: F0 29
  BMI @skip_2                                           ; $B972: 30 27
  LDA active_player_slot                                           ; $B974: AD AA 04
  EOR #$01                                            ; $B977: 49 01
  TAY                                                 ; $B979: A8
  LDA player_army_value_0,Y                                         ; $B97A: B9 B1 04
  SEC                                                 ; $B97D: 38
  SBC ppu_tile_lo                                         ; $B97E: ED 01 00
  BCS @skip                                           ; $B981: B0 02
  LDA #$00                                            ; $B983: A9 00
@skip:
  STA player_army_value_0,Y                                         ; $B985: 99 B1 04
  LDA ppu_tile_lo                                         ; $B988: AD 01 00
  STA selected_officer_id                                           ; $B98B: 8D 2C 04
  LDA #$00                                            ; $B98E: A9 00
  STA officer_id_ext                                           ; $B990: 8D 2D 04
  STA battle_result_phase                                           ; $B993: 8D 2E 04
  LDA #$22                                            ; $B996: A9 22
  JMP B1F_SetUI4                                      ; $B998: 4C 8B F2
@skip_2:
  LDA #$39                                            ; $B99B: A9 39
  JMP B1F_SetUI4                                      ; $B99D: 4C 8B F2
.endproc
;===============================================================================
; $B9A0: BattleResult_ShowVictory
;===============================================================================
.proc BattleResult_ShowVictory
BattleResult_ShowVictory:
  LDA #$25                                            ; $B9A0: A9 25
  JMP B1F_SetUI0                                      ; $B9A2: 4C 6D F2
.endproc
;===============================================================================
; $B9A5: BattleResult_CheckContinue
;===============================================================================
.proc BattleResult_CheckContinue
BattleResult_CheckContinue:
  JSR CheckButtonConfirm                                           ; $B9A5: 20 99 D2
  BCC @skip                                           ; $B9A8: 90 1D
  JSR ReadMenuSelection                                           ; $B9AA: 20 3D D1
  LDA a:$0081                                         ; $B9AD: AD 81 00
  AND #$03                                            ; $B9B0: 29 03
  BEQ @skip                                           ; $B9B2: F0 13
  JSR FinalizeSpriteBuffer                                           ; $B9B4: 20 60 D0
  LDA #$FF                                            ; $B9B7: A9 FF
  STA sprite_y_buffer,X                                         ; $B9B9: 9D 80 03
  INC sub_state                                           ; $B9BC: EE A9 04
  LDA a:$007E                                         ; $B9BF: AD 7E 00
  ORA #$04                                            ; $B9C2: 09 04
  STA a:$007E                                         ; $B9C4: 8D 7E 00
@skip:
  RTS                                                 ; $B9C7: 60
.endproc
;===============================================================================
; $B9C8: BattleResult_Finalize
;===============================================================================
.proc BattleResult_Finalize
  ppu_tile_lo     = $0001
  battle_tile_attr      = $0002
  temp_0010       = $0010
  param_0560      = $0560
  param_056e      = $056E
  param_0570      = $0570
BattleResult_Finalize:
  LDA a:$007E                                         ; $B9C8: AD 7E 00
  AND #$04                                            ; $B9CB: 29 04
  BNE @skip                                           ; $B9CD: D0 1D
  LDY active_player_slot                                           ; $B9CF: AC AA 04
  LDA player_army_value_0,Y                                         ; $B9D2: B9 B1 04
  BEQ @skip_2                                           ; $B9D5: F0 16
  LDA active_player_slot                                           ; $B9D7: AD AA 04
  EOR #$01                                            ; $B9DA: 49 01
  TAY                                                 ; $B9DC: A8
  LDA player_army_value_0,Y                                         ; $B9DD: B9 B1 04
  BEQ @skip_2                                           ; $B9E0: F0 0B
  LDA #$01                                            ; $B9E2: A9 01
  STA game_state                                           ; $B9E4: 8D A8 04
  LDA #$00                                            ; $B9E7: A9 00
  STA sub_state                                           ; $B9E9: 8D A9 04
@skip:
  RTS                                                 ; $B9EC: 60
@skip_2:
  STY active_player_slot                                           ; $B9ED: 8C AA 04
  LDA player_officer_id_0,Y                                         ; $B9F0: B9 AD 04
  STA selected_officer_id                                           ; $B9F3: 8D 2C 04
  CPY #$01                                            ; $B9F6: C0 01
  BNE @skip_3                                           ; $B9F8: D0 02
  LDY #$02                                            ; $B9FA: A0 02
@skip_3:
  LDA #$02                                            ; $B9FC: A9 02
  STA player0_officer_hi,Y                                         ; $B9FE: 99 15 05
  TYA                                                 ; $BA01: 98
  EOR #$02                                            ; $BA02: 49 02
  TAY                                                 ; $BA04: A8
  LDA #$00                                            ; $BA05: A9 00
  STA player0_officer_hi,Y                                         ; $BA07: 99 15 05
  LDA #$0D                                            ; $BA0A: A9 0D
  STA game_state                                           ; $BA0C: 8D A8 04
  LDA #$00                                            ; $BA0F: A9 00
  STA sub_state                                           ; $BA11: 8D A9 04
  RTS                                                 ; $BA14: 60
BattleResult_ComputeDifferential:
  JSR B1F_RandomBelow100                              ; $BA15: 20 43 E8
  STA temp_0010                                         ; $BA18: 8D 10 00
  LDY #$00                                            ; $BA1B: A0 00
  LDX active_player_slot                                           ; $BA1D: AE AA 04
  LDA player_officer_id_0,X                                         ; $BA20: BD AD 04
  CMP param_0560                                           ; $BA23: CD 60 05
  BEQ @skip_4                                           ; $BA26: F0 02
  LDY #$01                                            ; $BA28: A0 01
@skip_4:
  LDA player_scene_index,Y                                         ; $BA2A: B9 C1 04
  STA ppu_tile_lo                                         ; $BA2D: 8D 01 00
  LDA param_0570,Y                                         ; $BA30: B9 70 05
  CLC                                                 ; $BA33: 18
  ADC ppu_tile_lo                                         ; $BA34: 6D 01 00
  LSR A                                               ; $BA37: 4A
  STA ppu_tile_lo                                         ; $BA38: 8D 01 00
  TYA                                                 ; $BA3B: 98
  EOR #$01                                            ; $BA3C: 49 01
  TAY                                                 ; $BA3E: A8
  LDA param_056e,Y                                         ; $BA3F: B9 6E 05
  STA work_marker                                         ; $BA42: 8D 02 00
  LDA ppu_tile_lo                                         ; $BA45: AD 01 00
  SEC                                                 ; $BA48: 38
  SBC work_marker                                         ; $BA49: ED 02 00
  STA ppu_tile_lo                                         ; $BA4C: 8D 01 00
@loop:
  JSR B1F_RandomByte                                  ; $BA4F: 20 7A E8
  AND #$0F                                            ; $BA52: 29 0F
  CMP #$0B                                            ; $BA54: C9 0B
  BCS @loop                                           ; $BA56: B0 F7
  SEC                                                 ; $BA58: 38
  SBC #$05                                            ; $BA59: E9 05
  STA work_marker                                         ; $BA5B: 8D 02 00
  LDA ppu_tile_lo                                         ; $BA5E: AD 01 00
  CLC                                                 ; $BA61: 18
  ADC work_marker                                         ; $BA62: 6D 02 00
  BPL @skip_5                                           ; $BA65: 10 02
  LDA #$00                                            ; $BA67: A9 00
@skip_5:
  STA ppu_tile_lo                                         ; $BA69: 8D 01 00
  RTS                                                 ; $BA6C: 60
.endproc
;===============================================================================
; $BA6D: SingleCombatDispatch
;===============================================================================
.proc SingleCombatDispatch
SingleCombatDispatch:
  LDA sub_state                                           ; $BA6D: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $BA70: 20 DE EA
; --- Inline pointer table (10 entries) ---
  .word SingleCombat_Init                                         ; $BA73: 87 BA
  .word SingleCombat_CheckContinue                                         ; $BA75: A5 BA
  .word SingleCombat_ShowMenu                                         ; $BA77: C0 BA
  .word SingleCombat_PlayerAction                                         ; $BA79: DA BA
  .word SingleCombat_RandomEvent                                         ; $BA7B: 03 BB
  .word SingleCombat_ShowMenu2                                         ; $BA7D: 41 BB
  .word SingleCombat_ApplyDamage                                         ; $BA7F: 5B BB
  .word SingleCombat_CheckFlee                                         ; $BA81: 93 BB
  .word SingleCombat_NextRound                                         ; $BA83: C0 BB
  .word SingleCombat_CheckEnd                                         ; $BA85: 00 BC
.endproc
;===============================================================================
; $BA87: SingleCombat_Init
;===============================================================================
.proc SingleCombat_Init
  officer_data_ptr     = $0000
SingleCombat_Init:
  JSR CheckButtonConfirm                                           ; $BA87: 20 99 D2
  BCC @skip                                           ; $BA8A: 90 18
  INC sub_state                                           ; $BA8C: EE A9 04
  LDY active_player_slot                                           ; $BA8F: AC AA 04
  LDA player_officer_id_0,Y                                         ; $BA92: B9 AD 04
  STA officer_data_ptr                                         ; $BA95: 8D 00 00
  LDY #$3D                                            ; $BA98: A0 3D
  JSR B1F_BankedCallbackTrampoline                    ; $BA9A: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A030                                         ; $BA9D: 30 A0
  LDA #$29                                            ; $BA9F: A9 29
  JMP B1F_SetUI0                                      ; $BAA1: 4C 6D F2
@skip:
  RTS                                                 ; $BAA4: 60
.endproc
;===============================================================================
; $BAA5: SingleCombat_CheckContinue
;===============================================================================
.proc SingleCombat_CheckContinue
SingleCombat_CheckContinue:
  JSR SetupMenuPtr                                           ; $BAA5: 20 66 D1
  JSR CheckButtonConfirm                                           ; $BAA8: 20 99 D2
  BCC @skip                                           ; $BAAB: 90 12
  JSR ReadMenuSelection                                           ; $BAAD: 20 3D D1
  LDA a:$0081                                         ; $BAB0: AD 81 00
  AND #$03                                            ; $BAB3: 29 03
  BEQ @skip                                           ; $BAB5: F0 08
  INC sub_state                                           ; $BAB7: EE A9 04
  LDA #$00                                            ; $BABA: A9 00
  JMP B1F_SetUI4                                      ; $BABC: 4C 8B F2
@skip:
  RTS                                                 ; $BABF: 60
.endproc
;===============================================================================
; $BAC0: SingleCombat_ShowMenu
;===============================================================================
.proc SingleCombat_ShowMenu
SingleCombat_ShowMenu:
  JSR CheckButtonConfirm                                           ; $BAC0: 20 99 D2
  BCC @skip                                           ; $BAC3: 90 14
  LDA #$04                                            ; $BAC5: A9 04
  STA display_ptr_lo                                           ; $BAC7: 8D BD 04
  LDA #$03                                            ; $BACA: A9 03
  STA display_ptr_hi                                           ; $BACC: 8D BE 04
  LDA #$14                                            ; $BACF: A9 14
  STA game_state                                           ; $BAD1: 8D A8 04
  LDA #$00                                            ; $BAD4: A9 00
  STA sub_state                                           ; $BAD6: 8D A9 04
@skip:
  RTS                                                 ; $BAD9: 60
.endproc
;===============================================================================
; $BADA: SingleCombat_PlayerAction
;===============================================================================
.proc SingleCombat_PlayerAction
  officer_data_ptr     = $0000
  callback_result       = $00A4
SingleCombat_PlayerAction:
  JSR CheckButtonConfirm                                           ; $BADA: 20 99 D2
  BCC @skip                                           ; $BADD: 90 23
  LDA active_player_slot                                           ; $BADF: AD AA 04
  EOR #$01                                            ; $BAE2: 49 01
  STA active_player_slot                                           ; $BAE4: 8D AA 04
  TAY                                                 ; $BAE7: A8
  LDA player_officer_id_0,Y                                         ; $BAE8: B9 AD 04
  STA officer_data_ptr                                         ; $BAEB: 8D 00 00
  LDY #$3D                                            ; $BAEE: A0 3D
  JSR B1F_BankedCallbackTrampoline                    ; $BAF0: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A030                                         ; $BAF3: 30 A0
  LDA #$02                                            ; $BAF5: A9 02
  STA a:zp_a4                                         ; $BAF7: 8D A4 00
  INC sub_state                                           ; $BAFA: EE A9 04
  LDA #$2A                                            ; $BAFD: A9 2A
  JMP B1F_SetUI0                                      ; $BAFF: 4C 6D F2
@skip:
  RTS                                                 ; $BB02: 60
.endproc
;===============================================================================
; $BB03: SingleCombat_RandomEvent
;===============================================================================
.proc SingleCombat_RandomEvent
  work_0011       = $0011
SingleCombat_RandomEvent:
  LDA active_player_slot                                           ; $BB03: AD AA 04
  JSR SetupMenuPtr                                           ; $BB06: 20 66 D1
  JSR CheckButtonConfirm                                           ; $BB09: 20 99 D2
  BCC @skip_2                                           ; $BB0C: 90 32
  JSR ReadMenuSelection                                           ; $BB0E: 20 3D D1
  LDA a:$0081                                         ; $BB11: AD 81 00
  AND #$03                                            ; $BB14: 29 03
  BEQ @skip_2                                           ; $BB16: F0 28
  LDA active_player_slot                                           ; $BB18: AD AA 04
  EOR #$01                                            ; $BB1B: 49 01
  TAY                                                 ; $BB1D: A8
  LDA player_random_offset_0,Y                                         ; $BB1E: B9 B3 04
  ASL A                                               ; $BB21: 0A
  CLC                                                 ; $BB22: 18
  STA work_0011                                         ; $BB23: 8D 11 00
  JSR B1F_RandomBelow100                              ; $BB26: 20 43 E8
  CMP work_0011                                         ; $BB29: CD 11 00
  BCS @skip                                           ; $BB2C: B0 0A
  LDA #$09                                            ; $BB2E: A9 09
  STA sub_state                                           ; $BB30: 8D A9 04
  LDA #$3C                                            ; $BB33: A9 3C
  JMP B1F_SetUI0                                      ; $BB35: 4C 6D F2
@skip:
  INC sub_state                                           ; $BB38: EE A9 04
  LDA #$00                                            ; $BB3B: A9 00
  JMP B1F_SetUI4                                      ; $BB3D: 4C 8B F2
@skip_2:
  RTS                                                 ; $BB40: 60
.endproc
;===============================================================================
; $BB41: SingleCombat_ShowMenu2
;===============================================================================
.proc SingleCombat_ShowMenu2
SingleCombat_ShowMenu2:
  JSR CheckButtonConfirm                                           ; $BB41: 20 99 D2
  BCC @skip                                           ; $BB44: 90 14
  LDA #$04                                            ; $BB46: A9 04
  STA display_ptr_lo                                           ; $BB48: 8D BD 04
  LDA #$06                                            ; $BB4B: A9 06
  STA display_ptr_hi                                           ; $BB4D: 8D BE 04
  LDA #$15                                            ; $BB50: A9 15
  STA game_state                                           ; $BB52: 8D A8 04
  LDA #$00                                            ; $BB55: A9 00
  STA sub_state                                           ; $BB57: 8D A9 04
@skip:
  RTS                                                 ; $BB5A: 60
.endproc
;===============================================================================
; $BB5B: SingleCombat_ApplyDamage
;===============================================================================
.proc SingleCombat_ApplyDamage
  damage_amount_lo     = $042F
  damage_amount_hi     = $0430
  damage_applied       = $0431
  officer_data_ptr     = $0000
SingleCombat_ApplyDamage:
  LDA #$0A                                            ; $BB5B: A9 0A
  JSR B1F_RandomBelowThreshold                        ; $BB5D: 20 62 E8
  CLC                                                 ; $BB60: 18
  ADC #$05                                            ; $BB61: 69 05
  STA damage_amount_lo                                           ; $BB63: 8D 2F 04
  LDA #$00                                            ; $BB66: A9 00
  STA damage_amount_hi                                           ; $BB68: 8D 30 04
  STA damage_applied                                           ; $BB6B: 8D 31 04
  LDA active_player_slot                                           ; $BB6E: AD AA 04
  EOR #$01                                            ; $BB71: 49 01
  TAY                                                 ; $BB73: A8
  LDA player_officer_id_0,Y                                         ; $BB74: B9 AD 04
  STA selected_officer_id                                           ; $BB77: 8D 2C 04
  JSR B1F_GetOfficerRecordAddr                        ; $BB7A: 20 D7 F2
  LDY #$00                                            ; $BB7D: A0 00
  LDA (officer_data_ptr),Y                                         ; $BB7F: B1 00
  SEC                                                 ; $BB81: 38
  SBC damage_amount_lo                                           ; $BB82: ED 2F 04
  BPL @skip                                           ; $BB85: 10 02
  LDA #$00                                            ; $BB87: A9 00
@skip:
  STA (officer_data_ptr),Y                                         ; $BB89: 91 00
  INC sub_state                                           ; $BB8B: EE A9 04
  LDA #$3D                                            ; $BB8E: A9 3D
  JMP B1F_SetUI4                                      ; $BB90: 4C 8B F2
.endproc
;===============================================================================
; $BB93: SingleCombat_CheckFlee
;===============================================================================
.proc SingleCombat_CheckFlee
  officer_data_ptr     = $0000
SingleCombat_CheckFlee:
  JSR CheckButtonConfirm                                           ; $BB93: 20 99 D2
  BCC @skip_2                                           ; $BB96: 90 27
  JSR ReadMenuSelection                                           ; $BB98: 20 3D D1
  LDA a:$0081                                         ; $BB9B: AD 81 00
  AND #$03                                            ; $BB9E: 29 03
  BEQ @skip_2                                           ; $BBA0: F0 1D
  LDA active_player_slot                                           ; $BBA2: AD AA 04
  EOR #$01                                            ; $BBA5: 49 01
  TAY                                                 ; $BBA7: A8
  LDA player_officer_id_0,Y                                         ; $BBA8: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $BBAB: 20 D7 F2
  LDY #$00                                            ; $BBAE: A0 00
  LDA (officer_data_ptr),Y                                         ; $BBB0: B1 00
  BEQ @skip                                           ; $BBB2: F0 03
  JMP SingleCombat_SwapActive                                           ; $BBB4: 4C 16 BC
@skip:
  INC sub_state                                           ; $BBB7: EE A9 04
  LDA #$26                                            ; $BBBA: A9 26
  JMP B1F_SetUI4                                      ; $BBBC: 4C 8B F2
@skip_2:
  RTS                                                 ; $BBBF: 60
.endproc
;===============================================================================
; $BBC0: SingleCombat_NextRound
;===============================================================================
.proc SingleCombat_NextRound
SingleCombat_NextRound:
  JSR CheckButtonConfirm                                           ; $BBC0: 20 99 D2
  BCC @skip                                           ; $BBC3: 90 0A
  JSR ReadMenuSelection                                           ; $BBC5: 20 3D D1
  LDA a:$0081                                         ; $BBC8: AD 81 00
  AND #$03                                            ; $BBCB: 29 03
  BNE @skip_2                                           ; $BBCD: D0 01
@skip:
  RTS                                                 ; $BBCF: 60
@skip_2:
  LDA active_player_slot                                           ; $BBD0: AD AA 04
  EOR #$01                                            ; $BBD3: 49 01
  TAY                                                 ; $BBD5: A8
  LDA player_officer_id_0,Y                                         ; $BBD6: B9 AD 04
  STA selected_officer_id                                           ; $BBD9: 8D 2C 04
  CPY #$01                                            ; $BBDC: C0 01
  BNE @skip_3                                           ; $BBDE: D0 02
  LDY #$02                                            ; $BBE0: A0 02
@skip_3:
  LDA #$02                                            ; $BBE2: A9 02
  STA player0_officer_hi,Y                                         ; $BBE4: 99 15 05
  TYA                                                 ; $BBE7: 98
  EOR #$02                                            ; $BBE8: 49 02
  TAY                                                 ; $BBEA: A8
  LDA #$00                                            ; $BBEB: A9 00
  STA player0_officer_hi,Y                                         ; $BBED: 99 15 05
  LDA #$0E                                            ; $BBF0: A9 0E
  STA game_state                                           ; $BBF2: 8D A8 04
  LDA #$00                                            ; $BBF5: A9 00
  STA sub_state                                           ; $BBF7: 8D A9 04
  LDA #$FF                                            ; $BBFA: A9 FF
  STA frame_counter                                           ; $BBFC: 8D C0 04
  RTS                                                 ; $BBFF: 60
.endproc
;===============================================================================
; $BC00: SingleCombat_CheckEnd
;===============================================================================
.proc SingleCombat_CheckEnd
SingleCombat_CheckEnd:
  LDA active_player_slot                                           ; $BC00: AD AA 04
  JSR SetupMenuPtr                                           ; $BC03: 20 66 D1
  JSR CheckButtonConfirm                                           ; $BC06: 20 99 D2
  BCC @skip                                           ; $BC09: 90 0A
  JSR ReadMenuSelection                                           ; $BC0B: 20 3D D1
  LDA a:$0081                                         ; $BC0E: AD 81 00
  AND #$03                                            ; $BC11: 29 03
  BNE SingleCombat_SwapActive                                           ; $BC13: D0 01
@skip:
  RTS                                                 ; $BC15: 60
.endproc
;===============================================================================
; $BC16: SingleCombat_SwapActive
;===============================================================================
.proc SingleCombat_SwapActive
SingleCombat_SwapActive:
  LDA active_player_slot                                           ; $BC16: AD AA 04
  EOR #$01                                            ; $BC19: 49 01
  STA active_player_slot                                           ; $BC1B: 8D AA 04
  BEQ @skip                                           ; $BC1E: F0 02
  LDY #$02                                            ; $BC20: A0 02
@skip:
  LDA #$01                                            ; $BC22: A9 01
  STA player0_officer_hi,Y                                         ; $BC24: 99 15 05
  TYA                                                 ; $BC27: 98
  EOR #$02                                            ; $BC28: 49 02
  TAY                                                 ; $BC2A: A8
  LDA #$00                                            ; $BC2B: A9 00
  STA player0_officer_hi,Y                                         ; $BC2D: 99 15 05
  LDA #$0F                                            ; $BC30: A9 0F
  STA game_state                                           ; $BC32: 8D A8 04
  LDA #$00                                            ; $BC35: A9 00
  STA sub_state                                           ; $BC37: 8D A9 04
  RTS                                                 ; $BC3A: 60
.endproc
;===============================================================================
; $BC3B: DiplomacyDispatch
;===============================================================================
.proc DiplomacyDispatch
DiplomacyDispatch:
  LDA sub_state                                           ; $BC3B: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $BC3E: 20 DE EA
; --- Inline pointer table (3 entries) ---
  .word Diplomacy_Init                                         ; $BC41: 47 BC
  .word Diplomacy_ShowMenu                                         ; $BC43: 5C BC
  .word Diplomacy_HandleAction                                         ; $BC45: 8C BC
.endproc
;===============================================================================
; $BC47: Diplomacy_Init
;===============================================================================
.proc Diplomacy_Init
Diplomacy_Init:
  INC sub_state                                           ; $BC47: EE A9 04
  LDA #$00                                            ; $BC4A: A9 00
  STA domestic_cursor_lo                                           ; $BC4C: 8D 0C 04
  STA domestic_cursor_hi                                           ; $BC4F: 8D 0D 04
  LDY display_ptr_hi                                           ; $BC52: AC BE 04
  LDA player_officer_id_0,Y                                         ; $BC55: B9 AD 04
  STA domestic_officer_list_lo                                           ; $BC58: 8D 10 04
  RTS                                                 ; $BC5B: 60
.endproc
;===============================================================================
; $BC5C: Diplomacy_ShowMenu
;===============================================================================
.proc Diplomacy_ShowMenu
  temp_0097       = $0097
  temp_00bb       = $00BB
Diplomacy_ShowMenu:
  LDA display_ptr_hi                                           ; $BC5C: AD BE 04
  STA active_player_slot                                           ; $BC5F: 8D AA 04
  JSR SetupMenuPtr                                           ; $BC62: 20 66 D1
  LDA sub_action_type                                           ; $BC65: AD BF 04
  STA active_player_slot                                           ; $BC68: 8D AA 04
  LDY #$39                                            ; $BC6B: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $BC6D: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                                         ; $BC70: 12 A0
  LDA domestic_cursor_hi                                           ; $BC72: AD 0D 04
  CMP #$FF                                            ; $BC75: C9 FF
  BNE @skip                                           ; $BC77: D0 12
  LDA #$06                                            ; $BC79: A9 06
  STA temp_00bb                                         ; $BC7B: 8D BB 00
  INC sub_state                                           ; $BC7E: EE A9 04
  LDA #$00                                            ; $BC81: A9 00
  STA a:$0098                                         ; $BC83: 8D 98 00
  LDA #$01                                            ; $BC86: A9 01
  STA temp_0097                                         ; $BC88: 8D 97 00
@skip:
  RTS                                                 ; $BC8B: 60
.endproc
;===============================================================================
; $BC8C: Diplomacy_HandleAction
;===============================================================================
.proc Diplomacy_HandleAction
  diplomacy_flags       = $0010
  temp_0097       = $0097
  ptr_00bb_lo     = $00BB
  ptr_00bb_hi     = $00BC
  temp_00bd       = $00BD
Diplomacy_HandleAction:
  LDA display_ptr_hi                                           ; $BC8C: AD BE 04
  STA active_player_slot                                           ; $BC8F: 8D AA 04
  JSR SetupMenuPtr                                           ; $BC92: 20 66 D1
  LDA sub_action_type                                           ; $BC95: AD BF 04
  STA active_player_slot                                           ; $BC98: 8D AA 04
  LDA domestic_cursor_hi                                           ; $BC9B: AD 0D 04
  BPL @skip                                           ; $BC9E: 10 1E
  LDA a:$0081                                         ; $BCA0: AD 81 00
  STA diplomacy_flags                                         ; $BCA3: 8D 10 00
  AND #$02                                            ; $BCA6: 29 02
  BNE @skip_2                                           ; $BCA8: D0 15
  LDA diplomacy_flags                                         ; $BCAA: AD 10 00
  AND #$30                                            ; $BCAD: 29 30
  BEQ @skip                                           ; $BCAF: F0 0D
  LDA display_ptr_hi                                           ; $BCB1: AD BE 04
  EOR #$01                                            ; $BCB4: 49 01
  STA display_ptr_hi                                           ; $BCB6: 8D BE 04
  LDA #$00                                            ; $BCB9: A9 00
  STA sub_state                                           ; $BCBB: 8D A9 04
@skip:
  RTS                                                 ; $BCBE: 60
@skip_2:
  LDA #$01                                            ; $BCBF: A9 01
  STA game_state                                           ; $BCC1: 8D A8 04
  LDA #$02                                            ; $BCC4: A9 02
  STA sub_state                                           ; $BCC6: 8D A9 04
  LDA sub_action_type                                           ; $BCC9: AD BF 04
  STA active_player_slot                                           ; $BCCC: 8D AA 04
  LDA #$09                                            ; $BCCF: A9 09
  STA ptr_00bb_lo                                         ; $BCD1: 8D BB 00
  LDA #$06                                            ; $BCD4: A9 06
  STA ptr_00bb_hi                                         ; $BCD6: 8D BC 00
  LDA #$0C                                            ; $BCD9: A9 0C
  STA temp_00bd                                         ; $BCDB: 8D BD 00
  LDA #$00                                            ; $BCDE: A9 00
  STA temp_0097                                         ; $BCE0: 8D 97 00
  LDA #$A0                                            ; $BCE3: A9 A0
  STA a:$0098                                         ; $BCE5: 8D 98 00
  RTS                                                 ; $BCE8: 60
.endproc
;===============================================================================
; $BCE9: EventCutsceneDispatch
;===============================================================================
.proc EventCutsceneDispatch
EventCutsceneDispatch:
  LDA sub_state                                           ; $BCE9: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $BCEC: 20 DE EA
; --- Inline pointer table (6 entries) ---
  .word EventCutscene_Init                                         ; $BCEF: FB BC
  .word EventCutscene_ShowText                                         ; $BCF1: 1E BD
  .word EventCutscene_Display                                         ; $BCF3: 40 BD
  .word EventCutscene_NoEvent                                         ; $BCF5: 5D BD
  .word EventCutscene_Execute                                         ; $BCF7: A9 BD
  .word EventCutscene_Cleanup                                         ; $BCF9: 3F BE
.endproc
;===============================================================================
; $BCFB: EventCutscene_Init
;===============================================================================
.proc EventCutscene_Init
  officer_data_ptr     = $0000
  callback_result       = $00A4
EventCutscene_Init:
  JSR CheckButtonConfirm                                           ; $BCFB: 20 99 D2
  BCC @skip                                           ; $BCFE: 90 1D
  INC sub_state                                           ; $BD00: EE A9 04
  LDY active_player_slot                                           ; $BD03: AC AA 04
  LDA player_officer_id_0,Y                                         ; $BD06: B9 AD 04
  STA officer_data_ptr                                         ; $BD09: 8D 00 00
  LDY #$3D                                            ; $BD0C: A0 3D
  JSR B1F_BankedCallbackTrampoline                    ; $BD0E: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A030                                         ; $BD11: 30 A0
  LDA #$04                                            ; $BD13: A9 04
  STA a:zp_a4                                         ; $BD15: 8D A4 00
  LDA #$27                                            ; $BD18: A9 27
  JMP B1F_SetUI0                                      ; $BD1A: 4C 6D F2
@skip:
  RTS                                                 ; $BD1D: 60
.endproc
;===============================================================================
; $BD1E: EventCutscene_ShowText
;===============================================================================
.proc EventCutscene_ShowText
EventCutscene_ShowText:
  JSR SetupMenuPtr                                           ; $BD1E: 20 66 D1
  JSR CheckButtonConfirm                                           ; $BD21: 20 99 D2
  BCC EventCutscene_NoOp                                           ; $BD24: 90 36
  JSR ReadMenuSelection                                           ; $BD26: 20 3D D1
  LDA a:$0081                                         ; $BD29: AD 81 00
  AND #$03                                            ; $BD2C: 29 03
  BEQ EventCutscene_NoOp                                           ; $BD2E: F0 2C
  INC sub_state                                           ; $BD30: EE A9 04
  JSR B1F_BankPpuInit                                 ; $BD33: 20 7F E5
  LDA #$6C                                            ; $BD36: A9 6C
  JSR B1F_SoundWrapperC                               ; $BD38: 20 83 E6
  LDA #$00                                            ; $BD3B: A9 00
  JMP B1F_SetUI4                                      ; $BD3D: 4C 8B F2
.endproc
;===============================================================================
; $BD40: EventCutscene_Display
;===============================================================================
.proc EventCutscene_Display
  officer_data_ptr     = $0000
EventCutscene_Display:
  JSR CheckButtonConfirm                                           ; $BD40: 20 99 D2
  BCC EventCutscene_NoOp                                           ; $BD43: 90 17
  INC sub_state                                           ; $BD45: EE A9 04
  LDA #$43                                            ; $BD48: A9 43
  STA officer_data_ptr                                         ; $BD4A: 8D 00 00
  LDY active_player_slot                                           ; $BD4D: AC AA 04
  BEQ @skip                                           ; $BD50: F0 05
  LDA #$55                                            ; $BD52: A9 55
  STA officer_data_ptr                                         ; $BD54: 8D 00 00
@skip:
  LDA #$00                                            ; $BD57: A9 00
  JMP BuildPPUTileBuffer                                           ; $BD59: 4C FD CD
.endproc
;===============================================================================
; $BD5C: EventCutscene_NoOp
;===============================================================================
.proc EventCutscene_NoOp
EventCutscene_NoOp:
  RTS                                                 ; $BD5C: 60
.endproc
;===============================================================================
; $BD5D: EventCutscene_NoEvent
;===============================================================================
.proc EventCutscene_NoEvent
  officer_data_ptr     = $0000
  ptr_00c6_lo     = $00C6
  ptr_00c6_hi     = $00C7
  temp_00c8       = $00C8
  ptr_00ce_lo     = $00CE
  ptr_00ce_hi     = $00CF
  temp_00d0       = $00D0
  ptr_00d6_lo     = $00D6
  ptr_00d6_hi     = $00D7
  temp_00d8       = $00D8
EventCutscene_NoEvent:
  LDA #$98                                            ; $BD5D: A9 98
  STA a:zp_c6                                         ; $BD5F: 8D C6 00
  STA a:zp_ce                                         ; $BD62: 8D CE 00
  STA a:zp_d6                                         ; $BD65: 8D D6 00
  LDA #$99                                            ; $BD68: A9 99
  STA a:zp_c7                                         ; $BD6A: 8D C7 00
  STA a:zp_cf                                         ; $BD6D: 8D CF 00
  STA a:zp_d7                                         ; $BD70: 8D D7 00
  LDA #$02                                            ; $BD73: A9 02
  STA a:zp_c8                                         ; $BD75: 8D C8 00
  STA a:zp_d0                                         ; $BD78: 8D D0 00
  STA a:zp_d8                                         ; $BD7B: 8D D8 00
  LDA #$00                                            ; $BD7E: A9 00
  STA anim_timer                                           ; $BD80: 8D B8 04
  LDA #$5F                                            ; $BD83: A9 5F
  STA scroll_row_count                                           ; $BD85: 8D BA 04
  INC sub_state                                           ; $BD88: EE A9 04
  LDA #$18                                            ; $BD8B: A9 18
  STA slide_y_pos                                           ; $BD8D: 8D BB 04
  LDA #$E3                                            ; $BD90: A9 E3
  STA officer_data_ptr                                         ; $BD92: 8D 00 00
  LDY active_player_slot                                           ; $BD95: AC AA 04
  BEQ @skip                                           ; $BD98: F0 0A
  LDA #$A8                                            ; $BD9A: A9 A8
  STA slide_y_pos                                           ; $BD9C: 8D BB 04
  LDA #$F5                                            ; $BD9F: A9 F5
  STA officer_data_ptr                                         ; $BDA1: 8D 00 00
@skip:
  LDA #$00                                            ; $BDA4: A9 00
  JMP BuildPPUTileBuffer                                           ; $BDA6: 4C FD CD
.endproc
;===============================================================================
; $BDA9: EventCutscene_Execute
;===============================================================================
.proc EventCutscene_Execute
  officer_data_ptr     = $0000
  event_tile_attr      = $0002
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
EventCutscene_Execute:
  INC anim_timer                                           ; $BDA9: EE B8 04
  LDA anim_timer                                           ; $BDAC: AD B8 04
  LSR A                                               ; $BDAF: 4A
  LSR A                                               ; $BDB0: 4A
  LSR A                                               ; $BDB1: 4A
  LSR A                                               ; $BDB2: 4A
  LSR A                                               ; $BDB3: 4A
  AND #$07                                            ; $BDB4: 29 07
  CMP #$05                                            ; $BDB6: C9 05
  BNE LBDCB                                           ; $BDB8: D0 11
  INC sub_state                                           ; $BDBA: EE A9 04
  LDY active_player_slot                                           ; $BDBD: AC AA 04
  LDA player_officer_id_0,Y                                         ; $BDC0: B9 AD 04
  STA selected_officer_id                                           ; $BDC3: 8D 2C 04
  LDA #$28                                            ; $BDC6: A9 28
  JMP B1F_SetUI4                                      ; $BDC8: 4C 8B F2
LBDCB:
  STA ptr_0010_lo                                         ; $BDCB: 8D 10 00
  STA ptr_0010_hi                                         ; $BDCE: 8D 11 00
  LDA active_player_slot                                           ; $BDD1: AD AA 04
  BNE @skip                                           ; $BDD4: D0 09
  LDA ptr_0010_lo                                         ; $BDD6: AD 10 00
  CLC                                                 ; $BDD9: 18
  ADC #$1A                                            ; $BDDA: 69 1A
  STA ptr_0010_lo                                         ; $BDDC: 8D 10 00
@skip:
  LDA #$00                                            ; $BDDF: A9 00
  STA work_marker                                         ; $BDE1: 8D 02 00
  LDA ptr_0010_lo                                         ; $BDE4: AD 10 00
  CLC                                                 ; $BDE7: 18
  ADC #$A8                                            ; $BDE8: 69 A8
  JSR DrawSpriteFromBank                                           ; $BDEA: 20 A5 CE
  LDA active_player_slot                                           ; $BDED: AD AA 04
  CLC                                                 ; $BDF0: 18
  ADC #$01                                            ; $BDF1: 69 01
  STA work_marker                                         ; $BDF3: 8D 02 00
  LDY active_player_slot                                           ; $BDF6: AC AA 04
  LDA name_tile_index,Y                                         ; $BDF9: B9 AF 04
  STA officer_data_ptr                                         ; $BDFC: 8D 00 00
  ASL A                                               ; $BDFF: 0A
  ASL A                                               ; $BE00: 0A
  CLC                                                 ; $BE01: 18
  ADC officer_data_ptr                                         ; $BE02: 6D 00 00
  ADC ptr_0010_lo                                         ; $BE05: 6D 10 00
  ADC #$AD                                            ; $BE08: 69 AD
  JSR DrawSpriteFromBank                                           ; $BE0A: 20 A5 CE
  LDA ptr_0010_lo                                         ; $BE0D: AD 10 00
  SEC                                                 ; $BE10: 38
  SBC ptr_0010_hi                                         ; $BE11: ED 11 00
  STA ptr_0010_lo                                         ; $BE14: 8D 10 00
  LDA #$00                                            ; $BE17: A9 00
  STA work_marker                                         ; $BE19: 8D 02 00
  LDA ptr_0010_hi                                         ; $BE1C: AD 11 00
  CMP #$02                                            ; $BE1F: C9 02
  BCC @skip_3                                           ; $BE21: 90 1B
  LDY #$BC                                            ; $BE23: A0 BC
  CMP #$02                                            ; $BE25: C9 02
  BEQ @skip_2                                           ; $BE27: F0 02
  LDY #$BF                                            ; $BE29: A0 BF
@skip_2:
  STY officer_data_ptr                                         ; $BE2B: 8C 00 00
  LDY active_player_slot                                           ; $BE2E: AC AA 04
  LDA name_tile_index,Y                                         ; $BE31: B9 AF 04
  CLC                                                 ; $BE34: 18
  ADC ptr_0010_lo                                         ; $BE35: 6D 10 00
  ADC officer_data_ptr                                         ; $BE38: 6D 00 00
  JMP DrawSpriteFromBank                                           ; $BE3B: 4C A5 CE
@skip_3:
  RTS                                                 ; $BE3E: 60
.endproc
;===============================================================================
; $BE3F: EventCutscene_Cleanup
;===============================================================================
.proc EventCutscene_Cleanup
EventCutscene_Cleanup:
  LDA #$04                                            ; $BE3F: A9 04
  JSR LBDCB                                           ; $BE41: 20 CB BD
  JSR CheckButtonConfirm                                           ; $BE44: 20 99 D2
  BCC @skip_2                                           ; $BE47: 90 2E
  JSR ReadMenuSelection                                           ; $BE49: 20 3D D1
  LDA a:$0081                                         ; $BE4C: AD 81 00
  AND #$03                                            ; $BE4F: 29 03
  BEQ @skip_2                                           ; $BE51: F0 24
  LDY active_player_slot                                           ; $BE53: AC AA 04
  BEQ @skip                                           ; $BE56: F0 02
  LDY #$02                                            ; $BE58: A0 02
@skip:
  LDA #$03                                            ; $BE5A: A9 03
  STA player0_officer_hi,Y                                         ; $BE5C: 99 15 05
  TYA                                                 ; $BE5F: 98
  EOR #$02                                            ; $BE60: 49 02
  TAY                                                 ; $BE62: A8
  LDA #$00                                            ; $BE63: A9 00
  STA player0_officer_hi,Y                                         ; $BE65: 99 15 05
  LDA #$80                                            ; $BE68: A9 80
  STA frame_counter                                           ; $BE6A: 8D C0 04
  LDA #$0E                                            ; $BE6D: A9 0E
  STA game_state                                           ; $BE6F: 8D A8 04
  LDA #$00                                            ; $BE72: A9 00
  STA sub_state                                           ; $BE74: 8D A9 04
@skip_2:
  RTS                                                 ; $BE77: 60
.endproc
;===============================================================================
; $BE78: BattleInitDispatch
;===============================================================================
.proc BattleInitDispatch
BattleInitDispatch:
  LDA sub_state                                           ; $BE78: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $BE7B: 20 DE EA
; --- Inline pointer table (4 entries) ---
  .word BattleInit_Setup                                         ; $BE7E: 86 BE
  .word BattleInit_Position                                         ; $BE80: 43 BF
  .word BattleInit_Configure                                         ; $BE82: 66 BF
  .word BattleInit_Finalize                                         ; $BE84: 7E BF
.endproc
;===============================================================================
; $BE86: BattleInit_Setup
;===============================================================================
.proc BattleInit_Setup
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  formation_score       = $0012
BattleInit_Setup:
  LDA active_player_slot                                           ; $BE86: AD AA 04
  EOR #$01                                            ; $BE89: 49 01
  TAY                                                 ; $BE8B: A8
  LDA player_officer_id_0,Y                                         ; $BE8C: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $BE8F: 20 D7 F2
  LDY #$03                                            ; $BE92: A0 03
  LDA (officer_data_ptr),Y                                         ; $BE94: B1 00
  STA ptr_0010_lo                                         ; $BE96: 8D 10 00
  LDY #$00                                            ; $BE99: A0 00
  LDA (officer_data_ptr),Y                                         ; $BE9B: B1 00
  STA ptr_0010_hi                                         ; $BE9D: 8D 11 00
  LDY active_player_slot                                           ; $BEA0: AC AA 04
  LDA player_officer_id_0,Y                                         ; $BEA3: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $BEA6: 20 D7 F2
  LDY #$02                                            ; $BEA9: A0 02
  LDA (officer_data_ptr),Y                                         ; $BEAB: B1 00
  STA formation_score                                         ; $BEAD: 8D 12 00
  LDY #$04                                            ; $BEB0: A0 04
  LDA (officer_data_ptr),Y                                         ; $BEB2: B1 00
  CLC                                                 ; $BEB4: 18
  ADC formation_score                                         ; $BEB5: 6D 12 00
  STA formation_score                                         ; $BEB8: 8D 12 00
  LDX #$00                                            ; $BEBB: A2 00
  LDA ptr_0010_lo                                         ; $BEBD: AD 10 00
  CMP #$50                                            ; $BEC0: C9 50
  BCS @skip                                           ; $BEC2: B0 11
  TXA                                                 ; $BEC4: 8A
  CLC                                                 ; $BEC5: 18
  ADC #$18                                            ; $BEC6: 69 18
  TAX                                                 ; $BEC8: AA
  LDA ptr_0010_lo                                         ; $BEC9: AD 10 00
  CMP #$32                                            ; $BECC: C9 32
  BCS @skip                                           ; $BECE: B0 05
  TXA                                                 ; $BED0: 8A
  CLC                                                 ; $BED1: 18
  ADC #$18                                            ; $BED2: 69 18
  TAX                                                 ; $BED4: AA
@skip:
  LDA ptr_0010_hi                                         ; $BED5: AD 11 00
  CMP #$50                                            ; $BED8: C9 50
  BCS @skip_2                                           ; $BEDA: B0 11
  TXA                                                 ; $BEDC: 8A
  CLC                                                 ; $BEDD: 18
  ADC #$08                                            ; $BEDE: 69 08
  TAX                                                 ; $BEE0: AA
  LDA ptr_0010_hi                                         ; $BEE1: AD 11 00
  CMP #$32                                            ; $BEE4: C9 32
  BCS @skip_2                                           ; $BEE6: B0 05
  TXA                                                 ; $BEE8: 8A
  CLC                                                 ; $BEE9: 18
  ADC #$08                                            ; $BEEA: 69 08
  TAX                                                 ; $BEEC: AA
@skip_2:
  LDA formation_score                                         ; $BEED: AD 12 00
  CMP #$B4                                            ; $BEF0: C9 B4
  BCS @skip_3                                           ; $BEF2: B0 11
  TXA                                                 ; $BEF4: 8A
  CLC                                                 ; $BEF5: 18
  ADC #$48                                            ; $BEF6: 69 48
  TAX                                                 ; $BEF8: AA
  LDA formation_score                                         ; $BEF9: AD 12 00
  CMP #$82                                            ; $BEFC: C9 82
  BCS @skip_3                                           ; $BEFE: B0 05
  TXA                                                 ; $BF00: 8A
  CLC                                                 ; $BF01: 18
  ADC #$48                                            ; $BF02: 69 48
  TAX                                                 ; $BF04: AA
@skip_3:
  JSR B1F_RandomMod8                                  ; $BF05: 20 56 E8
  STA ptr_0010_lo                                         ; $BF08: 8D 10 00
  TXA                                                 ; $BF0B: 8A
  CLC                                                 ; $BF0C: 18
  ADC ptr_0010_lo                                         ; $BF0D: 6D 10 00
  TAX                                                 ; $BF10: AA
  LDA BattleInit_FormationData,X                                         ; $BF11: BD B2 BF
  STA sub_action_type                                           ; $BF14: 8D BF 04
  CLC                                                 ; $BF17: 18
  ADC #$33                                            ; $BF18: 69 33
  STA display_ptr_hi                                           ; $BF1A: 8D BE 04
  LDA sub_action_type                                           ; $BF1D: AD BF 04
  CLC                                                 ; $BF20: 18
  ADC #$2F                                            ; $BF21: 69 2F
  STA display_ptr_lo                                           ; $BF23: 8D BD 04
  LDA sub_action_type                                           ; $BF26: AD BF 04
  CMP #$03                                            ; $BF29: C9 03
  BCS @skip_4                                           ; $BF2B: B0 0B
  LDA active_player_slot                                           ; $BF2D: AD AA 04
  EOR #$01                                            ; $BF30: 49 01
  TAY                                                 ; $BF32: A8
  LDA #$02                                            ; $BF33: A9 02
  STA event_overlay_flag,Y                                         ; $BF35: 99 C3 04
@skip_4:
  LDA #$09                                            ; $BF38: A9 09
  STA game_state                                           ; $BF3A: 8D A8 04
  LDA #$00                                            ; $BF3D: A9 00
  STA sub_state                                           ; $BF3F: 8D A9 04
  RTS                                                 ; $BF42: 60
.endproc
;===============================================================================
; $BF43: BattleInit_Position
;===============================================================================
.proc BattleInit_Position
BattleInit_Position:
  LDA active_player_slot                                           ; $BF43: AD AA 04
  EOR #$01                                            ; $BF46: 49 01
  TAY                                                 ; $BF48: A8
  BEQ @skip                                           ; $BF49: F0 02
  LDY #$02                                            ; $BF4B: A0 02
@skip:
  LDA #$01                                            ; $BF4D: A9 01
  STA player0_officer_hi,Y                                         ; $BF4F: 99 15 05
  TYA                                                 ; $BF52: 98
  EOR #$02                                            ; $BF53: 49 02
  TAY                                                 ; $BF55: A8
  LDA #$00                                            ; $BF56: A9 00
  STA player0_officer_hi,Y                                         ; $BF58: 99 15 05
  LDA #$0F                                            ; $BF5B: A9 0F
  STA game_state                                           ; $BF5D: 8D A8 04
  LDA #$00                                            ; $BF60: A9 00
  STA sub_state                                           ; $BF62: 8D A9 04
  RTS                                                 ; $BF65: 60
.endproc
;===============================================================================
; $BF66: BattleInit_Configure
;===============================================================================
.proc BattleInit_Configure
BattleInit_Configure:
  LDA #$00                                            ; $BF66: A9 00
  STA player0_officer_hi                                           ; $BF68: 8D 15 05
  STA player1_officer_hi                                           ; $BF6B: 8D 17 05
  LDA #$0E                                            ; $BF6E: A9 0E
  STA game_state                                           ; $BF70: 8D A8 04
  LDA #$00                                            ; $BF73: A9 00
  STA sub_state                                           ; $BF75: 8D A9 04
  LDA #$FF                                            ; $BF78: A9 FF
  STA frame_counter                                           ; $BF7A: 8D C0 04
  RTS                                                 ; $BF7D: 60
.endproc
;===============================================================================
; $BF7E: BattleInit_Finalize
;===============================================================================
.proc BattleInit_Finalize
BattleInit_Finalize:
  JSR CheckButtonConfirm                                           ; $BF7E: 20 99 D2
  BCC @skip_2                                           ; $BF81: 90 2E
  JSR ReadMenuSelection                                           ; $BF83: 20 3D D1
  LDA a:$0081                                         ; $BF86: AD 81 00
  AND #$03                                            ; $BF89: 29 03
  BEQ @skip_2                                           ; $BF8B: F0 24
  LDY active_player_slot                                           ; $BF8D: AC AA 04
  BEQ @skip                                           ; $BF90: F0 02
  LDY #$02                                            ; $BF92: A0 02
@skip:
  LDA #$00                                            ; $BF94: A9 00
  STA player0_officer_hi,Y                                         ; $BF96: 99 15 05
  TYA                                                 ; $BF99: 98
  EOR #$02                                            ; $BF9A: 49 02
  TAY                                                 ; $BF9C: A8
  LDA #$04                                            ; $BF9D: A9 04
  STA player0_officer_hi,Y                                         ; $BF9F: 99 15 05
  LDA #$0E                                            ; $BFA2: A9 0E
  STA game_state                                           ; $BFA4: 8D A8 04
  LDA #$00                                            ; $BFA7: A9 00
  STA sub_state                                           ; $BFA9: 8D A9 04
  LDA #$FF                                            ; $BFAC: A9 FF
  STA frame_counter                                           ; $BFAE: 8D C0 04
@skip_2:
  RTS                                                 ; $BFB1: 60
.endproc
BattleInit_FormationData:
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $BFB2: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$02; $BFC2: 01 01 01 01 02 02 02 02 01 01 01 01 01 01 01 02
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$03,$03; $BFD2: 01 01 01 01 01 01 01 01 01 01 01 01 02 02 03 03
  .byte $01,$01,$01,$01,$01,$01,$04,$04,$01,$01,$03,$03,$04,$04,$04,$04; $BFE2: 01 01 01 01 01 01 04 04 01 01 03 03 04 04 04 04
  .byte $02,$02,$02,$02,$04,$04,$04,$04,$01,$01,$01,$01,$01,$01; $BFF2: 02 02 02 02 04 04 04 04 01 01 01 01 01 01

.segment "CODE_BANK18"

;===============================================================================
; $C000-$C089: Tile/map lookup table
;===============================================================================
;BattleInit_FormationDataBank18:
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$01,$01,$01,$01,$01,$01; $C000: 01 01 01 01 01 01 01 01 02 02 01 01 01 01 01 01
  .byte $02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02; $C010: 02 02 01 01 01 01 01 01 01 01 01 01 01 01 02 02
  .byte $03,$03,$01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$01,$01,$03,$03; $C020: 03 03 01 01 01 01 02 02 02 02 01 01 01 01 03 03
  .byte $04,$04,$01,$01,$03,$03,$03,$03,$04,$04,$01,$01,$03,$03,$04,$04; $C030: 04 04 01 01 03 03 03 03 04 04 01 01 03 03 04 04
  .byte $04,$04,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $C040: 04 04 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$01,$01,$04,$04; $C050: 01 01 01 01 01 01 02 02 02 02 01 01 01 01 04 04
  .byte $04,$04,$01,$01,$03,$03,$03,$03,$04,$04,$01,$01,$02,$02,$04,$04; $C060: 04 04 01 01 03 03 03 03 04 04 01 01 02 02 04 04
  .byte $04,$04,$01,$01,$01,$01,$04,$04,$04,$04,$01,$01,$02,$02,$04,$04; $C070: 04 04 01 01 01 01 04 04 04 04 01 01 02 02 04 04
  .byte $04,$04,$01,$01,$04,$04,$04,$04,$04,$04       ; $C080: 04 04 01 01 04 04 04 04 04 04
;===============================================================================
; $C08A: BattleSetup_Exec
;===============================================================================
.proc BattleSetup_Exec
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
BattleSetup_Exec:
  LDY active_player_slot                                           ; $C08A: AC AA 04
  LDA #$80                                            ; $C08D: A9 80
  STA player_action_timer_0,Y                                         ; $C08F: 99 B5 04
  TYA                                                 ; $C092: 98
  EOR #$01                                            ; $C093: 49 01
  TAY                                                 ; $C095: A8
  LDA player_officer_id_0,Y                                         ; $C096: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $C099: 20 D7 F2
  LDY #$02                                            ; $C09C: A0 02
  LDA (officer_data_ptr),Y                                         ; $C09E: B1 00
  STA ptr_0010_hi                                         ; $C0A0: 8D 11 00
  LDY active_player_slot                                           ; $C0A3: AC AA 04
  LDA player_officer_id_0,Y                                         ; $C0A6: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $C0A9: 20 D7 F2
  LDY #$02                                            ; $C0AC: A0 02
  LDA (officer_data_ptr),Y                                         ; $C0AE: B1 00
  STA ptr_0010_lo                                         ; $C0B0: 8D 10 00
  LDY #$04                                            ; $C0B3: A0 04
  LDA (officer_data_ptr),Y                                         ; $C0B5: B1 00
  CLC                                                 ; $C0B7: 18
  ADC ptr_0010_lo                                         ; $C0B8: 6D 10 00
  SEC                                                 ; $C0BB: 38
  SBC ptr_0010_hi                                         ; $C0BC: ED 11 00
  BCS @skip                                           ; $C0BF: B0 02
  LDA #$00                                            ; $C0C1: A9 00
@skip:
  STA ptr_0010_lo                                         ; $C0C3: 8D 10 00
  INC ptr_0010_lo                                         ; $C0C6: EE 10 00
@loop:
  JSR B1F_RandomMod16                                 ; $C0C9: 20 5C E8
  CMP #$0A                                            ; $C0CC: C9 0A
  BCS @loop                                           ; $C0CE: B0 F9
  ADC ptr_0010_lo                                         ; $C0D0: 6D 10 00
  CMP #$6E                                            ; $C0D3: C9 6E
  BCS @loop_2                                           ; $C0D5: B0 08
  LDA #$2F                                            ; $C0D7: A9 2F
  STA display_ptr_hi                                           ; $C0D9: 8D BE 04
  JMP @skip_2                                           ; $C0DC: 4C 03 C1
@loop_2:
  JSR B1F_RandomMod4                                  ; $C0DF: 20 50 E8
  STA ptr_0010_lo                                         ; $C0E2: 8D 10 00
  BEQ @loop_2                                           ; $C0E5: F0 F8
  INC ptr_0010_lo                                         ; $C0E7: EE 10 00
  INC ptr_0010_lo                                         ; $C0EA: EE 10 00
  LDA active_player_slot                                           ; $C0ED: AD AA 04
  EOR #$01                                            ; $C0F0: 49 01
  TAY                                                 ; $C0F2: A8
  LDA ptr_0010_lo                                         ; $C0F3: AD 10 00
  STA player_action_timer_0,Y                                         ; $C0F6: 99 B5 04
  LDA #$02                                            ; $C0F9: A9 02
  STA event_overlay_flag,Y                                         ; $C0FB: 99 C3 04
  LDA #$2E                                            ; $C0FE: A9 2E
  STA display_ptr_hi                                           ; $C100: 8D BE 04
@skip_2:
  LDA #$2D                                            ; $C103: A9 2D
  STA display_ptr_lo                                           ; $C105: 8D BD 04
  LDA #$09                                            ; $C108: A9 09
  STA game_state                                           ; $C10A: 8D A8 04
  LDA #$00                                            ; $C10D: A9 00
  STA sub_state                                           ; $C10F: 8D A9 04
  STA sub_action_type                                           ; $C112: 8D BF 04
  RTS                                                 ; $C115: 60
.endproc
;===============================================================================
; $C116: EventCutsceneDispatch2
;===============================================================================
.proc EventCutsceneDispatch2
EventCutsceneDispatch2:
  LDA sub_state                                           ; $C116: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $C119: 20 DE EA
; --- Inline pointer table (4 entries) ---
  .word EventCutscene2_Init                                         ; $C11C: 24 C1
  .word EventCutscene2_LoadData                                         ; $C11E: 3A C1
  .word EventCutscene2_Show                                         ; $C120: 4A C1
  .word EventCutscene2_Execute                                         ; $C122: 87 C1
.endproc
;===============================================================================
; $C124: EventCutscene2_Init
;===============================================================================
.proc EventCutscene2_Init
  officer_data_ptr     = $0000
EventCutscene2_Init:
  JSR CheckButtonConfirm                                           ; $C124: 20 99 D2
  BCC @skip                                           ; $C127: 90 10
  INC sub_state                                           ; $C129: EE A9 04
  LDA player_officer_id_0                                           ; $C12C: AD AD 04
  STA officer_data_ptr                                         ; $C12F: 8D 00 00
  LDY #$3D                                            ; $C132: A0 3D
  JSR B1F_BankedCallbackTrampoline                    ; $C134: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A030                                         ; $C137: 30 A0
@skip:
  RTS                                                 ; $C139: 60
.endproc
;===============================================================================
; $C13A: EventCutscene2_LoadData
;===============================================================================
.proc EventCutscene2_LoadData
EventCutscene2_LoadData:
  INC sub_state                                           ; $C13A: EE A9 04
  LDY #$3D                                            ; $C13D: A0 3D
  JSR B1F_BankedCallbackTrampoline                    ; $C13F: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A033                                         ; $C142: 33 A0
  LDA display_ptr_lo                                           ; $C144: AD BD 04
  JMP SetDisplayPointer                                           ; $C147: 4C 83 D2
.endproc
;===============================================================================
; $C14A: EventCutscene2_Show
;===============================================================================
.proc EventCutscene2_Show
  temp_0010       = $0010
EventCutscene2_Show:
  LDY active_player_slot                                           ; $C14A: AC AA 04
  LDA event_overlay_flag,Y                                         ; $C14D: B9 C3 04
  STA temp_0010,Y                                       ; $C150: 99 10 00
  TYA                                                 ; $C153: 98
  EOR #$01                                            ; $C154: 49 01
  TAY                                                 ; $C156: A8
  LDA #$80                                            ; $C157: A9 80
  STA temp_0010,Y                                       ; $C159: 99 10 00
  JSR EventCutscene_LoadOverlay                                           ; $C15C: 20 E2 C1
  JSR CheckButtonConfirm                                           ; $C15F: 20 99 D2
  BCC @skip                                           ; $C162: 90 22
  JSR ReadMenuSelection                                           ; $C164: 20 3D D1
  LDA a:$0081                                         ; $C167: AD 81 00
  AND #$03                                            ; $C16A: 29 03
  BEQ @skip                                           ; $C16C: F0 18
  INC sub_state                                           ; $C16E: EE A9 04
  LDA active_player_slot                                           ; $C171: AD AA 04
  EOR #$01                                            ; $C174: 49 01
  STA active_player_slot                                           ; $C176: 8D AA 04
  TAY                                                 ; $C179: A8
  LDA player_officer_id_0,Y                                         ; $C17A: B9 AD 04
  STA selected_officer_id                                           ; $C17D: 8D 2C 04
  LDA display_ptr_hi                                           ; $C180: AD BE 04
  JMP SetDisplayPointer                                           ; $C183: 4C 83 D2
@skip:
  RTS                                                 ; $C186: 60
.endproc
;===============================================================================
; $C187: EventCutscene2_Execute
;===============================================================================
.proc EventCutscene2_Execute
  temp_0010       = $0010
EventCutscene2_Execute:
  LDY active_player_slot                                           ; $C187: AC AA 04
  LDA event_overlay_flag,Y                                         ; $C18A: B9 C3 04
  STA temp_0010,Y                                       ; $C18D: 99 10 00
  TYA                                                 ; $C190: 98
  EOR #$01                                            ; $C191: 49 01
  TAY                                                 ; $C193: A8
  LDA #$80                                            ; $C194: A9 80
  STA temp_0010,Y                                       ; $C196: 99 10 00
  JSR EventCutscene_LoadOverlay                                           ; $C199: 20 E2 C1
  JSR CheckButtonConfirm                                           ; $C19C: 20 99 D2
  BCC @skip_2                                           ; $C19F: 90 40
  JSR ReadMenuSelection                                           ; $C1A1: 20 3D D1
  LDA a:$0081                                         ; $C1A4: AD 81 00
  AND #$03                                            ; $C1A7: 29 03
  BEQ @skip_2                                           ; $C1A9: F0 36
  LDA active_player_slot                                           ; $C1AB: AD AA 04
  EOR #$01                                            ; $C1AE: 49 01
  STA active_player_slot                                           ; $C1B0: 8D AA 04
  LDA sub_action_type                                           ; $C1B3: AD BF 04
  CMP #$02                                            ; $C1B6: C9 02
  BCC @skip                                           ; $C1B8: 90 17
  STA sub_state                                           ; $C1BA: 8D A9 04
  DEC sub_state                                           ; $C1BD: CE A9 04
  LDA #$07                                            ; $C1C0: A9 07
  STA game_state                                           ; $C1C2: 8D A8 04
  LDA sub_action_type                                           ; $C1C5: AD BF 04
  CMP #$04                                            ; $C1C8: C9 04
  BNE @skip_2                                           ; $C1CA: D0 15
  LDA #$38                                            ; $C1CC: A9 38
  JMP B1F_SetUI4                                      ; $C1CE: 4C 8B F2
@skip:
  LDA #$01                                            ; $C1D1: A9 01
  STA game_state                                           ; $C1D3: 8D A8 04
  LDA #$00                                            ; $C1D6: A9 00
  STA sub_state                                           ; $C1D8: 8D A9 04
  STA event_overlay_flag                                           ; $C1DB: 8D C3 04
  STA ui_state                                           ; $C1DE: 8D C4 04
@skip_2:
  RTS                                                 ; $C1E1: 60
.endproc
;===============================================================================
; $C1E2: EventCutscene_LoadOverlay
;===============================================================================
.proc EventCutscene_LoadOverlay
  officer_data_ptr     = $0000
  overlay_data_ptr          = $000A
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  callback_result       = $00A4
EventCutscene_LoadOverlay:
  LDA #$A5                                            ; $C1E2: A9 A5
  STA ptr_lo                                         ; $C1E4: 8D 0A 00
  LDX #$00                                            ; $C1E7: A2 00
  LDA player_officer_id_0                                           ; $C1E9: AD AD 04
  STA officer_data_ptr                                         ; $C1EC: 8D 00 00
  LDA ptr_0010_lo                                         ; $C1EF: AD 10 00
  STA a:zp_a4                                         ; $C1F2: 8D A4 00
  LDY #$39                                            ; $C1F5: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $C1F7: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                                         ; $C1FA: 00 A0
  LDX #$01                                            ; $C1FC: A2 01
  LDA #$C8                                            ; $C1FE: A9 C8
  STA cutscene_load_progress                                           ; $C200: 8D BC 04
  LDA player_officer_id_1                                           ; $C203: AD AE 04
  STA officer_data_ptr                                         ; $C206: 8D 00 00
  LDA ptr_0010_hi                                         ; $C209: AD 11 00
  STA a:zp_a4                                         ; $C20C: 8D A4 00
  LDY #$39                                            ; $C20F: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $C211: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                                         ; $C214: 00 A0
  LDA #$00                                            ; $C216: A9 00
  STA cutscene_load_progress                                           ; $C218: 8D BC 04
  RTS                                                 ; $C21B: 60
.endproc
;===============================================================================
; $C21C: MapFadeDispatch
;===============================================================================
.proc MapFadeDispatch
MapFadeDispatch:
  LDA sub_state                                           ; $C21C: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $C21F: 20 DE EA
; --- Inline pointer table (4 entries) ---
  .word MapFade_Init                                         ; $C222: 2A C2
  .word MapFade_FadeIn                                         ; $C224: 56 C2
  .word MapFade_Draw                                         ; $C226: 8E C2
  .word MapFade_Complete                                         ; $C228: AA C2
.endproc
;===============================================================================
; $C22A: MapFade_Init
;===============================================================================
.proc MapFade_Init
  officer_data_ptr     = $0000
  ppu_col_lo       = $00CC
  ppu_col_mid       = $00D4
  ppu_col_hi       = $00DC
MapFade_Init:
  JSR B1F_BankPpuInit                                 ; $C22A: 20 7F E5
  LDA #$71                                            ; $C22D: A9 71
  JSR B1F_SoundWrapperC                               ; $C22F: 20 83 E6
  LDA #$91                                            ; $C232: A9 91
  STA a:zp_cc                                         ; $C234: 8D CC 00
  STA a:zp_d4                                         ; $C237: 8D D4 00
  STA a:zp_dc                                         ; $C23A: 8D DC 00
  INC sub_state                                           ; $C23D: EE A9 04
  LDA #$43                                            ; $C240: A9 43
  STA officer_data_ptr                                         ; $C242: 8D 00 00
  LDA #$13                                            ; $C245: A9 13
  LDY active_player_slot                                           ; $C247: AC AA 04
  BEQ @skip                                           ; $C24A: F0 07
  LDA #$55                                            ; $C24C: A9 55
  STA officer_data_ptr                                         ; $C24E: 8D 00 00
  LDA #$15                                            ; $C251: A9 15
@skip:
  JMP BuildPPUTileBuffer                                           ; $C253: 4C FD CD
.endproc
;===============================================================================
; $C256: MapFade_FadeIn
;===============================================================================
.proc MapFade_FadeIn
  officer_data_ptr     = $0000
  temp_00c6       = $00C6
  temp_00ce       = $00CE
  temp_00d6       = $00D6
MapFade_FadeIn:
  LDA #$90                                            ; $C256: A9 90
  STA a:zp_c6                                         ; $C258: 8D C6 00
  STA a:zp_ce                                         ; $C25B: 8D CE 00
  STA a:zp_d6                                         ; $C25E: 8D D6 00
  LDA #$00                                            ; $C261: A9 00
  STA anim_timer                                           ; $C263: 8D B8 04
  LDA #$4F                                            ; $C266: A9 4F
  STA scroll_row_count                                           ; $C268: 8D BA 04
  INC sub_state                                           ; $C26B: EE A9 04
  LDA #$18                                            ; $C26E: A9 18
  STA slide_y_pos                                           ; $C270: 8D BB 04
  LDA #$E3                                            ; $C273: A9 E3
  STA officer_data_ptr                                         ; $C275: 8D 00 00
  LDA #$14                                            ; $C278: A9 14
  LDY active_player_slot                                           ; $C27A: AC AA 04
  BEQ @skip                                           ; $C27D: F0 0C
  LDA #$A8                                            ; $C27F: A9 A8
  STA slide_y_pos                                           ; $C281: 8D BB 04
  LDA #$F5                                            ; $C284: A9 F5
  STA officer_data_ptr                                         ; $C286: 8D 00 00
  LDA #$16                                            ; $C289: A9 16
@skip:
  JMP BuildPPUTileBuffer                                           ; $C28B: 4C FD CD
.endproc
;===============================================================================
; $C28E: MapFade_Draw
;===============================================================================
.proc MapFade_Draw
MapFade_Draw:
  INC anim_timer                                           ; $C28E: EE B8 04
  LDA anim_timer                                           ; $C291: AD B8 04
  ROL A                                               ; $C294: 2A
  ROL A                                               ; $C295: 2A
  ROL A                                               ; $C296: 2A
  AND #$03                                            ; $C297: 29 03
  CMP #$02                                            ; $C299: C9 02
  BNE MapFade_DrawColumn                                           ; $C29B: D0 2F
  LDA #$01                                            ; $C29D: A9 01
  JSR MapFade_DrawColumn                                           ; $C29F: 20 CC C2
  INC sub_state                                           ; $C2A2: EE A9 04
  LDA #$26                                            ; $C2A5: A9 26
  JMP B1F_SetUI4                                      ; $C2A7: 4C 8B F2
.endproc
;===============================================================================
; $C2AA: MapFade_Complete
;===============================================================================
.proc MapFade_Complete
MapFade_Complete:
  LDA #$01                                            ; $C2AA: A9 01
  JSR MapFade_DrawColumn                                           ; $C2AC: 20 CC C2
  JSR CheckButtonConfirm                                           ; $C2AF: 20 99 D2
  BCC @skip                                           ; $C2B2: 90 17
  JSR ReadMenuSelection                                           ; $C2B4: 20 3D D1
  LDA a:$0081                                         ; $C2B7: AD 81 00
  AND #$03                                            ; $C2BA: 29 03
  BEQ @skip                                           ; $C2BC: F0 0D
  LDA #$0E                                            ; $C2BE: A9 0E
  STA game_state                                           ; $C2C0: 8D A8 04
  LDA #$00                                            ; $C2C3: A9 00
  STA sub_state                                           ; $C2C5: 8D A9 04
  STA frame_counter                                           ; $C2C8: 8D C0 04
@skip:
  RTS                                                 ; $C2CB: 60
.endproc
;===============================================================================
; $C2CC: MapFade_DrawColumn
;===============================================================================
.proc MapFade_DrawColumn
  tilemap_attr      = $0002
  tilemap_work       = $0010
MapFade_DrawColumn:
  STA tilemap_work                                         ; $C2CC: 8D 10 00
  LDA active_player_slot                                           ; $C2CF: AD AA 04
  BEQ @skip                                           ; $C2D2: F0 09
  LDA tilemap_work                                         ; $C2D4: AD 10 00
  CLC                                                 ; $C2D7: 18
  ADC #$06                                            ; $C2D8: 69 06
  STA tilemap_work                                         ; $C2DA: 8D 10 00
@skip:
  LDA active_player_slot                                           ; $C2DD: AD AA 04
  CLC                                                 ; $C2E0: 18
  ADC #$01                                            ; $C2E1: 69 01
  STA work_marker                                         ; $C2E3: 8D 02 00
  LDY active_player_slot                                           ; $C2E6: AC AA 04
  LDA name_tile_index,Y                                         ; $C2E9: B9 AF 04
  ASL A                                               ; $C2EC: 0A
  CLC                                                 ; $C2ED: 18
  ADC tilemap_work                                         ; $C2EE: 6D 10 00
  ADC #$6A                                            ; $C2F1: 69 6A
  JMP DrawSpriteFromBank                                           ; $C2F3: 4C A5 CE
.endproc
;===============================================================================
; $C2F6: TerritoryEventDispatch
;===============================================================================
.proc TerritoryEventDispatch
TerritoryEventDispatch:
  LDA frame_counter                                           ; $C2F6: AD C0 04
  BMI @skip                                           ; $C2F9: 30 05
  LDA #$01                                            ; $C2FB: A9 01
  JSR MapFade_DrawColumn                                           ; $C2FD: 20 CC C2
@skip:
  LDA sub_state                                           ; $C300: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $C303: 20 DE EA
; --- Inline pointer table (4 entries) ---
  .word TerritoryEvent_Init                                         ; $C306: 0E C3
  .word TerritoryEvent_Check                                         ; $C308: 3B C3
  .word TerritoryEvent_Execute                                         ; $C30A: 5D C3
  .word TerritoryEvent_Finalize                                         ; $C30C: 4F C4
.endproc
;===============================================================================
; $C30E: TerritoryEvent_Init
;===============================================================================
.proc TerritoryEvent_Init
TerritoryEvent_Init:
  LDA player_officer_id_0                                           ; $C30E: AD AD 04
  STA player0_officer_lo                                           ; $C311: 8D 14 05
  LDA player_officer_id_1                                           ; $C314: AD AE 04
  STA player1_officer_lo                                           ; $C317: 8D 16 05
  LDY #$00                                            ; $C31A: A0 00
  LDA player0_officer_hi                                           ; $C31C: AD 15 05
  CMP #$02                                            ; $C31F: C9 02
  BEQ @skip                                           ; $C321: F0 0F
  LDY #$02                                            ; $C323: A0 02
  LDA player1_officer_hi                                           ; $C325: AD 17 05
  CMP #$02                                            ; $C328: C9 02
  BEQ @skip                                           ; $C32A: F0 06
  INC sub_state                                           ; $C32C: EE A9 04
  JMP B1F_PaletteCopyBuffer                           ; $C32F: 4C EE EC
@skip:
  STY display_ptr_lo                                           ; $C332: 8C BD 04
  LDA #$02                                            ; $C335: A9 02
  STA sub_state                                           ; $C337: 8D A9 04
  RTS                                                 ; $C33A: 60
.endproc
;===============================================================================
; $C33B: TerritoryEvent_Check
;===============================================================================
.proc TerritoryEvent_Check
  ptr_0500_lo     = $0500
  ptr_0500_hi     = $0501
TerritoryEvent_Check:
  LDA a:$0087                                         ; $C33B: AD 87 00
  BPL @skip_2                                           ; $C33E: 10 1C
  LDA #$0B                                            ; $C340: A9 0B
  STA ptr_0500_lo                                           ; $C342: 8D 00 05
  LDA #$00                                            ; $C345: A9 00
  STA ptr_0500_hi                                           ; $C347: 8D 01 05
  LDA territory_event_type                                           ; $C34A: AD 0F 05
  CMP #$03                                            ; $C34D: C9 03
  BEQ @skip                                           ; $C34F: F0 03
  STA $6F44                                           ; $C351: 8D 44 6F
@skip:
  LDA #$03                                            ; $C354: A9 03
  STA a:$007A                                         ; $C356: 8D 7A 00
  JMP B1F_PaletteFadeInit                             ; $C359: 4C BF EC
@skip_2:
  RTS                                                 ; $C35C: 60
.endproc
;===============================================================================
; $C35D: TerritoryEvent_Execute
;===============================================================================
.proc TerritoryEvent_Execute
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
TerritoryEvent_Execute:
  LDX display_ptr_lo                                           ; $C35D: AE BD 04
  LDA player0_officer_lo,X                                         ; $C360: BD 14 05
  CMP #$83                                            ; $C363: C9 83
  BNE @skip                                           ; $C365: D0 03
  JMP @skip_6                                           ; $C367: 4C AA C3
@skip:
  CMP #$AD                                            ; $C36A: C9 AD
  BNE @skip_2                                           ; $C36C: D0 03
  JMP @skip_7                                           ; $C36E: 4C C0 C3
@skip_2:
  CMP #$B6                                            ; $C371: C9 B6
  BNE @skip_3                                           ; $C373: D0 03
  JMP @skip_9                                           ; $C375: 4C 01 C4
@skip_3:
  CMP #$DE                                            ; $C378: C9 DE
  BNE @skip_4                                           ; $C37A: D0 03
  JMP TerritoryEvent_CaptureOfficer                                           ; $C37C: 4C 2E C4
@skip_4:
  LDA $6FE1                                           ; $C37F: AD E1 6F
  AND #$01                                            ; $C382: 29 01
  BNE @loop_2                                           ; $C384: D0 1E
  LDA #$00                                            ; $C386: A9 00
  STA ptr_0010_lo                                         ; $C388: 8D 10 00
@loop:
  JSR B1F_GetRulerDataPtr                             ; $C38B: 20 68 F3
  LDY #$00                                            ; $C38E: A0 00
  LDA (officer_data_ptr),Y                                         ; $C390: B1 00
  CMP player0_officer_lo,X                                         ; $C392: DD 14 05
  BNE @skip_5                                           ; $C395: D0 03
  JMP @skip_8                                           ; $C397: 4C E3 C3
@skip_5:
  INC ptr_0010_lo                                         ; $C39A: EE 10 00
  LDA ptr_0010_lo                                         ; $C39D: AD 10 00
  CMP #$07                                            ; $C3A0: C9 07
  BCC @loop                                           ; $C3A2: 90 E7
@loop_2:
  LDA #$01                                            ; $C3A4: A9 01
  STA sub_state                                           ; $C3A6: 8D A9 04
  RTS                                                 ; $C3A9: 60
@skip_6:
  LDA #$64                                            ; $C3AA: A9 64
  JSR B1F_RandomBelowThreshold                        ; $C3AC: 20 62 E8
  CMP #$1E                                            ; $C3AF: C9 1E
  BCS @loop_2                                           ; $C3B1: B0 F1
  LDA #$06                                            ; $C3B3: A9 06
  STA ptr_0010_lo                                         ; $C3B5: 8D 10 00
  LDA #$3F                                            ; $C3B8: A9 3F
  STA ptr_0010_hi                                         ; $C3BA: 8D 11 00
  JMP TerritoryEvent_ApplyResult                                           ; $C3BD: 4C 0B C4
@skip_7:
  LDA display_ptr_lo                                           ; $C3C0: AD BD 04
  EOR #$02                                            ; $C3C3: 49 02
  TAX                                                 ; $C3C5: AA
  LDA player0_officer_lo,X                                         ; $C3C6: BD 14 05
  JSR B1F_GetOfficerRecordAddr                        ; $C3C9: 20 D7 F2
  LDY #$0B                                            ; $C3CC: A0 0B
  LDA (officer_data_ptr),Y                                         ; $C3CE: B1 00
  AND #$F0                                            ; $C3D0: 29 F0
  CMP #$20                                            ; $C3D2: C9 20
  BCS @loop_2                                           ; $C3D4: B0 CE
  LDA #$07                                            ; $C3D6: A9 07
  STA ptr_0010_lo                                         ; $C3D8: 8D 10 00
  LDA #$40                                            ; $C3DB: A9 40
  STA ptr_0010_hi                                         ; $C3DD: 8D 11 00
  JMP TerritoryEvent_ApplyResult                                           ; $C3E0: 4C 0B C4
@skip_8:
  LDA #$64                                            ; $C3E3: A9 64
  JSR B1F_RandomBelowThreshold                        ; $C3E5: 20 62 E8
  CMP #$32                                            ; $C3E8: C9 32
  BCS @loop_2                                           ; $C3EA: B0 B8
  LDA $6FE1                                           ; $C3EC: AD E1 6F
  ORA #$01                                            ; $C3EF: 09 01
  STA $6FE1                                           ; $C3F1: 8D E1 6F
  LDA #$0E                                            ; $C3F4: A9 0E
  STA ptr_0010_lo                                         ; $C3F6: 8D 10 00
  LDA #$41                                            ; $C3F9: A9 41
  STA ptr_0010_hi                                         ; $C3FB: 8D 11 00
  JMP TerritoryEvent_ApplyResult                                           ; $C3FE: 4C 0B C4
@skip_9:
  LDA #$05                                            ; $C401: A9 05
  STA ptr_0010_lo                                         ; $C403: 8D 10 00
  LDA #$3E                                            ; $C406: A9 3E
  STA ptr_0010_hi                                         ; $C408: 8D 11 00
.endproc
;===============================================================================
; $C40B: TerritoryEvent_ApplyResult
;===============================================================================
.proc TerritoryEvent_ApplyResult
  officer_data_ptr     = $0000
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
TerritoryEvent_ApplyResult:
  LDA display_ptr_lo                                           ; $C40B: AD BD 04
  EOR #$02                                            ; $C40E: 49 02
  TAX                                                 ; $C410: AA
  LDA player0_officer_lo,X                                         ; $C411: BD 14 05
  STA selected_officer_id                                           ; $C414: 8D 2C 04
  JSR B1F_GetOfficerRecordAddr                        ; $C417: 20 D7 F2
  LDY #$0A                                            ; $C41A: A0 0A
  LDA (officer_data_ptr),Y                                         ; $C41C: B1 00
  AND #$E0                                            ; $C41E: 29 E0
  ORA ptr_0010_lo                                         ; $C420: 0D 10 00
  STA (officer_data_ptr),Y                                         ; $C423: 91 00
  INC sub_state                                           ; $C425: EE A9 04
  LDA ptr_0010_hi                                         ; $C428: AD 11 00
  JMP B1F_SetUI4                                      ; $C42B: 4C 8B F2
.endproc
;===============================================================================
; $C42E: TerritoryEvent_CaptureOfficer
;===============================================================================
.proc TerritoryEvent_CaptureOfficer
  officer_data_ptr     = $0000
TerritoryEvent_CaptureOfficer:
  LDA display_ptr_lo                                           ; $C42E: AD BD 04
  EOR #$02                                            ; $C431: 49 02
  TAX                                                 ; $C433: AA
  LDA player0_officer_lo,X                                         ; $C434: BD 14 05
  STA selected_officer_id                                           ; $C437: 8D 2C 04
  JSR B1F_GetOfficerRecordAddr                        ; $C43A: 20 D7 F2
  LDY #$0A                                            ; $C43D: A0 0A
  LDA (officer_data_ptr),Y                                         ; $C43F: B1 00
  AND #$1F                                            ; $C441: 29 1F
  ORA #$E0                                            ; $C443: 09 E0
  STA (officer_data_ptr),Y                                         ; $C445: 91 00
  INC sub_state                                           ; $C447: EE A9 04
  LDA #$42                                            ; $C44A: A9 42
  JMP B1F_SetUI4                                      ; $C44C: 4C 8B F2
.endproc
;===============================================================================
; $C44F: TerritoryEvent_Finalize
;===============================================================================
.proc TerritoryEvent_Finalize
TerritoryEvent_Finalize:
  JSR CheckButtonConfirm                                           ; $C44F: 20 99 D2
  BCC @skip                                           ; $C452: 90 0F
  JSR ReadMenuSelection                                           ; $C454: 20 3D D1
  LDA a:$0081                                         ; $C457: AD 81 00
  AND #$03                                            ; $C45A: 29 03
  BEQ @skip                                           ; $C45C: F0 05
  LDA #$01                                            ; $C45E: A9 01
  STA sub_state                                           ; $C460: 8D A9 04
@skip:
  RTS                                                 ; $C463: 60
.endproc
;===============================================================================
; $C464: PaletteTransitionDispatch
;===============================================================================
.proc PaletteTransitionDispatch
PaletteTransitionDispatch:
  LDA sub_state                                           ; $C464: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $C467: 20 DE EA
; --- Inline pointer table (2 entries) ---
  .word PaletteTransition_Copy                                         ; $C46A: 6E C4
  .word PaletteTransition_Fade                                         ; $C46C: 80 C4
.endproc
;===============================================================================
; $C46E: PaletteTransition_Copy
;===============================================================================
.proc PaletteTransition_Copy
PaletteTransition_Copy:
  LDA player_officer_id_0                                           ; $C46E: AD AD 04
  STA player0_officer_lo                                           ; $C471: 8D 14 05
  LDA player_officer_id_1                                           ; $C474: AD AE 04
  STA player1_officer_lo                                           ; $C477: 8D 16 05
  INC sub_state                                           ; $C47A: EE A9 04
  JMP B1F_PaletteCopyBuffer                           ; $C47D: 4C EE EC
.endproc
;===============================================================================
; $C480: PaletteTransition_Fade
;===============================================================================
.proc PaletteTransition_Fade
PaletteTransition_Fade:
  LDA a:$0087                                         ; $C480: AD 87 00
  BPL @skip_2                                           ; $C483: 10 12
  LDA territory_event_type                                           ; $C485: AD 0F 05
  CMP #$03                                            ; $C488: C9 03
  BEQ @skip                                           ; $C48A: F0 03
  STA $6F44                                           ; $C48C: 8D 44 6F
@skip:
  LDA #$05                                            ; $C48F: A9 05
  STA a:$007A                                         ; $C491: 8D 7A 00
  JMP B1F_PaletteFadeInit                             ; $C494: 4C BF EC
@skip_2:
  RTS                                                 ; $C497: 60
.endproc
;===============================================================================
; $C498: MapScrollDispatch_A
;===============================================================================
.proc MapScrollDispatch_A
MapScrollDispatch_A:
  LDA sub_state                                           ; $C498: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $C49B: 20 DE EA
; --- Inline pointer table (7 entries) ---
  .word MapScrollA_Init                                         ; $C49E: AC C4
  .word MapScrollA_Scroll                                         ; $C4A0: C3 C4
  .word MapScrollA_Draw                                         ; $C4A2: E9 C4
  .word MapScrollA_Update                                         ; $C4A4: 5A C5
  .word MapScrollA_Animate                                         ; $C4A6: 98 C5
  .word MapScrollA_Finalize                                         ; $C4A8: D2 C5
  .word MapScrollA_Complete                                         ; $C4AA: 6B C6
.endproc
;===============================================================================
; $C4AC: MapScrollA_Init
;===============================================================================
.proc MapScrollA_Init
  col_offset     = $0000
MapScrollA_Init:
  INC sub_state                                           ; $C4AC: EE A9 04
  LDA #$43                                            ; $C4AF: A9 43
  STA col_offset                                         ; $C4B1: 8D 00 00
  LDA active_player_slot                                           ; $C4B4: AD AA 04
  BEQ @skip                                           ; $C4B7: F0 05
  LDA #$55                                            ; $C4B9: A9 55
  STA col_offset                                         ; $C4BB: 8D 00 00
@skip:
  LDA #$00                                            ; $C4BE: A9 00
  JMP BuildPPUTileBuffer                                           ; $C4C0: 4C FD CD
.endproc
;===============================================================================
; $C4C3: MapScrollA_Scroll
;===============================================================================
.proc MapScrollA_Scroll
  col_offset     = $0000
MapScrollA_Scroll:
  LDA #$00                                            ; $C4C3: A9 00
  STA anim_timer                                           ; $C4C5: 8D B8 04
  INC sub_state                                           ; $C4C8: EE A9 04
  LDA #$18                                            ; $C4CB: A9 18
  STA slide_y_pos                                           ; $C4CD: 8D BB 04
  LDA #$E3                                            ; $C4D0: A9 E3
  STA col_offset                                         ; $C4D2: 8D 00 00
  LDA active_player_slot                                           ; $C4D5: AD AA 04
  BEQ @skip                                           ; $C4D8: F0 0A
  LDA #$A8                                            ; $C4DA: A9 A8
  STA slide_y_pos                                           ; $C4DC: 8D BB 04
  LDA #$F5                                            ; $C4DF: A9 F5
  STA col_offset                                         ; $C4E1: 8D 00 00
@skip:
  LDA #$00                                            ; $C4E4: A9 00
  JMP BuildPPUTileBuffer                                           ; $C4E6: 4C FD CD
.endproc
;===============================================================================
; $C4E9: MapScrollA_Draw
;===============================================================================
.proc MapScrollA_Draw
  col_offset     = $0000
  temp_0011       = $0011
MapScrollA_Draw:
  LDA active_player_slot                                           ; $C4E9: AD AA 04
  BEQ @skip                                           ; $C4EC: F0 0A
  LDA slide_y_pos                                           ; $C4EE: AD BB 04
  CMP #$58                                            ; $C4F1: C9 58
  BEQ @skip_4                                           ; $C4F3: F0 1E
  JMP @skip_2                                           ; $C4F5: 4C FF C4
@skip:
  LDA slide_y_pos                                           ; $C4F8: AD BB 04
  CMP #$68                                            ; $C4FB: C9 68
  BEQ @skip_4                                           ; $C4FD: F0 14
@skip_2:
  LDA active_player_slot                                           ; $C4FF: AD AA 04
  STA temp_0011                                         ; $C502: 8D 11 00
  BEQ @skip_3                                           ; $C505: F0 06
  DEC slide_y_pos                                           ; $C507: CE BB 04
  JMP MapScroll_UpdatePosition                                           ; $C50A: 4C E1 CE
@skip_3:
  INC slide_y_pos                                           ; $C50D: EE BB 04
  JMP MapScroll_UpdatePosition                                           ; $C510: 4C E1 CE
@skip_4:
  INC sub_state                                           ; $C513: EE A9 04
  LDA active_player_slot                                           ; $C516: AD AA 04
  BEQ @skip_5                                           ; $C519: F0 0A
  LDA #$4B                                            ; $C51B: A9 4B
  STA col_offset                                         ; $C51D: 8D 00 00
  LDA #$18                                            ; $C520: A9 18
  JMP @skip_6                                           ; $C522: 4C 2C C5
@skip_5:
  LDA #$4D                                            ; $C525: A9 4D
  STA col_offset                                         ; $C527: 8D 00 00
  LDA #$17                                            ; $C52A: A9 17
@skip_6:
  JSR BuildPPUTileBuffer                                           ; $C52C: 20 FD CD
  LDA #$02                                            ; $C52F: A9 02
  STA map_scroll_ptr_0_lo                                           ; $C531: 8D B7 03
  LDA #$23                                            ; $C534: A9 23
  STA map_scroll_ptr_0_hi                                           ; $C536: 8D B8 03
  LDA #$DB                                            ; $C539: A9 DB
  STA map_scroll_ptr_1_lo                                           ; $C53B: 8D B9 03
  LDA active_player_slot                                           ; $C53E: AD AA 04
  ASL A                                               ; $C541: 0A
  TAY                                                 ; $C542: A8
  LDA MapScrollA_ScrollOffsetTable,Y                                         ; $C543: B9 56 C5
  STA map_scroll_ptr_1_hi                                           ; $C546: 8D BA 03
  INY                                                 ; $C549: C8
  LDA MapScrollA_ScrollOffsetTable,Y                                         ; $C54A: B9 56 C5
  STA map_scroll_ptr_2_lo                                           ; $C54D: 8D BB 03
  LDA #$FF                                            ; $C550: A9 FF
  STA map_scroll_ptr_2_hi                                           ; $C552: 8D BC 03
  RTS                                                 ; $C555: 60
MapScrollA_ScrollOffsetTable:
  .byte $44,$11,$CC,$33                               ; $C556: 44 11 CC 33
.endproc

;===============================================================================
; $C55A: MapScrollA_Update
;===============================================================================
.proc MapScrollA_Update
  col_offset     = $0000
  ptr_00c7_lo     = $00C7
  ptr_00c7_hi     = $00C8
  ptr_00cf_lo     = $00CF
  ptr_00cf_hi     = $00D0
  ptr_00d7_lo     = $00D7
  ptr_00d7_hi     = $00D8
MapScrollA_Update:
  LDA #$92                                            ; $C55A: A9 92
  STA a:zp_c7                                         ; $C55C: 8D C7 00
  STA a:zp_cf                                         ; $C55F: 8D CF 00
  STA a:zp_d7                                         ; $C562: 8D D7 00
  LDA #$84                                            ; $C565: A9 84
  STA a:zp_c8                                         ; $C567: 8D C8 00
  STA a:zp_d0                                         ; $C56A: 8D D0 00
  STA a:zp_d8                                         ; $C56D: 8D D8 00
  LDA #$FF                                            ; $C570: A9 FF
  STA anim_timer                                           ; $C572: 8D B8 04
  LDA #$00                                            ; $C575: A9 00
  STA map_scroll_phase                                           ; $C577: 8D B9 04
  LDA #$4F                                            ; $C57A: A9 4F
  STA scroll_row_count                                           ; $C57C: 8D BA 04
  INC sub_state                                           ; $C57F: EE A9 04
  LDA #$ED                                            ; $C582: A9 ED
  STA col_offset                                         ; $C584: 8D 00 00
  LDA #$04                                            ; $C587: A9 04
  LDY active_player_slot                                           ; $C589: AC AA 04
  BEQ @skip                                           ; $C58C: F0 07
  LDA #$EB                                            ; $C58E: A9 EB
  STA col_offset                                         ; $C590: 8D 00 00
  LDA #$08                                            ; $C593: A9 08
@skip:
  JMP BuildPPUTileBuffer                                           ; $C595: 4C FD CD
.endproc
;===============================================================================
; $C598: MapScrollA_Animate
;===============================================================================
.proc MapScrollA_Animate
  col_offset     = $0000
  ppu_tile_hi     = $0001
  ppu_col_lo       = $00CC
  ppu_col_mid       = $00D4
  ppu_col_hi       = $00DC
MapScrollA_Animate:
  LDA #$90                                            ; $C598: A9 90
  STA a:zp_cc                                         ; $C59A: 8D CC 00
  STA a:zp_d4                                         ; $C59D: 8D D4 00
  STA a:zp_dc                                         ; $C5A0: 8D DC 00
  INC sub_state                                           ; $C5A3: EE A9 04
  LDA active_player_slot                                           ; $C5A6: AD AA 04
  EOR #$01                                            ; $C5A9: 49 01
  TAY                                                 ; $C5AB: A8
  LDA name_tile_index,Y                                         ; $C5AC: B9 AF 04
  STA ppu_tile_lo                                         ; $C5AF: 8D 01 00
  CPY #$01                                            ; $C5B2: C0 01
  BEQ @skip                                           ; $C5B4: F0 0E
  LDA #$43                                            ; $C5B6: A9 43
  STA col_offset                                         ; $C5B8: 8D 00 00
  LDA #$0D                                            ; $C5BB: A9 0D
  CLC                                                 ; $C5BD: 18
  ADC ppu_tile_lo                                         ; $C5BE: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $C5C1: 4C FD CD
@skip:
  LDA #$55                                            ; $C5C4: A9 55
  STA col_offset                                         ; $C5C6: 8D 00 00
  LDA #$10                                            ; $C5C9: A9 10
  CLC                                                 ; $C5CB: 18
  ADC ppu_tile_lo                                         ; $C5CC: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $C5CF: 4C FD CD
.endproc
;===============================================================================
; $C5D2: MapScrollA_Finalize
;===============================================================================
.proc MapScrollA_Finalize
  col_offset     = $0000
  tilemap_attr      = $0002
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  tilemap_work       = $0012
MapScrollA_Finalize:
  LDA anim_timer                                           ; $C5D2: AD B8 04
  LSR A                                               ; $C5D5: 4A
  LSR A                                               ; $C5D6: 4A
  LSR A                                               ; $C5D7: 4A
  LSR A                                               ; $C5D8: 4A
  AND #$01                                            ; $C5D9: 29 01
  STA tilemap_work                                         ; $C5DB: 8D 12 00
  INC anim_timer                                           ; $C5DE: EE B8 04
  LDA anim_timer                                           ; $C5E1: AD B8 04
  LSR A                                               ; $C5E4: 4A
  LSR A                                               ; $C5E5: 4A
  LSR A                                               ; $C5E6: 4A
  LSR A                                               ; $C5E7: 4A
  AND #$07                                            ; $C5E8: 29 07
  CMP #$05                                            ; $C5EA: C9 05
  BNE @skip_2                                           ; $C5EC: D0 34
  INC sub_state                                           ; $C5EE: EE A9 04
  LDA #$4B                                            ; $C5F1: A9 4B
  STA col_offset                                         ; $C5F3: 8D 00 00
  LDA active_player_slot                                           ; $C5F6: AD AA 04
  BNE @skip                                           ; $C5F9: D0 05
  LDA #$4D                                            ; $C5FB: A9 4D
  STA col_offset                                         ; $C5FD: 8D 00 00
@skip:
  LDA #$00                                            ; $C600: A9 00
  JSR BuildPPUTileBuffer                                           ; $C602: 20 FD CD
  LDA #$02                                            ; $C605: A9 02
  STA map_scroll_ptr_0_lo                                           ; $C607: 8D B7 03
  LDA #$23                                            ; $C60A: A9 23
  STA map_scroll_ptr_0_hi                                           ; $C60C: 8D B8 03
  LDA #$DB                                            ; $C60F: A9 DB
  STA map_scroll_ptr_1_lo                                           ; $C611: 8D B9 03
  LDA #$00                                            ; $C614: A9 00
  STA map_scroll_ptr_1_hi                                           ; $C616: 8D BA 03
  STA map_scroll_ptr_2_lo                                           ; $C619: 8D BB 03
  LDA #$FF                                            ; $C61C: A9 FF
  STA map_scroll_ptr_2_hi                                           ; $C61E: 8D BC 03
  RTS                                                 ; $C621: 60
@skip_2:
  AND #$01                                            ; $C622: 29 01
  STA ptr_0010_lo                                         ; $C624: 8D 10 00
  STA ptr_0010_hi                                         ; $C627: 8D 11 00
  BNE @skip_3                                           ; $C62A: D0 0A
  CMP tilemap_work                                         ; $C62C: CD 12 00
  BEQ @skip_3                                           ; $C62F: F0 05
  LDA #$62                                            ; $C631: A9 62
  JSR B1F_SoundWrapperE                               ; $C633: 20 93 E6
@skip_3:
  LDA active_player_slot                                           ; $C636: AD AA 04
  BEQ @skip_4                                           ; $C639: F0 09
  LDA ptr_0010_lo                                         ; $C63B: AD 10 00
  CLC                                                 ; $C63E: 18
  ADC #$06                                            ; $C63F: 69 06
  STA ptr_0010_lo                                         ; $C641: 8D 10 00
@skip_4:
  LDA active_player_slot                                           ; $C644: AD AA 04
  CLC                                                 ; $C647: 18
  ADC #$01                                            ; $C648: 69 01
  STA work_marker                                         ; $C64A: 8D 02 00
  LDY active_player_slot                                           ; $C64D: AC AA 04
  LDA name_tile_index,Y                                         ; $C650: B9 AF 04
  ASL A                                               ; $C653: 0A
  CLC                                                 ; $C654: 18
  ADC ptr_0010_lo                                         ; $C655: 6D 10 00
  ADC #$5E                                            ; $C658: 69 5E
  JSR DrawSpriteFromBank                                           ; $C65A: 20 A5 CE
  LDA ptr_0010_hi                                         ; $C65D: AD 11 00
  BNE @skip_5                                           ; $C660: D0 08
  LDA #$76                                            ; $C662: A9 76
  STA ptr_0010_lo                                         ; $C664: 8D 10 00
  JMP DrawCompletionSprite                                           ; $C667: 4C 35 D2
@skip_5:
  RTS                                                 ; $C66A: 60
.endproc
;===============================================================================
; $C66B: MapScrollA_Complete
;===============================================================================
.proc MapScrollA_Complete
  col_offset     = $0000
MapScrollA_Complete:
  LDA #$13                                            ; $C66B: A9 13
  STA game_state                                           ; $C66D: 8D A8 04
  LDA #$00                                            ; $C670: A9 00
  STA sub_state                                           ; $C672: 8D A9 04
  LDA #$ED                                            ; $C675: A9 ED
  STA col_offset                                         ; $C677: 8D 00 00
  LDY active_player_slot                                           ; $C67A: AC AA 04
  BEQ @skip                                           ; $C67D: F0 05
  LDA #$EB                                            ; $C67F: A9 EB
  STA col_offset                                         ; $C681: 8D 00 00
@skip:
  LDA #$00                                            ; $C684: A9 00
  JMP BuildPPUTileBuffer                                           ; $C686: 4C FD CD
.endproc
;===============================================================================
; $C689: MapScrollDispatch_B
;===============================================================================
.proc MapScrollDispatch_B
MapScrollDispatch_B:
  LDA sub_state                                           ; $C689: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $C68C: 20 DE EA
; --- Inline pointer table (8 entries) ---
  .word MapScrollB_Init                                         ; $C68F: 9F C6
  .word MapScrollB_Scroll                                         ; $C691: B6 C6
  .word MapScrollB_Draw                                         ; $C693: DC C6
  .word MapScrollB_Update                                         ; $C695: 2D C7
  .word MapScrollB_Animate                                         ; $C697: 73 C7
  .word MapScrollB_Finalize                                         ; $C699: 09 C8
  .word MapScrollB_Complete                                         ; $C69B: 4A C8
  .word MapScrollB_Extra                                         ; $C69D: 84 C8
.endproc
;===============================================================================
; $C69F: MapScrollB_Init
;===============================================================================
.proc MapScrollB_Init
  col_offset     = $0000
MapScrollB_Init:
  INC sub_state                                           ; $C69F: EE A9 04
  LDA #$43                                            ; $C6A2: A9 43
  STA col_offset                                         ; $C6A4: 8D 00 00
  LDA active_player_slot                                           ; $C6A7: AD AA 04
  BEQ @skip                                           ; $C6AA: F0 05
  LDA #$55                                            ; $C6AC: A9 55
  STA col_offset                                         ; $C6AE: 8D 00 00
@skip:
  LDA #$00                                            ; $C6B1: A9 00
  JMP BuildPPUTileBuffer                                           ; $C6B3: 4C FD CD
.endproc
;===============================================================================
; $C6B6: MapScrollB_Scroll
;===============================================================================
.proc MapScrollB_Scroll
  col_offset     = $0000
MapScrollB_Scroll:
  LDA #$00                                            ; $C6B6: A9 00
  STA anim_timer                                           ; $C6B8: 8D B8 04
  INC sub_state                                           ; $C6BB: EE A9 04
  LDA #$18                                            ; $C6BE: A9 18
  STA slide_y_pos                                           ; $C6C0: 8D BB 04
  LDA #$E3                                            ; $C6C3: A9 E3
  STA col_offset                                         ; $C6C5: 8D 00 00
  LDA active_player_slot                                           ; $C6C8: AD AA 04
  BEQ @skip                                           ; $C6CB: F0 0A
  LDA #$A8                                            ; $C6CD: A9 A8
  STA slide_y_pos                                           ; $C6CF: 8D BB 04
  LDA #$F5                                            ; $C6D2: A9 F5
  STA col_offset                                         ; $C6D4: 8D 00 00
@skip:
  LDA #$00                                            ; $C6D7: A9 00
  JMP BuildPPUTileBuffer                                           ; $C6D9: 4C FD CD
.endproc
;===============================================================================
; $C6DC: MapScrollB_Draw
;===============================================================================
.proc MapScrollB_Draw
  col_offset     = $0000
  temp_0011       = $0011
  ppu_col_lo       = $00CC
  ppu_col_mid       = $00D4
  ppu_col_hi       = $00DC
MapScrollB_Draw:
  LDA active_player_slot                                           ; $C6DC: AD AA 04
  BEQ @skip                                           ; $C6DF: F0 0A
  LDA slide_y_pos                                           ; $C6E1: AD BB 04
  CMP #$58                                            ; $C6E4: C9 58
  BNE @skip_4                                           ; $C6E6: D0 31
  JMP @skip_2                                           ; $C6E8: 4C F2 C6
@skip:
  LDA slide_y_pos                                           ; $C6EB: AD BB 04
  CMP #$68                                            ; $C6EE: C9 68
  BNE @skip_4                                           ; $C6F0: D0 27
@skip_2:
  LDA #$8F                                            ; $C6F2: A9 8F
  STA a:zp_cc                                         ; $C6F4: 8D CC 00
  STA a:zp_d4                                         ; $C6F7: 8D D4 00
  STA a:zp_dc                                         ; $C6FA: 8D DC 00
  INC sub_state                                           ; $C6FD: EE A9 04
  LDA active_player_slot                                           ; $C700: AD AA 04
  BEQ @skip_3                                           ; $C703: F0 0A
  LDA #$4B                                            ; $C705: A9 4B
  STA col_offset                                         ; $C707: 8D 00 00
  LDA #$0B                                            ; $C70A: A9 0B
  JMP BuildPPUTileBuffer                                           ; $C70C: 4C FD CD
@skip_3:
  LDA #$4D                                            ; $C70F: A9 4D
  STA col_offset                                         ; $C711: 8D 00 00
  LDA #$09                                            ; $C714: A9 09
  JMP BuildPPUTileBuffer                                           ; $C716: 4C FD CD
@skip_4:
  LDA active_player_slot                                           ; $C719: AD AA 04
  STA temp_0011                                         ; $C71C: 8D 11 00
  BEQ @skip_5                                           ; $C71F: F0 06
  DEC slide_y_pos                                           ; $C721: CE BB 04
  JMP MapScroll_UpdatePosition                                           ; $C724: 4C E1 CE
@skip_5:
  INC slide_y_pos                                           ; $C727: EE BB 04
  JMP MapScroll_UpdatePosition                                           ; $C72A: 4C E1 CE
.endproc
;===============================================================================
; $C72D: MapScrollB_Update
;===============================================================================
.proc MapScrollB_Update
  col_offset     = $0000
  temp_00c6       = $00C6
  temp_00c9       = $00C9
  temp_00ce       = $00CE
  temp_00d1       = $00D1
  temp_00d6       = $00D6
  temp_00d9       = $00D9
MapScrollB_Update:
  LDA #$83                                            ; $C72D: A9 83
  STA a:zp_c9                                         ; $C72F: 8D C9 00
  STA a:zp_d1                                         ; $C732: 8D D1 00
  STA a:zp_d9                                         ; $C735: 8D D9 00
  LDY active_player_slot                                           ; $C738: AC AA 04
  LDA name_tile_index,Y                                         ; $C73B: B9 AF 04
  BEQ @skip                                           ; $C73E: F0 0B
  LDA #$84                                            ; $C740: A9 84
  STA a:zp_c6                                         ; $C742: 8D C6 00
  STA a:zp_ce                                         ; $C745: 8D CE 00
  STA a:zp_d6                                         ; $C748: 8D D6 00
@skip:
  LDA #$FF                                            ; $C74B: A9 FF
  STA anim_timer                                           ; $C74D: 8D B8 04
  LDA #$00                                            ; $C750: A9 00
  STA map_scroll_phase                                           ; $C752: 8D B9 04
  LDA #$4F                                            ; $C755: A9 4F
  STA scroll_row_count                                           ; $C757: 8D BA 04
  INC sub_state                                           ; $C75A: EE A9 04
  LDA #$ED                                            ; $C75D: A9 ED
  STA col_offset                                         ; $C75F: 8D 00 00
  LDA #$0A                                            ; $C762: A9 0A
  LDY active_player_slot                                           ; $C764: AC AA 04
  BEQ @skip_2                                           ; $C767: F0 07
  LDA #$EB                                            ; $C769: A9 EB
  STA col_offset                                         ; $C76B: 8D 00 00
  LDA #$0C                                            ; $C76E: A9 0C
@skip_2:
  JMP BuildPPUTileBuffer                                           ; $C770: 4C FD CD
.endproc
;===============================================================================
; $C773: MapScrollB_Animate
;===============================================================================
.proc MapScrollB_Animate
  col_offset     = $0000
  tilemap_attr      = $0002
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  tilemap_work       = $0012
MapScrollB_Animate:
  LDA anim_timer                                           ; $C773: AD B8 04
  LSR A                                               ; $C776: 4A
  LSR A                                               ; $C777: 4A
  LSR A                                               ; $C778: 4A
  AND #$03                                            ; $C779: 29 03
  STA tilemap_work                                         ; $C77B: 8D 12 00
  INC anim_timer                                           ; $C77E: EE B8 04
  LDA anim_timer                                           ; $C781: AD B8 04
  LSR A                                               ; $C784: 4A
  LSR A                                               ; $C785: 4A
  LSR A                                               ; $C786: 4A
  AND #$03                                            ; $C787: 29 03
  CMP #$03                                            ; $C789: C9 03
  BNE @skip_2                                           ; $C78B: D0 26
  LDA #$00                                            ; $C78D: A9 00
  STA anim_timer                                           ; $C78F: 8D B8 04
  INC map_scroll_phase                                           ; $C792: EE B9 04
  LDY map_scroll_phase                                           ; $C795: AC B9 04
  CPY #$03                                            ; $C798: C0 03
  BNE @skip_2                                           ; $C79A: D0 17
  INC sub_state                                           ; $C79C: EE A9 04
  LDA #$4B                                            ; $C79F: A9 4B
  STA col_offset                                         ; $C7A1: 8D 00 00
  LDA active_player_slot                                           ; $C7A4: AD AA 04
  BNE @skip                                           ; $C7A7: D0 05
  LDA #$4D                                            ; $C7A9: A9 4D
  STA col_offset                                         ; $C7AB: 8D 00 00
@skip:
  LDA #$00                                            ; $C7AE: A9 00
  JMP BuildPPUTileBuffer                                           ; $C7B0: 4C FD CD
@skip_2:
  STA ptr_0010_lo                                         ; $C7B3: 8D 10 00
  CMP #$01                                            ; $C7B6: C9 01
  BNE @skip_3                                           ; $C7B8: D0 0A
  CMP tilemap_work                                         ; $C7BA: CD 12 00
  BEQ @skip_3                                           ; $C7BD: F0 05
  LDA #$61                                            ; $C7BF: A9 61
  JSR B1F_SoundNotePlayer                             ; $C7C1: 20 09 E6
@skip_3:
  LDA active_player_slot                                           ; $C7C4: AD AA 04
  BNE @skip_4                                           ; $C7C7: D0 09
  LDA ptr_0010_lo                                         ; $C7C9: AD 10 00
  CLC                                                 ; $C7CC: 18
  ADC #$0F                                            ; $C7CD: 69 0F
  STA ptr_0010_lo                                         ; $C7CF: 8D 10 00
@skip_4:
  LDA #$00                                            ; $C7D2: A9 00
  STA work_marker                                         ; $C7D4: 8D 02 00
  LDA ptr_0010_lo                                         ; $C7D7: AD 10 00
  CLC                                                 ; $C7DA: 18
  ADC #$22                                            ; $C7DB: 69 22
  JSR DrawSpriteFromBank                                           ; $C7DD: 20 A5 CE
  LDA active_player_slot                                           ; $C7E0: AD AA 04
  CLC                                                 ; $C7E3: 18
  ADC #$01                                            ; $C7E4: 69 01
  STA work_marker                                         ; $C7E6: 8D 02 00
  LDA ptr_0010_lo                                         ; $C7E9: AD 10 00
  CLC                                                 ; $C7EC: 18
  ADC #$25                                            ; $C7ED: 69 25
  JSR DrawSpriteFromBank                                           ; $C7EF: 20 A5 CE
  LDY active_player_slot                                           ; $C7F2: AC AA 04
  LDA name_tile_index,Y                                         ; $C7F5: B9 AF 04
  STA ptr_0010_hi                                         ; $C7F8: 8D 11 00
  ASL A                                               ; $C7FB: 0A
  CLC                                                 ; $C7FC: 18
  ADC ptr_0010_hi                                         ; $C7FD: 6D 11 00
  CLC                                                 ; $C800: 18
  ADC ptr_0010_lo                                         ; $C801: 6D 10 00
  ADC #$28                                            ; $C804: 69 28
  JMP DrawSpriteFromBank                                           ; $C806: 4C A5 CE
.endproc
;===============================================================================
; $C809: MapScrollB_Finalize
;===============================================================================
.proc MapScrollB_Finalize
  col_offset     = $0000
  temp_00c6       = $00C6
  temp_00c9       = $00C9
  temp_00ce       = $00CE
  temp_00d1       = $00D1
  temp_00d6       = $00D6
  temp_00d9       = $00D9
MapScrollB_Finalize:
  LDA #$00                                            ; $C809: A9 00
  STA anim_timer                                           ; $C80B: 8D B8 04
  LDA #$57                                            ; $C80E: A9 57
  STA scroll_row_count                                           ; $C810: 8D BA 04
  LDA #$80                                            ; $C813: A9 80
  STA a:zp_c6                                         ; $C815: 8D C6 00
  STA a:zp_ce                                         ; $C818: 8D CE 00
  STA a:zp_d6                                         ; $C81B: 8D D6 00
  LDY active_player_slot                                           ; $C81E: AC AA 04
  LDA name_tile_index,Y                                         ; $C821: B9 AF 04
  CMP #$01                                            ; $C824: C9 01
  BNE @skip                                           ; $C826: D0 0B
  LDA #$96                                            ; $C828: A9 96
  STA a:zp_c9                                         ; $C82A: 8D C9 00
  STA a:zp_d1                                         ; $C82D: 8D D1 00
  STA a:zp_d9                                         ; $C830: 8D D9 00
@skip:
  INC sub_state                                           ; $C833: EE A9 04
  LDA #$EB                                            ; $C836: A9 EB
  STA col_offset                                         ; $C838: 8D 00 00
  LDA active_player_slot                                           ; $C83B: AD AA 04
  BNE @skip_2                                           ; $C83E: D0 05
  LDA #$ED                                            ; $C840: A9 ED
  STA col_offset                                         ; $C842: 8D 00 00
@skip_2:
  LDA #$00                                            ; $C845: A9 00
  JMP BuildPPUTileBuffer                                           ; $C847: 4C FD CD
.endproc
;===============================================================================
; $C84A: MapScrollB_Complete
;===============================================================================
.proc MapScrollB_Complete
  col_offset     = $0000
  ppu_tile_hi     = $0001
  ppu_col_lo       = $00CC
  ppu_col_mid       = $00D4
  ppu_col_hi       = $00DC
MapScrollB_Complete:
  LDA #$90                                            ; $C84A: A9 90
  STA a:zp_cc                                         ; $C84C: 8D CC 00
  STA a:zp_d4                                         ; $C84F: 8D D4 00
  STA a:zp_dc                                         ; $C852: 8D DC 00
  INC sub_state                                           ; $C855: EE A9 04
  LDA active_player_slot                                           ; $C858: AD AA 04
  EOR #$01                                            ; $C85B: 49 01
  TAY                                                 ; $C85D: A8
  LDA name_tile_index,Y                                         ; $C85E: B9 AF 04
  STA ppu_tile_lo                                         ; $C861: 8D 01 00
  CPY #$01                                            ; $C864: C0 01
  BEQ @skip                                           ; $C866: F0 0E
  LDA #$43                                            ; $C868: A9 43
  STA col_offset                                         ; $C86A: 8D 00 00
  LDA #$0D                                            ; $C86D: A9 0D
  CLC                                                 ; $C86F: 18
  ADC ppu_tile_lo                                         ; $C870: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $C873: 4C FD CD
@skip:
  LDA #$55                                            ; $C876: A9 55
  STA col_offset                                         ; $C878: 8D 00 00
  LDA #$10                                            ; $C87B: A9 10
  CLC                                                 ; $C87D: 18
  ADC ppu_tile_lo                                         ; $C87E: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $C881: 4C FD CD
.endproc
;===============================================================================
; $C884: MapScrollB_Extra
;===============================================================================
.proc MapScrollB_Extra
  ppu_tile_hi     = $0001
  tilemap_attr      = $0002
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  tilemap_work       = $0012
  temp_00c9       = $00C9
  temp_00d1       = $00D1
  temp_00d9       = $00D9
MapScrollB_Extra:
  LDA anim_timer                                           ; $C884: AD B8 04
  LSR A                                               ; $C887: 4A
  LSR A                                               ; $C888: 4A
  LSR A                                               ; $C889: 4A
  AND #$07                                            ; $C88A: 29 07
  STA tilemap_work                                         ; $C88C: 8D 12 00
  INC anim_timer                                           ; $C88F: EE B8 04
  LDA anim_timer                                           ; $C892: AD B8 04
  LSR A                                               ; $C895: 4A
  LSR A                                               ; $C896: 4A
  LSR A                                               ; $C897: 4A
  AND #$07                                            ; $C898: 29 07
  CMP #$03                                            ; $C89A: C9 03
  BCC @skip_2                                           ; $C89C: 90 11
  CMP #$05                                            ; $C89E: C9 05
  BCC @skip                                           ; $C8A0: 90 0B
  LDA #$13                                            ; $C8A2: A9 13
  STA game_state                                           ; $C8A4: 8D A8 04
  LDA #$00                                            ; $C8A7: A9 00
  STA sub_state                                           ; $C8A9: 8D A9 04
  RTS                                                 ; $C8AC: 60
@skip:
  LDA #$02                                            ; $C8AD: A9 02
@skip_2:
  STA ptr_0010_lo                                         ; $C8AF: 8D 10 00
  STA ptr_0010_hi                                         ; $C8B2: 8D 11 00
  CMP #$01                                            ; $C8B5: C9 01
  BNE @skip_3                                           ; $C8B7: D0 0A
  CMP tilemap_work                                         ; $C8B9: CD 12 00
  BEQ @skip_3                                           ; $C8BC: F0 05
  LDA #$69                                            ; $C8BE: A9 69
  JSR B1F_SoundNotePlayer                             ; $C8C0: 20 09 E6
@skip_3:
  LDA active_player_slot                                           ; $C8C3: AD AA 04
  BNE @skip_4                                           ; $C8C6: D0 09
  LDA ptr_0010_lo                                         ; $C8C8: AD 10 00
  CLC                                                 ; $C8CB: 18
  ADC #$0F                                            ; $C8CC: 69 0F
  STA ptr_0010_lo                                         ; $C8CE: 8D 10 00
@skip_4:
  LDA #$00                                            ; $C8D1: A9 00
  STA work_marker                                         ; $C8D3: 8D 02 00
  LDA #$40                                            ; $C8D6: A9 40
  STA ppu_tile_lo                                         ; $C8D8: 8D 01 00
  LDY active_player_slot                                           ; $C8DB: AC AA 04
  LDA name_tile_index,Y                                         ; $C8DE: B9 AF 04
  CMP #$01                                            ; $C8E1: C9 01
  BNE @skip_5                                           ; $C8E3: D0 05
  LDA #$4C                                            ; $C8E5: A9 4C
  STA ppu_tile_lo                                         ; $C8E7: 8D 01 00
@skip_5:
  LDA ptr_0010_lo                                         ; $C8EA: AD 10 00
  CLC                                                 ; $C8ED: 18
  ADC ppu_tile_lo                                         ; $C8EE: 6D 01 00
  JSR DrawSpriteFromBank                                           ; $C8F1: 20 A5 CE
  LDA active_player_slot                                           ; $C8F4: AD AA 04
  CLC                                                 ; $C8F7: 18
  ADC #$01                                            ; $C8F8: 69 01
  STA work_marker                                         ; $C8FA: 8D 02 00
  LDY active_player_slot                                           ; $C8FD: AC AA 04
  LDA name_tile_index,Y                                         ; $C900: B9 AF 04
  STA ppu_tile_lo                                         ; $C903: 8D 01 00
  ASL A                                               ; $C906: 0A
  CLC                                                 ; $C907: 18
  ADC ppu_tile_lo                                         ; $C908: 6D 01 00
  CLC                                                 ; $C90B: 18
  ADC ptr_0010_lo                                         ; $C90C: 6D 10 00
  ADC #$43                                            ; $C90F: 69 43
  JSR DrawSpriteFromBank                                           ; $C911: 20 A5 CE
  LDY active_player_slot                                           ; $C914: AC AA 04
  LDA name_tile_index,Y                                         ; $C917: B9 AF 04
  CMP #$01                                            ; $C91A: C9 01
  BEQ @skip_6                                           ; $C91C: F0 12
  LDA anim_timer                                           ; $C91E: AD B8 04
  CMP #$11                                            ; $C921: C9 11
  BNE @skip_6                                           ; $C923: D0 0B
  LDA #$84                                            ; $C925: A9 84
  STA temp_00c9                                         ; $C927: 8D C9 00
  STA temp_00d1                                         ; $C92A: 8D D1 00
  STA temp_00d9                                         ; $C92D: 8D D9 00
@skip_6:
  LDA ptr_0010_hi                                         ; $C930: AD 11 00
  CMP #$02                                            ; $C933: C9 02
  BNE @skip_7                                           ; $C935: D0 11
  LDY active_player_slot                                           ; $C937: AC AA 04
  LDA name_tile_index,Y                                         ; $C93A: B9 AF 04
  AND #$01                                            ; $C93D: 29 01
  CLC                                                 ; $C93F: 18
  ADC #$77                                            ; $C940: 69 77
  STA ptr_0010_lo                                         ; $C942: 8D 10 00
  JMP DrawCompletionSprite                                           ; $C945: 4C 35 D2
@skip_7:
  RTS                                                 ; $C948: 60
.endproc
;===============================================================================
; $C949: MapScrollDispatch_C
;===============================================================================
.proc MapScrollDispatch_C
MapScrollDispatch_C:
  LDA sub_state                                           ; $C949: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $C94C: 20 DE EA
; --- Inline pointer table (8 entries) ---
  .word MapScrollC_Init                                         ; $C94F: 5F C9
  .word MapScrollC_Scroll                                         ; $C951: 76 C9
  .word MapScrollC_Draw                                         ; $C953: 9C C9
  .word MapScrollC_Update                                         ; $C955: ED C9
  .word MapScrollC_Animate                                         ; $C957: 50 CA
  .word MapScrollC_Finalize                                         ; $C959: B8 CA
  .word MapScrollC_Complete                                         ; $C95B: D4 CA
  .word MapScrollC_Extra                                         ; $C95D: 0E CB
.endproc
;===============================================================================
; $C95F: MapScrollC_Init
;===============================================================================
.proc MapScrollC_Init
  col_offset     = $0000
MapScrollC_Init:
  INC sub_state                                           ; $C95F: EE A9 04
  LDA #$55                                            ; $C962: A9 55
  STA col_offset                                         ; $C964: 8D 00 00
  LDA active_player_slot                                           ; $C967: AD AA 04
  BNE @skip                                           ; $C96A: D0 05
  LDA #$43                                            ; $C96C: A9 43
  STA col_offset                                         ; $C96E: 8D 00 00
@skip:
  LDA #$00                                            ; $C971: A9 00
  JMP BuildPPUTileBuffer                                           ; $C973: 4C FD CD
.endproc
;===============================================================================
; $C976: MapScrollC_Scroll
;===============================================================================
.proc MapScrollC_Scroll
  col_offset     = $0000
MapScrollC_Scroll:
  LDA #$00                                            ; $C976: A9 00
  STA anim_timer                                           ; $C978: 8D B8 04
  INC sub_state                                           ; $C97B: EE A9 04
  LDA #$A8                                            ; $C97E: A9 A8
  STA slide_y_pos                                           ; $C980: 8D BB 04
  LDA #$F5                                            ; $C983: A9 F5
  STA col_offset                                         ; $C985: 8D 00 00
  LDA active_player_slot                                           ; $C988: AD AA 04
  BNE @skip                                           ; $C98B: D0 0A
  LDA #$18                                            ; $C98D: A9 18
  STA slide_y_pos                                           ; $C98F: 8D BB 04
  LDA #$E3                                            ; $C992: A9 E3
  STA col_offset                                         ; $C994: 8D 00 00
@skip:
  LDA #$00                                            ; $C997: A9 00
  JMP BuildPPUTileBuffer                                           ; $C999: 4C FD CD
.endproc
;===============================================================================
; $C99C: MapScrollC_Draw
;===============================================================================
.proc MapScrollC_Draw
  col_offset     = $0000
  temp_0011       = $0011
  ppu_col_lo       = $00CC
  ppu_col_mid       = $00D4
  ppu_col_hi       = $00DC
MapScrollC_Draw:
  LDA active_player_slot                                           ; $C99C: AD AA 04
  BEQ @skip                                           ; $C99F: F0 0A
  LDA slide_y_pos                                           ; $C9A1: AD BB 04
  CMP #$58                                            ; $C9A4: C9 58
  BNE @skip_4                                           ; $C9A6: D0 31
  JMP @skip_2                                           ; $C9A8: 4C B2 C9
@skip:
  LDA slide_y_pos                                           ; $C9AB: AD BB 04
  CMP #$68                                            ; $C9AE: C9 68
  BNE @skip_4                                           ; $C9B0: D0 27
@skip_2:
  LDA #$8F                                            ; $C9B2: A9 8F
  STA a:zp_cc                                         ; $C9B4: 8D CC 00
  STA a:zp_d4                                         ; $C9B7: 8D D4 00
  STA a:zp_dc                                         ; $C9BA: 8D DC 00
  INC sub_state                                           ; $C9BD: EE A9 04
  LDA active_player_slot                                           ; $C9C0: AD AA 04
  BEQ @skip_3                                           ; $C9C3: F0 0A
  LDA #$4B                                            ; $C9C5: A9 4B
  STA col_offset                                         ; $C9C7: 8D 00 00
  LDA #$0B                                            ; $C9CA: A9 0B
  JMP BuildPPUTileBuffer                                           ; $C9CC: 4C FD CD
@skip_3:
  LDA #$4D                                            ; $C9CF: A9 4D
  STA col_offset                                         ; $C9D1: 8D 00 00
  LDA #$09                                            ; $C9D4: A9 09
  JMP BuildPPUTileBuffer                                           ; $C9D6: 4C FD CD
@skip_4:
  LDA active_player_slot                                           ; $C9D9: AD AA 04
  STA temp_0011                                         ; $C9DC: 8D 11 00
  BEQ @skip_5                                           ; $C9DF: F0 06
  DEC slide_y_pos                                           ; $C9E1: CE BB 04
  JMP MapScroll_UpdatePosition                                           ; $C9E4: 4C E1 CE
@skip_5:
  INC slide_y_pos                                           ; $C9E7: EE BB 04
  JMP MapScroll_UpdatePosition                                           ; $C9EA: 4C E1 CE
.endproc
;===============================================================================
; $C9ED: MapScrollC_Update
;===============================================================================
.proc MapScrollC_Update
  col_offset     = $0000
  ptr_00be_lo     = $00BE
  ptr_00be_hi     = $00BF
  ptr_00c0_lo     = $00C0
  ptr_00c0_hi     = $00C1
  ptr_00c6_lo     = $00C6
  ptr_00c6_hi     = $00C7
  ptr_00c8_lo     = $00C8
  ptr_00c8_hi     = $00C9
  ptr_00ce_lo     = $00CE
  ptr_00ce_hi     = $00CF
  ptr_00d0_lo     = $00D0
  ptr_00d0_hi     = $00D1
  ptr_00d6_lo     = $00D6
  ptr_00d6_hi     = $00D7
  ptr_00d8_lo     = $00D8
  ptr_00d8_hi     = $00D9
MapScrollC_Update:
  LDA #$3F                                            ; $C9ED: A9 3F
  STA scroll_row_count                                           ; $C9EF: 8D BA 04
  LDA #$86                                            ; $C9F2: A9 86
  STA a:zp_be                                         ; $C9F4: 8D BE 00
  STA a:zp_c6                                         ; $C9F7: 8D C6 00
  STA a:zp_ce                                         ; $C9FA: 8D CE 00
  STA a:zp_d6                                         ; $C9FD: 8D D6 00
  LDA #$87                                            ; $CA00: A9 87
  STA a:zp_bf                                         ; $CA02: 8D BF 00
  STA a:zp_c7                                         ; $CA05: 8D C7 00
  STA a:zp_cf                                         ; $CA08: 8D CF 00
  STA a:zp_d7                                         ; $CA0B: 8D D7 00
  LDA #$93                                            ; $CA0E: A9 93
  STA a:zp_c0                                         ; $CA10: 8D C0 00
  STA a:zp_c8                                         ; $CA13: 8D C8 00
  STA a:zp_d0                                         ; $CA16: 8D D0 00
  STA a:zp_d8                                         ; $CA19: 8D D8 00
  LDA #$94                                            ; $CA1C: A9 94
  STA a:zp_c1                                         ; $CA1E: 8D C1 00
  STA a:zp_c9                                         ; $CA21: 8D C9 00
  STA a:zp_d1                                         ; $CA24: 8D D1 00
  STA a:zp_d9                                         ; $CA27: 8D D9 00
  LDA #$00                                            ; $CA2A: A9 00
  STA anim_timer                                           ; $CA2C: 8D B8 04
  STA map_scroll_phase                                           ; $CA2F: 8D B9 04
  INC sub_state                                           ; $CA32: EE A9 04
  LDA #$61                                            ; $CA35: A9 61
  JSR B1F_SoundNotePlayer                             ; $CA37: 20 09 E6
  LDA #$ED                                            ; $CA3A: A9 ED
  STA col_offset                                         ; $CA3C: 8D 00 00
  LDA #$0A                                            ; $CA3F: A9 0A
  LDY active_player_slot                                           ; $CA41: AC AA 04
  BEQ @skip                                           ; $CA44: F0 07
  LDA #$EB                                            ; $CA46: A9 EB
  STA col_offset                                         ; $CA48: 8D 00 00
  LDA #$0C                                            ; $CA4B: A9 0C
@skip:
  JMP BuildPPUTileBuffer                                           ; $CA4D: 4C FD CD
.endproc
;===============================================================================
; $CA50: MapScrollC_Animate
;===============================================================================
.proc MapScrollC_Animate
  col_offset     = $0000
  ppu_tile_hi     = $0001
  tilemap_attr      = $0002
  tilemap_work       = $0010
MapScrollC_Animate:
  INC anim_timer                                           ; $CA50: EE B8 04
  LDA anim_timer                                           ; $CA53: AD B8 04
  LSR A                                               ; $CA56: 4A
  LSR A                                               ; $CA57: 4A
  LSR A                                               ; $CA58: 4A
  LSR A                                               ; $CA59: 4A
  AND #$01                                            ; $CA5A: 29 01
  BEQ @skip_2                                           ; $CA5C: F0 1C
  LDA #$00                                            ; $CA5E: A9 00
  STA anim_timer                                           ; $CA60: 8D B8 04
  INC sub_state                                           ; $CA63: EE A9 04
  LDA #$4B                                            ; $CA66: A9 4B
  STA col_offset                                         ; $CA68: 8D 00 00
  LDA active_player_slot                                           ; $CA6B: AD AA 04
  BNE @skip                                           ; $CA6E: D0 05
  LDA #$4D                                            ; $CA70: A9 4D
  STA col_offset                                         ; $CA72: 8D 00 00
@skip:
  LDA #$00                                            ; $CA75: A9 00
  JMP BuildPPUTileBuffer                                           ; $CA77: 4C FD CD
@skip_2:
  STA tilemap_work                                         ; $CA7A: 8D 10 00
  LDA active_player_slot                                           ; $CA7D: AD AA 04
  BNE @skip_3                                           ; $CA80: D0 09
  LDA tilemap_work                                         ; $CA82: AD 10 00
  CLC                                                 ; $CA85: 18
  ADC #$14                                            ; $CA86: 69 14
  STA tilemap_work                                         ; $CA88: 8D 10 00
@skip_3:
  LDA #$00                                            ; $CA8B: A9 00
  STA work_marker                                         ; $CA8D: 8D 02 00
  LDA tilemap_work                                         ; $CA90: AD 10 00
  CLC                                                 ; $CA93: 18
  ADC #$80                                            ; $CA94: 69 80
  JSR DrawSpriteFromBank                                           ; $CA96: 20 A5 CE
  LDY active_player_slot                                           ; $CA99: AC AA 04
  TYA                                                 ; $CA9C: 98
  CLC                                                 ; $CA9D: 18
  ADC #$01                                            ; $CA9E: 69 01
  STA work_marker                                         ; $CAA0: 8D 02 00
  LDA name_tile_index,Y                                         ; $CAA3: B9 AF 04
  STA ppu_tile_lo                                         ; $CAA6: 8D 01 00
  ASL A                                               ; $CAA9: 0A
  ASL A                                               ; $CAAA: 0A
  CLC                                                 ; $CAAB: 18
  ADC ppu_tile_lo                                         ; $CAAC: 6D 01 00
  CLC                                                 ; $CAAF: 18
  ADC tilemap_work                                         ; $CAB0: 6D 10 00
  ADC #$85                                            ; $CAB3: 69 85
  JMP DrawSpriteFromBank                                           ; $CAB5: 4C A5 CE
.endproc
;===============================================================================
; $CAB8: MapScrollC_Finalize
;===============================================================================
.proc MapScrollC_Finalize
  col_offset     = $0000
MapScrollC_Finalize:
  LDA #$00                                            ; $CAB8: A9 00
  STA anim_timer                                           ; $CABA: 8D B8 04
  INC sub_state                                           ; $CABD: EE A9 04
  LDA #$EB                                            ; $CAC0: A9 EB
  STA col_offset                                         ; $CAC2: 8D 00 00
  LDA active_player_slot                                           ; $CAC5: AD AA 04
  BNE @skip                                           ; $CAC8: D0 05
  LDA #$ED                                            ; $CACA: A9 ED
  STA col_offset                                         ; $CACC: 8D 00 00
@skip:
  LDA #$00                                            ; $CACF: A9 00
  JMP BuildPPUTileBuffer                                           ; $CAD1: 4C FD CD
.endproc
;===============================================================================
; $CAD4: MapScrollC_Complete
;===============================================================================
.proc MapScrollC_Complete
  col_offset     = $0000
  ppu_tile_hi     = $0001
  ppu_col_lo       = $00CC
  ppu_col_mid       = $00D4
  ppu_col_hi       = $00DC
MapScrollC_Complete:
  LDA #$90                                            ; $CAD4: A9 90
  STA a:zp_cc                                         ; $CAD6: 8D CC 00
  STA a:zp_d4                                         ; $CAD9: 8D D4 00
  STA a:zp_dc                                         ; $CADC: 8D DC 00
  INC sub_state                                           ; $CADF: EE A9 04
  LDA active_player_slot                                           ; $CAE2: AD AA 04
  EOR #$01                                            ; $CAE5: 49 01
  TAY                                                 ; $CAE7: A8
  LDA name_tile_index,Y                                         ; $CAE8: B9 AF 04
  STA ppu_tile_lo                                         ; $CAEB: 8D 01 00
  CPY #$01                                            ; $CAEE: C0 01
  BEQ @skip                                           ; $CAF0: F0 0E
  LDA #$43                                            ; $CAF2: A9 43
  STA col_offset                                         ; $CAF4: 8D 00 00
  LDA #$0D                                            ; $CAF7: A9 0D
  CLC                                                 ; $CAF9: 18
  ADC ppu_tile_lo                                         ; $CAFA: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $CAFD: 4C FD CD
@skip:
  LDA #$55                                            ; $CB00: A9 55
  STA col_offset                                         ; $CB02: 8D 00 00
  LDA #$10                                            ; $CB05: A9 10
  CLC                                                 ; $CB07: 18
  ADC ppu_tile_lo                                         ; $CB08: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $CB0B: 4C FD CD
.endproc
;===============================================================================
; $CB0E: MapScrollC_Extra
;===============================================================================
.proc MapScrollC_Extra
  ppu_tile_hi     = $0001
  tilemap_attr      = $0002
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  tilemap_work       = $0012
MapScrollC_Extra:
  LDA anim_timer                                           ; $CB0E: AD B8 04
  LSR A                                               ; $CB11: 4A
  LSR A                                               ; $CB12: 4A
  LSR A                                               ; $CB13: 4A
  LSR A                                               ; $CB14: 4A
  AND #$07                                            ; $CB15: 29 07
  STA tilemap_work                                         ; $CB17: 8D 12 00
  INC anim_timer                                           ; $CB1A: EE B8 04
  LDA anim_timer                                           ; $CB1D: AD B8 04
  LSR A                                               ; $CB20: 4A
  LSR A                                               ; $CB21: 4A
  LSR A                                               ; $CB22: 4A
  LSR A                                               ; $CB23: 4A
  AND #$07                                            ; $CB24: 29 07
  CMP #$06                                            ; $CB26: C9 06
  BNE @skip                                           ; $CB28: D0 0B
  LDA #$13                                            ; $CB2A: A9 13
  STA game_state                                           ; $CB2C: 8D A8 04
  LDA #$00                                            ; $CB2F: A9 00
  STA sub_state                                           ; $CB31: 8D A9 04
  RTS                                                 ; $CB34: 60
@skip:
  CMP #$03                                            ; $CB35: C9 03
  BNE @skip_2                                           ; $CB37: D0 0C
  CMP tilemap_work                                         ; $CB39: CD 12 00
  BEQ @skip_2                                           ; $CB3C: F0 07
  LDA #$68                                            ; $CB3E: A9 68
  JSR B1F_SoundNotePlayer                             ; $CB40: 20 09 E6
  LDA #$03                                            ; $CB43: A9 03
@skip_2:
  CMP #$04                                            ; $CB45: C9 04
  BCC @skip_3                                           ; $CB47: 90 02
  LDA #$03                                            ; $CB49: A9 03
@skip_3:
  STA ptr_0010_lo                                         ; $CB4B: 8D 10 00
  STA ptr_0010_hi                                         ; $CB4E: 8D 11 00
  LDA active_player_slot                                           ; $CB51: AD AA 04
  BNE @skip_4                                           ; $CB54: D0 09
  LDA ptr_0010_lo                                         ; $CB56: AD 10 00
  CLC                                                 ; $CB59: 18
  ADC #$14                                            ; $CB5A: 69 14
  STA ptr_0010_lo                                         ; $CB5C: 8D 10 00
@skip_4:
  LDA active_player_slot                                           ; $CB5F: AD AA 04
  CLC                                                 ; $CB62: 18
  ADC #$01                                            ; $CB63: 69 01
  STA work_marker                                         ; $CB65: 8D 02 00
  LDY active_player_slot                                           ; $CB68: AC AA 04
  LDA name_tile_index,Y                                         ; $CB6B: B9 AF 04
  STA ppu_tile_lo                                         ; $CB6E: 8D 01 00
  ASL A                                               ; $CB71: 0A
  ASL A                                               ; $CB72: 0A
  CLC                                                 ; $CB73: 18
  ADC ppu_tile_lo                                         ; $CB74: 6D 01 00
  CLC                                                 ; $CB77: 18
  ADC ptr_0010_lo                                         ; $CB78: 6D 10 00
  ADC #$86                                            ; $CB7B: 69 86
  JSR DrawSpriteFromBank                                           ; $CB7D: 20 A5 CE
  LDA #$00                                            ; $CB80: A9 00
  STA work_marker                                         ; $CB82: 8D 02 00
  LDA ptr_0010_lo                                         ; $CB85: AD 10 00
  CLC                                                 ; $CB88: 18
  ADC #$81                                            ; $CB89: 69 81
  JSR DrawSpriteFromBank                                           ; $CB8B: 20 A5 CE
  LDA ptr_0010_hi                                         ; $CB8E: AD 11 00
  CMP #$03                                            ; $CB91: C9 03
  BNE @skip_5                                           ; $CB93: D0 08
  LDA #$79                                            ; $CB95: A9 79
  STA ptr_0010_lo                                         ; $CB97: 8D 10 00
  JMP DrawCompletionSprite                                           ; $CB9A: 4C 35 D2
@skip_5:
  RTS                                                 ; $CB9D: 60
.endproc
;===============================================================================
; $CB9E: MapSlideDispatch_A
;===============================================================================
.proc MapSlideDispatch_A
MapSlideDispatch_A:
  LDA sub_state                                           ; $CB9E: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $CBA1: 20 DE EA
; --- Inline pointer table (3 entries: Init, Slide, Complete) ---
  .word MapSlideA_Init                                         ; $CBA4: AA CB
  .word MapSlideA_Slide                                         ; $CBA6: 0A CC
  .word MapSlideA_Complete                                         ; $CBA8: 62 CC
.endproc
;===============================================================================
; $CBAA: MapSlideA_Init
;===============================================================================
.proc MapSlideA_Init
  ppu_col_offset     = $0000
  tileset_offset     = $0001
  ptr_00c6_lo     = $00C6
  ptr_00c6_hi     = $00C7
  ptr_00c8_lo     = $00C8
  ptr_00c8_hi     = $00C9
  ptr_00ce_lo     = $00CE
  ptr_00ce_hi     = $00CF
  ptr_00d0_lo     = $00D0
  ptr_00d0_hi     = $00D1
  ptr_00d6_lo     = $00D6
  ptr_00d6_hi     = $00D7
  ptr_00d8_lo     = $00D8
  ptr_00d8_hi     = $00D9
MapSlideA_Init:
  LDA #$80                                            ; $CBAA: A9 80
  STA a:zp_c6                                         ; $CBAC: 8D C6 00
  STA a:zp_ce                                         ; $CBAF: 8D CE 00
  STA a:zp_d6                                         ; $CBB2: 8D D6 00
  LDA #$81                                            ; $CBB5: A9 81
  STA a:zp_c7                                         ; $CBB7: 8D C7 00
  STA a:zp_cf                                         ; $CBBA: 8D CF 00
  STA a:zp_d7                                         ; $CBBD: 8D D7 00
  LDA #$82                                            ; $CBC0: A9 82
  STA a:zp_c8                                         ; $CBC2: 8D C8 00
  STA a:zp_d0                                         ; $CBC5: 8D D0 00
  STA a:zp_d8                                         ; $CBC8: 8D D8 00
  LDA #$85                                            ; $CBCB: A9 85
  STA a:zp_c9                                         ; $CBCD: 8D C9 00
  STA a:zp_d1                                         ; $CBD0: 8D D1 00
  STA a:zp_d9                                         ; $CBD3: 8D D9 00
  LDA #$00                                            ; $CBD6: A9 00
  STA anim_timer                                           ; $CBD8: 8D B8 04
  INC sub_state                                           ; $CBDB: EE A9 04
  LDA active_player_slot                                           ; $CBDE: AD AA 04
  EOR #$01                                            ; $CBE1: 49 01
  TAY                                                 ; $CBE3: A8
  LDA name_tile_index,Y                                         ; $CBE4: B9 AF 04
  STA tileset_offset                                         ; $CBE7: 8D 01 00
  CPY #$01                                            ; $CBEA: C0 01
  BEQ @skip                                           ; $CBEC: F0 0E
  LDA #$43                                            ; $CBEE: A9 43
  STA ppu_col_offset                                         ; $CBF0: 8D 00 00
  LDA #$01                                            ; $CBF3: A9 01
  CLC                                                 ; $CBF5: 18
  ADC tileset_offset                                         ; $CBF6: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $CBF9: 4C FD CD
@skip:
  LDA #$55                                            ; $CBFC: A9 55
  STA ppu_col_offset                                         ; $CBFE: 8D 00 00
  LDA #$05                                            ; $CC01: A9 05
  CLC                                                 ; $CC03: 18
  ADC tileset_offset                                         ; $CC04: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $CC07: 4C FD CD
.endproc
;===============================================================================
; $CC0A: MapSlideA_Slide
;===============================================================================
.proc MapSlideA_Slide
  ppu_col_offset     = $0000
  tileset_offset     = $0001
  temp_0011       = $0011
MapSlideA_Slide:
  LDA active_player_slot                                           ; $CC0A: AD AA 04
  BEQ @skip                                           ; $CC0D: F0 0A
  LDA slide_y_pos                                           ; $CC0F: AD BB 04
  CMP #$A8                                            ; $CC12: C9 A8
  BNE @skip_4                                           ; $CC14: D0 33
  JMP @skip_2                                           ; $CC16: 4C 20 CC
@skip:
  LDA slide_y_pos                                           ; $CC19: AD BB 04
  CMP #$18                                            ; $CC1C: C9 18
  BNE @skip_4                                           ; $CC1E: D0 29
@skip_2:
  INC sub_state                                           ; $CC20: EE A9 04
  LDA #$43                                            ; $CC23: A9 43
  STA ppu_col_offset                                         ; $CC25: 8D 00 00
  LDA #$01                                            ; $CC28: A9 01
  STA tileset_offset                                         ; $CC2A: 8D 01 00
  LDA active_player_slot                                           ; $CC2D: AD AA 04
  BEQ @skip_3                                           ; $CC30: F0 0A
  LDA #$55                                            ; $CC32: A9 55
  STA ppu_col_offset                                         ; $CC34: 8D 00 00
  LDA #$05                                            ; $CC37: A9 05
  STA tileset_offset                                         ; $CC39: 8D 01 00
@skip_3:
  LDY active_player_slot                                           ; $CC3C: AC AA 04
  LDA name_tile_index,Y                                         ; $CC3F: B9 AF 04
  CLC                                                 ; $CC42: 18
  ADC tileset_offset                                         ; $CC43: 6D 01 00
  JMP BuildPPUTileBuffer                                           ; $CC46: 4C FD CD
@skip_4:
  LDA active_player_slot                                           ; $CC49: AD AA 04
  EOR #$01                                            ; $CC4C: 49 01
  STA temp_0011                                         ; $CC4E: 8D 11 00
  LDA active_player_slot                                           ; $CC51: AD AA 04
  BEQ @skip_5                                           ; $CC54: F0 06
  INC slide_y_pos                                           ; $CC56: EE BB 04
  JMP MapScroll_UpdatePosition                                           ; $CC59: 4C E1 CE
@skip_5:
  DEC slide_y_pos                                           ; $CC5C: CE BB 04
  JMP MapScroll_UpdatePosition                                           ; $CC5F: 4C E1 CE
.endproc
;===============================================================================
; $CC62: MapSlideA_Complete
;===============================================================================
.proc MapSlideA_Complete
  ppu_col_offset     = $0000
MapSlideA_Complete:
  LDA display_ptr_lo                                           ; $CC62: AD BD 04
  STA game_state                                           ; $CC65: 8D A8 04
  LDA display_ptr_hi                                           ; $CC68: AD BE 04
  STA sub_state                                           ; $CC6B: 8D A9 04
  LDA active_player_slot                                           ; $CC6E: AD AA 04
  BEQ @skip                                           ; $CC71: F0 0A
  LDA #$F5                                            ; $CC73: A9 F5
  STA ppu_col_offset                                         ; $CC75: 8D 00 00
  LDA #$08                                            ; $CC78: A9 08
  JMP BuildPPUTileBuffer                                           ; $CC7A: 4C FD CD
@skip:
  LDA #$E3                                            ; $CC7D: A9 E3
  STA ppu_col_offset                                         ; $CC7F: 8D 00 00
  LDA #$04                                            ; $CC82: A9 04
  JMP BuildPPUTileBuffer                                           ; $CC84: 4C FD CD
.endproc
;===============================================================================
; $CC87: MapSlideDispatch_B
;===============================================================================
.proc MapSlideDispatch_B
MapSlideDispatch_B:
  LDA sub_state                                           ; $CC87: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $CC8A: 20 DE EA
; --- Inline pointer table (3 entries: Init, Slide, Complete) ---
  .word MapSlideB_Init                                         ; $CC8D: 93 CC
  .word MapSlideB_Slide                                         ; $CC8F: AA CC
  .word MapSlideB_Complete                                         ; $CC91: D0 CC
.endproc
;===============================================================================
; $CC93: MapSlideB_Init
;===============================================================================
.proc MapSlideB_Init
  ppu_col_offset     = $0000
MapSlideB_Init:
  INC sub_state                                           ; $CC93: EE A9 04
  LDA #$55                                            ; $CC96: A9 55
  STA ppu_col_offset                                         ; $CC98: 8D 00 00
  LDA active_player_slot                                           ; $CC9B: AD AA 04
  BNE @skip                                           ; $CC9E: D0 05
  LDA #$43                                            ; $CCA0: A9 43
  STA ppu_col_offset                                         ; $CCA2: 8D 00 00
@skip:
  LDA #$00                                            ; $CCA5: A9 00
  JMP BuildPPUTileBuffer                                           ; $CCA7: 4C FD CD
.endproc
;===============================================================================
; $CCAA: MapSlideB_Slide
;===============================================================================
.proc MapSlideB_Slide
  ppu_col_offset     = $0000
MapSlideB_Slide:
  LDA #$00                                            ; $CCAA: A9 00
  STA anim_timer                                           ; $CCAC: 8D B8 04
  INC sub_state                                           ; $CCAF: EE A9 04
  LDA #$A8                                            ; $CCB2: A9 A8
  STA slide_y_pos                                           ; $CCB4: 8D BB 04
  LDA #$F5                                            ; $CCB7: A9 F5
  STA ppu_col_offset                                         ; $CCB9: 8D 00 00
  LDA active_player_slot                                           ; $CCBC: AD AA 04
  BNE @skip                                           ; $CCBF: D0 0A
  LDA #$18                                            ; $CCC1: A9 18
  STA slide_y_pos                                           ; $CCC3: 8D BB 04
  LDA #$E3                                            ; $CCC6: A9 E3
  STA ppu_col_offset                                         ; $CCC8: 8D 00 00
@skip:
  LDA #$00                                            ; $CCCB: A9 00
  JMP BuildPPUTileBuffer                                           ; $CCCD: 4C FD CD
.endproc
;===============================================================================
; $CCD0: MapSlideB_Complete
;===============================================================================
.proc MapSlideB_Complete
  temp_0011       = $0011
  sprite_list      = $0200
MapSlideB_Complete:
  LDA active_player_slot                                           ; $CCD0: AD AA 04
  BEQ @skip                                           ; $CCD3: F0 0A
  LDA slide_y_pos                                           ; $CCD5: AD BB 04
  CMP #$08                                            ; $CCD8: C9 08
  BNE @skip_3                                           ; $CCDA: D0 17
  JMP @skip_2                                           ; $CCDC: 4C E6 CC
@skip:
  LDA slide_y_pos                                           ; $CCDF: AD BB 04
  CMP #$B8                                            ; $CCE2: C9 B8
  BNE @skip_3                                           ; $CCE4: D0 0D
@skip_2:
  LDA display_ptr_lo                                           ; $CCE6: AD BD 04
  STA game_state                                           ; $CCE9: 8D A8 04
  LDA display_ptr_hi                                           ; $CCEC: AD BE 04
  STA sub_state                                           ; $CCEF: 8D A9 04
  RTS                                                 ; $CCF2: 60
@skip_3:
  LDA active_player_slot                                           ; $CCF3: AD AA 04
  EOR #$01                                            ; $CCF6: 49 01
  STA temp_0011                                         ; $CCF8: 8D 11 00
  LDA active_player_slot                                           ; $CCFB: AD AA 04
  BEQ @skip_4                                           ; $CCFE: F0 06
  INC slide_y_pos                                           ; $CD00: EE BB 04
  JMP @skip_5                                           ; $CD03: 4C 09 CD
@skip_4:
  DEC slide_y_pos                                           ; $CD06: CE BB 04
@skip_5:
  JSR MapScroll_UpdatePosition                                           ; $CD09: 20 E1 CE
  LDY #$00                                            ; $CD0C: A0 00
  LDX #$00                                            ; $CD0E: A2 00
@loop:
  CPY a:$007C                                         ; $CD10: CC 7C 00
  BEQ @skip_9                                           ; $CD13: F0 26
  INX                                                 ; $CD15: E8
  INX                                                 ; $CD16: E8
  INX                                                 ; $CD17: E8
  LDA active_player_slot                                           ; $CD18: AD AA 04
  BEQ @skip_6                                           ; $CD1B: F0 08
  LDA sprite_list,X                                         ; $CD1D: BD 00 02
  BMI @skip_8                                           ; $CD20: 30 11
  JMP @skip_7                                           ; $CD22: 4C 2E CD
@skip_6:
  LDA sprite_list,X                                         ; $CD25: BD 00 02
  CMP #$FF                                            ; $CD28: C9 FF
  BCS @skip_8                                           ; $CD2A: B0 07
  BPL @skip_8                                           ; $CD2C: 10 05
@skip_7:
  LDA #$F0                                            ; $CD2E: A9 F0
  STA sprite_list,Y                                         ; $CD30: 99 00 02
@skip_8:
  INX                                                 ; $CD33: E8
  INY                                                 ; $CD34: C8
  INY                                                 ; $CD35: C8
  INY                                                 ; $CD36: C8
  INY                                                 ; $CD37: C8
  JMP @loop                                           ; $CD38: 4C 10 CD
@skip_9:
  RTS                                                 ; $CD3B: 60
.endproc
;===============================================================================
; $CD3C: MapSlideDispatch_C
;===============================================================================
.proc MapSlideDispatch_C
MapSlideDispatch_C:
  LDA sub_state                                           ; $CD3C: AD A9 04
  JSR B1F_CallbackDispatcher                          ; $CD3F: 20 DE EA
; --- Inline pointer table (3 entries: Init, Slide, Complete) ---
  .word MapSlideC_Init                                         ; $CD42: 48 CD
  .word MapSlideC_Slide                                         ; $CD44: 5F CD
  .word MapSlideC_Complete                                         ; $CD46: 85 CD
.endproc
;===============================================================================
; $CD48: MapSlideC_Init
;===============================================================================
.proc MapSlideC_Init
  ppu_col_offset     = $0000
MapSlideC_Init:
  INC sub_state                                           ; $CD48: EE A9 04
  LDA #$55                                            ; $CD4B: A9 55
  STA ppu_col_offset                                         ; $CD4D: 8D 00 00
  LDA active_player_slot                                           ; $CD50: AD AA 04
  BNE @skip                                           ; $CD53: D0 05
  LDA #$43                                            ; $CD55: A9 43
  STA ppu_col_offset                                         ; $CD57: 8D 00 00
@skip:
  LDA #$00                                            ; $CD5A: A9 00
  JMP BuildPPUTileBuffer                                           ; $CD5C: 4C FD CD
.endproc
;===============================================================================
; $CD5F: MapSlideC_Slide
;===============================================================================
.proc MapSlideC_Slide
  ppu_col_offset     = $0000
MapSlideC_Slide:
  LDA #$00                                            ; $CD5F: A9 00
  STA anim_timer                                           ; $CD61: 8D B8 04
  INC sub_state                                           ; $CD64: EE A9 04
  LDA #$A8                                            ; $CD67: A9 A8
  STA slide_y_pos                                           ; $CD69: 8D BB 04
  LDA #$F5                                            ; $CD6C: A9 F5
  STA ppu_col_offset                                         ; $CD6E: 8D 00 00
  LDA active_player_slot                                           ; $CD71: AD AA 04
  BNE @skip                                           ; $CD74: D0 0A
  LDA #$18                                            ; $CD76: A9 18
  STA slide_y_pos                                           ; $CD78: 8D BB 04
  LDA #$E3                                            ; $CD7B: A9 E3
  STA ppu_col_offset                                         ; $CD7D: 8D 00 00
@skip:
  LDA #$00                                            ; $CD80: A9 00
  JMP BuildPPUTileBuffer                                           ; $CD82: 4C FD CD
.endproc
;===============================================================================
; $CD85: MapSlideC_Complete
;===============================================================================
.proc MapSlideC_Complete
  temp_0011       = $0011
  sprite_list      = $0200
MapSlideC_Complete:
  LDA active_player_slot                                           ; $CD85: AD AA 04
  BEQ @skip                                           ; $CD88: F0 0A
  LDA slide_y_pos                                           ; $CD8A: AD BB 04
  CMP #$B8                                            ; $CD8D: C9 B8
  BNE @skip_3                                           ; $CD8F: D0 17
  JMP @skip_2                                           ; $CD91: 4C 9B CD
@skip:
  LDA slide_y_pos                                           ; $CD94: AD BB 04
  CMP #$08                                            ; $CD97: C9 08
  BNE @skip_3                                           ; $CD99: D0 0D
@skip_2:
  LDA display_ptr_lo                                           ; $CD9B: AD BD 04
  STA game_state                                           ; $CD9E: 8D A8 04
  LDA display_ptr_hi                                           ; $CDA1: AD BE 04
  STA sub_state                                           ; $CDA4: 8D A9 04
  RTS                                                 ; $CDA7: 60
@skip_3:
  LDA active_player_slot                                           ; $CDA8: AD AA 04
  STA temp_0011                                         ; $CDAB: 8D 11 00
  LDA active_player_slot                                           ; $CDAE: AD AA 04
  BNE @skip_4                                           ; $CDB1: D0 06
  INC slide_y_pos                                           ; $CDB3: EE BB 04
  JMP @skip_5                                           ; $CDB6: 4C BC CD
@skip_4:
  DEC slide_y_pos                                           ; $CDB9: CE BB 04
@skip_5:
  JSR MapScroll_UpdatePosition                                           ; $CDBC: 20 E1 CE
  LDY #$00                                            ; $CDBF: A0 00
  LDX #$00                                            ; $CDC1: A2 00
@loop:
  CPY a:$007C                                         ; $CDC3: CC 7C 00
  BEQ @skip_10                                           ; $CDC6: F0 34
  INX                                                 ; $CDC8: E8
  INX                                                 ; $CDC9: E8
  INX                                                 ; $CDCA: E8
  LDA active_player_slot                                           ; $CDCB: AD AA 04
  BEQ @skip_6                                           ; $CDCE: F0 0F
  LDA slide_y_pos                                           ; $CDD0: AD BB 04
  CMP #$B8                                            ; $CDD3: C9 B8
  BCC @skip_9                                           ; $CDD5: 90 1D
  LDA sprite_list,X                                         ; $CDD7: BD 00 02
  BMI @skip_8                                           ; $CDDA: 30 13
  JMP @skip_9                                           ; $CDDC: 4C F4 CD
@skip_6:
  LDA slide_y_pos                                           ; $CDDF: AD BB 04
  CMP #$18                                            ; $CDE2: C9 18
  BCC @skip_7                                           ; $CDE4: 90 04
  CMP #$C8                                            ; $CDE6: C9 C8
  BCC @skip_9                                           ; $CDE8: 90 0A
@skip_7:
  LDA sprite_list,X                                         ; $CDEA: BD 00 02
  BMI @skip_9                                           ; $CDED: 30 05
@skip_8:
  LDA #$F0                                            ; $CDEF: A9 F0
  STA sprite_list,Y                                         ; $CDF1: 99 00 02
@skip_9:
  INX                                                 ; $CDF4: E8
  INY                                                 ; $CDF5: C8
  INY                                                 ; $CDF6: C8
  INY                                                 ; $CDF7: C8
  INY                                                 ; $CDF8: C8
  JMP @loop                                           ; $CDF9: 4C C3 CD
@skip_10:
  RTS                                                 ; $CDFC: 60
.endproc
;===============================================================================
; $CDFD: BuildPPUTileBuffer
;
; Queue a vertical column of 5 tiles (8x8 pixels each) into the PPU upload
; buffer at $0380 for deferred nametable writes during NMI.
;
; Input:
;   A      = tile column index (0-31), selects source tile data
;   $0000  = PPU destination address low byte (column position in nametable)
;   $0001  = (unused, overwritten with $21 inside)
;
; Source tile data is read from MapColumnTileGfx + index * 40.
; Each column entry in the buffer has a 3-byte header ($08, PPU hi, PPU lo)
; followed by 8 tile bytes. The buffer is terminated with $FF.
; Sets bit 2 of $007E to signal NMI that tile data is ready.
;===============================================================================
.proc BuildPPUTileBuffer
  ppu_col_lo      = $0000                               ; PPU dest addr lo (caller sets)
  ppu_col_hi      = $0001                               ; PPU dest addr hi (set to $21)
  tile_src_lo     = $0002                               ; Source pointer lo (computed)
  tile_src_hi     = $0003                               ; Source pointer hi (computed)
  tile_src_lo2    = $0004                               ; Temp copy for multiply
  tile_src_hi2    = $0005                               ; Temp copy for multiply
  ppu_upload_buf  = sprite_y_buffer                               ; PPU upload buffer base
  TILE_DATA_BASE_LO = <MapColumnTileGfx               ; Base addr lo ($D2AB)
  TILE_DATA_BASE_HI = >MapColumnTileGfx               ; Base addr hi ($D2AB)
  NUM_TILES       = 5                                   ; Tiles per column
  ENTRY_SIZE      = 11                                  ; 3 header + 8 data bytes
BuildPPUTileBuffer:
  ;--- Compute source pointer: tile_src = MapColumnTileGfx + A * 40 ---
  ; A * 40 = A * 8 + A * 32 (two shift-and-accumulate passes)
  STA tile_src_lo                                        ; $CDFD: 8D 02 00
  LDA #$00                                            ; $CE00: A9 00
  STA tile_src_hi                                        ; $CE02: 8D 03 00
  LDA tile_src_lo                                        ; $CE05: AD 02 00
  ; Pass 1: multiply by 8 (3 left shifts -> tile_src *= 8)
  ASL A                                               ; $CE08: 0A
  ROL tile_src_hi                                        ; $CE09: 2E 03 00
  ASL A                                               ; $CE0C: 0A
  ROL tile_src_hi                                        ; $CE0D: 2E 03 00
  ASL A                                               ; $CE10: 0A
  ROL tile_src_hi                                        ; $CE11: 2E 03 00
  STA tile_src_lo2                                       ; $CE14: 8D 04 00
  LDA tile_src_hi                                        ; $CE17: AD 03 00
  STA tile_src_hi2                                       ; $CE1A: 8D 05 00
  ; Pass 2: multiply by 32 (2 more shifts on the copy -> tile_src2 = A * 32)
  LDA tile_src_lo2                                       ; $CE1D: AD 04 00
  ASL A                                               ; $CE20: 0A
  ROL tile_src_hi                                        ; $CE21: 2E 03 00
  ASL A                                               ; $CE24: 0A
  ROL tile_src_hi                                        ; $CE25: 2E 03 00
  ; Accumulate: tile_src = A*8 + A*32 = A*40
  CLC                                                 ; $CE28: 18
  ADC tile_src_lo2                                       ; $CE29: 6D 04 00
  STA tile_src_lo                                        ; $CE2C: 8D 02 00
  LDA tile_src_hi                                        ; $CE2F: AD 03 00
  ADC tile_src_hi2                                       ; $CE32: 6D 05 00
  STA tile_src_hi                                        ; $CE35: 8D 03 00
  ; Add base address (MapColumnTileGfx)
  LDA tile_src_lo                                        ; $CE38: AD 02 00
  CLC                                                 ; $CE3B: 18
  ADC #TILE_DATA_BASE_LO                                ; $CE3C: 69 AB
  STA tile_src_lo                                        ; $CE3E: 8D 02 00
  LDA tile_src_hi                                        ; $CE41: AD 03 00
  ADC #TILE_DATA_BASE_HI                                ; $CE44: 69 D2
  STA tile_src_hi                                        ; $CE46: 8D 03 00
  ;--- Initialize PPU column address (hi byte always $21) ---
  LDA #$21                                            ; $CE49: A9 21
  STA ppu_col_hi                                         ; $CE4B: 8D 01 00
  LDX #$00                                            ; $CE4E: A2 00
;--- Main loop: queue 5 column entries into PPU upload buffer ---
@write_entry:
  ; Write 3-byte header: [$08, PPU_hi, PPU_lo]
  LDA #$08                                            ; $CE50: A9 08  (count = 8 tile bytes)
  STA ppu_upload_buf,X                                   ; $CE52: 9D 80 03
  INX                                                 ; $CE55: E8
  LDA ppu_col_hi                                         ; $CE56: AD 01 00
  STA ppu_upload_buf,X                                   ; $CE59: 9D 80 03
  INX                                                 ; $CE5C: E8
  LDA ppu_col_lo                                         ; $CE5D: AD 00 00
  STA ppu_upload_buf,X                                   ; $CE60: 9D 80 03
  INX                                                 ; $CE63: E8
  ; Copy 8 bytes of tile data from (tile_src),Y
  LDY #$00                                            ; $CE64: A0 00
@copy_tile:
  LDA (tile_src_lo),Y                                    ; $CE66: B1 02
  STA ppu_upload_buf,X                                   ; $CE68: 9D 80 03
  INX                                                 ; $CE6B: E8
  INY                                                 ; $CE6C: C8
  CPY #$08                                            ; $CE6D: C0 08
  BCC @copy_tile                                        ; $CE6F: 90 F5
  ; Advance PPU address down one row (+$20 = next nametable row)
  LDA ppu_col_lo                                         ; $CE71: AD 00 00
  CLC                                                 ; $CE74: 18
  ADC #$20                                            ; $CE75: 69 20
  STA ppu_col_lo                                         ; $CE77: 8D 00 00
  LDA ppu_col_hi                                         ; $CE7A: AD 01 00
  ADC #$00                                            ; $CE7D: 69 00
  STA ppu_col_hi                                         ; $CE7F: 8D 01 00
  ; Advance source pointer by 8 bytes (next tile)
  LDA tile_src_lo                                        ; $CE82: AD 02 00
  CLC                                                 ; $CE85: 18
  ADC #$08                                            ; $CE86: 69 08
  STA tile_src_lo                                        ; $CE88: 8D 02 00
  LDA tile_src_hi                                        ; $CE8B: AD 03 00
  ADC #$00                                            ; $CE8E: 69 00
  STA tile_src_hi                                        ; $CE90: 8D 03 00
  ; Loop until all 5 tiles queued (5 * 11 = 55 bytes, X = $37)
  CPX #(NUM_TILES * ENTRY_SIZE)                          ; $CE93: E0 37
  BCC @write_entry                                      ; $CE95: 90 B9
  ;--- Terminate buffer and signal NMI ---
  LDA #$FF                                            ; $CE97: A9 FF
  STA ppu_upload_buf,X                                   ; $CE99: 9D 80 03  (end marker)
  LDA a:addr_nmi_ctrl                                   ; $CE9C: AD 7E 00
  ORA #$04                                            ; $CE9F: 09 04  (set bit 2: tile data ready)
  STA a:addr_nmi_ctrl                                   ; $CEA1: 8D 7E 00
  RTS                                                 ; $CEA4: 60
.endproc
;===============================================================================
; $CEA5: DrawSpriteFromBank
;
; Load sprite OAM data from a banked ROM table and pass it to the OAM writer.
;
; Input:
;   A      = sprite ID: bit 7 selects bank, bits 6-0 = table entry index
;   $04BA  = X base coordinate (copied to $0A for OAM writer)
;   $04BB  = Y base coordinate (copied to $0C for OAM writer)
;   $0002  = flip flags (pre-set by caller, used by OAM writer)
;
; Bank selection: bit 7 clear -> PRG bank $34, bit 7 set -> PRG bank $35.
; Reads a 2-byte sprite data pointer from table at $8000 in the switched bank.
; The pointer high byte is adjusted by subtracting $00 (bank $34) or $20 (bank $35).
; Final pointer stored at $00/$01 for SpriteOamWriterSimple.
;===============================================================================
.proc DrawSpriteFromBank
  sprite_ptr_lo   = $0000                               ; Sprite data ptr lo (output)
  sprite_ptr_hi   = $0001                               ; Sprite data ptr hi (output, adjusted)
  x_coord_base    = $000A                               ; X base coord (for OAM writer)
  y_coord_base    = $000C                               ; Y base coord (for OAM writer)
  sprite_pos_lo   = $04BA                               ; Sprite position ptr lo (input)
  sprite_pos_hi   = $04BB                               ; Sprite position ptr hi (input)
  BANK_SPRITE_A   = $34                                 ; PRG bank for sprites (set A)
  BANK_SPRITE_B   = $35                                 ; PRG bank for sprites (set B)
  HI_OFFSET_A     = $00                                 ; Ptr hi adjustment bank A
  HI_OFFSET_B     = $20                                 ; Ptr hi adjustment bank B
DrawSpriteFromBank:
  ;--- Select sprite bank from bit 7 of A ---
  ASL A                                               ; $CEA5: 0A  (bit 7 -> carry, index *= 2)
  BCS @bank_b                                           ; $CEA6: B0 0E
  ; Bit 7 clear: use bank $34 (no hi-byte offset)
  LDY #BANK_SPRITE_A                                    ; $CEA8: A0 34
  JSR B1F_SwitchBank8_B                                 ; $CEAA: 20 5F F2
  TAY                                                 ; $CEAD: A8  (Y = shifted index)
  LDA #HI_OFFSET_A                                      ; $CEAE: A9 00
  STA sprite_ptr_hi                                     ; $CEB0: 8D 01 00
  JMP @read_entry                                       ; $CEB3: 4C C1 CE
@bank_b:
  ; Bit 7 set: use bank $35 (hi-byte offset $20)
  LDY #BANK_SPRITE_B                                    ; $CEB6: A0 35
  JSR B1F_SwitchBank8_B                                 ; $CEB8: 20 5F F2
  TAY                                                 ; $CEBB: A8  (Y = shifted index)
  LDA #HI_OFFSET_B                                      ; $CEBC: A9 20
  STA sprite_ptr_hi                                     ; $CEBE: 8D 01 00
@read_entry:
  ;--- Read 2-byte sprite data pointer from table at $8000 ---
  LDA $8000,Y                                           ; $CEC1: B9 00 80  (pointer lo)
  STA sprite_ptr_lo                                     ; $CEC4: 8D 00 00
  INY                                                 ; $CEC7: C8
  LDA $8000,Y                                           ; $CEC8: B9 00 80  (pointer hi)
  SEC                                                 ; $CECB: 38
  SBC sprite_ptr_hi                                     ; $CECC: ED 01 00  (hi - offset)
  STA sprite_ptr_hi                                     ; $CECF: 8D 01 00
  ;--- Load X/Y base coordinates from $04BA/$04BB ---
  LDA sprite_pos_lo                                     ; $CED2: AD BA 04
  STA x_coord_base                                      ; $CED5: 8D 0A 00  ($0A for OAM writer)
  LDA sprite_pos_hi                                     ; $CED8: AD BB 04
  STA y_coord_base                                      ; $CEDB: 8D 0C 00  ($0C for OAM writer)
  ;--- Hand off to OAM writer (reads sprite data, writes OAM entries) ---
  JMP B1F_SpriteOamWriterSimple                         ; $CEDE: 4C AD F1
.endproc
;===============================================================================
; $CEE1: MapScroll_UpdatePosition
;
; Update the map scroll animation by drawing 3 sprites that form one tile
; column. The scroll phase (derived from a frame counter) selects sprite
; indices from lookup tables to create a smooth scrolling illusion.
;
; Input (set by caller):
;   $0010  = scroll column offset (base sprite index)
;   $0011  = scroll direction (0 = forward, non-zero = backward)
;   $04AA  = active player slot
;   $04AF+slot = player state (2 = special offset applied)
;   $04B8  = frame counter (incremented here)
;   $04BA  = X coordinate base for sprites (adjusted by phase)
;
; Process:
;   1. Increment frame counter, play sound every 32 frames
;   2. Derive scroll phase (0-7) from counter / 4
;   3. Adjust X base ($04BA) by phase: phase 1,2 -> -2; phase 4,5 -> +2
;   4. Draw 3 sprites (top/middle/bottom tiles of the column)
;   5. Two paths: forward ($0011=0) or backward ($0011!=0) with different
;      sprite indices and flip flags
;===============================================================================
.proc MapScroll_UpdatePosition
  flip_flags      = $0002                               ; Sprite flip flags (for OAM writer)
  scroll_col_off  = $0010                               ; Scroll column offset (input)
  scroll_dir      = $0011                               ; Scroll direction: 0=fwd, nonzero=bwd
  player_offset   = $0012                               ; Extra offset from player state
  scroll_timer    = $04B8                               ; Frame counter for animation
  player_slot     = $04AA                               ; Active player slot index
  player_states   = $04AF                               ; Player state array base
  sprite_x_base   = $04BA                               ; Sprite X coordinate base
  SPRITE_X_DEFAULT = $5D                                ; Default X position
  SOUND_SCROLL    = $60                                 ; Sound ID for scroll tick
  TIMER_PERIOD    = $20                                 ; Frames between sound ticks
MapScroll_UpdatePosition:
  ;--- Advance frame counter, play tick sound every 32 frames ---
  INC scroll_timer                                       ; $CEE1: EE B8 04
  LDA scroll_timer                                       ; $CEE4: AD B8 04
  CMP #TIMER_PERIOD                                     ; $CEE7: C9 20
  BCC @no_sound                                         ; $CEE9: 90 0A
  LDA #$00                                            ; $CEEB: A9 00
  STA scroll_timer                                       ; $CEED: 8D B8 04
  LDA #SOUND_SCROLL                                     ; $CEF0: A9 60
  JSR B1F_SoundNotePlayer                               ; $CEF2: 20 09 E6
@no_sound:
  ;--- Derive scroll phase (0-7) from timer / 4 ---
  LSR A                                               ; $CEF5: 4A  (A = timer / 2)
  LSR A                                               ; $CEF6: 4A  (A = timer / 4)
  AND #$0F                                            ; $CEF7: 29 0F
  STA scroll_col_off                                     ; $CEF9: 8D 10 00  (reuse as phase index)
  ;--- Adjust sprite X base by scroll phase ---
  ; Phase 1,2 -> shift left (-2); Phase 4,5 -> shift right (+2); else unchanged
  LDA #SPRITE_X_DEFAULT                                 ; $CEFC: A9 5D
  STA sprite_x_base                                     ; $CEFE: 8D BA 04
  LDA scroll_col_off                                     ; $CF01: AD 10 00
  CMP #$01                                            ; $CF04: C9 01
  BEQ @shift_left                                       ; $CF06: F0 15
  CMP #$02                                            ; $CF08: C9 02
  BEQ @shift_left                                       ; $CF0A: F0 11
  CMP #$04                                            ; $CF0C: C9 04
  BEQ @shift_right                                      ; $CF0E: F0 04
  CMP #$05                                            ; $CF10: C9 05
  BNE @phase_done                                       ; $CF12: D0 0F
@shift_right:
  INC sprite_x_base                                     ; $CF14: EE BA 04  (phase 4,5: +2)
  INC sprite_x_base                                     ; $CF17: EE BA 04
  JMP @phase_done                                       ; $CF1A: 4C 23 CF
@shift_left:
  DEC sprite_x_base                                     ; $CF1D: CE BA 04  (phase 1,2: -2)
  DEC sprite_x_base                                     ; $CF20: CE BA 04
@phase_done:
  ;--- Compute player-specific offset (2 if player state == 2, else 0) ---
  LDY player_slot                                        ; $CF23: AC AA 04
  LDA player_states,Y                                    ; $CF26: B9 AF 04
  CMP #$02                                            ; $CF29: C9 02
  BEQ @store_offset                                     ; $CF2B: F0 02
  LDA #$00                                            ; $CF2D: A9 00
@store_offset:
  STA player_offset                                     ; $CF2F: 8D 12 00
  ;--- Branch on scroll direction ---
  LDA scroll_dir                                         ; $CF32: AD 11 00
  BEQ @scroll_forward                                   ; $CF35: F0 2A
  ;--- Backward scroll path: flip=$00, base offset=0 ---
  LDA #$00                                            ; $CF37: A9 00
  STA flip_flags                                        ; $CF39: 8D 02 00  (no flip)
  LDA scroll_col_off                                     ; $CF3C: AD 10 00
  JSR DrawSpriteFromBank                                ; $CF3F: 20 A5 CE  (sprite 1: column top)
  LDA player_slot                                        ; $CF42: AD AA 04
  CLC                                                 ; $CF45: 18
  ADC #$01                                            ; $CF46: 69 01
  STA flip_flags                                        ; $CF48: 8D 02 00  (flip = player_slot+1)
  LDY scroll_col_off                                     ; $CF4B: AC 10 00
  LDA ScrollSpriteMidTable,Y                             ; $CF4E: B9 9B CF  (middle sprite index)
  CLC                                                 ; $CF51: 18
  ADC player_offset                                     ; $CF52: 6D 12 00  (+ player state offset)
  JSR DrawSpriteFromBank                                ; $CF55: 20 A5 CE  (sprite 2: column middle)
  LDY scroll_col_off                                     ; $CF58: AC 10 00
  LDA ScrollSpriteTopTable,Y                             ; $CF5B: B9 93 CF  (top sprite index)
  JMP DrawSpriteFromBank                                ; $CF5E: 4C A5 CE  (sprite 3: column bottom)
  ;--- Forward scroll path: flip=$40, base offset=$11 ---
@scroll_forward:
  LDA #$40                                            ; $CF61: A9 40
  STA flip_flags                                        ; $CF63: 8D 02 00  (horizontal flip)
  LDA scroll_col_off                                     ; $CF66: AD 10 00
  CLC                                                 ; $CF69: 18
  ADC #$11                                            ; $CF6A: 69 11  (base offset $11)
  JSR DrawSpriteFromBank                                ; $CF6C: 20 A5 CE  (sprite 1)
  LDA player_slot                                        ; $CF6F: AD AA 04
  CLC                                                 ; $CF72: 18
  ADC #$41                                            ; $CF73: 69 41  (player + $41)
  STA flip_flags                                        ; $CF75: 8D 02 00  (flip flags)
  LDY scroll_col_off                                     ; $CF78: AC 10 00
  LDA ScrollSpriteMidTable,Y                             ; $CF7B: B9 9B CF  (middle sprite index)
  CLC                                                 ; $CF7E: 18
  ADC #$11                                            ; $CF7F: 69 11  (+ base offset)
  ADC player_offset                                     ; $CF81: 6D 12 00  (+ player state offset)
  JSR DrawSpriteFromBank                                ; $CF84: 20 A5 CE  (sprite 2)
  LDY scroll_col_off                                     ; $CF87: AC 10 00
  LDA ScrollSpriteTopTable,Y                             ; $CF8A: B9 93 CF  (top sprite index)
  CLC                                                 ; $CF8D: 18
  ADC #$11                                            ; $CF8E: 69 11  (+ base offset)
  JMP DrawSpriteFromBank                                ; $CF90: 4C A5 CE  (sprite 3)
; $CF93: ScrollSpriteTopTable - Top tile sprite IDs indexed by scroll phase (8 entries)
; $CF9B: ScrollSpriteMidTable - Middle tile sprite IDs indexed by scroll phase (8 entries)
ScrollSpriteTopTable:
  .byte $08,$09,$0A,$0A,$0B,$0C,$0B,$0B                 ; $CF93: 08 09 0A 0A 0B 0C 0B 0B
ScrollSpriteMidTable:
  .byte $0D,$0E,$0E,$0E,$0D,$0D,$0D,$0D                 ; $CF9B: 0D 0E 0E 0E 0D 0D 0D 0D
.endproc

;===============================================================================
; $CFA3: ExpandMetatileToSprites
; Expands a metatile (4 rows x 6 tiles) from data table at $8DB4 into
; sprite buffer entries at $0380+X.
; Input:  A = metatile ID, $0003 = base Y position for first row
; Data format: 13 bytes per metatile (header + 6 tile pairs per row)
;===============================================================================
.proc ExpandMetatileToSprites
  src_ptr_lo      = $0000
  src_ptr_hi      = $0001
  metatile_id     = $0002
  base_y_pos      = $0003
  offset_hi       = $0004
  tile_offset     = $0005
  row_data_buf    = $00AE
  sprite_buf      = sprite_y_buffer
ExpandMetatileToSprites:
  STA metatile_id                                        ; $CFA3: 8D 02 00  ; save metatile ID
  LDA #$00                                            ; $CFA6: A9 00
  STA offset_hi                                          ; $CFA8: 8D 01 00  ; clear high byte of offset
  LDA metatile_id                                        ; $CFAB: AD 02 00
  ASL A                                               ; $CFAE: 0A        ; *2
  ROL offset_hi                                          ; $CFAF: 2E 01 00
  CLC                                                 ; $CFB2: 18
  ADC metatile_id                                        ; $CFB3: 6D 02 00  ; *2 + id = *3
  STA metatile_id                                        ; $CFB6: 8D 00 00
  LDA offset_hi                                          ; $CFB9: AD 01 00
  ADC #$00                                            ; $CFBC: 69 00
  STA offset_hi                                          ; $CFBE: 8D 01 00
  LDA metatile_id                                        ; $CFC1: AD 00 00
  ASL A                                               ; $CFC4: 0A        ; *6
  ROL offset_hi                                          ; $CFC5: 2E 01 00
  ASL A                                               ; $CFC8: 0A        ; *12
  ROL offset_hi                                          ; $CFC9: 2E 01 00
  CLC                                                 ; $CFCC: 18
  ADC metatile_id                                        ; $CFCD: 6D 02 00  ; *12 + id = *13
  STA metatile_id                                        ; $CFD0: 8D 00 00  ; low byte of id*13
  LDA offset_hi                                          ; $CFD3: AD 01 00
  ADC #$00                                            ; $CFD6: 69 00
  STA offset_hi                                          ; $CFD8: 8D 01 00  ; high byte of id*13
  LDA #$B4                                            ; $CFDB: A9 B4     ; add base $8DB4
  CLC                                                 ; $CFDD: 18
  ADC metatile_id                                        ; $CFDE: 6D 00 00
  STA src_ptr_lo                                         ; $CFE1: 8D 00 00
  LDA #$8D                                            ; $CFE4: A9 8D
  ADC offset_hi                                          ; $CFE6: 6D 01 00
  STA src_ptr_hi                                         ; $CFE9: 8D 01 00
  LDY #$00                                            ; $CFEC: A0 00
  LDA (src_ptr_lo),Y                                     ; $CFEE: B1 00     ; read row header byte
  STA metatile_id                                        ; $CFF0: 8D 02 00  ; scratch: store header
  LDY #$05                                            ; $CFF3: A0 05     ; start tile pair index (byte 1)
  LDA #$40                                            ; $CFF5: A9 40     ; default tile offset
  STA tile_offset                                        ; $CFF7: 8D 05 00
  LDA base_y_pos                                         ; $CFFA: AD 03 00
  CMP #$52                                            ; $CFFD: C9 52     ; second metatile call?
  BNE @set_y_start                                       ; $CFFF: D0 06
  LDA #$80                                            ; $D001: A9 80     ; use upper tile offset
  STA tile_offset                                        ; $D003: 8D 05 00
  INY                                                 ; $D006: C8        ; start at byte 2
@set_y_start:
  LDA metatile_id                                        ; $D007: AD 02 00  ; reload header byte
  STA a:row_data_buf,Y                                   ; $D00A: 99 AE 00  ; cache in ZP buffer
@row_loop:
  LDA #$06                                            ; $D00D: A9 06     ; sprite type marker
  STA sprite_buf,X                                       ; $D00F: 9D 80 03
  INX                                                 ; $D012: E8
  LDA #$20                                            ; $D013: A9 20     ; X spacing
  STA sprite_buf,X                                       ; $D015: 9D 80 03
  INX                                                 ; $D018: E8
  LDA base_y_pos                                         ; $D019: AD 03 00  ; Y position
  STA sprite_buf,X                                       ; $D01C: 9D 80 03
  INX                                                 ; $D01F: E8
  LDY #$01                                            ; $D020: A0 01     ; first tile pair
@tile_loop:
  LDA (src_ptr_lo),Y                                     ; $D022: B1 00     ; read tile byte
  CMP #$FF                                            ; $D024: C9 FF     ; empty tile sentinel?
  BNE @calc_tile                                         ; $D026: D0 05
  LDA #$01                                            ; $D028: A9 01     ; blank tile
  JMP @store_tile                                        ; $D02A: 4C 31 D0
@calc_tile:
  CLC                                                 ; $D02D: 18
  ADC tile_offset                                        ; $D02E: 6D 05 00  ; add tile page offset
@store_tile:
  STA sprite_buf,X                                       ; $D031: 9D 80 03
  INX                                                 ; $D034: E8
  INY                                                 ; $D035: C8        ; advance to next byte in pair
  TYA                                                 ; $D036: 98
  AND #$01                                            ; $D037: 29 01     ; even index = next pair
  BEQ @tile_loop                                         ; $D039: F0 E7
  INY                                                 ; $D03B: C8        ; skip pair boundary
  INY                                                 ; $D03C: C8
  CPY #$0D                                            ; $D03D: C0 0D     ; processed all 6 pairs (13 bytes)?
  BCC @tile_loop                                         ; $D03F: 90 E1
  LDA src_ptr_lo                                         ; $D041: AD 00 00  ; advance to next 13-byte row
  CLC                                                 ; $D044: 18
  ADC #$02                                            ; $D045: 69 02
  STA src_ptr_lo                                         ; $D047: 8D 00 00
  LDA src_ptr_hi                                         ; $D04A: AD 01 00
  ADC #$00                                            ; $D04D: 69 00
  STA src_ptr_hi                                         ; $D04F: 8D 01 00
  LDA base_y_pos                                         ; $D052: AD 03 00  ; next row Y += $20
  CLC                                                 ; $D055: 18
  ADC #$20                                            ; $D056: 69 20
  STA base_y_pos                                         ; $D058: 8D 03 00
  CMP #$80                                            ; $D05B: C9 80     ; done 4 rows?
  BCC @row_loop                                          ; $D05D: 90 AE
  RTS                                                 ; $D05F: 60
.endproc
;===============================================================================
; $D060: FinalizeSpriteBuffer
;===============================================================================
.proc FinalizeSpriteBuffer
  sprite_pos      = $0000  ; sprite buffer position / quotient
  officer_pos     = $0001  ; officer position value / remainder
  slot_base       = $0010  ; base offset for sprite slot ($A4 or $B2)
FinalizeSpriteBuffer:
  LDX #$00                                            ; $D060: A2 00
@loop:
  LDA player_officer_id_0,X                                    ; $D062: BD AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $D065: 20 D7 F2
  LDA player_army_value_0,X                                   ; $D068: BD B1 04
  LDY #$00                                            ; $D06B: A0 00
  STA (sprite_pos),Y                                  ; $D06D: 91 00
  INX                                                 ; $D06F: E8
  CPX #$02                                            ; $D070: E0 02
  BCC @loop                                           ; $D072: 90 EE
  LDX #$00                                            ; $D074: A2 00
  LDA #$A4                                            ; $D076: A9 A4 (slot base for officer 0)
  STA slot_base                                       ; $D078: 8D 10 00
  LDA player_army_value_0                                     ; $D07B: AD B1 04 (officer 0 position)
  JSR WriteOfficerSpriteEntry                         ; $D07E: 20 89 D0
  LDA #$B2                                            ; $D081: A9 B2 (slot base for officer 1)
  STA slot_base                                       ; $D083: 8D 10 00
  LDA player_army_value_1                                     ; $D086: AD B2 04 (officer 1 position)
; Falls through into WriteOfficerSpriteEntry
WriteOfficerSpriteEntry:
  STA officer_pos                                     ; $D089: 8D 01 00
  LDA #$0A                                            ; $D08C: A9 0A (entry tag marker)
  STA sprite_y_buffer,X                                      ; $D08E: 9D 80 03
  INX                                                 ; $D091: E8
  LDA #$20                                            ; $D092: A9 20
  STA sprite_y_buffer,X                                      ; $D094: 9D 80 03
  INX                                                 ; $D097: E8
  LDA slot_base                                       ; $D098: AD 10 00
  STA sprite_y_buffer,X                                      ; $D09B: 9D 80 03
  INX                                                 ; $D09E: E8
  LDA #$00                                            ; $D09F: A9 00
  STA sprite_pos                                      ; $D0A1: 8D 00 00 (init quotient = 0)
@divmod_loop:
  LDA officer_pos                                     ; $D0A4: AD 01 00
  CMP #$0A                                            ; $D0A7: C9 0A
  BCC @divmod_done                                    ; $D0A9: 90 0C
  SEC                                                 ; $D0AB: 38
  SBC #$0A                                            ; $D0AC: E9 0A
  STA officer_pos                                     ; $D0AE: 8D 01 00 (remainder)
  INC sprite_pos                                      ; $D0B1: EE 00 00 (quotient)
  JMP @divmod_loop                                    ; $D0B4: 4C A4 D0
@divmod_done:
  LDA slot_base                                       ; $D0B7: AD 10 00
  CMP #$A4                                            ; $D0BA: C9 A4 (first officer?)
  BEQ @first_officer                                  ; $D0BC: F0 03
  JMP @second_officer                                 ; $D0BE: 4C FA D0
@first_officer:
  LDY #$00                                            ; $D0C1: A0 00
  LDA #$04                                            ; $D0C3: A9 04 (default fill tile)
@fill_fwd_pre:
  CPY sprite_pos                                      ; $D0C5: CC 00 00
  BEQ @fwd_at_pos                                     ; $D0C8: F0 08
  STA sprite_y_buffer,X                                      ; $D0CA: 9D 80 03
  INX                                                 ; $D0CD: E8
  INY                                                 ; $D0CE: C8
  JMP @fill_fwd_pre                                   ; $D0CF: 4C C5 D0
@fwd_at_pos:
  CPY #$0A                                            ; $D0D2: C0 0A
  BCS @finalize                                       ; $D0D4: B0 61
  LDA officer_pos                                     ; $D0D6: AD 01 00 (remainder)
  BEQ @fill_fwd_post                                  ; $D0D9: F0 10
  CMP #$06                                            ; $D0DB: C9 06
  BCS @fwd_tile_04                                    ; $D0DD: B0 05
  LDA #$05                                            ; $D0DF: A9 05 (tile $05: rem 1-5)
  JMP @fwd_write_tile                                 ; $D0E1: 4C E6 D0
@fwd_tile_04:
  LDA #$04                                            ; $D0E4: A9 04 (tile $04: rem 6-9)
@fwd_write_tile:
  STA sprite_y_buffer,X                                      ; $D0E6: 9D 80 03
  INX                                                 ; $D0E9: E8
  INY                                                 ; $D0EA: C8
@fill_fwd_post:
  CPY #$0A                                            ; $D0EB: C0 0A
  BEQ @done_rts                                       ; $D0ED: F0 0A
  LDA #$06                                            ; $D0EF: A9 06 (tile $06: trailing fill)
  STA sprite_y_buffer,X                                      ; $D0F1: 9D 80 03
  INX                                                 ; $D0F4: E8
  INY                                                 ; $D0F5: C8
  JMP @fill_fwd_post                                  ; $D0F6: 4C EB D0
@done_rts:
  RTS                                                 ; $D0F9: 60
@second_officer:
  TXA                                                 ; $D0FA: 8A
  CLC                                                 ; $D0FB: 18
  ADC #$09                                            ; $D0FC: 69 09 (advance X by 9)
  TAX                                                 ; $D0FE: AA
  LDY #$00                                            ; $D0FF: A0 00
  LDA #$04                                            ; $D101: A9 04 (default fill tile)
@fill_rev_pre:
  CPY sprite_pos                                      ; $D103: CC 00 00
  BEQ @rev_at_pos                                     ; $D106: F0 08
  STA sprite_y_buffer,X                                      ; $D108: 9D 80 03
  DEX                                                 ; $D10B: CA (fill backwards)
  INY                                                 ; $D10C: C8
  JMP @fill_rev_pre                                   ; $D10D: 4C 03 D1
@rev_at_pos:
  CPY #$0A                                            ; $D110: C0 0A
  BCS @finalize                                       ; $D112: B0 23
  LDA officer_pos                                     ; $D114: AD 01 00 (remainder)
  BEQ @fill_rev_post                                  ; $D117: F0 10
  CMP #$06                                            ; $D119: C9 06
  BCS @rev_tile_04                                    ; $D11B: B0 05
  LDA #$07                                            ; $D11D: A9 07 (tile $07: rem 1-5)
  JMP @rev_write_tile                                 ; $D11F: 4C 24 D1
@rev_tile_04:
  LDA #$04                                            ; $D122: A9 04 (tile $04: rem 6-9)
@rev_write_tile:
  STA sprite_y_buffer,X                                      ; $D124: 9D 80 03
  DEX                                                 ; $D127: CA
  INY                                                 ; $D128: C8
@fill_rev_post:
  CPY #$0A                                            ; $D129: C0 0A
  BEQ @finalize                                       ; $D12B: F0 0A
  LDA #$06                                            ; $D12D: A9 06 (tile $06: trailing fill)
  STA sprite_y_buffer,X                                      ; $D12F: 9D 80 03
  DEX                                                 ; $D132: CA
  INY                                                 ; $D133: C8
  JMP @fill_rev_post                                  ; $D134: 4C 29 D1
@finalize:
  TXA                                                 ; $D137: 8A
  CLC                                                 ; $D138: 18
  ADC #$0B                                            ; $D139: 69 0B (advance X by 11)
  TAX                                                 ; $D13B: AA
  RTS                                                 ; $D13C: 60
.endproc
;===============================================================================
; $D13D: ReadMenuSelection
;===============================================================================
.proc ReadMenuSelection
  param_byte1     = $0000
  param_byte2     = $0001
  ppu_addr_hi     = $0001
  tile_attr_byte      = $0002
  overlay_data_ptr          = $000A
  scene_coord_ptr     = $000C
ReadMenuSelection:
  INC menu_blink_timer                                           ; $D13D: EE 6C 04
  LDA menu_blink_timer                                           ; $D140: AD 6C 04
  AND #$10                                            ; $D143: 29 10
  BEQ @skip                                           ; $D145: F0 02
  LDA #$20                                            ; $D147: A9 20
@skip:
  STA ptr_lo                                         ; $D149: 8D 0A 00
  LDA #$00                                            ; $D14C: A9 00
  STA rle_marker                                         ; $D14E: 8D 02 00
  STA attr_ptr_lo                                         ; $D151: 8D 0C 00
  LDA #$61                                            ; $D154: A9 61
  STA param_byte1                                         ; $D156: 8D 00 00
  LDA #$D1                                            ; $D159: A9 D1
  STA param_byte2                                         ; $D15B: 8D 01 00
  JMP B1F_SpriteOamWriterSimple                       ; $D15E: 4C AD F1
.endproc
MenuCursorSpriteData:
  .byte $D9,$04,$00,$7C,$80                           ; $D161: D9 04 00 7C 80
;===============================================================================
; $D166: SetupMenuPtr
;===============================================================================
.proc SetupMenuPtr
  param_byte1     = $0000
  overlay_data_ptr          = $000A
SetupMenuPtr:
  LDA #$A5                                            ; $D166: A9 A5
  STA ptr_lo                                         ; $D168: 8D 0A 00
  LDY active_player_slot                                           ; $D16B: AC AA 04
  LDA player_officer_id_0,Y                                         ; $D16E: B9 AD 04
  STA param_byte1                                         ; $D171: 8D 00 00
  LDY #$39                                            ; $D174: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $D176: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                                         ; $D179: 00 A0
  RTS                                                 ; $D17B: 60
.endproc
;===============================================================================
; $D17C: TroopAssign_NextState
; Init $0380 buffer from defaults, then compute display tiles for 4 officer stats.
; Officer_ptr_lo/hi ($0000/$0001) = 16-bit pointer to officer record (set by SetupMenuPtr).
;===============================================================================
.proc TroopAssign_NextState
  officer_ptr_lo  = $0000
  officer_ptr_hi  = $0001
  ones_tile       = $0000
  stat_value      = $0001
  tile_attr_byte  = $0002
  tile_count_hi   = $0003
  row_count       = $0007
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  slot_buf_lo     = sprite_y_buffer
  slot_buf_hi     = sprite_y_buffer + 1
TroopAssign_NextState:
  LDY #$40                                            ; $D17C: A0 40
@init_loop:
  LDA slot_defaults,Y                                  ; $D17E: B9 F4 D1
  STA slot_buf_lo,Y                                    ; $D181: 99 80 03
  DEY                                                 ; $D184: 88
  BPL @init_loop                                      ; $D185: 10 F7
  LDY active_player_slot                                      ; $D187: AC AA 04
  LDA player_officer_id_0,Y                                    ; $D18A: B9 AD 04
  JSR B1F_GetOfficerRecordAddr                        ; $D18D: 20 D7 F2
  LDA officer_ptr_lo                                    ; $D190: AD 00 00
  STA ptr_0010_lo                                     ; $D193: 8D 10 00
  LDA officer_ptr_hi                                    ; $D196: AD 01 00
  STA ptr_0010_hi                                     ; $D199: 8D 11 00
  LDY #$00                                            ; $D19C: A0 00
  LDX #$0E                                            ; $D19E: A2 0E
@process_stat:                                        ; read stat byte, convert to BCD tiles
  LDA #$00                                            ; $D1A0: A9 00
  STA tile_attr_byte                                  ; $D1A2: 8D 02 00
  STA tile_count_hi                                   ; $D1A5: 8D 03 00
  LDA (ptr_0010_lo),Y                                 ; $D1A8: B1 10
  CMP #$64                                            ; $D1AA: C9 64
  BEQ @stat_is_100                                    ; $D1AC: F0 25
  STA stat_value                                      ; $D1AE: 8D 01 00
  JSR B1F_MathBinToBcd                                ; $D1B1: 20 BA E9
  LDA row_count                                       ; $D1B4: AD 07 00
  AND #$0F                                            ; $D1B7: 29 0F      ; ones digit tile
  CLC                                                 ; $D1B9: 18
  ADC #$76                                            ; $D1BA: 69 76
  STA ones_tile                                       ; $D1BC: 8D 00 00
  LDA row_count                                       ; $D1BF: AD 07 00
  LSR A                                               ; $D1C2: 4A
  LSR A                                               ; $D1C3: 4A
  LSR A                                               ; $D1C4: 4A
  LSR A                                               ; $D1C5: 4A      ; tens digit tile
  BNE @has_tens                                       ; $D1C6: D0 05
  LDA #$01                                            ; $D1C8: A9 01    ; suppress leading zero
  JMP @store_slot                                     ; $D1CA: 4C D8 D1
@has_tens:
  CLC                                                 ; $D1CD: 18
  ADC #$76                                            ; $D1CE: 69 76
  JMP @store_slot                                     ; $D1D0: 4C D8 D1
@stat_is_100:                                         ; display "--" for max stat
  LDA #$32                                            ; $D1D3: A9 32
  STA ones_tile                                       ; $D1D5: 8D 00 00
@store_slot:                                          ; write tile pair into slot buffer
  STA slot_buf_lo,X                                   ; $D1D8: 9D 80 03
  LDA ones_tile                                       ; $D1DB: AD 00 00
  STA slot_buf_hi,X                                   ; $D1DE: 9D 81 03
  TXA                                                 ; $D1E1: 8A
  CLC                                                 ; $D1E2: 18
  ADC #$10                                            ; $D1E3: 69 10    ; advance 16 bytes per slot
  TAX                                                 ; $D1E5: AA
  INY                                                 ; $D1E6: C8
  CPY #$04                                            ; $D1E7: C0 04
  BCC @process_stat                                   ; $D1E9: 90 B5    ; loop for 4 stats
  LDA a:$007E                                         ; $D1EB: AD 7E 00
  ORA #$04                                            ; $D1EE: 09 04    ; flag scene redraw
  STA a:$007E                                         ; $D1F0: 8D 7E 00
  RTS                                                 ; $D1F3: 60
slot_defaults:                                        ; 4x 16-byte default slot entries + terminator
  .byte $05,$22,$89,$80,$81,$01,$01,$01,$05,$22,$A9,$90,$91,$01,$01,$01; $D1F4
  .byte $05,$22,$C9,$84,$85,$01,$01,$01,$05,$22,$E9,$94,$95,$01,$01,$01; $D204
  .byte $05,$23,$09,$82,$83,$01,$01,$01,$05,$23,$29,$92,$93,$01,$01,$01; $D214
  .byte $05,$23,$49,$88,$89,$01,$01,$01,$05,$23,$69,$98,$99,$01,$01,$01; $D224
  .byte $FF                                           ; $D234
.endproc
;===============================================================================
; $D235: DrawCompletionSprite
;
; Draw a map-scroll completion sprite at a fixed screen position.
; Temporarily overrides $04BA/$04BB with fixed X/Y coordinates, calls
; DrawSpriteFromBank, then restores the original values.
;
; Input (set by caller before JMP):
;   $0010  = sprite data index (bit 7 selects PRG bank $34/$35)
;   $04AA  = active player slot (0 or 1, selects Y coordinate)
;
; Side effects:
;   $0002  = set to $03 (H+V flip flags for OAM writer)
;   $04BA  = temporarily set to $57 (sprite X position)
;   $04BB  = temporarily set to $B8 (player 0) or $38 (player 1)
;===============================================================================
.proc DrawCompletionSprite
  sprite_flip_flags = $0002                               ; Flip flags for OAM writer ($03 = H+V)
  sprite_index      = $0010                               ; Sprite data index (input from caller)
  SPRITE_X_POS      = $57                                 ; Fixed X coordinate for completion sprite
  SPRITE_Y_P0       = $B8                                 ; Y coordinate for player 0 (bottom viewport)
  SPRITE_Y_P1       = $38                                 ; Y coordinate for player 1 (top viewport)
  FLIP_HV           = $03                                 ; Horizontal + vertical flip
DrawCompletionSprite:
  ;--- Save current sprite position values ---
  LDA scroll_row_count                                           ; $D235: AD BA 04
  PHA                                                 ; $D238: 48
  LDA slide_y_pos                                           ; $D239: AD BB 04
  PHA                                                 ; $D23C: 48
  ;--- Override with fixed completion sprite coordinates ---
  LDA #SPRITE_X_POS                                       ; $D23D: A9 57  (X position)
  STA scroll_row_count                                           ; $D23F: 8D BA 04
  LDX #SPRITE_Y_P1                                       ; $D242: A2 38  (default: player 1 Y)
  LDA active_player_slot                                           ; $D244: AD AA 04
  BNE @skip                                           ; $D247: D0 02
  LDX #SPRITE_Y_P0                                       ; $D249: A2 B8  (player 0 Y)
@skip:
  STX slide_y_pos                                           ; $D24B: 8E BB 04
  ;--- Set flip flags and draw the completion sprite ---
  LDA #FLIP_HV                                           ; $D24E: A9 03  (H+V flip)
  STA sprite_flip_flags                                         ; $D250: 8D 02 00
  LDA sprite_index                                         ; $D253: AD 10 00
  JSR DrawSpriteFromBank                                           ; $D256: 20 A5 CE
  ;--- Restore original sprite position values ---
  PLA                                                 ; $D259: 68
  STA slide_y_pos                                           ; $D25A: 8D BB 04
  PLA                                                 ; $D25D: 68
  STA scroll_row_count                                           ; $D25E: 8D BA 04
  RTS                                                 ; $D261: 60
.endproc
;===============================================================================
; $D262: CheckPlayerIsRuler
;===============================================================================
.proc CheckPlayerIsRuler
  param_byte1     = $0000
  work_0010       = $0010
CheckPlayerIsRuler:
  LDY active_player_slot                                           ; $D262: AC AA 04
  LDA player_officer_id_0,Y                                         ; $D265: B9 AD 04
  STA work_0010                                         ; $D268: 8D 10 00
  LDX #$00                                            ; $D26B: A2 00
@loop:
  TXA                                                 ; $D26D: 8A
  JSR B1F_GetRulerDataPtr                             ; $D26E: 20 68 F3
  LDY #$00                                            ; $D271: A0 00
  LDA (param_byte1),Y                                         ; $D273: B1 00
  CMP work_0010                                         ; $D275: CD 10 00
  BEQ @skip                                           ; $D278: F0 07
  INX                                                 ; $D27A: E8
  CPX #$07                                            ; $D27B: E0 07
  BCC @loop                                           ; $D27D: 90 EE
  CLC                                                 ; $D27F: 18
  RTS                                                 ; $D280: 60
@skip:
  SEC                                                 ; $D281: 38
  RTS                                                 ; $D282: 60
.endproc
;===============================================================================
; $D283: SetDisplayPointer
;===============================================================================
.proc SetDisplayPointer
SetDisplayPointer:
  STA display_queue_ptr_hi                                           ; $D283: 8D 11 03
  LDA #$20                                            ; $D286: A9 20
  STA display_queue_ptr_lo                                           ; $D288: 8D 10 03
  LDA #$FF                                            ; $D28B: A9 FF
  STA display_queue_end_lo                                           ; $D28D: 8D 12 03
  STA display_queue_end_hi                                           ; $D290: 8D 13 03
  LDA #$00                                            ; $D293: A9 00
  STA confirm_check_0                                           ; $D295: 8D 00 03
  RTS                                                 ; $D298: 60
.endproc
;===============================================================================
; $D299: CheckButtonConfirm
;===============================================================================
.proc CheckButtonConfirm
CheckButtonConfirm:
  LDA confirm_check_1                                           ; $D299: AD 04 03
  CMP #$FF                                            ; $D29C: C9 FF
  BNE @skip                                           ; $D29E: D0 09
  LDA confirm_check_0                                           ; $D2A0: AD 00 03
  CMP #$FF                                            ; $D2A3: C9 FF
  BNE @skip                                           ; $D2A5: D0 02
  SEC                                                 ; $D2A7: 38
  RTS                                                 ; $D2A8: 60
@skip:
  CLC                                                 ; $D2A9: 18
  RTS                                                 ; $D2AA: 60
.endproc

;===============================================================================
; $D2AB: MapColumnTileGfx
; Tile graphics data for vertical map columns (25 entries × 40 bytes).
; Each entry encodes 5 tiles × 8 bytes for a vertical column strip.
; Indexed by BuildPPUTileBuffer: source = MapColumnTileGfx + index * 40.
; Entry 0 = blank column; entries 1-24 = map/UI tile patterns.
;===============================================================================
MapColumnTileGfx:
; Entry  0 ($D2AB)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D2AB: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D2B3: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D2BB: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D2C3: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D2CB: 00 00 00 00 00 00 00 00

; Entry  1 ($D2D3)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D2D3: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$05,$06        ; $D2DB: 00 00 00 00 00 00 05 06
  .byte $00,$00,$00,$07,$08,$09,$0A,$04        ; $D2E3: 00 00 00 07 08 09 0A 04
  .byte $00,$00,$0B,$0C,$0D,$0E,$0F,$00        ; $D2EB: 00 00 0B 0C 0D 0E 0F 00
  .byte $00,$10,$11,$12,$13,$14,$15,$16        ; $D2F3: 00 10 11 12 13 14 15 16

; Entry  2 ($D2FB)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D2FB: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$34,$35        ; $D303: 00 00 00 00 00 00 34 35
  .byte $00,$00,$00,$07,$08,$36,$37,$38        ; $D30B: 00 00 00 07 08 36 37 38
  .byte $00,$00,$0B,$0C,$0D,$0E,$0F,$00        ; $D313: 00 00 0B 0C 0D 0E 0F 00
  .byte $00,$10,$11,$12,$13,$14,$15,$16        ; $D31B: 00 10 11 12 13 14 15 16

; Entry  3 ($D323)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D323: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D32B: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$07,$39,$3A,$3B,$00        ; $D333: 00 00 00 07 39 3A 3B 00
  .byte $00,$00,$0B,$0C,$3C,$3D,$0F,$00        ; $D33B: 00 00 0B 0C 3C 3D 0F 00
  .byte $00,$00,$3E,$12,$13,$14,$15,$16        ; $D343: 00 00 3E 12 13 14 15 16

; Entry  4 ($D34B)
  .byte $17,$18,$19,$1A,$1B,$1C,$1D,$1E        ; $D34B: 17 18 19 1A 1B 1C 1D 1E
  .byte $1F,$20,$21,$22,$23,$24,$25,$00        ; $D353: 1F 20 21 22 23 24 25 00
  .byte $26,$27,$28,$29,$2A,$2B,$00,$00        ; $D35B: 26 27 28 29 2A 2B 00 00
  .byte $2C,$2D,$00,$00,$2E,$2F,$00,$00        ; $D363: 2C 2D 00 00 2E 2F 00 00
  .byte $30,$31,$00,$00,$32,$33,$00,$00        ; $D36B: 30 31 00 00 32 33 00 00

; Entry  5 ($D373)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D373: 00 00 00 00 00 00 00 00
  .byte $71,$72,$00,$00,$00,$00,$00,$00        ; $D37B: 71 72 00 00 00 00 00 00
  .byte $70,$73,$74,$45,$46,$00,$00,$00        ; $D383: 70 73 74 45 46 00 00 00
  .byte $00,$47,$48,$49,$4A,$4B,$00,$00        ; $D38B: 00 47 48 49 4A 4B 00 00
  .byte $4C,$4D,$4E,$4F,$50,$51,$52,$00        ; $D393: 4C 4D 4E 4F 50 51 52 00

; Entry  6 ($D39B)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D39B: 00 00 00 00 00 00 00 00
  .byte $40,$41,$00,$00,$00,$00,$00,$00        ; $D3A3: 40 41 00 00 00 00 00 00
  .byte $42,$43,$44,$45,$46,$00,$00,$00        ; $D3AB: 42 43 44 45 46 00 00 00
  .byte $00,$47,$48,$49,$4A,$4B,$00,$00        ; $D3B3: 00 47 48 49 4A 4B 00 00
  .byte $4C,$4D,$4E,$4F,$50,$51,$52,$00        ; $D3BB: 4C 4D 4E 4F 50 51 52 00

; Entry  7 ($D3C3)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D3C3: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D3CB: 00 00 00 00 00 00 00 00
  .byte $00,$75,$76,$77,$46,$00,$00,$00        ; $D3D3: 00 75 76 77 46 00 00 00
  .byte $00,$47,$78,$79,$4A,$4B,$00,$00        ; $D3DB: 00 47 78 79 4A 4B 00 00
  .byte $4C,$4D,$4E,$4F,$50,$7A,$00,$00        ; $D3E3: 4C 4D 4E 4F 50 7A 00 00

; Entry  8 ($D3EB)
  .byte $53,$54,$55,$56,$57,$58,$59,$5A        ; $D3EB: 53 54 55 56 57 58 59 5A
  .byte $00,$5B,$5C,$5D,$5E,$5F,$60,$61        ; $D3F3: 00 5B 5C 5D 5E 5F 60 61
  .byte $00,$00,$62,$63,$64,$65,$66,$67        ; $D3FB: 00 00 62 63 64 65 66 67
  .byte $00,$00,$68,$69,$00,$00,$6A,$6B        ; $D403: 00 00 68 69 00 00 6A 6B
  .byte $00,$00,$6C,$6D,$00,$00,$6E,$6F        ; $D40B: 00 00 6C 6D 00 00 6E 6F

; Entry  9 ($D413)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D413: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$00        ; $D41B: 00 00 00 00 00 00 98 00
  .byte $00,$00,$00,$00,$99,$9A,$9B,$00        ; $D423: 00 00 00 00 99 9A 9B 00
  .byte $00,$00,$00,$00,$9C,$9D,$9E,$9F        ; $D42B: 00 00 00 00 9C 9D 9E 9F
  .byte $00,$00,$00,$00,$A0,$A1,$00,$00        ; $D433: 00 00 00 00 A0 A1 00 00

; Entry 10 ($D43B)
  .byte $A2,$A3,$A4,$00,$00,$A5,$00,$00        ; $D43B: A2 A3 A4 00 00 A5 00 00
  .byte $A6,$A7,$A8,$A9,$AA,$00,$00,$00        ; $D443: A6 A7 A8 A9 AA 00 00 00
  .byte $AB,$AC,$AD,$AE,$00,$00,$00,$00        ; $D44B: AB AC AD AE 00 00 00 00
  .byte $AF,$B0,$B1,$00,$00,$00,$00,$00        ; $D453: AF B0 B1 00 00 00 00 00
  .byte $B2,$00,$B3,$B4,$00,$00,$00,$00        ; $D45B: B2 00 B3 B4 00 00 00 00

; Entry 11 ($D463)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D463: 00 00 00 00 00 00 00 00
  .byte $00,$7B,$00,$00,$00,$00,$00,$00        ; $D46B: 00 7B 00 00 00 00 00 00
  .byte $00,$7C,$7D,$7E,$00,$00,$00,$00        ; $D473: 00 7C 7D 7E 00 00 00 00
  .byte $7F,$80,$81,$82,$00,$00,$00,$00        ; $D47B: 7F 80 81 82 00 00 00 00
  .byte $00,$00,$83,$84,$00,$00,$00,$00        ; $D483: 00 00 83 84 00 00 00 00

; Entry 12 ($D48B)
  .byte $00,$00,$85,$00,$00,$86,$87,$88        ; $D48B: 00 00 85 00 00 86 87 88
  .byte $00,$00,$00,$89,$8A,$8B,$8C,$8D        ; $D493: 00 00 00 89 8A 8B 8C 8D
  .byte $00,$00,$00,$00,$8E,$8F,$90,$91        ; $D49B: 00 00 00 00 8E 8F 90 91
  .byte $00,$00,$00,$00,$00,$92,$93,$94        ; $D4A3: 00 00 00 00 00 92 93 94
  .byte $00,$00,$00,$00,$95,$96,$00,$97        ; $D4AB: 00 00 00 00 95 96 00 97

; Entry 13 ($D4B3)
  .byte $A6,$A7,$00,$00,$00,$00,$00,$00        ; $D4B3: A6 A7 00 00 00 00 00 00
  .byte $00,$A8,$A9,$00,$00,$00,$00,$00        ; $D4BB: 00 A8 A9 00 00 00 00 00
  .byte $00,$00,$AA,$AB,$00,$00,$00,$00        ; $D4C3: 00 00 AA AB 00 00 00 00
  .byte $00,$00,$AC,$AD,$AE,$85,$0F,$00        ; $D4CB: 00 00 AC AD AE 85 0F 00
  .byte $00,$00,$AF,$B0,$B1,$B2,$15,$16        ; $D4D3: 00 00 AF B0 B1 B2 15 16

; Entry 14 ($D4DB)
  .byte $B3,$B4,$B5,$00,$00,$00,$00,$00        ; $D4DB: B3 B4 B5 00 00 00 00 00
  .byte $00,$B6,$B7,$00,$00,$00,$00,$00        ; $D4E3: 00 B6 B7 00 00 00 00 00
  .byte $00,$00,$AA,$AB,$00,$00,$00,$00        ; $D4EB: 00 00 AA AB 00 00 00 00
  .byte $00,$00,$AC,$AD,$AE,$85,$0F,$00        ; $D4F3: 00 00 AC AD AE 85 0F 00
  .byte $00,$00,$AF,$B0,$B1,$B2,$15,$16        ; $D4FB: 00 00 AF B0 B1 B2 15 16

; Entry 15 ($D503)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D503: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$B8,$00,$00,$00,$00        ; $D50B: 00 00 00 B8 00 00 00 00
  .byte $00,$00,$BA,$C0,$C1,$C2,$C3,$C4        ; $D513: 00 00 BA C0 C1 C2 C3 C4
  .byte $00,$00,$C5,$AD,$C6,$85,$0F,$00        ; $D51B: 00 00 C5 AD C6 85 0F 00
  .byte $00,$00,$C7,$B0,$C8,$B9,$15,$16        ; $D523: 00 00 C7 B0 C8 B9 15 16

; Entry 16 ($D52B)
  .byte $00,$00,$00,$00,$00,$00,$C9,$CA        ; $D52B: 00 00 00 00 00 00 C9 CA
  .byte $00,$00,$00,$00,$00,$CB,$CC,$00        ; $D533: 00 00 00 00 00 CB CC 00
  .byte $00,$00,$00,$00,$CD,$CE,$00,$00        ; $D53B: 00 00 00 00 CD CE 00 00
  .byte $00,$47,$CF,$D0,$D1,$D2,$00,$00        ; $D543: 00 47 CF D0 D1 D2 00 00
  .byte $4C,$4D,$D3,$D4,$D5,$D6,$00,$00        ; $D54B: 4C 4D D3 D4 D5 D6 00 00

; Entry 17 ($D553)
  .byte $00,$00,$00,$00,$00,$D7,$D8,$00        ; $D553: 00 00 00 00 00 D7 D8 00
  .byte $00,$00,$00,$00,$00,$D9,$DA,$00        ; $D55B: 00 00 00 00 00 D9 DA 00
  .byte $00,$00,$00,$00,$CD,$CE,$00,$00        ; $D563: 00 00 00 00 CD CE 00 00
  .byte $00,$47,$CF,$D0,$D1,$D2,$00,$00        ; $D56B: 00 47 CF D0 D1 D2 00 00
  .byte $4C,$4D,$D3,$D4,$D5,$D6,$00,$00        ; $D573: 4C 4D D3 D4 D5 D6 00 00

; Entry 18 ($D57B)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D57B: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$DC,$00,$00,$00        ; $D583: 00 00 00 00 DC 00 00 00
  .byte $DD,$DE,$DF,$E0,$E1,$E2,$00,$00        ; $D58B: DD DE DF E0 E1 E2 00 00
  .byte $00,$47,$CF,$E3,$D1,$E4,$00,$00        ; $D593: 00 47 CF E3 D1 E4 00 00
  .byte $4C,$4D,$DB,$E5,$D5,$E6,$00,$00        ; $D59B: 4C 4D DB E5 D5 E6 00 00

; Entry 19 ($D5A3)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D5A3: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D5AB: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D5B3: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$A7,$0F,$00        ; $D5BB: 00 00 00 00 00 A7 0F 00
  .byte $00,$00,$00,$00,$00,$14,$15,$16        ; $D5C3: 00 00 00 00 00 14 15 16

; Entry 20 ($D5CB)
  .byte $17,$18,$19,$00,$00,$1C,$1D,$1E        ; $D5CB: 17 18 19 00 00 1C 1D 1E
  .byte $1F,$20,$21,$22,$23,$24,$25,$00        ; $D5D3: 1F 20 21 22 23 24 25 00
  .byte $26,$27,$28,$29,$2A,$2B,$00,$00        ; $D5DB: 26 27 28 29 2A 2B 00 00
  .byte $2C,$2D,$00,$00,$2E,$2F,$00,$00        ; $D5E3: 2C 2D 00 00 2E 2F 00 00
  .byte $30,$31,$00,$00,$32,$33,$00,$00        ; $D5EB: 30 31 00 00 32 33 00 00

; Entry 21 ($D5F3)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D5F3: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D5FB: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D603: 00 00 00 00 00 00 00 00
  .byte $00,$47,$A8,$00,$00,$00,$00,$00        ; $D60B: 00 47 A8 00 00 00 00 00
  .byte $4C,$4D,$4E,$00,$00,$00,$00,$00        ; $D613: 4C 4D 4E 00 00 00 00 00

; Entry 22 ($D61B)
  .byte $53,$54,$55,$00,$00,$58,$59,$5A        ; $D61B: 53 54 55 00 00 58 59 5A
  .byte $00,$5B,$5C,$5D,$5E,$5F,$60,$61        ; $D623: 00 5B 5C 5D 5E 5F 60 61
  .byte $00,$00,$62,$63,$64,$65,$66,$67        ; $D62B: 00 00 62 63 64 65 66 67
  .byte $00,$00,$68,$69,$00,$00,$6A,$6B        ; $D633: 00 00 68 69 00 00 6A 6B
  .byte $00,$00,$6C,$6D,$00,$00,$6E,$6F        ; $D63B: 00 00 6C 6D 00 00 6E 6F

; Entry 23 ($D643)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D643: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D64B: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D653: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$3F,$0F,$00        ; $D65B: 00 00 00 00 00 3F 0F 00
  .byte $00,$00,$00,$00,$00,$14,$15,$16        ; $D663: 00 00 00 00 00 14 15 16

; Entry 24 ($D66B)
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D66B: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D673: 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00        ; $D67B: 00 00 00 00 00 00 00 00
  .byte $00,$47,$48,$00,$00,$00,$00,$00        ; $D683: 00 47 48 00 00 00 00 00
  .byte $4C,$4D,$4E,$00,$00,$00,$00,$00        ; $D68B: 4C 4D 4E 00 00 00 00 00

;--- $D693: Domestic Action System ---

;===============================================================================
; $D693: DomesticActionDispatch
; Entry0A: Domestic action dispatch (6-entry dispatch table)
;===============================================================================
; Target0A ($D693):
.proc DomesticActionDispatch
DomesticActionDispatch:
  LDY #$26                                            ; $D693: A0 26
  JSR B1F_SwitchBank8_B                               ; $D695: 20 5F F2
  LDA dom_scroll_param                                           ; $D698: AD 41 05
  JSR B1F_CallbackDispatcher                          ; $D69B: 20 DE EA

;===============================================================================
; $D69E: DomesticAction dispatch table
; --- Inline pointer table (6 entries) ---
  .word DomAction_InitOfficerScroll                                         ; $D69E: AA D6
  .word DomAction_ScrollIntroPanel                                          ; $D6A0: 9B D7
  .word DomAction_ScrollTextPhase2                                         ; $D6A2: 3A D8
  .word DomAction_ScrollAndWait                                         ; $D6A4: C9 D8
  .word DomAction_MainInteractive                                         ; $D6A6: CA D9
  .word DomAction_FinalizeCleanup                                         ; $D6A8: 20 D9
.endproc
;===============================================================================
; $D6AA: DomAction_InitOfficerScroll
; Domestic action state 0: Initialize officer list and scroll display
;===============================================================================
.proc DomAction_InitOfficerScroll
  work_offset     = $0402
DomAction_InitOfficerScroll:
  LDA dispatch_src_ptr_lo                                           ; $D6AA: AD CA 04
  BNE @skip_2                                           ; $D6AD: D0 25
  LDA #$00                                            ; $D6AF: A9 00
  STA dispatch_dst_ptr_lo                                           ; $D6B1: 8D CD 04
  STA dispatch_dst_ptr_hi                                           ; $D6B4: 8D CE 04
  INC dispatch_src_ptr_lo                                           ; $D6B7: EE CA 04
  LDA #$FF                                            ; $D6BA: A9 FF
  STA dispatch_src_ptr_hi                                           ; $D6BC: 8D CB 04
  JSR @init_palette                                           ; $D6BF: 20 6D D7
  LDA #$D9                                            ; $D6C2: A9 D9
  LDX battle_result_phase                                           ; $D6C4: AE 2E 04
  CPX #$FF                                            ; $D6C7: E0 FF
  BEQ @skip                                           ; $D6C9: F0 02
  LDA #$D8                                            ; $D6CB: A9 D8
@skip:
  JSR B1F_SetUI4                                      ; $D6CD: 20 8B F2
  JSR B1F_PaletteFadeInit                             ; $D6D0: 20 BF EC
  RTS                                                 ; $D6D3: 60
@skip_2:
  INC dispatch_dst_ptr_lo                                           ; $D6D4: EE CD 04
  LDA #$7E                                            ; $D6D7: A9 7E
  STA $10                                             ; $D6D9: 85 10
  LDA #$9A                                            ; $D6DB: A9 9A
  STA $11                                             ; $D6DD: 85 11
  LDY dispatch_src_ptr_hi                                           ; $D6DF: AC CB 04
  BMI @skip_3                                           ; $D6E2: 30 03
  JSR RenderDispatchSprite                              ; $D6E4: 20 F3 DB
@skip_3:
  LDY dispatch_src_ptr_lo                                           ; $D6E7: AC CA 04
  JSR RenderDispatchSprite                              ; $D6EA: 20 F3 DB
  LDA dispatch_src_ptr_lo                                           ; $D6ED: AD CA 04
  CLC                                                 ; $D6F0: 18
  ADC #$04                                            ; $D6F1: 69 04
  TAY                                                 ; $D6F3: A8
  JSR RenderDispatchSprite                              ; $D6F4: 20 F3 DB
  LDA dispatch_dst_ptr_lo                                           ; $D6F7: AD CD 04
  LSR A                                               ; $D6FA: 4A
  LSR A                                               ; $D6FB: 4A
  LSR A                                               ; $D6FC: 4A
  AND #$03                                            ; $D6FD: 29 03
  CLC                                                 ; $D6FF: 18
  ADC #$01                                            ; $D700: 69 01
  STA dispatch_src_ptr_lo                                           ; $D702: 8D CA 04
  LDA dispatch_src_ptr_hi                                           ; $D705: AD CB 04
  CMP #$FE                                            ; $D708: C9 FE
  BEQ @skip_5                                           ; $D70A: F0 1E
  LDA confirm_check_0                                           ; $D70C: AD 00 03
  CMP #$FF                                            ; $D70F: C9 FF
  BNE @skip_4                                           ; $D711: D0 16
  LDA confirm_check_1                                           ; $D713: AD 04 03
  CMP #$FF                                            ; $D716: C9 FF
  BNE @skip_4                                           ; $D718: D0 0F
  INC dispatch_dst_ptr_hi                                           ; $D71A: EE CE 04
  LDA dispatch_dst_ptr_hi                                           ; $D71D: AD CE 04
  LSR A                                               ; $D720: 4A
  LSR A                                               ; $D721: 4A
  TAY                                                 ; $D722: A8
  LDA DispatchBankTable,Y                                         ; $D723: B9 55 D7
  STA dispatch_src_ptr_hi                                           ; $D726: 8D CB 04
@skip_4:
  RTS                                                 ; $D729: 60
@skip_5:
  LDA a:$0081                                         ; $D72A: AD 81 00
  AND #$01                                            ; $D72D: 29 01
  BEQ @skip_6                                           ; $D72F: F0 20
  LDA sram_scroll_pending                                           ; $D731: AD 43 6F
  BEQ @skip_7                                           ; $D734: F0 1C
  LDA #$00                                            ; $D736: A9 00
  STA sram_scroll_pending                                           ; $D738: 8D 43 6F
  LDA map_scroll_ptr_lo                                           ; $D73B: AD 72 04
  STA domestic_work_ptr_lo                                           ; $D73E: 8D 00 04
  LDA map_scroll_ptr_hi                                           ; $D741: AD 73 04
  STA domestic_work_ptr_hi                                           ; $D744: 8D 01 04
  LDA #$00                                            ; $D747: A9 00
  STA work_offset                                           ; $D749: 8D 02 04
  LDA #$01                                            ; $D74C: A9 01
  STA a:$007A                                         ; $D74E: 8D 7A 00
@skip_6:
  RTS                                                 ; $D751: 60
@skip_7:
  JMP $E000                                           ; $D752: 4C 00 E0
DispatchBankTable:
  .byte $09,$0A,$0B,$0C,$F0,$F0,$F0,$0D,$0E,$0F,$10,$11,$12,$13,$13,$14; $D755: Dispatch bank lookup (index → PRG bank)
  .byte $14,$15,$15,$14,$14,$13,$13,$FE               ; $D765: 14 15 15 14 14 13 13 FE
@init_palette:
  LDY #$00                                            ; $D76D: A0 00
@copy_loop:
  LDA OfficerScrollPalette,Y                                         ; $D76F: B9 7B D7
  STA $0100,Y                                         ; $D772: 99 00 01
  INY                                                 ; $D775: C8
  CPY #$20                                            ; $D776: C0 20
  BCC @copy_loop                                           ; $D778: 90 F5
  RTS                                                 ; $D77A: 60
OfficerScrollPalette:
  .byte $0F,$30,$10,$00,$0F,$27,$16,$2A,$0F,$36,$30,$16,$0F,$30,$10,$00; $D77B: Officer scroll palette data
  .byte $0F,$30,$10,$00,$0F,$0F,$1B,$28,$0F,$36,$30,$16,$0F,$20,$27,$17; $D78B
.endproc
;===============================================================================
; $D79B: DomAction_ScrollIntroPanel
; Domestic action state 1: Scroll intro panel with fade transition
;===============================================================================
.proc DomAction_ScrollIntroPanel
  temp_006a       = $006A
  ptr_006c_lo     = $006C
  ptr_006c_hi     = $006D
DomAction_ScrollIntroPanel:
  LDA dispatch_src_ptr_lo                                           ; $D79B: AD CA 04
  BNE @skip_3                                           ; $D79E: D0 37
  LDA dispatch_step                                           ; $D7A0: AD C9 04
  BNE @skip                                           ; $D7A3: D0 12
  LDA #$A0                                            ; $D7A5: A9 A0
  STA temp_006a                                         ; $D7A7: 8D 6A 00
  LDA #$F8                                            ; $D7AA: A9 F8
  STA ptr_006c_lo                                         ; $D7AC: 8D 6C 00
  LDA #$F1                                            ; $D7AF: A9 F1
  STA ptr_006c_hi                                         ; $D7B1: 8D 6D 00
  JSR ScrollPanel_PrepareRowData                                   ; $D7B4: 20 E1 DC
@skip:
  JSR ScrollPanel_LoadRow                                           ; $D7B7: 20 13 DC
  LDA dispatch_step                                           ; $D7BA: AD C9 04
  CMP #$10                                            ; $D7BD: C9 10
  BCC @skip_2                                           ; $D7BF: 90 15
  LDA #$00                                            ; $D7C1: A9 00
  STA dispatch_dst_ptr_lo                                           ; $D7C3: 8D CD 04
  STA dispatch_dst_ptr_hi                                           ; $D7C6: 8D CE 04
  LDA #$02                                            ; $D7C9: A9 02
  STA dispatch_src_ptr_lo                                           ; $D7CB: 8D CA 04
  LDA #$DC                                            ; $D7CE: A9 DC
  JSR B1F_SetUI4                                      ; $D7D0: 20 8B F2
  JSR B1F_PaletteFadeInit                             ; $D7D3: 20 BF EC
@skip_2:
  RTS                                                 ; $D7D6: 60
@skip_3:
  LDA dispatch_step                                           ; $D7D7: AD C9 04
  BPL @skip_4                                           ; $D7DA: 10 03
  JMP @skip_7                                           ; $D7DC: 4C 15 D8
@skip_4:
  INC dispatch_dst_ptr_lo                                           ; $D7DF: EE CD 04
  BNE @skip_5                                           ; $D7E2: D0 03
  INC dispatch_dst_ptr_hi                                           ; $D7E4: EE CE 04
@skip_5:
  LDA #$D9                                            ; $D7E7: A9 D9
  STA $10                                             ; $D7E9: 85 10
  LDA #$9C                                            ; $D7EB: A9 9C
  STA $11                                             ; $D7ED: 85 11
  LDY dispatch_src_ptr_lo                                           ; $D7EF: AC CA 04
  JSR RenderDispatchSprite                              ; $D7F2: 20 F3 DB
  LDA dispatch_dst_ptr_lo                                           ; $D7F5: AD CD 04
  LSR A                                               ; $D7F8: 4A
  LSR A                                               ; $D7F9: 4A
  LSR A                                               ; $D7FA: 4A
  AND #$03                                            ; $D7FB: 29 03
  STA $00                                             ; $D7FD: 85 00
  CLC                                                 ; $D7FF: 18
  ADC #$01                                            ; $D800: 69 01
  STA dispatch_src_ptr_lo                                           ; $D802: 8D CA 04
  LDA dispatch_dst_ptr_hi                                           ; $D805: AD CE 04
  CMP #$03                                            ; $D808: C9 03
  BCC @skip_6                                           ; $D80A: 90 08
  LDA #$80                                            ; $D80C: A9 80
  STA dispatch_step                                           ; $D80E: 8D C9 04
  JSR B1F_PaletteCopyBuffer                           ; $D811: 20 EE EC
@skip_6:
  RTS                                                 ; $D814: 60
@skip_7:
  LDA a:$0087                                         ; $D815: AD 87 00
  BPL @skip_8                                           ; $D818: 10 1F
  LDA #$70                                            ; $D81A: A9 70
  STA temp_006a                                         ; $D81C: 8D 6A 00
  LDA #$20                                            ; $D81F: A9 20
  STA ptr_006c_lo                                         ; $D821: 8D 6C 00
  LDA #$F2                                            ; $D824: A9 F2
  STA ptr_006c_hi                                         ; $D826: 8D 6D 00
  LDA #$00                                            ; $D829: A9 00
  STA dispatch_step                                           ; $D82B: 8D C9 04
  STA dispatch_src_ptr_lo                                           ; $D82E: 8D CA 04
  INC dom_scroll_param                                           ; $D831: EE 41 05
  LDA #$00                                            ; $D834: A9 00
  JSR B1F_SetUI4                                      ; $D836: 20 8B F2
@skip_8:
  RTS                                                 ; $D839: 60
.endproc
;===============================================================================
; $D83A: DomAction_ScrollTextPhase2
; Domestic action state 2: Scroll second text panel with fade transition
;===============================================================================
.proc DomAction_ScrollTextPhase2
DomAction_ScrollTextPhase2:
  LDA dispatch_src_ptr_lo                                           ; $D83A: AD CA 04
  BNE @skip_3                                           ; $D83D: D0 28
  LDA dispatch_step                                           ; $D83F: AD C9 04
  BNE @skip                                           ; $D842: D0 03
  JSR ScrollPanel_PrepareRowData                                   ; $D844: 20 E1 DC
@skip:
  JSR ScrollPanel_LoadRow                                           ; $D847: 20 13 DC
  LDA dispatch_step                                           ; $D84A: AD C9 04
  CMP #$10                                            ; $D84D: C9 10
  BCC @skip_2                                           ; $D84F: 90 15
  LDA #$00                                            ; $D851: A9 00
  STA dispatch_dst_ptr_lo                                           ; $D853: 8D CD 04
  STA dispatch_dst_ptr_hi                                           ; $D856: 8D CE 04
  LDA #$01                                            ; $D859: A9 01
  STA dispatch_src_ptr_lo                                           ; $D85B: 8D CA 04
  LDA #$DD                                            ; $D85E: A9 DD
  JSR B1F_SetUI4                                      ; $D860: 20 8B F2
  JSR B1F_PaletteFadeInit                             ; $D863: 20 BF EC
@skip_2:
  RTS                                                 ; $D866: 60
@skip_3:
  LDA dispatch_step                                           ; $D867: AD C9 04
  BPL @skip_4                                           ; $D86A: 10 03
  JMP @skip_8                                           ; $D86C: 4C B3 D8
@skip_4:
  INC dispatch_dst_ptr_lo                                           ; $D86F: EE CD 04
  BNE @skip_5                                           ; $D872: D0 03
  INC dispatch_dst_ptr_hi                                           ; $D874: EE CE 04
@skip_5:
  LDA #$75                                            ; $D877: A9 75
  STA $10                                             ; $D879: 85 10
  LDA #$9E                                            ; $D87B: A9 9E
  STA $11                                             ; $D87D: 85 11
  LDY dispatch_src_ptr_lo                                           ; $D87F: AC CA 04
  JSR RenderDispatchSprite                              ; $D882: 20 F3 DB
  LDA dispatch_src_ptr_lo                                           ; $D885: AD CA 04
  CLC                                                 ; $D888: 18
  ADC #$03                                            ; $D889: 69 03
  TAY                                                 ; $D88B: A8
  JSR RenderDispatchSprite                              ; $D88C: 20 F3 DB
  LDA dispatch_dst_ptr_lo                                           ; $D88F: AD CD 04
  LSR A                                               ; $D892: 4A
  LSR A                                               ; $D893: 4A
  LSR A                                               ; $D894: 4A
  AND #$03                                            ; $D895: 29 03
  CMP #$03                                            ; $D897: C9 03
  BNE @skip_6                                           ; $D899: D0 02
  LDA #$02                                            ; $D89B: A9 02
@skip_6:
  CLC                                                 ; $D89D: 18
  ADC #$01                                            ; $D89E: 69 01
  STA dispatch_src_ptr_lo                                           ; $D8A0: 8D CA 04
  LDA dispatch_dst_ptr_hi                                           ; $D8A3: AD CE 04
  CMP #$03                                            ; $D8A6: C9 03
  BCC @skip_7                                           ; $D8A8: 90 08
  LDA #$80                                            ; $D8AA: A9 80
  STA dispatch_step                                           ; $D8AC: 8D C9 04
  JSR B1F_PaletteCopyBuffer                           ; $D8AF: 20 EE EC
@skip_7:
  RTS                                                 ; $D8B2: 60
@skip_8:
  LDA a:$0087                                         ; $D8B3: AD 87 00
  BPL @skip_9                                           ; $D8B6: 10 10
  INC dom_scroll_param                                           ; $D8B8: EE 41 05
  LDA #$00                                            ; $D8BB: A9 00
  STA dispatch_step                                           ; $D8BD: 8D C9 04
  STA dispatch_src_ptr_lo                                           ; $D8C0: 8D CA 04
  LDA #$00                                            ; $D8C3: A9 00
  JSR B1F_SetUI4                                      ; $D8C5: 20 8B F2
@skip_9:
  RTS                                                 ; $D8C8: 60
.endproc
;===============================================================================
; $D8C9: DomAction_ScrollAndWait
; Domestic action state 3: Scroll final panel, wait for timer, then branch
;===============================================================================
.proc DomAction_ScrollAndWait
DomAction_ScrollAndWait:
  LDA dispatch_src_ptr_lo                                           ; $D8C9: AD CA 04
  BNE @skip_3                                           ; $D8CC: D0 28
  LDA dispatch_step                                           ; $D8CE: AD C9 04
  BNE @skip                                           ; $D8D1: D0 03
  JSR ScrollPanel_PrepareRowData                                   ; $D8D3: 20 E1 DC
@skip:
  JSR ScrollPanel_LoadRow                                           ; $D8D6: 20 13 DC
  LDA dispatch_step                                           ; $D8D9: AD C9 04
  CMP #$10                                            ; $D8DC: C9 10
  BCC @skip_2                                           ; $D8DE: 90 15
  LDA #$00                                            ; $D8E0: A9 00
  STA dispatch_dst_ptr_lo                                           ; $D8E2: 8D CD 04
  STA dispatch_dst_ptr_hi                                           ; $D8E5: 8D CE 04
  LDA #$01                                            ; $D8E8: A9 01
  STA dispatch_src_ptr_lo                                           ; $D8EA: 8D CA 04
  LDA #$DE                                            ; $D8ED: A9 DE
  JSR B1F_SetUI4                                      ; $D8EF: 20 8B F2
  JSR B1F_PaletteFadeInit                             ; $D8F2: 20 BF EC
@skip_2:
  RTS                                                 ; $D8F5: 60
@skip_3:
  INC dispatch_dst_ptr_lo                                           ; $D8F6: EE CD 04
  BNE @skip_4                                           ; $D8F9: D0 03
  INC dispatch_dst_ptr_hi                                           ; $D8FB: EE CE 04
@skip_4:
  LDA dispatch_dst_ptr_hi                                           ; $D8FE: AD CE 04
  CMP #$03                                            ; $D901: C9 03
  BCC @skip_5                                           ; $D903: 90 0F
  LDA dispatch_timer                                           ; $D905: AD 35 04
  CMP #$46                                            ; $D908: C9 46
  BCC @skip_6                                           ; $D90A: 90 09
  INC dom_scroll_param                                           ; $D90C: EE 41 05
  LDA #$00                                            ; $D90F: A9 00
  STA dom_display_ptr_lo                                           ; $D911: 8D 42 05
@skip_5:
  RTS                                                 ; $D914: 60
@skip_6:
  LDA #$05                                            ; $D915: A9 05
  STA dom_scroll_param                                           ; $D917: 8D 41 05
  LDA #$04                                            ; $D91A: A9 04
  STA dom_display_ptr_lo                                           ; $D91C: 8D 42 05
  RTS                                                 ; $D91F: 60
.endproc
;===============================================================================
; $D920: DomAction_FinalizeCleanup
; Domestic action state 5: Finalization sub-dispatcher (6 sub-states)
;===============================================================================
.proc DomAction_FinalizeCleanup
DomAction_FinalizeCleanup:
  LDA dom_display_ptr_lo                                           ; $D920: AD 42 05
  JSR B1F_CallbackDispatcher                          ; $D923: 20 DE EA
; --- Inline pointer table (6 entries) ---
  .word Finalize_Init                                                      ; $D926: 32 D9
  .word Finalize_SetupUI                                                     ; $D928: 50 D9
  .word Finalize_WaitConfirm                                                 ; $D92A: 5A D9
  .word Finalize_ScrollTimer                                                 ; $D92C: 76 D9
  .word Finalize_PaletteCopy                                                 ; $D92E: B4 D9
  .word Finalize_ExitTransition                                              ; $D930: C2 D9
.endproc
;===============================================================================
; $D932: Finalize_Init
;===============================================================================
.proc Finalize_Init
Finalize_Init:
  LDA #$00                                            ; $D932: A9 00
  STA $98                                             ; $D934: 85 98
  LDA #$08                                            ; $D936: A9 08
  STA $BA                                             ; $D938: 85 BA
  LDA #$09                                            ; $D93A: A9 09
  STA $BB                                             ; $D93C: 85 BB
  LDA #$A7                                            ; $D93E: A9 A7
  STA $BD                                             ; $D940: 85 BD
  LDA #$F2                                            ; $D942: A9 F2
  STA dom_display_ptr_hi                                           ; $D944: 8D 43 05
  INC dom_display_ptr_lo                                           ; $D947: EE 42 05
  LDA #$01                                            ; $D94A: A9 01
  STA dom_scroll_index                                           ; $D94C: 8D 44 05
  RTS                                                 ; $D94F: 60
.endproc
;===============================================================================
; $D950: Finalize_SetupUI
;===============================================================================
.proc Finalize_SetupUI
Finalize_SetupUI:
  LDA dom_display_ptr_hi                                           ; $D950: AD 43 05
  JSR B1F_SetUI4                                      ; $D953: 20 8B F2
  INC dom_display_ptr_lo                                           ; $D956: EE 42 05
  RTS                                                 ; $D959: 60
.endproc
;===============================================================================
; $D95A: Finalize_WaitConfirm
;===============================================================================
.proc Finalize_WaitConfirm
Finalize_WaitConfirm:
  LDA confirm_check_0                                           ; $D95A: AD 00 03
  CMP #$FF                                            ; $D95D: C9 FF
  BNE @skip                                           ; $D95F: D0 14
  LDA confirm_check_1                                           ; $D961: AD 04 03
  CMP #$FF                                            ; $D964: C9 FF
  BNE @skip                                           ; $D966: D0 0D
  DEC dom_scroll_index                                           ; $D968: CE 44 05
  BNE @skip                                           ; $D96B: D0 08
  LDA #$00                                            ; $D96D: A9 00
  STA scroll_ptr_hi                                           ; $D96F: 8D 09 04
  INC dom_display_ptr_lo                                           ; $D972: EE 42 05
@skip:
  RTS                                                 ; $D975: 60
.endproc
;===============================================================================
; $D976: Finalize_ScrollTimer
;===============================================================================
.proc Finalize_ScrollTimer
Finalize_ScrollTimer:
  INC a:$0098                                         ; $D976: EE 98 00
  LDA a:$0098                                         ; $D979: AD 98 00
  CMP #$F0                                            ; $D97C: C9 F0
  BCC @skip                                           ; $D97E: 90 05
  LDA #$00                                            ; $D980: A9 00
  STA a:$0098                                         ; $D982: 8D 98 00
@skip:
  INC scroll_ptr_hi                                           ; $D985: EE 09 04
  LDA scroll_ptr_hi                                           ; $D988: AD 09 04
  CMP #$50                                            ; $D98B: C9 50
  BCC @skip_3                                           ; $D98D: 90 24
  DEC dom_display_ptr_lo                                           ; $D98F: CE 42 05
  DEC dom_display_ptr_lo                                           ; $D992: CE 42 05
  LDA #$60                                            ; $D995: A9 60
  STA dom_scroll_index                                           ; $D997: 8D 44 05
  INC dom_display_ptr_hi                                           ; $D99A: EE 43 05
  LDA dom_display_ptr_hi                                           ; $D99D: AD 43 05
  CMP #$F9                                            ; $D9A0: C9 F9
  BNE @skip_2                                           ; $D9A2: D0 06
  LDA #$01                                            ; $D9A4: A9 01
  STA dom_scroll_index                                           ; $D9A6: 8D 44 05
  RTS                                                 ; $D9A9: 60
@skip_2:
  CMP #$FA                                            ; $D9AA: C9 FA
  BNE @skip_3                                           ; $D9AC: D0 05
  LDA #$04                                            ; $D9AE: A9 04
  STA dom_display_ptr_lo                                           ; $D9B0: 8D 42 05
@skip_3:
  RTS                                                 ; $D9B3: 60
.endproc
;===============================================================================
; $D9B4: Finalize_PaletteCopy
;===============================================================================
.proc Finalize_PaletteCopy
Finalize_PaletteCopy:
  LDA a:$0081                                         ; $D9B4: AD 81 00
  AND #$08                                            ; $D9B7: 29 08
  BEQ Finalize_NoOp                                          ; $D9B9: F0 06
  JSR B1F_PaletteCopyBuffer                           ; $D9BB: 20 EE EC
  INC dom_display_ptr_lo                                           ; $D9BE: EE 42 05
.endproc
;===============================================================================
; $D9C1: Finalize_NoOp
;===============================================================================
.proc Finalize_NoOp
Finalize_NoOp:
  RTS                                                 ; $D9C1: 60
.endproc
;===============================================================================
; $D9C2: Finalize_ExitTransition
;===============================================================================
.proc Finalize_ExitTransition
Finalize_ExitTransition:
  LDA a:$0087                                         ; $D9C2: AD 87 00
  BPL Finalize_NoOp                                          ; $D9C5: 10 FA
  JMP $E000                                           ; $D9C7: 4C 00 E0
.endproc
;===============================================================================
; $D9CA: DomAction_MainInteractive
; Domestic action state 4: Main interactive sub-dispatcher (7 sub-states)
;===============================================================================
.proc DomAction_MainInteractive
DomAction_MainInteractive:
  LDA dom_display_ptr_lo                                           ; $D9CA: AD 42 05
  JSR B1F_CallbackDispatcher                          ; $D9CD: 20 DE EA
; --- Inline pointer table (7 entries) ---
  .word DomAction_BuildOfficerList                                           ; $D9D0: DE D9
  .word DomAction_InitOfficerDisplay                                         ; $D9D2: 41 DA
  .word DomAction_RenderOfficerEntry                                         ; $D9D4: 87 DA
  .word DomAction_UpdateOfficerDisplay                                       ; $D9D6: B6 DA
  .word DomAction_ScrollOfficerList                                          ; $D9D8: E0 DA
  .word DomAction_FinalizeDisplayBuffer                                      ; $D9DA: 90 DB
  .word DomAction_CheckConfirmInput                                          ; $D9DC: DA DB
.endproc
;===============================================================================
; $D9DE: DomAction_BuildOfficerList
;===============================================================================
.proc DomAction_BuildOfficerList
  param_byte1     = $0000
DomAction_BuildOfficerList:
  LDY #$30                                            ; $D9DE: A0 30
  JSR B1F_SwitchBank8_B                               ; $D9E0: 20 5F F2
  LDA #$FE                                            ; $D9E3: A9 FE
  STA domestic_officer_list_lo                                           ; $D9E5: 8D 10 04
  LDA selected_officer_id                                           ; $D9E8: AD 2C 04
  STA domestic_officer_list_hi                                           ; $D9EB: 8D 11 04
  LDX #$00                                            ; $D9EE: A2 00
  LDA #$02                                            ; $D9F0: A9 02
  STA $02                                             ; $D9F2: 85 02
@loop:
  TXA                                                 ; $D9F4: 8A
  PHA                                                 ; $D9F5: 48
  JSR B1F_GetProvinceRecordAddr                       ; $D9F6: 20 AF F2
  LDY #$11                                            ; $D9F9: A0 11
@loop_2:
  LDA (param_byte1),Y                                         ; $D9FB: B1 00
  CMP #$FF                                            ; $D9FD: C9 FF
  BEQ @skip                                           ; $D9FF: F0 0C
  CMP domestic_officer_list_hi                                           ; $DA01: CD 11 04
  BEQ @skip                                           ; $DA04: F0 07
  LDX $02                                             ; $DA06: A6 02
  STA domestic_officer_list_lo,X                                         ; $DA08: 9D 10 04
  INC $02                                             ; $DA0B: E6 02
@skip:
  INY                                                 ; $DA0D: C8
  CPY #$1B                                            ; $DA0E: C0 1B
  BCC @loop_2                                           ; $DA10: 90 E9
  PLA                                                 ; $DA12: 68
  TAX                                                 ; $DA13: AA
  INX                                                 ; $DA14: E8
  CPX #$1E                                            ; $DA15: E0 1E
  BCC @loop                                           ; $DA17: 90 DB
  LDA #$FE                                            ; $DA19: A9 FE
  LDX $02                                             ; $DA1B: A6 02
  STA domestic_officer_list_lo,X                                         ; $DA1D: 9D 10 04
  INX                                                 ; $DA20: E8
  LDA #$FF                                            ; $DA21: A9 FF
  STA domestic_officer_list_lo,X                                         ; $DA23: 9D 10 04
  LDA #$00                                            ; $DA26: A9 00
  STA domestic_cursor_lo                                           ; $DA28: 8D 0C 04
  STA domestic_cursor_hi                                           ; $DA2B: 8D 0D 04
  STA domestic_work_ptr_hi                                           ; $DA2E: 8D 01 04
  LDA #$C0                                            ; $DA31: A9 C0
  STA dom_display_ptr_hi                                           ; $DA33: 8D 43 05
  LDA #$06                                            ; $DA36: A9 06
  STA dom_display_ptr_lo                                           ; $DA38: 8D 42 05
  LDA #$F1                                            ; $DA3B: A9 F1
  JSR B1F_SetUI4                                      ; $DA3D: 20 8B F2
  RTS                                                 ; $DA40: 60
.endproc
;===============================================================================
; $DA41: DomAction_InitOfficerDisplay
;===============================================================================
.proc DomAction_InitOfficerDisplay
DomAction_InitOfficerDisplay:
  LDY #$39                                            ; $DA41: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $DA43: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                                         ; $DA46: 12 A0
  LDA domestic_cursor_hi                                           ; $DA48: AD 0D 04
  CMP #$FF                                            ; $DA4B: C9 FF
  BEQ @skip                                           ; $DA4D: F0 01
  RTS                                                 ; $DA4F: 60
@skip:
  LDA #$08                                            ; $DA50: A9 08
  STA $BA                                             ; $DA52: 85 BA
  LDA #$06                                            ; $DA54: A9 06
  STA $BB                                             ; $DA56: 85 BB
  LDA #$00                                            ; $DA58: A9 00
  STA $96                                             ; $DA5A: 85 96
  LDA #$01                                            ; $DA5C: A9 01
  STA $97                                             ; $DA5E: 85 97
  LDA #$00                                            ; $DA60: A9 00
  STA $98                                             ; $DA62: 85 98
  LDA #$01                                            ; $DA64: A9 01
  STA $61                                             ; $DA66: 85 61
  LDA #$20                                            ; $DA68: A9 20
  STA $6E                                             ; $DA6A: 85 6E
  LDA #$C0                                            ; $DA6C: A9 C0
  STA $70                                             ; $DA6E: 85 70
  LDA #$E1                                            ; $DA70: A9 E1
  STA $E8                                             ; $DA72: 85 E8
  INC dom_display_ptr_lo                                           ; $DA74: EE 42 05
  LDA #$03                                            ; $DA77: A9 03
  STA domestic_work_ptr_hi                                           ; $DA79: 8D 01 04
  LDA #$20                                            ; $DA7C: A9 20
  STA dom_display_ptr_hi                                           ; $DA7E: 8D 43 05
  LDA #$00                                            ; $DA81: A9 00
  STA scroll_ptr_lo                                           ; $DA83: 8D 08 04
  RTS                                                 ; $DA86: 60
.endproc
;===============================================================================
; $DA87: DomAction_RenderOfficerEntry
;===============================================================================
.proc DomAction_RenderOfficerEntry
  scroll_done_flag     = $040A
DomAction_RenderOfficerEntry:
  LDA #$AE                                            ; $DA87: A9 AE
  STA $0A                                             ; $DA89: 85 0A
  LDX scroll_ptr_lo                                           ; $DA8B: AE 08 04
  LDA domestic_officer_list_lo,X                                         ; $DA8E: BD 10 04
  STA $00                                             ; $DA91: 85 00
  LDY #$39                                            ; $DA93: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $DA95: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                                         ; $DA98: 00 A0
  INC dom_display_ptr_lo                                           ; $DA9A: EE 42 05
  LDA #$00                                            ; $DA9D: A9 00
  STA scroll_ptr_hi                                           ; $DA9F: 8D 09 04
  STA scroll_done_flag                                           ; $DAA2: 8D 0A 04
  LDA #$00                                            ; $DAA5: A9 00
  STA domestic_cursor_hi                                           ; $DAA7: 8D 0D 04
  LDY scroll_ptr_lo                                           ; $DAAA: AC 08 04
  INY                                                 ; $DAAD: C8
  LDA domestic_officer_list_lo,Y                                         ; $DAAE: B9 10 04
  TYA                                                 ; $DAB1: 98
  STA domestic_cursor_lo                                           ; $DAB2: 8D 0C 04
  RTS                                                 ; $DAB5: 60
.endproc
;===============================================================================
; $DAB6: DomAction_UpdateOfficerDisplay
;===============================================================================
.proc DomAction_UpdateOfficerDisplay
DomAction_UpdateOfficerDisplay:
  LDY #$39                                            ; $DAB6: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $DAB8: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                                         ; $DABB: 12 A0
  LDA #$AE                                            ; $DABD: A9 AE
  STA $0A                                             ; $DABF: 85 0A
  LDX scroll_ptr_lo                                           ; $DAC1: AE 08 04
  LDA domestic_officer_list_lo,X                                         ; $DAC4: BD 10 04
  STA $00                                             ; $DAC7: 85 00
  LDY #$39                                            ; $DAC9: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $DACB: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                                         ; $DACE: 00 A0
  LDA domestic_cursor_hi                                           ; $DAD0: AD 0D 04
  CMP #$FF                                            ; $DAD3: C9 FF
  BNE @skip                                           ; $DAD5: D0 08
  DEC dom_display_ptr_hi                                           ; $DAD7: CE 43 05
  BNE @skip                                           ; $DADA: D0 03
  INC dom_display_ptr_lo                                           ; $DADC: EE 42 05
@skip:
  RTS                                                 ; $DADF: 60
.endproc
;===============================================================================
; $DAE0: DomAction_ScrollOfficerList
;===============================================================================
.proc DomAction_ScrollOfficerList
  scroll_src_ptr_lo     = $040E
  scroll_src_ptr_hi     = $040F
DomAction_ScrollOfficerList:
  LDA scroll_ptr_hi                                           ; $DAE0: AD 09 04
  CMP #$40                                            ; $DAE3: C9 40
  BNE @skip                                           ; $DAE5: D0 0A
  LDA scroll_src_ptr_lo                                           ; $DAE7: AD 0E 04
  STA $BC                                             ; $DAEA: 85 BC
  LDA scroll_src_ptr_hi                                           ; $DAEC: AD 0F 04
  STA $BD                                             ; $DAEF: 85 BD
@skip:
  INC $98                                             ; $DAF1: E6 98
  LDA $98                                             ; $DAF3: A5 98
  CMP #$F0                                            ; $DAF5: C9 F0
  BCC @skip_2                                           ; $DAF7: 90 04
  LDA #$00                                            ; $DAF9: A9 00
  STA $98                                             ; $DAFB: 85 98
@skip_2:
  LDA scroll_ptr_hi                                           ; $DAFD: AD 09 04
  CMP #$29                                            ; $DB00: C9 29
  BCS @skip_4                                           ; $DB02: B0 26
  LDA #$AC                                            ; $DB04: A9 AC
  SEC                                                 ; $DB06: 38
  SBC scroll_ptr_hi                                           ; $DB07: ED 09 04
  STA $0A                                             ; $DB0A: 85 0A
  LDX scroll_ptr_lo                                           ; $DB0C: AE 08 04
  JSR DomAction_RenderOfficerName                              ; $DB0F: 20 50 DB
  LDA #$FC                                            ; $DB12: A9 FC
  SEC                                                 ; $DB14: 38
  SBC scroll_ptr_hi                                           ; $DB15: ED 09 04
  CMP #$AE                                            ; $DB18: C9 AE
  BCS @skip_3                                           ; $DB1A: B0 02
  LDA #$AE                                            ; $DB1C: A9 AE
@skip_3:
  STA $0A                                             ; $DB1E: 85 0A
  LDX scroll_ptr_lo                                           ; $DB20: AE 08 04
  INX                                                 ; $DB23: E8
  JSR DomAction_RenderOfficerName                              ; $DB24: 20 50 DB
  JMP DomAction_AdvanceScrollPosition                         ; $DB27: 4C 5D DB
@skip_4:
  LDA #$FC                                            ; $DB2A: A9 FC
  SEC                                                 ; $DB2C: 38
  SBC scroll_ptr_hi                                           ; $DB2D: ED 09 04
  CMP #$AE                                            ; $DB30: C9 AE
  BCS @skip_5                                           ; $DB32: B0 02
  LDA #$AE                                            ; $DB34: A9 AE
@skip_5:
  STA $0A                                             ; $DB36: 85 0A
  LDX scroll_ptr_lo                                           ; $DB38: AE 08 04
  INX                                                 ; $DB3B: E8
  JSR DomAction_RenderOfficerName                              ; $DB3C: 20 50 DB
  LDA #$AC                                            ; $DB3F: A9 AC
  SEC                                                 ; $DB41: 38
  SBC scroll_ptr_hi                                           ; $DB42: ED 09 04
  STA $0A                                             ; $DB45: 85 0A
  LDX scroll_ptr_lo                                           ; $DB47: AE 08 04
  JSR DomAction_RenderOfficerName                              ; $DB4A: 20 50 DB
  JMP DomAction_AdvanceScrollPosition                         ; $DB4D: 4C 5D DB
;-------------------------------------------------------------------------------
; DomAction_RenderOfficerName
;   Renders the name tile for the officer at index X in domestic_officer_list.
;   Loads the officer ID from the list, stores it as parameter, and invokes
;   the banked rendering routine at $A000 via BankedCallbackTrampoline.
;   In:  X = officer list index
;   Uses: $00 (officer ID), Y = $39 (render parameter)
;-------------------------------------------------------------------------------
DomAction_RenderOfficerName:
  LDA domestic_officer_list_lo,X                                         ; $DB50: BD 10 04
  STA $00                                             ; $DB53: 85 00
  LDY #$39                                            ; $DB55: A0 39
  JSR B1F_BankedCallbackTrampoline                    ; $DB57: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                                         ; $DB5A: 00 A0
  RTS                                                 ; $DB5C: 60
;-------------------------------------------------------------------------------
; DomAction_AdvanceScrollPosition
;   Advances the scroll pointer after rendering officer entries. Increments
;   scroll_ptr_hi; when it reaches $50, shifts the display buffer pointer
;   ($0542-$0543) back by 2 and advances scroll_ptr_lo. If the next officer
;   entry is $FF (end-of-list sentinel), resets the buffer pointer to $8005
;   and sets the wrap parameter ($0544 = $27).
;   Uses: $0542-$0543 (display buffer ptr), $0544 (wrap parameter)
;-------------------------------------------------------------------------------
DomAction_AdvanceScrollPosition:
  INC scroll_ptr_hi                                           ; $DB5D: EE 09 04
  LDA scroll_ptr_hi                                           ; $DB60: AD 09 04
  CMP #$50                                            ; $DB63: C9 50
  BCC @adv_skip                                           ; $DB65: 90 28
  DEC dom_display_ptr_lo                                           ; $DB67: CE 42 05
  DEC dom_display_ptr_lo                                           ; $DB6A: CE 42 05
  INC scroll_ptr_lo                                           ; $DB6D: EE 08 04
  LDA #$20                                            ; $DB70: A9 20
  STA dom_display_ptr_hi                                           ; $DB72: 8D 43 05
  LDY scroll_ptr_lo                                           ; $DB75: AC 08 04
  INY                                                 ; $DB78: C8
  LDA domestic_officer_list_lo,Y                                         ; $DB79: B9 10 04
  CMP #$FF                                            ; $DB7C: C9 FF
  BNE @adv_skip                                           ; $DB7E: D0 0F
  LDA #$05                                            ; $DB80: A9 05
  STA dom_display_ptr_lo                                           ; $DB82: 8D 42 05
  LDA #$80                                            ; $DB85: A9 80
  STA dom_display_ptr_hi                                           ; $DB87: 8D 43 05
  LDA #$27                                            ; $DB8A: A9 27
  STA dom_scroll_index                                           ; $DB8C: 8D 44 05
@adv_skip:
  RTS                                                 ; $DB8F: 60
.endproc
;===============================================================================
; $DB90: DomAction_FinalizeDisplayBuffer
;===============================================================================
.proc DomAction_FinalizeDisplayBuffer
  ptr_0380_lo     = $0380
  ptr_0380_hi     = $0381
  ptr_0382_lo     = $0382
  ptr_0382_hi     = $0383
DomAction_FinalizeDisplayBuffer:
  LDA #$40                                            ; $DB90: A9 40
  STA ptr_0380_lo                                           ; $DB92: 8D 80 03
  LDA dom_scroll_index                                           ; $DB95: AD 44 05
  STA ptr_0380_hi                                           ; $DB98: 8D 81 03
  LDA dom_display_ptr_hi                                           ; $DB9B: AD 43 05
  STA ptr_0382_lo                                           ; $DB9E: 8D 82 03
  LDY #$00                                            ; $DBA1: A0 00
  LDA #$01                                            ; $DBA3: A9 01
@loop:
  STA ptr_0382_hi,Y                                         ; $DBA5: 99 83 03
  INY                                                 ; $DBA8: C8
  CPY #$40                                            ; $DBA9: C0 40
  BCC @loop                                           ; $DBAB: 90 F8
  LDA #$FF                                            ; $DBAD: A9 FF
  STA ptr_0382_hi,Y                                         ; $DBAF: 99 83 03
  LDA dom_display_ptr_hi                                           ; $DBB2: AD 43 05
  SEC                                                 ; $DBB5: 38
  SBC #$40                                            ; $DBB6: E9 40
  STA dom_display_ptr_hi                                           ; $DBB8: 8D 43 05
  LDA dom_scroll_index                                           ; $DBBB: AD 44 05
  SBC #$00                                            ; $DBBE: E9 00
  STA dom_scroll_index                                           ; $DBC0: 8D 44 05
  CMP #$23                                            ; $DBC3: C9 23
  BNE @skip                                           ; $DBC5: D0 0A
  LDA #$05                                            ; $DBC7: A9 05
  STA dom_scroll_param                                           ; $DBC9: 8D 41 05
  LDA #$00                                            ; $DBCC: A9 00
  STA dom_display_ptr_lo                                           ; $DBCE: 8D 42 05
@skip:
  LDA a:$007E                                         ; $DBD1: AD 7E 00
  ORA #$04                                            ; $DBD4: 09 04
  STA a:$007E                                         ; $DBD6: 8D 7E 00
  RTS                                                 ; $DBD9: 60
.endproc
;===============================================================================
; $DBDA: DomAction_CheckConfirmInput
;===============================================================================
.proc DomAction_CheckConfirmInput
DomAction_CheckConfirmInput:
  LDA confirm_check_0                                           ; $DBDA: AD 00 03
  CMP #$FF                                            ; $DBDD: C9 FF
  BNE @skip                                           ; $DBDF: D0 11
  LDA confirm_check_1                                           ; $DBE1: AD 04 03
  CMP #$FF                                            ; $DBE4: C9 FF
  BNE @skip                                           ; $DBE6: D0 0A
  DEC dom_display_ptr_hi                                           ; $DBE8: CE 43 05
  BNE @skip                                           ; $DBEB: D0 05
  LDA #$01                                            ; $DBED: A9 01
  STA dom_display_ptr_lo                                           ; $DBEF: 8D 42 05
@skip:
  RTS                                                 ; $DBF2: 60
.endproc
;===============================================================================
; $DBF3: RenderDispatchSprite
;===============================================================================
.proc RenderDispatchSprite
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  tile_attr_byte      = $0002
  overlay_data_ptr          = $000A
  var_0010        = $0010
RenderDispatchSprite:
  LDX #$10                                            ; $DBF3: A2 10
  STX $0C                                             ; $DBF5: 86 0C
  DEY                                                 ; $DBF7: 88
  TYA                                                 ; $DBF8: 98
  ASL A                                               ; $DBF9: 0A
  TAY                                                 ; $DBFA: A8
  LDA (var_0010),Y                                         ; $DBFB: B1 10
  STA param_byte1                                         ; $DBFD: 8D 00 00
  INY                                                 ; $DC00: C8
  LDA (var_0010),Y                                         ; $DC01: B1 10
  STA param_byte2                                         ; $DC03: 8D 01 00
  LDA #$1F                                            ; $DC06: A9 1F
  STA ptr_lo                                         ; $DC08: 8D 0A 00
  LDA #$00                                            ; $DC0B: A9 00
  STA rle_marker                                         ; $DC0D: 8D 02 00
  JMP B1F_SpriteOamWriterSimple                       ; $DC10: 4C AD F1
.endproc
;===============================================================================
; $DC13: ScrollPanel_LoadRow
;===============================================================================
.proc ScrollPanel_LoadRow
  ptr_0010_lo     = $0010
  ptr_0010_hi     = $0011
  ptr_0380_lo     = $0380
  ptr_0380_hi     = $0381
  ptr_0382_lo     = $0382
  ptr_0382_hi     = $0383
ScrollPanel_LoadRow:
  LDY #$26                                            ; $DC13: A0 26
  JSR B1F_SwitchBank8_B                               ; $DC15: 20 5F F2
  LDA dispatch_step                                           ; $DC18: AD C9 04
  CMP #$02                                            ; $DC1B: C9 02
  BCS @skip                                           ; $DC1D: B0 03
  JMP @skip_2                                           ; $DC1F: 4C 7E DC
@skip:
  LDA #$1C                                            ; $DC22: A9 1C
  STA ptr_0380_lo                                           ; $DC24: 8D 80 03
  LDA dispatch_offset_ptr_hi                                           ; $DC27: AD D5 04
  STA ptr_0380_hi                                           ; $DC2A: 8D 81 03
  LDA dispatch_offset_ptr_lo                                           ; $DC2D: AD D4 04
  STA ptr_0382_lo                                           ; $DC30: 8D 82 03
  LDA dispatch_data_ptr_lo                                           ; $DC33: AD D2 04
  STA ptr_0010_lo                                         ; $DC36: 8D 10 00
  LDA dispatch_data_ptr_hi                                           ; $DC39: AD D3 04
  STA ptr_0010_hi                                         ; $DC3C: 8D 11 00
  LDY #$00                                            ; $DC3F: A0 00
@loop:
  LDA (ptr_0010_lo),Y                                         ; $DC41: B1 10
  STA ptr_0382_hi,Y                                         ; $DC43: 99 83 03
  INY                                                 ; $DC46: C8
  CPY #$1C                                            ; $DC47: C0 1C
  BCC @loop                                           ; $DC49: 90 F6
  LDA #$FF                                            ; $DC4B: A9 FF
  STA ptr_0382_hi,Y                                         ; $DC4D: 99 83 03
  LDA ptr_0010_lo                                         ; $DC50: AD 10 00
  CLC                                                 ; $DC53: 18
  ADC #$1C                                            ; $DC54: 69 1C
  STA dispatch_data_ptr_lo                                           ; $DC56: 8D D2 04
  LDA ptr_0010_hi                                         ; $DC59: AD 11 00
  ADC #$00                                            ; $DC5C: 69 00
  STA dispatch_data_ptr_hi                                           ; $DC5E: 8D D3 04
  LDA dispatch_offset_ptr_lo                                           ; $DC61: AD D4 04
  CLC                                                 ; $DC64: 18
  ADC #$20                                            ; $DC65: 69 20
  STA dispatch_offset_ptr_lo                                           ; $DC67: 8D D4 04
  LDA dispatch_offset_ptr_hi                                           ; $DC6A: AD D5 04
  ADC #$00                                            ; $DC6D: 69 00
  STA dispatch_offset_ptr_hi                                           ; $DC6F: 8D D5 04
@loop_2:
  INC dispatch_step                                           ; $DC72: EE C9 04
  LDA a:$007E                                         ; $DC75: AD 7E 00
  ORA #$04                                            ; $DC78: 09 04
  STA a:$007E                                         ; $DC7A: 8D 7E 00
  RTS                                                 ; $DC7D: 60
@skip_2:
  LDA #$20                                            ; $DC7E: A9 20
  STA ptr_0380_lo                                           ; $DC80: 8D 80 03
  LDA #$23                                            ; $DC83: A9 23
  STA ptr_0380_hi                                           ; $DC85: 8D 81 03
  LDA #$C8                                            ; $DC88: A9 C8
  STA ptr_0382_lo                                           ; $DC8A: 8D 82 03
  LDA dom_scroll_param                                           ; $DC8D: AD 41 05
  SEC                                                 ; $DC90: 38
  SBC #$01                                            ; $DC91: E9 01
  ASL A                                               ; $DC93: 0A
  TAY                                                 ; $DC94: A8
  LDA ScrollPanel_OffsetPtrTable,Y                                         ; $DC95: B9 DB DC
  STA ptr_0010_lo                                         ; $DC98: 8D 10 00
  INY                                                 ; $DC9B: C8
  LDA ScrollPanel_OffsetPtrTable,Y                                         ; $DC9C: B9 DB DC
  STA ptr_0010_hi                                         ; $DC9F: 8D 11 00
  LDY #$00                                            ; $DCA2: A0 00
@loop_3:
  LDA (ptr_0010_lo),Y                                         ; $DCA4: B1 10
  STA ptr_0382_hi,Y                                         ; $DCA6: 99 83 03
  INY                                                 ; $DCA9: C8
  CPY #$20                                            ; $DCAA: C0 20
  BCC @loop_3                                           ; $DCAC: 90 F6
  LDA #$FF                                            ; $DCAE: A9 FF
  STA ptr_0382_hi,Y                                         ; $DCB0: 99 83 03
  LDA dom_scroll_param                                           ; $DCB3: AD 41 05
  SEC                                                 ; $DCB6: 38
  SBC #$01                                            ; $DCB7: E9 01
  ASL A                                               ; $DCB9: 0A
  TAY                                                 ; $DCBA: A8
  LDA ScrollPanel_DataPtrTable,Y                                         ; $DCBB: B9 D5 DC
  STA dispatch_data_ptr_lo                                           ; $DCBE: 8D D2 04
  INY                                                 ; $DCC1: C8
  LDA ScrollPanel_DataPtrTable,Y                                         ; $DCC2: B9 D5 DC
  STA dispatch_data_ptr_hi                                           ; $DCC5: 8D D3 04
  LDA #$82                                            ; $DCC8: A9 82
  STA dispatch_offset_ptr_lo                                           ; $DCCA: 8D D4 04
  LDA #$20                                            ; $DCCD: A9 20
  STA dispatch_offset_ptr_hi                                           ; $DCCF: 8D D5 04
  JMP @loop_2                                           ; $DCD2: 4C 72 DC
; --- Pointer tables for initial scroll panel setup (3 entries each, indexed by dom_scroll_param - 1) ---
ScrollPanel_DataPtrTable:
  .word $95E6                                           ; $DCD5: Entry 1 tile data pointer
  .word $976E                                           ; $DCD7: Entry 2 tile data pointer
  .word $98F6                                           ; $DCD9: Entry 3 tile data pointer
ScrollPanel_OffsetPtrTable:
  .word ScrollPanel_RowTemplate_Ornate                             ; $DCDB: Entry 1 row template pointer
  .word ScrollPanel_RowTemplate_Solid                              ; $DCDD: Entry 2 row template pointer
  .word ScrollPanel_RowTemplate_Plain                              ; $DCDF: Entry 3 row template pointer
.endproc
;===============================================================================
; $DCE1: ScrollPanel_PrepareRowData
; Load one row of tile + attribute data from built-in tables into scratch buffers
;===============================================================================
.proc ScrollPanel_PrepareRowData
  tile_buf        = $00BE
  attr_buf        = $0100
ScrollPanel_PrepareRowData:
  ; Y = (dom_scroll_param - 1) * $20  → row index into tile/attr tables
  LDA dom_scroll_param                                           ; $DCE1: AD 41 05
  SEC                                                 ; $DCE4: 38
  SBC #$01                                            ; $DCE5: E9 01
  ASL A                                               ; $DCE7: 0A  ; ×2
  ASL A                                               ; $DCE8: 0A  ; ×4
  ASL A                                               ; $DCE9: 0A  ; ×8
  ASL A                                               ; $DCEA: 0A  ; ×16
  ASL A                                               ; $DCEB: 0A  ; ×32
  TAY                                                 ; $DCEC: A8
  ; Copy $20 bytes from each table into scratch buffers
  LDX #$00                                            ; $DCED: A2 00
@loop:
  LDA ScrollPanel_TileTable,Y                                     ; $DCEF: B9 05 DD
  STA tile_buf,X                                          ; $DCF2: 9D BE 00
  LDA ScrollPanel_AttrTable,Y                                     ; $DCF5: B9 65 DD
  STA attr_buf,X                                          ; $DCF8: 9D 00 01
  INY                                                 ; $DCFB: C8
  INX                                                 ; $DCFC: E8
  CPX #$20                                            ; $DCFD: E0 20
  BCC @loop                                           ; $DCFF: 90 EE
  ; Advance to next dispatch step
  INC dispatch_step                                           ; $DD01: EE C9 04
  RTS                                                 ; $DD04: 60
  ; -- ScrollPanel tile data table (6 entries × $20 bytes, indexed by dom_scroll_param-1 × $20)
  ;    Entries: $DD05, $DD25, $DD45, $DD65, $DD85, $DDA5
  ;    NOTE: entries 3–5 overlap with ScrollPanel_AttrTable entries 0–2
ScrollPanel_TileTable:                                            ; $DD05
  .byte $DA,$C9,$00,$00,$02,$F9,$00,$00,$C5,$C2,$C0,$00,$02,$F9,$FA,$F5; $DD05: DA C9 00 00 02 F9 00 00 C5 C2 C0 00 02 F9 FA F5
  .byte $FB,$00,$00,$00,$02,$F6,$B5,$D7,$9F,$00,$00,$00,$02,$AB,$BF,$00; $DD15: FB 00 00 00 02 F6 B5 D7 9F 00 00 00 02 AB BF 00
  .byte $BB,$A9,$00,$00,$02,$AC,$AD,$AE,$BB,$A9,$00,$00,$02,$AC,$AD,$AE; $DD25: BB A9 00 00 02 AC AD AE BB A9 00 00 02 AC AD AE
  .byte $BB,$A9,$00,$00,$02,$AC,$AD,$AE,$BB,$A9,$00,$00,$02,$AC,$AD,$AE; $DD35: BB A9 00 00 02 AC AD AE BB A9 00 00 02 AC AD AE
  .byte $BB,$A9,$00,$00,$02,$9A,$00,$00,$BB,$A9,$00,$00,$02,$9B,$9A,$9C; $DD45: BB A9 00 00 02 9A 00 00 BB A9 00 00 02 9B 9A 9C
  .byte $BB,$A9,$00,$00,$02,$9C,$9D,$9E,$BB,$A9,$00,$00,$02,$9E,$9D,$9F; $DD55: BB A9 00 00 02 9C 9D 9E BB A9 00 00 02 9E 9D 9F
  ; -- ScrollPanel attribute data table (3 entries × $20 bytes, indexed same as tile table)
  ;    Entries: $DD65, $DD85, $DDA5
  ;    NOTE: entries 0–2 overlap with ScrollPanel_TileTable entries 3–5
ScrollPanel_AttrTable:                                            ; $DD65
  .byte $0F,$36,$17,$16,$0F,$27,$26,$17,$0F,$36,$20,$16,$0F,$27,$26,$36; $DD65: 0F 36 17 16 0F 27 26 17 0F 36 20 16 0F 27 26 36
  .byte $0F,$0F,$20,$06,$0F,$36,$0F,$0F,$0F,$30,$20,$16,$0F,$01,$02,$12; $DD75: 0F 0F 20 06 0F 36 0F 0F 0F 30 20 16 0F 01 02 12
  .byte $0F,$17,$16,$36,$0F,$27,$36,$20,$0F,$36,$20,$16,$0F,$17,$26,$27; $DD85: 0F 17 16 36 0F 27 36 20 0F 36 20 16 0F 17 26 27
  .byte $0F,$17,$16,$36,$0F,$27,$36,$20,$0F,$36,$20,$16,$0F,$17,$26,$27; $DD95: 0F 17 16 36 0F 27 36 20 0F 36 20 16 0F 17 26 27
  .byte $0F,$16,$17,$36,$0F,$17,$16,$30,$0F,$36,$20,$16,$0F,$17,$26,$27; $DDA5: 0F 16 17 36 0F 17 16 30 0F 36 20 16 0F 17 26 27
  .byte $0F,$0F,$20,$16,$0F,$16,$28,$0F,$0F,$36,$30,$16,$0F,$20,$27,$17; $DDB5: 0F 0F 20 16 0F 16 28 0F 0F 36 30 16 0F 20 27 17
; --- ScrollPanel row templates (3 entries × $20 bytes, referenced by ScrollPanel_OffsetPtrTable)
;     Each template defines a full 32-tile nametable row written to PPU $2320:
;       Bytes $00-$07: top border tile row
;       Bytes $08-$0F: bottom border tile row
;       Bytes $10-$17: left/right edge tiles (repeated for middle rows)
;       Bytes $18-$1F: interior fill row pattern (repeated for content rows)
ScrollPanel_RowTemplate_Ornate:                                     ; $DDC5: Group 1 – ornate decorative border ($AA/$5F/$6E accents)
  .byte $AA,$AA,$00,$AA,$AA,$22,$AA,$AA                           ; $DDC5: top border row
  .byte $6E,$5F,$00,$5F,$5F,$00,$50,$9B                           ; $DDCD: bottom border row
  .byte $66,$D5,$00,$04,$07,$C5,$41,$99                           ; $DDD5: left/right edge tiles
  .byte $AE,$AF,$A0,$A0,$A0,$AC,$A3,$A8                           ; $DDDD: fill row pattern
ScrollPanel_RowTemplate_Solid:                                      ; $DDE5: Group 2 – solid fill ($FF/$EE heavy blocks)
  .byte $EE,$FF,$77,$55,$55,$DD,$FF,$BB                           ; $DDE5: top border row
  .byte $EE,$FF,$37,$00,$05,$CD,$FF,$BB                           ; $DDED: bottom border row
  .byte $22,$00,$00,$00,$00,$00,$00,$88                           ; $DDF5: left/right edge tiles
  .byte $A2,$A0,$A0,$A0,$A0,$A0,$A0,$A8                           ; $DDFD: fill row pattern
ScrollPanel_RowTemplate_Plain:                                      ; $DE05: Group 3 – thin border, mostly empty ($22/$88 border, $00/$A0 fill)
  .byte $22,$00,$44,$15,$45,$11,$00,$88                           ; $DE05: top border row
  .byte $22,$00,$00,$00,$00,$00,$00,$88                           ; $DE0D: bottom border row
  .byte $22,$00,$00,$00,$00,$00,$00,$88                           ; $DE15: left/right edge tiles
  .byte $A2,$A0,$A0,$A0,$A0,$A0,$A0,$A8                           ; $DE1D: fill row pattern
.endproc


;===============================================================================
; $DE25: AnimationDispatch
; Entry0B: Animation dispatch
;===============================================================================
; Target0B ($DE25):
.proc AnimationDispatch
AnimationDispatch:
  LDA a:$0081                                         ; $DE25: AD 81 00
  AND #$08                                            ; $DE28: 29 08
  BEQ @skip                                           ; $DE2A: F0 08
  LDA #$03                                            ; $DE2C: A9 03
  STA dom_scroll_param                                           ; $DE2E: 8D 41 05
  JMP AnimSeq_PrepareTransition                                           ; $DE31: 4C C7 DE
@skip:
  LDA dom_scroll_param                                           ; $DE34: AD 41 05
  JSR B1F_CallbackDispatcher                          ; $DE37: 20 DE EA
; --- Inline pointer table (5 entries) ---
  .word AnimSeq_Init                                         ; $DE3A: 44 DE
  .word AnimSeq_PlayFrames                                         ; $DE3C: 66 DE
  .word AnimSeq_HoldFinalFrame                                         ; $DE3E: B9 DE
  .word AnimSeq_PrepareTransition                                         ; $DE40: C7 DE
  .word AnimSeq_ResetScene                                         ; $DE42: D6 DE
.endproc
;===============================================================================
; $DE44: AnimSeq_Init – wait then set up sprite pointer
;===============================================================================
.proc AnimSeq_Init
  ptr_0115_lo     = $0115
  ptr_0115_hi     = $0116
AnimSeq_Init:
  INC dom_scroll_index                                           ; $DE44: EE 44 05
  LDA dom_scroll_index                                           ; $DE47: AD 44 05
  CMP #$20                                            ; $DE4A: C9 20
  BCC @skip                                           ; $DE4C: 90 17
  LDA #$16                                            ; $DE4E: A9 16
  STA ptr_0115_lo                                           ; $DE50: 8D 15 01
  LDA #$30                                            ; $DE53: A9 30
  STA ptr_0115_hi                                           ; $DE55: 8D 16 01
  LDA #$00                                            ; $DE58: A9 00
  STA dom_display_ptr_hi                                           ; $DE5A: 8D 43 05
  LDA #$02                                            ; $DE5D: A9 02
  STA dom_scroll_index                                           ; $DE5F: 8D 44 05
  INC dom_scroll_param                                           ; $DE62: EE 41 05
@skip:
  RTS                                                 ; $DE65: 60
.endproc
;===============================================================================
; $DE66: AnimSeq_PlayFrames – iterate animation frame table
;===============================================================================
.proc AnimSeq_PlayFrames
AnimSeq_PlayFrames:
  LDY dom_display_ptr_hi                                           ; $DE66: AC 43 05
  CPY #$14                                            ; $DE69: C0 14
  BNE @skip                                           ; $DE6B: D0 05
  LDA #$62                                            ; $DE6D: A9 62
  JSR B1F_SoundWrapperE                               ; $DE6F: 20 93 E6
@skip:
  LDY #$21                                            ; $DE72: A0 21
  JSR B1F_SwitchBank8_B                               ; $DE74: 20 5F F2
  LDY dom_display_ptr_hi                                           ; $DE77: AC 43 05
  LDA DomAnim_FrameTable,Y                                 ; $DE7A: B9 A0 DE
  JSR SpriteFromTable                                           ; $DE7D: 20 FA DE
  DEC dom_scroll_index                                           ; $DE80: CE 44 05
  BNE @skip_2                                           ; $DE83: D0 1A
  LDA #$02                                            ; $DE85: A9 02
  STA dom_scroll_index                                           ; $DE87: 8D 44 05
  INC dom_display_ptr_hi                                           ; $DE8A: EE 43 05
  LDY dom_display_ptr_hi                                           ; $DE8D: AC 43 05
  LDA DomAnim_FrameTable,Y                                 ; $DE90: B9 A0 DE
  CMP #$FF                                            ; $DE93: C9 FF
  BNE @skip_2                                           ; $DE95: D0 08
  INC dom_scroll_param                                           ; $DE97: EE 41 05
  LDA #$40                                            ; $DE9A: A9 40
  STA dom_scroll_index                                           ; $DE9C: 8D 44 05
@skip_2:
  RTS                                                 ; $DE9F: 60

;===============================================================================
; $DEA0: DomAnim_FrameTable – sprite frame indices for domestic animation
; Indexed by dom_display_ptr_hi; $FF = end of sequence
;===============================================================================
DomAnim_FrameTable:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$08,$08,$08,$08,$08,$08,$08; $DEA0: 00 01 02 03 04 05 06 07 08 08 08 08 08 08 08 08
  .byte $09,$0A,$0B,$0C,$0D,$0E,$0D,$08,$FF           ; $DEB0: 09 0A 0B 0C 0D 0E 0D 08 FF
.endproc

;===============================================================================
; $DEB9: AnimSeq_HoldFinalFrame – display frame 8 while counting down
;===============================================================================
.proc AnimSeq_HoldFinalFrame
AnimSeq_HoldFinalFrame:
  DEC dom_scroll_index                                           ; $DEB9: CE 44 05
  BEQ @skip                                           ; $DEBC: F0 05
  LDA #$08                                            ; $DEBE: A9 08
  JMP SpriteFromTable                                           ; $DEC0: 4C FA DE
@skip:
  INC dom_scroll_param                                           ; $DEC3: EE 41 05
  RTS                                                 ; $DEC6: 60
.endproc
;===============================================================================
; $DEC7: AnimSeq_PrepareTransition – init vars and advance
;===============================================================================
.proc AnimSeq_PrepareTransition
  ptr_0115_lo     = $0115
  ptr_0115_hi     = $0116
  var_0117        = $0117
AnimSeq_PrepareTransition:
  INC dom_scroll_param                                           ; $DEC7: EE 41 05
  LDA #$0F                                            ; $DECA: A9 0F
  STA ptr_0115_lo                                           ; $DECC: 8D 15 01
  STA ptr_0115_hi                                           ; $DECF: 8D 16 01
  STA var_0117                                           ; $DED2: 8D 17 01
  RTS                                                 ; $DED5: 60
.endproc
;===============================================================================
; $DED6: AnimSeq_ResetScene – reset animation state, reinit PPU
;===============================================================================
.proc AnimSeq_ResetScene
  ptr_0540_lo     = $0540
AnimSeq_ResetScene:
  INC ptr_0540_lo                                           ; $DED6: EE 40 05
  LDA #$00                                            ; $DED9: A9 00
  STA ptr_0540_hi                                           ; $DEDB: 8D 41 05
  LDA #$B0                                            ; $DEDE: A9 B0
  STA $CE                                             ; $DEE0: 85 CE
  LDA #$04                                            ; $DEE2: A9 04
  STA $D6                                             ; $DEE4: 85 D6
  LDA #$00                                            ; $DEE6: A9 00
  STA dom_scroll_index                                           ; $DEE8: 8D 44 05
  STA anim_ppu_ptr_lo                                           ; $DEEB: 8D 70 04
  STA anim_ppu_ptr_hi                                           ; $DEEE: 8D 71 04
  JSR B1F_BankPpuInit                                 ; $DEF1: 20 7F E5
  LDA #$B0                                            ; $DEF4: A9 B0
  JSR $E673                                           ; $DEF6: 20 73 E6
  RTS                                                 ; $DEF9: 60
.endproc

;--- $DEFA: Sprite and Data ---

;===============================================================================
; $DEFA: SpriteFromTable
; Sprite OAM placement from table
;===============================================================================
.proc SpriteFromTable
SpriteFromTable:
  ASL A                                               ; $DEFA: 0A
  TAY                                                 ; $DEFB: A8
  LDA $97EF,Y                                         ; $DEFC: B9 EF 97
  STA $00                                             ; $DEFF: 85 00
  LDA $97F0,Y                                         ; $DF01: B9 F0 97
  STA $01                                             ; $DF04: 85 01
  LDA #$58                                            ; $DF06: A9 58
  STA $0A                                             ; $DF08: 85 0A
  LDA #$68                                            ; $DF0A: A9 68
  STA $0C                                             ; $DF0C: 85 0C
  LDA #$01                                            ; $DF0E: A9 01
  STA $02                                             ; $DF10: 85 02
  JMP B1F_SpriteOamWriterSimple                       ; $DF12: 4C AD F1
.endproc

;===============================================================================
; $DF15: DataRecordLoader
; Entry0D: Data record loader (pointer table lookup)
;===============================================================================
; Target0C ($DF15):
.proc DataRecordLoader
  param_byte1     = $0000
  ppu_addr_hi     = $0001
  ptr_00a8_lo     = $00A8
  ptr_00a8_hi     = $00A9
  ptr_00aa_lo     = $00AA
  ptr_00aa_hi     = $00AB
  ptr_00ac_lo     = $00AC
  ptr_00ac_hi     = $00AD
  param_050e      = $050E
DataRecordLoader:
  LDA param_050e                                           ; $DF15: AD 0E 05
  ASL A                                               ; $DF18: 0A
  TAY                                                 ; $DF19: A8
  LDA DataRecordPtrTable,Y                              ; $DF1A: B9 4A DF
  STA param_byte1                                         ; $DF1D: 8D 00 00
  LDA DataRecordPtrTable+1,Y                            ; $DF20: B9 4B DF
  STA param_byte2                                         ; $DF23: 8D 01 00
  LDY #$00                                            ; $DF26: A0 00
  LDA (param_byte1),Y                                         ; $DF28: B1 00
  STA a:param_byte1AA                                         ; $DF2A: 8D AA 00
  INY                                                 ; $DF2D: C8
  LDA (param_byte1),Y                                         ; $DF2E: B1 00
  STA a:param_byte1AB                                         ; $DF30: 8D AB 00
  INY                                                 ; $DF33: C8
  LDA (param_byte1),Y                                         ; $DF34: B1 00
  STA a:param_byte1AC                                         ; $DF36: 8D AC 00
  INY                                                 ; $DF39: C8
  LDA (param_byte1),Y                                         ; $DF3A: B1 00
  STA a:param_byte1AD                                         ; $DF3C: 8D AD 00
  LDA #$AA                                            ; $DF3F: A9 AA
  STA a:param_byte1A8                                         ; $DF41: 8D A8 00
  LDA #$00                                            ; $DF44: A9 00
  STA a:param_byte1A9                                         ; $DF46: 8D A9 00
  RTS                                                 ; $DF49: 60

;===============================================================================
; $DF4A: DataRecord pointer table (30 entries, 16-bit addresses)
; Used by DataRecordLoader: index = param_050e * 2
; Each entry points to a 4-byte data record; stride = +4
;===============================================================================
DataRecordPtrTable:
  .addr $DF86, $DF8A, $DF8E, $DF92, $DF96, $DF9A, $DF9E, $DFA2; $DF4A
  .addr $DFA6, $DFAA, $DFAE, $DFB2, $DFB6, $DFBA, $DFBE, $DFC2; $DF5A
  .addr $DFC6, $DFCA, $DFCE, $DFD2, $DFD6, $DFDA, $DFDE, $DFE2; $DF6A
  .addr $DFE6, $DFEA, $DFEE, $DFF2, $DFF6, $DFFA             ; $DF7A

;===============================================================================
; $DF86: Permutation index table (30 groups × 4 bytes) + sentinel
; Pattern per group: {base, base+2, base+1, base+3}
; Used for tile/attribute reordering
;===============================================================================
PermutationTable:
  .byte $00,$02,$01,$03, $04,$06,$05,$07, $08,$0A,$09,$0B, $0C,$0E,$0D,$0F; $DF86
  .byte $10,$12,$11,$13, $14,$16,$15,$17, $18,$1A,$19,$1B, $1C,$1E,$1D,$1F; $DF96
  .byte $20,$22,$21,$23, $24,$26,$25,$27, $28,$2A,$29,$2B, $2C,$2E,$2D,$2F; $DFA6
  .byte $30,$32,$31,$33, $34,$36,$35,$37, $38,$3A,$39,$3B, $3C,$3E,$3D,$3F; $DFB6
  .byte $40,$42,$41,$43, $44,$46,$45,$47, $48,$4A,$49,$4B, $4C,$4E,$4D,$4F; $DFC6
  .byte $50,$52,$51,$53, $54,$56,$55,$57, $58,$5A,$59,$5B, $5C,$5E,$5D,$5F; $DFD6
  .byte $60,$62,$61,$63, $64,$66,$65,$67, $68,$6A,$69,$6B, $6C,$6E,$6D,$6F; $DFE6
  .byte $70,$72,$71,$73, $74,$76,$75,$77                       ; $DFF6
.endproc

Sentinel:
  .byte $FF,$FF                                               ; $DFFE
