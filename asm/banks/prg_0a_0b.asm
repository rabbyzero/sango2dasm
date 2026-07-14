;===============================================================================
; PRG Banks $0A+$0B - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $0A at $A000-$BFFF, Bank $0B at $C000-$DFFF
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

; Global label declarations (ca65 .proc creates local scope)
.global ArmyDispatch
.global CheckGameStart_Entry
.global SubStateDispatch_Entry
.global ArmyValueCalc_Entry
.global DataRecordLookup_Entry
.global DistanceClamp_Entry
.global InitWorkAreas
.global NameTable
.global CheckGameStart
.global ProvinceSearch
.global ScanMatchData
.global SumAndCompare
.global TileRender
.global ArmyValueCalc
.global CallDomesticDisplay
.global ClearOverlay
.global DataRecordLookup
.global DistanceClamp
.global FillStackLoop
.global Init
.global JumpToBEC7
.global LoadRecord
.global PaletteCheck
.global RenderOverlay
.global SoundDispatch
.global SpriteSetup2
.global StackFill
.global SubStateDispatch
.global SearchBestTarget
.global LA7CA
.global LA7DA
.global LA8CC
.global LA9AD
.global LA9D0
.global LA9D8
.global LA9E4
.global LA9EC
.global LAA04
.global LAA10
.global LAA20
.global LAA2C
.global LAA39
.global LAAC2
.global LAAD5
.global LAB04
.global LAB55
.global LAB68
.global LAB97
.global LABD0
.global LABEE
.global LAC21
.global LAC33
.global LAC47
.global LACF2
.global LAD30
.global LADA7
.global LADE5
.global LAEB9
.global LB01B
.global LB043
.global LB09F
.global LB0BB
.global LB0CA
.global LB105
.global LB10D
.global LB144
.global LB150
.global LB156
.global LB174
.global ProvinceEvalExit
.global LB1E9

.global LC446
.global LC469
.global LC4C7
.global LC520
.global LC5BE
.global LC5EE
.global LC616
.global LC646
.global LC68D
.global LC690
.global LC6DA
.global LC6FF
.global LC70E
.global LC724
.global LC732
.global LC748
.global LC765
.global LC79F
.global LC7AA
.global LC7BB
.global LC7C1
.global LC7FE
.global LC7FF
.global LC80E
.global LC840
.global LC865
.global LC869
.global LC883
.global LC889
.global LC897
.global LC8B4
.global LC8B6
.global LC8E5
.global LC92B
.global LC949
.global LC997
.global LC9A4
.global LC9C1
.global LC9EF
.global LCA1E
.global LCA52
.global LCA7F
.global LCAAC
.global LCAB1
.global LCAD1
.global LCB0F
.global LCB36
.global LCB3E
.global LCB51
.global LCB79
.global LCB8A
.global LCB98
.global LCBA8
.global LCBEB
.global LCC17
.global LCC22
.global LCC82
.global LCDB7
.global LCF6E
.global LCF74
.global LCF8C
.global LCF98
.global LCFDC
.global LCFF8
.global LCFFE
.global LD004
.global LD02C
.global LD032
.global LD09F
.global LD0D6
.global LD0FE
.global LD161
.global LD1B2
.global LD1C5
.global LD1E4
.global LD1F1
.global LD202
.global LD216
.global LD239
.global LD257
.global LD270
.global LD317
.global LD340
.global LD385
.global LD39E
.global LD3BF
.global LD3D5
.global LD3E4
.global LD3F0
.global LD3FA
.global LD403
.global LD417
.global LD47B
.global LD48C
.global LD4B0
.global LD4C2
.global LD4CF
.global LD4DF
.global LD524
.global LD52D
.global LD5B8
.global LD5F6
.global LD603
.global LD610
.global LD61D
.global LD62D
.global LD63A
.global LD647
.global LD654
.global LD66E
.global LD687
.global LD69C
.global LD6E4
.global LD6EB
.global LD706
.global LD707
.global LD740
.global LD757
.global LD770
.global LD7A4
.global LD820
.global LD82A
.global LD861
.global LD8C3
.global LD8E7
.global LD904
.global LD91E
.global LD9AC
.global LDC08
.global LDC2E
.global LDC4F
.global LDC6D
.global LDC95
.global LDCB3
.global LDCE1
.global LDCFD
.global LDD0E
.global LDD1A
.global LDD1F
.global LDD29
.global LDD41
.global LDD8B
.global LDD9C
.global LDDB7
.global LDDC7
.global LDF62
.global LDF73
.global IterateArmyFields
.global KingdomActionDispatch
.global CalcKingdomTier
.global CalcKingdomTierWorkPtr
.global ResolveKingdomAbsorb
.global InitNewGameContext
.global CalcAvgProvinceVal
.global AbsorbPreview
.global TransferProvinceValues
.global FallbackMergeProvinces
.global AiTurnDispatch
.global AiAction_BoostMorale
.global AiAction_ManageOfficerLoyalty
.global AiAction_EvaluateAndExecute
.global DeductActionCost
.global Proc_C3FF
.global Proc_C498
.global Proc_C4D0
.global Proc_C50E
.global Proc_C5B9
.global Proc_C5D2
.global Proc_C68A
.global Proc_C795
.global Proc_C79A
.global Proc_C80A
.global Proc_C84D
.global Proc_C86A
.global Proc_C885
.global Proc_C8C3
.global Proc_C8E6
.global Proc_C917
.global Proc_C97A
.global Proc_C98F
.global Proc_C9A5
.global Proc_C9F9
.global Proc_CAAD
.global Proc_CAD8
.global Proc_CB05
.global Proc_CB52
.global Proc_CBA3
.global Proc_CD68
.global Proc_CDB9
.global Proc_CEDD
.global Proc_CFF1
.global Proc_D05D
.global Proc_D080
.global Proc_D0AA
.global Proc_D0E1
.global Proc_D0E9
.global Proc_D105
.global Proc_D12D
.global Proc_D152
.global Proc_D165
.global Proc_D178
.global Proc_D18D
.global Proc_D1A4
.global Proc_D1F4
.global Proc_D249
.global Proc_D283
.global Proc_D2D3
.global Proc_D304
.global Proc_D319
.global Proc_D336
.global Proc_D36F
.global Proc_D3A9
.global Proc_D3DD
.global Proc_D40F
.global Proc_D438
.global Proc_D471
.global JumpDispatcher
.global Proc_D4AD
.global Proc_D4BB
.global Proc_D4CB
.global Proc_D53E
.global Proc_D583
.global Proc_D5BF
.global Proc_D5E7
.global Proc_D5E8
.global Proc_D61E
.global Proc_D61F
.global Proc_D655
.global Proc_D688
.global Proc_D69D
.global Proc_D6E5
.global Proc_D6E6
.global Proc_D74C
.global Proc_D799
.global Proc_D7BD
.global Proc_D7EC
.global Proc_D83B
.global Proc_D856
.global Proc_D890
.global Proc_D8AD
.global Proc_D8B7
.global Proc_D8D9
.global Proc_D8DB
.global Proc_D8F8
.global Proc_D90D
.global Proc_D9A8
.global Proc_D9D0
.global Proc_DA1B
.global Proc_DA1D
.global Proc_DA3F
.global Proc_DA95
.global Proc_DAA6
.global Proc_DAFD
.global Proc_DB2B
.global Proc_DB2D
.global Proc_DB7B
.global Proc_DBBB
.global Proc_DBC1
.global Proc_DBD4
.global Proc_DBF1
.global Proc_DC2F
.global Proc_DC97
.global Proc_DD0F
.global Proc_DD34
.global Proc_DD53
.global Proc_DD79

;===============================================================================
; Global RAM Address Definitions
;===============================================================================
; These addresses have consistent meaning across the bank pair.

; --- Battery SRAM ($6Fxx) ---
sram_kingdom_index     = $6F02  ; Kingdom/region index
sram_player_id         = $6F03  ; Current player ID / slot
sram_game_start_flag   = $6F8B  ; Game start flag ($FF = new game)
sram_work_0            = $6F5F  ; Computed work value 0
sram_work_1            = $6F60  ; Computed work value 1
sram_work_2            = $6F61  ; Computed work value 2
sram_counter           = $6F5B  ; Iteration counter

; --- Work Area ($0036-$0045) ---
work_outer_idx         = $0036  ; Outer loop index
work_inner_idx         = $0037  ; Inner loop index
work_inner_idx2        = $0038  ; Inner loop index 2
work_sub_idx           = $0039  ; Sub-loop index
work_limit_a           = $003A  ; Comparison limit A
work_limit_b           = $003B  ; Comparison limit B
work_temp_0            = $003C  ; Temporary storage 0
work_temp_1            = $003D  ; Temporary storage 1
work_temp_2            = $003E  ; Temporary storage 2
work_record_idx        = $003F  ; Record index
work_record_val        = $0040  ; Record value
work_search_result     = $0041  ; Search/comparison result
work_search_max        = $0045  ; Search max value

; --- Math Workspace ($20-$27) ---
math_acc_lo            = $20    ; Accumulator low byte
math_acc_mlo           = $21    ; Accumulator mid-low
math_acc_mhi           = $22    ; Accumulator mid-high
math_acc_hi            = $23    ; Accumulator high byte
math_ext               = $24    ; Extension byte
math_temp1             = $25    ; Math temporary 1
math_temp2             = $26    ; Math temporary 2
math_temp3             = $27    ; Math temporary 3

; --- Game State ($05xx) ---
state_sub_dispatch     = $0540  ; Sub-state dispatch index
state_display_idx      = $0541  ; Display state index
state_overlay_param    = $0545  ; Overlay/menu parameter
state_palette_mode     = $0547  ; Palette animation mode

.segment "CODE_BANK0A"

;===============================================================================
; Jump Table - Public entry points ($A000-$A00E)
;===============================================================================
CheckGameStart_Entry:
  JMP CheckGameStart                                ; $A000: 4C 0F A0
SubStateDispatch_Entry:
  JMP SubStateDispatch                            ; $A003: 4C 17 D7
ArmyValueCalc_Entry:
  JMP ArmyValueCalc                               ; $A006: 4C 3F CF
DataRecordLookup_Entry:
  JMP DataRecordLookup                            ; $A009: 4C 7C CF
DistanceClamp_Entry:
  JMP DistanceClamp                               ; $A00C: 4C 0C D0
;===============================================================================
; $A00F: CheckGameStart
; Check game start flag ($6F8B) and dispatch start menu / main flow
;===============================================================================
.proc CheckGameStart
  game_start_flag            = $6F8B

  LDA game_start_flag                               ; $A00F: AD 8B 6F
  BMI @Exit                                           ; $A012: 30 2E  if negative, no game start
  CMP #$01                                            ; $A014: C9 01
  BNE @NotOne                                         ; $A016: D0 06  if != 1, skip new-game path
  JSR Proc_D4CB                                       ; $A018: 20 CB D4
  JMP InitNewGameContext                              ; $A01B: 4C D7 A8  new game: jump to start menu
@NotOne:
  JSR Proc_D4CB                                       ; $A01E: 20 CB D4
  JSR Proc_C50E                                       ; $A021: 20 0E C5
  JSR Proc_C5B9                                       ; $A024: 20 B9 C5
  JSR Proc_C79A                                       ; $A027: 20 9A C7
  LDA $6F03                                           ; $A02A: AD 03 6F
  JSR Proc_C98F                                       ; $A02D: 20 8F C9
  JSR Proc_D249                                       ; $A030: 20 49 D2
  JSR $CC12                                           ; $A033: 20 12 CC
  LDA $6F5B                                           ; $A036: AD 5B 6F
  JSR JumpDispatcher                                  ; $A039: 20 94 D4
  ; Jump table (3 entries):
  .word InitWorkAreas                                 ; $A03C: 43 A0 (entry 0)
  .word SumAndCompare                                 ; $A03E: 9C A1 (entry 1)
  .word @Exit                                         ; $A040: 42 A0 (entry 2)
@Exit:
  RTS                                                 ; $A042: 60
.endproc
;===============================================================================
; $A043: InitWorkAreas
; Initialize work areas and counters for province scanning
;===============================================================================
.proc InitWorkAreas
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp2               = $0026
  math_temp3               = $0027
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_sub_idx             = $0039
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C
  work_temp_1              = $003D
  sram_kingdom_index       = $6F02
  sram_player_id           = $6F03
  sram_counter             = $6F5B
  sram_work_0              = $6F5F
  sram_work_1              = $6F60
  sram_work_2              = $6F61

  LDA #$00                                            ; $A043: A9 00
  STA a:$0039                                         ; $A045: 8D 39 00
  STA a:$003A                                         ; $A048: 8D 3A 00
  STA a:$003B                                         ; $A04B: 8D 3B 00
  STA a:$003C                                         ; $A04E: 8D 3C 00
  STA a:$003D                                         ; $A051: 8D 3D 00
  LDA $6F02                                           ; $A054: AD 02 6F
  ASL A                                               ; $A057: 0A
  ASL A                                               ; $A058: 0A
  ASL A                                               ; $A059: 0A
  ORA $6F03                                           ; $A05A: 0D 03 6F
  TAY                                                 ; $A05D: A8
  LDA ProvinceDataA,Y                                 ; $A05E: B9 33 A1
  STA $6F5F                                           ; $A061: 8D 5F 6F
  LDA ProvinceDataB,Y                                 ; $A064: B9 4B A1
  STA $6F60                                           ; $A067: 8D 60 6F
  LDA ProvinceDataC,Y                                 ; $A06A: B9 63 A1
  STA $6F61                                           ; $A06D: 8D 61 6F
  JSR ScanMatchData                               ; $A070: 20 D3 A0
  LDA a:$0038                                         ; $A073: AD 38 00
  STA $20                                             ; $A076: 85 20
  LDA #$00                                            ; $A078: A9 00
  STA $21                                             ; $A07A: 85 21
  STA $22                                             ; $A07C: 85 22
  LDA #$64                                            ; $A07E: A9 64
  STA $23                                             ; $A080: 85 23
  JSR Proc_D438                                       ; $A082: 20 38 D4
  LDA $26                                             ; $A085: A5 26
  STA $21                                             ; $A087: 85 21
  LDA $27                                             ; $A089: A5 27
  STA $22                                             ; $A08B: 85 22
  LDA a:$0037                                         ; $A08D: AD 37 00
  STA $23                                             ; $A090: 85 23
  LDA #$00                                            ; $A092: A9 00
  STA $24                                             ; $A094: 85 24
  JSR Proc_D40F                                       ; $A096: 20 0F D4
  LDA $21                                             ; $A099: A5 21
  LDY #$00                                            ; $A09B: A0 00
  CMP #$1F                                            ; $A09D: C9 1F
  BCC @ApplyTierAdjust                                ; $A09F: 90 06
  INY                                                 ; $A0A1: C8
  CMP #$47                                            ; $A0A2: C9 47
  BCC @ApplyTierAdjust                                ; $A0A4: 90 01
  INY                                                 ; $A0A6: C8
@ApplyTierAdjust:
  STY $20                                             ; $A0A7: 84 20
  LDA $6F02                                           ; $A0A9: AD 02 6F
  ASL A                                               ; $A0AC: 0A
  ASL A                                               ; $A0AD: 0A
  ORA $20                                             ; $A0AE: 05 20
  TAY                                                 ; $A0B0: A8
  LDA TierAdjustA,Y                                     ; $A0B1: B9 7B A1
  CLC                                                 ; $A0B4: 18
  ADC $6F5F                                           ; $A0B5: 6D 5F 6F
  STA $6F5F                                           ; $A0B8: 8D 5F 6F
  LDA TierAdjustB,Y                                     ; $A0BB: B9 86 A1
  CLC                                                 ; $A0BE: 18
  ADC $6F60                                           ; $A0BF: 6D 60 6F
  STA $6F60                                           ; $A0C2: 8D 60 6F
  LDA TierAdjustC,Y                                     ; $A0C5: B9 91 A1
  CLC                                                 ; $A0C8: 18
  ADC $6F61                                           ; $A0C9: 6D 61 6F
  STA $6F61                                           ; $A0CC: 8D 61 6F
  INC $6F5B                                           ; $A0CF: EE 5B 6F
  RTS                                                 ; $A0D2: 60
.endproc


;===============================================================================
; $A0D3: ScanMatchData
; Scan and match province data against search criteria
;===============================================================================
.proc ScanMatchData
  math_acc_hi              = $0023
  math_ext                 = $0024
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_sub_idx             = $0039
  sram_player_id           = $6F03

  LDY #$30                                            ; $A0D3: A0 30
  JSR B1F_SwitchBank8_A                               ; $A0D5: 20 66 F2
  LDA #$00                                            ; $A0D8: A9 00
  STA a:$0036                                         ; $A0DA: 8D 36 00
  STA a:$0037                                         ; $A0DD: 8D 37 00
  STA a:$0038                                         ; $A0E0: 8D 38 00
@NextProvince:
  LDA #$00                                            ; $A0E3: A9 00
  STA a:$0039                                         ; $A0E5: 8D 39 00
  LDA a:$0036                                         ; $A0E8: AD 36 00
  ASL A                                               ; $A0EB: 0A
  ASL A                                               ; $A0EC: 0A
  ASL A                                               ; $A0ED: 0A
  TAY                                                 ; $A0EE: A8
@NextSubEntry:
  LDA $9D72,Y                                         ; $A0EF: B9 72 9D
  BMI @AdvanceOuter                                   ; $A0F2: 30 34
  STA $23                                             ; $A0F4: 85 23
  STY $24                                             ; $A0F6: 84 24
  JSR Proc_D105                                       ; $A0F8: 20 05 D1
  AND #$07                                            ; $A0FB: 29 07
  CMP #$07                                            ; $A0FD: C9 07
  BEQ @AdvanceInner                                   ; $A0FF: F0 05
  CMP $6F03                                           ; $A101: CD 03 6F
  .byte $D0,$13                                       ; $A104: D0 13 (BNE mid-instruction target)
@AdvanceInner:
  INC a:$0037                                         ; $A106: EE 37 00
  LDA a:$0036                                         ; $A109: AD 36 00
  JSR Proc_D304                                       ; $A10C: 20 04 D3
  CMP #$04                                            ; $A10F: C9 04
  .byte $B0,$06                                       ; $A111: B0 06 (BCS mid-instruction target)
  INC a:$0038                                         ; $A113: EE 38 00
  JMP @AdvanceOuter                                   ; $A116: 4C 28 A1
  LDA $23                                             ; $A119: A5 23
  LDY $24                                             ; $A11B: A4 24
  INY                                                 ; $A11D: C8
  INC a:$0039                                         ; $A11E: EE 39 00
  LDX a:$0039                                         ; $A121: AE 39 00
  CPX #$08                                            ; $A124: E0 08
  BCC @NextSubEntry                                   ; $A126: 90 C7
@AdvanceOuter:
  INC a:$0036                                         ; $A128: EE 36 00
  LDA a:$0036                                         ; $A12B: AD 36 00
  CMP #$1E                                            ; $A12E: C9 1E
  BCC @NextProvince                                   ; $A130: 90 B1
  RTS                                                 ; $A132: 60
.endproc



;===============================================================================
; $A133: ProvinceDataA (24 bytes)
; Province match parameter table A, indexed by [kingdom*8 + player_id]
;===============================================================================
ProvinceDataA:
  .byte $0D,$08,$0A,$0A,$04,$06,$07,$00  ; $A133
  .byte $0C,$07,$06,$08,$04,$02,$04,$00  ; $A13B
  .byte $09,$08,$08,$08,$05,$02,$06,$00  ; $A143

;===============================================================================
; $A14B: ProvinceDataB (24 bytes)
; Province match parameter table B, indexed by [kingdom*8 + player_id]
;===============================================================================
ProvinceDataB:
  .byte $03,$05,$04,$04,$04,$06,$05,$00  ; $A14B
  .byte $04,$06,$08,$06,$06,$0A,$08,$00  ; $A153
  .byte $06,$06,$06,$07,$08,$0B,$08,$00  ; $A15B

;===============================================================================
; $A163: ProvinceDataC (24 bytes)
; Province match parameter table C, indexed by [kingdom*8 + player_id]
;===============================================================================
ProvinceDataC:
  .byte $04,$07,$06,$06,$0C,$08,$08,$00  ; $A163
  .byte $04,$07,$06,$06,$0A,$08,$08,$00  ; $A16B
  .byte $05,$06,$06,$05,$07,$07,$06,$00  ; $A173

;===============================================================================
; $A17B: TierAdjustA (11 bytes)
; Tier-based adjustment table A, indexed by [kingdom*4 + tier]
;===============================================================================
TierAdjustA:
  .byte $02,$04,$05,$00,$00,$03,$05,$00,$01,$02,$04  ; $A17B

;===============================================================================
; $A186: TierAdjustB (11 bytes)
; Tier-based adjustment table B, indexed by [kingdom*4 + tier]
;===============================================================================
TierAdjustB:
  .byte $02,$02,$00,$00,$04,$03,$00,$00,$03,$02,$01  ; $A186

;===============================================================================
; $A191: TierAdjustC (11 bytes)
; Tier-based adjustment table C, indexed by [kingdom*4 + tier]
;===============================================================================
TierAdjustC:
  .byte $02,$00,$01,$00,$02,$00,$01,$00,$02,$02,$01  ; $A191

;===============================================================================
; $A19C: SumAndCompare
; Sum values and compare against thresholds
;===============================================================================
.proc SumAndCompare
  math_acc_mlo             = $0021
  sram_work_0              = $6F5F
  sram_work_1              = $6F60
  sram_work_2              = $6F61

  LDA $6F5F                                           ; $A19C: AD 5F 6F
  CLC                                                 ; $A19F: 18
  ADC $6F60                                           ; $A1A0: 6D 60 6F
  STA $21                                             ; $A1A3: 85 21
  CLC                                                 ; $A1A5: 18
  ADC $6F61                                           ; $A1A6: 6D 61 6F
  JSR Proc_D4AD                                       ; $A1A9: 20 AD D4
  LDY #$00                                            ; $A1AC: A0 00
  CMP $6F5F                                           ; $A1AE: CD 5F 6F
  BCC @UseIndex                                       ; $A1B1: 90 06
  INY                                                 ; $A1B3: C8
  CMP $21                                             ; $A1B4: C5 21
  BCC @UseIndex                                       ; $A1B6: 90 01
  INY                                                 ; $A1B8: C8
@UseIndex:
  TYA                                                 ; $A1B9: 98
  AND #$03                                            ; $A1BA: 29 03
  JSR JumpDispatcher                                  ; $A1BC: 20 94 D4
  ; Jump table (3 entries):
  .word StateThresholdCheck                           ; $A1BF: C5 A1 (entry 0)
  .word AiTurnDispatch                                ; $A1C1: 9C B4 (entry 1)
  .word $BEC7                                         ; $A1C3: C7 BE (entry 2)
.endproc


;===============================================================================
; $A1C5: StateThresholdCheck
; Dispatch target 0: check state thresholds and update counter
;===============================================================================
.proc StateThresholdCheck
  LDA $6F02                                           ; $A1C5: AD 02 6F
  CMP #$02                                            ; $A1C8: C9 02
  BEQ @check6F02                                      ; $A1CA: F0 0C
  LDA #$64                                            ; $A1CC: A9 64
  JSR Proc_D4BB                                       ; $A1CE: 20 BB D4
  CMP #$14                                            ; $A1D1: C9 14
  .byte $B0,$0F                                       ; $A1D3: B0 0F (BCS, dead code - follows JMP)
  JMP CalcAvgProvinceVal                              ; $A1D5: 4C 0E B1
@check6F02:
  LDA #$64                                            ; $A1D8: A9 64
  JSR Proc_D4BB                                       ; $A1DA: 20 BB D4
  CMP #$1E                                            ; $A1DD: C9 1E
  .byte $B0,$03                                       ; $A1DF: B0 03 (BCS, dead code - follows JMP)
  JMP CalcAvgProvinceVal                              ; $A1E1: 4C 0E B1
  LDA $6F02                                           ; $A1E4: AD 02 6F
  BEQ @incrementCounter                               ; $A1E7: F0 15
  CMP #$02                                            ; $A1E9: C9 02
  BEQ @ge90                                           ; $A1EB: F0 1B
  LDA $6F00                                           ; $A1ED: AD 00 6F
  CMP #$5A                                            ; $A1F0: C9 5A
  BCS @ge90                                           ; $A1F2: B0 14
  LDA $6F01                                           ; $A1F4: AD 01 6F
  CMP #$06                                            ; $A1F7: C9 06
  BCS @ge90                                           ; $A1F9: B0 0D
  JMP JumpToBEC7                                       ; $A1FB: 4C 3D A2
@incrementCounter:
  LDA $6F00                                           ; $A1FE: AD 00 6F
  CMP #$5A                                            ; $A201: C9 5A
  BCS @ge90                                           ; $A203: B0 03
  JMP JumpToBEC7                                       ; $A205: 4C 3D A2
@ge90:
  LDA #$00                                            ; $A208: A9 00
  STA a:$0044                                         ; $A20A: 8D 44 00
  JSR SearchBestTarget                                ; $A20D: 20 40 A2
  INC a:$0037                                         ; $A210: EE 37 00
  INC a:$0037                                         ; $A213: EE 37 00
  INC a:$0037                                         ; $A216: EE 37 00
  LDA a:$0037                                         ; $A219: AD 37 00
  CMP #$0A                                            ; $A21C: C9 0A
  BCC @callUpdates                                    ; $A21E: 90 05
  LDA #$0A                                            ; $A220: A9 0A
  STA a:$0037                                         ; $A222: 8D 37 00
@callUpdates:
  LDA a:$003A                                         ; $A225: AD 3A 00
  JSR Proc_D304                                       ; $A228: 20 04 D3
  CMP a:$0037                                         ; $A22B: CD 37 00
  BCS @skipSearch                                     ; $A22E: B0 03
  JSR ProvinceSearch                                  ; $A230: 20 03 A3
@skipSearch:
  JSR IterateArmyFields                                   ; $A233: 20 5C A4
  JSR KingdomActionDispatch                           ; $A236: 20 BC A6
  JSR ResolveKingdomAbsorb                              ; $A239: 20 9C A7
@done:
  RTS                                                 ; $A23C: 60
.endproc

;===============================================================================
; $A23D: JumpToBEC7
;===============================================================================
.proc JumpToBEC7
  JMP $BEC7                                           ; $A23D: 4C C7 BE
.endproc

;===============================================================================
; $A240: SearchBestTarget
; Iterate entities 0-$1D, count active items via Proc_D304, filter by type
; and bitmask (table at $9D72 in bank $30), and track the best candidate.
;===============================================================================
.proc SearchBestTarget
  table_offset             = $0024
  attr_value               = $0025
  entity_score             = $0026
  candidate_idx            = $0036
  best_inner_idx           = $0037
  best_idx                 = $0038
  best_sub_idx             = $0039
  best_outer_idx           = $003A
  sram_player_id           = $6F03

SearchBestTarget:
  LDY #$30                                            ; $A240: A0 30
  JSR B1F_SwitchBank8_A                               ; $A242: 20 66 F2
  LDA #$00                                            ; $A245: A9 00
  STA a:candidate_idx                                 ; $A247: 8D 36 00
  LDA #$FF                                            ; $A24A: A9 FF
  STA a:best_inner_idx                                ; $A24C: 8D 37 00
  STA a:best_idx                                      ; $A24F: 8D 38 00
  STA a:best_outer_idx                                ; $A252: 8D 3A 00
  LDA #$00                                            ; $A255: A9 00
  STA a:best_sub_idx                                  ; $A257: 8D 39 00
@loadAndCheckNext:
  LDA a:candidate_idx                                 ; $A25A: AD 36 00
  JSR Proc_D105                                       ; $A25D: 20 05 D1
  CMP sram_player_id                                  ; $A260: CD 03 6F
  BNE @nextEntity                                     ; $A263: D0 63
  JSR $D307                                           ; $A265: 20 07 D3
  STA entity_score                                    ; $A268: 85 26
  LDA a:candidate_idx                                 ; $A26A: AD 36 00
  ASL A                                               ; $A26D: 0A
  ASL A                                               ; $A26E: 0A
  ASL A                                               ; $A26F: 0A
  STA table_offset                                    ; $A270: 85 24
@tableLookup:
  LDY table_offset                                    ; $A272: A4 24
  LDA $9D72,Y                                         ; $A274: B9 72 9D
  BMI @nextEntity                                     ; $A277: 30 4F
  STA attr_value                                      ; $A279: 85 25
  JSR Proc_D105                                       ; $A27B: 20 05 D1
  AND #$07                                            ; $A27E: 29 07
  CMP #$07                                            ; $A280: C9 07
  BEQ @nextEntry                                      ; $A282: F0 3F
  CMP sram_player_id                                  ; $A284: CD 03 6F
  BEQ @nextEntry                                      ; $A287: F0 3A
  JSR @BitMaskLookup                                ; $A289: 20 D3 A2
  BNE @nextEntry                                      ; $A28C: D0 35
  JSR $D307                                           ; $A28E: 20 07 D3
  CMP a:best_inner_idx                                ; $A291: CD 37 00
  BEQ @updateBestSubIdx                               ; $A294: F0 02
  BCS @nextEntry                                      ; $A296: B0 2B
@updateBestSubIdx:
  STA a:best_inner_idx                                ; $A298: 8D 37 00
  LDA attr_value                                      ; $A29B: A5 25
  CMP a:best_idx                                      ; $A29D: CD 38 00
  BNE @storeBestAndContinue                           ; $A2A0: D0 13
  LDA entity_score                                    ; $A2A2: A5 26
  CMP a:best_sub_idx                                  ; $A2A4: CD 39 00
  BCC @nextEntry                                      ; $A2A7: 90 1A
  STA a:best_sub_idx                                  ; $A2A9: 8D 39 00
  LDA a:candidate_idx                                 ; $A2AC: AD 36 00
  STA a:best_outer_idx                                ; $A2AF: 8D 3A 00
  JMP @nextEntry                                      ; $A2B2: 4C C3 A2
@storeBestAndContinue:
  STA a:best_idx                                      ; $A2B5: 8D 38 00
  LDA entity_score                                    ; $A2B8: A5 26
  STA a:best_sub_idx                                  ; $A2BA: 8D 39 00
  LDA a:candidate_idx                                 ; $A2BD: AD 36 00
  STA a:best_outer_idx                                ; $A2C0: 8D 3A 00
@nextEntry:
  INC table_offset                                    ; $A2C3: E6 24
  JMP @tableLookup                                    ; $A2C5: 4C 72 A2
@nextEntity:
  INC a:candidate_idx                                 ; $A2C8: EE 36 00
  LDA a:candidate_idx                                 ; $A2CB: AD 36 00
  CMP #$1E                                            ; $A2CE: C9 1E
  BCC @loadAndCheckNext                               ; $A2D0: 90 88
  RTS                                                 ; $A2D2: 60

;-------------------------------------------------------------------------------
; @BitMaskLookup (nested in SearchBestTarget)
; A = bit index; returns masked value from NibbleMaskTable.
; Preserves $24-$25 across the call.
;-------------------------------------------------------------------------------
@BitMaskLookup:
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025

  PHA                                                 ; $A2D3: 48
  LDA $24                                             ; $A2D4: A5 24
  PHA                                                 ; $A2D6: 48
  LDA $25                                             ; $A2D7: A5 25
  PHA                                                 ; $A2D9: 48
  LDA sram_player_id                                  ; $A2DA: AD 03 6F
  JSR Proc_D319                                       ; $A2DD: 20 19 D3
  LDA $24                                             ; $A2E0: A5 24
  STA $22                                             ; $A2E2: 85 22
  LDA $25                                             ; $A2E4: A5 25
  STA $23                                             ; $A2E6: 85 23
  PLA                                                 ; $A2E8: 68
  STA $25                                             ; $A2E9: 85 25
  PLA                                                 ; $A2EB: 68
  STA $24                                             ; $A2EC: 85 24
  PLA                                                 ; $A2EE: 68
  TAX                                                 ; $A2EF: AA
  LSR A                                               ; $A2F0: 4A
  CLC                                                 ; $A2F1: 18
  ADC #$04                                            ; $A2F2: 69 04
  TAY                                                 ; $A2F4: A8
  LDA ($22),Y                                         ; $A2F5: B1 22
  AND NibbleMaskTable,X                               ; $A2F7: 3D FB A2
  RTS                                                 ; $A2FA: 60
NibbleMaskTable:                                      ; alternating low/high nibble masks
  .byte $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0               ; $A2FB: 0F F0 0F F0 0F F0 0F F0
.endproc

;===============================================================================
; $A303: ProvinceSearch
; Two-phase province search:
;   Phase 1 - find best province owned by current player (with access check)
;   Phase 2 - fallback: find best province among ALL (no owner/access filter)
; CompareValues ($A3D6) is a nested helper that scores each candidate.
;===============================================================================
.proc ProvinceSearch
  candidate_idx            = $0036   ; current province being evaluated
  best_slot_idx            = $0037   ; best slot index (set by CompareValues)
  source_province          = $003A   ; source/owner province ID (from caller)
  work_best_value          = $0041   ; best province score found so far
  search_max               = $0045   ; max provinces to scan
  compare_mode             = $0044   ; inner comparison mode flag (used by CompareValues)
  sram_player_id           = $6F03

  JSR Proc_D249                                       ; $A303: 20 49 D2
  STA a:search_max                                    ; $A306: 8D 45 00
  JSR LoadRecord                                      ; $A309: 20 3A D0
  LDY sram_player_id                                  ; $A30C: AC 03 6F
  LDA @PlayerThresholds,Y                             ; $A30F: B9 C6 A3
  STA a:work_best_value                               ; $A312: 8D 41 00
  LDA #$00                                            ; $A315: A9 00
  STA a:candidate_idx                                 ; $A317: 8D 36 00
; --- Phase 1: search provinces owned by current player ---
@phase1Loop:
  LDA a:candidate_idx                                 ; $A31A: AD 36 00
  CMP a:source_province                               ; $A31D: CD 3A 00
  BEQ @phase1Next                                     ; $A320: F0 39
  CMP a:search_max                                    ; $A322: CD 45 00
  BEQ @phase1Next                                     ; $A325: F0 34
  JSR Proc_D105                                       ; $A327: 20 05 D1
  CMP sram_player_id                                  ; $A32A: CD 03 6F
  BNE @phase1Next                                     ; $A32D: D0 2C
  JSR Proc_D1A4                                       ; $A32F: 20 A4 D1
  BNE @phase1Next                                     ; $A332: D0 27
  LDX a:source_province                               ; $A334: AE 3A 00
  LDY a:candidate_idx                                 ; $A337: AC 36 00
  JSR Proc_D583                                       ; $A33A: 20 83 D5
  CMP #$FF                                            ; $A33D: C9 FF
  BNE @phase1Next                                     ; $A33F: D0 1A
  LDA a:candidate_idx                                 ; $A341: AD 36 00
  JSR Proc_D304                                       ; $A344: 20 04 D3
  CMP a:work_best_value                               ; $A347: CD 41 00
  BCC @phase1Next                                     ; $A34A: 90 0F
  JSR CompareValues                                   ; $A34C: 20 D6 A3
  LDA a:source_province                               ; $A34F: AD 3A 00
  JSR Proc_D304                                       ; $A352: 20 04 D3
  CMP a:best_slot_idx                                 ; $A355: CD 37 00
  BCC @phase1Loop                                     ; $A358: 90 C0
  RTS                                                 ; $A35A: 60
@phase1Next:
  INC a:candidate_idx                                 ; $A35B: EE 36 00
  LDA a:candidate_idx                                 ; $A35E: AD 36 00
  CMP #$1E                                            ; $A361: C9 1E
  BCC @phase1Loop                                     ; $A363: 90 B5
; --- Phase 2: fallback search among all provinces ---
  LDY sram_player_id                                  ; $A365: AC 03 6F
  LDA @PlayerThresholds+8,Y                           ; $A368: B9 CE A3
  STA a:work_best_value                               ; $A36B: 8D 41 00
  LDA #$00                                            ; $A36E: A9 00
  STA a:candidate_idx                                 ; $A370: 8D 36 00
@phase2Loop:
  LDA a:candidate_idx                                 ; $A373: AD 36 00
  CMP a:source_province                               ; $A376: CD 3A 00
  BEQ @phase2Next                                     ; $A379: F0 3C
  JSR Proc_D105                                       ; $A37B: 20 05 D1
  CMP sram_player_id                                  ; $A37E: CD 03 6F
  BNE @phase2Next                                     ; $A381: D0 34
  LDA a:candidate_idx                                 ; $A383: AD 36 00
  CMP a:search_max                                    ; $A386: CD 45 00
  BEQ @phase2CheckAccess                              ; $A389: F0 05
  JSR Proc_D1A4                                       ; $A38B: 20 A4 D1
  BEQ @phase2Next                                     ; $A38E: F0 27
@phase2CheckAccess:
  LDX a:source_province                               ; $A390: AE 3A 00
  LDY a:candidate_idx                                 ; $A393: AC 36 00
  JSR Proc_D583                                       ; $A396: 20 83 D5
  CMP #$FF                                            ; $A399: C9 FF
  BNE @phase2Next                                     ; $A39B: D0 1A
  LDA a:candidate_idx                                 ; $A39D: AD 36 00
  JSR Proc_D304                                       ; $A3A0: 20 04 D3
  CMP a:work_best_value                               ; $A3A3: CD 41 00
  BCC @phase2Next                                     ; $A3A6: 90 0F
  JSR CompareValues                                   ; $A3A8: 20 D6 A3
  LDA a:source_province                               ; $A3AB: AD 3A 00
  JSR Proc_D304                                       ; $A3AE: 20 04 D3
  CMP a:best_slot_idx                                 ; $A3B1: CD 37 00
  BCC @phase2Loop                                     ; $A3B4: 90 BD
  RTS                                                 ; $A3B6: 60
@phase2Next:
  INC a:candidate_idx                                 ; $A3B7: EE 36 00
  LDA a:candidate_idx                                 ; $A3BA: AD 36 00
  CMP #$1E                                            ; $A3BD: C9 1E
  BCC @phase2Loop                                     ; $A3BF: 90 B2
; --- search exhausted: give up ---
  PLA                                                 ; $A3C1: 68
  PLA                                                 ; $A3C2: 68
  JMP JumpToBEC7                                      ; $A3C3: 4C 3D A2
@PlayerThresholds:                                    ; per-player thresholds [0..7]
  .byte $02,$03,$03,$02,$03,$03,$02,$02               ; $A3C6: 02 03 03 02 03 03 02 02
              ; fallback thresholds [8..15]
  .byte $04,$05,$04,$03,$04,$05,$04,$04               ; $A3CE: 04 05 04 03 04 05 04 04

;-------------------------------------------------------------------------------
; CompareValues (nested in ProvinceSearch)
; Score a candidate province by finding its best-valued slot ($11-$1A).
; Inputs:  candidate_idx ($0036) = province to evaluate
;          source_province ($003A) = source province ID
;          $0044 = inner comparison mode flag
; Outputs: best_slot_idx ($0037) = index of best slot found
;-------------------------------------------------------------------------------
CompareValues:
  record_ptr               = $0020   ; pointer to current record data
  slot_index               = $0024   ; slot offset iterator ($11..$1A)
  best_slot_val            = $0025   ; best slot value found
  best_slot_pos            = $0026   ; Y-index of best slot
  ref_value                = $0027   ; reference value for comparison
  saved_candidate          = $003B   ; saved candidate province ID
  best_result              = $003C   ; result value to write back

  LDA a:candidate_idx                                 ; $A3D6: AD 36 00
  STA a:saved_candidate                               ; $A3D9: 8D 3B 00
  LDA a:saved_candidate                               ; $A3DC: AD 3B 00
  JSR Proc_D105                                       ; $A3DF: 20 05 D1
  LDA sram_player_id                                  ; $A3E2: AD 03 6F
  JSR Proc_D319                                       ; $A3E5: 20 19 D3
  LDY #$00                                            ; $A3E8: A0 00
  LDA ($24),Y                                         ; $A3EA: B1 24  ; read from record ptr returned by Proc_D319
  STA ref_value                                       ; $A3EC: 85 27
  LDA #$11                                            ; $A3EE: A9 11
  STA slot_index                                      ; $A3F0: 85 24
  LDA #$00                                            ; $A3F2: A9 00
  STA best_slot_val                                   ; $A3F4: 85 25
  STA best_slot_pos                                   ; $A3F6: 85 26
@slotLoop:
  LDY slot_index                                      ; $A3F8: A4 24
  LDA (record_ptr),Y                                  ; $A3FA: B1 20
  CMP #$FF                                            ; $A3FC: C9 FF
  BEQ @slotDone                                       ; $A3FE: F0 28
  CMP ref_value                                       ; $A400: C5 27
  BEQ @slotDone                                       ; $A402: F0 24
  LDX a:compare_mode                                  ; $A404: AE 44 00
  BEQ @innerCheck                                     ; $A407: F0 0B
  LDX slot_index                                      ; $A409: A6 24
  CPX #$11                                            ; $A40B: E0 11
  BEQ @slotDone                                       ; $A40D: F0 19
  LDY #$03                                            ; $A40F: A0 03
  JMP @callScoreHelper                                ; $A411: 4C 16 A4
@innerCheck:
  LDY #$01                                            ; $A414: A0 01
@callScoreHelper:
  JSR $D2AB                                           ; $A416: 20 AB D2
  CMP best_slot_val                                   ; $A419: C5 25
  BCC @slotDone                                       ; $A41B: 90 0B
  STA best_slot_val                                   ; $A41D: 85 25
  LDY slot_index                                      ; $A41F: A4 24
  STY best_slot_pos                                   ; $A421: 84 26
  LDA (record_ptr),Y                                  ; $A423: B1 20
  STA a:best_result                                   ; $A425: 8D 3C 00
@slotDone:
  INC slot_index                                      ; $A428: E6 24
  LDA slot_index                                      ; $A42A: A5 24
  CMP #$1B                                            ; $A42C: C9 1B
  BCC @slotLoop                                       ; $A42E: 90 C8
; write back results
  LDY best_slot_pos                                   ; $A430: A4 26
  LDA #$FF                                            ; $A432: A9 FF
  STA (record_ptr),Y                                  ; $A434: 91 20
  LDA a:saved_candidate                               ; $A436: AD 3B 00
  JSR Proc_D3DD                                       ; $A439: 20 DD D3
  LDA a:source_province                               ; $A43C: AD 3A 00
  JSR Proc_D105                                       ; $A43F: 20 05 D1
  LDY #$10                                            ; $A442: A0 10
@scanResultSlot:
  INY                                                 ; $A444: C8
  LDA (record_ptr),Y                                  ; $A445: B1 20
  CMP #$FF                                            ; $A447: C9 FF
  BNE @scanResultSlot                                 ; $A449: D0 F9
  LDA a:best_result                                   ; $A44B: AD 3C 00
  STA (record_ptr),Y                                  ; $A44E: 91 20
  LDA #$02                                            ; $A450: A9 02
  JSR Proc_D165                                       ; $A452: 20 65 D1
  LDA a:saved_candidate                               ; $A455: AD 3B 00
  STA a:candidate_idx                                 ; $A458: 8D 36 00
  RTS                                                 ; $A45B: 60
.endproc


;===============================================================================
; $A45C: IterateArmyFields
; Iterate entity record fields $11-$1A, dispatching ArmyDispatch for each
; non-$FF value. Reads a byte from the entity's data record at each offset
; and invokes army operation dispatch unless the sentinel $FF is found.
;===============================================================================
.proc IterateArmyFields
  math_acc_lo              = $0020
  entity_idx               = $003A
  dispatch_val             = $003B
  field_offset             = $003C

  LDA #$11                                            ; $A45C: A9 11       ; start field offset = $11
  STA a:field_offset                                  ; $A45E: 8D 3C 00
@LoadEntityPtr:
  LDA a:entity_idx                                    ; $A461: AD 3A 00    ; load entity index
  JSR Proc_D105                                       ; $A464: 20 05 D1   ; get entity data pointer -> ($20)
  LDY a:field_offset                                  ; $A467: AC 3C 00
  LDA ($20),Y                                         ; $A46A: B1 20      ; read field byte
  CMP #$FF                                            ; $A46C: C9 FF     ; $FF = sentinel (no more data)
  BEQ @SkipDispatch                                   ; $A46E: F0 06      ; skip dispatch if sentinel
  STA a:dispatch_val                                  ; $A470: 8D 3B 00   ; store value for ArmyDispatch
  JSR ArmyDispatch                                    ; $A473: 20 81 A4
@SkipDispatch:
  INC a:field_offset                                  ; $A476: EE 3C 00    ; advance to next field offset
  LDA a:field_offset                                  ; $A479: AD 3C 00
  CMP #$1B                                            ; $A47C: C9 1B     ; done when offset reaches $1B
  BCC @LoadEntityPtr                                  ; $A47E: 90 E1      ; loop for offsets $11-$1A
  RTS                                                 ; $A480: 60
.endproc


;===============================================================================
; $A481: ArmyDispatch
; Army dispatch: route army operations
;===============================================================================
.proc ArmyDispatch
  math_acc_lo              = $0020
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  entity_idx               = $003A
  dispatch_val             = $003B
  record_val               = $0040
  search_result            = $0041
  remainder_lo             = $0042
  remainder_hi             = $0043

  LDA a:entity_idx                                    ; $A481: AD 3A 00
  JSR Proc_D105                                       ; $A484: 20 05 D1
  LDA a:dispatch_val                                  ; $A487: AD 3B 00
  LDY #$08                                            ; $A48A: A0 08
  JSR $D2AB                                           ; $A48C: 20 AB D2
  STA $2A                                             ; $A48F: 85 2A
  INY                                                 ; $A491: C8
  LDA ($22),Y                                         ; $A492: B1 22
  AND #$03                                            ; $A494: 29 03
  STA $2B                                             ; $A496: 85 2B
  LDA #$E8                                            ; $A498: A9 E8
  SEC                                                 ; $A49A: 38
  SBC $2A                                             ; $A49B: E5 2A
  STA a:record_val                                    ; $A49D: 8D 40 00
  STA $2C                                             ; $A4A0: 85 2C
  LDA #$03                                            ; $A4A2: A9 03
  SBC $2B                                             ; $A4A4: E5 2B
  STA a:search_result                                 ; $A4A6: 8D 41 00
  STA $2D                                             ; $A4A9: 85 2D
  LDA $2C                                             ; $A4AB: A5 2C
  ORA $2D                                             ; $A4AD: 05 2D
  BNE @DivLoop                                        ; $A4AF: D0 01
  RTS                                                 ; $A4B1: 60
@DivLoop:
  LDY #$0C                                            ; $A4B2: A0 0C
  LDA a:record_val                                    ; $A4B4: AD 40 00
  SEC                                                 ; $A4B7: 38
  SBC ($20),Y                                         ; $A4B8: F1 20
  STA a:remainder_lo                                  ; $A4BA: 8D 42 00
  INY                                                 ; $A4BD: C8
  LDA a:search_result                                 ; $A4BE: AD 41 00
  SBC ($20),Y                                         ; $A4C1: F1 20
  STA a:remainder_hi                                  ; $A4C3: 8D 43 00
  BCC @StoreQuotient                                  ; $A4C6: 90 66
@StoreQuotient:
  LDY #$00                                            ; $A4C8: A0 00
  STY $28                                             ; $A4CA: 84 28
  STY $29                                             ; $A4CC: 84 29
@SubtractLoop:
  TYA                                                 ; $A4CE: 98
  CLC                                                 ; $A4CF: 18
  ADC #$14                                            ; $A4D0: 69 14
  TAY                                                 ; $A4D2: A8
  LDA $28                                             ; $A4D3: A5 28
  CLC                                                 ; $A4D5: 18
  ADC #$64                                            ; $A4D6: 69 64
  STA $28                                             ; $A4D8: 85 28
  LDA $29                                             ; $A4DA: A5 29
  ADC #$00                                            ; $A4DC: 69 00
  STA $29                                             ; $A4DE: 85 29
@Subtract100:
  LDA a:remainder_lo                                  ; $A4E0: AD 42 00
  SEC                                                 ; $A4E3: 38
  SBC #$64                                            ; $A4E4: E9 64
  STA a:remainder_lo                                  ; $A4E6: 8D 42 00
  LDA a:remainder_hi                                  ; $A4E9: AD 43 00
  SBC #$00                                            ; $A4EC: E9 00
  STA a:remainder_hi                                  ; $A4EE: 8D 43 00
  BCS @SubtractLoop                                   ; $A4F1: B0 DA
  TYA                                                 ; $A4F3: 98
  STA $22                                             ; $A4F4: 85 22
  LDA #$00                                            ; $A4F6: A9 00
  STA $23                                             ; $A4F8: 85 23
  LDA #$00                                            ; $A4FA: A9 00
  STA $24                                             ; $A4FC: 85 24
  LDA a:entity_idx                                    ; $A4FE: AD 3A 00
  JSR Proc_D36F                                       ; $A501: 20 6F D3
  BCS @PostRender                                     ; $A504: B0 0F
  JSR TileRender                                  ; $A506: 20 5C A5
  BCS @PostRender                                     ; $A509: B0 0A
  PLA                                                 ; $A50B: 68
  PLA                                                 ; $A50C: 68
  PLA                                                 ; $A50D: 68
  PLA                                                 ; $A50E: 68
  JMP $BEC7                                           ; $A50F: 4C C7 BE
  JMP ArmyDispatch                                    ; $A512: 4C 81 A4
@PostRender:
  LDA a:entity_idx                                    ; $A515: AD 3A 00
  JSR Proc_D105                                       ; $A518: 20 05 D1
  LDY #$0C                                            ; $A51B: A0 0C
  LDA $28                                             ; $A51D: A5 28
  CLC                                                 ; $A51F: 18
  ADC ($20),Y                                         ; $A520: 71 20
  STA ($20),Y                                         ; $A522: 91 20
  INY                                                 ; $A524: C8
  LDA $29                                             ; $A525: A5 29
  ADC ($20),Y                                         ; $A527: 71 20
  STA ($20),Y                                         ; $A529: 91 20
  JSR Proc_D69D                                       ; $A52B: 20 9D D6
  LDY #$0C                                            ; $A52E: A0 0C
  LDA ($20),Y                                         ; $A530: B1 20
  SEC                                                 ; $A532: 38
  SBC a:record_val                                    ; $A533: ED 40 00
  STA ($20),Y                                         ; $A536: 91 20
  INY                                                 ; $A538: C8
  LDA ($20),Y                                         ; $A539: B1 20
  SBC a:search_result                                 ; $A53B: ED 41 00
  STA ($20),Y                                         ; $A53E: 91 20
  JSR Proc_D69D                                       ; $A540: 20 9D D6
  LDA a:dispatch_val                                  ; $A543: AD 3B 00
  LDY #$08                                            ; $A546: A0 08
  JSR $D2AB                                           ; $A548: 20 AB D2
  LDY #$08                                            ; $A54B: A0 08
  LDA #$E8                                            ; $A54D: A9 E8
  STA ($22),Y                                         ; $A54F: 91 22
  INY                                                 ; $A551: C8
  LDA #$03                                            ; $A552: A9 03
  STA ($22),Y                                         ; $A554: 91 22
  LDA #$02                                            ; $A556: A9 02
  JSR Proc_D165                                       ; $A558: 20 65 D1
  RTS                                                 ; $A55B: 60
.endproc


;===============================================================================
; $A55C: TileRender
; Render tile row to PPU
;===============================================================================
.proc TileRender
  math_acc_lo              = $0020
  work_outer_idx           = $0036
  work_limit_a             = $003A
  work_search_max          = $0045
  sram_player_id           = $6F03

  JSR Proc_D249                                       ; $A55C: 20 49 D2
  STA a:$0045                                         ; $A55F: 8D 45 00
  LDA #$00                                            ; $A562: A9 00
  STA a:$0036                                         ; $A564: 8D 36 00
  STA $2C                                             ; $A567: 85 2C
  LDA #$64                                            ; $A569: A9 64
  STA $2B                                             ; $A56B: 85 2B
  LDA #$FF                                            ; $A56D: A9 FF
  STA $2A                                             ; $A56F: 85 2A
@RowIterate:
  LDA a:$0036                                         ; $A571: AD 36 00
  CMP a:$003A                                         ; $A574: CD 3A 00
  BEQ @NextEntry                                      ; $A577: F0 26
  JSR Proc_D105                                       ; $A579: 20 05 D1
  CMP $6F03                                           ; $A57C: CD 03 6F
  BNE @NextEntry                                      ; $A57F: D0 1E
  LDY #$02                                            ; $A581: A0 02
  LDA $2B                                             ; $A583: A5 2B
  SEC                                                 ; $A585: 38
  SBC ($20),Y                                         ; $A586: F1 20
  INY                                                 ; $A588: C8
  LDA $2C                                             ; $A589: A5 2C
  SBC ($20),Y                                         ; $A58B: F1 20
  BCS @NextEntry                                      ; $A58D: B0 10
  LDY #$02                                            ; $A58F: A0 02
  LDA ($20),Y                                         ; $A591: B1 20
  STA $2B                                             ; $A593: 85 2B
  INY                                                 ; $A595: C8
  LDA ($20),Y                                         ; $A596: B1 20
  STA $2C                                             ; $A598: 85 2C
  LDA a:$0036                                         ; $A59A: AD 36 00
  STA $2A                                             ; $A59D: 85 2A
@NextEntry:
  INC a:$0036                                         ; $A59F: EE 36 00
  LDA a:$0036                                         ; $A5A2: AD 36 00
  CMP #$1E                                            ; $A5A5: C9 1E
  BCC @RowIterate                                     ; $A5A7: 90 C8
  LDA $2A                                             ; $A5A9: A5 2A
  CMP #$FF                                            ; $A5AB: C9 FF
  BNE @ClampAttr                                      ; $A5AD: D0 02
  CLC                                                 ; $A5AF: 18
  RTS                                                 ; $A5B0: 60
@ClampAttr:
  JSR Proc_D105                                       ; $A5B1: 20 05 D1
  LDY #$03                                            ; $A5B4: A0 03
  LDA ($20),Y                                         ; $A5B6: B1 20
  BNE @SkipAttr                                       ; $A5B8: D0 1B
  LDY #$02                                            ; $A5BA: A0 02
  LDA ($20),Y                                         ; $A5BC: B1 20
  CMP #$C8                                            ; $A5BE: C9 C8
  BCS @SkipSub                                        ; $A5C0: B0 13
  SEC                                                 ; $A5C2: 38
  SBC #$64                                            ; $A5C3: E9 64
  STA $2B                                             ; $A5C5: 85 2B
  LDY #$02                                            ; $A5C7: A0 02
  LDA #$64                                            ; $A5C9: A9 64
  STA ($20),Y                                         ; $A5CB: 91 20
  INY                                                 ; $A5CD: C8
  LDA #$00                                            ; $A5CE: A9 00
  STA ($20),Y                                         ; $A5D0: 91 20
  JMP @PaletteSetup                                   ; $A5D2: 4C E9 A5
@SkipAttr:
  LDY #$02                                            ; $A5D5: A0 02
  LDA ($20),Y                                         ; $A5D7: B1 20
  SEC                                                 ; $A5D9: 38
  SBC #$64                                            ; $A5DA: E9 64
  STA ($20),Y                                         ; $A5DC: 91 20
  INY                                                 ; $A5DE: C8
  LDA ($20),Y                                         ; $A5DF: B1 20
  SBC #$00                                            ; $A5E1: E9 00
  STA ($20),Y                                         ; $A5E3: 91 20
  LDA #$64                                            ; $A5E5: A9 64
  STA $2B                                             ; $A5E7: 85 2B
@PaletteSetup:
  JSR Proc_D69D                                       ; $A5E9: 20 9D D6
  LDA a:$003A                                         ; $A5EC: AD 3A 00
  JSR Proc_D105                                       ; $A5EF: 20 05 D1
  LDY #$02                                            ; $A5F2: A0 02
  LDA ($20),Y                                         ; $A5F4: B1 20
  CLC                                                 ; $A5F6: 18
  ADC $2B                                             ; $A5F7: 65 2B
  STA ($20),Y                                         ; $A5F9: 91 20
  INY                                                 ; $A5FB: C8
  LDA ($20),Y                                         ; $A5FC: B1 20
  ADC #$00                                            ; $A5FE: 69 00
  STA ($20),Y                                         ; $A600: 91 20
  JSR Proc_D69D                                       ; $A602: 20 9D D6
  LDA #$02                                            ; $A605: A9 02
  JSR Proc_D18D                                       ; $A607: 20 8D D1
  SEC                                                 ; $A60A: 38
  RTS                                                 ; $A60B: 60
.endproc

;===============================================================================
; $A60C: NameTable
; Find player entity, calculate screen position, setup scroll and display window
;===============================================================================
.proc NameTable
  math_acc_lo              = $0020
  work_outer_idx           = $0036
  work_limit_a             = $003A
  work_search_max          = $0045
  sram_player_id           = $6F03

  JSR Proc_D249                                       ; $A60C: 20 49 D2
  STA a:$0045                                         ; $A60F: 8D 45 00
  LDA #$00                                            ; $A612: A9 00
  STA a:$0036                                         ; $A614: 8D 36 00
  STA $2C                                             ; $A617: 85 2C
  LDA #$64                                            ; $A619: A9 64
  STA $2B                                             ; $A61B: 85 2B
  LDA #$FF                                            ; $A61D: A9 FF
  STA $2A                                             ; $A61F: 85 2A
@FindPlayerLoop:
  LDA a:$0036                                         ; $A621: AD 36 00
  CMP a:$003A                                         ; $A624: CD 3A 00
  BEQ @NextEntity                                     ; $A627: F0 26
  JSR Proc_D105                                       ; $A629: 20 05 D1
  CMP $6F03                                           ; $A62C: CD 03 6F
  BNE @NextEntity                                     ; $A62F: D0 1E
  LDY #$04                                            ; $A631: A0 04
  LDA $2B                                             ; $A633: A5 2B
  SEC                                                 ; $A635: 38
  SBC ($20),Y                                         ; $A636: F1 20
  INY                                                 ; $A638: C8
  LDA $2C                                             ; $A639: A5 2C
  SBC ($20),Y                                         ; $A63B: F1 20
  BCS @NextEntity                                     ; $A63D: B0 10
  LDY #$04                                            ; $A63F: A0 04
  LDA ($20),Y                                         ; $A641: B1 20
  STA $2B                                             ; $A643: 85 2B
  INY                                                 ; $A645: C8
  LDA ($20),Y                                         ; $A646: B1 20
  STA $2C                                             ; $A648: 85 2C
  LDA a:$0036                                         ; $A64A: AD 36 00
  STA $2A                                             ; $A64D: 85 2A
@NextEntity:
  INC a:$0036                                         ; $A64F: EE 36 00
  LDA a:$0036                                         ; $A652: AD 36 00
  CMP #$1E                                            ; $A655: C9 1E
  BCC @FindPlayerLoop                                 ; $A657: 90 C8
  LDA $2A                                             ; $A659: A5 2A
  CMP #$FF                                            ; $A65B: C9 FF
  BNE @AdjustWindow                                   ; $A65D: D0 02
  CLC                                                 ; $A65F: 18
  RTS                                                 ; $A660: 60
@AdjustWindow:
  JSR Proc_D105                                       ; $A661: 20 05 D1
  LDY #$05                                            ; $A664: A0 05
  LDA ($20),Y                                         ; $A666: B1 20
  BNE @ApplyScroll                                    ; $A668: D0 1B
  LDY #$04                                            ; $A66A: A0 04
  LDA ($20),Y                                         ; $A66C: B1 20
  CMP #$C8                                            ; $A66E: C9 C8
  BCS @ApplyScroll                                    ; $A670: B0 13
  SEC                                                 ; $A672: 38
  SBC #$64                                            ; $A673: E9 64
  STA $2B                                             ; $A675: 85 2B
  LDY #$04                                            ; $A677: A0 04
  LDA #$64                                            ; $A679: A9 64
  STA ($20),Y                                         ; $A67B: 91 20
  INY                                                 ; $A67D: C8
  LDA #$00                                            ; $A67E: A9 00
  STA ($20),Y                                         ; $A680: 91 20
@ApplyScroll:
  JSR Proc_D69D                                       ; $A699: 20 9D D6
  LDA a:$003A                                         ; $A69C: AD 3A 00
  JSR Proc_D105                                       ; $A69F: 20 05 D1
  LDY #$04                                            ; $A6A2: A0 04
  LDA ($20),Y                                         ; $A6A4: B1 20
  CLC                                                 ; $A6A6: 18
  ADC $2B                                             ; $A6A7: 65 2B
  STA ($20),Y                                         ; $A6A9: 91 20
  INY                                                 ; $A6AB: C8
  LDA ($20),Y                                         ; $A6AC: B1 20
  ADC #$00                                            ; $A6AE: 69 00
  STA ($20),Y                                         ; $A6B0: 91 20
  JSR Proc_D69D                                       ; $A6B2: 20 9D D6
  LDA #$02                                            ; $A6B5: A9 02
  JSR Proc_D18D                                       ; $A6B7: 20 8D D1
  SEC                                                 ; $A6BA: 38
  RTS                                                 ; $A6BB: 60
.endproc

;===============================================================================
; $A6BC: KingdomActionDispatch
; Dispatch wrapper that calls CalcKingdomTier
;===============================================================================
.proc KingdomActionDispatch

  JSR CalcKingdomTier                                 ; $A6BC: 20 C9 A6
  RTS                                                 ; $A6BF: 60
.endproc

;===============================================================================
; $A6C9: CalcKingdomTier
; Determine action tier (1-4) for current kingdom using threshold table,
; then perform army strength calculations and rendering.
;===============================================================================
.proc CalcKingdomTier
  ThresholdTable:                                      ; $A6C0: 9 bytes, 3 rows x 3 cols
    .byte $1E,$14,$0A                                  ; $A6C0: tier thresholds col 0
    .byte $3C,$32,$28                                  ; $A6C3: tier thresholds col 1
    .byte $5A,$50,$46                                  ; $A6C6: tier thresholds col 2
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  work_inner_idx           = $0037
  work_sub_idx             = $0039
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C
  work_temp_1              = $003D
  work_temp_2              = $003E
  sram_kingdom_index       = $6F02

  LDA a:$003A                                         ; $A6C9: AD 3A 00
  JSR Proc_D304                                       ; $A6CC: 20 04 D3
  STA a:$0039                                         ; $A6CF: 8D 39 00
  LDA #$01                                            ; $A6D2: A9 01
  STA a:$0037                                         ; $A6D4: 8D 37 00
  LDA #$64                                            ; $A6D7: A9 64
  JSR Proc_D4BB                                       ; $A6D9: 20 BB D4
  LDY $6F02                                           ; $A6DC: AC 02 6F
  LDX #$04                                            ; $A6DF: A2 04
  CMP ThresholdTable,Y                                ; $A6E1: D9 C0 A6
  BCC @StoreTier                                      ; $A6E4: 90 0D
  DEX                                                 ; $A6E6: CA
  CMP ThresholdTable+3,Y                              ; $A6E7: D9 C3 A6
  BCC @StoreTier                                      ; $A6EA: 90 07
  DEX                                                 ; $A6EC: CA
  CMP ThresholdTable+6,Y                              ; $A6ED: D9 C6 A6
  BCC @StoreTier                                      ; $A6F0: 90 01
  DEX                                                 ; $A6F2: CA
@StoreTier:
  STX $20                                             ; $A6F3: 86 20
  LDA a:$0039                                         ; $A6F5: AD 39 00
  SEC                                                 ; $A6F8: 38
  SBC $20                                             ; $A6F9: E5 20
  BCC @ClampResult                                    ; $A6FB: 90 05
  BEQ @ClampResult                                    ; $A6FD: F0 03
  STA a:$0037                                         ; $A6FF: 8D 37 00
@ClampResult:
  JSR CalcKingdomTierWorkPtr                          ; $A702: 20 4A A7
@RenderLoop:
  LDA a:$003A                                         ; $A705: AD 3A 00
  JSR Proc_D105                                       ; $A708: 20 05 D1
  LDY #$02                                            ; $A70B: A0 02
  LDA ($20),Y                                         ; $A70D: B1 20
  SEC                                                 ; $A70F: 38
  SBC a:$003D                                         ; $A710: ED 3D 00
  INY                                                 ; $A713: C8
  LDA ($20),Y                                         ; $A714: B1 20
  SBC a:$003E                                         ; $A716: ED 3E 00
  BCS @SubtractLimitB                                 ; $A719: B0 0C
  JSR TileRender                                      ; $A71B: 20 5C A5
  BCS @RenderLoop                                     ; $A71E: B0 E5
  PLA                                                 ; $A720: 68
  PLA                                                 ; $A721: 68
  PLA                                                 ; $A722: 68
  PLA                                                 ; $A723: 68
  JMP JumpToBEC7                                      ; $A724: 4C C7 BE
@SubtractLimitB:
  LDA a:$003A                                         ; $A727: AD 3A 00
  JSR Proc_D105                                       ; $A72A: 20 05 D1
  LDY #$04                                            ; $A72D: A0 04
  LDA ($20),Y                                         ; $A72F: B1 20
  SEC                                                 ; $A731: 38
  SBC a:$003B                                         ; $A732: ED 3B 00
  INY                                                 ; $A735: C8
  LDA ($20),Y                                         ; $A736: B1 20
  SBC a:$003C                                         ; $A738: ED 3C 00
  BCS @Exit                                           ; $A73B: B0 0C
  JSR NameTable                                       ; $A73D: 20 0C A6
  BCS @SubtractLimitB                                 ; $A740: B0 E5
  PLA                                                 ; $A742: 68
  PLA                                                 ; $A743: 68
  PLA                                                 ; $A744: 68
  PLA                                                 ; $A745: 68
  JMP JumpToBEC7                                      ; $A746: 4C C7 BE
@Exit:
  RTS                                                 ; $A749: 60
.endproc

;===============================================================================
; $A74A: CalcKingdomTierWorkPtr
; Compute two work pointers from limit values for kingdom tier processing
;===============================================================================
.proc CalcKingdomTierWorkPtr
  work_inner_idx           = $0037
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C
  work_temp_1              = $003D
  work_temp_2              = $003E

  LDA a:$0037                                         ; $A74A: AD 37 00
  STA $20                                             ; $A74D: 85 20
  LDA #$78                                            ; $A74F: A9 78
  STA $21                                             ; $A751: 85 21
  JSR Proc_D471                                       ; $A753: 20 71 D4
  LDA $2A                                             ; $A756: A5 2A
  STA a:$003B                                         ; $A758: 8D 3B 00
  LDA $2B                                             ; $A75B: A5 2B
  STA a:$003C                                         ; $A75D: 8D 3C 00
  LDA a:$0037                                         ; $A760: AD 37 00
  STA $20                                             ; $A763: 85 20
  LDA #$64                                            ; $A765: A9 64
  STA $21                                             ; $A767: 85 21
  JSR Proc_D471                                       ; $A769: 20 71 D4
  LDA #$64                                            ; $A76C: A9 64
  JSR Proc_D4BB                                       ; $A76E: 20 BB D4
  STA $21                                             ; $A771: 85 21
  JSR B1F_RandomByte2                                 ; $A773: 20 8A E8
  CMP #$80                                            ; $A776: C9 80
  BPL @PositiveDelta                                  ; $A778: 10 12
  LDA $2A                                             ; $A77A: A5 2A
  SEC                                                 ; $A77C: 38
  SBC $21                                             ; $A77D: E5 21
  STA a:$003D                                         ; $A77F: 8D 3D 00
  LDA $2B                                             ; $A782: A5 2B
  SBC #$00                                            ; $A784: E9 00
  STA a:$003E                                         ; $A786: 8D 3E 00
  JMP @DeadTarget                                     ; $A789: 4C 9B A7
@PositiveDelta:
  LDA $2A                                             ; $A78C: A5 2A
  CLC                                                 ; $A78E: 18
  ADC $21                                             ; $A78F: 65 21
  STA a:$003D                                         ; $A791: 8D 3D 00
  LDA $2B                                             ; $A794: A5 2B
  ADC #$00                                            ; $A796: 69 00
  STA a:$003E                                         ; $A798: 8D 3E 00
@DeadTarget:
  RTS                                                 ; $A79B: 60
.endproc


;===============================================================================
; $A79C: ResolveKingdomAbsorb
; Resolves a kingdom absorption between entity A ($003A) and entity B ($0038).
; Subtracts costs from A's fields, extracts B's best-scoring entry and items,
; sets up display/battle state, and updates game flags.
;===============================================================================
.proc ResolveKingdomAbsorb
  math_acc_lo              = $0020
  math_acc_mhi             = $0022
  math_ext                 = $0024
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C
  work_temp_1              = $003D
  work_temp_2              = $003E
  sram_player_id           = $6F03
  sram_game_start_flag     = $6F8B

  LDA a:$003A                                         ; $A79C: AD 3A 00
  JSR Proc_D105                                       ; $A79F: 20 05 D1
  LDY #$02                                            ; $A7A2: A0 02
  LDA ($20),Y                                         ; $A7A4: B1 20
  SEC                                                 ; $A7A6: 38
  SBC a:$003D                                         ; $A7A7: ED 3D 00
  STA ($20),Y                                         ; $A7AA: 91 20
  INY                                                 ; $A7AC: C8
  LDA ($20),Y                                         ; $A7AD: B1 20
  SBC a:$003E                                         ; $A7AF: ED 3E 00
  STA ($20),Y                                         ; $A7B2: 91 20
  LDY #$04                                            ; $A7B4: A0 04
  LDA ($20),Y                                         ; $A7B6: B1 20
  SEC                                                 ; $A7B8: 38
  SBC a:$003B                                         ; $A7B9: ED 3B 00
  STA ($20),Y                                         ; $A7BC: 91 20
  INY                                                 ; $A7BE: C8
  LDA ($20),Y                                         ; $A7BF: B1 20
  SBC a:$003C                                         ; $A7C1: ED 3C 00
  STA ($20),Y                                         ; $A7C4: 91 20
  LDY #$78                                            ; $A7C6: A0 78
  LDA #$FF                                            ; $A7C8: A9 FF
@FillBuffer:
  STA $0600,Y                                         ; $A7CA: 99 00 06
  DEY                                                 ; $A7CD: 88
  BPL @FillBuffer                                     ; $A7CE: 10 FA
  LDA a:$003A                                         ; $A7D0: AD 3A 00
  JSR Proc_D105                                       ; $A7D3: 20 05 D1
  LDA #$00                                            ; $A7D6: A9 00
  STA $2A                                             ; $A7D8: 85 2A
@SearchLoop:
  LDA #$11                                            ; $A7DA: A9 11
  STA $2B                                             ; $A7DC: 85 2B
  LDA #$00                                            ; $A7DE: A9 00
  STA $2C                                             ; $A7E0: 85 2C
  LDA #$FF                                            ; $A7E2: A9 FF
  STA $2D                                             ; $A7E4: 85 2D
  LDY $2B                                             ; $A7E6: A4 2B
  LDA ($20),Y                                         ; $A7E8: B1 20
  CMP #$FF                                            ; $A7EA: C9 FF
  BEQ @ExtractEntries                                 ; $A7EC: F0 1D
  LDY #$03                                            ; $A7EE: A0 03
  JSR Proc_D283                                       ; $A7F0: 20 AB D2
  CMP #$64                                            ; $A7F3: C9 64
  BEQ @UpdateBest                                     ; $A7F5: F0 14
  LDY #$01                                            ; $A7F7: A0 01
  LDA ($22),Y                                         ; $A7F9: B1 22
  LSR A                                               ; $A7FB: 4A
  LDY #$03                                            ; $A7FC: A0 03
  CLC                                                 ; $A7FE: 18
  ADC ($22),Y                                         ; $A7FF: 71 22
  CMP $2C                                             ; $A801: C5 2C
  BCC @NextEntry                                      ; $A803: 90 06
  STA $2C                                             ; $A805: 85 2C
  LDA $2B                                             ; $A807: A5 2B
  STA $2D                                             ; $A809: 85 2D
@NextEntry:
  INC $2B                                             ; $A80B: E6 2B
  LDA $2B                                             ; $A80D: A5 2B
  CMP #$1B                                            ; $A80F: C9 1B
  BCC @SearchLoop                                     ; $A811: 90 D3
  LDY $2D                                             ; $A813: A4 2D
  LDA ($20),Y                                         ; $A815: B1 20
  PHA                                                 ; $A817: 48
  LDA #$FF                                            ; $A818: A9 FF
  STA ($20),Y                                         ; $A81A: 91 20
  PLA                                                 ; $A81C: 68
  LDY $2A                                             ; $A81D: A4 2A
  STA $066E,Y                                         ; $A81F: 99 6E 06
  INC $2A                                             ; $A822: E6 2A
  LDY $2A                                             ; $A824: A4 2A
  CPY a:$0037                                         ; $A826: CC 37 00
  BCC @SearchLoop                                     ; $A829: 90 AF
@ExtractEntries:
  LDA a:$003A                                         ; $A82B: AD 3A 00
  JSR Proc_D3DD                                       ; $A82E: 20 DD D3
  LDA a:$0038                                         ; $A831: AD 38 00
  JSR Proc_D105                                       ; $A834: 20 05 D1
  LDX #$00                                            ; $A837: A2 00
  LDY #$11                                            ; $A839: A0 11
  LDA ($20),Y                                         ; $A83B: B1 20
  CMP #$FF                                            ; $A83D: C9 FF
  BEQ @CopyPosition                                  ; $A83F: F0 0D
  STA $0664,X                                         ; $A841: 9D 64 06
  LDA #$FF                                            ; $A844: A9 FF
  STA ($20),Y                                         ; $A846: 91 20
  INX                                                 ; $A848: E8
  INY                                                 ; $A849: C8
  CPY #$1B                                            ; $A84A: C0 1B
  BCC @ExtractEntries                                 ; $A84C: 90 ED
@CopyPosition:
  LDY #$02                                            ; $A84E: A0 02
  LDA ($20),Y                                         ; $A850: B1 20
  STA $0526                                           ; $A852: 8D 26 05
  INY                                                 ; $A855: C8
  LDA ($20),Y                                         ; $A856: B1 20
  STA $0527                                           ; $A858: 8D 27 05
  INY                                                 ; $A85B: C8
  LDA ($20),Y                                         ; $A85C: B1 20
  STA $0522                                           ; $A85E: 8D 22 05
  INY                                                 ; $A861: C8
  LDA ($20),Y                                         ; $A862: B1 20
  STA $0523                                           ; $A864: 8D 23 05
  LDY #$02                                            ; $A867: A0 02
  LDA #$00                                            ; $A869: A9 00
  STA ($20),Y                                         ; $A86B: 91 20
  INY                                                 ; $A86D: C8
  STA ($20),Y                                         ; $A86E: 91 20
  INY                                                 ; $A870: C8
  STA ($20),Y                                         ; $A871: 91 20
  INY                                                 ; $A873: C8
  STA ($20),Y                                         ; $A874: 91 20
  LDA $6F03                                           ; $A876: AD 03 6F
  ASL A                                               ; $A879: 0A
  ASL A                                               ; $A87A: 0A
  ASL A                                               ; $A87B: 0A
  ASL A                                               ; $A87C: 0A
  STA $22                                             ; $A87D: 85 22
  LDY #$00                                            ; $A87F: A0 00
  LDA ($20),Y                                         ; $A881: B1 20
  AND #$07                                            ; $A883: 29 07
  ORA $22                                             ; $A885: 05 22
  STA $0507                                           ; $A887: 8D 07 05
  LDA a:$0038                                         ; $A88A: AD 38 00
  STA $050E                                           ; $A88D: 8D 0E 05
  LDA a:$003A                                         ; $A890: AD 3A 00
  STA $0402                                           ; $A893: 8D 02 04
  LDA a:$003B                                         ; $A896: AD 3B 00
  STA $0524                                           ; $A899: 8D 24 05
  LDA a:$003C                                         ; $A89C: AD 3C 00
  STA $0525                                           ; $A89F: 8D 25 05
  LDA a:$003D                                         ; $A8A2: AD 3D 00
  STA $0528                                           ; $A8A5: 8D 28 05
  LDA a:$003E                                         ; $A8A8: AD 3E 00
  STA $0529                                           ; $A8AB: 8D 29 05
  LDA a:$0038                                         ; $A8AE: AD 38 00
  JSR Proc_D105                                       ; $A8B1: 20 05 D1
  JSR Proc_D319                                       ; $A8B4: 20 19 D3
  LDY #$03                                            ; $A8B7: A0 03
  LDA ($24),Y                                         ; $A8B9: B1 24
  CMP #$03                                            ; $A8BB: C9 03
  BEQ @Finalize                                       ; $A8BD: F0 0D
  PLA                                                 ; $A8BF: 68
  PLA                                                 ; $A8C0: 68
  LDA #$FE                                            ; $A8C1: A9 FE
  STA $6F8B                                           ; $A8C3: 8D 8B 6F
  LDA #$00                                            ; $A8C6: A9 00
  STA $6F8D                                           ; $A8C8: 8D 8D 6F
  RTS                                                 ; $A8CB: 60
@Finalize:
  JSR $ACD5                                           ; $A8CC: 20 D5 AC
  PLA                                                 ; $A8CF: 68
  PLA                                                 ; $A8D0: 68
  LDA #$FD                                            ; $A8D1: A9 FD
  STA $6F8B                                           ; $A8D3: 8D 8B 6F
  RTS                                                 ; $A8D6: 60
.endproc


;===============================================================================
; $A8D7: InitNewGameContext
;===============================================================================
.proc InitNewGameContext
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026
  math_temp3               = $0027
  work_outer_idx           = $0036
  work_inner_idx2          = $0038
  work_temp_0              = $003C
  work_temp_1              = $003D
  work_temp_2              = $003E
  work_record_idx          = $003F
  work_record_val          = $0040
  work_search_result       = $0041
  sram_player_id           = $6F03

  LDA $6F8C                                           ; $A8D7: AD 8C 6F  new game flag (0=new)
  BNE @SkipNewGamePrep                                ; $A8DA: D0 03
  JSR Proc_CD68                                       ; $A8DC: 20 68 CD
@SkipNewGamePrep:                                     ; $A8DF
  LDA a:$0038                                         ; $A8DF: AD 38 00
  JSR Proc_D105                                       ; $A8E2: 20 05 D1
  STA a:$003E                                         ; $A8E5: 8D 3E 00
  JSR @ClearGameStateVars                             ; $A8E8: 20 1F A9
  JSR @CountRecords                                       ; $A8EB: 20 CC A9
  JSR @AdjustGold                                     ; $A8EE: 20 9C AF
  LDA $6F8C                                           ; $A8F1: AD 8C 6F
  BNE @ContinueGamePath                               ; $A8F4: D0 1D
  ; --- New game path ---
  JSR @PlaceNewArmies                                       ; $A8F6: 20 80 AA
  JSR @SubtractBattleCosts                                       ; $A8F9: 20 67 AC
  LDA a:$0038                                         ; $A8FC: AD 38 00
  JSR Proc_D105                                       ; $A8FF: 20 05 D1
  LDY #$00                                            ; $A902: A0 00
  LDA ($20),Y                                         ; $A904: B1 20
  AND #$F8                                            ; $A906: 29 F8
  ORA sram_player_id                                  ; $A908: 0D 03 6F
  STA ($20),Y                                         ; $A90B: 91 20
  JSR Proc_D249                                       ; $A90D: 20 49 D2
  JMP $CA19                                           ; $A910: 4C 19 CA
  ; --- Continue existing game path ---
@ContinueGamePath:                                    ; $A913
  JSR @PlaceNewEnemies                                       ; $A913: 20 10 AB
  JSR @SubtractBattleCosts                                       ; $A916: 20 67 AC
  JSR Proc_D249                                       ; $A919: 20 49 D2
  JMP $CA19                                           ; $A91C: 4C 19 CA
@ClearGameStateVars:                                   ; $A91F
  LDA #$00                                            ; $A91F: A9 00
  STA $6F73                                           ; $A921: 8D 73 6F
  STA $6F74                                           ; $A924: 8D 74 6F
  STA $6F75                                           ; $A927: 8D 75 6F
  STA $6F76                                           ; $A92A: 8D 76 6F
  STA $6F77                                           ; $A92D: 8D 77 6F
  STA $6F78                                           ; $A930: 8D 78 6F
  LDA #$00                                            ; $A933: A9 00
  STA a:$0040                                         ; $A935: 8D 40 00
@RecordLoopBody:
  LDY a:$0040                                         ; $A938: AC 40 00
  LDA $0664,Y                                         ; $A93B: B9 64 06
  CMP #$FF                                            ; $A93E: C9 FF
  BNE @ProcessRecord                                                                           ; $A940: D0 03 (BNE mid-instruction target)
  JMP @NextRecordIter                                       ; $A942: 4C BE A9
@ProcessRecord:
  PHA                                                 ; $A945: 48
  LDY #$00                                            ; $A946: A0 00
  JSR $D2AB                                           ; $A948: 20 AB D2
  PHA                                                 ; $A94B: 48
  LDY #$08                                            ; $A94C: A0 08
  LDA ($22),Y                                         ; $A94E: B1 22
  STA $20                                             ; $A950: 85 20
  STA $30                                             ; $A952: 85 30
  INY                                                 ; $A954: C8
  LDA ($22),Y                                         ; $A955: B1 22
  AND #$03                                            ; $A957: 29 03
  STA $21                                             ; $A959: 85 21
  STA $31                                             ; $A95B: 85 31
  PLA                                                 ; $A95D: 68
  STA $23                                             ; $A95E: 85 23
  LDA #$00                                            ; $A960: A9 00
  STA $22                                             ; $A962: 85 22
  JSR Proc_D438                                       ; $A964: 20 38 D4
  LDA $26                                             ; $A967: A5 26
  STA $20                                             ; $A969: 85 20
  LDA $27                                             ; $A96B: A5 27
  STA $21                                             ; $A96D: 85 21
  LDA $28                                             ; $A96F: A5 28
  STA $22                                             ; $A971: 85 22
  LDA #$64                                            ; $A973: A9 64
  STA $23                                             ; $A975: 85 23
  LDA #$00                                            ; $A977: A9 00
  STA $24                                             ; $A979: 85 24
  JSR Proc_D336                                       ; $A97B: 20 36 D3
  PLA                                                 ; $A97E: 68
  LDY #$00                                            ; $A97F: A0 00
  JSR $D2AB                                           ; $A981: 20 AB D2
  LDY #$08                                            ; $A984: A0 08
  LDA $20                                             ; $A986: A5 20
  STA ($22),Y                                         ; $A988: 91 22
  INY                                                 ; $A98A: C8
  LDA ($22),Y                                         ; $A98B: B1 22
  AND #$FC                                            ; $A98D: 29 FC
  ORA $21                                             ; $A98F: 05 21
  STA ($22),Y                                         ; $A991: 91 22
  LDA $30                                             ; $A993: A5 30
  SEC                                                 ; $A995: 38
  SBC $20                                             ; $A996: E5 20
  STA $30                                             ; $A998: 85 30
  LDA $31                                             ; $A99A: A5 31
  SBC $21                                             ; $A99C: E5 21
  STA $31                                             ; $A99E: 85 31
  BCC @NextRecordIter                                                                          ; $A9A0: 90 1C (BCC cross-proc)
  LDY #$00                                            ; $A9A2: A0 00
  LDA a:$0040                                         ; $A9A4: AD 40 00
  CMP #$0A                                            ; $A9A7: C9 0A
  BCC @ClampIndexLo                                           ; $A9A9: 90 02
  LDY #$02                                            ; $A9AB: A0 02
@ClampIndexLo:
  LDA $30                                             ; $A9AD: A5 30
  CLC                                                 ; $A9AF: 18
  ADC $6F73,Y                                         ; $A9B0: 79 73 6F
  STA $6F73,Y                                         ; $A9B3: 99 73 6F
  LDA $31                                             ; $A9B6: A5 31
  ADC $6F74,Y                                         ; $A9B8: 79 74 6F
  STA $6F74,Y                                         ; $A9BB: 99 74 6F

@NextRecordIter:
  INC a:$0040                                         ; $A9BE: EE 40 00
  LDA a:$0040                                         ; $A9C1: AD 40 00
  CMP #$14                                            ; $A9C4: C9 14
  BCS @ClearExit                                                                               ; $A9C6: B0 03 (BCS mid-instruction target)
  JMP @RecordLoopBody                                       ; $A9C8: 4C 38 A9
@ClearExit:
  RTS                                                 ; $A9CB: 60

@CountRecords:
  LDY #$00                                            ; $A9CC: A0 00
  LDX #$00                                            ; $A9CE: A2 00
@CountArmyLoop:
  LDA $0664,Y                                         ; $A9D0: B9 64 06
  CMP #$FF                                            ; $A9D3: C9 FF
  BEQ @CountArmyNext                                           ; $A9D5: F0 01
  INX                                                 ; $A9D7: E8
@CountArmyNext:
  INY                                                 ; $A9D8: C8
  CPY #$0A                                            ; $A9D9: C0 0A
  BCC @CountArmyLoop                                           ; $A9DB: 90 F3
  STX a:$003C                                         ; $A9DD: 8E 3C 00
  LDY #$00                                            ; $A9E0: A0 00
  LDX #$00                                            ; $A9E2: A2 00
@CountEnemyLoop:
  LDA $066E,Y                                         ; $A9E4: B9 6E 06
  CMP #$FF                                            ; $A9E7: C9 FF
  BEQ @CountEnemyNext                                           ; $A9E9: F0 01
  INX                                                 ; $A9EB: E8
@CountEnemyNext:
  INY                                                 ; $A9EC: C8
  CPY #$0A                                            ; $A9ED: C0 0A
  BCC @CountEnemyLoop                                           ; $A9EF: 90 F3
  STX a:$003D                                         ; $A9F1: 8E 3D 00
  LDA a:$003C                                         ; $A9F4: AD 3C 00
  CMP #$05                                            ; $A9F7: C9 05
  BCC @CheckEnemyCount                                           ; $A9F9: 90 15
  LSR A                                               ; $A9FB: 4A
  LSR A                                               ; $A9FC: 4A
  CMP #$00                                            ; $A9FD: C9 00
  BEQ @CheckEnemyCount                                           ; $A9FF: F0 0F
  STA $6F77                                           ; $AA01: 8D 77 6F
@AllocArmyLoop:
  PHA                                                 ; $AA04: 48
  LDA #$00                                            ; $AA05: A9 00
  JSR @FindWeakestSlot                                       ; $AA07: 20 2D AA
  PLA                                                 ; $AA0A: 68
  SEC                                                 ; $AA0B: 38
  SBC #$01                                            ; $AA0C: E9 01
  BNE @AllocArmyLoop                                           ; $AA0E: D0 F4
@CheckEnemyCount:
  LDA a:$003D                                         ; $AA10: AD 3D 00
  CMP #$05                                            ; $AA13: C9 05
  BCC @AllocDone                                           ; $AA15: 90 15
  LSR A                                               ; $AA17: 4A
  LSR A                                               ; $AA18: 4A
  CMP #$00                                            ; $AA19: C9 00
  BEQ @AllocDone                                           ; $AA1B: F0 0F
  STA $6F78                                           ; $AA1D: 8D 78 6F
@AllocEnemyLoop:
  PHA                                                 ; $AA20: 48
  LDA #$0A                                            ; $AA21: A9 0A
  JSR @FindWeakestSlot                                       ; $AA23: 20 2D AA
  PLA                                                 ; $AA26: 68
  SEC                                                 ; $AA27: 38
  SBC #$01                                            ; $AA28: E9 01
  BNE @AllocEnemyLoop                                           ; $AA2A: D0 F4
@AllocDone:
  RTS                                                 ; $AA2C: 60

@FindWeakestSlot:
  STA $24                                             ; $AA2D: 85 24
  LDA #$FF                                            ; $AA2F: A9 FF
  STA $25                                             ; $AA31: 85 25
  STA $26                                             ; $AA33: 85 26
  LDA #$00                                            ; $AA35: A9 00
  STA $27                                             ; $AA37: 85 27
@FindWeakestArmyLoop:
  LDY $24                                             ; $AA39: A4 24
  LDA $0664,Y                                         ; $AA3B: B9 64 06
  CMP #$FF                                            ; $AA3E: C9 FF
  BEQ @SkipToStore                                                                             ; $AA40: F0 1C (BEQ mid-instruction target)
  LDY #$03                                            ; $AA42: A0 03
  JSR $D2AB                                           ; $AA44: 20 AB D2
  CMP #$64                                            ; $AA47: C9 64
  BEQ @SkipToStore                                                                             ; $AA49: F0 13 (BEQ mid-instruction target)
  LDY #$01                                            ; $AA4B: A0 01
  LDA ($22),Y                                         ; $AA4D: B1 22
  LDY #$02                                            ; $AA4F: A0 02
  CLC                                                 ; $AA51: 18
  ADC ($22),Y                                         ; $AA52: 71 22
  CMP $25                                             ; $AA54: C5 25
  BCS @SkipToStore                                                                             ; $AA56: B0 06 (BCS mid-instruction target)
  STA $25                                             ; $AA58: 85 25
  LDA $24                                             ; $AA5A: A5 24
  STA $26                                             ; $AA5C: 85 26
@SkipToStore:
  INC $24                                             ; $AA5E: E6 24
  INC $27                                             ; $AA60: E6 27
  LDA $27                                             ; $AA62: A5 27
  CMP #$0A                                            ; $AA64: C9 0A
  BCC @FindWeakestArmyLoop                                           ; $AA66: 90 D1
  LDY $26                                             ; $AA68: A4 26
  LDA $0664,Y                                         ; $AA6A: B9 64 06
  PHA                                                 ; $AA6D: 48
  LDA #$FF                                            ; $AA6E: A9 FF
  STA $0664,Y                                         ; $AA70: 99 64 06
  PLA                                                 ; $AA73: 68
  LDY #$0B                                            ; $AA74: A0 0B
  JSR $D2AB                                           ; $AA76: 20 AB D2
  AND #$FC                                            ; $AA79: 29 FC
  ORA #$03                                            ; $AA7B: 09 03
  STA ($22),Y                                         ; $AA7D: 91 22
  RTS                                                 ; $AA7F: 60

@PlaceNewArmies:
  LDA a:$0038                                         ; $AA80: AD 38 00
  JSR Proc_D105                                       ; $AA83: 20 05 D1
  LDX #$00                                            ; $AA86: A2 00
  LDY #$11                                            ; $AA88: A0 11
  LDA $066E,X                                         ; $AA8A: BD 6E 06
  CMP #$FF                                            ; $AA8D: C9 FF
  BEQ @SkipBattleSlot                                                                          ; $AA8F: F0 03 (BEQ mid-instruction target)
  STA ($20),Y                                         ; $AA91: 91 20
  INY                                                 ; $AA93: C8
@SkipBattleSlot:
  INX                                                 ; $AA94: E8
  CPX #$0A                                            ; $AA95: E0 0A
  BCC @BattleArmyLoop                                                                          ; $AA97: 90 F1 (BCC mid-instruction target)
  LDY #$00                                            ; $AA99: A0 00
  STY $24                                             ; $AA9B: 84 24
@BattleArmyLoop:
  LDY $24                                             ; $AA9D: A4 24
  LDA $0664,Y                                         ; $AA9F: B9 64 06
  CMP #$FF                                            ; $AAA2: C9 FF
  BEQ @BattleSearchNext                                           ; $AAA4: F0 2F
  STA $26                                             ; $AAA6: 85 26
  LDY #$03                                            ; $AAA8: A0 03
  JSR $D2AB                                           ; $AAAA: 20 AB D2
  CMP #$64                                            ; $AAAD: C9 64
  BEQ @BattleSearchStore                                           ; $AAAF: F0 11
  STA $25                                             ; $AAB1: 85 25
  LDA #$64                                            ; $AAB3: A9 64
  JSR Proc_D4BB                                       ; $AAB5: 20 BB D4
  CMP $25                                             ; $AAB8: C5 25
  BCC @BattleSearchStore                                           ; $AABA: 90 06
  JSR @InsertBattleSlot                                  ; $AABC: 20 DE AA
  JMP @BattleSearchNext                                           ; $AABF: 4C D5 AA
@BattleSearchStore:
  LDA a:$003E                                         ; $AAC2: AD 3E 00
  STA a:$0040                                         ; $AAC5: 8D 40 00
  LDA $26                                             ; $AAC8: A5 26
  STA a:$0041                                         ; $AACA: 8D 41 00
  LDA #$01                                            ; $AACD: A9 01
  STA a:$0042                                         ; $AACF: 8D 42 00
  JSR @FindBestTarget                                       ; $AAD2: 20 A3 AB
@BattleSearchNext:
  INC $24                                             ; $AAD5: E6 24
  LDA $24                                             ; $AAD7: A5 24
  CMP #$0A                                            ; $AAD9: C9 0A
  BCC @BattleArmyLoop                                                                          ; $AADB: 90 C0 (BCC mid-instruction target)
  RTS                                                 ; $AADD: 60

@InsertBattleSlot:
  LDA a:$0038                                         ; $AADE: AD 38 00
  JSR Proc_D105                                       ; $AAE1: 20 05 D1
  LDY #$11                                            ; $AAE4: A0 11
@BattleSlotLoop:
  LDA ($20),Y                                         ; $AAE6: B1 20
  CMP #$FF                                            ; $AAE8: C9 FF
  BEQ @ArmySlotFound                                           ; $AAEA: F0 18
  INY                                                 ; $AAEC: C8
  CPY #$1B                                            ; $AAED: C0 1B
  BCC @BattleSlotLoop                                                                          ; $AAEF: 90 F5 (BCC mid-instruction target)
  LDA $6F03                                           ; $AAF1: AD 03 6F
  STA a:$0040                                         ; $AAF4: 8D 40 00
  LDA $26                                             ; $AAF7: A5 26
  STA a:$0041                                         ; $AAF9: 8D 41 00
  LDA #$00                                            ; $AAFC: A9 00
  STA a:$0042                                         ; $AAFE: 8D 42 00
  JMP @FindBestTarget                                       ; $AB01: 4C A3 AB
@ArmySlotFound:
  LDA $26                                             ; $AB04: A5 26
  STA ($20),Y                                         ; $AB06: 91 20
  LDA $26                                             ; $AB08: A5 26
  STA $20                                             ; $AB0A: 85 20
  JSR DistanceClamp                               ; $AB0C: 20 0C D0
  RTS                                                 ; $AB0F: 60

@PlaceNewEnemies:
  LDA a:$0038                                         ; $AB10: AD 38 00
  JSR Proc_D105                                       ; $AB13: 20 05 D1
  LDX #$00                                            ; $AB16: A2 00
  LDY #$11                                            ; $AB18: A0 11
  LDA $0664,X                                         ; $AB1A: BD 64 06
  CMP #$FF                                            ; $AB1D: C9 FF
  BEQ @SkipEnemySlot                                                                           ; $AB1F: F0 03 (BEQ mid-instruction target)
  STA ($20),Y                                         ; $AB21: 91 20
  INY                                                 ; $AB23: C8
@SkipEnemySlot:
  INX                                                 ; $AB24: E8
  CPX #$0A                                            ; $AB25: E0 0A
  BCC @BattleEnemyLoop                                                                         ; $AB27: 90 F1 (BCC mid-instruction target)
  LDY #$00                                            ; $AB29: A0 00
  STY $24                                             ; $AB2B: 84 24
@BattleEnemyLoop:
  LDY $24                                             ; $AB2D: A4 24
  LDA $066E,Y                                         ; $AB2F: B9 6E 06
  CMP #$FF                                            ; $AB32: C9 FF
  BEQ @EnemyBattleNext                                           ; $AB34: F0 32
  STA $26                                             ; $AB36: 85 26
  PHA                                                 ; $AB38: 48
  LDA #$FF                                            ; $AB39: A9 FF
  STA $066E,Y                                         ; $AB3B: 99 6E 06
  PLA                                                 ; $AB3E: 68
  LDY #$03                                            ; $AB3F: A0 03
  JSR $D2AB                                           ; $AB41: 20 AB D2
  STA $25                                             ; $AB44: 85 25
  LDA #$64                                            ; $AB46: A9 64
  JSR Proc_D4BB                                       ; $AB48: 20 BB D4
  CMP $25                                             ; $AB4B: C5 25
  BCC @EnemyBattleStore                                           ; $AB4D: 90 06
  JSR @InsertEnemySlot                                   ; $AB4F: 20 71 AB
  JMP @EnemyBattleNext                                      ; $AB52: 4C 68 AB
@EnemyBattleStore:
  LDA $6F03                                           ; $AB55: AD 03 6F
  STA a:$0040                                         ; $AB58: 8D 40 00
  LDA $26                                             ; $AB5B: A5 26
  STA a:$0041                                         ; $AB5D: 8D 41 00
  LDA #$01                                            ; $AB60: A9 01
  STA a:$0042                                         ; $AB62: 8D 42 00
  JSR @FindBestTarget                                       ; $AB65: 20 A3 AB
@EnemyBattleNext:
  INC $24                                             ; $AB68: E6 24
  LDA $24                                             ; $AB6A: A5 24
  CMP #$0A                                            ; $AB6C: C9 0A
  BCC @BattleEnemyLoop                                                                         ; $AB6E: 90 BD (BCC mid-instruction target)
  RTS                                                 ; $AB70: 60
@InsertEnemySlot:
  LDA a:$0038                                         ; $AB71: AD 38 00
  JSR Proc_D105                                       ; $AB74: 20 05 D1
  LDY #$11                                            ; $AB77: A0 11
@EnemySlotLoop:
  LDA ($20),Y                                         ; $AB79: B1 20
  CMP #$FF                                            ; $AB7B: C9 FF
  BEQ @EnemySlotFound                                           ; $AB7D: F0 18
  INY                                                 ; $AB7F: C8
  CPY #$1B                                            ; $AB80: C0 1B
  BCC @EnemySlotLoop                                                                           ; $AB82: 90 F5 (BCC mid-instruction target)
  LDA a:$003E                                         ; $AB84: AD 3E 00
  STA a:$0040                                         ; $AB87: 8D 40 00
  LDA $26                                             ; $AB8A: A5 26
  STA a:$0041                                         ; $AB8C: 8D 41 00
  LDA #$00                                            ; $AB8F: A9 00
  STA a:$0042                                         ; $AB91: 8D 42 00
  JMP @FindBestTarget                                       ; $AB94: 4C A3 AB
@EnemySlotFound:
  LDA $26                                             ; $AB97: A5 26
  STA ($20),Y                                         ; $AB99: 91 20
  LDA $26                                             ; $AB9B: A5 26
  STA $20                                             ; $AB9D: 85 20
  JSR DistanceClamp                               ; $AB9F: 20 0C D0
  RTS                                                 ; $ABA2: 60

@FindBestTarget:
  LDY #$30                                            ; $ABA3: A0 30
  JSR B1F_SwitchBank8_A                               ; $ABA5: 20 66 F2
  LDA a:$0038                                         ; $ABA8: AD 38 00
  ASL A                                               ; $ABAB: 0A
  ASL A                                               ; $ABAC: 0A
  ASL A                                               ; $ABAD: 0A
  STA $2A                                             ; $ABAE: 85 2A
  LDA #$FF                                            ; $ABB0: A9 FF
  STA $2B                                             ; $ABB2: 85 2B
  STA $2C                                             ; $ABB4: 85 2C
  STA $2D                                             ; $ABB6: 85 2D
@ScanTargetLoop:
  LDY $2A                                             ; $ABB8: A4 2A
  LDA $9D72,Y                                         ; $ABBA: B9 72 9D
  BMI @CheckBestResult                                           ; $ABBD: 30 2F
  JSR Proc_D105                                       ; $ABBF: 20 05 D1
  CMP #$07                                            ; $ABC2: C9 07
  BNE @BestTargetCheck                                           ; $ABC4: D0 0A
  LDY $2A                                             ; $ABC6: A4 2A
  LDA $9D72,Y                                         ; $ABC8: B9 72 9D
  STA $2D                                             ; $ABCB: 85 2D
  JMP @AdvanceTarget                                           ; $ABCD: 4C E9 AB
@BestTargetCheck:
  CMP a:$0040                                         ; $ABD0: CD 40 00
  BNE @AdvanceTarget                                                                           ; $ABD3: D0 14 (BNE mid-instruction target)
  JSR $D307                                           ; $ABD5: 20 07 D3
  CMP #$0A                                            ; $ABD8: C9 0A
  BCS @AdvanceTarget                                                                           ; $ABDA: B0 0D (BCS mid-instruction target)
  CMP $2B                                             ; $ABDC: C5 2B
  BCS @AdvanceTarget                                                                           ; $ABDE: B0 09 (BCS mid-instruction target)
  STA $2B                                             ; $ABE0: 85 2B
  LDY $2A                                             ; $ABE2: A4 2A
  LDA $9D72,Y                                         ; $ABE4: B9 72 9D
  STA $2C                                             ; $ABE7: 85 2C
@AdvanceTarget:
  INC $2A                                             ; $ABE9: E6 2A
  JMP @ScanTargetLoop                                           ; $ABEB: 4C B8 AB
@CheckBestResult:
  LDA $2C                                             ; $ABEE: A5 2C
  CMP #$FF                                            ; $ABF0: C9 FF
  BEQ @ApplyBestResult                                           ; $ABF2: F0 2D
@RandomValue:
  JSR Proc_D105                                       ; $ABF4: 20 05 D1
  LDY #$11                                            ; $ABF7: A0 11
@FindSlotLoop:
  LDA ($20),Y                                         ; $ABF9: B1 20
  CMP #$FF                                            ; $ABFB: C9 FF
  BEQ @FindSlotLoop                                                                            ; $ABFD: F0 04 (BEQ mid-instruction target)
  INY                                                 ; $ABFF: C8
  JMP @FindSlotLoop                                           ; $AC00: 4C F9 AB
  LDA a:$0041                                         ; $AC03: AD 41 00
  STA ($20),Y                                         ; $AC06: 91 20
  LDY #$00                                            ; $AC08: A0 00
  LDA ($20),Y                                         ; $AC0A: B1 20
  AND #$F8                                            ; $AC0C: 29 F8
  ORA a:$0040                                         ; $AC0E: 0D 40 00
  STA ($20),Y                                         ; $AC11: 91 20
  LDA a:$0042                                         ; $AC13: AD 42 00
  BNE @SkipDistance                                                                            ; $AC16: D0 08 (BNE mid-instruction target)
  LDA a:$0041                                         ; $AC18: AD 41 00
  STA $20                                             ; $AC1B: 85 20
  JSR DistanceClamp                               ; $AC1D: 20 0C D0
@SkipDistance:
  RTS                                                 ; $AC20: 60
@ApplyBestResult:
  LDA $2D                                             ; $AC21: A5 2D
  CMP #$FF                                            ; $AC23: C9 FF
  BNE @RandomValue                                                                             ; $AC25: D0 CD (BNE mid-instruction target)
  LDA a:$0041                                         ; $AC27: AD 41 00
  LDY #$0B                                            ; $AC2A: A0 0B
  JSR $D2AB                                           ; $AC2C: 20 AB D2
  AND #$FC                                            ; $AC2F: 29 FC
  STA ($22),Y                                         ; $AC31: 91 22
@SetRandomValue:
  JSR B1F_RandomByte3                                 ; $AC33: 20 9A E8
  AND #$07                                            ; $AC36: 29 07
  BNE @ApplyRandomField                                           ; $AC38: D0 0D
  LDY #$05                                            ; $AC3A: A0 05
  LDA a:$0038                                         ; $AC3C: AD 38 00
  STA ($22),Y                                         ; $AC3F: 91 22
  LDA #$FF                                            ; $AC41: A9 FF
  STA a:$002D                                         ; $AC43: 8D 2D 00
  RTS                                                 ; $AC46: 60
@ApplyRandomField:
  STA a:$002D                                         ; $AC47: 8D 2D 00
  DEC a:$002D                                         ; $AC4A: CE 2D 00
  LDA a:$0038                                         ; $AC4D: AD 38 00
  ASL A                                               ; $AC50: 0A
  ASL A                                               ; $AC51: 0A
  ASL A                                               ; $AC52: 0A
  CLC                                                 ; $AC53: 18
  ADC a:$002D                                         ; $AC54: 6D 2D 00
  TAY                                                 ; $AC57: A8
  LDA $9D72,Y                                         ; $AC58: B9 72 9D
  BMI @SetRandomValue                                           ; $AC5B: 30 D6
  LDY #$05                                            ; $AC5D: A0 05
  STA ($22),Y                                         ; $AC5F: 91 22
  LDA #$FF                                            ; $AC61: A9 FF
  STA a:$002D                                         ; $AC63: 8D 2D 00
  RTS                                                 ; $AC66: 60

@SubtractBattleCosts:
  JSR @SumAllResources                                       ; $AC67: 20 BF AE
  LDA $0522                                           ; $AC6A: AD 22 05
  SEC                                                 ; $AC6D: 38
  SBC $2A                                             ; $AC6E: E5 2A
  STA $0522                                           ; $AC70: 8D 22 05
  LDA $0523                                           ; $AC73: AD 23 05
  SBC $2B                                             ; $AC76: E5 2B
  STA $0523                                           ; $AC78: 8D 23 05
  BCS @NoGoldUnderflow1                                                                        ; $AC7B: B0 08 (BCS mid-instruction target)
  LDA #$00                                            ; $AC7D: A9 00
  STA $0522                                           ; $AC7F: 8D 22 05
  STA $0523                                           ; $AC82: 8D 23 05
@NoGoldUnderflow1:
  LDA $0524                                           ; $AC85: AD 24 05
  SEC                                                 ; $AC88: 38
  SBC $2C                                             ; $AC89: E5 2C
  STA $0524                                           ; $AC8B: 8D 24 05
  LDA $0525                                           ; $AC8E: AD 25 05
  SBC $2D                                             ; $AC91: E5 2D
  STA $0525                                           ; $AC93: 8D 25 05
  BCS @NoGoldUnderflow2                                                                        ; $AC96: B0 08 (BCS mid-instruction target)
  LDA #$00                                            ; $AC98: A9 00
  STA $0524                                           ; $AC9A: 8D 24 05
  STA $0525                                           ; $AC9D: 8D 25 05
@NoGoldUnderflow2:
  JSR $CE67                                           ; $ACA0: 20 67 CE
  JSR Proc_CEDD                                       ; $ACA3: 20 DD CE
  LDA a:$0038                                         ; $ACA6: AD 38 00
  JSR Proc_D105                                       ; $ACA9: 20 05 D1
  LDY #$04                                            ; $ACAC: A0 04
  LDA $0522                                           ; $ACAE: AD 22 05
  CLC                                                 ; $ACB1: 18
  ADC $0524                                           ; $ACB2: 6D 24 05
  STA ($20),Y                                         ; $ACB5: 91 20
  INY                                                 ; $ACB7: C8
  LDA $0523                                           ; $ACB8: AD 23 05
  ADC $0525                                           ; $ACBB: 6D 25 05
  STA ($20),Y                                         ; $ACBE: 91 20
  LDY #$02                                            ; $ACC0: A0 02
  LDA $0526                                           ; $ACC2: AD 26 05
  CLC                                                 ; $ACC5: 18
  ADC $0528                                           ; $ACC6: 6D 28 05
  STA ($20),Y                                         ; $ACC9: 91 20
  INY                                                 ; $ACCB: C8
  LDA $0527                                           ; $ACCC: AD 27 05
  ADC $0529                                           ; $ACCF: 6D 29 05
  STA ($20),Y                                         ; $ACD2: 91 20
  RTS                                                 ; $ACD4: 60
  LDA #$00                                            ; $ACD5: A9 00
  STA a:$003C                                         ; $ACD7: 8D 3C 00
  STA a:$003D                                         ; $ACDA: 8D 3D 00
  STA a:$003E                                         ; $ACDD: 8D 3E 00
  STA a:$003F                                         ; $ACE0: 8D 3F 00
  STA a:$0040                                         ; $ACE3: 8D 40 00
  STA a:$0041                                         ; $ACE6: 8D 41 00
  STA a:$0042                                         ; $ACE9: 8D 42 00
  STA a:$0043                                         ; $ACEC: 8D 43 00
  STA a:$0044                                         ; $ACEF: 8D 44 00
@SumEnemyLoop:
  LDY a:$0040                                         ; $ACF2: AC 40 00
  LDA $066E,Y                                         ; $ACF5: B9 6E 06
  CMP #$FF                                            ; $ACF8: C9 FF
  BEQ @SumEnemyDone                                           ; $ACFA: F0 34
  LDY #$01                                            ; $ACFC: A0 01
  JSR $D2AB                                           ; $ACFE: 20 AB D2
  CLC                                                 ; $AD01: 18
  ADC a:$0041                                         ; $AD02: 6D 41 00
  STA a:$0041                                         ; $AD05: 8D 41 00
  LDA a:$0042                                         ; $AD08: AD 42 00
  ADC #$00                                            ; $AD0B: 69 00
  STA a:$0042                                         ; $AD0D: 8D 42 00
  LDY #$08                                            ; $AD10: A0 08
  LDA ($22),Y                                         ; $AD12: B1 22
  CLC                                                 ; $AD14: 18
  ADC a:$0043                                         ; $AD15: 6D 43 00
  STA a:$0043                                         ; $AD18: 8D 43 00
  INY                                                 ; $AD1B: C8
  LDA ($22),Y                                         ; $AD1C: B1 22
  AND #$03                                            ; $AD1E: 29 03
  ADC a:$0044                                         ; $AD20: 6D 44 00
  STA a:$0044                                         ; $AD23: 8D 44 00
  INC a:$0040                                         ; $AD26: EE 40 00
  LDA a:$0040                                         ; $AD29: AD 40 00
  CMP #$0A                                            ; $AD2C: C9 0A
  BCC @SumEnemyLoop                                           ; $AD2E: 90 C2
@SumEnemyDone:
  LDA a:$0041                                         ; $AD30: AD 41 00
  STA $21                                             ; $AD33: 85 21
  LDA a:$0042                                         ; $AD35: AD 42 00
  STA $22                                             ; $AD38: 85 22
  LDA #$0A                                            ; $AD3A: A9 0A
  STA $23                                             ; $AD3C: 85 23
  LDA #$00                                            ; $AD3E: A9 00
  STA $24                                             ; $AD40: 85 24
  JSR Proc_D40F                                       ; $AD42: 20 0F D4
  LDA $21                                             ; $AD45: A5 21
  STA a:$003C                                         ; $AD47: 8D 3C 00
  LDA a:$0043                                         ; $AD4A: AD 43 00
  STA $21                                             ; $AD4D: 85 21
  LDA a:$0044                                         ; $AD4F: AD 44 00
  STA $22                                             ; $AD52: 85 22
  LDA #$64                                            ; $AD54: A9 64
  STA $23                                             ; $AD56: 85 23
  LDA #$00                                            ; $AD58: A9 00
  STA $24                                             ; $AD5A: 85 24
  JSR Proc_D40F                                       ; $AD5C: 20 0F D4
  LDA a:$003C                                         ; $AD5F: AD 3C 00
  CLC                                                 ; $AD62: 18
  ADC $21                                             ; $AD63: 65 21
  STA a:$003C                                         ; $AD65: 8D 3C 00
  LDA a:$003D                                         ; $AD68: AD 3D 00
  ADC #$00                                            ; $AD6B: 69 00
  STA a:$003D                                         ; $AD6D: 8D 3D 00
  LDA $066E                                           ; $AD70: AD 6E 06
  LDY #$07                                            ; $AD73: A0 07
  JSR $D2AB                                           ; $AD75: 20 AB D2
  LSR A                                               ; $AD78: 4A
  LSR A                                               ; $AD79: 4A
  LSR A                                               ; $AD7A: 4A
  LSR A                                               ; $AD7B: 4A
  STA $20                                             ; $AD7C: 85 20
  LDA #$0A                                            ; $AD7E: A9 0A
  STA $21                                             ; $AD80: 85 21
  JSR Proc_D471                                       ; $AD82: 20 71 D4
  LDA a:$003C                                         ; $AD85: AD 3C 00
  CLC                                                 ; $AD88: 18
  ADC $2A                                             ; $AD89: 65 2A
  STA a:$003C                                         ; $AD8B: 8D 3C 00
  LDA a:$003D                                         ; $AD8E: AD 3D 00
  ADC #$00                                            ; $AD91: 69 00
  STA a:$003D                                         ; $AD93: 8D 3D 00
  LDA #$00                                            ; $AD96: A9 00
  STA a:$0040                                         ; $AD98: 8D 40 00
  STA a:$0041                                         ; $AD9B: 8D 41 00
  STA a:$0042                                         ; $AD9E: 8D 42 00
  STA a:$0043                                         ; $ADA1: 8D 43 00
  STA a:$0044                                         ; $ADA4: 8D 44 00
@SumArmyLoop:
  LDY a:$0040                                         ; $ADA7: AC 40 00
  LDA $0664,Y                                         ; $ADAA: B9 64 06
  CMP #$FF                                            ; $ADAD: C9 FF
  BEQ @SumArmyDone                                           ; $ADAF: F0 34
  LDY #$01                                            ; $ADB1: A0 01
  JSR $D2AB                                           ; $ADB3: 20 AB D2
  CLC                                                 ; $ADB6: 18
  ADC a:$0041                                         ; $ADB7: 6D 41 00
  STA a:$0041                                         ; $ADBA: 8D 41 00
  LDA a:$0042                                         ; $ADBD: AD 42 00
  ADC #$00                                            ; $ADC0: 69 00
  STA a:$0042                                         ; $ADC2: 8D 42 00
  LDY #$08                                            ; $ADC5: A0 08
  LDA ($22),Y                                         ; $ADC7: B1 22
  CLC                                                 ; $ADC9: 18
  ADC a:$0043                                         ; $ADCA: 6D 43 00
  STA a:$0043                                         ; $ADCD: 8D 43 00
  INY                                                 ; $ADD0: C8
  LDA ($22),Y                                         ; $ADD1: B1 22
  AND #$03                                            ; $ADD3: 29 03
  ADC a:$0044                                         ; $ADD5: 6D 44 00
  STA a:$0044                                         ; $ADD8: 8D 44 00
  INC a:$0040                                         ; $ADDB: EE 40 00
  LDA a:$0040                                         ; $ADDE: AD 40 00
  CMP #$0A                                            ; $ADE1: C9 0A
  BCC @SumArmyLoop                                           ; $ADE3: 90 C2
@SumArmyDone:
  LDA a:$0041                                         ; $ADE5: AD 41 00
  STA $21                                             ; $ADE8: 85 21
  LDA a:$0042                                         ; $ADEA: AD 42 00
  STA $22                                             ; $ADED: 85 22
  LDA #$0A                                            ; $ADEF: A9 0A
  STA $23                                             ; $ADF1: 85 23
  LDA #$00                                            ; $ADF3: A9 00
  STA $24                                             ; $ADF5: 85 24
  JSR Proc_D40F                                       ; $ADF7: 20 0F D4
  LDA $21                                             ; $ADFA: A5 21
  STA a:$003E                                         ; $ADFC: 8D 3E 00
  LDA a:$0043                                         ; $ADFF: AD 43 00
  STA $21                                             ; $AE02: 85 21
  LDA a:$0044                                         ; $AE04: AD 44 00
  STA $22                                             ; $AE07: 85 22
  LDA #$64                                            ; $AE09: A9 64
  STA $23                                             ; $AE0B: 85 23
  LDA #$00                                            ; $AE0D: A9 00
  STA $24                                             ; $AE0F: 85 24
  JSR Proc_D40F                                       ; $AE11: 20 0F D4
  LDA a:$003E                                         ; $AE14: AD 3E 00
  CLC                                                 ; $AE17: 18
  ADC $21                                             ; $AE18: 65 21
  STA a:$003E                                         ; $AE1A: 8D 3E 00
  LDA a:$003F                                         ; $AE1D: AD 3F 00
  ADC #$00                                            ; $AE20: 69 00
  STA a:$003F                                         ; $AE22: 8D 3F 00
  LDA $0664                                           ; $AE25: AD 64 06
  LDY #$07                                            ; $AE28: A0 07
  JSR $D2AB                                           ; $AE2A: 20 AB D2
  LSR A                                               ; $AE2D: 4A
  LSR A                                               ; $AE2E: 4A
  LSR A                                               ; $AE2F: 4A
  LSR A                                               ; $AE30: 4A
  STA $20                                             ; $AE31: 85 20
  LDA #$0A                                            ; $AE33: A9 0A
  STA $21                                             ; $AE35: 85 21
  JSR Proc_D471                                       ; $AE37: 20 71 D4
  LDA a:$003E                                         ; $AE3A: AD 3E 00
  CLC                                                 ; $AE3D: 18
  ADC $2A                                             ; $AE3E: 65 2A
  STA a:$003E                                         ; $AE40: 8D 3E 00
  LDA a:$003F                                         ; $AE43: AD 3F 00
  ADC $2B                                             ; $AE46: 65 2B
  STA a:$003F                                         ; $AE48: 8D 3F 00
  LDA a:$003C                                         ; $AE4B: AD 3C 00
  STA $20                                             ; $AE4E: 85 20
  LDA a:$003D                                         ; $AE50: AD 3D 00
  STA $21                                             ; $AE53: 85 21
  LDA #$00                                            ; $AE55: A9 00
  STA $22                                             ; $AE57: 85 22
  LDA #$64                                            ; $AE59: A9 64
  STA $23                                             ; $AE5B: 85 23
  JSR Proc_D438                                       ; $AE5D: 20 38 D4
  LDA $26                                             ; $AE60: A5 26
  STA $21                                             ; $AE62: 85 21
  LDA $27                                             ; $AE64: A5 27
  STA $22                                             ; $AE66: 85 22
  LDA a:$003C                                         ; $AE68: AD 3C 00
  CLC                                                 ; $AE6B: 18
  ADC a:$003E                                         ; $AE6C: 6D 3E 00
  STA $23                                             ; $AE6F: 85 23
  LDA a:$003D                                         ; $AE71: AD 3D 00
  ADC a:$003F                                         ; $AE74: 6D 3F 00
  STA $24                                             ; $AE77: 85 24
  JSR Proc_D40F                                       ; $AE79: 20 0F D4
  LDA $21                                             ; $AE7C: A5 21
  STA a:$003C                                         ; $AE7E: 8D 3C 00
  LDA a:$003C                                         ; $AE81: AD 3C 00
  LSR A                                               ; $AE84: 4A
  SEC                                                 ; $AE85: 38
  SBC #$19                                            ; $AE86: E9 19
  BCS @ClampPositive                                                                           ; $AE88: B0 05 (BCS mid-instruction target)
  EOR #$FF                                            ; $AE8A: 49 FF
  CLC                                                 ; $AE8C: 18
  ADC #$01                                            ; $AE8D: 69 01
@ClampPositive:
  STA $20                                             ; $AE8F: 85 20
  LDA #$1E                                            ; $AE91: A9 1E
  SEC                                                 ; $AE93: 38
  SBC $20                                             ; $AE94: E5 20
  STA $6F8D                                           ; $AE96: 8D 8D 6F
  JSR @SumAllResources                                       ; $AE99: 20 BF AE
  LDA $0522                                           ; $AE9C: AD 22 05
  SEC                                                 ; $AE9F: 38
  SBC $2A                                             ; $AEA0: E5 2A
  LDA $0523                                           ; $AEA2: AD 23 05
  SBC $2B                                             ; $AEA5: E5 2B
  BCC @EnoughResources                                                                         ; $AEA7: 90 0A (BCC mid-instruction target)
  LDA #$64                                            ; $AEA9: A9 64
  JSR Proc_D4BB                                       ; $AEAB: 20 BB D4
  CMP a:$003C                                         ; $AEAE: CD 3C 00
  BCS @SetContinueFlag                                           ; $AEB1: B0 06
@EnoughResources:
  LDA #$00                                            ; $AEB3: A9 00
  STA $6F8C                                           ; $AEB5: 8D 8C 6F
  RTS                                                 ; $AEB8: 60
@SetContinueFlag:
  LDA #$01                                            ; $AEB9: A9 01
  STA $6F8C                                           ; $AEBB: 8D 8C 6F
  RTS                                                 ; $AEBE: 60

@SumAllResources:
  LDA #$00                                            ; $AEBF: A9 00
  STA $24                                             ; $AEC1: 85 24
  STA $25                                             ; $AEC3: 85 25
  STA $26                                             ; $AEC5: 85 26
@SumAlliesLoop:
  LDY $24                                             ; $AEC7: A4 24
  LDA $0664,Y                                         ; $AEC9: B9 64 06
  CMP #$FF                                            ; $AECC: C9 FF
  BEQ @SumAlliesSkip                                                                           ; $AECE: F0 11 (BEQ mid-instruction target)
  LDY #$08                                            ; $AED0: A0 08
  JSR $D2AB                                           ; $AED2: 20 AB D2
  CLC                                                 ; $AED5: 18
  ADC $25                                             ; $AED6: 65 25
  STA $25                                             ; $AED8: 85 25
  INY                                                 ; $AEDA: C8
  LDA ($22),Y                                         ; $AEDB: B1 22
  ADC $26                                             ; $AEDD: 65 26
  STA $26                                             ; $AEDF: 85 26
@SumAlliesSkip:
  INC $24                                             ; $AEE1: E6 24
  LDA $24                                             ; $AEE3: A5 24
  CMP #$0A                                            ; $AEE5: C9 0A
  BCC @SumAlliesLoop                                                                           ; $AEE7: 90 DE (BCC mid-instruction target)
  LDA $25                                             ; $AEE9: A5 25
  STA $21                                             ; $AEEB: 85 21
  LDA $26                                             ; $AEED: A5 26
  STA $22                                             ; $AEEF: 85 22
  LDA #$64                                            ; $AEF1: A9 64
  STA $23                                             ; $AEF3: 85 23
  LDA #$00                                            ; $AEF5: A9 00
  STA $24                                             ; $AEF7: 85 24
  JSR Proc_D40F                                       ; $AEF9: 20 0F D4
  LDA $21                                             ; $AEFC: A5 21
  STA $20                                             ; $AEFE: 85 20
  LDA $22                                             ; $AF00: A5 22
  STA $21                                             ; $AF02: 85 21
  LDA #$00                                            ; $AF04: A9 00
  STA $22                                             ; $AF06: 85 22
  LDA $6F8D                                           ; $AF08: AD 8D 6F
  ASL A                                               ; $AF0B: 0A
  ASL A                                               ; $AF0C: 0A
  STA $23                                             ; $AF0D: 85 23
  JSR Proc_D438                                       ; $AF0F: 20 38 D4
  LDA $26                                             ; $AF12: A5 26
  STA $21                                             ; $AF14: 85 21
  LDA $27                                             ; $AF16: A5 27
  STA $22                                             ; $AF18: 85 22
  LDA #$0A                                            ; $AF1A: A9 0A
  STA $23                                             ; $AF1C: 85 23
  LDA #$00                                            ; $AF1E: A9 00
  STA $24                                             ; $AF20: 85 24
  JSR Proc_D40F                                       ; $AF22: 20 0F D4
  LDA $21                                             ; $AF25: A5 21
  STA $2A                                             ; $AF27: 85 2A
  LDA $22                                             ; $AF29: A5 22
  STA $2B                                             ; $AF2B: 85 2B
  LDA #$00                                            ; $AF2D: A9 00
  STA $24                                             ; $AF2F: 85 24
  STA $25                                             ; $AF31: 85 25
  STA $26                                             ; $AF33: 85 26
@SumEnemiesLoop:
  LDY $24                                             ; $AF35: A4 24
  LDA $066E,Y                                         ; $AF37: B9 6E 06
  CMP #$FF                                            ; $AF3A: C9 FF
  BEQ @SumEnemiesSkip                                                                          ; $AF3C: F0 11 (BEQ mid-instruction target)
  LDY #$08                                            ; $AF3E: A0 08
  JSR $D2AB                                           ; $AF40: 20 AB D2
  CLC                                                 ; $AF43: 18
  ADC $25                                             ; $AF44: 65 25
  STA $25                                             ; $AF46: 85 25
  INY                                                 ; $AF48: C8
  LDA ($22),Y                                         ; $AF49: B1 22
  ADC $26                                             ; $AF4B: 65 26
  STA $26                                             ; $AF4D: 85 26
@SumEnemiesSkip:
  INC $24                                             ; $AF4F: E6 24
  LDA $24                                             ; $AF51: A5 24
  CMP #$0A                                            ; $AF53: C9 0A
  BCC @SumEnemiesLoop                                                                          ; $AF55: 90 DE (BCC mid-instruction target)
  LDA $25                                             ; $AF57: A5 25
  STA $21                                             ; $AF59: 85 21
  LDA $26                                             ; $AF5B: A5 26
  STA $22                                             ; $AF5D: 85 22
  LDA #$64                                            ; $AF5F: A9 64
  STA $23                                             ; $AF61: 85 23
  LDA #$00                                            ; $AF63: A9 00
  STA $24                                             ; $AF65: 85 24
  JSR Proc_D40F                                       ; $AF67: 20 0F D4
  LDA $21                                             ; $AF6A: A5 21
  STA $20                                             ; $AF6C: 85 20
  LDA $22                                             ; $AF6E: A5 22
  STA $21                                             ; $AF70: 85 21
  LDA #$00                                            ; $AF72: A9 00
  STA $22                                             ; $AF74: 85 22
  LDA $6F8D                                           ; $AF76: AD 8D 6F
  ASL A                                               ; $AF79: 0A
  ASL A                                               ; $AF7A: 0A
  STA $23                                             ; $AF7B: 85 23
  JSR Proc_D438                                       ; $AF7D: 20 38 D4
  LDA $26                                             ; $AF80: A5 26
  STA $21                                             ; $AF82: 85 21
  LDA $27                                             ; $AF84: A5 27
  STA $22                                             ; $AF86: 85 22
  LDA #$0A                                            ; $AF88: A9 0A
  STA $23                                             ; $AF8A: 85 23
  LDA #$00                                            ; $AF8C: A9 00
  STA $24                                             ; $AF8E: 85 24
  JSR Proc_D40F                                       ; $AF90: 20 0F D4
  LDA $21                                             ; $AF93: A5 21
  STA $2C                                             ; $AF95: 85 2C
  LDA $22                                             ; $AF97: A5 22
  STA $2D                                             ; $AF99: 85 2D
  RTS                                                 ; $AF9B: 60
@AdjustGold:
  LDA $6F77                                           ; $AF9C: AD 77 6F
  STA $20                                             ; $AF9F: 85 20
  LDA #$78                                            ; $AFA1: A9 78
  STA $21                                             ; $AFA3: 85 21
  JSR Proc_D471                                       ; $AFA5: 20 71 D4
  LDA $2A                                             ; $AFA8: A5 2A
  CLC                                                 ; $AFAA: 18
  ADC $6F73                                           ; $AFAB: 6D 73 6F
  STA $6F73                                           ; $AFAE: 8D 73 6F
  LDA $2B                                             ; $AFB1: A5 2B
  ADC $6F74                                           ; $AFB3: 6D 74 6F
  STA $6F74                                           ; $AFB6: 8D 74 6F
  LDA $6F78                                           ; $AFB9: AD 78 6F
  STA $20                                             ; $AFBC: 85 20
  LDA #$78                                            ; $AFBE: A9 78
  STA $21                                             ; $AFC0: 85 21
  JSR Proc_D471                                       ; $AFC2: 20 71 D4
  LDA $2A                                             ; $AFC5: A5 2A
  CLC                                                 ; $AFC7: 18
  ADC $6F75                                           ; $AFC8: 6D 75 6F
  STA $6F75                                           ; $AFCB: 8D 75 6F
  LDA $2B                                             ; $AFCE: A5 2B
  ADC $6F76                                           ; $AFD0: 6D 76 6F
  STA $6F76                                           ; $AFD3: 8D 76 6F
  LDA $6F75                                           ; $AFD6: AD 75 6F
  STA $21                                             ; $AFD9: 85 21
  LDA $6F76                                           ; $AFDB: AD 76 6F
  STA $22                                             ; $AFDE: 85 22
  LDA a:$003C                                         ; $AFE0: AD 3C 00
  STA $23                                             ; $AFE3: 85 23
  LDA #$00                                            ; $AFE5: A9 00
  STA $24                                             ; $AFE7: 85 24
  JSR Proc_D40F                                       ; $AFE9: 20 0F D4
  LDA $21                                             ; $AFEC: A5 21
  STA $6F75                                           ; $AFEE: 8D 75 6F
  LDA $22                                             ; $AFF1: A5 22
  STA $6F76                                           ; $AFF3: 8D 76 6F
  LDA $6F73                                           ; $AFF6: AD 73 6F
  STA $21                                             ; $AFF9: 85 21
  LDA $6F74                                           ; $AFFB: AD 74 6F
  STA $22                                             ; $AFFE: 85 22
  LDA a:$003D                                         ; $B000: AD 3D 00
  STA $23                                             ; $B003: 85 23
  LDA #$00                                            ; $B005: A9 00
  STA $24                                             ; $B007: 85 24
  JSR Proc_D40F                                       ; $B009: 20 0F D4
  LDA $21                                             ; $B00C: A5 21
  STA $6F73                                           ; $B00E: 8D 73 6F
  LDA $22                                             ; $B011: A5 22
  STA $6F74                                           ; $B013: 8D 74 6F
  LDA #$00                                            ; $B016: A9 00
  STA a:$0036                                         ; $B018: 8D 36 00
@DistributeArmyLoop:
  LDY a:$0036                                         ; $B01B: AC 36 00
  LDA $0664,Y                                         ; $B01E: B9 64 06
  CMP #$FF                                            ; $B021: C9 FF
  BEQ @DistribArmySkip                                                                         ; $B023: F0 0F (BEQ mid-instruction target)
  STA $2A                                             ; $B025: 85 2A
  LDA $6F75                                           ; $B027: AD 75 6F
  STA $2B                                             ; $B02A: 85 2B
  LDA $6F76                                           ; $B02C: AD 76 6F
  STA $2C                                             ; $B02F: 85 2C
  JSR @DistributeToSlot                                           ; $B031: 20 67 B0
@DistribArmySkip:
  INC a:$0036                                         ; $B034: EE 36 00
  LDA a:$0036                                         ; $B037: AD 36 00
  CMP #$0A                                            ; $B03A: C9 0A
  BCC @DistributeArmyLoop                                           ; $B03C: 90 DD
  LDA #$00                                            ; $B03E: A9 00
  STA a:$0036                                         ; $B040: 8D 36 00
@DistributeEnemyLoop:
  LDY a:$0036                                         ; $B043: AC 36 00
  LDA $066E,Y                                         ; $B046: B9 6E 06
  CMP #$FF                                            ; $B049: C9 FF
  BEQ @DistribEnemySkip                                                                        ; $B04B: F0 0F (BEQ mid-instruction target)
  STA $2A                                             ; $B04D: 85 2A
  LDA $6F73                                           ; $B04F: AD 73 6F
  STA $2B                                             ; $B052: 85 2B
  LDA $6F74                                           ; $B054: AD 74 6F
  STA $2C                                             ; $B057: 85 2C
  JSR @DistributeToSlot                                           ; $B059: 20 67 B0
@DistribEnemySkip:
  INC a:$0036                                         ; $B05C: EE 36 00
  LDA a:$0036                                         ; $B05F: AD 36 00
  CMP #$0A                                            ; $B062: C9 0A
  BCC @DistributeEnemyLoop                                           ; $B064: 90 DD
  RTS                                                 ; $B066: 60
@DistributeToSlot:
  LDA $2A                                             ; $B067: A5 2A
  LDY #$00                                            ; $B069: A0 00
  JSR $D2AB                                           ; $B06B: 20 AB D2
  LSR $2C                                             ; $B06E: 46 2C
  ROR $2B                                             ; $B070: 66 2B
  LDY #$06                                            ; $B072: A0 06
  LDA ($22),Y                                         ; $B074: B1 22
  CLC                                                 ; $B076: 18
  ADC $2B                                             ; $B077: 65 2B
  STA $2D                                             ; $B079: 85 2D
  STA ($22),Y                                         ; $B07B: 91 22
  INY                                                 ; $B07D: C8
  LDA ($22),Y                                         ; $B07E: B1 22
  ADC $2C                                             ; $B080: 65 2C
  STA $2E                                             ; $B082: 85 2E
  STA ($22),Y                                         ; $B084: 91 22
  LDY #$06                                            ; $B086: A0 06
  LDA ($22),Y                                         ; $B088: B1 22
  SEC                                                 ; $B08A: 38
  SBC #$4F                                            ; $B08B: E9 4F
  INY                                                 ; $B08D: C8
  LDA ($22),Y                                         ; $B08E: B1 22
  SBC #$C3                                            ; $B090: E9 C3
  BCC @CheckLevelCap                                           ; $B092: 90 0B
  LDY #$06                                            ; $B094: A0 06
  LDA #$4F                                            ; $B096: A9 4F
  STA ($22),Y                                         ; $B098: 91 22
  INY                                                 ; $B09A: C8
  LDA #$C3                                            ; $B09B: A9 C3
  STA ($22),Y                                         ; $B09D: 91 22
@CheckLevelCap:
  LDY #$0B                                            ; $B09F: A0 0B
  LDA ($22),Y                                         ; $B0A1: B1 22
  AND #$F0                                            ; $B0A3: 29 F0
  LSR A                                               ; $B0A5: 4A
  LSR A                                               ; $B0A6: 4A
  LSR A                                               ; $B0A7: 4A
  CMP #$0E                                            ; $B0A8: C9 0E
  BCS @DistribExit                                           ; $B0AA: B0 0F
  TAY                                                 ; $B0AC: A8
  LDA $2D                                             ; $B0AD: A5 2D
  SEC                                                 ; $B0AF: 38
  SBC DistribLevelThresholds,Y                        ; $B0B0: F9 BC B0
  LDA a:$002E                                         ; $B0B3: AD 2E 00
  SBC DistribLevelThresholds+1,Y                      ; $B0B6: F9 BD B0
  BCS @SetLevelField                                                                           ; $B0B9: B0 0F (BCS cross-proc)
@DistribExit:
  RTS                                                 ; $B0BB: 60
DistribLevelThresholds:                               ; $B0BC
  .word $03E8                                         ; $B0BC: E8 03 (1000)
  .word $07D0                                         ; $B0BE: D0 07 (2000)
  .word $0DAC                                         ; $B0C0: AC 0D (3500)
  .word $1388                                         ; $B0C2: 88 13 (5000)
  .word $1D4C                                         ; $B0C4: 4C 1D (7500)
  .word $2710                                         ; $B0C6: 10 27 (10000)
  .word $3A98                                         ; $B0C8: 98 3A (15000)
@SetLevelField:
  TYA                                                 ; $B0CA: 98
  LSR A                                               ; $B0CB: 4A
  CLC                                                 ; $B0CC: 18
  ADC #$01                                            ; $B0CD: 69 01
  ASL A                                               ; $B0CF: 0A
  ASL A                                               ; $B0D0: 0A
  ASL A                                               ; $B0D1: 0A
  ASL A                                               ; $B0D2: 0A
  STA $2F                                             ; $B0D3: 85 2F
  LDY #$0B                                            ; $B0D5: A0 0B
  LDA ($22),Y                                         ; $B0D7: B1 22
  AND #$F0                                            ; $B0D9: 29 F0
  CMP $2F                                             ; $B0DB: C5 2F
  BCS @DistribExit                                                                             ; $B0DD: B0 DC (BCS cross-proc)
  LDY #$0B                                            ; $B0DF: A0 0B
  LDA ($22),Y                                         ; $B0E1: B1 22
  AND #$0F                                            ; $B0E3: 29 0F
  ORA $2F                                             ; $B0E5: 05 2F
  STA ($22),Y                                         ; $B0E7: 91 22
  LDY #$01                                            ; $B0E9: A0 01
  LDA ($22),Y                                         ; $B0EB: B1 22
  LDY #$06                                            ; $B0ED: A0 06
  CMP #$33                                            ; $B0EF: C9 33
  BCC @ApplyLevelBonus                                           ; $B0F1: 90 12
  LDY #$05                                            ; $B0F3: A0 05
  CMP #$47                                            ; $B0F5: C9 47
  BCC @ApplyLevelBonus                                           ; $B0F7: 90 0C
  LDY #$04                                            ; $B0F9: A0 04
  CMP #$51                                            ; $B0FB: C9 51
  BCC @ApplyLevelBonus                                           ; $B0FD: 90 06
  LDY #$02                                            ; $B0FF: A0 02
  CMP #$5A                                            ; $B101: C9 5A
  BCS @LevelDone                                           ; $B103: B0 08
@ApplyLevelBonus:
  TYA                                                 ; $B105: 98
  LDY #$01                                            ; $B106: A0 01
  CLC                                                 ; $B108: 18
  ADC ($22),Y                                         ; $B109: 71 22
  STA ($22),Y                                         ; $B10B: 91 22
@LevelDone:
  RTS                                                 ; $B10D: 60
.endproc


;===============================================================================
; $B10E: CalcAvgProvinceVal
;
; AI decision: compute average province value per owned ruler, then attempt
; to absorb a weaker neighbor province.
;
; Phase 1 ($B10E-$B134): Count owned rulers, sum their province values via
;         Proc_D0AA, then divide (province_sum / ruler_count) via Proc_D40F.
; Phase 2 ($B136-$B159): Clamp the average into a threshold value [4..18].
;         If avg < 2 → fall back to FallbackMergeProvinces (scan all owned provinces).
; Phase 3 ($B15C-$B1F8): Scan 30 provinces for the best slot-rich candidate
;         owned by the current player (inline subroutine ScanBestProvince).
; Phase 4 ($B15F-$B17D): If best candidate found, compare its value against
;         the threshold; optionally call ProvinceSearch, then absorb via
;         AbsorbPreview and $B287 (AbsorbUpdateRecord).
;
; Called via JMP from StateThresholdCheck ($A1D5/$A1E1).
;===============================================================================
.proc CalcAvgProvinceVal
  dividend_lo              = $0021   ; Proc_D40F dividend byte 0 (init 0)
  dividend_mid             = $0022   ; Proc_D40F dividend byte 1 (province_sum)
  dividend_hi              = $0023   ; Proc_D40F dividend byte 2 / divisor hi (ruler_count)
  math_ext                 = $0024   ; Proc_D40F divisor lo / work byte
  math_temp1               = $0025
  math_temp2               = $0026
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_sub_idx             = $0039
  work_limit_a             = $003A
  work_record_val          = $0040
  sram_player_id           = $6F03

  ; -- Phase 1: count owned rulers and sum their province values
  LDA #$01                                            ; $B10E: A9 01
  STA a:$0044                                         ; $B110: 8D 44 00  ; work_flag = 1 (enable province counting)
  JSR Proc_D0AA                                       ; $B113: 20 AA D0  ; → $2B = owned ruler count, $2C = province value sum
  LDA $2B                                             ; $B116: A5 2B    ; A = ruler_count
  BNE @hasRulers                                       ; $B118: D0 09  ; branch if at least one ruler owned
  ; Dead code ($B11A-$B122): unreachable — BNE above always branches when $2B=0 path taken
  ; Original intent: load a saved record value and jump to Phase 2 threshold processing
  JSR LoadRecord                                  ; $B11A: 20 3A D0
  LDA a:$0040                                         ; $B11D: AD 40 00
  JMP ComputeThreshold                                ; $B120: 4C 36 B1  ; jump to Phase 2
@hasRulers:
  LDA $2B                                             ; $B123: A5 2B    ; A = ruler_count
  STA $23                                             ; $B125: 85 23    ; divisor_hi = ruler_count
  LDA $2C                                             ; $B127: A5 2C    ; A = province_sum
  STA $22                                             ; $B129: 85 22    ; dividend_mid = province_sum
  LDA #$00                                            ; $B12B: A9 00
  STA $21                                             ; $B12D: 85 21    ; dividend_lo = 0
  STA $24                                             ; $B12F: 85 24    ; divisor_lo = 0
  ; Dividend = province_sum << 8, Divisor = ruler_count << 8
  ; Proc_D40F: 16-bit restoring division → quotient in $21(lo)/$22(hi)
  JSR Proc_D40F                                       ; $B131: 20 0F D4  ; avg = province_sum / ruler_count
  LDA $22                                             ; $B134: A5 22    ; A = avg (hi-byte of quotient)
  ; -- Phase 2: clamp average into threshold value [6..18]
  ;   avg >= 4 → threshold = clamp(avg - 2, 2, 16) + 2  (range [6, 18])
  ;   avg in [2,3] → BCS exits early (threshold = 4, skip Phase 3/4)
  ;   avg < 2 → fallback to FallbackMergeProvinces
ComputeThreshold:
  STA a:$0040                                         ; $B136: 8D 40 00  ; store avg
  CMP #$04                                            ; $B139: C9 04
  BCS @clampUpper                                     ; $B13B: B0 07  ; avg >= 4: compute threshold
  CMP #$02                                            ; $B13D: C9 02
  BCS @exit                                           ; $B13F: B0 3C  ; avg >= 2: skip Phase 3/4, exit early
  JMP FallbackMergeProvinces                           ; $B141: 4C 57 B3  ; avg < 2: fallback scan all owned provinces
@clampUpper:
  LDA a:$0040                                         ; $B144: AD 40 00  ; reload avg
  SEC                                                 ; $B147: 38
  SBC #$02                                            ; $B148: E9 02  ; avg - 2
  CMP #$10                                            ; $B14A: C9 10
  BCC @clampLower                                     ; $B14C: 90 02  ; if (avg-2) < 16, keep it
  LDA #$02                                            ; $B14E: A9 02  ; else clamp to 2 (→ final value 18)
@clampLower:
  CMP #$02                                            ; $B150: C9 02
  BCS @addOffset                                      ; $B152: B0 02  ; if value >= 2, keep it
  LDA #$02                                            ; $B154: A9 02  ; else floor to 2 (→ final value 4)
@addOffset:
  CLC                                                 ; $B156: 18
  ADC #$02                                            ; $B157: 69 02  ; threshold = clamped + 2
  STA a:$0037                                         ; $B159: 8D 37 00  ; store threshold in inner_idx
  ; -- Phase 3: scan 30 provinces for best slot-rich candidate
  JSR ScanBestProvince                                ; $B15C: 20 80 B1  ; → $38=best idx, $39=best slots, $3A=best province
  LDA a:$0038                                         ; $B15F: AD 38 00
  CMP #$FF                                            ; $B162: C9 FF  ; any candidate found?
  BEQ @exit                                           ; $B164: F0 17       ; no candidate → exit
  ; -- Phase 4: compare candidate value vs threshold, optionally search & absorb
  LDA a:$003A                                         ; $B166: AD 3A 00  ; best province idx
  JSR Proc_D304                                       ; $B169: 20 04 D3  ; A = settlement slot count of best province
  CMP a:$0037                                         ; $B16C: CD 37 00  ; compare vs threshold
  BCS @skipSearch                                     ; $B16F: B0 03  ; if value >= threshold, skip search
  JSR ProvinceSearch                                  ; $B171: 20 03 A3  ; find absorption target
@skipSearch:
  JSR AbsorbPreview                                   ; $B174: 20 F9 B1  ; compute absorb deltas → $3B-$3E
  JSR AbsorbUpdateRecord                              ; $B177: 20 87 B2  ; apply absorb: subtract src, add dst, transfer slots
  JMP @exit                                           ; $B17A: 4C 7D B1
@exit:
ProvinceEvalExit:
  JMP $BEC7                                           ; $B17D: 4C C7 BE  ; common exit → BEC7 (end turn)
  ; =====================================================================
  ; ScanBestProvince ($B180-$B1F8): inline subroutine
  ; Iterates provinces 0-29, finds the player-owned province with the
  ; most occupied settlement slots. Uses nested loop:
  ;   Outer: province idx ($36) from 0 to $1D
  ;   Inner: slot entries in $9D72[idx*8 .. idx*8+7]
  ; Returns: $38=best province, $39=best slot count, $3A=best province ID
  ; =====================================================================
ScanBestProvince:
  LDY #$30                                            ; $B180: A0 30
  JSR B1F_SwitchBank8_A                               ; $B182: 20 66 F2  ; switch to bank 8
  LDA #$00                                            ; $B185: A9 00
  STA a:$0036                                         ; $B187: 8D 36 00  ; outer_idx = 0
  LDA #$FF                                            ; $B18A: A9 FF
  STA a:$0038                                         ; $B18C: 8D 38 00  ; best_province = $FF (none)
  STA a:$003A                                         ; $B18F: 8D 3A 00  ; best_province_id = $FF
  LDA #$00                                            ; $B192: A9 00
  STA a:$0039                                         ; $B194: 8D 39 00  ; best_slot_count = 0
@outerLoop:                                           ; --- iterate provinces 0..$1D ---
  LDA a:$0036                                         ; $B197: AD 36 00  ; province idx
  JSR Proc_D105                                       ; $B19A: 20 05 D1  ; → ($20)=record ptr, A=owner byte
  CMP $6F03                                           ; $B19D: CD 03 6F  ; owned by current player?
  BNE @nextProvince                                   ; $B1A0: D0 4C       ; not owned → next province
  JSR $D307                                           ; $B1A2: 20 07 D3  ; Proc_D304 inline: count occupied slots
  STA $26                                             ; $B1A5: 85 26  ; $26 = slot count for this province
  LDA a:$0036                                         ; $B1A7: AD 36 00
  ASL A                                               ; $B1AA: 0A
  ASL A                                               ; $B1AB: 0A
  ASL A                                               ; $B1AC: 0A
  STA $24                                             ; $B1AD: 85 24  ; $24 = province_idx * 8 (offset into $9D72)
@slotLoop:                                            ; --- iterate 8 slot entries per province ---
  LDY $24                                             ; $B1AF: A4 24
  LDA $9D72,Y                                         ; $B1B1: B9 72 9D  ; slot entry byte
  BMI @nextProvince                                   ; $B1B4: 30 38       ; negative → empty slot, skip
  STA $25                                             ; $B1B6: 85 25  ; $25 = owner/type byte from $9D72
  JSR Proc_D105                                       ; $B1B8: 20 05 D1  ; reload record ptr
  AND #$07                                            ; $B1BB: 29 07  ; settlement type (low 3 bits)
  CMP #$07                                            ; $B1BD: C9 07  ; type 7 = active settlement?
  BNE @nextSlot                                       ; $B1BF: D0 28  ; skip if not type 7
  LDA $25                                             ; $B1C1: A5 25  ; $9D72 slot byte
  CMP a:$0038                                         ; $B1C3: CD 38 00  ; compare vs current best province
  BNE @skipBestUpdate                                 ; $B1C6: D0 13       ; not same province → skip update
  LDA $26                                             ; $B1C8: A5 26  ; slot count
  CMP a:$0039                                         ; $B1CA: CD 39 00  ; compare vs best slot count
  BCC @nextSlot                                       ; $B1CD: 90 1A  ; skip if fewer slots than best
  ; --- Update best: new province has more slots ---
  STA a:$0039                                         ; $B1CF: 8D 39 00  ; best_slot_count = this province's count
  LDA a:$0036                                         ; $B1D2: AD 36 00
  STA a:$003A                                         ; $B1D5: 8D 3A 00  ; best_province_id = this province idx
  JMP @nextSlot                                       ; $B1D8: 4C E9 B1  ; continue scanning slots
@skipBestUpdate:                                      ; dead code: duplicate best-update (reached only via BNE above)
  STA a:$0038                                         ; $B1DB: 8D 38 00
  LDA $26                                             ; $B1DE: A5 26
  STA a:$0039                                         ; $B1E0: 8D 39 00
  LDA a:$0036                                         ; $B1E3: AD 36 00
  STA a:$003A                                         ; $B1E6: 8D 3A 00
@nextSlot:                                            ; --- advance to next slot entry ---
  INC $24                                             ; $B1E9: E6 24  ; $24++ (next slot offset)
  JMP @slotLoop                                       ; $B1EB: 4C AF B1  ; loop (8 slots per province)
@nextProvince:                                        ; --- advance to next province ---
  INC a:$0036                                         ; $B1EE: EE 36 00  ; outer_idx++
  LDA a:$0036                                         ; $B1F1: AD 36 00
  CMP #$1E                                            ; $B1F4: C9 1E  ; done all 30 provinces?
  BCC @outerLoop                                      ; $B1F6: 90 9F       ; idx < 30 → continue
  RTS                                                 ; $B1F8: 60
.endproc
ProvinceEvalExit = $B17D


;===============================================================================
; $B1F9: AbsorbPreview
; Compute absorb deltas and render result without applying slot transfer.
;===============================================================================
.proc AbsorbPreview

  JSR TransferProvinceValues                            ; $B1F9: 20 FD B1
  RTS                                                 ; $B1FC: 60
.endproc

;===============================================================================
; $B1FD: TransferProvinceValues
; Compute deltas between province values and limit thresholds (underflow-protected).
; Entry points: AbsorbPreview (render-only), TransferProvinceValues (full)
;===============================================================================
.proc TransferProvinceValues
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C
  work_temp_1              = $003D
  work_temp_2              = $003E
  sram_player_id           = $6F03

  JSR CalcKingdomTierWorkPtr                          ; $B1FD: 20 4A A7
  LDA a:$0038                                         ; $B200: AD 38 00
  JSR Proc_D105                                       ; $B203: 20 05 D1
  LDA a:$003D                                         ; $B206: AD 3D 00
  LDY #$02                                            ; $B209: A0 02
  SEC                                                 ; $B20B: 38
  SBC ($20),Y                                         ; $B20C: F1 20
  STA a:$003D                                         ; $B20E: 8D 3D 00
  INY                                                 ; $B211: C8
  LDA a:$003E                                         ; $B212: AD 3E 00
  SBC ($20),Y                                         ; $B215: F1 20
  STA a:$003E                                         ; $B217: 8D 3E 00
  BCS @SubLimitB                                        ; $B21A: B0 08  ; no underflow → continue
  LDA #$00                                            ; $B21C: A9 00
  STA a:$003D                                         ; $B21E: 8D 3D 00
  STA a:$003E                                         ; $B221: 8D 3E 00
  LDA a:$003B                                         ; $B224: AD 3B 00
  LDY #$02                                            ; $B227: A0 02
  SEC                                                 ; $B229: 38
  SBC ($20),Y                                         ; $B22A: F1 20
  STA a:$003B                                         ; $B22C: 8D 3B 00
  INY                                                 ; $B22F: C8
  LDA a:$003C                                         ; $B230: AD 3C 00
  SBC ($20),Y                                         ; $B233: F1 20
  STA a:$003C                                         ; $B235: 8D 3C 00
  BCS @RenderNameLoop                                   ; $B238: B0 08  ; no underflow → continue
  LDA #$00                                            ; $B23A: A9 00
  STA a:$003B                                         ; $B23C: 8D 3B 00
  STA a:$003C                                         ; $B23F: 8D 3C 00
@RenderTileLoop:
  LDA a:$003A                                         ; $B242: AD 3A 00
  JSR Proc_D105                                       ; $B245: 20 05 D1
  LDY #$02                                            ; $B248: A0 02
  LDA ($20),Y                                         ; $B24A: B1 20
  SEC                                                 ; $B24C: 38
  SBC a:$003D                                         ; $B24D: ED 3D 00
  INY                                                 ; $B250: C8
  LDA ($20),Y                                         ; $B251: B1 20
  SBC a:$003E                                         ; $B253: ED 3E 00
  BCS @SubLimitB                                        ; $B256: B0 0C  ; no underflow → skip to limit_b
  JSR TileRender                                  ; $B258: 20 5C A5
  BCS @RenderTileLoop                                   ; $B25B: B0 E5  ; loop: render tile row and retry
  PLA                                                 ; $B25D: 68
  PLA                                                 ; $B25E: 68
  PLA                                                 ; $B25F: 68
  PLA                                                 ; $B260: 68
  JMP $BEC7                                           ; $B261: 4C C7 BE
@RenderNameLoop:
  LDA a:$003A                                         ; $B264: AD 3A 00
  JSR Proc_D105                                       ; $B267: 20 05 D1
  LDY #$04                                            ; $B26A: A0 04
  LDA ($20),Y                                         ; $B26C: B1 20
  SEC                                                 ; $B26E: 38
  SBC a:$003B                                         ; $B26F: ED 3B 00
  INY                                                 ; $B272: C8
  LDA ($20),Y                                         ; $B273: B1 20
  SBC a:$003C                                         ; $B275: ED 3C 00
  BCS @SubLimitB                                        ; $B278: B0 0C  ; no underflow → skip to limit_b
  JSR NameTable                                   ; $B27A: 20 0C A6
  BCS @RenderNameLoop                                   ; $B27D: B0 E5  ; loop: render name row and retry
  PLA                                                 ; $B27F: 68
  PLA                                                 ; $B280: 68
  PLA                                                 ; $B281: 68
  PLA                                                 ; $B282: 68
  JMP $BEC7                                           ; $B283: 4C C7 BE
  RTS                                                 ; $B286: 60
.endproc

;===============================================================================
; $B287: AbsorbUpdateRecord
; Apply absorb deltas: subtract source province values, add to target province,
; then transfer occupied slots from source to target.
;===============================================================================
.proc AbsorbUpdateRecord
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C
  work_temp_1              = $003D
  work_temp_2              = $003E
  sram_player_id           = $6F03

AbsorbUpdateRecord:
  LDA a:$003A                                         ; $B287: AD 3A 00
  JSR Proc_D105                                       ; $B28A: 20 05 D1
  LDY #$02                                            ; $B28D: A0 02
  LDA ($20),Y                                         ; $B28F: B1 20
  SEC                                                 ; $B291: 38
  SBC a:$003D                                         ; $B292: ED 3D 00
  STA ($20),Y                                         ; $B295: 91 20
  INY                                                 ; $B297: C8
  LDA ($20),Y                                         ; $B298: B1 20
  SBC a:$003E                                         ; $B29A: ED 3E 00
  STA ($20),Y                                         ; $B29D: 91 20
  JSR Proc_D69D                                       ; $B29F: 20 9D D6
  LDY #$04                                            ; $B2A2: A0 04
  LDA ($20),Y                                         ; $B2A4: B1 20
  SEC                                                 ; $B2A6: 38
  SBC a:$003B                                         ; $B2A7: ED 3B 00
  STA ($20),Y                                         ; $B2AA: 91 20
  INY                                                 ; $B2AC: C8
  LDA ($20),Y                                         ; $B2AD: B1 20
  SBC a:$003C                                         ; $B2AF: ED 3C 00
  STA ($20),Y                                         ; $B2B2: 91 20
  JSR Proc_D69D                                       ; $B2B4: 20 9D D6
  LDA a:$0038                                         ; $B2B7: AD 38 00
  JSR Proc_D105                                       ; $B2BA: 20 05 D1
  LDY #$02                                            ; $B2BD: A0 02
  LDA ($20),Y                                         ; $B2BF: B1 20
  CLC                                                 ; $B2C1: 18
  ADC a:$003D                                         ; $B2C2: 6D 3D 00
  STA ($20),Y                                         ; $B2C5: 91 20
  INY                                                 ; $B2C7: C8
  LDA ($20),Y                                         ; $B2C8: B1 20
  ADC a:$003E                                         ; $B2CA: 6D 3E 00
  STA ($20),Y                                         ; $B2CD: 91 20
  LDY #$04                                            ; $B2CF: A0 04
  LDA ($20),Y                                         ; $B2D1: B1 20
  CLC                                                 ; $B2D3: 18
  ADC a:$003B                                         ; $B2D4: 6D 3B 00
  STA ($20),Y                                         ; $B2D7: 91 20
  INY                                                 ; $B2D9: C8
  LDA ($20),Y                                         ; $B2DA: B1 20
  ADC a:$003C                                         ; $B2DC: 6D 3C 00
  STA ($20),Y                                         ; $B2DF: 91 20
  LDA a:$0038                                         ; $B2E1: AD 38 00
  JSR Proc_D105                                       ; $B2E4: 20 05 D1
  LDA $20                                             ; $B2E7: A5 20
  STA $28                                             ; $B2E9: 85 28
  LDA $21                                             ; $B2EB: A5 21
  STA $29                                             ; $B2ED: 85 29
  LDA a:$003A                                         ; $B2EF: AD 3A 00
  JSR Proc_D105                                       ; $B2F2: 20 05 D1
  DEC a:$0037                                         ; $B2F5: CE 37 00
  DEC a:$0037                                         ; $B2F8: CE 37 00
  LDA #$00                                            ; $B2FB: A9 00
  STA $2A                                             ; $B2FD: 85 2A
@TransferLoop:
  LDA #$12                                            ; $B2FF: A9 12
  STA $2B                                             ; $B301: 85 2B
  LDA #$00                                            ; $B303: A9 00
  STA $2C                                             ; $B305: 85 2C
  LDA #$FF                                            ; $B307: A9 FF
  STA $2D                                             ; $B309: 85 2D
@FindMaxLoop:
  LDY $2B                                             ; $B30B: A4 2B
  LDA ($20),Y                                         ; $B30D: B1 20
  CMP #$FF                                            ; $B30F: C9 FF
  BEQ @SlotEmpty                                        ; $B311: F0 0F  ; empty slot → skip
  LDY #$03                                            ; $B313: A0 03
  JSR $D2AB                                           ; $B315: 20 AB D2
  CMP $2C                                             ; $B318: C5 2C
  BCC @FoundNotMax                                      ; $B31A: 90 06  ; below current max → skip update
  STA $2C                                             ; $B31C: 85 2C
  LDA $2B                                             ; $B31E: A5 2B
  STA $2D                                             ; $B320: 85 2D
  INC $2B                                             ; $B322: E6 2B
  LDA $2B                                             ; $B324: A5 2B
  CMP #$1B                                            ; $B326: C9 1B
  BCC @FindMaxLoop                                      ; $B328: 90 E1  ; next slot
  LDY $2D                                             ; $B32A: A4 2D
  LDA ($20),Y                                         ; $B32C: B1 20
  PHA                                                 ; $B32E: 48
  LDA #$FF                                            ; $B32F: A9 FF
  STA ($20),Y                                         ; $B331: 91 20
  LDA $2A                                             ; $B333: A5 2A
  CLC                                                 ; $B335: 18
  ADC #$11                                            ; $B336: 69 11
  TAY                                                 ; $B338: A8
  PLA                                                 ; $B339: 68
  STA ($28),Y                                         ; $B33A: 91 28
  INC $2A                                             ; $B33C: E6 2A
  LDY $2A                                             ; $B33E: A4 2A
  CPY a:$0037                                         ; $B340: CC 37 00
  BCC @TransferLoop                                     ; $B343: 90 BA
  LDA a:$003A                                         ; $B345: AD 3A 00
  JSR Proc_D3DD                                       ; $B348: 20 DD D3
  LDY #$00                                            ; $B34B: A0 00
  LDA ($28),Y                                         ; $B34D: B1 28
  AND #$F8                                            ; $B34F: 29 F8
  ORA $6F03                                           ; $B351: 0D 03 6F
  STA ($28),Y                                         ; $B354: 91 28
  RTS                                                 ; $B356: 60
.endproc


;===============================================================================
; $B357: FallbackMergeProvinces
;
; Fallback routine invoked when current player's average province value < 2.
; Scans all 30 provinces (0–$1D) and merges the second owned province's troops
; and slot entries into the first owned province found, then marks the absorbed
; province as owner = 7 (neutralized).
;
; A nested helper (@eval_single_owned, $B433) runs for every province in the
; loop: it counts consecutive owned provinces starting at that index, and if
; exactly 1 is found, computes a weakness metric (record[8..9] + record[14..15]
; + active slot count) and tracks the province with the lowest value.
;
; Called via JMP from CalcAvgProvinceVal ($B141).
;===============================================================================
.proc FallbackMergeProvinces
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026
  math_temp3               = $0027
  province_idx             = $0036   ; outer loop: current province (0–$1D)
  first_owned_idx          = $0037   ; first owned province found ($FF = none)
  best_weak_idx            = $0038   ; weakest owned province index
  best_weak_val            = $0039   ; weakest owned province metric (lo byte)
  sram_player_id           = $6F03

  ; -- Init: no owned province found, no best candidate yet
  LDA #$FF                                            ; $B357: A9 FF
  STA a:first_owned_idx                               ; $B359: 8D 37 00
  STA a:best_weak_idx                                 ; $B35C: 8D 38 00
  STA a:best_weak_val                                 ; $B35F: 8D 39 00
  LDA #$00                                            ; $B362: A9 00
  STA a:province_idx                                  ; $B364: 8D 36 00

  ; -- Scan loop: iterate provinces 0–$1D
@scan_loop:
  LDA a:province_idx                                  ; $B367: AD 36 00
  JSR Proc_D105                                       ; $B36A: 20 05 D1  ; → A = owner, ($20) = record ptr
  AND #$07                                            ; $B36D: 29 07
  CMP sram_player_id                                  ; $B36F: CD 03 6F
  BNE @merge_phase                                    ; $B372: D0 03  ; not owned → skip eval
  JSR @eval_single_owned                              ; $B374: 20 33 B4  ; evaluate weakness metric
  INC a:province_idx                                  ; $B377: EE 36 00
  LDA a:province_idx                                  ; $B37A: AD 36 00
  CMP #$1E                                            ; $B37D: C9 1E
  BCC @scan_loop                                      ; $B37F: 90 E6

  ; -- Post-scan: if no owned province found, exit
  LDA a:first_owned_idx                               ; $B381: AD 37 00
  CMP #$FF                                            ; $B384: C9 FF
  BNE @merge_phase                                    ; $B386: D0 03  ; owned → do merge
@skip_or_exit:
  JMP ProvinceEvalExit                                ; $B388: 4C 7D B1  ; common exit → BEC7 (end turn)

  ; -- Merge phase: second+ owned province found
@merge_phase:
  ; Compute first_owned_idx * 8 → $9D72 table lookup for province record
  LDA a:first_owned_idx                               ; $B38B: AD 37 00
  ASL A                                               ; $B38E: 0A       ; ×2
  ASL A                                               ; $B38F: 0A       ; ×4
  ASL A                                               ; $B390: 0A       ; ×8
  STA math_ext                                        ; $B391: 85 24
@table_lookup:
  LDY math_ext                                        ; $B393: A4 24
  LDA $9D72,Y                                         ; $B395: B9 72 9D ; province table entry
  BMI @skip_or_exit                                   ; $B398: 30 EE    ; negative → invalid, exit
  JSR Proc_D105                                       ; $B39A: 20 05 D1 ; get owner of this entry
  AND #$07                                            ; $B39D: 29 07
  CMP sram_player_id                                  ; $B39F: CD 03 6F
  BEQ @found_owned                                    ; $B3A2: F0 05    ; owned → proceed
  INC math_ext                                        ; $B3A4: E6 24    ; try next table entry
  JMP @table_lookup                                   ; $B3A6: 4C 93 B3

@found_owned:
  ; ($22) = first owned province record pointer (dest)
  LDY math_ext                                        ; $B3A9: A4 24
  LDA $9D72,Y                                         ; $B3AB: B9 72 9D
  STA a:best_weak_idx                                 ; $B3AE: 8D 38 00 ; store dest province idx
  JSR Proc_D105                                       ; $B3B1: 20 05 D1 ; → ($20) = dest record ptr
  LDA math_acc_lo                                     ; $B3B4: A5 20
  STA math_acc_mhi                                    ; $B3B6: 85 22    ; ($22) = dest ptr
  LDA math_acc_mlo                                    ; $B3B8: A5 21
  STA math_acc_hi                                     ; $B3BA: 85 23

  ; ($20) = current (source) province record pointer
  LDA a:province_idx                                  ; $B3BC: AD 36 00
  JSR Proc_D105                                       ; $B3BF: 20 05 D1 ; → ($20) = source record ptr

  ; -- Merge 16-bit values: dest[2..3] += src[2..3], dest[4..5] += src[4..5]
  LDY #$02                                            ; $B3C2: A0 02
  LDA ($20),Y                                         ; $B3C4: B1 20    ; src[2]
  CLC                                                 ; $B3C6: 18
  ADC ($22),Y                                         ; $B3C7: 71 22    ; + dest[2]
  STA ($22),Y                                         ; $B3C9: 91 22    ; → dest[2]
  INY                                                 ; $B3CB: C8
  LDA ($20),Y                                         ; $B3CC: B1 20    ; src[3]
  ADC ($22),Y                                         ; $B3CE: 71 22    ; + dest[3]
  STA ($22),Y                                         ; $B3D0: 91 22    ; → dest[3]
  LDY #$04                                            ; $B3D2: A0 04
  LDA ($20),Y                                         ; $B3D4: B1 20    ; src[4]
  CLC                                                 ; $B3D6: 18
  ADC ($22),Y                                         ; $B3D7: 71 22    ; + dest[4]
  STA ($22),Y                                         ; $B3D9: 91 22    ; → dest[4]
  INY                                                 ; $B3DB: C8
  LDA ($20),Y                                         ; $B3DC: B1 20    ; src[5]
  ADC ($22),Y                                         ; $B3DE: 71 22    ; + dest[5]
  STA ($22),Y                                         ; $B3E0: 91 22    ; → dest[5]

  ; -- Zero out source province values at offsets 2–5
  LDY #$02                                            ; $B3E2: A0 02
  LDA #$00                                            ; $B3E4: A9 00
  STA ($20),Y                                         ; $B3E6: 91 20    ; src[2] = 0
  INY                                                 ; $B3E8: C8
  STA ($20),Y                                         ; $B3E9: 91 20    ; src[3] = 0
  INY                                                 ; $B3EB: C8
  STA ($20),Y                                         ; $B3EC: 91 20    ; src[4] = 0
  INY                                                 ; $B3EE: C8
  STA ($20),Y                                         ; $B3EF: 91 20    ; src[5] = 0

  ; -- Relocate slot entries from source to dest
  ; Source slots at offsets $11–$1A, dest free-slot scan starting at $11
  LDY #$11                                            ; $B3F1: A0 11
  STY math_ext                                        ; $B3F3: 84 24    ; src_slot = $11
  STY math_temp1                                      ; $B3F5: 84 25    ; dst_slot = $11
  LDY #$04                                            ; $B3F7: A0 04
  STY math_temp2                                      ; $B3F9: 84 26    ; relocated_count = 4
@reloc_loop:
  LDY math_ext                                        ; $B3FB: A4 24
  LDA ($20),Y                                         ; $B3FD: B1 20    ; read src slot
  CMP #$FF                                            ; $B3FF: C9 FF
  BEQ @finalize_owner                                 ; $B401: F0 1E    ; empty slot → done
  PHA                                                 ; $B403: 48       ; save slot value
  LDA #$FF                                            ; $B404: A9 FF
  STA ($20),Y                                         ; $B406: 91 20    ; clear src slot
@find_free_slot:
  LDY math_temp1                                      ; $B408: A4 25
  INC math_temp1                                      ; $B40A: E6 25    ; advance dst_slot
  LDA ($22),Y                                         ; $B40C: B1 22
  CMP #$FF                                            ; $B40E: C9 FF
  BNE @find_free_slot                                 ; $B410: D0 F6  ; not free → keep scanning
  PLA                                                 ; $B412: 68       ; restore slot value
  STA ($22),Y                                         ; $B413: 91 22    ; write to dest free slot
  INC math_temp2                                      ; $B415: E6 26    ; relocated_count += 2
  INC math_temp2                                      ; $B417: E6 26
  INC math_ext                                        ; $B419: E6 24    ; advance src_slot
  LDY math_ext                                        ; $B41B: A4 24
  CPY #$1B                                            ; $B41D: C0 1B
  BCC @reloc_loop                                     ; $B41F: 90 DA  ; more slots → continue

@finalize_owner:
  ; Mark absorbed province: set owner field to 7 (neutralized)
  LDY #$00                                            ; $B421: A0 00
  LDA ($20),Y                                         ; $B423: B1 20
  AND #$F8                                            ; $B425: 29 F8    ; clear owner bits
  ORA #$07                                            ; $B427: 09 07    ; set owner = 7
  STA ($20),Y                                         ; $B429: 91 20
  LDA math_temp2                                      ; $B42B: A5 26    ; A = relocated_count
  JSR Proc_D152                                       ; $B42D: 20 52 D1 ; decrement game counter
  JMP ProvinceEvalExit                                ; $B430: 4C 7D B1 ; common exit → BEC7 (end turn)

  ; =========================================================================
  ; Nested: @eval_single_owned ($B433)
  ; Count consecutive provinces owned by current player starting at
  ; province_idx. If exactly 1, compute weakness metric and track minimum.
  ; =========================================================================
@eval_single_owned:
  LDA a:province_idx                                  ; $B433: AD 36 00
  ASL A                                               ; $B436: 0A       ; ×2
  ASL A                                               ; $B437: 0A       ; ×4
  ASL A                                               ; $B438: 0A       ; ×8
  STA math_ext                                        ; $B439: 85 24    ; table offset
  LDA #$00                                            ; $B43B: A9 00
  STA math_temp1                                      ; $B43D: 85 25    ; consecutive_count = 0
@count_loop:
  LDY math_ext                                        ; $B43F: A4 24
  LDA $9D72,Y                                         ; $B441: B9 72 9D
  BMI @count_done                                     ; $B444: 30 11  ; negative → invalid, skip eval
  JSR Proc_D105                                       ; $B446: 20 05 D1 ; get owner
  AND #$07                                            ; $B449: 29 07
  CMP sram_player_id                                  ; $B44B: CD 03 6F
  BNE @count_next                                     ; $B44E: D0 02  ; not owned → skip count++
  INC math_temp1                                      ; $B450: E6 25    ; consecutive_count++
@count_next:
  INC math_ext                                        ; $B452: E6 24    ; next table entry
  JMP @count_loop                                     ; $B454: 4C 3F B4

@count_done:
  ; Only proceed if exactly 1 consecutive owned province
  LDA math_temp1                                      ; $B457: A5 25
  CMP #$01                                            ; $B459: C9 01
  BNE @eval_done                                      ; $B45B: D0 3E

  ; Compute weakness metric:
  ;   metric = Proc_D304(slot_count) + record[8..9] + record[14..15]
  LDA a:province_idx                                  ; $B45D: AD 36 00
  JSR Proc_D304                                       ; $B460: 20 04 D3 ; → A = active slot count
  LDY #$08                                            ; $B463: A0 08
  LDA ($20),Y                                         ; $B465: B1 20    ; record[8] lo
  STA math_temp2                                      ; $B467: 85 26
  INY                                                 ; $B469: C8
  LDA ($20),Y                                         ; $B46A: B1 20    ; record[9] hi
  STA math_temp3                                      ; $B46C: 85 27
  LDY #$0E                                            ; $B46E: A0 0E
  LDA ($20),Y                                         ; $B470: B1 20    ; record[14] lo
  CLC                                                 ; $B472: 18
  ADC math_temp2                                      ; $B473: 65 26    ; + slot_count
  STA math_temp2                                      ; $B475: 85 26
  INY                                                 ; $B477: C8
  LDA ($20),Y                                         ; $B478: B1 20    ; record[15] hi
  ADC math_temp3                                      ; $B47A: 65 27
  STA math_temp3                                      ; $B47C: 85 27

  ; Compare against current best (skip if metric >= best_weak)
  LDA math_temp2                                      ; $B47E: A5 26
  SEC                                                 ; $B480: 38
  SBC a:best_weak_idx                                 ; $B481: ED 38 00
  LDA math_temp3                                      ; $B484: A5 27
  SBC a:best_weak_val                                 ; $B486: ED 39 00
  BCS @eval_done                                      ; $B489: B0 10    ; metric >= best → no update

  ; New minimum found — update best
  LDA math_temp2                                      ; $B48B: A5 26
  STA a:best_weak_idx                                 ; $B48D: 8D 38 00
  LDA math_temp3                                      ; $B490: A5 27
  STA a:best_weak_val                                 ; $B492: 8D 39 00
  LDA a:province_idx                                  ; $B495: AD 36 00
  STA a:first_owned_idx                               ; $B498: 8D 37 00 ; save as candidate
@eval_done:
  RTS                                                 ; $B49B: 60
.endproc


;===============================================================================
; $B49C: AiTurnDispatch
;===============================================================================
.proc AiTurnDispatch
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026
  math_temp3               = $0027
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_sub_idx             = $0039
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C
  work_temp_1              = $003D
  work_temp_2              = $003E
  work_record_idx          = $003F
  work_record_val          = $0040
  work_search_result       = $0041
  work_search_max          = $0045
  sram_kingdom_index       = $6F02
  sram_player_id           = $6F03
  sram_game_start_flag     = $6F8B

  JSR B1F_RandomByte4                                 ; $B49C: 20 AA E8
  AND #$7F                                            ; $B49F: 29 7F
  CMP #$32                                            ; $B4A1: C9 32
  BCS AiTurnDispatch                                  ; $B4A3: B0 F7
  CMP #$0A                                            ; $B4A5: C9 0A
  BCS @BeginSearch                                    ; $B4A7: B0 03
  JMP @AiActionSelect                                 ; $B4A9: 4C FC B5
@BeginSearch:
  JSR Proc_D249                                       ; $B4AC: 20 49 D2
  STA a:$0045                                         ; $B4AF: 8D 45 00
  JSR LoadRecord                                  ; $B4B2: 20 3A D0
  LDA #$03                                            ; $B4B5: A9 03
  STA a:$0041                                         ; $B4B7: 8D 41 00
  LDA #$00                                            ; $B4BA: A9 00
  STA a:$0036                                         ; $B4BC: 8D 36 00

;===============================================================================
; $B4BF: @ScanOwnedProvinces
;===============================================================================
@ScanOwnedProvinces:
  LDA a:$0036                                         ; $B4BF: AD 36 00
  CMP a:$0045                                         ; $B4C2: CD 45 00
  BEQ @SkipToNext                                     ; $B4C5: F0 25
  JSR Proc_D105                                       ; $B4C7: 20 05 D1
  CMP $6F03                                           ; $B4CA: CD 03 6F
  BNE @SkipToNext                                     ; $B4CD: D0 1D
  JSR Proc_D1A4                                       ; $B4CF: 20 A4 D1
  BNE @SkipToNext                                     ; $B4D2: D0 18
  LDA a:$0036                                         ; $B4D4: AD 36 00
  JSR Proc_D304                                       ; $B4D7: 20 04 D3
  CMP a:$0041                                         ; $B4DA: CD 41 00
  BCC @SkipToNext                                     ; $B4DD: 90 0D
  JSR $B53E                                           ; $B4DF: 20 3E B5
  LDA a:$003D                                         ; $B4E2: AD 3D 00
  CMP #$FF                                            ; $B4E5: C9 FF
  BEQ @SkipToNext                                     ; $B4E7: F0 03
  JMP @ScanOwnedProvinces                             ; $B4E9: 4C BF B4
@SkipToNext:
  INC a:$0036                                         ; $B4EC: EE 36 00
  LDA a:$0036                                         ; $B4EF: AD 36 00
  CMP #$1E                                            ; $B4F2: C9 1E
  BCC @ScanOwnedProvinces                              ; $B4F4: 90 C9
  LDA a:$0040                                         ; $B4F6: AD 40 00
  CLC                                                 ; $B4F9: 18
  ADC #$02                                            ; $B4FA: 69 02
  STA a:$0041                                         ; $B4FC: 8D 41 00
  LDA #$00                                            ; $B4FF: A9 00
  STA a:$0036                                         ; $B501: 8D 36 00

;===============================================================================
; $B504: @ScanEnemyProvinces
;===============================================================================
@ScanEnemyProvinces:
  LDA a:$0036                                         ; $B504: AD 36 00
  CMP a:$0045                                         ; $B507: CD 45 00
  BEQ @SkipEnemyNext                                  ; $B50A: F0 25
  JSR Proc_D105                                       ; $B50C: 20 05 D1
  CMP $6F03                                           ; $B50F: CD 03 6F
  BNE @SkipEnemyNext                                  ; $B512: D0 1D
  JSR Proc_D1A4                                       ; $B514: 20 A4 D1
  BEQ @SkipEnemyNext                                  ; $B517: F0 18
  LDA a:$0036                                         ; $B519: AD 36 00
  JSR Proc_D304                                       ; $B51C: 20 04 D3
  CMP a:$0041                                         ; $B51F: CD 41 00
  BCC @SkipEnemyNext                                  ; $B522: 90 0D
  JSR $B53E                                           ; $B524: 20 3E B5
  LDA a:$003D                                         ; $B527: AD 3D 00
  CMP #$FF                                            ; $B52A: C9 FF
  BEQ @SkipEnemyNext                                  ; $B52C: F0 03
  JMP @ScanEnemyProvinces                             ; $B52E: 4C 04 B5
@SkipEnemyNext:
  INC a:$0036                                         ; $B531: EE 36 00
  LDA a:$0036                                         ; $B534: AD 36 00
  CMP #$1E                                            ; $B537: C9 1E
  BCC @ScanEnemyProvinces                             ; $B539: 90 C9
  JMP AiDev_Main                               ; $B53B: 4C 7A BD
  LDA a:$0036                                         ; $B53E: AD 36 00
  STA a:$003B                                         ; $B541: 8D 3B 00
  LDA #$00                                            ; $B544: A9 00
  STA a:$0036                                         ; $B546: 8D 36 00
  LDA #$FF                                            ; $B549: A9 FF
  STA a:$003C                                         ; $B54B: 8D 3C 00
  STA a:$003D                                         ; $B54E: 8D 3D 00
@InnerLoop:
  LDA a:$0036                                         ; $B551: AD 36 00
  CMP a:$0045                                         ; $B554: CD 45 00
  BEQ @SkipToInner                                    ; $B557: F0 0D
  JSR Proc_D105                                       ; $B559: 20 05 D1
  CMP $6F03                                           ; $B55C: CD 03 6F
  BNE @SkipToInner                                    ; $B55F: D0 2A
  JSR Proc_D1A4                                       ; $B561: 20 A4 D1
  BEQ @SkipToInner                                    ; $B564: F0 25
  LDX a:$003B                                         ; $B566: AE 3B 00
  LDY a:$0036                                         ; $B569: AC 36 00
  JSR Proc_D583                                       ; $B56C: 20 83 D5
  CMP #$FF                                            ; $B56F: C9 FF
  BNE @SkipToInner                                    ; $B571: D0 18
  LDA a:$0036                                         ; $B573: AD 36 00
  JSR Proc_D304                                       ; $B576: 20 04 D3
  CMP a:$003C                                         ; $B579: CD 3C 00
  BCS @SkipToInner                                    ; $B57C: B0 0D
  CMP #$0A                                            ; $B57E: C9 0A
  BCS @SkipToInner                                    ; $B580: B0 09
  STA a:$003C                                         ; $B582: 8D 3C 00
  LDA a:$0036                                         ; $B585: AD 36 00
  STA a:$003D                                         ; $B588: 8D 3D 00
@SkipToInner:
  INC a:$0036                                         ; $B58B: EE 36 00
  LDA a:$0036                                         ; $B58E: AD 36 00
  CMP #$1E                                            ; $B591: C9 1E
  BCC @InnerLoop                                      ; $B593: 90 BC
  LDA a:$003D                                         ; $B595: AD 3D 00
  CMP #$FF                                            ; $B598: C9 FF
  BEQ @NoMatchExit                                    ; $B59A: F0 59
  LDA a:$003B                                         ; $B59C: AD 3B 00
  JSR Proc_D105                                       ; $B59F: 20 05 D1
  LDA #$11                                            ; $B5A2: A9 11
  STA $24                                             ; $B5A4: 85 24
  LDA #$00                                            ; $B5A6: A9 00
  STA $25                                             ; $B5A8: 85 25
  STA $26                                             ; $B5AA: 85 26
  LDY $24                                             ; $B5AC: A4 24
@FindBestLoop:
  LDA ($20),Y                                         ; $B5AE: B1 20
  CMP #$FF                                            ; $B5B0: C9 FF
  BEQ @FindBestSkip                                   ; $B5B2: F0 14
  LDY #$01                                            ; $B5B4: A0 01
  JSR $D2AB                                           ; $B5B6: 20 AB D2
  CMP $25                                             ; $B5B9: C5 25
  BCC @FindBestSkip                                   ; $B5BB: 90 0B
  STA $25                                             ; $B5BD: 85 25
  LDY $24                                             ; $B5BF: A4 24
  STY $26                                             ; $B5C1: 84 26
  LDA ($20),Y                                         ; $B5C3: B1 20
  STA a:$003A                                         ; $B5C5: 8D 3A 00
@FindBestSkip:
  INC $24                                             ; $B5C8: E6 24
  LDA $24                                             ; $B5CA: A5 24
  CMP #$1B                                            ; $B5CC: C9 1B
  BCC @FindBestLoop                                   ; $B5CE: 90 DC
  LDY $26                                             ; $B5D0: A4 26
  LDA #$FF                                            ; $B5D2: A9 FF
  STA ($20),Y                                         ; $B5D4: 91 20
  LDA a:$003B                                         ; $B5D6: AD 3B 00
  JSR Proc_D3DD                                       ; $B5D9: 20 DD D3
  LDA a:$003D                                         ; $B5DC: AD 3D 00
  JSR Proc_D105                                       ; $B5DF: 20 05 D1
  LDY #$10                                            ; $B5E2: A0 10
@FindBestSlot:
  INY                                                 ; $B5E4: C8
  LDA ($20),Y                                         ; $B5E5: B1 20
  CMP #$FF                                            ; $B5E7: C9 FF
  BNE @FindBestSlot                                   ; $B5E9: D0 F9
  LDA a:$003A                                         ; $B5EB: AD 3A 00
  STA ($20),Y                                         ; $B5EE: 91 20
  LDA #$02                                            ; $B5F0: A9 02
  JSR Proc_D165                                       ; $B5F2: 20 65 D1
@NoMatchExit:
  LDA a:$003B                                         ; $B5F5: AD 3B 00
  STA a:$0036                                         ; $B5F8: 8D 36 00
  RTS                                                 ; $B5FB: 60


;===============================================================================
; $B5FC: @AiActionSelect
;===============================================================================
@AiActionSelect:
  JSR B1F_RandomByte3                                 ; $B5FC: 20 9A E8
  AND #$7F                                            ; $B5FF: 29 7F
  CMP #$5A                                            ; $B601: C9 5A
  BCS @AiActionSelect                                 ; $B603: B0 F7
  CMP #$1E                                            ; $B605: C9 1E
  BCC @DoAbsorbAction                                  ; $B607: 90 07
  CMP #$3C                                            ; $B609: C9 3C
  BCC @ActionDomestic                                 ; $B60B: 90 06
  JMP $B619                                           ; $B60D: 4C 19 B6
  JMP AiAbsorbEntityAction                             ; $B610: 4C B2 BB
@ActionDomestic:
  JMP AiDomesticAction                                ; $B613: 4C 8B B9
@ExitToBEC7:
  JMP $BEC7                                           ; $B616: 4C C7 BE
  LDA $6F03                                           ; $B619: AD 03 6F
  JSR Proc_D319                                       ; $B61C: 20 19 D3
  LDY #$00                                            ; $B61F: A0 00
  LDA ($24),Y                                         ; $B621: B1 24
  STA a:$0040                                         ; $B623: 8D 40 00
  JSR $B837                                           ; $B626: 20 37 B8
  LDA a:$003D                                         ; $B629: AD 3D 00
  CMP #$FF                                            ; $B62C: C9 FF
  BEQ @ActionExit                                     ; $B62E: F0 26
  STA a:$0042                                         ; $B630: 8D 42 00
  LDA #$00                                            ; $B633: A9 00
  STA $2A                                             ; $B635: 85 2A
  STA $2B                                             ; $B637: 85 2B
@CountOwnedLoop:
  LDA $2A                                             ; $B639: A5 2A
  JSR Proc_D319                                       ; $B63B: 20 19 D3
  LDY #$00                                            ; $B63E: A0 00
  LDA ($24),Y                                         ; $B640: B1 24
  CMP #$FF                                            ; $B642: C9 FF
  BEQ @CountOwnedNext                                 ; $B644: F0 02
  INC $2B                                             ; $B646: E6 2B
@CountOwnedNext:
  INC $2A                                             ; $B648: E6 2A
  LDA $2A                                             ; $B64A: A5 2A
  CMP #$07                                            ; $B64C: C9 07
  BCC @CountOwnedLoop                                 ; $B64E: 90 E9
  LDA $2B                                             ; $B650: A5 2B
  CMP #$03                                            ; $B652: C9 03
  BCS @SkipCountExit                                  ; $B654: B0 03
@ActionExit:
  JMP @ExitToBEC7                                     ; $B656: 4C 16 B6
  LDA $6F03                                           ; $B659: AD 03 6F
  JSR Proc_D319                                       ; $B65C: 20 19 D3
  LDX #$00                                            ; $B65F: A2 00
  LDY #$04                                            ; $B661: A0 04
  LDA ($24),Y                                         ; $B663: B1 24
  LDY #$05                                            ; $B665: A0 05
  CLC                                                 ; $B667: 18
  ADC ($24),Y                                         ; $B668: 71 24
  LDY #$06                                            ; $B66A: A0 06
  CLC                                                 ; $B66C: 18
  ADC ($24),Y                                         ; $B66D: 71 24
  LDY #$07                                            ; $B66F: A0 07
  CLC                                                 ; $B671: 18
  ADC ($24),Y                                         ; $B672: 71 24
  CMP #$00                                            ; $B674: C9 00
  BNE @ActionExit                                     ; $B676: D0 DE
  JSR ScanEntityOwnership                             ; $B678: 20 98 B8
  CPX #$02                                            ; $B67B: E0 02
  BCC @ActionExit                                     ; $B67D: 90 D7
  LDY #$00                                            ; $B67F: A0 00
  STY a:$0036                                         ; $B681: 8C 36 00
  STY a:$0037                                         ; $B684: 8C 37 00
  STY a:$0038                                         ; $B687: 8C 38 00
@FindStrongestLoop:
  LDY a:$0036                                         ; $B68A: AC 36 00
  LDA $6F73,Y                                         ; $B68D: B9 73 6F
  BNE @FindStrongestNext                              ; $B690: D0 16
  LDA a:$0036                                         ; $B692: AD 36 00
  JSR Proc_D080                                       ; $B695: 20 80 D0
  LDA $2B                                             ; $B698: A5 2B
  CMP a:$0037                                         ; $B69A: CD 37 00
  BCC @FindStrongestNext                              ; $B69D: 90 09
  STA a:$0037                                         ; $B69F: 8D 37 00
  LDA a:$0036                                         ; $B6A2: AD 36 00
  STA a:$0038                                         ; $B6A5: 8D 38 00
@FindStrongestNext:
  INC a:$0036                                         ; $B6A8: EE 36 00
  LDA a:$0036                                         ; $B6AB: AD 36 00
  CMP #$07                                            ; $B6AE: C9 07
  BCC @FindStrongestLoop                              ; $B6B0: 90 D8
  LDA $6F03                                           ; $B6B2: AD 03 6F
  JSR Proc_D080                                       ; $B6B5: 20 80 D0
  LDA $2B                                             ; $B6B8: A5 2B
  CLC                                                 ; $B6BA: 18
  ADC #$02                                            ; $B6BB: 69 02
  CMP a:$0037                                         ; $B6BD: CD 37 00
  BCC @DoTransfer                                     ; $B6C0: 90 03
  JMP @ActionExit                                     ; $B6C2: 4C 56 B6
@DoTransfer:
  LDA a:$0037                                         ; $B6C5: AD 37 00
  STA $20                                             ; $B6C8: 85 20
  LDA #$1E                                            ; $B6CA: A9 1E
  STA $21                                             ; $B6CC: 85 21
  JSR Proc_D471                                       ; $B6CE: 20 71 D4
  LDA $2A                                             ; $B6D1: A5 2A
  CLC                                                 ; $B6D3: 18
  ADC #$46                                            ; $B6D4: 69 46
  STA $21                                             ; $B6D6: 85 21
  LDA $2B                                             ; $B6D8: A5 2B
  ADC #$00                                            ; $B6DA: 69 00
  STA $22                                             ; $B6DC: 85 22
  LDA #$0A                                            ; $B6DE: A9 0A
  STA $23                                             ; $B6E0: 85 23
  LDA #$00                                            ; $B6E2: A9 00
  STA $24                                             ; $B6E4: 85 24
  JSR Proc_D40F                                       ; $B6E6: 20 0F D4
  LDA $21                                             ; $B6E9: A5 21
  STA $042F                                           ; $B6EB: 8D 2F 04
  LDA $22                                             ; $B6EE: A5 22
  STA $0430                                           ; $B6F0: 8D 30 04
  ASL $042F                                           ; $B6F3: 0E 2F 04
  ROL $0430                                           ; $B6F6: 2E 30 04
  ASL $042F                                           ; $B6F9: 0E 2F 04
  ROL $0430                                           ; $B6FC: 2E 30 04
  LDA #$00                                            ; $B6FF: A9 00
  STA $0431                                           ; $B701: 8D 31 04
  LDA #$00                                            ; $B704: A9 00
  STA a:$0039                                         ; $B706: 8D 39 00
  LDA #$64                                            ; $B709: A9 64
  JSR Proc_D4BB                                       ; $B70B: 20 BB D4
  CMP #$32                                            ; $B70E: C9 32
  BCC @ApplyResult                                    ; $B710: 90 28
  LDA #$01                                            ; $B712: A9 01
  STA a:$0039                                         ; $B714: 8D 39 00
  LDA $21                                             ; $B717: A5 21
  STA $20                                             ; $B719: 85 20
  LDA $22                                             ; $B71B: A5 22
  STA $21                                             ; $B71D: 85 21
  LDA #$00                                            ; $B71F: A9 00
  STA $22                                             ; $B721: 85 22
  LDA #$06                                            ; $B723: A9 06
  STA $23                                             ; $B725: 85 23
  JSR Proc_D438                                       ; $B727: 20 38 D4
  LDA a:$0026                                         ; $B72A: AD 26 00
  STA $042F                                           ; $B72D: 8D 2F 04
  LDA $27                                             ; $B730: A5 27
  STA $0430                                           ; $B732: 8D 30 04
  LDA #$00                                            ; $B735: A9 00
  STA $0431                                           ; $B737: 8D 31 04
@ApplyResult:
  LDA $042F                                           ; $B73A: AD 2F 04
  STA a:$003A                                         ; $B73D: 8D 3A 00
  LDA $0431                                           ; $B740: AD 31 04
  STA a:$003B                                         ; $B743: 8D 3B 00
  JSR $B7A2                                           ; $B746: 20 A2 B7
  BCS @SkipTransfer                                   ; $B749: B0 03
  JMP @ActionExit                                     ; $B74B: 4C 56 B6
@SkipTransfer:
  LDA a:$0038                                         ; $B74E: AD 38 00
  JSR Proc_D319                                       ; $B751: 20 19 D3
  LDY #$03                                            ; $B754: A0 03
  LDA ($24),Y                                         ; $B756: B1 24
  CMP #$03                                            ; $B758: C9 03
  BNE @SkipSwap                                       ; $B75A: D0 09
  JSR MarkSwapArmyFlags                               ; $B75C: 20 0A B9
  JSR AdjustSwapPositions                             ; $B75F: 20 CE B7
  JMP @ExitToBEC7                                     ; $B762: 4C 16 B6
  LDA $6F03                                           ; $B765: AD 03 6F
  JSR Proc_D319                                       ; $B768: 20 19 D3
  LDY #$00                                            ; $B76B: A0 00
  LDA ($24),Y                                         ; $B76D: B1 24
  STA a:$0040                                         ; $B76F: 8D 40 00
  LDA a:$0038                                         ; $B772: AD 38 00
  JSR Proc_D319                                       ; $B775: 20 19 D3
  LDY #$00                                            ; $B778: A0 00
  LDA ($24),Y                                         ; $B77A: B1 24
  STA a:$0041                                         ; $B77C: 8D 41 00
  LDY #$03                                            ; $B77F: A0 03
  LDA ($24),Y                                         ; $B781: B1 24
  STA $6F44                                           ; $B783: 8D 44 6F
  LDA #$F8                                            ; $B786: A9 F8
  STA $6F8B                                           ; $B788: 8D 8B 6F
@WaitForFlag:
  LDA $6F8B                                           ; $B78B: AD 8B 6F
  CMP #$F8                                            ; $B78E: C9 F8
  BEQ @WaitForFlag                                    ; $B790: F0 F9
  CMP #$00                                            ; $B792: C9 00
  BEQ @DoSwap                                         ; $B794: F0 03
  JMP @ExitToBEC7                                     ; $B796: 4C 16 B6
@DoSwap:
  JSR MarkSwapArmyFlags                               ; $B799: 20 0A B9
  JSR AdjustSwapPositions                             ; $B79C: 20 CE B7
  JMP @ExitToBEC7                                     ; $B79F: 4C 16 B6
  LDA $6F03                                           ; $B7A2: AD 03 6F
  JSR FindEntityForChar                               ; $B7A5: 20 55 B9
  JSR Proc_D105                                       ; $B7A8: 20 05 D1
  LDA a:$0039                                         ; $B7AB: AD 39 00
  BNE @SubtractOffset                                 ; $B7AE: D0 0F
  LDY #$02                                            ; $B7B0: A0 02
  LDA ($20),Y                                         ; $B7B2: B1 20
  SEC                                                 ; $B7B4: 38
  SBC $042F                                           ; $B7B5: ED 2F 04
  INY                                                 ; $B7B8: C8
  LDA ($20),Y                                         ; $B7B9: B1 20
  SBC $0430                                           ; $B7BB: ED 30 04
  RTS                                                 ; $B7BE: 60
@SubtractOffset:
  LDY #$04                                            ; $B7BF: A0 04
  LDA ($20),Y                                         ; $B7C1: B1 20
  SEC                                                 ; $B7C3: 38
  SBC $042F                                           ; $B7C4: ED 2F 04
  INY                                                 ; $B7C7: C8
  LDA ($20),Y                                         ; $B7C8: B1 20
  SBC $0430                                           ; $B7CA: ED 30 04
  RTS                                                 ; $B7CD: 60


;===============================================================================
; $B7CE: AdjustSwapPositions
; Adjusts 16-bit position offsets in slot data during a character swap.
; Phase 1: Subtract delta ($003A/$003B) from current character ($6F03) slot.
; Phase 2: Add delta to target character ($0038) slot.
; Phase 3: Refresh sub-character info for all slots matching $6F03.
; $0039 selects field: 0 = offsets at [2..3], else offsets at [4..5].
;===============================================================================
AdjustSwapPositions:
  ; --- Phase 1: Subtract position delta from current character's slot ---
  LDA $6F03                                           ; $B7CE: AD 03 6F  ; slot type of current character
  JSR FindEntityForChar                               ; $B7D1: 20 55 B9  ; find matching slot index
  JSR Proc_D105                                       ; $B7D4: 20 05 D1  ; resolve slot data pointer -> ($20)
  LDA a:$0039                                         ; $B7D7: AD 39 00  ; field selector
  BNE @SubtractAltOffset                              ; $B7DA: D0 15    ; != 0 -> use offsets [4..5]
  ; Subtract 16-bit delta from offsets [2..3]
  LDY #$02                                            ; $B7DC: A0 02
  LDA ($20),Y                                         ; $B7DE: B1 20
  SEC                                                 ; $B7E0: 38
  SBC a:$003A                                         ; $B7E1: ED 3A 00  ; low byte
  STA ($20),Y                                         ; $B7E4: 91 20
  INY                                                 ; $B7E6: C8
  LDA ($20),Y                                         ; $B7E7: B1 20
  SBC a:$003B                                         ; $B7E9: ED 3B 00  ; high byte
  STA ($20),Y                                         ; $B7EC: 91 20
  JMP @Phase2_AddToTarget                             ; $B7EE: 4C 03 B8  ; skip to phase 2
@SubtractAltOffset:
  ; Subtract 16-bit delta from offsets [4..5]
  LDY #$04                                            ; $B7F1: A0 04
  LDA ($20),Y                                         ; $B7F3: B1 20
  SEC                                                 ; $B7F5: 38
  SBC a:$003A                                         ; $B7F6: ED 3A 00  ; low byte
  STA ($20),Y                                         ; $B7F9: 91 20
  INY                                                 ; $B7FB: C8
  LDA ($20),Y                                         ; $B7FC: B1 20
  SBC a:$003B                                         ; $B7FE: ED 3B 00  ; high byte
  STA ($20),Y                                         ; $B801: 91 20
  ; --- Phase 2: Add position delta to target character's slot ---
@Phase2_AddToTarget:
  LDA a:$0038                                         ; $B803: AD 38 00  ; slot type of swap target
  JSR FindEntityForChar                               ; $B806: 20 55 B9  ; find matching slot index
  JSR Proc_D105                                       ; $B809: 20 05 D1  ; resolve slot data pointer -> ($20)
  LDA a:$0039                                         ; $B80C: AD 39 00  ; field selector
  BNE @AddAltOffset                                   ; $B80F: D0 13    ; != 0 -> use offsets [4..5]
  ; Add 16-bit delta to offsets [2..3]
  LDY #$02                                            ; $B811: A0 02
  LDA ($20),Y                                         ; $B813: B1 20
  CLC                                                 ; $B815: 18
  ADC a:$003A                                         ; $B816: 6D 3A 00  ; low byte
  STA ($20),Y                                         ; $B819: 91 20
  INY                                                 ; $B81B: C8
  LDA ($20),Y                                         ; $B81C: B1 20
  ADC a:$003B                                         ; $B81E: 6D 3B 00  ; high byte
  STA ($20),Y                                         ; $B821: 91 20
  RTS                                                 ; $B823: 60
@AddAltOffset:
  ; Add 16-bit delta to offsets [4..5]
  LDY #$04                                            ; $B824: A0 04
  LDA ($20),Y                                         ; $B826: B1 20
  CLC                                                 ; $B828: 18
  ADC a:$003A                                         ; $B829: 6D 3A 00  ; low byte
  STA ($20),Y                                         ; $B82C: 91 20
  INY                                                 ; $B82E: C8
  LDA ($20),Y                                         ; $B82F: B1 20
  ADC a:$003B                                         ; $B831: 6D 3B 00  ; high byte
  STA ($20),Y                                         ; $B834: 91 20
  RTS                                                 ; $B836: 60
  ; --- Phase 3: Refresh sub-character info for matching slots ---
  LDA #$00                                            ; $B837: A9 00
  STA a:$0036                                         ; $B839: 8D 36 00  ; slot index = 0
  LDA #$FF                                            ; $B83C: A9 FF
  STA a:$003D                                         ; $B83E: 8D 3D 00  ; best match = none
  LDA #$00                                            ; $B841: A9 00
  STA a:$003E                                         ; $B843: 8D 3E 00  ; best distance = 0
@Loop:
  LDA a:$0036                                         ; $B846: AD 36 00  ; current slot index
  JSR Proc_D105                                       ; $B849: 20 05 D1  ; resolve slot data
  CMP $6F03                                           ; $B84C: CD 03 6F  ; does slot match current character?
  BNE @NextSlot                                       ; $B84F: D0 03
  JSR FindBestSubCharacter                              ; $B851: 20 5F B8  ; find best sub-character in slot
@NextSlot:
  INC a:$0036                                         ; $B854: EE 36 00
  LDA a:$0036                                         ; $B857: AD 36 00
  CMP #$1E                                            ; $B85A: C9 1E    ; 30 slots total
  BCC @Loop                                           ; $B85C: 90 E8
  RTS                                                 ; $B85E: 60


;===============================================================================
; $B85F: FindBestSubCharacter
; Scan sub-character list (offsets $11-$1A) in the current character's slot
; and find the sub-character with the highest score (byte 3 of sub-char record).
; Results: $003D = best sub-character ID ($FF if none), $003E = best score.
;===============================================================================
FindBestSubCharacter:
  LDA a:$0036                                         ; $B85F: AD 36 00  ; slot index
  JSR Proc_D105                                       ; $B862: 20 05 D1  ; resolve entity data pointer -> ($20)
  LDA #$11                                            ; $B865: A9 11    ; start at offset $11 (sub-char list)
  STA a:$003C                                         ; $B867: 8D 3C 00  ; scan offset = $11
@ScanLoop:
  LDY a:$003C                                         ; $B86A: AC 3C 00  ; current offset in entity record
  LDA ($20),Y                                         ; $B86D: B1 20    ; sub-character ID at this slot
  CMP #$FF                                            ; $B86F: C9 FF    ; empty slot marker?
  BEQ @NextEntry                                      ; $B871: F0 0A    ; yes, skip
  CMP a:$0040                                         ; $B873: CD 40 00  ; same as current character?
  BEQ @NextEntry                                      ; $B876: F0 05    ; yes, skip self
  LDY #$03                                            ; $B878: A0 03    ; byte 3 = sub-character score
  JSR $D2AB                                           ; $B87A: 20 AB D2  ; read score from sub-char record
  CMP a:$003E                                         ; $B87D: CD 3E 00  ; better than current best?
  BCC @NextEntry                                      ; $B880: 90 0B    ; no, skip update
  STA a:$003E                                         ; $B882: 8D 3E 00  ; new best score
  LDY a:$003C                                         ; $B885: AC 3C 00  ; reload offset
  LDA ($20),Y                                         ; $B888: B1 20    ; re-read sub-character ID
  STA a:$003D                                         ; $B88A: 8D 3D 00  ; new best sub-character
@NextEntry:
  INC a:$003C                                         ; $B88D: EE 3C 00  ; advance to next sub-char slot
  LDA a:$003C                                         ; $B890: AD 3C 00
  CMP #$1B                                            ; $B893: C9 1B    ; scanned all 10 sub-char entries?
  BCC @ScanLoop                                       ; $B895: 90 D3    ; no, continue
  RTS                                                 ; $B897: 60


;-------------------------------------------------------------------------------
; $B898: ScanEntityOwnership (nested in AiTurnDispatch)
;-------------------------------------------------------------------------------
; Scan all entities (0–$1D) and their slot-table entries ($9D72, 8 per entity)
; to determine which players have no active type-7 entities outside their home
; province.  Initializes $6F73[0..7] = $FF, then clears a player's slot to $00
; whenever a qualifying entity is found.  Returns X = count of $00 slots
; (players with active entities) among indices 0–6.
;-------------------------------------------------------------------------------
ScanEntityOwnership:
  LDY #$30                                            ; $B898: A0 30
  JSR B1F_SwitchBank8_A                               ; $B89A: 20 66 F2  ; switch to bank $30 for $9D72 table

  ; --- Initialize $6F73[0..7] = $FF (all players default to "no entities") ---
  LDY #$07                                            ; $B89D: A0 07
@ClearLoop:
  LDA #$FF                                            ; $B89F: A9 FF
  STA $6F73,Y                                         ; $B8A1: 99 73 6F
  DEY                                                 ; $B8A4: 88
  BPL @ClearLoop                                      ; $B8A5: 10 F8

  ; --- Outer loop: iterate entity_idx from 0 to $1D ---
  LDA #$00                                            ; $B8A7: A9 00
  STA a:work_outer_idx                                ; $B8A9: 8D 36 00
  STA a:$0037                                         ; $B8AC: 8D 37 00
@EntityLoop:
  LDA #$00                                            ; $B8AF: A9 00
  STA a:work_sub_idx                                  ; $B8B1: 8D 39 00  ; reset slot counter
  LDA a:work_outer_idx                                ; $B8B4: AD 36 00
  JSR Proc_D105                                       ; $B8B7: 20 05 D1  ; A = entity owner, ($20) = record ptr
  CMP sram_player_id                                  ; $B8BA: CD 03 6F  ; only process entities owned by current player
  BNE @NextEntity                                     ; $B8BD: D0 31  ; skip if not current player's entity

  ; --- Compute table offset: entity_idx * 8 → Y ---
  LDA a:work_outer_idx                                ; $B8BF: AD 36 00
  ASL A                                               ; $B8C2: 0A       ; ×2
  ASL A                                               ; $B8C3: 0A       ; ×4
  ASL A                                               ; $B8C4: 0A       ; ×8
  TAY                                                 ; $B8C5: A8

  ; --- Inner loop: iterate 8 slot entries per entity ---
@SlotLoop:
  LDA $9D72,Y                                         ; $B8C6: B9 72 9D  ; read slot-table byte
  BMI @NextEntity                                     ; $B8C9: 30 25  ; negative = empty/invalid slot, skip
  STA math_acc_hi                                     ; $B8CB: 85 23  ; save table value
  STY math_ext                                        ; $B8CD: 84 24  ; save Y offset (Proc_D105 clobbers Y)
  JSR Proc_D105                                       ; $B8CF: 20 05 D1  ; reload entity record ptr → ($20), A = owner
  CMP #$07                                            ; $B8D2: C9 07  ; entity type in low 3 bits
  BEQ @AdvanceSlot                                    ; $B8D4: F0 0B  ; type 7 → skip (home province marker)
  CMP sram_player_id                                  ; $B8D6: CD 03 6F  ; check if entity belongs to current player
  BEQ @AdvanceSlot                                    ; $B8D9: F0 06  ; skip if same player
  TAY                                                 ; $B8DB: A8       ; Y = entity owner
  LDA #$00                                            ; $B8DC: A9 00
  STA $6F73,Y                                         ; $B8DE: 99 73 6F  ; mark owner as having active entities

@AdvanceSlot:
  LDA math_acc_hi                                     ; $B8E1: A5 23  ; restore table value
  LDY math_ext                                        ; $B8E3: A4 24  ; restore Y offset
  INY                                                 ; $B8E5: C8       ; next slot
  INC a:work_sub_idx                                  ; $B8E6: EE 39 00
  LDX a:work_sub_idx                                  ; $B8E9: AE 39 00
  CPX #$08                                            ; $B8EC: E0 08  ; 8 slots per entity
  BCC @SlotLoop                                       ; $B8EE: 90 D6

@NextEntity:
  INC a:work_outer_idx                                ; $B8F0: EE 36 00
  LDA a:work_outer_idx                                ; $B8F3: AD 36 00
  CMP #$1E                                            ; $B8F6: C9 1E  ; 30 entities total
  BCC @EntityLoop                                     ; $B8F8: 90 B5

  ; --- Count how many $6F73[0..6] == $00 → return in X ---
  LDY #$00                                            ; $B8FA: A0 00
  LDX #$00                                            ; $B8FC: A2 00
@CountZeros:
  LDA $6F73,Y                                         ; $B8FE: B9 73 6F
  BNE @CountNext                                      ; $B901: D0 01  ; skip if non-zero ($FF = no entities)
  INX                                                 ; $B903: E8       ; count this player
@CountNext:
  INY                                                 ; $B904: C8
  CPY #$07                                            ; $B905: C0 07  ; scan indices 0–6 only
  BCC @CountZeros                                     ; $B907: 90 F5
  RTS                                                 ; $B909: 60


;===============================================================================
; $B90A: MarkSwapArmyFlags
; Marks swap flags in the army-data nibbles of two character records during
; a character swap. For each record, one of offsets 4-7 is selected based on
; the other character's index (0-5), and either the high or low nibble is
; set to $A to indicate swap involvement.
; Phase 1: Mark current player ($6F03) record using target ($0038) as key.
; Phase 2: Mark target ($0038) record using current player ($6F03) as key.
;-------------------------------------------------------------------------------
; @ApplyNibbleMarker (nested, $B923):
; Given a character index in A (0-5), select the appropriate nibble offset
; (Y=4-7) in the record pointed to by ($24) and set either the high or low
; nibble to $A. Even indices (0,2,4) -> high nibble; odd (1,3,5) -> low.
;===============================================================================
MarkSwapArmyFlags:
  ; --- Phase 1: Mark current player's record with target's swap flag ---
  LDA a:$6F03                                         ; $B90A: AD 03 6F  ; sram_player_id
  JSR Proc_D319                                       ; $B90D: 20 19 D3  ; resolve current player -> ($24)
  LDA a:$0038                                         ; $B910: AD 38 00  ; target character index
  JSR @ApplyNibbleMarker                               ; $B913: 20 23 B9  ; mark nibble in current player record

  ; --- Phase 2: Mark target's record with current player's swap flag ---
  LDA a:$0038                                         ; $B916: AD 38 00
  JSR Proc_D319                                       ; $B919: 20 19 D3  ; resolve target -> ($24)
  LDA a:$6F03                                         ; $B91C: AD 03 6F  ; sram_player_id
  JSR @ApplyNibbleMarker                               ; $B91F: 20 23 B9  ; mark nibble in target record
  RTS                                                 ; $B922: 60

@ApplyNibbleMarker:
  LDY #$04                                            ; $B923: A0 04  ; default offset for index 0
  CMP #$00                                            ; $B925: C9 00
  BEQ @MarkHighNibble                                  ; $B927: F0 1A
  CMP #$01                                            ; $B929: C9 01
  BEQ @MarkLowNibble                                   ; $B92B: F0 1F
  LDY #$05                                            ; $B92D: A0 05  ; offset for index 2/3
  CMP #$02                                            ; $B92F: C9 02
  BEQ @MarkHighNibble                                  ; $B931: F0 10
  CMP #$03                                            ; $B933: C9 03
  BEQ @MarkLowNibble                                   ; $B935: F0 15
  LDY #$06                                            ; $B937: A0 06  ; offset for index 4/5
  CMP #$04                                            ; $B939: C9 04
  BEQ @MarkHighNibble                                  ; $B93B: F0 06
  CMP #$05                                            ; $B93D: C9 05
  BEQ @MarkLowNibble                                   ; $B93F: F0 0B
  LDY #$07                                            ; $B941: A0 07  ; fallback offset (index >= 6)
@MarkHighNibble:                                       ; set high nibble to $A, preserve low nibble
  LDA ($24),Y                                         ; $B943: B1 24
  AND #$F0                                            ; $B945: 29 F0
  ORA #$0A                                            ; $B947: 09 0A
  STA ($24),Y                                         ; $B949: 91 24
  RTS                                                 ; $B94B: 60
@MarkLowNibble:                                        ; set low nibble to $A, preserve high nibble
  LDA ($24),Y                                         ; $B94C: B1 24
  AND #$0F                                            ; $B94E: 29 0F
  ORA #$A0                                            ; $B950: 09 A0
  STA ($24),Y                                         ; $B952: 91 24
  RTS                                                 ; $B954: 60


;===============================================================================
; $B955: FindEntityForChar
; Searches entities 0-29 for one whose type (low 3 bits of Proc_D105 result)
; matches the input character index (A), and whose army slots ($11-$1A)
; contain the character ID from the input character's record.
; Input:  A = character index (used as type key and to resolve SRAM record)
; Output: A = matching entity index, or $FF with C=0 if not found
;===============================================================================
FindEntityForChar:
  STA $2C                                             ; $B955: 85 2C  ; save type key
  LDY #$00                                            ; $B957: A0 00
  STY $2B                                             ; $B959: 84 2B  ; entity index = 0
  JSR Proc_D319                                       ; $B95B: 20 19 D3  ; resolve char index -> ($24)
  LDY #$00                                            ; $B95E: A0 00
  LDA ($24),Y                                         ; $B960: B1 24  ; read character ID
  STA $2A                                             ; $B962: 85 2A  ; $2A = target character ID
@EntityLoop:                                                ; --- scan loop: entities 0..29 ---
  LDA $2B                                             ; $B964: A5 2B
  JSR Proc_D105                                       ; $B966: 20 05 D1  ; get entity record
  AND #$07                                            ; $B969: 29 07  ; entity type (low 3 bits)
  CMP $2C                                             ; $B96B: C5 2C  ; matches input type?
  BNE @NextEntity                                           ; $B96D: D0 10  ; no -> next entity
  LDY #$11                                            ; $B96F: A0 11  ; yes -> scan army slots $11-$1A
@SlotLoop:
  LDA ($20),Y                                         ; $B971: B1 20
  CMP $2A                                             ; $B973: C5 2A  ; slot contains target char ID?
  BEQ @Found                                           ; $B975: F0 02  ; yes -> found
  INY                                                 ; $B97A: C8
  CPY #$1B                                            ; $B97B: C0 1B
  BCC @SlotLoop                                           ; $B97D: 90 F2  ; continue scanning slots
@Found:
  LDA $2B                                             ; $B977: A5 2B  ; return entity index
  RTS                                                 ; $B979: 60
@NextEntity:                                                ; --- advance to next entity ---
  INC $2B                                             ; $B97F: E6 2B
  LDA $2B                                             ; $B981: A5 2B
  CMP #$1E                                            ; $B983: C9 1E  ; all 30 entities checked?
  BCC @EntityLoop                                           ; $B985: 90 DD
  LDA #$FF                                            ; $B987: A9 FF  ; not found
  CLC                                                 ; $B989: 18
  RTS                                                 ; $B98A: 60


;===============================================================================
; $B98B: AiDomesticAction
; AI domestic action handler: evaluates whether to absorb/recruit a character,
; computes a score based on army values and kingdom tier, performs a random
; threshold check, then executes the action if approved.
; Called from AiTurnDispatch when random value is $1E-$3B.
;-------------------------------------------------------------------------------
; $0036 = entity scan index,  $0037 = best army count (min)
; $0038 = best entity index,  $0039 = field selector from search phase
; $003D = best target char ID, $003E = best target army value
; $003F = best target entity idx, $0042 = current player's char slot
;===============================================================================
AiDomesticAction:
  LDA #$00                                            ; $B98B: A9 00
  STA a:$0036                                         ; $B98D: 8D 36 00
  STA a:$0039                                         ; $B990: 8D 39 00
  LDA #$FF                                            ; $B993: A9 FF
  STA a:$0037                                         ; $B995: 8D 37 00
  STA a:$0038                                         ; $B998: 8D 38 00
@Phase1Loop:                                                ; --- Phase 1: Find entity with fewest army members ---
  LDA a:$0036                                         ; $B99B: AD 36 00
  JSR Proc_D105                                       ; $B99E: 20 05 D1  ; resolve entity record
  CMP $6F03                                           ; $B9A1: CD 03 6F  ; owned by current player?
  BNE @Phase1Next                                           ; $B9A4: D0 1B  ; no -> skip
  JSR UpdateMinArmyCount                              ; $B9A6: 20 82 BB  ; track min army count in $0039
  LDA a:$0036                                         ; $B9A9: AD 36 00
  JSR Proc_D304                                       ; $B9AC: 20 04 D3  ; count occupied army slots
  CMP #$0A                                            ; $B9AF: C9 0A  ; army full (>= 10)?
  BCS @Phase1Next                                           ; $B9B1: B0 0E  ; yes -> skip
  CMP a:$0037                                         ; $B9B3: CD 37 00  ; fewer than current min?
  BCS @Phase1Next                                           ; $B9B6: B0 09  ; no -> skip
  STA a:$0037                                         ; $B9B8: 8D 37 00  ; new min army count
  LDA a:$0036                                         ; $B9BB: AD 36 00
  STA a:$0038                                         ; $B9BE: 8D 38 00  ; new best entity index
@Phase1Next:
  INC a:$0036                                         ; $B9C1: EE 36 00
  LDA a:$0036                                         ; $B9C4: AD 36 00
  CMP #$1E                                            ; $B9C7: C9 1E
  BCC @Phase1Loop                                           ; $B9C9: 90 D0
  LDA a:$0038                                         ; $B9CB: AD 38 00
  CMP #$FF                                            ; $B9CE: C9 FF
  .byte $D0,$03                                       ; $B9D0: D0 03 (BNE mid-instruction target)
  JMP JumpToBEC7                                      ; $B9D2: 4C 3D A2  ; no candidate -> exit
  ; --- Phase 2: Find best non-player target to absorb ---
  LDA #$00                                            ; $B9D5: A9 00
  STA a:$0036                                         ; $B9D7: 8D 36 00  ; reset entity index
  LDA #$FF                                            ; $B9DA: A9 FF
  STA a:$003D                                         ; $B9DC: 8D 3D 00  ; $003D = best char ID ($FF = none)
  STA a:$003E                                         ; $B9DF: 8D 3E 00  ; $003E = lowest army value
  STA a:$003F                                         ; $B9E2: 8D 3F 00  ; $003F = best entity index
@Phase2Loop:                                                ; --- Phase 2 loop: scan entities 0..29 ---
  LDA a:$0036                                         ; $B9E5: AD 36 00
  JSR Proc_D105                                       ; $B9E8: 20 05 D1
  CMP $6F03                                           ; $B9EB: CD 03 6F  ; owned by current player?
  BEQ @Phase2Next                                           ; $B9EE: F0 03  ; yes -> skip (don't absorb own)
  JSR ScanBestTarget                                  ; $B9F0: 20 48 BB  ; evaluate as potential target
@Phase2Next:
  INC a:$0036                                         ; $B9F3: EE 36 00
  LDA a:$0036                                         ; $B9F6: AD 36 00
  CMP #$1E                                            ; $B9F9: C9 1E
  BCC @Phase2Loop                                           ; $B9FB: 90 E8
  LDA a:$003E                                         ; $B9FD: AD 3E 00  ; best army value
  CMP #$46                                            ; $BA00: C9 46  ; >= 70? (very strong target)
  .byte $90,$03                                       ; $BA02: 90 03 (BCC mid-instruction target)
  JMP ExecDomesticAction                              ; $BA04: 4C 7E BA  ; guaranteed success path
  ; --- Phase 3: Compute action score from army values ---
  LDA a:$003D                                         ; $BA07: AD 3D 00  ; best target char ID
  LDY #$04                                            ; $BA0A: A0 04  ; offset 4 = army stat field
  JSR $D2AB                                           ; $BA0C: 20 AB D2  ; read stat -> A
  STA $21                                             ; $BA0F: 85 21  ; $21 = target army stat
  LDY #$0B                                            ; $BA11: A0 0B  ; offset $0B = formation byte
  LDA ($22),Y                                         ; $BA13: B1 22
  LSR A                                               ; $BA15: 4A  ; extract high nibble >> 4
  LSR A                                               ; $BA16: 4A
  LSR A                                               ; $BA17: 4A
  LSR A                                               ; $BA18: 4A
  STA $20                                             ; $BA19: 85 20  ; $20 = formation value
  LDA a:$0039                                         ; $BA1B: AD 39 00  ; field selector from Phase 1
  SEC                                                 ; $BA1E: 38
  SBC $20                                             ; $BA1F: E5 20  ; adjust by formation
  STA a:$0039                                         ; $BA21: 8D 39 00
  LDY #$02                                            ; $BA24: A0 02
  LDA ($22),Y                                         ; $BA26: B1 22
  CLC                                                 ; $BA28: 18
  ADC $21                                             ; $BA29: 65 21
  LDA #$14                                            ; $BA2B: A9 14
  STA $23                                             ; $BA2D: 85 23
  LDA #$00                                            ; $BA2F: A9 00
  STA $22                                             ; $BA31: 85 22
  STA $24                                             ; $BA33: 85 24
  JSR Proc_D40F                                       ; $BA35: 20 0F D4
  ; --- Compute score based on kingdom tier ---
  LDA a:$003E                                         ; $BA38: AD 3E 00  ; best target army value
  LDY #$00                                            ; $BA3B: A0 00  ; Y = tier index (0)
  CMP #$1F                                            ; $BA3D: C9 1F  ; < 31?
  BCC @ApplyModifier                                           ; $BA3F: 90 06  ; yes -> use tier 0
  INY                                                 ; $BA41: C8  ; Y = 1
  CMP #$33                                            ; $BA42: C9 33  ; < 51?
  BCC @ApplyModifier                                           ; $BA44: 90 01  ; yes -> use tier 1
  INY                                                 ; $BA46: C8  ; Y = 2 (army >= 51)
@ApplyModifier:
  STY $20                                             ; $BA47: 84 20  ; $20 = kingdom tier (0-2)
  LDA $6F02                                           ; $BA49: AD 02 6F  ; sram_kingdom_index
  ASL A                                               ; $BA4C: 0A  ; *4 (4 entries per kingdom)
  ASL A                                               ; $BA4D: 0A
  ORA $20                                             ; $BA4E: 05 20  ; + tier offset
  TAY                                                 ; $BA50: A8
  LDA KingdomTierModifiers,Y                          ; $BA51: B9 81 BA  ; lookup modifier from table
  CLC                                                 ; $BA54: 18
  ADC $21                                             ; $BA55: 65 21  ; score = modifier + army stat
  STA $2A                                             ; $BA57: 85 2A  ; $2A = final score
  LDA a:$0039                                         ; $BA59: AD 39 00  ; distance/adjustment value
  BPL @AddDistance                                           ; $BA5C: 10 12  ; positive -> add to score
  ; Negative distance: penalty = abs(value) * 2, subtracted from score
  EOR #$FF                                            ; $BA5E: 49 FF  ; two's complement
  CLC                                                 ; $BA60: 18
  ADC #$01                                            ; $BA61: 69 01
  ASL A                                               ; $BA63: 0A  ; penalty = abs * 2
  STA $20                                             ; $BA64: 85 20
  LDA $2A                                             ; $BA66: A5 2A
  SEC                                                 ; $BA68: 38
  SBC $20                                             ; $BA69: E5 20  ; score -= penalty
  STA $2A                                             ; $BA6B: 85 2A
  JMP CheckActionThreshold                            ; $BA6D: 4C 75 BA
@AddDistance:
  CLC                                                 ; $BA70: 18
  ADC $2A                                             ; $BA71: 65 2A  ; score += distance
  STA $2A                                             ; $BA73: 85 2A


;===============================================================================
; $BA75: CheckActionThreshold
; Random probability check against the computed action score.
; Generates random 0-99; if random < score ($2A), action succeeds (falls through
; to ExecDomesticAction). Otherwise exits.
; Input:  $2A = action score (0-255, higher = more likely to succeed)
;===============================================================================
CheckActionThreshold:
  LDA #$64                                            ; $BA75: A9 64  ; 100
  JSR Proc_D4BB                                       ; $BA77: 20 BB D4  ; random 0..99
  CMP $2A                                             ; $BA7A: C5 2A  ; random < score?
  BCC @FindEmptySlot                                  ; $BA7C: 90 0F (BCC -> @FindEmptySlot on success)

;===============================================================================
; $BA7E: ExecDomesticAction
; Executes the AI domestic action: transfers a character from another entity
; into the current player's army. Updates all references and triggers the
; game-start flag to signal the UI.
;-------------------------------------------------------------------------------
; KingdomTierModifiers: indexed by (kingdom_index * 4 + tier)
;   tier 0 = army < 31, tier 1 = 31-50, tier 2 = >= 51
;===============================================================================
ExecDomesticAction:
  JMP JumpToBEC7                                      ; $BA7E: 4C 3D A2  ; entry: skip past data table (unreachable path)
KingdomTierModifiers:
  .byte $28,$0F,$00,$00,$32,$14,$00,$00,$3C,$1E,$0A,$00   ; $BA81: modifier table (12 bytes)
@FindEmptySlot:                                                ; --- Find empty army slot in best entity ---
  LDA a:$0038                                         ; $BA8D: AD 38 00  ; best entity index
  JSR Proc_D105                                       ; $BA90: 20 05 D1  ; resolve entity record -> ($20)
  LDY #$10                                            ; $BA93: A0 10
@SlotScan:
  INY                                                 ; $BA95: C8  ; scan slots $11-$1A
  LDA ($20),Y                                         ; $BA96: B1 20
  CMP #$FF                                            ; $BA98: C9 FF  ; empty slot?
  BNE @SlotScan                                           ; $BA9A: D0 F9  ; no -> keep scanning
  LDA a:$003D                                         ; $BA9C: AD 3D 00  ; best target char ID
  STA ($20),Y                                         ; $BA9F: 91 20  ; write char ID into empty slot
  ; --- Update player's army reference ---
  LDA $6F03                                           ; $BAA1: AD 03 6F  ; current player ID
  JSR Proc_D319                                       ; $BAA4: 20 19 D3  ; resolve -> ($24)
  LDY #$00                                            ; $BAA7: A0 00
  LDA ($24),Y                                         ; $BAA9: B1 24  ; player's character ID
  STA $30                                             ; $BAAB: 85 30
  LDA a:$003D                                         ; $BAAD: AD 3D 00  ; new char ID
  STA $31                                             ; $BAB0: 85 31
  JSR ArmyValueCalc                                   ; $BAB2: 20 3F CF  ; recalculate army value
  ; --- Remove char from old owner's slot list ---
  LDA a:$003F                                         ; $BAB5: AD 3F 00  ; old owner entity index
  JSR Proc_D105                                       ; $BAB8: 20 05 D1  ; resolve -> ($20)
  STA a:$0042                                         ; $BABB: 8D 42 00  ; save for later
  LDY #$10                                            ; $BABE: A0 10
@CharRemoveLoop:
  INY                                                 ; $BAC0: C8  ; scan slots $11-$1A
  LDA ($20),Y                                         ; $BAC1: B1 20
  CMP a:$003D                                         ; $BAC3: CD 3D 00  ; found the transferred char?
  BNE @CharRemoveLoop                                           ; $BAC6: D0 F8  ; no -> keep scanning
  LDA #$FF                                            ; $BAC8: A9 FF
  STA ($20),Y                                         ; $BACA: 91 20  ; clear slot (mark empty)
  ; --- If old owner's status is 0 (dismissed), mark slot type 7 ---
  LDA a:$003F                                         ; $BACC: AD 3F 00
  JSR Proc_D3DD                                       ; $BACF: 20 DD D3  ; reset player-entity map
  LDA a:$003F                                         ; $BAD2: AD 3F 00
  JSR Proc_D304                                       ; $BAD5: 20 04 D3  ; count remaining slots
  CMP #$00                                            ; $BAD8: C9 00  ; any slots left?
  BNE @AfterDismiss                                           ; $BADA: D0 06  ; yes -> skip
  LDY #$00                                            ; $BADC: A0 00
  LDA #$07                                            ; $BADE: A9 07  ; slot type 7 = dismissed
  STA ($20),Y                                         ; $BAE0: 91 20  ; write type to old owner's record
@AfterDismiss:
  ; --- Swap army ownership between entities ---
  LDA a:$003D                                         ; $BAE2: AD 3D 00  ; transferred char ID
  STA a:$0043                                         ; $BAE5: 8D 43 00
  LDA a:$0038                                         ; $BAE8: AD 38 00  ; receiving entity index
  JSR Proc_D105                                       ; $BAEB: 20 05 D1  ; resolve -> ($20)
  JSR Proc_D319                                       ; $BAEE: 20 19 D3  ; resolve char record -> ($24)
  LDY #$00                                            ; $BAF1: A0 00
  LDA ($24),Y                                         ; $BAF3: B1 24  ; receiving char ID
  STA a:$0040                                         ; $BAF5: 8D 40 00
  LDA a:$0042                                         ; $BAF8: AD 42 00  ; old owner entity index
  JSR Proc_D319                                       ; $BAFB: 20 19 D3  ; resolve -> ($24)
  LDY #$00                                            ; $BAFE: A0 00
  LDA ($24),Y                                         ; $BB00: B1 24  ; old owner char ID
  STA a:$0041                                         ; $BB02: 8D 41 00
  ; --- Check if new character is AI-controlled ---
  LDY #$03                                            ; $BB05: A0 03  ; offset 3 = control/status
  LDA ($24),Y                                         ; $BB07: B1 24
  CMP #$03                                            ; $BB09: C9 03  ; status 3 = AI-controlled?
  BEQ @Exit                                           ; $BB0B: F0 38  ; yes -> skip post-action update
  ; --- Post-action: update all entities for new ownership ---
  LDA #$00                                            ; $BB0D: A9 00
  STA a:$0036                                         ; $BB0F: 8D 36 00  ; entity index
  LDA #$FF                                            ; $BB12: A9 FF
  STA a:$003D                                         ; $BB14: 8D 3D 00
  LDA #$00                                            ; $BB17: A9 00
  STA a:$003E                                         ; $BB19: 8D 3E 00
@PostUpdateLoop:                                                ; --- Post-action loop: entities 0..29 ---
  LDA a:$0036                                         ; $BB1C: AD 36 00
  JSR Proc_D105                                       ; $BB1F: 20 05 D1
  CMP #$07                                            ; $BB22: C9 07  ; dismissed entity?
  BEQ @PostUpdateNext                                           ; $BB24: F0 0B  ; yes -> skip
  CMP a:$0042                                         ; $BB26: CD 42 00  ; same as old owner?
  BNE @PostUpdateNext                                           ; $BB29: D0 06  ; no -> skip
  LDA a:$0041                                         ; $BB2B: AD 41 00  ; old owner char ID
  JSR FindBestOfficerInEntity                          ; $BB2E: 20 40 BD  ; find best replacement officer in entity
@PostUpdateNext:
  INC a:$0036                                         ; $BB31: EE 36 00
  LDA a:$0036                                         ; $BB34: AD 36 00
  CMP #$1E                                            ; $BB37: C9 1E
  BCC @PostUpdateLoop                                           ; $BB39: 90 E1  ; loop over all entities
  ; --- Signal game-start flag and wait for completion ---
  LDA #$FA                                            ; $BB3B: A9 FA
  STA $6F8B                                           ; $BB3D: 8D 8B 6F  ; game_start_flag = $FA
@WaitLoop:
  LDA $6F8B                                           ; $BB40: AD 8B 6F
  BNE @WaitLoop                                           ; $BB43: D0 FB  ; busy-wait until flag cleared
@Exit:
  JMP JumpToBEC7                                      ; $BB45: 4C 3D A2  ; done -> exit
;-------------------------------------------------------------------------------
; $BB48: ScanBestTarget
; Evaluates an entity as a potential absorption target. Scans army slots
; $11-$1A, reads each character's stat (offset 3), and tracks the one with
; the lowest value. Updates $003D (best char), $003E (best value), $003F (best entity).
; Input:  $0036 = entity index
;-------------------------------------------------------------------------------
ScanBestTarget:
  LDA a:$0036                                         ; $BB48: AD 36 00
  JSR Proc_D105                                       ; $BB4B: 20 05 D1
  LDA #$11                                            ; $BB4E: A9 11
  STA a:$003C                                         ; $BB50: 8D 3C 00
@ScanLoop:
  LDY a:$003C                                         ; $BB53: AC 3C 00
  LDA ($20),Y                                         ; $BB56: B1 20
  CMP #$FF                                            ; $BB58: C9 FF
  BEQ @ScanNext                                           ; $BB5A: F0 1B
  LDY #$03                                            ; $BB5C: A0 03
  JSR $D2AB                                           ; $BB5E: 20 AB D2
  CMP a:$003E                                         ; $BB61: CD 3E 00
  BCS @ScanNext                                           ; $BB64: B0 11
  STA a:$003E                                         ; $BB66: 8D 3E 00
  LDY a:$003C                                         ; $BB69: AC 3C 00
  LDA ($20),Y                                         ; $BB6C: B1 20
  STA a:$003D                                         ; $BB6E: 8D 3D 00
  LDA a:$0036                                         ; $BB71: AD 36 00
  STA a:$003F                                         ; $BB74: 8D 3F 00
@ScanNext:
  INC a:$003C                                         ; $BB77: EE 3C 00
  LDA a:$003C                                         ; $BB7A: AD 3C 00
  CMP #$1B                                            ; $BB7D: C9 1B
  BCC @ScanLoop                                           ; $BB7F: 90 D2
  RTS                                                 ; $BB81: 60


;===============================================================================
; $BB82: UpdateMinArmyCount
; Scans entity's army slots $11-$1A, reads each character's stat (offset $0B >> 4),
; and updates $0039 if a lower value is found.
; Input:  $0036 = entity index (already resolved via Proc_D105)
;===============================================================================
UpdateMinArmyCount:
  LDA a:$0036                                         ; $BB82: AD 36 00
  JSR Proc_D105                                       ; $BB85: 20 05 D1
  LDA #$11                                            ; $BB88: A9 11
  STA a:$003C                                         ; $BB8A: 8D 3C 00
@Loop:
  LDY a:$003C                                         ; $BB8D: AC 3C 00
  LDA ($20),Y                                         ; $BB90: B1 20
  CMP #$FF                                            ; $BB92: C9 FF
  .byte $F0,$11                                       ; $BB94: F0 11 (BEQ mid-instruction target)
  LDY #$0B                                            ; $BB96: A0 0B
  JSR $D2AB                                           ; $BB98: 20 AB D2
  LSR A                                               ; $BB9B: 4A
  LSR A                                               ; $BB9C: 4A
  LSR A                                               ; $BB9D: 4A
  LSR A                                               ; $BB9E: 4A
  CMP a:$0039                                         ; $BB9F: CD 39 00
  .byte $90,$03                                       ; $BBA2: 90 03 (BCC mid-instruction target)
  STA a:$0039                                         ; $BBA4: 8D 39 00
  INC a:$003C                                         ; $BBA7: EE 3C 00
  LDA a:$003C                                         ; $BBAA: AD 3C 00
  CMP #$1B                                            ; $BBAD: C9 1B
  BCC @Loop                                           ; $BBAF: 90 DC
  RTS                                                 ; $BBB1: 60


;-------------------------------------------------------------------------------
; $BBB2: AiAbsorbEntityAction
; AI action: attempt to absorb a rival entity by recruiting away their officers.
; Phase 1: Iterate entities to validate AI's own holdings
; Phase 2: Find non-AI entity with most officers (best absorption target)
; Phase 3: Abort if target has fewer than 6 officers
; Phase 4: Build list of recruitable officers (loyalty $32-$59)
; Phase 5: Pick random candidate, probability check vs stat + kingdom tier
; Phase 6: Transfer officer, reduce stat, sweep affected entities
;-------------------------------------------------------------------------------
AiAbsorbEntityAction:
  LDA #$00                                            ; $BBB2: A9 00  ; entity index = 0
  STA a:$0036                                         ; $BBB4: 8D 36 00
  LDA #$FF                                            ; $BBB7: A9 FF
  STA a:$003D                                         ; $BBB9: 8D 3D 00  ; best char tracker = none
  LDA #$00                                            ; $BBBC: A9 00
  STA a:$003E                                         ; $BBBE: 8D 3E 00  ; best stat value = 0
; --- Phase 1: validate AI's own entities ---
@Phase1Loop:
  LDA a:$0036                                         ; $BBC1: AD 36 00
  JSR Proc_D105                                       ; $BBC4: 20 05 D1  ; resolve entity → record ptr
  CMP $6F03                                           ; $BBC7: CD 03 6F  ; owned by current player?
  BNE @Phase1Next                                      ; $BBCA: D0 03
  JSR FindBestOfficerNoExclude                         ; $BBCC: 20 3E BD  ; init trackers (no exclusion)
@Phase1Next:
  INC a:$0036                                         ; $BBCF: EE 36 00
  LDA a:$0036                                         ; $BBD2: AD 36 00
  CMP #$1E                                            ; $BBD5: C9 1E
  BCC @Phase1Loop                                      ; $BBD7: 90 E8
; --- Phase 2: find non-AI entity with most officers ---
  LDA #$00                                            ; $BBD9: A9 00
  STA a:$0036                                         ; $BBDB: 8D 36 00  ; entity index = 0
  STA a:$0037                                         ; $BBDE: 8D 37 00  ; best army count = 0
  LDA #$FF                                            ; $BBE1: A9 FF
  STA a:$0038                                         ; $BBE3: 8D 38 00  ; best entity ID = none
@FindTargetLoop:
  LDA a:$0036                                         ; $BBE6: AD 36 00
  JSR Proc_D105                                       ; $BBE9: 20 05 D1  ; resolve entity → owner
  CMP $6F03                                           ; $BBEC: CD 03 6F  ; owned by player?
  BEQ @FindTargetNext                                 ; $BBEF: F0 1F  ; yes → skip (can't absorb own)
  JSR Proc_D319                                       ; $BBF1: 20 19 D3  ; resolve owner's character record
  LDY #$03                                            ; $BBF4: A0 03
  LDA ($24),Y                                         ; $BBF6: B1 24
  CMP #$03                                            ; $BBF8: C9 03  ; status $03 = dismissed/inactive?
  BEQ @FindTargetNext                                 ; $BBFA: F0 14  ; yes → skip
  LDA a:$0036                                         ; $BBFC: AD 36 00
  JSR Proc_D304                                       ; $BBFF: 20 04 D3  ; count filled army slots
  CMP a:$0037                                         ; $BC02: CD 37 00  ; higher count than current best?
  BCC @FindTargetNext                                 ; $BC05: 90 09  ; no → skip
  STA a:$0037                                         ; $BC07: 8D 37 00  ; new best army count
  LDA a:$0036                                         ; $BC0A: AD 36 00
  STA a:$0038                                         ; $BC0D: 8D 38 00  ; new best entity ID
@FindTargetNext:
  INC a:$0036                                         ; $BC10: EE 36 00
  LDA a:$0036                                         ; $BC13: AD 36 00
  CMP #$1E                                            ; $BC16: C9 1E
  BCC @FindTargetLoop                                 ; $BC18: 90 CC
; --- Phase 3: abort if target has < 6 officers ---
  LDA a:$0037                                         ; $BC1A: AD 37 00  ; best army count
  CMP #$06                                            ; $BC1D: C9 06  ; need >= 6 to attempt absorption
  BCS @Phase4Start                                     ; $BC1F: B0 03
  JMP JumpToBEC7                                      ; $BC21: 4C 3D A2  ; abort → exit
; --- Phase 4: build list of recruitable officers ---
@Phase4Start:
  LDY #$0F                                            ; $BC24: A0 0F
  LDA #$FF                                            ; $BC26: A9 FF
@ClearCandidateBuf:                                    ; clear candidate buffer $6F73[0..$0F]
  STA $6F73,Y                                         ; $BC28: 99 73 6F
  DEY                                                 ; $BC2B: 88
  BPL @ClearCandidateBuf                               ; $BC2C: 10 FA
  LDA a:$0038                                         ; $BC2E: AD 38 00  ; best entity ID
  JSR Proc_D105                                       ; $BC31: 20 05 D1  ; resolve entity → record ptr
  LDA #$11                                            ; $BC34: A9 11
  STA a:$0036                                         ; $BC36: 8D 36 00  ; slot index = $11
  LDA #$00                                            ; $BC39: A9 00
  STA a:$0037                                         ; $BC3B: 8D 37 00  ; candidate count = 0
@FilterOfficerLoop:                                    ; scan army slots $11-$1A for recruitable officers
  LDY a:$0036                                         ; $BC3E: AC 36 00
  LDA ($20),Y                                         ; $BC41: B1 20  ; character ID in slot
  CMP #$FF                                            ; $BC43: C9 FF  ; empty slot?
  BEQ @FilterOfficerNext                               ; $BC45: F0 1B  ; yes → next
  LDY #$03                                            ; $BC47: A0 03
  JSR $D2AB                                           ; $BC49: 20 AB D2  ; read stat at offset 3 (loyalty)
  CMP #$32                                            ; $BC4C: C9 32  ; loyalty < $32 → too disloyal
  BCC @FilterOfficerNext                               ; $BC4E: 90 12
  CMP #$5A                                            ; $BC50: C9 5A  ; loyalty >= $5A → too loyal
  BCS @FilterOfficerNext                               ; $BC52: B0 0E
  LDY a:$0036                                         ; $BC54: AC 36 00
  LDA ($20),Y                                         ; $BC57: B1 20  ; re-read character ID
  LDY a:$0037                                         ; $BC59: AC 37 00  ; candidate index
@StoreCandidate:
  STA $6F73,Y                                         ; $BC5C: 99 73 6F  ; store in candidate buffer
  INC a:$0037                                         ; $BC5F: EE 37 00  ; increment candidate count
@FilterOfficerNext:
  INC a:$0036                                         ; $BC62: EE 36 00
  LDA a:$0036                                         ; $BC65: AD 36 00
  CMP #$1B                                            ; $BC68: C9 1B
  BCC @FilterOfficerLoop                               ; $BC6A: 90 D2
; --- Phase 5: select random candidate and compute success probability ---
  LDA a:$0037                                         ; $BC6C: AD 37 00  ; candidate count
  BEQ JumpToBEC7                                       ; $BC6F: F0 37  ; no candidates → abort
  CMP #$01                                            ; $BC71: C9 01  ; exactly 1 candidate?
  BEQ @UseSingleCandidate                              ; $BC73: F0 06  ; exactly 1 → skip random
  JSR Proc_D4AD                                       ; $BC75: 20 AD D4  ; random index < count
  CLC                                                 ; $BC78: 18
  ADC #$01                                            ; $BC79: 69 01
@UseSingleCandidate:
  TAY                                                 ; $BC7B: A8
  LDA $6F72,Y                                         ; $BC7C: B9 72 6F  ; selected candidate char ID
  STA a:$0037                                         ; $BC7F: 8D 37 00  ; store as chosen officer
  LDA a:$0037                                         ; $BC82: AD 37 00
  LDY #$02                                            ; $BC85: A0 02
  JSR $D2AB                                           ; $BC87: 20 AB D2  ; read stat at offset 2
  STA $00                                             ; $BC8A: 85 00
  LDA a:$003E                                         ; $BC8C: AD 3E 00  ; best value from Phase 2
  SEC                                                 ; $BC8F: 38
  SBC $00                                             ; $BC90: E5 00  ; stat delta
  BCS @ComputeThreshold                                ; $BC92: B0 02
  LDA #$00                                            ; $BC94: A9 00  ; clamp to 0
@ComputeThreshold:
  LDY $6F02                                           ; $BC96: AC 02 6F  ; kingdom index
  CLC                                                 ; $BC99: 18
  ADC $BCAB,Y                                         ; $BC9A: 79 AB BC  ; + tier modifier
  STA $2A                                             ; $BC9D: 85 2A  ; success threshold
  LDA #$64                                            ; $BC9F: A9 64  ; max random = 100
  JSR Proc_D4BB                                       ; $BCA1: 20 BB D4  ; random 0-99
  CMP $2A                                             ; $BCA4: C5 2A  ; random >= threshold?
  .byte $90,$06                                       ; $BCA6: 90 06 (BCC mid-instruction target)
  JMP JumpToBEC7                                      ; $BCA8: 4C 3D A2  ; probability check failed → abort
; --- Phase 6: transfer officer, update stats, sweep affected entities ---
  .byte $10,$20                                       ; $BCAB: 10 20 (BPL mid-instruction target)
  BMI @StoreCandidate                                  ; $BCAD: 30 AD
  ROL $8500,X                                         ; $BCAF: 3E 00 85
  AND ($A9,X)                                         ; $BCB2: 21 A9
  .byte $14                                           ; $BCB4: 14
  STA $23                                             ; $BCB5: 85 23
  LDA #$00                                            ; $BCB7: A9 00
  STA $22                                             ; $BCB9: 85 22
  STA $24                                             ; $BCBB: 85 24
  JSR Proc_D40F                                       ; $BCBD: 20 0F D4  ; 16-bit division helper
  LDA #$07                                            ; $BCC0: A9 07
  JSR Proc_D4AD                                       ; $BCC2: 20 AD D4  ; random 0-7 for stat reduction
  CLC                                                 ; $BCC5: 18
  ADC #$01                                            ; $BCC6: 69 01
  CLC                                                 ; $BCC8: 18
  ADC $21                                             ; $BCC9: 65 21
  STA a:$0039                                         ; $BCCB: 8D 39 00  ; total reduction amount
  LDA a:$0037                                         ; $BCCE: AD 37 00  ; chosen officer char ID
  LDY #$03                                            ; $BCD1: A0 03
  JSR $D2AB                                           ; $BCD3: 20 AB D2  ; read officer stat[3]
  SEC                                                 ; $BCD6: 38
  SBC a:$0039                                         ; $BCD7: ED 39 00  ; stat - reduction
  BCS @ClampStatResult                                 ; $BCDA: B0 02
  LDA #$00                                            ; $BCDC: A9 00  ; clamp to 0 minimum
@ClampStatResult:
  STA ($22),Y                                         ; $BCDE: 91 22  ; write reduced stat back
  LDA $6F03                                           ; $BCE0: AD 03 6F  ; current player ID
  JSR Proc_D319                                       ; $BCE3: 20 19 D3  ; resolve player's character record
  LDY #$00                                            ; $BCE6: A0 00
  LDA ($24),Y                                         ; $BCE8: B1 24
  STA a:$0039                                         ; $BCEA: 8D 39 00  ; player's character ID
  LDA a:$0038                                         ; $BCED: AD 38 00  ; absorbed entity ID
  JSR Proc_D105                                       ; $BCF0: 20 05 D1  ; resolve entity → owner
  STA a:$003B                                         ; $BCF3: 8D 3B 00  ; absorbed entity owner
  JSR Proc_D319                                       ; $BCF6: 20 19 D3
  LDY #$00                                            ; $BCF9: A0 00
  LDA ($24),Y                                         ; $BCFB: B1 24
  STA a:$003A                                         ; $BCFD: 8D 3A 00  ; target entity's primary char ID
  LDY #$03                                            ; $BD00: A0 03
  LDA ($24),Y                                         ; $BD02: B1 24
  STA $6F44                                           ; $BD04: 8D 44 6F  ; absorbed officer display flag
; --- Final sweep: find best replacement in affected entities ---
  LDA #$00                                            ; $BD07: A9 00
  STA a:$0036                                         ; $BD09: 8D 36 00  ; entity index = 0
  LDA #$FF                                            ; $BD0C: A9 FF
  STA a:$003D                                         ; $BD0E: 8D 3D 00  ; best char tracker = none
  LDA #$00                                            ; $BD11: A9 00
  STA a:$003E                                         ; $BD13: 8D 3E 00  ; best stat value = 0
@SweepLoop:
  LDA a:$0036                                         ; $BD16: AD 36 00
  JSR Proc_D105                                       ; $BD19: 20 05 D1  ; resolve entity → owner
  CMP a:$003B                                         ; $BD1C: CD 3B 00  ; same owner as absorbed entity?
  BNE @SweepNext                                       ; $BD1F: D0 06
  LDA a:$003A                                         ; $BD21: AD 3A 00  ; target entity's primary char
  JSR FindBestOfficerInEntity                          ; $BD24: 20 40 BD  ; find best replacement officer
@SweepNext:
  INC a:$0036                                         ; $BD27: EE 36 00
  LDA a:$0036                                         ; $BD2A: AD 36 00
  CMP #$1E                                            ; $BD2D: C9 1E
  BCC @SweepLoop                                       ; $BD2F: 90 E5
  LDA #$F9                                            ; $BD31: A9 F9
  STA $6F8B                                           ; $BD33: 8D 8B 6F  ; signal game action $F9
@WaitForFlag:
  LDA $6F8B                                           ; $BD36: AD 8B 6F
  BNE @WaitForFlag                                     ; $BD39: D0 FB  ; busy-wait until flag cleared
  JMP JumpToBEC7                                      ; $BD3B: 4C 3D A2  ; done → exit
;-------------------------------------------------------------------------------
; $BD3E: FindBestOfficerNoExclude
; Alternate entry: exclude no character ($FF = none).
; Falls through to FindBestOfficerInEntity at $BD40.
;-------------------------------------------------------------------------------
FindBestOfficerNoExclude:
  LDA #$FF                                            ; $BD3E: A9 FF  ; sentinel = no exclusion


;-------------------------------------------------------------------------------
; $BD40: FindBestOfficerInEntity
; Scans entity $0036's army slots ($11-$1A) for the officer with the
; highest stat at record offset 2, excluding character in A.
; Input:  A = character ID to exclude ($FF = none), $0036 = entity index
; Output: $003D = best character ID, $003E = best stat value
;-------------------------------------------------------------------------------
FindBestOfficerInEntity:
  STA $2A                                             ; $BD40: 85 2A  ; save excluded character ID
  LDA a:$0036                                         ; $BD42: AD 36 00
  JSR Proc_D105                                       ; $BD45: 20 05 D1  ; resolve entity → record ptr ($20/$21)
  LDA #$11                                            ; $BD48: A9 11
  STA a:$003C                                         ; $BD4A: 8D 3C 00  ; start at army slot offset $11
@ScanOfficerLoop:
  LDY a:$003C                                         ; $BD4D: AC 3C 00
  LDA ($20),Y                                         ; $BD50: B1 20  ; character ID in slot
  CMP #$FF                                            ; $BD52: C9 FF  ; empty slot → done
  BEQ @ScanNext                                        ; $BD54: F0 19
  CMP $2A                                             ; $BD56: C5 2A  ; same as excluded character?
  BEQ @ScanNext                                        ; $BD58: F0 15
  LDY #$02                                            ; $BD5A: A0 02
  JSR $D2AB                                           ; $BD5C: 20 AB D2  ; read stat at offset 2
  CMP a:$003E                                         ; $BD5F: CD 3E 00  ; higher than current best?
  BCC @ScanNext                                        ; $BD62: 90 0B
  STA a:$003E                                         ; $BD64: 8D 3E 00  ; update best stat value
  LDY a:$003C                                         ; $BD67: AC 3C 00
  LDA ($20),Y                                         ; $BD6A: B1 20  ; re-read character ID
  STA a:$003D                                         ; $BD6C: 8D 3D 00  ; update best character ID
@ScanNext:
  INC a:$003C                                         ; $BD6F: EE 3C 00
  LDA a:$003C                                         ; $BD72: AD 3C 00
  CMP #$1B                                            ; $BD75: C9 1B
  BCC @ScanOfficerLoop                                 ; $BD77: 90 D4
  RTS                                                 ; $BD79: 60


;===============================================================================
; AiDev_Main — AI officer development search (nested in AiTurnDispatch)
; Scans owned provinces for trainable officers, selects the best candidate
; by province score, trains the officer (sets ability to $03E8/1000),
; deducts province resources, and loops until no candidates remain.
; Called from AiTurnDispatch after enemy province scan completes.
;
; Variables:
;   $0036 = candidate_idx  — entity scan index (0..$1D)
;   $0037 = best_score     — best province score (low byte at offset 1)
;   $0038 = best_slot_val  — best army-slot officer ID ($FF = none found)
;   $0039 = best_entity    — best province entity index ($FF = none found)
;   $24   = slot_offset    — army slot offset ($11..$1A)
;===============================================================================
AiDev_Main:

  ; --- Initialize scan state ---
  LDA #$00                                            ; $BD7A: A9 00
  STA a:$0036                                         ; $BD7C: 8D 36 00  ; candidate_idx = 0
  STA a:$0037                                         ; $BD7F: 8D 37 00  ; best_score = 0
  LDA #$FF                                            ; $BD82: A9 FF
  STA a:$0038                                         ; $BD84: 8D 38 00  ; best_slot_val = $FF (no target)
  STA a:$0039                                         ; $BD87: 8D 39 00  ; best_entity = $FF

AiDev_OuterLoop:                                                             ; scan entities 0..$1D
  LDA a:$0036                                         ; $BD8A: AD 36 00  ; candidate_idx
  JSR Proc_D105                                       ; $BD8D: 20 05 D1  ; resolve entity → record ptr ($20/$21)
  CMP sram_player_id                                  ; $BD90: CD 03 6F  ; owned by current player?
  BNE AiDev_OuterLoopNext                                   ; $BD93: D0 59      ; not ours → next entity

  ; --- Check province score ≥ $012C (300) ---
  LDY #$01                                            ; $BD95: A0 01
  LDA ($20),Y                                         ; $BD97: B1 20      ; score low byte
  SEC                                                 ; $BD99: 38
  SBC #$2C                                            ; $BD9A: E9 2C
  INY                                                 ; $BD9C: C8
  LDA ($20),Y                                         ; $BD9D: B1 20      ; score high byte
  SBC #$01                                            ; $BD9F: E9 01
  BCC AiDev_OuterLoopNext                                   ; $BDA1: 90 4B      ; score < 300 → skip

  ; --- Inner loop: scan army slots $11..$1A ---
  LDY #$11                                            ; $BDA3: A0 11      ; first army-slot offset
  STY $24                                             ; $BDA5: 84 24
AiDev_SlotLoop:                                                              ; iterate slot_offset $11..$1A
  LDY $24                                             ; $BDA7: A4 24
  LDA ($20),Y                                         ; $BDA9: B1 20      ; officer ID in slot
  CMP #$FF                                            ; $BDAB: C9 FF      ; empty slot?
  BEQ AiDev_SlotAdvance                                     ; $BDAD: F0 37      ; empty → qualify w/ score 100

  ; --- Officer eligibility: bits 0-1 of stat@9 must both be set ---
  LDY #$09                                            ; $BDAF: A0 09
  JSR $D2AB                                           ; $BDB1: 20 AB D2  ; read officer stat at offset 9
  AND #$03                                            ; $BDB4: 29 03      ; mask trainable flags
  CMP #$03                                            ; $BDB6: C9 03      ; both bits set = eligible
  BNE AiDev_NextSlot                                       ; $BDB8: D0 08      ; not eligible → next slot

  ; --- Officer ability cap check: stat@8 must not equal $E8 (cap = $03E8) ---
  LDY #$08                                            ; $BDBA: A0 08
  LDA ($22),Y                                         ; $BDBC: B1 22      ; officer ability low byte
  CMP #$E8                                            ; $BDBE: C9 E8      ; at cap ($03E8 = 1000)?
  BEQ AiDev_SlotAdvance                                     ; $BDC0: F0 24      ; at cap → qualify anyway

AiDev_NextSlot:                                                                ; advance to next army slot
  LDY $24                                             ; $BDC2: A4 24
  CPY #$11                                            ; $BDC4: C0 11      ; first slot?
  BNE AiDev_DeadCode                                        ; $BDC6: D0 05      ; dead code path
  LDA #$64                                            ; $BDC8: A9 64      ; empty-slot default score = 100
  JMP CompareAndUpdate                                 ; $BDCA: 4C D1 BD  ; → nested scoring proc
AiDev_DeadCode:  ; Dead code: unreachable after unconditional JMP above
  LDY #$01                                            ; $BDCD: A0 01
  LDA ($22),Y                                         ; $BDCF: B1 22

;===============================================================================
; CompareAndUpdate — Compare score with best and update if better
; Entry: A = province score (low byte), $24 = slot_offset
; Updates: best_score ($0037), best_slot_val ($0038), best_entity ($0039)
; Then continues the inner/outer scan loop or exits to processing.
;===============================================================================
CompareAndUpdate:
  CMP a:$0037                                         ; $BDD1: CD 37 00  ; compare with best score
  BCC AiDev_SlotAdvance                                    ; $BDD4: 90 10      ; worse → next slot
  STA a:$0037                                         ; $BDD6: 8D 37 00  ; new best score
  LDY $24                                             ; $BDD9: A4 24
  LDA ($20),Y                                         ; $BDDB: B1 20      ; officer ID at slot offset
  STA a:$0038                                         ; $BDDD: 8D 38 00  ; best_slot_val
  LDA a:$0036                                         ; $BDE0: AD 36 00  ; candidate_idx
  STA a:$0039                                         ; $BDE3: 8D 39 00  ; best_entity

AiDev_SlotAdvance:                                                             ; advance inner loop (next army slot)
  INC $24                                               ; $BDE6: E6 24      ; next slot offset
  LDA $24                                               ; $BDE8: A5 24
  CMP #$1B                                              ; $BDEA: C9 1B      ; end of slots?
  BCC AiDev_SlotLoop                                        ; $BDEC: 90 B9      ; continue inner loop

AiDev_OuterLoopNext:                                                           ; advance outer loop (next entity)
  INC a:$0036                                           ; $BDEE: EE 36 00  ; candidate_idx++
  LDA a:$0036                                           ; $BDF1: AD 36 00  ; candidate_idx
  CMP #$1E                                              ; $BDF4: C9 1E      ; scanned all entities?
  BCC AiDev_OuterLoop                                       ; $BDF6: 90 92      ; continue outer loop

  ; --- Post-scan: check if any target was found ---
  LDA a:$0038                                           ; $BDF8: AD 38 00  ; best_slot_val
  CMP #$FF                                              ; $BDFB: C9 FF      ; still $FF = no target
  BNE AiDev_ProcessBest                                      ; $BDFD: D0 03      ; found → process
AiDev_ExitSearch:                                                              ; no target found
  JMP AiDev_Terminate                                        ; $BDFF: 4C C7 BE  ; → termination phase

AiDev_ProcessBest:                                                             ; === Train the best officer ===
  LDA a:$0039                                           ; $BE02: AD 39 00  ; best entity index
  JSR Proc_D105                                         ; $BE05: 20 05 D1  ; resolve → record ptr ($20)
  LDA a:$0038                                           ; $BE08: AD 38 00  ; best officer ID
  LDY #$08                                              ; $BE0B: A0 08
  JSR $D2AB                                             ; $BE0D: 20 AB D2  ; read officer ability stat → ($22)
  STA $2A                                               ; $BE10: 85 2A      ; ability low byte
  INY                                                   ; $BE12: C8
  LDA ($22),Y                                           ; $BE13: B1 22      ; ability high byte
  AND #$03                                              ; $BE15: 29 03      ; mask (max $03)
  STA $2B                                               ; $BE17: 85 2B

  ; --- Compute remaining training capacity = $03E8 - ability ---
  LDA #$E8                                              ; $BE19: A9 E8
  SEC                                                   ; $BE1B: 38
  SBC $2A                                               ; $BE1C: E5 2A      ; ($03E8 - ability) low
  STA a:$003A                                           ; $BE1E: 8D 3A 00
  STA $2C                                               ; $BE21: 85 2C
  LDA #$03                                              ; $BE23: A9 03
  SBC $2B                                               ; $BE25: E5 2B      ; ($03E8 - ability) high
  STA a:$003B                                           ; $BE27: 8D 3B 00
  STA $2D                                               ; $BE2A: 85 2D

  ; --- Subtract prior investment: net = capacity - field[$0C/$0D] ---
  LDY #$0C                                              ; $BE2C: A0 0C
  LDA a:$003A                                           ; $BE2E: AD 3A 00
  SEC                                                   ; $BE31: 38
  SBC ($20),Y                                           ; $BE32: F1 20      ; net remaining low
  STA a:$003C                                           ; $BE34: 8D 3C 00
  INY                                                   ; $BE37: C8
  LDA a:$003B                                           ; $BE38: AD 3B 00
  SBC ($20),Y                                           ; $BE3B: F1 20      ; net remaining high
  STA a:$003D                                           ; $BE3D: 8D 3D 00
  BCC AiDev_AlreadyTrained                                  ; $BE40: 90 52      ; already trained → flush

  ; --- Ceiling division by 100: cost = ceil(remainder/100)×100 ---
  ; Determines training cost in batches of 100 resources.
  LDY #$00                                              ; $BE42: A0 00
  STY $28                                               ; $BE44: 84 28      ; cost accumulator = 0
  STY $29                                               ; $BE46: 84 29
AiDev_DivReset:                                                                ; A = 0 here, used as cost base
  TYA                                                   ; $BE48: 98        ; A = 0
  CLC                                                   ; $BE49: 18
  ADC #$14                                              ; $BE4A: 69 14      ; A = 20 (loop counter)
  TAY                                                   ; $BE4C: A8
AiDev_DivLoop:                                                                 ; subtract 100 from remainder, add 100 to cost
  LDA $28                                               ; $BE4D: A5 28
  CLC                                                   ; $BE4F: 18
  ADC #$64                                              ; $BE50: 69 64      ; cost += 100
  STA $28                                               ; $BE52: 85 28
  LDA $29                                               ; $BE54: A5 29
  ADC #$00                                              ; $BE56: 69 00
  STA $29                                               ; $BE58: 85 29
  LDA a:$003C                                           ; $BE5A: AD 3C 00
  SEC                                                   ; $BE5D: 38
  SBC #$64                                              ; $BE5E: E9 64      ; remainder -= 100
  STA a:$003C                                           ; $BE60: 8D 3C 00
  LDA a:$003D                                           ; $BE63: AD 3D 00
  SBC #$00                                              ; $BE66: E9 00
  STA a:$003D                                           ; $BE68: 8D 3D 00
  BCS AiDev_DivReset                                        ; $BE6B: B0 DB      ; remainder ≥ 0 → continue

  ; --- Store final 16-bit cost ---
  TYA                                                   ; $BE6D: 98
  STA $22                                               ; $BE6E: 85 22
  LDA #$00                                              ; $BE70: A9 00
  STA $23                                               ; $BE72: 85 23      ; $22/$23 = cost (16-bit)

  ; --- Consume province resources (deduct cost from field $02/$03) ---
  LDA #$00                                              ; $BE74: A9 00
  STA $24                                               ; $BE76: 85 24
  LDA a:$0039                                           ; $BE78: AD 39 00  ; best entity
  JSR Proc_D36F                                         ; $BE7B: 20 6F D3  ; deduct training cost

  ; --- Add cost to development investment (field $0C/$0D += cost) ---
  LDA a:$0039                                           ; $BE7E: AD 39 00  ; best entity
  JSR Proc_D105                                         ; $BE81: 20 05 D1  ; re-resolve province → ($20)
  LDY #$0C                                              ; $BE84: A0 0C
  LDA $28                                               ; $BE86: A5 28
  CLC                                                   ; $BE88: 18
  ADC ($20),Y                                           ; $BE89: 71 20      ; field[$0C] += cost_low
  STA ($20),Y                                           ; $BE8B: 91 20
  INY                                                   ; $BE8D: C8
  LDA $29                                               ; $BE8E: A5 29
  ADC ($20),Y                                           ; $BE90: 71 20      ; field[$0D] += cost_high
  STA ($20),Y                                           ; $BE92: 91 20
AiDev_AlreadyTrained:                                                            ; skip division → flush and continue
  JSR Proc_D69D                                         ; $BE94: 20 9D D6  ; flush pending updates

  ; --- Subtract remaining capacity from investment (net effect) ---
  LDY #$0C                                              ; $BE97: A0 0C
  LDA ($20),Y                                           ; $BE99: B1 20
  SEC                                                   ; $BE9B: 38
  SBC a:$003A                                           ; $BE9C: ED 3A 00  ; field[$0C] -= capacity_low
  STA ($20),Y                                           ; $BE9F: 91 20
  INY                                                   ; $BEA1: C8
  LDA ($20),Y                                           ; $BEA2: B1 20
  SBC a:$003B                                           ; $BEA4: ED 3B 00  ; field[$0D] -= capacity_high
  STA ($20),Y                                           ; $BEA7: 91 20
  JSR Proc_D69D                                         ; $BEA9: 20 9D D6  ; flush pending updates

  ; --- Mark officer as fully trained: set ability = $03E8 (1000) ---
  LDA a:$0038                                           ; $BEAC: AD 38 00  ; officer ID
  LDY #$08                                              ; $BEAF: A0 08
  JSR $D2AB                                             ; $BEB1: 20 AB D2  ; resolve officer record → ($22)
  LDY #$08                                              ; $BEB4: A0 08
  LDA #$E8                                              ; $BEB6: A9 E8
  STA ($22),Y                                           ; $BEB8: 91 22      ; ability_low = $E8
  INY                                                   ; $BEBA: C8
  LDA #$03                                              ; $BEBB: A9 03
  STA ($22),Y                                           ; $BEBD: 91 22      ; ability_high = $03 → total $03E8

  ; --- Signal action and loop for next trainable officer ---
  LDA #$02                                              ; $BEBF: A9 02      ; action type 2 = officer training
  JSR Proc_D152                                         ; $BEC1: 20 52 D1  ; signal game engine
  JMP AiDev_Main                               ; $BEC4: 4C 7A BD  ; restart search for next officer

; --- Termination phase: advance turn and random follow-up check ---
; Reached via JMP from AiDev_ExitSearch when no trainable officers remain.
AiDev_Terminate:
  JSR AiTurn_AdvancePhase                               ; $BEC7: 20 E6 BE  ; advance turn phase counter
  LDA #$50                                              ; $BECA: A9 50
  JSR Proc_D4BB                                         ; $BECC: 20 BB D4  ; random(80)
  PHA                                                   ; $BECF: 48
  LDA $6F03                                             ; $BED0: AD 03 6F
  AND #$07                                              ; $BED3: 29 07      ; player_id & 7
  TAY                                                   ; $BED5: A8
  PLA                                                   ; $BED6: 68
  CMP AiDev_ActionThreshold,Y                           ; $BED7: D9 DF BE  ; compare with per-player threshold
  BCC @RollAction                                         ; $BEDA: 90 3A      ; below threshold → alternate action
  JMP AiAction_ContinueTurn                             ; $BEDC: 4C E0 C1  ; continue AI turn (70%/30% officer/eval)

; Per-player aggression thresholds (indexed by player_id & 7)
; Controls probability of continuing AI action after officer development:
;   Player 0: $14 (75%), Player 1: $32 (37.5%), Player 2: $28 (50%),
;   Player 3: $1E (62.5%), Player 4: $28 (50%), Player 5: $3C (25%),
;   Player 6: $32 (37.5%)
AiDev_ActionThreshold:
  .byte $14,$32,$28,$1E,$28,$3C,$32                     ; $BEDF: 14 32 28 1E 28 3C 32

;===============================================================================
; $BEE6: AiTurn_AdvancePhase
; Advances the AI turn phase counter. Each call increments the per-player
; action counter ($6F83,X). After $1E actions, advances the global phase
; ($6F62). At phase 3, transitions to next game state via $D140.
; Otherwise, resets counter and resolves current entity.
;===============================================================================
AiTurn_AdvancePhase:
  LDX $6F03                                           ; $BEE6: AE 03 6F  ; current player
  INC $6F83,X                                         ; $BEE9: FE 83 6F  ; increment action counter
  LDA $6F83,X                                         ; $BEEC: BD 83 6F
  CMP #$1E                                            ; $BEEF: C9 1E      ; 30 actions per phase?
  BCC @ResetCounter                                       ; $BEF1: 90 14      ; not yet → reset and continue
  INC $6F62                                           ; $BEF3: EE 62 6F  ; advance global phase
  LDA $6F62                                           ; $BEF6: AD 62 6F
  CMP #$03                                            ; $BEF9: C9 03      ; phase 3 = end of AI turn
  .byte $D0,$08                                       ; $BEFB: D0 08 (BNE $BF05 — skip if phase ≠ 3)
  LDA #$00                                            ; $BEFD: A9 00      ; phase 3: reset state
  STA $6F62                                           ; $BEFF: 8D 62 6F
  JMP $D140                                           ; $BF02: 4C 40 D1  ; transition to next game state
  LDA #$00                                            ; $BF05: A9 00      ; phase ≠ 3: zero counter
@ResetCounter:
  STA $6F83,X                                         ; $BF07: 9D 83 6F  ; store zeroed counter
  STA $6F5E                                           ; $BF0A: 8D 5E 6F  ; reset entity index
  JSR Proc_D105                                       ; $BF0D: 20 05 D1  ; resolve entity record
  CMP $6F03                                           ; $BF10: CD 03 6F  ; entity owned by current player?
  BNE AiTurn_AdvancePhase                             ; $BF13: D0 D1      ; no → try next entity
  RTS                                                 ; $BF15: 60
;-------------------------------------------------------------------------------
; $BF16: AiAction_RandomDispatch
; 4-way random dispatch selecting AI action type. Rolls random(100):
;   0–39  → game-state check → ReinforceTroops or ReinforceSupplies
;   40–69 → AiAction_BoostMorale
;   70–89 → AiAction_SmallStatBoost
;   90–99 → AiAction_CompositeBoost
;-------------------------------------------------------------------------------
@RollAction:
  LDA #$64                                            ; $BF16: A9 64      ; random(100)
  JSR Proc_D4BB                                       ; $BF18: 20 BB D4
  CMP #$28                                            ; $BF1B: C9 28      ; < 40?
  BCS @CheckMorale                                        ; $BF1D: B0 03      ; no → check next range
  JMP AiAction_StatBranch                             ; $BF1F: 4C 33 BF  ; game-state dependent branch
@CheckMorale:
  CMP #$46                                            ; $BF22: C9 46      ; < 70?
  .byte $B0,$03                                       ; $BF24: B0 03 (BCS $BF29 — skip if ≥ 70)
  JMP AiAction_BoostMorale                            ; $BF26: 4C 4E C0  ; 40–69 → morale boost
  CMP #$5A                                            ; $BF29: C9 5A      ; < 90?
  .byte $B0,$03                                       ; $BF2B: B0 03 (BCS $BF30 — skip if ≥ 90)
  JMP AiAction_SmallStatBoost                         ; $BF2D: 4C CF C0  ; 70–89 → small stat boost
  JMP AiAction_CompositeBoost                         ; $BF30: 4C 30 C1  ; 90–99 → composite boost

; --- Game-state dependent branch (random < 40) ---
; If game state $6F01 is 3–7: reinforce troops; otherwise reinforce supplies.
AiAction_StatBranch:
  LDA $6F01                                           ; $BF33: AD 01 6F  ; game state
  CMP #$03                                            ; $BF36: C9 03      ; state < 3?
  BCC @GotoSupplies                                       ; $BF38: 90 07      ; yes → supplies
  CMP #$08                                            ; $BF3A: C9 08      ; state ≥ 8?
  BCS @GotoSupplies                                       ; $BF3C: B0 03      ; yes → supplies
  JMP AiAction_ReinforceTroops                        ; $BF3E: 4C 44 BF  ; state 3–7 → troops
@GotoSupplies:
  JMP AiAction_ReinforceSupplies                      ; $BF41: 4C C3 BF  ; default → supplies


;===============================================================================
; $BF44: AiAction_ReinforceTroops
; Computes troop reinforcement: (entity_idx × $0E × kingdom_mod) / $0A,
; adds loyalty bonus, writes to entity record[$08/$09] (16-bit), capped at 999.
;===============================================================================
AiAction_ReinforceTroops:
  LDA #$0A                                            ; $BF44: A9 0A
  STA $22                                             ; $BF46: 85 22
  LDA #$00                                            ; $BF48: A9 00
  STA $23                                             ; $BF4A: 85 23
  LDA #$0E                                            ; $BF4C: A9 0E
  STA $24                                             ; $BF4E: 85 24
  LDA $6F5E                                           ; $BF50: AD 5E 6F  ; entity index
  JSR Proc_D36F                                       ; $BF53: 20 6F D3  ; multiply: entity_idx × $0E
  .byte $90,$68                                       ; $BF56: 90 68 (BCC mid-instruction target)
  LDA $22                                             ; $BF58: A5 22
  STA $20                                             ; $BF5A: 85 20
  LDA $23                                             ; $BF5C: A5 23
  STA $21                                             ; $BF5E: 85 21
  LDA #$00                                            ; $BF60: A9 00
  STA $22                                             ; $BF62: 85 22
  LDY $6F02                                           ; $BF64: AC 02 6F  ; kingdom index
  LDA KingdomActionModifiers,Y                        ; $BF67: B9 42 C0  ; kingdom modifier
  STA $23                                             ; $BF6A: 85 23
  JSR Proc_D438                                       ; $BF6C: 20 38 D4  ; multiply result × modifier
  LDA $26                                             ; $BF6F: A5 26
  STA $21                                             ; $BF71: 85 21
  LDA $27                                             ; $BF73: A5 27
  STA $22                                             ; $BF75: 85 22
  LDA #$0A                                            ; $BF77: A9 0A
  STA $23                                             ; $BF79: 85 23
  LDA #$00                                            ; $BF7B: A9 00
  STA $24                                             ; $BF7D: 85 24
  JSR Proc_D40F                                       ; $BF7F: 20 0F D4  ; divide by $0A
  LDA $22                                             ; $BF82: A5 22
  STA $23                                             ; $BF84: 85 23
  LDA $21                                             ; $BF86: A5 21
  STA $22                                             ; $BF88: 85 22
  LDA $6F5E                                           ; $BF8A: AD 5E 6F
  JSR Proc_D105                                       ; $BF8D: 20 05 D1  ; resolve entity → ($20)
  LDA $22                                             ; $BF90: A5 22
  JSR AddLoyaltyBonus_Small                           ; $BF92: 20 A7 C1  ; add loyalty bonus to field[$0B]
  LDY #$08                                            ; $BF95: A0 08      ; entity record offset $08 (troops lo)
  LDA ($20),Y                                         ; $BF97: B1 20
  CLC                                                 ; $BF99: 18
  ADC $22                                             ; $BF9A: 65 22
  STA ($20),Y                                         ; $BF9C: 91 20
  INY                                                 ; $BF9E: C8
  LDA ($20),Y                                         ; $BF9F: B1 20
  ADC $23                                             ; $BFA1: 65 23
  AND #$03                                            ; $BFA3: 29 03      ; cap hi-byte to 3
  STA ($20),Y                                         ; $BFA5: 91 20
  CMP #$03                                            ; $BFA7: C9 03      ; hi = 3?
  .byte $90,$10                                       ; $BFA9: 90 10 (BCC $BFBB — skip cap if hi < 3)
  DEY                                                 ; $BFAB: 88         ; offset $08 (troops lo)
  LDA ($20),Y                                         ; $BFAC: B1 20
  CMP #$E7                                            ; $BFAE: C9 E7      ; lo ≥ $E7?
  .byte $90,$09                                       ; $BFB0: 90 09 (BCC $BFBB — skip cap if lo < $E7)
  LDA #$E7                                            ; $BFB2: A9 E7      ; clamp to $03E7 = 999
  STA ($20),Y                                         ; $BFB4: 91 20
  INY                                                 ; $BFB6: C8
  LDA #$03                                            ; $BFB7: A9 03
  STA ($20),Y                                         ; $BFB9: 91 20
  LDA #$05                                            ; $BFBB: A9 05      ; signal action type 5
  JSR Proc_D152                                       ; $BFBD: 20 52 D1
  JMP $BEC7                                           ; $BFC0: 4C C7 BE  ; return to AI turn loop

;===============================================================================
; $BFC3: AiAction_ReinforceSupplies
; Same algorithm as ReinforceTroops but writes to entity record[$0E/$0F]
; (supply/provision field) instead of $08/$09. Same kingdom modifier table
; (KingdomActionModifiers, offset 0). Same cap of 999.
;===============================================================================
AiAction_ReinforceSupplies:
  LDA #$0A                                            ; $BFC3: A9 0A
  STA $22                                             ; $BFC5: 85 22
  LDA #$00                                            ; $BFC7: A9 00
  STA $23                                             ; $BFC9: 85 23
  LDA #$0E                                            ; $BFCB: A9 0E
  STA $24                                             ; $BFCD: 85 24
  LDA $6F5E                                           ; $BFCF: AD 5E 6F
  JSR Proc_D36F                                       ; $BFD2: 20 6F D3
  .byte $90,$68                                       ; $BFD5: 90 68 (BCC cross-bank)
  LDA $22                                             ; $BFD7: A5 22
  STA $20                                             ; $BFD9: 85 20
  LDA $23                                             ; $BFDB: A5 23
  STA $21                                             ; $BFDD: 85 21
  LDA #$00                                            ; $BFDF: A9 00
  STA $22                                             ; $BFE1: 85 22
  LDY $6F02                                           ; $BFE3: AC 02 6F  ; kingdom index
  LDA KingdomActionModifiers,Y                        ; $BFE6: B9 42 C0  ; kingdom modifier
  STA $23                                             ; $BFE9: 85 23
  JSR Proc_D438                                       ; $BFEB: 20 38 D4
  LDA $26                                             ; $BFEE: A5 26
  STA $21                                             ; $BFF0: 85 21
  LDA $27                                             ; $BFF2: A5 27
  STA $22                                             ; $BFF4: 85 22
  LDA #$0A                                            ; $BFF6: A9 0A
  STA $23                                             ; $BFF8: 85 23
  LDA #$00                                            ; $BFFA: A9 00
  STA $24                                             ; $BFFC: 85 24
  JSR Proc_D40F                                       ; $BFFE: 20 0F D4  (cross-bank: hi byte at $C000)

  LDA $22                                             ; $C001: A5 22
  STA $23                                             ; $C003: 85 23
  LDA $21                                             ; $C005: A5 21
  STA $22                                             ; $C007: 85 22
  LDA $6F5E                                           ; $C009: AD 5E 6F
  JSR Proc_D105                                       ; $C00C: 20 05 D1  ; resolve entity → ($20)
  LDA $22                                             ; $C00F: A5 22
  JSR AddLoyaltyBonus_Small                           ; $C011: 20 A7 C1  ; loyalty bonus to field[$0B]
  LDY #$0E                                            ; $C014: A0 0E      ; offset $0E (supplies lo)
  LDA ($20),Y                                         ; $C016: B1 20
  CLC                                                 ; $C018: 18
  ADC $22                                             ; $C019: 65 22
  STA ($20),Y                                         ; $C01B: 91 20
  INY                                                 ; $C01D: C8
  LDA ($20),Y                                         ; $C01E: B1 20
  ADC $23                                             ; $C020: 65 23
  AND #$03                                            ; $C022: 29 03
  STA ($20),Y                                         ; $C024: 91 20
  CMP #$03                                            ; $C026: C9 03
  .byte $90,$10                                       ; $C028: 90 10 (BCC mid-instruction target)
  DEY                                                 ; $C02A: 88
  LDA ($20),Y                                         ; $C02B: B1 20
  CMP #$E7                                            ; $C02D: C9 E7
  .byte $90,$09                                       ; $C02F: 90 09 (BCC mid-instruction target)
  LDA #$E7                                            ; $C031: A9 E7
  STA ($20),Y                                         ; $C033: 91 20
  INY                                                 ; $C035: C8
  LDA #$03                                            ; $C036: A9 03
  STA ($20),Y                                         ; $C038: 91 20
  LDA #$05                                            ; $C03A: A9 05
  JSR Proc_D152                                       ; $C03C: 20 52 D1
  JMP $BEC7                                           ; $C03F: 4C C7 BE  ; return to AI turn loop

; Per-kingdom action modifiers (circular 12-byte table, indexed by kingdom_index)
; Accessed at different base offsets to select action type:
;   +0 = troops/supplies, +3 = small stat, +6 = composite, +9 = officer loyalty
KingdomActionModifiers:
  .byte $0C,$0F,$12,$06,$07,$08,$19,$14,$0F,$03,$05,$07  ; 12,15,18,6,7,8,25,20,15,3,5,7


;===============================================================================
; $C04E: AiAction_BoostMorale
; Computes morale boost at HALF strength: (entity_idx × $0E × mod) / $0A / 2.
; Writes to entity record[$06/$07] (16-bit morale), capped at $270F.
; Also adds a large loyalty bonus via AddLoyaltyBonus_Large.
;===============================================================================
.proc AiAction_BoostMorale
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026
  math_temp3               = $0027
  work_outer_idx           = $0036
  sram_kingdom_index       = $6F02

  LDA #$0A                                            ; $C04E: A9 0A
  STA $22                                             ; $C050: 85 22
  LDA #$00                                            ; $C052: A9 00
  STA $23                                             ; $C054: 85 23
  LDA #$0E                                            ; $C056: A9 0E
  STA $24                                             ; $C058: 85 24
  LDA $6F5E                                           ; $C05A: AD 5E 6F
  JSR Proc_D36F                                       ; $C05D: 20 6F D3
  .byte $90,$6A                                       ; $C060: 90 6A (BCC mid-instruction target)
  LDA $22                                             ; $C062: A5 22
  STA $20                                             ; $C064: 85 20
  LDA $23                                             ; $C066: A5 23
  STA $21                                             ; $C068: 85 21
  LDA #$00                                            ; $C06A: A9 00
  STA $22                                             ; $C06C: 85 22
  LDY $6F02                                           ; $C06E: AC 02 6F
  LDA KingdomActionModifiers,Y                        ; $C071: B9 42 C0  ; kingdom modifier (offset 0)
  STA $23                                             ; $C074: 85 23
  JSR Proc_D438                                       ; $C076: 20 38 D4
  LDA $26                                             ; $C079: A5 26
  STA $21                                             ; $C07B: 85 21
  LDA $27                                             ; $C07D: A5 27
  STA $22                                             ; $C07F: 85 22
  LDA #$0A                                            ; $C081: A9 0A
  STA $23                                             ; $C083: 85 23
  LDA #$00                                            ; $C085: A9 00
  STA $24                                             ; $C087: 85 24
  JSR Proc_D40F                                       ; $C089: 20 0F D4
  LDA $22                                             ; $C08C: A5 22
  STA $23                                             ; $C08E: 85 23
  LDA $21                                             ; $C090: A5 21
  STA $22                                             ; $C092: 85 22
  LSR $23                                             ; $C094: 46 23      ; halve the 16-bit result (÷2)
  ROR $22                                             ; $C096: 66 22
  LDA $6F5E                                           ; $C098: AD 5E 6F
  JSR Proc_D105                                       ; $C09B: 20 05 D1  ; resolve entity → ($20)
  JSR AddLoyaltyBonus_Large                           ; $C09E: 20 C0 C1  ; bonus based on 3000 threshold
  LDY #$06                                            ; $C0A1: A0 06      ; offset $06 (morale lo)
  LDA ($20),Y                                         ; $C0A3: B1 20
  CLC                                                 ; $C0A5: 18
  ADC $22                                             ; $C0A6: 65 22
  STA ($20),Y                                         ; $C0A8: 91 20
  INY                                                 ; $C0AA: C8
  LDA ($20),Y                                         ; $C0AB: B1 20
  ADC $23                                             ; $C0AD: 65 23
  AND #$7F                                            ; $C0AF: 29 7F      ; cap hi-byte to $7F
  STA ($20),Y                                         ; $C0B1: 91 20
  CMP #$27                                            ; $C0B3: C9 27      ; hi ≥ $27?
  .byte $90,$10                                       ; $C0B5: 90 10 (BCC $C0C7 — skip cap if hi < $27)
  DEY                                                 ; $C0B7: 88         ; offset $06 (morale lo)
  LDA ($20),Y                                         ; $C0B8: B1 20
  CMP #$10                                            ; $C0BA: C9 10      ; lo ≥ $10?
  .byte $90,$09                                       ; $C0BC: 90 09 (BCC $C0C7 — skip cap if lo < $10)
  LDA #$0F                                            ; $C0BE: A9 0F      ; clamp to $0F27 (morale cap)
  STA ($20),Y                                         ; $C0C0: 91 20
  INY                                                 ; $C0C2: C8
  LDA #$27                                            ; $C0C3: A9 27
  STA ($20),Y                                         ; $C0C5: 91 20
  LDA #$05                                            ; $C0C7: A9 05
  JSR Proc_D152                                       ; $C0C9: 20 52 D1
  JMP $BEC7                                           ; $C0CC: 4C C7 BE  ; return to AI turn loop

;-------------------------------------------------------------------------------
; $C0CF: AiAction_SmallStatBoost
; Single-byte stat boost: (entity_idx × $0A × mod[3]) / $0A.
; Writes to entity record[$0A] (single byte), capped at 99 ($63).
;-------------------------------------------------------------------------------
AiAction_SmallStatBoost:
  LDA #$0A                                            ; $C0CF: A9 0A
  STA $22                                             ; $C0D1: 85 22
  LDA #$00                                            ; $C0D3: A9 00
  STA $23                                             ; $C0D5: 85 23
  LDA #$0A                                            ; $C0D7: A9 0A
  STA $24                                             ; $C0D9: 85 24
  LDA $6F5E                                           ; $C0DB: AD 5E 6F
  JSR Proc_D36F                                       ; $C0DE: 20 6F D3
  .byte $90,$4A                                       ; $C0E1: 90 4A (BCC mid-instruction target)
  LDA $22                                             ; $C0E3: A5 22
  STA $20                                             ; $C0E5: 85 20
  LDA $23                                             ; $C0E7: A5 23
  STA $21                                             ; $C0E9: 85 21
  LDA #$00                                            ; $C0EB: A9 00
  STA $22                                             ; $C0ED: 85 22
  LDY $6F02                                           ; $C0EF: AC 02 6F
  LDA KingdomActionModifiers+3,Y                      ; $C0F2: B9 45 C0  ; modifier at offset 3
  STA $23                                             ; $C0F5: 85 23
  JSR Proc_D438                                       ; $C0F7: 20 38 D4
  LDA $26                                             ; $C0FA: A5 26
  STA $21                                             ; $C0FC: 85 21
  LDA $27                                             ; $C0FE: A5 27
  STA $22                                             ; $C100: 85 22
  LDA #$0A                                            ; $C102: A9 0A
  STA $23                                             ; $C104: 85 23
  LDA #$00                                            ; $C106: A9 00
  STA $24                                             ; $C108: 85 24
  JSR Proc_D40F                                       ; $C10A: 20 0F D4
  LDA $21                                             ; $C10D: A5 21
  STA $23                                             ; $C10F: 85 23
  LDA $6F5E                                           ; $C111: AD 5E 6F
  JSR Proc_D105                                       ; $C114: 20 05 D1
  LDY #$0A                                            ; $C117: A0 0A
  LDA ($20),Y                                         ; $C119: B1 20
  CLC                                                 ; $C11B: 18
  ADC $23                                             ; $C11C: 65 23
  STA ($20),Y                                         ; $C11E: 91 20
  CMP #$63                                            ; $C120: C9 63
  .byte $90,$04                                       ; $C122: 90 04 (BCC mid-instruction target)
  LDA #$63                                            ; $C124: A9 63
  STA ($20),Y                                         ; $C126: 91 20
  LDA #$05                                            ; $C128: A9 05
  JSR Proc_D152                                       ; $C12A: 20 52 D1
  JMP $BEC7                                           ; $C12D: 4C C7 BE  ; return to AI turn loop

;-------------------------------------------------------------------------------
; $C130: AiAction_CompositeBoost
; Composite boost combining TWO multiplication results:
;   part1 = entity_idx × $1E (via Proc_D36F)
;   part2 = entity_idx × $1E (via Proc_D3A9)
;   result = (part1 + part2) / mod[6]
; Writes to entity record[$0B] (single byte), capped at 99.
;-------------------------------------------------------------------------------
AiAction_CompositeBoost:
  LDA #$1E                                            ; $C130: A9 1E
  STA $22                                             ; $C132: 85 22
  LDA #$00                                            ; $C134: A9 00
  STA $23                                             ; $C136: 85 23
  LDA #$1E                                            ; $C138: A9 1E
  STA $24                                             ; $C13A: 85 24
  LDA $6F5E                                           ; $C13C: AD 5E 6F
  JSR Proc_D36F                                       ; $C13F: 20 6F D3
  .byte $90,$60                                       ; $C142: 90 60 (BCC mid-instruction target)
  LDA $22                                             ; $C144: A5 22
  STA $2A                                             ; $C146: 85 2A
  LDA $23                                             ; $C148: A5 23
  STA $2B                                             ; $C14A: 85 2B
  LDA #$1E                                            ; $C14C: A9 1E
  STA $22                                             ; $C14E: 85 22
  LDA #$00                                            ; $C150: A9 00
  STA $23                                             ; $C152: 85 23
  LDA #$1E                                            ; $C154: A9 1E
  STA $24                                             ; $C156: 85 24
  LDA $6F5E                                           ; $C158: AD 5E 6F
  JSR Proc_D3A9                                       ; $C15B: 20 A9 D3
  .byte $90,$44                                       ; $C15E: 90 44 (BCC mid-instruction target)
  LDA $22                                             ; $C160: A5 22
  CLC                                                 ; $C162: 18
  ADC $2A                                             ; $C163: 65 2A
  STA $2A                                             ; $C165: 85 2A
  LDA $23                                             ; $C167: A5 23
  ADC $2B                                             ; $C169: 65 2B
  STA $2B                                             ; $C16B: 85 2B
  LDA $2A                                             ; $C16D: A5 2A
  STA $21                                             ; $C16F: 85 21
  LDA $2B                                             ; $C171: A5 2B
  STA $22                                             ; $C173: 85 22
  LDY $6F02                                           ; $C175: AC 02 6F
  LDA KingdomActionModifiers+6,Y                      ; $C178: B9 48 C0  ; modifier at offset 6
  STA $23                                             ; $C17B: 85 23
  LDA #$00                                            ; $C17D: A9 00
  STA $24                                             ; $C17F: 85 24
  JSR Proc_D40F                                       ; $C181: 20 0F D4
  LDA $21                                             ; $C184: A5 21
  STA $23                                             ; $C186: 85 23
  LDA $6F5E                                           ; $C188: AD 5E 6F
  JSR Proc_D105                                       ; $C18B: 20 05 D1
  LDY #$0B                                            ; $C18E: A0 0B
  LDA ($20),Y                                         ; $C190: B1 20
  CLC                                                 ; $C192: 18
  ADC $23                                             ; $C193: 65 23
  STA ($20),Y                                         ; $C195: 91 20
  CMP #$63                                            ; $C197: C9 63
  .byte $90,$04                                       ; $C199: 90 04 (BCC mid-instruction target)
  LDA #$63                                            ; $C19B: A9 63
  STA ($20),Y                                         ; $C19D: 91 20
  LDA #$05                                            ; $C19F: A9 05
  JSR Proc_D152                                       ; $C1A1: 20 52 D1
  JMP $BEC7                                           ; $C1A4: 4C C7 BE  ; return to AI turn loop

;-------------------------------------------------------------------------------
; $C1A7: AddLoyaltyBonus_Small
; Adds loyalty bonus (1 or 2) to entity record[$0B], capped at 100.
; Input A = value to compare: if A < $1F → bonus=1, else bonus=2.
;-------------------------------------------------------------------------------
AddLoyaltyBonus_Small:
  LDY #$01                                            ; $C1A7: A0 01      ; default bonus = 1
  CMP #$1F                                            ; $C1A9: C9 1F
  BCC @AssignBonus_S                                      ; $C1AB: 90 01
  INY                                                 ; $C1AD: C8
@AssignBonus_S:
  STY $2A                                             ; $C1AE: 84 2A
  LDY #$0B                                            ; $C1B0: A0 0B
  LDA ($20),Y                                         ; $C1B2: B1 20
  CLC                                                 ; $C1B4: 18
  ADC $2A                                             ; $C1B5: 65 2A
  CMP #$64                                            ; $C1B7: C9 64
  BCC @CapLoyalty_S                                       ; $C1B9: 90 02
  LDA #$64                                            ; $C1BB: A9 64
@CapLoyalty_S:
  STA ($20),Y                                         ; $C1BD: 91 20
  RTS                                                 ; $C1BF: 60

;-------------------------------------------------------------------------------
; $C1C0: AddLoyaltyBonus_Large
; Adds loyalty bonus (1 or 2) based on whether 16-bit value $22/$23 ≥ 3000.
; Bonus is added to entity record[$0B], capped at 100.
;-------------------------------------------------------------------------------
AddLoyaltyBonus_Large:
  LDY #$01                                            ; $C1C0: A0 01      ; default bonus = 1
  LDA $22                                             ; $C1C2: A5 22
  SEC                                                 ; $C1C4: 38
  SBC #$B8                                            ; $C1C5: E9 B8      ; subtract $0BB8 (3000) lo
  LDA $23                                             ; $C1C7: A5 23
  SBC #$0B                                            ; $C1C9: E9 0B      ; subtract hi byte
  BCC @AssignBonus_L                                      ; $C1CB: 90 01      ; value < 3000 → bonus=1
  INY                                                 ; $C1CD: C8         ; value ≥ 3000 → bonus=2
@AssignBonus_L:
  STY $2A                                             ; $C1CE: 84 2A
  LDY #$0B                                            ; $C1D0: A0 0B
  LDA ($20),Y                                         ; $C1D2: B1 20
  CLC                                                 ; $C1D4: 18
  ADC $2A                                             ; $C1D5: 65 2A
  CMP #$64                                            ; $C1D7: C9 64
  BCC @CapLoyalty_L                                       ; $C1D9: 90 02
  LDA #$64                                            ; $C1DB: A9 64
@CapLoyalty_L:
  STA ($20),Y                                         ; $C1DD: 91 20
  RTS                                                 ; $C1DF: 60

;-------------------------------------------------------------------------------
; $C1E0: AiAction_ContinueTurn
; Clears AI work area ($6F73-$6F82), then randomly picks between:
;   70% → AiAction_ManageOfficerLoyalty (field[$02] management)
;   30% → FindWeakestLoyaltyOfficer → boost officer field[$03]
; If officer field[$03] ≥ 70, retries. Falls through to AiAction_EvaluateAndExecute
; if no valid officer found.
;-------------------------------------------------------------------------------
AiAction_ContinueTurn:
  LDY #$0F                                            ; $C1E0: A0 0F      ; clear 16 bytes of AI work area
  LDA #$FF                                            ; $C1E2: A9 FF
@ClearLoop:
  STA $6F73,Y                                         ; $C1E4: 99 73 6F
  DEY                                                 ; $C1E7: 88
  BPL @ClearLoop                                           ; $C1E8: 10 FA
  LDA #$64                                            ; $C1EA: A9 64
  JSR Proc_D4BB                                       ; $C1EC: 20 BB D4
  CMP #$1E                                            ; $C1EF: C9 1E
  BCC @BranchRandom                                           ; $C1F1: 90 03
  JMP AiAction_ManageOfficerLoyalty                   ; $C1F3: 4C 98 C2  ; 70% → officer management
@BranchRandom:
  JSR FindWeakestLoyaltyOfficer                       ; $C1F6: 20 48 C2  ; find officer w/ lowest field[$03]
  LDA $23                                             ; $C1F9: A5 23
  CMP #$FF                                            ; $C1FB: C9 FF
  BNE @ValidOfficer                                           ; $C1FD: D0 03
  JMP AiAction_EvaluateAndExecute                     ; $C1FF: 4C 37 C3  ; no officer → strategic eval
@ValidOfficer:
  STA a:$0036                                         ; $C202: 8D 36 00
  LDY #$03                                            ; $C205: A0 03
  JSR Proc_D283                                       ; $C207: 20 83 D2
  CMP #$46                                            ; $C20A: C9 46
  BCS @BranchRandom                                           ; $C20C: B0 E8
  LDA #$14                                            ; $C20E: A9 14
  STA $22                                             ; $C210: 85 22
  LDA #$00                                            ; $C212: A9 00
  STA $23                                             ; $C214: 85 23
  LDA #$0A                                            ; $C216: A9 0A
  STA $24                                             ; $C218: 85 24
  LDA $6F5E                                           ; $C21A: AD 5E 6F
  JSR Proc_D36F                                       ; $C21D: 20 6F D3
  .byte $90,$23                                       ; $C220: 90 23 (BCC mid-instruction target)
  LDA #$05                                            ; $C222: A9 05
  JSR Proc_D4AD                                       ; $C224: 20 AD D4
  CLC                                                 ; $C227: 18
  LDY $6F02                                           ; $C228: AC 02 6F
  ADC KingdomActionModifiers+9,Y                      ; $C22B: 79 4B C0  ; modifier at offset 9
  STA $22                                             ; $C22E: 85 22
  LDA a:$0036                                         ; $C230: AD 36 00
  LDY #$03                                            ; $C233: A0 03
  JSR Proc_D283                                       ; $C235: 20 83 D2
  CLC                                                 ; $C238: 18
  ADC $22                                             ; $C239: 65 22
  STA ($20),Y                                         ; $C23B: 91 20
  JSR Proc_D5E7                                       ; $C23D: 20 E7 D5
  LDA #$05                                            ; $C240: A9 05
  JSR Proc_D152                                       ; $C242: 20 52 D1
  JMP $BEC7                                           ; $C245: 4C C7 BE  ; return to AI turn loop

;-------------------------------------------------------------------------------
; $C248: FindWeakestLoyaltyOfficer
; Scans officer slots $11–$1A for the officer with lowest field[$03]
; (loyalty). Skips empty ($FF), inactive ($6F62=0), and maxed (100) officers.
; Returns: officer ID in $23 ($FF if none found).
;-------------------------------------------------------------------------------
FindWeakestLoyaltyOfficer:
  LDA #$11                                            ; $C248: A9 11      ; start slot = $11
  STA $24                                             ; $C24A: 85 24
  LDA #$FF                                            ; $C24C: A9 FF      ; init best = $FF (none)
  STA $22                                             ; $C24E: 85 22
  STA $23                                             ; $C250: 85 23
@ScanNext_Weak:
  LDA $6F5E                                           ; $C252: AD 5E 6F
  JSR Proc_D105                                       ; $C255: 20 05 D1
  LDY $24                                             ; $C258: A4 24
  LDA ($20),Y                                         ; $C25A: B1 20
  STA $25                                             ; $C25C: 85 25
  CMP #$FF                                            ; $C25E: C9 FF
  BEQ @NextSlot_Weak                                           ; $C260: F0 1A
  LDA $6F62,Y                                         ; $C262: B9 62 6F
  BEQ @NextSlot_Weak                                           ; $C265: F0 15
  LDY #$03                                            ; $C267: A0 03
  LDA $25                                             ; $C269: A5 25
  JSR Proc_D283                                       ; $C26B: 20 83 D2
  CMP #$64                                            ; $C26E: C9 64
  BEQ @NextSlot_Weak                                           ; $C270: F0 0A
  CMP $22                                             ; $C272: C5 22
  BCS @NextSlot_Weak                                           ; $C274: B0 06
  STA $22                                             ; $C276: 85 22
  LDA $24                                             ; $C278: A5 24
  STA $23                                             ; $C27A: 85 23
@NextSlot_Weak:
  INC $24                                             ; $C27C: E6 24
  LDY $24                                             ; $C27E: A4 24
  CPY #$1B                                            ; $C280: C0 1B
  BCC @ScanNext_Weak                                           ; $C282: 90 CE
  LDA $6F5E                                           ; $C284: AD 5E 6F
  JSR Proc_D105                                       ; $C287: 20 05 D1
  LDY $23                                             ; $C28A: A4 23
  BMI @Done_Weak                                           ; $C28C: 30 09
  LDA #$00                                            ; $C28E: A9 00
  STA $6F62,Y                                         ; $C290: 99 62 6F
  LDA ($20),Y                                         ; $C293: B1 20
  STA $23                                             ; $C295: 85 23
@Done_Weak:
  RTS                                                 ; $C297: 60
.endproc



;===============================================================================
; $C298: AiAction_ManageOfficerLoyalty
; Finds officer with lowest field[$02], boosts it if in range [50, 80).
; Uses FindLowestAttributeOfficer, then adds computed bonus to field[$02].
; Retries if value is outside [50, 80) range.
;===============================================================================
.proc AiAction_ManageOfficerLoyalty
  math_acc_lo              = $0020
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  work_outer_idx           = $0036
  sram_kingdom_index       = $6F02

  JSR FindLowestAttributeOfficer                      ; $C298: 20 EB C2  ; find officer w/ lowest field[$02]
  LDA $23                                             ; $C29B: A5 23
  CMP #$FF                                            ; $C29D: C9 FF
  .byte $F0,$47                                       ; $C29F: F0 47 (BEQ mid-instruction target)
  STA a:$0036                                         ; $C2A1: 8D 36 00
  LDY #$02                                            ; $C2A4: A0 02
  JSR Proc_D283                                       ; $C2A6: 20 83 D2
  CMP #$32                                            ; $C2A9: C9 32
  BCC AiAction_ManageOfficerLoyalty                   ; $C2AB: 90 EB      ; below 50 → retry
  CMP #$50                                            ; $C2AD: C9 50
  BCS AiAction_ManageOfficerLoyalty                   ; $C2AF: B0 E7      ; above 80 → retry
  LDA #$14                                            ; $C2B1: A9 14
  STA $22                                             ; $C2B3: 85 22
  LDA #$00                                            ; $C2B5: A9 00
  STA $23                                             ; $C2B7: 85 23
  LDA #$0A                                            ; $C2B9: A9 0A
  STA $24                                             ; $C2BB: 85 24
  LDA $6F5E                                           ; $C2BD: AD 5E 6F
  JSR Proc_D36F                                       ; $C2C0: 20 6F D3
  .byte $90,$23                                       ; $C2C3: 90 23 (BCC mid-instruction target)
  LDA #$05                                            ; $C2C5: A9 05
  JSR Proc_D4AD                                       ; $C2C7: 20 AD D4
  CLC                                                 ; $C2CA: 18
  LDY $6F02                                           ; $C2CB: AC 02 6F
  ADC KingdomActionModifiers+9,Y                      ; $C2CE: 79 4B C0  ; modifier at offset 9
  STA $22                                             ; $C2D1: 85 22
  LDA a:$0036                                         ; $C2D3: AD 36 00
  LDY #$02                                            ; $C2D6: A0 02
  JSR Proc_D283                                       ; $C2D8: 20 83 D2
  CLC                                                 ; $C2DB: 18
  ADC $22                                             ; $C2DC: 65 22
  STA ($20),Y                                         ; $C2DE: 91 20
  JSR Proc_D5E7                                       ; $C2E0: 20 E7 D5
  LDA #$05                                            ; $C2E3: A9 05
  JSR Proc_D152                                       ; $C2E5: 20 52 D1
  JMP $BEC7                                           ; $C2E8: 4C C7 BE  ; return to AI turn loop

;-------------------------------------------------------------------------------
; $C2EB: FindLowestAttributeOfficer
; Like FindWeakestLoyaltyOfficer but scans field[$02] instead of $03.
; Does NOT skip officers at value=100.
; Returns: officer ID in $23 ($FF if none found).
;-------------------------------------------------------------------------------
FindLowestAttributeOfficer:
  LDA #$11                                            ; $C2EB: A9 11      ; start slot = $11
  STA $24                                             ; $C2ED: 85 24
  LDA #$FF                                            ; $C2EF: A9 FF      ; init best = $FF (none)
  STA $22                                             ; $C2F1: 85 22
  STA $23                                             ; $C2F3: 85 23
@ScanNext_Low:
  LDA $6F5E                                           ; $C2F5: AD 5E 6F
  JSR Proc_D105                                       ; $C2F8: 20 05 D1
  LDY $24                                             ; $C2FB: A4 24
  LDA ($20),Y                                         ; $C2FD: B1 20
  STA $25                                             ; $C2FF: 85 25
  CMP #$FF                                            ; $C301: C9 FF
  BEQ @NextSlot_Low                                           ; $C303: F0 16
  LDA $6F62,Y                                         ; $C305: B9 62 6F
  BEQ @NextSlot_Low                                           ; $C308: F0 11
  LDY #$02                                            ; $C30A: A0 02
  LDA $25                                             ; $C30C: A5 25
  JSR Proc_D283                                       ; $C30E: 20 83 D2
  CMP $22                                             ; $C311: C5 22
  BCS @NextSlot_Low                                           ; $C313: B0 06
  STA $22                                             ; $C315: 85 22
  LDA $24                                             ; $C317: A5 24
  STA $23                                             ; $C319: 85 23
@NextSlot_Low:
  INC $24                                             ; $C31B: E6 24
  LDY $24                                             ; $C31D: A4 24
  CPY #$1B                                            ; $C31F: C0 1B
  BCC @ScanNext_Low                                           ; $C321: 90 D2
  LDA $6F5E                                           ; $C323: AD 5E 6F
  JSR Proc_D105                                       ; $C326: 20 05 D1
  LDY $23                                             ; $C329: A4 23
  BMI @Done_Low                                           ; $C32B: 30 09
  LDA #$00                                            ; $C32D: A9 00
  STA $6F62,Y                                         ; $C32F: 99 62 6F
  LDA ($20),Y                                         ; $C332: B1 20
  STA $23                                             ; $C334: 85 23
@Done_Low:
  RTS                                                 ; $C336: 60
.endproc


;===============================================================================
; $C337: AiAction_EvaluateAndExecute
; Switches to bank 1F, evaluates entity strategic state, and executes actions.
; Loops: evaluate → deduct cost → write result → re-evaluate until done.
; Two paths based on $3A bit fields: lower 5 bits (domestic/military actions)
; and upper 3 bits (diplomacy/special actions), using different cost tables.
;===============================================================================
.proc AiAction_EvaluateAndExecute
  math_acc_mhi             = $0022
  work_inner_idx2          = $0038
  work_limit_a             = $003A

  LDY #$30                                            ; $C337: A0 30
  JSR B1F_SwitchBank8_A                               ; $C339: 20 66 F2
  LDY $6F5E                                           ; $C33C: AC 5E 6F
  LDA $8FFC,Y                                         ; $C33F: B9 FC 8F
  AND #$01                                            ; $C342: 29 01
  .byte $D0,$03                                       ; $C344: D0 03 (BNE mid-instruction target)
@BailOut:
  JMP $BEC7                                           ; $C346: 4C C7 BE
  JSR Proc_C3FF                                       ; $C349: 20 FF C3
  LDA a:$0038                                         ; $C34C: AD 38 00
  CMP #$FF                                            ; $C34F: C9 FF
  BEQ @BailOut                                           ; $C351: F0 F3
  LDA $6F5E                                           ; $C353: AD 5E 6F
  JSR Proc_D105                                       ; $C356: 20 05 D1
  LDA a:$003A                                         ; $C359: AD 3A 00
  AND #$1F                                            ; $C35C: 29 1F
  BEQ @DiplomacyPath                                           ; $C35E: F0 1E
  ASL A                                               ; $C360: 0A
  TAX                                                 ; $C361: AA
  JSR DeductActionCost                                ; $C362: 20 A4 C3  ; deduct from cost table 1/2
  BCC @BailOut                                           ; $C365: 90 DF      ; underflow → bail out
  LDA a:$0038                                         ; $C367: AD 38 00
  LDY #$0A                                            ; $C36A: A0 0A
  JSR $D2AB                                           ; $C36C: 20 AB D2
  AND #$E0                                            ; $C36F: 29 E0
  ORA a:$003A                                         ; $C371: 0D 3A 00
  STA ($22),Y                                         ; $C374: 91 22
  LDA #$05                                            ; $C376: A9 05
  JSR Proc_D152                                       ; $C378: 20 52 D1
  JMP $C349                                           ; $C37B: 4C 49 C3
@DiplomacyPath:
  LSR A                                               ; $C37E: 4A
  LSR A                                               ; $C37F: 4A
  LSR A                                               ; $C380: 4A
  LSR A                                               ; $C381: 4A
  LSR A                                               ; $C382: 4A
  CLC                                                 ; $C383: 18
  ADC #$0C                                            ; $C384: 69 0C
  ASL A                                               ; $C386: 0A
  TAX                                                 ; $C387: AA
  JSR DeductActionCost                                ; $C388: 20 A4 C3  ; deduct from cost table 3/4
  BCC @BailOut                                           ; $C38B: 90 B9      ; underflow → bail out
  LDA a:$0038                                         ; $C38D: AD 38 00
  LDY #$0A                                            ; $C390: A0 0A
  JSR $D2AB                                           ; $C392: 20 AB D2
  AND #$1F                                            ; $C395: 29 1F
  ORA a:$003A                                         ; $C397: 0D 3A 00
  STA ($22),Y                                         ; $C39A: 91 22
  LDA #$05                                            ; $C39C: A9 05
  JSR Proc_D152                                       ; $C39E: 20 52 D1
  JMP $C349                                           ; $C3A1: 4C 49 C3
.endproc


;===============================================================================
; $C3A4: DeductActionCost
; Subtracts a 16-bit cost from entity record[$02/$03] using cost tables.
; X = table index (0,2,4,...14). Returns with C=1 on success, C=0 on underflow.
; Cost tables: $C3BF (domestic), $C3CF (military), $C3DF (diplomacy-A), $C3EF (diplomacy-B)
;===============================================================================
.proc DeductActionCost
  math_acc_lo              = $0020
  math_acc_mhi             = $0022

  LDY #$02                                            ; $C3A4: A0 02
  LDA ($20),Y                                         ; $C3A6: B1 20
  SEC                                                 ; $C3A8: 38
  SBC ActionCostTable_Domestic,X                      ; $C3A9: FD BF C3  ; subtract cost lo byte
  STA $22                                             ; $C3AC: 85 22
  INY                                                 ; $C3AE: C8
  LDA ($20),Y                                         ; $C3AF: B1 20
  SBC ActionCostTable_Domestic+1,X                    ; $C3B1: FD C0 C3  ; subtract cost hi byte
  .byte $90,$08                                       ; $C3B4: 90 08 (BCC mid-instruction target)
  STA ($20),Y                                         ; $C3B6: 91 20
  LDA $22                                             ; $C3B8: A5 22
  DEY                                                 ; $C3BA: 88
  STA ($20),Y                                         ; $C3BB: 91 20
  SEC                                                 ; $C3BD: 38
  RTS                                                 ; $C3BE: 60

; Action cost tables (16-bit LE, indexed by X = 0,2,4,...14)
; Each entry is a 16-bit cost value (lo,hi).
; Domestic: used by lower-5-bit path (indices 0–4, rest zero-padded)
ActionCostTable_Domestic:
  .word $0032,$0046,$0078,$00B4,$00FA              ; 50, 70, 120, 180, 250
  .word $0000,$0000,$0000                            ; padding (unused entries)
; Military: used by lower-5-bit path (indices 0–5)
ActionCostTable_Military:
  .word $003C,$0064,$0096,$00C8,$00F0,$0104         ; 60, 100, 150, 200, 240, 260
  .word $0000,$0090                                  ; padding
; Diplomacy-A: used by upper-3-bit path (indices 0–6)
ActionCostTable_DiplomacyA:
  .word $0050,$0064,$0078,$00C8,$00FA,$012C,$015E   ; 80, 100, 120, 200, 250, 300, 350
  .word $0190                                        ; padding
; Diplomacy-B: used by upper-3-bit path (indices 0–7)
ActionCostTable_DiplomacyB:
  .word $0032,$0050,$0064,$0096,$00C8,$00FA,$015E,$0190; 50, 80, 100, 150, 200, 250, 350, 400
.endproc
.endproc


;===============================================================================
; $C3FF: Proc_C3FF
;===============================================================================
.proc Proc_C3FF
  math_acc_lo              = $0020
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_sub_idx             = $0039
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C

  LDA #$11                                            ; $C3FF: A9 11
  STA a:$0037                                         ; $C401: 8D 37 00
  LDA #$FF                                            ; $C404: A9 FF
  STA a:$0038                                         ; $C406: 8D 38 00
  LDA #$00                                            ; $C409: A9 00
  STA a:$0039                                         ; $C40B: 8D 39 00
  LDA $6F5E                                           ; $C40E: AD 5E 6F
  JSR Proc_D105                                       ; $C411: 20 05 D1
  LDY a:$0037                                         ; $C414: AC 37 00
  LDA ($20),Y                                         ; $C417: B1 20
  CMP #$FF                                            ; $C419: C9 FF
  BEQ LC446                                           ; $C41B: F0 29
  STA a:$003B                                         ; $C41D: 8D 3B 00
  JSR $C451                                           ; $C420: 20 51 C4
  CMP #$FF                                            ; $C423: C9 FF
  BEQ LC446                                           ; $C425: F0 1F
  STA a:$003C                                         ; $C427: 8D 3C 00
  LDA a:$003B                                         ; $C42A: AD 3B 00
  LDY #$01                                            ; $C42D: A0 01
  JSR $D2AB                                           ; $C42F: 20 AB D2
  CMP a:$0039                                         ; $C432: CD 39 00
  BCC LC446                                           ; $C435: 90 0F
  STA a:$0039                                         ; $C437: 8D 39 00
  LDA a:$003B                                         ; $C43A: AD 3B 00
  STA a:$0038                                         ; $C43D: 8D 38 00
  LDA a:$003C                                         ; $C440: AD 3C 00
  STA a:$003A                                         ; $C443: 8D 3A 00
LC446:
  INC a:$0037                                         ; $C446: EE 37 00
  LDA a:$0037                                         ; $C449: AD 37 00
  CMP #$1B                                            ; $C44C: C9 1B
  .byte $90,$BE                                       ; $C44E: 90 BE (BCC mid-instruction target)
  RTS                                                 ; $C450: 60
  LDY #$0A                                            ; $C451: A0 0A
  JSR $D2AB                                           ; $C453: 20 AB D2
  STA $2A                                             ; $C456: 85 2A
  AND #$1F                                            ; $C458: 29 1F
  PHA                                                 ; $C45A: 48
  LDY #$00                                            ; $C45B: A0 00
  CMP #$08                                            ; $C45D: C9 08
  BCC LC469                                           ; $C45F: 90 08
  LDY #$04                                            ; $C461: A0 04
  CMP #$10                                            ; $C463: C9 10
  BCC LC469                                           ; $C465: 90 02
  LDY #$08                                            ; $C467: A0 08
LC469:
  STY $2B                                             ; $C469: 84 2B
  LDY $6F5E                                           ; $C46B: AC 5E 6F
  LDA $C4D0,Y                                         ; $C46E: B9 D0 C4
  ASL A                                               ; $C471: 0A
  ASL A                                               ; $C472: 0A
  ASL A                                               ; $C473: 0A
  ASL A                                               ; $C474: 0A
  CLC                                                 ; $C475: 18
  ADC $2B                                             ; $C476: 65 2B
  TAY                                                 ; $C478: A8
  PLA                                                 ; $C479: 68
  CMP $C4EE,Y                                         ; $C47A: D9 EE C4
  .byte $90,$15                                       ; $C47D: 90 15 (BCC mid-instruction target)
  INY                                                 ; $C47F: C8
  CMP $C4EE,Y                                         ; $C480: D9 EE C4
  .byte $90,$0F                                       ; $C483: 90 0F (BCC mid-instruction target)
  INY                                                 ; $C485: C8
  CMP $C4EE,Y                                         ; $C486: D9 EE C4
  .byte $90,$09                                       ; $C489: 90 09 (BCC mid-instruction target)
  INY                                                 ; $C48B: C8
  CMP $C4EE,Y                                         ; $C48C: D9 EE C4
  .byte $90,$03                                       ; $C48F: 90 03 (BCC mid-instruction target)
  JMP Proc_C498                                       ; $C491: 4C 98 C4
  LDA $C4EE,Y                                         ; $C494: B9 EE C4
  RTS                                                 ; $C497: 60
.endproc
LC446 = $C446
LC469 = $C469


;===============================================================================
; $C498: Proc_C498
;===============================================================================
.proc Proc_C498

  LDY $6F5E                                           ; $C498: AC 5E 6F
  LDA $C4D0,Y                                         ; $C49B: B9 D0 C4
  ASL A                                               ; $C49E: 0A
  ASL A                                               ; $C49F: 0A
  ASL A                                               ; $C4A0: 0A
  ASL A                                               ; $C4A1: 0A
  CLC                                                 ; $C4A2: 18
  ADC #$0C                                            ; $C4A3: 69 0C
  TAY                                                 ; $C4A5: A8
  LDA $2A                                             ; $C4A6: A5 2A
  LSR A                                               ; $C4A8: 4A
  LSR A                                               ; $C4A9: 4A
  LSR A                                               ; $C4AA: 4A
  LSR A                                               ; $C4AB: 4A
  LSR A                                               ; $C4AC: 4A
  CMP $C4EE,Y                                         ; $C4AD: D9 EE C4
  BCC LC4C7                                           ; $C4B0: 90 15
  INY                                                 ; $C4B2: C8
  CMP $C4EE,Y                                         ; $C4B3: D9 EE C4
  BCC LC4C7                                           ; $C4B6: 90 0F
  INY                                                 ; $C4B8: C8
  CMP $C4EE,Y                                         ; $C4B9: D9 EE C4
  BCC LC4C7                                           ; $C4BC: 90 09
  INY                                                 ; $C4BE: C8
  CMP $C4EE,Y                                         ; $C4BF: D9 EE C4
  BCC LC4C7                                           ; $C4C2: 90 03
  LDA #$FF                                            ; $C4C4: A9 FF
  RTS                                                 ; $C4C6: 60
LC4C7:
  LDA $C4EE,Y                                         ; $C4C7: B9 EE C4
  ASL A                                               ; $C4CA: 0A
  ASL A                                               ; $C4CB: 0A
  ASL A                                               ; $C4CC: 0A
  ASL A                                               ; $C4CD: 0A
  ASL A                                               ; $C4CE: 0A
  RTS                                                 ; $C4CF: 60
.endproc
LC4C7 = $C4C7


;===============================================================================
; $C4D0: Proc_C4D0
;===============================================================================
.proc Proc_C4D0

  BRK                                                 ; $C4D0: 00
  .byte $00,$00,$00,$01,$00,$00,$00,$01,$00,$00,$00,$01,$00,$00,$00,$00; $C4D1: 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 00
  .byte $00,$00,$00,$01,$00,$00,$00,$00,$01,$01,$00,$00,$01,$00,$01,$02; $C4E1: 00 00 00 01 00 00 00 00 01 01 00 00 01 00 01 02
  .byte $03,$08,$09,$0A,$0B,$10,$11,$12,$13,$00,$01,$02,$03,$01,$02,$03; $C4F1: 03 08 09 0A 0B 10 11 12 13 00 01 02 03 01 02 03
  .byte $04,$0A,$0B,$0C,$0D,$12,$13,$14,$15,$02,$03,$04,$05; $C501: 04 0A 0B 0C 0D 12 13 14 15 02 03 04 05
.endproc

;===============================================================================
; $C50E: Proc_C50E
;===============================================================================
.proc Proc_C50E
  math_acc_lo              = $0020
  work_outer_idx           = $0036
  work_limit_b             = $003B
  work_temp_0              = $003C
  work_temp_1              = $003D
  work_search_max          = $0045
  sram_player_id           = $6F03

  JSR Proc_D249                                       ; $C50E: 20 49 D2
  STA a:$0045                                         ; $C511: 8D 45 00
  LDA a:$0045                                         ; $C514: AD 45 00
  STA a:$0036                                         ; $C517: 8D 36 00
  JSR Proc_D1A4                                       ; $C51A: 20 A4 D1
  BNE LC520                                           ; $C51D: D0 01
  RTS                                                 ; $C51F: 60
LC520:
  LDA #$00                                            ; $C520: A9 00
  STA a:$003B                                         ; $C522: 8D 3B 00
  STA a:$003C                                         ; $C525: 8D 3C 00
  LDA #$FF                                            ; $C528: A9 FF
  STA a:$003D                                         ; $C52A: 8D 3D 00
  LDA a:$003B                                         ; $C52D: AD 3B 00
  STA a:$0036                                         ; $C530: 8D 36 00
  JSR Proc_D105                                       ; $C533: 20 05 D1
  AND #$07                                            ; $C536: 29 07
  CMP $6F03                                           ; $C538: CD 03 6F
  .byte $D0,$2A                                       ; $C53B: D0 2A (BNE mid-instruction target)
  JSR Proc_D1A4                                       ; $C53D: 20 A4 D1
  .byte $D0,$25                                       ; $C540: D0 25 (BNE mid-instruction target)
  LDX a:$0045                                         ; $C542: AE 45 00
  LDY a:$0036                                         ; $C545: AC 36 00
  JSR Proc_D583                                       ; $C548: 20 83 D5
  CMP #$FF                                            ; $C54B: C9 FF
  .byte $D0,$18                                       ; $C54D: D0 18 (BNE mid-instruction target)
  LDA a:$003B                                         ; $C54F: AD 3B 00
  JSR Proc_D304                                       ; $C552: 20 04 D3
  CMP a:$003C                                         ; $C555: CD 3C 00
  .byte $90,$0D                                       ; $C558: 90 0D (BCC mid-instruction target)
  CMP #$0A                                            ; $C55A: C9 0A
  .byte $F0,$09                                       ; $C55C: F0 09 (BEQ mid-instruction target)
  STA a:$003C                                         ; $C55E: 8D 3C 00
  LDA a:$003B                                         ; $C561: AD 3B 00
  STA a:$003D                                         ; $C564: 8D 3D 00
  INC a:$003B                                         ; $C567: EE 3B 00
  LDA a:$003B                                         ; $C56A: AD 3B 00
  CMP #$1E                                            ; $C56D: C9 1E
  .byte $90,$BC                                       ; $C56F: 90 BC (BCC mid-instruction target)
  LDA a:$003D                                         ; $C571: AD 3D 00
  CMP #$FF                                            ; $C574: C9 FF
  .byte $F0,$3D                                       ; $C576: F0 3D (BEQ mid-instruction target)
  LDA a:$0045                                         ; $C578: AD 45 00
  JSR Proc_D105                                       ; $C57B: 20 05 D1
  LDY #$00                                            ; $C57E: A0 00
  LDA ($EE),Y                                         ; $C580: B1 EE
  STA $2A                                             ; $C582: 85 2A
  LDY #$11                                            ; $C584: A0 11
  LDA ($20),Y                                         ; $C586: B1 20
  CMP $2A                                             ; $C588: C5 2A
  .byte $F0,$04                                       ; $C58A: F0 04 (BEQ mid-instruction target)
  INY                                                 ; $C58C: C8
  JMP $C586                                           ; $C58D: 4C 86 C5
  LDA #$FF                                            ; $C590: A9 FF
  STA ($20),Y                                         ; $C592: 91 20
  LDA a:$003D                                         ; $C594: AD 3D 00
  JSR Proc_D105                                       ; $C597: 20 05 D1
  LDY #$11                                            ; $C59A: A0 11
  LDA ($20),Y                                         ; $C59C: B1 20
  CMP #$FF                                            ; $C59E: C9 FF
  .byte $F0,$04                                       ; $C5A0: F0 04 (BEQ mid-instruction target)
  INY                                                 ; $C5A2: C8
  JMP $C59C                                           ; $C5A3: 4C 9C C5
  LDA $2A                                             ; $C5A6: A5 2A
  STA ($20),Y                                         ; $C5A8: 91 20
  LDA a:$0045                                         ; $C5AA: AD 45 00
  JSR Proc_D3DD                                       ; $C5AD: 20 DD D3
  LDA #$02                                            ; $C5B0: A9 02
  JSR Proc_D165                                       ; $C5B2: 20 65 D1
  JSR Proc_D249                                       ; $C5B5: 20 49 D2
  RTS                                                 ; $C5B8: 60
.endproc
LC520 = $C520


;===============================================================================
; $C5B9: Proc_C5B9
;===============================================================================
.proc Proc_C5B9
  work_outer_idx           = $0036

  LDA #$00                                            ; $C5B9: A9 00
  STA a:$0036                                         ; $C5BB: 8D 36 00
LC5BE:
  JSR Proc_C5D2                                       ; $C5BE: 20 D2 C5
  JSR $C6CC                                           ; $C5C1: 20 CC C6
  INC a:$0036                                         ; $C5C4: EE 36 00
  LDA a:$0036                                         ; $C5C7: AD 36 00
  CMP #$1E                                            ; $C5CA: C9 1E
  BCC LC5BE                                           ; $C5CC: 90 F0
  JSR Proc_D249                                       ; $C5CE: 20 49 D2
  RTS                                                 ; $C5D1: 60
.endproc
LC5BE = $C5BE


;===============================================================================
; $C5D2: Proc_C5D2
;===============================================================================
.proc Proc_C5D2
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  sram_player_id           = $6F03

  LDY #$31                                            ; $C5D2: A0 31
  JSR B1F_SwitchBank8_A                               ; $C5D4: 20 66 F2
  LDA a:$0036                                         ; $C5D7: AD 36 00
  JSR Proc_D105                                       ; $C5DA: 20 05 D1
  AND #$07                                            ; $C5DD: 29 07
  CMP $6F03                                           ; $C5DF: CD 03 6F
  .byte $D0,$09                                       ; $C5E2: D0 09 (BNE mid-instruction target)
  LDA #$64                                            ; $C5E4: A9 64
  JSR Proc_D4BB                                       ; $C5E6: 20 BB D4
  CMP #$0A                                            ; $C5E9: C9 0A
  BCC LC5EE                                           ; $C5EB: 90 01
  RTS                                                 ; $C5ED: 60
LC5EE:
  LDA a:$0036                                         ; $C5EE: AD 36 00
  JSR Proc_D304                                       ; $C5F1: 20 04 D3
  CMP #$0A                                            ; $C5F4: C9 0A
  .byte $B0,$F5                                       ; $C5F6: B0 F5 (BCS mid-instruction target)
  LDA a:$0036                                         ; $C5F8: AD 36 00
  STA $20                                             ; $C5FB: 85 20
  LDA #$14                                            ; $C5FD: A9 14
  STA $21                                             ; $C5FF: 85 21
  JSR Proc_D471                                       ; $C601: 20 71 D4
  LDA #$00                                            ; $C604: A9 00
  STA a:$0037                                         ; $C606: 8D 37 00
  LDA $2A                                             ; $C609: A5 2A
  CLC                                                 ; $C60B: 18
  ADC #$1C                                            ; $C60C: 69 1C
  STA $22                                             ; $C60E: 85 22
  LDA $2B                                             ; $C610: A5 2B
  ADC #$8B                                            ; $C612: 69 8B
  STA $23                                             ; $C614: 85 23
LC616:
  LDY a:$0037                                         ; $C616: AC 37 00
  INC a:$0037                                         ; $C619: EE 37 00
  INC a:$0037                                         ; $C61C: EE 37 00
  LDA ($22),Y                                         ; $C61F: B1 22
  STA $24                                             ; $C621: 85 24
  INY                                                 ; $C623: C8
  LDA ($22),Y                                         ; $C624: B1 22
  SEC                                                 ; $C626: 38
  SBC #$64                                            ; $C627: E9 64
  STA $20                                             ; $C629: 85 20
  LDA $6F00                                           ; $C62B: AD 00 6F
  CMP $20                                             ; $C62E: C5 20
  .byte $90,$3C                                       ; $C630: 90 3C (BCC mid-instruction target)
  LDA $24                                             ; $C632: A5 24
  LDY #$0B                                            ; $C634: A0 0B
  JSR Proc_D283                                       ; $C636: 20 83 D2
  AND #$03                                            ; $C639: 29 03
  CMP #$01                                            ; $C63B: C9 01
  BNE LC616                                           ; $C63D: D0 D7
  LDA $24                                             ; $C63F: A5 24
  JSR $C66F                                           ; $C641: 20 6F C6
  STA $2A                                             ; $C644: 85 2A
LC646:
  JSR B1F_RandomByte3                                 ; $C646: 20 9A E8
  CMP #$64                                            ; $C649: C9 64
  BCS LC646                                           ; $C64B: B0 F9
  CMP $2A                                             ; $C64D: C5 2A
  BCS LC616                                           ; $C64F: B0 C5
  LDY #$0B                                            ; $C651: A0 0B
  LDA ($20),Y                                         ; $C653: B1 20
  AND #$FC                                            ; $C655: 29 FC
  ORA #$02                                            ; $C657: 09 02
  STA ($20),Y                                         ; $C659: 91 20
  LDA a:$0036                                         ; $C65B: AD 36 00
  JSR Proc_D105                                       ; $C65E: 20 05 D1
  LDY #$10                                            ; $C661: A0 10
  INY                                                 ; $C663: C8
  LDA ($20),Y                                         ; $C664: B1 20
  CMP #$FF                                            ; $C666: C9 FF
  .byte $D0,$F9                                       ; $C668: D0 F9 (BNE mid-instruction target)
  LDA $24                                             ; $C66A: A5 24
  STA ($20),Y                                         ; $C66C: 91 20
  RTS                                                 ; $C66E: 60
  LDY $6F03                                           ; $C66F: AC 03 6F
  CPY #$04                                            ; $C672: C0 04
  .byte $D0,$1A                                       ; $C674: D0 1A (BNE cross-proc)
  CMP #$6D                                            ; $C676: C9 6D
  .byte $F0,$13                                       ; $C678: F0 13 (BEQ cross-proc)
  CMP #$70                                            ; $C67A: C9 70
  .byte $F0,$0F                                       ; $C67C: F0 0F (BEQ cross-proc)
  CMP #$37                                            ; $C67E: C9 37
  .byte $F0,$0B                                       ; $C680: F0 0B (BEQ cross-proc)
  CMP #$B7                                            ; $C682: C9 B7
  .byte $F0,$07                                       ; $C684: F0 07 (BEQ cross-proc)
  CMP #$90                                            ; $C686: C9 90
  .byte $F0,$03                                       ; $C688: F0 03 (BEQ cross-proc)
.endproc
LC5EE = $C5EE
LC616 = $C616
LC646 = $C646


;===============================================================================
; $C68A: Proc_C68A
;===============================================================================
.proc Proc_C68A
  math_acc_lo              = $0020
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  sram_kingdom_index       = $6F02
  sram_player_id           = $6F03

  LDA #$0A                                            ; $C68A: A9 0A
  RTS                                                 ; $C68C: 60
LC68D:
  LDA #$5A                                            ; $C68D: A9 5A
  RTS                                                 ; $C68F: 60
LC690:
  LDY $6F03                                           ; $C690: AC 03 6F
  CPY #$02                                            ; $C693: C0 02
  .byte $D0,$17                                       ; $C695: D0 17 (BNE mid-instruction target)
  CMP #$56                                            ; $C697: C9 56
  BEQ LC68D                                           ; $C699: F0 F2
  CMP #$63                                            ; $C69B: C9 63
  BEQ LC68D                                           ; $C69D: F0 EE
  CMP #$39                                            ; $C69F: C9 39
  BEQ LC68D                                           ; $C6A1: F0 EA
  CMP #$A5                                            ; $C6A3: C9 A5
  BEQ LC68D                                           ; $C6A5: F0 E6
  CMP #$9C                                            ; $C6A7: C9 9C
  BEQ LC68D                                           ; $C6A9: F0 E2
  JMP Proc_C68A                                       ; $C6AB: 4C 8A C6
  LDY $6F03                                           ; $C6AE: AC 03 6F
  CPY #$03                                            ; $C6B1: C0 03
  BNE Proc_C68A                                       ; $C6B3: D0 D5
  CMP #$6B                                            ; $C6B5: C9 6B
  BEQ LC68D                                           ; $C6B7: F0 D4
  CMP #$EA                                            ; $C6B9: C9 EA
  BEQ LC68D                                           ; $C6BB: F0 D0
  CMP #$EB                                            ; $C6BD: C9 EB
  BEQ LC68D                                           ; $C6BF: F0 CC
  CMP #$D5                                            ; $C6C1: C9 D5
  BEQ LC68D                                           ; $C6C3: F0 C8
  CMP #$2F                                            ; $C6C5: C9 2F
  BEQ LC68D                                           ; $C6C7: F0 C4
  JMP Proc_C68A                                       ; $C6C9: 4C 8A C6
  LDA a:$0036                                         ; $C6CC: AD 36 00
  JSR Proc_D105                                       ; $C6CF: 20 05 D1
  AND #$07                                            ; $C6D2: 29 07
  CMP $6F03                                           ; $C6D4: CD 03 6F
  BEQ LC6DA                                           ; $C6D7: F0 01
  RTS                                                 ; $C6D9: 60
LC6DA:
  LDA #$64                                            ; $C6DA: A9 64
  JSR Proc_D4BB                                       ; $C6DC: 20 BB D4
  LDY $6F02                                           ; $C6DF: AC 02 6F
  CMP $C795,Y                                         ; $C6E2: D9 95 C7
  .byte $B0,$F2                                       ; $C6E5: B0 F2 (BCS mid-instruction target)
  LDA a:$0036                                         ; $C6E7: AD 36 00
  JSR Proc_D304                                       ; $C6EA: 20 04 D3
  CMP #$0A                                            ; $C6ED: C9 0A
  .byte $B0,$E8                                       ; $C6EF: B0 E8 (BCS mid-instruction target)
  LDA #$00                                            ; $C6F1: A9 00
  STA a:$0037                                         ; $C6F3: 8D 37 00
  LDY #$30                                            ; $C6F6: A0 30
  JSR B1F_SwitchBank8_A                               ; $C6F8: 20 66 F2
  LDY #$0F                                            ; $C6FB: A0 0F
  LDA #$FF                                            ; $C6FD: A9 FF
LC6FF:
  STA $6F73,Y                                         ; $C6FF: 99 73 6F
  DEY                                                 ; $C702: 88
  BPL LC6FF                                           ; $C703: 10 FA
  LDA a:$0036                                         ; $C705: AD 36 00
  ASL A                                               ; $C708: 0A
  ASL A                                               ; $C709: 0A
  ASL A                                               ; $C70A: 0A
  TAY                                                 ; $C70B: A8
  LDX #$00                                            ; $C70C: A2 00
LC70E:
  LDA $9D72,Y                                         ; $C70E: B9 72 9D
  STA $6F73,X                                         ; $C711: 9D 73 6F
  INY                                                 ; $C714: C8
  INX                                                 ; $C715: E8
  CPX #$08                                            ; $C716: E0 08
  BCC LC70E                                           ; $C718: 90 F4
  LDA #$C0                                            ; $C71A: A9 C0
  STA $22                                             ; $C71C: 85 22
  LDA #$63                                            ; $C71E: A9 63
  STA $23                                             ; $C720: 85 23
  LDX #$00                                            ; $C722: A2 00
LC724:
  LDY #$0B                                            ; $C724: A0 0B
  LDA ($22),Y                                         ; $C726: B1 22
  AND #$03                                            ; $C728: 29 03
  .byte $D0,$26                                       ; $C72A: D0 26 (BNE mid-instruction target)
  TXA                                                 ; $C72C: 8A
  JSR $C66F                                           ; $C72D: 20 6F C6
  STA $2A                                             ; $C730: 85 2A
LC732:
  JSR B1F_RandomByte3                                 ; $C732: 20 9A E8
  CMP #$64                                            ; $C735: C9 64
  BCS LC732                                           ; $C737: B0 F9
  CMP $2A                                             ; $C739: C5 2A
  .byte $B0,$15                                       ; $C73B: B0 15 (BCS mid-instruction target)
  LDY #$05                                            ; $C73D: A0 05
  LDA ($22),Y                                         ; $C73F: B1 22
  CMP a:$0036                                         ; $C741: CD 36 00
  BEQ LC765                                           ; $C744: F0 1F
  LDY #$00                                            ; $C746: A0 00
LC748:
  CMP $6F73,Y                                         ; $C748: D9 73 6F
  BEQ LC765                                           ; $C74B: F0 18
  INY                                                 ; $C74D: C8
  CPY #$08                                            ; $C74E: C0 08
  BCC LC748                                           ; $C750: 90 F6
  LDA $22                                             ; $C752: A5 22
  CLC                                                 ; $C754: 18
  ADC #$0C                                            ; $C755: 69 0C
  STA $22                                             ; $C757: 85 22
  LDA $23                                             ; $C759: A5 23
  ADC #$00                                            ; $C75B: 69 00
  STA $23                                             ; $C75D: 85 23
  INX                                                 ; $C75F: E8
  CPX #$ED                                            ; $C760: E0 ED
  BCC LC724                                           ; $C762: 90 C0
  RTS                                                 ; $C764: 60
LC765:
  LDY #$0B                                            ; $C765: A0 0B
  LDA ($22),Y                                         ; $C767: B1 22
  AND #$FC                                            ; $C769: 29 FC
  ORA #$02                                            ; $C76B: 09 02
  STA ($22),Y                                         ; $C76D: 91 22
  LDA a:$0036                                         ; $C76F: AD 36 00
  JSR Proc_D105                                       ; $C772: 20 05 D1
  LDY #$10                                            ; $C775: A0 10
  INY                                                 ; $C777: C8
  LDA ($20),Y                                         ; $C778: B1 20
  CMP #$FF                                            ; $C77A: C9 FF
  .byte $D0,$F9                                       ; $C77C: D0 F9 (BNE mid-instruction target)
  TXA                                                 ; $C77E: 8A
  STA ($20),Y                                         ; $C77F: 91 20
  STA $31                                             ; $C781: 85 31
  LDA $6F03                                           ; $C783: AD 03 6F
  JSR Proc_D319                                       ; $C786: 20 19 D3
  LDY #$00                                            ; $C789: A0 00
  LDA ($24),Y                                         ; $C78B: B1 24
  STA $30                                             ; $C78D: 85 30
  JSR ArmyValueCalc                               ; $C78F: 20 3F CF
  PLA                                                 ; $C792: 68
  PLA                                                 ; $C793: 68
  RTS                                                 ; $C794: 60
.endproc
LC68D = $C68D
LC690 = $C690
LC6DA = $C6DA
LC6FF = $C6FF
LC70E = $C70E
LC724 = $C724
LC732 = $C732
LC748 = $C748
LC765 = $C765


;===============================================================================
; $C795: Proc_C795
;===============================================================================
.proc Proc_C795

  ASL A                                               ; $C795: 0A
  ASL A                                               ; $C796: 0A
  ASL A                                               ; $C797: 0A
  ASL A                                               ; $C798: 0A
  ASL A                                               ; $C799: 0A
.endproc

;===============================================================================
; $C79A: Proc_C79A
;===============================================================================
.proc Proc_C79A
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  work_outer_idx           = $0036
  state_sub_dispatch       = $0540
  sram_player_id           = $6F03

  LDY #$FF                                            ; $C79A: A0 FF
  STY a:$0036                                         ; $C79C: 8C 36 00
LC79F:
  INC a:$0036                                         ; $C79F: EE 36 00
  LDA a:$0036                                         ; $C7A2: AD 36 00
  CMP #$1E                                            ; $C7A5: C9 1E
  BCC LC7AA                                           ; $C7A7: 90 01
  RTS                                                 ; $C7A9: 60
LC7AA:
  LDA a:$0036                                         ; $C7AA: AD 36 00
  JSR Proc_D105                                       ; $C7AD: 20 05 D1
  AND #$07                                            ; $C7B0: 29 07
  CMP $6F03                                           ; $C7B2: CD 03 6F
  BNE LC79F                                           ; $C7B5: D0 E8
  LDY #$0F                                            ; $C7B7: A0 0F
  LDA #$FF                                            ; $C7B9: A9 FF
LC7BB:
  STA $0540,Y                                         ; $C7BB: 99 40 05
  DEY                                                 ; $C7BE: 88
  BPL LC7BB                                           ; $C7BF: 10 FA
LC7C1:
  JSR Proc_C917                                       ; $C7C1: 20 17 C9
  LDA $22                                             ; $C7C4: A5 22
  BNE LC79F                                           ; $C7C6: D0 D7
  LDA $2B                                             ; $C7C8: A5 2B
  CMP #$02                                            ; $C7CA: C9 02
  BCC LC79F                                           ; $C7CC: 90 D1
  JSR B1F_RandomByte2                                 ; $C7CE: 20 8A E8
  CMP $21                                             ; $C7D1: C5 21
  BCC LC7C1                                           ; $C7D3: 90 EC
  LDA #$14                                            ; $C7D5: A9 14
  STA $22                                             ; $C7D7: 85 22
  LDA #$00                                            ; $C7D9: A9 00
  STA $23                                             ; $C7DB: 85 23
  LDA #$00                                            ; $C7DD: A9 00
  STA $24                                             ; $C7DF: 85 24
  LDA a:$0036                                         ; $C7E1: AD 36 00
  JSR Proc_D36F                                       ; $C7E4: 20 6F D3
  BCC LC7FE                                           ; $C7E7: 90 15
  LDY #$30                                            ; $C7E9: A0 30
  JSR B1F_SwitchBank8_A                               ; $C7EB: 20 66 F2
  LDY a:$0036                                         ; $C7EE: AC 36 00
  LDA $8FFC,Y                                         ; $C7F1: B9 FC 8F
  AND #$08                                            ; $C7F4: 29 08
  BNE LC7FF                                           ; $C7F6: D0 07
  JSR Proc_C80A                                       ; $C7F8: 20 0A C8
  JMP LC7C1                                           ; $C7FB: 4C C1 C7
LC7FE:
  RTS                                                 ; $C7FE: 60
LC7FF:
  JSR Proc_C97A                                       ; $C7FF: 20 7A C9
  LDA #$05                                            ; $C802: A9 05
  JSR Proc_D165                                       ; $C804: 20 65 D1
  JMP LC7C1                                           ; $C807: 4C C1 C7
.endproc
LC79F = $C79F
LC7AA = $C7AA
LC7BB = $C7BB
LC7C1 = $C7C1
LC7FE = $C7FE
LC7FF = $C7FF


;===============================================================================
; $C80A: Proc_C80A
;===============================================================================
.proc Proc_C80A
  math_ext                 = $0024
  work_outer_idx           = $0036

  LDY #$0F                                            ; $C80A: A0 0F
  LDA #$FF                                            ; $C80C: A9 FF
LC80E:
  STA $6F73,Y                                         ; $C80E: 99 73 6F
  DEY                                                 ; $C811: 88
  BPL LC80E                                           ; $C812: 10 FA
  LDY #$30                                            ; $C814: A0 30
  JSR B1F_SwitchBank8_A                               ; $C816: 20 66 F2
  LDA a:$0036                                         ; $C819: AD 36 00
  ASL A                                               ; $C81C: 0A
  ASL A                                               ; $C81D: 0A
  ASL A                                               ; $C81E: 0A
  STA $24                                             ; $C81F: 85 24
  LDA #$08                                            ; $C821: A9 08
  JSR Proc_D4AD                                       ; $C823: 20 AD D4
  TAY                                                 ; $C826: A8
  LDA $6F73,Y                                         ; $C827: B9 73 6F
  .byte $F0,$12                                       ; $C82A: F0 12 (BEQ mid-instruction target)
  LDA #$00                                            ; $C82C: A9 00
  STA $6F73,Y                                         ; $C82E: 99 73 6F
  TYA                                                 ; $C831: 98
  CLC                                                 ; $C832: 18
  ADC $24                                             ; $C833: 65 24
  TAY                                                 ; $C835: A8
  LDA $9D72,Y                                         ; $C836: B9 72 9D
  .byte $30,$03                                       ; $C839: 30 03 (BMI mid-instruction target)
  JSR Proc_C84D                                       ; $C83B: 20 4D C8
  LDX #$00                                            ; $C83E: A2 00
LC840:
  LDA $6F73,X                                         ; $C840: BD 73 6F
  CMP #$FF                                            ; $C843: C9 FF
  .byte $F0,$DA                                       ; $C845: F0 DA (BEQ mid-instruction target)
  INX                                                 ; $C847: E8
  CPX #$08                                            ; $C848: E0 08
  BCC LC840                                           ; $C84A: 90 F4
  RTS                                                 ; $C84C: 60
.endproc
LC80E = $C80E
LC840 = $C840


;===============================================================================
; $C84D: Proc_C84D
;===============================================================================
.proc Proc_C84D
  work_inner_idx           = $0037
  sram_player_id           = $6F03

  STA a:$0037                                         ; $C84D: 8D 37 00
  JSR Proc_D105                                       ; $C850: 20 05 D1
  CMP $6F03                                           ; $C853: CD 03 6F
  BNE LC869                                           ; $C856: D0 11
  LDA a:$0037                                         ; $C858: AD 37 00
  JSR Proc_C86A                                       ; $C85B: 20 6A C8
  BCC LC865                                           ; $C85E: 90 05
  PLA                                                 ; $C860: 68
  PLA                                                 ; $C861: 68
  JMP Proc_C8E6                                       ; $C862: 4C E6 C8
LC865:
  JSR Proc_C885                                       ; $C865: 20 85 C8
  RTS                                                 ; $C868: 60
LC869:
  RTS                                                 ; $C869: 60
.endproc
LC865 = $C865
LC869 = $C869


;===============================================================================
; $C86A: Proc_C86A
;===============================================================================
.proc Proc_C86A

  PHA                                                 ; $C86A: 48
  LDY #$30                                            ; $C86B: A0 30
  JSR B1F_SwitchBank8_A                               ; $C86D: 20 66 F2
  PLA                                                 ; $C870: 68
  TAY                                                 ; $C871: A8
  LDA $8FFC,Y                                         ; $C872: B9 FC 8F
  AND #$08                                            ; $C875: 29 08
  BEQ LC883                                           ; $C877: F0 0A
  TYA                                                 ; $C879: 98
  JSR Proc_D304                                       ; $C87A: 20 04 D3
  CMP #$0A                                            ; $C87D: C9 0A
  BCS LC883                                           ; $C87F: B0 02
  SEC                                                 ; $C881: 38
  RTS                                                 ; $C882: 60
LC883:
  CLC                                                 ; $C883: 18
  RTS                                                 ; $C884: 60
.endproc
LC883 = $C883


;===============================================================================
; $C885: Proc_C885
;===============================================================================
.proc Proc_C885
  work_inner_idx           = $0037

  LDY #$08                                            ; $C885: A0 08
  LDA #$FF                                            ; $C887: A9 FF
LC889:
  STA $6F7B,Y                                         ; $C889: 99 7B 6F
  DEY                                                 ; $C88C: 88
  BPL LC889                                           ; $C88D: 10 FA
  LDA a:$0037                                         ; $C88F: AD 37 00
  ASL A                                               ; $C892: 0A
  ASL A                                               ; $C893: 0A
  ASL A                                               ; $C894: 0A
  STA $28                                             ; $C895: 85 28
LC897:
  LDA #$08                                            ; $C897: A9 08
  JSR Proc_D4AD                                       ; $C899: 20 AD D4
  TAY                                                 ; $C89C: A8
  LDA $6F7B,Y                                         ; $C89D: B9 7B 6F
  BEQ LC897                                           ; $C8A0: F0 F5
  LDA #$00                                            ; $C8A2: A9 00
  STA $6F7B,Y                                         ; $C8A4: 99 7B 6F
  TYA                                                 ; $C8A7: 98
  CLC                                                 ; $C8A8: 18
  ADC $28                                             ; $C8A9: 65 28
  TAY                                                 ; $C8AB: A8
  LDA $9D72,Y                                         ; $C8AC: B9 72 9D
  BMI LC8B4                                           ; $C8AF: 30 03
  JSR Proc_C8C3                                       ; $C8B1: 20 C3 C8
LC8B4:
  LDX #$00                                            ; $C8B4: A2 00
LC8B6:
  LDA $6F7B,X                                         ; $C8B6: BD 7B 6F
  CMP #$FF                                            ; $C8B9: C9 FF
  BEQ LC897                                           ; $C8BB: F0 DA
  INX                                                 ; $C8BD: E8
  CPX #$08                                            ; $C8BE: E0 08
  BCC LC8B6                                           ; $C8C0: 90 F4
  RTS                                                 ; $C8C2: 60
.endproc
LC889 = $C889
LC897 = $C897
LC8B4 = $C8B4
LC8B6 = $C8B6


;===============================================================================
; $C8C3: Proc_C8C3
;===============================================================================
.proc Proc_C8C3
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  sram_player_id           = $6F03

  STA a:$0038                                         ; $C8C3: 8D 38 00
  JSR Proc_D105                                       ; $C8C6: 20 05 D1
  CMP $6F03                                           ; $C8C9: CD 03 6F
  BNE LC8E5                                           ; $C8CC: D0 17
  LDA a:$0038                                         ; $C8CE: AD 38 00
  JSR Proc_C86A                                       ; $C8D1: 20 6A C8
  BCC LC8E5                                           ; $C8D4: 90 0F
  PLA                                                 ; $C8D6: 68
  PLA                                                 ; $C8D7: 68
  PLA                                                 ; $C8D8: 68
  PLA                                                 ; $C8D9: 68
  PLA                                                 ; $C8DA: 68
  PLA                                                 ; $C8DB: 68
  LDA a:$0038                                         ; $C8DC: AD 38 00
  STA a:$0037                                         ; $C8DF: 8D 37 00
  JMP Proc_C8E6                                       ; $C8E2: 4C E6 C8
LC8E5:
  RTS                                                 ; $C8E5: 60
.endproc
LC8E5 = $C8E5


;===============================================================================
; $C8E6: Proc_C8E6
;===============================================================================
.proc Proc_C8E6
  math_acc_lo              = $0020
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  work_sub_idx             = $0039

  LDA a:$0036                                         ; $C8E6: AD 36 00
  JSR Proc_D105                                       ; $C8E9: 20 05 D1
  LDY #$10                                            ; $C8EC: A0 10
  INY                                                 ; $C8EE: C8
  LDA ($20),Y                                         ; $C8EF: B1 20
  CMP a:$0039                                         ; $C8F1: CD 39 00
  .byte $D0,$F8                                       ; $C8F4: D0 F8 (BNE mid-instruction target)
  LDA #$FF                                            ; $C8F6: A9 FF
  STA ($20),Y                                         ; $C8F8: 91 20
  LDA a:$0037                                         ; $C8FA: AD 37 00
  JSR Proc_D105                                       ; $C8FD: 20 05 D1
  LDY #$10                                            ; $C900: A0 10
  INY                                                 ; $C902: C8
  LDA ($20),Y                                         ; $C903: B1 20
  CMP #$FF                                            ; $C905: C9 FF
  .byte $D0,$F9                                       ; $C907: D0 F9 (BNE mid-instruction target)
  LDA a:$0039                                         ; $C909: AD 39 00
  STA ($20),Y                                         ; $C90C: 91 20
  LDA a:$0036                                         ; $C90E: AD 36 00
  JSR Proc_D3DD                                       ; $C911: 20 DD D3
  JMP LC7FF                                           ; $C914: 4C FF C7
.endproc

;===============================================================================
; $C917: Proc_C917
;===============================================================================
.proc Proc_C917
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  work_outer_idx           = $0036
  work_sub_idx             = $0039

  LDA a:$0036                                         ; $C917: AD 36 00
  JSR Proc_D105                                       ; $C91A: 20 05 D1
  LDA #$11                                            ; $C91D: A9 11
  STA $28                                             ; $C91F: 85 28
  LDA #$FF                                            ; $C921: A9 FF
  STA $29                                             ; $C923: 85 29
  STA $2A                                             ; $C925: 85 2A
  LDA #$00                                            ; $C927: A9 00
  STA $2B                                             ; $C929: 85 2B
LC92B:
  LDY $28                                             ; $C92B: A4 28
  LDA $052F,Y                                         ; $C92D: B9 2F 05
  BEQ LC949                                           ; $C930: F0 17
  LDA ($20),Y                                         ; $C932: B1 20
  CMP #$FF                                            ; $C934: C9 FF
  BEQ LC949                                           ; $C936: F0 11
  INC $2B                                             ; $C938: E6 2B
  LDY #$00                                            ; $C93A: A0 00
  JSR $D2AB                                           ; $C93C: 20 AB D2
  CMP $29                                             ; $C93F: C5 29
  BCS LC949                                           ; $C941: B0 06
  STA $29                                             ; $C943: 85 29
  LDA $28                                             ; $C945: A5 28
  STA $2A                                             ; $C947: 85 2A
LC949:
  INC $28                                             ; $C949: E6 28
  LDY $28                                             ; $C94B: A4 28
  CPY #$1B                                            ; $C94D: C0 1B
  BCC LC92B                                           ; $C94F: 90 DA
  LDY $2A                                             ; $C951: A4 2A
  LDA #$00                                            ; $C953: A9 00
  STA $052F,Y                                         ; $C955: 99 2F 05
  LDA ($20),Y                                         ; $C958: B1 20
  STA a:$0039                                         ; $C95A: 8D 39 00
  LDY #$00                                            ; $C95D: A0 00
  JSR Proc_D2D3                                       ; $C95F: 20 D3 D2
  PHA                                                 ; $C962: 48
  LDA a:$0039                                         ; $C963: AD 39 00
  LDY #$00                                            ; $C966: A0 00
  JSR $D2AB                                           ; $C968: 20 AB D2
  STA $22                                             ; $C96B: 85 22
  PLA                                                 ; $C96D: 68
  STA $23                                             ; $C96E: 85 23
  LDA #$00                                            ; $C970: A9 00
  STA $21                                             ; $C972: 85 21
  STA $24                                             ; $C974: 85 24
  JSR Proc_D40F                                       ; $C976: 20 0F D4
  RTS                                                 ; $C979: 60
.endproc
LC92B = $C92B
LC949 = $C949


;===============================================================================
; $C97A: Proc_C97A
;===============================================================================
.proc Proc_C97A
  math_acc_mhi             = $0022
  work_sub_idx             = $0039

  LDA a:$0039                                         ; $C97A: AD 39 00
  LDY #$00                                            ; $C97D: A0 00
  JSR Proc_D2D3                                       ; $C97F: 20 D3 D2
  PHA                                                 ; $C982: 48
  LDA a:$0039                                         ; $C983: AD 39 00
  LDY #$00                                            ; $C986: A0 00
  JSR $D2AB                                           ; $C988: 20 AB D2
  PLA                                                 ; $C98B: 68
  STA ($22),Y                                         ; $C98C: 91 22
  RTS                                                 ; $C98E: 60
.endproc

;===============================================================================
; $C98F: Proc_C98F
;===============================================================================
.proc Proc_C98F
  work_outer_idx           = $0036
  work_inner_idx           = $0037

  STA a:$0037                                         ; $C98F: 8D 37 00
  LDA #$00                                            ; $C992: A9 00
  STA a:$0036                                         ; $C994: 8D 36 00
LC997:
  JSR Proc_C9A5                                       ; $C997: 20 A5 C9
  INC a:$0036                                         ; $C99A: EE 36 00
  LDA a:$0036                                         ; $C99D: AD 36 00
  CMP #$1E                                            ; $C9A0: C9 1E
  BCC LC997                                           ; $C9A2: 90 F3
LC9A4:
  RTS                                                 ; $C9A4: 60
.endproc
LC997 = $C997
LC9A4 = $C9A4


;===============================================================================
; $C9A5: Proc_C9A5
;===============================================================================
.proc Proc_C9A5
  math_acc_lo              = $0020
  math_acc_mhi             = $0022
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  work_limit_a             = $003A
  work_limit_b             = $003B
  work_temp_0              = $003C

  LDA a:$0036                                         ; $C9A5: AD 36 00
  JSR Proc_D105                                       ; $C9A8: 20 05 D1
  AND #$07                                            ; $C9AB: 29 07
  CMP a:$0037                                         ; $C9AD: CD 37 00
  .byte $D0,$F2                                       ; $C9B0: D0 F2 (BNE cross-proc)
  LDA #$11                                            ; $C9B2: A9 11
  STA a:$003A                                         ; $C9B4: 8D 3A 00
  LDA #$00                                            ; $C9B7: A9 00
  STA a:$003B                                         ; $C9B9: 8D 3B 00
  LDA #$FF                                            ; $C9BC: A9 FF
  STA a:$003C                                         ; $C9BE: 8D 3C 00
LC9C1:
  LDY a:$003A                                         ; $C9C1: AC 3A 00
  LDA ($20),Y                                         ; $C9C4: B1 20
  CMP #$FF                                            ; $C9C6: C9 FF
  BEQ LC9EF                                           ; $C9C8: F0 25
  LDY #$03                                            ; $C9CA: A0 03
  JSR $D2AB                                           ; $C9CC: 20 AB D2
  CMP #$64                                            ; $C9CF: C9 64
  .byte $D0,$09                                       ; $C9D1: D0 09 (BNE mid-instruction target)
  LDA a:$003A                                         ; $C9D3: AD 3A 00
  STA a:$003C                                         ; $C9D6: 8D 3C 00
  JMP Proc_C9F9                                       ; $C9D9: 4C F9 C9
  LDY #$04                                            ; $C9DC: A0 04
  CLC                                                 ; $C9DE: 18
  ADC ($22),Y                                         ; $C9DF: 71 22
  CMP a:$003B                                         ; $C9E1: CD 3B 00
  BCC LC9EF                                           ; $C9E4: 90 09
  STA a:$003B                                         ; $C9E6: 8D 3B 00
  LDA a:$003A                                         ; $C9E9: AD 3A 00
  STA a:$003C                                         ; $C9EC: 8D 3C 00
LC9EF:
  INC a:$003A                                         ; $C9EF: EE 3A 00
  LDA a:$003A                                         ; $C9F2: AD 3A 00
  CMP #$1B                                            ; $C9F5: C9 1B
  BCC LC9C1                                           ; $C9F7: 90 C8
.endproc
LC9C1 = $C9C1
LC9EF = $C9EF


;===============================================================================
; $C9F9: Proc_C9F9
;===============================================================================
.proc Proc_C9F9
  math_acc_lo              = $0020
  math_acc_mhi             = $0022
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026
  math_temp3               = $0027
  work_inner_idx2          = $0038
  work_temp_0              = $003C
  work_record_val          = $0040
  sram_game_start_flag     = $6F8B

  LDA a:$003C                                         ; $C9F9: AD 3C 00
  CMP #$FF                                            ; $C9FC: C9 FF
  .byte $F0,$18                                       ; $C9FE: F0 18 (BEQ mid-instruction target)
  CMP #$11                                            ; $CA00: C9 11
  .byte $F0,$14                                       ; $CA02: F0 14 (BEQ mid-instruction target)
  LDY #$11                                            ; $CA04: A0 11
  LDA ($20),Y                                         ; $CA06: B1 20
  PHA                                                 ; $CA08: 48
  LDY a:$003C                                         ; $CA09: AC 3C 00
  LDA ($20),Y                                         ; $CA0C: B1 20
  LDY #$11                                            ; $CA0E: A0 11
  STA ($20),Y                                         ; $CA10: 91 20
  PLA                                                 ; $CA12: 68
  LDY a:$003C                                         ; $CA13: AC 3C 00
  STA ($20),Y                                         ; $CA16: 91 20
  RTS                                                 ; $CA18: 60
  LDA #$00                                            ; $CA19: A9 00
  STA a:$0040                                         ; $CA1B: 8D 40 00
LCA1E:
  LDA a:$0040                                         ; $CA1E: AD 40 00
  JSR Proc_D319                                       ; $CA21: 20 19 D3
  LDY #$00                                            ; $CA24: A0 00
  LDA ($24),Y                                         ; $CA26: B1 24
  CMP #$FF                                            ; $CA28: C9 FF
  .byte $F0,$2C                                       ; $CA2A: F0 2C (BEQ mid-instruction target)
  STA a:$0038                                         ; $CA2C: 8D 38 00
  LDY #$03                                            ; $CA2F: A0 03
  LDA ($24),Y                                         ; $CA31: B1 24
  CMP #$03                                            ; $CA33: C9 03
  .byte $D0,$21                                       ; $CA35: D0 21 (BNE mid-instruction target)
  LDA a:$0038                                         ; $CA37: AD 38 00
  LDY #$0B                                            ; $CA3A: A0 0B
  JSR $D2AB                                           ; $CA3C: 20 AB D2
  AND #$03                                            ; $CA3F: 29 03
  CMP #$02                                            ; $CA41: C9 02
  BEQ LCA52                                           ; $CA43: F0 0D
  LDY #$0B                                            ; $CA45: A0 0B
  LDA ($22),Y                                         ; $CA47: B1 22
  AND #$FC                                            ; $CA49: 29 FC
  ORA #$03                                            ; $CA4B: 09 03
  STA ($22),Y                                         ; $CA4D: 91 22
  JSR $CA68                                           ; $CA4F: 20 68 CA
LCA52:
  LDA a:$0040                                         ; $CA52: AD 40 00
  JSR Proc_C98F                                       ; $CA55: 20 8F C9
  INC a:$0040                                         ; $CA58: EE 40 00
  LDA a:$0040                                         ; $CA5B: AD 40 00
  CMP #$07                                            ; $CA5E: C9 07
  BCC LCA1E                                           ; $CA60: 90 BC
  JSR Proc_D249                                       ; $CA62: 20 49 D2
  JMP $BEC7                                           ; $CA65: 4C C7 BE
  JSR $CA87                                           ; $CA68: 20 87 CA
  JSR Proc_CB05                                       ; $CA6B: 20 05 CB
  LDA a:$0040                                         ; $CA6E: AD 40 00
  JSR Proc_D319                                       ; $CA71: 20 19 D3
  LDY #$00                                            ; $CA74: A0 00
  LDA #$FF                                            ; $CA76: A9 FF
  STA ($24),Y                                         ; $CA78: 91 24
  LDA #$FB                                            ; $CA7A: A9 FB
  STA $6F8B                                           ; $CA7C: 8D 8B 6F
LCA7F:
  LDA $6F8B                                           ; $CA7F: AD 8B 6F
  CMP #$01                                            ; $CA82: C9 01
  BNE LCA7F                                           ; $CA84: D0 F9
  RTS                                                 ; $CA86: 60
  LDA a:$0040                                         ; $CA87: AD 40 00
  ASL A                                               ; $CA8A: 0A
  TAY                                                 ; $CA8B: A8
  LDA $CAD8,Y                                         ; $CA8C: B9 D8 CA
  STA $24                                             ; $CA8F: 85 24
  LDA $CAD9,Y                                         ; $CA91: B9 D9 CA
  STA $25                                             ; $CA94: 85 25
  LDA #$00                                            ; $CA96: A9 00
  STA $26                                             ; $CA98: 85 26
  LDY $26                                             ; $CA9A: A4 26
  LDA ($24),Y                                         ; $CA9C: B1 24
  CMP #$FF                                            ; $CA9E: C9 FF
  BEQ LCAAC                                           ; $CAA0: F0 0A
  STA $27                                             ; $CAA2: 85 27
  JSR Proc_CAAD                                       ; $CAA4: 20 AD CA
  INC $26                                             ; $CAA7: E6 26
  JMP $CA9A                                           ; $CAA9: 4C 9A CA
LCAAC:
  RTS                                                 ; $CAAC: 60
.endproc
LCA1E = $CA1E
LCA52 = $CA52
LCA7F = $CA7F
LCAAC = $CAAC


;===============================================================================
; $CAAD: Proc_CAAD
;===============================================================================
.proc Proc_CAAD
  math_acc_lo              = $0020
  math_temp3               = $0027
  work_record_val          = $0040

  LDA #$00                                            ; $CAAD: A9 00
  STA $2A                                             ; $CAAF: 85 2A
LCAB1:
  LDA $2A                                             ; $CAB1: A5 2A
  JSR Proc_D105                                       ; $CAB3: 20 05 D1
  CMP a:$0040                                         ; $CAB6: CD 40 00
  .byte $D0,$0D                                       ; $CAB9: D0 0D (BNE mid-instruction target)
  LDY #$11                                            ; $CABB: A0 11
  LDA ($20),Y                                         ; $CABD: B1 20
  CMP $27                                             ; $CABF: C5 27
  BEQ LCAD1                                           ; $CAC1: F0 0E
  INY                                                 ; $CAC3: C8
  CPY #$1B                                            ; $CAC4: C0 1B
  .byte $90,$F5                                       ; $CAC6: 90 F5 (BCC mid-instruction target)
  INC $2A                                             ; $CAC8: E6 2A
  LDA $2A                                             ; $CACA: A5 2A
  CMP #$1E                                            ; $CACC: C9 1E
  BCC LCAB1                                           ; $CACE: 90 E1
  RTS                                                 ; $CAD0: 60
LCAD1:
  PLA                                                 ; $CAD1: 68
  PLA                                                 ; $CAD2: 68
  PLA                                                 ; $CAD3: 68
  PLA                                                 ; $CAD4: 68
  JMP Proc_CB52                                       ; $CAD5: 4C 52 CB
.endproc
LCAB1 = $CAB1
LCAD1 = $CAD1


;===============================================================================
; $CAD8: Proc_CAD8
;===============================================================================
.proc Proc_CAD8

  INC $CA                                             ; $CAD8: E6 CA
  NOP                                                 ; $CADA: EA
  DEX                                                 ; $CADB: CA
  SBC $F4CA                                           ; $CADC: ED CA F4
  DEX                                                 ; $CADF: CA
  SED                                                 ; $CAE0: F8
  DEX                                                 ; $CAE1: CA
  SBC a:$00CA,X                                       ; $CAE2: FD CA 00
  .byte $CB,$DA,$DB,$D3,$FF,$09,$07,$FF,$84,$7B,$7F,$80,$85,$82,$FF,$89; $CAE5: CB DA DB D3 FF 09 07 FF 84 7B 7F 80 85 82 FF 89
  .byte $8B,$5D,$FF,$E0,$6D,$26,$99,$FF,$42,$97,$FF,$B4,$B0,$B5,$B3,$FF; $CAF5: 8B 5D FF E0 6D 26 99 FF 42 97 FF B4 B0 B5 B3 FF
.endproc

;===============================================================================
; $CB05: Proc_CB05
;===============================================================================
.proc Proc_CB05
  math_acc_lo              = $0020
  math_ext                 = $0024
  math_temp3               = $0027
  work_record_val          = $0040

  LDA #$00                                            ; $CB05: A9 00
  STA $2A                                             ; $CB07: 85 2A
  STA $2B                                             ; $CB09: 85 2B
  LDA #$FF                                            ; $CB0B: A9 FF
  STA $27                                             ; $CB0D: 85 27
LCB0F:
  LDA $2A                                             ; $CB0F: A5 2A
  JSR Proc_D105                                       ; $CB11: 20 05 D1
  CMP a:$0040                                         ; $CB14: CD 40 00
  BNE LCB3E                                           ; $CB17: D0 25
  LDY #$11                                            ; $CB19: A0 11
  STY $24                                             ; $CB1B: 84 24
  LDY $24                                             ; $CB1D: A4 24
  LDA ($20),Y                                         ; $CB1F: B1 20
  CMP #$FF                                            ; $CB21: C9 FF
  BEQ LCB36                                           ; $CB23: F0 11
  LDY #$04                                            ; $CB25: A0 04
  JSR $D2AB                                           ; $CB27: 20 AB D2
  CMP $2B                                             ; $CB2A: C5 2B
  BCC LCB36                                           ; $CB2C: 90 08
  STA $2B                                             ; $CB2E: 85 2B
  LDY $24                                             ; $CB30: A4 24
  LDA ($20),Y                                         ; $CB32: B1 20
  STA $27                                             ; $CB34: 85 27
LCB36:
  INC $24                                             ; $CB36: E6 24
  LDA $24                                             ; $CB38: A5 24
  CMP #$1B                                            ; $CB3A: C9 1B
  .byte $90,$DF                                       ; $CB3C: 90 DF (BCC mid-instruction target)
LCB3E:
  INC $2A                                             ; $CB3E: E6 2A
  LDA $2A                                             ; $CB40: A5 2A
  CMP #$1E                                            ; $CB42: C9 1E
  BCC LCB0F                                           ; $CB44: 90 C9
  LDA $27                                             ; $CB46: A5 27
  CMP #$FF                                            ; $CB48: C9 FF
  BEQ LCB51                                           ; $CB4A: F0 05
  PLA                                                 ; $CB4C: 68
  PLA                                                 ; $CB4D: 68
  JMP Proc_CB52                                       ; $CB4E: 4C 52 CB
LCB51:
  RTS                                                 ; $CB51: 60
.endproc
LCB0F = $CB0F
LCB36 = $CB36
LCB3E = $CB3E
LCB51 = $CB51


;===============================================================================
; $CB52: Proc_CB52
;===============================================================================
.proc Proc_CB52
  math_acc_mhi             = $0022
  math_ext                 = $0024
  math_temp3               = $0027
  work_record_val          = $0040
  work_search_max          = $0045
  sram_game_start_flag     = $6F8B

  LDA a:$0040                                         ; $CB52: AD 40 00
  JSR Proc_D319                                       ; $CB55: 20 19 D3
  LDY #$00                                            ; $CB58: A0 00
  LDA ($24),Y                                         ; $CB5A: B1 24
  STA $33                                             ; $CB5C: 85 33
  LDA $27                                             ; $CB5E: A5 27
  STA ($24),Y                                         ; $CB60: 91 24
  LDY #$03                                            ; $CB62: A0 03
  JSR $D2AB                                           ; $CB64: 20 AB D2
  LDA #$64                                            ; $CB67: A9 64
  STA ($22),Y                                         ; $CB69: 91 22
  LDA $27                                             ; $CB6B: A5 27
  PHA                                                 ; $CB6D: 48
  JSR $CB81                                           ; $CB6E: 20 81 CB
  PLA                                                 ; $CB71: 68
  STA $27                                             ; $CB72: 85 27
  LDA #$FC                                            ; $CB74: A9 FC
  STA $6F8B                                           ; $CB76: 8D 8B 6F
LCB79:
  LDA $6F8B                                           ; $CB79: AD 8B 6F
  CMP #$01                                            ; $CB7C: C9 01
  BNE LCB79                                           ; $CB7E: D0 F9
  RTS                                                 ; $CB80: 60
  LDA $27                                             ; $CB81: A5 27
  STA $30                                             ; $CB83: 85 30
  LDA #$00                                            ; $CB85: A9 00
  STA a:$0045                                         ; $CB87: 8D 45 00
LCB8A:
  LDA a:$0045                                         ; $CB8A: AD 45 00
  JSR Proc_D105                                       ; $CB8D: 20 05 D1
  CMP a:$0040                                         ; $CB90: CD 40 00
  BNE LCB98                                           ; $CB93: D0 03
  JSR Proc_CBA3                                       ; $CB95: 20 A3 CB
LCB98:
  INC a:$0045                                         ; $CB98: EE 45 00
  LDA a:$0045                                         ; $CB9B: AD 45 00
  CMP #$1E                                            ; $CB9E: C9 1E
  BCC LCB8A                                           ; $CBA0: 90 E8
  RTS                                                 ; $CBA2: 60
.endproc
LCB79 = $CB79
LCB8A = $CB8A
LCB98 = $CB98


;===============================================================================
; $CBA3: Proc_CBA3
;===============================================================================
.proc Proc_CBA3
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp2               = $0026
  math_temp3               = $0027
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  work_inner_idx2          = $0038
  work_sub_idx             = $0039
  work_limit_a             = $003A
  work_record_val          = $0040
  work_search_max          = $0045
  sram_player_id           = $6F03

  LDA #$11                                            ; $CBA3: A9 11
  STA a:$0044                                         ; $CBA5: 8D 44 00
LCBA8:
  LDA a:$0045                                         ; $CBA8: AD 45 00
  JSR Proc_D105                                       ; $CBAB: 20 05 D1
  LDY a:$0044                                         ; $CBAE: AC 44 00
  LDA ($20),Y                                         ; $CBB1: B1 20
  CMP #$FF                                            ; $CBB3: C9 FF
  .byte $F0,$E1                                       ; $CBB5: F0 E1 (BEQ cross-proc)
  CMP $30                                             ; $CBB7: C5 30
  .byte $F0,$DD                                       ; $CBB9: F0 DD (BEQ cross-proc)
  STA $31                                             ; $CBBB: 85 31
  LDA a:$0040                                         ; $CBBD: AD 40 00
  STA $32                                             ; $CBC0: 85 32
  JSR DataRecordLookup                            ; $CBC2: 20 7C CF
  LDA $31                                             ; $CBC5: A5 31
  LDY #$03                                            ; $CBC7: A0 03
  JSR $D2AB                                           ; $CBC9: 20 AB D2
  CMP #$1F                                            ; $CBCC: C9 1F
  BCS LCBEB                                           ; $CBCE: B0 1B
  LDA #$64                                            ; $CBD0: A9 64
  JSR Proc_D4BB                                       ; $CBD2: 20 BB D4
  CMP #$14                                            ; $CBD5: C9 14
  BCS LCBEB                                           ; $CBD7: B0 12
  LDA $31                                             ; $CBD9: A5 31
  LDY #$0B                                            ; $CBDB: A0 0B
  JSR $D2AB                                           ; $CBDD: 20 AB D2
  AND #$FC                                            ; $CBE0: 29 FC
  STA ($22),Y                                         ; $CBE2: 91 22
  LDY #$05                                            ; $CBE4: A0 05
  LDA a:$0045                                         ; $CBE6: AD 45 00
  STA ($22),Y                                         ; $CBE9: 91 22
LCBEB:
  INC a:$0044                                         ; $CBEB: EE 44 00
  LDA a:$0044                                         ; $CBEE: AD 44 00
  CMP #$1B                                            ; $CBF1: C9 1B
  BCC LCBA8                                           ; $CBF3: 90 B3
  LDA a:$0045                                         ; $CBF5: AD 45 00
  JSR Proc_D3DD                                       ; $CBF8: 20 DD D3
  LDA a:$0045                                         ; $CBFB: AD 45 00
  JSR Proc_D304                                       ; $CBFE: 20 04 D3
  CMP #$00                                            ; $CC01: C9 00
  .byte $D0,$0C                                       ; $CC03: D0 0C (BNE mid-instruction target)
  LDA a:$0045                                         ; $CC05: AD 45 00
  JSR Proc_D105                                       ; $CC08: 20 05 D1
  LDY #$00                                            ; $CC0B: A0 00
  LDA #$07                                            ; $CC0D: A9 07
  STA ($20),Y                                         ; $CC0F: 91 20
  RTS                                                 ; $CC11: 60
  LDY #$FF                                            ; $CC12: A0 FF
  STY a:$0036                                         ; $CC14: 8C 36 00
LCC17:
  INC a:$0036                                         ; $CC17: EE 36 00
  LDA a:$0036                                         ; $CC1A: AD 36 00
  CMP #$1E                                            ; $CC1D: C9 1E
  BCC LCC22                                           ; $CC1F: 90 01
  RTS                                                 ; $CC21: 60
LCC22:
  LDA a:$0036                                         ; $CC22: AD 36 00
  JSR Proc_D105                                       ; $CC25: 20 05 D1
  AND #$07                                            ; $CC28: 29 07
  CMP $6F03                                           ; $CC2A: CD 03 6F
  BNE LCC17                                           ; $CC2D: D0 E8
  LDY #$02                                            ; $CC2F: A0 02
  LDA ($20),Y                                         ; $CC31: B1 20
  SEC                                                 ; $CC33: 38
  SBC #$32                                            ; $CC34: E9 32
  INY                                                 ; $CC36: C8
  LDA ($20),Y                                         ; $CC37: B1 20
  SBC #$00                                            ; $CC39: E9 00
  BCS LCC17                                           ; $CC3B: B0 DA
  LDY #$30                                            ; $CC3D: A0 30
  JSR B1F_SwitchBank8_A                               ; $CC3F: 20 66 F2
  LDY a:$0036                                         ; $CC42: AC 36 00
  LDA $8FFC,Y                                         ; $CC45: B9 FC 8F
  AND #$04                                            ; $CC48: 29 04
  BEQ LCC17                                           ; $CC4A: F0 CB
  JSR $CCF8                                           ; $CC4C: 20 F8 CC
  LDA a:$0036                                         ; $CC4F: AD 36 00
  JSR Proc_D105                                       ; $CC52: 20 05 D1
  LDY #$04                                            ; $CC55: A0 04
  LDA ($20),Y                                         ; $CC57: B1 20
  SEC                                                 ; $CC59: 38
  SBC a:$0039                                         ; $CC5A: ED 39 00
  STA a:$0039                                         ; $CC5D: 8D 39 00
  INY                                                 ; $CC60: C8
  LDA ($20),Y                                         ; $CC61: B1 20
  SBC a:$003A                                         ; $CC63: ED 3A 00
  STA a:$003A                                         ; $CC66: 8D 3A 00
  BCC LCC17                                           ; $CC69: 90 AC
  LDA a:$0039                                         ; $CC6B: AD 39 00
  SEC                                                 ; $CC6E: 38
  SBC #$2C                                            ; $CC6F: E9 2C
  LDA a:$003A                                         ; $CC71: AD 3A 00
  SBC #$01                                            ; $CC74: E9 01
  BCC LCC82                                           ; $CC76: 90 0A
  LDA #$2C                                            ; $CC78: A9 2C
  STA a:$0039                                         ; $CC7A: 8D 39 00
  LDA #$01                                            ; $CC7D: A9 01
  STA a:$003A                                         ; $CC7F: 8D 3A 00
LCC82:
  LDY #$04                                            ; $CC82: A0 04
  LDA ($20),Y                                         ; $CC84: B1 20
  SEC                                                 ; $CC86: 38
  SBC a:$0039                                         ; $CC87: ED 39 00
  STA ($20),Y                                         ; $CC8A: 91 20
  INY                                                 ; $CC8C: C8
  LDA ($20),Y                                         ; $CC8D: B1 20
  SBC a:$003A                                         ; $CC8F: ED 3A 00
  STA ($20),Y                                         ; $CC92: 91 20
  LDY #$30                                            ; $CC94: A0 30
  JSR B1F_SwitchBank8_A                               ; $CC96: 20 66 F2
  LDA a:$0036                                         ; $CC99: AD 36 00
  ASL A                                               ; $CC9C: 0A
  TAY                                                 ; $CC9D: A8
  LDA $8FC0,Y                                         ; $CC9E: B9 C0 8F
  STA $23                                             ; $CCA1: 85 23
  LDA a:$0039                                         ; $CCA3: AD 39 00
  STA $20                                             ; $CCA6: 85 20
  LDA a:$003A                                         ; $CCA8: AD 3A 00
  STA $21                                             ; $CCAB: 85 21
  LDA #$00                                            ; $CCAD: A9 00
  STA $22                                             ; $CCAF: 85 22
  JSR Proc_D438                                       ; $CCB1: 20 38 D4
  LDA $26                                             ; $CCB4: A5 26
  STA $20                                             ; $CCB6: 85 20
  LDA $27                                             ; $CCB8: A5 27
  STA $21                                             ; $CCBA: 85 21
  LDA $28                                             ; $CCBC: A5 28
  STA $22                                             ; $CCBE: 85 22
  LDA #$64                                            ; $CCC0: A9 64
  STA $23                                             ; $CCC2: 85 23
  LDA #$00                                            ; $CCC4: A9 00
  STA $24                                             ; $CCC6: 85 24
  JSR Proc_D336                                       ; $CCC8: 20 36 D3
  LDA $20                                             ; $CCCB: A5 20
  STA a:$0039                                         ; $CCCD: 8D 39 00
  LDA $21                                             ; $CCD0: A5 21
  STA a:$003A                                         ; $CCD2: 8D 3A 00
  LDA a:$0036                                         ; $CCD5: AD 36 00
  JSR Proc_D105                                       ; $CCD8: 20 05 D1
  LDY #$02                                            ; $CCDB: A0 02
  LDA ($20),Y                                         ; $CCDD: B1 20
  CLC                                                 ; $CCDF: 18
  ADC a:$0039                                         ; $CCE0: 6D 39 00
  STA ($20),Y                                         ; $CCE3: 91 20
  INY                                                 ; $CCE5: C8
  LDA ($20),Y                                         ; $CCE6: B1 20
  ADC a:$003A                                         ; $CCE8: 6D 3A 00
  STA ($20),Y                                         ; $CCEB: 91 20
  JSR Proc_D69D                                       ; $CCED: 20 9D D6
  LDA #$02                                            ; $CCF0: A9 02
  JSR Proc_D165                                       ; $CCF2: 20 65 D1
  JMP LCC17                                           ; $CCF5: 4C 17 CC
  LDA a:$0036                                         ; $CCF8: AD 36 00
  JSR Proc_D105                                       ; $CCFB: 20 05 D1
  LDA #$11                                            ; $CCFE: A9 11
  STA a:$0037                                         ; $CD00: 8D 37 00
  LDA #$00                                            ; $CD03: A9 00
  STA a:$0038                                         ; $CD05: 8D 38 00
  STA a:$0039                                         ; $CD08: 8D 39 00
  LDY a:$0037                                         ; $CD0B: AC 37 00
  LDA ($20),Y                                         ; $CD0E: B1 20
  CMP #$FF                                            ; $CD10: C9 FF
  .byte $F0,$15                                       ; $CD12: F0 15 (BEQ mid-instruction target)
  LDY #$08                                            ; $CD14: A0 08
  JSR $D2AB                                           ; $CD16: 20 AB D2
  CLC                                                 ; $CD19: 18
  ADC a:$0038                                         ; $CD1A: 6D 38 00
  STA a:$0038                                         ; $CD1D: 8D 38 00
  INY                                                 ; $CD20: C8
  LDA a:$0039                                         ; $CD21: AD 39 00
  ADC ($22),Y                                         ; $CD24: 71 22
  STA a:$0039                                         ; $CD26: 8D 39 00
  INC a:$0037                                         ; $CD29: EE 37 00
  LDA a:$0037                                         ; $CD2C: AD 37 00
  CMP #$1B                                            ; $CD2F: C9 1B
  .byte $90,$D8                                       ; $CD31: 90 D8 (BCC mid-instruction target)
  LDA a:$0038                                         ; $CD33: AD 38 00
  STA $21                                             ; $CD36: 85 21
  LDA a:$0039                                         ; $CD38: AD 39 00
  STA $22                                             ; $CD3B: 85 22
  ASL a:$0038                                         ; $CD3D: 0E 38 00
  ROL a:$0039                                         ; $CD40: 2E 39 00
  LDA a:$0038                                         ; $CD43: AD 38 00
  CLC                                                 ; $CD46: 18
  ADC $21                                             ; $CD47: 65 21
  STA $21                                             ; $CD49: 85 21
  LDA a:$0039                                         ; $CD4B: AD 39 00
  ADC $22                                             ; $CD4E: 65 22
  STA $22                                             ; $CD50: 85 22
  LDA #$19                                            ; $CD52: A9 19
  STA $23                                             ; $CD54: 85 23
  LDA #$00                                            ; $CD56: A9 00
  STA $24                                             ; $CD58: 85 24
  JSR Proc_D40F                                       ; $CD5A: 20 0F D4
  LDA $21                                             ; $CD5D: A5 21
  STA a:$0039                                         ; $CD5F: 8D 39 00
  LDA $22                                             ; $CD62: A5 22
  STA a:$003A                                         ; $CD64: 8D 3A 00
  RTS                                                 ; $CD67: 60
.endproc
LCBA8 = $CBA8
LCBEB = $CBEB
LCC17 = $CC17
LCC22 = $CC22
LCC82 = $CC82


;===============================================================================
; $CD68: Proc_CD68
;===============================================================================
.proc Proc_CD68
  work_outer_idx           = $0036

  LDA #$0A                                            ; $CD68: A9 0A
  JSR Proc_D4AD                                       ; $CD6A: 20 AD D4
  CLC                                                 ; $CD6D: 18
  ADC #$0A                                            ; $CD6E: 69 0A
  LDY #$06                                            ; $CD70: A0 06
  STY a:$0036                                         ; $CD72: 8C 36 00
  JSR Proc_CDB9                                       ; $CD75: 20 B9 CD
  JSR $CD9A                                           ; $CD78: 20 9A CD
  LDY #$08                                            ; $CD7B: A0 08
  STY a:$0036                                         ; $CD7D: 8C 36 00
  JSR Proc_CDB9                                       ; $CD80: 20 B9 CD
  JSR $CD9A                                           ; $CD83: 20 9A CD
  LDY #$0E                                            ; $CD86: A0 0E
  STY a:$0036                                         ; $CD88: 8C 36 00
  JSR Proc_CDB9                                       ; $CD8B: 20 B9 CD
  JSR $CD9A                                           ; $CD8E: 20 9A CD
  LDY #$0B                                            ; $CD91: A0 0B
  STY a:$0036                                         ; $CD93: 8C 36 00
  JSR $CE1B                                           ; $CD96: 20 1B CE
  RTS                                                 ; $CD99: 60
  LDY #$0A                                            ; $CD9A: A0 0A
  LDA $6F8D                                           ; $CD9C: AD 8D 6F
  CMP #$05                                            ; $CD9F: C9 05
  BCC LCDB7                                           ; $CDA1: 90 14
  LDY #$14                                            ; $CDA3: A0 14
  CMP #$0A                                            ; $CDA5: C9 0A
  BCC LCDB7                                           ; $CDA7: 90 0E
  LDY #$1E                                            ; $CDA9: A0 1E
  CMP #$0F                                            ; $CDAB: C9 0F
  BCC LCDB7                                           ; $CDAD: 90 08
  LDY #$28                                            ; $CDAF: A0 28
  CMP #$14                                            ; $CDB1: C9 14
  BCC LCDB7                                           ; $CDB3: 90 02
  LDY #$3C                                            ; $CDB5: A0 3C
LCDB7:
  TYA                                                 ; $CDB7: 98
  RTS                                                 ; $CDB8: 60
.endproc
LCDB7 = $CDB7


;===============================================================================
; $CDB9: Proc_CDB9
;===============================================================================
.proc Proc_CDB9
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp2               = $0026
  math_temp3               = $0027
  work_outer_idx           = $0036
  work_inner_idx2          = $0038

  PHA                                                 ; $CDB9: 48
  LDA a:$0038                                         ; $CDBA: AD 38 00
  JSR Proc_D105                                       ; $CDBD: 20 05 D1
  LDY a:$0036                                         ; $CDC0: AC 36 00
  LDA ($20),Y                                         ; $CDC3: B1 20
  PHA                                                 ; $CDC5: 48
  INY                                                 ; $CDC6: C8
  LDA ($20),Y                                         ; $CDC7: B1 20
  STA $21                                             ; $CDC9: 85 21
  PLA                                                 ; $CDCB: 68
  STA $20                                             ; $CDCC: 85 20
  PLA                                                 ; $CDCE: 68
  STA $23                                             ; $CDCF: 85 23
  LDA #$00                                            ; $CDD1: A9 00
  STA $22                                             ; $CDD3: 85 22
  JSR Proc_D438                                       ; $CDD5: 20 38 D4
  LDA $26                                             ; $CDD8: A5 26
  STA $20                                             ; $CDDA: 85 20
  LDA $27                                             ; $CDDC: A5 27
  STA $21                                             ; $CDDE: 85 21
  LDA $28                                             ; $CDE0: A5 28
  STA $22                                             ; $CDE2: 85 22
  LDA #$64                                            ; $CDE4: A9 64
  STA $23                                             ; $CDE6: 85 23
  LDA #$00                                            ; $CDE8: A9 00
  STA $24                                             ; $CDEA: 85 24
  JSR Proc_D336                                       ; $CDEC: 20 36 D3
  LDA $20                                             ; $CDEF: A5 20
  STA $2A                                             ; $CDF1: 85 2A
  LDA $21                                             ; $CDF3: A5 21
  STA $2B                                             ; $CDF5: 85 2B
  LDA a:$0038                                         ; $CDF7: AD 38 00
  JSR Proc_D105                                       ; $CDFA: 20 05 D1
  LDY a:$0036                                         ; $CDFD: AC 36 00
  LDA ($20),Y                                         ; $CE00: B1 20
  SEC                                                 ; $CE02: 38
  SBC $2A                                             ; $CE03: E5 2A
  STA ($20),Y                                         ; $CE05: 91 20
  INY                                                 ; $CE07: C8
  LDA ($20),Y                                         ; $CE08: B1 20
  SBC $2B                                             ; $CE0A: E5 2B
  STA ($20),Y                                         ; $CE0C: 91 20
  .byte $B0,$0A                                       ; $CE0E: B0 0A (BCS mid-instruction target)
  LDY a:$0036                                         ; $CE10: AC 36 00
  LDA #$00                                            ; $CE13: A9 00
  STA ($20),Y                                         ; $CE15: 91 20
  INY                                                 ; $CE17: C8
  STA ($20),Y                                         ; $CE18: 91 20
  RTS                                                 ; $CE1A: 60
  PHA                                                 ; $CE1B: 48
  LDA a:$0038                                         ; $CE1C: AD 38 00
  JSR Proc_D105                                       ; $CE1F: 20 05 D1
  LDY a:$0036                                         ; $CE22: AC 36 00
  LDA ($20),Y                                         ; $CE25: B1 20
  STA $20                                             ; $CE27: 85 20
  PLA                                                 ; $CE29: 68
  STA $23                                             ; $CE2A: 85 23
  LDA #$00                                            ; $CE2C: A9 00
  STA $21                                             ; $CE2E: 85 21
  STA $22                                             ; $CE30: 85 22
  JSR Proc_D438                                       ; $CE32: 20 38 D4
  LDA $26                                             ; $CE35: A5 26
  STA $20                                             ; $CE37: 85 20
  LDA $27                                             ; $CE39: A5 27
  STA $21                                             ; $CE3B: 85 21
  LDA $28                                             ; $CE3D: A5 28
  STA $22                                             ; $CE3F: 85 22
  LDA #$64                                            ; $CE41: A9 64
  STA $23                                             ; $CE43: 85 23
  LDA #$00                                            ; $CE45: A9 00
  STA $24                                             ; $CE47: 85 24
  JSR Proc_D336                                       ; $CE49: 20 36 D3
  LDA $20                                             ; $CE4C: A5 20
  STA $2A                                             ; $CE4E: 85 2A
  LDA a:$0038                                         ; $CE50: AD 38 00
  JSR Proc_D105                                       ; $CE53: 20 05 D1
  LDY a:$0036                                         ; $CE56: AC 36 00
  LDA ($20),Y                                         ; $CE59: B1 20
  SEC                                                 ; $CE5B: 38
  SBC $2A                                             ; $CE5C: E5 2A
  STA ($20),Y                                         ; $CE5E: 91 20
  .byte $B0,$04                                       ; $CE60: B0 04 (BCS mid-instruction target)
  LDA #$00                                            ; $CE62: A9 00
  STA ($20),Y                                         ; $CE64: 91 20
  RTS                                                 ; $CE66: 60
  LDY #$FE                                            ; $CE67: A0 FE
  INY                                                 ; $CE69: C8
  INY                                                 ; $CE6A: C8
  LDA $0522                                           ; $CE6B: AD 22 05
  SEC                                                 ; $CE6E: 38
  SBC $CEC9,Y                                         ; $CE6F: F9 C9 CE
  LDA $0523                                           ; $CE72: AD 23 05
  SBC $CECA,Y                                         ; $CE75: F9 CA CE
  .byte $B0,$EF                                       ; $CE78: B0 EF (BCS mid-instruction target)
  TYA                                                 ; $CE7A: 98
  LSR A                                               ; $CE7B: 4A
  TAY                                                 ; $CE7C: A8
  LDA $CED3,Y                                         ; $CE7D: B9 D3 CE
  STA a:$0023                                         ; $CE80: 8D 23 00
  LDA $0522                                           ; $CE83: AD 22 05
  STA $20                                             ; $CE86: 85 20
  LDA $0523                                           ; $CE88: AD 23 05
  STA $21                                             ; $CE8B: 85 21
  LDA #$00                                            ; $CE8D: A9 00
  STA $22                                             ; $CE8F: 85 22
  JSR Proc_D438                                       ; $CE91: 20 38 D4
  LDA $26                                             ; $CE94: A5 26
  STA $20                                             ; $CE96: 85 20
  LDA $27                                             ; $CE98: A5 27
  STA $21                                             ; $CE9A: 85 21
  LDA $28                                             ; $CE9C: A5 28
  STA $22                                             ; $CE9E: 85 22
  LDA #$64                                            ; $CEA0: A9 64
  STA $23                                             ; $CEA2: 85 23
  LDA #$00                                            ; $CEA4: A9 00
  STA $24                                             ; $CEA6: 85 24
  JSR Proc_D336                                       ; $CEA8: 20 36 D3
  LDA $0522                                           ; $CEAB: AD 22 05
  SEC                                                 ; $CEAE: 38
  SBC a:$0020                                         ; $CEAF: ED 20 00
  STA $0522                                           ; $CEB2: 8D 22 05
  LDA $0523                                           ; $CEB5: AD 23 05
  SBC a:$0021                                         ; $CEB8: ED 21 00
  STA $0523                                           ; $CEBB: 8D 23 05
  .byte $B0,$08                                       ; $CEBE: B0 08 (BCS mid-instruction target)
  LDA #$00                                            ; $CEC0: A9 00
  STA $0522                                           ; $CEC2: 8D 22 05
  STA $0523                                           ; $CEC5: 8D 23 05
  RTS                                                 ; $CEC8: 60
  .byte $F4,$01,$E8,$03,$B8,$0B,$88,$13,$20,$4E,$32,$00,$3C,$00,$46,$00; $CEC9: F4 01 E8 03 B8 0B 88 13 20 4E 32 00 3C 00 46 00
  .byte $50,$00,$5A,$00                               ; $CED9: 50 00 5A 00
.endproc

;===============================================================================
; $CEDD: Proc_CEDD
;===============================================================================
.proc Proc_CEDD
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp2               = $0026
  math_temp3               = $0027

  LDY #$FE                                            ; $CEDD: A0 FE
  INY                                                 ; $CEDF: C8
  INY                                                 ; $CEE0: C8
  LDA $0526                                           ; $CEE1: AD 26 05
  SEC                                                 ; $CEE4: 38
  SBC $CEC9,Y                                         ; $CEE5: F9 C9 CE
  LDA $0527                                           ; $CEE8: AD 27 05
  SBC $CECA,Y                                         ; $CEEB: F9 CA CE
  .byte $B0,$EF                                       ; $CEEE: B0 EF (BCS mid-instruction target)
  TYA                                                 ; $CEF0: 98
  LSR A                                               ; $CEF1: 4A
  TAY                                                 ; $CEF2: A8
  LDA $CED3,Y                                         ; $CEF3: B9 D3 CE
  STA a:$0023                                         ; $CEF6: 8D 23 00
  LDA $0526                                           ; $CEF9: AD 26 05
  STA $20                                             ; $CEFC: 85 20
  LDA $0527                                           ; $CEFE: AD 27 05
  STA $21                                             ; $CF01: 85 21
  LDA #$00                                            ; $CF03: A9 00
  STA $22                                             ; $CF05: 85 22
  JSR Proc_D438                                       ; $CF07: 20 38 D4
  LDA $26                                             ; $CF0A: A5 26
  STA $20                                             ; $CF0C: 85 20
  LDA $27                                             ; $CF0E: A5 27
  STA $21                                             ; $CF10: 85 21
  LDA $28                                             ; $CF12: A5 28
  STA $22                                             ; $CF14: 85 22
  LDA #$64                                            ; $CF16: A9 64
  STA $23                                             ; $CF18: 85 23
  LDA #$00                                            ; $CF1A: A9 00
  STA $24                                             ; $CF1C: 85 24
  JSR Proc_D336                                       ; $CF1E: 20 36 D3
  LDA $0526                                           ; $CF21: AD 26 05
  SEC                                                 ; $CF24: 38
  SBC a:$0020                                         ; $CF25: ED 20 00
  STA $0526                                           ; $CF28: 8D 26 05
  LDA $0527                                           ; $CF2B: AD 27 05
  SBC a:$0021                                         ; $CF2E: ED 21 00
  STA $0527                                           ; $CF31: 8D 27 05
  .byte $B0,$08                                       ; $CF34: B0 08 (BCS mid-instruction target)
  LDA #$00                                            ; $CF36: A9 00
  STA $0526                                           ; $CF38: 8D 26 05
  STA $0527                                           ; $CF3B: 8D 27 05
  RTS                                                 ; $CF3E: 60
.endproc

;===============================================================================
; $CF3F: ArmyValueCalc
; Calculate total army value from officer/troop data
;===============================================================================
.proc ArmyValueCalc
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024

  LDA $30                                             ; $CF3F: A5 30
  LDY #$04                                            ; $CF41: A0 04
  JSR $D2AB                                           ; $CF43: 20 AB D2
  STA $21                                             ; $CF46: 85 21
  LDA #$0A                                            ; $CF48: A9 0A
  STA $23                                             ; $CF4A: 85 23
  LDA #$00                                            ; $CF4C: A9 00
  STA $22                                             ; $CF4E: 85 22
  STA $24                                             ; $CF50: 85 24
  JSR Proc_D40F                                       ; $CF52: 20 0F D4
  LDA $21                                             ; $CF55: A5 21
  CLC                                                 ; $CF57: 18
  ADC #$46                                            ; $CF58: 69 46
  PHA                                                 ; $CF5A: 48
  LDA $31                                             ; $CF5B: A5 31
  LDY #$03                                            ; $CF5D: A0 03
  JSR $D2AB                                           ; $CF5F: 20 AB D2
  STA $20                                             ; $CF62: 85 20
  PLA                                                 ; $CF64: 68
  SEC                                                 ; $CF65: 38
  SBC $20                                             ; $CF66: E5 20
  CMP #$5A                                            ; $CF68: C9 5A
  BCC LCF6E                                           ; $CF6A: 90 02
  LDA #$5A                                            ; $CF6C: A9 5A
LCF6E:
  CMP #$0A                                            ; $CF6E: C9 0A
  BCS LCF74                                           ; $CF70: B0 02
  LDA #$0A                                            ; $CF72: A9 0A
LCF74:
  LDY #$03                                            ; $CF74: A0 03
  STA ($22),Y                                         ; $CF76: 91 22
  JSR Proc_D61E                                       ; $CF78: 20 1E D6
  RTS                                                 ; $CF7B: 60
.endproc
LCF6E = $CF6E
LCF74 = $CF74


;===============================================================================
; $CF7C: DataRecordLookup
; Lookup data records by index (province/officer info)
;===============================================================================
.proc DataRecordLookup
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025

  LDA $32                                             ; $CF7C: A5 32
  ASL A                                               ; $CF7E: 0A
  TAY                                                 ; $CF7F: A8
  LDA $CAD8,Y                                         ; $CF80: B9 D8 CA
  STA $24                                             ; $CF83: 85 24
  LDA $CAD9,Y                                         ; $CF85: B9 D9 CA
  STA $25                                             ; $CF88: 85 25
  LDY #$FF                                            ; $CF8A: A0 FF
LCF8C:
  INY                                                 ; $CF8C: C8
  LDA ($24),Y                                         ; $CF8D: B1 24
  CMP #$FF                                            ; $CF8F: C9 FF
  BEQ LCF98                                           ; $CF91: F0 05
  CMP $30                                             ; $CF93: C5 30
  BNE LCF8C                                           ; $CF95: D0 F5
  RTS                                                 ; $CF97: 60
LCF98:
  LDA $30                                             ; $CF98: A5 30
  LDY #$04                                            ; $CF9A: A0 04
  JSR $D2AB                                           ; $CF9C: 20 AB D2
  STA $21                                             ; $CF9F: 85 21
  LDA #$05                                            ; $CFA1: A9 05
  STA $23                                             ; $CFA3: 85 23
  LDA #$00                                            ; $CFA5: A9 00
  STA $22                                             ; $CFA7: 85 22
  STA $24                                             ; $CFA9: 85 24
  JSR Proc_D40F                                       ; $CFAB: 20 0F D4
  LDA $21                                             ; $CFAE: A5 21
  PHA                                                 ; $CFB0: 48
  LDA $33                                             ; $CFB1: A5 33
  LDY #$04                                            ; $CFB3: A0 04
  JSR $D2AB                                           ; $CFB5: 20 AB D2
  STA $21                                             ; $CFB8: 85 21
  LDA #$05                                            ; $CFBA: A9 05
  STA $23                                             ; $CFBC: 85 23
  LDA #$00                                            ; $CFBE: A9 00
  STA $22                                             ; $CFC0: 85 22
  STA $24                                             ; $CFC2: 85 24
  JSR Proc_D40F                                       ; $CFC4: 20 0F D4
  PLA                                                 ; $CFC7: 68
  SEC                                                 ; $CFC8: 38
  SBC $21                                             ; $CFC9: E5 21
  BCC LCFDC                                           ; $CFCB: 90 0F
  STA $20                                             ; $CFCD: 85 20
  LDA $31                                             ; $CFCF: A5 31
  LDY #$03                                            ; $CFD1: A0 03
  JSR $D2AB                                           ; $CFD3: 20 AB D2
  CLC                                                 ; $CFD6: 18
  ADC $20                                             ; $CFD7: 65 20
  JMP Proc_CFF1                                       ; $CFD9: 4C F1 CF
LCFDC:
  EOR #$FF                                            ; $CFDC: 49 FF
  CLC                                                 ; $CFDE: 18
  ADC #$01                                            ; $CFDF: 69 01
  STA $20                                             ; $CFE1: 85 20
  LDA $31                                             ; $CFE3: A5 31
  LDY #$03                                            ; $CFE5: A0 03
  JSR $D2AB                                           ; $CFE7: 20 AB D2
  SEC                                                 ; $CFEA: 38
  SBC $20                                             ; $CFEB: E5 20
  .byte $B0,$02                                       ; $CFED: B0 02 (BCS cross-proc)
  LDA #$00                                            ; $CFEF: A9 00
.endproc
LCF8C = $CF8C
LCF98 = $CF98
LCFDC = $CFDC


;===============================================================================
; $CFF1: Proc_CFF1
;===============================================================================
.proc Proc_CFF1
  math_acc_mhi             = $0022

  SEC                                                 ; $CFF1: 38
  SBC #$0A                                            ; $CFF2: E9 0A
  BCS LCFF8                                           ; $CFF4: B0 02
  LDA #$00                                            ; $CFF6: A9 00
LCFF8:
  CMP #$63                                            ; $CFF8: C9 63
  BCC LCFFE                                           ; $CFFA: 90 02
  LDA #$63                                            ; $CFFC: A9 63
LCFFE:
  CMP #$0A                                            ; $CFFE: C9 0A
  BCS LD004                                           ; $D000: B0 02
  LDA #$0A                                            ; $D002: A9 0A
LD004:
  LDY #$03                                            ; $D004: A0 03
  STA ($22),Y                                         ; $D006: 91 22
  JSR Proc_D61E                                       ; $D008: 20 1E D6
  RTS                                                 ; $D00B: 60
.endproc
LCFF8 = $CFF8
LCFFE = $CFFE
LD004 = $D004


;===============================================================================
; $D00C: DistanceClamp
; Clamp distance values to valid range
;===============================================================================
.proc DistanceClamp
  math_acc_lo              = $0020
  math_acc_mhi             = $0022

  LDA $20                                             ; $D00C: A5 20
  LDY #$03                                            ; $D00E: A0 03
  JSR $D2AB                                           ; $D010: 20 AB D2
  STA $20                                             ; $D013: 85 20
  LDA #$32                                            ; $D015: A9 32
  SEC                                                 ; $D017: 38
  SBC $20                                             ; $D018: E5 20
  .byte $B0,$05                                       ; $D01A: B0 05 (BCS mid-instruction target)
  EOR #$FF                                            ; $D01C: 49 FF
  CLC                                                 ; $D01E: 18
  ADC #$01                                            ; $D01F: 69 01
  STA $20                                             ; $D021: 85 20
  LDA #$33                                            ; $D023: A9 33
  SEC                                                 ; $D025: 38
  SBC $20                                             ; $D026: E5 20
  BCS LD02C                                           ; $D028: B0 02
  LDA #$00                                            ; $D02A: A9 00
LD02C:
  CMP #$0A                                            ; $D02C: C9 0A
  BCS LD032                                           ; $D02E: B0 02
  LDA #$0A                                            ; $D030: A9 0A
LD032:
  LDY #$03                                            ; $D032: A0 03
  STA ($22),Y                                         ; $D034: 91 22
  JSR Proc_D61E                                       ; $D036: 20 1E D6
  RTS                                                 ; $D039: 60
.endproc
LD02C = $D02C
LD032 = $D032


;===============================================================================
; $D03A: LoadRecord
; Load province/officer record into work buffer
;===============================================================================
.proc LoadRecord
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  work_temp_2              = $003E
  work_record_idx          = $003F
  work_record_val          = $0040
  sram_player_id           = $6F03

  LDA $6F03                                           ; $D03A: AD 03 6F
  JSR Proc_D080                                       ; $D03D: 20 80 D0
  LDA $2B                                             ; $D040: A5 2B
  STA a:$003E                                         ; $D042: 8D 3E 00
  STA $23                                             ; $D045: 85 23
  LDA $2C                                             ; $D047: A5 2C
  STA a:$003F                                         ; $D049: 8D 3F 00
  STA $22                                             ; $D04C: 85 22
  LDA #$00                                            ; $D04E: A9 00
  STA $21                                             ; $D050: 85 21
  STA $24                                             ; $D052: 85 24
  JSR Proc_D40F                                       ; $D054: 20 0F D4
  LDA $22                                             ; $D057: A5 22
  STA a:$0040                                         ; $D059: 8D 40 00
  RTS                                                 ; $D05C: 60
.endproc

;===============================================================================
; $D05D: Proc_D05D
;===============================================================================
.proc Proc_D05D
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  work_temp_2              = $003E
  work_record_idx          = $003F
  work_record_val          = $0040
  sram_player_id           = $6F03

  LDA $6F03                                           ; $D05D: AD 03 6F
  JSR Proc_D080                                       ; $D060: 20 80 D0
  LDA $2B                                             ; $D063: A5 2B
  STA a:$003E                                         ; $D065: 8D 3E 00
  STA $23                                             ; $D068: 85 23
  LDA $2C                                             ; $D06A: A5 2C
  STA a:$003F                                         ; $D06C: 8D 3F 00
  STA $22                                             ; $D06F: 85 22
  LDA #$00                                            ; $D071: A9 00
  STA $21                                             ; $D073: 85 21
  STA $24                                             ; $D075: 85 24
  JSR Proc_D40F                                       ; $D077: 20 0F D4
  LDA $22                                             ; $D07A: A5 22
  STA a:$0040                                         ; $D07C: 8D 40 00
  RTS                                                 ; $D07F: 60
.endproc

;===============================================================================
; $D080: Proc_D080
;===============================================================================
.proc Proc_D080

  STA $2F                                             ; $D080: 85 2F
  LDA #$00                                            ; $D082: A9 00
  STA $2A                                             ; $D084: 85 2A
  STA $2B                                             ; $D086: 85 2B
  STA $2C                                             ; $D088: 85 2C
  LDA $2A                                             ; $D08A: A5 2A
  JSR Proc_D105                                       ; $D08C: 20 05 D1
  AND #$07                                            ; $D08F: 29 07
  CMP $2F                                             ; $D091: C5 2F
  BNE LD09F                                           ; $D093: D0 0A
  JSR $D307                                           ; $D095: 20 07 D3
  CLC                                                 ; $D098: 18
  ADC $2C                                             ; $D099: 65 2C
  STA $2C                                             ; $D09B: 85 2C
  INC $2B                                             ; $D09D: E6 2B
LD09F:
  INC $2A                                             ; $D09F: E6 2A
  LDA $2A                                             ; $D0A1: A5 2A
  CMP #$1E                                            ; $D0A3: C9 1E
  .byte $90,$E3                                       ; $D0A5: 90 E3 (BCC mid-instruction target)
  LDA $2B                                             ; $D0A7: A5 2B
  RTS                                                 ; $D0A9: 60
.endproc
LD09F = $D09F


;===============================================================================
; $D0AA: Proc_D0AA
;===============================================================================
.proc Proc_D0AA
  sram_player_id           = $6F03

  LDY #$30                                            ; $D0AA: A0 30
  JSR B1F_SwitchBank8_A                               ; $D0AC: 20 66 F2
  LDA #$00                                            ; $D0AF: A9 00
  STA $2A                                             ; $D0B1: 85 2A
  STA $2B                                             ; $D0B3: 85 2B
  STA $2C                                             ; $D0B5: 85 2C
  LDA $2A                                             ; $D0B7: A5 2A
  JSR Proc_D105                                       ; $D0B9: 20 05 D1
  AND #$07                                            ; $D0BC: 29 07
  CMP $6F03                                           ; $D0BE: CD 03 6F
  BNE LD0D6                                           ; $D0C1: D0 13
  LDA $2A                                             ; $D0C3: A5 2A
  JSR Proc_D0E1                                       ; $D0C5: 20 E1 D0
  BEQ LD0D6                                           ; $D0C8: F0 0C
  LDA $2A                                             ; $D0CA: A5 2A
  JSR Proc_D304                                       ; $D0CC: 20 04 D3
  CLC                                                 ; $D0CF: 18
  ADC $2C                                             ; $D0D0: 65 2C
  STA $2C                                             ; $D0D2: 85 2C
  INC $2B                                             ; $D0D4: E6 2B
LD0D6:
  INC $2A                                             ; $D0D6: E6 2A
  LDA $2A                                             ; $D0D8: A5 2A
  CMP #$1E                                            ; $D0DA: C9 1E
  .byte $90,$D9                                       ; $D0DC: 90 D9 (BCC mid-instruction target)
  LDA $2B                                             ; $D0DE: A5 2B
  RTS                                                 ; $D0E0: 60
.endproc
LD0D6 = $D0D6


;===============================================================================
; $D0E1: Proc_D0E1
;===============================================================================
.proc Proc_D0E1
  math_acc_mhi             = $0022

  ASL A                                               ; $D0E1: 0A
  ASL A                                               ; $D0E2: 0A
  ASL A                                               ; $D0E3: 0A
  TAX                                                 ; $D0E4: AA
  LDA #$00                                            ; $D0E5: A9 00
  STA $22                                             ; $D0E7: 85 22
.endproc

;===============================================================================
; $D0E9: Proc_D0E9
;===============================================================================
.proc Proc_D0E9
  math_acc_mhi             = $0022
  sram_player_id           = $6F03

  LDA $9D72,X                                         ; $D0E9: BD 72 9D
  .byte $30,$14                                       ; $D0EC: 30 14 (BMI mid-instruction target)
  JSR Proc_D105                                       ; $D0EE: 20 05 D1
  AND #$07                                            ; $D0F1: 29 07
  CMP #$07                                            ; $D0F3: C9 07
  BEQ LD0FE                                           ; $D0F5: F0 07
  CMP $6F03                                           ; $D0F7: CD 03 6F
  BEQ LD0FE                                           ; $D0FA: F0 02
  INC $22                                             ; $D0FC: E6 22
LD0FE:
  INX                                                 ; $D0FE: E8
  JMP Proc_D0E9                                       ; $D0FF: 4C E9 D0
  LDA $22                                             ; $D102: A5 22
  RTS                                                 ; $D104: 60
.endproc
LD0FE = $D0FE


;===============================================================================
; $D105: Proc_D105
;===============================================================================
.proc Proc_D105
  math_acc_lo              = $0020
  math_acc_mlo             = $0021

  LDY #$00                                            ; $D105: A0 00
  STY $21                                             ; $D107: 84 21
  ASL A                                               ; $D109: 0A
  ROL $21                                             ; $D10A: 26 21
  ASL A                                               ; $D10C: 0A
  ROL $21                                             ; $D10D: 26 21
  ASL A                                               ; $D10F: 0A
  ROL $21                                             ; $D110: 26 21
  ASL A                                               ; $D112: 0A
  ROL $21                                             ; $D113: 26 21
  ASL A                                               ; $D115: 0A
  ROL $21                                             ; $D116: 26 21
  CLC                                                 ; $D118: 18
  ADC #$00                                            ; $D119: 69 00
  STA $20                                             ; $D11B: 85 20
  LDA $21                                             ; $D11D: A5 21
  ADC #$60                                            ; $D11F: 69 60
  STA $21                                             ; $D121: 85 21
  JSR Proc_D69D                                       ; $D123: 20 9D D6
  LDY #$00                                            ; $D126: A0 00
  LDA ($20),Y                                         ; $D128: B1 20
  AND #$07                                            ; $D12A: 29 07
  RTS                                                 ; $D12C: 60
.endproc

;===============================================================================
; $D12D: Proc_D12D
;===============================================================================
.proc Proc_D12D
  math_acc_lo              = $0020
  sram_counter             = $6F5B
  sram_game_start_flag     = $6F8B

  STA $20                                             ; $D12D: 85 20
  LDA $6F5D                                           ; $D12F: AD 5D 6F
  SEC                                                 ; $D132: 38
  SBC $20                                             ; $D133: E5 20
  STA $6F5D                                           ; $D135: 8D 5D 6F
  .byte $90,$06                                       ; $D138: 90 06 (BCC mid-instruction target)
  INC $6F5E                                           ; $D13A: EE 5E 6F
  JMP SumAndCompare                               ; $D13D: 4C 9C A1
  PLA                                                 ; $D140: 68
  PLA                                                 ; $D141: 68
  LDA #$02                                            ; $D142: A9 02
  STA $6F5B                                           ; $D144: 8D 5B 6F
  LDA #$FF                                            ; $D147: A9 FF
  STA $6F8B                                           ; $D149: 8D 8B 6F
  LDA #$00                                            ; $D14C: A9 00
  STA $6F8D                                           ; $D14E: 8D 8D 6F
  RTS                                                 ; $D151: 60
.endproc

;===============================================================================
; $D152: Proc_D152
;===============================================================================
.proc Proc_D152
  math_acc_lo              = $0020

  STA $20                                             ; $D152: 85 20
  LDA $6F5D                                           ; $D154: AD 5D 6F
  SEC                                                 ; $D157: 38
  SBC $20                                             ; $D158: E5 20
  STA $6F5D                                           ; $D15A: 8D 5D 6F
  BEQ LD161                                           ; $D15D: F0 02
  .byte $B0,$03                                       ; $D15F: B0 03 (BCS mid-instruction target)
LD161:
  JMP $D140                                           ; $D161: 4C 40 D1
  RTS                                                 ; $D164: 60
.endproc
LD161 = $D161


;===============================================================================
; $D165: Proc_D165
;===============================================================================
.proc Proc_D165
  math_acc_lo              = $0020

  STA $20                                             ; $D165: 85 20
  LDA $6F5D                                           ; $D167: AD 5D 6F
  SEC                                                 ; $D16A: 38
  SBC $20                                             ; $D16B: E5 20
  STA $6F5D                                           ; $D16D: 8D 5D 6F
  .byte $B0,$05                                       ; $D170: B0 05 (BCS mid-instruction target)
  PLA                                                 ; $D172: 68
  PLA                                                 ; $D173: 68
  JMP $D140                                           ; $D174: 4C 40 D1
  RTS                                                 ; $D177: 60
.endproc

;===============================================================================
; $D178: Proc_D178
;===============================================================================
.proc Proc_D178
  math_acc_lo              = $0020

  STA $20                                             ; $D178: 85 20
  LDA $6F5D                                           ; $D17A: AD 5D 6F
  SEC                                                 ; $D17D: 38
  SBC $20                                             ; $D17E: E5 20
  STA $6F5D                                           ; $D180: 8D 5D 6F
  .byte $B0,$07                                       ; $D183: B0 07 (BCS mid-instruction target)
  PLA                                                 ; $D185: 68
  PLA                                                 ; $D186: 68
  PLA                                                 ; $D187: 68
  PLA                                                 ; $D188: 68
  JMP $D140                                           ; $D189: 4C 40 D1
  RTS                                                 ; $D18C: 60
.endproc

;===============================================================================
; $D18D: Proc_D18D
;===============================================================================
.proc Proc_D18D
  math_acc_lo              = $0020

  STA $20                                             ; $D18D: 85 20
  LDA $6F5D                                           ; $D18F: AD 5D 6F
  SEC                                                 ; $D192: 38
  SBC $20                                             ; $D193: E5 20
  STA $6F5D                                           ; $D195: 8D 5D 6F
  .byte $B0,$09                                       ; $D198: B0 09 (BCS mid-instruction target)
  PLA                                                 ; $D19A: 68
  PLA                                                 ; $D19B: 68
  PLA                                                 ; $D19C: 68
  PLA                                                 ; $D19D: 68
  PLA                                                 ; $D19E: 68
  PLA                                                 ; $D19F: 68
  JMP $D140                                           ; $D1A0: 4C 40 D1
  RTS                                                 ; $D1A3: 60
.endproc

;===============================================================================
; $D1A4: Proc_D1A4
;===============================================================================
.proc Proc_D1A4
  math_acc_hi              = $0023
  math_ext                 = $0024
  work_outer_idx           = $0036
  sram_player_id           = $6F03

  LDA $6F03                                           ; $D1A4: AD 03 6F
  STA $2A                                             ; $D1A7: 85 2A
  LDY #$30                                            ; $D1A9: A0 30
  JSR B1F_SwitchBank8_A                               ; $D1AB: 20 66 F2
  LDY #$0F                                            ; $D1AE: A0 0F
  LDA #$FF                                            ; $D1B0: A9 FF
LD1B2:
  STA $6F73,Y                                         ; $D1B2: 99 73 6F
  DEY                                                 ; $D1B5: 88
  BPL LD1B2                                           ; $D1B6: 10 FA
  LDA #$00                                            ; $D1B8: A9 00
  STA $2B                                             ; $D1BA: 85 2B
  STA $2C                                             ; $D1BC: 85 2C
  LDA a:$0036                                         ; $D1BE: AD 36 00
  ASL A                                               ; $D1C1: 0A
  ASL A                                               ; $D1C2: 0A
  ASL A                                               ; $D1C3: 0A
  TAY                                                 ; $D1C4: A8
LD1C5:
  LDA $9D72,Y                                         ; $D1C5: B9 72 9D
  BMI LD1F1                                           ; $D1C8: 30 27
  STA $23                                             ; $D1CA: 85 23
  STY $24                                             ; $D1CC: 84 24
  JSR Proc_D105                                       ; $D1CE: 20 05 D1
  AND #$07                                            ; $D1D1: 29 07
  CMP #$07                                            ; $D1D3: C9 07
  BEQ LD1E4                                           ; $D1D5: F0 0D
  CMP $2A                                             ; $D1D7: C5 2A
  BEQ LD1E4                                           ; $D1D9: F0 09
  LDY $2B                                             ; $D1DB: A4 2B
  LDA $23                                             ; $D1DD: A5 23
  STA $6F73,Y                                         ; $D1DF: 99 73 6F
  INC $2B                                             ; $D1E2: E6 2B
LD1E4:
  LDA $23                                             ; $D1E4: A5 23
  LDY $24                                             ; $D1E6: A4 24
  INY                                                 ; $D1E8: C8
  INC $2C                                             ; $D1E9: E6 2C
  LDX $2C                                             ; $D1EB: A6 2C
  CPX #$08                                            ; $D1ED: E0 08
  BCC LD1C5                                           ; $D1EF: 90 D4
LD1F1:
  LDA $2B                                             ; $D1F1: A5 2B
  RTS                                                 ; $D1F3: 60
.endproc
LD1B2 = $D1B2
LD1C5 = $D1C5
LD1E4 = $D1E4
LD1F1 = $D1F1


;===============================================================================
; $D1F4: Proc_D1F4
;===============================================================================
.proc Proc_D1F4
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  work_outer_idx           = $0036
  work_inner_idx           = $0037
  sram_player_id           = $6F03

  LDA $6F03                                           ; $D1F4: AD 03 6F
  STA $2A                                             ; $D1F7: 85 2A
  LDY #$30                                            ; $D1F9: A0 30
  JSR B1F_SwitchBank8_A                               ; $D1FB: 20 66 F2
  LDY #$0F                                            ; $D1FE: A0 0F
  LDA #$FF                                            ; $D200: A9 FF
LD202:
  STA $6F73,Y                                         ; $D202: 99 73 6F
  DEY                                                 ; $D205: 88
  BPL LD202                                           ; $D206: 10 FA
  LDA #$00                                            ; $D208: A9 00
  STA a:$0037                                         ; $D20A: 8D 37 00
  LDA a:$0036                                         ; $D20D: AD 36 00
  ASL A                                               ; $D210: 0A
  ASL A                                               ; $D211: 0A
  ASL A                                               ; $D212: 0A
  TAY                                                 ; $D213: A8
  LDX #$00                                            ; $D214: A2 00
LD216:
  LDA $9D72,Y                                         ; $D216: B9 72 9D
  .byte $30,$2A                                       ; $D219: 30 2A (BMI mid-instruction target)
  STA $23                                             ; $D21B: 85 23
  STY $24                                             ; $D21D: 84 24
  STX $25                                             ; $D21F: 86 25
  JSR Proc_D105                                       ; $D221: 20 05 D1
  AND #$07                                            ; $D224: 29 07
  CMP #$07                                            ; $D226: C9 07
  BEQ LD239                                           ; $D228: F0 0F
  CMP $2A                                             ; $D22A: C5 2A
  BEQ LD239                                           ; $D22C: F0 0B
  LDY a:$0037                                         ; $D22E: AC 37 00
  LDA $23                                             ; $D231: A5 23
  STA $6F73,Y                                         ; $D233: 99 73 6F
  INC a:$0037                                         ; $D236: EE 37 00
LD239:
  LDA $23                                             ; $D239: A5 23
  LDY $24                                             ; $D23B: A4 24
  LDX $25                                             ; $D23D: A6 25
  INY                                                 ; $D23F: C8
  INX                                                 ; $D240: E8
  CPX #$08                                            ; $D241: E0 08
  BCC LD216                                           ; $D243: 90 D1
  LDA a:$0037                                         ; $D245: AD 37 00
  RTS                                                 ; $D248: 60
.endproc
LD202 = $D202
LD216 = $D216
LD239 = $D239


;===============================================================================
; $D249: Proc_D249
;===============================================================================
.proc Proc_D249
  math_acc_lo              = $0020
  work_outer_idx           = $0036
  sram_player_id           = $6F03

  JSR Proc_D6E5                                       ; $D249: 20 E5 D6
  LDA #$00                                            ; $D24C: A9 00
  STA a:$0036                                         ; $D24E: 8D 36 00
  LDY #$00                                            ; $D251: A0 00
  LDA ($EE),Y                                         ; $D253: B1 EE
  STA $2A                                             ; $D255: 85 2A
LD257:
  LDA a:$0036                                         ; $D257: AD 36 00
  JSR Proc_D105                                       ; $D25A: 20 05 D1
  AND #$07                                            ; $D25D: 29 07
  CMP $6F03                                           ; $D25F: CD 03 6F
  .byte $D0,$11                                       ; $D262: D0 11 (BNE mid-instruction target)
  LDY #$11                                            ; $D264: A0 11
  LDA ($20),Y                                         ; $D266: B1 20
  CMP $2A                                             ; $D268: C5 2A
  BNE LD270                                           ; $D26A: D0 04
  LDA a:$0036                                         ; $D26C: AD 36 00
  RTS                                                 ; $D26F: 60
LD270:
  INY                                                 ; $D270: C8
  CPY #$1B                                            ; $D271: C0 1B
  .byte $90,$F1                                       ; $D273: 90 F1 (BCC mid-instruction target)
  INC a:$0036                                         ; $D275: EE 36 00
  LDA a:$0036                                         ; $D278: AD 36 00
  CMP #$1E                                            ; $D27B: C9 1E
  BCC LD257                                           ; $D27D: 90 D8
  LDA #$FF                                            ; $D27F: A9 FF
  CLC                                                 ; $D281: 18
  RTS                                                 ; $D282: 60
.endproc
LD257 = $D257
LD270 = $D270


;===============================================================================
; $D283: Proc_D283
;===============================================================================
.proc Proc_D283
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023

  LDX #$00                                            ; $D283: A2 00
  STX $21                                             ; $D285: 86 21
  STA $20                                             ; $D287: 85 20
  ASL A                                               ; $D289: 0A
  ROL $21                                             ; $D28A: 26 21
  CLC                                                 ; $D28C: 18
  ADC $20                                             ; $D28D: 65 20
  PHA                                                 ; $D28F: 48
  LDA $21                                             ; $D290: A5 21
  ADC #$00                                            ; $D292: 69 00
  STA $21                                             ; $D294: 85 21
  PLA                                                 ; $D296: 68
  ASL A                                               ; $D297: 0A
  ROL $21                                             ; $D298: 26 21
  ASL A                                               ; $D29A: 0A
  ROL $21                                             ; $D29B: 26 21
  CLC                                                 ; $D29D: 18
  ADC #$C0                                            ; $D29E: 69 C0
  STA $20                                             ; $D2A0: 85 20
  LDA $21                                             ; $D2A2: A5 21
  ADC #$63                                            ; $D2A4: 69 63
  STA $21                                             ; $D2A6: 85 21
  LDA ($20),Y                                         ; $D2A8: B1 20
  RTS                                                 ; $D2AA: 60
  LDX #$00                                            ; $D2AB: A2 00
  STX $23                                             ; $D2AD: 86 23
  STA $22                                             ; $D2AF: 85 22
  ASL A                                               ; $D2B1: 0A
  ROL $23                                             ; $D2B2: 26 23
  CLC                                                 ; $D2B4: 18
  ADC $22                                             ; $D2B5: 65 22
  PHA                                                 ; $D2B7: 48
  LDA $23                                             ; $D2B8: A5 23
  ADC #$00                                            ; $D2BA: 69 00
  STA $23                                             ; $D2BC: 85 23
  PLA                                                 ; $D2BE: 68
  ASL A                                               ; $D2BF: 0A
  ROL $23                                             ; $D2C0: 26 23
  ASL A                                               ; $D2C2: 0A
  ROL $23                                             ; $D2C3: 26 23
  CLC                                                 ; $D2C5: 18
  ADC #$C0                                            ; $D2C6: 69 C0
  STA $22                                             ; $D2C8: 85 22
  LDA $23                                             ; $D2CA: A5 23
  ADC #$63                                            ; $D2CC: 69 63
  STA $23                                             ; $D2CE: 85 23
  LDA ($22),Y                                         ; $D2D0: B1 22
  RTS                                                 ; $D2D2: 60
.endproc

;===============================================================================
; $D2D3: Proc_D2D3
;===============================================================================
.proc Proc_D2D3
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026

  STY $26                                             ; $D2D3: 84 26
  LDY #$31                                            ; $D2D5: A0 31
  JSR B1F_SwitchBank8_A                               ; $D2D7: 20 66 F2
  LDX #$00                                            ; $D2DA: A2 00
  STX $25                                             ; $D2DC: 86 25
  STA $24                                             ; $D2DE: 85 24
  ASL A                                               ; $D2E0: 0A
  ROL $25                                             ; $D2E1: 26 25
  CLC                                                 ; $D2E3: 18
  ADC $24                                             ; $D2E4: 65 24
  PHA                                                 ; $D2E6: 48
  LDA $25                                             ; $D2E7: A5 25
  ADC #$00                                            ; $D2E9: 69 00
  STA $25                                             ; $D2EB: 85 25
  PLA                                                 ; $D2ED: 68
  ASL A                                               ; $D2EE: 0A
  ROL $25                                             ; $D2EF: 26 25
  ASL A                                               ; $D2F1: 0A
  ROL $25                                             ; $D2F2: 26 25
  CLC                                                 ; $D2F4: 18
  ADC #$00                                            ; $D2F5: 69 00
  STA $24                                             ; $D2F7: 85 24
  LDA $25                                             ; $D2F9: A5 25
  ADC #$80                                            ; $D2FB: 69 80
  STA $25                                             ; $D2FD: 85 25
  LDY $26                                             ; $D2FF: A4 26
  LDA ($24),Y                                         ; $D301: B1 24
  RTS                                                 ; $D303: 60
.endproc

;===============================================================================
; $D304: Proc_D304
;===============================================================================
.proc Proc_D304
  math_acc_lo              = $0020

  JSR Proc_D105                                       ; $D304: 20 05 D1
  LDX #$00                                            ; $D307: A2 00
  LDY #$11                                            ; $D309: A0 11
  LDA ($20),Y                                         ; $D30B: B1 20
  CMP #$FF                                            ; $D30D: C9 FF
  BEQ LD317                                           ; $D30F: F0 06
  INX                                                 ; $D311: E8
  INY                                                 ; $D312: C8
  CPY #$1B                                            ; $D313: C0 1B
  .byte $90,$F4                                       ; $D315: 90 F4 (BCC mid-instruction target)
LD317:
  TXA                                                 ; $D317: 8A
  RTS                                                 ; $D318: 60
.endproc
LD317 = $D317


;===============================================================================
; $D319: Proc_D319
;===============================================================================
.proc Proc_D319
  math_ext                 = $0024
  math_temp1               = $0025

  AND #$0F                                            ; $D319: 29 0F
  ASL A                                               ; $D31B: 0A
  TAY                                                 ; $D31C: A8
  LDA $D328,Y                                         ; $D31D: B9 28 D3
  STA $24                                             ; $D320: 85 24
  LDA $D329,Y                                         ; $D322: B9 29 D3
  STA $25                                             ; $D325: 85 25
  RTS                                                 ; $D327: 60
  .byte $07,$6F,$0F,$6F,$17,$6F,$1F,$6F,$27,$6F,$2F,$6F,$37,$6F; $D328: 07 6F 0F 6F 17 6F 1F 6F 27 6F 2F 6F 37 6F
.endproc

;===============================================================================
; $D336: Proc_D336
;===============================================================================
.proc Proc_D336
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026
  math_temp3               = $0027

  LDA #$00                                            ; $D336: A9 00
  STA $25                                             ; $D338: 85 25
  STA $26                                             ; $D33A: 85 26
  STA $27                                             ; $D33C: 85 27
  LDY #$17                                            ; $D33E: A0 17
LD340:
  ASL $20                                             ; $D340: 06 20
  ROL $21                                             ; $D342: 26 21
  ROL $22                                             ; $D344: 26 22
  ROL $25                                             ; $D346: 26 25
  ROL $26                                             ; $D348: 26 26
  ROL $27                                             ; $D34A: 26 27
  LDA $25                                             ; $D34C: A5 25
  SEC                                                 ; $D34E: 38
  SBC $23                                             ; $D34F: E5 23
  STA $28                                             ; $D351: 85 28
  LDA $26                                             ; $D353: A5 26
  SBC $24                                             ; $D355: E5 24
  STA $29                                             ; $D357: 85 29
  LDA $27                                             ; $D359: A5 27
  SBC #$00                                            ; $D35B: E9 00
  .byte $90,$0C                                       ; $D35D: 90 0C (BCC mid-instruction target)
  STA $27                                             ; $D35F: 85 27
  LDA $28                                             ; $D361: A5 28
  STA $25                                             ; $D363: 85 25
  LDA $29                                             ; $D365: A5 29
  STA $26                                             ; $D367: 85 26
  INC $20                                             ; $D369: E6 20
  DEY                                                 ; $D36B: 88
  BPL LD340                                           ; $D36C: 10 D2
  RTS                                                 ; $D36E: 60
.endproc
LD340 = $D340


;===============================================================================
; $D36F: Proc_D36F
;===============================================================================
.proc Proc_D36F
  math_acc_lo              = $0020
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024

  PHA                                                 ; $D36F: 48
  JSR Proc_D105                                       ; $D370: 20 05 D1
  LDA $24                                             ; $D373: A5 24
  BEQ LD385                                           ; $D375: F0 0E
  JSR Proc_D4BB                                       ; $D377: 20 BB D4
  CLC                                                 ; $D37A: 18
  ADC $22                                             ; $D37B: 65 22
  STA $22                                             ; $D37D: 85 22
  LDA $23                                             ; $D37F: A5 23
  ADC #$00                                            ; $D381: 69 00
  STA $23                                             ; $D383: 85 23
LD385:
  PLA                                                 ; $D385: 68
  JSR Proc_D105                                       ; $D386: 20 05 D1
  JSR Proc_D69D                                       ; $D389: 20 9D D6
  LDY #$02                                            ; $D38C: A0 02
  LDA ($20),Y                                         ; $D38E: B1 20
  SEC                                                 ; $D390: 38
  SBC $22                                             ; $D391: E5 22
  PHA                                                 ; $D393: 48
  INY                                                 ; $D394: C8
  LDA ($20),Y                                         ; $D395: B1 20
  SBC $23                                             ; $D397: E5 23
  BCS LD39E                                           ; $D399: B0 03
  PLA                                                 ; $D39B: 68
  CLC                                                 ; $D39C: 18
  RTS                                                 ; $D39D: 60
LD39E:
  STA ($20),Y                                         ; $D39E: 91 20
  DEY                                                 ; $D3A0: 88
  PLA                                                 ; $D3A1: 68
  STA ($20),Y                                         ; $D3A2: 91 20
  JSR Proc_D69D                                       ; $D3A4: 20 9D D6
  SEC                                                 ; $D3A7: 38
  RTS                                                 ; $D3A8: 60
.endproc
LD385 = $D385
LD39E = $D39E


;===============================================================================
; $D3A9: Proc_D3A9
;===============================================================================
.proc Proc_D3A9
  math_acc_lo              = $0020
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024

  PHA                                                 ; $D3A9: 48
  JSR Proc_D105                                       ; $D3AA: 20 05 D1
  LDA $24                                             ; $D3AD: A5 24
  BEQ LD3BF                                           ; $D3AF: F0 0E
  JSR Proc_D4BB                                       ; $D3B1: 20 BB D4
  CLC                                                 ; $D3B4: 18
  ADC $22                                             ; $D3B5: 65 22
  STA $22                                             ; $D3B7: 85 22
  LDA $23                                             ; $D3B9: A5 23
  ADC #$00                                            ; $D3BB: 69 00
  STA $23                                             ; $D3BD: 85 23
LD3BF:
  PLA                                                 ; $D3BF: 68
  JSR Proc_D105                                       ; $D3C0: 20 05 D1
  LDY #$04                                            ; $D3C3: A0 04
  LDA ($20),Y                                         ; $D3C5: B1 20
  SEC                                                 ; $D3C7: 38
  SBC $22                                             ; $D3C8: E5 22
  PHA                                                 ; $D3CA: 48
  INY                                                 ; $D3CB: C8
  LDA ($20),Y                                         ; $D3CC: B1 20
  SBC $23                                             ; $D3CE: E5 23
  BCS LD3D5                                           ; $D3D0: B0 03
  PLA                                                 ; $D3D2: 68
  CLC                                                 ; $D3D3: 18
  RTS                                                 ; $D3D4: 60
LD3D5:
  STA ($20),Y                                         ; $D3D5: 91 20
  DEY                                                 ; $D3D7: 88
  PLA                                                 ; $D3D8: 68
  STA ($20),Y                                         ; $D3D9: 91 20
  SEC                                                 ; $D3DB: 38
  RTS                                                 ; $D3DC: 60
.endproc
LD3BF = $D3BF
LD3D5 = $D3D5


;===============================================================================
; $D3DD: Proc_D3DD
;===============================================================================
.proc Proc_D3DD
  math_acc_lo              = $0020

  JSR Proc_D105                                       ; $D3DD: 20 05 D1
  LDX #$00                                            ; $D3E0: A2 00
  LDA #$FF                                            ; $D3E2: A9 FF
LD3E4:
  STA $6F73,X                                         ; $D3E4: 9D 73 6F
  INX                                                 ; $D3E7: E8
  CPX #$10                                            ; $D3E8: E0 10
  BCC LD3E4                                           ; $D3EA: 90 F8
  LDY #$11                                            ; $D3EC: A0 11
  LDX #$00                                            ; $D3EE: A2 00
LD3F0:
  LDA ($20),Y                                         ; $D3F0: B1 20
  CMP #$FF                                            ; $D3F2: C9 FF
  BEQ LD3FA                                           ; $D3F4: F0 04
  STA $6F73,X                                         ; $D3F6: 9D 73 6F
  INX                                                 ; $D3F9: E8
LD3FA:
  INY                                                 ; $D3FA: C8
  CPY #$1B                                            ; $D3FB: C0 1B
  BCC LD3F0                                           ; $D3FD: 90 F1
  LDY #$11                                            ; $D3FF: A0 11
  LDX #$00                                            ; $D401: A2 00
LD403:
  LDA $6F73,X                                         ; $D403: BD 73 6F
  STA ($20),Y                                         ; $D406: 91 20
  INY                                                 ; $D408: C8
  INX                                                 ; $D409: E8
  CPY #$1B                                            ; $D40A: C0 1B
  BCC LD403                                           ; $D40C: 90 F5
  RTS                                                 ; $D40E: 60
.endproc
LD3E4 = $D3E4
LD3F0 = $D3F0
LD3FA = $D3FA
LD403 = $D403


;===============================================================================
; $D40F: Proc_D40F
;===============================================================================
.proc Proc_D40F
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026
  math_temp3               = $0027

  LDA #$00                                            ; $D40F: A9 00
  STA $25                                             ; $D411: 85 25
  STA $26                                             ; $D413: 85 26
  LDY #$0F                                            ; $D415: A0 0F
LD417:
  ASL $21                                             ; $D417: 06 21
  ROL $22                                             ; $D419: 26 22
  ROL $25                                             ; $D41B: 26 25
  ROL $26                                             ; $D41D: 26 26
  LDA $25                                             ; $D41F: A5 25
  SEC                                                 ; $D421: 38
  SBC $23                                             ; $D422: E5 23
  STA $27                                             ; $D424: 85 27
  LDA $26                                             ; $D426: A5 26
  SBC $24                                             ; $D428: E5 24
  .byte $90,$08                                       ; $D42A: 90 08 (BCC mid-instruction target)
  STA $26                                             ; $D42C: 85 26
  LDA $27                                             ; $D42E: A5 27
  STA $25                                             ; $D430: 85 25
  INC $21                                             ; $D432: E6 21
  DEY                                                 ; $D434: 88
  BPL LD417                                           ; $D435: 10 E0
  RTS                                                 ; $D437: 60
.endproc
LD417 = $D417


;===============================================================================
; $D438: Proc_D438
;===============================================================================
.proc Proc_D438
  math_acc_lo              = $0020
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022
  math_acc_hi              = $0023
  math_ext                 = $0024
  math_temp1               = $0025
  math_temp2               = $0026
  math_temp3               = $0027

  LDY #$07                                            ; $D438: A0 07
  LDA #$00                                            ; $D43A: A9 00
  STA $24                                             ; $D43C: 85 24
  STA $25                                             ; $D43E: 85 25
  STA $26                                             ; $D440: 85 26
  STA $27                                             ; $D442: 85 27
  STA $28                                             ; $D444: 85 28
  STA $29                                             ; $D446: 85 29
  LSR $23                                             ; $D448: 46 23
  .byte $90,$19                                       ; $D44A: 90 19 (BCC mid-instruction target)
  LDA $20                                             ; $D44C: A5 20
  CLC                                                 ; $D44E: 18
  ADC $26                                             ; $D44F: 65 26
  STA $26                                             ; $D451: 85 26
  LDA $21                                             ; $D453: A5 21
  ADC $27                                             ; $D455: 65 27
  STA $27                                             ; $D457: 85 27
  LDA $22                                             ; $D459: A5 22
  ADC $28                                             ; $D45B: 65 28
  STA $28                                             ; $D45D: 85 28
  LDA $24                                             ; $D45F: A5 24
  ADC $29                                             ; $D461: 65 29
  STA $29                                             ; $D463: 85 29
  ASL $20                                             ; $D465: 06 20
  ROL $21                                             ; $D467: 26 21
  ROL $22                                             ; $D469: 26 22
  ROL $24                                             ; $D46B: 26 24
  DEY                                                 ; $D46D: 88
  .byte $10,$D8                                       ; $D46E: 10 D8 (BPL mid-instruction target)
  RTS                                                 ; $D470: 60
.endproc

;===============================================================================
; $D471: Proc_D471
;===============================================================================
.proc Proc_D471
  math_acc_lo              = $0020
  math_acc_mlo             = $0021

  LDY #$07                                            ; $D471: A0 07
  LDA #$00                                            ; $D473: A9 00
  STA $2C                                             ; $D475: 85 2C
  STA $2A                                             ; $D477: 85 2A
  STA $2B                                             ; $D479: 85 2B
LD47B:
  LSR $21                                             ; $D47B: 46 21
  BCC LD48C                                           ; $D47D: 90 0D
  LDA $20                                             ; $D47F: A5 20
  CLC                                                 ; $D481: 18
  ADC $2A                                             ; $D482: 65 2A
  STA $2A                                             ; $D484: 85 2A
  LDA $2C                                             ; $D486: A5 2C
  ADC $2B                                             ; $D488: 65 2B
  STA $2B                                             ; $D48A: 85 2B
LD48C:
  ASL $20                                             ; $D48C: 06 20
  ROL $2C                                             ; $D48E: 26 2C
  DEY                                                 ; $D490: 88
  BPL LD47B                                           ; $D491: 10 E8
  RTS                                                 ; $D493: 60
.endproc
LD47B = $D47B
LD48C = $D48C


;===============================================================================
; $D494: JumpDispatcher
; Big-endian inline jump table dispatcher.
; Caller: A = table index, inline big-endian word table follows JSR.
; Reads target address from table and JMP indirect to it.
; Preserves original Y in $20 for the target routine.
;===============================================================================
.proc JumpDispatcher
  saved_Y                  = $0020
  table_ptr_lo             = $0021
  table_ptr_hi             = $0022
  target_hi                = $0023
  target_lo                = $0024

  STY saved_Y                                         ; $D494: 84 20
  ASL A                                               ; $D496: 0A  ; idx * 2 (word entries)
  TAY                                                 ; $D497: A8
  INY                                                 ; $D498: C8  ; +1 (JSR pushes addr-1)
  PLA                                                 ; $D499: 68  ; pull table ptr lo
  STA table_ptr_lo                                    ; $D49A: 85 21
  PLA                                                 ; $D49C: 68  ; pull table ptr hi
  STA table_ptr_hi                                    ; $D49D: 85 22
  LDA (table_ptr_lo),Y                                ; $D49F: B1 21 ; read target HI byte
  STA target_hi                                       ; $D4A1: 85 23
  INY                                                 ; $D4A3: C8
  LDA (table_ptr_lo),Y                                ; $D4A4: B1 21 ; read target LO byte
  STA target_lo                                       ; $D4A6: 85 24
  LDY saved_Y                                         ; $D4A8: A4 20 ; restore caller's Y
  JMP (target_hi)                                     ; $D4AA: 6C 23 00
.endproc

;===============================================================================
; $D4AD: Proc_D4AD
;===============================================================================
.proc Proc_D4AD

  STA a:$0056                                         ; $D4AD: 8D 56 00
LD4B0:
  JSR B1F_RandomByte2                                 ; $D4B0: 20 8A E8
  AND #$0F                                            ; $D4B3: 29 0F
  CMP a:$0056                                         ; $D4B5: CD 56 00
  BCS LD4B0                                           ; $D4B8: B0 F6
  RTS                                                 ; $D4BA: 60
.endproc
LD4B0 = $D4B0


;===============================================================================
; $D4BB: Proc_D4BB
;===============================================================================
.proc Proc_D4BB

  CMP #$0F                                            ; $D4BB: C9 0F
  .byte $90,$EE                                       ; $D4BD: 90 EE (BCC cross-proc)
  STA a:$0056                                         ; $D4BF: 8D 56 00
LD4C2:
  JSR B1F_RandomByte2                                 ; $D4C2: 20 8A E8
  CMP a:$0056                                         ; $D4C5: CD 56 00
  BCS LD4C2                                           ; $D4C8: B0 F8
  RTS                                                 ; $D4CA: 60
.endproc
LD4C2 = $D4C2


;===============================================================================
; $D4CB: Proc_D4CB
;===============================================================================
.proc Proc_D4CB
  math_ext                 = $0024
  math_temp1               = $0025
  work_outer_idx           = $0036
  sram_player_id           = $6F03

  LDY #$7F                                            ; $D4CB: A0 7F
  LDA #$00                                            ; $D4CD: A9 00
LD4CF:
  STA $0580,Y                                         ; $D4CF: 99 80 05
  DEY                                                 ; $D4D2: 88
  BPL LD4CF                                           ; $D4D3: 10 FA
  LDY #$30                                            ; $D4D5: A0 30
  JSR B1F_SwitchBank8_A                               ; $D4D7: 20 66 F2
  LDA #$1D                                            ; $D4DA: A9 1D
  STA a:$0036                                         ; $D4DC: 8D 36 00
LD4DF:
  LDA a:$0036                                         ; $D4DF: AD 36 00
  JSR Proc_D105                                       ; $D4E2: 20 05 D1
  AND #$07                                            ; $D4E5: 29 07
  CMP $6F03                                           ; $D4E7: CD 03 6F
  BNE LD524                                           ; $D4EA: D0 38
  LDA a:$0036                                         ; $D4EC: AD 36 00
  ASL A                                               ; $D4EF: 0A
  ASL A                                               ; $D4F0: 0A
  ASL A                                               ; $D4F1: 0A
  STA $24                                             ; $D4F2: 85 24
  LDY $24                                             ; $D4F4: A4 24
  LDA $9D72,Y                                         ; $D4F6: B9 72 9D
  BMI LD524                                           ; $D4F9: 30 29
  STA $25                                             ; $D4FB: 85 25
  JSR Proc_D105                                       ; $D4FD: 20 05 D1
  AND #$07                                            ; $D500: 29 07
  CMP $6F03                                           ; $D502: CD 03 6F
  .byte $D0,$18                                       ; $D505: D0 18 (BNE mid-instruction target)
  LDX $25                                             ; $D507: A6 25
  LDA a:$0036                                         ; $D509: AD 36 00
  CLC                                                 ; $D50C: 18
  ADC $D5BF,X                                         ; $D50D: 7D BF D5
  TAY                                                 ; $D510: A8
  LDA $25                                             ; $D511: A5 25
  AND #$07                                            ; $D513: 29 07
  TAX                                                 ; $D515: AA
  LDA $D5DF,X                                         ; $D516: BD DF D5
  ORA $0580,Y                                         ; $D519: 19 80 05
  STA $0580,Y                                         ; $D51C: 99 80 05
  INC $24                                             ; $D51F: E6 24
  JMP $D4F4                                           ; $D521: 4C F4 D4
LD524:
  DEC a:$0036                                         ; $D524: CE 36 00
  BPL LD4DF                                           ; $D527: 10 B6
  LDY #$01                                            ; $D529: A0 01
  LDX #$00                                            ; $D52B: A2 00
LD52D:
  JSR Proc_D53E                                       ; $D52D: 20 3E D5
  INY                                                 ; $D530: C8
  CPY #$1E                                            ; $D531: C0 1E
  BCC LD52D                                           ; $D533: 90 F8
  INX                                                 ; $D535: E8
  TXA                                                 ; $D536: 8A
  TAY                                                 ; $D537: A8
  INX                                                 ; $D538: E8
  CPX #$1D                                            ; $D539: E0 1D
  BCC LD52D                                           ; $D53B: 90 F0
  RTS                                                 ; $D53D: 60
.endproc
LD4CF = $D4CF
LD4DF = $D4DF
LD524 = $D524
LD52D = $D52D


;===============================================================================
; $D53E: Proc_D53E
;===============================================================================
.proc Proc_D53E

  LDA $0580,X                                         ; $D53E: BD 80 05
  AND $0580,Y                                         ; $D541: 39 80 05
  .byte $F0,$09                                       ; $D544: F0 09 (BEQ mid-instruction target)
  LDA $0580,X                                         ; $D546: BD 80 05
  ORA $0580,Y                                         ; $D549: 19 80 05
  STA $0580,Y                                         ; $D54C: 99 80 05
  LDA $05A0,X                                         ; $D54F: BD A0 05
  AND $05A0,Y                                         ; $D552: 39 A0 05
  .byte $F0,$09                                       ; $D555: F0 09 (BEQ mid-instruction target)
  LDA $05A0,X                                         ; $D557: BD A0 05
  ORA $05A0,Y                                         ; $D55A: 19 A0 05
  STA $05A0,Y                                         ; $D55D: 99 A0 05
  LDA $05C0,X                                         ; $D560: BD C0 05
  AND $05C0,Y                                         ; $D563: 39 C0 05
  .byte $F0,$09                                       ; $D566: F0 09 (BEQ mid-instruction target)
  LDA $05C0,X                                         ; $D568: BD C0 05
  ORA $05C0,Y                                         ; $D56B: 19 C0 05
  STA $05C0,Y                                         ; $D56E: 99 C0 05
  LDA $05E0,X                                         ; $D571: BD E0 05
  AND $05E0,Y                                         ; $D574: 39 E0 05
  .byte $F0,$09                                       ; $D577: F0 09 (BEQ mid-instruction target)
  LDA $05E0,X                                         ; $D579: BD E0 05
  ORA $05E0,Y                                         ; $D57C: 19 E0 05
  STA $05E0,Y                                         ; $D57F: 99 E0 05
  RTS                                                 ; $D582: 60
.endproc

;===============================================================================
; $D583: Proc_D583
;===============================================================================
.proc Proc_D583

  STY $31                                             ; $D583: 84 31
  STX $32                                             ; $D585: 86 32
  LDX #$1D                                            ; $D587: A2 1D
  STX $30                                             ; $D589: 86 30
  LDY $31                                             ; $D58B: A4 31
  LDA $30                                             ; $D58D: A5 30
  ORA $D5BF,Y                                         ; $D58F: 19 BF D5
  TAX                                                 ; $D592: AA
  LDA $31                                             ; $D593: A5 31
  AND #$07                                            ; $D595: 29 07
  TAY                                                 ; $D597: A8
  LDA $0580,X                                         ; $D598: BD 80 05
  AND $D5DF,Y                                         ; $D59B: 39 DF D5
  BEQ LD5B8                                           ; $D59E: F0 18
  LDY $32                                             ; $D5A0: A4 32
  LDA $30                                             ; $D5A2: A5 30
  ORA $D5BF,Y                                         ; $D5A4: 19 BF D5
  TAX                                                 ; $D5A7: AA
  LDA $32                                             ; $D5A8: A5 32
  AND #$07                                            ; $D5AA: 29 07
  TAY                                                 ; $D5AC: A8
  LDA $0580,X                                         ; $D5AD: BD 80 05
  AND $D5DF,Y                                         ; $D5B0: 39 DF D5
  BEQ LD5B8                                           ; $D5B3: F0 03
  LDA #$FF                                            ; $D5B5: A9 FF
  RTS                                                 ; $D5B7: 60
LD5B8:
  DEC $30                                             ; $D5B8: C6 30
  .byte $10,$CF                                       ; $D5BA: 10 CF (BPL mid-instruction target)
  LDA #$00                                            ; $D5BC: A9 00
  RTS                                                 ; $D5BE: 60
.endproc
LD5B8 = $D5B8


;===============================================================================
; $D5BF: Proc_D5BF
;===============================================================================
.proc Proc_D5BF

  BRK                                                 ; $D5BF: 00
  .byte $00,$00,$00,$00,$00,$00,$00,$20,$20,$20,$20,$20,$20,$20,$20,$40; $D5C0: 00 00 00 00 00 00 00 20 20 20 20 20 20 20 20 40
  .byte $40,$40,$40,$40,$40,$40,$40,$60,$60,$60,$60,$60,$60,$60,$60,$01; $D5D0: 40 40 40 40 40 40 40 60 60 60 60 60 60 60 60 01
  .byte $02,$04,$08,$10,$20,$40,$80                   ; $D5E0: 02 04 08 10 20 40 80
.endproc

;===============================================================================
; $D5E7: Proc_D5E7
;===============================================================================
.proc Proc_D5E7

  RTS                                                 ; $D5E7: 60
.endproc

;===============================================================================
; $D5E8: Proc_D5E8
;===============================================================================
.proc Proc_D5E8
  math_acc_lo              = $0020

  LDY #$00                                            ; $D5E8: A0 00
  LDA ($20),Y                                         ; $D5EA: B1 20
  CMP #$65                                            ; $D5EC: C9 65
  BCC LD5F6                                           ; $D5EE: 90 06
  LDA #$14                                            ; $D5F0: A9 14
  STA $6FFF                                           ; $D5F2: 8D FF 6F
  BRK                                                 ; $D5F5: 00
LD5F6:
  INY                                                 ; $D5F6: C8
  LDA ($20),Y                                         ; $D5F7: B1 20
  CMP #$65                                            ; $D5F9: C9 65
  BCC LD603                                           ; $D5FB: 90 06
  LDA #$15                                            ; $D5FD: A9 15
  STA $6FFF                                           ; $D5FF: 8D FF 6F
  BRK                                                 ; $D602: 00
LD603:
  INY                                                 ; $D603: C8
  LDA ($20),Y                                         ; $D604: B1 20
  CMP #$65                                            ; $D606: C9 65
  BCC LD610                                           ; $D608: 90 06
  LDA #$16                                            ; $D60A: A9 16
  STA $6FFF                                           ; $D60C: 8D FF 6F
  BRK                                                 ; $D60F: 00
LD610:
  INY                                                 ; $D610: C8
  LDA ($20),Y                                         ; $D611: B1 20
  CMP #$65                                            ; $D613: C9 65
  BCC LD61D                                           ; $D615: 90 06
  LDA #$17                                            ; $D617: A9 17
  STA $6FFF                                           ; $D619: 8D FF 6F
  BRK                                                 ; $D61C: 00
LD61D:
  RTS                                                 ; $D61D: 60
.endproc
LD5F6 = $D5F6
LD603 = $D603
LD610 = $D610
LD61D = $D61D


;===============================================================================
; $D61E: Proc_D61E
;===============================================================================
.proc Proc_D61E

  RTS                                                 ; $D61E: 60
.endproc

;===============================================================================
; $D61F: Proc_D61F
;===============================================================================
.proc Proc_D61F
  math_acc_mhi             = $0022

  LDY #$00                                            ; $D61F: A0 00
  LDA ($22),Y                                         ; $D621: B1 22
  CMP #$65                                            ; $D623: C9 65
  BCC LD62D                                           ; $D625: 90 06
  LDA #$18                                            ; $D627: A9 18
  STA $6FFF                                           ; $D629: 8D FF 6F
  BRK                                                 ; $D62C: 00
LD62D:
  INY                                                 ; $D62D: C8
  LDA ($22),Y                                         ; $D62E: B1 22
  CMP #$65                                            ; $D630: C9 65
  BCC LD63A                                           ; $D632: 90 06
  LDA #$19                                            ; $D634: A9 19
  STA $6FFF                                           ; $D636: 8D FF 6F
  BRK                                                 ; $D639: 00
LD63A:
  INY                                                 ; $D63A: C8
  LDA ($22),Y                                         ; $D63B: B1 22
  CMP #$65                                            ; $D63D: C9 65
  BCC LD647                                           ; $D63F: 90 06
  LDA #$1A                                            ; $D641: A9 1A
  STA $6FFF                                           ; $D643: 8D FF 6F
  BRK                                                 ; $D646: 00
LD647:
  INY                                                 ; $D647: C8
  LDA ($22),Y                                         ; $D648: B1 22
  CMP #$65                                            ; $D64A: C9 65
  BCC LD654                                           ; $D64C: 90 06
  LDA #$1B                                            ; $D64E: A9 1B
  STA $6FFF                                           ; $D650: 8D FF 6F
  BRK                                                 ; $D653: 00
LD654:
  RTS                                                 ; $D654: 60
.endproc
LD62D = $D62D
LD63A = $D63A
LD647 = $D647
LD654 = $D654


;===============================================================================
; $D655: Proc_D655
;===============================================================================
.proc Proc_D655
  math_acc_mhi             = $0022

  LDY #$02                                            ; $D655: A0 02
  LDA ($22),Y                                         ; $D657: B1 22
  SEC                                                 ; $D659: 38
  SBC #$10                                            ; $D65A: E9 10
  INY                                                 ; $D65C: C8
  LDA ($22),Y                                         ; $D65D: B1 22
  SBC #$27                                            ; $D65F: E9 27
  BCC LD66E                                           ; $D661: 90 0B
  LDY #$02                                            ; $D663: A0 02
  LDA #$0F                                            ; $D665: A9 0F
  STA ($22),Y                                         ; $D667: 91 22
  INY                                                 ; $D669: C8
  LDA #$27                                            ; $D66A: A9 27
  STA ($22),Y                                         ; $D66C: 91 22
LD66E:
  LDY #$04                                            ; $D66E: A0 04
  LDA ($22),Y                                         ; $D670: B1 22
  SEC                                                 ; $D672: 38
  SBC #$10                                            ; $D673: E9 10
  INY                                                 ; $D675: C8
  LDA ($22),Y                                         ; $D676: B1 22
  SBC #$27                                            ; $D678: E9 27
  BCC LD687                                           ; $D67A: 90 0B
  LDY #$04                                            ; $D67C: A0 04
  LDA #$0F                                            ; $D67E: A9 0F
  STA ($22),Y                                         ; $D680: 91 22
  INY                                                 ; $D682: C8
  LDA #$27                                            ; $D683: A9 27
  STA ($22),Y                                         ; $D685: 91 22
LD687:
  RTS                                                 ; $D687: 60
.endproc
LD66E = $D66E
LD687 = $D687


;===============================================================================
; $D688: Proc_D688
;===============================================================================
.proc Proc_D688
  math_acc_mhi             = $0022

  LDY #$0C                                            ; $D688: A0 0C
  LDA ($22),Y                                         ; $D68A: B1 22
  SEC                                                 ; $D68C: 38
  SBC #$10                                            ; $D68D: E9 10
  INY                                                 ; $D68F: C8
  LDA ($22),Y                                         ; $D690: B1 22
  SBC #$27                                            ; $D692: E9 27
  BCC LD69C                                           ; $D694: 90 06
  LDA #$1E                                            ; $D696: A9 1E
  STA $6FFF                                           ; $D698: 8D FF 6F
  BRK                                                 ; $D69B: 00
LD69C:
  RTS                                                 ; $D69C: 60
.endproc
LD69C = $D69C


;===============================================================================
; $D69D: Proc_D69D
;===============================================================================
.proc Proc_D69D
  math_acc_lo              = $0020

  LDY #$02                                            ; $D69D: A0 02
  LDA ($20),Y                                         ; $D69F: B1 20
  SEC                                                 ; $D6A1: 38
  SBC #$10                                            ; $D6A2: E9 10
  INY                                                 ; $D6A4: C8
  LDA ($20),Y                                         ; $D6A5: B1 20
  SBC #$27                                            ; $D6A7: E9 27
  .byte $90,$0B                                       ; $D6A9: 90 0B (BCC mid-instruction target)
  LDY #$02                                            ; $D6AB: A0 02
  LDA #$0F                                            ; $D6AD: A9 0F
  STA ($20),Y                                         ; $D6AF: 91 20
  INY                                                 ; $D6B1: C8
  LDA #$27                                            ; $D6B2: A9 27
  STA ($20),Y                                         ; $D6B4: 91 20
  LDY #$04                                            ; $D6B6: A0 04
  LDA ($20),Y                                         ; $D6B8: B1 20
  SEC                                                 ; $D6BA: 38
  SBC #$10                                            ; $D6BB: E9 10
  INY                                                 ; $D6BD: C8
  LDA ($20),Y                                         ; $D6BE: B1 20
  SBC #$27                                            ; $D6C0: E9 27
  .byte $90,$0B                                       ; $D6C2: 90 0B (BCC mid-instruction target)
  LDY #$04                                            ; $D6C4: A0 04
  LDA #$0F                                            ; $D6C6: A9 0F
  STA ($20),Y                                         ; $D6C8: 91 20
  INY                                                 ; $D6CA: C8
  LDA #$27                                            ; $D6CB: A9 27
  STA ($20),Y                                         ; $D6CD: 91 20
  RTS                                                 ; $D6CF: 60
  LDY #$0C                                            ; $D6D0: A0 0C
  LDA ($20),Y                                         ; $D6D2: B1 20
  SEC                                                 ; $D6D4: 38
  SBC #$10                                            ; $D6D5: E9 10
  INY                                                 ; $D6D7: C8
  LDA ($20),Y                                         ; $D6D8: B1 20
  SBC #$27                                            ; $D6DA: E9 27
  BCC LD6E4                                           ; $D6DC: 90 06
  LDA #$21                                            ; $D6DE: A9 21
  STA $6FFF                                           ; $D6E0: 8D FF 6F
  BRK                                                 ; $D6E3: 00
LD6E4:
  RTS                                                 ; $D6E4: 60
.endproc
LD6E4 = $D6E4


;===============================================================================
; $D6E5: Proc_D6E5
;===============================================================================
.proc Proc_D6E5

  RTS                                                 ; $D6E5: 60
.endproc

;===============================================================================
; $D6E6: Proc_D6E6
;===============================================================================
.proc Proc_D6E6
  math_acc_lo              = $0020
  work_outer_idx           = $0036

  LDA #$00                                            ; $D6E6: A9 00
  STA a:$0036                                         ; $D6E8: 8D 36 00
LD6EB:
  LDA a:$0036                                         ; $D6EB: AD 36 00
  JSR Proc_D105                                       ; $D6EE: 20 05 D1
  LDY #$11                                            ; $D6F1: A0 11
  LDA ($20),Y                                         ; $D6F3: B1 20
  CMP #$FF                                            ; $D6F5: C9 FF
  BNE LD707                                           ; $D6F7: D0 0E
  INY                                                 ; $D6F9: C8
  LDA ($20),Y                                         ; $D6FA: B1 20
  CMP #$FF                                            ; $D6FC: C9 FF
  BEQ LD706                                           ; $D6FE: F0 06
  LDA #$22                                            ; $D700: A9 22
  STA $6FFF                                           ; $D702: 8D FF 6F
  BRK                                                 ; $D705: 00
LD706:
  DEY                                                 ; $D706: 88
LD707:
  INY                                                 ; $D707: C8
  CPY #$1A                                            ; $D708: C0 1A
  .byte $90,$E7                                       ; $D70A: 90 E7 (BCC mid-instruction target)
  INC a:$0036                                         ; $D70C: EE 36 00
  LDA a:$0036                                         ; $D70F: AD 36 00
  CMP #$1E                                            ; $D712: C9 1E
  BCC LD6EB                                           ; $D714: 90 D5
  RTS                                                 ; $D716: 60
.endproc
LD6EB = $D6EB
LD706 = $D706
LD707 = $D707


;===============================================================================
; $D717: SubStateDispatch
; Sub-state dispatch: route to specific game phases
;===============================================================================
.proc SubStateDispatch
  state_sub_dispatch       = $0540

  JSR Proc_DD34                                       ; $D717: 20 34 DD
  LDA $0540                                           ; $D71A: AD 40 05
  JSR B1F_CallbackDispatcher                          ; $D71D: 20 DE EA
  ; --- Inline pointer table (5 entries) ---
  .addr CallDomesticDisplay                       ; $D720: 2A D7
  .addr $D74F                                         ; $D722: 4F D7
  .addr RenderOverlay                             ; $D724: 9C D9
  .addr ClearOverlay                              ; $D726: 7E DA
  .addr StackFill                                 ; $D728: 32 D7
.endproc

;===============================================================================
; $D72A: CallDomesticDisplay
;===============================================================================
.proc CallDomesticDisplay

  LDY #$37                                            ; $D72A: A0 37
  JSR B1F_BankedCallbackTrampoline                    ; $D72C: 20 07 EE
  ; --- BankedCallbackTrampoline target ---
  .addr $A021                                         ; $D72F: 21 A0
  RTS                                                 ; $D731: 60
.endproc

;===============================================================================
; $D732: StackFill
;===============================================================================
.proc StackFill
  state_display_idx        = $0541

  LDA $0541                                           ; $D732: AD 41 05
  JSR B1F_CallbackDispatcher                          ; $D735: 20 DE EA
  ; --- Inline pointer table (2 entries) ---
  .addr FillStackLoop                             ; $D738: 3C D7
  .addr Proc_D74C                                     ; $D73A: 4C D7
.endproc

;===============================================================================
; $D73C: FillStackLoop
;===============================================================================
.proc FillStackLoop
  state_display_idx        = $0541

  LDY #$00                                            ; $D73C: A0 00
  LDA #$0F                                            ; $D73E: A9 0F
LD740:
  STA $0100,Y                                         ; $D740: 99 00 01
  INY                                                 ; $D743: C8
  CPY #$20                                            ; $D744: C0 20
  BCC LD740                                           ; $D746: 90 F8
  INC $0541                                           ; $D748: EE 41 05
  RTS                                                 ; $D74B: 60
.endproc
LD740 = $D740


;===============================================================================
; $D74C: Proc_D74C
;===============================================================================
.proc Proc_D74C
  state_sub_dispatch       = $0540
  state_display_idx        = $0541

  JMP $E000                                           ; $D74C: 4C 00 E0
  INC $0470                                           ; $D74F: EE 70 04
  BNE LD757                                           ; $D752: D0 03
  INC $0471                                           ; $D754: EE 71 04
LD757:
  LDA $0470                                           ; $D757: AD 70 04
  CMP #$58                                            ; $D75A: C9 58
  BNE LD770                                           ; $D75C: D0 12
  LDA $0471                                           ; $D75E: AD 71 04
  CMP #$0B                                            ; $D761: C9 0B
  BNE LD770                                           ; $D763: D0 0B
  LDA #$04                                            ; $D765: A9 04
  STA $0540                                           ; $D767: 8D 40 05
  LDA #$00                                            ; $D76A: A9 00
  STA $0541                                           ; $D76C: 8D 41 05
  RTS                                                 ; $D76F: 60
LD770:
  LDA a:$0081                                         ; $D770: AD 81 00
  AND #$08                                            ; $D773: 29 08
  .byte $F0,$0A                                       ; $D775: F0 0A (BEQ mid-instruction target)
  LDA $0541                                           ; $D777: AD 41 05
  CMP #$07                                            ; $D77A: C9 07
  .byte $F0,$03                                       ; $D77C: F0 03 (BEQ mid-instruction target)
  JMP Proc_D90D                                       ; $D77E: 4C 0D D9
  LDA $0541                                           ; $D781: AD 41 05
  JSR B1F_CallbackDispatcher                          ; $D784: 20 DE EA
  ; --- Inline pointer table (9 entries) ---
  .addr Proc_D799                                     ; $D787: 99 D7
  .addr Proc_D7BD                                     ; $D789: BD D7
  .addr Proc_D7EC                                     ; $D78B: EC D7
  .addr Proc_D83B                                     ; $D78D: 3B D8
  .addr Proc_D856                                     ; $D78F: 56 D8
  .addr Proc_D890                                     ; $D791: 90 D8
  .addr Proc_D8AD                                     ; $D793: AD D8
  .addr Proc_D8D9                                     ; $D795: D9 D8
  .addr Proc_D8F8                                     ; $D797: F8 D8
.endproc
LD757 = $D757
LD770 = $D770


;===============================================================================
; $D799: Proc_D799
;===============================================================================
.proc Proc_D799
  state_display_idx        = $0541

  INC $0544                                           ; $D799: EE 44 05
  LDA $0544                                           ; $D79C: AD 44 05
  CMP #$40                                            ; $D79F: C9 40
  BEQ LD7A4                                           ; $D7A1: F0 01
  RTS                                                 ; $D7A3: 60
LD7A4:
  LDA #$04                                            ; $D7A4: A9 04
  STA a:$0088                                         ; $D7A6: 8D 88 00
  LDA #$88                                            ; $D7A9: A9 88
  STA a:$0089                                         ; $D7AB: 8D 89 00
  LDA #$00                                            ; $D7AE: A9 00
  STA a:$0087                                         ; $D7B0: 8D 87 00
  STA $0543                                           ; $D7B3: 8D 43 05
  STA $0544                                           ; $D7B6: 8D 44 05
  INC $0541                                           ; $D7B9: EE 41 05
  RTS                                                 ; $D7BC: 60
.endproc
LD7A4 = $D7A4


;===============================================================================
; $D7BD: Proc_D7BD
;===============================================================================
.proc Proc_D7BD
  state_display_idx        = $0541

  JSR $DCC8                                           ; $D7BD: 20 C8 DC
  LDA a:$0087                                         ; $D7C0: AD 87 00
  .byte $10,$26                                       ; $D7C3: 10 26 (BPL mid-instruction target)
  INC $0543                                           ; $D7C5: EE 43 05
  LDA $0543                                           ; $D7C8: AD 43 05
  CMP #$B8                                            ; $D7CB: C9 B8
  .byte $D0,$1C                                       ; $D7CD: D0 1C (BNE mid-instruction target)
  LDA #$28                                            ; $D7CF: A9 28
  STA $0121                                           ; $D7D1: 8D 21 01
  LDA #$19                                            ; $D7D4: A9 19
  STA $0122                                           ; $D7D6: 8D 22 01
  LDA #$17                                            ; $D7D9: A9 17
  STA $0123                                           ; $D7DB: 8D 23 01
  LDA #$08                                            ; $D7DE: A9 08
  STA $0543                                           ; $D7E0: 8D 43 05
  INC $0541                                           ; $D7E3: EE 41 05
  LDA #$5A                                            ; $D7E6: A9 5A
  JSR $E69B                                           ; $D7E8: 20 9B E6
  RTS                                                 ; $D7EB: 60
.endproc

;===============================================================================
; $D7EC: Proc_D7EC
;===============================================================================
.proc Proc_D7EC
  state_display_idx        = $0541

  LDY #$21                                            ; $D7EC: A0 21
  JSR B1F_SwitchBank8_B                               ; $D7EE: 20 5F F2
  LDA $0543                                           ; $D7F1: AD 43 05
  ASL A                                               ; $D7F4: 0A
  ASL A                                               ; $D7F5: 0A
  ASL A                                               ; $D7F6: 0A
  STA a:$000C                                         ; $D7F7: 8D 0C 00
  LDA #$00                                            ; $D7FA: A9 00
  SEC                                                 ; $D7FC: 38
  SBC a:$000C                                         ; $D7FD: ED 0C 00
  STA a:$000A                                         ; $D800: 8D 0A 00
  LDA a:$000C                                         ; $D803: AD 0C 00
  ASL A                                               ; $D806: 0A
  STA a:$000C                                         ; $D807: 8D 0C 00
  LDA $970C                                           ; $D80A: AD 0C 97
  STA a:$0000                                         ; $D80D: 8D 00 00
  LDA $970D                                           ; $D810: AD 0D 97
  STA a:$0001                                         ; $D813: 8D 01 00
  LDA #$00                                            ; $D816: A9 00
  STA a:$0002                                         ; $D818: 8D 02 00
  JSR B1F_SpriteOamWriterSimple                       ; $D81B: 20 AD F1
  LDY #$00                                            ; $D81E: A0 00
LD820:
  LDA $0200,Y                                         ; $D820: B9 00 02
  BPL LD82A                                           ; $D823: 10 05
  LDA #$F0                                            ; $D825: A9 F0
  STA $0200,Y                                         ; $D827: 99 00 02
LD82A:
  INY                                                 ; $D82A: C8
  INY                                                 ; $D82B: C8
  INY                                                 ; $D82C: C8
  INY                                                 ; $D82D: C8
  CPY #$4C                                            ; $D82E: C0 4C
  BCC LD820                                           ; $D830: 90 EE
  DEC $0543                                           ; $D832: CE 43 05
  .byte $10,$03                                       ; $D835: 10 03 (BPL mid-instruction target)
  INC $0541                                           ; $D837: EE 41 05
  RTS                                                 ; $D83A: 60
.endproc
LD820 = $D820
LD82A = $D82A


;===============================================================================
; $D83B: Proc_D83B
;===============================================================================
.proc Proc_D83B
  state_display_idx        = $0541

  LDA #$00                                            ; $D83B: A9 00
  STA a:$0087                                         ; $D83D: 8D 87 00
  STA $0543                                           ; $D840: 8D 43 05
  LDA #$04                                            ; $D843: A9 04
  STA a:$0088                                         ; $D845: 8D 88 00
  LDA #$44                                            ; $D848: A9 44
  STA a:$0089                                         ; $D84A: 8D 89 00
  LDA #$07                                            ; $D84D: A9 07
  STA $0542                                           ; $D84F: 8D 42 05
  INC $0541                                           ; $D852: EE 41 05
  RTS                                                 ; $D855: 60
.endproc

;===============================================================================
; $D856: Proc_D856
;===============================================================================
.proc Proc_D856
  state_display_idx        = $0541

  JSR $DCC8                                           ; $D856: 20 C8 DC
  LDA a:$0088                                         ; $D859: AD 88 00
  ASL A                                               ; $D85C: 0A
  ASL A                                               ; $D85D: 0A
  TAY                                                 ; $D85E: A8
  LDX #$00                                            ; $D85F: A2 00
LD861:
  LDA $D880,Y                                         ; $D861: B9 80 D8
  STA $0100,X                                         ; $D864: 9D 00 01
  INY                                                 ; $D867: C8
  INX                                                 ; $D868: E8
  CPX #$04                                            ; $D869: E0 04
  BCC LD861                                           ; $D86B: 90 F4
  LDA a:$0087                                         ; $D86D: AD 87 00
  .byte $10,$0D                                       ; $D870: 10 0D (BPL mid-instruction target)
  INC $0543                                           ; $D872: EE 43 05
  LDA $0543                                           ; $D875: AD 43 05
  CMP #$20                                            ; $D878: C9 20
  .byte $D0,$03                                       ; $D87A: D0 03 (BNE mid-instruction target)
  INC $0541                                           ; $D87C: EE 41 05
  RTS                                                 ; $D87F: 60
  .byte $0F,$28,$19,$17,$0F,$30,$00,$07,$0F,$10,$0F,$00,$0F,$00,$0F,$0F; $D880: 0F 28 19 17 0F 30 00 07 0F 10 0F 00 0F 00 0F 0F
.endproc
LD861 = $D861


;===============================================================================
; $D890: Proc_D890
;===============================================================================
.proc Proc_D890
  state_display_idx        = $0541

  LDA #$00                                            ; $D890: A9 00
  STA a:$0087                                         ; $D892: 8D 87 00
  LDA #$04                                            ; $D895: A9 04
  STA a:$0088                                         ; $D897: 8D 88 00
  LDA #$33                                            ; $D89A: A9 33
  STA a:$0089                                         ; $D89C: 8D 89 00
  LDA #$0F                                            ; $D89F: A9 0F
  STA $0542                                           ; $D8A1: 8D 42 05
  LDA #$00                                            ; $D8A4: A9 00
  STA $0543                                           ; $D8A6: 8D 43 05
  INC $0541                                           ; $D8A9: EE 41 05
  RTS                                                 ; $D8AC: 60
.endproc

;===============================================================================
; $D8AD: Proc_D8AD
;===============================================================================
.proc Proc_D8AD

  JSR $DCC8                                           ; $D8AD: 20 C8 DC
  LDA a:$0087                                         ; $D8B0: AD 87 00
  .byte $10,$23                                       ; $D8B3: 10 23 (BPL cross-proc)
  LDY #$00                                            ; $D8B5: A0 00
.endproc

;===============================================================================
; $D8B7: Proc_D8B7
;===============================================================================
.proc Proc_D8B7
  state_display_idx        = $0541

  LDA $D93C,Y                                         ; $D8B7: B9 3C D9
  BEQ LD8C3                                           ; $D8BA: F0 07
  STA $0380,Y                                         ; $D8BC: 99 80 03
  INY                                                 ; $D8BF: C8
  JMP Proc_D8B7                                       ; $D8C0: 4C B7 D8
LD8C3:
  LDA #$FF                                            ; $D8C3: A9 FF
  STA $0380,Y                                         ; $D8C5: 99 80 03
  LDA a:$007E                                         ; $D8C8: AD 7E 00
  ORA #$04                                            ; $D8CB: 09 04
  STA a:$007E                                         ; $D8CD: 8D 7E 00
  LDA #$1F                                            ; $D8D0: A9 1F
  STA $0542                                           ; $D8D2: 8D 42 05
  INC $0541                                           ; $D8D5: EE 41 05
  RTS                                                 ; $D8D8: 60
.endproc
LD8C3 = $D8C3


;===============================================================================
; $D8D9: Proc_D8D9
;===============================================================================
.proc Proc_D8D9

  LDY #$00                                            ; $D8D9: A0 00
.endproc

;===============================================================================
; $D8DB: Proc_D8DB
;===============================================================================
.proc Proc_D8DB
  state_display_idx        = $0541

  LDA $D962,Y                                         ; $D8DB: B9 62 D9
  BEQ LD8E7                                           ; $D8DE: F0 07
  STA $0380,Y                                         ; $D8E0: 99 80 03
  INY                                                 ; $D8E3: C8
  JMP Proc_D8DB                                       ; $D8E4: 4C DB D8
LD8E7:
  LDA #$FF                                            ; $D8E7: A9 FF
  STA $0380,Y                                         ; $D8E9: 99 80 03
  LDA a:$007E                                         ; $D8EC: AD 7E 00
  ORA #$04                                            ; $D8EF: 09 04
  STA a:$007E                                         ; $D8F1: 8D 7E 00
  INC $0541                                           ; $D8F4: EE 41 05
  RTS                                                 ; $D8F7: 60
.endproc
LD8E7 = $D8E7


;===============================================================================
; $D8F8: Proc_D8F8
;===============================================================================
.proc Proc_D8F8
  state_sub_dispatch       = $0540
  state_display_idx        = $0541

  LDA $0543                                           ; $D8F8: AD 43 05
  BNE LD904                                           ; $D8FB: D0 07
  LDA a:$0081                                         ; $D8FD: AD 81 00
  AND #$08                                            ; $D900: 29 08
  .byte $F0,$08                                       ; $D902: F0 08 (BEQ mid-instruction target)
LD904:
  INC $0540                                           ; $D904: EE 40 05
  LDA #$00                                            ; $D907: A9 00
  STA $0541                                           ; $D909: 8D 41 05
  RTS                                                 ; $D90C: 60
.endproc
LD904 = $D904


;===============================================================================
; $D90D: Proc_D90D
;===============================================================================
.proc Proc_D90D
  state_display_idx        = $0541

  LDA #$28                                            ; $D90D: A9 28
  STA $0121                                           ; $D90F: 8D 21 01
  LDA #$19                                            ; $D912: A9 19
  STA $0122                                           ; $D914: 8D 22 01
  LDA #$17                                            ; $D917: A9 17
  STA $0123                                           ; $D919: 8D 23 01
  LDY #$00                                            ; $D91C: A0 00
LD91E:
  LDA $0120,Y                                         ; $D91E: B9 20 01
  STA $0100,Y                                         ; $D921: 99 00 01
  INY                                                 ; $D924: C8
  CPY #$20                                            ; $D925: C0 20
  BCC LD91E                                           ; $D927: 90 F5
  LDA #$0F                                            ; $D929: A9 0F
  STA $0542                                           ; $D92B: 8D 42 05
  STA $0543                                           ; $D92E: 8D 43 05
  LDA #$06                                            ; $D931: A9 06
  STA $0541                                           ; $D933: 8D 41 05
  LDA #$FF                                            ; $D936: A9 FF
  STA a:$0087                                         ; $D938: 8D 87 00
  RTS                                                 ; $D93B: 60
  .byte $04,$21,$77,$DC,$DD,$DE,$DF,$0C,$21,$8F,$E4,$E5,$E6,$E7,$E8,$E9; $D93C: 04 21 77 DC DD DE DF 0C 21 8F E4 E5 E6 E7 E8 E9
  .byte $EA,$EB,$EC,$ED,$EE,$EF,$0C,$21,$AF,$F4,$F5,$F6,$F7,$F8,$F9,$FA; $D94C: EA EB EC ED EE EF 0C 21 AF F4 F5 F6 F7 F8 F9 FA
  .byte $FB,$FC,$FD,$FE,$FF,$00,$07,$22,$CC,$C0,$C1,$C2,$C3,$C4,$C5,$C6; $D95C: FB FC FD FE FF 00 07 22 CC C0 C1 C2 C3 C4 C5 C6
  .byte $16,$23,$05,$F0,$21,$E1,$E2,$F3,$F3,$21,$E1,$E2,$E2,$E4,$21,$E5; $D96C: 16 23 05 F0 21 E1 E2 F3 F3 21 E1 E2 E2 E4 21 E5
  .byte $C8,$E6,$E7,$E8,$21,$C9,$E9,$D9,$C7,$13,$23,$46,$C8,$C9,$C9,$21; $D97C: C8 E6 E7 E8 21 C9 E9 D9 C7 13 23 46 C8 C9 C9 21
  .byte $D0,$D1,$D2,$D3,$D4,$D5,$21,$D0,$D6,$D7,$D6,$D0,$D8,$D6,$D9,$00; $D98C: D0 D1 D2 D3 D4 D5 21 D0 D6 D7 D6 D0 D8 D6 D9 00
.endproc
LD91E = $D91E


;===============================================================================
; $D99C: RenderOverlay
; Render overlay tiles to name table
;===============================================================================
.proc RenderOverlay
  state_display_idx        = $0541

  LDA $0541                                           ; $D99C: AD 41 05
  JSR B1F_CallbackDispatcher                          ; $D99F: 20 DE EA
  ; --- Inline pointer table (3 entries) ---
  .addr Proc_D9A8                                     ; $D9A2: A8 D9
  .addr Proc_D9D0                                     ; $D9A4: D0 D9
  .addr Proc_DA1B                                     ; $D9A6: 1B DA
.endproc

;===============================================================================
; $D9A8: Proc_D9A8
;===============================================================================
.proc Proc_D9A8
  state_display_idx        = $0541

  LDY #$08                                            ; $D9A8: A0 08
  LDA #$0F                                            ; $D9AA: A9 0F
LD9AC:
  STA $0100,Y                                         ; $D9AC: 99 00 01
  INY                                                 ; $D9AF: C8
  CPY #$10                                            ; $D9B0: C0 10
  BCC LD9AC                                           ; $D9B2: 90 F8
  STA $011D                                           ; $D9B4: 8D 1D 01
  STA $011E                                           ; $D9B7: 8D 1E 01
  STA $011F                                           ; $D9BA: 8D 1F 01
  LDA #$C0                                            ; $D9BD: A9 C0
  STA $0543                                           ; $D9BF: 8D 43 05
  LDA #$21                                            ; $D9C2: A9 21
  STA $0544                                           ; $D9C4: 8D 44 05
  LDA #$17                                            ; $D9C7: A9 17
  STA $0542                                           ; $D9C9: 8D 42 05
  INC $0541                                           ; $D9CC: EE 41 05
  RTS                                                 ; $D9CF: 60
.endproc
LD9AC = $D9AC


;===============================================================================
; $D9D0: Proc_D9D0
;===============================================================================
.proc Proc_D9D0
  state_display_idx        = $0541

  LDA #$40                                            ; $D9D0: A9 40
  STA $0380                                           ; $D9D2: 8D 80 03
  LDA $0544                                           ; $D9D5: AD 44 05
  STA $0381                                           ; $D9D8: 8D 81 03
  LDA $0543                                           ; $D9DB: AD 43 05
  STA $0382                                           ; $D9DE: 8D 82 03
  LDY #$00                                            ; $D9E1: A0 00
  LDA #$21                                            ; $D9E3: A9 21
  STA $0383,Y                                         ; $D9E5: 99 83 03
  INY                                                 ; $D9E8: C8
  CPY #$40                                            ; $D9E9: C0 40
  .byte $90,$F8                                       ; $D9EB: 90 F8 (BCC mid-instruction target)
  LDA #$FF                                            ; $D9ED: A9 FF
  STA $0383,Y                                         ; $D9EF: 99 83 03
  LDA $0543                                           ; $D9F2: AD 43 05
  CLC                                                 ; $D9F5: 18
  ADC #$40                                            ; $D9F6: 69 40
  STA $0543                                           ; $D9F8: 8D 43 05
  LDA $0544                                           ; $D9FB: AD 44 05
  ADC #$00                                            ; $D9FE: 69 00
  STA $0544                                           ; $DA00: 8D 44 05
  LDA $0543                                           ; $DA03: AD 43 05
  CMP #$C0                                            ; $DA06: C9 C0
  .byte $D0,$08                                       ; $DA08: D0 08 (BNE mid-instruction target)
  INC $0541                                           ; $DA0A: EE 41 05
  LDA #$17                                            ; $DA0D: A9 17
  STA $0542                                           ; $DA0F: 8D 42 05
  LDA a:$007E                                         ; $DA12: AD 7E 00
  ORA #$04                                            ; $DA15: 09 04
  STA a:$007E                                         ; $DA17: 8D 7E 00
  RTS                                                 ; $DA1A: 60
.endproc

;===============================================================================
; $DA1B: Proc_DA1B
;===============================================================================
.proc Proc_DA1B

  LDY #$00                                            ; $DA1B: A0 00
.endproc

;===============================================================================
; $DA1D: Proc_DA1D
;===============================================================================
.proc Proc_DA1D
  state_sub_dispatch       = $0540
  state_display_idx        = $0541

  LDA $DA3F,Y                                         ; $DA1D: B9 3F DA
  .byte $F0,$07                                       ; $DA20: F0 07 (BEQ mid-instruction target)
  STA $0380,Y                                         ; $DA22: 99 80 03
  INY                                                 ; $DA25: C8
  JMP Proc_DA1D                                       ; $DA26: 4C 1D DA
  LDA #$FF                                            ; $DA29: A9 FF
  STA $0380,Y                                         ; $DA2B: 99 80 03
  LDA a:$007E                                         ; $DA2E: AD 7E 00
  ORA #$04                                            ; $DA31: 09 04
  STA a:$007E                                         ; $DA33: 8D 7E 00
  INC $0540                                           ; $DA36: EE 40 05
  LDA #$00                                            ; $DA39: A9 00
  STA $0541                                           ; $DA3B: 8D 41 05
  RTS                                                 ; $DA3E: 60
.endproc

;===============================================================================
; $DA3F: Proc_DA3F
;===============================================================================
.proc Proc_DA3F
  math_acc_mlo             = $0021
  math_acc_mhi             = $0022

  ORA ($21,X)                                         ; $DA3F: 01 21
  .byte $D0,$F5                                       ; $DA41: D0 F5 (BNE cross-proc)
  ASL $21                                             ; $DA43: 06 21
  SBC $EAE1                                           ; $DA45: ED E1 EA
  AND ($F4,X)                                         ; $DA48: 21 F4
  INC $F7,X                                           ; $DA4A: F6 F7
  ORA ($22,X)                                         ; $DA4C: 01 22
  .byte $10,$F5                                       ; $DA4E: 10 F5 (BPL mid-instruction target)
  ASL $22                                             ; $DA50: 06 22
  AND $EAE4                                           ; $DA52: 2D E4 EA
  AND ($F4,X)                                         ; $DA55: 21 F4
  INC $F7,X                                           ; $DA57: F6 F7
  ASL $22                                             ; $DA59: 06 22
  ADC $F9F8                                           ; $DA5B: 6D F8 F9
  .byte $FA,$FB,$EF,$FF,$18,$23,$D8,$55,$55,$55,$55,$55,$55,$55,$55,$55; $DA5E: FA FB EF FF 18 23 D8 55 55 55 55 55 55 55 55 55
  .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00; $DA6E: 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55 00
.endproc

;===============================================================================
; $DA7E: ClearOverlay
; Clear overlay region from name table
;===============================================================================
.proc ClearOverlay
  state_display_idx        = $0541

  JSR B1F_PaletteAnimation                            ; $DA7E: 20 67 EC
  LDA $0541                                           ; $DA81: AD 41 05
  JSR B1F_CallbackDispatcher                          ; $DA84: 20 DE EA
  ; --- Inline pointer table (7 entries) ---
  .addr Proc_DA95                                     ; $DA87: 95 DA
  .addr Proc_DAA6                                     ; $DA89: A6 DA
  .addr Proc_DAFD                                     ; $DA8B: FD DA
  .addr Proc_DB2B                                     ; $DA8D: 2B DB
  .addr Proc_DB7B                                     ; $DA8F: 7B DB
  .addr Proc_DBC1                                     ; $DA91: C1 DB
  .addr Proc_DBF1                                     ; $DA93: F1 DB
.endproc

;===============================================================================
; $DA95: Proc_DA95
;===============================================================================
.proc Proc_DA95
  state_display_idx        = $0541
  state_overlay_param      = $0545

  INC $0541                                           ; $DA95: EE 41 05
  LDA #$00                                            ; $DA98: A9 00
  STA $0424                                           ; $DA9A: 8D 24 04
  STA $0425                                           ; $DA9D: 8D 25 04
  LDA #$00                                            ; $DAA0: A9 00
  STA $0545                                           ; $DAA2: 8D 45 05
  RTS                                                 ; $DAA5: 60
.endproc

;===============================================================================
; $DAA6: Proc_DAA6
;===============================================================================
.proc Proc_DAA6
  state_display_idx        = $0541

  JSR Proc_DD79                                       ; $DAA6: 20 79 DD
  JSR PaletteCheck                                ; $DAA9: 20 4C DF
  LDA #$D4                                            ; $DAAC: A9 D4
  STA a:$0010                                         ; $DAAE: 8D 10 00
  LDA #$DB                                            ; $DAB1: A9 DB
  STA a:$0011                                         ; $DAB3: 8D 11 00
  LDA #$00                                            ; $DAB6: A9 00
  STA a:$0012                                         ; $DAB8: 8D 12 00
  JSR B1F_MenuStep1                                   ; $DABB: 20 19 ED
  LDA #$D8                                            ; $DABE: A9 D8
  STA a:$0010                                         ; $DAC0: 8D 10 00
  LDA #$DB                                            ; $DAC3: A9 DB
  STA a:$0011                                         ; $DAC5: 8D 11 00
  LDA #$DE                                            ; $DAC8: A9 DE
  STA a:$0000                                         ; $DACA: 8D 00 00
  LDA #$DB                                            ; $DACD: A9 DB
  STA a:$0001                                         ; $DACF: 8D 01 00
  LDA a:$0012                                         ; $DAD2: AD 12 00
  JSR B1F_PointerTableLookup                          ; $DAD5: 20 F5 ED
  LDA a:$0081                                         ; $DAD8: AD 81 00
  AND #$08                                            ; $DADB: 29 08
  .byte $F0,$1D                                       ; $DADD: F0 1D (BEQ mid-instruction target)
  LDA a:$0012                                         ; $DADF: AD 12 00
  STA $0543                                           ; $DAE2: 8D 43 05
  CMP #$02                                            ; $DAE5: C9 02
  .byte $D0,$0B                                       ; $DAE7: D0 0B (BNE mid-instruction target)
  JSR Proc_DC2F                                       ; $DAE9: 20 2F DC
  .byte $90,$0E                                       ; $DAEC: 90 0E (BCC mid-instruction target)
  INC $0541                                           ; $DAEE: EE 41 05
  JMP B1F_PaletteCopyBuffer                           ; $DAF1: 4C EE EC
  STA $6F43                                           ; $DAF4: 8D 43 6F
  LDA #$03                                            ; $DAF7: A9 03
  STA $0541                                           ; $DAF9: 8D 41 05
  RTS                                                 ; $DAFC: 60
.endproc

;===============================================================================
; $DAFD: Proc_DAFD
;===============================================================================
.proc Proc_DAFD
  state_display_idx        = $0541
  sram_player_id           = $6F03

  LDA a:$0087                                         ; $DAFD: AD 87 00
  .byte $10,$FA                                       ; $DB00: 10 FA (BPL cross-proc)
  JSR Proc_DC97                                       ; $DB02: 20 97 DC
  LDA #$00                                            ; $DB05: A9 00
  STA $0541                                           ; $DB07: 8D 41 05
  LDA #$01                                            ; $DB0A: A9 01
  STA a:$007A                                         ; $DB0C: 8D 7A 00
  LDA #$0D                                            ; $DB0F: A9 0D
  STA $0400                                           ; $DB11: 8D 00 04
  LDA #$03                                            ; $DB14: A9 03
  STA $0401                                           ; $DB16: 8D 01 04
  LDA $6F03                                           ; $DB19: AD 03 6F
  ASL A                                               ; $DB1C: 0A
  TAY                                                 ; $DB1D: A8
  LDA $DBE3,Y                                         ; $DB1E: B9 E3 DB
  STA a:$00EE                                         ; $DB21: 8D EE 00
  LDA $DBE4,Y                                         ; $DB24: B9 E4 DB
  STA a:$00EF                                         ; $DB27: 8D EF 00
  RTS                                                 ; $DB2A: 60
.endproc

;===============================================================================
; $DB2B: Proc_DB2B
;===============================================================================
.proc Proc_DB2B

  LDY #$00                                            ; $DB2B: A0 00
.endproc

;===============================================================================
; $DB2D: Proc_DB2D
;===============================================================================
.proc Proc_DB2D
  state_display_idx        = $0541

  LDA $DB4F,Y                                         ; $DB2D: B9 4F DB
  STA $0380,Y                                         ; $DB30: 99 80 03
  CMP #$FF                                            ; $DB33: C9 FF
  .byte $F0,$04                                       ; $DB35: F0 04 (BEQ mid-instruction target)
  INY                                                 ; $DB37: C8
  JMP Proc_DB2D                                       ; $DB38: 4C 2D DB
  LDA #$00                                            ; $DB3B: A9 00
  STA $0424                                           ; $DB3D: 8D 24 04
  STA $0425                                           ; $DB40: 8D 25 04
  INC $0541                                           ; $DB43: EE 41 05
  LDA a:$007E                                         ; $DB46: AD 7E 00
  ORA #$04                                            ; $DB49: 09 04
  STA a:$007E                                         ; $DB4B: 8D 7E 00
  RTS                                                 ; $DB4E: 60
  .byte $02,$21,$CF,$21,$21,$08,$21,$EC,$C9,$D6,$D8,$D6,$C9,$21,$E1,$21; $DB4F: 02 21 CF 21 21 08 21 EC C9 D6 D8 D6 C9 21 E1 21
  .byte $02,$22,$0F,$21,$21,$08,$22,$2C,$C9,$D6,$D8,$D6,$C9,$21,$E4,$21; $DB5F: 02 22 0F 21 21 08 22 2C C9 D6 D8 D6 C9 21 E4 21
  .byte $08,$22,$6C,$C9,$D6,$D8,$D6,$C9,$21,$E0,$21,$FF; $DB6F: 08 22 6C C9 D6 D8 D6 C9 21 E0 21 FF
.endproc

;===============================================================================
; $DB7B: Proc_DB7B
;===============================================================================
.proc Proc_DB7B
  state_display_idx        = $0541

  LDA #$D4                                            ; $DB7B: A9 D4
  STA a:$0010                                         ; $DB7D: 8D 10 00
  LDA #$DB                                            ; $DB80: A9 DB
  STA a:$0011                                         ; $DB82: 8D 11 00
  LDA #$00                                            ; $DB85: A9 00
  STA a:$0012                                         ; $DB87: 8D 12 00
  JSR B1F_MenuStep1                                   ; $DB8A: 20 19 ED
  LDA #$BB                                            ; $DB8D: A9 BB
  STA a:$0010                                         ; $DB8F: 8D 10 00
  LDA #$DB                                            ; $DB92: A9 DB
  STA a:$0011                                         ; $DB94: 8D 11 00
  LDA #$DE                                            ; $DB97: A9 DE
  STA a:$0000                                         ; $DB99: 8D 00 00
  LDA #$DB                                            ; $DB9C: A9 DB
  STA a:$0001                                         ; $DB9E: 8D 01 00
  LDA a:$0012                                         ; $DBA1: AD 12 00
  JSR B1F_PointerTableLookup                          ; $DBA4: 20 F5 ED
  LDA a:$0081                                         ; $DBA7: AD 81 00
  AND #$08                                            ; $DBAA: 29 08
  .byte $F0,$0C                                       ; $DBAC: F0 0C (BEQ mid-instruction target)
  LDA a:$0012                                         ; $DBAE: AD 12 00
  STA $0544                                           ; $DBB1: 8D 44 05
  JSR B1F_PaletteCopyBuffer                           ; $DBB4: 20 EE EC
  INC $0541                                           ; $DBB7: EE 41 05
  RTS                                                 ; $DBBA: 60
.endproc

;===============================================================================
; $DBBB: Proc_DBBB
;===============================================================================
.proc Proc_DBBB

  SEI                                                 ; $DBBB: 78
  CLI                                                 ; $DBBC: 58
  DEY                                                 ; $DBBD: 88
  CLI                                                 ; $DBBE: 58
  TYA                                                 ; $DBBF: 98
  CLI                                                 ; $DBC0: 58
.endproc

;===============================================================================
; $DBC1: Proc_DBC1
;===============================================================================
.proc Proc_DBC1
  state_sub_dispatch       = $0540
  state_display_idx        = $0541

  LDA a:$0087                                         ; $DBC1: AD 87 00
  .byte $10,$F4                                       ; $DBC4: 10 F4 (BPL cross-proc)
  LDA #$00                                            ; $DBC6: A9 00
  STA $0540                                           ; $DBC8: 8D 40 05
  STA $0541                                           ; $DBCB: 8D 41 05
  LDA #$0B                                            ; $DBCE: A9 0B
  STA a:$007A                                         ; $DBD0: 8D 7A 00
  RTS                                                 ; $DBD3: 60
.endproc

;===============================================================================
; $DBD4: Proc_DBD4
;===============================================================================
.proc Proc_DBD4

  BRK                                                 ; $DBD4: 00
  .byte $01,$02,$FF,$78,$60,$88,$60,$98,$60,$00,$07,$00,$00,$80,$07,$6F; $DBD5: 01 02 FF 78 60 88 60 98 60 00 07 00 00 80 07 6F
  .byte $0F,$6F,$17,$6F,$1F,$6F,$27,$6F,$2F,$6F,$37,$6F; $DBE5: 0F 6F 17 6F 1F 6F 27 6F 2F 6F 37 6F
.endproc

;===============================================================================
; $DBF1: Proc_DBF1
;===============================================================================
.proc Proc_DBF1
  state_sub_dispatch       = $0540
  state_display_idx        = $0541

  LDA a:$0087                                         ; $DBF1: AD 87 00
  BPL LDC2E                                           ; $DBF4: 10 38
  LDA #$00                                            ; $DBF6: A9 00
  STA $0540                                           ; $DBF8: 8D 40 05
  LDA #$01                                            ; $DBFB: A9 01
  STA $0541                                           ; $DBFD: 8D 41 05
  LDA #$0D                                            ; $DC00: A9 0D
  STA a:$007A                                         ; $DC02: 8D 7A 00
  LDA #$00                                            ; $DC05: A9 00
  TAY                                                 ; $DC07: A8
LDC08:
  STA $042C,Y                                         ; $DC08: 99 2C 04
  INY                                                 ; $DC0B: C8
  CPY #$40                                            ; $DC0C: C0 40
  BCC LDC08                                           ; $DC0E: 90 F8
  LDA #$DE                                            ; $DC10: A9 DE
  STA $042C                                           ; $DC12: 8D 2C 04
  LDA #$C8                                            ; $DC15: A9 C8
  STA $042F                                           ; $DC17: 8D 2F 04
  LDA #$01                                            ; $DC1A: A9 01
  STA $0432                                           ; $DC1C: 8D 32 04
  LDA #$64                                            ; $DC1F: A9 64
  STA $0435                                           ; $DC21: 8D 35 04
  LDA #$0B                                            ; $DC24: A9 0B
  STA $044C                                           ; $DC26: 8D 4C 04
  LDA #$03                                            ; $DC29: A9 03
  STA $044F                                           ; $DC2B: 8D 4F 04
LDC2E:
  RTS                                                 ; $DC2E: 60
.endproc
LDC08 = $DC08
LDC2E = $DC2E


;===============================================================================
; $DC2F: Proc_DC2F
;===============================================================================
.proc Proc_DC2F

  LDA $7FFC                                           ; $DC2F: AD FC 7F
  CMP #$49                                            ; $DC32: C9 49
  BNE LDC95                                           ; $DC34: D0 5F
  LDA $7FFD                                           ; $DC36: AD FD 7F
  CMP #$44                                            ; $DC39: C9 44
  BNE LDC95                                           ; $DC3B: D0 58
  LDA #$00                                            ; $DC3D: A9 00
  STA a:$0000                                         ; $DC3F: 8D 00 00
  STA a:$0002                                         ; $DC42: 8D 02 00
  STA a:$0003                                         ; $DC45: 8D 03 00
  LDA #$70                                            ; $DC48: A9 70
  STA a:$0001                                         ; $DC4A: 8D 01 00
  LDY #$00                                            ; $DC4D: A0 00
LDC4F:
  LDA ($00),Y                                         ; $DC4F: B1 00
  CLC                                                 ; $DC51: 18
  ADC a:$0002                                         ; $DC52: 6D 02 00
  STA a:$0002                                         ; $DC55: 8D 02 00
  LDA a:$0003                                         ; $DC58: AD 03 00
  ADC #$00                                            ; $DC5B: 69 00
  STA a:$0003                                         ; $DC5D: 8D 03 00
  INY                                                 ; $DC60: C8
  BNE LDC4F                                           ; $DC61: D0 EC
  INC a:$0001                                         ; $DC63: EE 01 00
  LDA a:$0001                                         ; $DC66: AD 01 00
  CMP #$7F                                            ; $DC69: C9 7F
  BCC LDC4F                                           ; $DC6B: 90 E2
LDC6D:
  LDA ($00),Y                                         ; $DC6D: B1 00
  CLC                                                 ; $DC6F: 18
  ADC a:$0002                                         ; $DC70: 6D 02 00
  STA a:$0002                                         ; $DC73: 8D 02 00
  LDA a:$0003                                         ; $DC76: AD 03 00
  ADC #$00                                            ; $DC79: 69 00
  STA a:$0003                                         ; $DC7B: 8D 03 00
  INY                                                 ; $DC7E: C8
  CPY #$FE                                            ; $DC7F: C0 FE
  BCC LDC6D                                           ; $DC81: 90 EA
  LDA $7FFE                                           ; $DC83: AD FE 7F
  CMP a:$0002                                         ; $DC86: CD 02 00
  BNE LDC95                                           ; $DC89: D0 0A
  LDA $7FFF                                           ; $DC8B: AD FF 7F
  CMP a:$0003                                         ; $DC8E: CD 03 00
  BNE LDC95                                           ; $DC91: D0 02
  SEC                                                 ; $DC93: 38
  RTS                                                 ; $DC94: 60
LDC95:
  CLC                                                 ; $DC95: 18
  RTS                                                 ; $DC96: 60
.endproc
LDC4F = $DC4F
LDC6D = $DC6D
LDC95 = $DC95


;===============================================================================
; $DC97: Proc_DC97
;===============================================================================
.proc Proc_DC97

  LDA #$4C                                            ; $DC97: A9 4C
  STA a:$00A5                                         ; $DC99: 8D A5 00
  STA B1F_NmiHandler                                  ; $DC9C: 8D 00 F8
  LDA #$00                                            ; $DC9F: A9 00
  STA a:$0000                                         ; $DCA1: 8D 00 00
  STA a:$0002                                         ; $DCA4: 8D 02 00
  LDA #$70                                            ; $DCA7: A9 70
  STA a:$0001                                         ; $DCA9: 8D 01 00
  LDA #$60                                            ; $DCAC: A9 60
  STA a:$0003                                         ; $DCAE: 8D 03 00
  LDY #$00                                            ; $DCB1: A0 00
LDCB3:
  LDA ($00),Y                                         ; $DCB3: B1 00
  STA ($02),Y                                         ; $DCB5: 91 02
  INY                                                 ; $DCB7: C8
  BNE LDCB3                                           ; $DCB8: D0 F9
  INC a:$0003                                         ; $DCBA: EE 03 00
  INC a:$0001                                         ; $DCBD: EE 01 00
  LDA a:$0001                                         ; $DCC0: AD 01 00
  CMP #$80                                            ; $DCC3: C9 80
  BCC LDCB3                                           ; $DCC5: 90 EC
  RTS                                                 ; $DCC7: 60
  LDA a:$0087                                         ; $DCC8: AD 87 00
  BMI LDD0E                                           ; $DCCB: 30 41
  DEC a:$008A                                         ; $DCCD: CE 8A 00
  BPL LDD0E                                           ; $DCD0: 10 3C
  LDA #$04                                            ; $DCD2: A9 04
  STA a:$008A                                         ; $DCD4: 8D 8A 00
  DEC a:$0088                                         ; $DCD7: CE 88 00
  BNE LDCE1                                           ; $DCDA: D0 05
  LDA #$FF                                            ; $DCDC: A9 FF
  STA a:$0087                                         ; $DCDE: 8D 87 00
LDCE1:
  LDA #$00                                            ; $DCE1: A9 00
  STA a:$0000                                         ; $DCE3: 8D 00 00
  LDA #$01                                            ; $DCE6: A9 01
  STA a:$0001                                         ; $DCE8: 8D 01 00
  LDA #$20                                            ; $DCEB: A9 20
  STA a:$0002                                         ; $DCED: 8D 02 00
  LDA #$01                                            ; $DCF0: A9 01
  STA a:$0003                                         ; $DCF2: 8D 03 00
  LDA a:$0089                                         ; $DCF5: AD 89 00
  STA a:$0010                                         ; $DCF8: 8D 10 00
  LDY #$00                                            ; $DCFB: A0 00
LDCFD:
  LDA a:$0010                                         ; $DCFD: AD 10 00
  ASL A                                               ; $DD00: 0A
  STA a:$0010                                         ; $DD01: 8D 10 00
  .byte $90,$03                                       ; $DD04: 90 03 (BCC mid-instruction target)
  JSR Proc_DD0F                                       ; $DD06: 20 0F DD
  INY                                                 ; $DD09: C8
  CPY #$08                                            ; $DD0A: C0 08
  BCC LDCFD                                           ; $DD0C: 90 EF
LDD0E:
  RTS                                                 ; $DD0E: 60
.endproc
LDCB3 = $DCB3
LDCE1 = $DCE1
LDCFD = $DCFD
LDD0E = $DD0E


;===============================================================================
; $DD0F: Proc_DD0F
;===============================================================================
.proc Proc_DD0F

  TYA                                                 ; $DD0F: 98
  PHA                                                 ; $DD10: 48
  ASL A                                               ; $DD11: 0A
  ASL A                                               ; $DD12: 0A
  TAY                                                 ; $DD13: A8
  CLC                                                 ; $DD14: 18
  ADC #$04                                            ; $DD15: 69 04
  STA a:$0011                                         ; $DD17: 8D 11 00
LDD1A:
  LDX a:$0088                                         ; $DD1A: AE 88 00
  LDA ($02),Y                                         ; $DD1D: B1 02
LDD1F:
  DEX                                                 ; $DD1F: CA
  BMI LDD29                                           ; $DD20: 30 07
  SEC                                                 ; $DD22: 38
  SBC #$10                                            ; $DD23: E9 10
  BPL LDD1F                                           ; $DD25: 10 F8
  LDA #$0F                                            ; $DD27: A9 0F
LDD29:
  STA ($00),Y                                         ; $DD29: 91 00
  INY                                                 ; $DD2B: C8
  CPY a:$0011                                         ; $DD2C: CC 11 00
  BCC LDD1A                                           ; $DD2F: 90 E9
  PLA                                                 ; $DD31: 68
  TAY                                                 ; $DD32: A8
  RTS                                                 ; $DD33: 60
.endproc
LDD1A = $DD1A
LDD1F = $DD1F
LDD29 = $DD29


;===============================================================================
; $DD34: Proc_DD34
;===============================================================================
.proc Proc_DD34

  LDY #$21                                            ; $DD34: A0 21
  JSR B1F_SwitchBank8_B                               ; $DD36: 20 5F F2
  LDY #$00                                            ; $DD39: A0 00
  LDA $0542                                           ; $DD3B: AD 42 05
  STA a:$0012                                         ; $DD3E: 8D 12 00
LDD41:
  LDA a:$0012                                         ; $DD41: AD 12 00
  LSR A                                               ; $DD44: 4A
  STA a:$0012                                         ; $DD45: 8D 12 00
  .byte $90,$03                                       ; $DD48: 90 03 (BCC mid-instruction target)
  JSR Proc_DD53                                       ; $DD4A: 20 53 DD
  INY                                                 ; $DD4D: C8
  CPY #$05                                            ; $DD4E: C0 05
  BCC LDD41                                           ; $DD50: 90 EF
  RTS                                                 ; $DD52: 60
.endproc
LDD41 = $DD41


;===============================================================================
; $DD53: Proc_DD53
;===============================================================================
.proc Proc_DD53

  TYA                                                 ; $DD53: 98
  PHA                                                 ; $DD54: 48
  ASL A                                               ; $DD55: 0A
  TAY                                                 ; $DD56: A8
  LDA $970C,Y                                         ; $DD57: B9 0C 97
  STA a:$0000                                         ; $DD5A: 8D 00 00
  INY                                                 ; $DD5D: C8
  LDA $970C,Y                                         ; $DD5E: B9 0C 97
  STA a:$0001                                         ; $DD61: 8D 01 00
  LDA #$00                                            ; $DD64: A9 00
  STA a:$000C                                         ; $DD66: 8D 0C 00
  LDA #$00                                            ; $DD69: A9 00
  STA a:$000A                                         ; $DD6B: 8D 0A 00
  LDA #$00                                            ; $DD6E: A9 00
  STA a:$0002                                         ; $DD70: 8D 02 00
  JSR B1F_SpriteOamWriterSimple                       ; $DD73: 20 AD F1
  PLA                                                 ; $DD76: 68
  TAY                                                 ; $DD77: A8
  RTS                                                 ; $DD78: 60
.endproc

;===============================================================================
; $DD79: Proc_DD79
;===============================================================================
.proc Proc_DD79
  state_overlay_param      = $0545

  LDA $0546                                           ; $DD79: AD 46 05
  BMI LDDC7                                           ; $DD7C: 30 49
  LDA a:$0083                                         ; $DD7E: AD 83 00
  AND #$01                                            ; $DD81: 29 01
  BNE LDD8B                                           ; $DD83: D0 06
  LDA #$00                                            ; $DD85: A9 00
  STA $0546                                           ; $DD87: 8D 46 05
  RTS                                                 ; $DD8A: 60
LDD8B:
  LDA $0546                                           ; $DD8B: AD 46 05
  BEQ LDD9C                                           ; $DD8E: F0 0C
  CMP #$01                                            ; $DD90: C9 01
  .byte $F0,$11                                       ; $DD92: F0 11 (BEQ mid-instruction target)
  CMP #$02                                            ; $DD94: C9 02
  .byte $F0,$16                                       ; $DD96: F0 16 (BEQ mid-instruction target)
  CMP #$03                                            ; $DD98: C9 03
  BEQ LDDB7                                           ; $DD9A: F0 1B
LDD9C:
  LDA a:$0081                                         ; $DD9C: AD 81 00
  AND #$10                                            ; $DD9F: 29 10
  .byte $F0,$23                                       ; $DDA1: F0 23 (BEQ mid-instruction target)
  .byte $D0,$1E                                       ; $DDA3: D0 1E (BNE mid-instruction target)
  LDA a:$0081                                         ; $DDA5: AD 81 00
  AND #$20                                            ; $DDA8: 29 20
  .byte $F0,$1A                                       ; $DDAA: F0 1A (BEQ mid-instruction target)
  .byte $D0,$15                                       ; $DDAC: D0 15 (BNE mid-instruction target)
  LDA a:$0081                                         ; $DDAE: AD 81 00
  AND #$40                                            ; $DDB1: 29 40
  .byte $F0,$11                                       ; $DDB3: F0 11 (BEQ mid-instruction target)
  .byte $D0,$0C                                       ; $DDB5: D0 0C (BNE mid-instruction target)
LDDB7:
  LDA a:$0081                                         ; $DDB7: AD 81 00
  AND #$80                                            ; $DDBA: 29 80
  .byte $F0,$08                                       ; $DDBC: F0 08 (BEQ mid-instruction target)
  LDA #$80                                            ; $DDBE: A9 80
  STA $0546                                           ; $DDC0: 8D 46 05
  INC $0546                                           ; $DDC3: EE 46 05
  RTS                                                 ; $DDC6: 60
LDDC7:
  JSR SpriteSetup2                                ; $DDC7: 20 AF DE
  LDA a:$0081                                         ; $DDCA: AD 81 00
  AND #$03                                            ; $DDCD: 29 03
  .byte $F0,$66                                       ; $DDCF: F0 66 (BEQ mid-instruction target)
  LDA a:$0083                                         ; $DDD1: AD 83 00
  AND #$01                                            ; $DDD4: 29 01
  .byte $F0,$03                                       ; $DDD6: F0 03 (BEQ mid-instruction target)
  JSR B1F_BankPpuInit                                 ; $DDD8: 20 7F E5
  LDA $0545                                           ; $DDDB: AD 45 05
  ASL A                                               ; $DDDE: 0A
  TAY                                                 ; $DDDF: A8
  LDA SoundDispatch,Y                             ; $DDE0: B9 5F DE
  CMP #$02                                            ; $DDE3: C9 02
  .byte $F0,$1D                                       ; $DDE5: F0 1D (BEQ mid-instruction target)
  CMP #$03                                            ; $DDE7: C9 03
  .byte $F0,$22                                       ; $DDE9: F0 22 (BEQ mid-instruction target)
  CMP #$04                                            ; $DDEB: C9 04
  .byte $F0,$27                                       ; $DDED: F0 27 (BEQ mid-instruction target)
  CMP #$05                                            ; $DDEF: C9 05
  .byte $F0,$2C                                       ; $DDF1: F0 2C (BEQ mid-instruction target)
  CMP #$06                                            ; $DDF3: C9 06
  .byte $F0,$31                                       ; $DDF5: F0 31 (BEQ mid-instruction target)
  CMP #$07                                            ; $DDF7: C9 07
  .byte $F0,$36                                       ; $DDF9: F0 36 (BEQ mid-instruction target)
  LDA $DE60,Y                                         ; $DDFB: B9 60 DE
  JSR B1F_SoundNotePlayer                             ; $DDFE: 20 09 E6
  JMP $DE37                                           ; $DE01: 4C 37 DE
  LDA $DE60,Y                                         ; $DE04: B9 60 DE
  JSR $E69B                                           ; $DE07: 20 9B E6
  JMP $DE37                                           ; $DE0A: 4C 37 DE
  LDA $DE60,Y                                         ; $DE0D: B9 60 DE
  JSR B1F_SoundWrapperE                               ; $DE10: 20 93 E6
  JMP $DE37                                           ; $DE13: 4C 37 DE
  LDA $DE60,Y                                         ; $DE16: B9 60 DE
  JSR $E68B                                           ; $DE19: 20 8B E6
  JMP $DE37                                           ; $DE1C: 4C 37 DE
  LDA $DE60,Y                                         ; $DE1F: B9 60 DE
  JSR B1F_SoundWrapperC                               ; $DE22: 20 83 E6
  JMP $DE37                                           ; $DE25: 4C 37 DE
  LDA $DE60,Y                                         ; $DE28: B9 60 DE
  JSR $E67B                                           ; $DE2B: 20 7B E6
  JMP $DE37                                           ; $DE2E: 4C 37 DE
  LDA $DE60,Y                                         ; $DE31: B9 60 DE
  JSR $E673                                           ; $DE34: 20 73 E6
  LDA a:$0081                                         ; $DE37: AD 81 00
  AND #$80                                            ; $DE3A: 29 80
  .byte $F0,$0F                                       ; $DE3C: F0 0F (BEQ mid-instruction target)
  INC $0545                                           ; $DE3E: EE 45 05
  LDA $0545                                           ; $DE41: AD 45 05
  CMP #$28                                            ; $DE44: C9 28
  .byte $90,$05                                       ; $DE46: 90 05 (BCC mid-instruction target)
  LDA #$00                                            ; $DE48: A9 00
  STA $0545                                           ; $DE4A: 8D 45 05
  LDA a:$0081                                         ; $DE4D: AD 81 00
  AND #$40                                            ; $DE50: 29 40
  .byte $F0,$0A                                       ; $DE52: F0 0A (BEQ mid-instruction target)
  DEC $0545                                           ; $DE54: CE 45 05
  .byte $10,$05                                       ; $DE57: 10 05 (BPL mid-instruction target)
  LDA #$27                                            ; $DE59: A9 27
  STA $0545                                           ; $DE5B: 8D 45 05
  RTS                                                 ; $DE5E: 60
.endproc
LDD8B = $DD8B
LDD9C = $DD9C
LDDB7 = $DDB7
LDDC7 = $DDC7


;===============================================================================
; $DE5F: SoundDispatch
; Sound dispatch: route to NMC sound routines
;===============================================================================
.proc SoundDispatch

  ORA $08                                             ; $DE5F: 05 08
  ORA $0D                                             ; $DE61: 05 0D
  ASL $12                                             ; $DE63: 06 12
  ORA $18                                             ; $DE65: 05 18
  .byte $07,$1D,$05,$24,$05,$29,$04,$2E,$06,$32,$04,$3E,$05,$42,$06,$47; $DE67: 07 1D 05 24 05 29 04 2E 06 32 04 3E 05 42 06 47
  .byte $05,$4D,$04,$52,$01,$57,$02,$5A,$01,$5C,$01,$5D,$01,$5E,$01,$60; $DE77: 05 4D 04 52 01 57 02 5A 01 5C 01 5D 01 5E 01 60
  .byte $01,$61,$03,$62,$02,$65,$01,$68,$01,$69,$05,$6C,$05,$71,$05,$76; $DE87: 01 61 03 62 02 65 01 68 01 69 05 6C 05 71 05 76
  .byte $04,$7B,$06,$82,$05,$88,$04,$8D,$04,$91,$03,$95,$07,$98,$03,$9F; $DE97: 04 7B 06 82 05 88 04 8D 04 91 03 95 07 98 03 9F
  .byte $04,$A2,$04,$A6,$06,$AA,$07,$B0               ; $DEA7: 04 A2 04 A6 06 AA 07 B0
.endproc

;===============================================================================
; $DEAF: SpriteSetup2
;===============================================================================
.proc SpriteSetup2
  state_overlay_param      = $0545

  LDA #$A2                                            ; $DEAF: A9 A2
  STA a:$00D8                                         ; $DEB1: 8D D8 00
  LDA #$A5                                            ; $DEB4: A9 A5
  STA a:$00D9                                         ; $DEB6: 8D D9 00
  LDX a:$007C                                         ; $DEB9: AE 7C 00
  LDA #$90                                            ; $DEBC: A9 90
  STA $0200,X                                         ; $DEBE: 9D 00 02
  LDA #$02                                            ; $DEC1: A9 02
  STA $0202,X                                         ; $DEC3: 9D 02 02
  LDA #$BC                                            ; $DEC6: A9 BC
  STA $0203,X                                         ; $DEC8: 9D 03 02
  LDA #$90                                            ; $DECB: A9 90
  STA $0204,X                                         ; $DECD: 9D 04 02
  LDA #$02                                            ; $DED0: A9 02
  STA $0206,X                                         ; $DED2: 9D 06 02
  LDA #$C4                                            ; $DED5: A9 C4
  STA $0207,X                                         ; $DED7: 9D 07 02
  LDA $0545                                           ; $DEDA: AD 45 05
  LSR A                                               ; $DEDD: 4A
  LSR A                                               ; $DEDE: 4A
  LSR A                                               ; $DEDF: 4A
  LSR A                                               ; $DEE0: 4A
  TAY                                                 ; $DEE1: A8
  LDA $DF3C,Y                                         ; $DEE2: B9 3C DF
  STA $0201,X                                         ; $DEE5: 9D 01 02
  LDA $0545                                           ; $DEE8: AD 45 05
  AND #$0F                                            ; $DEEB: 29 0F
  TAY                                                 ; $DEED: A8
  LDA $DF3C,Y                                         ; $DEEE: B9 3C DF
  STA $0205,X                                         ; $DEF1: 9D 05 02
  TXA                                                 ; $DEF4: 8A
  CLC                                                 ; $DEF5: 18
  ADC #$08                                            ; $DEF6: 69 08
  STA a:$007C                                         ; $DEF8: 8D 7C 00
  LDA #$17                                            ; $DEFB: A9 17
  STA a:$0000                                         ; $DEFD: 8D 00 00
  LDA #$DF                                            ; $DF00: A9 DF
  STA a:$0001                                         ; $DF02: 8D 01 00
  LDA #$B0                                            ; $DF05: A9 B0
  STA a:$000C                                         ; $DF07: 8D 0C 00
  LDA #$78                                            ; $DF0A: A9 78
  STA a:$000A                                         ; $DF0C: 8D 0A 00
  LDA #$00                                            ; $DF0F: A9 00
  STA a:$0002                                         ; $DF11: 8D 02 00
  JMP B1F_SpriteOamWriterSimple                       ; $DF14: 4C AD F1
  BRK                                                 ; $DF17: 00
  .byte $9F,$02,$00,$00,$BA,$02,$08,$00,$BB,$02,$10,$00,$BC,$02,$18,$00; $DF18: 9F 02 00 00 BA 02 08 00 BB 02 10 00 BC 02 18 00
  .byte $BD,$02,$20,$0C,$BE,$02,$04,$0C,$BF,$02,$0C,$0C,$9F,$02,$14,$0C; $DF28: BD 02 20 0C BE 02 04 0C BF 02 0C 0C 9F 02 14 0C
  .byte $BE,$02,$1C,$80,$EB,$EC,$ED,$EE,$EF,$FB,$FC,$FD,$FE,$FF,$A3,$A4; $DF38: BE 02 1C 80 EB EC ED EE EF FB FC FD FE FF A3 A4
  .byte $B4,$BD,$BF,$9E                               ; $DF48: B4 BD BF 9E
.endproc

;===============================================================================
; $DF4C: PaletteCheck
; Check and update palette animation state
;===============================================================================
.proc PaletteCheck
  state_display_idx        = $0541
  state_palette_mode       = $0547

  LDY $0547                                           ; $DF4C: AC 47 05
  LDA $DF7F,Y                                         ; $DF4F: B9 7F DF
  BPL LDF62                                           ; $DF52: 10 0E
  JSR B1F_PaletteCopyBuffer                           ; $DF54: 20 EE EC
  LDA #$06                                            ; $DF57: A9 06
  STA $0541                                           ; $DF59: 8D 41 05
  LDA #$62                                            ; $DF5C: A9 62
  JSR B1F_SoundWrapperE                               ; $DF5E: 20 93 E6
  RTS                                                 ; $DF61: 60
LDF62:
  LDA a:$0083                                         ; $DF62: AD 83 00
  LDY $0547                                           ; $DF65: AC 47 05
  AND $DF7F,Y                                         ; $DF68: 39 7F DF
  BNE LDF73                                           ; $DF6B: D0 06
  LDA #$00                                            ; $DF6D: A9 00
  STA $0547                                           ; $DF6F: 8D 47 05
  RTS                                                 ; $DF72: 60
LDF73:
  LDA a:$0081                                         ; $DF73: AD 81 00
  AND $DF88,Y                                         ; $DF76: 39 88 DF
  .byte $F0,$03                                       ; $DF79: F0 03 (BEQ mid-instruction target)
  INC $0547                                           ; $DF7B: EE 47 05
  RTS                                                 ; $DF7E: 60
  .byte $02,$02,$02,$02,$02,$02,$02,$02,$80,$40,$80,$80,$40,$20,$10,$10; $DF7F: 02 02 02 02 02 02 02 02 80 40 80 80 40 20 10 10
  .byte $20,$80,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DF8F: 20 80 FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DF9F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFAF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFBF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFCF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFDF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFEF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF                                           ; $DFFF: FF
.endproc
LDF62 = $DF62
LDF73 = $DF73


