;===============================================================================
; PRG Bank 1F - $E000-$FFFF
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Boot bank: Reset handler, state dispatch, NMI/IRQ handlers,
; sound engine, PPU utilities, math routines, controller I/O, data tables
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"

.segment "CODE_BANK1F"

;===============================================================================
; Global RAM Address Definitions
;===============================================================================
; These addresses have consistent meaning across the entire bank.
; Function-specific aliases are defined within .proc scopes.

; --- Game State ---
addr_game_state     = $007A                     ; State counter (0-14), indexes VectorTable
addr_sub_state      = $0078                     ; Sub-state within each major state
addr_dispatch_ptr   = $004E                     ; Indirect jump target (low)
addr_dispatch_ptr_h = $004F                     ; Indirect jump target (high)

; --- PPU ---
addr_ppu_ctrl_ram   = $008B                     ; RAM copy of PPU control ($2000)
addr_ppu_mask_ram   = $008C                     ; RAM copy of PPU mask ($2001)
addr_display_mode   = $0098                     ; Display mode parameter
addr_display_mode_h = $0099                     ; Display mode parameter (high)
addr_nmi_flag       = $007D                     ; NMI update pending flag
addr_nmi_ctrl       = $007E                     ; NMI sub-dispatch control bits

; --- Controller ---
addr_pad1_edge      = $0081                     ; Pad 1 newly-pressed buttons
addr_pad2_edge      = $0082                     ; Pad 2 newly-pressed buttons
addr_pad1_raw       = $0083                     ; Pad 1 raw button state
addr_pad1_prev      = $0084                     ; Pad 1 previous frame state
addr_pad2_raw       = $0085                     ; Pad 2 raw button state
addr_pad2_prev      = $0086                     ; Pad 2 previous frame state

; --- Bank Switch ---
addr_bank_e6        = $00E6                     ; CHR bank register RAM copy (NAMCO_CHR_BANK_0)
addr_bank_e7        = $00E7                     ; CHR bank register RAM copy (NAMCO_CHR_BANK_1)
addr_bank_e8        = $00E8                     ; CHR bank register RAM copy (NAMCO_CHR_BANK_2)
addr_bank_e9        = $00E9                     ; CHR bank register RAM copy (NAMCO_CHR_BANK_3)
addr_bank_ea        = $00EA                     ; Extended bank config
addr_bank_eb        = $00EB                     ; Extended bank config
addr_bank_ec        = $00EC                     ; Extended bank config
addr_bank_ed        = $00ED                     ; Extended bank config

; --- RNG ---
addr_rng_index      = $0050                     ; RNG table index
addr_rng_saved_x    = $0051                     ; Saved X register (RNG)
addr_rng2_index     = $0052                     ; RNG variant 2 table index
addr_rng_temp_x     = $0053                     ; RNG temp X save (variants)
addr_rng3_index     = $0054                     ; RNG variant 3 table index
addr_rng4_index     = $0055                     ; RNG variant 4 table index

; --- Sprite ---
addr_sprite_count   = $007C                     ; Current OAM slot index

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

; --- PRG Bank Select ---
addr_prg_select_1a  = $00DE                     ; PRG bank select 1 (set A)
addr_prg_select_2a  = $00DF                     ; PRG bank select 2 (set A)
addr_prg_select_3a  = $00E0                     ; PRG bank select 3 (set A)
addr_prg_select_1b  = $00E1                     ; PRG bank select 1 (set B)
addr_prg_select_2b  = $00E2                     ; PRG bank select 2 (set B)
addr_prg_select_3b  = $00E3                     ; PRG bank select 3 (set B)

; --- Menu ---
addr_menu_step      = $00                       ; Items per page (1-8), set by entry point
addr_menu_ptr_lo    = $10                       ; Menu data table pointer (low)
addr_menu_ptr_hi    = $11                       ; Menu data table pointer (high)
addr_menu_result    = $12                       ; Current item value (returned)
addr_menu_column    = $0424                     ; Cursor column (0-based within page)
addr_menu_page      = $0425                     ; Cursor page (0-based)

; --- Trampoline ---
addr_trampoline_saved_bank = $0058
addr_trampoline_ret_lo     = $0059
addr_trampoline_ret_hi     = $005A
addr_trampoline_target_lo  = $005B
addr_trampoline_target_hi  = $005C
addr_trampoline_bank_param = $005D

;===============================================================================
; $E000: Reset Handler
;===============================================================================
.proc Reset
  SEI                                           ; $E000: 78  Disable interrupts
  CLD                                           ; $E001: D8  Clear decimal mode
  LDA #$00                                      ; $E002: A9 00
  STA PPU_CTRL                                  ; $E004: 8D 00 20  Disable NMI
  STA PPU_MASK                                  ; $E007: 8D 01 20  Disable rendering
  LDY #$02                                      ; $E00A: A0 02
@vblank1:
  LDA PPU_STATUS                                ; $E00C: AD 02 20  Wait for VBlank
  BPL @vblank1                                  ; $E00F: 10 FB
  LDA PPU_STATUS                                ; $E011: AD 02 20
  BMI @vblank1_nego                             ; $E014: 30 FB  Wait for VBlank end
@vblank1_nego:
  DEY                                           ; $E016: 88
  BPL @vblank1                                  ; $E017: 10 F3

  ; APU init
  LDA #$00                                      ; $E019: A9 00
  STA APU_DMC_FREQ                              ; $E01B: 8D 10 40  $4010
  LDA #$0F                                      ; $E01E: A9 0F
  STA APU_SND_CHN                               ; $E020: 8D 15 40  $4015
  LDA #$C0                                      ; $E023: A9 C0
  STA APU_FRAME                                 ; $E025: 8D 17 40  $4017

  ; Second PPU warmup
  LDA #$00                                      ; $E028: A9 00
  STA PPU_CTRL                                  ; $E02A: 8D 00 20
  STA PPU_MASK                                  ; $E02D: 8D 01 20
  LDY #$04                                      ; $E030: A0 04
@vblank2:
  LDA PPU_STATUS                                ; $E032: AD 02 20
  BPL @vblank2                                  ; $E035: 10 FB
  LDA PPU_STATUS                                ; $E037: AD 02 20
  BMI @vblank2_nego                             ; $E03A: 30 FB
@vblank2_nego:
  DEY                                           ; $E03C: 88
  BPL @vblank2                                  ; $E03D: 10 F3

  ; Set stack pointer
  LDX #$FF                                      ; $E03F: A2 FF
  TXS                                           ; $E041: 9A

  ; Clear RAM $0000-$07FF
  LDA #$04                                      ; $E042: A9 04
  STA $01                                       ; $E044: 8D 01 00
  LDY #$00                                      ; $E047: A0 00
  STY $02                                       ; $E049: 8C 02 00
  TYA                                           ; $E04C: 98
@clear_loop:
  STA ($01),Y                                   ; $E04D: 91 01
  INC $01                                       ; $E04F: EE 01 00
  BNE @clear_loop                               ; $E052: D0 F8
  INC $02                                       ; $E054: EE 02 00
  LDA $02                                       ; $E057: AD 02 00
  CMP #$08                                      ; $E05A: C9 08
  BCC @clear_loop                               ; $E05C: 90 EE

  ; Mapper init + controller check
  JSR MapperInitCtrlCheck                       ; $E05E: 20 BD F3

  ; Initialize game state to 0
  LDA #$00                                      ; $E061: A9 00
  STA addr_game_state                           ; $E063: 8D 7A 00
.endproc

;===============================================================================
; StateDispatch: Main game loop dispatch target ($E066)
; All state handlers JMP here to re-enter the main loop.
;===============================================================================
.proc StateDispatch
  LDA addr_game_state                           ; $E066: AD 7A 00
  AND #$1F                                      ; $E069: 29 1F  Mask to 0-31
  ASL                                           ; $E06B: 0A  * 2 for word index
  TAY                                           ; $E06C: A8
  LDA VectorTable,Y                             ; $E06D: B9 7C E0
  STA addr_dispatch_ptr                         ; $E070: 8D 4E 00
  LDA VectorTable+1,Y                           ; $E073: B9 7D E0
  STA addr_dispatch_ptr+1                       ; $E076: 8D 4F 00
  JMP (addr_dispatch_ptr)                       ; $E079: 6C 4E 00
.endproc

;===============================================================================
; $E07C: Vector Dispatch Table (15 entries, 30 bytes)
;===============================================================================
VectorTable:
  .addr State_SystemInit                        ; $E07C: 9A E0 | 0:  $E09A
  .addr State_NewGameInit                       ; $E07E: DA E0 | 1:  $E0DA
  .addr State_RandomDisplay2A                   ; $E080: 7D E1 | 2:  $E17D
  .addr State_KingdomSelect                     ; $E082: 8B E1 | 3:  $E18B
  .addr State_RandomDisplay28                   ; $E084: 21 E2 | 4:  $E221
  .addr State_DomesticAffairs                   ; $E086: 2F E2 | 5:  $E22F
  .addr State_RandomAdvance1                    ; $E088: E2 E2 | 6:  $E2E2
  .addr State_BattlePhase                       ; $E08A: E8 E2 | 7:  $E2E8
  .addr State_RandomAdvance2                    ; $E08C: 6A E3 | 8:  $E36A
  .addr State_TerritoryView                     ; $E08E: 7C E3 | 9:  $E37C
  .addr State_IdleWait                          ; $E090: EB E3 | 10: $E3EB
  .addr State_AdvisorCouncil                    ; $E092: EE E3 | 11: $E3EE
  .addr State_IdleWait                          ; $E094: EB E3 | 12: $E3EB (same as 10)
  .addr State_TurnSummary                       ; $E096: 6A E4 | 13: $E46A
  .addr State_IdleWait                          ; $E098: EB E3 | 14: $E3EB (same as 10)

;===============================================================================
; $E09A: Entry 0 - System Init
; Params: none
;===============================================================================
.proc State_SystemInit
  JSR NmiDisable                                ; $E09A: 20 68 E7
  JSR WaitForVBlank                             ; $E09D: 20 4D E7
  STA PPU_MASK                                  ; $E0A0: 8D 01 20  Disable rendering
  JSR BankPpuInit                               ; $E0A3: 20 7F E5
  LDX #$1F                                      ; $E0A6: A2 1F
  LDA #$0F                                      ; $E0A8: A9 0F
@fill_palette:
  STA $0100,X                                   ; $E0AA: 9D 00 01  Fill sprite palette buffer
  DEX                                           ; $E0AD: CA
  BPL @fill_palette                             ; $E0AE: 10 FA
@wait_vb:
  LDA PPU_STATUS                                ; $E0B0: AD 02 20
  BPL @wait_vb                                  ; $E0B3: 10 FB
  LDA #$4C                                      ; $E0B5: A9 4C  JMP opcode
  STA $00A5                                     ; $E0B7: 8D A5 00  Patch RAM
  STA NAMCO_CTRL                                ; $E0BA: 8D 00 F8  Patch mapper
  LDA #$00                                      ; $E0BD: A9 00
  JSR BankSwitch                                ; $E0BF: 20 1F E5
  LDA #$10                                      ; $E0C2: A9 10  NMI enable + sprite height
  STA addr_ppu_ctrl_ram                         ; $E0C4: 8D 8B 00
  STA PPU_CTRL                                  ; $E0C7: 8D 00 20
  LDA #$00                                      ; $E0CA: A9 00  Rendering off
  STA addr_ppu_mask_ram                         ; $E0CC: 8D 8C 00
  STA PPU_MASK                                  ; $E0CF: 8D 01 20
  LDA #$09                                      ; $E0D2: A9 09  Next state = 9
  STA addr_game_state                           ; $E0D4: 8D 7A 00
  JMP StateDispatch                             ; $E0D7: 4C 66 E0
.endproc

;===============================================================================
; $E0DA: Entry 1 - New Game Init
; Params: $0400 = controller input result
;         $0098 = display param
;         SRAM: $6F41, $6F3F, $6F8B = kingdom init
;===============================================================================
.proc State_NewGameInit
  JSR FrameInit                                 ; $E0DA: 20 DA E4
  LDA #$02                                      ; $E0DD: A9 02
  STA addr_sub_state                            ; $E0DF: 8D 78 00  Sub-state = 2
  LDA #$00                                      ; $E0E2: A9 00
  JSR DisplayInit                               ; $E0E4: 20 70 E3
  LDY #$30                                      ; $E0E7: A0 30
  JSR WindowDisplaySetup                        ; $E0E9: 20 5F F2

  ; Set pointer to $8000
  LDA #$00                                      ; $E0EC: A9 00
  STA $000A                                     ; $E0EE: 8D 0A 00  ptr_lo
  LDA #$80                                      ; $E0F1: A9 80
  STA $000B                                     ; $E0F3: 8D 0B 00  ptr_hi -> $8000
  LDA #$20                                      ; $E0F6: A9 20
  STA $0001                                     ; $E0F8: 8D 01 00  width param
  LDA #$00                                      ; $E0FB: A9 00
  STA $0000                                     ; $E0FD: 8D 00 00
  STA $0004                                     ; $E100: 8D 04 00
  STA $0005                                     ; $E103: 8D 05 00
  STA $0006                                     ; $E106: 8D 06 00
  LDA #$04                                      ; $E109: A9 04
  STA $0007                                     ; $E10B: 8D 07 00

  LDY #$37                                      ; $E10E: A0 37
  JSR WindowDisplaySetup                        ; $E110: 20 37 F2
  JSR $A003                                     ; $E113: 20 03 A0  Display (bank-switched)

  ; Window + render
  LDY #$3D                                      ; $E116: A0 3D
  JSR WindowDisplaySetup                        ; $E118: 20 37 F2
  LDA #$00                                      ; $E11B: A9 00
  STA $0000                                     ; $E11D: 8D 00 00
  JSR $A015                                     ; $E120: 20 15 A0  Overlay display

  JSR ControllerRead                            ; $E123: 20 F7 EA
  LDA $0400                                     ; $E126: AD 00 04  Check input
  CMP #$0D                                      ; $E129: C9 0D
  BEQ @skip_sram_flag                           ; $E12B: F0 05
  LDA #$FF                                      ; $E12D: A9 FF
  STA $6F8B                                     ; $E12F: 8D 8B 6F  Set SRAM flag
@skip_sram_flag:
  LDY #$3D                                      ; $E132: A0 3D
  JSR WindowDisplaySetup                        ; $E134: 20 37 F2
  JSR $A003                                     ; $E137: 20 36 A0
  JSR $A009                                     ; $E13A: 20 BF EC
  LDA #$A0                                      ; $E142: A9 00
  STA addr_display_mode                         ; $E149: 8D 98 00
  LDA #$00                                      ; $E14C: A9 00
  STA $0420                                     ; $E14E: 8D 20 04
  STA $04E0                                     ; $E151: 8D E0 04
  STA $04E1                                     ; $E154: 8D E1 04
  STA $04E2                                     ; $E157: 8D E2 04
  STA $04E3                                     ; $E15A: 8D E3 04
  LDA #$F0                                      ; $E15D: A9 F0
  STA $6F41                                     ; $E15F: 8D 41 6F  SRAM: kingdom param
  LDA #$80                                      ; $E162: A9 80
  STA $6F3F                                     ; $E164: 8D 3F 6F  SRAM: kingdom param
  LDA #$00                                      ; $E167: A9 00
  JSR BankSwitch                                ; $E169: 20 1F E5
  INC addr_game_state                           ; $E16C: EE 7A 00  Next state
  LDA #$81                                      ; $E16F: A9 81
  JSR SoundWrapperA                             ; $E171: 20 73 E6  Music $81
  JSR PpuMaskHelper                             ; $E174: 20 49 E7
  JSR NmiEnable                                 ; $E177: 20 53 E7
  JMP StateDispatch                             ; $E17A: 4C 66 E0
.endproc

;===============================================================================
; $E17D: Entry 2 - Random + Display (Y=$2A)
;===============================================================================
.proc State_RandomDisplay2A
  JSR RandomByte                                ; $E17D: 20 7A E8
  LDY #$2A                                      ; $E180: A0 2A
  JSR WindowSetup2                              ; $E182: 20 4B F2
  JSR $A000                                     ; $E185: 20 00 A0  Display (bank-switched)
  JMP StateDispatch                             ; $E188: 4C 66 E0
.endproc

;===============================================================================
; $E18B: Entry 3 - Kingdom Select
; Params: $0500 = kingdom mode ($0B=scenario)
;         $0510-$0513 = kingdom coordinate data
;         $0068/$0069 = territory data pointer
;===============================================================================
.proc State_KingdomSelect
kingdom_mode    = $0500
kingdom_x       = $0510
kingdom_y       = $0511
kingdom_x2      = $0512
kingdom_y2      = $0513
territory_ptr_lo = $0068
territory_ptr_hi = $0069

  JSR FrameInit                                 ; $E18B: 20 DA E4
  LDA #$03                                      ; $E18E: A9 03
  STA addr_sub_state                            ; $E190: 8D 78 00
  LDA #$01                                      ; $E193: A9 01
  JSR DisplayInit                               ; $E195: 20 70 E3
  LDY #$37                                      ; $E198: A0 37
  JSR WindowDisplaySetup                        ; $E19A: 20 37 F2
  JSR $A027                                     ; $E19D: 20 27 A0  Kingdom display (bank-switched)

  LDA kingdom_mode                              ; $E1A0: AD 00 05
  CMP #$0B                                      ; $E1A3: C9 0B  Scenario mode?
  BNE @normal_mode                              ; $E1A5: D0 0B
  LDY #$2C                                      ; $E1A7: A0 2C
  JSR WindowDisplaySetup                        ; $E1A9: 20 37 F2
  JSR $A006                                     ; $E1AC: 20 06 A0  Scenario function
  JMP @after_mode_check                         ; $E1AF: 4C BA E1
@normal_mode:
  LDY #$28                                      ; $E1B2: A0 28
  JSR WindowDisplaySetup                        ; $E1B4: 20 37 F2
  JSR $A003                                     ; $E1B7: 20 03 A0  Normal function
@after_mode_check:
  LDA kingdom_x                                 ; $E1BA: AD 10 05
  STA $0090                                     ; $E1BD: 8D 90 00
  LDA kingdom_y                                 ; $E1C0: AD 11 05
  STA $0091                                     ; $E1C3: 8D 91 00
  LDA kingdom_x2                                ; $E1C6: AD 12 05
  STA $008E                                     ; $E1C9: 8D 8E 00
  LDA kingdom_y2                                ; $E1CC: AD 13 05
  STA $008F                                     ; $E1CF: 8D 8F 00
  LDA #$FF                                      ; $E1D2: A9 FF
  STA $0518                                     ; $E1D4: 8D 18 05  Kingdom flag

  ; Display + render
  LDY #$3D                                      ; $E1D7: A0 37
  JSR WindowDisplaySetup                        ; $E1D9: 20 37 F2
  JSR $A009                                     ; $E1DC: 20 09 A0
  LDA #$00                                      ; $E1E4: A9 01
  STA $0000                                     ; $E1E6: 8D 00 00
  JSR $A015                                     ; $E1E9: 20 15 A0
  JSR ControllerRead                            ; $E1EC: 20 F7 EA

  LDA #$00                                      ; $E1EF: A9 00
  STA $0508                                     ; $E1F1: 8D 08 05
  LDA #$70                                      ; $E1F4: A9 70
  STA territory_ptr_lo                          ; $E1F6: 8D 68 00
  LDA #$AF                                      ; $E1F9: A9 AF
  STA territory_ptr_hi                          ; $E1FB: 8D 69 00  Ptr = $AF70

  LDA #$01                                      ; $E1FE: A9 01
  JSR BankSwitch                                ; $E200: 20 1F E5
  LDA #$01                                      ; $E203: A9 01
  STA $0097                                     ; $E205: 8D 97 00
  JSR PaletteUpload                             ; $E208: 20 BF EC
  LDA #$05                                      ; $E20B: A9 05
  STA $0061                                     ; $E20D: 8D 61 00
  INC addr_game_state                           ; $E210: EE 7A 00
  LDA #$1D                                      ; $E213: A9 1D
  JSR SoundWrapperA                             ; $E215: 20 73 E6  Music $1D
  JSR PpuMaskHelper                             ; $E218: 20 49 E7
  JSR NmiEnable                                 ; $E21B: 20 53 E7
  JMP StateDispatch                             ; $E21E: 4C 66 E0
.endproc

;===============================================================================
; $E221: Entry 4 - Random + Display (Y=$28)
;===============================================================================
.proc State_RandomDisplay28
  JSR RandomByte                                ; $E221: 20 7A E8
  LDY #$28                                      ; $E224: A0 28
  JSR WindowSetup2                              ; $E226: 20 4B F2
  JSR $A000                                     ; $E229: 20 00 A0
  JMP StateDispatch                             ; $E22C: 4C 66 E0
.endproc

;===============================================================================
; $E22F: Entry 5 - Domestic Affairs
; Params: $0544 = domestic action type (0-6)
;         $0562/$0563 = sprite position indices
;===============================================================================
.proc State_DomesticAffairs
action_type     = $0544
sprite_idx1     = $0563
sprite_idx2     = $0562

  JSR FrameInit                                 ; $E22F: 20 DA E4
  LDA #$04                                      ; $E232: A9 04
  STA addr_sub_state                            ; $E234: 8D 78 00
  LDA action_type                               ; $E237: AD 44 05
  CLC                                           ; $E23A: 18
  ADC #$02                                      ; $E23B: 69 02
  JSR DisplayInit                               ; $E23D: 20 70 E3
  LDA #$02                                      ; $E240: A9 02
  JSR BankSwitch                                ; $E242: 20 1F E5
  LDY #$37                                      ; $E245: A0 37
  JSR WindowDisplaySetup                        ; $E247: 20 37 F2
  JSR $A024                                     ; $E24A: 20 24 A0  Domestic display
  LDY #$3D                                      ; $E24D: A0 3D
  JSR WindowDisplaySetup                        ; $E24F: 20 37 F2

  ; Second display call with action type
  LDA action_type                               ; $E252: AD 44 05
  CLC                                           ; $E255: 18
  ADC #$02                                      ; $E256: 69 02
  STA $0000                                     ; $E258: 8D 00 00
  JSR DomesticActionDisplay                     ; $E25B: 20 15 A0

  ; Sprite positions from table
  LDY sprite_idx1                               ; $E25E: AC 63 05
  LDA DomesticSpriteYPos,Y                      ; $E261: B9 DE E2
  STA $0107                                     ; $E264: 8D 07 01  Sprite position indicator
  STA $0113                                     ; $E267: 8D 13 01  Mirror
  LDY sprite_idx2                               ; $E26A: AC 62 05
  LDA DomesticSpriteYPos,Y                      ; $E26D: B9 DE E2
  STA $010F                                     ; $E270: 8D 0F 01
  STA $0117                                     ; $E273: 8D 17 01

  JSR ControllerRead                            ; $E276: 20 F7 EA
  LDY #$3D                                      ; $E279: A0 3D
  JSR WindowDisplaySetup                        ; $E27B: 20 37 F2
  LDA #$01                                      ; $E27E: A9 01
  STA $0000                                     ; $E285: 8D 98 00
  JSR $A015                                     ; $E288: 20 BF EC
  INC addr_game_state                           ; $E28B: EE 7A 00
  LDA #$0D                                      ; $E28E: A9 0D
  JSR SoundWrapperC                             ; $E290: 20 83 E6
  JSR PpuMaskHelper                             ; $E293: 20 49 E7
  JSR NmiEnable                                 ; $E296: 20 53 E7
  JMP StateDispatch                             ; $E299: 4C 66 E0
.endproc

;===============================================================================
; $E29C: Domestic Action Display Lookup
; Params: $0544 = action type (0-6)
;         $000A/$000B = graphic pointer
;         $000C/$000D = base data pointer
;===============================================================================
.proc DomesticActionLookup
action_type     = $0544
graphic_ptr_lo  = $000A
graphic_ptr_hi  = $000B
base_ptr_lo     = $000C
base_ptr_hi     = $000D

  LDA action_type                               ; $E29C: AD 44 05
  ASL                                           ; $E29F: 0A  * 2 for table index
  TAY                                           ; $E2A0: A8
  LDA DomesticGraphicPtrs,Y                     ; $E2A1: B9 C2 E2
  STA graphic_ptr_lo                            ; $E2A4: 8D 0A 00
  LDA DomesticGraphicPtrs+1,Y                   ; $E2A7: B9 C3 E2
  STA graphic_ptr_hi                            ; $E2AA: 8D 0B 00
  LDA DomesticBaseDataPtrs,Y                    ; $E2AD: B9 D0 E2
  STA base_ptr_lo                               ; $E2B0: 8D 0C 00
  LDA DomesticBaseDataPtrs+1,Y                  ; $E2B3: B9 D1 E2
  STA base_ptr_hi                               ; $E2B6: 8D 0D 00
  LDY #$37                                      ; $E2B9: A0 37
  JSR WindowDisplaySetup                        ; $E2BB: 20 37 F2
  JSR $A006                                     ; $E2BE: 20 06 A0  Action display (bank-switched)
  RTS                                           ; $E2C1: 60
.endproc

; Domestic action display (wraps lookup)
DomesticActionDisplay = DomesticActionLookup

;===============================================================================
; $E2C2: Domestic Action Data Tables
;===============================================================================
DomesticGraphicPtrs:
  .addr $8440, $8570, $86A0, $87D0              ; $E2C2: 40 84 70 85 A0 86 D0 87
  .addr $8900, $8A30, $8B60                     ; $E2CA: 00 89 30 8A 60 8B

DomesticBaseDataPtrs:
  .addr $8000, $8000, $8000, $8000              ; $E2D0: 00 80 00 80 00 80 00 80
  .addr $8000, $8000, $8000                     ; $E2D8: 00 80 00 80 00 80

DomesticSpriteYPos:
  .byte $10, $0F, $00, $16                      ; $E2DE: 10 0F 00 16

;===============================================================================
; $E2E2: Entry 6 - Random Seed Advance
;===============================================================================
.proc State_RandomAdvance1
  JSR RandomByte                                ; $E2E2: 20 7A E8
  JMP StateDispatch                             ; $E2E5: 4C 66 E0
.endproc

;===============================================================================
; $E2E8: Entry 7 - Battle Phase
; Params: $04AB/$04AC = army status flags
;         $0098 = display param ($A0)
;===============================================================================
.proc State_BattlePhase
army_status1    = $04AB
army_status2    = $04AC

  JSR FrameInit                                 ; $E2E8: 20 DA E4
  LDA #$05                                      ; $E2EB: A9 05
  STA addr_sub_state                            ; $E2ED: 8D 78 00
  LDA #$0A                                      ; $E2F0: A9 0A  Battle display mode
  JSR DisplayInit                               ; $E2F2: 20 70 E3
  LDA #$A0                                      ; $E2F5: A9 A0
  STA addr_display_mode                         ; $E2F7: 8D 98 00
  LDY #$30                                      ; $E2FA: A0 30
  JSR WindowDisplaySetup                        ; $E2FC: 20 5F F2
  LDA #$00                                      ; $E2FF: A9 00
  STA $000A                                     ; $E301: 8D 0A 00  ptr_lo
  LDA #$84                                      ; $E304: A9 84
  STA $000B                                     ; $E306: 8D 0B 00  ptr_hi -> $8400
  LDA #$00                                      ; $E309: A9 00
  STA $0000                                     ; $E30B: 8D 00 00
  LDA #$20                                      ; $E30E: A9 20
  STA $0001                                     ; $E310: 8D 01 00
  LDY #$37                                      ; $E313: A0 37
  JSR WindowDisplaySetup                        ; $E315: 20 37 F2
  JSR $A003                                     ; $E318: 20 03 A0  Battle display
  LDY #$3D                                      ; $E31B: A0 3D
  JSR WindowDisplaySetup                        ; $E31D: 20 37 F2
  LDA #$0A                                      ; $E320: A9 0A
  STA $0000                                     ; $E322: 8D 00 00
  JSR $A015                                     ; $E325: 20 15 A0

  JSR ControllerRead                            ; $E328: 20 F7 EA

  ; Check army status flags
  LDX #$00                                      ; $E32B: A2 00
  LDA army_status1                              ; $E32D: AD AB 04
  CMP #$01                                      ; $E330: C9 01
  BNE @army2_check                              ; $E332: D0 06
  STX $0106                                     ; $E334: 8E 06 01  Clear sprite if army=1
  STX $0116                                     ; $E337: 8E 16 01
@army2_check:
  LDA army_status2                              ; $E33A: AD AC 04
  CMP #$01                                      ; $E33D: C9 01
  BNE @after_army                               ; $E33F: D0 06
  STX $010E                                     ; $E341: 8E 0E 01  Clear sprite if army=1
  STX $011A                                     ; $E344: 8E 1A 01
@after_army:
  JSR PaletteUpload                             ; $E347: 20 BF EC
  LDY #$3D                                      ; $E34A: A0 3D
  JSR WindowDisplaySetup                        ; $E34C: 20 37 F2
  LDA #$02                                      ; $E34F: A9 02
  JSR BankSwitch                                ; $E351: 20 45 A0
  INC addr_game_state                           ; $E359: EE 7A 00
  LDA #$12                                      ; $E35C: A9 12
  JSR SoundWrapperB                             ; $E35E: 20 7B E6  Battle music $12
  JSR PpuMaskHelper                             ; $E361: 20 49 E7
  JSR NmiEnable                                 ; $E364: 20 53 E7
  JMP StateDispatch                             ; $E367: 4C 66 E0
.endproc

;===============================================================================
; $E36A: Entry 8 - Random Seed Advance
;===============================================================================
.proc State_RandomAdvance2
  JSR RandomByte                                ; $E36A: 20 7A E8
  JMP StateDispatch                             ; $E36D: 4C 66 E0
.endproc

;===============================================================================
; $E370: Display Init Helper
; Params: A = display mode index (passed before call)
;===============================================================================
.proc DisplayInit
  LDY #$3D                                      ; $E370: A0 3D
  JSR WindowDisplaySetup                        ; $E372: 20 37 F2  Window clear
  JSR $A01B                                     ; $E375: 20 1B A0  Bank-switched display
  JSR ChrBankSwitch                             ; $E378: 20 06 F2  Window/display helper
  RTS                                           ; $E37B: 60
.endproc

;===============================================================================
; $E37C: Entry 9 - Territory / Map View
;===============================================================================
.proc State_TerritoryView
  JSR FrameInit                                 ; $E37C: 20 DA E4
  LDA #$06                                      ; $E37F: A9 06
  STA addr_sub_state                            ; $E381: 8D 78 00
  LDA #$0B                                      ; $E384: A9 0B  Territory display mode
  JSR DisplayInit                               ; $E386: 20 70 E3
  LDY #$35                                      ; $E389: A0 35
  JSR WindowDisplaySetup                        ; $E38B: 20 5F F2
  LDA #$90                                      ; $E38E: A9 90
  STA $000A                                     ; $E390: 8D 0A 00
  LDA #$9A                                      ; $E393: A9 9A
  STA $000B                                     ; $E395: 8D 0B 00  Ptr -> $9A90
  LDA #$20                                      ; $E398: A9 20
  STA $0001                                     ; $E39A: 8D 01 00
  LDA #$00                                      ; $E39D: A9 00
  STA $0000                                     ; $E39F: 8D 00 00
  STA $0004                                     ; $E3A2: 8D 04 00
  STA $0005                                     ; $E3A5: 8D 05 00
  STA $0006                                     ; $E3A8: 8D 06 00
  LDA #$04                                      ; $E3AB: A9 04
  STA $0007                                     ; $E3AD: 8D 07 00
  LDY #$37                                      ; $E3B0: A0 37
  JSR WindowDisplaySetup                        ; $E3B2: 20 37 F2
  JSR $A003                                     ; $E3B5: 20 03 A0
  LDY #$3D                                      ; $E3B8: A0 3D
  JSR WindowDisplaySetup                        ; $E3BA: 20 37 F2
  LDA #$0B                                      ; $E3BD: A9 0B
  STA $0000                                     ; $E3BF: 8D 00 00
  JSR $A015                                     ; $E3C2: 20 15 A0
  JSR ControllerRead                            ; $E3C5: 20 F7 EA
  JSR PaletteUpload                             ; $E3C8: 20 BF EC
  LDY #$3D                                      ; $E3CB: A0 3D
  JSR WindowDisplaySetup                        ; $E3CD: 20 37 F2
  LDA #$03                                      ; $E3D0: A9 03
  JSR PaletteUpload                             ; $E3D2: 20 45 A0
  LDA #$A0                                      ; $E3D5: A9 A0
  STA addr_display_mode                         ; $E3D7: 8D 98 00
  LDA #$02                                      ; $E3DA: A9 02
  JSR BankSwitch                                ; $E3DC: 20 1F E5
  INC addr_game_state                           ; $E3DF: EE 7A 00
  JSR PpuMaskHelper                             ; $E3E2: 20 49 E7
  JSR NmiEnable                                 ; $E3E5: 20 53 E7
  JMP StateDispatch                             ; $E3E8: 4C 66 E0
.endproc

;===============================================================================
; $E3EB: Entry 10/12/14 - Idle / Wait State
;===============================================================================
State_IdleWait:
  JMP StateDispatch                             ; $E3EB: 4C 66 E0

;===============================================================================
; $E3EE: Entry 11 - Advisor / Council
;===============================================================================
.proc State_AdvisorCouncil
  JSR FrameInit                                 ; $E3EE: 20 DA E4
  LDA #$07                                      ; $E3F1: A9 07
  STA addr_sub_state                            ; $E3F3: 8D 78 00
  LDA #$0C                                      ; $E3F6: A9 0C  Advisor display mode
  JSR DisplayInit                               ; $E3F8: 20 70 E3
  LDY #$32                                      ; $E3FB: A0 32
  JSR WindowDisplaySetup                        ; $E3FD: 20 5F F2
  LDA #$E3                                      ; $E400: A9 E3
  STA $000A                                     ; $E402: 8D 0A 00
  LDA #$9A                                      ; $E405: A9 9A
  STA $000B                                     ; $E407: 8D 0B 00  Ptr -> $9AE3
  LDA #$20                                      ; $E40A: A9 20
  STA $0001                                     ; $E40C: 8D 01 00
  LDA #$00                                      ; $E40F: A9 00
  STA $0000                                     ; $E411: 8D 00 00
  STA $0004                                     ; $E414: 8D 04 00
  STA $0005                                     ; $E417: 8D 05 00
  STA $0006                                     ; $E41A: 8D 06 00
  LDA #$04                                      ; $E41D: A9 04
  STA $0007                                     ; $E41F: 8D 07 00
  LDY #$37                                      ; $E422: A0 37
  JSR WindowDisplaySetup                        ; $E424: 20 37 F2
  JSR $A003                                     ; $E427: 20 03 A0
  LDY #$3D                                      ; $E42A: A0 3D
  JSR WindowDisplaySetup                        ; $E42C: 20 37 F2
  JSR $A018                                     ; $E42F: 20 18 A0  Advisor dialogue
  LDY #$3D                                      ; $E432: A0 3D
  JSR WindowDisplaySetup                        ; $E434: 20 37 F2
  LDA #$0C                                      ; $E437: A9 0C
  STA $0000                                     ; $E439: 8D 00 00
  JSR $A015                                     ; $E43C: 20 15 A0
  JSR ControllerRead                            ; $E43F: 20 F7 EA
  JSR PaletteUpload                             ; $E442: 20 BF EC
  LDY #$3D                                      ; $E445: A0 3D
  JSR WindowDisplaySetup                        ; $E447: 20 37 F2
  LDA #$04                                      ; $E44A: A9 04
  JSR PaletteUpload                             ; $E44C: 20 45 A0
  LDA #$A0                                      ; $E44F: A9 A0
  STA addr_display_mode                         ; $E451: 8D 98 00
  LDA #$02                                      ; $E454: A9 02
  JSR BankSwitch                                ; $E456: 20 1F E5
  INC addr_game_state                           ; $E459: EE 7A 00
  LDA #$08                                      ; $E45C: A9 08
  JSR SoundWrapperC                             ; $E45E: 20 83 E6  Sound $08
  JSR PpuMaskHelper                             ; $E461: 20 49 E7
  JSR NmiEnable                                 ; $E464: 20 53 E7
  JMP StateDispatch                             ; $E467: 4C 66 E0
.endproc

;===============================================================================
; $E46A: Entry 13 - Turn Summary
; Params: $0541 = completion flag (0=normal, nonzero=victory)
;===============================================================================
.proc State_TurnSummary
completion_flag = $0541

  JSR FrameInit                                 ; $E46A: 20 DA E4
  LDA #$08                                      ; $E46D: A9 08
  STA addr_sub_state                            ; $E46F: 8D 78 00
  LDA #$0D                                      ; $E472: A9 0D  Report display mode
  JSR DisplayInit                               ; $E474: 20 70 E3
  LDY #$36                                      ; $E477: A0 36
  JSR WindowDisplaySetup                        ; $E479: 20 5F F2
  LDA #$92                                      ; $E47C: A9 92
  STA $000A                                     ; $E47E: 8D 0A 00
  LDA #$9B                                      ; $E481: A9 9B
  STA $000B                                     ; $E483: 8D 0B 00  Ptr -> $9B92
  LDA #$00                                      ; $E486: A9 00
  STA $0000                                     ; $E488: 8D 00 00
  LDA #$20                                      ; $E48B: A9 20
  STA $0001                                     ; $E48D: 8D 01 00
  LDY #$37                                      ; $E490: A0 37
  JSR WindowDisplaySetup                        ; $E492: 20 37 F2
  JSR $A003                                     ; $E495: 20 03 A0
  LDY #$3D                                      ; $E498: A0 3D
  JSR WindowDisplaySetup                        ; $E49A: 20 37 F2
  LDA #$0D                                      ; $E49D: A9 0D
  STA $0000                                     ; $E49F: 8D 00 00
  JSR $A015                                     ; $E4A2: 20 15 A0
  JSR ScrollSet                                 ; $E4A5: 20 F7 EA
  LDY #$3D                                      ; $E4A8: A0 3D
  JSR WindowDisplaySetup                        ; $E4AA: 20 37 F2
  LDA #$05                                      ; $E4AD: A9 05
  JSR $A045                                     ; $E4AF: 20 45 A0
  LDA #$A0                                      ; $E4B2: A9 A0
  STA addr_display_mode                         ; $E4B4: 8D 98 00
  LDA #$02                                      ; $E4B7: A9 02
  JSR BankSwitch                                ; $E4B9: 20 1F E5
  INC addr_game_state                           ; $E4BC: EE 7A 00
  LDY completion_flag                           ; $E4BF: AC 41 05
  BNE @victory_music                            ; $E4C2: D0 08
  LDA #$98                                      ; $E4C4: A9 98
  JSR SoundWrapperA                             ; $E4C6: 20 73 E6  Normal music $98
  JMP @after_music                              ; $E4C9: 4C D1 E4
@victory_music:
  LDA #$AA                                      ; $E4CC: A9 AA
  JSR SoundWrapperB                             ; $E4CE: 20 7B E6  Victory music $AA
@after_music:
  JSR PpuMaskHelper                             ; $E4D1: 20 49 E7
  JSR NmiEnable                                 ; $E4D4: 20 53 E7
  JMP StateDispatch                             ; $E4D7: 4C 66 E0
.endproc

;===============================================================================
; $E4DA: Frame Init Helper
; Clears display working RAM, sets sentinel values
;===============================================================================
.proc FrameInit
  JSR NmiDisable                                ; $E4DA: 20 68 E7
  JSR WaitForVBlank                             ; $E4DD: 20 4D E7
  STA PPU_MASK                                  ; $E4E0: 8D 01 20  Disable rendering
  JSR BankPpuInit                               ; $E4E3: 20 7F E5
  JSR NametableFill2                            ; $E4E6: 20 DF E7
  LDA #$00                                      ; $E4E9: A9 00
  STA $0090                                     ; $E4EB: 8D 90 00
  STA $0091                                     ; $E4EE: 8D 91 00
  STA $008E                                     ; $E4F1: 8D 8E 00
  STA $008F                                     ; $E4F4: 8D 8F 00
  STA addr_display_mode                         ; $E4F7: 8D 98 00
  STA $0099                                     ; $E4FA: 8D 99 00
  STA $0096                                     ; $E4FD: 8D 96 00
  STA $0097                                     ; $E500: 8D 97 00
  STA addr_nmi_ctrl                             ; $E505: 8D 7E 00
  STA $005E                                     ; $E508: 8D 5E 00
  STA $005F                                     ; $E50B: 8D 5F 00
  STA $008D                                     ; $E50E: 8D 8D 00
  STA $00A4                                     ; $E511: 8D A4 00
  LDA #$FF                                      ; $E514: A9 FF
  STA $0300                                     ; $E516: 8D 00 03  Sentinel values
  STA $0304                                     ; $E519: 8D 04 03
  JMP SpriteBufferInit                          ; $E51C: 4C 23 E8
.endproc

;===============================================================================
; $E51F: Bank Switch
; Params: A = config index (0-N), reads 8-byte config from BankSwitchTable
;===============================================================================
.proc BankSwitch
  ASL                                           ; $E51F: 0A  A * 2
  ASL                                           ; $E520: 0A  A * 4
  ASL                                           ; $E521: 0A  A * 8 -> table offset
  TAY                                           ; $E522: A8
  LDA BankSwitchTable,Y                         ; $E523: B9 67 E5
  STA addr_bank_e6                              ; $E526: 8D E6 00
  STA NAMCO_CHR_BANK_0                                     ; $E529: 8D 00 C0  CHR bank 0
  INY                                           ; $E52C: C8
  LDA BankSwitchTable,Y                         ; $E52D: B9 67 E5
  STA addr_bank_e7                              ; $E530: 8D E7 00
  STA NAMCO_CHR_BANK_1                                     ; $E533: 8D 00 C8  CHR bank 1
  INY                                           ; $E536: C8
  LDA BankSwitchTable,Y                         ; $E537: B9 67 E5
  STA addr_bank_e8                              ; $E53A: 8D E8 00
  STA NAMCO_CHR_BANK_2                                     ; $E53D: 8D 00 D0  CHR bank 2
  INY                                           ; $E540: C8
  LDA BankSwitchTable,Y                         ; $E541: B9 67 E5
  STA addr_bank_e9                              ; $E544: 8D E9 00
  STA NAMCO_CHR_BANK_3                                     ; $E547: 8D 00 D8  CHR bank 3
  INY                                           ; $E54A: C8
  LDA BankSwitchTable,Y                         ; $E54B: B9 67 E5
  STA addr_bank_ea                              ; $E54E: 8D EA 00
  INY                                           ; $E551: C8
  LDA BankSwitchTable,Y                         ; $E552: B9 67 E5
  STA addr_bank_eb                              ; $E555: 8D EB 00
  INY                                           ; $E558: C8
  LDA BankSwitchTable,Y                         ; $E559: B9 67 E5
  STA addr_bank_ec                              ; $E55C: 8D EC 00
  INY                                           ; $E55F: C8
  LDA BankSwitchTable,Y                         ; $E560: B9 67 E5
  STA addr_bank_ed                              ; $E563: 8D ED 00
  RTS                                           ; $E566: 60
.endproc

;===============================================================================
; $E567: Bank Switch Configuration Table
; 8 bytes per config. First 4: PRG bank regs, Last 4: extended config
;===============================================================================
BankSwitchTable:
  .byte $E0, $E1, $E1, $E1, $E0, $E1, $E0, $E1  ; $E567: E0 E1 E1 E1 E0 E1 E0 E1  Config 0
  .byte $E0, $E0, $E0, $E0, $E0, $E1, $E0, $E1  ; $E56F: E0 E0 E0 E0 E1 E1 E1 E1  Config 1
  .byte $E0, $E1, $E0, $E1, $E0, $E1, $E0, $E1  ; $E577: E0 E1 E0 E1 E0 E1 E0 E1  Config 2

;===============================================================================
; $E57F: Bank + PPU Init + JMP Patch
;===============================================================================
.proc BankPpuInit
  LDA #$00                                      ; $E57F: A9 00
  JSR SoundWrapperA                             ; $E581: 20 73 E6  Sound off
  JSR PaletteUpload                             ; $E584: 20 90 E5
  LDA #$4C                                      ; $E587: A9 4C  JMP opcode
  STA $00A5                                     ; $E589: 8D A5 00  Patch RAM at $00A5
  STA NAMCO_CTRL                                ; $E58C: 8D 00 F8  Write mapper
  RTS                                           ; $E58F: 60
.endproc

;===============================================================================
; $E590: Sound Init + IRQ Timer
; Initializes APU, clears sound RAM, uploads wavetable
;===============================================================================
.proc SoundInit
sound_irq_lo   = $07F6
sound_irq_hi   = $07F7
sound_ram_ptr  = $07F2

  LDA #$00                                      ; $E590: A9 00
  STA APU_SND_CHN                               ; $E592: 8D 15 40  $4015 - silence all channels
  STA sound_irq_lo                              ; $E595: 8D F6 07
  LDA #$10                                      ; $E598: A9 10
  STA APU_PULSE1_VOL                            ; $E59A: 8D 00 40  $4000
  STA APU_PULSE2_VOL                            ; $E59D: 8D 04 40  $4004
  STA APU_NOISE_VOL                             ; $E5A0: 8D 0C 40  $400C
  LDA #$08                                      ; $E5A3: A9 08
  STA APU_PULSE1_SWEEP                          ; $E5A5: 8D 01 40  $4001
  STA APU_PULSE2_SWEEP                          ; $E5A8: 8D 05 40  $4005
  LDA #$00                                      ; $E5AB: A9 00
  STA APU_TRI_LINEAR                            ; $E5AD: 8D 08 40  $4008
  STA sound_ram_ptr                             ; $E5B0: 8D F2 07  $07F2

  ; Clear sound RAM $0700-$07FF
  TAX                                           ; $E5B3: AA
@clear_loop:
  LDA #$FF                                      ; $E5B4: A9 FF
  STA $0700,X                                   ; $E5B6: 9D 00 07
  LDA #$00                                      ; $E5B9: A9 00
  STA $0706,X                                   ; $E5BB: 9D 06 07
  TXA                                           ; $E5BE: 8A
  CLC                                           ; $E5BF: 18
  ADC #$16                                      ; $E5C0: 69 16
  TAX                                           ; $E5C2: AA
  CMP #$F2                                      ; $E5C3: C9 F2
  BNE @clear_loop                               ; $E5C5: D0 ED

  ; Upload wavetable to Namco-163 $4800
  LDA #$C0                                      ; $E5C7: A9 C0
  STA NAMCO_CTRL                                ; $E5C9: 8D 00 F8  Select wavetable address
  LDX #$3F                                      ; $E5CC: A2 3F
  LDA #$00                                      ; $E5CE: A9 00
@wavetable_loop:
  STA NAMCO_SOUND                               ; $E5D0: 8D 00 48  Write to sound RAM
  DEX                                           ; $E5D3: CA
  BPL @wavetable_loop                           ; $E5D4: 10 FA

  ; Upload wavetable init data
  LDX #$80                                      ; $E5D6: A2 80
  STX NAMCO_CTRL                                ; $E5D8: 8E 00 F8  Set auto-increment address
  LDX #$00                                      ; $E5DB: A2 00
@wt_init_loop:
  LDA WavetableInitData,X                       ; $E5DD: BD A6 E6
  STA NAMCO_SOUND                               ; $E5E0: 8D 00 48
  INX                                           ; $E5E3: E8
  CPX #$20                                      ; $E5E4: E0 20
  BCC @wt_init_loop                             ; $E5E6: 90 F5
  LDX #$64                                      ; $E5E8: A2 64
  LDA #$F0                                      ; $E5EA: A9 F0
  JSR WavetableWriteDelay                       ; $E5EC: 20 FA E5
  LDX #$7F                                      ; $E5EF: A2 7F
  LDA #$30                                      ; $E5F1: A9 30
WavetableWriteEntry:
  STX NAMCO_CTRL                                ; $E5F3: 8E 00 F8
  STA NAMCO_SOUND                               ; $E5F6: 8D 00 48
  RTS                                           ; $E5F9: 60
.endproc

;===============================================================================
; $E5FA: Wavetable Write Delay
; Params: A = value, X = register
;===============================================================================
.proc WavetableWriteDelay
  PHA                                           ; $E5FA: 48
@loop:
  PLA                                           ; $E5FB: 68
  JSR WavetableWriteEntry                       ; $E5FC: 20 F3 E5  Delay sub-entry ($E5F3)
  PHA                                           ; $E5FF: 48
  TXA                                           ; $E600: 8A
  CLC                                           ; $E601: 18
  ADC #$08                                      ; $E602: 69 08
  TAX                                           ; $E604: AA
  BPL @loop                                     ; $E605: 10 F4
  PLA                                           ; $E607: 68
  RTS                                           ; $E608: 60
.endproc

;===============================================================================
; $E609: Sound Note Player
; Reads 4-byte note entry from $8000+A*4 in banked ROM.
; Validates channel, copies entry bytes 1-3 to $0701-$0703+X,
; stores (byte3+$40) low ptr at $0703+X and $00 high ptr at $0700+X.
;===============================================================================
.proc SoundNotePlayer
note_ptr_lo    = $F0
note_ptr_hi    = $F1
sound_channel_ram = $07F6                       ; RAM copy of Namco sound channel

  LDY #$22                                      ; $E609: A0 22           ; window param for display setup
  JSR WindowDisplaySetup                        ; $E60B: 20 5F F2        ; prepare display/window context
  LDY #$00                                      ; $E60E: A0 00           ; Y=0 for indirect indexed access
  STY note_ptr_hi                               ; $E610: 8C F1 00        ; clear high byte of pointer
  ASL A                                         ; $E613: 0A              ; A = entry_index * 2 (shift 1)
  ROL note_ptr_hi                               ; $E614: 2E F1 00        ; rotate carry into high byte
  ASL A                                         ; $E617: 0A              ; A = entry_index * 4 (shift 2)
  ROL note_ptr_hi                               ; $E618: 2E F1 00        ; rotate carry into high byte
  CLC                                           ; $E61B: 18              ; prepare 16-bit add
  ADC #$00                                      ; $E61C: 69 00           ; add leftover carry to low byte
  STA note_ptr_lo                               ; $E61E: 8D F0 00        ; $F0 = low byte of (index*4)
  LDA #$80                                      ; $E621: A9 80           ; base address $8000 (PRG_SLOT0)
  ADC note_ptr_hi                               ; $E623: 6D F1 00        ; $80 + high byte of (index*4)
  STA note_ptr_hi                               ; $E626: 8D F1 00        ; $F1 = high byte → ptr = $8000+A*4
  TXA                                           ; $E629: 8A              ; save X (slot index in $0700)
  PHA                                           ; $E62A: 48              ; push X to stack
  LDA (note_ptr_lo),Y                           ; $E62B: B1 F0           ; read entry byte 0 (Y=0)
  TAX                                           ; $E62D: AA              ; X = entry byte 0 (lookup index)
  LDA $0700,X                                   ; $E62E: BD 00 07        ; load stored ptr high from slot
  CMP #$FF                                      ; $E631: C9 FF           ; $FF = end-of-sequence sentinel
  BEQ SoundNotePlayer_done                      ; $E633: F0 14           ; if sentinel → skip channel setup
  LDA $0701,X                                   ; $E635: BD 01 07        ; load channel index from slot
  CMP #$04                                      ; $E638: C9 04           ; must be valid channel (0-3)
  BCS SoundNotePlayer_done                      ; $E63A: B0 0D           ; if ≥ 4 → skip channel setup
  TAY                                           ; $E63C: A8              ; Y = sound channel index (0-3)
  LDA SoundChannelTable,Y                       ; $E63D: B9 67 E6        ; lookup Namco channel bits
  AND sound_channel_ram                         ; $E640: 2D F6 07        ; mask with current channel RAM
  STA sound_channel_ram                         ; $E643: 8D F6 07        ; save masked channel to RAM
  STA APU_SND_CHN                               ; $E646: 8D 15 40        ; write to APU_SND_CHN (channel enable)
SoundNotePlayer_done:                                                   ; entry[0]=$FF → skip to LDY
  LDY #$01                                      ; $E649: A0 01           ; Y=1: start reading entry byte 1
  LDA (note_ptr_lo),Y                           ; $E64B: B1 F0           ; read entry byte 1
  STA $0701,X                                   ; $E64D: 9D 01 07        ; store to slot byte 1
  INY                                           ; $E650: C8              ; Y=2
  LDA (note_ptr_lo),Y                           ; $E651: B1 F0           ; read entry byte 2
  STA $0702,X                                   ; $E653: 9D 02 07        ; store to slot byte 2
  INY                                           ; $E656: C8              ; Y=3
  LDA (note_ptr_lo),Y                           ; $E657: B1 F0           ; read entry byte 3
  CLC                                           ; $E659: 18              ; prepare addition
  ADC #$40                                      ; $E65A: 69 40           ; A = byte3 + $40 (low ptr byte)
  STA $0703,X                                   ; $E65C: 9D 03 07        ; store to slot byte 3
  LDA #$00                                      ; $E65F: A9 00           ; high byte = $00
  STA $0700,X                                   ; $E661: 9D 00 07        ; store to slot byte 0 (ptr high)
  PLA                                           ; $E664: 68              ; restore X
  TAX                                           ; $E665: AA
  RTS                                           ; $E666: 60
.endproc

;===============================================================================
; $E667: Sound Channel Table (4 bytes)
; Maps logical channel index (0-3) to Namco-163 hardware channel
;===============================================================================
SoundChannelTable:
  .byte $0E, $0D, $0B, $07

;===============================================================================
; $E66B-$E6A5: Sound Wrapper Functions (7 variants)
; Each plays a sound ID then increments and plays again
;===============================================================================
SoundWrapper0:
  PHA                                           ; $E66B: 48
  JSR SoundNotePlayer                           ; $E66C: 20 09 E6
  PLA                                           ; $E66F: 68
  CLC                                           ; $E670: 18
  ADC #$01                                      ; $E671: 69 01

SoundWrapperA:
  PHA                                           ; $E673: 48
  JSR SoundNotePlayer                           ; $E674: 20 09 E6
  PLA                                           ; $E677: 68
  CLC                                           ; $E678: 18
  ADC #$01                                      ; $E679: 69 01

SoundWrapperB:
  PHA                                           ; $E67B: 48
  JSR SoundNotePlayer                           ; $E67C: 20 09 E6
  PLA                                           ; $E67F: 68
  CLC                                           ; $E680: 18
  ADC #$01                                      ; $E681: 69 01

SoundWrapperC:
  PHA                                           ; $E683: 48
  JSR SoundNotePlayer                           ; $E684: 20 09 E6
  PLA                                           ; $E687: 68
  CLC                                           ; $E688: 18
  ADC #$01                                      ; $E689: 69 01

SoundWrapperD:
  PHA                                           ; $E68B: 48
  JSR SoundNotePlayer                           ; $E68C: 20 09 E6
  PLA                                           ; $E68F: 68
  CLC                                           ; $E690: 18
  ADC #$01                                      ; $E691: 69 01

SoundWrapperE:
  PHA                                           ; $E693: 48
  JSR SoundNotePlayer                           ; $E694: 20 09 E6
  PLA                                           ; $E697: 68
  CLC                                           ; $E698: 18
  ADC #$01                                      ; $E699: 69 01

SoundWrapperF:
  PHA                                           ; $E69B: 48
  JSR SoundNotePlayer                           ; $E69C: 20 09 E6
  PLA                                           ; $E69F: 68
  CLC                                           ; $E6A0: 18
  ADC #$01                                      ; $E6A1: 69 01
  JMP SoundNotePlayer                           ; $E6A3: 4C 09 E6

;===============================================================================
; $E6A6: Wavetable Init Data (32 bytes)
;===============================================================================
WavetableInitData:
  .byte $FF, $00, $00, $00, $00, $00, $00, $00   ; $E6A6: FF 00 00 00 00 00 00 00
  .byte $FF, $FF, $00, $00, $00, $00, $00, $00   ; $E6AE: FF FF 00 00 00 00 00 00
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF   ; $E6B6: FF FF FF FF FF FF FF FF
  .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00   ; $E6BE: FF 00 FF 00 FF 00 FF 00

;===============================================================================
; $E6C6: Controller Read (Both Pads)
; Reads 8-bit serial data from $4016/$4017 for both controllers
; Output: $0081 = pad1 edge, $0083 = pad1 raw, $0084 = pad1 prev
;         $0082 = pad2 edge, $0085 = pad2 raw, $0086 = pad2 prev
;===============================================================================
.proc ControllerRead
  LDA addr_pad1_raw                             ; $E6C6: AD 83 00
  STA addr_pad1_prev                            ; $E6C9: 8D 84 00  Save previous pad1
  LDA addr_pad2_raw                             ; $E6CC: AD 85 00
  STA addr_pad2_prev                            ; $E6CF: 8D 86 00  Save previous pad2
  LDA #$01                                      ; $E6D2: A9 01
  STA APU_JOY1                                  ; $E6D4: 8D 16 40  Strobe controller (start)
  LDA #$00                                      ; $E6D7: A9 00
  STA APU_JOY1                                  ; $E6D9: 8D 16 40  Strobe controller (end)
  LDX #$07                                      ; $E6DC: A2 07      8 bits per controller
@read_loop:
  LDA APU_JOY1                                  ; $E6DE: AD 16 40  Read pad 1 bit
  AND #$03                                      ; $E6E1: 29 03
  CMP #$01                                      ; $E6E3: C9 01
  ROR addr_pad1_raw                             ; $E6E5: 6E 83 00  Shift into pad1 raw
  LDA APU_JOY2                                  ; $E6E8: AD 17 40  Read pad 2 bit
  AND #$03                                      ; $E6EB: 29 03
  CMP #$01                                      ; $E6ED: C9 01
  ROR addr_pad2_raw                             ; $E6EF: 6E 85 00  Shift into pad2 raw
  DEX                                           ; $E6F2: CA
  BPL @read_loop                                ; $E6F3: 10 E9      Loop 8 times
  LDA addr_pad1_raw                             ; $E6F5: AD 83 00
  EOR addr_pad1_prev                            ; $E6F8: 4D 84 00
  AND addr_pad1_raw                             ; $E6FB: 2D 83 00
  STA addr_pad1_edge                            ; $E6FE: 8D 81 00  Pad 1 edge-triggered
  LDA addr_pad2_raw                             ; $E701: AD 85 00
  EOR addr_pad2_prev                            ; $E704: 4D 86 00
  AND addr_pad2_raw                             ; $E707: 2D 85 00
  STA addr_pad2_edge                            ; $E70A: 8D 82 00  Pad 2 edge-triggered
  RTS                                           ; $E70D: 60
.endproc

;===============================================================================
; $E70E: Palette Upload
; Uploads palette data from $0100-$011F to PPU $3F00
;===============================================================================
.proc PaletteUpload
  LDA addr_ppu_ctrl_ram                         ; $E70E: AD 8B 00  Load PPU ctrl mirror
  AND #$FB                                      ; $E711: 29 FB     Clear VRAM inc bit (set +1)
  STA PPU_CTRL                                  ; $E713: 8D 00 20  Apply to PPU
  LDA PPU_STATUS                                ; $E716: AD 02 20  Reset PPU address latch
  LDY #$00                                      ; $E719: A0 00
  STY $007D                                     ; $E71B: 8C 7D 00
  LDA #$3F                                      ; $E71E: A9 3F
  STA PPU_ADDR                                  ; $E720: 8D 06 20  PPU addr high = $3F
  STY PPU_ADDR                                  ; $E723: 8C 06 20  PPU addr low = $00
@upload_loop:
  LDA $0100,Y                                   ; $E726: B9 00 01
  STA PPU_DATA                                  ; $E729: 8D 07 20
  LDA $0101,Y                                   ; $E72C: B9 01 01
  STA PPU_DATA                                  ; $E72F: 8D 07 20
  INY                                           ; $E732: C8
  INY                                           ; $E733: C8
  CPY #$20                                      ; $E734: C0 20     32 bytes total
  BCC @upload_loop                              ; $E736: 90 EE
  LDA #$3F                                      ; $E738: A9 3F
  STA PPU_ADDR                                  ; $E73A: 8D 06 20  Reset PPU addr
  LDA #$00                                      ; $E73D: A9 00
  STA PPU_ADDR                                  ; $E73F: 8D 06 20  → $0000
  STA PPU_ADDR                                  ; $E742: 8D 06 20
  STA PPU_ADDR                                  ; $E745: 8D 06 20
  RTS                                           ; $E748: 60
.endproc

;===============================================================================
; $E749/$E74D: PPU Mask Helpers
; $E749 entry: enable rendering (mask=$1E)
; $E74D entry: disable rendering (mask=$00)
;===============================================================================
PpuMaskEnable:
  LDA #$1E                                      ; $E749: A9 1E
  BNE :+                                        ; $E74B: D0 02     (always taken)
PpuMaskDisable:
  LDA #$00                                      ; $E74D: A9 00
: STA addr_ppu_mask_ram                         ; $E74F: 8D 8C 00
  RTS                                           ; $E752: 60

;===============================================================================
; $E753/$E768: PPU Ctrl NMI Helpers
; $E753 entry: enable NMI (set bit 7 of PPU_CTRL)
; $E768 entry: disable NMI (clear bit 7 of PPU_CTRL)
;===============================================================================
NmiEnable:
  LDA PPU_STATUS                                ; $E753: AD 02 20  Reset PPU latch
  LDY #$00                                      ; $E756: A0 00
  STY $007B                                     ; $E758: 8C 7B 00
  STY $007E                                     ; $E75B: 8C 7E 00
  LDA addr_ppu_ctrl_ram                         ; $E75E: AD 8B 00
  ORA #$80                                      ; $E761: 09 80     Set NMI enable bit
  STA addr_ppu_ctrl_ram                         ; $E763: 8D 8B 00
  BNE :+                                        ; $E766: D0 08     (always taken)
NmiDisable:
  LDA addr_ppu_ctrl_ram                         ; $E768: AD 8B 00
  AND #$7F                                      ; $E76B: 29 7F     Clear NMI enable bit
  STA addr_ppu_ctrl_ram                         ; $E76D: 8D 8B 00
: STA PPU_CTRL                                  ; $E770: 8D 00 20
  RTS                                           ; $E773: 60

;===============================================================================
; $E774: Nametable Fill Mode 1
; Sets NT CHR banks to CIRAM, fills nametables $2000/$2400/$2800
; with tile=$01, attr=$00
;===============================================================================
.proc NametableFill1
fill_tile     = $02
fill_attr     = $03
page_count    = $01

  LDA #$E0                                      ; $E774: A9 E0     NT0 = CIRAM page 0
  STA NAMCO_CHR_BANK_0                                     ; $E776: 8D 00 C0
  LDA #$E1                                      ; $E779: A9 E1     NT1 = CIRAM page 1
  STA NAMCO_CHR_BANK_1                                     ; $E77B: 8D 00 C8
  LDA #$E0                                      ; $E77E: A9 E0     NT2 = CIRAM page 0
  STA NAMCO_CHR_BANK_2                                     ; $E780: 8D 00 D0
  LDA #$E1                                      ; $E783: A9 E1     NT3 = CIRAM page 1
  STA NAMCO_CHR_BANK_3                                     ; $E785: 8D 00 D8
  LDA PPU_STATUS                                ; $E788: AD 02 20  Reset PPU latch
  LDA #$01                                      ; $E78B: A9 01
  STA fill_tile                                 ; $E78D: 85 02
  LDA #$00                                      ; $E78F: A9 00
  STA fill_attr                                 ; $E791: 85 03
  LDA #$20                                      ; $E793: A9 20     Nametable $2000
  JSR NametableFillSub                          ; $E795: 20 B5 E7
  LDA PPU_STATUS                                ; $E798: AD 02 20  Reset PPU latch
  LDA #$01                                      ; $E79B: A9 01
  STA fill_tile                                 ; $E79D: 85 02
  LDA #$00                                      ; $E79F: A9 00
  STA fill_attr                                 ; $E7A1: 85 03
  LDA #$24                                      ; $E7A3: A9 24     Nametable $2400
  JSR NametableFillSub                          ; $E7A5: 20 B5 E7
  LDA PPU_STATUS                                ; $E7A8: AD 02 20  Reset PPU latch
  LDA #$01                                      ; $E7AB: A9 01
  STA fill_tile                                 ; $E7AD: 85 02
  LDA #$00                                      ; $E7AF: A9 00
  STA fill_attr                                 ; $E7B1: 85 03
  LDA #$28                                      ; $E7B3: A9 28     Nametable $2800 (fall through)
.endproc

;===============================================================================
; $E7B5: Nametable Fill Subroutine
; Fills one nametable (1024 bytes) starting at PPU address A:$00
; Input: A = high byte of PPU address, $02 = tile value, $03 = attr value
; Writes 960 bytes of tile, 64 bytes of attribute
;===============================================================================
.proc NametableFillSub
fill_tile     = $02
fill_attr     = $03
page_count    = $01

  STA PPU_ADDR                                  ; $E7B5: 8D 06 20  PPU addr high
  LDA #$00                                      ; $E7B8: A9 00
  STA PPU_ADDR                                  ; $E7BA: 8D 06 20  PPU addr low
  TAY                                           ; $E7BD: A8        Y = 0
  LDA #$03                                      ; $E7BE: A9 03
  STA page_count                                ; $E7C0: 85 01     3 pages = 768 bytes
  LDA fill_tile                                 ; $E7C2: A5 02
@tile_loop:
  STA PPU_DATA                                  ; $E7C4: 8D 07 20
  DEY                                           ; $E7C7: 88
  BNE @tile_loop                                ; $E7C8: D0 FA
  DEC page_count                                ; $E7CA: C6 01
  BNE @tile_loop                                ; $E7CC: D0 F6
@tile_extra:
  STA PPU_DATA                                  ; $E7CE: 8D 07 20  192 more tiles
  INY                                           ; $E7D1: C8
  CPY #$C0                                      ; $E7D2: C0 C0
  BCC @tile_extra                               ; $E7D4: 90 F8
  LDA fill_attr                                 ; $E7D6: A5 03
@attr_loop:
  STA PPU_DATA                                  ; $E7D8: 8D 07 20  64 attr bytes
  INY                                           ; $E7DB: C8
  BNE @attr_loop                                ; $E7DC: D0 FA
  RTS                                           ; $E7DE: 60
.endproc

;===============================================================================
; $E7DF: Nametable Fill Mode 2
; Same as Fill1 but with tile=$01, attr=$AA
;===============================================================================
.proc NametableFill2
fill_tile     = $02
fill_attr     = $03

  LDA #$E0                                      ; $E7DF: A9 E0     NT0 = CIRAM page 0
  STA NAMCO_CHR_BANK_0                                     ; $E7E1: 8D 00 C0
  LDA #$E1                                      ; $E7E4: A9 E1     NT1 = CIRAM page 1
  STA NAMCO_CHR_BANK_1                                     ; $E7E6: 8D 00 C8
  LDA #$E0                                      ; $E7E9: A9 E0     NT2 = CIRAM page 0
  STA NAMCO_CHR_BANK_2                                     ; $E7EB: 8D 00 D0
  LDA #$E1                                      ; $E7EE: A9 E1     NT3 = CIRAM page 1
  STA NAMCO_CHR_BANK_3                                     ; $E7F0: 8D 00 D8
  LDA PPU_STATUS                                ; $E7F3: AD 02 20  Reset PPU latch
  LDA #$01                                      ; $E7F6: A9 01
  STA fill_tile                                 ; $E7F8: 85 02
  LDA #$AA                                      ; $E7FA: A9 AA
  STA fill_attr                                 ; $E7FC: 85 03
  LDA #$20                                      ; $E7FE: A9 20     Nametable $2000
  JSR NametableFillSub                          ; $E800: 20 B5 E7
  LDA PPU_STATUS                                ; $E803: AD 02 20  Reset PPU latch
  LDA #$01                                      ; $E806: A9 01
  STA fill_tile                                 ; $E808: 85 02
  LDA #$AA                                      ; $E80A: A9 AA
  STA fill_attr                                 ; $E80C: 85 03
  LDA #$24                                      ; $E80E: A9 24     Nametable $2400
  JSR NametableFillSub                          ; $E810: 20 B5 E7
  LDA PPU_STATUS                                ; $E813: AD 02 20  Reset PPU latch
  LDA #$01                                      ; $E816: A9 01
  STA fill_tile                                 ; $E818: 85 02
  LDA #$AA                                      ; $E81A: A9 AA
  STA fill_attr                                 ; $E81C: 85 03
  LDA #$28                                      ; $E81E: A9 28     Nametable $2800
  JMP NametableFillSub                          ; $E820: 4C B5 E7
.endproc

;===============================================================================
; $E823: Sprite Buffer Init
; Two entry points:
;   $E823 - fills $0204-$02FF with $F0 (preserves sprite 0)
;   $E825 - fills $0200-$02FF with $F0 (all sprites off-screen)
;===============================================================================
.proc SpriteBufferInit
  LDY #$04                                      ; $E823: A0 04
SpriteBufferInitAll:
  LDY #$00                                      ; $E825: A0 00
  LDA #$F0                                      ; $E827: A9 F0
@fill_loop:
  STA $0200,Y                                   ; $E829: 99 00 02
  INY                                           ; $E82C: C8
  BNE @fill_loop                                ; $E82D: D0 FA
  RTS                                           ; $E82F: 60
.endproc

;===============================================================================
; $E830: Sprite Clear From Index
; Clears sprites from index in $007C onward (4 bytes per sprite)
; If $007C == $FF, does nothing
;===============================================================================
.proc SpriteClearFromIndex
  LDX $7C                                       ; $E830: AE 7C 00
  CPX #$FF                                      ; $E833: E0 FF
  BEQ @done                                     ; $E835: F0 0B
@clear_loop:
  LDA #$F0                                      ; $E837: A9 F0
  STA $0200,X                                   ; $E839: 9D 00 02
  INX                                           ; $E83C: E8
  INX                                           ; $E83D: E8
  INX                                           ; $E83E: E8
  INX                                           ; $E83F: E8
  BNE @clear_loop                               ; $E840: D0 F5
@done:
  RTS                                           ; $E842: 60
.endproc

;===============================================================================
; $E843: Random Below 100
; Returns: A = random value in range [0, 99]
;===============================================================================
.proc RandomBelow100
@loop:
  JSR RandomByte                                ; $E843: 20 7A E8
  CMP #$64                                      ; $E846: C9 64
  BCS @loop                                     ; $E848: B0 F9
  RTS                                           ; $E84A: 60
.endproc

;===============================================================================
; $E84B: Random Div 2
; Returns: A = random byte / 2 (range [0, 127])
;===============================================================================
.proc RandomDiv2
  JSR RandomByte                                ; $E84B: 20 7A E8
  LSR                                           ; $E84E: 4A
  RTS                                           ; $E84F: 60
.endproc

;===============================================================================
; $E850: Random Mod Power of 2
; Multiple entry points: RandomMod4, RandomMod8, RandomMod16
;===============================================================================
.proc RandomModPow2
RandomMod4:
  JSR RandomByte                                ; $E850: 20 7A E8
  AND #$03                                      ; $E853: 29 03
  RTS                                           ; $E855: 60

RandomMod8:
  JSR RandomByte                                ; $E856: 20 7A E8
  AND #$07                                      ; $E859: 29 07
  RTS                                           ; $E85B: 60

RandomMod16:
  JSR RandomByte                                ; $E85C: 20 7A E8
  AND #$0F                                      ; $E85F: 29 0F
  RTS                                           ; $E861: 60
.endproc

;===============================================================================
; $E862: Random Below Threshold
; Input: A = threshold (max value exclusive)
; Returns: A = random value in [0, threshold-1]
; If threshold < 15, uses AND #$0F mask optimization
;===============================================================================
.proc RandomBelowThreshold
threshold = $10

  STA threshold                                 ; $E862: 85 10
  CMP #$0F                                      ; $E864: C9 0F
  BCS @full_range                               ; $E866: B0 0A
@loop_masked:
  JSR RandomByte                                ; $E868: 20 7A E8
  AND #$0F                                      ; $E86B: 29 0F
  CMP threshold                                 ; $E86D: C5 10
  BCS @loop_masked                              ; $E86F: B0 F7
  RTS                                           ; $E871: 60
@full_range:
  JSR RandomByte                                ; $E872: 20 7A E8
  CMP threshold                                 ; $E875: C5 10
  BCS @full_range                               ; $E877: B0 F9
  RTS                                           ; $E879: 60
.endproc

;===============================================================================
; $E87A: Random Byte (RNG Core)
; Table lookup using index at $0050, table at $E8BA
; Returns: A = pseudo-random byte
; Preserves: X (saved/restored via $0051)
;===============================================================================
.proc RandomByte
  STX addr_rng_saved_x                          ; $E87A: 8E 51 00
  LDX addr_rng_index                            ; $E87D: AE 50 00
  LDA RandomTable,X                             ; $E880: BD BA E8
  INC addr_rng_index                            ; $E883: EE 50 00
  LDX addr_rng_saved_x                          ; $E886: AE 51 00
  RTS                                           ; $E889: 60
.endproc

;===============================================================================
; $E88A: Random Variants (3 additional RNG instances)
; RandomByte2 uses index at $0052
; RandomByte3 uses index at $0054
; RandomByte4 uses index at $0055
;===============================================================================
.proc RandomVariants
RandomByte2:
  STX addr_rng_temp_x                           ; $E88A: 8E 53 00
  LDX addr_rng2_index                           ; $E88D: AE 52 00
  LDA RandomTable,X                             ; $E890: BD BA E8
  INC addr_rng2_index                           ; $E893: EE 52 00
  LDX addr_rng_temp_x                           ; $E896: AE 53 00
  RTS                                           ; $E899: 60

RandomByte3:
  STX addr_rng_temp_x                           ; $E89A: 8E 53 00
  LDX addr_rng3_index                           ; $E89D: AE 54 00
  LDA RandomTable,X                             ; $E8A0: BD BA E8
  INC addr_rng3_index                           ; $E8A3: EE 54 00
  LDX addr_rng_temp_x                           ; $E8A6: AE 53 00
  RTS                                           ; $E8A9: 60

RandomByte4:
  STX addr_rng_temp_x                           ; $E8AA: 8E 53 00
  LDX addr_rng4_index                           ; $E8AD: AE 55 00
  LDA RandomTable,X                             ; $E8B0: BD BA E8
  INC addr_rng4_index                           ; $E8B3: EE 55 00
  LDX addr_rng_temp_x                           ; $E8B6: AE 53 00
  RTS                                           ; $E8B9: 60
.endproc

;===============================================================================
; $E8BA-$E9B9: Random Number Table (256 bytes)
; Pre-computed permutation table for RNG
;===============================================================================
RandomTable:
  .byte $3E,$4E,$4F,$83,$0E,$C9,$7F,$5D         ; $E8BA: 3E 4E 4F 83 0E C9 7F 5D
  .byte $FC,$E6,$BA,$01,$F8,$00,$F4,$0A         ; $E8C2: FC E6 BA 01 F8 00 F4 0A
  .byte $E5,$A9,$8D,$D1,$E8,$DB,$DE,$81         ; $E8CA: E5 A9 8D D1 E8 DB DE 81
  .byte $95,$72,$08,$9A,$C7,$49,$C8,$23         ; $E8D2: 95 72 08 9A C7 49 C8 23
  .byte $39,$37,$E0,$91,$C3,$33,$9B,$5F         ; $E8DA: 39 37 E0 91 C3 33 9B 5F
  .byte $BE,$41,$EE,$74,$E2,$0B,$47,$7E         ; $E8E2: BE 41 EE 74 E2 0B 47 7E
  .byte $BF,$60,$BB,$20,$61,$05,$B2,$94         ; $E8EA: BF 60 BB 20 61 05 B2 94
  .byte $B6,$E4,$3A,$21,$1E,$B4,$8C,$CE         ; $E8F2: B6 E4 3A 21 1E B4 8C CE
  .byte $7B,$FE,$22,$DC,$18,$C4,$6D,$FB         ; $E8FA: 7B FE 22 DC 18 C4 6D FB
  .byte $CD,$27,$A0,$09,$6E,$38,$8A,$04         ; $E902: CD 27 A0 09 6E 38 8A 04
  .byte $7C,$56,$97,$5A,$A8,$4D,$78,$B5         ; $E90A: 7C 56 97 5A A8 4D 78 B5
  .byte $6C,$AA,$03,$1A,$4A,$0D,$26,$82         ; $E912: 6C AA 03 1A 4A 0D 26 82
  .byte $AD,$02,$A1,$B9,$A3,$6B,$D8,$0C         ; $E91A: AD 02 A1 B9 A3 6B D8 0C
  .byte $4C,$AE,$19,$45,$5B,$9C,$16,$07         ; $E922: 4C AE 19 45 5B 9C 16 07
  .byte $89,$51,$90,$29,$F5,$62,$F7,$CB         ; $E92A: 89 51 90 29 F5 62 F7 CB
  .byte $F1,$53,$FF,$14,$65,$D0,$87,$35         ; $E932: F1 53 FF 14 65 D0 87 35
  .byte $10,$73,$7A,$9F,$EB,$D9,$3C,$EF         ; $E93A: 10 73 7A 9F EB D9 3C EF
  .byte $9E,$D7,$3D,$6F,$D6,$84,$AB,$11         ; $E942: 9E D7 3D 6F D6 84 AB 11
  .byte $CA,$D2,$88,$17,$E1,$A6,$52,$8E         ; $E94A: CA D2 88 17 E1 A6 52 8E
  .byte $5E,$36,$24,$44,$28,$A4,$55,$A7         ; $E952: 5E 36 24 44 28 A4 55 A7
  .byte $C2,$FD,$76,$2E,$B7,$D5,$F6,$64         ; $E95A: C2 FD 76 2E B7 D5 F6 64
  .byte $15,$31,$99,$93,$C0,$8F,$B3,$FA         ; $E962: 15 31 99 93 C0 8F B3 FA
  .byte $E9,$E3,$67,$4B,$85,$32,$C6,$69         ; $E96A: E9 E3 67 4B 85 32 C6 69
  .byte $48,$DF,$A2,$EC,$98,$6A,$E7,$D4         ; $E972: 48 DF A2 EC 98 6A E7 D4
  .byte $1C,$F3,$58,$50,$ED,$2B,$1D,$86         ; $E97A: 1C F3 58 50 ED 2B 1D 86
  .byte $F0,$71,$BD,$34,$1B,$AF,$30,$2D         ; $E982: F0 71 BD 34 1B AF 30 2D
  .byte $68,$CC,$0F,$57,$EA,$92,$8B,$3F         ; $E98A: 68 CC 0F 57 EA 92 8B 3F
  .byte $3B,$AC,$B8,$C1,$2F,$F2,$46,$75         ; $E992: 3B AC B8 C1 2F F2 46 75
  .byte $96,$7D,$2A,$79,$40,$DA,$9D,$25         ; $E99A: 96 7D 2A 79 40 DA 9D 25
  .byte $12,$42,$54,$D3,$1F,$80,$5C,$59         ; $E9A2: 12 42 54 D3 1F 80 5C 59
  .byte $43,$F9,$B0,$DD,$63,$A5,$77,$CF         ; $E9AA: 43 F9 B0 DD 63 A5 77 CF
  .byte $13,$2C,$66,$BC,$70,$B1,$C5,$06         ; $E9B2: 13 2C 66 BC 70 B1 C5 06

;===============================================================================
; $E9BA: Math - Binary to BCD (24-bit)
; Input: $01/$02/$03 = 24-bit binary value (LE, mod 1,000,000)
; Output: $07 = tens|ones, $08 = thousands|hundreds, $09 = hthou|tthou
; Clobbers: $01-$05
;===============================================================================
.proc MathBinToBcd
dividend_lo   = $01
dividend_mid  = $02
dividend_hi   = $03
temp_lo       = $04
temp_mid      = $05
bcd_tens_ones = $07
bcd_thou_hund = $08
bcd_htth_tth  = $09

  LDA #$00                                      ; $E9BA: A9 00
  STA bcd_tens_ones                             ; $E9BC: 85 07
  STA bcd_thou_hund                             ; $E9BE: 85 08
  STA bcd_htth_tth                              ; $E9C0: 85 09

  ; Subtract 1,000,000 ($0F4240) repeatedly - clamping
@clamp_million:
  LDA dividend_lo                               ; $E9C2: A5 01
  SEC                                           ; $E9C4: 38
  SBC #$40                                      ; $E9C5: E9 40
  STA temp_lo                                   ; $E9C7: 85 04
  LDA dividend_mid                              ; $E9C9: A5 02
  SBC #$42                                      ; $E9CB: E9 42
  STA temp_mid                                  ; $E9CD: 85 05
  LDA dividend_hi                               ; $E9CF: A5 03
  SBC #$0F                                      ; $E9D1: E9 0F
  BCC @sub_100k                                 ; $E9D3: 90 0D
  STA dividend_hi                               ; $E9D5: 85 03
  LDA temp_lo                                   ; $E9D7: A5 04
  STA dividend_lo                               ; $E9D9: 85 01
  LDA temp_mid                                  ; $E9DB: A5 05
  STA dividend_mid                              ; $E9DD: 85 02
  JMP @clamp_million                            ; $E9DF: 4C C2 E9

  ; Subtract 100,000 ($0186A0) -> hundred-thousands digit
@sub_100k:
  LDA dividend_lo                               ; $E9E2: A5 01
  SEC                                           ; $E9E4: 38
  SBC #$A0                                      ; $E9E5: E9 A0
  STA temp_lo                                   ; $E9E7: 85 04
  LDA dividend_mid                              ; $E9E9: A5 02
  SBC #$86                                      ; $E9EB: E9 86
  STA temp_mid                                  ; $E9ED: 85 05
  LDA dividend_hi                               ; $E9EF: A5 03
  SBC #$01                                      ; $E9F1: E9 01
  BCC @sub_10k                                  ; $E9F3: 90 12
  STA dividend_hi                               ; $E9F5: 85 03
  LDA temp_lo                                   ; $E9F7: A5 04
  STA dividend_lo                               ; $E9F9: 85 01
  LDA temp_mid                                  ; $E9FB: A5 05
  STA dividend_mid                              ; $E9FD: 85 02
  LDA bcd_htth_tth                              ; $E9FF: A5 09
  ADC #$0F                                      ; $EA01: 69 0F
  STA bcd_htth_tth                              ; $EA03: 85 09
  BNE @sub_100k                                 ; $EA05: D0 DB

  ; Subtract 10,000 ($002710) -> ten-thousands digit
@sub_10k:
  LDA dividend_lo                               ; $EA07: A5 01
  SEC                                           ; $EA09: 38
  SBC #$10                                      ; $EA0A: E9 10
  STA temp_lo                                   ; $EA0C: 85 04
  LDA dividend_mid                              ; $EA0E: A5 02
  SBC #$27                                      ; $EA10: E9 27
  STA temp_mid                                  ; $EA12: 85 05
  LDA dividend_hi                               ; $EA14: A5 03
  SBC #$00                                      ; $EA16: E9 00
  BCC @sub_1k                                   ; $EA18: 90 0E
  STA dividend_hi                               ; $EA1A: 85 03
  LDA temp_lo                                   ; $EA1C: A5 04
  STA dividend_lo                               ; $EA1E: 85 01
  LDA temp_mid                                  ; $EA20: A5 05
  STA dividend_mid                              ; $EA22: 85 02
  INC bcd_htth_tth                              ; $EA24: E6 09
  BNE @sub_10k                                  ; $EA26: D0 DF

  ; Subtract 1,000 ($03E8) -> thousands digit
@sub_1k:
  LDA dividend_lo                               ; $EA28: A5 01
  SEC                                           ; $EA2A: 38
  SBC #$E8                                      ; $EA2B: E9 E8
  STA temp_lo                                   ; $EA2D: 85 04
  LDA dividend_mid                              ; $EA2F: A5 02
  SBC #$03                                      ; $EA31: E9 03
  BCC @sub_100                                  ; $EA33: 90 0E
  STA dividend_mid                              ; $EA35: 85 02
  LDA temp_lo                                   ; $EA37: A5 04
  STA dividend_lo                               ; $EA39: 85 01
  LDA bcd_thou_hund                             ; $EA3B: A5 08
  ADC #$0F                                      ; $EA3D: 69 0F
  STA bcd_thou_hund                             ; $EA3F: 85 08
  BNE @sub_1k                                   ; $EA41: D0 E5

  ; Subtract 100 ($0064) -> hundreds digit
@sub_100:
  LDA dividend_lo                               ; $EA43: A5 01
  SEC                                           ; $EA45: 38
  SBC #$64                                      ; $EA46: E9 64
  STA temp_lo                                   ; $EA48: 85 04
  LDA dividend_mid                              ; $EA4A: A5 02
  SBC #$00                                      ; $EA4C: E9 00
  BCC @sub_10                                   ; $EA4E: 90 0A
  STA dividend_mid                              ; $EA50: 85 02
  LDA temp_lo                                   ; $EA52: A5 04
  STA dividend_lo                               ; $EA54: 85 01
  INC bcd_thou_hund                             ; $EA56: E6 08
  BNE @sub_100                                  ; $EA58: D0 E9

  ; Subtract 10 ($000A) -> tens digit
@sub_10:
  LDA dividend_lo                               ; $EA5A: A5 01
  SEC                                           ; $EA5C: 38
  SBC #$0A                                      ; $EA5D: E9 0A
  STA temp_lo                                   ; $EA5F: 85 04
  LDA dividend_mid                              ; $EA61: A5 02
  SBC #$00                                      ; $EA63: E9 00
  BCC @final                                    ; $EA65: 90 0E
  STA dividend_mid                              ; $EA67: 85 02
  LDA temp_lo                                   ; $EA69: A5 04
  STA dividend_lo                               ; $EA6B: 85 01
  LDA bcd_tens_ones                             ; $EA6D: A5 07
  ADC #$0F                                      ; $EA6F: 69 0F
  STA bcd_tens_ones                             ; $EA71: 85 07
  BNE @sub_10                                   ; $EA73: D0 E5

  ; Remainder = ones digit
@final:
  LDA dividend_lo                               ; $EA75: A5 01
  ORA bcd_tens_ones                             ; $EA77: 05 07
  STA bcd_tens_ones                             ; $EA79: 85 07
  RTS                                           ; $EA7B: 60
.endproc

;===============================================================================
; $EA7C: Math - 16-bit Unsigned Division
; Input: $01/$02 = dividend (16-bit), $03/$04 = divisor (16-bit)
; Output: $01/$02 = quotient, $05/$06 = remainder
;===============================================================================
.proc MathDiv16
dividend_lo   = $01
dividend_hi   = $02
divisor_lo    = $03
divisor_hi    = $04
remainder_lo  = $05
remainder_hi  = $06
temp          = $07

  LDA #$00                                      ; $EA7C: A9 00
  STA remainder_lo                              ; $EA7E: 85 05
  STA remainder_hi                              ; $EA80: 85 06
  LDY #$0F                                      ; $EA82: A0 0F
@loop:
  ASL dividend_lo                               ; $EA84: 06 01
  ROL dividend_hi                               ; $EA86: 26 02
  ROL remainder_lo                              ; $EA88: 26 05
  ROL remainder_hi                              ; $EA8A: 26 06
  LDA remainder_lo                              ; $EA8C: A5 05
  SEC                                           ; $EA8E: 38
  SBC divisor_lo                                ; $EA8F: E5 03
  STA temp                                      ; $EA91: 85 07
  LDA remainder_hi                              ; $EA93: A5 06
  SBC divisor_hi                                ; $EA95: E5 04
  BCC @skip                                     ; $EA97: 90 08
  STA remainder_hi                              ; $EA99: 85 06
  LDA temp                                      ; $EA9B: A5 07
  STA remainder_lo                              ; $EA9D: 85 05
  INC dividend_lo                               ; $EA9F: E6 01
@skip:
  DEY                                           ; $EAA1: 88
  BPL @loop                                     ; $EAA2: 10 E0
  RTS                                           ; $EAA4: 60
.endproc

;===============================================================================
; $EAA5: Math - 24-bit Unsigned Division
; Input: $00/$01/$02 = dividend (24-bit), $03/$04 = divisor (16-bit)
; Output: $00/$01/$02 = quotient, $05/$06/$07 = remainder
;===============================================================================
.proc MathDiv24
dividend_b0   = $00
dividend_b1   = $01
dividend_b2   = $02
divisor_lo    = $03
divisor_hi    = $04
remainder_b0  = $05
remainder_b1  = $06
remainder_b2  = $07
temp_b0       = $08
temp_b1       = $09

  LDA #$00                                      ; $EAA5: A9 00
  STA remainder_b0                              ; $EAA7: 85 05
  STA remainder_b1                              ; $EAA9: 85 06
  STA remainder_b2                              ; $EAAB: 85 07
  LDY #$17                                      ; $EAAD: A0 17
@loop:
  ASL dividend_b0                               ; $EAAF: 06 00
  ROL dividend_b1                               ; $EAB1: 26 01
  ROL dividend_b2                               ; $EAB3: 26 02
  ROL remainder_b0                              ; $EAB5: 26 05
  ROL remainder_b1                              ; $EAB7: 26 06
  ROL remainder_b2                              ; $EAB9: 26 07
  LDA remainder_b0                              ; $EABB: A5 05
  SEC                                           ; $EABD: 38
  SBC divisor_lo                                ; $EABE: E5 03
  STA temp_b0                                   ; $EAC0: 85 08
  LDA remainder_b1                              ; $EAC2: A5 06
  SBC divisor_hi                                ; $EAC4: E5 04
  STA temp_b1                                   ; $EAC6: 85 09
  LDA remainder_b2                              ; $EAC8: A5 07
  SBC #$00                                      ; $EACA: E9 00
  BCC @skip                                     ; $EACC: 90 0C
  STA remainder_b2                              ; $EACE: 85 07
  LDA temp_b0                                   ; $EAD0: A5 08
  STA remainder_b0                              ; $EAD2: 85 05
  LDA temp_b1                                   ; $EAD4: A5 09
  STA remainder_b1                              ; $EAD6: 85 06
  INC dividend_b0                               ; $EAD8: E6 00
@skip:
  DEY                                           ; $EADA: 88
  BPL @loop                                     ; $EADB: 10 D2
  RTS                                           ; $EADD: 60
.endproc

;===============================================================================
; $EADE: Callback Dispatcher (Indirect Jump via Inline Table)
; Input: A = index into table, Y = parameter
; The caller's inline word table follows the JSR instruction
; Usage: JSR CallbackDispatcher; .word handler0, handler1, ...
;===============================================================================
.proc CallbackDispatcher
param         = $00
ret_addr_lo   = $01
ret_addr_hi   = $02
target_lo     = $03
target_hi     = $04

  STY param                                     ; $EADE: 84 00
  ASL                                           ; $EAE0: 0A
  TAY                                           ; $EAE1: A8
  INY                                           ; $EAE2: C8
  PLA                                           ; $EAE3: 68
  STA ret_addr_lo                               ; $EAE4: 85 01
  PLA                                           ; $EAE6: 68
  STA ret_addr_hi                               ; $EAE7: 85 02
  LDA (ret_addr_lo),Y                           ; $EAE9: B1 01
  STA target_lo                                 ; $EAEB: 85 03
  INY                                           ; $EAED: C8
  LDA (ret_addr_lo),Y                           ; $EAEE: B1 01
  STA target_hi                                 ; $EAF0: 85 04
  LDY param                                     ; $EAF2: A4 00
  JMP (target_lo)                               ; $EAF4: 6C 03 00
.endproc

;===============================================================================
; $EAF7: Scroll Set
; Writes scroll_x ($008E) and scroll_y ($0090) to PPU_SCROLL
; Then updates PPU_CTRL nametable select bits from $008F
;===============================================================================
.proc ScrollSet
  LDA addr_scroll_x                             ; $EAF7: AD 8E 00
  STA PPU_SCROLL                                ; $EAFA: 8D 05 20
  LDA addr_scroll_y                             ; $EAFD: AD 90 00
  STA PPU_SCROLL                                ; $EB00: 8D 05 20
  LDA addr_ppu_ctrl_ram                         ; $EB03: AD 8B 00
  AND #$FE                                      ; $EB06: 29 FE
  STA addr_ppu_ctrl_ram                         ; $EB08: 8D 8B 00
  LDA addr_scroll_x_hi                          ; $EB0B: AD 8F 00
  AND #$01                                      ; $EB0E: 29 01
  ORA addr_ppu_ctrl_ram                         ; $EB10: 0D 8B 00
  STA addr_ppu_ctrl_ram                         ; $EB13: 8D 8B 00
  STA PPU_CTRL                                  ; $EB16: 8D 00 20
  RTS                                           ; $EB19: 60
.endproc

;===============================================================================
; $EB1A: Window Reset
; Sets PPU_ADDR to $0250, zeros scroll registers
;===============================================================================
.proc WindowReset
  LDA #$02                                      ; $EB1A: A9 02
  STA PPU_ADDR                                  ; $EB1C: 8D 06 20
  LDA #$50                                      ; $EB1F: A9 50
  STA PPU_ADDR                                  ; $EB21: 8D 06 20
  LDA #$00                                      ; $EB24: A9 00
  STA PPU_SCROLL                                ; $EB26: 8D 05 20
  STA PPU_SCROLL                                ; $EB29: 8D 05 20
  RTS                                           ; $EB2C: 60
.endproc

;===============================================================================
; $EB2D: Math - BCD to Binary
; Input: $0A = tens|ones, $0B = thou|hund, $0C = hthou|tthou (packed BCD)
; Output: $0D/$0E/$0F = 24-bit binary result
;===============================================================================
.proc MathBcdToBin
bcd_tens_ones = $0A
bcd_thou_hund = $0B
bcd_htth_tth  = $0C
result_b0     = $0D
result_b1     = $0E
result_b2     = $0F
mul_lo        = $00
mul_mid       = $01
mul_hi        = $02
multiplier    = $03

  LDA #$00                                      ; $EB2D: A9 00
  STA result_b1                                 ; $EB2F: 85 0E
  STA result_b2                                 ; $EB31: 85 0F
  ; Ones digit
  LDA bcd_tens_ones                             ; $EB33: A5 0A
  PHA                                           ; $EB35: 48
  AND #$0F                                      ; $EB36: 29 0F
  STA result_b0                                 ; $EB38: 85 0D
  ; Tens digit x 10
  PLA                                           ; $EB3A: 68
  JSR MathExtractUpperNibble                    ; $EB3B: 20 B1 EB
  STA multiplier                                ; $EB3E: 85 03
  LDA #$0A                                      ; $EB40: A9 0A
  STA mul_lo                                    ; $EB42: 85 00
  LDA #$00                                      ; $EB44: A9 00
  STA mul_mid                                   ; $EB46: 85 01
  STA mul_hi                                    ; $EB48: 85 02
  JSR MathMul24x8                               ; $EB4A: 20 E9 EB
  JSR MathAccumulate24                          ; $EB4D: 20 B6 EB
  ; Hundreds digit x 100
  LDA bcd_thou_hund                             ; $EB50: A5 0B
  PHA                                           ; $EB52: 48
  AND #$0F                                      ; $EB53: 29 0F
  STA multiplier                                ; $EB55: 85 03
  LDA #$64                                      ; $EB57: A9 64
  STA mul_lo                                    ; $EB59: 85 00
  LDA #$00                                      ; $EB5B: A9 00
  STA mul_mid                                   ; $EB5D: 85 01
  STA mul_hi                                    ; $EB5F: 85 02
  JSR MathMul24x8                               ; $EB61: 20 E9 EB
  JSR MathAccumulate24                          ; $EB64: 20 B6 EB
  ; Thousands digit x 1000
  PLA                                           ; $EB67: 68
  JSR MathExtractUpperNibble                    ; $EB68: 20 B1 EB
  STA multiplier                                ; $EB6B: 85 03
  LDA #$E8                                      ; $EB6D: A9 E8
  STA mul_lo                                    ; $EB6F: 85 00
  LDA #$03                                      ; $EB71: A9 03
  STA mul_mid                                   ; $EB73: 85 01
  LDA #$00                                      ; $EB75: A9 00
  STA mul_hi                                    ; $EB77: 85 02
  JSR MathMul24x8                               ; $EB79: 20 E9 EB
  JSR MathAccumulate24                          ; $EB7C: 20 B6 EB
  ; Ten-thousands digit x 10000
  LDA bcd_htth_tth                              ; $EB7F: A5 0C
  PHA                                           ; $EB81: 48
  AND #$0F                                      ; $EB82: 29 0F
  STA multiplier                                ; $EB84: 85 03
  LDA #$10                                      ; $EB86: A9 10
  STA mul_lo                                    ; $EB88: 85 00
  LDA #$27                                      ; $EB8A: A9 27
  STA mul_mid                                   ; $EB8C: 85 01
  LDA #$00                                      ; $EB8E: A9 00
  STA mul_hi                                    ; $EB90: 85 02
  JSR MathMul24x8                               ; $EB92: 20 E9 EB
  JSR MathAccumulate24                          ; $EB95: 20 B6 EB
  ; Hundred-thousands digit x 100000
  PLA                                           ; $EB98: 68
  JSR MathExtractUpperNibble                    ; $EB99: 20 B1 EB
  STA multiplier                                ; $EB9C: 85 03
  LDA #$A0                                      ; $EB9E: A9 A0
  STA mul_lo                                    ; $EBA0: 85 00
  LDA #$86                                      ; $EBA2: A9 86
  STA mul_mid                                   ; $EBA4: 85 01
  LDA #$01                                      ; $EBA6: A9 01
  STA mul_hi                                    ; $EBA8: 85 02
  JSR MathMul24x8                               ; $EBAA: 20 E9 EB
  JSR MathAccumulate24                          ; $EBAD: 20 B6 EB
  RTS                                           ; $EBB0: 60
.endproc

;===============================================================================
; $EBB1: Extract Upper Nibble
; Input: A = byte; Output: A = upper nibble >> 4
;===============================================================================
.proc MathExtractUpperNibble
  LSR                                           ; $EBB1: 4A
  LSR                                           ; $EBB2: 4A
  LSR                                           ; $EBB3: 4A
  LSR                                           ; $EBB4: 4A
  RTS                                           ; $EBB5: 60
.endproc

;===============================================================================
; $EBB6: Math - 24-bit Accumulate
; $0D/$0E/$0F += $06/$07/$08
;===============================================================================
.proc MathAccumulate24
  LDA $06                                       ; $EBB6: A5 06
  CLC                                           ; $EBB8: 18
  ADC $0D                                       ; $EBB9: 65 0D
  STA $0D                                       ; $EBBB: 85 0D
  LDA $07                                       ; $EBBD: A5 07
  ADC $0E                                       ; $EBBF: 65 0E
  STA $0E                                       ; $EBC1: 85 0E
  LDA $08                                       ; $EBC3: A5 08
  ADC $0F                                       ; $EBC5: 65 0F
  STA $0F                                       ; $EBC7: 85 0F
  RTS                                           ; $EBC9: 60
.endproc

;===============================================================================
; $EBCA: Math - Multiply then Divide by 100
; Input: $00/$01 = value, $03 = multiplier
; Computes: (value * multiplier) / 100
; Output: $00/$01/$02 = quotient
;===============================================================================
.proc MathMulDiv100
  LDA #$00                                      ; $EBCA: A9 00
  STA $02                                       ; $EBCC: 85 02
  JSR MathMul24x8                               ; $EBCE: 20 E9 EB
  LDA $06                                       ; $EBD1: A5 06
  STA $00                                       ; $EBD3: 85 00
  LDA $07                                       ; $EBD5: A5 07
  STA $01                                       ; $EBD7: 85 01
  LDA $08                                       ; $EBD9: A5 08
  STA $02                                       ; $EBDB: 85 02
  LDA #$64                                      ; $EBDD: A9 64
  STA $03                                       ; $EBDF: 85 03
  LDA #$00                                      ; $EBE1: A9 00
  STA $04                                       ; $EBE3: 85 04
  JSR MathDiv24                                 ; $EBE5: 20 A5 EA
  RTS                                           ; $EBE8: 60
.endproc

;===============================================================================
; $EBE9: Math - 24x8 Multiply
; Input: $00/$01/$02 = multiplicand (24-bit), $03 = multiplier (8-bit)
; Output: $06/$07/$08/$09 = product (32-bit)
;===============================================================================
.proc MathMul24x8
multiplicand_b0 = $00
multiplicand_b1 = $01
multiplicand_b2 = $02
multiplier_val  = $03
extension       = $04
product_b0      = $05
product_b1      = $06
product_b2      = $07
product_b3      = $08
product_b4      = $09

  LDY #$07                                      ; $EBE9: A0 07
  LDA #$00                                      ; $EBEB: A9 00
  STA extension                                 ; $EBED: 85 04
  STA product_b0                                ; $EBEF: 85 05
  STA product_b1                                ; $EBF1: 85 06
  STA product_b2                                ; $EBF3: 85 07
  STA product_b3                                ; $EBF5: 85 08
  STA product_b4                                ; $EBF7: 85 09
@loop:
  LSR multiplier_val                            ; $EBF9: 46 03
  BCC @skip_add                                 ; $EBFB: 90 19
  LDA multiplicand_b0                           ; $EBFD: A5 00
  CLC                                           ; $EBFF: 18
  ADC product_b1                                ; $EC00: 65 06
  STA product_b1                                ; $EC02: 85 06
  LDA multiplicand_b1                           ; $EC04: A5 01
  ADC product_b2                                ; $EC06: 65 07
  STA product_b2                                ; $EC08: 85 07
  LDA multiplicand_b2                           ; $EC0A: A5 02
  ADC product_b3                                ; $EC0C: 65 08
  STA product_b3                                ; $EC0E: 85 08
  LDA extension                                 ; $EC10: A5 04
  ADC product_b4                                ; $EC12: 65 09
  STA product_b4                                ; $EC14: 85 09
@skip_add:
  ASL multiplicand_b0                           ; $EC16: 06 00
  ROL multiplicand_b1                           ; $EC18: 26 01
  ROL multiplicand_b2                           ; $EC1A: 26 02
  ROL extension                                 ; $EC1C: 26 04
  DEY                                           ; $EC1E: 88
  BPL @loop                                     ; $EC1F: 10 D8
  RTS                                           ; $EC21: 60
.endproc

;===============================================================================
; $EC22: Math - 24x16 Multiply
; Input: $00/$01/$02 = multiplicand, $03/$04 = multiplier (16-bit)
; Output: $06/$07/$08/$09/$0A = product (40-bit)
;===============================================================================
.proc MathMul24x16
multiplicand_b0 = $00
multiplicand_b1 = $01
multiplicand_b2 = $02
multiplier_lo   = $03
multiplier_hi   = $04
product_b0      = $06
product_b1      = $07
product_b2      = $08
product_b3      = $09
product_b4      = $0A
ext_b0          = $0B
ext_b1          = $0C

  LDY #$0F                                      ; $EC22: A0 0F
  LDA #$00                                      ; $EC24: A9 00
  STA product_b0                                ; $EC26: 85 06
  STA product_b1                                ; $EC28: 85 07
  STA product_b2                                ; $EC2A: 85 08
  STA product_b3                                ; $EC2C: 85 09
  STA product_b4                                ; $EC2E: 85 0A
  STA ext_b0                                    ; $EC30: 85 0B
  STA ext_b1                                    ; $EC32: 85 0C
@loop:
  LSR multiplier_hi                             ; $EC34: 46 04
  ROR multiplier_lo                             ; $EC36: 66 03
  BCC @skip_add                                 ; $EC38: 90 1F
  LDA multiplicand_b0                           ; $EC3A: A5 00
  CLC                                           ; $EC3C: 18
  ADC product_b0                                ; $EC3D: 65 06
  STA product_b0                                ; $EC3F: 85 06
  LDA multiplicand_b1                           ; $EC41: A5 01
  ADC product_b1                                ; $EC43: 65 07
  STA product_b1                                ; $EC45: 85 07
  LDA multiplicand_b2                           ; $EC47: A5 02
  ADC product_b2                                ; $EC49: 65 08
  STA product_b2                                ; $EC4B: 85 08
  LDA ext_b0                                    ; $EC4D: A5 0B
  ADC product_b3                                ; $EC4F: 65 09
  STA product_b3                                ; $EC51: 85 09
  LDA ext_b1                                    ; $EC53: A5 0C
  ADC product_b4                                ; $EC55: 65 0A
  STA product_b4                                ; $EC57: 85 0A
@skip_add:
  ASL multiplicand_b0                           ; $EC59: 06 00
  ROL multiplicand_b1                           ; $EC5B: 26 01
  ROL multiplicand_b2                           ; $EC5D: 26 02
  ROL ext_b0                                    ; $EC5F: 26 0B
  ROL ext_b1                                    ; $EC61: 26 0C
  DEY                                           ; $EC63: 88
  BPL @loop                                     ; $EC64: 10 CE
  RTS                                           ; $EC66: 60
.endproc


;===============================================================================
; $EC67: Palette Animation
; Controls color cycling animation for palette entries
; Uses frame counter at $0087, animation direction at $0087,
; step counter at $0088, speed at $0089, tick counter at $008A
;===============================================================================
.proc PaletteAnimation
anim_direction  = $0087
anim_step       = $0088
anim_speed      = $0089
anim_counter    = $008A
nmi_flag        = $007D

  LDA anim_direction                            ; $EC67: AD 87 00
  BMI @done                                     ; $EC6A: 30 52
  DEC anim_counter                              ; $EC6C: CE 8A 00
  BPL @done                                     ; $EC6F: 10 4D
  LDA anim_speed                                ; $EC71: AD 89 00
  STA anim_counter                              ; $EC74: 8D 8A 00
  LDA #$01                                      ; $EC77: A9 01
  STA nmi_flag                                  ; $EC79: 8D 7D 00
  LDA anim_direction                            ; $EC7C: AD 87 00
  BEQ @reverse                                  ; $EC7F: F0 0D
  INC anim_step                                 ; $EC81: EE 88 00
  LDA anim_step                                 ; $EC84: AD 88 00
  CMP #$04                                      ; $EC87: C9 04
  BCC @apply_shift                              ; $EC89: 90 0D
  JMP @mark_done                                ; $EC8B: 4C 93 EC
@reverse:
  DEC anim_step                                 ; $EC8E: CE 88 00
  BNE @apply_shift                              ; $EC91: D0 05
@mark_done:
  LDA #$FF                                      ; $EC93: A9 FF
  STA anim_direction                            ; $EC95: 8D 87 00
@apply_shift:
  LDA #$00                                      ; $EC98: A9 00
  STA $00                                       ; $EC9A: 85 00
  LDA #$01                                      ; $EC9C: A9 01
  STA $01                                       ; $EC9E: 85 01
  LDA #$20                                      ; $ECA0: A9 20
  STA $02                                       ; $ECA2: 85 02
  LDA #$01                                      ; $ECA4: A9 01
  STA $03                                       ; $ECA6: 85 03
  LDY #$1F                                      ; $ECA8: A0 1F
@shift_loop:
  LDX anim_step                                 ; $ECAA: AE 88 00
  LDA ($02),Y                                   ; $ECAD: B1 02
@sub_loop:
  DEX                                           ; $ECAF: CA
  BMI @store                                    ; $ECB0: 30 07
  SEC                                           ; $ECB2: 38
  SBC #$10                                      ; $ECB3: E9 10
  BPL @sub_loop                                 ; $ECB5: 10 F8
  LDA #$0F                                      ; $ECB7: A9 0F
@store:
  STA ($00),Y                                   ; $ECB9: 91 00
  DEY                                           ; $ECBB: 88
  BPL @shift_loop                               ; $ECBC: 10 EC
@done:
  RTS                                           ; $ECBE: 60
.endproc

;===============================================================================
; $ECBF: Palette Fade Init (Move $0100 -> $0120)
; Initializes fade: copies palette from $0100 to $0120, fills $0100 with $0F
;===============================================================================
.proc PaletteFadeInit
  LDA #$00                                      ; $ECBF: A9 00
  STA $0087                                     ; $ECC1: 8D 87 00
  LDA #$04                                      ; $ECC4: A9 04
  STA $0088                                     ; $ECC6: 8D 88 00
  LDA #$04                                      ; $ECC9: A9 04
  STA $0089                                     ; $ECCB: 8D 89 00
  LDA #$00                                      ; $ECCE: A9 00
  STA $00                                       ; $ECD0: 85 00
  LDA #$01                                      ; $ECD2: A9 01
  STA $01                                       ; $ECD4: 85 01
  LDA #$20                                      ; $ECD6: A9 20
  STA $02                                       ; $ECD8: 85 02
  LDA #$01                                      ; $ECDA: A9 01
  STA $03                                       ; $ECDC: 85 03
  LDY #$00                                      ; $ECDE: A0 00
@copy_loop:
  LDA ($00),Y                                   ; $ECE0: B1 00
  STA ($02),Y                                   ; $ECE2: 91 02
  LDA #$0F                                      ; $ECE4: A9 0F
  STA ($00),Y                                   ; $ECE6: 91 00
  INY                                           ; $ECE8: C8
  CPY #$20                                      ; $ECE9: C0 20
  BCC @copy_loop                                ; $ECEB: 90 F3
  RTS                                           ; $ECED: 60
.endproc

;===============================================================================
; $ECEE: Palette Copy Buffer ($0100 -> $0120, no fill)
; Similar to PaletteFadeInit but doesn't blank source
;===============================================================================
.proc PaletteCopyBuffer
  LDA #$01                                      ; $ECEE: A9 01
  STA $0087                                     ; $ECF0: 8D 87 00
  LDA #$00                                      ; $ECF3: A9 00
  STA $0088                                     ; $ECF5: 8D 88 00
  LDA #$04                                      ; $ECF8: A9 04
  STA $0089                                     ; $ECFA: 8D 89 00
  LDA #$00                                      ; $ECFD: A9 00
  STA $00                                       ; $ECFF: 85 00
  LDA #$01                                      ; $ED01: A9 01
  STA $01                                       ; $ED03: 85 01
  LDA #$20                                      ; $ED05: A9 20
  STA $02                                       ; $ED07: 85 02
  LDA #$01                                      ; $ED09: A9 01
  STA $03                                       ; $ED0B: 85 03
  LDY #$00                                      ; $ED0D: A0 00
@copy_loop:
  LDA ($00),Y                                   ; $ED0F: B1 00
  STA ($02),Y                                   ; $ED11: 91 02
  INY                                           ; $ED13: C8
  CPY #$20                                      ; $ED14: C0 20
  BCC @copy_loop                                ; $ED16: 90 F7
  RTS                                           ; $ED18: 60
.endproc

;===============================================================================
; $ED19: Menu Cursor System (8 entry points)
; Entry: MenuStep1-MenuStep8 with step_size = 1..8
; Input: ($10) = data table pointer
; Output: $12 = current item value from table lookup
; Checks pad1 edges for directional input
;===============================================================================
.proc MenuCursorSystem
step_size       = $00
data_ptr        = $10
cur_item        = $12

MenuStep1:
  LDA #$01                                      ; $ED19: A9 01
  JMP MenuMain                                  ; $ED1B: 4C 41 ED
MenuStep2:
  LDA #$02                                      ; $ED1E: A9 02
  JMP MenuMain                                  ; $ED20: 4C 41 ED
MenuStep3:
  LDA #$03                                      ; $ED23: A9 03
  JMP MenuMain                                  ; $ED25: 4C 41 ED
MenuStep4:
  LDA #$04                                      ; $ED28: A9 04
  JMP MenuMain                                  ; $ED2A: 4C 41 ED
MenuStep5:
  LDA #$05                                      ; $ED2D: A9 05
  JMP MenuMain                                  ; $ED2F: 4C 41 ED
MenuStep6:
  LDA #$06                                      ; $ED32: A9 06
  JMP MenuMain                                  ; $ED34: 4C 41 ED
MenuStep7:
  LDA #$07                                      ; $ED37: A9 07
  JMP MenuMain                                  ; $ED39: 4C 41 ED
MenuStep8:
  LDA #$08                                      ; $ED3C: A9 08
  JMP MenuMain                                  ; $ED3E: 4C 41 ED
MenuMain:
  STA step_size                                 ; $ED41: 85 00
  LDA addr_pad1_edge                            ; $ED43: AD 81 00
  AND #$80                                      ; $ED46: 29 80
  BEQ @check_left                               ; $ED48: F0 03
  JSR @cursor_right                             ; $ED4A: 20 71 ED
@check_left:
  LDA addr_pad1_edge                            ; $ED4D: AD 81 00
  AND #$40                                      ; $ED50: 29 40
  BEQ @check_down                               ; $ED52: F0 03
  JSR @cursor_left                              ; $ED54: 20 8D ED
@check_down:
  LDA addr_pad1_edge                            ; $ED57: AD 81 00
  AND #$20                                      ; $ED5A: 29 20
  BEQ @check_up                                 ; $ED5C: F0 03
  JSR @cursor_down                              ; $ED5E: 20 A9 ED
@check_up:
  LDA addr_pad1_edge                            ; $ED61: AD 81 00
  AND #$10                                      ; $ED64: 29 10
  BEQ @do_lookup                                ; $ED66: F0 03
  JSR @cursor_up                                ; $ED68: 20 BE ED
@do_lookup:
  JSR MenuItemLookup                            ; $ED6B: 20 DD ED
  STA cur_item                                  ; $ED6E: 85 12
  RTS                                           ; $ED70: 60

; --- cursor_right: increment column ---
@cursor_right:
  INC addr_menu_column                          ; $ED71: EE 24 04
  JSR MenuItemLookup                            ; $ED74: 20 DD ED
  BMI @right_overflow                           ; $ED77: 30 07
  LDA addr_menu_column                          ; $ED79: AD 24 04
  CMP step_size                                 ; $ED7C: C5 00
  BCC @right_done                               ; $ED7E: 90 0C
@right_overflow:
  DEC addr_menu_column                          ; $ED80: CE 24 04
  LDA cur_item                                  ; $ED83: A5 12
  BNE @right_done                               ; $ED85: D0 05
  LDA #$00                                      ; $ED87: A9 00
  STA addr_menu_column                          ; $ED89: 8D 24 04
@right_done:
  RTS                                           ; $ED8C: 60

; --- cursor_left: decrement column ---
@cursor_left:
  DEC addr_menu_column                          ; $ED8D: CE 24 04
  BPL @left_valid                               ; $ED90: 10 16
  INC addr_menu_column                          ; $ED92: EE 24 04
  LDA cur_item                                  ; $ED95: A5 12
  BNE @left_valid                               ; $ED97: D0 0F
  LDA step_size                                 ; $ED99: A5 00
  STA addr_menu_column                          ; $ED9B: 8D 24 04
@left_scan:
  DEC addr_menu_column                          ; $ED9E: CE 24 04
  JSR MenuItemLookup                            ; $EDA1: 20 DD ED
  CMP #$FF                                      ; $EDA4: C9 FF
  BEQ @left_scan                                ; $EDA6: F0 F6
@left_valid:
  RTS                                           ; $EDA8: 60

; --- cursor_down: increment page ---
@cursor_down:
  INC addr_menu_page                            ; $EDA9: EE 25 04
  JSR MenuItemLookup                            ; $EDAC: 20 DD ED
  BPL @down_done                                ; $EDAF: 10 0C
  DEC addr_menu_page                            ; $EDB1: CE 25 04
  LDA cur_item                                  ; $EDB4: A5 12
  BNE @down_done                                ; $EDB6: D0 05
  LDA #$00                                      ; $EDB8: A9 00
  STA addr_menu_page                            ; $EDBA: 8D 25 04
@down_done:
  RTS                                           ; $EDBD: 60

; --- cursor_up: decrement page ---
@cursor_up:
  DEC addr_menu_page                            ; $EDBE: CE 25 04
  BPL @up_done                                  ; $EDC1: 10 19
  INC addr_menu_page                            ; $EDC3: EE 25 04
  LDA cur_item                                  ; $EDC6: A5 12
  BNE @up_done                                  ; $EDC8: D0 12
  LDX #$FF                                      ; $EDCA: A2 FF
  LDY addr_menu_column                          ; $EDCC: AC 24 04
@up_count:
  INX                                           ; $EDCF: E8
  TYA                                           ; $EDD0: 98
  CLC                                           ; $EDD1: 18
  ADC step_size                                 ; $EDD2: 65 00
  TAY                                           ; $EDD4: A8
  LDA (data_ptr),Y                              ; $EDD5: B1 10
  BPL @up_count                                 ; $EDD7: 10 F6
  STX addr_menu_page                            ; $EDD9: 8E 25 04
@up_done:
  RTS                                           ; $EDDC: 60
.endproc

;===============================================================================
; $EDDD: Menu Item Lookup
; Computes: offset = page * step_size + column
; Returns: A = (data_ptr)[offset]
;===============================================================================
.proc MenuItemLookup
step_size  = $00
data_ptr   = $10

  LDA #$00                                      ; $EDDD: A9 00
  LDY addr_menu_page                            ; $EDDF: AC 25 04
@mul_loop:
  CPY #$00                                      ; $EDE2: C0 00
  BEQ @add_column                               ; $EDE4: F0 07
  CLC                                           ; $EDE6: 18
  ADC step_size                                 ; $EDE7: 65 00
  DEY                                           ; $EDE9: 88
  JMP @mul_loop                                 ; $EDEA: 4C E2 ED
@add_column:
  CLC                                           ; $EDED: 18
  ADC addr_menu_column                          ; $EDEE: 6D 24 04
  TAY                                           ; $EDF1: A8
  LDA (data_ptr),Y                              ; $EDF2: B1 10
  RTS                                           ; $EDF4: 60
.endproc

;===============================================================================
; $EDF5: Pointer Table Lookup
; Input: A = entry index, ($10) = pointer table base
; Output: $0A/$0C = fetched pointer, then JMP SpriteOamWriterSimple
;===============================================================================
.proc PointerTableLookup
ptr_lo   = $0A
ptr_hi   = $0C

  ASL                                           ; $EDF5: 0A
  TAY                                           ; $EDF6: A8
  LDA ($10),Y                                   ; $EDF7: B1 10
  STA ptr_lo                                    ; $EDF9: 85 0A
  INY                                           ; $EDFB: C8
  LDA ($10),Y                                   ; $EDFC: B1 10
  STA ptr_hi                                    ; $EDFE: 85 0C
  LDA #$00                                      ; $EE00: A9 00
  STA $02                                       ; $EE02: 85 02
  JMP SpriteOamWriterSimple                     ; $EE04: 4C AD F1
.endproc

;===============================================================================
; $EE07: Banked Callback Trampoline
; Switches PRG banks, calls target, restores bank on return
; Usage: LDY #bank; JSR BankedCallbackTrampoline; .word target_addr
;===============================================================================
.proc BankedCallbackTrampoline
  LDA addr_prg_select_2b                        ; $EE07: AD E2 00
  STA addr_trampoline_saved_bank                ; $EE0A: 8D 58 00
  STY addr_trampoline_bank_param                ; $EE0D: 8C 5D 00
  PLA                                           ; $EE10: 68
  CLC                                           ; $EE11: 18
  ADC #$01                                      ; $EE12: 69 01
  STA addr_trampoline_ret_lo                    ; $EE14: 8D 59 00
  PLA                                           ; $EE17: 68
  ADC #$00                                      ; $EE18: 69 00
  STA addr_trampoline_ret_hi                    ; $EE1A: 8D 5A 00
  LDY #$00                                      ; $EE1D: A0 00
  LDA (addr_trampoline_ret_lo),Y                ; $EE1F: B1 59
  STA addr_trampoline_target_lo                 ; $EE21: 8D 5B 00
  INY                                           ; $EE24: C8
  LDA (addr_trampoline_ret_lo),Y                ; $EE25: B1 59
  STA addr_trampoline_target_hi                 ; $EE27: 8D 5C 00
  LDY addr_trampoline_bank_param                ; $EE2A: AC 5D 00
  JSR SwitchBankAC_B                            ; $EE2D: 20 37 F2
  INC addr_trampoline_ret_lo                    ; $EE30: EE 59 00
  BNE @no_carry                                 ; $EE33: D0 03
  INC addr_trampoline_ret_hi                    ; $EE35: EE 5A 00
@no_carry:
  LDA addr_trampoline_ret_hi                    ; $EE38: AD 5A 00
  PHA                                           ; $EE3B: 48
  LDA addr_trampoline_ret_lo                    ; $EE3C: AD 59 00
  PHA                                           ; $EE3F: 48
  LDA addr_trampoline_saved_bank                ; $EE40: AD 58 00
  PHA                                           ; $EE43: 48
  LDA #$EE                                      ; $EE44: A9 EE
  PHA                                           ; $EE46: 48
  LDA #$4C                                      ; $EE47: A9 4C
  PHA                                           ; $EE49: 48
  JMP (addr_trampoline_target_lo)               ; $EE4A: 6C 5B 00
.endproc

;===============================================================================
; $EE4D: Banked Callback Return
; Restores PRG banks after banked call completes
;===============================================================================
.proc BankedCallbackReturn
  PLA                                           ; $EE4D: 68
  TAY                                           ; $EE4E: A8
  JSR SwitchBankAC_B                            ; $EE4F: 20 37 F2
  RTS                                           ; $EE52: 60
.endproc

;===============================================================================
; $EE53: NMI Sub-Dispatch
; Tests bits of $007E to dispatch PPU update tasks
; bit7 -> PpuBgTileWrite, bit6 -> PpuSpriteTileWrite
; bit5 -> PpuAttrTileWrite, bit4 -> PpuAttrTileWriteAlt
;===============================================================================
.proc NmiSubDispatch
nmi_flag = $007D
nmi_ctrl = $007E

  LDA nmi_flag                                  ; $EE53: AD 7D 00
  BNE @check_bits                               ; $EE56: D0 1A
  LDA nmi_ctrl                                  ; $EE58: AD 7E 00
  BMI @do_bg                                    ; $EE5B: 30 18
  ASL                                           ; $EE5D: 0A
  BMI @do_sprite                                ; $EE5E: 30 27
@test_attr:
  ASL                                           ; $EE60: 0A
  BMI @do_attr                                  ; $EE61: 30 35
  ASL                                           ; $EE63: 0A
  BMI @do_attr_alt                              ; $EE64: 30 3D
  ASL                                           ; $EE66: 0A
  BMI @do_bank_3d_a                             ; $EE67: 30 45
  ASL                                           ; $EE69: 0A
  BMI @do_bank_3d_b                             ; $EE6A: 30 52
  ASL                                           ; $EE6C: 0A
  BMI @do_bank_3d_c                             ; $EE6D: 30 5F
  ASL                                           ; $EE6F: 0A
  BMI @do_bank_3d_d                             ; $EE70: 30 6C
@check_bits:
  JMP PaletteUpload                             ; $EE72: 4C 0E E7

@do_bg:
  PHA                                           ; $EE75: 48
  LDA nmi_ctrl                                  ; $EE76: AD 7E 00
  AND #$7F                                      ; $EE79: 29 7F
  STA nmi_ctrl                                  ; $EE7B: 8D 7E 00
  JSR PpuBgTileWrite                            ; $EE7E: 20 0B EF
  PLA                                           ; $EE81: 68
  RTS                                           ; $EE82: 60
  ASL                                           ; $EE83: 0A
  JMP @test_attr                                ; $EE84: 4C 60 EE

@do_sprite:
  PHA                                           ; $EE87: 48
  LDA nmi_ctrl                                  ; $EE88: AD 7E 00
  AND #$BF                                      ; $EE8B: 29 BF
  STA nmi_ctrl                                  ; $EE8D: 8D 7E 00
  JSR PpuSpriteTileWrite                        ; $EE90: 20 71 EF
  PLA                                           ; $EE93: 68
  RTS                                           ; $EE94: 60
  JMP @test_attr                                ; $EE95: 4C 60 EE

@do_attr:
  LDA nmi_ctrl                                  ; $EE98: AD 7E 00
  AND #$DF                                      ; $EE9B: 29 DF
  STA nmi_ctrl                                  ; $EE9D: 8D 7E 00
  JMP PpuAttrTileWrite                          ; $EEA0: 4C C0 EF

@do_attr_alt:
  LDA nmi_ctrl                                  ; $EEA3: AD 7E 00
  AND #$EF                                      ; $EEA6: 29 EF
  STA nmi_ctrl                                  ; $EEA8: 8D 7E 00
  JMP PpuAttrTileWriteAlt                       ; $EEAB: 4C 28 F0

@do_bank_3d_a:
  LDY #$3D                                      ; $EEAE: A0 3D
  JSR SwitchBankAC_B                            ; $EEB0: 20 37 F2
  LDA nmi_ctrl                                  ; $EEB3: AD 7E 00
  AND #$F7                                      ; $EEB6: 29 F7
  STA nmi_ctrl                                  ; $EEB8: 8D 7E 00
  JMP $A00C                                     ; $EEBB: 4C 0C A0

@do_bank_3d_b:
  LDA nmi_ctrl                                  ; $EEBE: AD 7E 00
  AND #$FB                                      ; $EEC1: 29 FB
  STA nmi_ctrl                                  ; $EEC3: 8D 7E 00
  LDY #$3D                                      ; $EEC6: A0 3D
  JSR SwitchBankAC_B                            ; $EEC8: 20 37 F2
  JMP $A006                                     ; $EECB: 4C 06 A0

@do_bank_3d_c:
  LDA nmi_ctrl                                  ; $EECE: AD 7E 00
  AND #$FD                                      ; $EED1: 29 FD
  STA nmi_ctrl                                  ; $EED3: 8D 7E 00
  LDY #$3D                                      ; $EED6: A0 3D
  JSR SwitchBankAC_B                            ; $EED8: 20 37 F2
  JMP $A012                                     ; $EEDB: 4C 12 A0

@do_bank_3d_d:
  LDY #$3D                                      ; $EEDE: A0 3D
  JSR SwitchBankAC_B                            ; $EEE0: 20 37 F2
  JMP $A000                                     ; $EEE3: 4C 00 A0
.endproc

;===============================================================================
; $EEE6: NMI Sub-Dispatch Alt
; Simplified variant checking fewer bits of $007E
;===============================================================================
.proc NmiSubDispatchAlt
nmi_ctrl = $007E

  LDA nmi_ctrl                                  ; $EEE6: AD 7E 00
  BMI @do_bg                                    ; $EEE9: 30 0A
  ASL                                           ; $EEEB: 0A
  BMI @do_sprite                                ; $EEEC: 30 12
  ASL                                           ; $EEEE: 0A
  BMI @do_attr                                  ; $EEEF: 30 A7
  ASL                                           ; $EEF1: 0A
  BMI @do_attr_alt                              ; $EEF2: 30 AF
  RTS                                           ; $EEF4: 60

@do_bg:
  LDA nmi_ctrl                                  ; $EEF5: AD 7E 00
  AND #$7F                                      ; $EEF8: 29 7F
  STA nmi_ctrl                                  ; $EEFA: 8D 7E 00
  JMP PpuBgTileWrite                            ; $EEFD: 4C 0B EF

@do_sprite:
  LDA nmi_ctrl                                  ; $EF00: AD 7E 00
  AND #$BF                                      ; $EF03: 29 BF
  STA nmi_ctrl                                  ; $EF05: 8D 7E 00
  JMP PpuSpriteTileWrite                        ; $EF08: 4C 71 EF
.endproc

;===============================================================================
; $EF0B: PPU BG Tile Write (Vertical increment mode)
; Writes tile data from $0142 buffer to PPU with vertical increment
; Address from $0140/$0141, length computed from $0141
;===============================================================================
.proc PpuBgTileWrite
  LDA $0141                                     ; $EF0B: AD 41 01
  STA $0001                                     ; $EF0E: 8D 01 00
  LDA $0140                                     ; $EF11: AD 40 01
  AND #$03                                      ; $EF14: 29 03
  ASL $0001                                     ; $EF16: 0E 01 00
  ROL                                           ; $EF19: 2A
  ASL $0001                                     ; $EF1A: 0E 01 00
  ROL                                           ; $EF1D: 2A
  ASL $0001                                     ; $EF1E: 0E 01 00
  ROL                                           ; $EF21: 2A
  STA $0001                                     ; $EF22: 8D 01 00
  LDA #$1E                                      ; $EF25: A9 1E
  SEC                                           ; $EF27: 38
  SBC $0001                                     ; $EF28: ED 01 00
  STA $0000                                     ; $EF2B: 8D 00 00
  LDA addr_ppu_ctrl_ram                         ; $EF2E: AD 8B 00
  ORA #$04                                      ; $EF31: 09 04
  STA PPU_CTRL                                  ; $EF33: 8D 00 20
  LDA PPU_STATUS                                ; $EF36: AD 02 20
  LDA $0140                                     ; $EF39: AD 40 01
  STA PPU_ADDR                                  ; $EF3C: 8D 06 20
  LDA $0141                                     ; $EF3F: AD 41 01
  STA PPU_ADDR                                  ; $EF42: 8D 06 20
  LDY #$00                                      ; $EF45: A0 00
@write_loop1:
  LDA $0142,Y                                   ; $EF47: B9 42 01
  STA PPU_DATA                                  ; $EF4A: 8D 07 20
  INY                                           ; $EF4D: C8
  CPY $0000                                     ; $EF4E: CC 00 00
  BCC @write_loop1                              ; $EF51: 90 F4
  LDA $0140                                     ; $EF53: AD 40 01
  AND #$FC                                      ; $EF56: 29 FC
  STA PPU_ADDR                                  ; $EF58: 8D 06 20
  LDA $0141                                     ; $EF5B: AD 41 01
  AND #$1F                                      ; $EF5E: 29 1F
  STA PPU_ADDR                                  ; $EF60: 8D 06 20
@write_loop2:
  CPY #$1E                                      ; $EF63: C0 1E
  BCS @done                                     ; $EF65: B0 09
  LDA $0142,Y                                   ; $EF67: B9 42 01
  STA PPU_DATA                                  ; $EF6A: 8D 07 20
  INY                                           ; $EF6D: C8
  BNE @write_loop2                              ; $EF6E: D0 F3
@done:
  RTS                                           ; $EF70: 60
.endproc

;===============================================================================
; $EF71: PPU Sprite Tile Write (Horizontal mode)
; Writes tile data from $0166 buffer to PPU
; Address from $0164/$0165
;===============================================================================
.proc PpuSpriteTileWrite
  LDA addr_ppu_ctrl_ram                         ; $EF71: AD 8B 00
  AND #$FB                                      ; $EF74: 29 FB
  STA PPU_CTRL                                  ; $EF76: 8D 00 20
  LDA PPU_STATUS                                ; $EF79: AD 02 20
  LDA $0164                                     ; $EF7C: AD 64 01
  STA PPU_ADDR                                  ; $EF7F: 8D 06 20
  LDA $0165                                     ; $EF82: AD 65 01
  STA PPU_ADDR                                  ; $EF85: 8D 06 20
  AND #$1F                                      ; $EF88: 29 1F
  STA $0000                                     ; $EF8A: 8D 00 00
  LDA #$20                                      ; $EF8D: A9 20
  SEC                                           ; $EF8F: 38
  SBC $0000                                     ; $EF90: ED 00 00
  STA $0000                                     ; $EF93: 8D 00 00
  LDY #$00                                      ; $EF96: A0 00
@write_loop1:
  LDA $0166,Y                                   ; $EF98: B9 66 01
  STA PPU_DATA                                  ; $EF9B: 8D 07 20
  INY                                           ; $EF9E: C8
  CPY $0000                                     ; $EF9F: CC 00 00
  BCC @write_loop1                              ; $EFA2: 90 F4
  LDA $0164                                     ; $EFA4: AD 64 01
  STA PPU_ADDR                                  ; $EFA7: 8D 06 20
  LDA $0165                                     ; $EFAA: AD 65 01
  AND #$E0                                      ; $EFAD: 29 E0
  STA PPU_ADDR                                  ; $EFAF: 8D 06 20
@write_loop2:
  CPY #$20                                      ; $EFB2: C0 20
  BCS @done                                     ; $EFB4: B0 09
  LDA $0166,Y                                   ; $EFB6: B9 66 01
  STA PPU_DATA                                  ; $EFB9: 8D 07 20
  INY                                           ; $EFBC: C8
  BNE @write_loop2                              ; $EFBD: D0 F3
@done:
  RTS                                           ; $EFBF: 60
.endproc


;===============================================================================
; $EFC0: PPU Attribute Tile Write (Vertical increment mode)
; Writes attribute data from $018A buffer using vertical PPU increment
; Address from $0188/$0189, handles wrap
;===============================================================================
.proc PpuAttrTileWrite
  LDA $0189                                     ; $EFC0: AD 89 01
  STA $0001                                     ; $EFC3: 8D 01 00
  AND #$38                                      ; $EFC6: 29 38
  LSR                                           ; $EFC8: 4A
  LSR                                           ; $EFC9: 4A
  LSR                                           ; $EFCA: 4A
  STA $0000                                     ; $EFCB: 8D 00 00
  LDA #$08                                      ; $EFCE: A9 08
  SEC                                           ; $EFD0: 38
  SBC $0000                                     ; $EFD1: ED 00 00
  STA $0000                                     ; $EFD4: 8D 00 00
  LDY #$00                                      ; $EFD7: A0 00
  LDA PPU_STATUS                                ; $EFD9: AD 02 20
@write_loop1:
  LDA $0188                                     ; $EFDC: AD 88 01
  STA PPU_ADDR                                  ; $EFDF: 8D 06 20
  LDA $0001                                     ; $EFE2: AD 01 00
  STA PPU_ADDR                                  ; $EFE5: 8D 06 20
  LDA $018A,Y                                   ; $EFE8: B9 8A 01
  STA PPU_DATA                                  ; $EFEB: 8D 07 20
  LDA $0001                                     ; $EFEE: AD 01 00
  CLC                                           ; $EFF1: 18
  ADC #$08                                      ; $EFF2: 69 08
  STA $0001                                     ; $EFF4: 8D 01 00
  INY                                           ; $EFF7: C8
  CPY $0000                                     ; $EFF8: CC 00 00
  BCC @write_loop1                              ; $EFFB: 90 DF
  LDA $0189                                     ; $EFFD: AD 89 01
  AND #$C7                                      ; $F000: 29 C7
  STA $0001                                     ; $F002: 8D 01 00
@write_loop2:
  CPY #$08                                      ; $F005: C0 08
  BCS @done                                     ; $F007: B0 1E
  LDA $0188                                     ; $F009: AD 88 01
  STA PPU_ADDR                                  ; $F00C: 8D 06 20
  LDA $0001                                     ; $F00F: AD 01 00
  STA PPU_ADDR                                  ; $F012: 8D 06 20
  LDA $018A,Y                                   ; $F015: B9 8A 01
  STA PPU_DATA                                  ; $F018: 8D 07 20
  LDA $0001                                     ; $F01B: AD 01 00
  CLC                                           ; $F01E: 18
  ADC #$08                                      ; $F01F: 69 08
  STA $0001                                     ; $F021: 8D 01 00
  INY                                           ; $F024: C8
  BNE @write_loop2                              ; $F025: D0 DE
@done:
  RTS                                           ; $F027: 60
.endproc

;===============================================================================
; $F028: PPU Attribute Tile Write (Alt - Horizontal mode)
; Writes attribute data from $019E buffer
; Address from $019C/$019D, handles wrap at 8 bytes
;===============================================================================
.proc PpuAttrTileWriteAlt
  LDA addr_ppu_ctrl_ram                         ; $F028: AD 8B 00
  AND #$FB                                      ; $F02B: 29 FB
  STA PPU_CTRL                                  ; $F02D: 8D 00 20
  LDA PPU_STATUS                                ; $F030: AD 02 20
  LDA $019C                                     ; $F033: AD 9C 01
  STA PPU_ADDR                                  ; $F036: 8D 06 20
  LDA $019D                                     ; $F039: AD 9D 01
  STA PPU_ADDR                                  ; $F03C: 8D 06 20
  AND #$07                                      ; $F03F: 29 07
  STA $0000                                     ; $F041: 8D 00 00
  LDA #$08                                      ; $F044: A9 08
  SEC                                           ; $F046: 38
  SBC $0000                                     ; $F047: ED 00 00
  STA $0000                                     ; $F04A: 8D 00 00
  LDY #$00                                      ; $F04D: A0 00
@write_loop1:
  LDA $019E,Y                                   ; $F04F: B9 9E 01
  STA PPU_DATA                                  ; $F052: 8D 07 20
  INY                                           ; $F055: C8
  CPY $0000                                     ; $F056: CC 00 00
  BCC @write_loop1                              ; $F059: 90 F4
  LDA $019C                                     ; $F05B: AD 9C 01
  STA PPU_ADDR                                  ; $F05E: 8D 06 20
  LDA $019D                                     ; $F061: AD 9D 01
  AND #$F8                                      ; $F064: 29 F8
  STA PPU_ADDR                                  ; $F066: 8D 06 20
@write_loop2:
  CPY #$08                                      ; $F069: C0 08
  BCS @done                                     ; $F06B: B0 09
  LDA $019E,Y                                   ; $F06D: B9 9E 01
  STA PPU_DATA                                  ; $F070: 8D 07 20
  INY                                           ; $F073: C8
  BNE @write_loop2                              ; $F074: D0 F3
@done:
  RTS                                           ; $F076: 60
.endproc

;===============================================================================
; $F077: Namco-163 Sound Register Change Detect
; Compares $009C and $009D, flags changes in $0094/$0095
;===============================================================================
.proc NamcoSoundRegRead
  LDA addr_ctrl_state_x                         ; $F077: AD 9C 00
  EOR addr_ctrl_state_y                         ; $F07A: 4D 9D 00
  PHA                                           ; $F07D: 48
  AND #$C0                                      ; $F07E: 29 C0
  BEQ @check_low                                ; $F080: F0 05
  LDY #$FF                                      ; $F082: A0 FF
  STY addr_input_prev_y                         ; $F084: 8C 95 00
@check_low:
  PLA                                           ; $F087: 68
  AND #$30                                      ; $F088: 29 30
  BEQ @done                                     ; $F08A: F0 05
  LDY #$FF                                      ; $F08C: A0 FF
  STY addr_input_prev_x                         ; $F08E: 8C 94 00
@done:
  RTS                                           ; $F091: 60
.endproc

;===============================================================================
; $F092: Sprite OAM Writer (with scroll offsets)
; Converts sprite data at ($00) with scroll/flip handling
; Input: $00/$01 = sprite data ptr, $02 = flip flags
;        $0A/$0B = X offset, $0C/$0D = Y offset
;        $007C = starting OAM slot index
;===============================================================================
.proc SpriteOamWriterScroll
  LDA #$00                                      ; $F092: A9 00
  STA $0003                                     ; $F094: 8D 03 00
  LDA #$F0                                      ; $F097: A9 F0
  STA $0004                                     ; $F099: 8D 04 00
  BIT $0002                                     ; $F09C: 2C 02 00
  BPL @skip_x_flip                              ; $F09F: 10 12
  LDA $000A                                     ; $F0A1: AD 0A 00
  SEC                                           ; $F0A4: 38
  SBC #$08                                      ; $F0A5: E9 08
  CMP #$F0                                      ; $F0A7: C9 F0
  BCC @store_x                                  ; $F0A9: 90 05
  SBC #$10                                      ; $F0AB: E9 10
  DEC $000B                                     ; $F0AD: CE 0B 00
@store_x:
  STA $000A                                     ; $F0B0: 8D 0A 00
@skip_x_flip:
  BIT $0002                                     ; $F0B3: 2C 02 00
  BVC @apply_scroll                             ; $F0B6: 50 0E
  LDA $000C                                     ; $F0B8: AD 0C 00
  SEC                                           ; $F0BB: 38
  SBC #$10                                      ; $F0BC: E9 10
  STA $000C                                     ; $F0BE: 8D 0C 00
  BCS @apply_scroll                             ; $F0C1: B0 03
  DEC $000D                                     ; $F0C3: CE 0D 00
@apply_scroll:
  LDA $000A                                     ; $F0C6: AD 0A 00
  SEC                                           ; $F0C9: 38
  SBC addr_scroll_y                             ; $F0CA: ED 90 00
  BCS @no_borrow_x                              ; $F0CD: B0 04
  SEC                                           ; $F0CF: 38
  SBC #$10                                      ; $F0D0: E9 10
  CLC                                           ; $F0D2: 18
@no_borrow_x:
  STA $000A                                     ; $F0D3: 8D 0A 00
  LDA $000B                                     ; $F0D6: AD 0B 00
  SBC addr_scroll_y_hi                          ; $F0D9: ED 91 00
  STA $000B                                     ; $F0DC: 8D 0B 00
  LDA $000C                                     ; $F0DF: AD 0C 00
  SEC                                           ; $F0E2: 38
  SBC addr_scroll_x                             ; $F0E3: ED 8E 00
  STA $000C                                     ; $F0E6: 8D 0C 00
  LDA $000D                                     ; $F0E9: AD 0D 00
  SBC addr_scroll_x_hi                          ; $F0EC: ED 8F 00
  STA $000D                                     ; $F0EF: 8D 0D 00
  LDY #$00                                      ; $F0F2: A0 00
  LDX addr_sprite_count                         ; $F0F4: AE 7C 00
@main_loop:
  CPX #$FF                                      ; $F0F7: E0 FF
  BNE @process_sprite                           ; $F0F9: D0 04
@end:
  STX addr_sprite_count                         ; $F0FB: 8E 7C 00
  RTS                                           ; $F0FE: 60
@process_sprite:
  LDA $000B                                     ; $F0FF: AD 0B 00
  STA $000F                                     ; $F102: 8D 0F 00
  LDA ($00),Y                                   ; $F105: B1 00
  CMP #$80                                      ; $F107: C9 80
  BEQ @end                                      ; $F109: F0 F0
  BIT $0002                                     ; $F10B: 2C 02 00
  BPL @no_x_mirror                              ; $F10E: 10 05
  LDA #$08                                      ; $F110: A9 08
  SEC                                           ; $F112: 38
  SBC ($00),Y                                   ; $F113: F1 00
@no_x_mirror:
  CMP #$80                                      ; $F115: C9 80
  BCS @negative_x                               ; $F117: B0 0F
  ADC $000A                                     ; $F119: 6D 0A 00
  STA $000E                                     ; $F11C: 8D 0E 00
  LDA $000B                                     ; $F11F: AD 0B 00
  ADC #$00                                      ; $F122: 69 00
  BEQ @visible                                  ; $F124: F0 1A
  BNE @skip_sprite                              ; $F126: D0 7E
@negative_x:
  EOR #$FF                                      ; $F128: 49 FF
  ADC #$00                                      ; $F12A: 69 00
  STA $000E                                     ; $F12C: 8D 0E 00
  LDA $000A                                     ; $F12F: AD 0A 00
  SEC                                           ; $F132: 38
  SBC $000E                                     ; $F133: ED 0E 00
  STA $000E                                     ; $F136: 8D 0E 00
  LDA $000B                                     ; $F139: AD 0B 00
  SBC #$00                                      ; $F13C: E9 00
  BNE @skip_sprite                              ; $F13E: D0 66
@visible:
  LDA $000E                                     ; $F140: AD 0E 00
  SEC                                           ; $F143: 38
  SBC #$01                                      ; $F144: E9 01
  CMP $0004                                     ; $F146: CD 04 00
  BCS @skip_sprite                              ; $F149: B0 5B
  STA $0200,X                                   ; $F14B: 9D 00 02
  INY                                           ; $F14E: C8
  LDA ($00),Y                                   ; $F14F: B1 00
  CLC                                           ; $F151: 18
  ADC $0003                                     ; $F152: 6D 03 00
  STA $0201,X                                   ; $F155: 9D 01 02
  INY                                           ; $F158: C8
  LDA ($00),Y                                   ; $F159: B1 00
  EOR $0002                                     ; $F15B: 4D 02 00
  STA $0202,X                                   ; $F15E: 9D 02 02
  INY                                           ; $F161: C8
  BIT $0002                                     ; $F162: 2C 02 00
  LDA ($00),Y                                   ; $F165: B1 00
  BVC @no_y_mirror                              ; $F167: 50 05
  LDA #$08                                      ; $F169: A9 08
  SEC                                           ; $F16B: 38
  SBC ($00),Y                                   ; $F16C: F1 00
@no_y_mirror:
  BPL @positive_y                               ; $F16E: 10 26
  EOR #$FF                                      ; $F170: 49 FF
  STA $000E                                     ; $F172: 8D 0E 00
  LDA $000C                                     ; $F175: AD 0C 00
  SEC                                           ; $F178: 38
  SBC $000E                                     ; $F179: ED 0E 00
  STA $0203,X                                   ; $F17C: 9D 03 02
  LDA $000D                                     ; $F17F: AD 0D 00
  SBC #$00                                      ; $F182: E9 00
  BNE @skip_y_offscreen                         ; $F184: D0 0C
@advance_slot:
  INY                                           ; $F186: C8
  INX                                           ; $F187: E8
  INX                                           ; $F188: E8
  INX                                           ; $F189: E8
  INX                                           ; $F18A: E8
  BNE @back_to_loop                             ; $F18B: D0 02
  LDX #$FF                                      ; $F18D: A2 FF
@back_to_loop:
  JMP @main_loop                                ; $F18F: 4C F7 F0
@skip_y_offscreen:
  INY                                           ; $F192: C8
  JMP @main_loop                                ; $F193: 4C F7 F0
@positive_y:
  CLC                                           ; $F196: 18
  ADC $000C                                     ; $F197: 6D 0C 00
  STA $0203,X                                   ; $F19A: 9D 03 02
  LDA $000D                                     ; $F19D: AD 0D 00
  ADC #$00                                      ; $F1A0: 69 00
  BEQ @advance_slot                             ; $F1A2: F0 E2
  BNE @skip_y_offscreen                         ; $F1A4: D0 EC
@skip_sprite:
  INY                                           ; $F1A6: C8
  INY                                           ; $F1A7: C8
  INY                                           ; $F1A8: C8
  INY                                           ; $F1A9: C8
  JMP @main_loop                                ; $F1AA: 4C F7 F0
.endproc

;===============================================================================
; $F1AD: Sprite OAM Writer (Simple - no scroll)
; Converts sprite data at ($00) directly to OAM
; Input: $00/$01 = sprite data ptr, $02 = flip flags
;        $0A = X base, $0C = Y base, $007C = OAM slot
;===============================================================================
.proc SpriteOamWriterSimple
  LDA #$00                                      ; $F1AD: A9 00
  STA $0003                                     ; $F1AF: 8D 03 00
  LDA #$00                                      ; $F1B2: A9 00
  STA $0004                                     ; $F1B4: 8D 04 00
  LDY #$00                                      ; $F1B7: A0 00
  LDX addr_sprite_count                         ; $F1B9: AE 7C 00
@main_loop:
  CPX #$FF                                      ; $F1BC: E0 FF
  BNE @process                                  ; $F1BE: D0 04
@end:
  STX addr_sprite_count                         ; $F1C0: 8E 7C 00
  RTS                                           ; $F1C3: 60
@process:
  LDA ($00),Y                                   ; $F1C4: B1 00
  CMP #$80                                      ; $F1C6: C9 80
  BEQ @end                                      ; $F1C8: F0 F6
  CLC                                           ; $F1CA: 18
  ADC $000A                                     ; $F1CB: 6D 0A 00
  CMP $0004                                     ; $F1CE: CD 04 00
  BCS @write_oam                                ; $F1D1: B0 07
  INY                                           ; $F1D3: C8
  INY                                           ; $F1D4: C8
  INY                                           ; $F1D5: C8
  INY                                           ; $F1D6: C8
  JMP @process                                  ; $F1D7: 4C C4 F1
@write_oam:
  STA $0200,X                                   ; $F1DA: 9D 00 02
  INY                                           ; $F1DD: C8
  LDA ($00),Y                                   ; $F1DE: B1 00
  CLC                                           ; $F1E0: 18
  ADC $0003                                     ; $F1E1: 6D 03 00
  STA $0201,X                                   ; $F1E4: 9D 01 02
  INY                                           ; $F1E7: C8
  LDA ($00),Y                                   ; $F1E8: B1 00
  EOR $0002                                     ; $F1EA: 4D 02 00
  STA $0202,X                                   ; $F1ED: 9D 02 02
  INY                                           ; $F1F0: C8
  LDA ($00),Y                                   ; $F1F1: B1 00
  CLC                                           ; $F1F3: 18
  ADC $000C                                     ; $F1F4: 6D 0C 00
  STA $0203,X                                   ; $F1F7: 9D 03 02
  INY                                           ; $F1FA: C8
  INX                                           ; $F1FB: E8
  INX                                           ; $F1FC: E8
  INX                                           ; $F1FD: E8
  INX                                           ; $F1FE: E8
  BNE @main_loop                                ; $F1FF: D0 BB
  LDX #$FF                                      ; $F201: A2 FF
  JMP @end                                      ; $F203: 4C C0 F1
.endproc

;===============================================================================
; $F206: CHR Bank Switch
; Writes 8 CHR bank values from $00AE-$00B5 to Namco-163
; CHR registers at $8000/$8800/$9000/$9800/$A000/$A800/$B000/$B800
;===============================================================================
.proc ChrBankSwitch
  LDA addr_chr_bank_0                           ; $F206: AD AE 00
  STA $8000                                     ; $F209: 8D 00 80
  LDA addr_chr_bank_1                           ; $F20C: AD AF 00
  STA $8800                                     ; $F20F: 8D 00 88
  LDA addr_chr_bank_2                           ; $F212: AD B0 00
  STA $9000                                     ; $F215: 8D 00 90
  LDA addr_chr_bank_3                           ; $F218: AD B1 00
  STA $9800                                     ; $F21B: 8D 00 98
  LDA addr_chr_bank_4                           ; $F21E: AD B2 00
  STA $A000                                     ; $F221: 8D 00 A0
  LDA addr_chr_bank_5                           ; $F224: AD B3 00
  STA $A800                                     ; $F227: 8D 00 A8
  LDA addr_chr_bank_6                           ; $F22A: AD B4 00
  STA $B000                                     ; $F22D: 8D 00 B0
  LDA addr_chr_bank_7                           ; $F230: AD B5 00
  STA $B800                                     ; $F233: 8D 00 B8
  RTS                                           ; $F236: 60
.endproc

;===============================================================================
; $F237: Switch Bank Pair at $A000+$C000 (Slot B)
; Input: Y = bank number for $A000 window (Y+1 maps to $C000)
; Writes to Namco-163 registers NAMCO_PRG_A000 (A000, with CHR flags $C0) and NAMCO_PRG_C000 (C000)
; Saves bank numbers to RAM slot B ($00E2, $00E3)
;===============================================================================
.proc SwitchBankAC_B
  STY addr_prg_select_2b                        ; $F237: 8C E2 00
  INY                                           ; $F23A: C8
  STY addr_prg_select_3b                        ; $F23B: 8C E3 00
  ; Write NAMCO_PRG_C000 first: Y already holds bank Y+1 for the $C000 window.
  ; NAMCO_PRG_C000 only needs the raw bank number (bits 0-5), so STY works directly.
  STY NAMCO_PRG_C000                                     ; $F23E: 8C 00 F0
  DEY                                           ; $F241: 88
  ; Write NAMCO_PRG_A000 second: the $A000 register requires bits 6-7 set ($C0)
  ; to disable CHR-RAM. This needs ORA in A, so we save/restore caller's A.
  PHA                                           ; $F242: 48
  TYA                                           ; $F243: 98
  ORA #$C0                                      ; $F244: 09 C0
  STA NAMCO_PRG_A000                                     ; $F246: 8D 00 E8
  PLA                                           ; $F249: 68
  RTS                                           ; $F24A: 60
.endproc

;===============================================================================
; $F24B: Switch Bank Pair at $A000+$C000 (Slot A)
; Input: Y = bank number for $A000 window (Y+1 maps to $C000)
; Writes to Namco-163 registers NAMCO_PRG_A000 (A000, with CHR flags $C0) and NAMCO_PRG_C000 (C000)
; Saves bank numbers to RAM slot A ($00DF, $00E0)
;===============================================================================
.proc SwitchBankAC_A
  STY addr_prg_select_2a                        ; $F24B: 8C DF 00
  INY                                           ; $F24E: C8
  STY addr_prg_select_3a                        ; $F24F: 8C E0 00
  STY NAMCO_PRG_C000                                     ; $F252: 8C 00 F0
  DEY                                           ; $F255: 88
  PHA                                           ; $F256: 48
  TYA                                           ; $F257: 98
  ORA #$C0                                      ; $F258: 09 C0
  STA NAMCO_PRG_A000                                     ; $F25A: 8D 00 E8
  PLA                                           ; $F25D: 68
  RTS                                           ; $F25E: 60
.endproc

;===============================================================================
; $F25F: Switch Bank at $8000 (Slot B)
; Input: Y = bank number for $8000-$9FFF window
; Writes to Namco-163 register NAMCO_PRG_8000, saves to RAM slot B ($00E1)
;===============================================================================
.proc SwitchBank8_B
  STY addr_prg_select_1b                        ; $F25F: 8C E1 00
  STY NAMCO_PRG_8000                                     ; $F262: 8C 00 E0
  RTS                                           ; $F265: 60
.endproc

;===============================================================================
; $F266: Switch Bank at $8000 (Slot A)
; Input: Y = bank number for $8000-$9FFF window
; Writes to Namco-163 register NAMCO_PRG_8000, saves to RAM slot A ($00DE)
;===============================================================================
.proc SwitchBank8_A
  STY addr_prg_select_1a                        ; $F266: 8C DE 00
  STY NAMCO_PRG_8000                                     ; $F269: 8C 00 E0
  RTS                                           ; $F26C: 60
.endproc

;===============================================================================
; $F26D: Set UI Mode 0
; Input: A = UI ID
; Sets UI sub-ID to 0, clears next/FF markers
;===============================================================================
.proc SetUI0
  STA $0311                                     ; $F26D: 8D 11 03
  LDA #$00                                      ; $F270: A9 00
@common:
  STA $0310                                     ; $F272: 8D 10 03
  LDA #$FF                                      ; $F275: A9 FF
  STA $0312                                     ; $F277: 8D 12 03
  STA $0313                                     ; $F27A: 8D 13 03
  LDA #$00                                      ; $F27D: A9 00
  STA $0300                                     ; $F27F: 8D 00 03
  RTS                                           ; $F282: 60
.endproc

;===============================================================================
; $F283: Set UI Mode 2
; Input: A = UI ID
;===============================================================================
.proc SetUI2
  STA $0311                                     ; $F283: 8D 11 03
  LDA #$02                                      ; $F286: A9 02
  JMP SetUI0::@common                           ; $F288: 4C 72 F2
.endproc

;===============================================================================
; $F28B: Set UI Mode 4
; Input: A = UI ID
;===============================================================================
.proc SetUI4
  STA $0311                                     ; $F28B: 8D 11 03
  LDA #$04                                      ; $F28E: A9 04
  JMP SetUI0::@common                           ; $F290: 4C 72 F2
.endproc

;===============================================================================
; $F293: Set UI Mode 5
; Input: A = UI ID
;===============================================================================
.proc SetUI5
  STA $0311                                     ; $F293: 8D 11 03
  LDA #$05                                      ; $F296: A9 05
  JMP SetUI0::@common                           ; $F298: 4C 72 F2
.endproc

;===============================================================================
; $F29B: Clear UI
; Clears all UI state, sets UI ID to $FF
;===============================================================================
.proc ClearUI
  STA $0310                                     ; $F29B: 8D 10 03
  LDA #$FF                                      ; $F29E: A9 FF
  STA $0311                                     ; $F2A0: 8D 11 03
  STA $0312                                     ; $F2A3: 8D 12 03
  STA $0313                                     ; $F2A6: 8D 13 03
  LDA #$00                                      ; $F2A9: A9 00
  STA $0300                                     ; $F2AB: 8D 00 03
  RTS                                           ; $F2AE: 60
.endproc

;===============================================================================
; $F2AF: GetProvinceRecordAddr
; Computes: A * 32 + $6000 -> ($0000, $0001) as 16-bit pointer
; Input: A = province index
; Output: $0000/$0001 = 16-bit pointer to province record in SRAM
; Used for: Province data record lookup (32 bytes per entry, base $6000)
;===============================================================================
.proc GetProvinceRecordAddr
  LDY #$00                                      ; $F2AF: A0 00
  STY $0001                                     ; $F2B1: 8C 01 00
  ASL A                                         ; $F2B4: 0A
  ROL $0001                                     ; $F2B5: 2E 01 00
  ASL A                                         ; $F2B8: 0A
  ROL $0001                                     ; $F2B9: 2E 01 00
  ASL A                                         ; $F2BC: 0A
  ROL $0001                                     ; $F2BD: 2E 01 00
  ASL A                                         ; $F2C0: 0A
  ROL $0001                                     ; $F2C1: 2E 01 00
  ASL A                                         ; $F2C4: 0A
  ROL $0001                                     ; $F2C5: 2E 01 00
  CLC                                           ; $F2C8: 18
  ADC #$00                                      ; $F2C9: 69 00
  STA $0000                                     ; $F2CB: 8D 00 00
  LDA $0001                                     ; $F2CE: AD 01 00
  ADC #$60                                      ; $F2D1: 69 60
  STA $0001                                     ; $F2D3: 8D 01 00
  RTS                                           ; $F2D6: 60
.endproc

;===============================================================================
; $F2D7: GetOfficerRecordAddr
; Computes: A * 12 + $63C0 -> ($0000, $0001) as 16-bit pointer
; Input: A = officer index
; Output: $0000/$0001 = 16-bit pointer to officer record in SRAM
; Method: A*2 + A = A*3, then shift left twice = A*12, add base $63C0
; Used for: Officer data record lookup (12 bytes per entry, base $63C0)
;===============================================================================
.proc GetOfficerRecordAddr
  LDY #$00                                      ; $F2D7: A0 00
  STY $0001                                     ; $F2D9: 8C 01 00
  STA $0000                                     ; $F2DC: 8D 00 00
  ASL A                                         ; $F2DF: 0A
  ROL $0001                                     ; $F2E0: 2E 01 00
  CLC                                           ; $F2E3: 18
  ADC $0000                                     ; $F2E4: 6D 00 00
  PHA                                           ; $F2E7: 48
  LDA $0001                                     ; $F2E8: AD 01 00
  ADC #$00                                      ; $F2EB: 69 00
  STA $0001                                     ; $F2ED: 8D 01 00
  PLA                                           ; $F2F0: 68
  ASL A                                         ; $F2F1: 0A
  ROL $0001                                     ; $F2F2: 2E 01 00
  ASL A                                         ; $F2F5: 0A
  ROL $0001                                     ; $F2F6: 2E 01 00
  CLC                                           ; $F2F9: 18
  ADC #$C0                                      ; $F2FA: 69 C0
  STA $0000                                     ; $F2FC: 8D 00 00
  LDA $0001                                     ; $F2FF: AD 01 00
  ADC #$63                                      ; $F302: 69 63
  STA $0001                                     ; $F304: 8D 01 00
  RTS                                           ; $F307: 60
.endproc

;===============================================================================
; $F308: GetNameDisplayScale
; Switches to PRG bank $10 at $8000, computes address = A*10 + $901A,
; then scans string at that address counting characters that are not
; separator bytes ($39/$3A) or null terminator ($00).
; Returns a display scale value from NameScaleTable based on count.
; Input: A = name string index
; Output: A = display scale value from table (3,3,3,2,2,1,1,0,0) leading spaces
;===============================================================================
.proc GetNameDisplayScale
  STA $0002                                     ; $F308: 8D 02 00
  LDY #$30                                      ; $F30B: A0 30
  JSR SwitchBank8_B                             ; $F30D: 20 5F F2
  LDA #$00                                      ; $F310: A9 00
  STA $0001                                     ; $F312: 8D 01 00
  LDA $0002                                     ; $F315: AD 02 00
  ASL A                                         ; $F318: 0A
  ROL $0001                                     ; $F319: 2E 01 00
  ASL A                                         ; $F31C: 0A
  ROL $0001                                     ; $F31D: 2E 01 00
  CLC                                           ; $F320: 18
  ADC $0002                                     ; $F321: 6D 02 00
  STA $0000                                     ; $F324: 8D 00 00
  LDA $0001                                     ; $F327: AD 01 00
  ADC #$00                                      ; $F32A: 69 00
  STA $0001                                     ; $F32C: 8D 01 00
  ASL $0000                                     ; $F32F: 0E 00 00
  ROL $0001                                     ; $F332: 2E 01 00
  LDA $0000                                     ; $F335: AD 00 00
  CLC                                           ; $F338: 18
  ADC #$1A                                      ; $F339: 69 1A
  STA $0000                                     ; $F33B: 8D 00 00
  LDA $0001                                     ; $F33E: AD 01 00
  ADC #$90                                      ; $F341: 69 90
  STA $0001                                     ; $F343: 8D 01 00
  LDY #$00                                      ; $F346: A0 00
  LDX #$00                                      ; $F348: A2 00
@scan_loop:
  LDA ($00),Y                                   ; $F34A: B1 00
  BEQ @done                                     ; $F34C: F0 0D
  INY                                           ; $F34E: C8
  CMP #$39                                      ; $F34F: C9 39
  BEQ @scan_loop                                ; $F351: F0 F7
  CMP #$3A                                      ; $F353: C9 3A
  BEQ @scan_loop                                ; $F355: F0 F3
  INX                                           ; $F357: E8
  JMP @scan_loop                                ; $F358: 4C 4A F3
@done:
  LDA NameScaleTable,X                          ; $F35B: BD 5F F3
  RTS                                           ; $F35E: 60
.endproc

;===============================================================================
; $F35F: NameScaleTable
; Maps character count (X=0..8) to a display scale value.
; Higher counts yield lower values (more compressed display).
;===============================================================================
NameScaleTable:
  .byte $03,$03,$03,$02,$02,$01,$01,$00,$00      ; $F35F: 03 03 03 02 02 01 01 00 00

;===============================================================================
; $F368: GetRulerDataPtr
; Masks A to low 4 bits (ruler index 0-6), looks up SRAM pointer.
; Input: A = value (low nibble = ruler index, 0-6 valid)
; Output: $0000/$0001 = 16-bit pointer to ruler's 8-byte data block
;===============================================================================
.proc GetRulerDataPtr
  AND #$0F                                      ; $F368: 29 0F
  ASL A                                         ; $F36A: 0A
  TAY                                           ; $F36B: A8
  LDA RulerDataPtrTable,Y                       ; $F36C: B9 79 F3
  STA $0000                                     ; $F36F: 8D 00 00
  LDA RulerDataPtrTable+1,Y                     ; $F372: B9 7A F3
  STA $0001                                     ; $F375: 8D 01 00
  RTS                                           ; $F378: 60
.endproc

;===============================================================================
; $F379: RulerDataPtrTable
; 7 word entries pointing to per-ruler 8-byte SRAM blocks ($6F07-$6F37)
;===============================================================================
RulerDataPtrTable:
  .word $6F07                                   ; $F379: 07 6F
  .word $6F0F                                   ; $F37B: 0F 6F
  .word $6F17                                   ; $F37D: 17 6F
  .word $6F1F                                   ; $F37F: 1F 6F
  .word $6F27                                   ; $F381: 27 6F
  .word $6F2F                                   ; $F383: 2F 6F
  .word $6F37                                   ; $F385: 37 6F

;===============================================================================
; $F387: GetOfficerRomRecordAddr
; Switches to PRG bank $11 at $8000, computes: A * 12 + $8000
; Input: A = officer index
; Output: $0000/$0001 = 16-bit pointer to officer ROM record (bank $11)
; Method: A*2 + A = A*3, then shift left twice = A*12, add base $8000
; Used for: ROM-based default officer data lookup (12 bytes per entry)
;===============================================================================
.proc GetOfficerRomRecordAddr
  LDY #$31                                      ; $F387: A0 31
  JSR SwitchBank8_B                             ; $F389: 20 5F F2
  LDY #$00                                      ; $F38C: A0 00
  STY $0001                                     ; $F38E: 8C 01 00
  STA $0000                                     ; $F391: 8D 00 00
  ASL A                                         ; $F394: 0A
  ROL $0001                                     ; $F395: 2E 01 00
  CLC                                           ; $F398: 18
  ADC $0000                                     ; $F399: 6D 00 00
  PHA                                           ; $F39C: 48
  LDA $0001                                     ; $F39D: AD 01 00
  ADC #$00                                      ; $F3A0: 69 00
  STA $0001                                     ; $F3A2: 8D 01 00
  PLA                                           ; $F3A5: 68
  ASL A                                         ; $F3A6: 0A
  ROL $0001                                     ; $F3A7: 2E 01 00
  ASL A                                         ; $F3AA: 0A
  ROL $0001                                     ; $F3AB: 2E 01 00
  CLC                                           ; $F3AE: 18
  ADC #$00                                      ; $F3AF: 69 00
  STA $0000                                     ; $F3B1: 8D 00 00
  LDA $0001                                     ; $F3B4: AD 01 00
  ADC #$80                                      ; $F3B7: 69 80
  STA $0001                                     ; $F3B9: 8D 01 00
  RTS                                           ; $F3BC: 60
.endproc

;===============================================================================
; $F3BD: CopyProtectionCheck
; Initializes Namco-163 mapper (IRQ disable, nametable mapping), then performs
; a controller port 2 bit-verification against code bytes. Under normal
; hardware conditions the check fails early and returns via RTS.
; If the check passes (anti-piracy trigger), performs RAM test and halts
; with a diagnostic palette color.
; Input: None
; Output: Returns normally if check fails (expected); halts if check passes
;===============================================================================
.proc CopyProtectionCheck
  LDA #$00                                      ; $F3BD: A9 00
  STA $5000                                     ; $F3BF: 8D 00 50
  STA $5800                                     ; $F3C2: 8D 00 58
  LDA #$E0                                      ; $F3C5: A9 E0
  STA NAMCO_CHR_BANK_0                                     ; $F3C7: 8D 00 C0
  STA NAMCO_CHR_BANK_2                                     ; $F3CA: 8D 00 D0
  LDA #$E1                                      ; $F3CD: A9 E1
  STA NAMCO_CHR_BANK_1                                     ; $F3CF: 8D 00 C8
  STA NAMCO_CHR_BANK_3                                     ; $F3D2: 8D 00 D8
  LDX #$00                                      ; $F3D5: A2 00
@check_loop:
  LDA CopyProtectionCheck,X                                   ; $F3D7: BD BD F3
  AND #$01                                      ; $F3DA: 29 01
  STA $0001                                     ; $F3DC: 8D 01 00
  STA APU_JOY1                                   ; $F3DF: 8D 16 40
  LDA APU_JOY2                                   ; $F3E2: AD 17 40
  LSR A                                         ; $F3E5: 4A
  EOR #$FF                                      ; $F3E6: 49 FF
  AND #$01                                      ; $F3E8: 29 01
  CMP $0001                                     ; $F3EA: CD 01 00
  BNE @normal_exit                              ; $F3ED: D0 32
  INX                                           ; $F3EF: E8
  CPX #$46                                      ; $F3F0: E0 46
  BNE @check_loop                               ; $F3F2: D0 E3
  ; --- Anti-piracy path: all 70 checks passed (should not happen normally) ---
  LDA #$40                                      ; $F3F4: A9 40
  STA NAMCO_PRG_8000_ALT                             ; $F3F6: 8D 00 F8
  LDX #$01                                      ; $F3F9: A2 01
  JSR VerifyRamPattern                          ; $F3FB: 20 22 F4
  BEQ @display_error                            ; $F3FE: F0 0C
  LDX #$37                                      ; $F400: A2 37
  JSR WriteRamPattern                           ; $F402: 20 3F F4
  JSR VerifyRamPattern                          ; $F405: 20 22 F4
  BEQ @display_error                            ; $F408: F0 02
  LDX #$16                                      ; $F40A: A2 16
@display_error:
  LDA #$3F                                      ; $F40C: A9 3F
  STA PPU_ADDR                                   ; $F40E: 8D 06 20
  LDY #$00                                      ; $F411: A0 00
  STY PPU_ADDR                                   ; $F413: 8C 06 20
@fill_palette:
  STX PPU_DATA                                   ; $F416: 8E 07 20
  INY                                           ; $F419: C8
  CPY #$20                                      ; $F41A: C0 20
  BNE @fill_palette                             ; $F41C: D0 F8
@halt_loop:
  JMP @halt_loop                                ; $F41E: 4C 1E F4
@normal_exit:
  RTS                                           ; $F421: 60
.endproc

;===============================================================================
; $F422: VerifyRamPattern
; Verifies that RAM ($6000-$7FFF) contains the expected pseudo-random pattern.
; Initializes parameters via InitRamTestParams, then reads each byte and
; compares against the hash-generated expected value.
; Output: Z=1 (A=0) if all match; Z=0 (A=mismatch value) if any differ
;===============================================================================
.proc VerifyRamPattern
  JSR InitRamTestParams                         ; $F422: 20 58 F4
@verify_loop:
  LDA ($02),Y                                   ; $F425: B1 02
  CMP $0000                                     ; $F427: CD 00 00
  BNE @fail                                     ; $F42A: D0 12
  JSR AdvanceHashPattern                        ; $F42C: 20 68 F4
  INY                                           ; $F42F: C8
  BNE @verify_loop                              ; $F430: D0 F3
  INC $0003                                     ; $F432: EE 03 00
  LDA $0003                                     ; $F435: AD 03 00
  CMP #$80                                      ; $F438: C9 80
  BNE @verify_loop                              ; $F43A: D0 E9
  LDA #$00                                      ; $F43C: A9 00
@fail:
  RTS                                           ; $F43E: 60
.endproc

;===============================================================================
; $F43F: WriteRamPattern
; Fills RAM ($6000-$7FFF) with a pseudo-random pattern generated by
; AdvanceHashPattern. Used to write a test pattern for later verification.
;===============================================================================
.proc WriteRamPattern
  JSR InitRamTestParams                         ; $F43F: 20 58 F4
@write_loop:
  LDA $0000                                     ; $F442: AD 00 00
  STA ($02),Y                                   ; $F445: 91 02
  JSR AdvanceHashPattern                        ; $F447: 20 68 F4
  INY                                           ; $F44A: C8
  BNE @write_loop                               ; $F44B: D0 F5
  INC $0003                                     ; $F44D: EE 03 00
  LDA $0003                                     ; $F450: AD 03 00
  CMP #$80                                      ; $F453: C9 80
  BNE @write_loop                               ; $F455: D0 EB
  RTS                                           ; $F457: 60
.endproc

;===============================================================================
; $F458: InitRamTestParams
; Initializes parameters for RAM test routines.
; Sets pointer ($02/$03) = $6000, pattern seed ($0000) = $AA, Y = 0
;===============================================================================
.proc InitRamTestParams
  LDY #$00                                      ; $F458: A0 00
  STY $0002                                     ; $F45A: 8C 02 00
  LDA #$60                                      ; $F45D: A9 60
  STA $0003                                     ; $F45F: 8D 03 00
  LDA #$AA                                      ; $F462: A9 AA
  STA $0000                                     ; $F464: 8D 00 00
  RTS                                           ; $F467: 60
.endproc

;===============================================================================
; $F468: AdvanceHashPattern
; Advances the pseudo-random hash value in $0000.
; Algorithm: value = (value << 2) + value + 1 (SEC before ADC)
; If result is zero, retries to avoid zero values.
; Input/Output: $0000 = current/next hash value
;===============================================================================
.proc AdvanceHashPattern
@retry:
  LDA $0000                                     ; $F468: AD 00 00
  ASL A                                         ; $F46B: 0A
  ASL A                                         ; $F46C: 0A
  SEC                                           ; $F46D: 38
  ADC $0000                                     ; $F46E: 6D 00 00
  STA $0000                                     ; $F471: 8D 00 00
  BEQ @retry                                    ; $F474: F0 F2
  RTS                                           ; $F476: 60
.endproc

;===============================================================================
; $F477: MetaTileData
; Metatile attribute/composition data table (497 bytes).
; Used for map tile rendering and attribute lookup.
;===============================================================================
MetaTileData:
  .byte $00,$00,$00,$00,$01,$01,$01,$01,$14,$15,$24,$25,$07,$08,$17,$18 ; $F477: 00 00 00 00 01 01 01 01 14 15 24 25 07 08 17 18
  .byte $07,$27,$1A,$25,$26,$08,$24,$1B,$12,$15,$17,$37,$14,$13,$36,$18 ; $F487: 07 27 1A 25 26 08 24 1B 12 15 17 37 14 13 36 18
  .byte $07,$0A,$1A,$25,$0A,$08,$24,$1B,$12,$15,$17,$0A,$14,$13,$0A,$18 ; $F497: 07 0A 1A 25 0A 08 24 1B 12 15 17 0A 14 13 0A 18
  .byte $26,$0A,$0A,$0A,$0A,$27,$0A,$0A,$0A,$0A,$0A,$37,$0A,$0A,$36,$0A ; $F4A7: 26 0A 0A 0A 0A 27 0A 0A 0A 0A 0A 37 0A 0A 36 0A
  .byte $26,$27,$0A,$0A,$0A,$0A,$36,$37,$0A,$27,$0A,$37,$26,$0A,$36,$0A ; $F4B7: 26 27 0A 0A 0A 0A 36 37 0A 27 0A 37 26 0A 36 0A
  .byte $26,$27,$24,$25,$14,$15,$36,$37,$07,$27,$17,$37,$26,$08,$36,$18 ; $F4C7: 26 27 24 25 14 15 36 37 07 27 17 37 26 08 36 18
  .byte $0A,$0A,$24,$25,$14,$15,$0A,$0A,$07,$0A,$17,$0A,$0A,$08,$0A,$18 ; $F4D7: 0A 0A 24 25 14 15 0A 0A 07 0A 17 0A 0A 08 0A 18
  .byte $22,$23,$04,$05,$34,$35,$32,$33,$22,$06,$32,$16,$09,$23,$19,$33 ; $F4E7: 22 23 04 05 34 35 32 33 22 06 32 16 09 23 19 33
  .byte $0C,$0D,$1C,$1D,$0E,$0F,$1E,$1F,$22,$40,$32,$50,$41,$42,$51,$52 ; $F4F7: 0C 0D 1C 1D 0E 0F 1E 1F 22 40 32 50 41 42 51 52
  .byte $43,$44,$53,$54,$22,$23,$55,$33,$46,$42,$56,$54,$22,$23,$55,$33 ; $F507: 43 44 53 54 22 23 55 33 46 42 56 54 22 23 55 33
  .byte $2C,$2D,$3C,$3D,$2E,$2F,$3E,$3F,$20,$21,$30,$31,$22,$23,$45,$33 ; $F517: 2C 2D 3C 3D 2E 2F 3E 3F 20 21 30 31 22 23 45 33
  .byte $2A,$2B,$3A,$3B,$60,$63,$70,$73,$22,$23,$48,$49,$58,$59,$32,$33 ; $F527: 2A 2B 3A 3B 60 63 70 73 22 23 48 49 58 59 32 33
  .byte $22,$57,$32,$33,$5A,$23,$32,$33,$22,$23,$32,$47,$22,$23,$4A,$33 ; $F537: 22 57 32 33 5A 23 32 33 22 23 32 47 22 23 4A 33
  .byte $22,$4B,$32,$5B,$4C,$23,$5C,$33,$60,$61,$5D,$3B,$62,$63,$3A,$5E ; $F547: 22 4B 32 5B 4C 23 5C 33 60 61 5D 3B 62 63 3A 5E
  .byte $4D,$2B,$70,$71,$22,$23,$32,$33,$60,$4E,$70,$73,$60,$63,$5D,$5E ; $F557: 4D 2B 70 71 22 23 32 33 60 4E 70 73 60 63 5D 5E
  .byte $60,$61,$70,$71,$62,$63,$72,$73,$4D,$4E,$5D,$5E,$62,$61,$72,$71 ; $F567: 60 61 70 71 62 63 72 73 4D 4E 5D 5E 62 61 72 71
  .byte $0A,$27,$24,$25,$0A,$08,$36,$18,$26,$08,$0A,$18,$14,$15,$36,$0A ; $F577: 0A 27 24 25 0A 08 36 18 26 08 0A 18 14 15 36 0A
  .byte $14,$15,$0A,$37,$07,$27,$17,$0A,$07,$0A,$17,$37,$26,$0A,$24,$25 ; $F587: 14 15 0A 37 07 27 17 0A 07 0A 17 37 26 0A 24 25
  .byte $4C,$4B,$4F,$5F,$2A,$4E,$72,$73,$2A,$2B,$72,$71,$62,$61,$3A,$3B ; $F597: 4C 4B 4F 5F 2A 4E 72 73 2A 2B 72 71 62 61 3A 3B
  .byte $22,$23,$32,$33,$64,$23,$64,$33,$22,$74,$32,$74,$65,$65,$32,$33 ; $F5A7: 22 23 32 33 64 23 64 33 22 74 32 74 65 65 32 33
  .byte $22,$23,$75,$75,$66,$66,$65,$33,$22,$75,$66,$66,$66,$23,$66,$64 ; $F5B7: 22 23 75 75 66 66 65 33 22 75 66 66 66 23 66 64
  .byte $22,$66,$74,$66,$22,$23,$55,$33,$2C,$2D,$67,$3D,$0B,$35,$19,$33 ; $F5C7: 22 66 74 66 22 23 55 33 2C 2D 67 3D 0B 35 19 33
  .byte $22,$06,$04,$76,$43,$68,$53,$78,$09,$23,$77,$05,$6A,$0D,$7A,$1D ; $F5D7: 22 06 04 76 43 68 53 78 09 23 77 05 6A 0D 7A 1D
  .byte $6B,$2D,$7B,$3D,$69,$21,$79,$31,$0A,$0A,$0A,$0A,$4D,$3B,$5D,$3B ; $F5E7: 6B 2D 7B 3D 69 21 79 31 0A 0A 0A 0A 4D 3B 5D 3B
  .byte $22,$23,$32,$33,$22,$23,$32,$33,$8C,$8D,$86,$87,$88,$89,$8C,$8D ; $F5F7: 22 23 32 33 22 23 32 33 8C 8D 86 87 88 89 8C 8D
  .byte $8A,$8B,$8E,$8F,$14,$13,$24,$1B,$3B,$4E,$3B,$5E,$12,$13,$17,$18 ; $F607: 8A 8B 8E 8F 14 13 24 1B 3B 4E 3B 5E 12 13 17 18
  .byte $D2,$15,$1A,$25,$17,$18,$1A,$1B,$6C,$01,$01,$01,$01,$01,$7C,$01 ; $F617: D2 15 1A 25 17 18 1A 1B 6C 01 01 01 01 01 7C 01
  .byte $01,$6D,$01,$01,$01,$01,$01,$7D,$6E,$23,$7E,$33,$23,$6F,$33,$7F ; $F627: 01 6D 01 01 01 01 01 7D 6E 23 7E 33 23 6F 33 7F
  .byte $01,$6D,$01,$7D,$6E,$23,$23,$23,$6E,$33,$23,$33,$33,$6F,$33,$33 ; $F637: 01 6D 01 7D 6E 23 23 23 6E 33 23 33 33 6F 33 33
  .byte $01,$01,$7C,$7D,$33,$6F,$33,$33,$6E,$6F,$22,$22,$26,$0A,$0A,$37 ; $F647: 01 01 7C 7D 33 6F 33 33 6E 6F 22 22 26 0A 0A 37
  .byte $0A,$27,$36,$0A,$22,$23,$32,$33,$22,$23,$32,$33,$22,$23,$32,$33 ; $F657: 0A 27 36 0A 22 23 32 33 22 23 32 33 22 23 32 33

;===============================================================================
; $F667-$F67E: Unused padding (24 bytes of $00)
;===============================================================================
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $F667: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00                 ; $F677: 00 00 00 00 00 00 00 00

;===============================================================================
; $F67F-$F7FF: Unused space (385 bytes of $FF)
;===============================================================================
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F67F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F68F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F69F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F6AF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F6BF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F6CF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F6DF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F6EF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F6FF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F70F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F71F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F72F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F73F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F74F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F75F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F76F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F77F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F78F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F79F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F7AF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F7BF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F7CF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F7DF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $F7EF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF                                             ; $F7FF: FF

;===============================================================================
; $F800: NmiHandler
; Non-Maskable Interrupt handler. Saves registers, configures Namco-163
; sound/IRQ, sets nametable mirroring, restores PRG banks, performs OAM DMA,
; then dispatches to a game-state-specific VBlank handler via jump table.
;===============================================================================
.proc NmiHandler
  PHA                                         ; $F800: 48
  TXA                                         ; $F801: 8A
  PHA                                         ; $F802: 48
  TYA                                         ; $F803: 98
  PHA                                         ; $F804: 48
  LDA PPU_STATUS                               ; $F805: AD 02 20
  LDA #$00                                    ; $F808: A9 00
  STA $5800                                   ; $F80A: 8D 00 58
  LDA $0068                                   ; $F80D: AD 68 00
  STA $5000                                   ; $F810: 8D 00 50
  LDA $0069                                   ; $F813: AD 69 00
  STA $5800                                   ; $F816: 8D 00 58
  STA $0062                                   ; $F819: 8D 62 00
  LDA $0061                                   ; $F81C: AD 61 00
  STA $0060                                   ; $F81F: 8D 60 00
  CLI                                         ; $F822: 58
  LDA #$E0                                    ; $F823: A9 E0
  STA NAMCO_CHR_BANK_0                                   ; $F825: 8D 00 C0
  LDA #$E1                                    ; $F828: A9 E1
  STA NAMCO_CHR_BANK_1                                   ; $F82A: 8D 00 C8
  LDA #$E0                                    ; $F82D: A9 E0
  STA NAMCO_CHR_BANK_2                                   ; $F82F: 8D 00 D0
  LDA #$E1                                    ; $F832: A9 E1
  STA NAMCO_CHR_BANK_3                                   ; $F834: 8D 00 D8
  LDA $7B                                     ; $F837: A5 7B
  BEQ @set_prg_banks                          ; $F839: F0 03
  JMP NmiHandler_Busy                         ; $F83B: 4C D5 FA
@set_prg_banks:
  LDA $E1                                     ; $F83E: A5 E1
  STA NAMCO_PRG_8000                                   ; $F840: 8D 00 E0
  LDA $E2                                     ; $F843: A5 E2
  ORA #$C0                                    ; $F845: 09 C0
  STA NAMCO_PRG_A000                                   ; $F847: 8D 00 E8
  LDA $E3                                     ; $F84A: A5 E3
  STA NAMCO_PRG_C000                                   ; $F84C: 8D 00 F0
  LDY #$00                                    ; $F84F: A0 00
  STY PPU_OAM_ADDR                             ; $F851: 8C 03 20
  INY                                         ; $F854: C8
  STY $7B                                     ; $F855: 84 7B
  LDA #$02                                    ; $F857: A9 02
  STA APU_OAM_DMA                              ; $F859: 8D 14 40
  LDA $008C                                   ; $F85C: AD 8C 00
  STA PPU_MASK                                 ; $F85F: 8D 01 20
  LDA #$00                                    ; $F862: A9 00
  STA $7C                                     ; $F864: 85 7C
  LDA $78                                     ; $F866: A5 78
  AND #$0F                                    ; $F868: 29 0F
  ASL A                                       ; $F86A: 0A
  TAY                                         ; $F86B: A8
  LDA NmiDispatchTable,Y                      ; $F86C: B9 7B F8
  STA $0000                                   ; $F86F: 8D 00 00
  LDA NmiDispatchTable+1,Y                                 ; $F872: B9 7C F8
  STA $0001                                   ; $F875: 8D 01 00
  JMP ($0000)                                 ; $F878: 6C 00 00
.endproc

;===============================================================================
; $F87B: NmiDispatchTable - Jump table for NMI game state dispatch.
; 9 interleaved lo/hi address pairs. Index = ($78 & $0F) * 2.
;===============================================================================
NmiDispatchTable:
  .byte $97,$FA,$97,$FA,$B5,$F8,$FE,$F8,$6A,$F9         ; $F87B: 97 FA 97 FA B5 F8 FE F8 6A F9
  .byte $A0,$F9,$E4,$F9,$13,$FA,$53,$FA                 ; $F885: A0 F9 E4 F9 13 FA 53 FA

;===============================================================================
; $F88D: NmiEpilogue
; Restores PRG banks, increments tick counters, restores regs, RTI.
;===============================================================================
.proc NmiEpilogue
  DEC $007B                                   ; $F88D: CE 7B 00
  LDA $DE                                     ; $F890: A5 DE
  STA NAMCO_PRG_8000                                   ; $F892: 8D 00 E0
  LDA $DF                                     ; $F895: A5 DF
  ORA #$C0                                    ; $F897: 09 C0
  STA NAMCO_PRG_A000                                   ; $F899: 8D 00 E8
  LDA $E0                                     ; $F89C: A5 E0
  STA NAMCO_PRG_C000                                   ; $F89E: 8D 00 F0
  INC $50                                     ; $F8A1: E6 50
  INC $52                                     ; $F8A3: E6 52
  INC $54                                     ; $F8A5: E6 54
  INC $55                                     ; $F8A7: E6 55
  INC $5E                                     ; $F8A9: E6 5E
  BNE @restore_regs                           ; $F8AB: D0 02
  INC $5F                                     ; $F8AD: E6 5F
@restore_regs:
  PLA                                         ; $F8AF: 68
  TAY                                         ; $F8B0: A8
  PLA                                         ; $F8B1: 68
  TAX                                         ; $F8B2: AA
  PLA                                         ; $F8B3: 68
  RTI                                         ; $F8B4: 40
.endproc

;--- $F8B5: VBlank handler - map screen ---
.proc NmiState2_MapScreen
  JSR NmiSubDispatch                                   ; $F8B5: 20 53 EE
  JSR ChrBankSwitch                                   ; $F8B8: 20 06 F2
  JSR SetupChrBanksAndWait                    ; $F8BB: 20 0B FB
  JSR PaletteAnimation                                   ; $F8BE: 20 67 EC
  JSR ControllerRead                                   ; $F8C1: 20 C6 E6
  LDY #$2E                                    ; $F8C4: A0 2E
  JSR SwitchBankAC_B                                   ; $F8C6: 20 37 F2
  JSR $A003                                   ; $F8C9: 20 03 A0
  LDA #$4C                                    ; $F8CC: A9 4C
  STA $A5                                     ; $F8CE: 85 A5
  STA NAMCO_PRG_8000_ALT                           ; $F8D0: 8D 00 F8
  JSR CalcScrollAddrAlt                       ; $F8D3: 20 9B FF
  JSR SwapPlayerPointers                      ; $F8D6: 20 A9 FA
  LDY #$3D                                    ; $F8D9: A0 3D
  JSR SwitchBankAC_B                                   ; $F8DB: 20 37 F2
  JSR $A003                                   ; $F8DE: 20 03 A0
  JSR $A009                                   ; $F8E1: 20 09 A0
  JSR $A00F                                   ; $F8E4: 20 0F A0
  JSR $A03F                                   ; $F8E7: 20 3F A0
  LDY #$3B                                    ; $F8EA: A0 3B
  JSR SwitchBankAC_B                                   ; $F8EC: 20 37 F2
  JSR $A000                                   ; $F8EF: 20 00 A0
  JSR RestorePlayerPointers                   ; $F8F2: 20 BF FA
  JSR SpriteClearFromIndex                                   ; $F8F5: 20 30 E8
  JSR WaitVBlank                              ; $F8F8: 20 28 FB
  JMP NmiEpilogue                             ; $F8FB: 4C 8D F8
.endproc

;--- $F8FE: VBlank handler - battle ---
.proc NmiState3_Battle
  JSR NmiSubDispatch                                   ; $F8FE: 20 53 EE
  JSR ChrBankSwitch                                   ; $F901: 20 06 F2
  JSR SetupChrBanksAndWait                    ; $F904: 20 0B FB
  LDA #$00                                    ; $F907: A9 00
  STA $7C                                     ; $F909: 85 7C
  JSR PaletteAnimation                                   ; $F90B: 20 67 EC
  JSR ControllerRead                                   ; $F90E: 20 C6 E6
  LDY #$2E                                    ; $F911: A0 2E
  JSR SwitchBankAC_B                                   ; $F913: 20 37 F2
  JSR $A003                                   ; $F916: 20 03 A0
  LDA #$4C                                    ; $F919: A9 4C
  STA $A5                                     ; $F91B: 85 A5
  STA NAMCO_PRG_8000_ALT                           ; $F91D: 8D 00 F8
  JSR CalcScrollAddr                          ; $F920: 20 62 FF
  LDA $0500                                   ; $F923: AD 00 05
  CMP #$0C                                    ; $F926: C9 0C
  BCS @skip_weather                           ; $F928: B0 13
  LDA $008F                                   ; $F92A: AD 8F 00
  BNE @skip_weather                           ; $F92D: D0 0E
  JSR NamcoSoundRegRead                                   ; $F92F: 20 77 F0
  LDY #$37                                    ; $F932: A0 37
  JSR SwitchBankAC_B                                   ; $F934: 20 37 F2
  JSR $A00C                                   ; $F937: 20 0C A0
  JSR $A00F                                   ; $F93A: 20 0F A0
@skip_weather:
  JSR SwapPlayerPointers                      ; $F93D: 20 A9 FA
  LDY #$39                                    ; $F940: A0 39
  JSR SwitchBankAC_B                                   ; $F942: 20 37 F2
  JSR $A00F                                   ; $F945: 20 0F A0
  LDY #$2C                                    ; $F948: A0 2C
  JSR SwitchBankAC_B                                   ; $F94A: 20 37 F2
  JSR $A000                                   ; $F94D: 20 00 A0
  LDY #$3D                                    ; $F950: A0 3D
  JSR SwitchBankAC_B                                   ; $F952: 20 37 F2
  JSR $A003                                   ; $F955: 20 03 A0
  JSR RestorePlayerPointers                   ; $F958: 20 BF FA
  JSR SpriteClearFromIndex                                   ; $F95B: 20 30 E8
  LDA $009C                                   ; $F95E: AD 9C 00
  STA $009D                                   ; $F961: 8D 9D 00
  JSR WaitVBlank                              ; $F964: 20 28 FB
  JMP NmiEpilogue                             ; $F967: 4C 8D F8
.endproc

;--- $F96A: VBlank handler - menu ---
.proc NmiState4_Menu
  JSR NmiSubDispatch                                   ; $F96A: 20 53 EE
  JSR ChrBankSwitch                                   ; $F96D: 20 06 F2
  JSR SetupChrBanksAndWait                    ; $F970: 20 0B FB
  LDA #$00                                    ; $F973: A9 00
  STA $7C                                     ; $F975: 85 7C
  JSR PaletteAnimation                                   ; $F977: 20 67 EC
  JSR ControllerRead                                   ; $F97A: 20 C6 E6
  LDY #$2E                                    ; $F97D: A0 2E
  JSR SwitchBankAC_B                                   ; $F97F: 20 37 F2
  JSR $A003                                   ; $F982: 20 03 A0
  LDA #$4C                                    ; $F985: A9 4C
  STA $A5                                     ; $F987: 85 A5
  STA NAMCO_PRG_8000_ALT                           ; $F989: 8D 00 F8
  JSR CalcScrollAddr                          ; $F98C: 20 62 FF
  LDY #$2E                                    ; $F98F: A0 2E
  JSR SwitchBankAC_B                                   ; $F991: 20 37 F2
  JSR $A000                                   ; $F994: 20 00 A0
  JSR SpriteClearFromIndex                                   ; $F997: 20 30 E8
  JSR WaitVBlank                              ; $F99A: 20 28 FB
  JMP NmiEpilogue                             ; $F99D: 4C 8D F8
.endproc

;--- $F9A0: VBlank handler - diplomacy ---
.proc NmiState5_Diplomacy
  JSR NmiSubDispatch                                   ; $F9A0: 20 53 EE
  JSR ChrBankSwitch                                   ; $F9A3: 20 06 F2
  JSR SetupChrBanksAndWait                    ; $F9A6: 20 0B FB
  LDA #$00                                    ; $F9A9: A9 00
  STA $7C                                     ; $F9AB: 85 7C
  JSR PaletteAnimation                                   ; $F9AD: 20 67 EC
  JSR ControllerRead                                   ; $F9B0: 20 C6 E6
  LDY #$2E                                    ; $F9B3: A0 2E
  JSR SwitchBankAC_B                                   ; $F9B5: 20 37 F2
  JSR $A003                                   ; $F9B8: 20 03 A0
  LDA #$4C                                    ; $F9BB: A9 4C
  STA $A5                                     ; $F9BD: 85 A5
  STA NAMCO_PRG_8000_ALT                           ; $F9BF: 8D 00 F8
  JSR CalcScrollAddr                          ; $F9C2: 20 62 FF
  JSR SwapPlayerPointers                      ; $F9C5: 20 A9 FA
  LDY #$37                                    ; $F9C8: A0 37
  JSR SwitchBankAC_B                                   ; $F9CA: 20 37 F2
  JSR $A01B                                   ; $F9CD: 20 1B A0
  LDY #$3D                                    ; $F9D0: A0 3D
  JSR SwitchBankAC_B                                   ; $F9D2: 20 37 F2
  JSR $A003                                   ; $F9D5: 20 03 A0
  JSR RestorePlayerPointers                   ; $F9D8: 20 BF FA
  JSR SpriteClearFromIndex                                   ; $F9DB: 20 30 E8
  JSR WaitVBlank                              ; $F9DE: 20 28 FB
  JMP NmiEpilogue                             ; $F9E1: 4C 8D F8
.endproc

;--- $F9E4: VBlank handler - event ---
.proc NmiState6_Event
  JSR NmiSubDispatch                                   ; $F9E4: 20 53 EE
  JSR ChrBankSwitch                                   ; $F9E7: 20 06 F2
  JSR SetupChrBanksAndWait                    ; $F9EA: 20 0B FB
  JSR ControllerRead                                   ; $F9ED: 20 C6 E6
  LDY #$2E                                    ; $F9F0: A0 2E
  JSR SwitchBankAC_B                                   ; $F9F2: 20 37 F2
  JSR $A003                                   ; $F9F5: 20 03 A0
  LDA #$4C                                    ; $F9F8: A9 4C
  STA $A5                                     ; $F9FA: 85 A5
  STA NAMCO_PRG_8000_ALT                           ; $F9FC: 8D 00 F8
  LDY #$2A                                    ; $F9FF: A0 2A
  JSR SwitchBankAC_B                                   ; $FA01: 20 37 F2
  JSR $A003                                   ; $FA04: 20 03 A0
  JSR CalcScrollAddr                          ; $FA07: 20 62 FF
  JSR SpriteClearFromIndex                                   ; $FA0A: 20 30 E8
  JSR WaitVBlank                              ; $FA0D: 20 28 FB
  JMP NmiEpilogue                             ; $FA10: 4C 8D F8
.endproc

;--- $FA13: VBlank handler - strategy ---
.proc NmiState7_Strategy
  JSR NmiSubDispatch                                   ; $FA13: 20 53 EE
  JSR ChrBankSwitch                                   ; $FA16: 20 06 F2
  JSR SetupChrBanksAndWait                    ; $FA19: 20 0B FB
  JSR PaletteAnimation                                   ; $FA1C: 20 67 EC
  JSR ControllerRead                                   ; $FA1F: 20 C6 E6
  LDY #$2E                                    ; $FA22: A0 2E
  JSR SwitchBankAC_B                                   ; $FA24: 20 37 F2
  JSR $A003                                   ; $FA27: 20 03 A0
  JSR CalcScrollAddrAlt                       ; $FA2A: 20 9B FF
  LDA #$4C                                    ; $FA2D: A9 4C
  STA $A5                                     ; $FA2F: 85 A5
  STA NAMCO_PRG_8000_ALT                           ; $FA31: 8D 00 F8
  JSR SwapPlayerPointers                      ; $FA34: 20 A9 FA
  LDY #$3D                                    ; $FA37: A0 3D
  JSR SwitchBankAC_B                                   ; $FA39: 20 37 F2
  JSR $A003                                   ; $FA3C: 20 03 A0
  LDY #$28                                    ; $FA3F: A0 28
  JSR SwitchBankAC_B                                   ; $FA41: 20 37 F2
  JSR $A024                                   ; $FA44: 20 24 A0
  JSR RestorePlayerPointers                   ; $FA47: 20 BF FA
  JSR SpriteClearFromIndex                                   ; $FA4A: 20 30 E8
  JSR WaitVBlank                              ; $FA4D: 20 28 FB
  JMP NmiEpilogue                             ; $FA50: 4C 8D F8
.endproc

;--- $FA53: VBlank handler - officer mgmt ---
.proc NmiState8_Officer
  JSR NmiSubDispatch                                   ; $FA53: 20 53 EE
  JSR ChrBankSwitch                                   ; $FA56: 20 06 F2
  JSR SetupChrBanksAndWait                    ; $FA59: 20 0B FB
  JSR PaletteAnimation                                   ; $FA5C: 20 67 EC
  LDY #$2E                                    ; $FA5F: A0 2E
  JSR SwitchBankAC_B                                   ; $FA61: 20 37 F2
  JSR $A003                                   ; $FA64: 20 03 A0
  LDA #$00                                    ; $FA67: A9 00
  STA $81                                     ; $FA69: 85 81
  LDY #$3D                                    ; $FA6B: A0 3D
  JSR SwitchBankAC_B                                   ; $FA6D: 20 37 F2
  JSR $A003                                   ; $FA70: 20 03 A0
  LDA #$4C                                    ; $FA73: A9 4C
  STA $A5                                     ; $FA75: 85 A5
  STA NAMCO_PRG_8000_ALT                           ; $FA77: 8D 00 F8
  JSR ControllerRead                                   ; $FA7A: 20 C6 E6
  JSR SwapPlayerPointers                      ; $FA7D: 20 A9 FA
  LDY #$37                                    ; $FA80: A0 37
  JSR SwitchBankAC_B                                   ; $FA82: 20 37 F2
  JSR $A01E                                   ; $FA85: 20 1E A0
  JSR RestorePlayerPointers                   ; $FA88: 20 BF FA
  JSR CalcScrollAddr                          ; $FA8B: 20 62 FF
  JSR SpriteClearFromIndex                                   ; $FA8E: 20 30 E8
  JSR WaitVBlank                              ; $FA91: 20 28 FB
  JMP NmiEpilogue                             ; $FA94: 4C 8D F8
.endproc

;--- $FA97: VBlank handler - idle (states 0,1) ---
.proc NmiState0_Idle
  JSR SetupChrBanksAndWait                    ; $FA97: 20 0B FB
  JSR ChrBankSwitch                                   ; $FA9A: 20 06 F2
  JSR ControllerRead                                   ; $FA9D: 20 C6 E6
  JSR CalcScrollAddr                          ; $FAA0: 20 62 FF
  JSR WaitVBlank                              ; $FAA3: 20 28 FB
  JMP NmiEpilogue                             ; $FAA6: 4C 8D F8
.endproc

;--- $FAA9: Swap player pointers if 2P ---
.proc SwapPlayerPointers
  LDA $6F44                                   ; $FAA9: AD 44 6F
  BEQ @rts_swap                               ; $FAAC: F0 10
  LDY $81                                     ; $FAAE: A4 81
  LDA $82                                     ; $FAB0: A5 82
  STA $81                                     ; $FAB2: 85 81
  STY $82                                     ; $FAB4: 84 82
  LDY $83                                     ; $FAB6: A4 83
  LDA $85                                     ; $FAB8: A5 85
  STA $83                                     ; $FABA: 85 83
  STY $85                                     ; $FABC: 84 85
@rts_swap:
  RTS                                         ; $FABE: 60
.endproc

;--- $FABF: Restore player pointers ---
.proc RestorePlayerPointers
  LDA $6F44                                   ; $FABF: AD 44 6F
  BEQ @rts_restore                            ; $FAC2: F0 10
  LDY $82                                     ; $FAC4: A4 82
  LDA $81                                     ; $FAC6: A5 81
  STA $82                                     ; $FAC8: 85 82
  STY $81                                     ; $FACA: 84 81
  LDY $85                                     ; $FACC: A4 85
  LDA $83                                     ; $FACE: A5 83
  STA $85                                     ; $FAD0: 85 85
  STY $83                                     ; $FAD2: 84 83
@rts_restore:
  RTS                                         ; $FAD4: 60
.endproc

;--- $FAD5: NMI when busy ($7B != 0) ---
.proc NmiHandler_Busy
  JSR ChrBankSwitch                                   ; $FAD5: 20 06 F2
  JSR SetupChrBanksAndWait                    ; $FAD8: 20 0B FB
  LDA $E3                                     ; $FADB: A5 E3
  PHA                                         ; $FADD: 48
  LDA $E2                                     ; $FADE: A5 E2
  PHA                                         ; $FAE0: 48
  LDA $E1                                     ; $FAE1: A5 E1
  PHA                                         ; $FAE3: 48
  LDY #$2E                                    ; $FAE4: A0 2E
  JSR SwitchBankAC_B                                   ; $FAE6: 20 37 F2
  JSR $A003                                   ; $FAE9: 20 03 A0
  LDA $A5                                     ; $FAEC: A5 A5
  STA NAMCO_PRG_8000_ALT                           ; $FAEE: 8D 00 F8
  PLA                                         ; $FAF1: 68
  STA $E1                                     ; $FAF2: 85 E1
  STA NAMCO_PRG_8000                                   ; $FAF4: 8D 00 E0
  PLA                                         ; $FAF7: 68
  STA $E2                                     ; $FAF8: 85 E2
  ORA #$C0                                    ; $FAFA: 09 C0
  STA NAMCO_PRG_A000                                   ; $FAFC: 8D 00 E8
  PLA                                         ; $FAFF: 68
  STA $E3                                     ; $FB00: 85 E3
  STA NAMCO_PRG_C000                                   ; $FB02: 8D 00 F0
  JSR WaitVBlank                              ; $FB05: 20 28 FB
  JMP @restore_regs                           ; $FB08: 4C AF F8
.endproc

;--- $FB0B: Setup CHR banks and wait for sprite-0 ---
.proc SetupChrBanksAndWait
  JSR ScrollSet                                   ; $FB0B: 20 F7 EA
  LDA $E6                                     ; $FB0E: A5 E6
  STA NAMCO_CHR_BANK_0                                   ; $FB10: 8D 00 C0
  LDA $E7                                     ; $FB13: A5 E7
  STA NAMCO_CHR_BANK_1                                   ; $FB15: 8D 00 C8
  LDA $E8                                     ; $FB18: A5 E8
  STA NAMCO_CHR_BANK_2                                   ; $FB1A: 8D 00 D0
  LDA $E9                                     ; $FB1D: A5 E9
  STA NAMCO_CHR_BANK_3                                   ; $FB1F: 8D 00 D8
@wait_vbl_flag:
  BIT PPU_STATUS                               ; $FB22: 2C 02 20
  BVS @wait_vbl_flag                          ; $FB25: 70 FB
  RTS                                         ; $FB27: 60
.endproc

;--- $FB28: Wait for VBlank completion (poll $62) ---
.proc WaitVBlank
  LDA $62                                     ; $FB28: A5 62
  BNE WaitVBlank                              ; $FB2A: D0 FC
  RTS                                         ; $FB2C: 60
.endproc

;===============================================================================
; $FB2D: IrqHandler
; Scanline IRQ (Namco-163). Dispatches to 12 modes based on $0060.
;===============================================================================
.proc IrqHandler
  PHA                                         ; $FB2D: 48
  TXA                                         ; $FB2E: 8A
  PHA                                         ; $FB2F: 48
  TYA                                         ; $FB30: 98
  PHA                                         ; $FB31: 48
  LDA $5800                                   ; $FB32: AD 00 58
  AND #$7F                                    ; $FB35: 29 7F
  CMP #$7F                                    ; $FB37: C9 7F
  BEQ @irq_dispatch                           ; $FB39: F0 04
  NOP                                         ; $FB3B: EA
@irq_hang:
  JMP @irq_hang                               ; $FB3C: 4C 3C FB
@irq_dispatch:
  LDY $0060                                   ; $FB3F: AC 60 00
  BEQ @irq_exit_sei                           ; $FB42: F0 4E
  DEY                                         ; $FB44: 88
  BNE @check_mode2                            ; $FB45: D0 09
  NOP                                         ; $FB47: EA
  NOP                                         ; $FB48: EA
  NOP                                         ; $FB49: EA
  NOP                                         ; $FB4A: EA
  NOP                                         ; $FB4B: EA
  NOP                                         ; $FB4C: EA
  JMP IrqMode1_SoundAndChr                    ; $FB4D: 4C A4 FB
@check_mode2:
  DEY                                         ; $FB50: 88
  BNE @check_mode3                            ; $FB51: D0 03
  JMP IrqMode2_FullSetup                      ; $FB53: 4C 8B FC
@check_mode3:
  DEY                                         ; $FB56: 88
  BNE @check_mode4                            ; $FB57: D0 03
  JMP IrqMode1_SoundAndChr                    ; $FB59: 4C A4 FB
@check_mode4:
  DEY                                         ; $FB5C: 88
  BNE @check_mode5                            ; $FB5D: D0 03
  JMP IrqMode4_SimpleChr                      ; $FB5F: 4C 2A FD
@check_mode5:
  DEY                                         ; $FB62: 88
  BNE @check_mode6                            ; $FB63: D0 03
  JMP IrqMode5_PpuAddrChr                     ; $FB65: 4C 95 FD
@check_mode6:
  DEY                                         ; $FB68: 88
  BNE @check_mode7                            ; $FB69: D0 03
  JMP IrqMode6_Minimal                        ; $FB6B: 4C F4 FD
@check_mode7:
  DEY                                         ; $FB6E: 88
  BNE @check_mode8                            ; $FB6F: D0 03
  JMP IrqMode7_SoundChr                       ; $FB71: 4C 03 FE
@check_mode8:
  DEY                                         ; $FB74: 88
  BNE @check_mode9                            ; $FB75: D0 03
  JMP IrqMode8_SoundChr                       ; $FB77: 4C 69 FE
@check_mode9:
  DEY                                         ; $FB7A: 88
  BNE @check_mode10                           ; $FB7B: D0 03
  JMP IrqMode9_BasicChr                       ; $FB7D: 4C 96 FE
@check_mode10:
  DEY                                         ; $FB80: 88
  BNE @check_mode11                           ; $FB81: D0 03
  JMP IrqMode10_PpuScroll                     ; $FB83: 4C CD FE
@check_mode11:
  DEY                                         ; $FB86: 88
  BNE @check_mode12                           ; $FB87: D0 03
  JMP IrqMode11_ScrollFwd                     ; $FB89: 4C 31 FF
@check_mode12:
  DEY                                         ; $FB8C: 88
  BNE @irq_exit_sei                           ; $FB8D: D0 03
  JMP IrqMode12_ScrollBack                    ; $FB8F: 4C 48 FF
@irq_exit_sei:
  SEI                                         ; $FB92: 78
  LDA #$00                                    ; $FB93: A9 00
  STA $0062                                   ; $FB95: 8D 62 00
  STA $5000                                   ; $FB98: 8D 00 50
  STA $5800                                   ; $FB9B: 8D 00 58
.endproc

;--- $FB9E: IrqExit - restore regs and RTI ---
IrqExit:
  PLA                                         ; $FB9E: 68
  TAY                                         ; $FB9F: A8
  PLA                                         ; $FBA0: 68
  TAX                                         ; $FBA1: AA
  PLA                                         ; $FBA2: 68
  RTI                                         ; $FBA3: 40

;--- $FBA4: IRQ modes 1,3 - sound regs + CHR dispatch ---
.proc IrqMode1_SoundAndChr
  LDA $0063                                   ; $FBA4: AD 63 00
  ASL A                                       ; $FBA7: 0A
  TAX                                         ; $FBA8: AA
  LDA #$00                                    ; $FBA9: A9 00
  STA $5000                                   ; $FBAB: 8D 00 50
  LDA $006A,X                                 ; $FBAE: BD 6A 00
  STA $5000                                   ; $FBB1: 8D 00 50
  LDA $006B,X                                 ; $FBB4: BD 6B 00
  STA $5800                                   ; $FBB7: 8D 00 58
@check_sub2:
  LDY $0063                                   ; $FBBA: AC 63 00
  BEQ IrqChrUpdate_Block1                     ; $FBBD: F0 0F
  DEY                                         ; $FBBF: 88
  BNE @check_sub3                             ; $FBC0: D0 03
  JMP IrqChrUpdate_Block2                     ; $FBC2: 4C FC FB
@check_sub3:
  DEY                                         ; $FBC5: 88
  BNE @dispatch_block4                        ; $FBC6: D0 03
  JMP IrqChrUpdate_Block3                     ; $FBC8: 4C 2A FC
@dispatch_block4:
  JMP IrqChrUpdate_Block4                     ; $FBCB: 4C 58 FC
.endproc

;--- $FBCE: CHR update block 1 ---
.proc IrqChrUpdate_Block1
  LDA $C2                                     ; $FBCE: A5 C2
  LDY $C3                                     ; $FBD0: A4 C3
  LDX $C4                                     ; $FBD2: A6 C4
  STA $A000                                   ; $FBD4: 8D 00 A0
  STY $A800                                   ; $FBD7: 8C 00 A8
  STX $B000                                   ; $FBDA: 8E 00 B0
  LDA $C5                                     ; $FBDD: A5 C5
  STA $B800                                   ; $FBDF: 8D 00 B8
  LDA $BE                                     ; $FBE2: A5 BE
  LDY $BF                                     ; $FBE4: A4 BF
  LDX $C0                                     ; $FBE6: A6 C0
  STA $8000                                   ; $FBE8: 8D 00 80
  STY $8800                                   ; $FBEB: 8C 00 88
  STX $9000                                   ; $FBEE: 8E 00 90
  LDA $C1                                     ; $FBF1: A5 C1
  STA $9800                                   ; $FBF3: 8D 00 98
  INC $0063                                   ; $FBF6: EE 63 00
  JMP IrqExit                                 ; $FBF9: 4C 9E FB
.endproc

;--- $FBFC: CHR update block 2 ---
.proc IrqChrUpdate_Block2
  LDA $CA                                     ; $FBFC: A5 CA
  LDY $CB                                     ; $FBFE: A4 CB
  LDX $CC                                     ; $FC00: A6 CC
  STA $A000                                   ; $FC02: 8D 00 A0
  STY $A800                                   ; $FC05: 8C 00 A8
  STX $B000                                   ; $FC08: 8E 00 B0
  LDA $CD                                     ; $FC0B: A5 CD
  STA $B800                                   ; $FC0D: 8D 00 B8
  LDY $C6                                     ; $FC10: A4 C6
  LDX $C7                                     ; $FC12: A6 C7
  LDA $C8                                     ; $FC14: A5 C8
  STY $8000                                   ; $FC16: 8C 00 80
  STX $8800                                   ; $FC19: 8E 00 88
  STA $9000                                   ; $FC1C: 8D 00 90
  LDY $C9                                     ; $FC1F: A4 C9
  STY $9800                                   ; $FC21: 8C 00 98
  INC $0063                                   ; $FC24: EE 63 00
  JMP IrqExit                                 ; $FC27: 4C 9E FB
.endproc

;--- $FC2A: CHR update block 3 ---
.proc IrqChrUpdate_Block3
  LDA $D2                                     ; $FC2A: A5 D2
  LDY $D3                                     ; $FC2C: A4 D3
  LDX $D4                                     ; $FC2E: A6 D4
  STA $A000                                   ; $FC30: 8D 00 A0
  STY $A800                                   ; $FC33: 8C 00 A8
  STX $B000                                   ; $FC36: 8E 00 B0
  LDA $D5                                     ; $FC39: A5 D5
  STA $B800                                   ; $FC3B: 8D 00 B8
  LDY $CE                                     ; $FC3E: A4 CE
  LDX $CF                                     ; $FC40: A6 CF
  STY $8000                                   ; $FC42: 8C 00 80
  STX $8800                                   ; $FC45: 8E 00 88
  LDA $D0                                     ; $FC48: A5 D0
  LDY $D1                                     ; $FC4A: A4 D1
  STA $9000                                   ; $FC4C: 8D 00 90
  STY $9800                                   ; $FC4F: 8C 00 98
  INC $0063                                   ; $FC52: EE 63 00
  JMP IrqExit                                 ; $FC55: 4C 9E FB
.endproc

;--- $FC58: CHR update block 4 (resets counter) ---
.proc IrqChrUpdate_Block4
  LDA $DA                                     ; $FC58: A5 DA
  LDY $DB                                     ; $FC5A: A4 DB
  LDX $DC                                     ; $FC5C: A6 DC
  STA $A000                                   ; $FC5E: 8D 00 A0
  STY $A800                                   ; $FC61: 8C 00 A8
  STX $B000                                   ; $FC64: 8E 00 B0
  LDA $DD                                     ; $FC67: A5 DD
  STA $B800                                   ; $FC69: 8D 00 B8
  LDY $D6                                     ; $FC6C: A4 D6
  LDX $D7                                     ; $FC6E: A6 D7
  STY $8000                                   ; $FC70: 8C 00 80
  STX $8800                                   ; $FC73: 8E 00 88
  LDA $D8                                     ; $FC76: A5 D8
  LDY $D9                                     ; $FC78: A4 D9
  STA $9000                                   ; $FC7A: 8D 00 90
  STY $9800                                   ; $FC7D: 8C 00 98
  LDA #$00                                    ; $FC80: A9 00
  STA $0063                                   ; $FC82: 8D 63 00
  INC $0060                                   ; $FC85: EE 60 00
  JMP IrqExit                                 ; $FC88: 4C 9E FB
.endproc

;--- $FC8B: IRQ mode 2 - full CHR/PPU with delays ---
.proc IrqMode2_FullSetup
  SEI                                         ; $FC8B: 78
  LDA #$00                                    ; $FC8C: A9 00
  STA $0062                                   ; $FC8E: 8D 62 00
  STA $5000                                   ; $FC91: 8D 00 50
  STA $5800                                   ; $FC94: 8D 00 58
  LDY #$08                                    ; $FC97: A0 08
@delay_spin1:
  DEY                                         ; $FC99: 88
  BPL @delay_spin1                            ; $FC9A: 10 FD
  LDA $0099                                   ; $FC9C: AD 99 00
  AND #$07                                    ; $FC9F: 29 07
  ASL A                                       ; $FCA1: 0A
  TAY                                         ; $FCA2: A8
  LDA ScanlineDelayTable,Y                    ; $FCA3: B9 1A FD
  STA $0046                                   ; $FCA6: 8D 46 00
  LDA ScanlineDelayTable+1,Y                                 ; $FCA9: B9 1B FD
  STA $0047                                   ; $FCAC: 8D 47 00
  LDA #$0F                                    ; $FCAF: A9 0F
  STA $8000                                   ; $FCB1: 8D 00 80
  STA $8800                                   ; $FCB4: 8D 00 88
  STA $9000                                   ; $FCB7: 8D 00 90
  STA $9800                                   ; $FCBA: 8D 00 98
  STA $A000                                   ; $FCBD: 8D 00 A0
  STA $A800                                   ; $FCC0: 8D 00 A8
  STA $B000                                   ; $FCC3: 8D 00 B0
  STA $B800                                   ; $FCC6: 8D 00 B8
@delay_loop1:
  DEC $0046                                   ; $FCC9: CE 46 00
  BNE @delay_loop1                            ; $FCCC: D0 FB
  LDA $EA                                     ; $FCCE: A5 EA
  LDY $9B                                     ; $FCD0: A4 9B
  LDX $9A                                     ; $FCD2: A6 9A
  STA $C700                                   ; $FCD4: 8D 00 C7
  STY PPU_ADDR                                 ; $FCD7: 8C 06 20
  STX PPU_ADDR                                 ; $FCDA: 8E 06 20
  LDX $96                                     ; $FCDD: A6 96
  STX PPU_SCROLL                               ; $FCDF: 8E 05 20
  STX PPU_SCROLL                               ; $FCE2: 8E 05 20
@delay_loop2:
  DEC $0047                                   ; $FCE5: CE 47 00
  BNE @delay_loop2                            ; $FCE8: D0 FB
  LDA $BA                                     ; $FCEA: A5 BA
  LDY $BB                                     ; $FCEC: A4 BB
  LDX $BC                                     ; $FCEE: A6 BC
  STA $A000                                   ; $FCF0: 8D 00 A0
  STY $A800                                   ; $FCF3: 8C 00 A8
  STX $B000                                   ; $FCF6: 8E 00 B0
  LDA $BD                                     ; $FCF9: A5 BD
  STA $B800                                   ; $FCFB: 8D 00 B8
  LDY #$1B                                    ; $FCFE: A0 1B
@delay_loop3:
  DEY                                         ; $FD00: 88
  BNE @delay_loop3                            ; $FD01: D0 FD
  LDA $B6                                     ; $FD03: A5 B6
  LDY $B7                                     ; $FD05: A4 B7
  LDX $B8                                     ; $FD07: A6 B8
  STA $8000                                   ; $FD09: 8D 00 80
  STY $8800                                   ; $FD0C: 8C 00 88
  STX $9000                                   ; $FD0F: 8E 00 90
  LDA $B9                                     ; $FD12: A5 B9
  STA $9800                                   ; $FD14: 8D 00 98
  JMP IrqExit                                 ; $FD17: 4C 9E FB
.endproc

;--- $FD1A: Scanline delay table (8 pairs) ---
ScanlineDelayTable:
  .byte $68,$0B,$5C,$18,$50,$23,$44,$2E                 ; $FD1A: 68 0B 5C 18 50 23 44 2E
  .byte $37,$39,$2A,$45,$1E,$50,$12,$5B                 ; $FD22: 37 39 2A 45 1E 50 12 5B

;--- $FD2A: IRQ mode 4 - simple CHR with ZP delays ---
.proc IrqMode4_SimpleChr
  SEI                                         ; $FD2A: 78
  LDA #$00                                    ; $FD2B: A9 00
  STA $0062                                   ; $FD2D: 8D 62 00
  STA $5000                                   ; $FD30: 8D 00 50
  STA $5800                                   ; $FD33: 8D 00 58
  LDY #$0F                                    ; $FD36: A0 0F
  STY $A000                                   ; $FD38: 8C 00 A0
  STY $A800                                   ; $FD3B: 8C 00 A8
  STY $B000                                   ; $FD3E: 8C 00 B0
  STY $B800                                   ; $FD41: 8C 00 B8
  LDY $72                                     ; $FD44: A4 72
@delay1:
  DEY                                         ; $FD46: 88
  BPL @delay1                                 ; $FD47: 10 FD
  LDA $EA                                     ; $FD49: A5 EA
  LDX $9B                                     ; $FD4B: A6 9B
  LDY $9A                                     ; $FD4D: A4 9A
  STX PPU_ADDR                                   ; $FD4F: 8E 06 20
  STY PPU_ADDR                                   ; $FD52: 8C 06 20
  LDX $96                                     ; $FD55: A6 96
  STX PPU_SCROLL                                   ; $FD57: 8E 05 20
  STX PPU_SCROLL                                   ; $FD5A: 8E 05 20
  STA $C700                                   ; $FD5D: 8D 00 C7
  LDY $73                                     ; $FD60: A4 73
@delay2:
  DEY                                         ; $FD62: 88
  BPL @delay2                                 ; $FD63: 10 FD
  LDA $BA                                     ; $FD65: A5 BA
  LDY $BB                                     ; $FD67: A4 BB
  LDX $BC                                     ; $FD69: A6 BC
  STA $A000                                   ; $FD6B: 8D 00 A0
  STY $A800                                   ; $FD6E: 8C 00 A8
  STX $B000                                   ; $FD71: 8E 00 B0
  LDA $BD                                     ; $FD74: A5 BD
  STA $B800                                   ; $FD76: 8D 00 B8
  LDY $74                                     ; $FD79: A4 74
@delay3:
  DEY                                         ; $FD7B: 88
  BPL @delay3                                 ; $FD7C: 10 FD
  LDA $B6                                     ; $FD7E: A5 B6
  LDY $B7                                     ; $FD80: A4 B7
  LDX $B8                                     ; $FD82: A6 B8
  STA $8000                                   ; $FD84: 8D 00 80
  STY $8800                                   ; $FD87: 8C 00 88
  STX $9000                                   ; $FD8A: 8E 00 90
  LDA $B9                                     ; $FD8D: A5 B9
  STA $9800                                   ; $FD8F: 8D 00 98
  JMP IrqExit                                 ; $FD92: 4C 9E FB
.endproc

;--- $FD95: IRQ mode 5 - PPU addr + CHR + nametable ---
.proc IrqMode5_PpuAddrChr
  SEI                                         ; $FD95: 78
  LDA #$00                                    ; $FD96: A9 00
  STA $0062                                   ; $FD98: 8D 62 00
  STA $5000                                   ; $FD9B: 8D 00 50
  STA $5800                                   ; $FD9E: 8D 00 58
  LDA PPU_STATUS                                   ; $FDA1: AD 02 20
  LDA #$E1                                    ; $FDA4: A9 E1
  LDX $9B                                     ; $FDA6: A6 9B
  LDY $9A                                     ; $FDA8: A4 9A
  STA $C700                                   ; $FDAA: 8D 00 C7
  STA NAMCO_CHR_BANK_2                                   ; $FDAD: 8D 00 D0
  STA NAMCO_CHR_BANK_1                                   ; $FDB0: 8D 00 C8
  STA NAMCO_CHR_BANK_3                                   ; $FDB3: 8D 00 D8
  STX PPU_ADDR                                   ; $FDB6: 8E 06 20
  STY PPU_ADDR                                   ; $FDB9: 8C 06 20
  LDY $BB                                     ; $FDBC: A4 BB
  LDX $BC                                     ; $FDBE: A6 BC
  LDA $BA                                     ; $FDC0: A5 BA
  STA $A000                                   ; $FDC2: 8D 00 A0
  STY $A800                                   ; $FDC5: 8C 00 A8
  STX $B000                                   ; $FDC8: 8E 00 B0
  LDA $BD                                     ; $FDCB: A5 BD
  STA $B800                                   ; $FDCD: 8D 00 B8
  LDX $96                                     ; $FDD0: A6 96
  STX PPU_SCROLL                                   ; $FDD2: 8E 05 20
  STX PPU_SCROLL                                   ; $FDD5: 8E 05 20
  LDY #$30                                    ; $FDD8: A0 30
@delay_loop3:
  DEY                                         ; $FDDA: 88
  BPL @delay_loop3                            ; $FDDB: 10 FD
  LDA $B6                                     ; $FDDD: A5 B6
  LDY $B7                                     ; $FDDF: A4 B7
  LDX $B8                                     ; $FDE1: A6 B8
  STA $8000                                   ; $FDE3: 8D 00 80
  STY $8800                                   ; $FDE6: 8C 00 88
  STX $9000                                   ; $FDE9: 8E 00 90
  LDA $B9                                     ; $FDEC: A5 B9
  STA $9800                                   ; $FDEE: 8D 00 98
  JMP IrqExit                                 ; $FDF1: 4C 9E FB
.endproc

;--- $FDF4: IRQ mode 6 - minimal (disable + exit) ---
.proc IrqMode6_Minimal
  SEI                                         ; $FDF4: 78
  LDA #$00                                    ; $FDF5: A9 00
  STA $0062                                   ; $FDF7: 8D 62 00
  STA $5000                                   ; $FDFA: 8D 00 50
  STA $5800                                   ; $FDFD: 8D 00 58
  JMP IrqExit                                 ; $FE00: 4C 9E FB
.endproc

;--- $FE03: IRQ mode 7 - sound + CHR sub-dispatch ---
.proc IrqMode7_SoundChr
  LDA $0063                                   ; $FE03: AD 63 00
  ASL A                                       ; $FE06: 0A
  TAX                                         ; $FE07: AA
  LDA #$00                                    ; $FE08: A9 00
  STA $5000                                   ; $FE0A: 8D 00 50
  LDA $006A,X                                 ; $FE0D: BD 6A 00
  STA $5000                                   ; $FE10: 8D 00 50
  LDA $006B,X                                 ; $FE13: BD 6B 00
  STA $5800                                   ; $FE16: 8D 00 58
  LDY $0063                                   ; $FE19: AC 63 00
  BEQ @block1_update                          ; $FE1C: F0 09
  DEY                                         ; $FE1E: 88
@mode7_dispatch:
  BEQ @jmp_block3                             ; $FE1F: F0 3A
  DEY                                         ; $FE21: 88
  BEQ @jmp_block4                             ; $FE22: F0 3A
  JMP IrqMode7_Exit                           ; $FE24: 4C 61 FE
@block1_update:
  LDA PPU_STATUS                                   ; $FE27: AD 02 20
  LDA #$E1                                    ; $FE2A: A9 E1
  LDX #$25                                    ; $FE2C: A2 25
  LDY #$B8                                    ; $FE2E: A0 B8
  STA $C700                                   ; $FE30: 8D 00 C7
  STA NAMCO_CHR_BANK_2                                   ; $FE33: 8D 00 D0
  STA NAMCO_CHR_BANK_1                                   ; $FE36: 8D 00 C8
  STA NAMCO_CHR_BANK_3                                   ; $FE39: 8D 00 D8
  STX PPU_ADDR                                   ; $FE3C: 8E 06 20
  STY PPU_ADDR                                   ; $FE3F: 8C 06 20
  LDA #$0F                                    ; $FE42: A9 0F
  STA $A000                                   ; $FE44: 8D 00 A0
  STA $A800                                   ; $FE47: 8D 00 A8
  STA $B000                                   ; $FE4A: 8D 00 B0
  STA $B800                                   ; $FE4D: 8D 00 B8
  LDX #$00                                    ; $FE50: A2 00
  STX PPU_SCROLL                                   ; $FE52: 8E 05 20
  STX PPU_SCROLL                                   ; $FE55: 8E 05 20
  JMP IrqChrUpdate_Block1                     ; $FE58: 4C CE FB
@jmp_block3:
  JMP IrqChrUpdate_Block2                     ; $FE5B: 4C FC FB
@jmp_block4:
  JMP IrqChrUpdate_Block3                     ; $FE5E: 4C 2A FC
  LDA #$00                                    ; $FE61: A9 00
  STA $0063                                   ; $FE63: 8D 63 00
  JMP IrqMode5_PpuAddrChr                     ; $FE66: 4C 95 FD
.endproc

;--- $FE69: IRQ mode 8 - sound + CHR variant ---
.proc IrqMode8_SoundChr
  LDA $0063                                   ; $FE69: AD 63 00
  ASL A                                       ; $FE6C: 0A
  TAX                                         ; $FE6D: AA
  LDA #$00                                    ; $FE6E: A9 00
  STA $5000                                   ; $FE70: 8D 00 50
  LDA $006A,X                                 ; $FE73: BD 6A 00
  STA $5000                                   ; $FE76: 8D 00 50
  LDA $006B,X                                 ; $FE79: BD 6B 00
  STA $5800                                   ; $FE7C: 8D 00 58
  LDY $0063                                   ; $FE7F: AC 63 00
  BNE @mode8_check1                           ; $FE82: D0 03
  JMP IrqChrUpdate_Block1                     ; $FE84: 4C CE FB
@mode8_check1:
  DEY                                         ; $FE87: 88
  BNE @mode8_check2                           ; $FE88: D0 03
  JMP IrqChrUpdate_Block2                     ; $FE8A: 4C FC FB
@mode8_check2:
  DEY                                         ; $FE8D: 88
  BNE @mode8_jmp4                             ; $FE8E: D0 03
  JMP IrqChrUpdate_Block3                     ; $FE90: 4C 2A FC
@mode8_jmp4:
  JMP IrqChrUpdate_Block4                     ; $FE93: 4C 58 FC
.endproc

;--- $FE96: IRQ mode 9 - basic CHR ---
.proc IrqMode9_BasicChr
  SEI                                         ; $FE96: 78
  LDA #$00                                    ; $FE97: A9 00
  STA $0062                                   ; $FE99: 8D 62 00
  STA $5000                                   ; $FE9C: 8D 00 50
  STA $5800                                   ; $FE9F: 8D 00 58
  LDA $BA                                     ; $FEA2: A5 BA
  LDY $BB                                     ; $FEA4: A4 BB
  LDX $BC                                     ; $FEA6: A6 BC
  STA $A000                                   ; $FEA8: 8D 00 A0
  STY $A800                                   ; $FEAB: 8C 00 A8
  STX $B000                                   ; $FEAE: 8E 00 B0
  LDA $BD                                     ; $FEB1: A5 BD
  STA $B800                                   ; $FEB3: 8D 00 B8
  LDA $B6                                     ; $FEB6: A5 B6
  LDY $B7                                     ; $FEB8: A4 B7
  LDX $B8                                     ; $FEBA: A6 B8
  STA $8000                                   ; $FEBC: 8D 00 80
  STY $8800                                   ; $FEBF: 8C 00 88
  STX $9000                                   ; $FEC2: 8E 00 90
  LDA $B9                                     ; $FEC5: A5 B9
  STA $9800                                   ; $FEC7: 8D 00 98
  JMP IrqExit                                 ; $FECA: 4C 9E FB
.endproc

;--- $FECD: IRQ mode 10 - PPU scroll + CHR ---
.proc IrqMode10_PpuScroll
  SEI                                         ; $FECD: 78
  LDA #$00                                    ; $FECE: A9 00
  STA $0062                                   ; $FED0: 8D 62 00
  STA $5000                                   ; $FED3: 8D 00 50
  STA $5800                                   ; $FED6: 8D 00 58
  LDA PPU_STATUS                                   ; $FED9: AD 02 20
  LDA $EA                                     ; $FEDC: A5 EA
  STA NAMCO_CHR_BANK_0                                   ; $FEDE: 8D 00 C0
  LDA #$0F                                    ; $FEE1: A9 0F
  LDY $9B                                     ; $FEE3: A4 9B
  LDX $9A                                     ; $FEE5: A6 9A
  STA $A000                                   ; $FEE7: 8D 00 A0
  STA $A800                                   ; $FEEA: 8D 00 A8
  STA $B000                                   ; $FEED: 8D 00 B0
  STA $B800                                   ; $FEF0: 8D 00 B8
  STY PPU_ADDR                                   ; $FEF3: 8C 06 20
  STX PPU_ADDR                                   ; $FEF6: 8E 06 20
  LDA #$00                                    ; $FEF9: A9 00
  STA PPU_SCROLL                                   ; $FEFB: 8D 05 20
  STA PPU_SCROLL                                   ; $FEFE: 8D 05 20
  LDY #$10                                    ; $FF01: A0 10
@delay_m10:
  DEY                                         ; $FF03: 88
  BPL @delay_m10                              ; $FF04: 10 FD
  LDA $BA                                     ; $FF06: A5 BA
  LDY $BB                                     ; $FF08: A4 BB
  LDX $BC                                     ; $FF0A: A6 BC
  STA $A000                                   ; $FF0C: 8D 00 A0
  STY $A800                                   ; $FF0F: 8C 00 A8
  STX $B000                                   ; $FF12: 8E 00 B0
  LDA $BD                                     ; $FF15: A5 BD
  STA $B800                                   ; $FF17: 8D 00 B8
  LDA $B6                                     ; $FF1A: A5 B6
  LDY $B7                                     ; $FF1C: A4 B7
  LDX $B8                                     ; $FF1E: A6 B8
  STA $8000                                   ; $FF20: 8D 00 80
  STY $8800                                   ; $FF23: 8C 00 88
  STX $9000                                   ; $FF26: 8E 00 90
  LDA $B9                                     ; $FF29: A5 B9
  STA $9800                                   ; $FF2B: 8D 00 98
  JMP IrqExit                                 ; $FF2E: 4C 9E FB
.endproc

;--- $FF31: IRQ mode 11 - scroll forward ---
.proc IrqMode11_ScrollFwd
  LDA #$00                                    ; $FF31: A9 00
  STA $5000                                   ; $FF33: 8D 00 50
  LDA $006A                                   ; $FF36: AD 6A 00
  STA $5000                                   ; $FF39: 8D 00 50
  LDA $006B                                   ; $FF3C: AD 6B 00
  STA $5800                                   ; $FF3F: 8D 00 58
  INC $0060                                   ; $FF42: EE 60 00
  JMP IrqChrUpdate_Block1                     ; $FF45: 4C CE FB
.endproc

;--- $FF48: IRQ mode 12 - scroll backward ---
.proc IrqMode12_ScrollBack
  LDA #$00                                    ; $FF48: A9 00
  STA $5000                                   ; $FF4A: 8D 00 50
  LDA $006C                                   ; $FF4D: AD 6C 00
  STA $5000                                   ; $FF50: 8D 00 50
  LDA $006D                                   ; $FF53: AD 6D 00
  STA $5800                                   ; $FF56: 8D 00 58
  DEC $0060                                   ; $FF59: CE 60 00
  DEC $0060                                   ; $FF5C: CE 60 00
  JMP IrqChrUpdate_Block2                     ; $FF5F: 4C FC FB
.endproc

;===============================================================================
; $FF62: CalcScrollAddr
; Calculates PPU scroll address from map position ($0098).
; Output: $0099=copy, $009A/$009B=PPU addr, $00EA/$00EC=nametable.
;===============================================================================
.proc CalcScrollAddr
  LDA #$00                                    ; $FF62: A9 00
  STA $0047                                   ; $FF64: 8D 47 00
  LDA $0098                                   ; $FF67: AD 98 00
  STA $0099                                   ; $FF6A: 8D 99 00
  AND #$F8                                    ; $FF6D: 29 F8
  ASL A                                       ; $FF6F: 0A
  ROL $0047                                   ; $FF70: 2E 47 00
  ASL A                                       ; $FF73: 0A
  ROL $0047                                   ; $FF74: 2E 47 00
  STA $009A                                   ; $FF77: 8D 9A 00
  LDA $0047                                   ; $FF7A: AD 47 00
  CLC                                         ; $FF7D: 18
  ADC #$20                                    ; $FF7E: 69 20
  STA $009B                                   ; $FF80: 8D 9B 00
  LDA #$E0                                    ; $FF83: A9 E0
  STA $00EA                                   ; $FF85: 8D EA 00
  STA $00EC                                   ; $FF88: 8D EC 00
  LDA $0097                                   ; $FF8B: AD 97 00
  AND #$01                                    ; $FF8E: 29 01
@check_nt:
  BEQ @rts_calc                               ; $FF90: F0 08
  LDA #$E1                                    ; $FF92: A9 E1
  STA $00EA                                   ; $FF94: 8D EA 00
  STA $00EC                                   ; $FF97: 8D EC 00
@rts_calc:
  RTS                                         ; $FF9A: 60
.endproc

;===============================================================================
; $FF9B: CalcScrollAddrAlt
; Alternate version: adds +4 to $009B when on nametable $E1.
;===============================================================================
.proc CalcScrollAddrAlt
  LDA #$00                                    ; $FF9B: A9 00
  STA $0047                                   ; $FF9D: 8D 47 00
  LDA $0098                                   ; $FFA0: AD 98 00
  STA $0099                                   ; $FFA3: 8D 99 00
  AND #$F8                                    ; $FFA6: 29 F8
  ASL A                                       ; $FFA8: 0A
  ROL $0047                                   ; $FFA9: 2E 47 00
  ASL A                                       ; $FFAC: 0A
  ROL $0047                                   ; $FFAD: 2E 47 00
  STA $009A                                   ; $FFB0: 8D 9A 00
  LDA $0047                                   ; $FFB3: AD 47 00
  CLC                                         ; $FFB6: 18
  ADC #$20                                    ; $FFB7: 69 20
  STA $009B                                   ; $FFB9: 8D 9B 00
  LDA #$E0                                    ; $FFBC: A9 E0
  STA $00EA                                   ; $FFBE: 8D EA 00
  LDA $0097                                   ; $FFC1: AD 97 00
  AND #$01                                    ; $FFC4: 29 01
@check_nt_alt:
  BEQ @rts_calc_alt                           ; $FFC6: F0 0E
  LDA $009B                                   ; $FFC8: AD 9B 00
  CLC                                         ; $FFCB: 18
  ADC #$04                                    ; $FFCC: 69 04
  STA $009B                                   ; $FFCE: 8D 9B 00
  LDA #$E1                                    ; $FFD1: A9 E1
  STA $00EA                                   ; $FFD3: 8D EA 00
@rts_calc_alt:
  RTS                                         ; $FFD6: 60
.endproc

;===============================================================================
; $FFD7-$FFF9: Unused space (35 bytes of $FF)
;===============================================================================
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $FFD7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $FFE7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$00                                     ; $FFF7: FF FF 00

;===============================================================================
; $FFFA-$FFFF: 6502 Interrupt Vectors
;===============================================================================
  .word NmiHandler                              ; $FFFA: 00 F8 (NMI -> $F800)
  .word $E000                                   ; $FFFC: 00 E0 (RESET -> $E000)
  .word IrqHandler                              ; $FFFE: 2D FB (IRQ -> $FB2D)

