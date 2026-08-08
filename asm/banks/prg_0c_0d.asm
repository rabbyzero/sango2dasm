;===============================================================================
; PRG Banks $0C+$0D - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $0C at $A000-$BFFF, Bank $0D at $C000-$DFFF
;
; MODULE SUMMARY: Officer Exchange / Strategic Command
;
; This bank implements the officer exchange, transfer, and strategic command
; system used during the "officer affairs" game mode.  It is loaded via
; SwitchBankAC with Y=$28 and entered through a 3-entry jump table ($A000-$A006).
;
; Major functional areas:
;   $A000-$A04D  Jump table + ExchangeFrameUpdate main loop
;   $A04E-$A21A  PhaseDispatch - 5-phase exchange flow state machine
;   $A21B-$A292  OfficerDetailView - officer info panel
;   $A293-$A44C  OfficerTransferExecute - transfer animation + result
;   $A44D-$A87B  OfficerMovePhase - officer movement on strategic map
;   $A87C-$AD7F  OfficerCommandPhase - command menu, target select, confirm
;   $AD80-$B02A  ValidateActionTarget - per-stratagem validation (16 stratagems)
;   $B02B-$B72A  ExecuteAction - per-stratagem execution (16 stratagems)
;   $B72B-$B949  CheckActionSuccess / CalcDistance / BuildNeighborList
;   $B94A-$BC92  ProvinceSelectDispatch - province selection UI
;   $BC93-$BE7D  OfficerTurnDispatch - officer turn cycle
;   $BE7E-$C1FB  OfficerMarchDispatch - army march (17 sub-states)
;   $C1FC-$C203  MainLoopDispatch - trampoline back to frame update
;   $C204-$C690  ArmyDeployDispatch - army deployment (7 sub-states)
;   $C691-$C765  OfficerExchangeDispatch - exchange init/select/exit
;   $C766-$C98B  OfficerTransferCalc - transfer merit + action dispatch
;   $C98C-$CC28  OfficerExchangeConfirmDispatch - confirmation screen
;   $CC29-$CD15  RecalcExchangeStats - ruler stat recalculation
;   $CD16-$D2CC  OfficerExchangeSelectDispatch - officer selection (7 states)
;   $D2CD-$D4EF  OfficerReserveAssignDispatch - reserve assignment (7 states)
;   $D4F0-$DFFF  ExchangeScene - map scroll, cursor, terrain, rosters, SFX
;
; Dispatch mechanism:
;   $0500 = game mode (0-$0F); $0501 = sub-state within each mode.
;   All modes use B1F_CallbackDispatcher inline tables for state dispatch.
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

;-------------------------------------------------------------------------------
; Page $04 WRAM ($0400-$04FF) - Officer Exchange / Transfer Work Area
;
; This page is shared across banks with context-dependent meaning.
; In bank $0C/$0D it holds the officer-exchange and transfer state.
; Addresses not listed here are unused by this bank.
;-------------------------------------------------------------------------------

; --- Scene / province context ($0400-$040F) ---
scene_callback_id   = $0400  ; scene callback ID (shared w/ 1D_1E)
scene_callback_st   = $0401  ; scene callback state counter
province_idx        = $0402  ; current province index (map bounds calc)
; $0403-$040B - unused in this bank
detail_cursor_x     = $040C  ; officer-detail panel cursor X (init 0)
detail_cursor_y     = $040D  ; officer-detail panel cursor Y (init 0)
; $040E-$040F - unused in this bank
detail_officer_id   = $0410  ; officer ID shown in detail view (from $0664,Y)

; --- Menu cursor state ($0420-$0425) ---
menu_scroll_state   = $0420  ; menu scroll / render state (shared w/ 1D_1E, 1F)
; $0421-$0423 - unused
menu_cursor_col     = $0424  ; menu cursor column (0-based, shared w/ 1F MenuStep)
menu_cursor_page    = $0425  ; menu cursor page   (0-based, shared w/ 1F MenuStep)

; --- Officer selection array ($042C-$044B, 32 bytes) ---
; Built by @BuildOfficerList: populated from city + reserve rosters.
; Each byte = officer ID; $FF = empty slot; $FE = list terminator.
; Also used as a single-officer work byte at $042C in move/validate procs.
officer_sel_list    = $042C  ; officer selection list base (32 bytes)
; $042D - secondary officer state ($FF = cancel pending)
; $042E - battle result phase (shared w/ 17_18)
; $042F - level difference (ValidateExchangeOfficer)
; $0430-$0431 - exchange validation work
; $0432 - exchange result officer ID

; --- Exchange display stats ($044C-$046B, 32 bytes) ---
; Cleared in ExchangeScene init; populated by @InitExchangeDisplay.
exchange_disp_base  = $044C  ; exchange display stats base (32 bytes)
exchange_ruler_id   = $044C  ; exchange partner ruler ID
; $044D - ruler stat 1 (from $051D)
; $044E - display stat (cleared)
; $044F - display stat (from $051A)
; $0450 - display stat (from $051B)
; $0451 - display stat (cleared)
; $0452 - display stat (from $051F)
; $0453-$0454 - display stats (cleared)
; $0455 - display stat (from $051E)
; $0456-$0457 - display stats (cleared)
; $0458 - group B officer count
; $0459-$045A - group B reserve counts (cleared)
; $045B - group A officer count
; $045C-$045D - group A reserve counts (cleared)

; --- Kingdom parameter snapshot ($046C-$046F) ---
; Copied from SRAM $6F3F-$6F42 in CommandState_Init.
kingdom_param_copy  = $046C  ; kingdom parameter snapshot (4 bytes)

; --- Animation / scroll pointers ($0470-$0473) ---
anim_ppu_ptr_lo     = $0470  ; animation PPU pointer lo (shared w/ 17_18)
anim_ppu_ptr_hi     = $0471  ; animation PPU pointer hi
map_scroll_ptr_lo   = $0472  ; map scroll source pointer lo
map_scroll_ptr_hi   = $0473  ; map scroll source pointer hi

; --- Exchange result ($04C8) ---
exchange_result_cnt = $04C8  ; exchange result counter ($0543+1; 0 = show result)

; --- Officer record pointers ($04D2-$04D5, shared w/ 1D_1E) ---
officer_rec_src_lo  = $04D2  ; officer record source ptr lo
officer_rec_src_hi  = $04D3  ; officer record source ptr hi
officer_rec_dst_lo  = $04D4  ; officer record dest ptr lo
officer_rec_dst_hi  = $04D5  ; officer record dest ptr hi

; --- Army group slot array ($04D8-$04DF, 8 bytes) ---
; Two groups of 4 slots: group A at $04D8-$04DB, group B at $04DC-$04DF.
; Each slot: officer index into $06xx tables; $FF = empty.
; Populated by ExecStratagem_AmbushAllSides; checked in move validation.
army_slot_base      = $04D8  ; army group slot array base (8 bytes)
; $04D8-$04DB - group A slots (selected by $0504 >= 0)
; $04DC-$04DF - group B slots (selected by $0504 < 0)

;-------------------------------------------------------------------------------
; Page $05 WRAM ($0500-$05FF) - Exchange State Machine / Army Data
;
; Core state machine variables for the officer exchange and transfer system.
; $0500/$0501 form the main dispatch pair (state, phase).
;-------------------------------------------------------------------------------

; --- Main dispatch state ($0500-$0501) ---
exchange_state      = $0500  ; exchange main state (0-15, indexes dispatch table)
exchange_phase      = $0501  ; exchange sub-phase within current state

; --- Exchange context ($0504-$050F) ---
exchange_dir_flag   = $0504  ; direction flag (bit7: 0=group A, 1=group B)
move_points_left    = $0505  ; movement points remaining / army strength
ruler_turn_counter  = $0506  ; ruler turn counter (inc per ruler switch)
packed_ruler_pair   = $0507  ; packed ruler pair (lo=A, hi=B nibble)
exchange_wait_timer = $0508  ; timer / wait counter
src_officer_slot    = $0509  ; source officer slot index (into $06xx tables)
dst_officer_slot    = $050A  ; target officer slot / move path length
cmd_phase_step      = $050B  ; command phase step counter / message index
morale_group_a      = $050C  ; group A morale (ComputeArmyMorale)
morale_group_b      = $050D  ; group B morale (ComputeArmyMorale)
province_check_flag = $050E  ; province check flag
ruler_status_flag   = $050F  ; ruler data byte 3 (alliance/status)

; --- Map scroll position ($0510-$0513) ---
; Copied from ZP $8E-$91 in OfficerTransfer_ShowResult.
map_scroll_x_lo     = $0510  ; map scroll X lo
map_scroll_x_hi     = $0511  ; map scroll X hi
map_scroll_y_lo     = $0512  ; map scroll Y lo
map_scroll_y_hi     = $0513  ; map scroll Y hi

; --- Army merit sums ($051A-$051F) ---
; Computed by SumArmyOfficerStats: merit = byte8 + (byte9 & 3).
merit_sum_a_lo      = $051A  ; group A merit sum lo
merit_sum_a_hi      = $051B  ; group A merit sum hi
merit_sum_b_lo      = $051C  ; group B merit sum lo
merit_sum_b_hi      = $051D  ; group B merit sum hi
officer_count_a     = $051E  ; group A officer count
officer_count_b     = $051F  ; group B officer count

; --- Province data pointers ($0522-$0525) ---
; Two word pointers: group A province record, group B province record.
province_ptr_a_lo   = $0522  ; group A province ptr lo
province_ptr_a_hi   = $0523  ; group A province ptr hi
province_ptr_b_lo   = $0524  ; group B province ptr lo
province_ptr_b_hi   = $0525  ; group B province ptr hi

; --- Exchange scene state ($052A-$052F) ---
scene_province_idx  = $052A  ; province index copy (from $0402)
scene_sel_officer   = $052B  ; exchange scene selected officer index
xfer_status_0       = $052C  ; officer 0 status flags (byte 11 hi-nibble)
xfer_status_1       = $052D  ; officer 1 status flags
xfer_power_0        = $052E  ; officer 0 power (byte 1)
xfer_power_1        = $052F  ; officer 1 power

; --- Move path undo buffer ($053D-$053F) ---
; 3 bytes per undo step: province X, province Y, cost.
undo_province_x     = $053D  ; undo: province X
undo_province_y     = $053E  ; undo: province Y
undo_cost           = $053F  ; undo: movement cost

; --- Move path recording ($0540-$0544) ---
; Arrays indexed by step ($050A/3): province X, Y, cost per step.
move_path_x         = $0540  ; move path province X array
move_path_y         = $0541  ; move path province Y array
move_path_cost      = $0542  ; move path cost array
move_path_total     = $0543  ; move path total cost / action index
action_dispatch_idx = $0544  ; terrain type / action dispatch index

; --- Officer selection list ($0550-$055F, 16 bytes) ---
; Used in exchange scene; $FF = empty slot.
exchange_sel_list   = $0550  ; exchange officer selection list (16 bytes)

; --- Transfer result data ($0560-$0565) ---
xfer_officer_id_0   = $0560  ; officer ID slot 0 (result display)
xfer_officer_id_1   = $0561  ; officer ID slot 1
xfer_ruler_data_0   = $0562  ; ruler byte-3 for source ruler
xfer_ruler_data_1   = $0563  ; ruler byte-3 for target ruler
xfer_ruler_id_0     = $0564  ; ruler ID 0 (from $0507, ordered by dir)
xfer_ruler_id_1     = $0565  ; ruler ID 1

; --- Officer selection flags ($0580-$059F, 32 bytes) ---
; Used by exchange scene to mark selected officers; $FF = unselected.
officer_select_flg  = $0580  ; officer selection flags base (32 bytes)

.segment "CODE_BANK0C"

ExchangeFrameUpdate_Entry:
  JMP ExchangeFrameUpdate               ; $A000: 4C 09 A0
ExchangeSceneInit_Entry:
  JMP ExchangeScene_Init               ; $A003: 4C 99 DC
OfficerTransferCalc_Entry:
  JMP OfficerTransferCalc               ; $A006: 4C 66 C7
ExchangeFrameUpdate:
  JSR UpdateExchangeSfx                 ; $A009: 20 88 DF
  LDY #$28                              ; $A00C: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $A00E: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                               ; $A011: $12 A0
  LDY #$28                                    ; $A013: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $A015: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A021                               ; $A018: $21 A0
  JSR $A028                             ; $A01A: 20 28 A0
  JSR SetupExchangeSfx                  ; $A01D: 20 39 DF
  LDY #$20                                    ; $A020: A0 20
  JSR B1F_BankedCallbackTrampoline      ; $A022: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A015                               ; $A025: $15 A0
  RTS                                         ; $A027: 60
  LDA exchange_state                      ; $A028: AD 00 05
  JSR B1F_CallbackDispatcher            ; $A02B: 20 DE EA
; --- CallbackDispatcher table (16 entries) ---
  .word PhaseDispatch                      ; $A02E: 4E A0
  .word OfficerDetailView                    ; $A030: 1B A2
  .word OfficerTransferExecute                ; $A032: 93 A2
  .word OfficerTransferExecute                ; $A034: 93 A2
  .word OfficerMovePhase                    ; $A036: 4D A4
  .word OfficerCommandPhase                 ; $A038: 7C A8
  .word ProvinceSelectDispatch              ; $A03A: 4A B9
  .word OfficerTurnDispatch                 ; $A03C: 93 BC
  .word OfficerMarchDispatch               ; $A03E: 7E BE
  .word MainLoopDispatch                    ; $A040: FC C1
  .word ArmyDeployDispatch                   ; $A042: 04 C2
  .word OfficerExchangeDispatch             ; $A044: 91 C6
  .word OfficerExchangeConfirmDispatch       ; $A046: 8C C9
  .word OfficerExchangeSelectDispatch       ; $A048: 16 CD
  .word OfficerReserveAssignDispatch      ; $A04A: CD D2
  .word ExchangeScene                    ; $A04C: F0 D4
.proc PhaseDispatch
  ; Phase dispatcher for state $0500==0; dispatches on $0501 (5 phases)
  LDA exchange_phase                      ; $A04E: AD 01 05
  JSR B1F_CallbackDispatcher            ; $A051: 20 DE EA
; --- CallbackDispatcher table (5 entries) ---
  .word Phase_Check                         ; $A054: $5E A0
  .word Phase_Wait                          ; $A056: $8D A0
  .word Phase_Input                         ; $A058: $BB A0
  .word Phase_Menu                          ; $A05A: $18 A1
  .word Phase_Confirm                       ; $A05C: $B8 A1
.endproc

.proc Phase_Check
  ; Phase 0: Check conditions; advance or reset state based on $050F/$0505
  JSR CheckExchangeGroupStatus          ; $A05E: 20 72 DD
  LDA ruler_status_flag                   ; $A061: AD 0F 05
  CMP #$03                              ; $A064: C9 03
  BNE @CheckInput                       ; $A066: D0 12
  LDA move_points_left                    ; $A068: AD 05 05
  BEQ @Abort                            ; $A06B: F0 19
  BMI @Abort                            ; $A06D: 30 17
  LDA #$08                              ; $A06F: A9 08
  STA exchange_state                      ; $A071: 8D 00 05
  LDA #$00                              ; $A074: A9 00
  STA exchange_phase                      ; $A076: 8D 01 05
  RTS                                   ; $A079: 60
@CheckInput:
  JSR CheckExchangePossible             ; $A07A: 20 27 DF
  BCC @Done                             ; $A07D: 90 0D
  LDA move_points_left                    ; $A07F: AD 05 05
  BEQ @Abort                            ; $A082: F0 02
  BPL @AdvancePhase                     ; $A084: 10 03
@Abort:
  JMP OfficerTurn_EndTurn               ; $A086: 4C C0 BD
@AdvancePhase:
  INC exchange_phase                      ; $A089: EE 01 05
@Done:
  RTS                                   ; $A08C: 60
.endproc

.proc Phase_Wait
  ; Phase 1: Render and wait for timer; load ruler data then advance
  JSR MapScroll_Update                  ; $A08D: 20 EE D5
  LDA exchange_wait_timer                 ; $A090: AD 08 05
  BNE @NotReady                         ; $A093: D0 25
  LDA $007E                             ; $A095: AD 7E 00
  BNE @NotReady                         ; $A098: D0 20
  INC exchange_phase                      ; $A09A: EE 01 05
  LDA #$C0                              ; $A09D: A9 C0
  JSR B1F_SetUI5                        ; $A09F: 20 93 F2
  LDA packed_ruler_pair                   ; $A0A2: AD 07 05
  LDY exchange_dir_flag                   ; $A0A5: AC 04 05
  BPL @GetNibble                        ; $A0A8: 10 04
  LSR                                   ; $A0AA: 4A
  LSR                                   ; $A0AB: 4A
  LSR                                   ; $A0AC: 4A
  LSR                                   ; $A0AD: 4A
@GetNibble:
  AND #$0F                              ; $A0AE: 29 0F
  JSR B1F_GetRulerDataPtr               ; $A0B0: 20 68 F3
  LDY #$00                              ; $A0B3: A0 00
  LDA ($00),Y                           ; $A0B5: B1 00
  STA officer_sel_list                             ; $A0B7: 8D 2C 04
@NotReady:
  RTS                                   ; $A0BA: 60
.endproc

.proc Phase_Input
  ; Phase 2: Process input; B-button resets, A-button/direction advances
  JSR MapScroll_Update                  ; $A0BB: 20 EE D5
  JSR RenderExchangeSprites             ; $A0BE: 20 57 D6
  JSR CheckExchangePossible             ; $A0C1: 20 27 DF
  BCS @ProcessInput                     ; $A0C4: B0 01
  RTS                                   ; $A0C6: 60
@ProcessInput:
  JSR ExchangeAnimFrameUpdate           ; $A0C7: 20 FB D4
  LDA $81                               ; $A0CA: A5 81
  AND #$01                              ; $A0CC: 29 01
  BEQ @CheckCancel                      ; $A0CE: F0 2B
  JSR ScrollToTileSearch                ; $A0D0: 20 8A D6
  TYA                                   ; $A0D3: 98
  BMI @CheckCancel                      ; $A0D4: 30 25
  JSR CheckOfficerArmyGroup             ; $A0D6: 20 4B DC
  CMP #$FF                              ; $A0D9: C9 FF
  BEQ @CheckCancel                      ; $A0DB: F0 1E
  STY $0509                             ; $A0DD: 8C 09 05
  STY $050A                             ; $A0E0: 8C 0A 05
  INC $0501                             ; $A0E3: EE 01 05
  LDY #$3D                              ; $A0E6: A0 3D
  JSR B1F_BankedCallbackTrampoline      ; $A0E8: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A027                               ; $A0EB: $27 A0
  LDA #$C1                                    ; $A0ED: A9 C1
  JSR B1F_SetUI5                              ; $A0EF: 20 83 F2
  LDA #$00                                    ; $A0F2: A9 00
  STA menu_cursor_col                                   ; $A0F4: 8D 24 04
  STA menu_cursor_page                                   ; $A0F7: 8D 25 04
  RTS                                         ; $A0FA: 60
@CheckCancel:
  LDA $81                               ; $A0FB: A5 81
  AND #$02                              ; $A0FD: 29 02
  BEQ PhaseExit                          ; $A0FF: F0 16
  JSR ScrollToTileSearch                ; $A101: 20 8A D6
  TYA                                   ; $A104: 98
  BMI PhaseExit                          ; $A105: 30 10
  STY $0509                             ; $A107: 8C 09 05
  STY $050A                             ; $A10A: 8C 0A 05
  LDA #$01                              ; $A10D: A9 01
  STA $0500                             ; $A10F: 8D 00 05
  LDA #$00                              ; $A112: A9 00
  STA $0501                             ; $A114: 8D 01 05
.endproc

PhaseExit:
  ; Shared exit point for Phase_Input and Phase_Menu (early return)
  RTS                                   ; $A117: 60

.proc Phase_Menu
  ; Phase 3: Display command menu; handle selection and navigation
  LDA #$00                              ; $A118: A9 00
  STA $00A4                             ; $A11A: 8D A4 00
  JSR CenterMapOnOfficer                ; $A11D: 20 33 DC
  JSR TryAutoAdvance                       ; $A120: 20 DE A1
  LDA #$93                              ; $A123: A9 93
  STA $10                               ; $A125: 85 10
  LDA #$A1                              ; $A127: A9 A1
  STA $11                               ; $A129: 85 11
  LDA #$00                              ; $A12B: A9 00
  STA $12                               ; $A12D: 85 12
  JSR B1F_MenuStep2                     ; $A12F: 20 1E ED
  LDA #$9B                              ; $A132: A9 9B
  STA $10                               ; $A134: 85 10
  LDA #$A1                              ; $A136: A9 A1
  STA $11                               ; $A138: 85 11
  LDA #$A7                              ; $A13A: A9 A7
  STA $00                               ; $A13C: 85 00
  LDA #$A1                              ; $A13E: A9 A1
  STA $01                               ; $A140: 85 01
  LDA $12                               ; $A142: A5 12
  JSR B1F_PointerTableLookup            ; $A144: 20 F5 ED
  JSR CheckExchangePossible             ; $A147: 20 27 DF
  BCC PhaseExit                          ; $A14A: 90 CB
  LDA $81                               ; $A14C: A5 81
  AND #$02                              ; $A14E: 29 02
  BEQ @CheckConfirm                     ; $A150: F0 08
  LDA #$00                              ; $A152: A9 00
  STA $0501                             ; $A154: 8D 01 05
  JMP FinishSequence                       ; $A157: 4C F7 A1
@CheckConfirm:
  LDA $81                               ; $A15A: A5 81
  AND #$01                              ; $A15C: 29 01
  BEQ @Done                             ; $A15E: F0 32
  LDY $12                               ; $A160: A4 12
  BNE @CheckFirstItem                   ; $A162: D0 10
  LDX $0509                             ; $A164: AE 09 05
  LDA $0650,X                           ; $A167: BD 50 06
  BEQ @CheckFirstItem                   ; $A16A: F0 08
  INC $0501                             ; $A16C: EE 01 05
  LDA #$BC                              ; $A16F: A9 BC
  JMP B1F_SetUI2                        ; $A171: 4C 83 F2
@CheckFirstItem:
  CPY #$01                              ; $A174: C0 01
  BNE @ApplySelection                   ; $A176: D0 07
  LDA $0505                             ; $A178: AD 05 05
  CMP #$02                              ; $A17B: C9 02
  BCC @Done                             ; $A17D: 90 13
@ApplySelection:
  LDA @MenuCommandTable+25,Y                           ; $A17F: B9 AC A1
  STA $0500                             ; $A182: 8D 00 05
  LDA @MenuCommandTable+31,Y                           ; $A185: B9 B2 A1
  STA $0501                             ; $A188: 8D 01 05
  LDA #$01                              ; $A18B: A9 01
  STA $12                               ; $A18D: 85 12
  JSR UpdateCursorTile                  ; $A18F: 20 CC D6
@Done:
  RTS                                   ; $A192: 60
; --- Data Region ---
@MenuCommandTable:
  .byte $00,$01,$02,$03,$04,$FF,$FF,$FF,$A8,$47,$A8,$97,$B8,$47,$B8,$97; $A193: 00 01 02 03 04 FF FF FF A8 47 A8 97 B8 47 B8 97
  .byte $C8,$47,$C8,$97,$00,$07,$00,$00,$80,$04,$03,$05,$07,$06,$00,$00; $A1A3: C8 47 C8 97 00 07 00 00 80 04 03 05 07 06 00 00
  .byte $00,$00,$00,$00,$00               ; $A1B3: 00 00 00 00 00
.endproc

.proc Phase_Confirm
  ; Phase 4: Validate and confirm; advance phase on valid input
  LDA #$00                              ; $A1B8: A9 00
  STA $00A4                             ; $A1BA: 8D A4 00
  JSR CenterMapOnOfficer                ; $A1BD: 20 33 DC
  JSR TryAutoAdvance                       ; $A1C0: 20 DE A1
  JSR CheckExchangePossible             ; $A1C3: 20 27 DF
  BCC @Done                             ; $A1C6: 90 15
  JSR DrawExchangeArrows_Right          ; $A1C8: 20 63 DC
  LDA $81                               ; $A1CB: A5 81
  AND #$03                              ; $A1CD: 29 03
  BEQ @Done                             ; $A1CF: F0 0C
  LDA #$01                              ; $A1D1: A9 01
  STA $0501                             ; $A1D3: 8D 01 05
  LDA #$01                              ; $A1D6: A9 01
  STA $12                               ; $A1D8: 85 12
  JSR UpdateCursorTile                  ; $A1DA: 20 CC D6
@Done:
  RTS                                   ; $A1DD: 60
.endproc

.proc TryAutoAdvance
  ; Conditionally advance phase: check frame tick ($005E) and $007E flags
  LDA $005E                             ; $A1DE: AD 5E 00
  AND #$07                              ; $A1E1: 29 07
  BNE @Exit                             ; $A1E3: D0 11
  LDA $007E                             ; $A1E5: AD 7E 00
  AND #$04                              ; $A1E8: 29 04
  BNE @Exit                             ; $A1EA: D0 0A
  LDA $005E                             ; $A1EC: AD 5E 00
  AND #$10                              ; $A1EF: 29 10
  STA $12                               ; $A1F1: 85 12
  JSR UpdateCursorTile                             ; $A1F3: 20 CC D6
@Exit:
  RTS                                   ; $A1F6: 60
.endproc

.proc FinishSequence
  ; Complete sequence: set UI mode 5, reset phase, clear $0424/$0425
  LDA #$05                              ; $A1F7: A9 05
  JSR B1F_SetUI5                        ; $A1F9: 20 93 F2
  LDA #$01                              ; $A1FC: A9 01
  STA $12                               ; $A1FE: 85 12
  JSR UpdateCursorTile                             ; $A200: 20 CC D6
  LDA #$00                              ; $A203: A9 00
  STA menu_cursor_col                             ; $A205: 8D 24 04
  STA menu_cursor_page                             ; $A208: 8D 25 04
  RTS                                   ; $A20B: 60
.endproc

.proc ResetToIdle
  ; Full state reset: $0500=0, $0501=0, clear $0424/$0425
  LDA #$00                              ; $A20C: A9 00
  STA $0501                             ; $A20E: 8D 01 05
  STA $0500                             ; $A211: 8D 00 05
  STA menu_cursor_col                             ; $A214: 8D 24 04
  STA menu_cursor_page                             ; $A217: 8D 25 04
  RTS                                   ; $A21A: 60
.endproc

.proc OfficerDetailView
  ; State $0500=1: Display officer detail panel; exit on A/B press
  ; Dispatches on $0501 (3 phases: init, render+input, done)
  LDA $0501                             ; $A21B: AD 01 05
  JSR B1F_CallbackDispatcher            ; $A21E: 20 DE EA
; --- CallbackDispatcher table (3 entries) ---
  .word OfficerDetail_Init                  ; $A221: $27 A2
  .word OfficerDetail_RenderWait            ; $A223: $44 A2
  .word OfficerDetail_Done                  ; $A225: $7B A2
.endproc

.proc OfficerDetail_Init
  ; Advance phase; set up panel position and load officer ID for display
  INC $0501                             ; $A227: EE 01 05
  LDA #$08                              ; $A22A: A9 08
  STA $BA                               ; $A22C: 85 BA
  LDA #$06                              ; $A22E: A9 06
  STA $BB                               ; $A230: 85 BB
  LDA #$00                              ; $A232: A9 00
  STA detail_cursor_x                             ; $A234: 8D 0C 04
  STA detail_cursor_y                             ; $A237: 8D 0D 04
  LDY $0509                             ; $A23A: AC 09 05
  LDA $0664,Y                           ; $A23D: B9 64 06
  STA detail_officer_id                             ; $A240: 8D 10 04
  RTS                                   ; $A243: 60
.endproc

.proc OfficerDetail_RenderWait
  ; Render officer panel via trampoline; advance phase on A/B input
  JSR TryAutoAdvance                       ; $A244: 20 DE A1
  LDA #$A7                              ; $A247: A9 A7
  STA $0A                               ; $A249: 85 0A
  LDA detail_officer_id                             ; $A24B: AD 10 04
  STA $00                               ; $A24E: 85 00
  LDA #$00                              ; $A250: A9 00
  STA $00A4                             ; $A252: 8D A4 00
  LDY #$39                              ; $A255: A0 39
  JSR B1F_BankedCallbackTrampoline      ; $A257: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                               ; $A25A: $00 A0
  LDA #$06                                    ; $A25C: A9 06
  STA $BB                                     ; $A25E: 85 BB
  LDY #$39                                    ; $A260: A0 39
  JSR B1F_BankedCallbackTrampoline            ; $A262: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                               ; $A265: 12 A0
  JSR CheckExchangePossible                             ; $A267: 20 27 DF
  BCC @Done                             ; $A26A: 90 0E
  LDA $81                                     ; $A26C: A5 81
  AND #$03                                    ; $A26E: 29 03
  BEQ @Done                             ; $A270: F0 08
  INC $0501                                   ; $A272: EE 01 05
  LDA #$05                                    ; $A275: A9 05
  JSR $F293                             ; $A277: 20 93 F2
@Done:
  RTS                                   ; $A27A: 60
.endproc

.proc OfficerDetail_Done
  ; Wait for A/B input; reset state and finish sequence
  JSR TryAutoAdvance                       ; $A27B: 20 DE A1
  JSR CheckExchangePossible                             ; $A27E: 20 27 DF
  BCC @Exit                             ; $A281: 90 0F
  LDA #$09                              ; $A283: A9 09
  STA $BB                               ; $A285: 85 BB
  LDA #$00                              ; $A287: A9 00
  STA $0500                             ; $A289: 8D 00 05
  STA $0501                             ; $A28C: 8D 01 05
  JSR FinishSequence                       ; $A28F: 20 F7 A1
@Exit:
  RTS                                   ; $A292: 60
.endproc

.proc OfficerTransferExecute
  ; States $0500=2/3: Execute officer transfer between adjacent rulers
  ; Dispatches on $0501 (4 phases: init, target select, animation, result)
  LDY $050A                             ; $A293: AC 0A 05
  JSR CenterMapOnSlot                             ; $A296: 20 36 DC
  LDA $0501                             ; $A299: AD 01 05
  JSR B1F_CallbackDispatcher            ; $A29C: 20 DE EA
; --- CallbackDispatcher table (4 entries) ---
  .word OfficerTransfer_Init                ; $A29F: $A7 A2
  .word OfficerTransfer_SelectTarget        ; $A2A1: $BB A2
  .word OfficerTransfer_Animate             ; $A2A3: $0C A3
  .word OfficerTransfer_ShowResult          ; $A2A5: $25 A3
.endproc

.proc OfficerTransfer_Init
  ; Set UI mode, advance phase, copy source officer index
  LDA #$C3                                    ; $A2A7: A9 C3
  JSR B1F_SetUI5                              ; $A2A9: 20 83 F2
  INC $0501                                   ; $A2AC: EE 01 05
  LDA $0509                                   ; $A2AF: AD 09 05
  STA $050A                                   ; $A2B2: 8D 0A 05
  LDA #$00                                    ; $A2B5: A9 00
  STA $00A4                                   ; $A2B7: 8D A4 00
  RTS                                         ; $A2BA: 60
.endproc

.proc OfficerTransfer_SelectTarget
  ; Process cursor input; B cancels, A selects target and checks adjacency
  LDA $050A                             ; $A2BB: AD 0A 05
  STA $0509                             ; $A2BE: 8D 09 05
  JSR TryAutoAdvance                       ; $A2C1: 20 DE A1
  JSR ExchangeAnimFrameUpdate           ; $A2C4: 20 FB D4
  JSR RenderExchangeSprites             ; $A2C7: 20 57 D6
  JSR CheckExchangePossible                             ; $A2CA: 20 27 DF
  BCC @Done                             ; $A2CD: 90 3C
  LDA $81                               ; $A2CF: A5 81
  AND #$02                              ; $A2D1: 29 02
  BEQ @CheckConfirm                     ; $A2D3: F0 0D
  ; B button: cancel transfer, reset state
  LDA #$00                              ; $A2D5: A9 00
  STA $0501                             ; $A2D7: 8D 01 05
  LDA #$00                              ; $A2DA: A9 00
  STA $0500                             ; $A2DC: 8D 00 05
  JMP FinishSequence                       ; $A2DF: 4C F7 A1
@CheckConfirm:
  LDA $81                               ; $A2E2: A5 81
  AND #$01                              ; $A2E4: 29 01
  BEQ @Done                             ; $A2E6: F0 23
  JSR ScrollToTileSearch                             ; $A2E8: 20 8A D6
  TYA                                   ; $A2EB: 98
  BMI @Done                             ; $A2EC: 30 1D
  JSR CheckOfficerArmyGroup                             ; $A2EE: 20 4B DC
  CMP #$FF                              ; $A2F1: C9 FF
  BNE @Done                             ; $A2F3: D0 16
  STY $0509                             ; $A2F5: 8C 09 05
  JSR @CheckGridAdjacency               ; $A2F8: 20 68 A3
  TXA                                   ; $A2FB: 8A
  BMI @Done                             ; $A2FC: 30 0D
  ; Target is adjacent: advance to animation phase
  INC $0501                             ; $A2FE: EE 01 05
  LDA #$02                              ; $A301: A9 02
  STA $00A4                             ; $A303: 8D A4 00
  LDA #$CB                              ; $A306: A9 CB
  JSR B1F_SetUI2                        ; $A308: 20 83 F2
@Done:
  RTS                                   ; $A30B: 60
@CheckGridAdjacency:
  ; Check if source ($050A) and target (Y) officers are on adjacent grid cells
  ; Uses $0600 (grid X) and $0614 (grid Y) position tables
  ; Returns: X=0 if adjacent, X=$FF if not
  LDX $050A                             ; $A368: AE 0A 05
  LDA $0600,X                           ; $A36B: BD 00 06
  SEC                                   ; $A36E: 38
  SBC #$01                              ; $A36F: E9 01
  CMP $0600,Y                           ; $A371: D9 00 06
  BNE @CheckRight                       ; $A374: D0 09
  LDA $0614,X                           ; $A376: BD 14 06
  CMP $0614,Y                           ; $A379: D9 14 06
  BNE @CheckRight                       ; $A37C: D0 01
@Adjacent:
  RTS                                   ; $A37E: 60
@CheckRight:
  ; Check target at source X+1, same Y
  LDX $050A                             ; $A37F: AE 0A 05
  LDA $0600,X                           ; $A382: BD 00 06
  CLC                                   ; $A385: 18
  ADC #$01                              ; $A386: 69 01
  CMP $0600,Y                           ; $A388: D9 00 06
  BNE @CheckDown                        ; $A38B: D0 08
  LDA $0614,X                           ; $A38D: BD 14 06
  CMP $0614,Y                           ; $A390: D9 14 06
  BEQ @Adjacent                         ; $A393: F0 E9
@CheckDown:
  ; Check target at same X, source Y-1 (with wrap at boundary $0F)
  LDX $050A                             ; $A395: AE 0A 05
  LDA $0600,X                           ; $A398: BD 00 06
  CMP $0600,Y                           ; $A39B: D9 00 06
  BNE @CheckUp                          ; $A39E: D0 12
  LDA $0614,X                           ; $A3A0: BD 14 06
  SEC                                   ; $A3A3: 38
  SBC #$01                              ; $A3A4: E9 01
  CMP #$0F                              ; $A3A6: C9 0F
  BNE @CompareDown                      ; $A3A8: D0 03
  SEC                                   ; $A3AA: 38
  SBC #$01                              ; $A3AB: E9 01
@CompareDown:
  CMP $0614,Y                           ; $A3AD: D9 14 06
  BEQ @Adjacent                         ; $A3B0: F0 CC
@CheckUp:
  ; Check target at same X, source Y+1 (with wrap at boundary $0F)
  LDX $050A                             ; $A3B2: AE 0A 05
  LDA $0600,X                           ; $A3B5: BD 00 06
  CMP $0600,Y                           ; $A3B8: D9 00 06
  BNE @NotAdjacent                      ; $A3BB: D0 12
  LDA $0614,X                           ; $A3BD: BD 14 06
  CLC                                   ; $A3C0: 18
  ADC #$01                              ; $A3C1: 69 01
  CMP #$0F                              ; $A3C3: C9 0F
  BNE @CompareUp                        ; $A3C5: D0 03
  CLC                                   ; $A3C7: 18
  ADC #$01                              ; $A3C8: 69 01
@CompareUp:
  CMP $0614,Y                           ; $A3CA: D9 14 06
  BEQ @Adjacent                         ; $A3CD: F0 AF
@NotAdjacent:
  LDX #$FF                              ; $A3CF: A2 FF
  RTS                                   ; $A3D1: 60
.endproc

.proc OfficerTransfer_Animate
  ; Wait for animation; on complete, advance phase and set up result
  JSR DrawExchangeArrows_Right                             ; $A30C: 20 63 DC
  LDA $81                               ; $A30F: A5 81
  AND #$01                              ; $A311: 29 01
  BEQ @Done                             ; $A313: F0 0F
  JSR B1F_PaletteCopyBuffer             ; $A315: 20 EE EC
  INC $0501                             ; $A318: EE 01 05
  DEC $0505                             ; $A31B: CE 05 05
  DEC $0505                             ; $A31E: CE 05 05
  JSR OfficerTransfer_SetupResult                          ; $A321: 20 D2 A3
@Done:
  RTS                                   ; $A324: 60
OfficerTransfer_SetupResult:
  ; Load both officers' data and resolve ruler associations for result display
  ; $0560/$0561 = officer IDs, $052C/$052D = status, $052E/$052F = power
  ; $0562/$0563 = ruler byte-3 values for source/target rulers
  LDA #$00                              ; $A3D2: A9 00
  STA $0544                             ; $A3D4: 8D 44 05
  LDY $050A                             ; $A3D7: AC 0A 05
  LDX #$00                              ; $A3DA: A2 00
  JSR @LoadOfficerInfo                  ; $A3DC: 20 33 A4
  LDY $0509                             ; $A3DF: AC 09 05
  LDX #$01                              ; $A3E2: A2 01
  LDA #$00                              ; $A3E4: A9 00
  STA $0650,Y                           ; $A3E6: 99 50 06
  JSR @LoadOfficerInfo                  ; $A3E9: 20 33 A4
  ; Split $0507 packed ruler pair into $0564/$0565 (order depends on $0504)
  LDA $0504                             ; $A3EC: AD 04 05
  BMI @SwapRulerOrder                   ; $A3EF: 30 15
  LDA $0507                             ; $A3F1: AD 07 05
  AND #$0F                              ; $A3F4: 29 0F
  STA $0564                             ; $A3F6: 8D 64 05
  LDA $0507                             ; $A3F9: AD 07 05
  LSR                                   ; $A3FC: 4A
  LSR                                   ; $A3FD: 4A
  LSR                                   ; $A3FE: 4A
  LSR                                   ; $A3FF: 4A
  STA $0565                             ; $A400: 8D 65 05
  JMP @LoadRulerData                    ; $A403: 4C 18 A4
@SwapRulerOrder:
  LDA $0507                             ; $A406: AD 07 05
  AND #$0F                              ; $A409: 29 0F
  STA $0565                             ; $A40B: 8D 65 05
  LDA $0507                             ; $A40E: AD 07 05
  LSR                                   ; $A411: 4A
  LSR                                   ; $A412: 4A
  LSR                                   ; $A413: 4A
  LSR                                   ; $A414: 4A
  STA $0564                             ; $A415: 8D 64 05
@LoadRulerData:
  ; Fetch ruler data byte 3 for both source and target rulers
  LDA $0564                             ; $A418: AD 64 05
  JSR B1F_GetRulerDataPtr               ; $A41B: 20 68 F3
  LDY #$03                              ; $A41E: A0 03
  LDA ($00),Y                           ; $A420: B1 00
  STA $0562                             ; $A422: 8D 62 05
  LDA $0565                             ; $A425: AD 65 05
  JSR B1F_GetRulerDataPtr               ; $A428: 20 68 F3
  LDY #$03                              ; $A42B: A0 03
  LDA ($00),Y                           ; $A42D: B1 00
  STA $0563                             ; $A42F: 8D 63 05
  RTS                                   ; $A432: 60
@LoadOfficerInfo:
  ; Load officer ID, status flags (byte 11 hi-nibble), and power (byte 1)
  ; In: Y = officer list index, X = slot (0 or 1)
  LDA $0664,Y                           ; $A433: B9 64 06
  STA $0560,X                           ; $A436: 9D 60 05
  JSR B1F_GetOfficerRecordAddr          ; $A439: 20 D7 F2
  LDY #$0B                              ; $A43C: A0 0B
  LDA ($00),Y                           ; $A43E: B1 00
  AND #$F0                              ; $A440: 29 F0
  STA $052C,X                           ; $A442: 9D 2C 05
  LDY #$01                              ; $A445: A0 01
  LDA ($00),Y                           ; $A447: B1 00
  STA $052E,X                           ; $A449: 9D 2E 05
  RTS                                   ; $A44C: 60
.endproc

.proc OfficerTransfer_ShowResult
  ; Wait for animation flag; set up result display with officer/ruler data
  LDA $0087                             ; $A325: AD 87 00
  BPL @Done                             ; $A328: 10 3D
  LDA #$05                              ; $A32A: A9 05
  STA $007A                             ; $A32C: 8D 7A 00
  LDA #$00                              ; $A32F: A9 00
  STA $0540                             ; $A331: 8D 40 05
  STA $0541                             ; $A334: 8D 41 05
  STA $0542                             ; $A337: 8D 42 05
  STA $0543                             ; $A33A: 8D 43 05
  STA $00A4                             ; $A33D: 8D A4 00
  LDA $90                               ; $A340: A5 90
  STA $0510                             ; $A342: 8D 10 05
  LDA $91                               ; $A345: A5 91
  STA $0511                             ; $A347: 8D 11 05
  LDA $8E                               ; $A34A: A5 8E
  STA $0512                             ; $A34C: 8D 12 05
  LDA $8F                               ; $A34F: A5 8F
  STA $0513                             ; $A351: 8D 13 05
  LDY $0509                             ; $A354: AC 09 05
  LDA $0600,Y                           ; $A357: B9 00 06
  STA $10                               ; $A35A: 85 10
  LDA $0614,Y                           ; $A35C: B9 14 06
  STA $11                               ; $A35F: 85 11
  JSR GetTerrainType                    ; $A361: 20 46 DB
  STA $0544                             ; $A364: 8D 44 05
@Done:
  RTS                                   ; $A367: 60
.endproc

.proc OfficerMovePhase
  ; (dispatch callback target)
  LDA $0501                             ; $A44D: AD 01 05
  CMP #$02                              ; $A450: C9 02
  BCS @SkipReset                        ; $A452: B0 08
  LDA #$00                              ; $A454: A9 00
  STA $00A4                             ; $A456: 8D A4 00
  JSR CenterMapOnOfficer                             ; $A459: 20 33 DC
@SkipReset:
  LDA $0501                             ; $A45C: AD 01 05
  JSR B1F_CallbackDispatcher            ; $A45F: 20 DE EA
; --- CallbackDispatcher table (7 entries) ---
  .word MoveState_Init                      ; $A462: $70 A4
  .word MoveState_UndoCheck                 ; $A464: $7E A4
  .word MoveState_CheckDest                 ; $A466: $B5 A4
  .word MoveState_CheckStart                ; $A468: $1F A5
  .word MoveState_Select                    ; $A46A: $35 A5
  .word MoveState_Confirm                   ; $A46C: $CE A5
  .word MoveState_Cancel                    ; $A46E: $17 A6
.endproc

.proc MoveState_Init
  LDA #$C6                                    ; $A470: A9 C6
  JSR B1F_SetUI5                              ; $A472: 20 83 F2
  INC $0501                                   ; $A475: EE 01 05
  LDA #$00                                    ; $A478: A9 00
  STA $050A                                   ; $A47A: 8D 0A 05
  RTS                                         ; $A47D: 60
.endproc

.proc MoveState_UndoCheck
  JSR TryAutoAdvance                       ; $A47E: 20 DE A1
  JSR MovePhase_UndoStep                  ; $A481: 20 4A A6
  LDY $0509                             ; $A484: AC 09 05
  LDA $0600,Y                           ; $A487: B9 00 06
  STA $00                               ; $A48A: 85 00
  LDA $0614,Y                           ; $A48C: B9 14 06
  STA $02                               ; $A48F: 85 02
  JSR TileToPixelCoord                  ; $A491: 20 5A DA
  LDA $00                               ; $A494: A5 00
  STA $6F3F                             ; $A496: 8D 3F 6F
  LDA $01                               ; $A499: A5 01
  STA $6F40                             ; $A49B: 8D 40 6F
  LDA $02                               ; $A49E: A5 02
  STA $6F41                             ; $A4A0: 8D 41 6F
  LDA $03                               ; $A4A3: A5 03
  STA $6F42                             ; $A4A5: 8D 42 6F
  JSR MapScroll_Update                  ; $A4A8: 20 EE D5
  LDA $81                               ; $A4AB: A5 81
  AND #$01                              ; $A4AD: 29 01
  BEQ @Done                             ; $A4AF: F0 03
  INC $0501                             ; $A4B1: EE 01 05
@Done:
  RTS                                   ; $A4B4: 60
.endproc

.proc MoveState_CheckDest
  LDY $0509                             ; $A4B5: AC 09 05
  LDA $0600,Y                           ; $A4B8: B9 00 06
  STA $10                               ; $A4BB: 85 10
  LDA $0614,Y                           ; $A4BD: B9 14 06
  STA $11                               ; $A4C0: 85 11
  LDA $0504                             ; $A4C2: AD 04 05
  BPL $A4D6                             ; $A4C5: 10 0F
  JSR GetTerrainType                    ; $A4C7: 20 46 DB
  CMP #$05                              ; $A4CA: C9 05
  BNE $A4D6                             ; $A4CC: D0 08
  LDY #$28                              ; $A4CE: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $A4D0: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A027                               ; $A4D3: $27 A0
  RTS                                         ; $A4D5: 60
  LDA $050F                                   ; $A4D6: AD 0F 05
  CMP #$03                                    ; $A4D9: C9 03
  BEQ @AdvanceState                     ; $A4DB: F0 27
  LDY #$31                                    ; $A4DD: A0 31
  JSR $F25F                             ; $A4DF: 20 5F F2
  LDA $050E                                   ; $A4E2: AD 0E 05
  ASL A                                       ; $A4E5: 0A
  STA $00                                     ; $A4E6: 85 00
  ASL A                                       ; $A4E8: 0A
  CLC                                         ; $A4E9: 18
  ADC $00                                     ; $A4EA: 65 00
  TAY                                         ; $A4EC: A8
  LDX #$00                                    ; $A4ED: A2 00
@ScanLoop:
  LDA $9BA4,Y                           ; $A4EF: B9 A4 9B
  CMP $10                               ; $A4F2: C5 10
  BNE @NextEntry                        ; $A4F4: D0 07
  LDA $9BA5,Y                           ; $A4F6: B9 A5 9B
  CMP $11                               ; $A4F9: C5 11
  BEQ MoveState_CheckDest_Found          ; $A4FB: F0 0B
@NextEntry:
  INY                                   ; $A4FD: C8
  INY                                   ; $A4FE: C8
  INX                                   ; $A4FF: E8
  CPX #$03                              ; $A500: E0 03
  BCC @ScanLoop                         ; $A502: 90 EB
@AdvanceState:
  INC $0501                             ; $A504: EE 01 05
  RTS                                   ; $A507: 60
.endproc

.proc MoveState_CheckDest_Found
  STX anim_ppu_ptr_lo                             ; $A508: 8E 70 04
  LDA #$01                              ; $A50B: A9 01
  STA $12                               ; $A50D: 85 12
  JSR UpdateCursorTile                             ; $A50F: 20 CC D6
  LDA #$09                              ; $A512: A9 09
  STA $0500                             ; $A514: 8D 00 05
  STA $0501                             ; $A517: 8D 01 05
  LDA #$A7                              ; $A51A: A9 A7
  JMP B1F_SetUI5                        ; $A51C: 4C 93 F2
.endproc

.proc MoveState_CheckStart
  LDA $6F8B                             ; $A51F: AD 8B 6F
  CMP #$FF                              ; $A522: C9 FF
  BNE @Done                             ; $A524: D0 0E
  LDA #$01                              ; $A526: A9 01
  STA $6F8B                             ; $A528: 8D 8B 6F
  LDA $0509                             ; $A52B: AD 09 05
  STA $6F8C                             ; $A52E: 8D 8C 6F
  INC $0501                             ; $A531: EE 01 05
@Done:
  RTS                                   ; $A534: 60
.endproc

.proc MoveState_Select
  LDA $6F8B                             ; $A535: AD 8B 6F
  CMP #$FF                              ; $A538: C9 FF
  BEQ @CheckPhase                       ; $A53A: F0 01
  RTS                                   ; $A53C: 60
@CheckPhase:
  LDA $6F8F                             ; $A53D: AD 8F 6F
  BEQ @InitSelection                    ; $A540: F0 03
  JMP MovePhase_Exit                    ; $A542: 4C 34 A6
@InitSelection:
  INC $0501                             ; $A545: EE 01 05
  LDA officer_sel_list                             ; $A548: AD 2C 04
  STA $0B                               ; $A54B: 85 0B
  LDA officer_sel_list+1                             ; $A54D: AD 2D 04
  STA $0C                               ; $A550: 85 0C
  LDY #$04                              ; $A552: A0 04
  LDA $0504                             ; $A554: AD 04 05
  BPL @LoadOfficer                      ; $A557: 10 02
  LDY #$00                              ; $A559: A0 00
@LoadOfficer:
  LDA army_slot_base,Y                           ; $A55B: B9 D8 04
  TAY                                   ; $A55E: A8
  LDA $0664,Y                           ; $A55F: B9 64 06
  STA $0A                               ; $A562: 85 0A
  JSR B1F_GetOfficerRecordAddr          ; $A564: 20 D7 F2
  LDY #$0B                              ; $A567: A0 0B
  LDA ($00),Y                           ; $A569: B1 00
  AND #$F0                              ; $A56B: 29 F0
  STA $052C                             ; $A56D: 8D 2C 05
  LDY #$01                              ; $A570: A0 01
  LDA ($00),Y                           ; $A572: B1 00
  STA $052E                             ; $A574: 8D 2E 05
  LDY #$2E                              ; $A577: A0 2E
  JSR B1F_BankedCallbackTrampoline      ; $A579: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A006                               ; $A57C: $06 A0
  JSR CalcOfficerMeritLevels              ; $A57E: 20 03 DB
  LDA $0509                                   ; $A581: AD 09 05
  STA $050A                                   ; $A584: 8D 0A 05
  LDY $6F8C                                   ; $A587: AC 8C 6F
  LDA $6FA1,Y                                 ; $A58A: B9 A1 6F
  CMP #$FF                                    ; $A58D: C9 FF
  BEQ @NoAlly                           ; $A58F: F0 19
  LDY #$04                                    ; $A591: A0 04
  LDA $0504                                   ; $A593: AD 04 05
  BPL @RestoreSlot                      ; $A596: 10 02
  LDY #$00                                    ; $A598: A0 00
@RestoreSlot:
  LDA army_slot_base,Y                           ; $A59A: B9 D8 04
  STA $0509                             ; $A59D: 8D 09 05
  LDA #$04                              ; $A5A0: A9 04
  STA $00A4                             ; $A5A2: 8D A4 00
  LDA #$B9                              ; $A5A5: A9 B9
  JMP @ShowUI                           ; $A5A7: 4C B6 A5
@NoAlly:
  LDA #$03                              ; $A5AA: A9 03
  STA $00A4                             ; $A5AC: 8D A4 00
  LDA #$00                              ; $A5AF: A9 00
  STA $052E                             ; $A5B1: 8D 2E 05
  LDA #$B8                              ; $A5B4: A9 B8
@ShowUI:
  JSR B1F_SetUI2                        ; $A5B6: 20 83 F2
  LDY #$3D                              ; $A5B9: A0 3D
  JSR B1F_BankedCallbackTrampoline      ; $A5BB: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A027                               ; $A5BE: $27 A0
  LDA $0509                                   ; $A5C0: AD 09 05
  TAX                                         ; $A5C3: AA
  LDA $050A                                   ; $A5C4: AD 0A 05
  STA $0509                                   ; $A5C7: 8D 09 05
  STX $050A                                   ; $A5CA: 8E 0A 05
  RTS                                         ; $A5CD: 60
.endproc

.proc MoveState_Confirm
  LDA #$03                              ; $A5CE: A9 03
  STA $00A4                             ; $A5D0: 8D A4 00
  LDY $050A                             ; $A5D3: AC 0A 05
  JSR CenterMapOnSlot                             ; $A5D6: 20 36 DC
  JSR TryAutoAdvance                       ; $A5D9: 20 DE A1
  JSR CheckExchangePossible                             ; $A5DC: 20 27 DF
  BCC @Done                             ; $A5DF: 90 35
  JSR DrawExchangeArrows_Right                             ; $A5E1: 20 63 DC
  LDA $81                               ; $A5E4: A5 81
  AND #$03                              ; $A5E6: 29 03
  BEQ @Done                             ; $A5E8: F0 2C
  LDY #$04                              ; $A5EA: A0 04
  LDA $0504                             ; $A5EC: AD 04 05
  BPL @ClearSlot                        ; $A5EF: 10 02
  LDY #$00                              ; $A5F1: A0 00
@ClearSlot:
  LDA #$FF                              ; $A5F3: A9 FF
  STA army_slot_base,Y                           ; $A5F5: 99 D8 04
  LDA $052E                             ; $A5F8: AD 2E 05
  BEQ MovePhase_Exit                    ; $A5FB: F0 37
  LDY $050A                             ; $A5FD: AC 0A 05
  LDA $0664,Y                           ; $A600: B9 64 06
  STA officer_sel_list                             ; $A603: 8D 2C 04
  JSR ValidateExchangeOfficer           ; $A606: 20 E9 DE
  BCS @Skip1                            ; $A609: 90 29 (inverted)
  JMP MovePhase_Exit                    ; (was fall-through to @A634)
@Skip1:
  INC $0501                             ; $A60B: EE 01 05
  JSR B1F_BankPpuInit                   ; $A60E: 20 7F E5
  LDA #$7B                              ; $A611: A9 7B
  JSR B1F_SoundWrapperD                 ; $A613: 20 8B E6
@Done:
  RTS                                   ; $A616: 60
.endproc

.proc MoveState_Cancel
  JSR CheckExchangePossible                             ; $A617: 20 27 DF
  BCC @Done                             ; $A61A: 90 23
  JSR DrawExchangeArrows_Right                             ; $A61C: 20 63 DC
  LDA $81                               ; $A61F: A5 81
  AND #$03                              ; $A621: 29 03
  BEQ @Done                             ; $A623: F0 1A
  LDA officer_sel_list+1                             ; $A625: AD 2D 04
  CMP #$FF                              ; $A628: C9 FF
  BNE @ShowCancelUI                     ; $A62A: D0 14
  JSR B1F_BankPpuInit                   ; $A62C: 20 7F E5
  LDA #$1D                              ; $A62F: A9 1D
  JSR B1F_SoundWrapperA                 ; $A631: 20 73 E6
  JSR MovePhase_Exit                    ; (was fall-through to @A634)
@Done:
  RTS                                   ; $A63F: 60
@ShowCancelUI:
  LDA #$FF                              ; $A640: A9 FF
  STA officer_sel_list+1                             ; $A642: 8D 2D 04
  LDA #$4B                              ; $A645: A9 4B
  JMP B1F_SetUI5                        ; $A647: 4C 93 F2
.endproc

.proc MovePhase_Exit
  LDA #$00                              ; $A634: A9 00
  STA $0500                             ; $A636: 8D 00 05
  STA $0501                             ; $A639: 8D 01 05
  JSR FinishSequence                    ; $A63C: 20 F7 A1
  RTS
.endproc

.proc MovePhase_UndoStep
  LDA $81                               ; $A64A: A5 81
  AND #$02                              ; $A64C: 29 02
  BEQ @CheckLeft                        ; $A64E: F0 32
  LDY $050A                             ; $A650: AC 0A 05
  BEQ @CheckLeft                        ; $A653: F0 2D
  LDA #$00                              ; $A655: A9 00
  STA $12                               ; $A657: 85 12
  JSR UpdateCursorTile                             ; $A659: 20 CC D6
  LDY $050A                             ; $A65C: AC 0A 05
  LDX $0509                             ; $A65F: AE 09 05
  LDA $053D,Y                           ; $A662: B9 3D 05
  STA $0600,X                           ; $A665: 9D 00 06
  LDA $053E,Y                           ; $A668: B9 3E 05
  STA $0614,X                           ; $A66B: 9D 14 06
  LDA $053F,Y                           ; $A66E: B9 3F 05
  CLC                                   ; $A671: 18
  ADC $0505                             ; $A672: 6D 05 05
  STA $0505                             ; $A675: 8D 05 05
  DEC $050A                             ; $A678: CE 0A 05
  DEC $050A                             ; $A67B: CE 0A 05
  DEC $050A                             ; $A67E: CE 0A 05
  RTS                                   ; $A681: 60
@CheckLeft:
  LDA $81                               ; $A682: A5 81
  ASL                                   ; $A684: 0A
  BPL @CheckRight                       ; $A685: 10 47
  LDY $0509                             ; $A687: AC 09 05
  LDA $0600,Y                           ; $A68A: B9 00 06
  SEC                                   ; $A68D: 38
  SBC #$01                              ; $A68E: E9 01
  BCC @CheckRight                       ; $A690: 90 3C
  STA $00                               ; $A692: 85 00
  LDA $0614,Y                           ; $A694: B9 14 06
  STA $01                               ; $A697: 85 01
  JSR SearchRosterByTileCoord                             ; $A699: 20 B6 D6
  TYA                                   ; $A69C: 98
  BPL @CheckRight                       ; $A69D: 10 2F
  LDY $0509                             ; $A69F: AC 09 05
  LDA $0600,Y                           ; $A6A2: B9 00 06
  SEC                                   ; $A6A5: 38
  SBC #$01                              ; $A6A6: E9 01
  STA $10                               ; $A6A8: 85 10
  LDA $0614,Y                           ; $A6AA: B9 14 06
  STA $11                               ; $A6AD: 85 11
  JSR GetTerrainType                    ; $A6AF: 20 46 DB
  JSR MovePhase_CalcCost                ; $A6B2: 20 E7 A7
  BCC @CheckRight                       ; $A6B5: 90 17
  STA $0505                             ; $A6B7: 8D 05 05
  TXA                                   ; $A6BA: 8A
  PHA                                   ; $A6BB: 48
  LDA #$00                              ; $A6BC: A9 00
  STA $12                               ; $A6BE: 85 12
  JSR UpdateCursorTile                             ; $A6C0: 20 CC D6
  PLA                                   ; $A6C3: 68
  JSR MovePhase_RecordMove              ; $A6C4: 20 5B A8
  LDX $0509                             ; $A6C7: AE 09 05
  DEC $0600,X                           ; $A6CA: DE 00 06
  RTS                                   ; $A6CD: 60
@CheckRight:
  LDA $81                               ; $A6CE: A5 81
  BPL @CheckUp                          ; $A6D0: 10 49
  LDY $0509                             ; $A6D2: AC 09 05
  LDA $0600,Y                           ; $A6D5: B9 00 06
  CLC                                   ; $A6D8: 18
  ADC #$01                              ; $A6D9: 69 01
  CMP #$20                              ; $A6DB: C9 20
  BCS @CheckUp                          ; $A6DD: B0 3C
  STA $00                               ; $A6DF: 85 00
  LDA $0614,Y                           ; $A6E1: B9 14 06
  STA $01                               ; $A6E4: 85 01
  JSR SearchRosterByTileCoord                             ; $A6E6: 20 B6 D6
  TYA                                   ; $A6E9: 98
  BPL @CheckUp                          ; $A6EA: 10 2F
  LDY $0509                             ; $A6EC: AC 09 05
  LDA $0600,Y                           ; $A6EF: B9 00 06
  CLC                                   ; $A6F2: 18
  ADC #$01                              ; $A6F3: 69 01
  STA $10                               ; $A6F5: 85 10
  LDA $0614,Y                           ; $A6F7: B9 14 06
  STA $11                               ; $A6FA: 85 11
  JSR GetTerrainType                    ; $A6FC: 20 46 DB
  JSR MovePhase_CalcCost                ; $A6FF: 20 E7 A7
  BCC @CheckUp                          ; $A702: 90 17
  STA $0505                             ; $A704: 8D 05 05
  TXA                                   ; $A707: 8A
  PHA                                   ; $A708: 48
  LDA #$00                              ; $A709: A9 00
  STA $12                               ; $A70B: 85 12
  JSR UpdateCursorTile                             ; $A70D: 20 CC D6
  PLA                                   ; $A710: 68
  JSR MovePhase_RecordMove              ; $A711: 20 5B A8
  LDX $0509                             ; $A714: AE 09 05
  INC $0600,X                           ; $A717: FE 00 06
  RTS                                   ; $A71A: 60
@CheckUp:
  LDA $81                               ; $A71B: A5 81
  ASL                                   ; $A71D: 0A
  ASL                                   ; $A71E: 0A
  ASL                                   ; $A71F: 0A
  BPL @CheckDown                        ; $A720: 10 5E
  LDY $0509                             ; $A722: AC 09 05
  LDA $0600,Y                           ; $A725: B9 00 06
  STA $00                               ; $A728: 85 00
  LDA $0614,Y                           ; $A72A: B9 14 06
  SEC                                   ; $A72D: 38
  SBC #$01                              ; $A72E: E9 01
  BMI @CheckDown                        ; $A730: 30 4E
  CMP #$0F                              ; $A732: C9 0F
  BNE @SkipRowAdj1                      ; $A734: D0 03
  SEC                                   ; $A736: 38
  SBC #$01                              ; $A737: E9 01
@SkipRowAdj1:
  STA $01                               ; $A739: 85 01
  JSR SearchRosterByTileCoord                             ; $A73B: 20 B6 D6
  TYA                                   ; $A73E: 98
  BPL @CheckDown                        ; $A73F: 10 3F
  LDY $0509                             ; $A741: AC 09 05
  LDA $0600,Y                           ; $A744: B9 00 06
  STA $10                               ; $A747: 85 10
  LDA $0614,Y                           ; $A749: B9 14 06
  SEC                                   ; $A74C: 38
  SBC #$01                              ; $A74D: E9 01
  CMP #$0F                              ; $A74F: C9 0F
  BNE @SkipRowAdj2                      ; $A751: D0 03
  SEC                                   ; $A753: 38
  SBC #$01                              ; $A754: E9 01
@SkipRowAdj2:
  STA $11                               ; $A756: 85 11
  JSR GetTerrainType                    ; $A758: 20 46 DB
  JSR MovePhase_CalcCost                ; $A75B: 20 E7 A7
  BCC @CheckDown                        ; $A75E: 90 20
  STA $0505                             ; $A760: 8D 05 05
  TXA                                   ; $A763: 8A
  PHA                                   ; $A764: 48
  LDA #$00                              ; $A765: A9 00
  STA $12                               ; $A767: 85 12
  JSR UpdateCursorTile                             ; $A769: 20 CC D6
  PLA                                   ; $A76C: 68
  JSR MovePhase_RecordMove              ; $A76D: 20 5B A8
  LDX $0509                             ; $A770: AE 09 05
  DEC $0614,X                           ; $A773: DE 14 06
  LDA $0614,X                           ; $A776: BD 14 06
  CMP #$0F                              ; $A779: C9 0F
  BNE @CheckDown                        ; $A77B: D0 03
  DEC $0614,X                           ; $A77D: DE 14 06
@CheckDown:
  LDA $81                               ; $A780: A5 81
  ASL                                   ; $A782: 0A
  ASL                                   ; $A783: 0A
  BPL @Done                             ; $A784: 10 60
  LDY $0509                             ; $A786: AC 09 05
  LDA $0600,Y                           ; $A789: B9 00 06
  STA $00                               ; $A78C: 85 00
  LDA $0614,Y                           ; $A78E: B9 14 06
  CLC                                   ; $A791: 18
  ADC #$01                              ; $A792: 69 01
  CMP #$14                              ; $A794: C9 14
  BCS @Done                             ; $A796: B0 4E
  CMP #$0F                              ; $A798: C9 0F
  BNE @SkipRowAdj3                      ; $A79A: D0 03
  CLC                                   ; $A79C: 18
  ADC #$01                              ; $A79D: 69 01
@SkipRowAdj3:
  STA $01                               ; $A79F: 85 01
  JSR SearchRosterByTileCoord                             ; $A7A1: 20 B6 D6
  TYA                                   ; $A7A4: 98
  BPL @Done                             ; $A7A5: 10 3F
  LDY $0509                             ; $A7A7: AC 09 05
@LoadPos:
  LDA $0600,Y                           ; $A7AA: B9 00 06
  STA $10                               ; $A7AD: 85 10
  LDA $0614,Y                           ; $A7AF: B9 14 06
  CLC                                   ; $A7B2: 18
  ADC #$01                              ; $A7B3: 69 01
  CMP #$0F                              ; $A7B5: C9 0F
  BNE @SkipRowAdj4                      ; $A7B7: D0 03
  CLC                                   ; $A7B9: 18
  ADC #$01                              ; $A7BA: 69 01
@SkipRowAdj4:
  STA $11                               ; $A7BC: 85 11
  JSR GetTerrainType                    ; $A7BE: 20 46 DB
  JSR MovePhase_CalcCost                ; $A7C1: 20 E7 A7
  BCC @Done                             ; $A7C4: 90 20
  STA $0505                             ; $A7C6: 8D 05 05
  TXA                                   ; $A7C9: 8A
  PHA                                   ; $A7CA: 48
  LDA #$00                              ; $A7CB: A9 00
  STA $12                               ; $A7CD: 85 12
  JSR UpdateCursorTile                             ; $A7CF: 20 CC D6
  PLA                                   ; $A7D2: 68
  JSR MovePhase_RecordMove              ; $A7D3: 20 5B A8
  LDX $0509                             ; $A7D6: AE 09 05
  INC $0614,X                           ; $A7D9: FE 14 06
  LDA $0614,X                           ; $A7DC: BD 14 06
  CMP #$0F                              ; $A7DF: C9 0F
  BNE @Done                             ; $A7E1: D0 03
  INC $0614,X                           ; $A7E3: FE 14 06
@Done:
  RTS                                   ; $A7E6: 60
.endproc

.proc MovePhase_CalcCost
  PHA                                   ; $A7E7: 48
  LDY $0509                             ; $A7E8: AC 09 05
  LDA $0664,Y                           ; $A7EB: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $A7EE: 20 D7 F2
  LDY #$0B                              ; $A7F1: A0 0B
  LDA ($00),Y                           ; $A7F3: B1 00
  LSR                                   ; $A7F5: 4A
  LSR                                   ; $A7F6: 4A
  AND #$03                              ; $A7F7: 29 03
  STA $00                               ; $A7F9: 85 00
  PLA                                   ; $A7FB: 68
  ASL                                   ; $A7FC: 0A
  ASL                                   ; $A7FD: 0A
  ORA $00                               ; $A7FE: 05 00
  TAY                                   ; $A800: A8
  LDX $0509                             ; $A801: AE 09 05
  LDA $063C,X                           ; $A804: BD 3C 06
  CMP #$06                              ; $A807: C9 06
  BCC @UseLowRank                       ; $A809: 90 0C
  LDA @MoveCost_HighRank,Y              ; $A80B: B9 23 A8
  TAX                                   ; $A80E: AA
  LDA $0505                             ; $A80F: AD 05 05
  SEC                                   ; $A812: 38
  SBC @MoveCost_HighRank,Y              ; $A813: F9 23 A8
  RTS                                   ; $A816: 60
@UseLowRank:
  LDA @MoveCost_LowRank,Y               ; $A817: B9 3F A8
  TAX                                   ; $A81A: AA
  LDA $0505                             ; $A81B: AD 05 05
  SEC                                   ; $A81E: 38
  SBC @MoveCost_LowRank,Y               ; $A81F: F9 3F A8
  RTS                                   ; $A822: 60
; Movement cost table for high-rank officers (rank >= 6)
; Indexed by (direction × 4 + rank), 4 bytes per direction (3 costs + padding)
@MoveCost_HighRank:
  .byte $03,$05,$05,$00,$04,$04,$04,$00,$02,$03,$03,$00,$05,$06,$03,$00; $A823: 03 05 05 00 04 04 04 00 02 03 03 00 05 06 03 00
  .byte $05,$03,$06,$00,$06,$06,$06,$00,$06,$06,$06,$00,$02,$03,$03,$00; $A833: 05 03 06 00 06 06 06 00 06 06 06 00 02 03 03 00
; Movement cost table for low-rank officers (rank < 6)
@MoveCost_LowRank:
  .byte $03,$03,$03,$00,$01,$02,$02,$00,$03,$05,$02,$00,$03,$02,$04,$00; $A843: 03 03 03 00 01 02 02 00 03 05 02 00 03 02 04 00
  .byte $04,$04,$04,$00,$04,$04,$04,$00   ; $A853: 04 04 04 00 04 04 04 00
.endproc

.proc MovePhase_RecordMove
  PHA                                   ; $A85B: 48
  LDY $050A                             ; $A85C: AC 0A 05
  LDX $0509                             ; $A85F: AE 09 05
  LDA $0600,X                           ; $A862: BD 00 06
  STA $0540,Y                           ; $A865: 99 40 05
  LDA $0614,X                           ; $A868: BD 14 06
  STA $0541,Y                           ; $A86B: 99 41 05
  PLA                                   ; $A86E: 68
  STA $0542,Y                           ; $A86F: 99 42 05
  INC $050A                             ; $A872: EE 0A 05
  INC $050A                             ; $A875: EE 0A 05
  INC $050A                             ; $A878: EE 0A 05
  RTS                                   ; $A87B: 60
.endproc

.proc OfficerCommandPhase
  ; (dispatch callback target)
  LDY $050A                             ; $A87C: AC 0A 05
  JSR CenterMapOnSlot                             ; $A87F: 20 36 DC
  LDA $0501                             ; $A882: AD 01 05
  JSR B1F_CallbackDispatcher            ; $A885: 20 DE EA
; --- CallbackDispatcher table (11 entries) ---
  .word CommandState_Init                    ; $A888: $9E A8
  .word CommandState_Animate                 ; $A88A: $C1 A8
  .word CommandState_MenuSetup               ; $A88C: $D8 A8
  .word CommandState_Menu                    ; $A88E: $17 A9
  .word CommandState_SelectTarget            ; $A890: $DD A9
  .word CommandState_Confirm                 ; $A892: $2E AA
  .word CommandState_ShowResult              ; $A894: $6C AA
  .word CommandState_Cancel                  ; $A896: $A7 AA
  .word CommandState_Confirm2                ; $A898: $2A AB
  .word CommandState_CancelConfirm           ; $A89A: $52 AB
  .word CommandState_Reset                   ; $A89C: $90 AB
.endproc

.proc CommandState_Init
  LDA #$F3                              ; $A89E: A9 F3
  STA $0310                             ; $A8A0: 8D 10 03
  LDA #$00                              ; $A8A3: A9 00
  STA $0300                             ; $A8A5: 8D 00 03
  STA $050B                             ; $A8A8: 8D 0B 05
  LDY #$03                              ; $A8AB: A0 03
@CopyLoop:
  LDA $6F3F,Y                           ; $A8AD: B9 3F 6F
  STA kingdom_param_copy,Y                           ; $A8B0: 99 6C 04
  DEY                                   ; $A8B3: 88
  BPL @CopyLoop                         ; $A8B4: 10 F7
  INC $0501                             ; $A8B6: EE 01 05
  LDY #$28                              ; $A8B9: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $A8BB: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A01B                               ; $A8BE: $1B A0
  RTS                                         ; $A8C0: 60
.endproc

.proc CommandState_Animate
  JSR CheckExchangePossible                             ; $A8C1: 20 27 DF
  BCC @Done                             ; $A8C4: 90 11
  JSR CommandPhase_BuildMsg              ; $A8C6: 20 D9 AB
  LDA $050B                             ; $A8C9: AD 0B 05
  INC $050B                             ; $A8CC: EE 0B 05
  CMP $0542                             ; $A8CF: CD 42 05
  BCC @Done                             ; $A8D2: 90 03
  INC $0501                             ; $A8D4: EE 01 05
@Done:
  RTS                                   ; $A8D7: 60
.endproc

.proc CommandState_MenuSetup
  LDA #$C7                              ; $A8D8: A9 C7
  JSR B1F_SetUI2                        ; $A8DA: 20 83 F2
  INC $0501                             ; $A8DD: EE 01 05
  LDA #$E1                              ; $A8E0: A9 E1
  STA $E7                               ; $A8E2: 85 E7
  LDA #$E1                              ; $A8E4: A9 E1
  STA $E9                               ; $A8E6: 85 E9
  LDA #$02                              ; $A8E8: A9 02
  STA $B4                               ; $A8EA: 85 B4
  LDA #$16                              ; $A8EC: A9 16
  STA $B3                               ; $A8EE: 85 B3
  LDA #$17                              ; $A8F0: A9 17
  STA $B5                               ; $A8F2: 85 B5
  LDA #$5B                              ; $A8F4: A9 5B
  STA $B2                               ; $A8F6: 85 B2
  LDA $8E                               ; $A8F8: A5 8E
  STA $0540                             ; $A8FA: 8D 40 05
  LDA $90                               ; $A8FD: A5 90
  STA $0541                             ; $A8FF: 8D 41 05
  LDA #$00                              ; $A902: A9 00
  STA $8E                               ; $A904: 85 8E
  LDA #$50                              ; $A906: A9 50
  STA $90                               ; $A908: 85 90
  LDA #$01                              ; $A90A: A9 01
  STA $8F                               ; $A90C: 85 8F
  LDA #$00                              ; $A90E: A9 00
  STA menu_cursor_col                             ; $A910: 8D 24 04
  STA menu_cursor_page                             ; $A913: 8D 25 04
  RTS                                   ; $A916: 60
.endproc

.proc CommandState_Menu
  LDA #$5B                              ; $A917: A9 5B
  STA $B2                               ; $A919: 85 B2
  LDA $0542                             ; $A91B: AD 42 05
  ASL                                   ; $A91E: 0A
  TAY                                   ; $A91F: A8
  LDA MenuTypeItemListPtrs,Y            ; $A920: B9 9F BA
  STA $10                               ; $A923: 85 10
  LDA MenuTypeItemListPtrs+1,Y          ; $A925: B9 A0 BA
  STA $11                               ; $A928: 85 11
  LDA #$00                              ; $A92A: A9 00
  STA $12                               ; $A92C: 85 12
  JSR B1F_MenuStep2                     ; $A92E: 20 1E ED
  LDA #$A4                              ; $A931: A9 A4
  STA $10                               ; $A933: 85 10
  LDA #$AB                              ; $A935: A9 AB
  STA $11                               ; $A937: 85 11
  LDA #$C4                              ; $A939: A9 C4
  STA $00                               ; $A93B: 85 00
  LDA #$AB                              ; $A93D: A9 AB
  STA $01                               ; $A93F: 85 01
  LDA $12                               ; $A941: A5 12
  JSR B1F_PointerTableLookup            ; $A943: 20 F5 ED
  JSR CheckExchangePossible                             ; $A946: 20 27 DF
  BCC @Done                             ; $A949: 90 54
  LDA $81                               ; $A94B: A5 81
  AND #$01                              ; $A94D: 29 01
  BEQ @CheckCancel                      ; $A94F: F0 17
  LDY $12                               ; $A951: A4 12
  LDA $0580,Y                           ; $A953: B9 80 05
  STA $0543                             ; $A956: 8D 43 05
  LDA $0505                             ; $A959: AD 05 05
  LDY $12                               ; $A95C: A4 12
  CMP @ActionParamTable+5,Y             ; $A95E: D9 C9 AB
  BCC @NotEnough                        ; $A961: 90 03
  JMP CommandState_Menu_Enough           ; $A963: 4C A0 A9
@NotEnough:
  LDA #$00                              ; $A966: A9 00
@CheckCancel:
  LDA $81                               ; $A968: A5 81
  AND #$02                              ; $A96A: 29 02
  BEQ @Done                             ; $A96C: F0 31
  LDA #$E0                              ; $A96E: A9 E0
  STA $E7                               ; $A970: 85 E7
  LDA #$E0                              ; $A972: A9 E0
  STA $E9                               ; $A974: 85 E9
  LDA #$89                              ; $A976: A9 89
  STA $B3                               ; $A978: 85 B3
  LDA #$8A                              ; $A97A: A9 8A
  STA $B4                               ; $A97C: 85 B4
  LDA #$88                              ; $A97E: A9 88
  STA $B5                               ; $A980: 85 B5
  STA $B2                               ; $A982: 85 B2
  LDA $0540                             ; $A984: AD 40 05
  STA $8E                               ; $A987: 85 8E
  LDA $0541                             ; $A989: AD 41 05
  STA $90                               ; $A98C: 85 90
  LDA #$00                              ; $A98E: A9 00
  STA $8F                               ; $A990: 85 8F
  LDA #$00                              ; $A992: A9 00
  STA $0501                             ; $A994: 8D 01 05
  LDA #$00                              ; $A997: A9 00
  STA $0500                             ; $A999: 8D 00 05
  JMP FinishSequence                       ; $A99C: 4C F7 A1
@Done:
  RTS                                   ; $A99F: 60
.endproc

.proc CommandState_Menu_Enough
  LDA #$89                              ; $A9A0: A9 89
  STA $B3                               ; $A9A2: 85 B3
  LDA #$8A                              ; $A9A4: A9 8A
  STA $B4                               ; $A9A6: 85 B4
  LDA #$88                              ; $A9A8: A9 88
  STA $B5                               ; $A9AA: 85 B5
  STA $B2                               ; $A9AC: 85 B2
  LDA $0540                             ; $A9AE: AD 40 05
  STA $8E                               ; $A9B1: 85 8E
  LDA $0541                             ; $A9B3: AD 41 05
  STA $90                               ; $A9B6: 85 90
  LDA #$00                              ; $A9B8: A9 00
  STA $8F                               ; $A9BA: 85 8F
  LDA #$E0                              ; $A9BC: A9 E0
  STA $E7                               ; $A9BE: 85 E7
  LDA #$E0                              ; $A9C0: A9 E0
  STA $E9                               ; $A9C2: 85 E9
  LDA $0543                             ; $A9C4: AD 43 05
  CMP #$0B                              ; $A9C7: C9 0B
  BNE @ShowMenuUI                       ; $A9C9: D0 09
  LDY $050A                             ; $A9CB: AC 0A 05
  INC $0501                             ; $A9CE: EE 01 05
  JMP CommandState_SelectTarget_Proceed  ; $A9D1: 4C 03 AA
@ShowMenuUI:
  LDA #$F4                              ; $A9D4: A9 F4
  JSR B1F_SetUI2                        ; $A9D6: 20 83 F2
  INC $0501                             ; $A9D9: EE 01 05
  RTS                                   ; $A9DC: 60
.endproc

.proc CommandState_SelectTarget
  JSR ExchangeAnimFrameUpdate           ; $A9DD: 20 FB D4
  JSR MapScroll_Update                  ; $A9E0: 20 EE D5
  JSR RenderExchangeSprites             ; $A9E3: 20 57 D6
  JSR CheckExchangePossible                             ; $A9E6: 20 27 DF
  BCC CommandState_SelectTarget_Done     ; $A9E9: 90 3D
  LDA $81                               ; $A9EB: A5 81
  LSR                                   ; $A9ED: 4A
  BCS @HandleConfirm                    ; $A9EE: B0 06
  LSR                                   ; $A9F0: 4A
  BCS CommandState_SelectTarget_Reset    ; $A9F1: B0 30
  JMP CommandState_SelectTarget_Done     ; $A9F3: 4C 28 AA
@HandleConfirm:
  JSR ScrollToTileSearch                             ; $A9F6: 20 8A D6
  TYA                                   ; $A9F9: 98
  BMI CommandState_SelectTarget_Done     ; $A9FA: 30 2C
  JSR CheckOfficerArmyGroup                             ; $A9FC: 20 4B DC
  CMP #$FF                              ; $A9FF: C9 FF
  BNE CommandState_SelectTarget_Done     ; $AA01: D0 25
.endproc

.proc CommandState_SelectTarget_Proceed
  STY $0509                             ; $AA03: 8C 09 05
  JSR CalcDistance                      ; $AA06: 20 60 B8
  CMP #$06                              ; $AA09: C9 06
  BCS @ShowFullUI                       ; $AA0B: B0 1C
  JSR ValidateActionTarget              ; $AA0D: 20 80 AD
  BCS @ValidTarget                      ; $AA10: B0 0B
  LDA #$0A                              ; $AA12: A9 0A
  STA $0501                             ; $AA14: 8D 01 05
  LDA #$F7                              ; $AA17: A9 F7
  JSR B1F_SetUI2                        ; $AA19: 20 83 F2
  RTS                                   ; $AA1C: 60
@ValidTarget:
  INC $0501                             ; $AA1D: EE 01 05
  JMP CommandPhase_ShowResultMsg         ; $AA20: 4C 63 AD
.endproc

.proc CommandState_SelectTarget_Reset
  LDA #$00                              ; $AA23: A9 00
  STA $0501                             ; $AA25: 8D 01 05
.endproc

.proc CommandState_SelectTarget_Done
  RTS                                   ; $AA28: 60
.endproc

.proc CommandState_SelectTarget_ShowFull
@ShowFullUI:
  LDA #$4C                              ; $AA29: A9 4C
  JMP B1F_SetUI2                        ; $AA2B: 4C 83 F2
.endproc

.proc CommandState_Confirm
  JSR DrawExchangeArrows_Right                             ; $AA2E: 20 63 DC
  JSR RenderExchangeSprites             ; $AA31: 20 57 D6
  JSR CheckExchangePossible                             ; $AA34: 20 27 DF
  BCC @Done                             ; $AA37: 90 32
  LDA $81                               ; $AA39: A5 81
  AND #$01                              ; $AA3B: 29 01
  BEQ @Done                             ; $AA3D: F0 2C
  INC $0501                             ; $AA3F: EE 01 05
  LDA #$89                              ; $AA42: A9 89
  STA $C3                               ; $AA44: 85 C3
  LDA #$8A                              ; $AA46: A9 8A
  STA $C4                               ; $AA48: 85 C4
  LDA #$88                              ; $AA4A: A9 88
  STA $C5                               ; $AA4C: 85 C5
  STA $C2                               ; $AA4E: 85 C2
  LDY $0509                             ; $AA50: AC 09 05
  LDA #$00                              ; $AA53: A9 00
  STA $0650,Y                           ; $AA55: 99 50 06
  LDA $0543                             ; $AA58: AD 43 05
  CLC                                   ; $AA5B: 18
  ADC #$01                              ; $AA5C: 69 01
  STA exchange_result_cnt                             ; $AA5E: 8D C8 04
  LDA #$05                              ; $AA61: A9 05
  STA $0310                             ; $AA63: 8D 10 03
  LDA #$00                              ; $AA66: A9 00
  STA $0300                             ; $AA68: 8D 00 03
@Done:
  RTS                                   ; $AA6B: 60
.endproc

.proc CommandState_ShowResult
  LDA exchange_result_cnt                             ; $AA6C: AD C8 04
  BNE @Done                             ; $AA6F: D0 35
  LDY $050A                             ; $AA71: AC 0A 05
  LDA $0664,Y                           ; $AA74: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $AA77: 20 D7 F2
  LDY #$0B                              ; $AA7A: A0 0B
  LDA ($00),Y                           ; $AA7C: B1 00
  AND #$F0                              ; $AA7E: 29 F0
  STA $052C                             ; $AA80: 8D 2C 05
  LDY #$01                              ; $AA83: A0 01
  LDA ($00),Y                           ; $AA85: B1 00
  STA $052E                             ; $AA87: 8D 2E 05
  LDY $0543                             ; $AA8A: AC 43 05
  LDA @ActionParamTable+5,Y             ; $AA8D: B9 C9 AB
  STA $00                               ; $AA90: 85 00
  LDA $0505                             ; $AA92: AD 05 05
  SEC                                   ; $AA95: 38
  SBC $00                               ; $AA96: E5 00
  STA $0505                             ; $AA98: 8D 05 05
  JSR ExecuteAction                     ; $AA9B: 20 2B B0
  JSR CalcOfficerMeritLevels              ; $AA9E: 20 03 DB
  LDA #$00                              ; $AAA1: A9 00
  STA $050B                             ; $AAA3: 8D 0B 05
@Done:
  RTS                                   ; $AAA6: 60
.endproc

.proc CommandState_Cancel
  LDA $007E                             ; $AAA7: AD 7E 00
  BNE $AAE2                             ; $AAAA: D0 36
  LDA $050B                             ; $AAAC: AD 0B 05
  STA $0509                             ; $AAAF: 8D 09 05
  LDA #$01                              ; $AAB2: A9 01
  STA $12                               ; $AAB4: 85 12
  JSR UpdateCursorTile                             ; $AAB6: 20 CC D6
  INC $050B                             ; $AAB9: EE 0B 05
  LDA $050B                             ; $AABC: AD 0B 05
  CMP #$14                              ; $AABF: C9 14
  BCC @Done                             ; $AAC1: 90 1F
  INC $0501                             ; $AAC3: EE 01 05
  LDA $0544                             ; $AAC6: AD 44 05
  BEQ @CheckActionType                  ; $AAC9: F0 18
  LDA #$04                              ; $AACB: A9 04
  STA $00A4                             ; $AACD: 8D A4 00
  LDA #$73                              ; $AAD0: A9 73
  JSR B1F_SetUI2                        ; $AAD2: 20 83 F2
@FinishAndExit:
  LDA $050A                             ; $AAD5: AD 0A 05
  STA $0509                             ; $AAD8: 8D 09 05
  LDY #$3D                              ; $AADB: A0 3D
  JSR B1F_BankedCallbackTrampoline      ; $AADD: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word B1D_1E_ProvinceDataHandler          ; $AAE0: $27 A0
@Done:
  RTS                                         ; $AAE2: 60
@CheckActionType:
  LDA #$03                                    ; $AAE3: A9 03
  STA $00A4                                   ; $AAE5: 8D A4 00
  LDA $0543                                   ; $AAE8: AD 43 05
  AND #$0F                                    ; $AAEB: 29 0F
  TAY                                         ; $AAED: A8
  CPY #$01                                    ; $AAEE: C0 01
  BEQ @CheckPendingOfficer              ; $AAF0: F0 10
  CPY #$09                                    ; $AAF2: C0 09
  BNE @ShowCancelMsg                    ; $AAF4: D0 1B
  LDA officer_sel_list                                   ; $AAF6: AD 2C 04
  BNE @CheckPendingOfficer              ; $AAF9: D0 07
  LDA officer_sel_list+1                                   ; $AAFB: AD 2D 04
  BNE @CheckPendingOfficer              ; $AAFE: D0 02
  LDY #$01                                    ; $AB00: A0 01
@CheckPendingOfficer:
  LDA officer_sel_list+6                             ; $AB02: AD 32 04
  CMP #$FF                              ; $AB05: C9 FF
  BEQ @ShowCancelMsg                    ; $AB07: F0 08
  STA officer_sel_list                             ; $AB09: 8D 2C 04
  LDA #$4E                              ; $AB0C: A9 4E
  JMP B1F_SetUI5                        ; $AB0E: 4C 93 F2
@ShowCancelMsg:
  LDA @CancelMsgTable,Y                 ; $AB11: B9 1A AB
  JSR B1F_SetUI2                        ; $AB14: 20 83 F2
  JMP @FinishAndExit                    ; $AB17: 4C D5 AA
; Cancel message IDs indexed by stratagem code
@CancelMsgTable:
  .byte $6C,$6D,$6E,$6C,$6C,$6F,$6C,$6C,$70,$BB,$71,$BA,$6C,$6C,$6C,$72; $AB1A: 6C 6D 6E 6C 6C 6F 6C 6C 70 BB 71 BA 6C 6C 6C 72
.endproc

.proc CommandState_Confirm2
  JSR CheckExchangePossible                             ; $AB2A: 20 27 DF
  BCC @Done                             ; $AB2D: 90 22
  JSR DrawExchangeArrows_Right                             ; $AB2F: 20 63 DC
  LDA $81                               ; $AB32: A5 81
  AND #$01                              ; $AB34: 29 01
  BEQ @Done                             ; $AB36: F0 19
  LDY $050A                             ; $AB38: AC 0A 05
  LDA $0664,Y                           ; $AB3B: B9 64 06
  STA officer_sel_list                             ; $AB3E: 8D 2C 04
  JSR ValidateExchangeOfficer                             ; $AB41: 20 E9 DE
  BCS @Skip2                            ; $AB44: 90 29 (inverted)
  JMP CommandPhase_RestorePosition       ; (was fall-through to @AB6F)
@Skip2:
  INC $0501                             ; $AB46: EE 01 05
  JSR B1F_BankPpuInit                   ; $AB49: 20 7F E5
  LDA #$7B                              ; $AB4C: A9 7B
  JSR B1F_SoundWrapperD                 ; $AB4E: 20 8B E6
@Done:
  RTS                                   ; $AB51: 60
.endproc

.proc CommandState_CancelConfirm
  JSR CheckExchangePossible                             ; $AB52: 20 27 DF
  BCC @Done                             ; $AB55: 90 2E
  JSR DrawExchangeArrows_Right                             ; $AB57: 20 63 DC
  LDA $81                               ; $AB5A: A5 81
  AND #$01                              ; $AB5C: 29 01
  BEQ @Done                             ; $AB5E: F0 25
  LDA officer_sel_list+1                             ; $AB60: AD 2D 04
  CMP #$FF                              ; $AB63: C9 FF
  BNE @ShowCancelUI                     ; $AB65: D0 1F
  JSR B1F_BankPpuInit                   ; $AB67: 20 7F E5
  LDA #$1D                              ; $AB6A: A9 1D
  JSR B1F_SoundWrapperA                 ; $AB6C: 20 73 E6
  JSR CommandPhase_RestorePosition       ; (was fall-through to @AB6F)
@Done:
  RTS                                   ; $AB85: 60
@ShowCancelUI:
  LDA #$FF                              ; $AB86: A9 FF
  STA officer_sel_list+1                             ; $AB88: 8D 2D 04
  LDA #$4B                              ; $AB8B: A9 4B
  JMP B1F_SetUI5                        ; $AB8D: 4C 93 F2
.endproc

.proc CommandPhase_RestorePosition
  LDY #$03                              ; $AB6F: A0 03
@CopyLoop:
  LDA kingdom_param_copy,Y                           ; $AB71: B9 6C 04
  STA $6F3F,Y                           ; $AB74: 99 3F 6F
  DEY                                   ; $AB77: 88
  BPL @CopyLoop                         ; $AB78: 10 F7
  LDA #$00                              ; $AB7A: A9 00
  STA $0501                             ; $AB7C: 8D 01 05
  STA $0500                             ; $AB7F: 8D 00 05
  JMP FinishSequence                    ; $AB82: 4C F7 A1
.endproc

.proc CommandState_Reset
  JSR CheckExchangePossible                             ; $AB90: 20 27 DF
  BCC @Done                             ; $AB93: 90 0E
  JSR DrawExchangeArrows_Right                             ; $AB95: 20 63 DC
  LDA $81                               ; $AB98: A5 81
  AND #$01                              ; $AB9A: 29 01
  BEQ @Done                             ; $AB9C: F0 05
  LDA #$00                              ; $AB9E: A9 00
  STA $0501                             ; $ABA0: 8D 01 05
@Done:
  RTS                                   ; $ABA3: 60
; PPU nametable/attribute data for action state reset
@ResetPpuData:
  .byte $1E,$18,$1E,$98,$2E,$18,$2E,$98,$3E,$18,$3E,$98,$4E,$18,$4E,$98; $ABA4: 1E 18 1E 98 2E 18 2E 98 3E 18 3E 98 4E 18 4E 98
  .byte $5E,$18,$5E,$98,$6E,$18,$6E,$98,$7E,$18,$7E,$98,$8E,$18,$8E,$98; $ABB4: 5E 18 5E 98 6E 18 6E 98 7E 18 7E 98 8E 18 8E 98
; Action cost/parameter table
@ActionParamTable:
  .byte $00,$07,$00,$00,$80,$06,$05,$04,$06,$07,$08,$08,$08,$0A,$09,$09; $ABC4: 00 07 00 00 80 06 05 04 06 07 08 08 08 0A 09 09
  .byte $0A,$0A,$08,$0C,$0A               ; $ABD4: 0A 0A 08 0C 0A
.endproc

.proc CommandPhase_BuildMsg
  LDY $050B                             ; $ABD9: AC 0B 05
  LDA $0580,Y                           ; $ABDC: B9 80 05
  ASL                                   ; $ABDF: 0A
  TAY                                   ; $ABE0: A8
  LDA @MsgPointerTable,Y                ; $ABE1: B9 91 AC
  STA $00                               ; $ABE4: 85 00
  LDA @MsgPointerTable+1,Y              ; $ABE6: B9 92 AC
  STA $01                               ; $ABE9: 85 01
  LDA $050B                             ; $ABEB: AD 0B 05
  ASL                                   ; $ABEE: 0A
  ASL                                   ; $ABEF: 0A
  STA $02                               ; $ABF0: 85 02
  LDX #$00                              ; $ABF2: A2 00
  LDY #$00                              ; $ABF4: A0 00
  LDA ($00),Y                           ; $ABF6: B1 00
  STA $0380,X                           ; $ABF8: 9D 80 03
  STA $03                               ; $ABFB: 85 03
  INX                                   ; $ABFD: E8
  LDY $02                               ; $ABFE: A4 02
  LDA @MsgTileAddrTable+1,Y             ; $AC00: B9 52 AC
  STA $0380,X                           ; $AC03: 9D 80 03
  INX                                   ; $AC06: E8
  LDA @MsgTileAddrTable,Y               ; $AC07: B9 51 AC
  STA $0380,X                           ; $AC0A: 9D 80 03
  INX                                   ; $AC0D: E8
  LDY #$01                              ; $AC0E: A0 01
@CopyMsgLoop:
  LDA ($00),Y                           ; $AC10: B1 00
  STA $0380,X                           ; $AC12: 9D 80 03
  INX                                   ; $AC15: E8
  INY                                   ; $AC16: C8
  DEC $03                               ; $AC17: C6 03
  BNE @CopyMsgLoop                      ; $AC19: D0 F5
  LDA ($00),Y                           ; $AC1B: B1 00
  STA $0380,X                           ; $AC1D: 9D 80 03
  STA $03                               ; $AC20: 85 03
  INY                                   ; $AC22: C8
  TYA                                   ; $AC23: 98
  PHA                                   ; $AC24: 48
  INX                                   ; $AC25: E8
  LDY $02                               ; $AC26: A4 02
  LDA $AC54,Y                           ; $AC28: B9 54 AC
  STA $0380,X                           ; $AC2B: 9D 80 03
  INX                                   ; $AC2E: E8
  LDA $AC53,Y                           ; $AC2F: B9 53 AC
  STA $0380,X                           ; $AC32: 9D 80 03
  INX                                   ; $AC35: E8
  PLA                                   ; $AC36: 68
  TAY                                   ; $AC37: A8
@CopyMsgLoop2:
  LDA ($00),Y                           ; $AC38: B1 00
  STA $0380,X                           ; $AC3A: 9D 80 03
  INX                                   ; $AC3D: E8
  INY                                   ; $AC3E: C8
  DEC $03                               ; $AC3F: C6 03
  BNE @CopyMsgLoop2                     ; $AC41: D0 F5
  LDA #$FF                              ; $AC43: A9 FF
  STA $0380,X                           ; $AC45: 9D 80 03
  LDA $007E                             ; $AC48: AD 7E 00
  ORA #$04                              ; $AC4B: 09 04
  STA $007E                             ; $AC4D: 8D 7E 00
  RTS                                   ; $AC50: 60
; Tile address table for message building (16-bit pointers)
@MsgTileAddrTable:
  .byte $A4,$25,$C4,$25,$B4,$25,$D4,$25,$E4,$25,$04,$26,$F4,$25,$14,$26; $AC51: A4 25 C4 25 B4 25 D4 25 E4 25 04 26 F4 25 14 26
  .byte $24,$26,$44,$26,$34,$26,$54,$26,$64,$26,$84,$26,$74,$26,$94,$26; $AC61: 24 26 44 26 34 26 54 26 64 26 84 26 74 26 94 26
  .byte $A4,$26,$C4,$26,$B4,$26,$D4,$26,$E4,$26,$04,$27,$F4,$26,$14,$27; $AC71: A4 26 C4 26 B4 26 D4 26 E4 26 04 27 F4 26 14 27
  .byte $24,$27,$44,$27,$34,$27,$54,$27,$64,$27,$84,$27,$74,$27,$94,$27; $AC81: 24 27 44 27 34 27 54 27 64 27 84 27 74 27 94 27
; Message pointer table (16-bit pointers to message content)
@MsgPointerTable:
  .byte $B1,$AC,$BB,$AC,$C5,$AC,$CF,$AC,$D9,$AC,$E3,$AC,$ED,$AC,$FD,$AC; $AC91: B1 AC BB AC C5 AC CF AC D9 AC E3 AC ED AC FD AC
  .byte $07,$AD,$11,$AD,$1B,$AD,$25,$AD,$35,$AD,$3F,$AD,$49,$AD,$53,$AD; $ACA1: 07 AD 11 AD 1B AD 25 AD 35 AD 3F AD 49 AD 53 AD
; Message content data (tile indices for action messages)
@MsgContentData:
  .byte $04,$40,$41,$42,$43,$04,$50,$51,$52,$53,$04,$44,$45,$46,$47,$04; $ACB1: 04 40 41 42 43 04 50 51 52 53 04 44 45 46 47 04
  .byte $54,$55,$56,$57,$04,$48,$49,$4A,$4B,$04,$58,$59,$5A,$5B,$04,$4C; $ACC1: 54 55 56 57 04 48 49 4A 4B 04 58 59 5A 5B 04 4C
  .byte $4D,$4E,$4F,$04,$5C,$5D,$5E,$5F,$04,$60,$61,$62,$63,$04,$70,$71; $ACD1: 4D 4E 4F 04 5C 5D 5E 5F 04 60 61 62 63 04 70 71
  .byte $72,$73,$04,$40,$41,$64,$65,$04,$50,$51,$74,$75,$07,$66,$67,$68; $ACE1: 72 73 04 40 41 64 65 04 50 51 74 75 07 66 67 68
  .byte $69,$6A,$6B,$6C,$07,$76,$77,$78,$79,$7A,$7B,$7C,$04,$6D,$6E,$6F; $ACF1: 69 6A 6B 6C 07 76 77 78 79 7A 7B 7C 04 6D 6E 6F
  .byte $C0,$04,$7D,$7E,$7F,$D0,$04,$C1,$C2; $AD01: C0 04 7D 7E 7F D0 04 C1 C2
@ActionMenuMsgData:
  .byte $C3,$C4,$04,$D1,$D2,$D3,$D4,$04,$C5,$C6,$C7,$C8,$04,$D5,$D6,$D7; $AD0A: C3 C4 04 D1 D2 D3 D4 04 C5 C6 C7 C8 04 D5 D6 D7
  .byte $D8,$04,$C9,$CA,$CB,$CC,$04,$D9,$DA,$DB,$DC,$07,$CD,$CE,$CF,$E0; $AD1A: D8 04 C9 CA CB CC 04 D9 DA DB DC 07 CD CE CF E0
  .byte $E1,$E2,$E3,$07,$DD,$DE,$DF,$F0,$F1,$F2,$F3,$04,$62,$63,$E4,$E5; $AD2A: E1 E2 E3 07 DD DE DF F0 F1 F2 F3 04 62 63 E4 E5
  .byte $04,$72,$73,$F4,$F5,$04,$C9,$CA,$E6,$E7,$04,$D9,$DA,$F6,$F7,$04; $AD3A: 04 72 73 F4 F5 04 C9 CA E6 E7 04 D9 DA F6 F7 04
  .byte $E8,$E9,$40,$41,$04,$F8,$F9,$50,$51,$07,$EA,$EB,$EC,$ED,$EE,$EF; $AD4A: E8 E9 40 41 04 F8 F9 50 51 07 EA EB EC ED EE EF
  .byte $30,$07,$FA,$FB,$FC,$FD,$FE,$FF,$31; $AD5A: 30 07 FA FB FC FD FE FF 31
.endproc

.proc CommandPhase_ShowResultMsg
  LDA $0543                             ; $AD63: AD 43 05
  AND #$0F                              ; $AD66: 29 0F
  TAY                                   ; $AD68: A8
  LDA @ResultMsgTable,Y                 ; $AD69: B9 70 AD
  JSR B1F_SetUI2                        ; $AD6C: 20 83 F2
  RTS                                   ; $AD6F: 60
; Result message IDs indexed by stratagem code
@ResultMsgTable:
  .byte $FB,$FC,$FD,$FE,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B; $AD70: FB FC FD FE 60 61 62 63 64 65 66 67 68 69 6A 6B
.endproc

.proc ValidateActionTarget
  LDY $0509                             ; $AD80: AC 09 05
  LDA $0600,Y                           ; $AD83: B9 00 06
  STA $10                               ; $AD86: 85 10
  LDA $0614,Y                           ; $AD88: B9 14 06
  STA $11                               ; $AD8B: 85 11
  JSR GetTerrainType                             ; $AD8D: 20 46 DB
  STA $0A                               ; $AD90: 85 0A
  LDY $050A                             ; $AD92: AC 0A 05
  LDA $0600,Y                           ; $AD95: B9 00 06
  STA $10                               ; $AD98: 85 10
  LDA $0614,Y                           ; $AD9A: B9 14 06
  STA $11                               ; $AD9D: 85 11
  JSR GetTerrainType                             ; $AD9F: 20 46 DB
  STA $0B                               ; $ADA2: 85 0B
  LDA $0543                             ; $ADA4: AD 43 05
  AND #$0F                              ; $ADA7: 29 0F
  JSR B1F_CallbackDispatcher            ; $ADA9: 20 DE EA
; --- CallbackDispatcher table (16 entries): stratagem validation handlers ---
; Stratagem codes: 0=FireAttack (火攻), 1=Trap (陷阱), 2=FeintTroops (虚兵),
; 3=AmbushStrike (要击), 4=MuddyWater (乱水), 5=FireArrows (火箭),
; 6=FeintCounter (伪击转杀), 7=CoordinatedStrike (共杀), 8=WinOver (笼络),
; 9=FallingRocks (落石), 10=ChainStratagem (连环), 11=AmbushAllSides (十面埋伏),
; 12=WaterAttack (水攻), 13=RepeatingCrossbow (连弩), 14=PillageFire (劫火),
; 15=QimenDunjia (奇门遁甲). Terrain: 0=woods, 2=plains, 3=water, 4=mountain,
; 5=castle.
  .word ValidStratagem_FireAttack             ; $ADAC: $CC AD   ; stratagem 0
  .word ValidStratagem_Trap                   ; $ADAE: $D8 AD   ; stratagem 1
  .word ValidStratagem_FeintTroops            ; $ADB0: $D8 AD   ; stratagem 2
  .word ValidStratagem_AmbushStrike           ; $ADB2: $D8 AD   ; stratagem 3
  .word ValidStratagem_MuddyWater             ; $ADB4: $E4 AD   ; stratagem 4
  .word ValidStratagem_FireArrows             ; $ADB6: $EE AD   ; stratagem 5
  .word ValidStratagem_FeintCounter           ; $ADB8: $FB AD   ; stratagem 6
  .word ValidStratagem_CoordinatedStrike      ; $ADBA: $68 AE   ; stratagem 7
  .word ValidStratagem_WinOver                ; $ADBC: $C4 AE   ; stratagem 8
  .word ValidStratagem_FallingRocks           ; $ADBE: $CE AE   ; stratagem 9
  .word ValidStratagem_ChainStratagem         ; $ADC0: $0A AF   ; stratagem 10
  .word ValidStratagem_AmbushAllSides         ; $ADC2: $73 AF   ; stratagem 11
  .word ValidStratagem_WaterAttack            ; $ADC4: $0A AF   ; stratagem 12
  .word ValidStratagem_RepeatingCrossbow      ; $ADC6: $A1 AF   ; stratagem 13
  .word ValidStratagem_PillageFire            ; $ADC8: $D3 AF   ; stratagem 14
  .word ValidStratagem_QimenDunjia            ; $ADCA: $1D B0   ; stratagem 15
.endproc

.proc ValidStratagem_FireAttack
  LDA $0A                               ; $ADCC: A5 0A
  BEQ @Success                          ; $ADCE: F0 06
  CMP #$02                              ; $ADD0: C9 02
  BEQ @Success                          ; $ADD2: F0 02
  CLC                                   ; $ADD4: 18
  RTS                                   ; $ADD5: 60
@Success:
  SEC                                   ; $ADD6: 38
  RTS                                   ; $ADD7: 60
.endproc

.proc ValidStratagem_Trap
  LDA $0A                               ; $ADD8: A5 0A
  BEQ @Success                          ; $ADDA: F0 06
  CMP #$04                              ; $ADDC: C9 04
  BEQ @Success                          ; $ADDE: F0 02
  CLC                                   ; $ADE0: 18
  RTS                                   ; $ADE1: 60
@Success:
  SEC                                   ; $ADE2: 38
  RTS                                   ; $ADE3: 60
.endproc
; FeintTroops (虚兵, stratagem 2) and AmbushStrike (要击, stratagem 3) share
; the Trap validation body at $ADD8.
ValidStratagem_FeintTroops = ValidStratagem_Trap
ValidStratagem_AmbushStrike = ValidStratagem_Trap

.proc ValidStratagem_MuddyWater
  LDA $0A                               ; $ADE4: A5 0A
  CMP #$03                              ; $ADE6: C9 03
  BEQ @Success                          ; $ADE8: F0 02
  CLC                                   ; $ADEA: 18
  RTS                                   ; $ADEB: 60
@Success:
  SEC                                   ; $ADEC: 38
  RTS                                   ; $ADED: 60
.endproc

.proc ValidStratagem_FireArrows
  LDY $0509                             ; $ADEE: AC 09 05
  BEQ @Success                          ; $ADF1: F0 06
  CPY #$0A                              ; $ADF3: C0 0A
  BEQ @Success                          ; $ADF5: F0 02
  CLC                                   ; $ADF7: 18
  RTS                                   ; $ADF8: 60
@Success:
  SEC                                   ; $ADF9: 38
  RTS                                   ; $ADFA: 60
.endproc

.proc ValidStratagem_FeintCounter
  LDY $0A                               ; $ADFB: A4 0A
  CPY #$05                              ; $ADFD: C0 05
  BNE @Fail                             ; $ADFF: D0 28
  JSR GetOfficerPosition                ; $AE01: 20 2D AE
  INC $00                               ; $AE04: E6 00
  JSR CheckAdjacentAlly                 ; $AE06: 20 42 AE
  BCS @Success                          ; $AE09: B0 20
  JSR GetOfficerPosition                ; $AE0B: 20 2D AE
  DEC $00                               ; $AE0E: C6 00
  JSR CheckAdjacentAlly                 ; $AE10: 20 42 AE
  BCS @Success                          ; $AE13: B0 16
  JSR GetOfficerPosition                ; $AE15: 20 2D AE
  INC $01                               ; $AE18: E6 01
  JSR CheckAdjacentAlly                 ; $AE1A: 20 42 AE
  BCS @Success                          ; $AE1D: B0 0C
  JSR GetOfficerPosition                ; $AE1F: 20 2D AE
  DEC $01                               ; $AE22: C6 01
  JSR CheckAdjacentAlly                 ; $AE24: 20 42 AE
  BCS @Success                          ; $AE27: B0 02
@Fail:
  CLC                                   ; $AE29: 18
  RTS                                   ; $AE2A: 60
@Success:
  SEC                                   ; $AE2B: 38
  RTS                                   ; $AE2C: 60
.endproc

.proc GetOfficerPosition
  LDY $0509                             ; $AE2D: AC 09 05
  LDA $0600,Y                           ; $AE30: B9 00 06
  STA $00                               ; $AE33: 85 00
  LDA $0614,Y                           ; $AE35: B9 14 06
  CMP #$10                              ; $AE38: C9 10
  BCC @SkipRowAdj                       ; $AE3A: 90 03
  SEC                                   ; $AE3C: 38
  SBC #$01                              ; $AE3D: E9 01
@SkipRowAdj:
  STA $01                               ; $AE3F: 85 01
  RTS                                   ; $AE41: 60
.endproc

.proc CheckAdjacentAlly
  LDA $00                               ; $AE42: A5 00
  CMP #$20                              ; $AE44: C9 20
  BCS @Fail                             ; $AE46: B0 E1
  LDA $01                               ; $AE48: A5 01
  CMP #$14                              ; $AE4A: C9 14
  BCS @Fail                             ; $AE4C: B0 DB
  LDY $050A                             ; $AE4E: AC 0A 05
  LDA $0600,Y                           ; $AE51: B9 00 06
  CMP $00                               ; $AE54: C5 00
  BNE @Fail                             ; $AE56: D0 D1
  LDA $0614,Y                           ; $AE58: B9 14 06
  CMP #$10                              ; $AE5B: C9 10
  BCC @SkipRowAdj                       ; $AE5D: 90 03
  SEC                                   ; $AE5F: 38
  SBC #$01                              ; $AE60: E9 01
@SkipRowAdj:
  CMP $01                               ; $AE62: C5 01
  BNE @Fail                             ; $AE64: D0 C3
  SEC                                   ; $AE66: 38
  RTS                                   ; $AE67: 60
@Fail:
  CLC                                   ; (shared exit with ValidStratagem_FeintCounter)
  RTS
.endproc

.proc ValidStratagem_CoordinatedStrike
  LDY $0A                               ; $AE68: A4 0A
  BEQ @CheckAdjacent                    ; $AE6A: F0 04
  CPY #$04                              ; $AE6C: C0 04
  BNE @Fail                             ; $AE6E: D0 32
@CheckAdjacent:
  JSR GetOfficerPosition                ; $AE70: 20 2D AE
  INC $00                               ; $AE73: E6 00
  JSR CheckTileOccupied                 ; $AE75: 20 A4 AE
  CMP #$FF                              ; $AE78: C9 FF
  BEQ @Success                          ; $AE7A: F0 24
  JSR GetOfficerPosition                ; $AE7C: 20 2D AE
  DEC $00                               ; $AE7F: C6 00
  JSR CheckTileOccupied                 ; $AE81: 20 A4 AE
  CMP #$FF                              ; $AE84: C9 FF
  BEQ @Success                          ; $AE86: F0 18
  JSR GetOfficerPosition                ; $AE88: 20 2D AE
  INC $01                               ; $AE8B: E6 01
  JSR CheckTileOccupied                 ; $AE8D: 20 A4 AE
  CMP #$FF                              ; $AE90: C9 FF
  BEQ @Success                          ; $AE92: F0 0C
  JSR GetOfficerPosition                ; $AE94: 20 2D AE
  DEC $01                               ; $AE97: C6 01
  JSR CheckTileOccupied                 ; $AE99: 20 A4 AE
  CMP #$FF                              ; $AE9C: C9 FF
  BNE @Fail                             ; $AE9E: D0 02
@Success:
  SEC                                   ; $AEA0: 38
  RTS                                   ; $AEA1: 60
@Fail:
  CLC                                   ; $AEA2: 18
  RTS                                   ; $AEA3: 60
.endproc

.proc CheckTileOccupied
  LDA $00                               ; $AEA4: A5 00
  CMP #$20                              ; $AEA6: C9 20
  BCS @ReturnEmpty                      ; $AEA8: B0 17
  LDA $01                               ; $AEAA: A5 01
  CMP #$14                              ; $AEAC: C9 14
  BCS @ReturnEmpty                      ; $AEAE: B0 11
  CMP #$0F                              ; $AEB0: C9 0F
  BNE @SkipRowAdj                       ; $AEB2: D0 03
  INC $0001                             ; $AEB4: EE 01 00
@SkipRowAdj:
  JSR SearchRosterByTileCoord                             ; $AEB7: 20 B6 D6
  TYA                                   ; $AEBA: 98
  BMI @ReturnEmpty                      ; $AEBB: 30 04
  JSR CheckOfficerArmyGroup                             ; $AEBD: 20 4B DC
  RTS                                   ; $AEC0: 60
@ReturnEmpty:
  LDA #$00                              ; $AEC1: A9 00
  RTS                                   ; $AEC3: 60
.endproc

.proc ValidStratagem_WinOver
  LDA $0A                               ; $AEC4: A5 0A
  CMP #$05                              ; $AEC6: C9 05
  BNE @Success                          ; $AEC8: D0 02
  CLC                                   ; $AECA: 18
  RTS                                   ; $AECB: 60
@Success:
  SEC                                   ; $AECC: 38
  RTS                                   ; $AECD: 60
.endproc

.proc ValidStratagem_FallingRocks
  LDA $0B                               ; $AECE: A5 0B
  CMP #$04                              ; $AED0: C9 04
  BEQ @CheckAdjacent                    ; $AED2: F0 04
  CMP #$05                              ; $AED4: C9 05
  BNE @Fail                             ; $AED6: D0 30
@CheckAdjacent:
  JSR GetOfficerPosition                ; $AED8: 20 2D AE
  INC $00                               ; $AEDB: E6 00
  JSR CheckAdjacentAlly                 ; $AEDD: 20 42 AE
  BCS @CheckActionType                  ; $AEE0: B0 1E
  JSR GetOfficerPosition                ; $AEE2: 20 2D AE
  DEC $00                               ; $AEE5: C6 00
  JSR CheckAdjacentAlly                 ; $AEE7: 20 42 AE
  BCS @CheckActionType                  ; $AEEA: B0 14
  JSR GetOfficerPosition                ; $AEEC: 20 2D AE
  INC $01                               ; $AEEF: E6 01
  JSR CheckAdjacentAlly                 ; $AEF1: 20 42 AE
  BCS @CheckActionType                  ; $AEF4: B0 0A
  JSR GetOfficerPosition                ; $AEF6: 20 2D AE
  DEC $01                               ; $AEF9: C6 01
  JSR CheckAdjacentAlly                 ; $AEFB: 20 42 AE
  BCC @Fail                             ; $AEFE: 90 08
@CheckActionType:
  LDA $0A                               ; $AF00: A5 0A
  CMP #$05                              ; $AF02: C9 05
  BEQ @Fail                             ; $AF04: F0 02
  SEC                                   ; $AF06: 38
  RTS                                   ; $AF07: 60
@Fail:
  CLC                                   ; $AF08: 18
  RTS                                   ; $AF09: 60
.endproc

.proc ValidStratagem_ChainStratagem
  LDY $0A                               ; $AF0A: A4 0A
  CPY #$03                              ; $AF0C: C0 03
  BNE @Fail                             ; $AF0E: D0 32
  JSR GetOfficerPosition                ; $AF10: 20 2D AE
  INC $00                               ; $AF13: E6 00
  JSR CheckAdjacentEnemy                ; $AF15: 20 44 AF
  CMP #$03                              ; $AF18: C9 03
  BEQ @Success                          ; $AF1A: F0 24
  JSR GetOfficerPosition                ; $AF1C: 20 2D AE
  DEC $00                               ; $AF1F: C6 00
  JSR CheckAdjacentEnemy                ; $AF21: 20 44 AF
  CMP #$03                              ; $AF24: C9 03
  BEQ @Success                          ; $AF26: F0 18
  JSR GetOfficerPosition                ; $AF28: 20 2D AE
  INC $01                               ; $AF2B: E6 01
  JSR CheckAdjacentEnemy                ; $AF2D: 20 44 AF
  CMP #$03                              ; $AF30: C9 03
  BEQ @Success                          ; $AF32: F0 0C
  JSR GetOfficerPosition                ; $AF34: 20 2D AE
  DEC $01                               ; $AF37: C6 01
  JSR CheckAdjacentEnemy                ; $AF39: 20 44 AF
  CMP #$03                              ; $AF3C: C9 03
  BNE @Fail                             ; $AF3E: D0 02
@Success:
  SEC                                   ; $AF40: 38
  RTS                                   ; $AF41: 60
@Fail:
  CLC                                   ; $AF42: 18
  RTS                                   ; $AF43: 60
.endproc

.proc CheckAdjacentEnemy
  LDA $00                               ; $AF44: A5 00
  CMP #$20                              ; $AF46: C9 20
  BCS @ReturnInvalid                    ; $AF48: B0 26
  LDA $01                               ; $AF4A: A5 01
  CMP #$14                              ; $AF4C: C9 14
  BCS @ReturnInvalid                    ; $AF4E: B0 20
  CMP #$0F                              ; $AF50: C9 0F
  BNE @SkipRowAdj                       ; $AF52: D0 03
  INC $0001                             ; $AF54: EE 01 00
@SkipRowAdj:
  JSR SearchRosterByTileCoord                             ; $AF57: 20 B6 D6
  TYA                                   ; $AF5A: 98
  BMI @ReturnInvalid                    ; $AF5B: 30 13
  JSR CheckOfficerArmyGroup                             ; $AF5D: 20 4B DC
  CMP #$FF                              ; $AF60: C9 FF
  BNE @ReturnInvalid                    ; $AF62: D0 0C
  LDA $00                               ; $AF64: A5 00
  STA $10                               ; $AF66: 85 10
  LDA $01                               ; $AF68: A5 01
  STA $11                               ; $AF6A: 85 11
  JSR GetTerrainType                             ; $AF6C: 20 46 DB
  RTS                                   ; $AF6F: 60
@ReturnInvalid:
  LDA #$FF                              ; $AF70: A9 FF
  RTS                                   ; $AF72: 60
.endproc
; WaterAttack (水攻, stratagem 12) shares the ChainStratagem validation body
; at $AF0A.
ValidStratagem_WaterAttack = ValidStratagem_ChainStratagem

.proc ValidStratagem_AmbushAllSides
  LDA $0B                               ; $AF73: A5 0B
  BNE @Fail                             ; $AF75: D0 26
  LDY $050A                             ; $AF77: AC 0A 05
  LDA $0664,Y                           ; $AF7A: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $AF7D: 20 D7 F2
  LDY #$09                              ; $AF80: A0 09
  LDA ($00),Y                           ; $AF82: B1 00
  BNE @CheckSlot                        ; $AF84: D0 07
  DEY                                   ; $AF86: 88
  LDA ($00),Y                           ; $AF87: B1 00
  CMP #$64                              ; $AF89: C9 64
  BCC @Fail                             ; $AF8B: 90 10
@CheckSlot:
  LDY #$00                              ; $AF8D: A0 00
  LDA $0504                             ; $AF8F: AD 04 05
  BPL @LoadSlot                         ; $AF92: 10 02
  LDY #$04                              ; $AF94: A0 04
@LoadSlot:
  LDA army_slot_base,Y                           ; $AF96: B9 D8 04
  CMP #$FF                              ; $AF99: C9 FF
  BEQ @Success                          ; $AF9B: F0 02
@Fail:
  CLC                                   ; $AF9D: 18
  RTS                                   ; $AF9E: 60
@Success:
  SEC                                   ; $AF9F: 38
  RTS                                   ; $AFA0: 60
.endproc

.proc ValidStratagem_RepeatingCrossbow
  LDY $0B                               ; $AFA1: A4 0B
  CPY #$05                              ; $AFA3: C0 05
  BNE @Fail                             ; $AFA5: D0 2A
  JSR GetOfficerPosition                ; $AFA7: 20 2D AE
  INC $00                               ; $AFAA: E6 00
  JSR CheckAdjacentAlly                 ; $AFAC: 20 42 AE
  BCS @Success                          ; $AFAF: B0 1E
  JSR GetOfficerPosition                ; $AFB1: 20 2D AE
  DEC $00                               ; $AFB4: C6 00
  JSR CheckAdjacentAlly                 ; $AFB6: 20 42 AE
  BCS @Success                          ; $AFB9: B0 14
  JSR GetOfficerPosition                ; $AFBB: 20 2D AE
  INC $01                               ; $AFBE: E6 01
  JSR CheckAdjacentAlly                 ; $AFC0: 20 42 AE
  BCS @Success                          ; $AFC3: B0 0A
  JSR GetOfficerPosition                ; $AFC5: 20 2D AE
  DEC $01                               ; $AFC8: C6 01
  JSR CheckAdjacentAlly                 ; $AFCA: 20 42 AE
  BCC @Fail                             ; $AFCD: 90 02
@Success:
  SEC                                   ; $AFCF: 38
  RTS                                   ; $AFD0: 60
@Fail:
  CLC                                   ; $AFD1: 18
  RTS                                   ; $AFD2: 60
.endproc

.proc ValidStratagem_PillageFire
  LDY $0A                               ; $AFD3: A4 0A
  CPY #$05                              ; $AFD5: C0 05
  BEQ @Fail                             ; $AFD7: F0 42
  JSR GetOfficerPosition                ; $AFD9: 20 2D AE
  INC $00                               ; $AFDC: E6 00
  JSR CheckAdjacentEnemy                ; $AFDE: 20 44 AF
  CMP #$FF                              ; $AFE1: C9 FF
  BEQ @CheckNext1                       ; $AFE3: F0 04
  CMP #$05                              ; $AFE5: C9 05
  BNE @Success                          ; $AFE7: D0 30
@CheckNext1:
  JSR GetOfficerPosition                ; $AFE9: 20 2D AE
  DEC $00                               ; $AFEC: C6 00
  JSR CheckAdjacentEnemy                ; $AFEE: 20 44 AF
  CMP #$FF                              ; $AFF1: C9 FF
  BEQ @CheckNext2                       ; $AFF3: F0 04
  CMP #$05                              ; $AFF5: C9 05
  BNE @Success                          ; $AFF7: D0 20
@CheckNext2:
  JSR GetOfficerPosition                ; $AFF9: 20 2D AE
  INC $01                               ; $AFFC: E6 01
  JSR CheckAdjacentEnemy                ; $AFFE: 20 44 AF
  CMP #$FF                              ; $B001: C9 FF
  BEQ @CheckNext3                       ; $B003: F0 04
  CMP #$05                              ; $B005: C9 05
  BNE @Success                          ; $B007: D0 10
@CheckNext3:
  JSR GetOfficerPosition                ; $B009: 20 2D AE
  DEC $01                               ; $B00C: C6 01
  JSR CheckAdjacentEnemy                ; $B00E: 20 44 AF
  CMP #$FF                              ; $B011: C9 FF
  BEQ @Fail                             ; $B013: F0 06
  CMP #$05                              ; $B015: C9 05
  BEQ @Fail                             ; $B017: F0 02
@Success:
  SEC                                   ; $B019: 38
  RTS                                   ; $B01A: 60
@Fail:
  CLC                                   ; $B01B: 18
  RTS                                   ; $B01C: 60
.endproc

.proc ValidStratagem_QimenDunjia
  LDY $0A                               ; $B01D: A4 0A
  CPY #$03                              ; $B01F: C0 03
  BEQ @Fail                             ; $B021: F0 06
  CPY #$05                              ; $B023: C0 05
  BEQ @Fail                             ; $B025: F0 02
  SEC                                   ; $B027: 38
  RTS                                   ; $B028: 60
@Fail:
  CLC                                   ; $B029: 18
  RTS                                   ; $B02A: 60
.endproc

.proc ExecuteAction
@Entry:
  LDY #$00                              ; $B02B: A0 00
  LDA #$00                              ; $B02D: A9 00
@ClearLoop:
  STA officer_sel_list,Y                           ; $B02F: 99 2C 04
  INY                                   ; $B032: C8
  CPY #$09                              ; $B033: C0 09
  BCC @ClearLoop                        ; $B035: 90 F8
  STA $0544                             ; $B037: 8D 44 05
  LDA $0543                             ; $B03A: AD 43 05
  AND #$0F                              ; $B03D: 29 0F
  JSR B1F_CallbackDispatcher            ; $B03F: 20 DE EA
; --- CallbackDispatcher table (16 entries): stratagem execution handlers ---
  .word ExecStratagem_FireAttack              ; $B042: $62 B0   ; stratagem 0
  .word ExecStratagem_Trap                    ; $B044: $DD B0   ; stratagem 1
  .word ExecStratagem_FeintTroops             ; $B046: $55 B1   ; stratagem 2
  .word ExecStratagem_AmbushStrike            ; $B048: $7A B1   ; stratagem 3
  .word ExecStratagem_MuddyWater              ; $B04A: $D5 B1   ; stratagem 4
  .word ExecStratagem_FireArrows              ; $B04C: $43 B2   ; stratagem 5
  .word ExecStratagem_FeintCounter            ; $B04E: $62 B0   ; stratagem 6
  .word ExecStratagem_CoordinatedStrike       ; $B050: $CD B2   ; stratagem 7
  .word ExecStratagem_WinOver                 ; $B052: $1C B3   ; stratagem 8
  .word ExecStratagem_FallingRocks            ; $B054: $B6 B3   ; stratagem 9
  .word ExecStratagem_ChainStratagem          ; $B056: $D0 B3   ; stratagem 10
  .word ExecStratagem_AmbushAllSides          ; $B058: $2A B4   ; stratagem 11
  .word ExecStratagem_WaterAttack             ; $B05A: $66 B4   ; stratagem 12
  .word ExecStratagem_RepeatingCrossbow       ; $B05C: $B8 B4   ; stratagem 13
  .word ExecStratagem_PillageFire             ; $B05E: $0C B5   ; stratagem 14
  .word ExecStratagem_QimenDunjia             ; $B060: $A6 B5   ; stratagem 15
.endproc

;===============================================================================
; ExecStratagem_FireAttack ($B062)
;
; FireAttack (火攻, stratagem 0); the exec table entry for FeintCounter
; (伪击转杀, stratagem 6) resolves here via the ExecStratagem_FeintCounter
; alias. Drains resources from the target officer to the acting side.
;   Entry 1 (ExecStratagem_FireAttack): dispatch entry - check success by stats;
;           on failure set error flag $0544=$FF and return.
;   Entry 2 (CommandPhase_DrainCalc, $B070): drain calculation only (no success
;           check); also called directly from ExecStratagem_CoordinatedStrike
;           and ExecStratagem_CoordinatedStrikeNeighbor.
;===============================================================================
.proc ExecStratagem_FireAttack
  JSR CheckSuccessByStats               ; $B062: 20 BE B7
  BCS CommandPhase_DrainCalc             ; $B065: B0 09
  INC $0501                             ; $B067: EE 01 05
  LDA #$FF                              ; $B06A: A9 FF
  STA $0544                             ; $B06C: 8D 44 05
  RTS                                   ; $B06F: 60
CommandPhase_DrainCalc:
  LDY $050A                             ; $B070: AC 0A 05
  LDA $0664,Y                           ; $B073: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B076: 20 D7 F2
  LDY #$0B                              ; $B079: A0 0B
  LDA ($00),Y                           ; $B07B: B1 00
  LSR                                   ; $B07D: 4A
  LSR                                   ; $B07E: 4A
  LSR                                   ; $B07F: 4A
  LSR                                   ; $B080: 4A
  ASL                                   ; $B081: 0A
  STA $02                               ; $B082: 85 02
  ASL                                   ; $B084: 0A
  ASL                                   ; $B085: 0A
  CLC                                   ; $B086: 18
  ADC $02                               ; $B087: 65 02
  PHA                                   ; $B089: 48
  LDY #$02                              ; $B08A: A0 02
  LDA ($00),Y                           ; $B08C: B1 00
  STA $00                               ; $B08E: 85 00
  LDA #$00                              ; $B090: A9 00
  STA $01                               ; $B092: 85 01
  STA $02                               ; $B094: 85 02
  LDA #$05                              ; $B096: A9 05
  JSR B1F_RandomBelowThreshold          ; $B098: 20 62 E8
  CLC                                   ; $B09B: 18
@AddBase:
  ADC #$09                              ; $B09C: 69 09
  STA $03                               ; $B09E: 85 03
  JSR B1F_MathMul24x8                   ; $B0A0: 20 E9 EB
  LDA $06                               ; $B0A3: A5 06
  STA $01                               ; $B0A5: 85 01
  LDA $07                               ; $B0A7: A5 07
  STA $02                               ; $B0A9: 85 02
  LDA #$0A                              ; $B0AB: A9 0A
  STA $03                               ; $B0AD: 85 03
  LDA #$00                              ; $B0AF: A9 00
  STA $04                               ; $B0B1: 85 04
  JSR B1F_MathDiv16                     ; $B0B3: 20 7C EA
  PLA                                   ; $B0B6: 68
  CLC                                   ; $B0B7: 18
  ADC $01                               ; $B0B8: 65 01
  STA $02                               ; $B0BA: 85 02
  LDA #$00                              ; $B0BC: A9 00
  STA $03                               ; $B0BE: 85 03
  LDA $02                               ; $B0C0: A5 02
  CLC                                   ; $B0C2: 18
  ADC #$1E                              ; $B0C3: 69 1E
  STA $02                               ; $B0C5: 85 02
  LDA $03                               ; $B0C7: A5 03
  ADC #$00                              ; $B0C9: 69 00
  STA $03                               ; $B0CB: 85 03
  LDY $0509                             ; $B0CD: AC 09 05
  LDA $0664,Y                           ; $B0D0: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B0D3: 20 D7 F2
  JSR ApplyGoldChange                   ; $B0D6: 20 8B B6
  INC $0501                             ; $B0D9: EE 01 05
  RTS                                   ; $B0DC: 60
.endproc
; FeintCounter (伪击转杀, stratagem 6) shares the FireAttack execution body
; at $B062.
ExecStratagem_FeintCounter = ExecStratagem_FireAttack

.proc ExecStratagem_Trap
  JSR CheckSuccessByStats               ; $B0DD: 20 BE B7
  BCS @B0EB                             ; $B0E0: B0 09
  INC $0501                             ; $B0E2: EE 01 05
  LDA #$FF                              ; $B0E5: A9 FF
  STA $0544                             ; $B0E7: 8D 44 05
  RTS                                   ; $B0EA: 60
.endproc

.proc CommandPhase_LoyaltyDrainCalc
  LDY $050A                             ; $B0EB: AC 0A 05
  LDA $0664,Y                           ; $B0EE: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B0F1: 20 D7 F2
  LDY #$0B                              ; $B0F4: A0 0B
  LDA ($00),Y                           ; $B0F6: B1 00
  LSR                                   ; $B0F8: 4A
  LSR                                   ; $B0F9: 4A
  LSR                                   ; $B0FA: 4A
  LSR                                   ; $B0FB: 4A
  PHA                                   ; $B0FC: 48
  LDY #$01                              ; $B0FD: A0 01
  LDA ($00),Y                           ; $B0FF: B1 00
  CLC                                   ; $B101: 18
  LDY #$02                              ; $B102: A0 02
  ADC ($00),Y                           ; $B104: 71 00
  STA $01                               ; $B106: 85 01
  LDA #$00                              ; $B108: A9 00
  STA $02                               ; $B10A: 85 02
  STA $04                               ; $B10C: 85 04
  LDA #$0A                              ; $B10E: A9 0A
  STA $03                               ; $B110: 85 03
  JSR B1F_MathDiv16                     ; $B112: 20 7C EA
  PLA                                   ; $B115: 68
  CLC                                   ; $B116: 18
  ADC $01                               ; $B117: 65 01
  STA $00                               ; $B119: 85 00
  LDA #$00                              ; $B11B: A9 00
  STA $01                               ; $B11D: 85 01
  STA $02                               ; $B11F: 85 02
  LDA #$03                              ; $B121: A9 03
  JSR B1F_RandomBelowThreshold          ; $B123: 20 62 E8
  CLC                                   ; $B126: 18
  ADC #$05                              ; $B127: 69 05
  STA $03                               ; $B129: 85 03
  JSR B1F_MathMul24x8                   ; $B12B: 20 E9 EB
  LDA $06                               ; $B12E: A5 06
  STA $01                               ; $B130: 85 01
  LDA $07                               ; $B132: A5 07
  STA $02                               ; $B134: 85 02
  LDA #$0A                              ; $B136: A9 0A
  STA $03                               ; $B138: 85 03
  LDA #$00                              ; $B13A: A9 00
  STA $04                               ; $B13C: 85 04
  JSR B1F_MathDiv16                     ; $B13E: 20 7C EA
  LDA $01                               ; $B141: A5 01
  STA $02                               ; $B143: 85 02
  LDY $0509                             ; $B145: AC 09 05
  LDA $0664,Y                           ; $B148: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B14B: 20 D7 F2
  JSR ApplyLoyaltyChange                ; $B14E: 20 D8 B5
  INC $0501                             ; $B151: EE 01 05
  RTS                                   ; $B154: 60
.endproc

.proc ExecStratagem_FeintTroops
  JSR CheckSuccessByStats               ; $B155: 20 BE B7
  BCS @Success                          ; $B158: B0 09
  INC $0501                             ; $B15A: EE 01 05
  LDA #$FF                              ; $B15D: A9 FF
  STA $0544                             ; $B15F: 8D 44 05
  RTS                                   ; $B162: 60
@Success:
  LDA #$02                              ; $B163: A9 02
  STA $00                               ; $B165: 85 00
  LDA $0504                             ; $B167: AD 04 05
  BPL @StoreResult                      ; $B16A: 10 02
  INC $00                               ; $B16C: E6 00
@StoreResult:
  LDY $0509                             ; $B16E: AC 09 05
  LDA $00                               ; $B171: A5 00
  STA $0650,Y                           ; $B173: 99 50 06
  INC $0501                             ; $B176: EE 01 05
  RTS                                   ; $B179: 60
.endproc

.proc ExecStratagem_AmbushStrike
  JSR CheckSuccessByStats               ; $B17A: 20 BE B7
  BCS @B188                             ; $B17D: B0 09
  INC $0501                             ; $B17F: EE 01 05
  LDA #$FF                              ; $B182: A9 FF
  STA $0544                             ; $B184: 8D 44 05
  RTS                                   ; $B187: 60
.endproc

.proc CommandPhase_StatDrainCalcA
  LDY $050A                             ; $B188: AC 0A 05
  LDA $0664,Y                           ; $B18B: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B18E: 20 D7 F2
  LDY #$01                              ; $B191: A0 01
  LDA ($00),Y                           ; $B193: B1 00
  STA $00                               ; $B195: 85 00
  LDA #$00                              ; $B197: A9 00
  STA $01                               ; $B199: 85 01
  STA $02                               ; $B19B: 85 02
  LDA #$07                              ; $B19D: A9 07
  JSR B1F_RandomBelowThreshold          ; $B19F: 20 62 E8
  CLC                                   ; $B1A2: 18
  ADC #$0E                              ; $B1A3: 69 0E
  STA $03                               ; $B1A5: 85 03
  JSR B1F_MathMul24x8                   ; $B1A7: 20 E9 EB
  LDA $06                               ; $B1AA: A5 06
  STA $01                               ; $B1AC: 85 01
  LDA $07                               ; $B1AE: A5 07
  STA $02                               ; $B1B0: 85 02
  LDA #$0A                              ; $B1B2: A9 0A
  STA $03                               ; $B1B4: 85 03
  LDA #$00                              ; $B1B6: A9 00
  STA $04                               ; $B1B8: 85 04
  JSR B1F_MathDiv16                     ; $B1BA: 20 7C EA
  LDA $02                               ; $B1BD: A5 02
  STA $03                               ; $B1BF: 85 03
  LDA $01                               ; $B1C1: A5 01
  STA $02                               ; $B1C3: 85 02
  LDY $0509                             ; $B1C5: AC 09 05
  LDA $0664,Y                           ; $B1C8: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B1CB: 20 D7 F2
  JSR ApplyGoldChange                   ; $B1CE: 20 8B B6
  INC $0501                             ; $B1D1: EE 01 05
  RTS                                   ; $B1D4: 60
.endproc

.proc ExecStratagem_MuddyWater
  JSR CheckSuccessByStats               ; $B1D5: 20 BE B7
  BCS @B1E3                             ; $B1D8: B0 09
  INC $0501                             ; $B1DA: EE 01 05
  LDA #$FF                              ; $B1DD: A9 FF
  STA $0544                             ; $B1DF: 8D 44 05
  RTS                                   ; $B1E2: 60
.endproc

.proc CommandPhase_StatDrainCalcB
  LDY $050A                             ; $B1E3: AC 0A 05
  LDA $0664,Y                           ; $B1E6: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B1E9: 20 D7 F2
  LDY #$0B                              ; $B1EC: A0 0B
  LDA ($00),Y                           ; $B1EE: B1 00
  LSR                                   ; $B1F0: 4A
  LSR                                   ; $B1F1: 4A
  LSR                                   ; $B1F2: 4A
  LSR                                   ; $B1F3: 4A
  PHA                                   ; $B1F4: 48
  LDY #$02                              ; $B1F5: A0 02
  LDA ($00),Y                           ; $B1F7: B1 00
  STA $00                               ; $B1F9: 85 00
  LDA #$00                              ; $B1FB: A9 00
  STA $01                               ; $B1FD: 85 01
  STA $02                               ; $B1FF: 85 02
  LDA #$07                              ; $B201: A9 07
  JSR B1F_RandomBelowThreshold          ; $B203: 20 62 E8
  CLC                                   ; $B206: 18
  ADC #$14                              ; $B207: 69 14
  STA $03                               ; $B209: 85 03
  JSR B1F_MathMul24x8                   ; $B20B: 20 E9 EB
  LDA $06                               ; $B20E: A5 06
  STA $01                               ; $B210: 85 01
  LDA $07                               ; $B212: A5 07
  STA $02                               ; $B214: 85 02
  LDA #$0A                              ; $B216: A9 0A
  STA $03                               ; $B218: 85 03
  LDA #$00                              ; $B21A: A9 00
  STA $04                               ; $B21C: 85 04
  JSR B1F_MathDiv16                     ; $B21E: 20 7C EA
  PLA                                   ; $B221: 68
  CLC                                   ; $B222: 18
  ADC #$07                              ; $B223: 69 07
  ADC $01                               ; $B225: 65 01
  STA $01                               ; $B227: 85 01
  LDA $02                               ; $B229: A5 02
  ADC #$00                              ; $B22B: 69 00
  STA $03                               ; $B22D: 85 03
  LDA $01                               ; $B22F: A5 01
  STA $02                               ; $B231: 85 02
  LDY $0509                             ; $B233: AC 09 05
  LDA $0664,Y                           ; $B236: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B239: 20 D7 F2
  JSR ApplyGoldChange                   ; $B23C: 20 8B B6
  INC $0501                             ; $B23F: EE 01 05
  RTS                                   ; $B242: 60
.endproc

.proc ExecStratagem_FireArrows
  JSR CheckSuccessByStats               ; $B243: 20 BE B7
  BCS @Success                          ; $B246: B0 09
  INC $0501                             ; $B248: EE 01 05
  LDA #$FF                              ; $B24B: A9 FF
  STA $0544                             ; $B24D: 8D 44 05
  RTS                                   ; $B250: 60
@Success:
  LDA #$05                              ; $B251: A9 05
  JSR B1F_RandomBelowThreshold          ; $B253: 20 62 E8
  CLC                                   ; $B256: 18
  ADC #$0A                              ; $B257: 69 0A
  STA $03                               ; $B259: 85 03
  LDY #$00                              ; $B25B: A0 00
  LDA $0504                             ; $B25D: AD 04 05
  BMI @LoadProvince                     ; $B260: 30 02
  LDY #$02                              ; $B262: A0 02
@LoadProvince:
  LDA $0522,Y                           ; $B264: B9 22 05
  STA $00                               ; $B267: 85 00
  LDA $0523,Y                           ; $B269: B9 23 05
  STA $01                               ; $B26C: 85 01
  LDA #$00                              ; $B26E: A9 00
  STA $02                               ; $B270: 85 02
  JSR B1F_MathMul24x8                   ; $B272: 20 E9 EB
  LDA $06                               ; $B275: A5 06
  STA $00                               ; $B277: 85 00
  LDA $07                               ; $B279: A5 07
  STA $01                               ; $B27B: 85 01
  LDA $08                               ; $B27D: A5 08
  STA $02                               ; $B27F: 85 02
  LDA #$64                              ; $B281: A9 64
  STA $03                               ; $B283: 85 03
  LDA #$00                              ; $B285: A9 00
  STA $04                               ; $B287: 85 04
  JSR B1F_MathDiv24                     ; $B289: 20 A5 EA
  LDA $00                               ; $B28C: A5 00
  STA $10                               ; $B28E: 85 10
  LDA $01                               ; $B290: A5 01
  STA $11                               ; $B292: 85 11
  LDY $050A                             ; $B294: AC 0A 05
  LDA $0664,Y                           ; $B297: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B29A: 20 D7 F2
  LDY #$02                              ; $B29D: A0 02
  LDA ($00),Y                           ; $B29F: B1 00
  STA $01                               ; $B2A1: 85 01
  LDA #$00                              ; $B2A3: A9 00
  STA $02                               ; $B2A5: 85 02
  STA $04                               ; $B2A7: 85 04
  LDA #$05                              ; $B2A9: A9 05
  STA $03                               ; $B2AB: 85 03
  JSR B1F_MathDiv16                     ; $B2AD: 20 7C EA
  LDA $01                               ; $B2B0: A5 01
  CLC                                   ; $B2B2: 18
  ADC $10                               ; $B2B3: 65 10
  STA $10                               ; $B2B5: 85 10
  LDA $11                               ; $B2B7: A5 11
  ADC #$00                              ; $B2B9: 69 00
  STA $11                               ; $B2BB: 85 11
  LDY #$00                              ; $B2BD: A0 00
  LDA $0504                             ; $B2BF: AD 04 05
  BMI @LoadSlot                         ; $B2C2: 30 02
  LDY #$02                              ; $B2C4: A0 02
@LoadSlot:
  JSR ApplyGoldChangeAlt                ; $B2C6: 20 F0 B6
  INC $0501                             ; $B2C9: EE 01 05
  RTS                                   ; $B2CC: 60
.endproc

.proc ExecStratagem_CoordinatedStrike
  JSR CheckSuccessByStats               ; $B2CD: 20 BE B7
  BCS @Success                          ; $B2D0: B0 09
  INC $0501                             ; $B2D2: EE 01 05
  LDA #$FF                              ; $B2D5: A9 FF
  STA $0544                             ; $B2D7: 8D 44 05
  RTS                                   ; $B2DA: 60
@Success:
  JSR CommandPhase_DrainCalc              ; $B2DB: 20 70 B0
  JSR GetOfficerPos                     ; $B2DE: 20 7B B6
  DEC $10                               ; $B2E1: C6 10
  JSR ExecStratagem_CoordinatedStrikeNeighbor ; $B2E3: 20 04 B3
  JSR GetOfficerPos                     ; $B2E6: 20 7B B6
  INC $10                               ; $B2E9: E6 10
  JSR ExecStratagem_CoordinatedStrikeNeighbor ; $B2EB: 20 04 B3
  JSR GetOfficerPos                     ; $B2EE: 20 7B B6
  DEC $11                               ; $B2F1: C6 11
  JSR ExecStratagem_CoordinatedStrikeNeighbor ; $B2F3: 20 04 B3
  JSR GetOfficerPos                     ; $B2F6: 20 7B B6
  INC $11                               ; $B2F9: E6 11
  JSR ExecStratagem_CoordinatedStrikeNeighbor ; $B2FB: 20 04 B3
  LDA #$07                              ; $B2FE: A9 07
  STA $0501                             ; $B300: 8D 01 05
  RTS                                   ; $B303: 60
.endproc

.proc ExecStratagem_CoordinatedStrikeNeighbor
  JSR CheckTileAccess                   ; $B304: 20 43 B6
  BEQ @Done                             ; $B307: F0 12
  CMP #$FE                              ; $B309: C9 FE
  BEQ @Done                             ; $B30B: F0 0E
  LDA $0509                             ; $B30D: AD 09 05
  PHA                                   ; $B310: 48
  STY $0509                             ; $B311: 8C 09 05
  JSR CommandPhase_DrainCalc              ; $B314: 20 70 B0
  PLA                                   ; $B317: 68
  STA $0509                             ; $B318: 8D 09 05
@Done:
  RTS                                   ; $B31B: 60
.endproc

.proc ExecStratagem_WinOver
  JSR CheckActionSuccess                ; $B31C: 20 2B B7
  BCS @Success                          ; $B31F: B0 09
  INC $0501                             ; $B321: EE 01 05
  LDA #$FF                              ; $B324: A9 FF
  STA $0544                             ; $B326: 8D 44 05
  RTS                                   ; $B329: 60
@Success:
  LDY $0509                             ; $B32A: AC 09 05
  JSR $C886                             ; $B32D: 20 86 C8
  LDY $0509                             ; $B330: AC 09 05
  LDA $0628,Y                           ; $B333: B9 28 06
  EOR #$80                              ; $B336: 49 80
  STA $0628,Y                           ; $B338: 99 28 06
  LDA $0664,Y                           ; $B33B: B9 64 06
  STA officer_sel_list                             ; $B33E: 8D 2C 04
  LDA #$FF                              ; $B341: A9 FF
  CPY army_slot_base                             ; $B343: CC D8 04
  BNE @CheckSlot2                       ; $B346: D0 03
  STA army_slot_base                             ; $B348: 8D D8 04
@CheckSlot2:
  CPY army_slot_base+4                             ; $B34B: CC DC 04
  BNE @CheckAlly                        ; $B34E: D0 03
  STA army_slot_base+4                             ; $B350: 8D DC 04
@CheckAlly:
  LDA $6FA1,Y                           ; $B353: B9 A1 6F
  CMP #$FF                              ; $B356: C9 FF
  BNE @ClearAlly                        ; $B358: D0 08
  LDA #$04                              ; $B35A: A9 04
  STA $6FA1,Y                           ; $B35C: 99 A1 6F
  JMP @Continue                         ; $B35F: 4C 67 B3
@ClearAlly:
  LDA #$FF                              ; $B362: A9 FF
  STA $6FA1,Y                           ; $B364: 99 A1 6F
@Continue:
  LDA $0507                             ; $B367: AD 07 05
  AND #$0F                              ; $B36A: 29 0F
  STA $10                               ; $B36C: 85 10
  LDA $0507                             ; $B36E: AD 07 05
  LSR                                   ; $B371: 4A
  LSR                                   ; $B372: 4A
  LSR                                   ; $B373: 4A
  LSR                                   ; $B374: 4A
  STA $11                               ; $B375: 85 11
  LDX $10                               ; $B377: A6 10
  LDY $0509                             ; $B379: AC 09 05
  LDA $0628,Y                           ; $B37C: B9 28 06
  BPL @GetNewRuler                      ; $B37F: 10 02
  LDX $11                               ; $B381: A6 11
@GetNewRuler:
  TXA                                   ; $B383: 8A
  JSR B1F_GetRulerDataPtr               ; $B384: 20 68 F3
  LDY #$00                              ; $B387: A0 00
  LDA ($00),Y                           ; $B389: B1 00
  STA $30                               ; $B38B: 85 30
  LDX $11                               ; $B38D: A6 11
  LDY $0509                             ; $B38F: AC 09 05
  LDA $0628,Y                           ; $B392: B9 28 06
  BPL @GetOldRuler                      ; $B395: 10 02
  LDX $10                               ; $B397: A6 10
@GetOldRuler:
  TXA                                   ; $B399: 8A
  JSR B1F_GetRulerDataPtr               ; $B39A: 20 68 F3
  LDY #$00                              ; $B39D: A0 00
  LDA ($00),Y                           ; $B39F: B1 00
  STA $32                               ; $B3A1: 85 32
  LDY $0509                             ; $B3A3: AC 09 05
  LDA $0664,Y                           ; $B3A6: B9 64 06
  STA $31                               ; $B3A9: 85 31
  LDY #$2A                              ; $B3AB: A0 2A
  JSR B1F_BankedCallbackTrampoline      ; $B3AD: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A006                               ; $B3B0: $06 A0
  INC $0501                                   ; $B3B2: EE 01 05
  RTS                                         ; $B3B5: 60
.endproc

.proc ExecStratagem_FallingRocks
  JSR CheckSuccessByStats               ; $B3B6: 20 BE B7
  BCS @Success                          ; $B3B9: B0 09
  INC $0501                             ; $B3BB: EE 01 05
  LDA #$FF                              ; $B3BE: A9 FF
  STA $0544                             ; $B3C0: 8D 44 05
  RTS                                   ; $B3C3: 60
@Success:
  JSR CommandPhase_LoyaltyDrainCalc     ; $B3C4: 20 EB B0
  JSR CommandPhase_StatDrainCalcA       ; $B3C7: 20 88 B1
  LDA #$07                              ; $B3CA: A9 07
  STA $0501                             ; $B3CC: 8D 01 05
  RTS                                   ; $B3CF: 60
.endproc

.proc ExecStratagem_ChainStratagem
  JSR CheckSuccessByStats               ; $B3D0: 20 BE B7
  BCS @Success                          ; $B3D3: B0 09
  INC $0501                             ; $B3D5: EE 01 05
  LDA #$FF                              ; $B3D8: A9 FF
  STA $0544                             ; $B3DA: 8D 44 05
  RTS                                   ; $B3DD: 60
@Success:
  JSR BuildNeighborList                 ; $B3DE: 20 A1 B8
  LDY #$00                              ; $B3E1: A0 00
@ScanLoop:
  LDA $6FC9,Y                           ; $B3E3: B9 C9 6F
  CMP #$FF                              ; $B3E6: C9 FF
  BEQ @NextNeighbor                     ; $B3E8: F0 09
  STA $12                               ; $B3EA: 85 12
  TYA                                   ; $B3EC: 98
  PHA                                   ; $B3ED: 48
  JSR ExecStratagem_ChainStratagemProcess   ; $B3EE: 20 FE B3
  PLA                                   ; $B3F1: 68
  TAY                                   ; $B3F2: A8
@NextNeighbor:
  INY                                   ; $B3F3: C8
  CPY #$14                              ; $B3F4: C0 14
  BCC @ScanLoop                         ; $B3F6: 90 EB
  LDA #$07                              ; $B3F8: A9 07
  STA $0501                             ; $B3FA: 8D 01 05
  RTS                                   ; $B3FD: 60
.endproc

.proc ExecStratagem_ChainStratagemProcess
  LDY $12                               ; $B3FE: A4 12
  LDA $0600,Y                           ; $B400: B9 00 06
  STA $10                               ; $B403: 85 10
  LDA $0614,Y                           ; $B405: B9 14 06
  STA $11                               ; $B408: 85 11
  JSR GetTerrainType                             ; $B40A: 20 46 DB
  CMP #$03                              ; $B40D: C9 03
  BNE @B429                             ; $B40F: D0 18
  LDA #$02                              ; $B411: A9 02
  JSR B1F_RandomBelowThreshold          ; $B413: 20 62 E8
  CLC                                   ; $B416: 18
  ADC #$03                              ; $B417: 69 03
  STA $00                               ; $B419: 85 00
  LDA $0504                             ; $B41B: AD 04 05
  BPL @StoreResult                      ; $B41E: 10 02
  INC $00                               ; $B420: E6 00
@StoreResult:
  LDY $12                               ; $B422: A4 12
  LDA $00                               ; $B424: A5 00
  STA $0650,Y                           ; $B426: 99 50 06
@Done:
  RTS                                   ; $B429: 60
.endproc

.proc ExecStratagem_AmbushAllSides
  LDX #$00                              ; $B42A: A2 00
  LDA $0504                             ; $B42C: AD 04 05
  BPL @LoadSlot                         ; $B42F: 10 02
  LDX #$04                              ; $B431: A2 04
@LoadSlot:
  LDY $050A                             ; $B433: AC 0A 05
  LDA $0600,Y                           ; $B436: B9 00 06
  STA army_slot_base+1,X                           ; $B439: 9D D9 04
  LDA $0614,Y                           ; $B43C: B9 14 06
  STA army_slot_base+2,X                           ; $B43F: 9D DA 04
  LDA #$05                              ; $B442: A9 05
  STA army_slot_base+3,X                           ; $B444: 9D DB 04
  TYA                                   ; $B447: 98
  STA army_slot_base,X                           ; $B448: 9D D8 04
  TAY                                   ; $B44B: A8
  LDA $0664,Y                           ; $B44C: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B44F: 20 D7 F2
  LDY #$08                              ; $B452: A0 08
  LDA ($00),Y                           ; $B454: B1 00
  SEC                                   ; $B456: 38
  SBC #$64                              ; $B457: E9 64
  STA ($00),Y                           ; $B459: 91 00
  INY                                   ; $B45B: C8
  LDA ($00),Y                           ; $B45C: B1 00
  SBC #$00                              ; $B45E: E9 00
  STA ($00),Y                           ; $B460: 91 00
  INC $0501                             ; $B462: EE 01 05
  RTS                                   ; $B465: 60
.endproc

.proc ExecStratagem_WaterAttack
  JSR CheckSuccessByStats               ; $B466: 20 BE B7
  BCS @Success                          ; $B469: B0 09
  INC $0501                             ; $B46B: EE 01 05
  LDA #$FF                              ; $B46E: A9 FF
  STA $0544                             ; $B470: 8D 44 05
  RTS                                   ; $B473: 60
@Success:
  JSR BuildNeighborList                 ; $B474: 20 A1 B8
  LDY #$00                              ; $B477: A0 00
@ScanLoop:
  LDA $6FC9,Y                           ; $B479: B9 C9 6F
  CMP #$FF                              ; $B47C: C9 FF
  BEQ @NextNeighbor                     ; $B47E: F0 09
  STA $12                               ; $B480: 85 12
  TYA                                   ; $B482: 98
  PHA                                   ; $B483: 48
  JSR ExecStratagem_WaterAttackProcess      ; $B484: 20 94 B4
  PLA                                   ; $B487: 68
  TAY                                   ; $B488: A8
@NextNeighbor:
  INY                                   ; $B489: C8
  CPY #$14                              ; $B48A: C0 14
  BCC @ScanLoop                         ; $B48C: 90 EB
  LDA #$07                              ; $B48E: A9 07
  STA $0501                             ; $B490: 8D 01 05
  RTS                                   ; $B493: 60
.endproc

.proc ExecStratagem_WaterAttackProcess
  LDY $12                               ; $B494: A4 12
  LDA $0600,Y                           ; $B496: B9 00 06
  STA $10                               ; $B499: 85 10
  LDA $0614,Y                           ; $B49B: B9 14 06
  STA $11                               ; $B49E: 85 11
  JSR GetTerrainType                             ; $B4A0: 20 46 DB
  CMP #$03                              ; $B4A3: C9 03
  BNE @B4B7                             ; $B4A5: D0 10
  LDY $12                               ; $B4A7: A4 12
  LDA $0509                             ; $B4A9: AD 09 05
  PHA                                   ; $B4AC: 48
  STY $0509                             ; $B4AD: 8C 09 05
  JSR CommandPhase_StatDrainCalcB       ; $B4B0: 20 E3 B1
  PLA                                   ; $B4B3: 68
  STA $0509                             ; $B4B4: 8D 09 05
@Done:
  RTS                                   ; $B4B7: 60
.endproc

.proc ExecStratagem_RepeatingCrossbow
  JSR CheckSuccessByStats               ; $B4B8: 20 BE B7
  BCS @Success                          ; $B4BB: B0 09
  INC $0501                             ; $B4BD: EE 01 05
  LDA #$FF                              ; $B4C0: A9 FF
  STA $0544                             ; $B4C2: 8D 44 05
  RTS                                   ; $B4C5: 60
@Success:
  LDY $050A                             ; $B4C6: AC 0A 05
  LDA $0664,Y                           ; $B4C9: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B4CC: 20 D7 F2
  LDA #$00                              ; $B4CF: A9 00
  STA $02                               ; $B4D1: 85 02
  STA $03                               ; $B4D3: 85 03
@RandomLoop:
  JSR B1F_RandomByte                    ; $B4D5: 20 7A E8
  CMP #$C8                              ; $B4D8: C9 C8
  BCS @RandomLoop                       ; $B4DA: B0 F9
  CLC                                   ; $B4DC: 18
  ADC #$96                              ; $B4DD: 69 96
  STA $02                               ; $B4DF: 85 02
  LDA $03                               ; $B4E1: A5 03
  ADC #$00                              ; $B4E3: 69 00
  STA $03                               ; $B4E5: 85 03
  LDY #$01                              ; $B4E7: A0 01
  LDA ($00),Y                           ; $B4E9: B1 00
  CLC                                   ; $B4EB: 18
  LDY #$02                              ; $B4EC: A0 02
  ADC ($00),Y                           ; $B4EE: 71 00
  LSR                                   ; $B4F0: 4A
  CLC                                   ; $B4F1: 18
  ADC $02                               ; $B4F2: 65 02
  STA $02                               ; $B4F4: 85 02
  LDA $03                               ; $B4F6: A5 03
  ADC #$00                              ; $B4F8: 69 00
  STA $03                               ; $B4FA: 85 03
  LDY $0509                             ; $B4FC: AC 09 05
  LDA $0664,Y                           ; $B4FF: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B502: 20 D7 F2
  JSR ApplyGoldChange                   ; $B505: 20 8B B6
  INC $0501                             ; $B508: EE 01 05
  RTS                                   ; $B50B: 60
.endproc

.proc ExecStratagem_PillageFire
  JSR CheckSuccessByStats               ; $B50C: 20 BE B7
  BCS @Success                          ; $B50F: B0 09
  INC $0501                             ; $B511: EE 01 05
  LDA #$FF                              ; $B514: A9 FF
  STA $0544                             ; $B516: 8D 44 05
  RTS                                   ; $B519: 60
@Success:
  JSR BuildNeighborList                 ; $B51A: 20 A1 B8
  LDY #$00                              ; $B51D: A0 00
@ScanLoop:
  LDA $6FC9,Y                           ; $B51F: B9 C9 6F
  CMP #$FF                              ; $B522: C9 FF
  BEQ @NextNeighbor                     ; $B524: F0 09
  STA $12                               ; $B526: 85 12
  TYA                                   ; $B528: 98
  PHA                                   ; $B529: 48
  JSR ExecStratagem_PillageFireCheck        ; $B52A: 20 38 B5
  PLA                                   ; $B52D: 68
  TAY                                   ; $B52E: A8
@NextNeighbor:
  INY                                   ; $B52F: C8
  CPY #$14                              ; $B530: C0 14
  BCC @ScanLoop                         ; $B532: 90 EB
  INC $0501                             ; $B534: EE 01 05
  RTS                                   ; $B537: 60
.endproc

.proc ExecStratagem_PillageFireCheck
  LDY $12                               ; $B538: A4 12
  LDA $0600,Y                           ; $B53A: B9 00 06
  STA $10                               ; $B53D: 85 10
  LDA $0614,Y                           ; $B53F: B9 14 06
  STA $11                               ; $B542: 85 11
  JSR GetTerrainType                             ; $B544: 20 46 DB
  CMP #$05                              ; $B547: C9 05
  BEQ @B55B                             ; $B549: F0 10
  LDY $12                               ; $B54B: A4 12
  LDA $0509                             ; $B54D: AD 09 05
  PHA                                   ; $B550: 48
  STY $0509                             ; $B551: 8C 09 05
  JSR ExecStratagem_PillageFireCalc         ; $B554: 20 5C B5
  PLA                                   ; $B557: 68
  STA $0509                             ; $B558: 8D 09 05
@Done:
  RTS                                   ; $B55B: 60
.endproc

.proc ExecStratagem_PillageFireCalc
  LDY $050A                             ; $B55C: AC 0A 05
  LDA $0664,Y                           ; $B55F: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B562: 20 D7 F2
  LDA #$06                              ; $B565: A9 06
  JSR B1F_RandomBelowThreshold          ; $B567: 20 62 E8
  CLC                                   ; $B56A: 18
  ADC #$1E                              ; $B56B: 69 1E
  STA $03                               ; $B56D: 85 03
  LDY #$02                              ; $B56F: A0 02
  LDA ($00),Y                           ; $B571: B1 00
  STA $00                               ; $B573: 85 00
  LDA #$00                              ; $B575: A9 00
  STA $01                               ; $B577: 85 01
  STA $02                               ; $B579: 85 02
  JSR B1F_MathMul24x8                   ; $B57B: 20 E9 EB
  LDA $06                               ; $B57E: A5 06
  STA $01                               ; $B580: 85 01
  LDA $07                               ; $B582: A5 07
  STA $02                               ; $B584: 85 02
  LDA #$0A                              ; $B586: A9 0A
  STA $03                               ; $B588: 85 03
  LDA #$00                              ; $B58A: A9 00
  STA $04                               ; $B58C: 85 04
  JSR B1F_MathDiv16                     ; $B58E: 20 7C EA
  LDA $02                               ; $B591: A5 02
  STA $03                               ; $B593: 85 03
  LDA $01                               ; $B595: A5 01
  STA $02                               ; $B597: 85 02
  LDY $0509                             ; $B599: AC 09 05
  LDA $0664,Y                           ; $B59C: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B59F: 20 D7 F2
  JSR ApplyGoldChange                   ; $B5A2: 20 8B B6
  RTS                                   ; $B5A5: 60
.endproc

.proc ExecStratagem_QimenDunjia
  JSR CheckSuccessByStats               ; $B5A6: 20 BE B7
  BCS @Success                          ; $B5A9: B0 09
  INC $0501                             ; $B5AB: EE 01 05
  LDA #$FF                              ; $B5AE: A9 FF
  STA $0544                             ; $B5B0: 8D 44 05
  RTS                                   ; $B5B3: 60
@Success:
  JSR B1F_RandomMod4                    ; $B5B4: 20 50 E8
  CLC                                   ; $B5B7: 18
  ADC #$05                              ; $B5B8: 69 05
  ASL                                   ; $B5BA: 0A
  ASL                                   ; $B5BB: 0A
  ASL                                   ; $B5BC: 0A
  ASL                                   ; $B5BD: 0A
  STA $00                               ; $B5BE: 85 00
  LDA $0504                             ; $B5C0: AD 04 05
  BPL @StoreResult                      ; $B5C3: 10 07
  LDA $00                               ; $B5C5: A5 00
  CLC                                   ; $B5C7: 18
  ADC #$10                              ; $B5C8: 69 10
  STA $00                               ; $B5CA: 85 00
@StoreResult:
  LDY $0509                             ; $B5CC: AC 09 05
  LDA $00                               ; $B5CF: A5 00
  STA $0650,Y                           ; $B5D1: 99 50 06
  INC $0501                             ; $B5D4: EE 01 05
  RTS                                   ; $B5D7: 60
.endproc

.proc ApplyLoyaltyChange
  LDY #$00                              ; $B5D8: A0 00
  LDA ($00),Y                           ; $B5DA: B1 00
  STA $04                               ; $B5DC: 85 04
  SEC                                   ; $B5DE: 38
  SBC $02                               ; $B5DF: E5 02
  STA $06                               ; $B5E1: 85 06
  BCS @StoreResult                      ; $B5E3: B0 08
  LDA $04                               ; $B5E5: A5 04
  STA $02                               ; $B5E7: 85 02
  LDA #$00                              ; $B5E9: A9 00
  STA $06                               ; $B5EB: 85 06
@StoreResult:
  LDY #$00                              ; $B5ED: A0 00
  LDA $06                               ; $B5EF: A5 06
  STA ($00),Y                           ; $B5F1: 91 00
  LDA $02                               ; $B5F3: A5 02
  STA officer_sel_list+3                             ; $B5F5: 8D 2F 04
  LDA #$00                              ; $B5F8: A9 00
  STA officer_sel_list+4                             ; $B5FA: 8D 30 04
  STA officer_sel_list+5                             ; $B5FD: 8D 31 04
  LDA #$FF                              ; $B600: A9 FF
  STA officer_sel_list+6                             ; $B602: 8D 32 04
  LDA $06                               ; $B605: A5 06
  BNE $B642                             ; $B607: D0 39
  LDY #$0B                              ; $B609: A0 0B
  LDA ($00),Y                           ; $B60B: B1 00
  ORA #$03                              ; $B60D: 09 03
  STA ($00),Y                           ; $B60F: 91 00
  LDA #$00                              ; $B611: A9 00
  STA $12                               ; $B613: 85 12
  JSR UpdateCursorTile                             ; $B615: 20 CC D6
  LDY $050A                             ; $B618: AC 0A 05
  LDA $0664,Y                           ; $B61B: B9 64 06
  STA $0A                               ; $B61E: 85 0A
  LDY $0509                             ; $B620: AC 09 05
  LDA $0664,Y                           ; $B623: B9 64 06
  STA $0B                               ; $B626: 85 0B
  LDY #$2E                              ; $B628: A0 2E
  JSR B1F_BankedCallbackTrampoline      ; $B62A: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A009                               ; $B62D: $09 A0
  LDY $0509                                   ; $B62F: AC 09 05
  LDA $0664,Y                                 ; $B632: B9 64 06
  STA officer_sel_list+6                                   ; $B635: 8D 32 04
  STY $0000                                   ; $B638: 8C 00 00
  LDY #$28                                    ; $B63B: A0 28
  JSR B1F_BankedCallbackTrampoline            ; $B63D: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A02A                               ; $B640: $2A A0
.endproc

.proc CheckTileAccess
  LDA $11                                     ; $B643: A5 11
  CMP #$0F                                    ; $B645: C9 0F
  BNE @CheckBounds                      ; $B647: D0 11
  LDA $01                                     ; $B649: A5 01
  CMP #$0E                                    ; $B64B: C9 0E
  BEQ @AdjustCol                        ; $B64D: F0 07
  LDA #$0E                                    ; $B64F: A9 0E
  STA $11                                     ; $B651: 85 11
  JMP @CheckBounds                      ; $B653: 4C 5A B6
@AdjustCol:
  LDA #$10                              ; $B656: A9 10
  STA $11                               ; $B658: 85 11
@CheckBounds:
  LDA $10                               ; $B65A: A5 10
  STA $00                               ; $B65C: 85 00
  LDA $11                               ; $B65E: A5 11
  STA $01                               ; $B660: 85 01
  LDA $00                               ; $B662: A5 00
  CMP #$20                              ; $B664: C9 20
  BCS @ReturnInvalid                    ; $B666: B0 10
  LDA $01                               ; $B668: A5 01
  CMP #$14                              ; $B66A: C9 14
  BCS @ReturnInvalid                    ; $B66C: B0 0A
  JSR SearchRosterByTileCoord                             ; $B66E: 20 B6 D6
  TYA                                   ; $B671: 98
  BMI @ReturnInvalid                    ; $B672: 30 04
  JSR CheckOfficerArmyGroup                             ; $B674: 20 4B DC
  RTS                                   ; $B677: 60
@ReturnInvalid:
  LDA #$FE                              ; $B678: A9 FE
  RTS                                   ; $B67A: 60
.endproc

.proc GetOfficerPos
  LDY $0509                             ; $B67B: AC 09 05
  LDA $0600,Y                           ; $B67E: B9 00 06
  STA $10                               ; $B681: 85 10
  LDA $0614,Y                           ; $B683: B9 14 06
  STA $11                               ; $B686: 85 11
  STA $01                               ; $B688: 85 01
  RTS                                   ; $B68A: 60
.endproc

.proc ApplyGoldChange
  LDY #$08                              ; $B68B: A0 08
  LDA ($00),Y                           ; $B68D: B1 00
  STA $04                               ; $B68F: 85 04
  INY                                   ; $B691: C8
  LDA ($00),Y                           ; $B692: B1 00
  AND #$03                              ; $B694: 29 03
  STA $05                               ; $B696: 85 05
  LDA $04                               ; $B698: A5 04
  SEC                                   ; $B69A: 38
  SBC $02                               ; $B69B: E5 02
  STA $06                               ; $B69D: 85 06
  LDA $05                               ; $B69F: A5 05
  SBC $03                               ; $B6A1: E5 03
  STA $07                               ; $B6A3: 85 07
  BCS @StoreResult                      ; $B6A5: B0 0E
  LDA $04                               ; $B6A7: A5 04
  STA $02                               ; $B6A9: 85 02
  LDA $05                               ; $B6AB: A5 05
  STA $03                               ; $B6AD: 85 03
  LDA #$00                              ; $B6AF: A9 00
  STA $06                               ; $B6B1: 85 06
  STA $07                               ; $B6B3: 85 07
@StoreResult:
  LDY #$08                              ; $B6B5: A0 08
  LDA $06                               ; $B6B7: A5 06
  STA ($00),Y                           ; $B6B9: 91 00
  INY                                   ; $B6BB: C8
  LDA $07                               ; $B6BC: A5 07
  STA ($00),Y                           ; $B6BE: 91 00
  LDA $02                               ; $B6C0: A5 02
  CLC                                   ; $B6C2: 18
  ADC officer_sel_list                             ; $B6C3: 6D 2C 04
  STA officer_sel_list                             ; $B6C6: 8D 2C 04
  LDA $03                               ; $B6C9: A5 03
  ADC officer_sel_list+1                             ; $B6CB: 6D 2D 04
  STA officer_sel_list+1                             ; $B6CE: 8D 2D 04
  LDA #$00                              ; $B6D1: A9 00
  STA officer_sel_list+2                             ; $B6D3: 8D 2E 04
  LDY $050A                             ; $B6D6: AC 0A 05
  LDA $0664,Y                           ; $B6D9: B9 64 06
  STA $0A                               ; $B6DC: 85 0A
  LDA officer_sel_list                             ; $B6DE: AD 2C 04
  STA $0B                               ; $B6E1: 85 0B
  LDA officer_sel_list+1                             ; $B6E3: AD 2D 04
  STA $0C                               ; $B6E6: 85 0C
  LDY #$2E                              ; $B6E8: A0 2E
  JSR B1F_BankedCallbackTrampoline      ; $B6EA: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A006                               ; $B6ED: $06 A0
  RTS                                         ; $B6EF: 60
.endproc

.proc ApplyGoldChangeAlt
  LDA $0522,Y                                 ; $B6F0: B9 22 05
  SEC                                         ; $B6F3: 38
  SBC $10                                     ; $B6F4: E5 10
  STA $12                                     ; $B6F6: 85 12
  LDA $0523,Y                                 ; $B6F8: B9 23 05
  SBC $11                                     ; $B6FB: E5 11
  STA $13                                     ; $B6FD: 85 13
  BCS @B711                             ; $B6FF: B0 10
  LDA $0522,Y                                 ; $B701: B9 22 05
  STA $10                                     ; $B704: 85 10
  LDA $0523,Y                                 ; $B706: B9 23 05
  STA $11                                     ; $B709: 85 11
  LDA #$00                                    ; $B70B: A9 00
  STA $12                                     ; $B70D: 85 12
  STA $13                                     ; $B70F: 85 13
@StoreResult:
  LDA $12                               ; $B711: A5 12
  STA $0522,Y                           ; $B713: 99 22 05
  LDA $13                               ; $B716: A5 13
  STA $0523,Y                           ; $B718: 99 23 05
  LDA $10                               ; $B71B: A5 10
  STA officer_sel_list                             ; $B71D: 8D 2C 04
  LDA $11                               ; $B720: A5 11
  STA officer_sel_list+1                             ; $B722: 8D 2D 04
  LDA #$00                              ; $B725: A9 00
  STA officer_sel_list+2                             ; $B727: 8D 2E 04
  RTS                                   ; $B72A: 60
.endproc

.proc CheckActionSuccess
  JSR CalcDistance                      ; $B72B: 20 60 B8
  CMP #$06                              ; $B72E: C9 06
  BCC @CheckStats                       ; $B730: 90 03
  JMP @Fail                             ; $B732: 4C B6 B7
@CheckStats:
  LDY $0509                             ; $B735: AC 09 05
  LDA $0664,Y                           ; $B738: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B73B: 20 D7 F2
  LDX #$00                              ; $B73E: A2 00
  LDY #$0B                              ; $B740: A0 0B
  LDA ($00),Y                           ; $B742: B1 00
  LSR                                   ; $B744: 4A
  LSR                                   ; $B745: 4A
  LSR                                   ; $B746: 4A
  LSR                                   ; $B747: 4A
  STA $11                               ; $B748: 85 11
  LDY #$03                              ; $B74A: A0 03
  LDA ($00),Y                           ; $B74C: B1 00
  CMP #$1F                              ; $B74E: C9 1F
  BCC @ApplyThreshold                   ; $B750: 90 0C
  INX                                   ; $B752: E8
  CMP #$33                              ; $B753: C9 33
  BCC @ApplyThreshold                   ; $B755: 90 07
  INX                                   ; $B757: E8
  CMP #$47                              ; $B758: C9 47
  BCC @ApplyThreshold                   ; $B75A: 90 02
  CLC                                   ; $B75C: 18
  RTS                                   ; $B75D: 60
@ApplyThreshold:
  LDA @SuccessThresholdTable,X          ; $B75E: BD BA B7
  STA $10                               ; $B761: 85 10
  LDY $050A                             ; $B763: AC 0A 05
  LDA $0664,Y                           ; $B766: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B769: 20 D7 F2
  LDA $00                               ; $B76C: A5 00
  STA $0A                               ; $B76E: 85 0A
  LDA $01                               ; $B770: A5 01
  STA $0B                               ; $B772: 85 0B
  LDY #$0B                              ; $B774: A0 0B
  LDA ($0A),Y                           ; $B776: B1 0A
  LSR                                   ; $B778: 4A
  LSR                                   ; $B779: 4A
  LSR                                   ; $B77A: 4A
  LSR                                   ; $B77B: 4A
  SEC                                   ; $B77C: 38
  SBC $11                               ; $B77D: E5 11
  BPL @CalcBonus                        ; $B77F: 10 02
  LDA #$00                              ; $B781: A9 00
@CalcBonus:
  ASL                                   ; $B783: 0A
  STA $11                               ; $B784: 85 11
  LDY #$02                              ; $B786: A0 02
  LDA ($0A),Y                           ; $B788: B1 0A
  STA $01                               ; $B78A: 85 01
  LDY #$04                              ; $B78C: A0 04
  LDA ($0A),Y                           ; $B78E: B1 0A
  CLC                                   ; $B790: 18
  ADC $01                               ; $B791: 65 01
  STA $01                               ; $B793: 85 01
  LDA #$00                              ; $B795: A9 00
  STA $02                               ; $B797: 85 02
  STA $04                               ; $B799: 85 04
  LDA #$0A                              ; $B79B: A9 0A
  STA $03                               ; $B79D: 85 03
  JSR B1F_MathDiv16                     ; $B79F: 20 7C EA
  LDA $01                               ; $B7A2: A5 01
  CLC                                   ; $B7A4: 18
  ADC $10                               ; $B7A5: 65 10
  ADC $11                               ; $B7A7: 65 11
  STA $00                               ; $B7A9: 85 00
@RandomLoop:
  JSR B1F_RandomByte                    ; $B7AB: 20 7A E8
  CMP #$64                              ; $B7AE: C9 64
  BCS @RandomLoop                       ; $B7B0: B0 F9
  CMP $00                               ; $B7B2: C5 00
  BCC @Success                          ; $B7B4: 90 02
@Fail:
  CLC                                   ; $B7B6: 18
  RTS                                   ; $B7B7: 60
@Success:
  SEC                                   ; $B7B8: 38
  RTS                                   ; $B7B9: 60
; Success threshold table indexed by officer rank tier
@SuccessThresholdTable:
  .byte $3C,$1E,$0A,$05                   ; $B7BA: 3C 1E 0A 05
.endproc

.proc CheckSuccessByStats
  LDY $0509                             ; $B7BE: AC 09 05
  LDA $0664,Y                           ; $B7C1: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B7C4: 20 D7 F2
  LDY #$02                              ; $B7C7: A0 02
  LDA ($00),Y                           ; $B7C9: B1 00
  STA $10                               ; $B7CB: 85 10
  LDY #$0B                              ; $B7CD: A0 0B
  LDA ($00),Y                           ; $B7CF: B1 00
  LSR                                   ; $B7D1: 4A
  LSR                                   ; $B7D2: 4A
  LSR                                   ; $B7D3: 4A
  LSR                                   ; $B7D4: 4A
  STA $11                               ; $B7D5: 85 11
  LDY $050A                             ; $B7D7: AC 0A 05
  LDA $0664,Y                           ; $B7DA: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $B7DD: 20 D7 F2
  LDY #$02                              ; $B7E0: A0 02
  LDA ($00),Y                           ; $B7E2: B1 00
  STA $12                               ; $B7E4: 85 12
  LDY #$0B                              ; $B7E6: A0 0B
  LDA ($00),Y                           ; $B7E8: B1 00
  LSR                                   ; $B7EA: 4A
  LSR                                   ; $B7EB: 4A
  LSR                                   ; $B7EC: 4A
  LSR                                   ; $B7ED: 4A
  STA $13                               ; $B7EE: 85 13
  LDA $12                               ; $B7F0: A5 12
  SEC                                   ; $B7F2: 38
  SBC $10                               ; $B7F3: E5 10
  BCS @ClampLow1                        ; $B7F5: B0 02
  LDA #$00                              ; $B7F7: A9 00
@ClampLow1:
  STA $10                               ; $B7F9: 85 10
  LDA $13                               ; $B7FB: A5 13
  SEC                                   ; $B7FD: 38
  SBC $11                               ; $B7FE: E5 11
  BCS @ClampLow2                        ; $B800: B0 02
  LDA #$00                              ; $B802: A9 00
@ClampLow2:
  ASL                                   ; $B804: 0A
  STA $11                               ; $B805: 85 11
  JSR CalcDistance                      ; $B807: 20 60 B8
  TAY                                   ; $B80A: A8
  CPY #$06                              ; $B80B: C0 06
  BCS @Fail                             ; $B80D: B0 47
  LDA @SuccessModifierTable,Y           ; $B80F: B9 5A B8
  STA $12                               ; $B812: 85 12
  LDX #$0A                              ; $B814: A2 0A
  LDA $050F                             ; $B816: AD 0F 05
  CMP #$03                              ; $B819: C9 03
  BNE @StoreModifier                    ; $B81B: D0 0F
  LDA $6F02                             ; $B81D: AD 02 6F
  CMP #$01                              ; $B820: C9 01
  BEQ @StoreModifier                    ; $B822: F0 08
  LDX #$14                              ; $B824: A2 14
  CMP #$02                              ; $B826: C9 02
  BEQ @StoreModifier                    ; $B828: F0 02
  LDX #$05                              ; $B82A: A2 05
@StoreModifier:
  STX $14                               ; $B82C: 86 14
  LDA $12                               ; $B82E: A5 12
  CLC                                   ; $B830: 18
  ADC $10                               ; $B831: 65 10
  CLC                                   ; $B833: 18
  ADC $11                               ; $B834: 65 11
  CLC                                   ; $B836: 18
  ADC $14                               ; $B837: 65 14
  BPL @ClampHigh                        ; $B839: 10 02
  LDA #$00                              ; $B83B: A9 00
@ClampHigh:
  CMP #$5F                              ; $B83D: C9 5F
  BCC @ClampMin                         ; $B83F: 90 02
  LDA #$5F                              ; $B841: A9 5F
@ClampMin:
  CMP #$05                              ; $B843: C9 05
  BCS @StoreThreshold                   ; $B845: B0 02
  LDA #$05                              ; $B847: A9 05
@StoreThreshold:
  STA $00                               ; $B849: 85 00
@RandomLoop:
  JSR B1F_RandomByte                    ; $B84B: 20 7A E8
  CMP #$64                              ; $B84E: C9 64
  BCS @RandomLoop                       ; $B850: B0 F9
  CMP $00                               ; $B852: C5 00
  BCC @Success                          ; $B854: 90 02
@Fail:
  CLC                                   ; $B856: 18
  RTS                                   ; $B857: 60
@Success:
  SEC                                   ; $B858: 38
  RTS                                   ; $B859: 60
; Success modifier table for stat-based checks
@SuccessModifierTable:
  .byte $0F,$0A,$05,$00,$FB,$F6           ; $B85A: 0F 0A 05 00 FB F6
.endproc

.proc CalcDistance
  LDY $0509                             ; $B860: AC 09 05
  LDA $0614,Y                           ; $B863: B9 14 06
  CMP #$10                              ; $B866: C9 10
  BCC @SkipRowAdj1                      ; $B868: 90 02
  SBC #$01                              ; $B86A: E9 01
@SkipRowAdj1:
  STA $00                               ; $B86C: 85 00
  LDY $050A                             ; $B86E: AC 0A 05
  LDA $0614,Y                           ; $B871: B9 14 06
  CMP #$10                              ; $B874: C9 10
  BCC @SkipRowAdj2                      ; $B876: 90 02
  SBC #$01                              ; $B878: E9 01
@SkipRowAdj2:
  SEC                                   ; $B87A: 38
  SBC $00                               ; $B87B: E5 00
  BCS @AbsRow                           ; $B87D: B0 05
  EOR #$FF                              ; $B87F: 49 FF
  CLC                                   ; $B881: 18
  ADC #$01                              ; $B882: 69 01
@AbsRow:
  STA $00                               ; $B884: 85 00
  LDY $050A                             ; $B886: AC 0A 05
  LDA $0600,Y                           ; $B889: B9 00 06
  SEC                                   ; $B88C: 38
  LDY $0509                             ; $B88D: AC 09 05
  SBC $0600,Y                           ; $B890: F9 00 06
  BCS @AbsCol                           ; $B893: B0 05
  EOR #$FF                              ; $B895: 49 FF
  CLC                                   ; $B897: 18
  ADC #$01                              ; $B898: 69 01
@AbsCol:
  CMP $00                               ; $B89A: C5 00
  BCS @ReturnMax                        ; $B89C: B0 02
  LDA $00                               ; $B89E: A5 00
@ReturnMax:
  RTS                                   ; $B8A0: 60
.endproc

.proc BuildNeighborList
  LDY #$00                              ; $B8A1: A0 00
  LDA #$FF                              ; $B8A3: A9 FF
@ClearLoop:
  STA $6FC9,Y                           ; $B8A5: 99 C9 6F
  INY                                   ; $B8A8: C8
  CPY #$14                              ; $B8A9: C0 14
  BCC @ClearLoop                        ; $B8AB: 90 F8
  LDA $0509                             ; $B8AD: AD 09 05
  STA $6FC9                             ; $B8B0: 8D C9 6F
  TAY                                   ; $B8B3: A8
  JSR ExpandNeighbors                   ; $B8B4: 20 CE B8
  LDX #$01                              ; $B8B7: A2 01
@ScanLoop:
  LDA $6FC9,X                           ; $B8B9: BD C9 6F
  CMP #$FF                              ; $B8BC: C9 FF
  BEQ @Done                             ; $B8BE: F0 0D
  TAY                                   ; $B8C0: A8
  TXA                                   ; $B8C1: 8A
  PHA                                   ; $B8C2: 48
  JSR ExpandNeighbors                   ; $B8C3: 20 CE B8
  PLA                                   ; $B8C6: 68
  TAX                                   ; $B8C7: AA
  INX                                   ; $B8C8: E8
  CPX #$14                              ; $B8C9: E0 14
  BCC @ScanLoop                         ; $B8CB: 90 EC
@Done:
  RTS                                   ; $B8CD: 60
.endproc

.proc ExpandNeighbors
  LDA $0600,Y                           ; $B8CE: B9 00 06
  STA $12                               ; $B8D1: 85 12
  LDA $0614,Y                           ; $B8D3: B9 14 06
  CMP #$10                              ; $B8D6: C9 10
  BCC @SkipRowAdj                       ; $B8D8: 90 03
  SEC                                   ; $B8DA: 38
  SBC #$01                              ; $B8DB: E9 01
@SkipRowAdj:
  STA $13                               ; $B8DD: 85 13
  INC $12                               ; $B8DF: E6 12
  JSR ScanAdjacentTile                  ; $B8E1: 20 FA B8
  DEC $12                               ; $B8E4: C6 12
  DEC $12                               ; $B8E6: C6 12
  JSR ScanAdjacentTile                  ; $B8E8: 20 FA B8
  INC $12                               ; $B8EB: E6 12
  INC $13                               ; $B8ED: E6 13
  JSR ScanAdjacentTile                  ; $B8EF: 20 FA B8
  DEC $13                               ; $B8F2: C6 13
  DEC $13                               ; $B8F4: C6 13
  JSR ScanAdjacentTile                  ; $B8F6: 20 FA B8
  RTS                                   ; $B8F9: 60
.endproc

.proc ScanAdjacentTile
  LDY #$00                              ; $B8FA: A0 00
@ScanLoop:
  LDA $0600,Y                           ; $B8FC: B9 00 06
  CMP $12                               ; $B8FF: C5 12
  BNE @NextSlot                         ; $B901: D0 15
  LDA $0614,Y                           ; $B903: B9 14 06
  CMP #$10                              ; $B906: C9 10
  BCC @SkipRowAdj                       ; $B908: 90 03
  SEC                                   ; $B90A: 38
  SBC #$01                              ; $B90B: E9 01
@SkipRowAdj:
  CMP $13                               ; $B90D: C5 13
  BNE @NextSlot                         ; $B90F: D0 07
  JSR CheckOfficerArmyGroup                             ; $B911: 20 4B DC
  CMP #$FF                              ; $B914: C9 FF
  BEQ @Done                             ; $B916: F0 06
@NextSlot:
  INY                                   ; $B918: C8
  CPY #$14                              ; $B919: C0 14
  BCC @ScanLoop                         ; $B91B: 90 DF
  RTS                                   ; $B91D: 60
.endproc

.proc AddNeighborToList
  STY $14                               ; $B91E: 84 14
  LDA $0600,Y                           ; $B920: B9 00 06
  STA $10                               ; $B923: 85 10
  LDA $0614,Y                           ; $B925: B9 14 06
  STA $11                               ; $B928: 85 11
  JSR GetTerrainType                             ; $B92A: 20 46 DB
  CMP #$05                              ; $B92D: C9 05
  BEQ @Done                             ; $B92F: F0 18
  LDY #$00                              ; $B931: A0 00
@ScanLoop:
  LDA $6FC9,Y                           ; $B933: B9 C9 6F
  CMP #$FF                              ; $B936: C9 FF
  BNE @CheckDuplicate                   ; $B938: D0 06
  LDA $14                               ; $B93A: A5 14
  STA $6FC9,Y                           ; $B93C: 99 C9 6F
  RTS                                   ; $B93F: 60
@CheckDuplicate:
  CMP $14                               ; $B940: C5 14
  BNE @NextSlot                         ; $B942: D0 01
  RTS                                   ; $B944: 60
@NextSlot:
  INY                                   ; $B945: C8
  JMP @ScanLoop                         ; $B946: 4C 33 B9
@Done:
  RTS                                   ; $B949: 60
.endproc

.proc ProvinceSelectDispatch
  ; (dispatch callback target)
  LDA #$00                              ; $B94A: A9 00
  STA $00A4                             ; $B94C: 8D A4 00
  JSR CenterMapOnOfficer                             ; $B94F: 20 33 DC
  LDA $0501                             ; $B952: AD 01 05
  JSR B1F_CallbackDispatcher            ; $B955: 20 DE EA
; --- CallbackDispatcher table (6 entries) ---
  .word ProvinceState_Init                  ; $B958: $64 B9
  .word ProvinceState_Select                ; $B95A: $6D B9
  .word ProvinceState_Menu                  ; $B95C: $B6 B9
  .word ProvinceState_Confirm               ; $B95E: $30 BA
  .word ProvinceState_Cancel                ; $B960: $64 BA
  .word ProvinceState_Reset                 ; $B962: $83 BA
.endproc

.proc ProvinceState_Init
  LDA #$D6                                    ; $B964: A9 D6
  JSR B1F_SetUI5                              ; $B966: 20 83 F2
  INC $0501                                   ; $B969: EE 01 05
  RTS                                         ; $B96C: 60
.endproc

.proc ProvinceState_Select
  JSR DrawExchangeArrows_Left                             ; $B96D: 20 70 DC
  JSR TryAutoAdvance                       ; $B970: 20 DE A1
  JSR CheckExchangePossible                             ; $B973: 20 27 DF
  BCC @Done                             ; $B976: 90 3D
  LDA $81                               ; $B978: A5 81
  AND #$02                              ; $B97A: 29 02
  BEQ @CheckConfirm                     ; $B97C: F0 0D
  LDA #$00                              ; $B97E: A9 00
  STA $0501                             ; $B980: 8D 01 05
  LDA #$00                              ; $B983: A9 00
  STA $0500                             ; $B985: 8D 00 05
  JMP FinishSequence                       ; $B988: 4C F7 A1
@CheckConfirm:
  LDA $81                               ; $B98B: A5 81
  AND #$01                              ; $B98D: 29 01
  BEQ @Done                             ; $B98F: F0 24
  INC $0501                             ; $B991: EE 01 05
  LDA #$D7                              ; $B994: A9 D7
  JSR B1F_SetUI2                        ; $B996: 20 83 F2
  LDA #$00                              ; $B999: A9 00
  STA menu_cursor_col                             ; $B99B: 8D 24 04
  STA menu_cursor_page                             ; $B99E: 8D 25 04
  JSR ProvinceSelect_InitList            ; $B9A1: 20 84 BB
  LDA $050A                             ; $B9A4: AD 0A 05
  CMP #$FF                              ; $B9A7: C9 FF
  BNE @Done                             ; $B9A9: D0 0A
  LDA #$05                              ; $B9AB: A9 05
  STA $0501                             ; $B9AD: 8D 01 05
  LDA #$D9                              ; $B9B0: A9 D9
  JSR B1F_SetUI2                        ; $B9B2: 20 83 F2
@Done:
  RTS                                   ; $B9B5: 60
.endproc

.proc ProvinceState_Menu
  JSR TryAutoAdvance                       ; $B9B6: 20 DE A1
  LDA $050A                             ; $B9B9: AD 0A 05
  ASL                                   ; $B9BC: 0A
  TAY                                   ; $B9BD: A8
  LDA MenuTypeItemListPtrs,Y            ; $B9BE: B9 9F BA
  STA $10                               ; $B9C1: 85 10
  LDA MenuTypeItemListPtrs+1,Y          ; $B9C3: B9 A0 BA
  STA $11                               ; $B9C6: 85 11
  LDA #$00                              ; $B9C8: A9 00
  STA $12                               ; $B9CA: 85 12
  JSR B1F_MenuStep2                     ; $B9CC: 20 1E ED
  LDA #<MenuSlotPPUAddrs                ; $B9CF: A9 6F
  STA $10                               ; $B9D1: 85 10
  LDA #>MenuSlotPPUAddrs                ; $B9D3: A9 BB
  STA $11                               ; $B9D5: 85 11
  LDA #<MenuSlotConfig                  ; $B9D7: A9 7F
  STA $00                               ; $B9D9: 85 00
  LDA #>MenuSlotConfig                  ; $B9DB: A9 BB
  STA $01                               ; $B9DD: 85 01
  LDA $12                               ; $B9DF: A5 12
  JSR B1F_PointerTableLookup            ; $B9E1: 20 F5 ED
  JSR CheckExchangePossible                             ; $B9E4: 20 27 DF
  BCC @Done                             ; $B9E7: 90 CC
  LDA $81                               ; $B9E9: A5 81
  AND #$02                              ; $B9EB: 29 02
  BEQ @CheckConfirm                     ; $B9ED: F0 0D
  LDA #$00                              ; $B9EF: A9 00
  STA $0501                             ; $B9F1: 8D 01 05
  LDA #$00                              ; $B9F4: A9 00
  STA $0500                             ; $B9F6: 8D 00 05
  JMP FinishSequence                       ; $B9F9: 4C F7 A1
@CheckConfirm:
  LDA $81                               ; $B9FC: A5 81
  AND #$01                              ; $B9FE: 29 01
  BEQ @Done                             ; $BA00: F0 17
  LDY $12                               ; $BA02: A4 12
  LDA officer_sel_list,Y                           ; $BA04: B9 2C 04
  STA $050B                             ; $BA07: 8D 0B 05
  JSR ProvinceSelect_CheckSlot           ; $BA0A: 20 11 BC
  BCC @AdvanceState                     ; $BA0D: 90 0B
  LDA #$01                              ; $BA0F: A9 01
  STA $0501                             ; $BA11: 8D 01 05
  LDA #$DA                              ; $BA14: A9 DA
  JSR B1F_SetUI2                        ; $BA16: 20 83 F2
@Done:
  RTS                                   ; $BA19: 60
@AdvanceState:
  INC $0501                             ; $BA1A: EE 01 05
  LDA $0509                             ; $BA1D: AD 09 05
  BEQ @ShowFullUI                       ; $BA20: F0 04
  CMP #$0A                              ; $BA22: C9 0A
  BNE @ShowMenuUI                       ; $BA24: D0 05
@ShowFullUI:
  LDA #$52                              ; $BA26: A9 52
  JMP B1F_SetUI2                        ; $BA28: 4C 83 F2
@ShowMenuUI:
  LDA #$C8                              ; $BA2B: A9 C8
  JMP B1F_SetUI2                        ; $BA2D: 4C 83 F2
.endproc

.proc ProvinceState_Confirm
  JSR DrawExchangeArrows_Left                             ; $BA30: 20 70 DC
  JSR TryAutoAdvance                       ; $BA33: 20 DE A1
  JSR CheckExchangePossible                             ; $BA36: 20 27 DF
  BCC @Done                             ; $BA39: 90 28
  LDA $81                               ; $BA3B: A5 81
  AND #$02                              ; $BA3D: 29 02
  BEQ @CheckConfirm                     ; $BA3F: F0 0D
  LDA #$00                              ; $BA41: A9 00
  STA $0501                             ; $BA43: 8D 01 05
  LDA #$00                              ; $BA46: A9 00
  STA $0500                             ; $BA48: 8D 00 05
  JMP FinishSequence                       ; $BA4B: 4C F7 A1
@CheckConfirm:
  LDA $81                               ; $BA4E: A5 81
  AND #$01                              ; $BA50: 29 01
  BEQ @Done                             ; $BA52: F0 0F
  INC $0501                             ; $BA54: EE 01 05
  LDA #$00                              ; $BA57: A9 00
  STA $12                               ; $BA59: 85 12
  JSR UpdateCursorTile                             ; $BA5B: 20 CC D6
  LDA #$D8                              ; $BA5E: A9 D8
  JSR B1F_SetUI5                        ; $BA60: 20 93 F2
@Done:
  RTS                                   ; $BA63: 60
.endproc

.proc ProvinceState_Cancel
  JSR CheckExchangePossible                             ; $BA64: 20 27 DF
  BCC @Done                             ; $BA67: 90 19
  JSR DrawExchangeArrows_Left                             ; $BA69: 20 70 DC
  LDA $81                               ; $BA6C: A5 81
  AND #$01                              ; $BA6E: 29 01
  BEQ @Done                             ; $BA70: F0 10
  JSR ProvinceSelect_RemoveOfficer       ; $BA72: 20 2A BC
  LDA #$00                              ; $BA75: A9 00
  STA $0501                             ; $BA77: 8D 01 05
  LDA #$00                              ; $BA7A: A9 00
  STA $0500                             ; $BA7C: 8D 00 05
  JMP FinishSequence                       ; $BA7F: 4C F7 A1
@Done:
  RTS                                   ; $BA82: 60
.endproc

.proc ProvinceState_Reset
  JSR CheckExchangePossible                             ; $BA83: 20 27 DF
  BCC @Done                             ; $BA86: 90 16
  JSR DrawExchangeArrows_Left                             ; $BA88: 20 70 DC
  LDA $81                               ; $BA8B: A5 81
  AND #$01                              ; $BA8D: 29 01
  BEQ @Done                             ; $BA8F: F0 0D
  LDA #$00                              ; $BA91: A9 00
  STA $0501                             ; $BA93: 8D 01 05
  LDA #$00                              ; $BA96: A9 00
  STA $0500                             ; $BA98: 8D 00 05
  JMP FinishSequence                       ; $BA9B: 4C F7 A1
@Done:
  RTS                                   ; $BA9E: 60
.endproc
; --- Menu System Data ---

; Pointer table: maps menu type index (0-15) to its item index list.
; Type N has (16-N) valid item indices, padded with $FF terminators.
; Used by CommandState_Menu ($0542), ProvinceState_Menu ($050A), and
; province select callbacks at $CDFA and $D353.
MenuTypeItemListPtrs:                     ; $BA9F
  .word MenuItemIndexPool00               ; type  0:  1 item
  .word MenuItemIndexPool01               ; type  1:  2 items
  .word MenuItemIndexPool02               ; type  2:  3 items
  .word MenuItemIndexPool03               ; type  3:  4 items
  .word MenuItemIndexPool04               ; type  4:  5 items
  .word MenuItemIndexPool05               ; type  5:  6 items
  .word MenuItemIndexPool06               ; type  6:  7 items
  .word MenuItemIndexPool07               ; type  7:  8 items
  .word MenuItemIndexPool08               ; type  8:  9 items
  .word MenuItemIndexPool09               ; type  9: 10 items
  .word MenuItemIndexPool0A               ; type 10: 11 items
  .word MenuItemIndexPool0B               ; type 11: 12 items
  .word MenuItemIndexPool0C               ; type 12: 13 items
  .word MenuItemIndexPool0D               ; type 13: 14 items
  .word MenuItemIndexPool0E               ; type 14: 15 items
  .word MenuItemIndexPool0F               ; type 15: 16 items

; Menu item index lists: each contains sequential indices 0..N-1 followed
; by $FF padding. Pieces are laid out in ascending address order.
MenuItemIndexPool0F:                      ; $BABF: 16 items
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F; $BABF: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
MenuItemIndexPool0D:                      ; $BAD1: 14 items + 2 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$FF,$FF; $BAD1: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D FF FF
MenuItemIndexPool0B:                      ; $BAE1: 12 items + 2 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$FF,$FF; $BAE1: 00 01 02 03 04 05 06 07 08 09 0A 0B FF FF
MenuItemIndexPool09:                      ; $BAEF: 10 items + 2 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$FF,$FF; $BAEF: 00 01 02 03 04 05 06 07 08 09 FF FF
MenuItemIndexPool07:                      ; $BAFB: 8 items + 4 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$FF,$FF; $BAFB: 00 01 02 03 04 05 06 07 FF FF
MenuItemIndexPool05:                      ; $BB05: 6 items + 2 pad
  .byte $00,$01,$02,$03,$04,$05,$FF,$FF; $BB05: 00 01 02 03 04 05 FF FF
MenuItemIndexPool03:                      ; $BB0D: 4 items + 2 pad
  .byte $00,$01,$02,$03,$FF,$FF; $BB0D: 00 01 02 03 FF FF
MenuItemIndexPool01:                      ; $BB13: 2 items + 2 pad
  .byte $00,$01,$FF,$FF; $BB13: 00 01 FF FF
MenuItemIndexPool0E:                      ; $BB17: 15 items + 3 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$FF; $BB17: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E FF
  .byte $FF,$FF; $BB27: FF FF
MenuItemIndexPool0C:                      ; $BB29: 13 items + 3 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$FF,$FF,$FF; $BB29: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C FF FF FF
MenuItemIndexPool0A:                      ; $BB39: 11 items + 3 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$FF,$FF,$FF; $BB39: 00 01 02 03 04 05 06 07 08 09 0A FF FF FF
MenuItemIndexPool08:                      ; $BB47: 9 items + 3 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$FF,$FF,$FF; $BB47: 00 01 02 03 04 05 06 07 08 FF FF FF
MenuItemIndexPool06:                      ; $BB53: 7 items + 3 pad
  .byte $00,$01,$02,$03,$04,$05,$06,$FF,$FF,$FF; $BB53: 00 01 02 03 04 05 06 FF FF FF
MenuItemIndexPool04:                      ; $BB5D: 5 items + 3 pad
  .byte $00,$01,$02,$03,$04,$FF,$FF,$FF; $BB5D: 00 01 02 03 04 FF FF FF
MenuItemIndexPool02:                      ; $BB65: 3 items + 3 pad
  .byte $00,$01,$02,$FF,$FF,$FF; $BB65: 00 01 02 FF FF FF
MenuItemIndexPool00:                      ; $BB6B: 1 item + 3 pad
  .byte $00,$FF,$FF,$FF; $BB6B: 00 FF FF FF

; PPU nametable addresses for menu cursor slot positions (4 rows x 2 cols).
; Row stride = $10, column stride = $50.
MenuSlotPPUAddrs:                         ; $BB6F
  .word $48A6, $98A6                      ; row 0: col 0, col 1
  .word $48B6, $98B6                      ; row 1: col 0, col 1
  .word $48C6, $98C6                      ; row 2: col 0, col 1
  .word $48D6, $98D6                      ; row 3: col 0, col 1

; Menu slot rendering configuration parameters
MenuSlotConfig:                           ; $BB7F
  .byte $00,$07,$00,$00,$80

.proc ProvinceSelect_InitList
  LDA #$FF                              ; $BB84: A9 FF
  STA $050A                             ; $BB86: 8D 0A 05
  LDY #$3F                              ; $BB89: A0 3F
  LDA #$FF                              ; $BB8B: A9 FF
@ClearLoop1:
  STA officer_sel_list,Y                           ; $BB8D: 99 2C 04
  DEY                                   ; $BB90: 88
  BPL @ClearLoop1                       ; $BB91: 10 FA
  LDY #$0F                              ; $BB93: A0 0F
  LDA #$FF                              ; $BB95: A9 FF
@ClearLoop2:
  STA $0550,Y                           ; $BB97: 99 50 05
  DEY                                   ; $BB9A: 88
  BPL @ClearLoop2                       ; $BB9B: 10 FA
  LDA $0507                             ; $BB9D: AD 07 05
  LDY $0504                             ; $BBA0: AC 04 05
  BPL @GetRuler                         ; $BBA3: 10 04
  LSR                                   ; $BBA5: 4A
  LSR                                   ; $BBA6: 4A
  LSR                                   ; $BBA7: 4A
  LSR                                   ; $BBA8: 4A
@GetRuler:
  AND #$0F                              ; $BBA9: 29 0F
  STA $02                               ; $BBAB: 85 02
  LDY #$30                              ; $BBAD: A0 30
  JSR B1F_SwitchBank8_B                 ; $BBAF: 20 5F F2
  LDA $050E                             ; $BBB2: AD 0E 05
  ASL                                   ; $BBB5: 0A
  ASL                                   ; $BBB6: 0A
  ASL                                   ; $BBB7: 0A
  TAY                                   ; $BBB8: A8
  LDX #$00                              ; $BBB9: A2 00
@ScanLoop:
  LDA $9D72,Y                           ; $BBBB: B9 72 9D
  BMI @Done                             ; $BBBE: 30 48
  STA $03                               ; $BBC0: 85 03
  STY $04                               ; $BBC2: 84 04
  JSR B1F_GetProvinceRecordAddr         ; $BBC4: 20 AF F2
  LDY #$00                              ; $BBC7: A0 00
  LDA ($00),Y                           ; $BBC9: B1 00
  AND #$07                              ; $BBCB: 29 07
  CMP #$07                              ; $BBCD: C9 07
  BEQ @AddProvince                      ; $BBCF: F0 04
  CMP $02                               ; $BBD1: C5 02
  BNE @NextProvince                     ; $BBD3: D0 2B
@AddProvince:
  TXA                                   ; $BBD5: 8A
  PHA                                   ; $BBD6: 48
  INC $050A                             ; $BBD7: EE 0A 05
  LDY $050A                             ; $BBDA: AC 0A 05
  LDA $03                               ; $BBDD: A5 03
  STA officer_sel_list,Y                           ; $BBDF: 99 2C 04
  JSR ProvinceSelect_GetRecord           ; $BBE2: 20 14 BC
  LDY $050A                             ; $BBE5: AC 0A 05
  LDA ProvinceSelect_SlotRecordOffsets,Y   ; $BBE8: B9 09 BC
  TAY                                   ; $BBEB: A8
  LDA #$00                              ; $BBEC: A9 00
  STA officer_sel_list+1,Y                           ; $BBEE: 99 2D 04
  STA officer_sel_list+2,Y                           ; $BBF1: 99 2E 04
  TXA                                   ; $BBF4: 8A
  STA officer_sel_list,Y                           ; $BBF5: 99 2C 04
  LDY $050A                             ; $BBF8: AC 0A 05
  STA $0550,Y                           ; $BBFB: 99 50 05
  PLA                                   ; $BBFE: 68
  TAX                                   ; $BBFF: AA
@NextProvince:
  LDY $04                               ; $BC00: A4 04
  INY                                   ; $BC02: C8
  INX                                   ; $BC03: E8
  CPX #$08                              ; $BC04: E0 08
  BCC @ScanLoop                         ; $BC06: 90 B3
@Done:
  RTS                                   ; $BC08: 60
.endproc
; Province slot-to-record offset table (stride 3, indexed by slot 0-7)
ProvinceSelect_SlotRecordOffsets:
  .byte $20,$23,$26,$29,$2C,$2F,$32,$35   ; $BC09: 20 23 26 29 2C 2F 32 35

.proc ProvinceSelect_CheckSlot
  LDA $050B                             ; $BC11: AD 0B 05
ProvinceSelect_GetRecord:
  JSR B1F_GetProvinceRecordAddr         ; $BC14: 20 AF F2
  LDY #$11                              ; $BC17: A0 11
  LDX #$00                              ; $BC19: A2 00
@ScanLoop:
  LDA ($00),Y                           ; $BC1B: B1 00
  CMP #$FF                              ; $BC1D: C9 FF
  BEQ @Success                          ; $BC1F: F0 07
  INX                                   ; $BC21: E8
  INY                                   ; $BC22: C8
  CPY #$1B                              ; $BC23: C0 1B
  BCC @ScanLoop                         ; $BC25: 90 F4
  RTS                                   ; $BC27: 60
@Success:
  CLC                                   ; $BC28: 18
  RTS                                   ; $BC29: 60
.endproc

.proc ProvinceSelect_RemoveOfficer
  JSR $C91E                             ; $BC2A: 20 1E C9
  JSR ProvinceSelect_CheckSlot           ; $BC2D: 20 11 BC
  LDX $0509                             ; $BC30: AE 09 05
  BEQ @StoreOfficer                     ; $BC33: F0 04
  CPX #$0A                              ; $BC35: E0 0A
  BNE @SkipStore                        ; $BC37: D0 0C
@StoreOfficer:
  LDA $0664,X                           ; $BC39: BD 64 06
  STA $052B                             ; $BC3C: 8D 2B 05
  LDA $050B                             ; $BC3F: AD 0B 05
  STA $052C                             ; $BC42: 8D 2C 05
@SkipStore:
  LDA $0664,X                           ; $BC45: BD 64 06
  STA ($00),Y                           ; $BC48: 91 00
  LDA #$FF                              ; $BC4A: A9 FF
  STA $0600,X                           ; $BC4C: 9D 00 06
  STA $0614,X                           ; $BC4F: 9D 14 06
  STA $0628,X                           ; $BC52: 9D 28 06
  STA $063C,X                           ; $BC55: 9D 3C 06
  STA $0650,X                           ; $BC58: 9D 50 06
  STA $0664,X                           ; $BC5B: 9D 64 06
  CPX army_slot_base                             ; $BC5E: EC D8 04
  BNE @CheckSlot2                       ; $BC61: D0 03
  STA army_slot_base                             ; $BC63: 8D D8 04
@CheckSlot2:
  CPX army_slot_base+4                             ; $BC66: EC DC 04
  BNE @CheckProvince                    ; $BC69: D0 03
  STA army_slot_base+4                             ; $BC6B: 8D DC 04
@CheckProvince:
  LDY #$00                              ; $BC6E: A0 00
  LDA ($00),Y                           ; $BC70: B1 00
  AND #$07                              ; $BC72: 29 07
  CMP #$07                              ; $BC74: C9 07
  BNE @Done                             ; $BC76: D0 1A
  LDA $0507                             ; $BC78: AD 07 05
  LDY $0504                             ; $BC7B: AC 04 05
  BPL @GetRuler                         ; $BC7E: 10 04
  LSR                                   ; $BC80: 4A
  LSR                                   ; $BC81: 4A
  LSR                                   ; $BC82: 4A
  LSR                                   ; $BC83: 4A
@GetRuler:
  AND #$0F                              ; $BC84: 29 0F
  STA $02                               ; $BC86: 85 02
  LDY #$00                              ; $BC88: A0 00
  LDA ($00),Y                           ; $BC8A: B1 00
  AND #$F0                              ; $BC8C: 29 F0
  ORA $02                               ; $BC8E: 05 02
  STA ($00),Y                           ; $BC90: 91 00
@Done:
  RTS                                   ; $BC92: 60
.endproc

.proc OfficerTurnDispatch
  ; (dispatch callback target)
  LDA $0501                             ; $BC93: AD 01 05
  CMP #$04                              ; $BC96: C9 04
  BCS @SkipReset                        ; $BC98: B0 03
  JSR CenterMapOnOfficer                             ; $BC9A: 20 33 DC
@SkipReset:
  LDA $0501                             ; $BC9D: AD 01 05
  JSR B1F_CallbackDispatcher            ; $BCA0: 20 DE EA
; --- CallbackDispatcher table (8 entries) ---
  .word OfficerTurnState_Init               ; $BCA3: $B3 BC
  .word OfficerTurnState_Select             ; $BCA5: $C1 BC
  .word OfficerTurnState_Confirm            ; $BCA7: $F6 BC
  .word OfficerTurnState_Reset              ; $BCA9: $13 BD
  .word OfficerTurnState_Next               ; $BCAB: $2C BD
  .word OfficerTurnState_Execute            ; $BCAD: $41 BD
  .word OfficerTurnState_Cancel             ; $BCAF: $6F BD
  .word OfficerTurnState_EndTurn            ; $BCB1: $ED BC
.endproc

.proc OfficerTurnState_Init
  LDA #$00                              ; $BCB3: A9 00
  STA $00A4                             ; $BCB5: 8D A4 00
  LDA #$CA                              ; $BCB8: A9 CA
  JSR B1F_SetUI2                        ; $BCBA: 20 83 F2
  INC $0501                             ; $BCBD: EE 01 05
  RTS                                   ; $BCC0: 60
.endproc

.proc OfficerTurnState_Select
  JSR CheckExchangePossible                             ; $BCC1: 20 27 DF
  BCC @Done                             ; $BCC4: 90 26
  JSR DrawExchangeArrows_Right                             ; $BCC6: 20 63 DC
  LDA $81                               ; $BCC9: A5 81
  AND #$02                              ; $BCCB: 29 02
  BEQ @CheckConfirm                     ; $BCCD: F0 0D
  LDA #$00                              ; $BCCF: A9 00
  STA $0501                             ; $BCD1: 8D 01 05
  LDA #$00                              ; $BCD4: A9 00
  STA $0500                             ; $BCD6: 8D 00 05
  JMP FinishSequence                       ; $BCD9: 4C F7 A1
@CheckConfirm:
  LDA $81                               ; $BCDC: A5 81
  AND #$01                              ; $BCDE: 29 01
  BEQ @Done                             ; $BCE0: F0 0A
  LDA #$07                              ; $BCE2: A9 07
  STA $0501                             ; $BCE4: 8D 01 05
  LDA #$05                              ; $BCE7: A9 05
  JSR B1F_SetUI5                        ; $BCE9: 20 93 F2
@Done:
  RTS                                   ; $BCEC: 60
.endproc

.proc OfficerTurnState_EndTurn
  JSR CheckExchangePossible                             ; $BCED: 20 27 DF
  BCC @Done                             ; $BCF0: 90 03
  JMP OfficerTurn_EndTurn               ; $BCF2: 4C C0 BD
@Done:
  RTS                                   ; $BCF5: 60
.endproc

.proc OfficerTurnState_Confirm
  LDY #$3D                              ; $BCF6: A0 3D
  JSR B1F_BankedCallbackTrampoline      ; $BCF8: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A027                               ; $BCFB: $27 A0
  LDA officer_sel_list                                   ; $BCFD: AD 2C 04
  JSR B1F_GetRulerDataPtr                     ; $BD00: 20 68 F3
  LDY #$00                                    ; $BD03: A0 00
  LDA ($00),Y                                 ; $BD05: B1 00
  STA officer_sel_list                                   ; $BD07: 8D 2C 04
  INC $0501                                   ; $BD0A: EE 01 05
  LDA $050A                                   ; $BD0D: AD 0A 05
  JMP B1F_SetUI5                              ; $BD10: 4C 83 F2
.endproc

.proc OfficerTurnState_Reset
  JSR CheckExchangePossible                             ; $BD13: 20 27 DF
  BCC @Done                             ; $BD16: 90 13
  JSR DrawExchangeArrows_Right                             ; $BD18: 20 63 DC
  LDA $81                               ; $BD1B: A5 81
  AND #$03                              ; $BD1D: 29 03
  BEQ @Done                             ; $BD1F: F0 0A
  LDA #$0C                              ; $BD21: A9 0C
  STA $0500                             ; $BD23: 8D 00 05
  LDA #$00                              ; $BD26: A9 00
  STA $0501                             ; $BD28: 8D 01 05
@Done:
  RTS                                   ; $BD2B: 60
.endproc

.proc OfficerTurnState_Next
  LDA #$01                              ; $BD2C: A9 01
  STA $12                               ; $BD2E: 85 12
  JSR UpdateCursorTile                             ; $BD30: 20 CC D6
  INC $0509                             ; $BD33: EE 09 05
  LDA $0509                             ; $BD36: AD 09 05
  CMP #$14                              ; $BD39: C9 14
  BCC @Done                             ; $BD3B: 90 03
  INC $0501                             ; $BD3D: EE 01 05
@Done:
  RTS                                   ; $BD40: 60
.endproc

.proc OfficerTurnState_Execute
  LDA $052E                             ; $BD41: AD 2E 05
  BNE @CheckAlly                        ; $BD44: D0 03
  JSR OfficerTurn_RestoreAndExit        ; $BD46: 4C 97 BD
  RTS
@CheckAlly:
  LDY $052F                             ; $BD49: AC 2F 05
  LDA $6FA1,Y                           ; $BD4C: B9 A1 6F
  CMP #$FF                              ; $BD4F: C9 FF
  BEQ @SetupConfirm                     ; $BD51: F0 03
  JSR OfficerTurn_RestoreAndExit        ; $BD53: 4C 97 BD
  RTS
@SetupConfirm:
  LDA #$6D                              ; $BD56: A9 6D
  STA officer_sel_list                             ; $BD58: 8D 2C 04
  JSR ValidateExchangeOfficer                             ; $BD5B: 20 E9 DE
  BCS @ConfirmOk                        ; $BD5E: B0 03
  JSR OfficerTurn_RestoreAndExit        ; $BD60: 4C 97 BD
  RTS
@ConfirmOk:
  INC $0501                             ; $BD63: EE 01 05
  JSR B1F_BankPpuInit                   ; $BD66: 20 7F E5
  LDA #$7B                              ; $BD69: A9 7B
  JSR B1F_SoundWrapperD                 ; $BD6B: 20 8B E6
  RTS                                   ; $BD6E: 60
.endproc

.proc OfficerTurnState_Cancel
  JSR CheckExchangePossible                             ; $BD6F: 20 27 DF
  BCC @Done                             ; $BD72: 90 1A
  JSR DrawExchangeArrows_Right                             ; $BD74: 20 63 DC
  LDA $81                               ; $BD77: A5 81
  AND #$03                              ; $BD79: 29 03
  BEQ @Done                             ; $BD7B: F0 11
  LDA officer_sel_list+1                             ; $BD7D: AD 2D 04
  CMP #$FF                              ; $BD80: C9 FF
  BEQ @ExitToIdle                       ; $BD82: F0 0B
  LDA #$FF                              ; $BD84: A9 FF
  STA officer_sel_list+1                             ; $BD86: 8D 2D 04
  LDA #$4B                              ; $BD89: A9 4B
  JMP B1F_SetUI5                        ; $BD8B: 4C 93 F2
@Done:
  RTS                                   ; $BD8E: 60
@ExitToIdle:
  JSR B1F_BankPpuInit                   ; $BD8F: 20 7F E5
  LDA #$1D                              ; $BD92: A9 1D
  JSR B1F_SoundWrapperA                 ; $BD94: 20 73 E6
  JSR OfficerTurn_RestoreAndExit        ; $BD97: AD 70 04
  RTS
.endproc

.proc OfficerTurn_RestoreAndExit
  LDA anim_ppu_ptr_lo                             ; $BD97: AD 70 04
  STA $00                               ; $BD9A: 85 00
  LDA anim_ppu_ptr_hi                             ; $BD9C: AD 71 04
  STA $02                               ; $BD9F: 85 02
  JSR TileToPixelCoord                             ; $BDA1: 20 5A DA
  LDA $00                               ; $BDA4: A5 00
  STA $6F3F                             ; $BDA6: 8D 3F 6F
  LDA $01                               ; $BDA9: A5 01
  STA $6F40                             ; $BDAB: 8D 40 6F
  LDA $02                               ; $BDAE: A5 02
  STA $6F41                             ; $BDB0: 8D 41 6F
  LDA $03                               ; $BDB3: A5 03
  STA $6F42                             ; $BDB5: 8D 42 6F
  LDA #$05                              ; $BDB8: A9 05
  JSR B1F_SetUI5                        ; $BDBA: 20 93 F2
  JMP ResetToIdle                          ; $BDBD: 4C 0C A2
.endproc

.proc OfficerTurn_EndTurn
  LDA $0505                             ; $BDC0: AD 05 05
  BPL @ClearState                       ; $BDC3: 10 05
  LDA #$00                              ; $BDC5: A9 00
  STA $0505                             ; $BDC7: 8D 05 05
@ClearState:
  LDA #$00                              ; $BDCA: A9 00
  STA $6F94                             ; $BDCC: 8D 94 6F
  STA $6F95                             ; $BDCF: 8D 95 6F
  STA $6F96                             ; $BDD2: 8D 96 6F
  STA $052C                             ; $BDD5: 8D 2C 05
  STA $052E                             ; $BDD8: 8D 2E 05
  LDA $0504                             ; $BDDB: AD 04 05
  EOR #$80                              ; $BDDE: 49 80
  STA $0504                             ; $BDE0: 8D 04 05
  AND #$80                              ; $BDE3: 29 80
  BEQ OfficerTurn_SwitchRuler           ; $BDE5: F0 4C
  LDA $0507                             ; $BDE7: AD 07 05
  LSR                                   ; $BDEA: 4A
  LSR                                   ; $BDEB: 4A
  LSR                                   ; $BDEC: 4A
  LSR                                   ; $BDED: 4A
  JSR B1F_GetRulerDataPtr               ; $BDEE: 20 68 F3
  LDY #$03                              ; $BDF1: A0 03
  LDA ($00),Y                           ; $BDF3: B1 00
  STA $050F                             ; $BDF5: 8D 0F 05
  LDA $0505                             ; $BDF8: AD 05 05
  STA $050C                             ; $BDFB: 8D 0C 05
  JSR ComputeArmyMorale                 ; $BDFE: 20 A0 C5
  INC $0506                             ; $BE01: EE 06 05
  LDA $050D                             ; $BE04: AD 0D 05
  STA $0505                             ; $BE07: 8D 05 05
  LDY #$28                              ; $BE0A: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $BE0C: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A00F                               ; $BE0F: $0F A0
  LDA $050A                                   ; $BE11: AD 0A 05
  BEQ @SkipRestore                      ; $BE14: F0 0B
  LDA #$07                                    ; $BE16: A9 07
  STA $0500                                   ; $BE18: 8D 00 05
  LDA #$02                                    ; $BE1B: A9 02
  STA $0501                                   ; $BE1D: 8D 01 05
@Done:
  RTS                                   ; $BE20: 60
@SkipRestore:
  JSR CalcOfficerMeritLevels              ; $BE21: 20 03 DB
  LDA $060A                             ; $BE24: AD 0A 06
  STA anim_ppu_ptr_lo                             ; $BE27: 8D 70 04
  LDA $061E                             ; $BE2A: AD 1E 06
  STA anim_ppu_ptr_hi                             ; $BE2D: 8D 71 04
  JMP OfficerTurn_SwitchRuler_CheckPhase ; $BE30: 4C 5A BE
.endproc

.proc OfficerTurn_SwitchRuler
  LDA $0507                             ; $BE33: AD 07 05
  AND #$0F                              ; $BE36: 29 0F
  JSR B1F_GetRulerDataPtr               ; $BE38: 20 68 F3
  LDY #$03                              ; $BE3B: A0 03
  LDA ($00),Y                           ; $BE3D: B1 00
  STA $050F                             ; $BE3F: 8D 0F 05
  LDA $0505                             ; $BE42: AD 05 05
  STA $050D                             ; $BE45: 8D 0D 05
  LDA $050C                             ; $BE48: AD 0C 05
  STA $0505                             ; $BE4B: 8D 05 05
  LDA $0600                             ; $BE4E: AD 00 06
  STA anim_ppu_ptr_lo                             ; $BE51: 8D 70 04
  LDA $0614                             ; $BE54: AD 14 06
  STA anim_ppu_ptr_hi                             ; $BE57: 8D 71 04
OfficerTurn_SwitchRuler_CheckPhase:
  LDA $050F                             ; $BE5A: AD 0F 05
  CMP #$03                              ; $BE5D: C9 03
  BEQ @CallTrampoline                   ; $BE5F: F0 06
  STA $6F44                             ; $BE61: 8D 44 6F
  JMP @Continue                         ; $BE64: 4C 6E BE
@CallTrampoline:
  LDY #$28                              ; $BE67: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $BE69: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A00C                               ; $BE6C: $0C A0
@Continue:
  LDA #$04                              ; $BE6E: A9 04
  STA $0501                             ; $BE70: 8D 01 05
  LDA #$07                              ; $BE73: A9 07
  STA $0500                             ; $BE75: 8D 00 05
  LDA #$00                              ; $BE78: A9 00
  STA $0509                             ; $BE7A: 8D 09 05
  RTS                                   ; $BE7D: 60
.endproc

.proc OfficerMarchDispatch
  ; (dispatch callback target)
  LDA $0501                             ; $BE7E: AD 01 05
  JSR B1F_CallbackDispatcher            ; $BE81: 20 DE EA
; --- CallbackDispatcher table (17 entries) ---
  .word @Init                               ; $BE84: $A6 BE
  .word @SelectOfficer                      ; $BE86: $BA BE
  .word @DispatchPhase                      ; $BE88: $01 BF
  .word @ApplyMovement                      ; $BE8A: $19 BF
  .word @FinishMove                         ; $BE8C: $7C BF
  .word @AnimateMove                        ; $BE8E: $98 BF
  .word @WaitConfirm                        ; $BE90: $B8 BF
  .word @EnterBattle                        ; $BE92: $DC BF
  .word @ShowCost                           ; $BE94: $04 C0
  .word @NextOfficer                        ; $BE96: $54 C0
  .word @ShowResult                         ; $BE98: $7D C0
  .word @CancelAction                       ; $BE9A: $10 C1
  .word @ResetWait                          ; $BE9C: $3B C1
  .word @SelectTarget                       ; $BE9E: $49 C1
  .word @ConfirmAction                      ; $BEA0: $78 C1
  .word @CancelWait                         ; $BEA2: $D1 C1
  .word @Exit                               ; $BEA4: $EB C1
@Init:
  LDA $0087                             ; $BEA6: AD 87 00
  BPL @Done                             ; $BEA9: 10 0E
  LDA #$00                              ; $BEAB: A9 00
  STA $6F8B                             ; $BEAD: 8D 8B 6F
  STA $6F8D                             ; $BEB0: 8D 8D 6F
  STA $6F8E                             ; $BEB3: 8D 8E 6F
  INC $0501                             ; $BEB6: EE 01 05
@Done:
  RTS                                   ; $BEB9: 60
@SelectOfficer:
  LDA $6F8B                             ; $BEBA: AD 8B 6F
  CMP #$FF                              ; $BEBD: C9 FF
  BNE @Done                             ; $BEBF: D0 3F
  LDA $6F8F                             ; $BEC1: AD 8F 6F
  CMP #$03                              ; $BEC4: C9 03
  BEQ @AdvanceState                     ; $BEC6: F0 35
  LDA $6F8C                             ; $BEC8: AD 8C 6F
  STA $0509                             ; $BECB: 8D 09 05
  TAY                                   ; $BECE: A8
  LDA $0600,Y                           ; $BECF: B9 00 06
  STA $00                               ; $BED2: 85 00
  LDA $0614,Y                           ; $BED4: B9 14 06
  STA $02                               ; $BED7: 85 02
  JSR TileToPixelCoord                             ; $BED9: 20 5A DA
  LDA $00                               ; $BEDC: A5 00
  STA $6F3F                             ; $BEDE: 8D 3F 6F
  LDA $01                               ; $BEE1: A5 01
  STA $6F40                             ; $BEE3: 8D 40 6F
  LDA $02                               ; $BEE6: A5 02
  STA $6F41                             ; $BEE8: 8D 41 6F
  LDA $03                               ; $BEEB: A5 03
  STA $6F42                             ; $BEED: 8D 42 6F
  JSR MapScroll_Update                             ; $BEF0: 20 EE D5
  LDA $0508                             ; $BEF3: AD 08 05
  BNE @Done                             ; $BEF6: D0 08
  LDA $007E                             ; $BEF8: AD 7E 00
  BNE @Done                             ; $BEFB: D0 03
@AdvanceState:
  INC $0501                             ; $BEFD: EE 01 05
@SelectDone:
  RTS                                   ; $BF00: 60
@DispatchPhase:
  LDY $6F8F                             ; $BF01: AC 8F 6F
  LDA @DispatchTable,Y                  ; $BF04: B9 14 BF
  STA $0501                             ; $BF07: 8D 01 05
  CMP #$0C                              ; $BF0A: C9 0C
  BNE @DispatchDone                     ; $BF0C: D0 05
  LDA #$05                              ; $BF0E: A9 05
  JSR B1F_SetUI5                        ; $BF10: 20 93 F2
@DispatchDone:
  RTS                                   ; $BF13: 60
; Dispatch table for phase transitions
@DispatchTable:
  .byte $03,$05,$08,$0C,$0D               ; $BF14: 03 05 08 0C 0D
@ApplyMovement:
  LDA $007E                             ; $BF19: AD 7E 00
  BEQ @InitMovement                     ; $BF1C: F0 01
  RTS                                   ; $BF1E: 60
@InitMovement:
  LDA #$00                              ; $BF1F: A9 00
  STA $12                               ; $BF21: 85 12
  JSR UpdateCursorTile                             ; $BF23: 20 CC D6
  LDA #$00                              ; $BF26: A9 00
  STA $00                               ; $BF28: 85 00
  STA $01                               ; $BF2A: 85 01
  LDA #$01                              ; $BF2C: A9 01
  STA $02                               ; $BF2E: 85 02
  LDA $6F8D                             ; $BF30: AD 8D 6F
  AND #$01                              ; $BF33: 29 01
  BNE @ApplyMove                        ; $BF35: D0 04
  LDA #$FF                              ; $BF37: A9 FF
  STA $02                               ; $BF39: 85 02
@ApplyMove:
  LDA $6F8D                             ; $BF3B: AD 8D 6F
  LSR                                   ; $BF3E: 4A
  AND #$01                              ; $BF3F: 29 01
  EOR #$01                              ; $BF41: 49 01
  TAX                                   ; $BF43: AA
  LDA $02                               ; $BF44: A5 02
  STA $0000,X                           ; $BF46: 9D 00 00
  LDY $0509                             ; $BF49: AC 09 05
  LDA $0600,Y                           ; $BF4C: B9 00 06
  CLC                                   ; $BF4F: 18
  ADC $00                               ; $BF50: 65 00
  STA $0600,Y                           ; $BF52: 99 00 06
  LDA $0614,Y                           ; $BF55: B9 14 06
  CLC                                   ; $BF58: 18
  ADC $01                               ; $BF59: 65 01
  STA $0614,Y                           ; $BF5B: 99 14 06
  CMP #$0F                              ; $BF5E: C9 0F
  BNE @AdvanceState                     ; $BF60: D0 16
  LDA $01                               ; $BF62: A5 01
  BMI @MoveUp                           ; $BF64: 30 09
  LDA $0614,Y                           ; $BF66: B9 14 06
  CLC                                   ; $BF69: 18
  ADC #$01                              ; $BF6A: 69 01
  JMP @StoreCol                         ; $BF6C: 4C 75 BF
@MoveUp:
  LDA $0614,Y                           ; $BF6F: B9 14 06
  SEC                                   ; $BF72: 38
  SBC #$01                              ; $BF73: E9 01
@StoreCol:
  STA $0614,Y                           ; $BF75: 99 14 06
@MoveAdvance:
  INC $0501                             ; $BF78: EE 01 05
  RTS                                   ; $BF7B: 60
@FinishMove:
  LDA #$01                              ; $BF7C: A9 01
  STA $12                               ; $BF7E: 85 12
  JSR UpdateCursorTile                             ; $BF80: 20 CC D6
  LDA $0505                             ; $BF83: AD 05 05
  SEC                                   ; $BF86: 38
  SBC $6F97                             ; $BF87: ED 97 6F
  STA $0505                             ; $BF8A: 8D 05 05
  LDA #$04                              ; $BF8D: A9 04
  STA $0500                             ; $BF8F: 8D 00 05
  LDA #$02                              ; $BF92: A9 02
  STA $0501                             ; $BF94: 8D 01 05
  RTS                                   ; $BF97: 60
@AnimateMove:
  LDA $6F8D                             ; $BF98: AD 8D 6F
  STA $0509                             ; $BF9B: 8D 09 05
  LDY #$3D                              ; $BF9E: A0 3D
  JSR B1F_BankedCallbackTrampoline      ; $BFA0: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A027                               ; $BFA3: $27 A0
  LDA #$02                                    ; $BFA5: A9 02
  STA $00A4                                   ; $BFA7: 8D A4 00
  DEC $0505                                   ; $BFAA: CE 05 05
  DEC $0505                                   ; $BFAD: CE 05 05
  INC $0501                                   ; $BFB0: EE 01 05
  LDA #$A0                                    ; $BFB3: A9 A0
  JMP B1F_SetUI5                              ; $BFB5: 4C 83 F2
@WaitConfirm:
  LDY $6F8D                             ; $BFB8: AC 8D 6F
  JSR CenterMapOnSlot                             ; $BFBB: 20 36 DC
  LDA $6F8C                             ; $BFBE: AD 8C 6F
  STA $0509                             ; $BFC1: 8D 09 05
  JSR TryAutoAdvance                       ; $BFC4: 20 DE A1
  JSR CheckExchangePossible                             ; $BFC7: 20 27 DF
  BCC @DispatchDone                     ; $BFCA: 90 0F
  JSR DrawExchangeArrows_Right                             ; $BFCC: 20 63 DC
  LDA $81                               ; $BFCF: A5 81
  AND #$01                              ; $BFD1: 29 01
  BEQ @DispatchDone                     ; $BFD3: F0 06
  INC $0501                             ; $BFD5: EE 01 05
  JSR B1F_PaletteCopyBuffer             ; $BFD8: 20 EE EC
@BattleWait:
  RTS                                   ; $BFDB: 60
@EnterBattle:
  LDY $6F8D                             ; $BFDC: AC 8D 6F
  JSR CenterMapOnSlot                             ; $BFDF: 20 36 DC
  LDA $0087                             ; $BFE2: AD 87 00
  BPL @BattleWait                       ; $BFE5: 10 1C
  LDA $6F8D                             ; $BFE7: AD 8D 6F
  STA $0509                             ; $BFEA: 8D 09 05
  LDA $6F8C                             ; $BFED: AD 8C 6F
  STA $050A                             ; $BFF0: 8D 0A 05
  LDA #$03                              ; $BFF3: A9 03
  STA $0500                             ; $BFF5: 8D 00 05
  STA $0501                             ; $BFF8: 8D 01 05
  LDA #$00                              ; $BFFB: A9 00
  STA $00A4                             ; $BFFD: 8D A4 00
.segment "CODE_BANK0D"
  JMP OfficerTransfer_SetupResult                          ; $C000: 4C D2 A3
@NextDone:
  RTS                                   ; $C003: 60
@ShowCost:
  LDA $6F8D                             ; $C004: AD 8D 6F
  CMP #$0B                              ; $C007: C9 0B
  BNE @ProcessResult                    ; $C009: D0 03
  JMP @ExecuteAction                    ; $C00B: 4C AF C1
@ProcessResult:
  LDA $6F8E                             ; $C00E: AD 8E 6F
  STA $0509                             ; $C011: 8D 09 05
  LDY #$3D                              ; $C014: A0 3D
  JSR B1F_BankedCallbackTrampoline      ; $C016: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A027                               ; $C019: $27 A0
  LDY $6F8D                                   ; $C01B: AC 8D 6F
  LDA $0505                                   ; $C01E: AD 05 05
  SEC                                         ; $C021: 38
  SBC @ActionCostTable,Y                   ; $C022: F9 44 C0
  STA $0505                                   ; $C025: 8D 05 05
  LDA $6F8D                                   ; $C028: AD 8D 6F
  STA officer_sel_list                                   ; $C02B: 8D 2C 04
  LDA #$00                                    ; $C02E: A9 00
  STA officer_sel_list+1                                   ; $C030: 8D 2D 04
  STA officer_sel_list+2                                   ; $C033: 8D 2E 04
  LDA #$A1                                    ; $C036: A9 A1
  JSR B1F_SetUI5                              ; $C038: 20 83 F2
  LDA #$65                                    ; $C03B: A9 65
  JSR $E69B                             ; $C03D: 20 9B E6
  INC $0501                                   ; $C040: EE 01 05
  RTS                                         ; $C043: 60
; Action point cost table indexed by stratagem code ($6F8D)
@ActionCostTable:
  .byte $06,$05,$04,$06,$07,$08,$08,$0C,$0A,$09,$09,$0F,$0E,$0F,$19,$14; $C044: 06 05 04 06 07 08 08 0C 0A 09 09 0F 0E 0F 19 14
@NextOfficer:
  INC officer_sel_list+1                             ; $C054: EE 2D 04
  LDA #$00                              ; $C057: A9 00
  STA $00A4                             ; $C059: 8D A4 00
  LDY $6F8E                             ; $C05C: AC 8E 6F
  JSR CenterMapOnSlot                             ; $C05F: 20 36 DC
  LDA $6F8C                             ; $C062: AD 8C 6F
  STA $0509                             ; $C065: 8D 09 05
  JSR TryAutoAdvance                       ; $C068: 20 DE A1
  JSR CheckExchangePossible                             ; $C06B: 20 27 DF
  BCC @NextDone                         ; $C06E: 90 0C
  JSR DrawExchangeArrows_Right                             ; $C070: 20 63 DC
  LDA $81                               ; $C073: A5 81
  AND #$03                              ; $C075: 29 03
  BEQ @NextDone                         ; $C077: F0 03
  INC $0501                             ; $C079: EE 01 05
@NoActionExit:
  RTS                                   ; $C07C: 60
@ShowResult:
  LDY $6F8E                             ; $C07D: AC 8E 6F
  JSR CenterMapOnSlot                             ; $C080: 20 36 DC
  LDA $6F8D                             ; $C083: AD 8D 6F
  STA $0543                             ; $C086: 8D 43 05
  LDA $6F8C                             ; $C089: AD 8C 6F
  STA $050A                             ; $C08C: 8D 0A 05
  LDA $6F8E                             ; $C08F: AD 8E 6F
  STA $0509                             ; $C092: 8D 09 05
  LDY $0509                             ; $C095: AC 09 05
  LDA #$00                              ; $C098: A9 00
  STA $0650,Y                           ; $C09A: 99 50 06
  JSR $B02B                             ; $C09D: 20 2B B0
  JSR CalcOfficerMeritLevels              ; $C0A0: 20 03 DB
  LDA #$01                              ; $C0A3: A9 01
  STA $12                               ; $C0A5: 85 12
  JSR UpdateCursorTile                             ; $C0A7: 20 CC D6
  LDA #$0B                              ; $C0AA: A9 0B
  STA $0501                             ; $C0AC: 8D 01 05
  LDA $0544                             ; $C0AF: AD 44 05
  BEQ @ShowMsg                          ; $C0B2: F0 0A
  LDA #$03                              ; $C0B4: A9 03
  STA $00A4                             ; $C0B6: 8D A4 00
  LDA #$A2                              ; $C0B9: A9 A2
  JMP B1F_SetUI2                        ; $C0BB: 4C 83 F2
@ShowMsg:
  LDA #$04                              ; $C0BE: A9 04
  STA $00A4                             ; $C0C0: 8D A4 00
  LDA $0543                             ; $C0C3: AD 43 05
  AND #$0F                              ; $C0C6: 29 0F
  TAY                                   ; $C0C8: A8
  CPY #$08                              ; $C0C9: C0 08
  BEQ @ShowFullMsg                      ; $C0CB: F0 2E
  CPY #$01                              ; $C0CD: C0 01
  BEQ @CheckPending                     ; $C0CF: F0 10
  CPY #$09                              ; $C0D1: C0 09
  BNE @ShowCancelMsg                    ; $C0D3: D0 20
  LDA officer_sel_list                             ; $C0D5: AD 2C 04
  BNE @CheckPending                     ; $C0D8: D0 07
  LDA officer_sel_list+1                             ; $C0DA: AD 2D 04
  BNE @CheckPending                     ; $C0DD: D0 02
  LDY #$01                              ; $C0DF: A0 01
@CheckPending:
  LDA officer_sel_list+6                             ; $C0E1: AD 32 04
  CMP #$FF                              ; $C0E4: C9 FF
  BEQ @ShowCancelMsg                    ; $C0E6: F0 0D
  STA officer_sel_list                             ; $C0E8: 8D 2C 04
  LDA #$0F                              ; $C0EB: A9 0F
  STA $0501                             ; $C0ED: 8D 01 05
  LDA #$4E                              ; $C0F0: A9 4E
  JMP B1F_SetUI5                        ; $C0F2: 4C 93 F2
@ShowCancelMsg:
  LDA @CancelMsgTable,Y                 ; $C0F5: B9 00 C1
  JMP B1F_SetUI2                        ; $C0F8: 4C 83 F2
@ShowFullMsg:
  LDA #$B7                              ; $C0FB: A9 B7
  JMP B1F_SetUI5                        ; $C0FD: 4C 93 F2
; Cancel message IDs indexed by stratagem code
@CancelMsgTable:
  .byte $A3,$A4,$A5,$A3,$A3,$A6,$A3,$A3,$B7,$4F,$A5,$A3,$A3,$A3,$A3,$B6; $C100: A3 A4 A5 A3 A3 A6 A3 A3 B7 4F A5 A3 A3 A3 A3 B6
@CancelAction:
  LDY $6F8E                             ; $C110: AC 8E 6F
  JSR CenterMapOnSlot                             ; $C113: 20 36 DC
  LDA $6F8C                             ; $C116: AD 8C 6F
  STA $0509                             ; $C119: 8D 09 05
  JSR TryAutoAdvance                       ; $C11C: 20 DE A1
  JSR CheckExchangePossible                             ; $C11F: 20 27 DF
  BCC @WaitInput                        ; $C122: 90 16
  JSR DrawExchangeArrows_Right                             ; $C124: 20 63 DC
  LDA $81                               ; $C127: A5 81
  AND #$03                              ; $C129: 29 03
  BEQ @NoActionExit                     ; $C12B: F0 0D
  JSR FinishSequence                       ; $C12D: 20 F7 A1
  LDA #$05                              ; $C130: A9 05
  JSR B1F_SetUI5                        ; $C132: 20 93 F2
  LDA #$10                              ; $C135: A9 10
  STA $0501                             ; $C137: 8D 01 05
@WaitInput:
  RTS                                   ; $C13A: 60
@ResetWait:
  JSR CheckExchangePossible                             ; $C13B: 20 27 DF
  BCC @WaitInput                        ; $C13E: 90 FA
  LDA $6F8C                             ; $C140: AD 8C 6F
  STA $0509                             ; $C143: 8D 09 05
  JMP OfficerTurn_EndTurn               ; $C146: 4C C0 BD
@SelectTarget:
  LDY #$00                              ; $C149: A0 00
  LDA $0504                             ; $C14B: AD 04 05
  BMI @StoreSlot                        ; $C14E: 30 02
  LDY #$0A                              ; $C150: A0 0A
@StoreSlot:
  TYA                                   ; $C152: 98
  STA $0509                             ; $C153: 8D 09 05
  LDY #$3D                              ; $C156: A0 3D
  JSR B1F_BankedCallbackTrampoline      ; $C158: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A027                               ; $C15B: $27 A0
  LDA $0509                                   ; $C15D: AD 09 05
  STA $050A                                   ; $C160: 8D 0A 05
  LDA $6F8C                                   ; $C163: AD 8C 6F
  STA $0509                                   ; $C166: 8D 09 05
  TAY                                         ; $C169: A8
  LDA $0664,Y                                 ; $C16A: B9 64 06
  STA officer_sel_list                                   ; $C16D: 8D 2C 04
  INC $0501                                   ; $C170: EE 01 05
  LDA #$BD                                    ; $C173: A9 BD
  JMP B1F_SetUI5                              ; $C175: 4C 83 F2
@ConfirmAction:
  LDA #$00                              ; $C178: A9 00
  STA $00A4                             ; $C17A: 8D A4 00
  LDY $050A                             ; $C17D: AC 0A 05
  JSR CenterMapOnSlot                             ; $C180: 20 36 DC
  JSR TryAutoAdvance                       ; $C183: 20 DE A1
  JSR CheckExchangePossible                             ; $C186: 20 27 DF
  BCC @WaitInput                        ; $C189: 90 AF
  JSR DrawExchangeArrows_Right                             ; $C18B: 20 63 DC
  LDA $81                               ; $C18E: A5 81
  AND #$03                              ; $C190: 29 03
  BEQ @WaitInput                        ; $C192: F0 1A
  LDA #$00                              ; $C194: A9 00
  STA $12                               ; $C196: 85 12
  JSR UpdateCursorTile                             ; $C198: 20 CC D6
  LDA $6F8D                             ; $C19B: AD 8D 6F
  STA $050B                             ; $C19E: 8D 0B 05
  JSR $BC2A                             ; $C1A1: 20 2A BC
  LDA #$05                              ; $C1A4: A9 05
  JSR B1F_SetUI5                        ; $C1A6: 20 93 F2
; Advance to final state
  LDA #$10                              ; $C1A9: A9 10
  STA $0501                             ; $C1AB: 8D 01 05
@CancelPending:
  RTS                                   ; $C1AE: 60
@ExecuteAction:
  LDA $6F8D                             ; $C1AF: AD 8D 6F
  STA $0543                             ; $C1B2: 8D 43 05
  LDA $6F8C                             ; $C1B5: AD 8C 6F
  STA $0509                             ; $C1B8: 8D 09 05
  STA $050A                             ; $C1BB: 8D 0A 05
  JSR $B02B                             ; $C1BE: 20 2B B0
  JSR CalcOfficerMeritLevels              ; $C1C1: 20 03 DB
  LDA #$01                              ; $C1C4: A9 01
  STA $12                               ; $C1C6: 85 12
  JSR UpdateCursorTile                             ; $C1C8: 20 CC D6
  JSR FinishSequence                       ; $C1CB: 20 F7 A1
  JMP @ClearState                       ; $C1CE: 4C F0 C1
@CancelWait:
  JSR CheckExchangePossible                             ; $C1D1: 20 27 DF
  BCC @CancelPending                    ; $C1D4: 90 14
  JSR DrawExchangeArrows_Right                             ; $C1D6: 20 63 DC
  LDA $81                               ; $C1D9: A5 81
  AND #$03                              ; $C1DB: 29 03
  BEQ @CancelPending                    ; $C1DD: F0 0B
  JSR FinishSequence                       ; $C1DF: 20 F7 A1
  LDA #$05                              ; $C1E2: A9 05
  JSR B1F_SetUI5                        ; $C1E4: 20 93 F2
  INC $0501                             ; $C1E7: EE 01 05
@ExitPending:
  RTS                                   ; $C1EA: 60
@Exit:
  JSR CheckExchangePossible                             ; $C1EB: 20 27 DF
  BCC @ExitPending                      ; $C1EE: 90 0B
@ClearState:
  LDA #$00                              ; $C1F0: A9 00
  STA $0500                             ; $C1F2: 8D 00 05
  STA $0501                             ; $C1F5: 8D 01 05
  STA $00A4                             ; $C1F8: 8D A4 00
@ExitDone:
  RTS                                   ; $C1FB: 60
.endproc

.proc MainLoopDispatch
  ; (dispatch callback target)
  LDY #$28                              ; $C1FC: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $C1FE: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A009                               ; $C201: $09 A0
  RTS                                         ; $C203: 60
.endproc

.proc ArmyDeployDispatch
  ; (dispatch callback target)
  LDA $0501                                   ; $C204: AD 01 05
  JSR B1F_CallbackDispatcher                  ; $C207: 20 DE EA
; --- CallbackDispatcher table (7 entries) ---
  .word @State_InitArmy                       ; $C20A: 18 C2
  .word @State_CheckSrcRuler                  ; $C20C: 4F C2
  .word @State_CheckDestRuler                 ; $C20E: 8A C2
  .word @State_ResetForTransfer               ; $C210: CD C2
  .word @State_WaitConfirm                    ; $C212: F7 C2
  .word @State_AdvanceOfficer                 ; $C214: 0E C3
  .word @State_RenderAndInput                 ; $C216: 50 C3
@State_InitArmy:
  JSR @SumArmyStats                     ; $C218: 20 20 C6
  INC $0501                             ; $C21B: EE 01 05
  LDA $060A                             ; $C21E: AD 0A 06
  STA $00                               ; $C221: 85 00
  LDA $061E                             ; $C223: AD 1E 06
  STA $02                               ; $C226: 85 02
  JSR TileToPixelCoord                             ; $C228: 20 5A DA
  LDA $00                               ; $C22B: A5 00
  STA $6F3F                             ; $C22D: 8D 3F 6F
  LDA $01                               ; $C230: A5 01
  STA $6F40                             ; $C232: 8D 40 6F
  LDA $02                               ; $C235: A5 02
  STA $6F41                             ; $C237: 8D 41 6F
  LDA $03                               ; $C23A: A5 03
  STA $6F42                             ; $C23C: 8D 42 6F
  JSR ComputeArmyMorale                 ; $C23F: 20 A0 C5
  INC $0506                             ; $C242: EE 06 05
  LDA $050D                             ; $C245: AD 0D 05
  STA $0505                             ; $C248: 8D 05 05
  JSR ClearEmptyRosterSlots                             ; $C24B: 20 1E DC
  RTS                                   ; $C24E: 60
@State_CheckSrcRuler:
  LDA $0507                             ; $C24F: AD 07 05
  AND #$0F                              ; $C252: 29 0F
  JSR B1F_GetRulerDataPtr               ; $C254: 20 68 F3
  LDY #$03                              ; $C257: A0 03
  LDA ($00),Y                           ; $C259: B1 00
  CMP #$03                              ; $C25B: C9 03
  BEQ @RulerDefeated                    ; $C25D: F0 27
  STA $6F44                             ; $C25F: 8D 44 6F
  LDA #$04                              ; $C262: A9 04
  STA $0501                             ; $C264: 8D 01 05
  LDA #$02                              ; $C267: A9 02
  STA $050B                             ; $C269: 8D 0B 05
  LDA #$00                              ; $C26C: A9 00
  STA $0509                             ; $C26E: 8D 09 05
  LDA #$F9                              ; $C271: A9 F9
  JSR B1F_SetUI5                        ; $C273: 20 93 F2
  LDA $0507                             ; $C276: AD 07 05
  AND #$0F                              ; $C279: 29 0F
  JSR B1F_GetRulerDataPtr               ; $C27B: 20 68 F3
  LDY #$00                              ; $C27E: A0 00
  LDA ($00),Y                           ; $C280: B1 00
  STA officer_sel_list                             ; $C282: 8D 2C 04
  RTS                                   ; $C285: 60
@RulerDefeated:
  INC $0501                             ; $C286: EE 01 05
  RTS                                   ; $C289: 60
@State_CheckDestRuler:
  LDA $0507                             ; $C28A: AD 07 05
  LSR                                   ; $C28D: 4A
  LSR                                   ; $C28E: 4A
  LSR                                   ; $C28F: 4A
  LSR                                   ; $C290: 4A
  AND #$0F                              ; $C291: 29 0F
  JSR B1F_GetRulerDataPtr               ; $C293: 20 68 F3
  LDY #$03                              ; $C296: A0 03
  LDA ($00),Y                           ; $C298: B1 00
  CMP #$03                              ; $C29A: C9 03
  BEQ @DestRulerDefeated                ; $C29C: F0 2B
  STA $6F44                             ; $C29E: 8D 44 6F
  LDA #$04                              ; $C2A1: A9 04
  STA $0501                             ; $C2A3: 8D 01 05
  LDA #$03                              ; $C2A6: A9 03
  STA $050B                             ; $C2A8: 8D 0B 05
  LDA #$0A                              ; $C2AB: A9 0A
  STA $0509                             ; $C2AD: 8D 09 05
  LDA #$F9                              ; $C2B0: A9 F9
  JSR B1F_SetUI5                        ; $C2B2: 20 93 F2
  LDA $0507                             ; $C2B5: AD 07 05
  LSR                                   ; $C2B8: 4A
  LSR                                   ; $C2B9: 4A
  LSR                                   ; $C2BA: 4A
  LSR                                   ; $C2BB: 4A
  AND #$0F                              ; $C2BC: 29 0F
  JSR B1F_GetRulerDataPtr               ; $C2BE: 20 68 F3
  LDY #$00                              ; $C2C1: A0 00
  LDA ($00),Y                           ; $C2C3: B1 00
  STA officer_sel_list                             ; $C2C5: 8D 2C 04
  RTS                                   ; $C2C8: 60
@DestRulerDefeated:
  INC $0501                             ; $C2C9: EE 01 05
  RTS                                   ; $C2CC: 60
@State_ResetForTransfer:
  LDA #$00                              ; $C2CD: A9 00
  STA $0500                             ; $C2CF: 8D 00 05
  LDA #$00                              ; $C2D2: A9 00
  STA $0501                             ; $C2D4: 8D 01 05
  STA $0508                             ; $C2D7: 8D 08 05
  STA $0509                             ; $C2DA: 8D 09 05
  STA $050A                             ; $C2DD: 8D 0A 05
  STA $050B                             ; $C2E0: 8D 0B 05
  LDA $0507                             ; $C2E3: AD 07 05
  LSR                                   ; $C2E6: 4A
  LSR                                   ; $C2E7: 4A
  LSR                                   ; $C2E8: 4A
  LSR                                   ; $C2E9: 4A
  AND #$0F                              ; $C2EA: 29 0F
  JSR B1F_GetRulerDataPtr               ; $C2EC: 20 68 F3
  LDY #$03                              ; $C2EF: A0 03
  LDA ($00),Y                           ; $C2F1: B1 00
  STA $050F                             ; $C2F3: 8D 0F 05
  RTS                                   ; $C2F6: 60
@State_WaitConfirm:
  JSR CheckExchangePossible                             ; $C2F7: 20 27 DF
  BCC @WaitDone                         ; $C2FA: 90 11
  JSR DrawExchangeArrows_Right                             ; $C2FC: 20 63 DC
  LDA $81                               ; $C2FF: A5 81
  AND #$01                              ; $C301: 29 01
  BEQ @WaitDone                         ; $C303: F0 08
  INC $0501                             ; $C305: EE 01 05
  LDA #$FF                              ; $C308: A9 FF
  STA $050A                             ; $C30A: 8D 0A 05
@WaitDone:
  RTS                                   ; $C30D: 60
@State_AdvanceOfficer:
  INC $050A                             ; $C30E: EE 0A 05
  LDA $050A                             ; $C311: AD 0A 05
  CMP #$0A                              ; $C314: C9 0A
  BCC @Timeout                          ; $C316: 90 10
  LDA #$09                              ; $C318: A9 09
  STA $BB                               ; $C31A: 85 BB
  LDA $050B                             ; $C31C: AD 0B 05
  STA $0501                             ; $C31F: 8D 01 05
  LDA #$05                              ; $C322: A9 05
  JMP B1F_SetUI5                        ; $C324: 4C 93 F2
  RTS                                   ; $C327: 60  (unreachable - after JMP)
@Timeout:
  LDY $0509                             ; $C328: AC 09 05
  LDA $0664,Y                           ; $C32B: B9 64 06
  CMP #$FF                              ; $C32E: C9 FF
  BNE @NextOfficer                      ; $C330: D0 06
  INC $0509                             ; $C332: EE 09 05
  JMP @State_AdvanceOfficer             ; $C335: 4C 0E C3
@NextOfficer:
  STA detail_officer_id                             ; $C338: 8D 10 04
  LDA #$08                              ; $C33B: A9 08
  STA $BA                               ; $C33D: 85 BA
  LDA #$00                              ; $C33F: A9 00
  STA detail_cursor_x                             ; $C341: 8D 0C 04
  LDA #$00                              ; $C344: A9 00
  STA detail_cursor_y                             ; $C346: 8D 0D 04
  INC $0501                             ; $C349: EE 01 05
  JSR @BuildOfficerList                 ; $C34C: 20 CB C3
  RTS                                   ; $C34F: 60
@State_RenderAndInput:
  LDA #$A7                              ; $C350: A9 A7
  STA $0A                               ; $C352: 85 0A
  LDA detail_officer_id                             ; $C354: AD 10 04
  STA $00                               ; $C357: 85 00
  LDA #$00                              ; $C359: A9 00
  STA $00A4                             ; $C35B: 8D A4 00
  LDY #$39                              ; $C35E: A0 39
  JSR B1F_BankedCallbackTrampoline      ; $C360: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                               ; $C363: $00 A0
  LDY $0509                                   ; $C365: AC 09 05
  LDA $0600,Y                                 ; $C368: B9 00 06
  STA $00                                     ; $C36B: 85 00
  LDA $0614,Y                                 ; $C36D: B9 14 06
  STA $02                                     ; $C370: 85 02
  JSR TileToPixelCoord                             ; $C372: 20 5A DA
  LDA $00                                     ; $C375: A5 00
  STA $6F3F                                   ; $C377: 8D 3F 6F
  LDA $01                                     ; $C37A: A5 01
  STA $6F40                                   ; $C37C: 8D 40 6F
  LDA $02                                     ; $C37F: A5 02
  STA $6F41                                   ; $C381: 8D 41 6F
  LDA $03                                     ; $C384: A5 03
  STA $6F42                                   ; $C386: 8D 42 6F
  JSR MapScroll_Update                             ; $C389: 20 EE D5
  LDA $0508                                   ; $C38C: AD 08 05
  BNE @Done                             ; $C38F: D0 39
  LDA $007E                                   ; $C391: AD 7E 00
  BNE @Done                             ; $C394: D0 34
  LDA #$06                                    ; $C396: A9 06
  STA $BB                                     ; $C398: 85 BB
  LDY #$39                                    ; $C39A: A0 39
  JSR B1F_BankedCallbackTrampoline            ; $C39C: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                                 ; $C39F: 12 A0
  JSR TryAutoAdvance                          ; $C3A1: 20 DE A1
  LDA detail_cursor_y                                   ; $C3A4: AD 0D 04
  CMP #$FF                                    ; $C3A7: C9 FF
@SkipAutoAdvance:
  BNE @Done                             ; $C3A9: D0 1F
  JSR @AdjustCursorForInput             ; $C3AB: 20 B1 C4
  JSR CheckExchangePossible                             ; $C3AE: 20 27 DF
  BCC @Done                             ; $C3B1: 90 17
  LDA $81                               ; $C3B3: A5 81
  CMP #$10                              ; $C3B5: C9 10
  BCS @Done                             ; $C3B7: B0 11
  AND #$01                              ; $C3B9: 29 01
  BEQ @Done                             ; $C3BB: F0 0D
  DEC $0501                             ; $C3BD: CE 01 05
  LDA #$01                              ; $C3C0: A9 01
  STA $12                               ; $C3C2: 85 12
  JSR UpdateCursorTile                             ; $C3C4: 20 CC D6
  INC $0509                             ; $C3C7: EE 09 05
@Done:
  RTS                                   ; $C3CA: 60
@BuildOfficerList:
  LDA $050B                             ; $C3CB: AD 0B 05
  CMP #$02                              ; $C3CE: C9 02
  BNE @Mode2Bounds                      ; $C3D0: D0 4A
  JSR GetCityOfficerData                             ; $C3D2: 20 BF DE
  ASL                                   ; $C3D5: 0A
  ASL                                   ; $C3D6: 0A
  ASL                                   ; $C3D7: 0A
  ASL                                   ; $C3D8: 0A
  ASL                                   ; $C3D9: 0A
  STA $18                               ; $C3DA: 85 18
  LDY #$26                              ; $C3DC: A0 26
  JSR B1F_SwitchBank8_B                 ; $C3DE: 20 5F F2
  LDA $050E                             ; $C3E1: AD 0E 05
  ASL                                   ; $C3E4: 0A
  TAY                                   ; $C3E5: A8
  LDA $8C52,Y                           ; $C3E6: B9 52 8C
  CLC                                   ; $C3E9: 18
  ADC $18                               ; $C3EA: 65 18
  STA $10                               ; $C3EC: 85 10
  LDA $8C53,Y                           ; $C3EE: B9 53 8C
  ADC #$00                              ; $C3F1: 69 00
  STA $11                               ; $C3F3: 85 11
@ReadEntry:
  LDY #$00                              ; $C3F5: A0 00
@ReadPair:
  LDA ($10),Y                           ; $C3F7: B1 10
  STA $01                               ; $C3F9: 85 01
  INY                                   ; $C3FB: C8
  LDA ($10),Y                           ; $C3FC: B1 10
  STA $00                               ; $C3FE: 85 00
  INY                                   ; $C400: C8
  STY $12                               ; $C401: 84 12
  JSR SearchRosterByTileCoord                             ; $C403: 20 B6 D6
  TYA                                   ; $C406: 98
  BMI @StoreResult                      ; $C407: 30 05
  LDY $12                               ; $C409: A4 12
  JMP @ReadPair                         ; $C40B: 4C F7 C3
@StoreResult:
  LDY $0509                             ; $C40E: AC 09 05
  LDA $00                               ; $C411: A5 00
  STA $0600,Y                           ; $C413: 99 00 06
  LDA $01                               ; $C416: A5 01
  STA $0614,Y                           ; $C418: 99 14 06
  RTS                                   ; $C41B: 60
@Mode2Bounds:
  JSR GetCityDataA                             ; $C41C: 20 9E DE
  STA $18                               ; $C41F: 85 18
  ASL                                   ; $C421: 0A
  ASL                                   ; $C422: 0A
  ASL                                   ; $C423: 0A
  ASL                                   ; $C424: 0A
  CLC                                   ; $C425: 18
  ADC $18                               ; $C426: 65 18
  ASL                                   ; $C428: 0A
  STA $18                               ; $C429: 85 18
  LDY #$26                              ; $C42B: A0 26
  JSR B1F_SwitchBank8_B                 ; $C42D: 20 5F F2
  LDA $050E                             ; $C430: AD 0E 05
  ASL                                   ; $C433: 0A
  TAY                                   ; $C434: A8
  LDA $8000,Y                           ; $C435: B9 00 80
  CLC                                   ; $C438: 18
  ADC $18                               ; $C439: 65 18
  STA $10                               ; $C43B: 85 10
  LDA $8001,Y                           ; $C43D: B9 01 80
  ADC #$00                              ; $C440: 69 00
  STA $11                               ; $C442: 85 11
  JMP @ReadEntry                        ; $C444: 4C F5 C3
@CheckBoundsForPosition:
  LDA $050B                             ; $C447: AD 0B 05
  CMP #$02                              ; $C44A: C9 02
  BNE @OtherModeBounds                  ; $C44C: D0 40
  JSR GetCityOfficerData                             ; $C44E: 20 BF DE
  ASL                                   ; $C451: 0A
  ASL                                   ; $C452: 0A
  STA $18                               ; $C453: 85 18
  LDY #$26                              ; $C455: A0 26
  JSR B1F_SwitchBank8_B                 ; $C457: 20 5F F2
  LDA $050E                             ; $C45A: AD 0E 05
  ASL                                   ; $C45D: 0A
  TAY                                   ; $C45E: A8
  LDA $94D6,Y                           ; $C45F: B9 D6 94
  CLC                                   ; $C462: 18
  ADC $18                               ; $C463: 65 18
  STA $10                               ; $C465: 85 10
  LDA $94D7,Y                           ; $C467: B9 D7 94
  ADC #$00                              ; $C46A: 69 00
  STA $11                               ; $C46C: 85 11
@CompareBounds:
  LDY #$00                              ; $C46E: A0 00
  LDA $01                               ; $C470: A5 01
  CMP ($10),Y                           ; $C472: D1 10
  BCC @OutOfBounds                      ; $C474: 90 16
  LDY #$02                              ; $C476: A0 02
  CMP ($10),Y                           ; $C478: D1 10
  BCS @OutOfBounds                      ; $C47A: B0 10
  LDY #$01                              ; $C47C: A0 01
  LDA $00                               ; $C47E: A5 00
  CMP ($10),Y                           ; $C480: D1 10
  BCC @OutOfBounds                      ; $C482: 90 08
  LDY #$03                              ; $C484: A0 03
  CMP ($10),Y                           ; $C486: D1 10
  BCS @OutOfBounds                      ; $C488: B0 02
  SEC                                   ; $C48A: 38
  RTS                                   ; $C48B: 60
@OutOfBounds:
  CLC                                   ; $C48C: 18
  RTS                                   ; $C48D: 60
@OtherModeBounds:
  JSR GetCityDataA                             ; $C48E: 20 9E DE
  ASL                                   ; $C491: 0A
  ASL                                   ; $C492: 0A
  STA $18                               ; $C493: 85 18
  LDY #$26                              ; $C495: A0 26
  JSR B1F_SwitchBank8_B                 ; $C497: 20 5F F2
  LDA $050E                             ; $C49A: AD 0E 05
  ASL                                   ; $C49D: 0A
  TAY                                   ; $C49E: A8
  LDA $932E,Y                           ; $C49F: B9 2E 93
  CLC                                   ; $C4A2: 18
  ADC $18                               ; $C4A3: 65 18
  STA $10                               ; $C4A5: 85 10
  LDA $932F,Y                           ; $C4A7: B9 2F 93
  ADC #$00                              ; $C4AA: 69 00
  STA $11                               ; $C4AC: 85 11
  JMP @CompareBounds                    ; $C4AE: 4C 6E C4
@AdjustCursorForInput:
  LDA detail_cursor_y                             ; $C4B1: AD 0D 04
  CMP #$FF                              ; $C4B4: C9 FF
  BEQ @CheckMoveUp                      ; $C4B6: F0 01
  RTS                                   ; $C4B8: 60
@CheckMoveUp:
  LDA $81                               ; $C4B9: A5 81
  ASL                                   ; $C4BB: 0A
  BPL @CheckMoveDown                    ; $C4BC: 10 2B
  LDY $0509                             ; $C4BE: AC 09 05
  LDA $0600,Y                           ; $C4C1: B9 00 06
  SEC                                   ; $C4C4: 38
  SBC #$01                              ; $C4C5: E9 01
  BCC @CheckMoveDown                    ; $C4C7: 90 20
  STA $00                               ; $C4C9: 85 00
  LDA $0614,Y                           ; $C4CB: B9 14 06
  STA $01                               ; $C4CE: 85 01
  JSR SearchRosterByTileCoord                             ; $C4D0: 20 B6 D6
  TYA                                   ; $C4D3: 98
  BPL @CheckMoveDown                    ; $C4D4: 10 13
  JSR $C447                             ; $C4D6: 20 47 C4
  BCC @CheckMoveDown                    ; $C4D9: 90 0E
  LDA #$00                              ; $C4DB: A9 00
  STA $12                               ; $C4DD: 85 12
  JSR UpdateCursorTile                             ; $C4DF: 20 CC D6
  LDX $0509                             ; $C4E2: AE 09 05
  DEC $0600,X                           ; $C4E5: DE 00 06
  RTS                                   ; $C4E8: 60
@CheckMoveDown:
  LDA $81                               ; $C4E9: A5 81
  BPL @CheckMoveLeft                    ; $C4EB: 10 2D
  LDY $0509                             ; $C4ED: AC 09 05
  LDA $0600,Y                           ; $C4F0: B9 00 06
  CLC                                   ; $C4F3: 18
  ADC #$01                              ; $C4F4: 69 01
  CMP #$1F                              ; $C4F6: C9 1F
  BCS @CheckMoveLeft                    ; $C4F8: B0 20
  STA $00                               ; $C4FA: 85 00
  LDA $0614,Y                           ; $C4FC: B9 14 06
  STA $01                               ; $C4FF: 85 01
  JSR SearchRosterByTileCoord                             ; $C501: 20 B6 D6
  TYA                                   ; $C504: 98
  BPL @CheckMoveLeft                    ; $C505: 10 13
  JSR $C447                             ; $C507: 20 47 C4
  BCC @CheckMoveLeft                    ; $C50A: 90 0E
  LDA #$00                              ; $C50C: A9 00
  STA $12                               ; $C50E: 85 12
  JSR UpdateCursorTile                             ; $C510: 20 CC D6
  LDX $0509                             ; $C513: AE 09 05
  INC $0600,X                           ; $C516: FE 00 06
  RTS                                   ; $C519: 60
@CheckMoveLeft:
  LDA $81                               ; $C51A: A5 81
  ASL                                   ; $C51C: 0A
  ASL                                   ; $C51D: 0A
  ASL                                   ; $C51E: 0A
  BPL @CheckMoveRight                   ; $C51F: 10 3B
  LDY $0509                             ; $C521: AC 09 05
  LDA $0600,Y                           ; $C524: B9 00 06
  STA $00                               ; $C527: 85 00
  LDA $0614,Y                           ; $C529: B9 14 06
  SEC                                   ; $C52C: 38
  SBC #$01                              ; $C52D: E9 01
  BMI @CheckMoveRight                   ; $C52F: 30 2B
  CMP #$0F                              ; $C531: C9 0F
  BNE @SkipRowLeft                      ; $C533: D0 03
  SEC                                   ; $C535: 38
  SBC #$01                              ; $C536: E9 01
@SkipRowLeft:
  STA $01                               ; $C538: 85 01
  JSR SearchRosterByTileCoord                             ; $C53A: 20 B6 D6
  TYA                                   ; $C53D: 98
  BPL @CheckMoveRight                   ; $C53E: 10 1C
  JSR $C447                             ; $C540: 20 47 C4
  BCC @CheckMoveRight                   ; $C543: 90 17
  LDA #$00                              ; $C545: A9 00
  STA $12                               ; $C547: 85 12
  JSR UpdateCursorTile                             ; $C549: 20 CC D6
  LDX $0509                             ; $C54C: AE 09 05
  DEC $0614,X                           ; $C54F: DE 14 06
  LDA $0614,X                           ; $C552: BD 14 06
  CMP #$0F                              ; $C555: C9 0F
  BNE @CheckMoveRight                   ; $C557: D0 03
  DEC $0614,X                           ; $C559: DE 14 06
@CheckMoveRight:
  LDA $81                               ; $C55C: A5 81
  ASL                                   ; $C55E: 0A
  ASL                                   ; $C55F: 0A
  BPL @CursorDone                       ; $C560: 10 3D
  LDY $0509                             ; $C562: AC 09 05
  LDA $0600,Y                           ; $C565: B9 00 06
  STA $00                               ; $C568: 85 00
  LDA $0614,Y                           ; $C56A: B9 14 06
  CLC                                   ; $C56D: 18
  ADC #$01                              ; $C56E: 69 01
  CMP #$14                              ; $C570: C9 14
  BCS @CursorDone                       ; $C572: B0 2B
  CMP #$0F                              ; $C574: C9 0F
  BNE @SkipRowRight                     ; $C576: D0 03
  CLC                                   ; $C578: 18
  ADC #$01                              ; $C579: 69 01
@SkipRowRight:
  STA $01                               ; $C57B: 85 01
  JSR SearchRosterByTileCoord                             ; $C57D: 20 B6 D6
  TYA                                   ; $C580: 98
  BPL @CursorDone                       ; $C581: 10 1C
  JSR $C447                             ; $C583: 20 47 C4
  BCC @CursorDone                       ; $C586: 90 17
  LDA #$00                              ; $C588: A9 00
  STA $12                               ; $C58A: 85 12
  JSR UpdateCursorTile                             ; $C58C: 20 CC D6
  LDX $0509                             ; $C58F: AE 09 05
  INC $0614,X                           ; $C592: FE 14 06
  LDA $0614,X                           ; $C595: BD 14 06
  CMP #$0F                              ; $C598: C9 0F
  BNE @CursorDone                       ; $C59A: D0 03
  INC $0614,X                           ; $C59C: FE 14 06
@CursorDone:
  RTS                                   ; $C59F: 60
; ComputeArmyMorale: Adjust morale for two army groups based on average officer merit.
; 1) CalcOfficerMeritLevels: per-officer (byte8|(byte9&3)<<8) / 100 → $063C,X
; 2) SumArmyGroupA_Stats: sum merit for group A ($0628,X >= 0) → $000B/$000C, count → $000A
; 3) Divide total by 1000 → avg merit index (0-12)
; 4) Add MoraleBonusByAvgMerit[index] to $050C, cap at MoraleCapByAvgMerit[index]
; 5) Repeat for group B via SumArmyGroupB_Stats → $050D
ComputeArmyMorale:
  JSR CalcOfficerMeritLevels            ; $C5A0: 20 03 DB
  JSR SumArmyGroupA_Stats               ; $C5A3: 20 83 DA
  ; Divide group A total merit ($000B/$000C) by 1000 → avg merit index
  LDA $0B                               ; $C5A6: A5 0B
  STA $00                               ; $C5A8: 85 00
  LDA $0C                               ; $C5AA: A5 0C
  STA $01                               ; $C5AC: 85 01
  LDA #$00                              ; $C5AE: A9 00
  STA $02                               ; $C5B0: 85 02
  LDA #$E8                              ; $C5B2: A9 E8
  STA $03                               ; $C5B4: 85 03
  LDA #$03                              ; $C5B6: A9 03
  STA $04                               ; $C5B8: 85 04
  JSR B1F_MathDiv24                     ; $C5BA: 20 A5 EA
  LDY $00                               ; $C5BD: A4 00  ; Y = avg merit index
  LDA $C606,Y                           ; $C5BF: B9 06 C6  ; bonus = MoraleBonusByAvgMerit[Y]
  CLC                                   ; $C5C2: 18
  ADC $050C                             ; $C5C3: 6D 0C 05
  STA $050C                             ; $C5C6: 8D 0C 05
  CMP $C613,Y                           ; $C5C9: D9 13 C6
  BCC @MoraleCap1                       ; $C5CC: 90 06
  LDA $C613,Y                           ; $C5CE: B9 13 C6
  STA $050C                             ; $C5D1: 8D 0C 05
@MoraleCap1:
  JSR SumArmyGroupB_Stats               ; $C5D4: 20 C3 DA
  ; Divide group B total merit ($000B/$000C) by 1000 → avg merit index
  LDA $0B                               ; $C5D7: A5 0B
  STA $00                               ; $C5D9: 85 00
  LDA $0C                               ; $C5DB: A5 0C
  STA $01                               ; $C5DD: 85 01
  LDA #$00                              ; $C5DF: A9 00
  STA $02                               ; $C5E1: 85 02
  LDA #$E8                              ; $C5E3: A9 E8
  STA $03                               ; $C5E5: 85 03
  LDA #$03                              ; $C5E7: A9 03
  STA $04                               ; $C5E9: 85 04
  JSR B1F_MathDiv24                     ; $C5EB: 20 A5 EA
  LDY $00                               ; $C5EE: A4 00  ; Y = avg merit index
  LDA $C606,Y                           ; $C5F0: B9 06 C6  ; bonus = MoraleBonusByAvgMerit[Y]
  CLC                                   ; $C5F3: 18
  ADC $050D                             ; $C5F4: 6D 0D 05
  STA $050D                             ; $C5F7: 8D 0D 05
  CMP $C613,Y                           ; $C5FA: D9 13 C6
  BCC @MoraleCap2                       ; $C5FD: 90 06
  LDA $C613,Y                           ; $C5FF: B9 13 C6
  STA $050D                             ; $C602: 8D 0D 05
@MoraleCap2:
  RTS                                   ; $C605: 60
; --- Morale lookup tables (indexed by average merit = total_merit / 1000, clamped 0-12) ---
MoraleBonusByAvgMerit:                  ; $C606: bonus added to morale
  .byte $0A,$10,$14,$18,$1C,$20,$23,$25,$28,$2A,$2A,$2A,$2A
MoraleCapByAvgMerit:                    ; $C613: maximum morale after bonus
  .byte $14,$1A,$20,$24,$2A,$2E,$33,$35,$3A,$3C,$3C,$3C,$3C
; SumArmyOfficerStats: Sum officer merit (byte8 + byte9&3) for both army groups.
; Group A ($0628,X >= 0): sum → $051A/$051B, count → $051E
; Group B ($0628,X < 0):  sum → $051C/$051D, count → $051F
@SumArmyStats:
  LDA #$00                              ; $C620: A9 00
  STA $051A                             ; $C622: 8D 1A 05
  STA $051B                             ; $C625: 8D 1B 05
  STA $051E                             ; $C628: 8D 1E 05
@SumGroupA_Loop:
  TAY                                   ; $C62B: A8
  PHA                                   ; $C62C: 48
  LDA $0664,Y                           ; $C62D: B9 64 06
  CMP #$FF                              ; $C630: C9 FF
  BEQ @SumGroupA_Skip                   ; $C632: F0 1C
  JSR B1F_GetOfficerRecordAddr          ; $C634: 20 D7 F2
  LDY #$08                              ; $C637: A0 08
  LDA ($00),Y                           ; $C639: B1 00
  CLC                                   ; $C63B: 18
  ADC $051A                             ; $C63C: 6D 1A 05
  STA $051A                             ; $C63F: 8D 1A 05
  INY                                   ; $C642: C8
  LDA ($00),Y                           ; $C643: B1 00
  AND #$03                              ; $C645: 29 03
  ADC $051B                             ; $C647: 6D 1B 05
  STA $051B                             ; $C64A: 8D 1B 05
  INC $051E                             ; $C64D: EE 1E 05
@SumGroupA_Skip:
  PLA                                   ; $C650: 68
  CLC                                   ; $C651: 18
  ADC #$01                              ; $C652: 69 01
  CMP #$0A                              ; $C654: C9 0A
  BCC @SumGroupA_Loop                   ; $C656: 90 D3
  LDA #$00                              ; $C658: A9 00
  STA $051C                             ; $C65A: 8D 1C 05
  STA $051D                             ; $C65D: 8D 1D 05
  STA $051F                             ; $C660: 8D 1F 05
@SumGroupB_Loop:
  TAY                                   ; $C663: A8
  PHA                                   ; $C664: 48
  LDA $066E,Y                           ; $C665: B9 6E 06
  CMP #$FF                              ; $C668: C9 FF
  BEQ @SumGroupB_Skip                   ; $C66A: F0 1C
  JSR B1F_GetOfficerRecordAddr          ; $C66C: 20 D7 F2
  LDY #$08                              ; $C66F: A0 08
  LDA ($00),Y                           ; $C671: B1 00
  CLC                                   ; $C673: 18
  ADC $051C                             ; $C674: 6D 1C 05
  STA $051C                             ; $C677: 8D 1C 05
  INY                                   ; $C67A: C8
  LDA ($00),Y                           ; $C67B: B1 00
  AND #$03                              ; $C67D: 29 03
  ADC $051D                             ; $C67F: 6D 1D 05
  STA $051D                             ; $C682: 8D 1D 05
  INC $051F                             ; $C685: EE 1F 05
@SumGroupB_Skip:
  PLA                                   ; $C688: 68
  CLC                                   ; $C689: 18
  ADC #$01                              ; $C68A: 69 01
  CMP #$0A                              ; $C68C: C9 0A
  BCC @SumGroupB_Loop                   ; $C68E: 90 D3
  RTS                                   ; $C690: 60
.endproc

.proc OfficerExchangeDispatch
  ; Game mode 11: Officer exchange/transfer between factions
  ; State machine on $0501: 0=Init, 1=Select, 2=Exit, 3=Confirm
  LDA $0501                             ; $C691: AD 01 05
  JSR B1F_CallbackDispatcher            ; $C694: 20 DE EA
; --- CallbackDispatcher table (4 entries) ---
  .word @State_Init                         ; $C697: $9F C6
  .word @State_Select                       ; $C699: $AC C6
  .word @State_Exit                         ; $C69B: $B9 C6
  .word @State_Confirm                      ; $C69D: $BC C6
@State_Init:  ; (dispatch callback target)
  LDA $0514                             ; $C69F: AD 14 05
  STA $10                               ; $C6A2: 85 10
  LDA #$01                              ; $C6A4: A9 01
  STA anim_ppu_ptr_lo                             ; $C6A6: 8D 70 04
  JMP @SetupAndValidate                 ; $C6A9: 4C EA C6
@State_Select:  ; (dispatch callback target)
  LDA $0516                             ; $C6AC: AD 16 05
  STA $10                               ; $C6AF: 85 10
  LDA #$02                              ; $C6B1: A9 02
  STA anim_ppu_ptr_lo                             ; $C6B3: 8D 70 04
  JMP @SetupAndValidate                 ; $C6B6: 4C EA C6
@State_Exit:  ; (dispatch callback target)
  JMP ResetToIdle                       ; $C6B9: 4C 0C A2
@State_Confirm:  ; (dispatch callback target)
  JSR CheckExchangePossible                             ; $C6BC: 20 27 DF
  BCC @Done                             ; $C6BF: 90 1E
  JSR DrawExchangeArrows_Right                             ; $C6C1: 20 63 DC
  LDA $81                               ; $C6C4: A5 81
  AND #$01                              ; $C6C6: 29 01
  BEQ @Done                             ; $C6C8: F0 15
  LDA officer_sel_list+1                             ; $C6CA: AD 2D 04
  CMP #$FF                              ; $C6CD: C9 FF
  BNE @ShowCancelUI                     ; $C6CF: D0 0F
  JSR B1F_BankPpuInit                   ; $C6D1: 20 7F E5
  LDA #$1D                              ; $C6D4: A9 1D
  JSR B1F_SoundWrapperA                 ; $C6D6: 20 73 E6
  LDA anim_ppu_ptr_lo                             ; $C6D9: AD 70 04
  STA $0501                             ; $C6DC: 8D 01 05  ; restore state from mode
@Done:
  RTS                                   ; $C6DF: 60
@ShowCancelUI:
  LDA #$FF                              ; $C6E0: A9 FF
  STA officer_sel_list+1                             ; $C6E2: 8D 2D 04
  LDA #$4B                              ; $C6E5: A9 4B
  JMP B1F_SetUI5                        ; $C6E7: 4C 93 F2
; --- Setup and validate officer transfer ---
; $10 = officer/group ID, $0470 = mode (1=init, 2=select)
; Determines slot from $0560, loads officer data, validates ally status
@SetupAndValidate:
  LDY #$00                              ; $C6EA: A0 00
  LDA $10                               ; $C6EC: A5 10
  CMP $0560                             ; $C6EE: CD 60 05
  BEQ @SelectSlot                       ; $C6F1: F0 02
  LDY #$01                              ; $C6F3: A0 01
@SelectSlot:
  LDA $052E,Y                           ; $C6F5: B9 2E 05
  STA $11                               ; $C6F8: 85 11
  LDA $052C,Y                           ; $C6FA: B9 2C 05
  STA $12                               ; $C6FD: 85 12
  LDA $10                               ; $C6FF: A5 10
  STA officer_sel_list                             ; $C701: 8D 2C 04
  JSR FindOfficerInRoster               ; $C704: 20 5B C7
  CPY #$FF                              ; $C707: C0 FF
  BEQ @NextState                        ; $C709: F0 07
  LDA $6FA1,Y                           ; $C70B: B9 A1 6F
  CMP #$FF                              ; $C70E: C9 FF
  BEQ @ExecuteTransfer                  ; $C710: F0 04
@NextState:
  INC $0501                             ; $C712: EE 01 05
  RTS                                   ; $C715: 60
@ExecuteTransfer:
  LDA officer_sel_list                             ; $C716: AD 2C 04
  JSR B1F_GetOfficerRecordAddr          ; $C719: 20 D7 F2
  LDY #$0B                              ; $C71C: A0 0B
  LDA ($00),Y                           ; $C71E: B1 00
  AND #$F0                              ; $C720: 29 F0
  CMP $12                               ; $C722: C5 12
  BEQ @NextState                        ; $C724: F0 EC
  LDY #$01                              ; $C726: A0 01
  LDA ($00),Y                           ; $C728: B1 00
  SEC                                   ; $C72A: 38
  SBC $11                               ; $C72B: E5 11
  STA officer_sel_list+3                             ; $C72D: 8D 2F 04
  LDA #$00                              ; $C730: A9 00
  STA officer_sel_list+1                             ; $C732: 8D 2D 04
  STA officer_sel_list+4                             ; $C735: 8D 30 04
  STA officer_sel_list+5                             ; $C738: 8D 31 04
  LDY #$28                              ; $C73B: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $C73D: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A018                               ; $C740: $18 A0
  LDA #$03                                    ; $C742: A9 03
  STA $0501                                   ; $C744: 8D 01 05  ; state = Confirm
  JSR $E57F                             ; $C747: 20 7F E5
  LDA #$7B                                    ; $C74A: A9 7B
  JSR $E68B                             ; $C74C: 20 8B E6
  LDA #$4A                                    ; $C74F: A9 4A
  LDY $042F                                   ; $C751: AC 2F 04
  BNE @DisplayUI                        ; $C754: D0 02
  LDA #$4D                                    ; $C756: A9 4D
@DisplayUI:
  JMP B1F_SetUI5                        ; $C758: 4C 93 F2
.endproc

; --- Find officer in active roster ($0664, 20 entries) ---
; A = officer ID to find; returns Y = index or $FF if not found
FindOfficerInRoster:
  LDY #$13                              ; $C75B: A0 13
@ScanLoop:
  CMP $0664,Y                           ; $C75D: D9 64 06
  BEQ @FindDone                         ; $C760: F0 03
  DEY                                   ; $C762: 88
  BPL @ScanLoop                         ; $C763: 10 F8
@FindDone:
  RTS                                   ; $C765: 60

.proc OfficerTransferCalc
; --- Transfer two officers (from $0514/$0516 with actions $0515/$0517) ---
  JSR CalcOfficerMeritLevels            ; $C766: 20 03 DB
  LDA $0514                             ; $C769: AD 14 05
  JSR FindOfficerInRoster               ; $C76C: 20 5B C7
  LDA $0515                             ; $C76F: AD 15 05
  JSR @DispatchOfficerAction            ; $C772: 20 82 C7
  LDA $0516                             ; $C775: AD 16 05
  JSR FindOfficerInRoster               ; $C778: 20 5B C7
  LDA $0517                             ; $C77B: AD 17 05
  JSR @DispatchOfficerAction            ; $C77E: 20 82 C7
  RTS                                   ; $C781: 60
; --- Dispatch officer action (A & 7 = action type) ---
@DispatchOfficerAction:
  AND #$07                              ; $C782: 29 07
  JSR B1F_CallbackDispatcher            ; $C784: 20 DE EA
; --- CallbackDispatcher table (8 entries) ---
  .word @Action_Nop                         ; $C787: $97 C7
  .word @Action_Nop2                        ; $C789: $98 C7
  .word @Action_TransferOfficer             ; $C78B: $99 C7
  .word @Action_AddToList                   ; $C78D: $DB C7
  .word @Action_ToggleSelect                ; $C78F: $1F C8
  .word @Action_ToggleSelect                ; $C791: $1F C8
  .word @Action_ToggleSelect                ; $C793: $1F C8
  .word @Action_ToggleSelect                ; $C795: $1F C8
@Action_Nop:  ; (dispatch callback target)
  RTS                                   ; $C797: 60
@Action_Nop2:  ; (dispatch callback target)
  RTS                                   ; $C798: 60
@Action_TransferOfficer:  ; (dispatch callback target)
  ; Transfer officer between groups; Y = roster index
  TYA                                   ; $C799: 98
  PHA                                   ; $C79A: 48
  LDA $0664,Y                           ; $C79B: B9 64 06
  STA $0B                               ; $C79E: 85 0B
  LDA $0514                             ; $C7A0: AD 14 05
  CMP $0664,Y                           ; $C7A3: D9 64 06
  BNE @SaveTarget                       ; $C7A6: D0 03
  LDA $0516                             ; $C7A8: AD 16 05
@SaveTarget:
  STA $0A                               ; $C7AB: 85 0A
  LDY #$2E                              ; $C7AD: A0 2E
  JSR B1F_BankedCallbackTrampoline      ; $C7AF: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A009                               ; $C7B2: $09 A0
  PLA                                         ; $C7B4: 68
  TAY                                         ; $C7B5: A8
  TYA                                         ; $C7B6: 98
  PHA                                         ; $C7B7: 48
  LDA $0664,Y                                 ; $C7B8: B9 64 06
  JSR B1F_GetOfficerRecordAddr                ; $C7BB: 20 D7 F2
  LDY #$0B                                    ; $C7BE: A0 0B
  LDA ($00),Y                                 ; $C7C0: B1 00
  ORA #$03                                    ; $C7C2: 09 03  ; set status bits 0-1
  STA ($00),Y                                 ; $C7C4: 91 00
  PLA                                         ; $C7C6: 68
  TAY                                         ; $C7C7: A8
  LDA $0628,Y                                 ; $C7C8: B9 28 06
  BPL @CallUpdateUI                   ; $C7CB: 10 03
  JMP @CallUpdateUI                   ; $C7CD: 4C D0 C7
@CallUpdateUI:
  STY $0000                             ; $C7D0: 8C 00 00
  LDY #$28                              ; $C7D3: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $C7D5: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A02A                               ; $C7D8: $2A A0
  RTS                                         ; $C7DA: 60
@Action_AddToList:  ; (dispatch callback target)
  ; Add officer to pending list; bit7 of $0628,Y selects list
  LDA $0628,Y                                 ; $C7DB: B9 28 06
  BPL @ScanPendingList2               ; $C7DE: 10 19
  LDX #$00                                    ; $C7E0: A2 00
@ScanLoop1:
  LDA $6F47,X                           ; $C7E2: BD 47 6F
  CMP #$FF                              ; $C7E5: C9 FF
  BEQ @AddToPendingList1                ; $C7E7: F0 04
  INX                                   ; $C7E9: E8
  JMP @ScanLoop1                        ; $C7EA: 4C E2 C7
@AddToPendingList1:
  LDA $0664,Y                           ; $C7ED: B9 64 06
  STA $6F47,X                           ; $C7F0: 9D 47 6F
  INC $0520                             ; $C7F3: EE 20 05
  JMP @FinishListAction                 ; $C7F6: 4C 0F C8
@ScanPendingList2:
  LDX #$00                              ; $C7F9: A2 00
@ScanLoop2:
  LDA $6F5B,X                           ; $C7FB: BD 5B 6F
  CMP #$FF                              ; $C7FE: C9 FF
  BEQ @AddToPendingList2                ; $C800: F0 04
  INX                                   ; $C802: E8
  JMP @ScanLoop2                        ; $C803: 4C FB C7
@AddToPendingList2:
  LDA $0664,Y                           ; $C806: B9 64 06
  STA $6F5B,X                           ; $C809: 9D 5B 6F
  INC $0521                             ; $C80C: EE 21 05
@FinishListAction:
  STA $20                               ; $C80F: 85 20
  STY $12                               ; $C811: 84 12
  LDY #$2A                              ; $C813: A0 2A
  JSR B1F_BankedCallbackTrampoline      ; $C815: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A00C                               ; $C818: $0C A0
  LDY $12                                     ; $C81A: A4 12
  JMP @CallUpdateUI                   ; $C81C: 4C D0 C7
@Action_ToggleSelect:  ; (dispatch callback target)
  ; Toggle officer selection (bit7 of $0628) and ally flag ($6FA1)
  JSR @AdjustStatsForY                  ; $C81F: 20 86 C8
  LDA $0628,Y                           ; $C822: B9 28 06
  EOR #$80                              ; $C825: 49 80
  STA $0628,Y                           ; $C827: 99 28 06
  LDA #$FF                              ; $C82A: A9 FF
  CPY army_slot_base                             ; $C82C: CC D8 04
  BNE @CheckCursor2                     ; $C82F: D0 03
  STA army_slot_base                             ; $C831: 8D D8 04
@CheckCursor2:
  CPY army_slot_base+4                             ; $C834: CC DC 04
  BNE @CheckAllyStatus                  ; $C837: D0 03
  STA army_slot_base+4                             ; $C839: 8D DC 04
@CheckAllyStatus:
  LDA $6FA1,Y                           ; $C83C: B9 A1 6F
  CMP #$FF                              ; $C83F: C9 FF
  BNE @ClearAllyFlag                    ; $C841: D0 08
  LDA #$04                              ; $C843: A9 04
  STA $6FA1,Y                           ; $C845: 99 A1 6F
  JMP @FinishListAction                 ; $C848: 4C 50 C8
@ClearAllyFlag:
  LDA #$FF                              ; $C84B: A9 FF
  STA $6FA1,Y                           ; $C84D: 99 A1 6F
@UpdateUI:
  ; Update exchange UI; $0507 = packed group IDs (lo/hi nibble)
  STY $12                               ; $C850: 84 12
  LDA $0507                             ; $C852: AD 07 05
  AND #$0F                              ; $C855: 29 0F
  STA $10                               ; $C857: 85 10
  LDA $0507                             ; $C859: AD 07 05
  LSR                                   ; $C85C: 4A
  LSR                                   ; $C85D: 4A
  LSR                                   ; $C85E: 4A
  LSR                                   ; $C85F: 4A
  STA $11                               ; $C860: 85 11
  LDX $10                               ; $C862: A6 10
  LDY $12                               ; $C864: A4 12
  LDA $0628,Y                           ; $C866: B9 28 06
  BPL @GetRuler                         ; $C869: 10 02
  LDX $11                               ; $C86B: A6 11
@GetRuler:
  TXA                                   ; $C86D: 8A
  JSR B1F_GetRulerDataPtr               ; $C86E: 20 68 F3
  LDY #$00                              ; $C871: A0 00
  LDA ($00),Y                           ; $C873: B1 00
  STA $30                               ; $C875: 85 30
  LDY $12                               ; $C877: A4 12
  LDA $0664,Y                           ; $C879: B9 64 06
  STA $31                               ; $C87C: 85 31
  LDY #$2A                              ; $C87E: A0 2A
  JSR B1F_BankedCallbackTrampoline      ; $C880: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A006                               ; $C883: $06 A0
  RTS                                         ; $C885: 60
; --- Adjust group stats for officer at roster index Y ---
; bit7 of $0628: 0=remove from group A ($051A) add to B ($051C)
;                1=remove from group B ($051C) add to A ($051A)
@AdjustStatsForY:
  TYA                                   ; $C886: 98
  TAX                                   ; $C887: AA
  PHA                                   ; $C888: 48
  LDA $0628,X                           ; $C889: BD 28 06
  BMI @SubtractFromGroupA               ; $C88C: 30 48
  DEC $051E                             ; $C88E: CE 1E 05
  LDA $0664,X                           ; $C891: BD 64 06
  JSR B1F_GetOfficerRecordAddr          ; $C894: 20 D7 F2
  LDY #$08                              ; $C897: A0 08
  LDA ($00),Y                           ; $C899: B1 00
  STA $02                               ; $C89B: 85 02
  INY                                   ; $C89D: C8
  LDA ($00),Y                           ; $C89E: B1 00
  AND #$03                              ; $C8A0: 29 03
  STA $03                               ; $C8A2: 85 03
  LDA $051A                             ; $C8A4: AD 1A 05
  SEC                                   ; $C8A7: 38
  SBC $02                               ; $C8A8: E5 02
  STA $051A                             ; $C8AA: 8D 1A 05
  LDA $051B                             ; $C8AD: AD 1B 05
  SBC $03                               ; $C8B0: E5 03
  STA $051B                             ; $C8B2: 8D 1B 05
  BCS @AddToGroupB                      ; $C8B5: B0 08
  LDA #$00                              ; $C8B7: A9 00
  STA $051A                             ; $C8B9: 8D 1A 05
  STA $051B                             ; $C8BC: 8D 1B 05
@AddToGroupB:
  INC $051F                             ; $C8BF: EE 1F 05
  LDA $051C                             ; $C8C2: AD 1C 05
  CLC                                   ; $C8C5: 18
  ADC $02                               ; $C8C6: 65 02
  STA $051C                             ; $C8C8: 8D 1C 05
  LDA $051D                             ; $C8CB: AD 1D 05
  ADC $03                               ; $C8CE: 65 03
  STA $051D                             ; $C8D0: 8D 1D 05
  JMP @RestoreY                         ; $C8D3: 4C 1B C9
@SubtractFromGroupA:
  DEC $051F                             ; $C8D6: CE 1F 05
  LDA $0664,X                           ; $C8D9: BD 64 06
  JSR B1F_GetOfficerRecordAddr          ; $C8DC: 20 D7 F2
  LDY #$08                              ; $C8DF: A0 08
  LDA ($00),Y                           ; $C8E1: B1 00
  STA $02                               ; $C8E3: 85 02
  INY                                   ; $C8E5: C8
  LDA ($00),Y                           ; $C8E6: B1 00
  AND #$03                              ; $C8E8: 29 03
  STA $03                               ; $C8EA: 85 03
  LDA $051C                             ; $C8EC: AD 1C 05
  SEC                                   ; $C8EF: 38
  SBC $02                               ; $C8F0: E5 02
  STA $051C                             ; $C8F2: 8D 1C 05
  LDA $051D                             ; $C8F5: AD 1D 05
  SBC $03                               ; $C8F8: E5 03
  STA $051D                             ; $C8FA: 8D 1D 05
  BCS @AddToGroupB2                     ; $C8FD: B0 08
  LDA #$00                              ; $C8FF: A9 00
@ClampZero:
  STA $051C                             ; $C901: 8D 1C 05
  STA $051D                             ; $C904: 8D 1D 05
@AddToGroupB2:
  INC $051E                             ; $C907: EE 1E 05
  LDA $051A                             ; $C90A: AD 1A 05
  CLC                                   ; $C90D: 18
  ADC $02                               ; $C90E: 65 02
  STA $051A                             ; $C910: 8D 1A 05
  LDA $051B                             ; $C913: AD 1B 05
  ADC $03                               ; $C916: 65 03
  STA $051B                             ; $C918: 8D 1B 05
@RestoreY:
  PLA                                   ; $C91B: 68
  TAY                                   ; $C91C: A8
  RTS                                   ; $C91D: 60
; --- Adjust group stats for officer at $0509 index ---
@AdjustStatsByIndex:
  LDX $0509                             ; $C91E: AE 09 05
  LDA $0628,X                           ; $C921: BD 28 06
  BMI @SubtractFromGroupA2              ; $C924: 30 34
  DEC $051E                             ; $C926: CE 1E 05
  LDA $0664,X                           ; $C929: BD 64 06
  JSR B1F_GetOfficerRecordAddr          ; $C92C: 20 D7 F2
  LDY #$08                              ; $C92F: A0 08
  LDA ($00),Y                           ; $C931: B1 00
  STA $02                               ; $C933: 85 02
  INY                                   ; $C935: C8
  LDA ($00),Y                           ; $C936: B1 00
  AND #$03                              ; $C938: 29 03
  STA $03                               ; $C93A: 85 03
  LDA $051A                             ; $C93C: AD 1A 05
  SEC                                   ; $C93F: 38
  SBC $02                               ; $C940: E5 02
  STA $051A                             ; $C942: 8D 1A 05
  LDA $051B                             ; $C945: AD 1B 05
  SBC $03                               ; $C948: E5 03
  STA $051B                             ; $C94A: 8D 1B 05
  BCS @RestoreY                         ; $C94D: B0 3C
  LDA #$00                              ; $C94F: A9 00
  STA $051A                             ; $C951: 8D 1A 05
  STA $051B                             ; $C954: 8D 1B 05
  JMP @RestoreY                         ; $C957: 4C 8B C9
@SubtractFromGroupA2:
  DEC $051F                             ; $C95A: CE 1F 05
  LDA $0664,X                           ; $C95D: BD 64 06
  JSR B1F_GetOfficerRecordAddr          ; $C960: 20 D7 F2
  LDY #$08                              ; $C963: A0 08
  LDA ($00),Y                           ; $C965: B1 00
  STA $02                               ; $C967: 85 02
  INY                                   ; $C969: C8
  LDA ($00),Y                           ; $C96A: B1 00
  AND #$03                              ; $C96C: 29 03
  STA $03                               ; $C96E: 85 03
  LDA $051C                             ; $C970: AD 1C 05
  SEC                                   ; $C973: 38
  SBC $02                               ; $C974: E5 02
  STA $051C                             ; $C976: 8D 1C 05
  LDA $051D                             ; $C979: AD 1D 05
  SBC $03                               ; $C97C: E5 03
  STA $051D                             ; $C97E: 8D 1D 05
  BCS @RestoreY                         ; $C981: B0 08
  LDA #$00                              ; $C983: A9 00
  STA $051C                             ; $C985: 8D 1C 05
  STA $051D                             ; $C988: 8D 1D 05
  RTS                                   ; $C98B: 60
.endproc

.proc OfficerExchangeConfirmDispatch
  ; Dispatch for $0500==$0C: officer exchange confirmation screen
  ; States: 0=Init, 1=Select, 2=Menu, 3=Confirm, 4=Execute, 5=Cancel
  LDA $0501                             ; $C98C: AD 01 05
  JSR B1F_CallbackDispatcher            ; $C98F: 20 DE EA
; --- CallbackDispatcher table (6 entries) ---
  .word @State_Init                         ; $C992: $9E C9
  .word @State_Select                       ; $C994: $AD C9
  .word @State_Menu                         ; $C996: $C3 C9
  .word @State_Confirm                      ; $C998: $FE C9
  .word @State_Execute                      ; $C99A: $13 CA
  .word @State_Cancel                       ; $C99C: $2F CA
@State_Init:
  JSR B1F_BankPpuInit                   ; $C99E: 20 7F E5
  LDA #$D5                              ; $C9A1: A9 D5
  JSR B1F_SetUI5                        ; $C9A3: 20 93 F2
  JSR @InitExchangeDisplay              ; $C9A6: 20 F8 CA
  INC $0501                             ; $C9A9: EE 01 05
  RTS                                   ; $C9AC: 60
@State_Select:
  JSR CheckExchangePossible                             ; $C9AD: 20 27 DF
  BCC @Done                             ; $C9B0: 90 10
  LDA $007E                             ; $C9B2: AD 7E 00
  BNE @Done                             ; $C9B5: D0 0B
  INC $0501                             ; $C9B7: EE 01 05
  JSR @BuildExchangeMsg                 ; $C9BA: 20 53 CA
  LDA #$04                              ; $C9BD: A9 04
  JSR B1F_SetUI4                        ; $C9BF: 20 8B F2
@Done:
  RTS                                   ; $C9C2: 60
@State_Menu:
  LDA $007E                             ; $C9C3: AD 7E 00
  BNE @Done                             ; $C9C6: D0 FA
  LDA #$E1                              ; $C9C8: A9 E1
  STA $E6                               ; $C9CA: 85 E6
  LDA #$E1                              ; $C9CC: A9 E1
  STA $E8                               ; $C9CE: 85 E8
  LDA #$08                              ; $C9D0: A9 08
  STA $B2                               ; $C9D2: 85 B2
  LDA #$09                              ; $C9D4: A9 09
  STA $B3                               ; $C9D6: 85 B3
  LDA #$02                              ; $C9D8: A9 02
  STA $B4                               ; $C9DA: 85 B4
  LDA #$03                              ; $C9DC: A9 03
  STA $B5                               ; $C9DE: 85 B5
  LDA #$00                              ; $C9E0: A9 00
  LDX #$1F                              ; $C9E2: A2 1F
@ClearLoop:
  STA exchange_ruler_id,X                           ; $C9E4: 9D 4C 04
  DEX                                   ; $C9E7: CA
  BPL @ClearLoop                        ; $C9E8: 10 FA
  LDA #$00                              ; $C9EA: A9 00
  STA $8E                               ; $C9EC: 85 8E
  LDA #$50                              ; $C9EE: A9 50
  STA $90                               ; $C9F0: 85 90
  INC $0501                             ; $C9F2: EE 01 05
  JSR @SetupPpuRegisters                ; $C9F5: 20 41 CA
  LDA #$18                              ; $C9F8: A9 18
  JSR B1F_SoundWrapperC                 ; $C9FA: 20 83 E6
  RTS                                   ; $C9FD: 60
@State_Confirm:
  JSR RecalcExchangeStats               ; $C9FE: 20 29 CC
  JSR CheckExchangePossible                             ; $CA01: 20 27 DF
  BCC @Done                             ; $CA04: 90 0C
  JSR DrawExchangeArrows_Right                             ; $CA06: 20 63 DC
  LDA $81                               ; $CA09: A5 81
  AND #$01                              ; $CA0B: 29 01
  BEQ @Done                             ; $CA0D: F0 03
  INC $0501                             ; $CA0F: EE 01 05
@CA12:
  RTS                                   ; $CA12: 60
@State_Execute:
  JSR RecalcExchangeStats               ; $CA13: 20 29 CC
  JSR @AlwaysSuccess                    ; $CA16: 20 51 CA
  BCC @AdvanceState                     ; $CA19: 90 0B  ; never taken (carry always set)
  LDA #$0F                              ; $CA1B: A9 0F
  STA $0500                             ; $CA1D: 8D 00 05
  LDA #$00                              ; $CA20: A9 00
  STA $0501                             ; $CA22: 8D 01 05
  RTS                                   ; $CA25: 60
@AdvanceState:
  INC $0501                             ; $CA26: EE 01 05
  LDA #$D5                              ; $CA29: A9 D5
  JSR B1F_SetUI5                        ; $CA2B: 20 93 F2
  RTS                                   ; $CA2E: 60
@State_Cancel:
  JSR RecalcExchangeStats               ; $CA2F: 20 29 CC
  JSR CheckExchangePossible                             ; $CA32: 20 27 DF
  BCC @CA12                             ; $CA35: 90 09
  LDA $81                               ; $CA37: A5 81
  AND #$01                              ; $CA39: 29 01
  BEQ @CA12                             ; $CA3B: F0 03
  DEC $0501                             ; $CA3D: CE 01 05  ; back to State_Execute
@CA40:
  RTS                                   ; $CA40: 60
@SetupPpuRegisters:
  LDA #$E0                              ; $CA41: A9 E0
  STA $0310                             ; $CA43: 8D 10 03
  LDA #$DB                              ; $CA46: A9 DB
  STA $0311                             ; $CA48: 8D 11 03
  LDA #$00                              ; $CA4B: A9 00
  STA $0300                             ; $CA4D: 8D 00 03
  RTS                                   ; $CA50: 60
@AlwaysSuccess:
  SEC                                   ; $CA51: 38
  RTS                                   ; $CA52: 60
@BuildExchangeMsg:
  ; Build exchange summary message at $0380 from indexed text pairs
  ; $0514 = message index (0-3); copies 14+15 bytes from two pointer tables
  LDX #$00                              ; $CA53: A2 00
  LDA $0514                             ; $CA55: AD 14 05
  ASL                                   ; $CA58: 0A
  TAY                                   ; $CA59: A8
  LDA $CA91,Y                           ; $CA5A: B9 91 CA
  STA $00                               ; $CA5D: 85 00
  LDA $CA92,Y                           ; $CA5F: B9 92 CA
  STA $01                               ; $CA62: 85 01
  LDA $CA99,Y                           ; $CA64: B9 99 CA
  STA $02                               ; $CA67: 85 02
  LDA $CA9A,Y                           ; $CA69: B9 9A CA
  STA $03                               ; $CA6C: 85 03
  LDY #$00                              ; $CA6E: A0 00
@CopyLoop1:
  LDA ($00),Y                           ; $CA70: B1 00
  STA $0380,X                           ; $CA72: 9D 80 03
  INX                                   ; $CA75: E8
  INY                                   ; $CA76: C8
  CPY #$0E                              ; $CA77: C0 0E
  BCC @CopyLoop1                        ; $CA79: 90 F5
  LDY #$00                              ; $CA7B: A0 00
@CopyLoop2:
  LDA ($02),Y                           ; $CA7D: B1 02
  STA $0380,X                           ; $CA7F: 9D 80 03
  INX                                   ; $CA82: E8
  INY                                   ; $CA83: C8
  CPY #$0F                              ; $CA84: C0 0F
  BCC @CopyLoop2                        ; $CA86: 90 F5
  LDA $007E                             ; $CA88: AD 7E 00
  ORA #$04                              ; $CA8B: 09 04
  STA $007E                             ; $CA8D: 8D 7E 00
  RTS                                   ; $CA90: 60
; --- Message pointer tables (4 entries each) ---
@MsgPtrTable1:
  .word @Msg0_Part1                         ; $CA91: $A1 CA
  .word @Msg1_Part1                         ; $CA93: $AF CA
  .word @Msg2_Part1                         ; $CA95: $BD CA
  .word @Msg2_Part1                         ; $CA97: $BD CA  ; msg3 = msg2
@MsgPtrTable2:
  .word @Msg0_Part2                         ; $CA99: $DA CA
  .word @Msg1_Part2                         ; $CA9B: $CB CA
  .word @Msg2_Part2                         ; $CA9D: $E9 CA
  .word @Msg2_Part2                         ; $CA9F: $E9 CA  ; msg3 = msg2
; --- Message text data ---
@Msg0_Part1:
  .byte $04,$25,$EA,$E0,$E1,$E2,$E3,$04,$26,$0A,$F0,$F1,$F2,$F3; $CAA1
@Msg1_Part1:
  .byte $04,$25,$EA,$E4,$E5,$E6,$E7,$04,$26,$0A,$F4,$F5,$F6,$F7; $CAAF
@Msg2_Part1:
  .byte $04,$25,$EA,$EC,$ED,$EE,$EF,$04,$26,$0A,$FC,$FD,$FE,$FE; $CABD
@Msg1_Part2:
  .byte $04,$25,$F8,$E8,$E9,$EA,$EB,$04,$26,$18,$F8,$F9,$FA,$FB,$FF; $CACB
@Msg0_Part2:
  .byte $04,$25,$F8,$E4,$E5,$E6,$E7,$04,$26,$18,$F4,$F5,$F6,$F7,$FF; $CADA
@Msg2_Part2:
  .byte $04,$25,$F8,$EC,$ED,$EE,$EF,$04,$26,$18,$FC,$FD,$FE,$FE,$FF; $CAE9
@InitExchangeDisplay:
  ; Recalculate stats, copy to display buffer, count pending lists
  JSR @RecalcRemainingStats             ; $CAF8: 20 6E CB
  LDA $051A                             ; $CAFB: AD 1A 05
  STA exchange_disp_base+3                             ; $CAFE: 8D 4F 04
  LDA $051B                             ; $CB01: AD 1B 05
  STA exchange_disp_base+4                             ; $CB04: 8D 50 04
  LDA #$00                              ; $CB07: A9 00
  STA exchange_disp_base+2                             ; $CB09: 8D 4E 04
  STA exchange_disp_base+5                             ; $CB0C: 8D 51 04
  LDA $051C                             ; $CB0F: AD 1C 05
  STA exchange_ruler_id                             ; $CB12: 8D 4C 04
  LDA $051D                             ; $CB15: AD 1D 05
  STA exchange_disp_base+1                             ; $CB18: 8D 4D 04
  LDA $051E                             ; $CB1B: AD 1E 05
  STA exchange_disp_base+9                             ; $CB1E: 8D 55 04
  LDA $051F                             ; $CB21: AD 1F 05
  STA exchange_disp_base+6                             ; $CB24: 8D 52 04
  LDA #$00                              ; $CB27: A9 00
  STA exchange_disp_base+7                             ; $CB29: 8D 53 04
  STA exchange_disp_base+8                             ; $CB2C: 8D 54 04
  STA exchange_disp_base+10                             ; $CB2F: 8D 56 04
  STA exchange_disp_base+11                             ; $CB32: 8D 57 04
  LDY #$00                              ; $CB35: A0 00
  LDX #$00                              ; $CB37: A2 00
@CountLoop1:
  LDA $6F47,Y                           ; $CB39: B9 47 6F
  CMP #$FF                              ; $CB3C: C9 FF
  BEQ @NextSlot1                        ; $CB3E: F0 01
  INX                                   ; $CB40: E8
@NextSlot1:
  INY                                   ; $CB41: C8
  CPY #$14                              ; $CB42: C0 14
  BCC @CountLoop1                       ; $CB44: 90 F3
  STX exchange_disp_base+15                             ; $CB46: 8E 5B 04
  LDX #$00                              ; $CB49: A2 00
  STX exchange_disp_base+16                             ; $CB4B: 8E 5C 04
  STX exchange_disp_base+17                             ; $CB4E: 8E 5D 04
  LDY #$00                              ; $CB51: A0 00
  LDX #$00                              ; $CB53: A2 00
@CountLoop2:
  LDA $6F5B,Y                           ; $CB55: B9 5B 6F
  CMP #$FF                              ; $CB58: C9 FF
  BEQ @NextSlot2                        ; $CB5A: F0 01
  INX                                   ; $CB5C: E8
@NextSlot2:
  INY                                   ; $CB5D: C8
  CPY #$14                              ; $CB5E: C0 14
  BCC @CountLoop2                       ; $CB60: 90 F3
  STX exchange_disp_base+12                             ; $CB62: 8E 58 04
  LDX #$00                              ; $CB65: A2 00
  STX exchange_disp_base+13                             ; $CB67: 8E 59 04
  STX exchange_disp_base+14                             ; $CB6A: 8E 5A 04
  RTS                                   ; $CB6D: 60
@RecalcRemainingStats:
  ; Subtract selected officer stats from ruler totals ($051A-$051F)
  ; Scans roster 0-19; bit7 of $0628: 0=group A, 1=group B
  LDA #$00                              ; $CB6E: A9 00
  STA $0A                               ; $CB70: 85 0A
  STA $0B                               ; $CB72: 85 0B
  STA $0C                               ; $CB74: 85 0C
@ScanLoop1:
  TAY                                   ; $CB76: A8
  PHA                                   ; $CB77: 48
  LDA $0628,Y                           ; $CB78: B9 28 06
  BMI @NextOfficer1                     ; $CB7B: 30 1E
  LDA $0664,Y                           ; $CB7D: B9 64 06
  CMP #$FF                              ; $CB80: C9 FF
  BEQ @NextOfficer1                     ; $CB82: F0 17
  JSR B1F_GetOfficerRecordAddr          ; $CB84: 20 D7 F2
  LDY #$08                              ; $CB87: A0 08
  LDA ($00),Y                           ; $CB89: B1 00
  CLC                                   ; $CB8B: 18
  ADC $0A                               ; $CB8C: 65 0A
  STA $0A                               ; $CB8E: 85 0A
  INY                                   ; $CB90: C8
  LDA ($00),Y                           ; $CB91: B1 00
  AND #$03                              ; $CB93: 29 03
  ADC $0B                               ; $CB95: 65 0B
  STA $0B                               ; $CB97: 85 0B
  INC $0C                               ; $CB99: E6 0C
@NextOfficer1:
  PLA                                   ; $CB9B: 68
  CLC                                   ; $CB9C: 18
  ADC #$01                              ; $CB9D: 69 01
  CMP #$14                              ; $CB9F: C9 14
  BCC @ScanLoop1                        ; $CBA1: 90 D3
  LDA $051A                             ; $CBA3: AD 1A 05
  SEC                                   ; $CBA6: 38
  SBC $0A                               ; $CBA7: E5 0A
  STA $051A                             ; $CBA9: 8D 1A 05
  LDA $051B                             ; $CBAC: AD 1B 05
  SBC $0B                               ; $CBAF: E5 0B
  STA $051B                             ; $CBB1: 8D 1B 05
  BCS @ClampCount1                      ; $CBB4: B0 08
  LDA #$00                              ; $CBB6: A9 00
  STA $051A                             ; $CBB8: 8D 1A 05
  STA $051B                             ; $CBBB: 8D 1B 05
@ClampCount1:
  LDA $051E                             ; $CBBE: AD 1E 05
  SEC                                   ; $CBC1: 38
  SBC $0C                               ; $CBC2: E5 0C
  BCS @StoreCount1                      ; $CBC4: B0 02
  LDA #$00                              ; $CBC6: A9 00
@StoreCount1:
  STA $051E                             ; $CBC8: 8D 1E 05
  LDA #$00                              ; $CBCB: A9 00
  STA $0A                               ; $CBCD: 85 0A
  STA $0B                               ; $CBCF: 85 0B
  STA $0C                               ; $CBD1: 85 0C
@ScanLoop2:
  TAY                                   ; $CBD3: A8
  PHA                                   ; $CBD4: 48
  LDA $0628,Y                           ; $CBD5: B9 28 06
  BPL @NextOfficer2                     ; $CBD8: 10 1E
  LDA $0664,Y                           ; $CBDA: B9 64 06
  CMP #$FF                              ; $CBDD: C9 FF
  BEQ @NextOfficer2                     ; $CBDF: F0 17
  JSR B1F_GetOfficerRecordAddr          ; $CBE1: 20 D7 F2
  LDY #$08                              ; $CBE4: A0 08
  LDA ($00),Y                           ; $CBE6: B1 00
  CLC                                   ; $CBE8: 18
  ADC $0A                               ; $CBE9: 65 0A
  STA $0A                               ; $CBEB: 85 0A
  INY                                   ; $CBED: C8
  LDA ($00),Y                           ; $CBEE: B1 00
  AND #$03                              ; $CBF0: 29 03
  ADC $0B                               ; $CBF2: 65 0B
  STA $0B                               ; $CBF4: 85 0B
  INC $0C                               ; $CBF6: E6 0C
@NextOfficer2:
  PLA                                   ; $CBF8: 68
  CLC                                   ; $CBF9: 18
  ADC #$01                              ; $CBFA: 69 01
  CMP #$14                              ; $CBFC: C9 14
  BCC @ScanLoop2                        ; $CBFE: 90 D3
  LDA $051C                             ; $CC00: AD 1C 05
  SEC                                   ; $CC03: 38
  SBC $0A                               ; $CC04: E5 0A
  STA $051C                             ; $CC06: 8D 1C 05
  LDA $051D                             ; $CC09: AD 1D 05
  SBC $0B                               ; $CC0C: E5 0B
  STA $051D                             ; $CC0E: 8D 1D 05
  BCS @ClampCount2                      ; $CC11: B0 08
  LDA #$00                              ; $CC13: A9 00
  STA $051C                             ; $CC15: 8D 1C 05
  STA $051D                             ; $CC18: 8D 1D 05
@ClampCount2:
  LDA $051F                             ; $CC1B: AD 1F 05
  SEC                                   ; $CC1E: 38
  SBC $0C                               ; $CC1F: E5 0C
  BCS @StoreCount2                      ; $CC21: B0 02
  LDA #$00                              ; $CC23: A9 00
@StoreCount2:
  STA $051F                             ; $CC25: 8D 1F 05
  RTS                                   ; $CC28: 60
.endproc

.proc RecalcExchangeStats
  ; Recalculate ruler display stats for exchange screen
  ; $0507 = packed ruler IDs (lo nibble = ruler A, hi nibble = ruler B)
  ; Writes digit data to $0200+ via $007C index
  LDY #$31                              ; $CC29: A0 31
  JSR B1F_SwitchBank8_B                 ; $CC2B: 20 5F F2
  LDA #$00                              ; $CC2E: A9 00
  STA $0A                               ; $CC30: 85 0A
  LDA $005E                             ; $CC32: AD 5E 00
  AND #$01                              ; $CC35: 29 01
  BNE @SwapOrder                        ; $CC37: D0 06
  JSR @CalcHighNibble                   ; $CC39: 20 45 CC
  JMP @CalcLowNibble                    ; $CC3C: 4C 5A CC
@SwapOrder:
  JSR @CalcLowNibble                    ; $CC3F: 20 5A CC
  JMP @CalcHighNibble                   ; $CC42: 4C 45 CC
@CalcHighNibble:
  ; Process high nibble of $0507 (ruler B); tile base $40, X offset $00
  LDA #$40                              ; $CC45: A9 40
  STA $0B                               ; $CC47: 85 0B
  LDA #$00                              ; $CC49: A9 00
  STA $0C                               ; $CC4B: 85 0C
  LDA $0507                             ; $CC4D: AD 07 05
  LSR                                   ; $CC50: 4A
  LSR                                   ; $CC51: 4A
  LSR                                   ; $CC52: 4A
  LSR                                   ; $CC53: 4A
  JSR @GetRulerValue                    ; $CC54: 20 6D CC
  STA $AF                               ; $CC57: 85 AF
  RTS                                   ; $CC59: 60
@CalcLowNibble:
  ; Process low nibble of $0507 (ruler A); tile base $80, X offset $70
  LDA #$80                              ; $CC5A: A9 80
  STA $0B                               ; $CC5C: 85 0B
  LDA #$70                              ; $CC5E: A9 70
  STA $0C                               ; $CC60: 85 0C
  LDA $0507                             ; $CC62: AD 07 05
  AND #$0F                              ; $CC65: 29 0F
  JSR @GetRulerValue                    ; $CC67: 20 6D CC
  STA $B0                               ; $CC6A: 85 B0
  RTS                                   ; $CC6C: 60
@GetRulerValue:
  ; Get ruler base value, multiply by 13, index into stat table at $8DB4
  ; Then render 12 digits to OAM buffer
  JSR B1F_GetRulerDataPtr               ; $CC6D: 20 68 F3
  LDY #$00                              ; $CC70: A0 00
  LDA ($00),Y                           ; $CC72: B1 00
  STA $00                               ; $CC74: 85 00
  LDA #$00                              ; $CC76: A9 00
  STA $01                               ; $CC78: 85 01
  STA $02                               ; $CC7A: 85 02
  LDA #$0D                              ; $CC7C: A9 0D
  STA $03                               ; $CC7E: 85 03
  JSR B1F_MathMul24x8                   ; $CC80: 20 E9 EB
  LDA $06                               ; $CC83: A5 06
  CLC                                   ; $CC85: 18
  ADC #$B4                              ; $CC86: 69 B4
  STA $06                               ; $CC88: 85 06
  LDA $07                               ; $CC8A: A5 07
  ADC #$8D                              ; $CC8C: 69 8D
  STA $07                               ; $CC8E: 85 07
  LDY #$00                              ; $CC90: A0 00
  LDA ($06),Y                           ; $CC92: B1 06
  PHA                                   ; $CC94: 48
  JSR @IncPtr                           ; $CC95: 20 DF CC
  LDA #$00                              ; $CC98: A9 00
@DigitLoop:
  PHA                                   ; $CC9A: 48
  JSR @RenderDigit                      ; $CC9B: 20 AA CC
  PLA                                   ; $CC9E: 68
  INC $0A                               ; $CC9F: E6 0A
  CLC                                   ; $CCA1: 18
  ADC #$01                              ; $CCA2: 69 01
  CMP #$0C                              ; $CCA4: C9 0C
  BCC @DigitLoop                        ; $CCA6: 90 F2
  PLA                                   ; $CCA8: 68
  RTS                                   ; $CCA9: 60
@RenderDigit:
  ; Render one stat digit to OAM buffer at $0200+X
  ; Reads digit value from ($06), skips if $FF
  LDY #$00                              ; $CCAA: A0 00
  LDA ($06),Y                           ; $CCAC: B1 06
  JSR @IncPtr                           ; $CCAE: 20 DF CC
  CMP #$FF                              ; $CCB1: C9 FF
  BEQ @DigitDone                        ; $CCB3: F0 29
  LDY $0A                               ; $CCB5: A4 0A
  LDX $007C                             ; $CCB7: AE 7C 00
  CLC                                   ; $CCBA: 18
  ADC $0B                               ; $CCBB: 65 0B
  STA $0201,X                           ; $CCBD: 9D 01 02  ; tile index
  LDA @DigitYTable,Y                    ; $CCC0: B9 E6 CC
  SEC                                   ; $CCC3: 38
@SubtractLoop:
  SBC #$01                              ; $CCC4: E9 01
  STA $0200,X                           ; $CCC6: 9D 00 02  ; Y position
  LDA @DigitXTable,Y                    ; $CCC9: B9 FE CC
  CLC                                   ; $CCCC: 18
  ADC $0C                               ; $CCCD: 65 0C
  STA $0203,X                           ; $CCCF: 9D 03 02  ; X position
  LDA #$00                              ; $CCD2: A9 00
  STA $0202,X                           ; $CCD4: 9D 02 02  ; attribute
  INX                                   ; $CCD7: E8
  INX                                   ; $CCD8: E8
  INX                                   ; $CCD9: E8
@SkipDigit:
  INX                                   ; $CCDA: E8
  STX $007C                             ; $CCDB: 8E 7C 00
@DigitDone:
  RTS                                   ; $CCDE: 60
@IncPtr:
  INC $06                               ; $CCDF: E6 06
  BNE @DigitDone                        ; $CCE1: D0 02
  INC $07                               ; $CCE3: E6 07
  RTS                                   ; $CCE5: 60
; --- Digit position tables (12 entries used by code, extra padding in ROM) ---
@DigitYTable:
  .byte $10,$10,$18,$18,$10,$10,$18,$18,$10,$10,$18,$18; $CCE6: entries 0-11
  .byte $10,$10,$18,$18,$10,$10,$18,$18,$10,$10,$18,$18; $CCF2: entries 12-23 (unused)
@DigitXTable:
  .byte $28,$30,$28,$30,$38,$40,$38,$40,$48,$50,$48,$50; $CCFE: entries 0-11
  .byte $28,$30,$28,$30,$38,$40,$38,$40                   ; $CD0A: entries 12-19 (unused)
.endproc

.proc OfficerExchangeSelectDispatch
  ; Game mode $0D: Officer exchange selection and transfer
  ; State machine on $0501: 0=Init, 1=Select, 2=Menu, 3=Confirm, 4=Execute, 5=Cancel, 6=Finalize
  LDA $0501                             ; $CD16: AD 01 05
  JSR B1F_CallbackDispatcher            ; $CD19: 20 DE EA
; --- CallbackDispatcher table (7 entries) ---
  .word @State_Init                         ; $CD1C: $2A CD
  .word @State_Select                       ; $CD1E: $52 CD
  .word @State_Menu                         ; $CD20: $F2 CD
  .word @State_Confirm                      ; $CD22: $56 CE
  .word @State_Execute                      ; $CD24: $76 CE
  .word @State_Cancel                       ; $CD26: $9E CE
  .word @State_Finalize                     ; $CD28: $09 CF
@State_Init:
  ; Build eligible officer list; if slot 0 empty, exit to mode $0F
  JSR RecalcExchangeStats               ; $CD2A: 20 29 CC
  JSR @BuildOfficerList                  ; $CD2D: 20 E1 D0
  LDA #$FF                              ; $CD30: A9 FF
  STA officer_sel_list,X                           ; $CD32: 9D 2C 04
@CheckSlot:
  TXA                                   ; $CD35: 8A
  BNE @ShowUI                           ; $CD36: D0 0E
@ExitToMenu:
  LDA $050B                             ; $CD38: AD 0B 05
@SetPhase:
  AND #$0F                              ; $CD3B: 29 0F
  STA $0501                             ; $CD3D: 8D 01 05
  LDA #$0F                              ; $CD40: A9 0F
  STA $0500                             ; $CD42: 8D 00 05
  RTS                                   ; $CD45: 60
@ShowUI:
  LDA #$DC                              ; $CD46: A9 DC
  JSR B1F_SetUI5                        ; $CD48: 20 93 F2
  JSR @LoadExchangeRulerId              ; $CD4B: 20 C3 D0
  INC $0501                             ; $CD4E: EE 01 05
@Done:
  RTS                                   ; $CD51: 60
@State_Select:
  ; Handle officer selection input; on confirm, assign officers to new ruler
  JSR RecalcExchangeStats               ; $CD52: 20 29 CC
  JSR CheckExchangePossible                             ; $CD55: 20 27 DF
  BCC @Done                             ; $CD58: 90 09
  JSR DrawExchangeArrows_Right                             ; $CD5A: 20 63 DC
@CheckConfirm:
  LDA $81                               ; $CD5D: A5 81
  AND #$01                              ; $CD5F: 29 01
  BNE @AdvanceState                     ; $CD61: D0 01
@SelectDone:
  RTS                                   ; $CD63: 60
@AdvanceState:
  INC $0501                             ; $CD64: EE 01 05
  LDA #$00                              ; $CD67: A9 00
  STA menu_cursor_col                             ; $CD69: 8D 24 04
  STA menu_cursor_page                             ; $CD6C: 8D 25 04
  LDA $050B                             ; $CD6F: AD 0B 05
  AND #$10                              ; $CD72: 29 10
  ASL                                   ; $CD74: 0A
  ASL                                   ; $CD75: 0A
  ASL                                   ; $CD76: 0A
  STA $0504                             ; $CD77: 8D 04 05
  JSR $BB84                             ; $CD7A: 20 84 BB
  INC $050A                             ; $CD7D: EE 0A 05
  LDA $050A                             ; $CD80: AD 0A 05
  BEQ @GetRuler                         ; $CD83: F0 17
  TAY                                   ; $CD85: A8
  LDA #$1E                              ; $CD86: A9 1E
  STA officer_sel_list,Y                           ; $CD88: 99 2C 04
  DEY                                   ; $CD8B: 88
@ScanLoop:
  LDA $0550,Y                           ; $CD8C: B9 50 05
  CMP #$0A                              ; $CD8F: C9 0A
  BCS @NextSlot                         ; $CD91: B0 06
  LDA #$D7                              ; $CD93: A9 D7
  JSR B1F_SetUI2                        ; $CD95: 20 83 F2
  RTS                                   ; $CD98: 60
@NextSlot:
  DEY                                   ; $CD99: 88
  BPL @ScanLoop                         ; $CD9A: 10 F0
@GetRuler:
  LDA $0507                             ; $CD9C: AD 07 05
  LDY $050B                             ; $CD9F: AC 0B 05
  CPY #$02                              ; $CDA2: C0 02
  BEQ @GetRulerValue                    ; $CDA4: F0 04
  LSR                                   ; $CDA6: 4A
  LSR                                   ; $CDA7: 4A
  LSR                                   ; $CDA8: 4A
  LSR                                   ; $CDA9: 4A
@GetRulerValue:
  AND #$0F                              ; $CDAA: 29 0F
  JSR B1F_GetRulerDataPtr               ; $CDAC: 20 68 F3
  LDY #$00                              ; $CDAF: A0 00
  LDA ($00),Y                           ; $CDB1: B1 00
  STA $03                               ; $CDB3: 85 03
  JSR @BuildOfficerList                  ; $CDB5: 20 E1 D0
  LDX #$00                              ; $CDB8: A2 00
@AssignLoop:
  LDA officer_sel_list,X                           ; $CDBA: BD 2C 04
  CMP #$FE                              ; $CDBD: C9 FE
  BCS @ResetState                       ; $CDBF: B0 1A
  CMP $03                               ; $CDC1: C5 03
  BEQ @MarkOfficer                      ; $CDC3: F0 1E
  JSR B1F_GetOfficerRecordAddr          ; $CDC5: 20 D7 F2
  LDY #$0B                              ; $CDC8: A0 0B
  LDA ($00),Y                           ; $CDCA: B1 00
  AND #$FC                              ; $CDCC: 29 FC
  STA ($00),Y                           ; $CDCE: 91 00
  LDY #$05                              ; $CDD0: A0 05
  LDA $050E                             ; $CDD2: AD 0E 05
  STA ($00),Y                           ; $CDD5: 91 00
  INX                                   ; $CDD7: E8
  JMP @AssignLoop                        ; $CDD8: 4C BA CD
@ResetState:
  LDA #$00                              ; $CDDB: A9 00
  STA $0501                             ; $CDDD: 8D 01 05
  JMP @ExitToMenu                       ; $CDE0: 4C 38 CD
@MarkOfficer:
  ; Officer belongs to ruler: set status bits 0-1 (mark as retained)
  JSR B1F_GetOfficerRecordAddr          ; $CDE3: 20 D7 F2
  LDY #$0B                              ; $CDE6: A0 0B
  LDA ($00),Y                           ; $CDE8: B1 00
  ORA #$03                              ; $CDEA: 09 03
  STA ($00),Y                           ; $CDEC: 91 00
  INX                                   ; $CDEE: E8
  JMP @AssignLoop                        ; $CDEF: 4C BA CD
@State_Menu:
  ; Show exchange type menu; on confirm, advance to execute or show UI
  JSR RecalcExchangeStats               ; $CDF2: 20 29 CC
  LDA $050A                             ; $CDF5: AD 0A 05
  ASL                                   ; $CDF8: 0A
  TAY                                   ; $CDF9: A8
  LDA MenuTypeItemListPtrs,Y            ; $CDFA: B9 9F BA
  STA $10                               ; $CDFD: 85 10
  LDA MenuTypeItemListPtrs+1,Y          ; $CDFF: B9 A0 BA
  STA $11                               ; $CE02: 85 11
  LDA #$00                              ; $CE04: A9 00
  STA $12                               ; $CE06: 85 12
  JSR B1F_MenuStep2                     ; $CE08: 20 1E ED
  LDA #<MenuSlotPPUAddrs                ; $CE0B: A9 6F
  STA $10                               ; $CE0D: 85 10
  LDA #>MenuSlotPPUAddrs                ; $CE0F: A9 BB
  STA $11                               ; $CE11: 85 11
  LDA #<MenuSlotConfig                  ; $CE13: A9 7F
  STA $00                               ; $CE15: 85 00
  LDA #>MenuSlotConfig                  ; $CE17: A9 BB
  STA $01                               ; $CE19: 85 01
  LDA $12                               ; $CE1B: A5 12
  JSR B1F_PointerTableLookup            ; $CE1D: 20 F5 ED
  JSR CheckExchangePossible                             ; $CE20: 20 27 DF
  BCC @SelectDone                        ; $CE23: 90 30
  LDA $81                               ; $CE25: A5 81
  AND #$01                              ; $CE27: 29 01
  BEQ @SelectDone                        ; $CE29: F0 2A
  LDY $12                               ; $CE2B: A4 12
  LDA officer_sel_list,Y                           ; $CE2D: B9 2C 04
  STA $0540                             ; $CE30: 8D 40 05
  STY $0541                             ; $CE33: 8C 41 05
  CMP #$1E                              ; $CE36: C9 1E
  BEQ @AdvanceState                     ; $CE38: F0 07
  LDA $0550,Y                           ; $CE3A: B9 50 05
  CMP #$0A                              ; $CE3D: C9 0A
  BCS @SelectDone                        ; $CE3F: B0 14
@AdvanceToConfirm:
  INC $0501                             ; $CE41: EE 01 05
  LDA #$DD                              ; $CE44: A9 DD
  LDY $0540                             ; $CE46: AC 40 05
  CPY #$1E                              ; $CE49: C0 1E
  BNE @ShowUI                           ; $CE4B: D0 02
  LDA #$E5                              ; $CE4D: A9 E5
@ShowConfirmUI:
  JSR B1F_SetUI2                        ; $CE4F: 20 83 F2
  JSR @LoadExchangeRulerId              ; $CE52: 20 C3 D0
@ConfirmDone:
  RTS                                   ; $CE55: 60
@State_Confirm:
  ; Wait for A-button; rebuild officer list and show confirmation dialog
  JSR RecalcExchangeStats               ; $CE56: 20 29 CC
  JSR CheckExchangePossible                             ; $CE59: 20 27 DF
  BCC @ConfirmDone                      ; $CE5C: 90 17
  JSR DrawExchangeArrows_Right                             ; $CE5E: 20 63 DC
  LDA $81                               ; $CE61: A5 81
  AND #$01                              ; $CE63: 29 01
  BEQ @ConfirmDone                      ; $CE65: F0 0E
  JSR @BuildOfficerList                  ; $CE67: 20 E1 D0
  STX $050A                             ; $CE6A: 8E 0A 05
  LDA #$DE                              ; $CE6D: A9 DE
  JSR B1F_SetUI4                        ; $CE6F: 20 8B F2
  INC $0501                             ; $CE72: EE 01 05
@ExecuteDone:
  RTS                                   ; $CE75: 60
@State_Execute:
  ; Remove selected officer from exchange slot and advance
  JSR RecalcExchangeStats               ; $CE76: 20 29 CC
  JSR CheckExchangePossible                             ; $CE79: 20 27 DF
  BCC @ExecuteDone                      ; $CE7C: 90 1F
  LDX $050A                             ; $CE7E: AE 0A 05
  LDA #$FF                              ; $CE81: A9 FF
  STA officer_sel_list,X                           ; $CE83: 9D 2C 04
  LDA #$E0                              ; $CE86: A9 E0
  STA $E6                               ; $CE88: 85 E6
  STA $E7                               ; $CE8A: 85 E7
  INC $0501                             ; $CE8C: EE 01 05
  LDA #$00                              ; $CE8F: A9 00
  STA $8E                               ; $CE91: 85 8E
  STA $90                               ; $CE93: 85 90
  LDA #$00                              ; $CE95: A9 00
  STA menu_cursor_col                             ; $CE97: 8D 24 04
  STA menu_cursor_page                             ; $CE9A: 8D 25 04
@CancelDone:
  RTS                                   ; $CE9D: 60
@State_Cancel:
  ; Undo officer selections; show cancel menu and toggle selection flags
  LDA $050A                             ; $CE9E: AD 0A 05
  ASL                                   ; $CEA1: 0A
  TAY                                   ; $CEA2: A8
  LDA @ExchangeItemPoolPtrs,Y           ; $CEA3: B9 5E CF
  STA $10                               ; $CEA6: 85 10
  LDA @ExchangeItemPoolPtrs+1,Y         ; $CEA8: B9 5F CF
  STA $11                               ; $CEAB: 85 11
  LDA #$00                              ; $CEAD: A9 00
  STA $12                               ; $CEAF: 85 12
  JSR B1F_MenuStep3                     ; $CEB1: 20 23 ED
  LDA #<@ExchangeSlotPPUAddrs           ; $CEB4: A9 34
  STA $10                               ; $CEB6: 85 10
  LDA #>@ExchangeSlotPPUAddrs           ; $CEB8: A9 CF
  STA $11                               ; $CEBA: 85 11
  LDA #<@ExchangeSlotConfig             ; $CEBC: A9 04
  STA $00                               ; $CEBE: 85 00
  LDA #>@ExchangeSlotConfig             ; $CEC0: A9 CF
  STA $01                               ; $CEC2: 85 01
  LDA $12                               ; $CEC4: A5 12
  STA $0508                             ; $CEC6: 8D 08 05
  JSR B1F_PointerTableLookup            ; $CEC9: 20 F5 ED
  JSR @ToggleOfficerSelect              ; $CECC: 20 67 D1
  JSR @RenderExchangeMenu               ; $CECF: 20 BC D1
  LDA $81                               ; $CED2: A5 81
  AND #$01                              ; $CED4: 29 01
  BEQ @CancelDone                        ; $CED6: F0 2B
  LDA $050A                             ; $CED8: AD 0A 05
  CMP $0508                             ; $CEDB: CD 08 05
  BNE @CancelDone                        ; $CEDE: D0 23
  LDY #$00                              ; $CEE0: A0 00
  LDX #$00                              ; $CEE2: A2 00
@CountLoop:
  LDA $0580,Y                           ; $CEE4: B9 80 05
  BMI @SkipSlot                          ; $CEE7: 30 01
  INX                                   ; $CEE9: E8
@SkipSlot:
  INY                                   ; $CEEA: C8
  CPY #$14                              ; $CEEB: C0 14
  BCC @CountLoop                        ; $CEED: 90 F5
  TXA                                   ; $CEEF: 8A
  BEQ @FinalizeExchange                  ; $CEF0: F0 28
  LDA #$D8                              ; $CEF2: A9 D8
  LDY $0540                             ; $CEF4: AC 40 05
  CPY #$1E                              ; $CEF7: C0 1E
  BNE @ShowConfirmUI                    ; $CEF9: D0 02
  LDA #$E6                              ; $CEFB: A9 E6
@ShowCancelUI:
  JSR B1F_SetUI2                        ; $CEFD: 20 83 F2
  INC $0501                             ; $CF00: EE 01 05
@FinalizeDone:
  RTS                                   ; $CF03: 60
@ExchangeSlotConfig:
  .byte $00,$07,$00,$F8,$80             ; $CF04: menu slot config (5 bytes)
@State_Finalize:
  ; Wait for A-button confirmation; execute all pending transfers and restart
  JSR @RenderExchangeMenu               ; $CF09: 20 BC D1
  JSR CheckExchangePossible                             ; $CF0C: 20 27 DF
  BCC @FinalizeDone                     ; $CF0F: 90 22
  JSR DrawExchangeArrows_Right                             ; $CF11: 20 63 DC
@WaitConfirm:
  LDA $81                               ; $CF14: A5 81
  AND #$01                              ; $CF16: 29 01
  BEQ @FinalizeDone                     ; $CF18: F0 19
@FinalizeExchange:
  ; Execute all selected officer transfers, then restart from Init
  LDA #$E1                              ; $CF1A: A9 E1
  STA $E6                               ; $CF1C: 85 E6
  STA $E7                               ; $CF1E: 85 E7
  LDA #$00                              ; $CF20: A9 00
  STA $8E                               ; $CF22: 85 8E
  LDA #$50                              ; $CF24: A9 50
  STA $90                               ; $CF26: 85 90
  LDA #$00                              ; $CF28: A9 00
  STA $0501                             ; $CF2A: 8D 01 05
  JSR @ExecuteAllTransfers              ; $CF2D: 20 F9 D1
  JMP @State_Init                       ; $CF30: 4C 2A CD
  RTS                                   ; $CF33: 60
; --- Exchange slot PPU addresses (7 rows x 3 columns = 21 entries) ---
@ExchangeSlotPPUAddrs:
  .word $2016,$6816,$B016               ; $CF34: row 0
  .word $2026,$6826,$B026               ; $CF3A: row 1
  .word $2036,$6836,$B036               ; $CF40: row 2
  .word $2046,$6846,$B046               ; $CF46: row 3
  .word $2056,$6856,$B056               ; $CF4C: row 4
  .word $2066,$6866,$B066               ; $CF52: row 5
  .word $2076,$6876,$B076               ; $CF58: row 6
; --- Exchange item pool pointers (21 entries, indexed by officer count) ---
@ExchangeItemPoolPtrs:
  .word @Pool_20                        ; $CF5E: $D0BD
  .word @Pool_19                        ; $CF60: $D0B7
  .word @Pool_18                        ; $CF62: $D0B1
  .word @Pool_17                        ; $CF64: $D0A8
  .word @Pool_16                        ; $CF66: $D09F
  .word @Pool_15                        ; $CF68: $D096
  .word @Pool_14                        ; $CF6A: $D08A
  .word @Pool_13                        ; $CF6C: $D07E
  .word @Pool_12                        ; $CF6E: $D072
  .word @Pool_11                        ; $CF70: $D063
  .word @Pool_10                        ; $CF72: $D054
  .word @Pool_09                        ; $CF74: $D045
  .word @Pool_08                        ; $CF76: $D033
  .word @Pool_07                        ; $CF78: $D021
  .word @Pool_06                        ; $CF7A: $D00F
  .word @Pool_05                        ; $CF7C: $CFFA
  .word @Pool_04                        ; $CF7E: $CFE5
  .word @Pool_03                        ; $CF80: $CFD0
  .word @Pool_02                        ; $CF82: $CFB8
  .word @Pool_01                        ; $CF84: $CFA0
  .word @Pool_00                        ; $CF86: $CF88
; --- Item index pools (slot indices 0-$14, terminated by $FF) ---
@Pool_00:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F; $CF88
  .byte $10,$11,$12,$13,$14,$FF,$FF,$FF ; $CF98: 21 items + 3 FF
@Pool_01:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F; $CFA0
  .byte $10,$11,$12,$13,$FF,$FF,$FF,$FF ; $CFB0: 20 items + 4 FF
@Pool_02:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F; $CFB8
  .byte $10,$11,$12,$FF,$FF,$00,$FF,$01 ; $CFC8: 19 items + padding
@Pool_03:
  .byte $02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11; $CFD0
  .byte $FF,$FF,$FF,$FF,$FF             ; $CFE0: 18 items + 3 FF (includes $CFE2-$CFE4)
@Pool_04:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F; $CFE5
  .byte $10,$FF,$FF,$FF,$FF             ; $CFF5: 17 items + 4 FF
@Pool_05:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F; $CFFA
  .byte $FF,$FF,$FF,$FF,$FF             ; $D00A: 16 items + 5 FF
@Pool_06:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$FF; $D00F
  .byte $FF,$FF                         ; $D01F: 15 items + 3 FF
@Pool_07:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$FF,$FF; $D021
  .byte $FF,$FF                         ; $D031: 14 items + 4 FF
@Pool_08:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$FF,$FF,$FF; $D033
  .byte $FF,$FF                         ; $D043: 13 items + 5 FF
@Pool_09:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$FF,$FF,$FF; $D045: 12 items + 3 FF
@Pool_10:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$FF,$FF,$FF,$FF; $D054: 11 items + 4 FF
@Pool_11:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$FF,$FF,$FF,$FF,$FF; $D063: 10 items + 5 FF
@Pool_12:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$FF,$FF,$FF ; $D072: 9 items + 3 FF
@Pool_13:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$FF,$FF,$FF,$FF ; $D07E: 8 items + 4 FF
@Pool_14:
  .byte $00,$01,$02,$03,$04,$05,$06,$FF,$FF,$FF,$FF,$FF ; $D08A: 7 items + 5 FF
@Pool_15:
  .byte $00,$01,$02,$03,$04,$05,$FF,$FF,$FF ; $D096: 6 items + 3 FF
@Pool_16:
  .byte $00,$01,$02,$03,$04,$FF,$FF,$FF,$FF ; $D09F: 5 items + 4 FF
@Pool_17:
  .byte $00,$01,$02,$03,$FF,$FF,$FF,$FF,$FF ; $D0A8: 4 items + 5 FF
@Pool_18:
  .byte $00,$01,$02,$FF,$FF,$FF         ; $D0B1: 3 items + 3 FF
@Pool_19:
  .byte $00,$01,$FF,$FF,$FF,$FF         ; $D0B7: 2 items + 4 FF
@Pool_20:
  .byte $00,$FF,$FF,$FF,$FF,$FF         ; $D0BD: 1 item + 5 FF
@LoadExchangeRulerId:
  ; Load exchange partner ruler ID into $044C
  LDY $0507                             ; $D0C3: AC 07 05
  LDA $050B                             ; $D0C6: AD 0B 05
  AND #$F0                              ; $D0C9: 29 F0
  BEQ @GetRulerNibble                    ; $D0CB: F0 06
  TYA                                   ; $D0CD: 98
  LSR                                   ; $D0CE: 4A
  LSR                                   ; $D0CF: 4A
  LSR                                   ; $D0D0: 4A
  LSR                                   ; $D0D1: 4A
  TAY                                   ; $D0D2: A8
@GetRulerNibble:
  TYA                                   ; $D0D3: 98
  AND #$0F                              ; $D0D4: 29 0F
  JSR B1F_GetRulerDataPtr               ; $D0D6: 20 68 F3
  LDY #$00                              ; $D0D9: A0 00
  LDA ($00),Y                           ; $D0DB: B1 00
  STA exchange_ruler_id                             ; $D0DD: 8D 4C 04
  RTS                                   ; $D0E0: 60
@BuildOfficerList:
  ; Clear selection flags ($0580) and officer slots ($042C), then populate
  ; from city officer lists based on exchange direction ($050B bit 4)
  LDY #$20                              ; $D0E1: A0 20
  LDA #$FF                              ; $D0E3: A9 FF
@ClearSelectFlags:
  STA $0580,Y                           ; $D0E5: 99 80 05
  DEY                                   ; $D0E8: 88
  BPL @ClearSelectFlags                 ; $D0E9: 10 FA
  LDA #$FF                              ; $D0EB: A9 FF
  STA $050A                             ; $D0ED: 8D 0A 05
  LDY #$1F                              ; $D0F0: A0 1F
  LDA #$FF                              ; $D0F2: A9 FF
@ClearSlots:
  STA officer_sel_list,Y                           ; $D0F4: 99 2C 04
  DEY                                   ; $D0F7: 88
  BPL @ClearSlots                       ; $D0F8: 10 FA
  LDA $050B                             ; $D0FA: AD 0B 05
  AND #$10                              ; $D0FD: 29 10
  BNE @ReceiveDirection                 ; $D0FF: D0 33
  LDY #$00                              ; $D101: A0 00
  LDX #$00                              ; $D103: A2 00
@GiveScanCities:
  LDA $0628,Y                           ; $D105: B9 28 06
  AND #$80                              ; $D108: 29 80
  BNE @GiveSkipCity                     ; $D10A: D0 0B
  LDA $0664,Y                           ; $D10C: B9 64 06
  CMP #$FF                              ; $D10F: C9 FF
  BEQ @GiveSkipCity                     ; $D111: F0 04
  STA officer_sel_list,X                           ; $D113: 9D 2C 04
  INX                                   ; $D116: E8
@GiveSkipCity:
  INY                                   ; $D117: C8
  CPY #$14                              ; $D118: C0 14
  BCC @GiveScanCities                   ; $D11A: 90 E9
  LDY #$00                              ; $D11C: A0 00
@GiveScanReserve:
  LDA $6F47,Y                           ; $D11E: B9 47 6F
  CMP #$FF                              ; $D121: C9 FF
  BEQ @GiveSkipReserve                  ; $D123: F0 04
  STA officer_sel_list,X                           ; $D125: 9D 2C 04
  INX                                   ; $D128: E8
@GiveSkipReserve:
  INY                                   ; $D129: C8
  CPY #$14                              ; $D12A: C0 14
  BCC @GiveScanReserve                  ; $D12C: 90 F0
  LDA #$FE                              ; $D12E: A9 FE
  STA officer_sel_list,X                           ; $D130: 9D 2C 04
  RTS                                   ; $D133: 60
@ReceiveDirection:
  LDY #$00                              ; $D134: A0 00
  LDX #$00                              ; $D136: A2 00
@RecvScanCities:
  LDA $0628,Y                           ; $D138: B9 28 06
  AND #$80                              ; $D13B: 29 80
  BEQ @RecvSkipCity                     ; $D13D: F0 0B
  LDA $0664,Y                           ; $D13F: B9 64 06
  CMP #$FF                              ; $D142: C9 FF
  BEQ @RecvSkipCity                     ; $D144: F0 04
  STA officer_sel_list,X                           ; $D146: 9D 2C 04
  INX                                   ; $D149: E8
@RecvSkipCity:
  INY                                   ; $D14A: C8
  CPY #$14                              ; $D14B: C0 14
  BCC @RecvScanCities                   ; $D14D: 90 E9
  LDY #$00                              ; $D14F: A0 00
@RecvScanReserve:
  LDA $6F5B,Y                           ; $D151: B9 5B 6F
  CMP #$FF                              ; $D154: C9 FF
  BEQ @RecvSkipReserve                  ; $D156: F0 04
  STA officer_sel_list,X                           ; $D158: 9D 2C 04
  INX                                   ; $D15B: E8
@RecvSkipReserve:
  INY                                   ; $D15C: C8
  CPY #$14                              ; $D15D: C0 14
  BCC @RecvScanReserve                  ; $D15F: 90 F0
  LDA #$FE                              ; $D161: A9 FE
  STA officer_sel_list,X                           ; $D163: 9D 2C 04
  RTS                                   ; $D166: 60
@ToggleOfficerSelect:
  ; Toggle officer selection flag in $0580; validates capacity and ruler constraints
  LDX #$00                              ; $D167: A2 00
  LDY #$1F                              ; $D169: A0 1F
@CountSelected:
  LDA $0580,Y                           ; $D16B: B9 80 05
  CMP #$FF                              ; $D16E: C9 FF
  BEQ @SkipCount                        ; $D170: F0 01
  INX                                   ; $D172: E8
@SkipCount:
  DEY                                   ; $D173: 88
  BPL @CountSelected                    ; $D174: 10 F5
  LDA $81                               ; $D176: A5 81
  AND #$01                              ; $D178: 29 01
  BEQ @ToggleDone                       ; $D17A: F0 3F
  LDY $0508                             ; $D17C: AC 08 05
  CPY $050A                             ; $D17F: CC 0A 05
  BEQ @ToggleDone                       ; $D182: F0 37
  LDA $0580,Y                           ; $D184: B9 80 05
  BEQ @DeselectOfficer                  ; $D187: F0 2D
  LDA $0540                             ; $D189: AD 40 05
  CMP #$1E                              ; $D18C: C9 1E
  BNE @CheckCapacity                    ; $D18E: D0 0E
  JSR @LoadExchangeRulerId              ; $D190: 20 C3 D0
  LDY $0508                             ; $D193: AC 08 05
  CMP officer_sel_list,Y                           ; $D196: D9 2C 04
  BEQ @ToggleDone                       ; $D199: F0 20
  JMP @ClearSelection                   ; $D19B: 4C AD D1
@CheckCapacity:
  STX $00                               ; $D19E: 86 00
  LDY $0541                             ; $D1A0: AC 41 05
  LDA #$09                              ; $D1A3: A9 09
  SEC                                   ; $D1A5: 38
  SBC $0550,Y                           ; $D1A6: F9 50 05
  CMP $00                               ; $D1A9: C5 00
  BCC @ToggleDone                       ; $D1AB: 90 0E
@ClearSelection:
  LDY $0508                             ; $D1AD: AC 08 05
  LDA #$00                              ; $D1B0: A9 00
  STA $0580,Y                           ; $D1B2: 99 80 05
  RTS                                   ; $D1B5: 60
@DeselectOfficer:
  LDA #$FF                              ; $D1B6: A9 FF
  STA $0580,Y                           ; $D1B8: 99 80 05
@ToggleDone:
  RTS                                   ; $D1BB: 60
@RenderExchangeMenu:
  ; Render all selected officers in the exchange menu grid
  LDA #$08                              ; $D1BC: A9 08
  STA $00AF                             ; $D1BE: 8D AF 00
  LDA #$36                              ; $D1C1: A9 36
  STA $0115                             ; $D1C3: 8D 15 01
  LDA #$16                              ; $D1C6: A9 16
  STA $0117                             ; $D1C8: 8D 17 01
  LDY #$00                              ; $D1CB: A0 00
@MenuSlotLoop:
  LDA $0580,Y                           ; $D1CD: B9 80 05
  BMI @MenuSlotSkip                     ; $D1D0: 30 07
  TYA                                   ; $D1D2: 98
  PHA                                   ; $D1D3: 48
  JSR @RenderMenuSlot                   ; $D1D4: 20 DF D1
  PLA                                   ; $D1D7: 68
  TAY                                   ; $D1D8: A8
@MenuSlotSkip:
  INY                                   ; $D1D9: C8
  CPY #$14                              ; $D1DA: C0 14
  BCC @MenuSlotLoop                     ; $D1DC: 90 EF
  RTS                                   ; $D1DE: 60
@RenderMenuSlot:
  ; Render a single officer slot using PPU address and config tables
  LDA #<@ExchangeSlotPPUAddrs           ; $D1DF: A9 34
  STA $10                               ; $D1E1: 85 10
  LDA #>@ExchangeSlotPPUAddrs           ; $D1E3: A9 CF
  STA $11                               ; $D1E5: 85 11
  LDA #<@MenuSlotRenderConfig           ; $D1E7: A9 F4
  STA $00                               ; $D1E9: 85 00
  LDA #>@MenuSlotRenderConfig           ; $D1EB: A9 D1
  STA $01                               ; $D1ED: 85 01
  TYA                                   ; $D1EF: 98
  JSR B1F_PointerTableLookup            ; $D1F0: 20 F5 ED
  RTS                                   ; $D1F3: 60
@MenuSlotRenderConfig:
  .byte $00,$7E,$01,$00,$80             ; $D1F4: render config (5 bytes)
@ExecuteAllTransfers:
  ; Iterate $0580 selection flags; transfer each selected officer
  LDY #$00                              ; $D1F9: A0 00
@TransferLoop:
  LDA $0580,Y                           ; $D1FB: B9 80 05
  BMI @TransferSkip                     ; $D1FE: 30 07
  TYA                                   ; $D200: 98
  PHA                                   ; $D201: 48
  JSR @TransferOfficer                  ; $D202: 20 0D D2
  PLA                                   ; $D205: 68
  TAY                                   ; $D206: A8
@TransferSkip:
  INY                                   ; $D207: C8
  CPY #$14                              ; $D208: C0 14
  BCC @TransferLoop                     ; $D20A: 90 EF
  RTS                                   ; $D20C: 60
@TransferOfficer:
  ; Transfer a single officer to the exchange partner ruler
  ; If $0540==$1E: assign random province; otherwise: swap ruler assignment
  LDA $0540                             ; $D20D: AD 40 05
  CMP #$1E                              ; $D210: C9 1E
  BNE @SwapRuler                        ; $D212: D0 35
  LDA officer_sel_list,Y                           ; $D214: B9 2C 04
  PHA                                   ; $D217: 48
  JSR B1F_GetOfficerRecordAddr          ; $D218: 20 D7 F2
  LDY #$0B                              ; $D21B: A0 0B
  LDA ($00),Y                           ; $D21D: B1 00
  AND #$FC                              ; $D21F: 29 FC
  STA ($00),Y                           ; $D221: 91 00
  LDY #$30                              ; $D223: A0 30
  JSR B1F_SwitchBank8_A                 ; $D225: 20 66 F2
  LDA $050E                             ; $D228: AD 0E 05
  ASL                                   ; $D22B: 0A
  ASL                                   ; $D22C: 0A
  ASL                                   ; $D22D: 0A
  STA $0002                             ; $D22E: 8D 02 00
  JSR B1F_RandomMod8                    ; $D231: 20 56 E8
  CLC                                   ; $D234: 18
  ADC $0002                             ; $D235: 6D 02 00
  TAY                                   ; $D238: A8
  LDA $9D72,Y                           ; $D239: B9 72 9D
  BPL @AssignProvince                   ; $D23C: 10 03
  LDA $050E                             ; $D23E: AD 0E 05
@AssignProvince:
  LDY #$05                              ; $D241: A0 05
  STA ($00),Y                           ; $D243: 91 00
  PLA                                   ; $D245: 68
  JMP @RemoveFromRoster                 ; $D246: 4C 99 D2
@SwapRuler:
  ; Swap officer to the other ruler's roster
  TYA                                   ; $D249: 98
  PHA                                   ; $D24A: 48
  LDA $050B                             ; $D24B: AD 0B 05
  PHA                                   ; $D24E: 48
  LDA $0540                             ; $D24F: AD 40 05
  STA $050B                             ; $D252: 8D 0B 05
  JSR $BC11                             ; $D255: 20 11 BC
  PLA                                   ; $D258: 68
  STA $050B                             ; $D259: 8D 0B 05
  PLA                                   ; $D25C: 68
  TAX                                   ; $D25D: AA
  LDA officer_sel_list,X                           ; $D25E: BD 2C 04
  CMP $052B                             ; $D261: CD 2B 05
  BNE @SetRulerField                    ; $D264: D0 06
  LDX $0540                             ; $D266: AE 40 05
  STX $052C                             ; $D269: 8E 2C 05
@SetRulerField:
  STA ($00),Y                           ; $D26C: 91 00
  PHA                                   ; $D26E: 48
  LDY #$00                              ; $D26F: A0 00
  LDA ($00),Y                           ; $D271: B1 00
  AND #$07                              ; $D273: 29 07
  CMP #$07                              ; $D275: C9 07
  BNE @SkipProvinceUpdate               ; $D277: D0 1F
  LDY $0507                             ; $D279: AC 07 05
  LDA $050B                             ; $D27C: AD 0B 05
  AND #$F0                              ; $D27F: 29 F0
  BEQ @GetProvinceNibble                ; $D281: F0 06
  TYA                                   ; $D283: 98
  LSR                                   ; $D284: 4A
  LSR                                   ; $D285: 4A
  LSR                                   ; $D286: 4A
  LSR                                   ; $D287: 4A
  TAY                                   ; $D288: A8
@GetProvinceNibble:
  TYA                                   ; $D289: 98
  AND #$0F                              ; $D28A: 29 0F
  STA $02                               ; $D28C: 85 02
  LDY #$00                              ; $D28E: A0 00
  LDA ($00),Y                           ; $D290: B1 00
  AND #$F0                              ; $D292: 29 F0
  ORA $02                               ; $D294: 05 02
  STA ($00),Y                           ; $D296: 91 00
@SkipProvinceUpdate:
  PLA                                   ; $D298: 68
@RemoveFromRoster:
  ; Remove officer from old ruler's city/reserve roster
  LDX #$00                              ; $D299: A2 00
@ScanCityRoster:
  CMP $0664,X                           ; $D29B: DD 64 06
  BEQ @ClearCitySlot                    ; $D29E: F0 12
  INX                                   ; $D2A0: E8
  CPX #$14                              ; $D2A1: E0 14
  BCC @ScanCityRoster                   ; $D2A3: 90 F6
  LDX #$00                              ; $D2A5: A2 00
@ScanReserveRoster:
  CMP $6F47,X                           ; $D2A7: DD 47 6F
@CheckReserveMatch:
  BEQ @ClearReserveSlot                 ; $D2AA: F0 1B
  INX                                   ; $D2AC: E8
  CPX #$28                              ; $D2AD: E0 28
  BCC @ScanReserveRoster                ; $D2AF: 90 F6
  RTS                                   ; $D2B1: 60
@ClearCitySlot:
  ; Clear all 6 city roster fields for this slot
  LDA #$FF                              ; $D2B2: A9 FF
  STA $0600,X                           ; $D2B4: 9D 00 06
  STA $0614,X                           ; $D2B7: 9D 14 06
  STA $0628,X                           ; $D2BA: 9D 28 06
  STA $063C,X                           ; $D2BD: 9D 3C 06
  STA $0650,X                           ; $D2C0: 9D 50 06
  STA $0664,X                           ; $D2C3: 9D 64 06
  RTS                                   ; $D2C6: 60
@ClearReserveSlot:
  LDA #$FF                              ; $D2C7: A9 FF
  STA $6F47,X                           ; $D2C9: 9D 47 6F
  RTS                                   ; $D2CC: 60
.endproc

.proc OfficerReserveAssignDispatch
  ; Game mode $0F: Officer reserve assignment
  ; State machine on $0501: 0=Init, 1=WaitInput, 2=MenuSelect, 3=Confirm,
  ;                         4=Execute, 5=RenderMenu, 6=Finalize
  LDA $0501                             ; $D2CD: AD 01 05
  JSR B1F_CallbackDispatcher            ; $D2D0: 20 DE EA
; --- CallbackDispatcher table (7 entries) ---
  .word @State_Init                         ; $D2D3: $E1 D2
  .word @State_WaitInput                    ; $D2D5: $10 D3
  .word @State_MenuSelect                   ; $D2D7: $4B D3
  .word @State_Confirm                      ; $D2D9: $AF D3
  .word @State_Execute                      ; $D2DB: $D7 D3
  .word @State_RenderMenu                   ; $D2DD: $F7 D3
  .word @State_Finalize                     ; $D2DF: $62 D4
@State_Init:
  ; Build eligible officer list; if fewer than 11, show error and advance
  JSR RecalcExchangeStats               ; $D2E1: 20 29 CC
  JSR $D0E1                             ; $D2E4: 20 E1 D0  ; OfficerExchangeSelectDispatch@BuildOfficerList
  LDA #$FF                              ; $D2E7: A9 FF
  STA officer_sel_list,X                           ; $D2E9: 9D 2C 04
  STX $050A                             ; $D2EC: 8E 0A 05
  CPX #$0B                              ; $D2EF: E0 0B
  BCS @InitError                        ; $D2F1: B0 11
  JSR @AssignReserveSlots               ; $D2F3: 20 8D D4
  LDA #$0F                              ; $D2F6: A9 0F
  STA $0500                             ; $D2F8: 8D 00 05
  LDA $050B                             ; $D2FB: AD 0B 05
  AND #$0F                              ; $D2FE: 29 0F
  STA $0501                             ; $D300: 8D 01 05
  RTS                                   ; $D303: 60
@InitError:
  ; Too few officers; show error dialog and advance state
  LDA #$DF                              ; $D304: A9 DF
  JSR B1F_SetUI5                        ; $D306: 20 93 F2
  JSR $D0C3                             ; $D309: 20 C3 D0  ; OfficerExchangeSelectDispatch@LoadExchangeRulerId
  INC $0501                             ; $D30C: EE 01 05
  RTS                                   ; $D30F: 60
@State_WaitInput:
  ; Poll for A-button; on confirm, setup UI panel and advance to MenuSelect
  JSR RecalcExchangeStats               ; $D310: 20 29 CC
  JSR CheckExchangePossible                             ; $D313: 20 27 DF  ; WaitVBlankInput
  BCC @WaitDone                         ; $D316: 90 32
  JSR DrawExchangeArrows_Right                             ; $D318: 20 63 DC  ; ReadJoypad
  LDA $81                               ; $D31B: A5 81
  AND #$01                              ; $D31D: 29 01
  BEQ @WaitDone                         ; $D31F: F0 29
  INC $0501                             ; $D321: EE 01 05
  LDA #$D7                              ; $D324: A9 D7
  JSR B1F_SetUI2                        ; $D326: 20 83 F2
  LDA #$00                              ; $D329: A9 00
  STA menu_cursor_col                             ; $D32B: 8D 24 04
  STA menu_cursor_page                             ; $D32E: 8D 25 04
  LDA $050B                             ; $D331: AD 0B 05
  AND #$10                              ; $D334: 29 10
  ASL                                   ; $D336: 0A
  ASL                                   ; $D337: 0A
  ASL                                   ; $D338: 0A
  STA $0504                             ; $D339: 8D 04 05
  JSR $BB84                             ; $D33C: 20 84 BB
  INC $050A                             ; $D33F: EE 0A 05
  LDY $050A                             ; $D342: AC 0A 05
  LDA #$1E                              ; $D345: A9 1E
  STA officer_sel_list,Y                           ; $D347: 99 2C 04
@WaitDone:
  RTS                                   ; $D34A: 60
@State_MenuSelect:
  ; Show item selection menu; validate and store chosen officer slot
  JSR RecalcExchangeStats               ; $D34B: 20 29 CC
  LDA $050A                             ; $D34E: AD 0A 05
  ASL                                   ; $D351: 0A
  TAY                                   ; $D352: A8
  LDA MenuTypeItemListPtrs,Y            ; $D353: B9 9F BA
  STA $10                               ; $D356: 85 10
  LDA MenuTypeItemListPtrs+1,Y          ; $D358: B9 A0 BA
  STA $11                               ; $D35B: 85 11
  LDA #$00                              ; $D35D: A9 00
  STA $12                               ; $D35F: 85 12
  JSR B1F_MenuStep2                     ; $D361: 20 1E ED
  LDA #<MenuSlotPPUAddrs                ; $D364: A9 6F
  STA $10                               ; $D366: 85 10
  LDA #>MenuSlotPPUAddrs                ; $D368: A9 BB
  STA $11                               ; $D36A: 85 11
  LDA #<MenuSlotConfig                  ; $D36C: A9 7F
  STA $00                               ; $D36E: 85 00
  LDA #>MenuSlotConfig                  ; $D370: A9 BB
  STA $01                               ; $D372: 85 01
  LDA $12                               ; $D374: A5 12
  JSR B1F_PointerTableLookup            ; $D376: 20 F5 ED
  JSR CheckExchangePossible                             ; $D379: 20 27 DF  ; WaitVBlankInput
  BCC @WaitDone                         ; $D37C: 90 CC
  LDA $81                               ; $D37E: A5 81
  AND #$01                              ; $D380: 29 01
  BEQ @MenuDone                         ; $D382: F0 2A
  LDY $12                               ; $D384: A4 12
  LDA officer_sel_list,Y                           ; $D386: B9 2C 04
  STA $0540                             ; $D389: 8D 40 05
  STY $0541                             ; $D38C: 8C 41 05
  CMP #$1E                              ; $D38F: C9 1E
  BEQ @MenuValid                        ; $D391: F0 07
  LDA $0550,Y                           ; $D393: B9 50 05
  CMP #$0A                              ; $D396: C9 0A
  BCS @MenuDone                         ; $D398: B0 14
@MenuValid:
  ; Selection valid; advance to Confirm state
  INC $0501                             ; $D39A: EE 01 05
  LDA #$DD                              ; $D39D: A9 DD
  LDY $0540                             ; $D39F: AC 40 05
  CPY #$1E                              ; $D3A2: C0 1E
  BNE @SetMenuUI                        ; $D3A4: D0 02
  LDA #$E5                              ; $D3A6: A9 E5
@SetMenuUI:
  JSR B1F_SetUI2                        ; $D3A8: 20 83 F2
  JSR $D0C3                             ; $D3AB: 20 C3 D0  ; OfficerExchangeSelectDispatch@LoadExchangeRulerId
@MenuDone:
  RTS                                   ; $D3AE: 60
@State_Confirm:
  ; Wait for A-button; rebuild officer list and advance to Execute
  JSR RecalcExchangeStats               ; $D3AF: 20 29 CC
  JSR CheckExchangePossible                             ; $D3B2: 20 27 DF  ; WaitVBlankInput
  BCC @ConfirmDone                      ; $D3B5: 90 1F
  JSR DrawExchangeArrows_Right                             ; $D3B7: 20 63 DC  ; ReadJoypad
  LDA $81                               ; $D3BA: A5 81
  AND #$01                              ; $D3BC: 29 01
  BEQ @ConfirmDone                      ; $D3BE: F0 16
  LDA #$00                              ; $D3C0: A9 00
  STA menu_cursor_col                             ; $D3C2: 8D 24 04
  STA menu_cursor_page                             ; $D3C5: 8D 25 04
  JSR $D0E1                             ; $D3C8: 20 E1 D0  ; OfficerExchangeSelectDispatch@BuildOfficerList
  STX $050A                             ; $D3CB: 8E 0A 05
  LDA #$DE                              ; $D3CE: A9 DE
  JSR B1F_SetUI4                        ; $D3D0: 20 8B F2
  INC $0501                             ; $D3D3: EE 01 05
@ConfirmDone:
  RTS                                   ; $D3D6: 60
@State_Execute:
  ; Clear selected slot, reset cursor, and advance to RenderMenu
  JSR RecalcExchangeStats               ; $D3D7: 20 29 CC
  JSR CheckExchangePossible                             ; $D3DA: 20 27 DF  ; WaitVBlankInput
  BCC @ExecDone                         ; $D3DD: 90 17
  LDX $050A                             ; $D3DF: AE 0A 05
  LDA #$FF                              ; $D3E2: A9 FF
  STA officer_sel_list,X                           ; $D3E4: 9D 2C 04
  LDA #$E0                              ; $D3E7: A9 E0
  STA $E6                               ; $D3E9: 85 E6
  STA $E7                               ; $D3EB: 85 E7
  INC $0501                             ; $D3ED: EE 01 05
  LDA #$00                              ; $D3F0: A9 00
  STA $8E                               ; $D3F2: 85 8E
  STA $90                               ; $D3F4: 85 90
@ExecDone:
  RTS                                   ; $D3F6: 60
@State_RenderMenu:
  ; Render exchange menu grid; count selected officers and advance if any
  LDA $050A                             ; $D3F7: AD 0A 05
  ASL                                   ; $D3FA: 0A
  TAY                                   ; $D3FB: A8
  LDA $CF5E,Y                           ; $D3FC: B9 5E CF  ; ExchangeItemPoolPtrs
  STA $10                               ; $D3FF: 85 10
  LDA $CF5F,Y                           ; $D401: B9 5F CF
  STA $11                               ; $D404: 85 11
  LDA #$00                              ; $D406: A9 00
  STA $12                               ; $D408: 85 12
  JSR B1F_MenuStep3                     ; $D40A: 20 23 ED
  LDA #$34                              ; $D40D: A9 34
  STA $10                               ; $D40F: 85 10
  LDA #$CF                              ; $D411: A9 CF
  STA $11                               ; $D413: 85 11
  LDA #$5D                              ; $D415: A9 5D
  STA $00                               ; $D417: 85 00
  LDA #$D4                              ; $D419: A9 D4
  STA $01                               ; $D41B: 85 01
  LDA $12                               ; $D41D: A5 12
  STA $0508                             ; $D41F: 8D 08 05
  JSR B1F_PointerTableLookup            ; $D422: 20 F5 ED
  JSR $D167                             ; $D425: 20 67 D1  ; OfficerExchangeSelectDispatch@ToggleOfficerSelect
  JSR $D1BC                             ; $D428: 20 BC D1  ; OfficerExchangeSelectDispatch@RenderExchangeMenu
  LDA $81                               ; $D42B: A5 81
  AND #$01                              ; $D42D: 29 01
  BEQ @RenderDone                       ; $D42F: F0 2B
  LDA $050A                             ; $D431: AD 0A 05
  CMP $0508                             ; $D434: CD 08 05
  BNE @RenderDone                       ; $D437: D0 23
  LDY #$00                              ; $D439: A0 00
  LDX #$00                              ; $D43B: A2 00
@CountLoop:
  LDA $0580,Y                           ; $D43D: B9 80 05
  BMI @CountSkip                        ; $D440: 30 01
  INX                                   ; $D442: E8
@CountSkip:
  INY                                   ; $D443: C8
  CPY #$14                              ; $D444: C0 14
  BCC @CountLoop                        ; $D446: 90 F5
  TXA                                   ; $D448: 8A
  BEQ @FinalizeEntry                    ; $D449: F0 28
  LDA #$D8                              ; $D44B: A9 D8
  LDY $0540                             ; $D44D: AC 40 05
  CPY #$1E                              ; $D450: C0 1E
  BNE @SetRenderUI                      ; $D452: D0 02
  LDA #$E6                              ; $D454: A9 E6
@SetRenderUI:
  JSR B1F_SetUI2                        ; $D456: 20 83 F2
  INC $0501                             ; $D459: EE 01 05
@RenderDone:
  RTS                                   ; $D45C: 60
@MenuRenderConfig:
  .byte $00,$07,$00,$F8,$80               ; $D45D: 00 07 00 F8 80
@State_Finalize:
  ; Execute all pending transfers, reset state, and restart from Init
  JSR $D1BC                             ; $D462: 20 BC D1  ; OfficerExchangeSelectDispatch@RenderExchangeMenu
  JSR CheckExchangePossible                             ; $D465: 20 27 DF  ; WaitVBlankInput
  BCC @FinalDone                        ; $D468: 90 22
  JSR DrawExchangeArrows_Right                             ; $D46A: 20 63 DC  ; ReadJoypad
  LDA $81                               ; $D46D: A5 81
  AND #$01                              ; $D46F: 29 01
  BEQ @FinalDone                        ; $D471: F0 19
@FinalizeEntry:
  ; Reset scroll/cursor and execute all officer transfers
  LDA #$E1                              ; $D473: A9 E1
  STA $E6                               ; $D475: 85 E6
  STA $E7                               ; $D477: 85 E7
  LDA #$00                              ; $D479: A9 00
  STA $8E                               ; $D47B: 85 8E
  LDA #$50                              ; $D47D: A9 50
  STA $90                               ; $D47F: 85 90
  LDA #$00                              ; $D481: A9 00
  STA $0501                             ; $D483: 8D 01 05
  JSR $D1F9                             ; $D486: 20 F9 D1  ; OfficerExchangeSelectDispatch@ExecuteAllTransfers
  JMP @State_Init                       ; $D489: 4C E1 D2
@FinalDone:
  RTS                                   ; $D48C: 60
@AssignReserveSlots:
  ; Iterate all 20 reserve slots; for each occupied slot, remove officer
  ; from active rosters and write to target pointer ($00/$01)
  LDY #$00                              ; $D48D: A0 00
@SlotLoop:
  LDA officer_sel_list,Y                           ; $D48F: B9 2C 04
  CMP #$FF                              ; $D492: C9 FF
  BEQ @SlotSkip                         ; $D494: F0 07
  TYA                                   ; $D496: 98
  PHA                                   ; $D497: 48
  JSR @RemoveOfficerFromRoster           ; $D498: 20 A3 D4
  PLA                                   ; $D49B: 68
  TAY                                   ; $D49C: A8
@SlotSkip:
  INY                                   ; $D49D: C8
  CPY #$14                              ; $D49E: C0 14
  BCC @SlotLoop                         ; $D4A0: 90 ED
  RTS                                   ; $D4A2: 60
@RemoveOfficerFromRoster:
  ; Remove one officer from city roster ($0600-$0664) or reserve ($6F47)
  ; and store to target list via ($00),Y
  PHA                                   ; $D4A3: 48
  LDA $050B                             ; $D4A4: AD 0B 05
  PHA                                   ; $D4A7: 48
  LDA $050E                             ; $D4A8: AD 0E 05
  STA $050B                             ; $D4AB: 8D 0B 05
  JSR $BC11                             ; $D4AE: 20 11 BC
  PLA                                   ; $D4B1: 68
  STA $050B                             ; $D4B2: 8D 0B 05
  PLA                                   ; $D4B5: 68
  TAX                                   ; $D4B6: AA
  LDA officer_sel_list,X                           ; $D4B7: BD 2C 04
  STA ($00),Y                           ; $D4BA: 91 00
  LDX #$00                              ; $D4BC: A2 00
@ScanCity:
  CMP $0664,X                           ; $D4BE: DD 64 06
  BEQ @ClearCitySlot                    ; $D4C1: F0 12
  INX                                   ; $D4C3: E8
  CPX #$14                              ; $D4C4: E0 14
  BCC @ScanCity                         ; $D4C6: 90 F6
  LDX #$00                              ; $D4C8: A2 00
@ScanReserve:
  CMP $6F47,X                           ; $D4CA: DD 47 6F
  BEQ @ClearReserveSlot                 ; $D4CD: F0 1B
  INX                                   ; $D4CF: E8
  CPX #$28                              ; $D4D0: E0 28
  BCC @ScanReserve                      ; $D4D2: 90 F6
  RTS                                   ; $D4D4: 60
@ClearCitySlot:
  ; Clear all 6 city roster fields for matched slot
  LDA #$FF                              ; $D4D5: A9 FF
  STA $0600,X                           ; $D4D7: 9D 00 06
  STA $0614,X                           ; $D4DA: 9D 14 06
  STA $0628,X                           ; $D4DD: 9D 28 06
  STA $063C,X                           ; $D4E0: 9D 3C 06
  STA $0650,X                           ; $D4E3: 9D 50 06
  STA $0664,X                           ; $D4E6: 9D 64 06
  RTS                                   ; $D4E9: 60
@ClearReserveSlot:
  LDA #$FF                              ; $D4EA: A9 FF
  STA $6F47,X                           ; $D4EC: 9D 47 6F
  RTS                                   ; $D4EF: 60
.endproc

.proc ExchangeScene
  ; Officer Exchange scene module ($D4F0-$DFFF)
  ; Handles map scroll, cursor, terrain, rosters, and exchange state machine
@ExchangeScene_Update:
  ; (dispatch callback target) Recalc stats then invoke banked render callback
  JSR RecalcExchangeStats               ; $D4F0: 20 29 CC
  LDY #$28                              ; $D4F3: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $D4F5: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A006                               ; $D4F8: $06 A0
  RTS                                         ; $D4FA: 60
ExchangeAnimFrameUpdate:
  ; Advance animation frame counter ($0318/$0319); triggers refresh every 15 frames
  LDA $0318                                   ; $D4FB: AD 18 03
  STA $00                                     ; $D4FE: 85 00
  LDA $0083                                   ; $D500: AD 83 00
  AND #$F0                                    ; $D503: 29 F0
  STA $0318                                   ; $D505: 8D 18 03
  BEQ @ResetCounter                     ; $D508: F0 1B
  CMP $00                                     ; $D50A: C5 00
  BNE @DirChanged                       ; $D50C: D0 1D
  INC $0319                                   ; $D50E: EE 19 03
  LDA $0319                                   ; $D511: AD 19 03
  CMP #$0F                                    ; $D514: C9 0F
  BCC @AnimDone                         ; $D516: 90 0C
  LDA #$0F                                    ; $D518: A9 0F
  STA $0319                                   ; $D51A: 8D 19 03
  LDA $005E                                   ; $D51D: AD 5E 00
  AND #$03                                    ; $D520: 29 03
  BEQ @DoScroll                         ; $D522: F0 0C
@AnimDone:
  RTS                                   ; $D524: 60
@ResetCounter:
  LDA #$00                              ; $D525: A9 00
  STA $0319                             ; $D527: 8D 19 03
  RTS                                   ; $D52A: 60
@DirChanged:
  LDA #$00                              ; $D52B: A9 00
  STA $0319                             ; $D52D: 8D 19 03
@DoScroll:
  LDA $0083                             ; $D530: AD 83 00
  BPL @CheckLeft                        ; $D533: 10 2B
  LDX $6F40                             ; $D535: AE 40 6F
  CPX #$01                              ; $D538: E0 01
  BNE @ScrollRight                      ; $D53A: D0 07
  LDX $6F3F                             ; $D53C: AE 3F 6F
  CPX #$F0                              ; $D53F: E0 F0
  BCS @CheckLeft                        ; $D541: B0 1D
@ScrollRight:
  PHA                                   ; $D543: 48
  LDA $6F3F                             ; $D544: AD 3F 6F
  SEC                                   ; $D547: 38
  SBC $8E                               ; $D548: E5 8E
  CMP #$F0                              ; $D54A: C9 F0
  BCS @RightDone                        ; $D54C: B0 11
  LDA $6F3F                             ; $D54E: AD 3F 6F
  CLC                                   ; $D551: 18
  ADC #$10                              ; $D552: 69 10
  STA $6F3F                             ; $D554: 8D 3F 6F
  LDA $6F40                             ; $D557: AD 40 6F
  ADC #$00                              ; $D55A: 69 00
  STA $6F40                             ; $D55C: 8D 40 6F
@RightDone:
  PLA                                   ; $D55F: 68
@CheckLeft:
  ASL                                   ; $D560: 0A
  BPL @CheckDown                        ; $D561: 10 27
  LDX $6F40                             ; $D563: AE 40 6F
  BNE @ScrollLeft                       ; $D566: D0 05
  LDX $6F3F                             ; $D568: AE 3F 6F
  BEQ @CheckDown                        ; $D56B: F0 1D
@ScrollLeft:
  PHA                                   ; $D56D: 48
  LDA $6F3F                             ; $D56E: AD 3F 6F
  SEC                                   ; $D571: 38
  SBC $8E                               ; $D572: E5 8E
  CMP #$10                              ; $D574: C9 10
  BCC @LeftDone                         ; $D576: 90 11
  LDA $6F3F                             ; $D578: AD 3F 6F
  SEC                                   ; $D57B: 38
  SBC #$10                              ; $D57C: E9 10
  STA $6F3F                             ; $D57E: 8D 3F 6F
  LDA $6F40                             ; $D581: AD 40 6F
  SBC #$00                              ; $D584: E9 00
  STA $6F40                             ; $D586: 8D 40 6F
@LeftDone:
  PLA                                   ; $D589: 68
@CheckDown:
  ASL                                   ; $D58A: 0A
  BPL @CheckUp                          ; $D58B: 10 32
  PHA                                   ; $D58D: 48
  LDA $6F42                             ; $D58E: AD 42 6F
  BEQ @ScrollDown                       ; $D591: F0 07
  LDA $6F41                             ; $D593: AD 41 6F
  CMP #$40                              ; $D596: C9 40
  BCS @DownDone                         ; $D598: B0 24
@ScrollDown:
  LDA $6F41                             ; $D59A: AD 41 6F
  SEC                                   ; $D59D: 38
  SBC $0090                             ; $D59E: ED 90 00
  CMP #$A0                              ; $D5A1: C9 A0
  BCS @DownDone                         ; $D5A3: B0 19
  LDA $6F41                             ; $D5A5: AD 41 6F
  CLC                                   ; $D5A8: 18
  ADC #$10                              ; $D5A9: 69 10
  CMP #$F0                              ; $D5AB: C9 F0
  BCC @StoreY                           ; $D5AD: 90 04
  CLC                                   ; $D5AF: 18
  ADC #$10                              ; $D5B0: 69 10
  SEC                                   ; $D5B2: 38
@StoreY:
  STA $6F41                             ; $D5B3: 8D 41 6F
  LDA $6F42                             ; $D5B6: AD 42 6F
  ADC #$00                              ; $D5B9: 69 00
  STA $6F42                             ; $D5BB: 8D 42 6F
@DownDone:
  PLA                                   ; $D5BE: 68
@CheckUp:
  ASL                                   ; $D5BF: 0A
  BPL @ScrollExit                       ; $D5C0: 10 2B
  LDX $6F42                             ; $D5C2: AE 42 6F
  BNE @ScrollUp                         ; $D5C5: D0 07
  LDX $6F41                             ; $D5C7: AE 41 6F
  CPX #$10                              ; $D5CA: E0 10
  BCC @ScrollExit                       ; $D5CC: 90 1F
@ScrollUp:
  LDA $6F41                             ; $D5CE: AD 41 6F
  SEC                                   ; $D5D1: 38
  SBC $0090                             ; $D5D2: ED 90 00
  CMP #$10                              ; $D5D5: C9 10
  BCC @ScrollExit                       ; $D5D7: 90 14
  LDA $6F41                             ; $D5D9: AD 41 6F
  SEC                                   ; $D5DC: 38
  SBC #$10                              ; $D5DD: E9 10
  STA $6F41                             ; $D5DF: 8D 41 6F
  BCS @ScrollExit                       ; $D5E2: B0 09
  SEC                                   ; $D5E4: 38
  SBC #$10                              ; $D5E5: E9 10
  STA $6F41                             ; $D5E7: 8D 41 6F
  DEC $6F42                             ; $D5EA: CE 42 6F
@ScrollExit:
  RTS                                   ; $D5ED: 60
MapScroll_Update:
  ; Update map scroll position ($6F3F-$6F42) based on direction flags in A
  JSR @PixelToTileCoord               ; $D5EE: 20 17 DA
  LDA #$00                              ; $D5F1: A9 00
  STA $04                               ; $D5F3: 85 04
  LDA $0002                             ; $D5F5: AD 02 00
  SEC                                   ; $D5F8: 38
  SBC $0000                             ; $D5F9: ED 00 00
  BCC @NeedScrollLeft                   ; $D5FC: 90 04
  CMP #$03                              ; $D5FE: C9 03
  BCS @CheckRight                       ; $D600: B0 0D
@NeedScrollLeft:
  LDY $0090                             ; $D602: AC 90 00
  BEQ @CheckRight                       ; $D605: F0 08
  LDA #$20                              ; $D607: A9 20
  STA $0004                             ; $D609: 8D 04 00
  JMP @CheckVert                        ; $D60C: 4C 1F D6
@CheckRight:
  CMP #$07                              ; $D60F: C9 07
  BCC @CheckVert                        ; $D611: 90 0C
  LDY $0090                             ; $D613: AC 90 00
  CPY #$8E                              ; $D616: C0 8E
  BCS @CheckVert                        ; $D618: B0 05
  LDA #$10                              ; $D61A: A9 10
  STA $0004                             ; $D61C: 8D 04 00
@CheckVert:
  LDA $0003                             ; $D61F: AD 03 00
  SEC                                   ; $D622: 38
  SBC $0001                             ; $D623: ED 01 00
  BCC @NeedScrollUp                     ; $D626: 90 04
  CMP #$04                              ; $D628: C9 04
  BCS @CheckDown                        ; $D62A: B0 0F
@NeedScrollUp:
  LDY $8E                               ; $D62C: A4 8E
  BEQ @CheckDown                        ; $D62E: F0 0B
  LDA $0004                             ; $D630: AD 04 00
  ORA #$40                              ; $D633: 09 40
  STA $0004                             ; $D635: 8D 04 00
  JMP @StoreFlags                       ; $D638: 4C 4D D6
@CheckDown:
  CMP #$0C                              ; $D63B: C9 0C
  BCC @StoreFlags                       ; $D63D: 90 0E
  LDY $8E                               ; $D63F: A4 8E
  CPY #$FE                              ; $D641: C0 FE
  BCS @StoreFlags                       ; $D643: B0 08
  LDA $0004                             ; $D645: AD 04 00
  ORA #$80                              ; $D648: 09 80
  STA $0004                             ; $D64A: 8D 04 00
@StoreFlags:
  LDA $0508                             ; $D64D: AD 08 05
  ORA $0004                             ; $D650: 0D 04 00
  STA $0508                             ; $D653: 8D 08 05
  RTS                                   ; $D656: 60
RenderExchangeSprites:
  ; Copy scroll pos to sprite params and write OAM via B1F_SpriteOamWriterScroll
  LDA $6F41                             ; $D657: AD 41 6F
  STA $000A                             ; $D65A: 8D 0A 00
  LDA $6F42                             ; $D65D: AD 42 6F
  STA $000B                             ; $D660: 8D 0B 00
  LDA $6F3F                             ; $D663: AD 3F 6F
  STA $000C                             ; $D666: 8D 0C 00
  LDA $6F40                             ; $D669: AD 40 6F
  STA $000D                             ; $D66C: 8D 0D 00
  LDA #$81                              ; $D66F: A9 81
  STA $0000                             ; $D671: 8D 00 00
  LDA #$D6                              ; $D674: A9 D6
  STA $0001                             ; $D676: 8D 01 00
  LDA #$00                              ; $D679: A9 00
  STA $0002                             ; $D67B: 8D 02 00
  JMP B1F_SpriteOamWriterScroll         ; $D67E: 4C 92 F0
ExchangeScrollOamData:
  .byte $00,$05,$00,$04,$08,$06,$00,$04,$80; $D681: 00 05 00 04 08 06 00 04 80
ScrollToTileSearch:
  ; Convert scroll position to tile coords (÷16) and search city roster for match
  LDA $6F3F                             ; $D68A: AD 3F 6F
  STA $0000                             ; $D68D: 8D 00 00
  LDA $6F40                             ; $D690: AD 40 6F
  LSR                                   ; $D693: 4A
  ROR $0000                             ; $D694: 6E 00 00
  ROR $0000                             ; $D697: 6E 00 00
  ROR $0000                             ; $D69A: 6E 00 00
  ROR $0000                             ; $D69D: 6E 00 00
  LDA $6F41                             ; $D6A0: AD 41 6F
  STA $0001                             ; $D6A3: 8D 01 00
  LDA $6F42                             ; $D6A6: AD 42 6F
@ScrollToTileSearch_Y:
  ; (dispatch callback target) Entry with Y pre-loaded for tile search
  LSR                                   ; $D6A9: 4A
  ROR $0001                             ; $D6AA: 6E 01 00
  ROR $0001                             ; $D6AD: 6E 01 00
  ROR $0001                             ; $D6B0: 6E 01 00
  ROR $0001                             ; $D6B3: 6E 01 00
SearchRosterByTileCoord:
  ; Search city roster ($0600/$0614) for tile coords in $0000/$0001; returns Y=slot
  LDY #$13                              ; $D6B6: A0 13
@ScanLoop:
  LDA $0600,Y                           ; $D6B8: B9 00 06
  CMP $0000                             ; $D6BB: CD 00 00
  BNE @Next                             ; $D6BE: D0 08
  LDA $0614,Y                           ; $D6C0: B9 14 06
  CMP $0001                             ; $D6C3: CD 01 00
  BEQ @Found                            ; $D6C6: F0 03
@Next:
  DEY                                   ; $D6C8: 88
  BPL @ScanLoop                         ; $D6C9: 10 ED
@Found:
  RTS                                   ; $D6CB: 60
UpdateCursorTile:
  JMP @UpdateCursorTile_Main             ; $D6CC: 4C D0 D6
@UpdateCursorTile_Exit:
  RTS                                   ; $D6CF: 60
@UpdateCursorTile_Main:
  LDY $0509                             ; $D6D0: AC 09 05
  LDA $0600,Y                           ; $D6D3: B9 00 06
  STA $10                               ; $D6D6: 85 10
  LDA $0614,Y                           ; $D6D8: B9 14 06
  STA $11                               ; $D6DB: 85 11
  LDA $0090                             ; $D6DD: AD 90 00
  LSR                                   ; $D6E0: 4A
  LSR                                   ; $D6E1: 4A
  LSR                                   ; $D6E2: 4A
  LSR                                   ; $D6E3: 4A
  STA $00                               ; $D6E4: 85 00
  LDA $11                               ; $D6E6: A5 11
  SEC                                   ; $D6E8: 38
  SBC $00                               ; $D6E9: E5 00
  CMP #$0F                              ; $D6EB: C9 0F
  BCS @UpdateCursorTile_Exit             ; $D6ED: B0 E0
  LDA $8E                               ; $D6EF: A5 8E
  CLC                                   ; $D6F1: 18
  ADC #$04                              ; $D6F2: 69 04
  BCC @NoOverflow                       ; $D6F4: 90 05
  LDA #$10                              ; $D6F6: A9 10
  JMP @CalcCol                          ; $D6F8: 4C FF D6
@NoOverflow:
  LSR                                   ; $D6FB: 4A
  LSR                                   ; $D6FC: 4A
  LSR                                   ; $D6FD: 4A
  LSR                                   ; $D6FE: 4A
@CalcCol:
  STA $00                               ; $D6FF: 85 00
  LDA $10                               ; $D701: A5 10
  SEC                                   ; $D703: 38
  SBC $00                               ; $D704: E5 00
  CMP #$10                              ; $D706: C9 10
  BCS @UpdateCursorTile_Exit             ; $D708: B0 C5
  LDY #$00                              ; $D70A: A0 00
  LDA $10                               ; $D70C: A5 10
  CMP #$10                              ; $D70E: C9 10
  BCC @CheckRow                         ; $D710: 90 02
  LDY #$01                              ; $D712: A0 01
@CheckRow:
  LDA $11                               ; $D714: A5 11
  CMP #$10                              ; $D716: C9 10
  BCC @LoadTile                         ; $D718: 90 04
  TYA                                   ; $D71A: 98
  ORA #$02                              ; $D71B: 09 02
  TAY                                   ; $D71D: A8
@LoadTile:
  LDA ($A8),Y                           ; $D71E: B1 A8
  STA $00                               ; $D720: 85 00
  TYA                                   ; $D722: 98
  EOR #$01                              ; $D723: 49 01
  TAY                                   ; $D725: A8
  LDA ($A8),Y                           ; $D726: B1 A8
  PHA                                   ; $D728: 48
  LDA $00                               ; $D729: A5 00
  PHA                                   ; $D72B: 48
  LDY #$37                              ; $D72C: A0 37
  JSR B1F_BankedCallbackTrampoline      ; $D72E: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                               ; $D731: $12 A0
  LDA $10                                     ; $D733: A5 10
  AND #$0F                                    ; $D735: 29 0F
  STA $08                                     ; $D737: 85 08
  LDX #$00                                    ; $D739: A2 00
  LDA $11                                     ; $D73B: A5 11
  ASL A                                       ; $D73D: 0A
  ASL A                                       ; $D73E: 0A
  ASL A                                       ; $D73F: 0A
  ASL A                                       ; $D740: 0A
  PHA                                         ; $D741: 48
@CalcTileAddr:
  ORA $08                               ; $D742: 05 08
  TAY                                   ; $D744: A8
  LDA #$00                              ; $D745: A9 00
  STA $04                               ; $D747: 85 04
  LDA ($00),Y                           ; $D749: B1 00
  ASL                                   ; $D74B: 0A
  ROL $04                               ; $D74C: 26 04
  ASL                                   ; $D74E: 0A
  ROL $04                               ; $D74F: 26 04
  CLC                                   ; $D751: 18
  ADC $02                               ; $D752: 65 02
  STA $02                               ; $D754: 85 02
  LDA $03                               ; $D756: A5 03
  ADC $04                               ; $D758: 65 04
  STA $03                               ; $D75A: 85 03
  LDY #$00                              ; $D75C: A0 00
  LDA ($02),Y                           ; $D75E: B1 02
  STA $0383                             ; $D760: 8D 83 03
  INY                                   ; $D763: C8
  LDA ($02),Y                           ; $D764: B1 02
  STA $0384                             ; $D766: 8D 84 03
  INY                                   ; $D769: C8
  LDA ($02),Y                           ; $D76A: B1 02
  STA $0388                             ; $D76C: 8D 88 03
  INY                                   ; $D76F: C8
  LDA ($02),Y                           ; $D770: B1 02
  STA $0389                             ; $D772: 8D 89 03
  ASL $08                               ; $D775: 06 08
  LDA #$00                              ; $D777: A9 00
  STA $0B                               ; $D779: 85 0B
  PLA                                   ; $D77B: 68
  ASL                                   ; $D77C: 0A
  ROL $0B                               ; $D77D: 26 0B
  ASL                                   ; $D77F: 0A
  ROL $0B                               ; $D780: 26 0B
  CLC                                   ; $D782: 18
  ADC $08                               ; $D783: 65 08
  STA $0382                             ; $D785: 8D 82 03
  LDA $0B                               ; $D788: A5 0B
  ADC #$20                              ; $D78A: 69 20
  STA $0381                             ; $D78C: 8D 81 03
  LDA $0382                             ; $D78F: AD 82 03
  CLC                                   ; $D792: 18
  ADC #$20                              ; $D793: 69 20
  STA $0387                             ; $D795: 8D 87 03
  LDA $0381                             ; $D798: AD 81 03
  ADC #$00                              ; $D79B: 69 00
  STA $0386                             ; $D79D: 8D 86 03
  LDA #$02                              ; $D7A0: A9 02
  STA $0380                             ; $D7A2: 8D 80 03
  LDA #$02                              ; $D7A5: A9 02
  STA $0385                             ; $D7A7: 8D 85 03
  LDA $12                               ; $D7AA: A5 12
  BEQ @UpdateDone                       ; $D7AC: F0 2D
  LDA $0509                             ; $D7AE: AD 09 05
  STA $00                               ; $D7B1: 85 00
  LDY #$37                              ; $D7B3: A0 37
  JSR B1F_BankedCallbackTrampoline      ; $D7B5: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A018                               ; $D7B8: $18 A0
  LDA #$B0                                    ; $D7BA: A9 B0
  STA $00                                     ; $D7BC: 85 00
  LDA #$01                                    ; $D7BE: A9 01
  STA $01                                     ; $D7C0: 85 01
  LDY #$00                                    ; $D7C2: A0 00
  LDA ($00),Y                                 ; $D7C4: B1 00
  STA $0383                                   ; $D7C6: 8D 83 03
  INY                                         ; $D7C9: C8
  LDA ($00),Y                                 ; $D7CA: B1 00
  STA $0384                                   ; $D7CC: 8D 84 03
  INY                                         ; $D7CF: C8
  LDA ($00),Y                                 ; $D7D0: B1 00
  STA $0388                                   ; $D7D2: 8D 88 03
  INY                                         ; $D7D5: C8
  LDA ($00),Y                                 ; $D7D6: B1 00
  STA $0389                                   ; $D7D8: 8D 89 03
@UpdateDone:
  PLA                                   ; $D7DB: 68
  STA $00                               ; $D7DC: 85 00
  LDY #$37                              ; $D7DE: A0 37
  JSR B1F_BankedCallbackTrampoline      ; $D7E0: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A015                               ; $D7E3: $15 A0
  LDA $10                                     ; $D7E5: A5 10
  AND #$0E                                    ; $D7E7: 29 0E
  LSR A                                       ; $D7E9: 4A
  STA $08                                     ; $D7EA: 85 08
  LDA $11                                     ; $D7EC: A5 11
  AND #$0E                                    ; $D7EE: 29 0E
  ASL A                                       ; $D7F0: 0A
  ASL A                                       ; $D7F1: 0A
  ORA $08                                     ; $D7F2: 05 08
  TAY                                         ; $D7F4: A8
  LDA ($00),Y                                 ; $D7F5: B1 00
  STA $0A                                     ; $D7F7: 85 0A
  PLA                                         ; $D7F9: 68
  STA $00                                     ; $D7FA: 85 00
  LDA $8E                                     ; $D7FC: A5 8E
  CLC                                         ; $D7FE: 18
  ADC #$04                                    ; $D7FF: 69 04
  BCC @CalcNibble                       ; $D801: 90 05
  LDA #$10                                    ; $D803: A9 10
  JMP @CheckOddCol                      ; $D805: 4C 0C D8
@CalcNibble:
  LSR                                   ; $D808: 4A
  LSR                                   ; $D809: 4A
  LSR                                   ; $D80A: 4A
  LSR                                   ; $D80B: 4A
@CheckOddCol:
  TAX                                   ; $D80C: AA
  AND #$01                              ; $D80D: 29 01
  BEQ @WriteAttr                        ; $D80F: F0 45
  TXA                                   ; $D811: 8A
  AND #$1F                              ; $D812: 29 1F
  STA $04                               ; $D814: 85 04
  LDA $10                               ; $D816: A5 10
  SEC                                   ; $D818: 38
  SBC $04                               ; $D819: E5 04
  BNE @CheckEdge                        ; $D81B: D0 1C
  LDA $0A                               ; $D81D: A5 0A
  AND #$CC                              ; $D81F: 29 CC
  STA $0A                               ; $D821: 85 0A
  TYA                                   ; $D823: 98
  PHA                                   ; $D824: 48
  LDY #$37                              ; $D825: A0 37
  JSR B1F_BankedCallbackTrampoline      ; $D827: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A015                               ; $D82A: $15 A0
  PLA                                         ; $D82C: 68
  TAY                                         ; $D82D: A8
  LDA ($00),Y                                 ; $D82E: B1 00
  AND #$33                                    ; $D830: 29 33
  ORA $0A                                     ; $D832: 05 0A
  STA $0A                                     ; $D834: 85 0A
  JMP @WriteAttr                        ; $D836: 4C 56 D8
@CheckEdge:
  CMP #$0F                              ; $D839: C9 0F
  BNE @WriteAttr                        ; $D83B: D0 19
  LDA $0A                               ; $D83D: A5 0A
  AND #$33                              ; $D83F: 29 33
  STA $0A                               ; $D841: 85 0A
  TYA                                   ; $D843: 98
  PHA                                   ; $D844: 48
  LDY #$37                              ; $D845: A0 37
  JSR B1F_BankedCallbackTrampoline      ; $D847: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A015                               ; $D84A: $15 A0
  PLA                                         ; $D84C: 68
  TAY                                         ; $D84D: A8
  LDA ($00),Y                                 ; $D84E: B1 00
  AND #$CC                                    ; $D850: 29 CC
  ORA $0A                                     ; $D852: 05 0A
  STA $0A                                     ; $D854: 85 0A
@WriteAttr:
  LDA $0A                               ; $D856: A5 0A
  STA $00                               ; $D858: 85 00
  JSR @CalcAdjacentTiles               ; $D85A: 20 8E D8
  LDA $00                               ; $D85D: A5 00
  STA $038D                             ; $D85F: 8D 8D 03
  LDA $10                               ; $D862: A5 10
  AND #$0E                              ; $D864: 29 0E
  LSR                                   ; $D866: 4A
  STA $00                               ; $D867: 85 00
  LDA $11                               ; $D869: A5 11
  AND #$0E                              ; $D86B: 29 0E
  ASL                                   ; $D86D: 0A
  ASL                                   ; $D86E: 0A
  ORA $00                               ; $D86F: 05 00
  ORA #$C0                              ; $D871: 09 C0
  STA $038C                             ; $D873: 8D 8C 03
  LDA #$23                              ; $D876: A9 23
  STA $038B                             ; $D878: 8D 8B 03
  LDA #$01                              ; $D87B: A9 01
  STA $038A                             ; $D87D: 8D 8A 03
  LDA #$FF                              ; $D880: A9 FF
  STA $038E                             ; $D882: 8D 8E 03
  LDA $007E                             ; $D885: AD 7E 00
  ORA #$04                              ; $D888: 09 04
  STA $007E                             ; $D88A: 8D 7E 00
  RTS                                   ; $D88D: 60
@CalcAdjacentTiles:
  ; Check 4 adjacent tiles around cursor and set directional bits in $00
  LDA $10                               ; $D88E: A5 10
  AND #$1E                              ; $D890: 29 1E
  STA $02                               ; $D892: 85 02
  LDA $11                               ; $D894: A5 11
  AND #$1E                              ; $D896: 29 1E
  STA $03                               ; $D898: 85 03
  LDY #$13                              ; $D89A: A0 13
@AdjLoop:
  LDA $12                               ; $D89C: A5 12
  BNE @DoCheck                          ; $D89E: D0 05
  CPY $0509                             ; $D8A0: CC 09 05
  BEQ @AdjNext                          ; $D8A3: F0 03
@DoCheck:
  JSR @CalcScrollNibble                 ; $D8A5: 20 AC D8
@AdjNext:
  DEY                                   ; $D8A8: 88
  BPL @AdjLoop                          ; $D8A9: 10 F1
  RTS                                   ; $D8AB: 60
@CalcScrollNibble:
  LDA $8E                               ; $D8AC: A5 8E
  CLC                                   ; $D8AE: 18
  ADC #$04                              ; $D8AF: 69 04
  BCC @NibbleShift                      ; $D8B1: 90 05
  LDA #$10                              ; $D8B3: A9 10
  JMP @CheckCol                         ; $D8B5: 4C BC D8
@NibbleShift:
  LSR                                   ; $D8B8: 4A
  LSR                                   ; $D8B9: 4A
  LSR                                   ; $D8BA: 4A
  LSR                                   ; $D8BB: 4A
@CheckCol:
  TAX                                   ; $D8BC: AA
  AND #$01                              ; $D8BD: 29 01
  BEQ @CheckAdjacent                    ; $D8BF: F0 16
  TXA                                   ; $D8C1: 8A
  AND #$1F                              ; $D8C2: 29 1F
  STA $04                               ; $D8C4: 85 04
  LDA $10                               ; $D8C6: A5 10
  SEC                                   ; $D8C8: 38
  SBC $04                               ; $D8C9: E5 04
  BNE @NotLeftEdge                      ; $D8CB: D0 03
  JMP @LeftEdge                         ; $D8CD: 4C A7 D9
@NotLeftEdge:
  CMP #$0F                              ; $D8D0: C9 0F
  BNE @CheckAdjacent                    ; $D8D2: D0 03
  JMP @RightEdge                        ; $D8D4: 4C 38 D9
@CheckAdjacent:
  LDA $02                               ; $D8D7: A5 02
  CMP $0600,Y                           ; $D8D9: D9 00 06
  BNE @ChkRight                         ; $D8DC: D0 0F
  LDA $03                               ; $D8DE: A5 03
  CMP $0614,Y                           ; $D8E0: D9 14 06
  BNE @ChkRight                         ; $D8E3: D0 08
  LDA $00                               ; $D8E5: A5 00
  AND #$FC                              ; $D8E7: 29 FC
  ORA #$02                              ; $D8E9: 09 02
  STA $00                               ; $D8EB: 85 00
@ChkRight:
  INC $02                               ; $D8ED: E6 02
  LDA $02                               ; $D8EF: A5 02
  CMP $0600,Y                           ; $D8F1: D9 00 06
  BNE @ChkDown                          ; $D8F4: D0 0F
  LDA $03                               ; $D8F6: A5 03
  CMP $0614,Y                           ; $D8F8: D9 14 06
  BNE @ChkDown                          ; $D8FB: D0 08
  LDA $00                               ; $D8FD: A5 00
  AND #$F3                              ; $D8FF: 29 F3
  ORA #$08                              ; $D901: 09 08
  STA $00                               ; $D903: 85 00
@ChkDown:
  INC $03                               ; $D905: E6 03
  LDA $02                               ; $D907: A5 02
  CMP $0600,Y                           ; $D909: D9 00 06
  BNE @ChkUp                            ; $D90C: D0 0F
  LDA $03                               ; $D90E: A5 03
  CMP $0614,Y                           ; $D910: D9 14 06
  BNE @ChkUp                            ; $D913: D0 08
  LDA $00                               ; $D915: A5 00
  AND #$3F                              ; $D917: 29 3F
  ORA #$80                              ; $D919: 09 80
  STA $00                               ; $D91B: 85 00
@ChkUp:
  DEC $02                               ; $D91D: C6 02
  LDA $02                               ; $D91F: A5 02
  CMP $0600,Y                           ; $D921: D9 00 06
  BNE @AdjExit                          ; $D924: D0 0F
  LDA $03                               ; $D926: A5 03
  CMP $0614,Y                           ; $D928: D9 14 06
  BNE @AdjExit                          ; $D92B: D0 08
  LDA $00                               ; $D92D: A5 00
  AND #$CF                              ; $D92F: 29 CF
  ORA #$20                              ; $D931: 09 20
  STA $00                               ; $D933: 85 00
@AdjExit:
  DEC $03                               ; $D935: C6 03
  RTS                                   ; $D937: 60
@RightEdge:
  LDA $10                               ; $D938: A5 10
  STA $02                               ; $D93A: 85 02
  LDA $02                               ; $D93C: A5 02
  CMP $0600,Y                           ; $D93E: D9 00 06
  BNE @RE_ChkDown                       ; $D941: D0 0F
  LDA $03                               ; $D943: A5 03
  CMP $0614,Y                           ; $D945: D9 14 06
  BNE @RE_ChkDown                       ; $D948: D0 08
  LDA $00                               ; $D94A: A5 00
  AND #$FC                              ; $D94C: 29 FC
  ORA #$02                              ; $D94E: 09 02
  STA $00                               ; $D950: 85 00
@RE_ChkDown:
  INC $03                               ; $D952: E6 03
  LDA $02                               ; $D954: A5 02
  CMP $0600,Y                           ; $D956: D9 00 06
  BNE @RE_ChkLeft                       ; $D959: D0 0F
  LDA $03                               ; $D95B: A5 03
  CMP $0614,Y                           ; $D95D: D9 14 06
  BNE @RE_ChkLeft                       ; $D960: D0 08
  LDA $00                               ; $D962: A5 00
  AND #$CF                              ; $D964: 29 CF
  ORA #$20                              ; $D966: 09 20
  STA $00                               ; $D968: 85 00
@RE_ChkLeft:
  LDA $02                               ; $D96A: A5 02
  SEC                                   ; $D96C: 38
  SBC #$0F                              ; $D96D: E9 0F
  STA $02                               ; $D96F: 85 02
  LDA $02                               ; $D971: A5 02
  CMP $0600,Y                           ; $D973: D9 00 06
  BNE @RE_ChkUp                         ; $D976: D0 0F
  LDA $03                               ; $D978: A5 03
  CMP $0614,Y                           ; $D97A: D9 14 06
  BNE @RE_ChkUp                         ; $D97D: D0 08
  LDA $00                               ; $D97F: A5 00
  AND #$3F                              ; $D981: 29 3F
  ORA #$80                              ; $D983: 09 80
  STA $00                               ; $D985: 85 00
@RE_ChkUp:
  DEC $03                               ; $D987: C6 03
  LDA $02                               ; $D989: A5 02
  CMP $0600,Y                           ; $D98B: D9 00 06
  BNE @RE_Exit                          ; $D98E: D0 0F
  LDA $03                               ; $D990: A5 03
  CMP $0614,Y                           ; $D992: D9 14 06
  BNE @RE_Exit                          ; $D995: D0 08
  LDA $00                               ; $D997: A5 00
  AND #$F3                              ; $D999: 29 F3
  ORA #$08                              ; $D99B: 09 08
  STA $00                               ; $D99D: 85 00
@RE_Exit:
  LDA $02                               ; $D99F: A5 02
  CLC                                   ; $D9A1: 18
  ADC #$0F                              ; $D9A2: 69 0F
  STA $02                               ; $D9A4: 85 02
  RTS                                   ; $D9A6: 60
@LeftEdge:
  LDA $10                               ; $D9A7: A5 10
  STA $02                               ; $D9A9: 85 02
  LDA $02                               ; $D9AB: A5 02
  CLC                                   ; $D9AD: 18
  ADC #$0F                              ; $D9AE: 69 0F
  STA $02                               ; $D9B0: 85 02
  LDA $02                               ; $D9B2: A5 02
  CMP $0600,Y                           ; $D9B4: D9 00 06
  BNE @LE_ChkDown                       ; $D9B7: D0 0F
  LDA $03                               ; $D9B9: A5 03
  CMP $0614,Y                           ; $D9BB: D9 14 06
  BNE @LE_ChkDown                       ; $D9BE: D0 08
  LDA $00                               ; $D9C0: A5 00
  AND #$FC                              ; $D9C2: 29 FC
  ORA #$02                              ; $D9C4: 09 02
  STA $00                               ; $D9C6: 85 00
@LE_ChkDown:
  INC $03                               ; $D9C8: E6 03
  LDA $02                               ; $D9CA: A5 02
  CMP $0600,Y                           ; $D9CC: D9 00 06
  BNE @LE_ChkRight                      ; $D9CF: D0 0F
  LDA $03                               ; $D9D1: A5 03
  CMP $0614,Y                           ; $D9D3: D9 14 06
  BNE @LE_ChkRight                      ; $D9D6: D0 08
  LDA $00                               ; $D9D8: A5 00
  AND #$CF                              ; $D9DA: 29 CF
  ORA #$20                              ; $D9DC: 09 20
  STA $00                               ; $D9DE: 85 00
@LE_ChkRight:
  LDA $02                               ; $D9E0: A5 02
  SEC                                   ; $D9E2: 38
  SBC #$0F                              ; $D9E3: E9 0F
  STA $02                               ; $D9E5: 85 02
  LDA $02                               ; $D9E7: A5 02
  CMP $0600,Y                           ; $D9E9: D9 00 06
  BNE @LE_ChkUp                         ; $D9EC: D0 10
  LDA $03                               ; $D9EE: A5 03
  CMP $0614,Y                           ; $D9F0: D9 14 06
  BNE @LE_ChkUp                         ; $D9F3: D0 09
  LDA $00                               ; $D9F5: A5 00
  AND #$3F                              ; $D9F7: 29 3F
  ORA #$80                              ; $D9F9: 09 80
  STA $0000                             ; $D9FB: 8D 00 00
@LE_ChkUp:
  DEC $03                               ; $D9FE: C6 03
  LDA $02                               ; $DA00: A5 02
  CMP $0600,Y                           ; $DA02: D9 00 06
  BNE @LE_Exit                          ; $DA05: D0 0F
  LDA $03                               ; $DA07: A5 03
  CMP $0614,Y                           ; $DA09: D9 14 06
  BNE @LE_Exit                          ; $DA0C: D0 08
  LDA $00                               ; $DA0E: A5 00
  AND #$F3                              ; $DA10: 29 F3
  ORA #$08                              ; $DA12: 09 08
  STA $00                               ; $DA14: 85 00
@LE_Exit:
  RTS                                   ; $DA16: 60
@PixelToTileCoord:
  ; Convert pixel coords ($0090/$8E/$6F41/$6F3F) to tile coords ($00-$03) by ÷16
  LDA $0090                             ; $DA17: AD 90 00
  STA $00                               ; $DA1A: 85 00
  LDA $0091                             ; $DA1C: AD 91 00
  LSR                                   ; $DA1F: 4A
  ROR $00                               ; $DA20: 66 00
  LSR $00                               ; $DA22: 46 00
  LSR $00                               ; $DA24: 46 00
  LSR $00                               ; $DA26: 46 00
  LDA $8E                               ; $DA28: A5 8E
  STA $01                               ; $DA2A: 85 01
  LDA $8F                               ; $DA2C: A5 8F
  LSR                                   ; $DA2E: 4A
  ROR $01                               ; $DA2F: 66 01
  LSR $01                               ; $DA31: 46 01
  LSR $01                               ; $DA33: 46 01
  LSR $01                               ; $DA35: 46 01
  LDA $6F41                             ; $DA37: AD 41 6F
  STA $02                               ; $DA3A: 85 02
  LDA $6F42                             ; $DA3C: AD 42 6F
  LSR                                   ; $DA3F: 4A
  ROR $02                               ; $DA40: 66 02
  LSR $02                               ; $DA42: 46 02
  LSR $02                               ; $DA44: 46 02
  LSR $02                               ; $DA46: 46 02
  LDA $6F3F                             ; $DA48: AD 3F 6F
  STA $03                               ; $DA4B: 85 03
  LDA $6F40                             ; $DA4D: AD 40 6F
  LSR                                   ; $DA50: 4A
  ROR $03                               ; $DA51: 66 03
  LSR $03                               ; $DA53: 46 03
  LSR $03                               ; $DA55: 46 03
  LSR $03                               ; $DA57: 46 03
  RTS                                   ; $DA59: 60
TileToPixelCoord:
  ; Scale tile coords ($00,$02) by ×16 to pixel coords
  LDA #$00                              ; $DA5A: A9 00
  STA $01                               ; $DA5C: 85 01
  ASL $00                               ; $DA5E: 06 00
  ROL $01                               ; $DA60: 26 01
  ASL $00                               ; $DA62: 06 00
  ROL $01                               ; $DA64: 26 01
  ASL $00                               ; $DA66: 06 00
  ROL $01                               ; $DA68: 26 01
  ASL $00                               ; $DA6A: 06 00
  ROL $01                               ; $DA6C: 26 01
  LDA #$00                              ; $DA6E: A9 00
  STA $03                               ; $DA70: 85 03
  ASL $02                               ; $DA72: 06 02
  ROL $03                               ; $DA74: 26 03
  ASL $02                               ; $DA76: 06 02
  ROL $03                               ; $DA78: 26 03
  ASL $02                               ; $DA7A: 06 02
  ROL $03                               ; $DA7C: 26 03
  ASL $02                               ; $DA7E: 06 02
  ROL $03                               ; $DA80: 26 03
  RTS                                   ; $DA82: 60
SumArmyGroupA_Stats:                    ; $DA83: sum merit for group A ($0628 >= 0)
  LDA #$00                              ; $DA83: A9 00
  STA $000A                             ; $DA85: 8D 0A 00
  STA $000B                             ; $DA88: 8D 0B 00
  STA $000C                             ; $DA8B: 8D 0C 00
  LDX #$13                              ; $DA8E: A2 13
@LoopA:
  LDA $0628,X                           ; $DA90: BD 28 06
  BMI @NextA                            ; $DA93: 30 2A
  LDA $0664,X                           ; $DA95: BD 64 06
  CMP #$FF                              ; $DA98: C9 FF
  BEQ @NextA                            ; $DA9A: F0 23
  JSR B1F_GetOfficerRecordAddr          ; $DA9C: 20 D7 F2
  LDY #$09                              ; $DA9F: A0 09
  LDA ($00),Y                           ; $DAA1: B1 00
  AND #$03                              ; $DAA3: 29 03
  STA $0002                             ; $DAA5: 8D 02 00
  LDY #$08                              ; $DAA8: A0 08
  LDA ($00),Y                           ; $DAAA: B1 00
  CLC                                   ; $DAAC: 18
  ADC $000B                             ; $DAAD: 6D 0B 00
  STA $000B                             ; $DAB0: 8D 0B 00
  LDA $000C                             ; $DAB3: AD 0C 00
  ADC $0002                             ; $DAB6: 6D 02 00
  STA $000C                             ; $DAB9: 8D 0C 00
  INC $000A                             ; $DABC: EE 0A 00
@NextA:
  DEX                                   ; $DABF: CA
  BPL @LoopA                            ; $DAC0: 10 CE
  RTS                                   ; $DAC2: 60
SumArmyGroupB_Stats:                    ; $DAC3: sum merit for group B ($0628 < 0)
  LDA #$00                              ; $DAC3: A9 00
  STA $000A                             ; $DAC5: 8D 0A 00
  STA $000B                             ; $DAC8: 8D 0B 00
  STA $000C                             ; $DACB: 8D 0C 00
  LDX #$13                              ; $DACE: A2 13
@LoopB:
  LDA $0628,X                           ; $DAD0: BD 28 06
  BPL @NextB                            ; $DAD3: 10 2A
  LDA $0664,X                           ; $DAD5: BD 64 06
  CMP #$FF                              ; $DAD8: C9 FF
  BEQ @NextB                            ; $DADA: F0 23
  JSR B1F_GetOfficerRecordAddr          ; $DADC: 20 D7 F2
  LDY #$09                              ; $DADF: A0 09
  LDA ($00),Y                           ; $DAE1: B1 00
  AND #$03                              ; $DAE3: 29 03
  STA $0002                             ; $DAE5: 8D 02 00
  LDY #$08                              ; $DAE8: A0 08
  LDA ($00),Y                           ; $DAEA: B1 00
  CLC                                   ; $DAEC: 18
  ADC $000B                             ; $DAED: 6D 0B 00
  STA $000B                             ; $DAF0: 8D 0B 00
  LDA $000C                             ; $DAF3: AD 0C 00
  ADC $0002                             ; $DAF6: 6D 02 00
  STA $000C                             ; $DAF9: 8D 0C 00
  INC $000A                             ; $DAFC: EE 0A 00
@NextB:
  DEX                                   ; $DAFF: CA
  BPL @LoopB                            ; $DB00: 10 CE
  RTS                                   ; $DB02: 60
CalcOfficerMeritLevels:                 ; $DB03: compute (byte8|(byte9&3)<<8)/100 per officer → $063C
  LDY #$31                              ; $DB03: A0 31
  JSR B1F_SwitchBank8_B                 ; $DB05: 20 5F F2
  LDX #$13                              ; $DB08: A2 13
@MeritLoop:
  LDA $0664,X                           ; $DB0A: BD 64 06
  CMP #$FF                              ; $DB0D: C9 FF
  BEQ @StoreMerit                       ; $DB0F: F0 2E
  JSR B1F_GetOfficerRecordAddr          ; $DB11: 20 D7 F2
  TXA                                   ; $DB14: 8A
  PHA                                   ; $DB15: 48
  LDY #$08                              ; $DB16: A0 08
  LDA ($00),Y                           ; $DB18: B1 00
  PHA                                   ; $DB1A: 48
  LDY #$09                              ; $DB1B: A0 09
  LDA ($00),Y                           ; $DB1D: B1 00
  AND #$03                              ; $DB1F: 29 03
  STA $0001                             ; $DB21: 8D 01 00
  PLA                                   ; $DB24: 68
  STA $0000                             ; $DB25: 8D 00 00
  LDA #$00                              ; $DB28: A9 00
  STA $0002                             ; $DB2A: 8D 02 00
  LDA #$64                              ; $DB2D: A9 64
  STA $0003                             ; $DB2F: 8D 03 00
  LDA #$00                              ; $DB32: A9 00
  STA $0004                             ; $DB34: 8D 04 00
  JSR B1F_MathDiv24                     ; $DB37: 20 A5 EA
  PLA                                   ; $DB3A: 68
  TAX                                   ; $DB3B: AA
  LDA $0000                             ; $DB3C: AD 00 00
@StoreMerit:
  STA $063C,X                           ; $DB3F: 9D 3C 06
  DEX                                   ; $DB42: CA
  BPL @MeritLoop                        ; $DB43: 10 C5
  RTS                                   ; $DB45: 60
GetTerrainType:
  ; Get terrain type at position; returns value 0-5 (clamped)
  JSR @GetTerrainCode                  ; $DB46: 20 50 DB
  CMP #$06                              ; $DB49: C9 06
  BCC @ClampDone                        ; $DB4B: 90 02
  LDA #$02                              ; $DB4D: A9 02
@ClampDone:
  RTS                                   ; $DB4F: 60
@GetTerrainCode:
  ; Look up terrain code from map data via banked callback; returns raw tile value
  LDY #$00                              ; $DB50: A0 00
  LDA $0010                             ; $DB52: AD 10 00
  CMP #$10                              ; $DB55: C9 10
  BCC @CheckRowQ                        ; $DB57: 90 02
  LDY #$01                              ; $DB59: A0 01
@CheckRowQ:
  LDA $0011                             ; $DB5B: AD 11 00
  CMP #$10                              ; $DB5E: C9 10
  BCC @LookupTile                       ; $DB60: 90 04
  TYA                                   ; $DB62: 98
  ORA #$02                              ; $DB63: 09 02
  TAY                                   ; $DB65: A8
@LookupTile:
  LDA ($A8),Y                           ; $DB66: B1 A8
  STA $0000                             ; $DB68: 8D 00 00
  LDY #$37                              ; $DB6B: A0 37
  JSR B1F_BankedCallbackTrampoline      ; $DB6D: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                               ; $DB70: $12 A0
  LDA #$9E                                    ; $DB72: A9 9E
  STA $0002                                   ; $DB74: 8D 02 00
  LDA #$DB                                    ; $DB77: A9 DB
  STA $0003                                   ; $DB79: 8D 03 00
  LDA $0010                                   ; $DB7C: AD 10 00
  AND #$0F                                    ; $DB7F: 29 0F
  STA $0008                                   ; $DB81: 8D 08 00
  LDX #$00                                    ; $DB84: A2 00
  LDA $0011                                   ; $DB86: AD 11 00
  ASL A                                       ; $DB89: 0A
  ASL A                                       ; $DB8A: 0A
  ASL A                                       ; $DB8B: 0A
  ASL A                                       ; $DB8C: 0A
  ORA $0008                                   ; $DB8D: 0D 08 00
  TAY                                         ; $DB90: A8
  LDA ($00),Y                                 ; $DB91: B1 00
  TAY                                         ; $DB93: A8
  CMP #$80                                    ; $DB94: C9 80
  BCC @FetchCode                        ; $DB96: 90 03
  LDA #$00                                    ; $DB98: A9 00
  RTS                                         ; $DB9A: 60
@FetchCode:
  LDA ($02),Y                           ; $DB9B: B1 02
  RTS                                   ; $DB9D: 60
TerrainTypeTable:
  .byte $00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03; $DB9E: 00 01 03 03 03 03 03 03 03 03 03 03 03 03 03 03
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02; $DBAE: 03 03 03 03 03 03 03 03 03 03 03 03 02 02 02 02
  .byte $04,$04,$02,$04,$04,$02,$04,$02,$04,$04,$04,$02,$00,$00,$02,$02; $DBBE: 04 04 02 04 04 02 04 02 04 04 04 02 00 00 02 02
  .byte $02,$02,$02,$02,$02,$02,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00; $DBCE: 02 02 02 02 02 02 00 00 00 02 00 00 00 00 00 00
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$02,$00,$00,$00,$02,$02,$02,$02; $DBDE: 03 03 03 03 03 03 03 03 02 00 00 00 02 02 02 02
  .byte $02,$02,$02,$02,$02,$02,$04,$02,$02,$04,$02,$04,$04,$04,$03,$00; $DBEE: 02 02 02 02 02 02 04 02 02 04 02 04 04 04 03 00
  .byte $00,$05,$05,$05,$05,$03,$00,$03,$03,$03,$01,$01,$01,$01,$02,$02; $DBFE: 00 05 05 05 05 03 00 03 03 03 01 01 01 01 02 02
  .byte $01,$02,$02,$02,$01,$02,$02,$03,$03,$06,$07,$08,$00,$00,$00,$00; $DC0E: 01 02 02 02 01 02 02 03 03 06 07 08 00 00 00 00
ClearEmptyRosterSlots:
  ; For each empty roster slot ($0664==$FF), clear position ($0600/$0614)
; --- Code Region ---
  LDY #$13                              ; $DC1E: A0 13
@ClearLoop:
  LDA $0664,Y                           ; $DC20: B9 64 06
  CMP #$FF                              ; $DC23: C9 FF
  BNE @ClearNext                        ; $DC25: D0 08
  LDA #$FF                              ; $DC27: A9 FF
  STA $0600,Y                           ; $DC29: 99 00 06
  STA $0614,Y                           ; $DC2C: 99 14 06
@ClearNext:
  DEY                                   ; $DC2F: 88
  BPL @ClearLoop                        ; $DC30: 10 EE
  RTS                                   ; $DC32: 60
CenterMapOnOfficer:
  ; Center map view on the currently selected officer ($0509)
  LDY $0509                             ; $DC33: AC 09 05
CenterMapOnSlot:
  ; Center map on officer in roster slot Y
  LDA $0664,Y                           ; $DC36: B9 64 06
  STA $0000                             ; $DC39: 8D 00 00
  LDA #$A7                              ; $DC3C: A9 A7
  STA $000A                             ; $DC3E: 8D 0A 00
  LDX #$00                              ; $DC41: A2 00
  LDY #$39                              ; $DC43: A0 39
  JSR B1F_BankedCallbackTrampoline      ; $DC45: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                               ; $DC48: $00 A0
  RTS                                         ; $DC4A: 60
CheckOfficerArmyGroup:
  ; Check if officer at Y belongs to correct army group; returns $00 or $FF
  LDA $0504                                   ; $DC4B: AD 04 05
  BMI @CheckGroupB                      ; $DC4E: 30 0B
  LDA $0628,Y                                 ; $DC50: B9 28 06
  BMI @ReturnFF                         ; $DC53: 30 03
  LDA #$00                                    ; $DC55: A9 00
  RTS                                         ; $DC57: 60
@ReturnFF:
  LDA #$FF                              ; $DC58: A9 FF
  RTS                                   ; $DC5A: 60
@CheckGroupB:
  LDA $0628,Y                           ; $DC5B: B9 28 06
  BPL @ReturnFF                         ; $DC5E: 10 F8
  LDA #$00                              ; $DC60: A9 00
  RTS                                   ; $DC62: 60
DrawExchangeArrows_Right:
  ; Draw exchange direction arrows (right variant, $000A=$D8)
  LDA #$D8                              ; $DC63: A9 D8
  STA $000A                             ; $DC65: 8D 0A 00
  LDA #$A0                              ; $DC68: A9 A0
  STA $000C                             ; $DC6A: 8D 0C 00
  JMP @DrawArrows                       ; $DC6D: 4C 7A DC
DrawExchangeArrows_Left:
  ; Draw exchange direction arrows (left variant, $000A=$E0)
  LDA #$E0                              ; $DC70: A9 E0
  STA $000A                             ; $DC72: 8D 0A 00
  LDA #$A0                              ; $DC75: A9 A0
  STA $000C                             ; $DC77: 8D 0C 00
@DrawArrows:
  LDA $005E                             ; $DC7A: AD 5E 00
  AND #$10                              ; $DC7D: 29 10
  BNE @ArrowExit                        ; $DC7F: D0 12
  LDA #$94                              ; $DC81: A9 94
  STA $0000                             ; $DC83: 8D 00 00
  LDA #$DC                              ; $DC86: A9 DC
  STA $0001                             ; $DC88: 8D 01 00
  LDA #$00                              ; $DC8B: A9 00
  STA $0002                             ; $DC8D: 8D 02 00
  JMP B1F_SpriteOamWriterSimple         ; $DC90: 4C AD F1
@ArrowExit:
  RTS                                   ; $DC93: 60
ExchangeArrowOam:
  .byte $00,$04,$00,$00,$80               ; $DC94: 00 04 00 00 80
ExchangeScene_Init:
  ; Initialize exchange scene: set up map bounds, rosters, army groups, merit levels
; --- Code Region ---
  LDY #$31                              ; $DC99: A0 31
  JSR B1F_SwitchBank8_B                 ; $DC9B: 20 5F F2
  LDA province_idx                             ; $DC9E: AD 02 04
  ASL                                   ; $DCA1: 0A
  ASL                                   ; $DCA2: 0A
  TAY                                   ; $DCA3: A8
  LDA $9D5A,Y                           ; $DCA4: B9 5A 9D
  SEC                                   ; $DCA7: 38
  SBC #$80                              ; $DCA8: E9 80
  STA $0512                             ; $DCAA: 8D 12 05
  LDA $9D5B,Y                           ; $DCAD: B9 5B 9D
  SBC #$00                              ; $DCB0: E9 00
  STA $0513                             ; $DCB2: 8D 13 05
  BCS @ClampX                           ; $DCB5: B0 08
  LDA #$00                              ; $DCB7: A9 00
  STA $0512                             ; $DCB9: 8D 12 05
  STA $0513                             ; $DCBC: 8D 13 05
@ClampX:
  LDA $0513                             ; $DCBF: AD 13 05
  BEQ @ClampY                           ; $DCC2: F0 0A
  LDA #$FE                              ; $DCC4: A9 FE
  STA $0512                             ; $DCC6: 8D 12 05
  LDA #$00                              ; $DCC9: A9 00
  STA $0513                             ; $DCCB: 8D 13 05
@ClampY:
  LDA $9D58,Y                           ; $DCCE: B9 58 9D
  SEC                                   ; $DCD1: 38
  SBC #$60                              ; $DCD2: E9 60
  STA $0510                             ; $DCD4: 8D 10 05
  LDA $9D59,Y                           ; $DCD7: B9 59 9D
  SBC #$00                              ; $DCDA: E9 00
  STA $0511                             ; $DCDC: 8D 11 05
  BCS @CheckMaxX                        ; $DCDF: B0 08
  LDA #$00                              ; $DCE1: A9 00
  STA $0510                             ; $DCE3: 8D 10 05
  STA $0511                             ; $DCE6: 8D 11 05
@CheckMaxX:
  LDA $0510                             ; $DCE9: AD 10 05
  CMP #$90                              ; $DCEC: C9 90
  BCC @ClearState                       ; $DCEE: 90 0A
  LDA #$8E                              ; $DCF0: A9 8E
  STA $0510                             ; $DCF2: 8D 10 05
  LDA #$00                              ; $DCF5: A9 00
  STA $0511                             ; $DCF7: 8D 11 05
@ClearState:
  LDA province_idx                             ; $DCFA: AD 02 04
  STA $052A                             ; $DCFD: 8D 2A 05
  LDA #$00                              ; $DD00: A9 00
  STA $050C                             ; $DD02: 8D 0C 05
  STA $050D                             ; $DD05: 8D 0D 05
  STA $051A                             ; $DD08: 8D 1A 05
  STA $051B                             ; $DD0B: 8D 1B 05
  STA $051C                             ; $DD0E: 8D 1C 05
  STA $051D                             ; $DD11: 8D 1D 05
  STA $051E                             ; $DD14: 8D 1E 05
  STA $051F                             ; $DD17: 8D 1F 05
  STA $0520                             ; $DD1A: 8D 20 05
  STA $0521                             ; $DD1D: 8D 21 05
  LDA #$FF                              ; $DD20: A9 FF
  STA $052B                             ; $DD22: 8D 2B 05
  LDY #$27                              ; $DD25: A0 27
  LDA #$FF                              ; $DD27: A9 FF
@ClearReserve:
  STA $6F47,Y                           ; $DD29: 99 47 6F
  DEY                                   ; $DD2C: 88
  BPL @ClearReserve                     ; $DD2D: 10 FA
  LDX #$13                              ; $DD2F: A2 13
@InitLoop:
  LDA $0664,X                           ; $DD31: BD 64 06
  CMP #$FF                              ; $DD34: C9 FF
  BEQ @ClearAll                         ; $DD36: F0 24
  JSR B1F_GetOfficerRecordAddr          ; $DD38: 20 D7 F2
  LDA #$FF                              ; $DD3B: A9 FF
  STA $0600,X                           ; $DD3D: 9D 00 06
  STA $0614,X                           ; $DD40: 9D 14 06
  LDY #$0B                              ; $DD43: A0 0B
  LDA ($00),Y                           ; $DD45: B1 00
  LSR                                   ; $DD47: 4A
  LSR                                   ; $DD48: 4A
  AND #$03                              ; $DD49: 29 03
  CPX #$0A                              ; $DD4B: E0 0A
  BCC @StoreGroup                       ; $DD4D: 90 02
  ORA #$80                              ; $DD4F: 09 80
@StoreGroup:
  STA $0628,X                           ; $DD51: 9D 28 06
  LDA #$00                              ; $DD54: A9 00
  STA $0650,X                           ; $DD56: 9D 50 06
  JMP @InitNext                         ; $DD59: 4C 6B DD
@ClearAll:
  STA $0600,X                           ; $DD5C: 9D 00 06
  STA $0614,X                           ; $DD5F: 9D 14 06
  STA $0628,X                           ; $DD62: 9D 28 06
  STA $063C,X                           ; $DD65: 9D 3C 06
  STA $0650,X                           ; $DD68: 9D 50 06
@InitNext:
  DEX                                   ; $DD6B: CA
  BPL @InitLoop                         ; $DD6C: 10 C3
  JSR CalcOfficerMeritLevels             ; $DD6E: 20 03 DB
  RTS                                   ; $DD71: 60
CheckExchangeGroupStatus:
  ; Check first city slot for group A membership; falls through to state machine
  LDX #$00                              ; $DD72: A2 00
  LDA $0664                             ; $DD74: AD 64 06
  CMP #$FF                              ; $DD77: C9 FF
  BEQ @ExchangeTurnStateMachine         ; $DD79: F0 05
  LDA $0628                             ; $DD7B: AD 28 06
  BPL @CheckSecondSlot                  ; $DD7E: 10 0F
@ExchangeTurnStateMachine:
  ; Exchange turn state machine: handles group selection, ruler checks, scene transitions
  LDA #$00                              ; $DD80: A9 00
  STA $0514                             ; $DD82: 8D 14 05
  LDA $052B                             ; $DD85: AD 2B 05
  CMP #$FF                              ; $DD88: C9 FF
  BNE @StartExchange                    ; $DD8A: D0 20
  JMP @SelectGroupA                     ; $DD8C: 4C B9 DD
@CheckSecondSlot:
  INX                                   ; $DD8F: E8
  LDA $066E                             ; $DD90: AD 6E 06
  CMP #$FF                              ; $DD93: C9 FF
  BEQ @SetFlag                          ; $DD95: F0 05
  LDA $0632                             ; $DD97: AD 32 06
  BMI @GroupOk                          ; $DD9A: 30 0F
@SetFlag:
  LDA #$01                              ; $DD9C: A9 01
  STA $0514                             ; $DD9E: 8D 14 05
  LDA $052B                             ; $DDA1: AD 2B 05
  CMP #$FF                              ; $DDA4: C9 FF
  BNE @StartExchange                    ; $DDA6: D0 04
  JMP @SelectGroupB                     ; $DDA8: 4C 14 DE
@GroupOk:
  RTS                                   ; $DDAB: 60
@StartExchange:
  LDA #$0C                              ; $DDAC: A9 0C
  STA $0500                             ; $DDAE: 8D 00 05
  LDA #$00                              ; $DDB1: A9 00
  STA $0501                             ; $DDB3: 8D 01 05
  PLA                                   ; $DDB6: 68
  PLA                                   ; $DDB7: 68
  RTS                                   ; $DDB8: 60
@SelectGroupA:
  LDA #$07                              ; $DDB9: A9 07
  STA $0500                             ; $DDBB: 8D 00 05
  LDA #$02                              ; $DDBE: A9 02
  STA $0501                             ; $DDC0: 8D 01 05
  PLA                                   ; $DDC3: 68
  PLA                                   ; $DDC4: 68
  LDA $0507                             ; $DDC5: AD 07 05
  AND #$0F                              ; $DDC8: 29 0F
  STA officer_sel_list                             ; $DDCA: 8D 2C 04
  LDA #$00                              ; $DDCD: A9 00
  JSR @FindFirstOfficerByGroup             ; $DDCF: 20 82 DE
  BCS @FoundOfficer                     ; $DDD2: B0 03
  JMP @NextRuler                        ; $DDD4: 4C 6D DE
@FoundOfficer:
  STY $0509                             ; $DDD7: 8C 09 05
  LDA $0507                             ; $DDDA: AD 07 05
  LSR                                   ; $DDDD: 4A
  LSR                                   ; $DDDE: 4A
  LSR                                   ; $DDDF: 4A
  LSR                                   ; $DDE0: 4A
  JSR B1F_GetRulerDataPtr               ; $DDE1: 20 68 F3
  LDY #$03                              ; $DDE4: A0 03
  LDA ($00),Y                           ; $DDE6: B1 00
  CMP #$03                              ; $DDE8: C9 03
  BNE @NotRuler3A                       ; $DDEA: D0 0B
  LDA #$04                              ; $DDEC: A9 04
  STA $00A4                             ; $DDEE: 8D A4 00
  LDA #$54                              ; $DDF1: A9 54
  STA $050A                             ; $DDF3: 8D 0A 05
  RTS                                   ; $DDF6: 60
@NotRuler3A:
  STA $6F44                             ; $DDF7: 8D 44 6F
  LDA $0507                             ; $DDFA: AD 07 05
  LSR                                   ; $DDFD: 4A
  LSR                                   ; $DDFE: 4A
  LSR                                   ; $DDFF: 4A
  LSR                                   ; $DE00: 4A
  STA officer_sel_list                             ; $DE01: 8D 2C 04
  LDA #$0A                              ; $DE04: A9 0A
  STA $0509                             ; $DE06: 8D 09 05
  LDA #$03                              ; $DE09: A9 03
  STA $00A4                             ; $DE0B: 8D A4 00
  LDA #$53                              ; $DE0E: A9 53
  STA $050A                             ; $DE10: 8D 0A 05
  RTS                                   ; $DE13: 60
@SelectGroupB:
  LDA #$07                              ; $DE14: A9 07
  STA $0500                             ; $DE16: 8D 00 05
  LDA #$02                              ; $DE19: A9 02
  STA $0501                             ; $DE1B: 8D 01 05
  PLA                                   ; $DE1E: 68
  PLA                                   ; $DE1F: 68
@ExchangeSelectTarget:
  ; (dispatch callback target) Select target officer for exchange from group B
  LDA $0507                             ; $DE20: AD 07 05
  LSR                                   ; $DE23: 4A
  LSR                                   ; $DE24: 4A
  LSR                                   ; $DE25: 4A
  LSR                                   ; $DE26: 4A
  STA officer_sel_list                             ; $DE27: 8D 2C 04
  LDA #$80                              ; $DE2A: A9 80
  JSR @FindFirstOfficerByGroup             ; $DE2C: 20 82 DE
  BCS @FoundOfficerB                    ; $DE2F: B0 03
  JMP @NextRuler                        ; $DE31: 4C 6D DE
@FoundOfficerB:
  STY $0509                             ; $DE34: 8C 09 05
  LDA $0507                             ; $DE37: AD 07 05
  AND #$0F                              ; $DE3A: 29 0F
  JSR B1F_GetRulerDataPtr               ; $DE3C: 20 68 F3
  LDY #$03                              ; $DE3F: A0 03
  LDA ($00),Y                           ; $DE41: B1 00
  CMP #$03                              ; $DE43: C9 03
  BNE @NotRuler3B                       ; $DE45: D0 0B
  LDA #$04                              ; $DE47: A9 04
  STA $00A4                             ; $DE49: 8D A4 00
  LDA #$54                              ; $DE4C: A9 54
  STA $050A                             ; $DE4E: 8D 0A 05
  RTS                                   ; $DE51: 60
@NotRuler3B:
  STA $6F44                             ; $DE52: 8D 44 6F
  LDA $0507                             ; $DE55: AD 07 05
  AND #$0F                              ; $DE58: 29 0F
  STA officer_sel_list                             ; $DE5A: 8D 2C 04
  LDA #$00                              ; $DE5D: A9 00
  STA $0509                             ; $DE5F: 8D 09 05
  LDA #$03                              ; $DE62: A9 03
  STA $00A4                             ; $DE64: 8D A4 00
  LDA #$53                              ; $DE67: A9 53
  STA $050A                             ; $DE69: 8D 0A 05
  RTS                                   ; $DE6C: 60
@NextRuler:
  LDA officer_sel_list                             ; $DE6D: AD 2C 04
  JSR B1F_GetRulerDataPtr               ; $DE70: 20 68 F3
  LDY #$00                              ; $DE73: A0 00
  LDA ($00),Y                           ; $DE75: B1 00
  STA officer_sel_list                             ; $DE77: 8D 2C 04
  INC $0501                             ; $DE7A: EE 01 05
  LDA #$55                              ; $DE7D: A9 55
  JMP B1F_SetUI5                        ; $DE7F: 4C 93 F2
@FindFirstOfficerByGroup:
  ; Find first officer in army group matching flag in A; carry set if found, Y=slot
  STA $0002                             ; $DE82: 8D 02 00
  LDY #$00                              ; $DE85: A0 00
@SearchLoop:
  LDA $0628,Y                           ; $DE87: B9 28 06
  CMP #$FF                              ; $DE8A: C9 FF
  BEQ @SearchNext                       ; $DE8C: F0 07
  AND #$80                              ; $DE8E: 29 80
  CMP $0002                             ; $DE90: CD 02 00
  BEQ @SearchFound                      ; $DE93: F0 07
@SearchNext:
  INY                                   ; $DE95: C8
  CPY #$14                              ; $DE96: C0 14
  BCC @SearchLoop                       ; $DE98: 90 ED
  CLC                                   ; $DE9A: 18
  RTS                                   ; $DE9B: 60
@SearchFound:
  SEC                                   ; $DE9C: 38
  RTS                                   ; $DE9D: 60
GetCityDataA:
  ; Get city data byte from table $9D72 for current scene ($050E)
  LDY #$30                              ; $DE9E: A0 30
  JSR B1F_SwitchBank8_B                 ; $DEA0: 20 5F F2
  LDA $050E                             ; $DEA3: AD 0E 05
  ASL                                   ; $DEA6: 0A
  ASL                                   ; $DEA7: 0A
  ASL                                   ; $DEA8: 0A
  TAY                                   ; $DEA9: A8
@CityLoop:
  LDA $9D72,Y                           ; $DEAA: B9 72 9D
  BMI @CityNone                         ; $DEAD: 30 0D
  CMP $052A                             ; $DEAF: CD 2A 05
  BEQ @CityFound                        ; $DEB2: F0 04
  INY                                   ; $DEB4: C8
  JMP @CityLoop                         ; $DEB5: 4C AA DE
@CityFound:
  LDA $9E62,Y                           ; $DEB8: B9 62 9E
  RTS                                   ; $DEBB: 60
@CityNone:
  LDA #$00                              ; $DEBC: A9 00
  RTS                                   ; $DEBE: 60
GetCityOfficerData:
  ; Get officer data from table $9AB4 for current scene ($050E)
  LDY #$30                              ; $DEBF: A0 30
  JSR B1F_SwitchBank8_B                 ; $DEC1: 20 5F F2
  LDA $050E                             ; $DEC4: AD 0E 05
  ASL                                   ; $DEC7: 0A
  ASL                                   ; $DEC8: 0A
  ASL                                   ; $DEC9: 0A
  TAY                                   ; $DECA: A8
@OfficerLoop:
  LDA $9D72,Y                           ; $DECB: B9 72 9D
  BMI @OfficerNone                      ; $DECE: 30 16
  CMP $052A                             ; $DED0: CD 2A 05
  BEQ @OfficerFound                     ; $DED3: F0 04
  INY                                   ; $DED5: C8
  JMP @OfficerLoop                      ; $DED6: 4C CB DE
@OfficerFound:
  TYA                                   ; $DED9: 98
  PHA                                   ; $DEDA: 48
  LDY #$31                              ; $DEDB: A0 31
  JSR B1F_SwitchBank8_B                 ; $DEDD: 20 5F F2
  PLA                                   ; $DEE0: 68
  TAY                                   ; $DEE1: A8
  LDA $9AB4,Y                           ; $DEE2: B9 B4 9A
  RTS                                   ; $DEE5: 60
@OfficerNone:
  LDA #$00                              ; $DEE6: A9 00
  RTS                                   ; $DEE8: 60
ValidateExchangeOfficer:
  ; Validate officer $042C for exchange; check allegiance, compute level diff
  LDA officer_sel_list                             ; $DEE9: AD 2C 04
  JSR B1F_GetOfficerRecordAddr          ; $DEEC: 20 D7 F2
  LDY #$0B                              ; $DEEF: A0 0B
  LDA ($00),Y                           ; $DEF1: B1 00
  AND #$F0                              ; $DEF3: 29 F0
  CMP $052C                             ; $DEF5: CD 2C 05
  BEQ @Valid                            ; $DEF8: F0 2B
  LDY #$01                              ; $DEFA: A0 01
  LDA ($00),Y                           ; $DEFC: B1 00
  SEC                                   ; $DEFE: 38
  SBC $052E                             ; $DEFF: ED 2E 05
  STA officer_sel_list+3                             ; $DF02: 8D 2F 04
  LDA #$00                              ; $DF05: A9 00
  STA officer_sel_list+1                             ; $DF07: 8D 2D 04
  STA officer_sel_list+4                             ; $DF0A: 8D 30 04
  STA officer_sel_list+5                             ; $DF0D: 8D 31 04
  LDY #$28                              ; $DF10: A0 28
  JSR B1F_BankedCallbackTrampoline      ; $DF12: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A018                               ; $DF15: $18 A0
  LDA #$4A                                    ; $DF17: A9 4A
  LDY $042F                                   ; $DF19: AC 2F 04
  BNE @SetResult                        ; $DF1C: D0 02
  LDA #$4D                                    ; $DF1E: A9 4D
@SetResult:
  JSR B1F_SetUI5                        ; $DF20: 20 93 F2
  SEC                                   ; $DF23: 38
  RTS                                   ; $DF24: 60
@Valid:
  CLC                                   ; $DF25: 18
  RTS                                   ; $DF26: 60
CheckExchangePossible:
  ; Check if exchange is possible: $0304 or $0300 must not be $FF
  LDA $0304                             ; $DF27: AD 04 03
  CMP #$FF                              ; $DF2A: C9 FF
  BNE @Possible                         ; $DF2C: D0 09
  LDA $0300                             ; $DF2E: AD 00 03
  CMP #$FF                              ; $DF31: C9 FF
  BNE @Possible                         ; $DF33: D0 02
  SEC                                   ; $DF35: 38
  RTS                                   ; $DF36: 60
@Possible:
  CLC                                   ; $DF37: 18
  RTS                                   ; $DF38: 60
SetupExchangeSfx:
  ; Configure sound effect parameters for exchange events based on $0518 state
  LDA $0518                             ; $DF39: AD 18 05
  BNE @CheckState                       ; $DF3C: D0 31
  LDA #$68                              ; $DF3E: A9 68
  STA $68                               ; $DF40: 85 68
  LDA #$E4                              ; $DF42: A9 E4
  STA $69                               ; $DF44: 85 69
  LDA #$96                              ; $DF46: A9 96
  STA $6A                               ; $DF48: 85 6A
  LDA #$EF                              ; $DF4A: A9 EF
  STA $6B                               ; $DF4C: 85 6B
  LDA #$30                              ; $DF4E: A9 30
  STA $6C                               ; $DF50: 85 6C
  LDA #$F2                              ; $DF52: A9 F2
  STA $6D                               ; $DF54: 85 6D
  LDA #$40                              ; $DF56: A9 40
  STA $6E                               ; $DF58: 85 6E
  LDA #$EA                              ; $DF5A: A9 EA
  STA $6F                               ; $DF5C: 85 6F
  LDA #$20                              ; $DF5E: A9 20
  STA $70                               ; $DF60: 85 70
  LDA #$F8                              ; $DF62: A9 F8
  STA $71                               ; $DF64: 85 71
  LDA #$07                              ; $DF66: A9 07
  STA $61                               ; $DF68: 85 61
  LDA #$FF                              ; $DF6A: A9 FF
  STA $0518                             ; $DF6C: 8D 18 05
@CheckState:
  LDA $0518                             ; $DF6F: AD 18 05
  CMP #$01                              ; $DF72: C9 01
  BNE @SfxDone                          ; $DF74: D0 11
  LDA #$72                              ; $DF76: A9 72
  STA $68                               ; $DF78: 85 68
  LDA #$AF                              ; $DF7A: A9 AF
  STA $69                               ; $DF7C: 85 69
  LDA #$05                              ; $DF7E: A9 05
  STA $61                               ; $DF80: 85 61
  LDA #$FF                              ; $DF82: A9 FF
  STA $0518                             ; $DF84: 8D 18 05
@SfxDone:
  RTS                                   ; $DF87: 60
UpdateExchangeSfx:
  ; Adjust SFX tone based on horizontal scroll position ($8E)
  LDA $61                               ; $DF88: A5 61
  CMP #$05                              ; $DF8A: C9 05
  BNE @SfxExit                          ; $DF8C: D0 0F
  LDA $8E                               ; $DF8E: A5 8E
  CMP #$10                              ; $DF90: C9 10
  BCS @RightSide                        ; $DF92: B0 05
  LDA #$72                              ; $DF94: A9 72
  STA $68                               ; $DF96: 85 68
  RTS                                   ; $DF98: 60
@RightSide:
  LDA #$74                              ; $DF99: A9 74
  STA $68                               ; $DF9B: 85 68
@SfxExit:
  RTS                                   ; $DF9D: 60
@BankEndPadding:
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DF9E: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFAE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFBE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFCE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFDE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFEE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF                           ; $DFFE: FF FF
.endproc

