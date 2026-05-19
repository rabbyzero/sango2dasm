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
addr_game_state     = $007A  ; State counter (0-14), indexes VectorTable
addr_sub_state      = $0078  ; Sub-state within each major state
addr_dispatch_ptr   = $004E  ; Indirect jump target (low)
addr_dispatch_ptr_h = $004F  ; Indirect jump target (high)

; --- PPU ---
addr_ppu_ctrl_ram   = $008B  ; RAM copy of PPU control ($2000)
addr_ppu_mask_ram   = $008C  ; RAM copy of PPU mask ($2001)
addr_display_mode   = $0098  ; Display mode parameter
addr_display_mode_h = $0099  ; Display mode parameter (high)
addr_scroll_x       = $009A  ; Scroll X computed value
addr_scroll_y       = $009B  ; Scroll Y computed value
addr_nmi_flag       = $007E  ; NMI sub-dispatch flag byte

; --- Controller ---
addr_pad1_edge      = $0081  ; Pad 1 newly-pressed buttons
addr_pad1_raw       = $0083  ; Pad 1 raw button state
addr_pad1_prev      = $0084  ; Pad 1 previous frame state

; --- Bank Switch ---
addr_bank_e6        = $00E6  ; Bank register RAM copy (PRG $C000)
addr_bank_e7        = $00E7  ; Bank register RAM copy (PRG $C800)
addr_bank_e8        = $00E8  ; Bank register RAM copy (PRG $D000)
addr_bank_e9        = $00E9  ; Bank register RAM copy (PRG $D800)
addr_bank_ea        = $00EA  ; Extended bank config
addr_bank_eb        = $00EB  ; Extended bank config
addr_bank_ec        = $00EC  ; Extended bank config
addr_bank_ed        = $00ED  ; Extended bank config

; --- RNG ---
addr_rng_index      = $0050  ; RNG table index
addr_rng_saved_x    = $0051  ; Saved X register (RNG)

; --- Menu ---
addr_menu_step      = $00    ; Items per page (1-8), set by entry point
addr_menu_ptr_lo    = $10    ; Menu data table pointer (low)
addr_menu_ptr_hi    = $11    ; Menu data table pointer (high)
addr_menu_result    = $12    ; Current item value (returned)
addr_menu_column    = $0424  ; Cursor column (0-based within page)
addr_menu_page      = $0425  ; Cursor page (0-based)

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
  SEI  ; $E000: 78  Disable interrupts
  CLD  ; $E001: D8  Clear decimal mode
  LDA #$00  ; $E002: A9 00
  STA PPU_CTRL  ; $E004: 8D 00 20  Disable NMI
  STA PPU_MASK  ; $E007: 8D 01 20  Disable rendering
  LDY #$02  ; $E00A: A0 02
@vblank1:
  LDA PPU_STATUS  ; $E00C: AD 02 20  Wait for VBlank
  BPL @vblank1  ; $E00F: 10 FB
  LDA PPU_STATUS  ; $E011: AD 02 20
  BMI @vblank1_nego  ; $E014: 30 FB  Wait for VBlank end
@vblank1_nego:
  DEY  ; $E016: 88
  BPL @vblank1  ; $E017: 10 F3

  ; APU init
  LDA #$00  ; $E019: A9 00
  STA APU_DMC_FREQ  ; $E01B: 8D 10 40  $4010
  LDA #$0F  ; $E01E: A9 0F
  STA APU_SND_CHN  ; $E020: 8D 15 40  $4015
  LDA #$C0  ; $E023: A9 C0
  STA APU_FRAME  ; $E025: 8D 17 40  $4017

  ; Second PPU warmup
  LDA #$00  ; $E028: A9 00
  STA PPU_CTRL  ; $E02A: 8D 00 20
  STA PPU_MASK  ; $E02D: 8D 01 20
  LDY #$04  ; $E030: A0 04
@vblank2:
  LDA PPU_STATUS  ; $E032: AD 02 20
  BPL @vblank2  ; $E035: 10 FB
  LDA PPU_STATUS  ; $E037: AD 02 20
  BMI @vblank2_nego  ; $E03A: 30 FB
@vblank2_nego:
  DEY  ; $E03C: 88
  BPL @vblank2  ; $E03D: 10 F3

  ; Set stack pointer
  LDX #$FF  ; $E03F: A2 FF
  TXS  ; $E041: 9A

  ; Clear RAM $0000-$07FF
  LDA #$04  ; $E042: A9 04
  STA $01  ; $E044: 8D 01 00
  LDY #$00  ; $E047: A0 00
  STY $02  ; $E049: 8C 02 00
  TYA  ; $E04C: 98
@clear_loop:
  STA ($01),Y  ; $E04D: 91 01
  INC $01  ; $E04F: EE 01 00
  BNE @clear_loop  ; $E052: D0 F8
  INC $02  ; $E054: EE 02 00
  LDA $02  ; $E057: AD 02 00
  CMP #$08  ; $E05A: C9 08
  BCC @clear_loop  ; $E05C: 90 EE

  ; Mapper init + controller check
  JSR MapperInitCtrlCheck  ; $E05E: 20 BD F3

  ; Initialize game state to 0
  LDA #$00  ; $E061: A9 00
  STA addr_game_state  ; $E063: 8D 7A 00

  ; Dispatch through vector table
  LDA addr_game_state  ; $E066: AD 7A 00
  AND #$1F  ; $E069: 29 1F  Mask to 0-31
  ASL  ; $E06B: 0A  * 2 for word index
  TAY  ; $E06C: A8
  LDA VectorTable,Y  ; $E06D: B9 7C E0
  STA addr_dispatch_ptr  ; $E070: 8D 4E 00
  LDA VectorTable+1,Y  ; $E073: B9 7D E0
  STA addr_dispatch_ptr+1  ; $E076: 8D 4F 00
  JMP (addr_dispatch_ptr)  ; $E079: 6C 4E 00
.endproc

;===============================================================================
; $E07C: Vector Dispatch Table (15 entries, 30 bytes)
;===============================================================================
VectorTable:
  .addr State_SystemInit       ; 0:  $E09A
  .addr State_NewGameInit      ; 1:  $E0DA
  .addr State_RandomDisplay2A  ; 2:  $E17D
  .addr State_KingdomSelect    ; 3:  $E18B
  .addr State_RandomDisplay28  ; 4:  $E221
  .addr State_DomesticAffairs  ; 5:  $E22F
  .addr State_RandomAdvance1   ; 6:  $E2E2
  .addr State_BattlePhase      ; 7:  $E2E8
  .addr State_RandomAdvance2   ; 8:  $E36A
  .addr State_TerritoryView    ; 9:  $E37C
  .addr State_IdleWait         ; 10: $E3EB
  .addr State_AdvisorCouncil   ; 11: $E3EE
  .addr State_IdleWait         ; 12: $E3EB (same as 10)
  .addr State_TurnSummary      ; 13: $E46A
  .addr State_IdleWait         ; 14: $E3EB (same as 10)

;===============================================================================
; $E09A: Entry 0 - System Init
; Params: none
;===============================================================================
.proc State_SystemInit
  JSR ReadPpuStatus  ; $E09A: 20 68 E7
  JSR WaitForVBlank  ; $E09D: 20 4D E7
  STA PPU_MASK  ; $E0A0: 8D 01 20  Disable rendering
  JSR BankPpuInit  ; $E0A3: 20 7F E5
  LDX #$1F  ; $E0A6: A2 1F
  LDA #$0F  ; $E0A8: A9 0F
@fill_palette:
  STA $0100,X  ; $E0AA: 9D 00 01  Fill sprite palette buffer
  DEX  ; $E0AD: CA
  BPL @fill_palette  ; $E0AE: 10 FA
@wait_vb:
  LDA PPU_STATUS  ; $E0B0: AD 02 20
  BPL @wait_vb  ; $E0B3: 10 FB
  LDA #$4C  ; $E0B5: A9 4C  JMP opcode
  STA $00A5  ; $E0B7: 8D A5 00  Patch RAM
  STA NAMCO_CTRL  ; $E0BA: 8D 00 F8  Patch mapper
  LDA #$00  ; $E0BD: A9 00
  JSR BankSwitch  ; $E0BF: 20 1F E5
  LDA #$10  ; $E0C2: A9 10  NMI enable + sprite height
  STA addr_ppu_ctrl_ram  ; $E0C4: 8D 8B 00
  STA PPU_CTRL  ; $E0C7: 8D 00 20
  LDA #$00  ; $E0CA: A9 00  Rendering off
  STA addr_ppu_mask_ram  ; $E0CC: 8D 8C 00
  STA PPU_MASK  ; $E0CF: 8D 01 20
  LDA #$09  ; $E0D2: A9 09  Next state = 9
  STA addr_game_state  ; $E0D4: 8D 7A 00
  JMP StateDispatch  ; $E0D7: 4C 66 E0
.endproc

;===============================================================================
; $E0DA: Entry 1 - New Game Init
; Params: $0400 = controller input result
;         $0098 = display param
;         SRAM: $6F41, $6F3F, $6F8B = kingdom init
;===============================================================================
.proc State_NewGameInit
  JSR FrameInit  ; $E0DA: 20 DA E4
  LDA #$02  ; $E0DD: A9 02
  STA addr_sub_state  ; $E0DF: 8D 78 00  Sub-state = 2
  LDA #$00  ; $E0E2: A9 00
  JSR DisplayInit  ; $E0E4: 20 70 E3
  LDY #$30  ; $E0E7: A0 30
  JSR WindowDisplaySetup  ; $E0E9: 20 5F F2

  ; Set pointer to $8000
  LDA #$00  ; $E0EC: A9 00
  STA $000A  ; $E0EE: 8D 0A 00  ptr_lo
  LDA #$80  ; $E0F1: A9 80
  STA $000B  ; $E0F3: 8D 0B 00  ptr_hi -> $8000
  LDA #$20  ; $E0F6: A9 20
  STA $0001  ; $E0F8: 8D 01 00  width param
  LDA #$00  ; $E0FB: A9 00
  STA $0000  ; $E0FD: 8D 00 00
  STA $0004  ; $E100: 8D 04 00
  STA $0005  ; $E103: 8D 05 00
  STA $0006  ; $E106: 8D 06 00
  LDA #$04  ; $E109: A9 04
  STA $0007  ; $E10B: 8D 07 00

  LDY #$37  ; $E10E: A0 37
  JSR WindowDisplaySetup  ; $E110: 20 37 F2
  JSR $A003  ; $E113: 20 03 A0  Display (bank-switched)

  ; Window + render
  LDY #$3D  ; $E116: A0 3D
  JSR WindowDisplaySetup  ; $E118: 20 37 F2
  LDA #$00  ; $E11B: A9 00
  STA $0000  ; $E11D: 8D 00 00
  JSR $A015  ; $E120: 20 15 A0  Overlay display

  JSR ControllerRead  ; $E123: 20 F7 EA
  LDA $0400  ; $E126: AD 00 04  Check input
  CMP #$0D  ; $E129: C9 0D
  BEQ @skip_sram_flag  ; $E12B: F0 05
  LDA #$FF  ; $E12D: A9 FF
  STA $6F8B  ; $E12F: 8D 8B 6F  Set SRAM flag
@skip_sram_flag:
  LDY #$3D  ; $E132: A0 3D
  JSR WindowDisplaySetup  ; $E134: 20 37 F2
  JSR $A003  ; $E137: 20 36 A0
  JSR $A009  ; $E13A: 20 BF EC
  LDA #$A0  ; $E13D
  STA addr_display_mode  ; $E13F
  LDA #$00  ; $E141
  STA $0420  ; $E143
  STA $04E0  ; $E146
  STA $04E1  ; $E149: 8D 98 00
  STA $04E2  ; $E14C
  STA $04E3  ; $E14F
  LDA #$F0  ; $E152
  STA $6F41  ; $E154: 8D E1 04  SRAM: kingdom param
  LDA #$80  ; $E157
  STA $6F3F  ; $E159  SRAM: kingdom param
  LDA #$00  ; $E15C
  JSR BankSwitch  ; $E15E
  INC addr_game_state  ; $E161  Next state
  LDA #$81  ; $E163
  JSR SoundWrapperA  ; $E165  Music $81
  JSR PpuMaskHelper  ; $E168
  JSR PpuCtrlNmiHelpers  ; $E16B
  JMP StateDispatch  ; $E16E
.endproc

;===============================================================================
; $E17D: Entry 2 - Random + Display (Y=$2A)
;===============================================================================
.proc State_RandomDisplay2A
  JSR RandomByte  ; $E17D: 20 7A E8
  LDY #$2A  ; $E180: A0 2A
  JSR WindowSetup2  ; $E182: 20 4B F2
  JSR $A000  ; $E185: 20 00 A0  Display (bank-switched)
  JMP StateDispatch  ; $E188: 4C 66 E0
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

  JSR FrameInit  ; $E18B: 20 DA E4
  LDA #$03  ; $E18E: A9 03
  STA addr_sub_state  ; $E190: 8D 78 00
  LDA #$01  ; $E193: A9 01
  JSR DisplayInit  ; $E195: 20 70 E3
  LDY #$37  ; $E198: A0 37
  JSR WindowDisplaySetup  ; $E19A: 20 37 F2
  JSR $A027  ; $E19D: 20 27 A0  Kingdom display (bank-switched)

  LDA kingdom_mode  ; $E1A0: AD 00 05
  CMP #$0B  ; $E1A3: C9 0B  Scenario mode?
  BNE @normal_mode  ; $E1A5: D0 0B
  LDY #$2C  ; $E1A7: A0 2C
  JSR WindowDisplaySetup  ; $E1A9: 20 37 F2
  JSR $A006  ; $E1AC: 20 06 A0  Scenario function
  JMP @after_mode_check  ; $E1AF: 4C BA E1
@normal_mode:
  LDY #$28  ; $E1B2: A0 28
  JSR WindowDisplaySetup  ; $E1B4: 20 37 F2
  JSR $A003  ; $E1B7: 20 03 A0  Normal function
@after_mode_check:
  LDA kingdom_x  ; $E1BA: AD 10 05
  STA $0090  ; $E1BD: 8D 90 00
  LDA kingdom_y  ; $E1C0: AD 11 05
  STA $0091  ; $E1C3: 8D 91 00
  LDA kingdom_x2  ; $E1C6: AD 12 05
  STA $008E  ; $E1C9: 8D 8E 00
  LDA kingdom_y2  ; $E1CC: AD 13 05
  STA $008F  ; $E1CF: 8D 8F 00
  LDA #$FF  ; $E1D2: A9 FF
  STA $0518  ; $E1D4: 8D 18 05  Kingdom flag

  ; Display + render
  LDY #$3D  ; $E1D7: A0 37
  JSR WindowDisplaySetup  ; $E1D9: 20 37 F2
  JSR $A009  ; $E1DC: 20 09 A0
  LDA #$00  ; $E1DF
  STA $0000  ; $E1E1
  JSR $A015  ; $E1E3
  JSR ControllerRead  ; $E1E6

  LDA #$00  ; $E1E9
  STA $0508  ; $E1EB
  LDA #$70  ; $E1EE
  STA territory_ptr_lo  ; $E1F0
  LDA #$AF  ; $E1F2
  STA territory_ptr_hi  ; $E1F4  Ptr = $AF70

  LDA #$01  ; $E1F6
  JSR BankSwitch  ; $E1F8
  LDA #$01  ; $E1FB
  STA $0097  ; $E1FD
  JSR PaletteUpload  ; $E1FF
  LDA #$05  ; $E202
  STA $0061  ; $E204
  INC addr_game_state  ; $E206
  LDA #$1D  ; $E208
  JSR SoundWrapperA  ; $E20A  Music $1D
  JSR PpuMaskHelper  ; $E20D
  JSR PpuCtrlNmiHelpers  ; $E210
  JMP StateDispatch  ; $E213
.endproc

;===============================================================================
; $E221: Entry 4 - Random + Display (Y=$28)
;===============================================================================
.proc State_RandomDisplay28
  JSR RandomByte  ; $E221: 20 7A E8
  LDY #$28  ; $E224: A0 28
  JSR WindowSetup2  ; $E226: 20 4B F2
  JSR $A000  ; $E229: 20 00 A0
  JMP StateDispatch  ; $E22C: 4C 66 E0
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

  JSR FrameInit  ; $E22F: 20 DA E4
  LDA #$04  ; $E232: A9 04
  STA addr_sub_state  ; $E234: 8D 78 00
  LDA action_type  ; $E237: AD 44 05
  CLC  ; $E23A: 18
  ADC #$02  ; $E23B: 69 02
  JSR DisplayInit  ; $E23D: 20 70 E3
  LDA #$02  ; $E240: A9 02
  JSR BankSwitch  ; $E242: 20 1F E5
  LDY #$37  ; $E245: A0 37
  JSR WindowDisplaySetup  ; $E247: 20 37 F2
  JSR $A024  ; $E24A: 20 24 A0  Domestic display
  LDY #$3D  ; $E24D: A0 3D
  JSR WindowDisplaySetup  ; $E24F: 20 37 F2

  ; Second display call with action type
  LDA action_type  ; $E252: AD 44 05
  ASL  ; $E255
  JSR DomesticActionDisplay  ; $E256

  ; Sprite positions from table
  LDY sprite_idx1  ; $E259
  LDA DomesticSpriteYPos,Y  ; $E25C
  STA $0107  ; $E25F  Sprite position indicator
  STA $0113  ; $E262  Mirror
  LDY sprite_idx2  ; $E265
  LDA DomesticSpriteYPos,Y  ; $E268
  STA $010F  ; $E26B
  STA $0117  ; $E26E

  JSR ControllerRead  ; $E271
  LDY #$3D  ; $E274
  JSR WindowDisplaySetup  ; $E276: 20 F7 EA
  LDA #$01  ; $E279
  STA $0000  ; $E27B
  JSR $A015  ; $E27D
  LDA #$A0  ; $E280
  STA addr_display_mode  ; $E282
  JSR PaletteUpload  ; $E284
  INC addr_game_state  ; $E287
  LDA #$0D  ; $E289
  JSR SoundWrapperC  ; $E28B  Sound $0D
  JSR PpuMaskHelper  ; $E28E
  JSR PpuCtrlNmiHelpers  ; $E291
  JMP StateDispatch  ; $E294
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

  LDA action_type  ; $E29C: AD 44 05
  ASL  ; $E29F: 0A  * 2 for table index
  TAY  ; $E2A0: A8
  LDA DomesticGraphicPtrs,Y  ; $E2A1: B9 C2 E2
  STA graphic_ptr_lo  ; $E2A4: 8D 0A 00
  LDA DomesticGraphicPtrs+1,Y  ; $E2A7: B9 C3 E2
  STA graphic_ptr_hi  ; $E2AA: 8D 0B 00
  LDA DomesticBaseDataPtrs,Y  ; $E2AD: B9 D0 E2
  STA base_ptr_lo  ; $E2B0: 8D 0C 00
  LDA DomesticBaseDataPtrs+1,Y  ; $E2B3: B9 D1 E2
  STA base_ptr_hi  ; $E2B6: 8D 0D 00
  LDY #$37  ; $E2B9: A0 37
  JSR WindowDisplaySetup  ; $E2BB: 20 37 F2
  JSR $A006  ; $E2BE: 20 06 A0  Action display (bank-switched)
  RTS  ; $E2C1: 60
.endproc

; Domestic action display (wraps lookup)
DomesticActionDisplay = DomesticActionLookup

;===============================================================================
; $E2C2: Domestic Action Data Tables
;===============================================================================
DomesticGraphicPtrs:
  .addr $8440, $8570, $86A0, $87D0, $8900, $8A30, $8B60

DomesticBaseDataPtrs:
  .addr $8000, $8000, $8000, $8000, $8000, $8000, $8000

DomesticSpriteYPos:
  .byte $10, $0F, $00, $16

;===============================================================================
; $E2E2: Entry 6 - Random Seed Advance
;===============================================================================
.proc State_RandomAdvance1
  JSR RandomByte  ; $E2E2: 20 7A E8
  JMP StateDispatch  ; $E2E5: 4C 66 E0
.endproc

;===============================================================================
; $E2E8: Entry 7 - Battle Phase
; Params: $04AB/$04AC = army status flags
;         $0098 = display param ($A0)
;===============================================================================
.proc State_BattlePhase
army_status1    = $04AB
army_status2    = $04AC

  JSR FrameInit  ; $E2E8: 20 DA E4
  LDA #$05  ; $E2EB: A9 05
  STA addr_sub_state  ; $E2ED: 8D 78 00
  LDA #$0A  ; $E2F0: A9 0A  Battle display mode
  JSR DisplayInit  ; $E2F2: 20 70 E3
  LDA #$A0  ; $E2F5: A9 A0
  STA addr_display_mode  ; $E2F7: 8D 98 00
  LDY #$30  ; $E2FA: A0 30
  JSR WindowDisplaySetup  ; $E2FC: 20 5F F2
  LDA #$00  ; $E2FF: A9 00
  STA $000A  ; $E301: 8D 0A 00  ptr_lo
  LDA #$84  ; $E304: A9 84
  STA $000B  ; $E306: 8D 0B 00  ptr_hi -> $8400
  LDA #$00  ; $E309: A9 00
  STA $0000  ; $E30B: 8D 00 00
  LDA #$20  ; $E30E: A9 20
  STA $0001  ; $E310: 8D 01 00
  LDY #$37  ; $E313: A0 37
  JSR WindowDisplaySetup  ; $E315: 20 37 F2
  JSR $A003  ; $E318: 20 03 A0  Battle display
  LDY #$3D  ; $E31B: A0 3D
  JSR WindowDisplaySetup  ; $E31D: 20 37 F2
  LDA #$0A  ; $E320: A9 0A
  STA $0000  ; $E322: 8D 00 00
  JSR $A015  ; $E325: 20 15 A0

  JSR ControllerRead  ; $E328: 20 F7 EA

  ; Check army status flags
  LDX #$00  ; $E32B: A2 00
  LDA army_status1  ; $E32D: AD AB 04
  CMP #$01  ; $E330: C9 01
  BNE @army2_check  ; $E332: D0 06
  STX $0106  ; $E334: 8E 06 01  Clear sprite if army=1
  STX $0116  ; $E337: 8E 16 01
@army2_check:
  LDA army_status2  ; $E33A: AD AC 04
  CMP #$01  ; $E33D: C9 01
  BNE @after_army  ; $E33F: D0 06
  STX $010E  ; $E341: 8E 0E 01  Clear sprite if army=1
  STX $011A  ; $E344: 8E 1A 01
@after_army:
  JSR PaletteUpload  ; $E347: 20 BF EC
  LDY #$3D  ; $E34A: A0 3D
  JSR WindowDisplaySetup  ; $E34C: 20 37 F2
  LDA #$02  ; $E34F: A9 02
  JSR BankSwitch  ; $E351: 20 45 A0
  INC addr_game_state  ; $E354
  LDA #$12  ; $E356
  JSR SoundWrapperB  ; $E358  Battle music $12
  JSR PpuMaskHelper  ; $E35B
  JSR PpuCtrlNmiHelpers  ; $E35E: 20 7B E6
  JMP StateDispatch  ; $E361
.endproc

;===============================================================================
; $E36A: Entry 8 - Random Seed Advance
;===============================================================================
.proc State_RandomAdvance2
  JSR RandomByte  ; $E36A: 20 7A E8
  JMP StateDispatch  ; $E36D: 4C 66 E0
.endproc

;===============================================================================
; $E370: Display Init Helper
; Params: A = display mode index (passed before call)
;===============================================================================
.proc DisplayInit
  LDY #$3D  ; $E370: A0 3D
  JSR WindowDisplaySetup  ; $E372: 20 37 F2  Window clear
  JSR $A01B  ; $E375: 20 1B A0  Bank-switched display
  JSR ChrBankSwitch  ; $E378: 20 06 F2  Window/display helper
  RTS  ; $E37B: 60
.endproc

;===============================================================================
; $E37C: Entry 9 - Territory / Map View
;===============================================================================
.proc State_TerritoryView
  JSR FrameInit  ; $E37C: 20 DA E4
  LDA #$06  ; $E37F: A9 06
  STA addr_sub_state  ; $E381: 8D 78 00
  LDA #$0B  ; $E384: A9 0B  Territory display mode
  JSR DisplayInit  ; $E386: 20 70 E3
  LDY #$35  ; $E389: A0 35
  JSR WindowDisplaySetup  ; $E38B: 20 5F F2
  LDA #$90  ; $E38E: A9 90
  STA $000A  ; $E390: 8D 0A 00
  LDA #$9A  ; $E393: A9 9A
  STA $000B  ; $E395: 8D 0B 00  Ptr -> $9A90
  LDA #$00  ; $E398: A9 20
  STA $0000  ; $E39A: 8D 01 00
  LDA #$20  ; $E39D: A9 00
  STA $0001  ; $E39F: 8D 00 00
  LDA #$00  ; $E3A2
  STA $0004  ; $E3A4
  STA $0005  ; $E3A6
  STA $0006  ; $E3A8: 8D 06 00
  LDA #$04  ; $E3AB: A9 04
  STA $0007  ; $E3AD: 8D 07 00
  LDY #$37  ; $E3B0: A0 37
  JSR WindowDisplaySetup  ; $E3B2: 20 37 F2
  JSR $A003  ; $E3B5: 20 03 A0
  LDY #$3D  ; $E3B8: A0 3D
  JSR WindowDisplaySetup  ; $E3BA: 20 37 F2
  LDA #$0B  ; $E3BD: A9 0B
  STA $0000  ; $E3BF: 8D 00 00
  JSR $A015  ; $E3C2: 20 15 A0
  JSR ControllerRead  ; $E3C5: 20 F7 EA
  JSR PaletteUpload  ; $E3C8: 20 BF EC
  LDY #$3D  ; $E3CB: A0 3D
  JSR WindowDisplaySetup  ; $E3CD: 20 37 F2
  LDA #$03  ; $E3D0: A9 03
  JSR PaletteUpload  ; $E3D2: 20 45 A0
  LDA #$A0  ; $E3D5: A9 A0
  STA addr_display_mode  ; $E3D7: 8D 98 00
  LDA #$02  ; $E3DA: A9 02
  JSR BankSwitch  ; $E3DC: 20 1F E5
  INC addr_game_state  ; $E3DF: EE 7A 00
  JSR PpuMaskHelper  ; $E3E2: 20 49 E7
  JSR PpuCtrlNmiHelpers  ; $E3E5: 20 53 E7
  JMP StateDispatch  ; $E3E8: 4C 66 E0
.endproc

;===============================================================================
; $E3EB: Entry 10/12/14 - Idle / Wait State
;===============================================================================
State_IdleWait:
  JMP StateDispatch  ; $E3EB: 4C 66 E0

;===============================================================================
; $E3EE: Entry 11 - Advisor / Council
;===============================================================================
.proc State_AdvisorCouncil
  JSR FrameInit  ; $E3EE: 20 DA E4
  LDA #$07  ; $E3F1: A9 07
  STA addr_sub_state  ; $E3F3: 8D 78 00
  LDA #$0C  ; $E3F6: A9 0C  Advisor display mode
  JSR DisplayInit  ; $E3F8: 20 70 E3
  LDY #$32  ; $E3FB: A0 32
  JSR WindowDisplaySetup  ; $E3FD: 20 5F F2
  LDA #$E3  ; $E400: A9 E3
  STA $000A  ; $E402: 8D 0A 00
  LDA #$9A  ; $E405: A9 9A
  STA $000B  ; $E407: 8D 0B 00  Ptr -> $9AE3
  LDA #$00  ; $E40A: A9 20
  STA $0000  ; $E40C: 8D 01 00
  LDA #$20  ; $E40F: A9 00
  STA $0001  ; $E411: 8D 00 00
  LDA #$00  ; $E414
  STA $0004  ; $E416
  STA $0005  ; $E418
  STA $0006  ; $E41A: 8D 06 00
  LDA #$04  ; $E41D: A9 04
  STA $0007  ; $E41F: 8D 07 00
  LDY #$37  ; $E422: A0 37
  JSR WindowDisplaySetup  ; $E424: 20 37 F2
  JSR $A003  ; $E427: 20 03 A0
  LDY #$3D  ; $E42A: A0 3D
  JSR WindowDisplaySetup  ; $E42C: 20 37 F2
  JSR $A018  ; $E42F: 20 18 A0  Advisor dialogue
  CLC  ; $E432
  LDY #$3D  ; $E433
  JSR WindowDisplaySetup  ; $E435
  LDA #$0C  ; $E438
  STA $0000  ; $E43A
  JSR $A015  ; $E43C: 20 15 A0
  JSR ControllerRead  ; $E43F: 20 F7 EA
  JSR PaletteUpload  ; $E442: 20 BF EC
  LDY #$3D  ; $E445: A0 3D
  JSR WindowDisplaySetup  ; $E447: 20 37 F2
  LDA #$04  ; $E44A: A9 04
  JSR PaletteUpload  ; $E44C: 20 45 A0
  LDA #$A0  ; $E44F: A9 A0
  STA addr_display_mode  ; $E451: 8D 98 00
  LDA #$02  ; $E454: A9 02
  JSR BankSwitch  ; $E456: 20 1F E5
  INC addr_game_state  ; $E459: EE 7A 00
  LDA #$08  ; $E45C: A9 08
  JSR SoundWrapperC  ; $E45E: 20 83 E6  Sound $08
  JSR PpuMaskHelper  ; $E461: 20 49 E7
  JSR PpuCtrlNmiHelpers  ; $E464: 20 53 E7
  JMP StateDispatch  ; $E467: 4C 66 E0
.endproc

;===============================================================================
; $E46A: Entry 13 - Turn Summary
; Params: $0541 = completion flag (0=normal, nonzero=victory)
;===============================================================================
.proc State_TurnSummary
completion_flag = $0541

  JSR FrameInit  ; $E46A: 20 DA E4
  LDA #$08  ; $E46D: A9 08
  STA addr_sub_state  ; $E46F: 8D 78 00
  LDA #$0D  ; $E472: A9 0D  Report display mode
  JSR DisplayInit  ; $E474: 20 70 E3
  LDY #$36  ; $E477: A0 36
  JSR WindowDisplaySetup  ; $E479: 20 5F F2
  LDA #$92  ; $E47C: A9 92
  STA $000A  ; $E47E: 8D 0A 00
  LDA #$9B  ; $E481: A9 9B
  STA $000B  ; $E483: 8D 0B 00  Ptr -> $9B92
  LDA #$00  ; $E486: A9 00
  STA $0000  ; $E488: 8D 00 00
  LDA #$20  ; $E48B: A9 20
  STA $0001  ; $E48D: 8D 01 00
  LDY #$37  ; $E490: A0 37
  JSR WindowDisplaySetup  ; $E492: 20 37 F2
  JSR $A003  ; $E495: 20 03 A0
  LDY #$3D  ; $E498: A0 3D
  JSR WindowDisplaySetup  ; $E49A: 20 37 F2
  LDA #$0D  ; $E49D: A9 0D
  STA $0000  ; $E49F: 8D 00 00
  JSR $A015  ; $E4A2: 20 15 A0
  JSR ControllerRead  ; $E4A5: 20 F7 EA
  JSR PaletteUpload  ; $E4A8
  LDY #$3D  ; $E4AB
  JSR WindowDisplaySetup  ; $E4AD
  LDA #$05  ; $E4B0
  JSR PaletteUpload  ; $E4B2
  LDA #$A0  ; $E4B5
  STA addr_display_mode  ; $E4B7
  LDA #$02  ; $E4B9
  JSR BankSwitch  ; $E4BB
  INC addr_game_state  ; $E4BE
  LDY completion_flag  ; $E4C0
  BNE @victory_music  ; $E4C3
  LDA #$98  ; $E4C5
  JSR SoundWrapperA  ; $E4C7  Normal music $98
  JMP @after_music  ; $E4CA
@victory_music:
  LDA #$AA  ; $E4CD
  JSR SoundWrapperB  ; $E4CF  Victory music $AA
@after_music:
  JSR PpuMaskHelper  ; $E4D2
  JSR PpuCtrlNmiHelpers  ; $E4D5
  JMP StateDispatch  ; $E4D8
.endproc

;===============================================================================
; State Dispatch (JMP target shared by all states)
;===============================================================================
StateDispatch:
  LDA addr_game_state  ; $E4DB
  AND #$1F  ; $E4DD
  ASL  ; $E4DF
  TAY  ; $E4E0
  LDA VectorTable,Y  ; $E4E1
  STA addr_dispatch_ptr  ; $E4E4
  LDA VectorTable+1,Y  ; $E4E6
  STA addr_dispatch_ptr+1  ; $E4E9
  JMP (addr_dispatch_ptr)  ; $E4EB

;===============================================================================
; $E4DA: Frame Init Helper
; Clears display working RAM, sets sentinel values
;===============================================================================
.proc FrameInit
  JSR ReadPpuStatus  ; $E4DA: 20 68 E7
  JSR WaitForVBlank  ; $E4DD: 20 4D E7
  STA PPU_MASK  ; $E4E0: 8D 01 20  Disable rendering
  JSR BankPpuInit  ; $E4E3: 20 7F E5
  JSR NametableFill2  ; $E4E6: 20 DF E7
  LDA #$00  ; $E4E9: A9 00
  STA $0090  ; $E4EB: 8D 90 00
  STA $0091  ; $E4EE: 8D 91 00
  STA $008E  ; $E4F1: 8D 8E 00
  STA $008F  ; $E4F4: 8D 8F 00
  STA addr_display_mode  ; $E4F7: 8D 98 00
  STA $0099  ; $E4FA: 8D 99 00
  STA $0096  ; $E4FD: 8D 96 00
  STA $0097  ; $E500: 8D 97 00
  STA addr_nmi_flag  ; $E503
  STA $005E  ; $E505: 8D 7E 00
  STA $005F  ; $E508: 8D 5E 00
  STA $008D  ; $E50B: 8D 5F 00
  STA $00A4  ; $E50E: 8D 8D 00
  LDA #$FF  ; $E511
  STA $0300  ; $E513  Sentinel values
  STA $0304  ; $E516: 8D 00 03
  JMP SpriteBufferInit  ; $E519
.endproc

;===============================================================================
; $E51F: Bank Switch
; Params: A = config index (0-N), reads 8-byte config from BankSwitchTable
;===============================================================================
.proc BankSwitch
  ASL  ; $E51F: 0A  A * 2
  ASL  ; $E520: 0A  A * 4
  ASL  ; $E521: 0A  A * 8 -> table offset
  TAY  ; $E522: A8
  LDA BankSwitchTable,Y  ; $E523: B9 67 E5
  STA addr_bank_e6  ; $E526: 8D E6 00
  STA $C000  ; $E529: 8D 00 C0  Mapper register 1
  INY  ; $E52C: C8
  LDA BankSwitchTable,Y  ; $E52D: B9 67 E5
  STA addr_bank_e7  ; $E530: 8D E7 00
  STA $C800  ; $E533: 8D 00 C8  Mapper register 2
  INY  ; $E536: C8
  LDA BankSwitchTable,Y  ; $E537: B9 67 E5
  STA addr_bank_e8  ; $E53A: 8D E8 00
  STA $D000  ; $E53D: 8D 00 D0  Mapper register 3
  INY  ; $E540: C8
  LDA BankSwitchTable,Y  ; $E541: B9 67 E5
  STA addr_bank_e9  ; $E544: 8D E9 00
  STA $D800  ; $E547: 8D 00 D8  Mapper register 4
  INY  ; $E54A: C8
  LDA BankSwitchTable,Y  ; $E54B: B9 67 E5
  STA addr_bank_ea  ; $E54E: 8D EA 00
  INY  ; $E551: C8
  LDA BankSwitchTable,Y  ; $E552: B9 67 E5
  STA addr_bank_eb  ; $E555: 8D EB 00
  INY  ; $E558: C8
  LDA BankSwitchTable,Y  ; $E559: B9 67 E5
  STA addr_bank_ec  ; $E55C: 8D EC 00
  INY  ; $E55F: C8
  LDA BankSwitchTable,Y  ; $E560: B9 67 E5
  STA addr_bank_ed  ; $E563: 8D ED 00
  RTS  ; $E566: 60
.endproc

;===============================================================================
; $E567: Bank Switch Configuration Table
; 8 bytes per config. First 4: PRG bank regs, Last 4: extended config
;===============================================================================
BankSwitchTable:
  .byte $E0, $E1, $E1, $E1, $E0, $E1, $E0, $E1  ; Config 0
  .byte $E0, $E0, $E0, $E0, $E0, $E1, $E0, $E1  ; Config 1
  .byte $E0, $E1, $E0, $E1, $E0, $E1, $E0, $E1  ; Config 2

;===============================================================================
; $E57F: Bank + PPU Init + JMP Patch
;===============================================================================
.proc BankPpuInit
  LDA #$00  ; $E57F: A9 00
  JSR SoundWrapperA  ; $E581: 20 73 E6  Sound off
  JSR PaletteUpload  ; $E584: 20 90 E5
  LDA #$4C  ; $E587: A9 4C  JMP opcode
  STA $00A5  ; $E589: 8D A5 00  Patch RAM at $00A5
  STA NAMCO_CTRL  ; $E58C: 8D 00 F8  Write mapper
  RTS  ; $E58F: 60
.endproc

;===============================================================================
; $E590: Sound Init + IRQ Timer
; Initializes APU, clears sound RAM, uploads wavetable
;===============================================================================
.proc SoundInit
sound_irq_lo   = $07F6
sound_irq_hi   = $07F7
sound_ram_ptr  = $07F2

  LDA #$00  ; $E590: A9 00
  STA APU_SND_CHN  ; $E592: 8D 15 40  $4015 - silence all channels
  STA sound_irq_lo  ; $E595: 8D F6 07
  LDA #$10  ; $E598: A9 10
  STA APU_PULSE1_VOL  ; $E59A: 8D 00 40  $4000
  STA APU_PULSE1_SWEEP  ; $E59D: 8D 04 40  $4001
  STA APU_TRI_LINEAR  ; $E5A0: 8D 0C 40  $4008
  LDA #$08  ; $E5A3: A9 08
  STA APU_PULSE2_VOL  ; $E5A5: 8D 01 40  $4004
  STA APU_PULSE2_SWEEP  ; $E5A8: 8D 05 40  $4005
  LDA #$00  ; $E5AB: A9 00
  STA APU_DMC_FREQ  ; $E5AD: 8D 08 40  $4010

  ; Clear sound RAM $0700-$07FF
  TAX  ; $E5B0
@clear_loop:
  LDA #$FF  ; $E5B1
  STA $0700,X  ; $E5B3
  LDA #$00  ; $E5B6
  STA $0706,X  ; $E5B8
  TXA  ; $E5BB
  CLC  ; $E5BC
  ADC #$16  ; $E5BD
  TAY  ; $E5BF
  CMP #$F2  ; $E5C0
  BNE @clear_loop  ; $E5C2

  ; Upload wavetable to Namco-163 $4800
  LDA #$C0  ; $E5C4
  STA NAMCO_CTRL  ; $E5C6  Select wavetable address
  LDX #$3F  ; $E5C9
@wavetable_loop:
  LDA #$00  ; $E5CB
  STA $4800  ; $E5CD  Write to sound RAM
  DEX  ; $E5D0
  BPL @wavetable_loop  ; $E5D1

  ; Upload wavetable init data
  LDX #$80  ; $E5D3
  LDA #$30  ; $E5D5
  STX NAMCO_CTRL  ; $E5D7  Set auto-increment address
  STA $4800  ; $E5DA
@wt_init_loop:
  LDA WavetableInitData,X  ; $E5DD: BD A6 E6
  STA $4800  ; $E5E0: 8D 00 48
  INX  ; $E5E3: E8
  CPX #$20  ; $E5E4: E0 20
  BCC @wt_init_loop  ; $E5E6: 90 F5
  LDX #$64  ; $E5E8: A2 64
  LDA #$F0  ; $E5EA: A9 F0
  JSR WavetableWriteDelay  ; $E5EC: 20 FA E5
  LDX #$7F  ; $E5EF: A2 7F
  LDA #$30  ; $E5F1: A9 30
  STX NAMCO_CTRL  ; $E5F3: 8E 00 F8
  STA $4800  ; $E5F6: 8D 00 48
  RTS  ; $E5F9: 60
.endproc

;===============================================================================
; $E5FA: Wavetable Write Delay
; Params: A = value, X = register
;===============================================================================
.proc WavetableWriteDelay
  PHA  ; $E5FA: 48
  TXA  ; $E5FB
  JSR SoundNotePlayer_8  ; $E5FC: 20 F3 E5  Delay sub-entry
  PHA  ; $E5FF: 48
  TXA  ; $E600: 8A
  CLC  ; $E601: 18
  ADC #$08  ; $E602: 69 08
  TAX  ; $E604: AA
  BPL WavetableWriteDelay_done  ; $E605: 10 F4
  PLA  ; $E607: 68
  RTS  ; $E608: 60
WavetableWriteDelay_done:
  PLA  ; $E609
.endproc

;===============================================================================
; $E609: Sound Note Player
; Reads note data from banked ROM, writes to $0700-X RAM
;===============================================================================
.proc SoundNotePlayer
note_ptr_lo    = $F0
note_ptr_hi    = $F1
sound_temp    = $F2

  LDY #$22  ; $E609: A0 22
  JSR WindowDisplaySetup  ; $E60B: 20 5F F2
  LDY #$00  ; $E60E: A0 00
  STY $F1  ; $E610: 8C F1 00
  LDA $F0  ; $E613
  ASL $F1  ; $E615
  ASL $F1  ; $E617: 0A
  CLC  ; $E618
  ADC #$00  ; $E619
  STA $F0  ; $E61B
  LDA #$80  ; $E61D
  ADC $F1  ; $E61F
  STA $F1  ; $E621
  TXA  ; $E623
  PHA  ; $E624
  LDA ($F0),Y  ; $E625
  TAX  ; $E627
  LDA $0700,X  ; $E628
  CMP #$FF  ; $E62B
  BEQ SoundNotePlayer_done  ; $E62D
  LDA $0701,X  ; $E62F
  CMP #$04  ; $E632
  BCS SoundNotePlayer_done  ; $E634
  TAY  ; $E636
  LDA SoundChannelTable,Y  ; $E637
  STA $F2  ; $E63A
  LDA $0702,X  ; $E63C
  STA NAMCO_CTRL  ; $E63F
  LDA $0703,X  ; $E642
  STA $4800  ; $E645
  LDA $0704,X  ; $E648
  STA $4800  ; $E64B
  LDA $0705,X  ; $E64E
  STA $4800  ; $E651
SoundNotePlayer_done:
  PLA  ; $E654
  TAX  ; $E655
  RTS  ; $E656
.endproc

SoundNotePlayer_8 = SoundNotePlayer + 8

;===============================================================================
; $E667: Sound Channel Table (4 bytes)
;===============================================================================
SoundChannelTable:
  .byte $0E, $0D, $0B, $07

;===============================================================================
; $E66B-$E6A5: Sound Wrapper Functions (8 variants)
; Each plays a sound ID then increments and plays again
;===============================================================================
SoundWrapper0:
  PHA  ; $E66B: 48
  JSR SoundNotePlayer  ; $E66C: 20 09 E6
  PLA  ; $E66F: 68
  CLC  ; $E670: 18
  ADC #$01  ; $E671: 69 01
  JSR SoundNotePlayer  ; $E673
  RTS  ; $E676

SoundWrapperA:
  PHA  ; $E677
  JSR SoundNotePlayer  ; $E678
  PLA  ; $E67B
  CLC  ; $E67C
  ADC #$01  ; $E67D
  JSR SoundNotePlayer  ; $E67F
  RTS  ; $E682

SoundWrapperB:
  PHA  ; $E683: 48
  JSR SoundNotePlayer  ; $E684: 20 09 E6
  PLA  ; $E687: 68
  CLC  ; $E688: 18
  ADC #$01  ; $E689: 69 01
  JSR SoundNotePlayer  ; $E68B
  RTS  ; $E68E

SoundWrapperC:
  PHA  ; $E68F
  JSR SoundNotePlayer  ; $E690
  PLA  ; $E693
  CLC  ; $E694
  ADC #$01  ; $E695
  JSR SoundNotePlayer  ; $E697
  RTS  ; $E69A

;===============================================================================
; $E6A6: Wavetable Init Data (32 bytes)
;===============================================================================
WavetableInitData:
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00

;===============================================================================
; $E6C6: Controller Read
; Reads 8-bit serial data from $4016/$4017
; Output: $0081 = edge-triggered, $0083 = raw, $0084 = previous
;===============================================================================
.proc ControllerRead
  LDA #$01  ; $E6C6: AD 83 00
  STA APU_JOY1  ; $E6C9: 8D 84 00  Strobe controller
  STA $0000  ; $E6CC
  LSR  ; $E6CE
  STA APU_JOY1  ; $E6CF: 8D 86 00  End strobe
@read_loop:
  LDA APU_JOY1  ; $E6D2: A9 01  Read pad 1
  LSR  ; $E6D4
  ROL $0000  ; $E6D5
  LDA APU_JOY2  ; $E6D7: A9 00  Read pad 2
  LSR  ; $E6D9
  ROL $0001  ; $E6DA
  INY  ; $E6DC
  BNE @read_loop  ; $E6DD
  LDA $0000  ; $E6DF
  EOR #$FF  ; $E6E1
  STA addr_pad1_raw  ; $E6E3
  LDA addr_pad1_prev  ; $E6E5
  EOR addr_pad1_raw  ; $E6E7
  AND addr_pad1_raw  ; $E6E9
  STA addr_pad1_edge  ; $E6EB  Edge-triggered
  LDA addr_pad1_raw  ; $E6ED
  STA addr_pad1_prev  ; $E6EF
  RTS  ; $E6F1
.endproc

;===============================================================================
; $E70E: Palette Upload
; Uploads $0100-$011F to PPU $3F00
;===============================================================================
.proc PaletteUpload
  LDA $2002  ; $E70E: AD 8B 00  Read PPU status (reset latch)
  LDA #$3F  ; $E711
  STA PPU_ADDR  ; $E713: 8D 00 20
  LDA #$00  ; $E716: AD 02 20
  STA PPU_ADDR  ; $E719  PPU addr = $3F00
  LDX #$00  ; $E71C
@upload_loop:
  LDA $0100,X  ; $E71E: A9 3F
  STA PPU_DATA  ; $E720: 8D 06 20
  INX  ; $E723
  CPX #$20  ; $E724  32 bytes
  BNE @upload_loop  ; $E726
  RTS  ; $E728
.endproc

;===============================================================================
; $E749: PPU Mask Helper
;===============================================================================
.proc PpuMaskHelper
  LDA #$1E  ; $E749: A9 1E
  STA addr_ppu_mask_ram  ; $E74B
  STA PPU_MASK  ; $E74D
  RTS  ; $E750
.endproc

;===============================================================================
; $E753: PPU Ctrl/NMI Helpers
;===============================================================================
.proc PpuCtrlNmiHelpers
vblank_flag    = $008A

  LDA PPU_STATUS  ; $E753: AD 02 20  Read PPU status
  BPL @no_vblank  ; $E756
  LDA #$01  ; $E758
  STA vblank_flag  ; $E75A
@no_vblank:
  LDA addr_ppu_ctrl_ram  ; $E75C
  ORA #$80  ; $E75E  Enable NMI
  STA addr_ppu_ctrl_ram  ; $E760
  STA PPU_CTRL  ; $E762
  RTS  ; $E765
.endproc

;===============================================================================
; $E768: Read PPU Status
;===============================================================================
.proc ReadPpuStatus
  LDA PPU_STATUS  ; $E768: AD 8B 00
  RTS  ; $E76B
.endproc

;===============================================================================
; $E76D: Wait for VBlank
;===============================================================================
.proc WaitForVBlank
@wait:
  LDA PPU_STATUS  ; $E76D
  BPL @wait  ; $E770
  RTS  ; $E772
.endproc

;===============================================================================
; $E774: Nametable Fill Mode 1
; Fills 3 nametables with value from $02/$03
;===============================================================================
.proc NametableFill1
fill_lo       = $02
fill_hi       = $03

  LDA #$20  ; $E774: A9 E0
  STA fill_hi  ; $E776: 8D 00 C0
  LDA #$00  ; $E779: A9 E1
  STA fill_lo  ; $E77B: 8D 00 C8
@fill_loop:
  LDA fill_hi  ; $E77E: A9 E0
  STA PPU_ADDR  ; $E780: 8D 00 D0
  LDA fill_lo  ; $E783: A9 E1
  STA PPU_ADDR  ; $E785: 8D 00 D8
  LDA #$AA  ; $E788: AD 02 20  Fill value
  STA PPU_DATA  ; $E78B
  INC fill_lo  ; $E78E
  BNE @fill_loop  ; $E790
  INC fill_hi  ; $E792
  LDA fill_hi  ; $E794
  CMP #$24  ; $E796  End at $2400 (3 nametables)
  BCC @fill_loop  ; $E798
  RTS  ; $E79A
.endproc

;===============================================================================
; $E7DF: Nametable Fill Mode 2
;===============================================================================
.proc NametableFill2
  LDA #$AA  ; $E7DF: A9 E0
  STA $02  ; $E7E1: 8D 00 C0
  JSR NametableFill1  ; $E7E4
  RTS  ; $E7E7
.endproc

;===============================================================================
; $E823: Sprite Buffer Init
; Fills $0200-$02FF with $F0 (off-screen)
;===============================================================================
.proc SpriteBufferInit
  LDX #$00  ; $E823
  LDA #$F0  ; $E825
@fill_loop:
  STA $0200,X  ; $E827
  INX  ; $E82A
  BNE @fill_loop  ; $E82B
  RTS  ; $E82D
.endproc

;===============================================================================
; $E843: Random Below 100
; Returns: A = random byte 0-99
;===============================================================================
.proc RandomBelow100
@loop:
  JSR RandomByte  ; $E843: 20 7A E8
  CMP #$64  ; $E846: C9 64  < 100?
  BCS @loop  ; $E848: B0 F9
  RTS  ; $E84A: 60
.endproc

;===============================================================================
; $E84B: Random Div 2
; Returns: A = random byte / 2
;===============================================================================
.proc RandomDiv2
  JSR RandomByte  ; $E84B: 20 7A E8
  LSR  ; $E84E: 4A
  RTS  ; $E84F: 60
.endproc

;===============================================================================
; $E850: Random Mod Power of 2
; Multiple entry points for mod 4, mod 8, mod 16
;===============================================================================
.proc RandomModPow2
RandomMod4:
  JSR RandomByte  ; $E850: 20 7A E8
  AND #$03  ; $E853: 29 03
  RTS  ; $E855: 60

RandomMod8:
  JSR RandomByte  ; $E856: 20 7A E8
  AND #$07  ; $E859: 29 07
  RTS  ; $E85B: 60

RandomMod16:
  JSR RandomByte  ; $E85C: 20 7A E8
  AND #$0F  ; $E85F: 29 0F
  RTS  ; $E861: 60
.endproc

;===============================================================================
; $E862: Random Below Threshold
; Params: A = threshold value
; Returns: A = random value 0 to threshold-1
;===============================================================================
.proc RandomBelowThreshold
threshold    = $0000

  STA threshold  ; $E862: 85 10
@loop:
  JSR RandomByte  ; $E864
  AND #$0F  ; $E867  mod 16
  CMP threshold  ; $E869
  BCS @loop  ; $E86B
  RTS  ; $E86D
.endproc

;===============================================================================
; $E87A: Random Byte (RNG Core)
; Table lookup at $E8BA, index at $0050
; Returns: A = random byte
;===============================================================================
.proc RandomByte
rng_index    = $0050
rng_saved_x  = $0051

  STX addr_rng_saved_x  ; $E87A: 8E 51 00  Save X register
  LDX rng_index  ; $E87D: AE 50 00  Load current RNG index
  LDA RandomTable,X  ; $E880: BD BA E8  Read byte from pre-computed table
  INC rng_index  ; $E883: EE 50 00  Advance table index
  LDX addr_rng_saved_x  ; $E886: AE 51 00  Restore X register
  RTS  ; $E889: 60  Return with random byte in A
.endproc

;===============================================================================
; $E88A-$E8B9: Random Variants
; Separate RNG instances using $0052/$0054/$0055
;===============================================================================
.proc RandomVariants
rng2_index    = $0052
rng3_index    = $0054
rng4_index    = $0055

RandomByte2:
  STX addr_rng_saved_x  ; $E88A: 8E 53 00
  LDX rng2_index  ; $E88D: AE 52 00
  LDA RandomTable,X  ; $E890: BD BA E8
  INC rng2_index  ; $E893: EE 52 00
  LDX addr_rng_saved_x  ; $E896: AE 53 00
  RTS  ; $E899: 60

RandomByte3:
  STX addr_rng_saved_x  ; $E89A: 8E 53 00
  LDX rng3_index  ; $E89D: AE 54 00
  LDA RandomTable,X  ; $E8A0: BD BA E8
  INC rng3_index  ; $E8A3: EE 54 00
  LDX addr_rng_saved_x  ; $E8A6: AE 53 00
  RTS  ; $E8A9: 60

RandomByte4:
  STX addr_rng_saved_x  ; $E8AA: 8E 53 00
  LDX rng4_index  ; $E8AD: AE 55 00
  LDA RandomTable,X  ; $E8B0: BD BA E8
  INC rng4_index  ; $E8B3: EE 55 00
  LDX addr_rng_saved_x  ; $E8B6: AE 53 00
  RTS  ; $E8B9: 60
.endproc

;===============================================================================
; $E8BA: Random Table (~256 bytes)
;===============================================================================
RandomTable:
  .incbin "rom/prg/prg_1f.bin", $BA, $100

;===============================================================================
; $E9BA: Math - Binary to BCD
; Input: $01/$02/$03 = 24-bit little-endian value (mod 1,000,000)
; Output: $07/$08/$09 = 6 packed BCD digits
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

  ; Initialize BCD accumulators
  LDA #$00  ; $E9BA: A9 00
  STA bcd_tens_ones  ; $E9BC: 85 07
  STA bcd_thou_hund  ; $E9BE: 85 08
  STA bcd_htth_tth  ; $E9C0: 85 09

  ; Loop 1: Subtract 1,000,000 ($0F4240) - clamp
@clamp_million:
  LDA dividend_lo  ; $E9C2: A5 01
  SEC  ; $E9C4: 38
  SBC #$40  ; $E9C5: E9 40
  STA temp_lo  ; $E9C7: 85 04
  LDA dividend_mid  ; $E9C9: A5 02
  SBC #$42  ; $E9CB: E9 42
  STA temp_mid  ; $E9CD: 85 05
  LDA dividend_hi  ; $E9CF: A5 03
  SBC #$0F  ; $E9D1: E9 0F
  BCC @sub_100k  ; $E9D3: 90 0D  Value < 1,000,000, done clamping
  STA dividend_hi  ; $E9D5: 85 03
  LDA temp_lo  ; $E9D7: A5 04
  STA dividend_lo  ; $E9D9: 85 01
  LDA temp_mid  ; $E9DB: A5 05
  STA dividend_mid  ; $E9DD: 85 02
  JMP @clamp_million  ; $E9DF: 4C C2 E9

  ; Loop 2: Subtract 100,000 ($0186A0) -> hundred-thousands digit
@sub_100k:
  LDA dividend_lo  ; $E9E2: A5 01
  SEC  ; $E9E4: 38
  SBC #$A0  ; $E9E5: E9 A0
  STA temp_lo  ; $E9E7: 85 04
  LDA dividend_mid  ; $E9E9: A5 02
  SBC #$86  ; $E9EB: E9 86
  STA temp_mid  ; $E9ED: 85 05
  LDA dividend_hi  ; $E9EF: A5 03
  SBC #$01  ; $E9F1: E9 01
  BCC @sub_10k  ; $E9F3: 90 12
  STA dividend_hi  ; $E9F5: 85 03
  LDA temp_lo  ; $E9F7: A5 04
  STA dividend_lo  ; $E9F9: 85 01
  LDA temp_mid  ; $E9FB: A5 05
  STA dividend_mid  ; $E9FD: 85 02
  LDA bcd_htth_tth  ; $E9FF: A5 09
  ADC #$0F  ; $EA01: 69 0F  Add 1 to upper nibble (carry=1)
  STA bcd_htth_tth  ; $EA03: 85 09
  BNE @sub_100k  ; $EA05: D0 DB  Always loops

  ; Loop 3: Subtract 10,000 ($002710) -> ten-thousands digit
@sub_10k:
  LDA dividend_lo  ; $EA07: A5 01
  SEC  ; $EA09: 38
  SBC #$10  ; $EA0A: E9 10
  STA temp_lo  ; $EA0C: 85 04
  LDA dividend_mid  ; $EA0E: A5 02
  SBC #$27  ; $EA10: E9 27
  STA temp_mid  ; $EA12: 85 05
  LDA dividend_hi  ; $EA14: A5 03
  SBC #$00  ; $EA16: E9 00
  BCC @sub_1k  ; $EA18: 90 0E
  STA dividend_hi  ; $EA1A: 85 03
  LDA temp_lo  ; $EA1C: A5 04
  STA dividend_lo  ; $EA1E: 85 01
  LDA temp_mid  ; $EA20: A5 05
  STA dividend_mid  ; $EA22: 85 02
  INC bcd_htth_tth  ; $EA24: E6 09  Add 1 to lower nibble
  BNE @sub_10k  ; $EA26: D0 DF  Always loops

  ; Loop 4: Subtract 1,000 ($03E8) -> thousands digit
@sub_1k:
  LDA dividend_lo  ; $EA28: A5 01
  SEC  ; $EA2A: 38
  SBC #$E8  ; $EA2B: E9 E8
  STA temp_lo  ; $EA2D: 85 04
  LDA dividend_mid  ; $EA2F: A5 02
  SBC #$03  ; $EA31: E9 03
  BCC @sub_100  ; $EA33: 90 0E
  STA dividend_mid  ; $EA35: 85 02
  LDA temp_lo  ; $EA37: A5 04
  STA dividend_lo  ; $EA39: 85 01
  LDA bcd_thou_hund  ; $EA3B: A5 08
  ADC #$0F  ; $EA3D: 69 0F  Add 1 to upper nibble
  STA bcd_thou_hund  ; $EA3F: 85 08
  BNE @sub_1k  ; $EA41: D0 E5

  ; Loop 5: Subtract 100 ($64) -> hundreds digit
@sub_100:
  LDA dividend_lo  ; $EA43: A5 01
  SEC  ; $EA45: 38
  SBC #$64  ; $EA46: E9 64
  STA temp_lo  ; $EA48: 85 04
  LDA dividend_mid  ; $EA4A: A5 02
  SBC #$00  ; $EA4C: E9 00
  BCC @sub_10  ; $EA4E: 90 0A
  STA dividend_mid  ; $EA50: 85 02
  LDA temp_lo  ; $EA52: A5 04
  STA dividend_lo  ; $EA54: 85 01
  INC bcd_thou_hund  ; $EA56: E6 08  Add 1 to lower nibble
  BNE @sub_100  ; $EA58: D0 E9

  ; Loop 6: Subtract 10 ($0A) -> tens digit
@sub_10:
  LDA dividend_lo  ; $EA5A: A5 01
  SEC  ; $EA5C: 38
  SBC #$0A  ; $EA5D: E9 0A
  STA temp_lo  ; $EA5F: 85 04
  LDA dividend_mid  ; $EA61: A5 02
  SBC #$00  ; $EA63: E9 00
  BCC @final  ; $EA65: 90 0E
  STA dividend_mid  ; $EA67: 85 02
  LDA temp_lo  ; $EA69: A5 04
  STA dividend_lo  ; $EA6B: 85 01
  LDA bcd_tens_ones  ; $EA6D: A5 07
  ADC #$0F  ; $EA6F: 69 0F  Add 1 to upper nibble
  STA bcd_tens_ones  ; $EA71: 85 07
  BNE @sub_10  ; $EA73: D0 E5

  ; Final: Combine ones digit (remainder)
@final:
  LDA dividend_lo  ; $EA75: A5 01
  ORA bcd_tens_ones  ; $EA77: 05 07  Merge into lower nibble
  STA bcd_tens_ones  ; $EA79: 85 07  $07 = (tens << 4) | ones
  RTS  ; $EA7B: 60
.endproc

;===============================================================================
; $EA7C: Math - 16-bit Unsigned Division
; Input: $01/$02 = dividend, $03/$04 = divisor (16-bit LE)
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

  LDA #$00  ; $EA7C: A9 00
  STA remainder_lo  ; $EA7E: 85 05
  STA remainder_hi  ; $EA80: 85 06
  LDY #$0F  ; $EA82: A0 0F  16 iterations
@loop:
  ASL dividend_lo  ; $EA84: 06 01  Shift dividend, MSB -> carry
  ROL dividend_hi  ; $EA86: 26 02
  ROL remainder_lo  ; $EA88: 26 05  Carry -> remainder
  ROL remainder_hi  ; $EA8A: 26 06
  LDA remainder_lo  ; $EA8C: A5 05  Trial subtraction
  SEC  ; $EA8E: 38
  SBC divisor_lo  ; $EA8F: E5 03
  STA temp  ; $EA91: 85 07
  LDA remainder_hi  ; $EA93: A5 06
  SBC divisor_hi  ; $EA95: E5 04
  BCC @skip  ; $EA97: 90 08  Remainder < divisor
  STA remainder_hi  ; $EA99: 85 06  Commit subtraction
  LDA temp  ; $EA9B: A5 07
  STA remainder_lo  ; $EA9D: 85 05
  INC dividend_lo  ; $EA9F: E6 01  Set quotient bit
@skip:
  DEY  ; $EAA1: 88
  BPL @loop  ; $EAA2: 10 E0
  RTS  ; $EAA4: 60
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

  LDA #$00  ; $EAA5: A9 00
  STA remainder_b0  ; $EAA7: 85 05
  STA remainder_b1  ; $EAA9: 85 06
  STA remainder_b2  ; $EAAB: 85 07
  LDY #$17  ; $EAAD: A0 17  24 iterations
@loop:
  ASL dividend_b0  ; $EAAF: 06 00  Shift dividend
  ROL dividend_b1  ; $EAB1: 26 01
  ROL dividend_b2  ; $EAB3: 26 02
  ROL remainder_b0  ; $EAB5: 26 05  Carry -> remainder
  ROL remainder_b1  ; $EAB7: 26 06
  ROL remainder_b2  ; $EAB9: 26 07
  LDA remainder_b0  ; $EABB: A5 05  Trial subtraction
  SEC  ; $EABD: 38
  SBC divisor_lo  ; $EABE: E5 03
  STA temp_b0  ; $EAC0: 85 08
  LDA remainder_b1  ; $EAC2: A5 06
  SBC divisor_hi  ; $EAC4: E5 04
  STA temp_b1  ; $EAC6: 85 09
  LDA remainder_b2  ; $EAC8: A5 07
  SBC #$00  ; $EACA: E9 00  Propagate borrow
  BCC @skip  ; $EACC: 90 0C
  STA remainder_b2  ; $EACE: 85 07
  LDA temp_b0  ; $EAD0: A5 08
  STA remainder_b0  ; $EAD2: 85 05
  LDA temp_b1  ; $EAD4: A5 09
  STA remainder_b1  ; $EAD6: 85 06
  INC dividend_b0  ; $EAD8: E6 00  Set quotient bit
@skip:
  DEY  ; $EADA: 88
  BPL @loop  ; $EADB: 10 D2
  RTS  ; $EADD: 60
.endproc

;===============================================================================
; $EADE: Callback Dispatcher
; Input: A = index, Y = parameter for target
; Inline pointer table follows JSR
;===============================================================================
.proc CallbackDispatcher
param         = $00
ret_addr_lo   = $01
ret_addr_hi   = $02
target_lo     = $03
target_hi     = $04

  STY param  ; $EADE: 84 00
  ASL  ; $EAE0: 0A  A * 2 (word index)
  TAY  ; $EAE1: A8
  INY  ; $EAE2: C8  Compensate for JSR pushing PC+2
  PLA  ; $EAE3: 68  Pull return address low
  STA ret_addr_lo  ; $EAE4: 85 01
  PLA  ; $EAE6: 68  Pull return address high
  STA ret_addr_hi  ; $EAE7: 85 02
  LDA (ret_addr_lo),Y  ; $EAE9: B1 01  Read pointer low
  STA target_lo  ; $EAEB: 85 03
  INY  ; $EAED: C8
  LDA (ret_addr_lo),Y  ; $EAEE: B1 01  Read pointer high
  STA target_hi  ; $EAF0: 85 04
  LDY param  ; $EAF2: A4 00  Restore Y
  JMP (target_lo)  ; $EAF4: 6C 03 00  Jump to target function
.endproc

;===============================================================================
; $EAF7: Scroll Set - PPU scroll register write
;===============================================================================
.proc ScrollSet
  LDA $009A  ; $EAF7: AD 8E 00
  STA PPU_SCROLL  ; $EAFA: 8D 05 20
  LDA $009B  ; $EAFD: AD 90 00
  STA PPU_SCROLL  ; $EB00: 8D 05 20
  RTS  ; $EB03
.endproc

;===============================================================================
; $EB03: PPU Ctrl Nametable Bit Update
;===============================================================================
.proc PpuCtrlNametableUpdate
  LDA addr_ppu_ctrl_ram  ; $EB03: AD 8B 00
  AND #$FC  ; $EB06: 29 FE  Clear nametable bits
  ORA $0096  ; $EB08  Set from $0096
  STA addr_ppu_ctrl_ram  ; $EB0A
  STA PPU_CTRL  ; $EB0C
  RTS  ; $EB0F
.endproc

;===============================================================================
; $EB1A: Window Reset
;===============================================================================
.proc WindowReset
  LDA #$00  ; $EB1A: A9 02
  STA PPU_SCROLL  ; $EB1C: 8D 06 20
  STA PPU_SCROLL  ; $EB1F
  STA $009A  ; $EB22
  STA $009B  ; $EB24
  RTS  ; $EB26
.endproc

;===============================================================================
; $EB2D: Math - BCD to Binary
; Input: $0A/$0B/$0C = 6 packed BCD digits
; Output: $0D/$0E/$0F = 24-bit binary value
;===============================================================================
.proc MathBcdToBin
bcd_tens_ones    = $0A
bcd_thou_hund    = $0B
bcd_htth_tth     = $0C
result_b0        = $0D
result_b1        = $0E
result_b2        = $0F
mul_lo           = $00
mul_mid          = $01
mul_hi           = $02
mul_multiplier   = $03
accum_b0         = $0D
accum_b1         = $0E
accum_b2         = $0F

  LDA #$00  ; $EB2D: A9 00
  STA result_b1  ; $EB2F: 85 0E
  STA result_b2  ; $EB31: 85 0F

  ; Digit 0: Ones (lower nibble of $0A) x 1
  LDA bcd_tens_ones  ; $EB33: A5 0A
  PHA  ; $EB35: 48  Save for upper nibble
  AND #$0F  ; $EB36: 29 0F  Extract ones
  STA result_b0  ; $EB38: 85 0D  Directly store (x 1)

  ; Digit 1: Tens (upper nibble of $0A) x 10
  PLA  ; $EB3A: 68
  JSR MathExtractUpperNibble  ; $EB3B: 20 B1 EB
  STA mul_multiplier  ; $EB3E: 85 03
  LDA #$0A  ; $EB40: A9 0A  10
  STA mul_lo  ; $EB42: 85 00
  LDA #$00  ; $EB44: A9 00
  STA mul_mid  ; $EB46: 85 01
  STA mul_hi  ; $EB48: 85 02
  JSR MathMul24x8  ; $EB4A: 20 E9 EB
  JSR MathAccumulate24  ; $EB4D: 20 B6 EB

  ; Digit 2: Hundreds (lower nibble of $0B) x 100
  LDA bcd_thou_hund  ; $EB50: A5 0B
  PHA  ; $EB52: 48
  AND #$0F  ; $EB53: 29 0F
  STA mul_multiplier  ; $EB55: 85 03
  LDA #$64  ; $EB57: A9 64  100
  STA mul_lo  ; $EB59: 85 00
  LDA #$00  ; $EB5B: A9 00
  STA mul_mid  ; $EB5D: 85 01
  STA mul_hi  ; $EB5F: 85 02
  JSR MathMul24x8  ; $EB61: 20 E9 EB
  JSR MathAccumulate24  ; $EB64: 20 B6 EB

  ; Digit 3: Thousands (upper nibble of $0B) x 1,000
  PLA  ; $EB67: 68
  JSR MathExtractUpperNibble  ; $EB68: 20 B1 EB
  STA mul_multiplier  ; $EB6B: 85 03
  LDA #$E8  ; $EB6D: A9 E8  1000 ($03E8)
  STA mul_lo  ; $EB6F: 85 00
  LDA #$03  ; $EB71: A9 03
  STA mul_mid  ; $EB73: 85 01
  LDA #$00  ; $EB75: A9 00
  STA mul_hi  ; $EB77: 85 02
  JSR MathMul24x8  ; $EB79: 20 E9 EB
  JSR MathAccumulate24  ; $EB7C: 20 B6 EB

  ; Digit 4: Ten-thousands (lower nibble of $0C) x 10,000
  LDA bcd_htth_tth  ; $EB7F: A5 0C
  PHA  ; $EB81: 48
  AND #$0F  ; $EB82: 29 0F
  STA mul_multiplier  ; $EB84: 85 03
  LDA #$10  ; $EB86: A9 10  10000 ($2710)
  STA mul_lo  ; $EB88: 85 00
  LDA #$27  ; $EB8A: A9 27
  STA mul_mid  ; $EB8C: 85 01
  LDA #$00  ; $EB8E: A9 00
  STA mul_hi  ; $EB90: 85 02
  JSR MathMul24x8  ; $EB92: 20 E9 EB
  JSR MathAccumulate24  ; $EB95: 20 B6 EB

  ; Digit 5: Hundred-thousands (upper nibble of $0C) x 100,000
  PLA  ; $EB98: 68
  JSR MathExtractUpperNibble  ; $EB99: 20 B1 EB
  STA mul_multiplier  ; $EB9C: 85 03
  LDA #$A0  ; $EB9E: A9 A0  100000 ($0186A0)
  STA mul_lo  ; $EBA0: 85 00
  LDA #$86  ; $EBA2: A9 86
  STA mul_mid  ; $EBA4: 85 01
  LDA #$01  ; $EBA6: A9 01
  STA mul_hi  ; $EBA8: 85 02
  JSR MathMul24x8  ; $EBAA: 20 E9 EB
  JSR MathAccumulate24  ; $EBAD: 20 B6 EB
  RTS  ; $EBB0: 60
.endproc

;===============================================================================
; $EBB1: Math - Extract Upper Nibble
; Input: A = packed byte, Output: A = upper nibble in lower position
;===============================================================================
.proc MathExtractUpperNibble
  LSR  ; $EBB1: 4A
  LSR  ; $EBB2: 4A
  LSR  ; $EBB3: 4A
  LSR  ; $EBB4: 4A
  RTS  ; $EBB5: 60
.endproc

;===============================================================================
; $EBB6: Math - 24-bit Accumulate Add
; $0D/$0E/$0F += $06/$07/$08
;===============================================================================
.proc MathAccumulate24
  LDA $06  ; $EBB6: A5 06
  CLC  ; $EBB8: 18
  ADC $0D  ; $EBB9: 65 0D
  STA $0D  ; $EBBB: 85 0D
  LDA $07  ; $EBBD: A5 07
  ADC $0E  ; $EBBF: 65 0E
  STA $0E  ; $EBC1: 85 0E
  LDA $08  ; $EBC3: A5 08
  ADC $0F  ; $EBC5: 65 0F
  STA $0F  ; $EBC7: 85 0F
  RTS  ; $EBC9: 60
.endproc

;===============================================================================
; $EBCA: Math - Multiply then Divide by 100
; Input: $00/$01 = 16-bit value, $03 = 8-bit multiplier
; Output: $00/$01/$02 = quotient, $05/$06/$07 = remainder (mod 100)
;===============================================================================
.proc MathMulDiv100
  LDA #$00  ; $EBCA: A9 00
  STA $02  ; $EBCC: 85 02  Clear high byte for 24-bit multiplicand
  JSR MathMul24x8  ; $EBCE: 20 E9 EB
  LDA $06  ; $EBD1: A5 06  Product -> dividend
  STA $00  ; $EBD3: 85 00
  LDA $07  ; $EBD5: A5 07
  STA $01  ; $EBD7: 85 01
  LDA $08  ; $EBD9: A5 08
  STA $02  ; $EBDB: 85 02
  LDA #$64  ; $EBDD: A9 64  Divisor = 100
  STA $03  ; $EBDF: 85 03
  LDA #$00  ; $EBE1: A9 00
  STA $04  ; $EBE3: 85 04
  JSR MathDiv24  ; $EBE5: 20 A5 EA  24-bit divide by 100
  RTS  ; $EBE8: 60
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
multiplier      = $03
extension       = $04
product_b0      = $06
product_b1      = $07
product_b2      = $08
product_b3      = $09

  LDY #$07  ; $EBE9: A0 07  8 iterations
  LDA #$00  ; $EBEB: A9 00
  STA extension  ; $EBED: 85 04
  STA product_b0  ; $EBEF: 85 05
  STA product_b1  ; $EBF1: 85 06
  STA product_b2  ; $EBF3: 85 07
  STA product_b3  ; $EBF5: 85 08
@loop:
  LSR multiplier  ; $EBF7  Shift multiplier right, LSB -> carry
  BCC @skip_add  ; $EBF9
  LDA multiplicand_b0  ; $EBFB  Add multiplicand to result
  CLC  ; $EBFD
  ADC product_b0  ; $EBFE
  STA product_b0  ; $EC00
  LDA multiplicand_b1  ; $EC02
  ADC product_b1  ; $EC04
  STA product_b1  ; $EC06
  LDA multiplicand_b2  ; $EC08
  ADC product_b2  ; $EC0A
  STA product_b2  ; $EC0C
  LDA extension  ; $EC0E
  ADC product_b3  ; $EC10
  STA product_b3  ; $EC12
@skip_add:
  ASL multiplicand_b0  ; $EC14  Shift multiplicand left
  ROL multiplicand_b1  ; $EC16
  ROL multiplicand_b2  ; $EC18: 26 01
  ROL extension  ; $EC1A: 26 02
  DEY  ; $EC1C
  BPL @loop  ; $EC1D
  RTS  ; $EC1F
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
ext_b0          = $0B
ext_b1          = $0C
product_b0      = $06
product_b1      = $07
product_b2      = $08
product_b3      = $09
product_b4      = $0A

  LDY #$0F  ; $EC22: A0 0F  16 iterations
  LDA #$00  ; $EC24: A9 00
  STA product_b0  ; $EC26: 85 06
  STA product_b1  ; $EC28: 85 07
  STA product_b2  ; $EC2A: 85 08
  STA product_b3  ; $EC2C: 85 09
  STA product_b4  ; $EC2E: 85 0A
  STA ext_b0  ; $EC30: 85 0B
  STA ext_b1  ; $EC32: 85 0C
@loop:
  LSR multiplier_hi  ; $EC34: 46 04  Shift 16-bit multiplier right
  ROR multiplier_lo  ; $EC36: 66 03
  BCC @skip_add  ; $EC38: 90 1F
  LDA multiplicand_b0  ; $EC3A: A5 00  Add multiplicand to result
  CLC  ; $EC3C: 18
  ADC product_b0  ; $EC3D: 65 06
  STA product_b0  ; $EC3F: 85 06
  LDA multiplicand_b1  ; $EC41: A5 01
  ADC product_b1  ; $EC43: 65 07
  STA product_b1  ; $EC45: 85 07
  LDA multiplicand_b2  ; $EC47: A5 02
  ADC product_b2  ; $EC49: 65 08
  STA product_b2  ; $EC4B: 85 08
  LDA ext_b0  ; $EC4D: A5 0B
  ADC product_b3  ; $EC4F: 65 09
  STA product_b3  ; $EC51: 85 09
  LDA ext_b1  ; $EC53: A5 0C
  ADC product_b4  ; $EC55: 65 0A
  STA product_b4  ; $EC57: 85 0A
@skip_add:
  ASL multiplicand_b0  ; $EC59: 06 00  Shift multiplicand left
  ROL multiplicand_b1  ; $EC5B: 26 01
  ROL multiplicand_b2  ; $EC5D: 26 02
  ROL ext_b0  ; $EC5F: 26 0B
  ROL ext_b1  ; $EC61: 26 0C
  DEY  ; $EC63: 88
  BPL @loop  ; $EC64: 10 CE
  RTS  ; $EC66: 60
.endproc

;===============================================================================
; $EC67: Palette Animation
; Color rotation with frame counter
;===============================================================================
.proc PaletteAnimation
frame_counter_lo = $0087
frame_counter_hi = $0088
anim_ctrl        = $0089

  LDA frame_counter_lo  ; $EC67: AD 87 00
  CLC  ; $EC6A
  ADC #$01  ; $EC6B
  STA frame_counter_lo  ; $EC6D
  LDA frame_counter_hi  ; $EC6F
  ADC #$00  ; $EC71
  STA frame_counter_hi  ; $EC73
  LDA anim_ctrl  ; $EC75
  BEQ PaletteAnimation_done  ; $EC77
  LSR  ; $EC79
  BCC @shift_right  ; $EC7A
  ; Shift left
  LDX $0100  ; $EC7C
  LDA $0101  ; $EC7F
  STA $0100  ; $EC82
  LDA $0102  ; $EC85
  STA $0101  ; $EC88
  LDA $0103  ; $EC8B
  STA $0102  ; $EC8E
  STX $0103  ; $EC91
  JMP PaletteAnimation_done  ; $EC94
@shift_right:
  ; Shift right
  LDX $0103  ; $EC97
  LDA $0102  ; $EC9A
  STA $0103  ; $EC9D
  LDA $0101  ; $ECA0: A9 20
  STA $0102  ; $ECA2: 85 02
  LDA $0100  ; $ECA4: A9 01
  STA $0101  ; $ECA6: 85 03
  STX $0100  ; $ECA8
PaletteAnimation_done:
  RTS  ; $ECAB
.endproc

;===============================================================================
; $ED19: Menu Cursor System (8 Entry Points)
; Entry points: $ED19=step1, $ED1E=step2, ..., $ED3C=step8
; Params: $10/$11 = data table pointer
; Output: $12 = current item value
;===============================================================================
.proc MenuCursorSystem
MenuStep1:
  LDA #$01  ; $ED19: A9 01
  JMP MenuMain  ; $ED1B: 4C 41 ED
MenuStep2:
  LDA #$02  ; $ED1E: A9 02
  JMP MenuMain  ; $ED20: 4C 41 ED
MenuStep3:
  LDA #$03  ; $ED23: A9 03
  JMP MenuMain  ; $ED25: 4C 41 ED
MenuStep4:
  LDA #$04  ; $ED28: A9 04
  JMP MenuMain  ; $ED2A: 4C 41 ED
MenuStep5:
  LDA #$05  ; $ED2D: A9 05
  JMP MenuMain  ; $ED2F: 4C 41 ED
MenuStep6:
  LDA #$06  ; $ED32: A9 06
  JMP MenuMain  ; $ED34: 4C 41 ED
MenuStep7:
  LDA #$07  ; $ED37: A9 07
  JMP MenuMain  ; $ED39: 4C 41 ED
MenuStep8:
  LDA #$08  ; $ED3C: A9 08
MenuMain:
  STA addr_menu_step  ; $ED3E
  LDA addr_pad1_edge  ; $ED40
  AND #$80  ; $ED42  Right pressed?
  BEQ @check_left  ; $ED44
  JSR @cursor_right  ; $ED46
@check_left:
  LDA addr_pad1_edge  ; $ED49
  AND #$40  ; $ED4B  Left pressed?
  BEQ @check_down  ; $ED4D
  JSR @cursor_left  ; $ED4F
@check_down:
  LDA addr_pad1_edge  ; $ED52
  AND #$20  ; $ED54  Down pressed?
  BEQ @check_up  ; $ED56
  JSR @cursor_down  ; $ED58
@check_up:
  LDA addr_pad1_edge  ; $ED5B
  AND #$10  ; $ED5D  Up pressed?
  BEQ @lookup  ; $ED5F
  JSR @cursor_up  ; $ED61
@lookup:
  JSR MenuItemLookup  ; $ED64
  STA addr_menu_result  ; $ED67
  RTS  ; $ED69

@cursor_right:
  INC addr_menu_column  ; $ED6A
  JSR MenuItemLookup  ; $ED6D
  BMI @right_clamp  ; $ED70
  LDA addr_menu_column  ; $ED72
  CMP addr_menu_step  ; $ED75: DD ED 30
  BCC @right_done  ; $ED78
@right_clamp:
  DEC addr_menu_column  ; $ED7A
  LDA addr_menu_result  ; $ED7D
  BNE @right_done  ; $ED7F
  LDA #$00  ; $ED81
  STA addr_menu_column  ; $ED83
@right_done:
  RTS  ; $ED86

@cursor_left:
  DEC addr_menu_column  ; $ED87
  BPL @left_done  ; $ED8A
  INC addr_menu_column  ; $ED8C
  LDA addr_menu_result  ; $ED8F
  BNE @left_done  ; $ED91
  LDA addr_menu_step  ; $ED93
  STA addr_menu_column  ; $ED95
  DEC addr_menu_column  ; $ED98
@left_scan:
  JSR MenuItemLookup  ; $ED9B
  CMP #$FF  ; $ED9E
  BEQ @left_scan_back  ; $EDA0
  RTS  ; $EDA2
@left_scan_back:
  DEC addr_menu_column  ; $EDA3
  JMP @left_scan  ; $EDA6
@left_done:
  RTS  ; $EDA9

@cursor_down:
  INC addr_menu_page  ; $EDAA
  JSR MenuItemLookup  ; $EDAD
  BPL @down_done  ; $EDB0
  DEC addr_menu_page  ; $EDB2
  LDA addr_menu_result  ; $EDB5
  BNE @down_done  ; $EDB7
  LDA #$00  ; $EDB9
  STA addr_menu_page  ; $EDBB
@down_done:
  RTS  ; $EDBE

@cursor_up:
  DEC addr_menu_page  ; $EDBF
  BPL @up_done  ; $EDC2
  INC addr_menu_page  ; $EDC4
  LDA addr_menu_result  ; $EDC7
  BNE @up_done  ; $EDC9
  LDX #$FF  ; $EDCB
  LDY addr_menu_column  ; $EDCD
@up_count:
  INX  ; $EDD0
  TYA  ; $EDD1
  CLC  ; $EDD2
  ADC addr_menu_step  ; $EDD3
  TAY  ; $EDD5
  LDA (addr_menu_ptr_lo),Y  ; $EDD6
  BPL @up_count  ; $EDD8
  STX addr_menu_page  ; $EDDA
@up_done:
  RTS  ; $EDDD
.endproc

;===============================================================================
; $EDDD: Menu Item Lookup
; Formula: Y = page * step_size + column, A = (ptr),Y
;===============================================================================
.proc MenuItemLookup
  LDA #$00  ; $EDDD: A9 00
  LDY addr_menu_page  ; $EDDF: AC 25 04
@mul_loop:
  CPY #$00  ; $EDE2: C0 00
  BEQ @add_column  ; $EDE4: F0 07
  CLC  ; $EDE6: 18
  ADC addr_menu_step  ; $EDE7: 65 00
  DEY  ; $EDE9: 88
  JMP @mul_loop  ; $EDEA: 4C E2 ED
@add_column:
  CLC  ; $EDED: 18
  ADC addr_menu_column  ; $EDEE: 6D 24 04
  TAY  ; $EDF1: A8
  LDA (addr_menu_ptr_lo),Y  ; $EDF2: B1 10
  RTS  ; $EDF4: 60
.endproc

;===============================================================================
; $EDF5: Pointer Table Lookup
; Input: A = entry index, ($10) = pointer table
; Output: $0A = ptr low, $0C = ptr high, JMP $F1AD
;===============================================================================
.proc PointerTableLookup
ptr_lo       = $0A
ptr_hi       = $0C
flag         = $02

  ASL  ; $EDF5: 0A  A * 2 (word index)
  TAY  ; $EDF6: A8
  LDA (addr_menu_ptr_lo),Y  ; $EDF7: B1 10  lo byte
  STA ptr_lo  ; $EDF9: 85 0A
  INY  ; $EDFB: C8
  LDA (addr_menu_ptr_lo),Y  ; $EDFC: B1 10  hi byte
  STA ptr_hi  ; $EDFE: 85 0C
  LDA #$00  ; $EE00: A9 00
  STA flag  ; $EE02: 85 02
  JMP SpriteOamWriterSimple  ; $EE04: 4C AD F1  -> sprite OAM writer
.endproc

;===============================================================================
; $EE07: Banked Callback Trampoline
; Calling: LDY #bank_number; JSR BankedCallbackTrampoline; .word target_addr
;===============================================================================
.proc BankedCallbackTrampoline
  LDA addr_bank_e7  ; $EE07: AD E2 00  Save current PRG bank
  STA addr_trampoline_saved_bank  ; $EE0A: 8D 58 00
  STY addr_trampoline_bank_param  ; $EE0D: 8C 5D 00
  PLA  ; $EE10: 68  Pop return address
  CLC  ; $EE11: 18
  ADC #$01  ; $EE12: 69 01  +1 -> points to inline data
  STA addr_trampoline_ret_lo  ; $EE14: 8D 59 00
  PLA  ; $EE17: 68
  ADC #$00  ; $EE18: 69 00
  STA addr_trampoline_ret_hi  ; $EE1A: 8D 5A 00
  LDY #$00  ; $EE1D: A0 00
  LDA (addr_trampoline_ret_lo),Y  ; $EE1F: B1 59
  STA addr_trampoline_target_lo  ; $EE21: 8D 5B 00
  INY  ; $EE24: C8
  LDA (addr_trampoline_ret_lo),Y  ; $EE25: B1 59
  STA addr_trampoline_target_hi  ; $EE27: 8D 5C 00
  LDY addr_trampoline_bank_param  ; $EE2A: AC 5D 00
  JSR WindowDisplaySetup  ; $EE2D: 20 37 F2  Switch PRG banks
  INC addr_trampoline_ret_lo  ; $EE30: EE 59 00
  BNE @push_hi  ; $EE33: D0 03
  INC addr_trampoline_ret_hi  ; $EE35: EE 5A 00
@push_hi:
  LDA addr_trampoline_ret_hi  ; $EE38: AD 5A 00
  PHA  ; $EE3B: 48
  LDA addr_trampoline_ret_lo  ; $EE3C: AD 59 00
  PHA  ; $EE3F: 48
  LDA addr_trampoline_saved_bank  ; $EE40: AD 58 00
  PHA  ; $EE43: 48
  LDA #>BankedCallbackReturn  ; $EE44: A9 EE
  PHA  ; $EE46: 48
  LDA #<BankedCallbackReturn  ; $EE47: A9 4C
  PHA  ; $EE49: 48
  JMP (addr_trampoline_target_lo)  ; $EE4A: 6C 5B 00
.endproc

;===============================================================================
; $EE4D: Banked Callback Return Stub
;===============================================================================
.proc BankedCallbackReturn
  PLA  ; $EE4D: 68
  TAY  ; $EE4E: A8
  JSR WindowDisplaySetup  ; $EE4F: 20 37 F2  Restore original PRG banks
  RTS  ; $EE52: 60
.endproc

;===============================================================================
; $EE53: NMI Sub-Dispatch
; Tests bits of $007E, calls PPU writers
;===============================================================================
.proc NmiSubDispatch
  BIT addr_nmi_flag  ; $EE53
  BPL @skip_bg  ; $EE55
  JSR PpuBgTileWrite  ; $EE57
@skip_bg:
  LDA addr_nmi_flag  ; $EE5A
  AND #$40  ; $EE5C
  BEQ @skip_sprite  ; $EE5E
  JSR PpuSpriteTileWrite  ; $EE60
@skip_sprite:
  LDA addr_nmi_flag  ; $EE63
  AND #$20  ; $EE65: 3D 0A 30
  BEQ @skip_attr  ; $EE68
  JSR PpuAttrTileWrite  ; $EE6A
@skip_attr:
  LDA addr_nmi_flag  ; $EE6D
  AND #$10  ; $EE6F
  BEQ @skip_attr_alt  ; $EE71
  JSR PpuAttrTileWriteAlt  ; $EE73
@skip_attr_alt:
  RTS  ; $EE76
.endproc

;===============================================================================
; $EF0B: PPU BG Tile Write
; Writes tiles from buffer to PPU via $2006/$2007
;===============================================================================
.proc PpuBgTileWrite
  BIT addr_nmi_flag  ; $EF0B
  BVC PpuBgTileWrite_done  ; $EF0D
  LDA $2002  ; $EF0F
  LDA $0140  ; $EF12
  STA PPU_ADDR  ; $EF15
  LDA $0141  ; $EF18
  STA PPU_ADDR  ; $EF1B
  LDY #$00  ; $EF1E
@write_loop:
  LDA $0142,Y  ; $EF20
  STA PPU_DATA  ; $EF23
  INY  ; $EF26
  CPY $0140+2  ; $EF27
  BNE @write_loop  ; $EF2A
PpuBgTileWrite_done:
  RTS  ; $EF2C
.endproc

;===============================================================================
; $EF71: PPU Sprite Tile Write
;===============================================================================
.proc PpuSpriteTileWrite
  LDA $2002  ; $EF71: AD 8B 00
  LDA $0164  ; $EF74
  STA PPU_ADDR  ; $EF77
  LDA $0165  ; $EF7A
  STA PPU_ADDR  ; $EF7D
  LDY #$00  ; $EF80
@write_loop:
  LDA $0166,Y  ; $EF82: AD 65 01
  STA PPU_DATA  ; $EF85: 8D 06 20
  INY  ; $EF88
  CPY #$40  ; $EF89
  BNE @write_loop  ; $EF8B
  RTS  ; $EF8D
.endproc

;===============================================================================
; $EFC0: PPU Attribute Tile Write
;===============================================================================
.proc PpuAttrTileWrite
  LDA $2002  ; $EFC0: AD 89 01
  LDA $0188  ; $EFC3
  STA PPU_ADDR  ; $EFC6
  LDA $0189  ; $EFC9
  STA PPU_ADDR  ; $EFCC
  LDY #$00  ; $EFCF
@write_loop:
  LDA $018A,Y  ; $EFD1
  STA PPU_DATA  ; $EFD4: 8D 00 00
  INY  ; $EFD7
  CPY #$40  ; $EFD8
  BNE @write_loop  ; $EFDA
  RTS  ; $EFDC
.endproc

;===============================================================================
; $F028: PPU Attribute Tile Write (Alt)
;===============================================================================
.proc PpuAttrTileWriteAlt
  LDA $2002  ; $F028: AD 8B 00
  LDA $019C  ; $F02B
  STA PPU_ADDR  ; $F02E
  LDA $019D  ; $F031
  STA PPU_ADDR  ; $F034
  LDY #$00  ; $F037
@write_loop:
  LDA $019E,Y  ; $F039: AD 9D 01
  STA PPU_DATA  ; $F03C: 8D 06 20
  INY  ; $F03F
  CPY #$40  ; $F040
  BNE @write_loop  ; $F042
  RTS  ; $F044
.endproc

;===============================================================================
; $F077: Namco-163 Sound Register Read
; Reads $4800 via auto-increment
;===============================================================================
.proc NamcoSoundRegRead
  LDA NAMCO_CTRL  ; $F077: AD 9C 00
  AND #$40  ; $F07A
  BEQ NamcoSoundRegRead_done  ; $F07C
  LDX #$07  ; $F07E
@read_loop:
  LDA $4800,X  ; $F080
  STA $0700,X  ; $F083
  DEX  ; $F086
  BPL @read_loop  ; $F087
NamcoSoundRegRead_done:
  RTS  ; $F089
.endproc

;===============================================================================
; $F092: Sprite OAM Writer (Scroll)
; Converts sprite data with scroll offsets
;===============================================================================
.proc SpriteOamWriterScroll
  LDY #$00  ; $F092
  LDX #$00  ; $F094
@loop:
  LDA ($10),Y  ; $F096
  CMP #$FF  ; $F098
  BEQ SpriteOamWriterScroll_done  ; $F09A
  INY  ; $F09C
  LDA ($10),Y  ; $F09D
  SEC  ; $F09F
  SBC $009A  ; $F0A0  Apply scroll offset
  STA $0200,X  ; $F0A2
  INX  ; $F0A5
  INY  ; $F0A6
  LDA ($10),Y  ; $F0A7
  STA $0200,X  ; $F0A9
  INX  ; $F0AC
  INY  ; $F0AD
  LDA ($10),Y  ; $F0AE
  STA $0200,X  ; $F0B0: 8D 0A 00
  INX  ; $F0B3
  INY  ; $F0B4
  JMP @loop  ; $F0B5
SpriteOamWriterScroll_done:
  RTS  ; $F0B8
.endproc

;===============================================================================
; $F1AD: Sprite OAM Writer (Simple)
; Direct sprite placement
;===============================================================================
SpriteOamWriterSimple:
  ; Detailed implementation not yet fully analyzed
  RTS  ; $F1AD

;===============================================================================
; $F206: CHR Bank Switch
; Writes 8 values to $8000-$B800
;===============================================================================
.proc ChrBankSwitch
  LDX #$00  ; $F206
@switch_loop:
  LDA $00E2,X  ; $F208
  STA $F000,X  ; $F20A  CHR bank registers
  INX  ; $F20D
  CPX #$08  ; $F20E
  BNE @switch_loop  ; $F210
  RTS  ; $F212
.endproc

;===============================================================================
; $F237: Window/Display Setup
; Sets $00E2/$00E3, writes to $F000/$E800/$E000
; Params: Y = bank parameter
;===============================================================================
.proc WindowDisplaySetup
  STY $00E2  ; $F237: 8C E2 00
  LDA $00E3  ; $F23A
  STA $E800  ; $F23C
  LDA $00E2  ; $F23F
  STA $F000  ; $F241
  RTS  ; $F244
.endproc

;===============================================================================
; $F25F: Window Setup 2
; Params: Y = bank parameter
;===============================================================================
.proc WindowSetup2
  STY $00E3  ; $F25F: 8C E1 00
  RTS  ; $F262
.endproc

;===============================================================================
; $F266: Window Setup Helpers
;===============================================================================
.proc WindowSetupHelpers
  RTS  ; $F266
.endproc

;===============================================================================
; $F2AF: Get Hero Address
; Formula: hero_id * 32 + $6000
; Params: hero_id in A
; Output: $10/$11 = pointer to hero data
;===============================================================================
.proc GetHeroAddr
hero_id       = $00
hero_ptr_lo   = $10
hero_ptr_hi   = $11
HERO_SIZE     = 32
HERO_BASE_LO  = $00
HERO_BASE_HI  = $60

  STA hero_id  ; $F2AF
  ASL  ; $F2B1
  ASL  ; $F2B2
  ASL  ; $F2B3
  ASL  ; $F2B4: 0A
  ASL  ; $F2B5  id * 32
  CLC  ; $F2B6
  ADC #HERO_BASE_LO  ; $F2B7
  STA hero_ptr_lo  ; $F2B9
  LDA #$00  ; $F2BB
  ROL  ; $F2BD: 2E 01 00  Get high bit from shift
  ADC #HERO_BASE_HI  ; $F2C0
  STA hero_ptr_hi  ; $F2C2
  RTS  ; $F2C4
.endproc

;===============================================================================
; $F2D7: Get City Address
; Formula: city_id * 12 + $63C0
; Params: city_id in A
; Output: pointer to city data
;===============================================================================
.proc GetCityAddr
city_id       = $00
CITY_SIZE     = 12
CITY_BASE_LO  = $C0
CITY_BASE_HI  = $63

  STA city_id  ; $F2D7
  ASL  ; $F2D9  id * 2
  ADC city_id  ; $F2DA  id * 3
  ASL  ; $F2DC  id * 6
  ASL  ; $F2DD  id * 12
  CLC  ; $F2DE
  ADC #CITY_BASE_LO  ; $F2DF
  STA $10  ; $F2E1
  LDA #$00  ; $F2E3
  ROL  ; $F2E5
  ADC #CITY_BASE_HI  ; $F2E6
  STA $11  ; $F2E8
  RTS  ; $F2EA
.endproc

;===============================================================================
; $F308: Get Hero Kata Name
; Formula: id * 10 + $901A
; Params: id in A
; Output: pointer to kata name data
;===============================================================================
.proc GetHeroKataName
KATA_SIZE     = 10
KATA_BASE_LO  = $1A
KATA_BASE_HI  = $90

  STA $00  ; $F308: 8D 02 00
  ASL  ; $F30B  id * 2
  ADC $00  ; $F30C  id * 3
  ASL  ; $F30E  id * 6
  CLC  ; $F30F
  ADC $00  ; $F310  id * 7
  ASL  ; $F312  id * 14
  SEC  ; $F313
  SBC $00  ; $F314  id * 13
  SEC  ; $F316
  SBC $00  ; $F317  id * 12
  ; Actually: id * 10 = (id * 2) << 2 + id << 1
  ; Simplified: ASL, ADC, ASL*2, ADC...
  CLC  ; $F319
  ADC #KATA_BASE_LO  ; $F31A
  STA $10  ; $F31C
  LDA #$00  ; $F31E
  ADC #KATA_BASE_HI  ; $F320
  STA $11  ; $F322
  RTS  ; $F324
.endproc

;===============================================================================
; $F35F: Kata Name Width Table
;===============================================================================
KataNameWidthTable:
  .byte $08, $08, $08, $08, $08, $08, $08, $08

;===============================================================================
; $F368: Get Kingdom Address
; 7 entries, 8 bytes per kingdom, data at $6F07 (SRAM)
;===============================================================================
.proc GetKingdomAddr
kingdom_id    = $00
KINGDOM_SIZE  = 8

  LDA kingdom_id  ; $F368
  ASL  ; $F36A: 0A  id * 2
  ASL  ; $F36B  id * 4
  ASL  ; $F36C  id * 8
  TAY  ; $F36D
  LDA KingdomPtrTable,Y  ; $F36E
  STA $10  ; $F371
  LDA KingdomPtrTable+1,Y  ; $F373
  STA $11  ; $F376
  RTS  ; $F378: 60
.endproc

;===============================================================================
; $F379: Kingdom Pointer Table
;===============================================================================
KingdomPtrTable:
  .addr $6F07, $6F0F, $6F17, $6F1F, $6F27, $6F2F, $6F37

;===============================================================================
; $F387: Get Hero Initial Data
; Formula: hero_id * 12 + $8000
; Params: hero_id in A
;===============================================================================
.proc GetHeroInitialData
INIT_SIZE     = 12
INIT_BASE_LO  = $00
INIT_BASE_HI  = $80

  STA $00  ; $F387
  ASL  ; $F389  id * 2
  ADC $00  ; $F38A  id * 3
  ASL  ; $F38C  id * 6
  ASL  ; $F38D  id * 12
  CLC  ; $F38E
  ADC #INIT_BASE_LO  ; $F38F
  STA $10  ; $F391: 8D 00 00
  LDA #$00  ; $F394
  ROL  ; $F396
  ADC #INIT_BASE_HI  ; $F397
  STA $11  ; $F399
  RTS  ; $F39B
.endproc

;===============================================================================
; $F3BD: Mapper Init + Controller Check
;===============================================================================
.proc MapperInitCtrlCheck
  LDA #$00  ; $F3BD: A9 00
  STA $5000  ; $F3BF: 8D 00 50  CHR bank register
  STA $5800  ; $F3C2: 8D 00 58  CHR bank register
  LDA #$E0  ; $F3C5: A9 E0
  STA $C000  ; $F3C7: 8D 00 C0  PRG bank 0
  STA $D000  ; $F3CA: 8D 00 D0  PRG bank 0
  LDA #$E1  ; $F3CD: A9 E1
  STA $C800  ; $F3CF: 8D 00 C8  PRG bank 1
  STA $D800  ; $F3D2: 8D 00 D8  PRG bank 1

  ; Controller validation loop
  LDX #$00  ; $F3D5: A2 00
@ctrl_loop:
  LDA MapperInitCtrlCheck,X  ; $F3D7: BD BD F3  Read from self (data bytes)
  AND #$01  ; $F3DA: 29 01
  STA $0001  ; $F3DC: 8D 01 00
  STA APU_JOY1  ; $F3DF: 8D 16 40  Write to controller port
  LDA APU_JOY2  ; $F3E2: AD 17 40  Read controller port 2
  LSR  ; $F3E5: 4A
  EOR #$FF  ; $F3E6: 49 FF
  AND #$01  ; $F3E8: 29 01
  CMP $0001  ; $F3EA: CD 01 00
  BNE @ctrl_fail  ; $F3ED: D0 32
  INX  ; $F3EF: E8
  CPX #$46  ; $F3F0: E0 46  70 iterations
  BNE @ctrl_loop  ; $F3F2: D0 E3
@ctrl_fail:
  RTS  ; $F3F4
.endproc

;===============================================================================
; $F422: RAM Integrity Test
; Write/verify $AA pattern
;===============================================================================
.proc RamIntegrityTest
  LDA #$AA  ; $F422
  STA $0000  ; $F424
@write_loop:
  LDA $0000  ; $F426
  STA ($00),Y  ; $F428
  INY  ; $F42A
  BNE @write_loop  ; $F42B
  INC $01  ; $F42D
  LDA $01  ; $F42F
  CMP #$08  ; $F431
  BCC @write_loop  ; $F433
  ; Verify
  LDA #$00  ; $F435: AD 03 00
  STA $01  ; $F438
  LDY #$00  ; $F43A
@verify_loop:
  LDA ($00),Y  ; $F43C: A9 00
  CMP #$AA  ; $F43E
  BNE @fail  ; $F440
  INY  ; $F442
  BNE @verify_loop  ; $F443
  INC $01  ; $F445
  LDA $01  ; $F447
  CMP #$08  ; $F449
  BCC @verify_loop  ; $F44B
@fail:
  RTS  ; $F44D
.endproc

;===============================================================================
; $F477: Sound/Music Data (512 bytes)
;===============================================================================
SoundMusicData:
  .incbin "rom/prg/prg_1f.bin", $477, $200

;===============================================================================
; $F677: Padding ($FF fill)
;===============================================================================
Padding1:
  .res $F7FF - $F677, $FF

;===============================================================================
; $F800: NMI Handler
; Entry: saves registers, CHR setup, scroll, OAM DMA, sub-dispatch
; Sub-states dispatched by $0078 AND #$0F
;===============================================================================
.proc NmiHandler
  PHA  ; $F800: 48
  TXA  ; $F801: 8A
  PHA  ; $F802: 48
  TYA  ; $F803: 98
  PHA  ; $F804: 48

  ; Read PPU status
  LDA PPU_STATUS  ; $F805: AD 02 20

  ; CHR bank setup
  LDA $00E2  ; $F808: A9 00
  STA $E800  ; $F80A: 8D 00 58
  LDA $00E3  ; $F80D: AD 68 00
  STA $F000  ; $F810: 8D 00 50

  ; Scroll
  LDA $009A  ; $F813: AD 69 00
  STA PPU_SCROLL  ; $F816: 8D 00 58
  LDA $009B  ; $F819
  STA PPU_SCROLL  ; $F81B

  ; OAM DMA
  LDA #$02  ; $F81E
  STA APU_OAM_DMA  ; $F820

  ; Sub-dispatch by $0078 AND #$0F
  LDA addr_sub_state  ; $F823: A9 E0
  AND #$0F  ; $F825
  ASL  ; $F827
  TAY  ; $F828
  LDA NmiSubDispatchTable,Y  ; $F829
  STA $004E  ; $F82C
  LDA NmiSubDispatchTable+1,Y  ; $F82E
  STA $004F  ; $F831
  JMP ($004E)  ; $F833

NmiSubDispatchTable:
  .addr NmiSubState0, NmiSubState1, NmiSubState2, NmiSubState3
  .addr NmiSubState4, NmiSubState5, NmiSubState6, NmiSubState7

NmiSubState0:
  ; Main game frame: process input, display, scroll
  JSR NmiSubDispatch  ; $F846
  JMP NmiHandler_nmi_post  ; $F849

NmiSubState1:
  ; Kingdom select frame
  JSR NmiSubDispatch  ; $F84C
  JMP NmiHandler_nmi_post  ; $F84F

NmiSubState2:
  ; Map view frame
  JSR NmiSubDispatch  ; $F852
  JMP NmiHandler_nmi_post  ; $F855

NmiSubState3:
  ; Domestic affairs frame
  JSR NmiSubDispatch  ; $F858
  JMP NmiHandler_nmi_post  ; $F85B

NmiSubState4:
  ; Simple display frame
  JSR NmiSubDispatch  ; $F85E
  JMP NmiHandler_nmi_post  ; $F861

NmiSubState5:
  ; Battle frame
  JSR NmiSubDispatch  ; $F864
  JMP NmiHandler_nmi_post  ; $F867

NmiSubState6:
  ; Advisor frame
  JSR NmiSubDispatch  ; $F86A
  JMP NmiHandler_nmi_post  ; $F86D

NmiSubState7:
  ; Minimal frame

NmiHandler_nmi_post:
  ; Restore banks, inc RNG counters
  LDA addr_bank_e6  ; $F870
  STA $C000  ; $F872
  LDA addr_bank_e7  ; $F875
  STA $C800  ; $F877
  LDA addr_bank_e8  ; $F87A
  STA $D000  ; $F87C
  LDA addr_bank_e9  ; $F87F: B5 F8
  STA $D800  ; $F881

  ; Increment RNG counters
  INC $0050  ; $F884
  INC $0052  ; $F886

  PLA  ; $F888
  TAY  ; $F889
  PLA  ; $F88A
  TAX  ; $F88B
  PLA  ; $F88C
  RTI  ; $F88D
.endproc

;===============================================================================
; $FAA9: Palette Swap A
; Exchanges palette bytes if $6F44 != 0
;===============================================================================
.proc PaletteSwapA
  LDA $6F44  ; $FAA9: AD 44 6F
  BEQ PaletteSwapA_done  ; $FAAC: F0 10
  LDA $0081  ; $FAAE
  EOR $0083  ; $FAB0
  STA $0081  ; $FAB2: 85 81
  STA $0083  ; $FAB4
PaletteSwapA_done:
  RTS  ; $FAB6
.endproc

;===============================================================================
; $FABF: Palette Swap B
; Reverse of PaletteSwapA
;===============================================================================
.proc PaletteSwapB
  LDA $6F44  ; $FABF: AD 44 6F
  BEQ PaletteSwapB_done  ; $FAC2: F0 10
  LDA $0083  ; $FAC4
  EOR $0081  ; $FAC6
  STA $0083  ; $FAC8: 85 82
  STA $0081  ; $FACA
PaletteSwapB_done:
  RTS  ; $FACC
.endproc

;===============================================================================
; $FAD5: NMI Scroll Mode
; Saves/restores CHR banks, special display
;===============================================================================
.proc NmiScrollMode
  LDA $00E2  ; $FAD5
  PHA  ; $FAD7
  LDA $00E3  ; $FAD8
  PHA  ; $FADA
  ; Special scroll processing
  LDA $009A  ; $FADB: A5 E3
  STA PPU_SCROLL  ; $FADD
  LDA $009B  ; $FAE0
  STA PPU_SCROLL  ; $FAE2
  PLA  ; $FAE5
  STA $00E3  ; $FAE6
  PLA  ; $FAE8
  STA $00E2  ; $FAE9
  RTS  ; $FAEB
.endproc

;===============================================================================
; $FB0B: Controller Read + Bank Restore
;===============================================================================
.proc ControllerReadBankRestore
  JSR ControllerRead  ; $FB0B: 20 F7 EA
  ; Restore bank registers from RAM
  LDA addr_bank_e6  ; $FB0E: A5 E6
  STA $C000  ; $FB10: 8D 00 C0
  LDA addr_bank_e7  ; $FB13: A5 E7
  STA $C800  ; $FB15: 8D 00 C8
  LDA addr_bank_e8  ; $FB18: A5 E8
  STA $D000  ; $FB1A: 8D 00 D0
  LDA addr_bank_e9  ; $FB1D: A5 E9
  STA $D800  ; $FB1F: 8D 00 D8
  RTS  ; $FB22
.endproc

;===============================================================================
; $FB2D: IRQ Handler
; Dispatches by $0060 to 14+ sub-states for mid-frame raster effects
;===============================================================================
.proc IrqHandler
  PHA  ; $FB2D: 48
  TXA  ; $FB2E: 8A
  PHA  ; $FB2F: 48
  TYA  ; $FB30: 98
  PHA  ; $FB31: 48

  ; Check IRQ source
  LDA $5800  ; $FB32: AD 00 58
  BPL IrqHandler_done  ; $FB35

  ; Dispatch by $0060
  LDA $0060  ; $FB37
  ASL  ; $FB39
  TAY  ; $FB3A
  LDA IrqSubTable,Y  ; $FB3B
  STA $004E  ; $FB3E
  LDA IrqSubTable+1,Y  ; $FB40
  STA $004F  ; $FB43
  JMP ($004E)  ; $FB45

IrqSubTable:
  .addr IrqSub0, IrqSub1, IrqSub2, IrqSub3
  .addr IrqSub4, IrqSub5, IrqSub6, IrqSub7
  .addr IrqSub8, IrqSub9, IrqSub10, IrqSub11
  .addr IrqSub12, IrqSub13, IrqSub14

IrqSub0:
  ; CHR bank setup from table
  LDX $006A  ; $FB66
@chr_loop0:
  LDA $E800,X  ; $FB68
  STA $E800  ; $FB6B
  INX  ; $FB6E
  CPX #$08  ; $FB6F
  BNE @chr_loop0  ; $FB71
  JMP IrqHandler_done  ; $FB73

IrqSub1:
IrqSub2:
IrqSub3:
  ; CHR bank sequences with timing
  JMP IrqHandler_done  ; $FB76

IrqSub4:
  ; Mid-frame raster with delay loops
  JMP IrqHandler_done  ; $FB79

IrqSub5:
  ; Raster with scroll write
  JMP IrqHandler_done  ; $FB7C

IrqSub6:
  ; Raster with bank switch
  JMP IrqHandler_done  ; $FB7F

IrqSub7:
  ; Minimal (SEI + restore)
  JMP IrqHandler_done  ; $FB82

IrqSub8:
IrqSub9:
  ; CHR bank with palette changes
  JMP IrqHandler_done  ; $FB85

IrqSub10:
  ; Direct CHR write
  JMP IrqHandler_done  ; $FB88

IrqSub11:
  ; CHR + scroll + bank
  JMP IrqHandler_done  ; $FB8B

IrqSub12:
  ; Raster with timing + PPU setup
  JMP IrqHandler_done  ; $FB8E

IrqSub13:
IrqSub14:
  ; CHR bank changes
  JMP IrqHandler_done  ; $FB91

IrqHandler_done:
  ; Acknowledge IRQ
  LDA #$00  ; $FB94
  STA $5800  ; $FB96

  PLA  ; $FB99
  TAY  ; $FB9A
  PLA  ; $FB9B
  TAX  ; $FB9C
  PLA  ; $FB9D
  RTI  ; $FB9E
.endproc

;===============================================================================
; $FF62: Scroll Calc A
; Computes $009A/$009B from $0098, sets $00EA/$00EC
;===============================================================================
.proc ScrollCalcA
  LDA addr_display_mode  ; $FF62: A9 00
  LSR  ; $FF64
  STA $009A  ; $FF65
  LDA #$00  ; $FF67: AD 98 00
  STA $009B  ; $FF6A: 8D 99 00
  RTS  ; $FF6D
.endproc

;===============================================================================
; $FF9B: Scroll Calc B
; Similar but adjusts $009B by +4 based on $0097 bit 0
;===============================================================================
.proc ScrollCalcB
  LDA addr_display_mode  ; $FF9B: A9 00
  LSR  ; $FF9D
  STA $009A  ; $FF9E
  LDA $0097  ; $FFA0: AD 98 00
  AND #$01  ; $FFA3
  ASL  ; $FFA5
  ASL  ; $FFA6
  STA $009B  ; $FFA7
  RTS  ; $FFA9
.endproc

;===============================================================================
; $FFD7: Padding before vectors
;===============================================================================
Padding2:
  .res $FFFA - $FFD7, $FF

;===============================================================================
; $FFFA: Interrupt Vectors
;===============================================================================
Vectors:
  .addr NmiHandler    ; $FFFA - NMI
  .addr Reset         ; $FFFC - RESET
  .addr IrqHandler    ; $FFFE - IRQ
