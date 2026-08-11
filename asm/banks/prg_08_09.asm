;===============================================================================
; PRG Banks $08+$09 - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $08 at $A000-$BFFF, Bank $09 at $C000-$DFFF
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

;===============================================================================
; RAM map (WRAM $0400-$06FF work area, SRAM $6F00-$6FFF) - battle context
; Cross-proc globals for this bank. Addresses shared with other scenes reuse
; the canonical globals defined in the owning bank files:
;   $0424/$0425 = menu_cursor_col/menu_cursor_page (prg_0c_0d.asm)
;   $04D8       = army_slot_base (+1 target X, +2 target Y, +3 timer,
;                 +4 group 1 owner, +5..+7 group 1 timers) (prg_0c_0d.asm)
;   $6F8B       = sram_game_start_flag (prg_0a_0b.asm)
;===============================================================================
; --- Battle scene state ($0500-$0514) ---
battle_scene_id        = $0500  ; battle scene/command id (state select)
battle_scene_phase     = $0501  ; battle scene phase/state index
battle_side_flag       = $0504  ; acting-side flag (bit7: 1=attacker, 0=defender)
battle_action_points   = $0505  ; AI action budget / status panel counter
battle_round_counter   = $0506  ; battle round/day counter
battle_faction_pair    = $0507  ; packed faction pair (lo=side 0, hi=side 1)
battle_officer_slot    = $0509  ; acting officer slot / scene variant
battle_scene_index     = $050A  ; scene/command index (result scene $50/$51)
battle_province_idx    = $050E  ; battle province (group) index
battle_attacker_code   = $050F  ; attacker code (3 = ally side)
battle_side_selector   = $0514  ; side selector (0/1, cleared on result init)
; --- Per-side stat pairs ($0522-$052C, side 1 entries at +2) ---
battle_stat_a_lo       = $0522  ; side 0 stat A lo (side 1 at +2)
battle_stat_a_hi       = $0523  ; side 0 stat A hi (side 1 at +2)
battle_stat_b_lo       = $0526  ; side 0 stat B lo (side 1 at +2)
battle_stat_b_hi       = $0527  ; side 0 stat B hi (side 1 at +2)
battle_target_province = $052A  ; battle/retreat target province
battle_target_officer  = $052B  ; secondary/special target officer id
battle_target_param    = $052C  ; secondary target param (officer/province)
; --- Action result triple ($042C-$042E, also slot position records) ---
action_result_lo       = $042C  ; reported amount / result lo
action_result_hi       = $042D  ; reported amount / result hi
action_result_cnt      = $042E  ; result counter / record byte 2
; --- Battle result scene menu ($040C-$046D) ---
result_cursor_x        = $040C  ; result menu cursor X (cleared per phase)
result_cursor_y        = $040D  ; result menu cursor Y / pending-select flag
result_sel_entry       = $0410  ; result menu selected entry id
result_menu_row        = $046C  ; result menu row cursor
battle_overlay_flag    = $04C8  ; battle overlay flag (gates panel/marker draw)
; --- Battle result scene state ($0541-$0548, $6F44, $6FEA) ---
result_scene_phase     = $0541  ; result scene phase index (0-6)
result_dir_repeat      = $0545  ; dir-repeat hold counters (4 bytes, +0..+3)
result_latch_flags     = $6FEA  ; dir-repeat latch / outcome bits
battle_outcome_flag    = $6F44  ; battle outcome / ruler result flag
; --- Battle slot record columns (20 slots, 10 per side) ---
unit_coord_x           = $0600  ; slot X coord column
unit_coord_y           = $0614  ; slot Y coord column
unit_army_array        = $0628  ; army column (bit7 = side flag)
unit_state_array       = $063C  ; unit state column
unit_immobilized       = $0650  ; immobilized/state flag column
battle_roster          = $0664  ; officer id roster column ($FF = empty)
officer_state_table    = $6FA1  ; officer state / unit placement queue ($40)
proximity_table        = $6FC9  ; proximity scan table ($14 bytes)
; --- Faction records (SRAM, 7 x 8 bytes, also result entry records) ---
faction_records        = $6F07  ; faction record base (stride 8)
faction_rec_status     = $6F0A  ; faction record status bytes (stride 8)
; --- AI turn state ($6F8C-$6F9B) ---
ai_officer_idx         = $6F8C  ; current AI officer slot index
ai_action_result       = $6F8F  ; AI action decision/result code
side_unit_base         = $6F91  ; side unit index base (0 or 10) / dispatch idx
officer_scan_idx       = $6F94  ; officer scan index / unit count - 1
acted_officer_cnt      = $6F95  ; acted officer count
valid_officer_cnt      = $6F96  ; valid officer count
formation_slot0_units  = $6F99  ; formation slot 0 unit count nibble
formation_slot1_units  = $6F9B  ; formation slot 1 unit count nibble
; --- RNG ($B5D5 NextRandomByte) ---
rng_cursor             = $6F92  ; RNG table cursor (never reset, wraps)
rng_x_save             = $6F93  ; X register save for NextRandomByte

.segment "CODE_BANK08"

AiTurnProcess_Entry:  ; (dispatch callback target)
  JMP AiTurnProcess                      ; $A000: 4C 2D A0
BattleSetup_Entry:  ; (dispatch callback target)
  JMP BattleSetup                       ; $A003: 4C 30 B1
BattlePhaseProcess_Entry:  ; (dispatch callback target)
  JMP BattlePhaseProcess                ; $A006: 4C B3 BA
AiOfficerActionDispatch_Entry:
  JMP AiOfficerActionDispatch           ; $A009: 4C BB C0
BattleCasualtyResolution_Entry:
  JMP BattleCasualtyResolution              ; $A00C: 4C 83 C9
BattleAttritionRound_Entry:
  JMP BattleAttritionRound              ; $A00F: 4C 78 CD
BattleStatusPanelDraw_Entry:
  JMP BattleStatusPanelDraw             ; $A012: 4C A2 CF
StratagemTargetMarker_Entry:
  JMP DrawStratagemTargetMarkers       ; $A015: 4C ED D1
ValidateSpecialOfficer_Entry:
  JMP ValidateSpecialOfficer            ; $A018: 4C 90 D3
BuildCommandList_Entry:
  JMP BuildCommandList                  ; $A01B: 4C EE D3
ExpandFormationSlots_Entry:
  JMP AiOfficerActionDispatch::ExpandFormationSlots ; $A01E: 4C 51 C8
BattleMapScrollUpdate_Entry:
  JMP BattleMapScrollUpdate             ; $A021: 4C 7B D5
BattleResultDispatch_Entry:
  JMP BattleResultDispatch              ; $A024: 4C 0F D7
BattleResultSceneInit_Entry:
  JMP BattleResultSceneInit             ; $A027: 4C 6E D6
BattleSlotClear_Entry:  ; (dispatch callback target)
  JMP BattleSlotClear                   ; $A02A: 4C CD D6
;===============================================================================
; AiTurnProcess - Main AI turn processing entry point
; Called via dispatch callback at $A000
; Checks game state and iterates through AI officers
; Spans $A02D-$B12F: includes @AiOfficerActionDecide, the Action_* handlers,
; the nested AiExecuteMove movement engine, and the nested helpers
; AiScanAdjacentOfficers, AiCheckAttackNearby, AiFindNearbyOfficers,
; AiCheckFaction, AiCheckMove, AiCheckAttackFeasible, AiCheckRecruit,
; AiCheckActionFeasible, AiSortNearbyOfficers, AiCheckFlee,
; AiComputeArmyStats and AiComputeBattleStats. All are called only from
; this group, except AiCheckFaction which is also called from $CB74
; (via AiTurnProcess::AiCheckFaction).
;===============================================================================
.proc AiTurnProcess
; --- Proc-local RAM (AI work area) ---
ai_target_slot         = $6F8D  ; chosen direction / target slot / move result
ai_target_officer      = $6F8E  ; action target officer slot
ai_move_cost           = $6F97  ; committed move cost nibble
move_reverse_dirs      = $6FB5  ; per-officer reverse of last move direction
adjacent_scan_results  = $6FDD  ; adjacent officer scan result table
  LDA sram_game_start_flag                             ; $A02D: AD 8B 6F  ; game start flag
  CMP #$FF                              ; $A030: C9 FF
  BNE @CheckPhase                       ; $A032: D0 01
  RTS                                   ; $A034: 60
@CheckPhase:
  CMP #$01                              ; $A035: C9 01
  BNE @OfficerLoop                      ; $A037: D0 03
  JMP BattleResultProcess               ; $A039: 4C 33 B9  ; phase 1 handler
@OfficerLoop:
  LDY officer_scan_idx                             ; $A03C: AC 94 6F  ; officer scan index
  CPY #$14                              ; $A03F: C0 14     ; max 20 officers
  BCS @CountCheck                       ; $A041: B0 30
  INC officer_scan_idx                             ; $A043: EE 94 6F
  LDA officer_state_table,Y                           ; $A046: B9 A1 6F  ; officer state table
  CMP #$FF                              ; $A049: C9 FF
@SkipCheck:
  BEQ @LoopContinue                     ; $A04B: F0 1F
  JSR AiCheckFaction                    ; $A04D: 20 44 A9  ; check faction
  BMI @LoopContinue                     ; $A050: 30 1A
  LDA battle_roster,Y                           ; $A052: B9 64 06  ; officer record ptr
  CMP #$FF                              ; $A055: C9 FF
  BEQ @LoopContinue                     ; $A057: F0 13
  INC valid_officer_cnt                             ; $A059: EE 96 6F  ; valid officer count
  STY ai_officer_idx                             ; $A05C: 8C 8C 6F  ; current officer index
  JSR @AiOfficerActionDecide            ; $A05F: 20 99 A0
  LDA ai_action_result                             ; $A062: AD 8F 6F  ; action result
  CMP #$03                              ; $A065: C9 03     ; 3 = no action
  BNE @Done                             ; $A067: D0 2A
  INC acted_officer_cnt                             ; $A069: EE 95 6F  ; acted count
@LoopContinue:
  LDA officer_scan_idx                             ; $A06C: AD 94 6F
  CMP #$14                              ; $A06F: C9 14
  BCC @OfficerLoop                      ; $A071: 90 C9
@CountCheck:
  LDA valid_officer_cnt                             ; $A073: AD 96 6F  ; valid count
  CMP acted_officer_cnt                             ; $A076: CD 95 6F  ; acted count
  BEQ @SetPhase3                        ; $A079: F0 0E
  LDA #$00                              ; $A07B: A9 00     ; reset counters
  STA officer_scan_idx                             ; $A07D: 8D 94 6F
  STA acted_officer_cnt                             ; $A080: 8D 95 6F
  STA valid_officer_cnt                             ; $A083: 8D 96 6F
  JMP @OfficerLoop                      ; $A086: 4C 3C A0  ; rescan
@SetPhase3:
  LDA #$03                              ; $A089: A9 03
  STA ai_action_result                             ; $A08B: 8D 8F 6F
  LDA #$00                              ; $A08E: A9 00
  STA officer_scan_idx                             ; $A090: 8D 94 6F
@Done:
  LDA #$FF                              ; $A093: A9 FF
  STA sram_game_start_flag                             ; $A095: 8D 8B 6F  ; mark turn complete
  RTS                                   ; $A098: 60
;===============================================================================
; AiOfficerActionDecide - Decide action for current AI officer
; Input: Y = officer index ($6F8C also holds it)
; Reads officer state from $6FA1,Y; low nibble selects the action handler via
; the inline CallbackDispatcher table:
;   0 = Action_DefaultDecision   (flee/recruit/attack/move priority chain)
;   1 = Action_Regroup           (rejoin main force / march to capital)
;   2 = Action_AttackNearest     (nearest enemy, range 2 from self)
;   3 = Action_DefendBase        (nearest enemy, range 2 from capital)
;   4 = Action_SweepRange3       (nearest enemy, range 3 from self)
;   5 = Action_CaptureProvince   (occupy province, transfer resources)
;   6 = Action_RestoreHP         (spend 50 gold to restore HP)
;   7 = Action_Idle              (no action)
; Sets $6F8F with action result (0-4, or 3 for no action)
;===============================================================================
@AiOfficerActionDecide:
  LDA officer_state_table,Y                           ; $A099: B9 A1 6F  ; officer state
  AND #$0F                              ; $A09C: 29 0F     ; low nibble = action type
  JSR CallbackDispatcher                ; $A09E: 20 17 B5  ; dispatch on action type (0-7)
  ; Inline dispatch table (targets of CallbackDispatcher)
  .word Action_DefaultDecision          ; $A0A1: B1 A0     ; action 0: priority chain (flee/recruit/attack/move/random)
  .word Action_Regroup                  ; $A0A3: 05 A1     ; action 1: rejoin main force / march to capital
  .word Action_AttackNearest            ; $A0A5: 66 A1     ; action 2: attack nearest enemy (range 2, self)
  .word Action_DefendBase               ; $A0A7: 10 A2     ; action 3: intercept enemy near base (range 2)
  .word Action_SweepRange3              ; $A0A9: AD A2     ; action 4: sweep enemies within range 3
  .word Action_CaptureProvince          ; $A0AB: 29 A3     ; action 5: capture target province
  .word Action_RestoreHP                ; $A0AD: 07 A5     ; action 6: spend 50 gold, restore HP
  .word Action_Idle                     ; $A0AF: 06 A6     ; action 7: no action
Action_DefaultDecision:
  LDA battle_side_flag                             ; $A0B1: AD 04 05  ; AI faction flag
  BMI @Path1                            ; $A0B4: 30 03     ; bit7 set -> chain with attack
  JMP @Path2                            ; $A0B6: 4C F6 A0  ; else -> chain without attack
@Path1:
  JSR AiCheckFlee                       ; $A0B9: 20 0D AF
  BCC @CheckRecruit                     ; $A0BC: 90 01     ; C=1: action decided
  RTS                                   ; $A0BE: 60
@CheckRecruit:
  JSR AiCheckRecruit                    ; $A0BF: 20 F8 AA
  BCC @CheckAttack                      ; $A0C2: 90 01
  RTS                                   ; $A0C4: 60
@CheckAttack:
  JSR AiCheckAttackNearby               ; $A0C5: 20 A8 A8
  BCC @CheckMove                        ; $A0C8: 90 01
  RTS                                   ; $A0CA: 60
@CheckMove:
  JSR AiCheckMove                       ; $A0CB: 20 5C A9
  BCC @RandomAction                     ; $A0CE: 90 01
  RTS                                   ; $A0D0: 60
@RandomAction:
  JSR NextRandomByte                    ; $A0D1: 20 D5 B5  ; pseudo-random
  AND #$03                              ; $A0D4: 29 03     ; 25% chance: idle
  BNE @MoveToCity                       ; $A0D6: D0 06
  LDA #$03                              ; $A0D8: A9 03     ; result = no action
  STA ai_action_result                             ; $A0DA: 8D 8F 6F
  RTS                                   ; $A0DD: 60
@MoveToCity:
  LDA unit_coord_x                             ; $A0DE: AD 00 06  ; capital city X
  STA $0020                             ; $A0E1: 8D 20 00
  LDA unit_coord_y                             ; $A0E4: AD 14 06  ; capital city Y
  CMP #$10                              ; $A0E7: C9 10     ; Y >= $10 needs wrap fix
  BCC @StoreY                           ; $A0E9: 90 02
  SBC #$01                              ; $A0EB: E9 01
@StoreY:
  STA $0021                             ; $A0ED: 8D 21 00
  LDY ai_officer_idx                             ; $A0F0: AC 8C 6F
  JMP AiExecuteMove                     ; $A0F3: 4C 0C A6
@Path2:
  JSR AiCheckFlee                       ; $A0F6: 20 0D AF
  BCC @CheckRecruit2                    ; $A0F9: 90 01
  RTS                                   ; $A0FB: 60
@CheckRecruit2:
  JSR AiCheckRecruit                    ; $A0FC: 20 F8 AA
  BCC @CheckMove2                       ; $A0FF: 90 01
  RTS                                   ; $A101: 60
@CheckMove2:
  JMP AiCheckMove                       ; $A102: 4C 5C A9
; Action 1: Regroup - rejoin main force, else march to capital/ordered target
Action_Regroup:
  JSR AiCheckFlee                       ; $A105: 20 0D AF
  BCC @TryRecruit                       ; $A108: 90 01
  RTS                                   ; $A10A: 60
@TryRecruit:
  JSR AiCheckRecruit                    ; $A10B: 20 F8 AA
  BCC @CheckStrength                    ; $A10E: 90 01
  RTS                                   ; $A110: 60
@CheckStrength:
  LDA battle_action_points                             ; $A111: AD 05 05  ; move points/strength
  CMP #$02                              ; $A114: C9 02
  BCC @MarchToCapital                   ; $A116: 90 2C     ; too weak: just march
  LDY ai_officer_idx                             ; $A118: AC 8C 6F
  JSR AiScanAdjacentOfficers            ; $A11B: 20 37 A8  ; fill $6FDD
  LDX #$0A                              ; $A11E: A2 0A     ; main-force slot (faction B)
  LDA battle_side_flag                             ; $A120: AD 04 05
  BPL @ScanAdjLoop                      ; $A123: 10 02
  LDX #$00                              ; $A125: A2 00     ; main-force slot (faction A)
@ScanAdjLoop:
  STX $0020                             ; $A127: 8E 20 00
  LDY #$00                              ; $A12A: A0 00
@ScanAdjNext:
  LDA adjacent_scan_results,Y                           ; $A12C: B9 DD 6F  ; adjacent officer entry
  AND #$7F                              ; $A12F: 29 7F     ; strip enemy bit
  CMP $0020                             ; $A131: CD 20 00
  BNE @ScanAdjNext2                     ; $A134: D0 09
  STA ai_target_slot                             ; $A136: 8D 8D 6F  ; target found
  LDA #$01                              ; $A139: A9 01
  STA ai_action_result                             ; $A13B: 8D 8F 6F  ; result = attack target
  RTS                                   ; $A13E: 60
@ScanAdjNext2:
  INY                                   ; $A13F: C8
  CPY #$04                              ; $A140: C0 04
  BCC @ScanAdjNext                      ; $A142: 90 E8
@MarchToCapital:
  LDX #$0A                              ; $A144: A2 0A     ; capital slot (faction B)
  LDA battle_side_flag                             ; $A146: AD 04 05
  BMI @GetOrderedDest                   ; $A149: 30 15     ; faction A: ordered target
  LDA unit_coord_x,X                           ; $A14B: BD 00 06  ; capital X
  STA $0020                             ; $A14E: 8D 20 00
  LDA unit_coord_y,X                           ; $A151: BD 14 06  ; capital Y
  CMP #$10                              ; $A154: C9 10
  BCC @StoreTargetY                     ; $A156: 90 02
  SBC #$01                              ; $A158: E9 01
@StoreTargetY:
  STA $0021                             ; $A15A: 8D 21 00
  JMP @Execute                          ; $A15D: 4C 63 A1
@GetOrderedDest:
  JSR GetOrderedDestination             ; $A160: 20 E5 A1  ; coords from $8C52 table
@Execute:
  JMP AiExecuteMove                     ; $A163: 4C 0C A6
; Action 2: Attack nearest enemy within range 2 of this officer
Action_AttackNearest:
  JSR AiCheckFlee                       ; $A166: 20 0D AF
  BCC @TryRecruitAtk                    ; $A169: 90 01
  RTS                                   ; $A16B: 60
@TryRecruitAtk:
  JSR AiCheckRecruit                    ; $A16C: 20 F8 AA
  BCC @TryAttackAdj                     ; $A16F: 90 01
  RTS                                   ; $A171: 60
@TryAttackAdj:
  LDY ai_officer_idx                             ; $A172: AC 8C 6F
  JSR AiCheckAttackNearby               ; $A175: 20 A8 A8  ; adjacent enemy?
  BCC @ScanEnemy                        ; $A178: 90 01
  RTS                                   ; $A17A: 60
@ScanEnemy:
  LDY ai_officer_idx                             ; $A17B: AC 8C 6F
  LDA #$02                              ; $A17E: A9 02     ; range = 2
  JSR AiFindNearbyOfficers              ; $A180: 20 D3 A8  ; fill $6FC9 (bit7=enemy, low=dist)
  LDA #$FF                              ; $A183: A9 FF
  STA $0020                             ; $A185: 8D 20 00  ; best distance = none
  LDY #$00                              ; $A188: A0 00
@ScanEnemyNext:
  LDA proximity_table,Y                           ; $A18A: B9 C9 6F
  BPL @ScanEnemyLoop                    ; $A18D: 10 0D     ; skip non-enemy
  AND #$7F                              ; $A18F: 29 7F     ; distance
  CMP $0020                             ; $A191: CD 20 00
  BCS @ScanEnemyLoop                    ; $A194: B0 06     ; not nearer
  STA $0020                             ; $A196: 8D 20 00  ; new best distance
  STY $0021                             ; $A199: 8C 21 00  ; officer index
@ScanEnemyLoop:
  INY                                   ; $A19C: C8
  CPY #$14                              ; $A19D: C0 14     ; 20 officers
  BCC @ScanEnemyNext                    ; $A19F: 90 E9
  LDA $0020                             ; $A1A1: AD 20 00
  CMP #$FF                              ; $A1A4: C9 FF
  BEQ @MarchFallback                    ; $A1A6: F0 18     ; no enemy found
  LDY $0021                             ; $A1A8: AC 21 00
  LDA unit_coord_x,Y                           ; $A1AB: B9 00 06  ; enemy X
  STA $0020                             ; $A1AE: 8D 20 00
  LDA unit_coord_y,Y                           ; $A1B1: B9 14 06  ; enemy Y
  CMP #$10                              ; $A1B4: C9 10
  BCC @StoreEnemyY                      ; $A1B6: 90 02
  SBC #$01                              ; $A1B8: E9 01
@StoreEnemyY:
  STA $0021                             ; $A1BA: 8D 21 00
  JMP @ExecuteMove2                     ; $A1BD: 4C DF A1
@MarchFallback:
  LDX #$0A                              ; $A1C0: A2 0A     ; capital slot (faction B)
  LDA battle_side_flag                             ; $A1C2: AD 04 05
  BMI @UseOrderedDest2                  ; $A1C5: 30 15     ; faction A: ordered target
  LDA unit_coord_x,X                           ; $A1C7: BD 00 06
  STA $0020                             ; $A1CA: 8D 20 00
  LDA unit_coord_y,X                           ; $A1CD: BD 14 06
  CMP #$10                              ; $A1D0: C9 10
  BCC @StoreCapitalY2                   ; $A1D2: 90 02
  SBC #$01                              ; $A1D4: E9 01
@StoreCapitalY2:
  STA $0021                             ; $A1D6: 8D 21 00
  JMP @ExecuteMove2                     ; $A1D9: 4C DF A1
@UseOrderedDest2:
  JSR GetOrderedDestination             ; $A1DC: 20 E5 A1
@ExecuteMove2:
  LDY ai_officer_idx                             ; $A1DF: AC 8C 6F
  JMP AiExecuteMove                     ; $A1E2: 4C 0C A6
; GetOrderedDestination - read ordered destination coords for current province
; Switches $8000 slot to bank $26, indexes pointer table $8C52 by $050E,
; dereferences to (X,Y); result in $0020/$0021
GetOrderedDestination:
  LDY #$26                              ; $A1E5: A0 26     ; data bank
  JSR B1F_SwitchBank8_A                             ; $A1E7: 20 66 F2  ; SwitchBank8_A
  LDA battle_province_idx                             ; $A1EA: AD 0E 05  ; province/action index
  ASL                                   ; $A1ED: 0A        ; *2 (word table)
  TAY                                   ; $A1EE: A8
  LDA $8C52,Y                           ; $A1EF: B9 52 8C  ; pointer low
  STA $0022                             ; $A1F2: 8D 22 00
  LDA $8C53,Y                           ; $A1F5: B9 53 8C  ; pointer high
  STA $0023                             ; $A1F8: 8D 23 00
  LDY #$00                              ; $A1FB: A0 00
  LDA ($22),Y                           ; $A1FD: B1 22     ; dest Y
  CMP #$10                              ; $A1FF: C9 10
  BCC @DestYOk                          ; $A201: 90 03
  SEC                                   ; $A203: 38
  SBC #$01                              ; $A204: E9 01
@DestYOk:
  STA $0021                             ; $A206: 8D 21 00
  INY                                   ; $A209: C8
  LDA ($22),Y                           ; $A20A: B1 22     ; dest X
  STA $0020                             ; $A20C: 8D 20 00
  RTS                                   ; $A20F: 60
; Action 3: Defend base - intercept nearest enemy within range 2 of own capital
Action_DefendBase:
  JSR AiCheckFlee                       ; $A210: 20 0D AF
  BCC @DefTryRecruit                    ; $A213: 90 01
  RTS                                   ; $A215: 60
@DefTryRecruit:
  JSR AiCheckRecruit                    ; $A216: 20 F8 AA
  BCC @DefTryAttack                     ; $A219: 90 01
  RTS                                   ; $A21B: 60
@DefTryAttack:
  JSR AiCheckAttackNearby               ; $A21C: 20 A8 A8
  BCC @DefSelectBase                    ; $A21F: 90 01
  RTS                                   ; $A221: 60
@DefSelectBase:
  LDY #$00                              ; $A222: A0 00     ; base slot (faction A)
  LDA battle_side_flag                             ; $A224: AD 04 05
  BPL @DefScanEnemy                     ; $A227: 10 02
  LDY #$0A                              ; $A229: A0 0A     ; base slot (faction B)
@DefScanEnemy:
  LDA #$02                              ; $A22B: A9 02     ; range = 2
  JSR AiFindNearbyOfficers              ; $A22D: 20 D3 A8  ; scan centered on base
  LDA #$FF                              ; $A230: A9 FF
  STA $0020                             ; $A232: 8D 20 00  ; best value = none
  LDY #$00                              ; $A235: A0 00
@DefScanNext:
  LDA proximity_table,Y                           ; $A237: B9 C9 6F
  BPL @DefScanLoop                      ; $A23A: 10 0B     ; skip non-enemy
  CMP $0020                             ; $A23C: CD 20 00
  BCS @DefScanLoop                      ; $A23F: B0 06     ; not closer
  STA $0020                             ; $A241: 8D 20 00
  STY $0021                             ; $A244: 8C 21 00
@DefScanLoop:
  INY                                   ; $A247: C8
  CPY #$14                              ; $A248: C0 14
  BCC @DefScanNext                      ; $A24A: 90 EB
  LDA $0020                             ; $A24C: AD 20 00
  CMP #$FF                              ; $A24F: C9 FF
  BEQ @DefNoEnemy                       ; $A251: F0 36
  LDY $0021                             ; $A253: AC 21 00
  STY ai_target_officer                             ; $A256: 8C 8E 6F  ; remember target officer
  JSR AiScanAdjacentOfficers            ; $A259: 20 37 A8  ; fill $6FDD
  LDY #$00                              ; $A25C: A0 00
@DefAdjCheck:
  LDA adjacent_scan_results,Y                           ; $A25E: B9 DD 6F  ; adjacent officer
  BMI @DefAdjNext                       ; $A261: 30 09     ; enemy: skip
  BEQ @DefAdjNext                       ; $A263: F0 07     ; empty: skip
  CMP #$0A                              ; $A265: C9 0A
  BEQ @DefAdjNext                       ; $A267: F0 03     ; slot $0A: skip
  JMP AiCheckMove                       ; $A269: 4C 5C A9  ; ally adjacent: let move logic decide
@DefAdjNext:
  INY                                   ; $A26C: C8
  CPY #$04                              ; $A26D: C0 04
  BCC @DefAdjCheck                      ; $A26F: 90 ED
  LDY ai_target_officer                             ; $A271: AC 8E 6F  ; target officer
  LDA unit_coord_x,Y                           ; $A274: B9 00 06
  STA $0020                             ; $A277: 8D 20 00
  LDA unit_coord_y,Y                           ; $A27A: B9 14 06
  CMP #$10                              ; $A27D: C9 10
  BCC @DefStoreY                        ; $A27F: 90 02
  SBC #$01                              ; $A281: E9 01
@DefStoreY:
  STA $0021                             ; $A283: 8D 21 00
  JMP AiExecuteMove                     ; $A286: 4C 0C A6
@DefNoEnemy:
  JSR AiCheckMove                       ; $A289: 20 5C A9  ; generic move check
  BCC @DefCapital                       ; $A28C: 90 01
  RTS                                   ; $A28E: 60
@DefCapital:
  LDX #$00                              ; $A28F: A2 00     ; capital slot (faction A)
  LDA battle_side_flag                             ; $A291: AD 04 05
  BPL @DefLoadCapital                   ; $A294: 10 02
  LDX #$0A                              ; $A296: A2 0A     ; capital slot (faction B)
@DefLoadCapital:
  LDA unit_coord_x,X                           ; $A298: BD 00 06
  STA $0020                             ; $A29B: 8D 20 00
  LDA unit_coord_y,X                           ; $A29E: BD 14 06
  CMP #$10                              ; $A2A1: C9 10
  BCC @DefStoreY2                       ; $A2A3: 90 02
  SBC #$01                              ; $A2A5: E9 01
@DefStoreY2:
  STA $0021                             ; $A2A7: 8D 21 00
  JMP AiExecuteMove                     ; $A2AA: 4C 0C A6
; Action 4: Sweep - attack nearest enemy within range 3 of this officer
Action_SweepRange3:
  JSR AiCheckFlee                       ; $A2AD: 20 0D AF
  BCC @SwTryRecruit                     ; $A2B0: 90 01
  RTS                                   ; $A2B2: 60
@SwTryRecruit:
  JSR AiCheckRecruit                    ; $A2B3: 20 F8 AA
  BCC @SwTryAttack                      ; $A2B6: 90 01
  RTS                                   ; $A2B8: 60
@SwTryAttack:
  JSR AiCheckAttackNearby               ; $A2B9: 20 A8 A8
  BCC @SwScan                           ; $A2BC: 90 01
  RTS                                   ; $A2BE: 60
@SwScan:
  LDY ai_officer_idx                             ; $A2BF: AC 8C 6F
  LDA #$03                              ; $A2C2: A9 03     ; range = 3
  JSR AiFindNearbyOfficers              ; $A2C4: 20 D3 A8  ; scan centered on self
  LDA #$FF                              ; $A2C7: A9 FF
  STA $0020                             ; $A2C9: 8D 20 00  ; best value = none
  LDY #$00                              ; $A2CC: A0 00
@SwScanNext:
  LDA proximity_table,Y                           ; $A2CE: B9 C9 6F
  BPL @SwScanLoop                       ; $A2D1: 10 0B     ; skip non-enemy
  CMP $0020                             ; $A2D3: CD 20 00
  BCS @SwScanLoop                       ; $A2D6: B0 06     ; not closer
  STA $0020                             ; $A2D8: 8D 20 00
  STY $0021                             ; $A2DB: 8C 21 00
@SwScanLoop:
  INY                                   ; $A2DE: C8
  CPY #$14                              ; $A2DF: C0 14
  BCC @SwScanNext                       ; $A2E1: 90 EB
  LDA $0020                             ; $A2E3: AD 20 00
  CMP #$FF                              ; $A2E6: C9 FF
  BEQ @SwNoEnemy                        ; $A2E8: F0 1B
  LDY $0021                             ; $A2EA: AC 21 00
  STY ai_target_officer                             ; $A2ED: 8C 8E 6F  ; remember target officer
  LDA unit_coord_x,Y                           ; $A2F0: B9 00 06
  STA $0020                             ; $A2F3: 8D 20 00
  LDA unit_coord_y,Y                           ; $A2F6: B9 14 06
  CMP #$10                              ; $A2F9: C9 10
  BCC @SwStoreY                         ; $A2FB: 90 02
  SBC #$01                              ; $A2FD: E9 01
@SwStoreY:
  STA $0021                             ; $A2FF: 8D 21 00
  JMP AiExecuteMove                     ; $A302: 4C 0C A6
@SwNoEnemy:
  JSR AiCheckMove                       ; $A305: 20 5C A9  ; generic move check
  BCC @SwCapital                        ; $A308: 90 01
  RTS                                   ; $A30A: 60
@SwCapital:
  LDX #$00                              ; $A30B: A2 00     ; capital slot (faction A)
  LDA battle_side_flag                             ; $A30D: AD 04 05
  BPL @SwLoadCapital                    ; $A310: 10 02
  LDX #$0A                              ; $A312: A2 0A     ; capital slot (faction B)
@SwLoadCapital:
  LDA unit_coord_x,X                           ; $A314: BD 00 06
  STA $0020                             ; $A317: 8D 20 00
  LDA unit_coord_y,X                           ; $A31A: BD 14 06
  CMP #$10                              ; $A31D: C9 10
  BCC @SwStoreY2                        ; $A31F: 90 02
  SBC #$01                              ; $A321: E9 01
@SwStoreY2:
  STA $0021                             ; $A323: 8D 21 00
  JMP AiExecuteMove                     ; $A326: 4C 0C A6
; Action 5: Capture province - march to target province from $9BA4 table (bank $31,
; 3-byte entries indexed by $050E*3). On arrival, set officer state nibble to 7
; (occupation) and transfer a share of the province resources to faction stock.
Action_CaptureProvince:
  LDY #$31                              ; $A329: A0 31     ; data bank
  JSR B1F_SwitchBank8_A                             ; $A32B: 20 66 F2  ; SwitchBank8_A
  LDA battle_province_idx                             ; $A32E: AD 0E 05  ; province index
  ASL                                   ; $A331: 0A        ; *3 (3-byte entries)
  STA $0020                             ; $A332: 8D 20 00
  ASL                                   ; $A335: 0A
  CLC                                   ; $A336: 18
  ADC $0020                             ; $A337: 6D 20 00
  TAY                                   ; $A33A: A8
  LDA $9BA4,Y                           ; $A33B: B9 A4 9B  ; target X
  STA $0020                             ; $A33E: 8D 20 00
  INY                                   ; $A341: C8
  LDA $9BA4,Y                           ; $A342: B9 A4 9B  ; target Y
  CMP #$10                              ; $A345: C9 10
  BCC @CapStoreY                        ; $A347: 90 02
  SBC #$01                              ; $A349: E9 01
@CapStoreY:
  STA $0021                             ; $A34B: 8D 21 00
  JSR AiExecuteMove                     ; $A34E: 20 0C A6  ; march toward province
  LDA ai_action_result                             ; $A351: AD 8F 6F  ; result
  BNE @CapExit                          ; $A354: D0 57     ; not arrived yet
  LDY ai_officer_idx                             ; $A356: AC 8C 6F
  LDA unit_coord_x,Y                           ; $A359: B9 00 06  ; officer X
  STA $0020                             ; $A35C: 8D 20 00
  LDA unit_coord_y,Y                           ; $A35F: B9 14 06  ; officer Y
  STA $0021                             ; $A362: 8D 21 00
  LDY #$00                              ; $A365: A0 00     ; adjust X by default
  LDA ai_target_slot                             ; $A367: AD 8D 6F  ; move result flags
  AND #$02                              ; $A36A: 29 02
  BNE @CapAxisY                         ; $A36C: D0 01
  INY                                   ; $A36E: C8        ; bit1 clear: adjust Y
@CapAxisY:
  LDA ai_target_slot                             ; $A36F: AD 8D 6F
  AND #$01                              ; $A372: 29 01
  BEQ @CapNegDir                        ; $A374: F0 05
  LDA #$01                              ; $A376: A9 01     ; bit0 set: +1
  JMP @CapApplyStep                     ; $A378: 4C 7D A3
@CapNegDir:
  LDA #$FF                              ; $A37B: A9 FF     ; bit0 clear: -1
@CapApplyStep:
  STA $0022                             ; $A37D: 8D 22 00
  LDA $0020,Y                           ; $A380: B9 20 00  ; step coord toward target
  CLC                                   ; $A383: 18
  ADC $0022                             ; $A384: 6D 22 00
  STA $0020,Y                           ; $A387: 99 20 00
  LDY #$31                              ; $A38A: A0 31     ; re-select data bank
  JSR B1F_SwitchBank8_A                             ; $A38C: 20 66 F2  ; SwitchBank8_A
  LDA battle_province_idx                             ; $A38F: AD 0E 05
  ASL                                   ; $A392: 0A
  STA $0022                             ; $A393: 8D 22 00
  ASL                                   ; $A396: 0A
  CLC                                   ; $A397: 18
  ADC $0022                             ; $A398: 6D 22 00
  TAY                                   ; $A39B: A8
  LDA $9BA4,Y                           ; $A39C: B9 A4 9B  ; target X
  CMP $0020                             ; $A39F: CD 20 00
  BNE @CapExit                          ; $A3A2: D0 09     ; not at target X
  INY                                   ; $A3A4: C8
  LDA $9BA4,Y                           ; $A3A5: B9 A4 9B  ; target Y
  CMP $0021                             ; $A3A8: CD 21 00
  BEQ @CapArrived                       ; $A3AB: F0 01
@CapExit:
  RTS                                   ; $A3AD: 60
@CapArrived:
  LDY ai_officer_idx                             ; $A3AE: AC 8C 6F
  LDA officer_state_table,Y                           ; $A3B1: B9 A1 6F  ; officer state
  AND #$F0                              ; $A3B4: 29 F0
  ORA #$07                              ; $A3B6: 09 07     ; action nibble = 7 (occupy)
  STA officer_state_table,Y                           ; $A3B8: 99 A1 6F
  LDX #$00                              ; $A3BB: A2 00     ; faction A resource ptr
  LDA battle_side_flag                             ; $A3BD: AD 04 05
  BPL @CapGetPtr                        ; $A3C0: 10 02
  LDX #$02                              ; $A3C2: A2 02     ; faction B resource ptr
@CapGetPtr:
  LDA battle_stat_b_lo,X                           ; $A3C4: BD 26 05  ; province value lo
  STA $0020                             ; $A3C7: 8D 20 00
  LDA battle_stat_b_hi,X                           ; $A3CA: BD 27 05  ; province value hi
  STA $0021                             ; $A3CD: 8D 21 00
  LDA #$00                              ; $A3D0: A9 00
  STA $0022                             ; $A3D2: 8D 22 00
  LDA #$07                              ; $A3D5: A9 07     ; *7
  STA $0023                             ; $A3D7: 8D 23 00
  JSR Mul24x8                           ; $A3DA: 20 85 B5
  LDA $0026                             ; $A3DD: AD 26 00  ; product lo
  STA $0020                             ; $A3E0: 8D 20 00
  LDA $0027                             ; $A3E3: AD 27 00
  STA $0021                             ; $A3E6: 8D 21 00
  LDA $0028                             ; $A3E9: AD 28 00  ; product hi
  STA $0022                             ; $A3EC: 8D 22 00
  LDA #$0A                              ; $A3EF: A9 0A     ; /10 -> 70% share
  STA $0023                             ; $A3F1: 8D 23 00
  LDA #$00                              ; $A3F4: A9 00
  STA $0024                             ; $A3F6: 8D 24 00
  JSR Div24Bit                          ; $A3F9: 20 36 B5
  LDA $0020                             ; $A3FC: AD 20 00  ; share lo
  STA $0036                             ; $A3FF: 8D 36 00
  LDA $0021                             ; $A402: AD 21 00  ; share hi
  STA $0037                             ; $A405: 8D 37 00
  JSR AiComputeBattleStats              ; $A408: 20 B8 B0
  LDX #$00                              ; $A40B: A2 00
  LDA battle_side_flag                             ; $A40D: AD 04 05
  BPL @CapCalcDelta                     ; $A410: 10 02
  LDX #$02                              ; $A412: A2 02
@CapCalcDelta:
  LDA $002A                             ; $A414: AD 2A 00  ; battle result lo
  SEC                                   ; $A417: 38
  SBC battle_stat_a_lo,X                           ; $A418: FD 22 05  ; - stock lo
  STA $0038                             ; $A41B: 8D 38 00  ; delta lo
  STA $0020                             ; $A41E: 8D 20 00
  LDA $002B                             ; $A421: AD 2B 00  ; battle result hi
  SBC battle_stat_a_hi,X                           ; $A424: FD 23 05  ; - stock hi
  STA $0039                             ; $A427: 8D 39 00  ; delta hi
  STA $0021                             ; $A42A: 8D 21 00
  LDA #$00                              ; $A42D: A9 00
  STA $0022                             ; $A42F: 8D 22 00
  LDA #$64                              ; $A432: A9 64     ; *100
  STA $0023                             ; $A434: 8D 23 00
  JSR Mul24x8                           ; $A437: 20 85 B5
  LDA $0026                             ; $A43A: AD 26 00
  STA $0020                             ; $A43D: 8D 20 00
  LDA $0027                             ; $A440: AD 27 00
  STA $0021                             ; $A443: 8D 21 00
  LDA $0028                             ; $A446: AD 28 00
  STA $0022                             ; $A449: 8D 22 00
  LDY #$30                              ; $A44C: A0 30     ; data bank $30
  JSR B1F_SwitchBank8_A                             ; $A44E: 20 66 F2  ; SwitchBank8_A
  LDA battle_province_idx                             ; $A451: AD 0E 05
  ASL                                   ; $A454: 0A
  TAY                                   ; $A455: A8
  INY                                   ; $A456: C8        ; word entry high byte
  LDA $8FC0,Y                           ; $A457: B9 C0 8F  ; province rate factor
  STA $003A                             ; $A45A: 8D 3A 00
  STA $0023                             ; $A45D: 8D 23 00  ; divisor
  LDA #$00                              ; $A460: A9 00
  STA $0024                             ; $A462: 8D 24 00
  JSR Div24Bit                          ; $A465: 20 36 B5  ; scaled transfer amount
  LDX #$00                              ; $A468: A2 00
  LDA battle_side_flag                             ; $A46A: AD 04 05
  BPL @CapCheckFunds                    ; $A46D: 10 02
  LDX #$02                              ; $A46F: A2 02
@CapCheckFunds:
  LDA $0036                             ; $A471: AD 36 00  ; 70% share lo
  SEC                                   ; $A474: 38
  SBC $0020                             ; $A475: ED 20 00  ; - transfer lo
  LDA $0037                             ; $A478: AD 37 00
  SBC $0021                             ; $A47B: ED 21 00  ; - transfer hi
  BCC @CapPartial                       ; $A47E: 90 27     ; transfer > share: clamp
  LDA battle_stat_b_lo,X                           ; $A480: BD 26 05  ; province value lo
  SEC                                   ; $A483: 38
  SBC $0020                             ; $A484: ED 20 00
  STA battle_stat_b_lo,X                           ; $A487: 9D 26 05
  LDA battle_stat_b_hi,X                           ; $A48A: BD 27 05
  SBC $0021                             ; $A48D: ED 21 00
  STA battle_stat_b_hi,X                           ; $A490: 9D 27 05
  LDA battle_stat_a_lo,X                           ; $A493: BD 22 05  ; stock lo
  CLC                                   ; $A496: 18
  ADC $0038                             ; $A497: 6D 38 00  ; + delta lo
  STA battle_stat_a_lo,X                           ; $A49A: 9D 22 05
  LDA battle_stat_a_hi,X                           ; $A49D: BD 23 05
  ADC $0039                             ; $A4A0: 6D 39 00  ; + delta hi
  STA battle_stat_a_hi,X                           ; $A4A3: 9D 23 05
  RTS                                   ; $A4A6: 60
@CapPartial:
  LDA $0036                             ; $A4A7: AD 36 00  ; clamp to share: use all
  STA $0020                             ; $A4AA: 8D 20 00
  LDA $0037                             ; $A4AD: AD 37 00
  STA $0021                             ; $A4B0: 8D 21 00
  LDA #$00                              ; $A4B3: A9 00
  STA $0022                             ; $A4B5: 8D 22 00
  LDA $003A                             ; $A4B8: AD 3A 00  ; rate factor
  STA $0023                             ; $A4BB: 8D 23 00
  JSR Mul24x8                           ; $A4BE: 20 85 B5  ; share * rate
  LDA $0026                             ; $A4C1: AD 26 00
  STA $0020                             ; $A4C4: 8D 20 00
  LDA $0027                             ; $A4C7: AD 27 00
  STA $0021                             ; $A4CA: 8D 21 00
  LDA $0028                             ; $A4CD: AD 28 00
  STA $0022                             ; $A4D0: 8D 22 00
  LDA #$00                              ; $A4D3: A9 00
  STA $0024                             ; $A4D5: 8D 24 00
  LDA #$64                              ; $A4D8: A9 64     ; /100
  STA $0023                             ; $A4DA: 8D 23 00
  JSR Div24Bit                          ; $A4DD: 20 36 B5
  LDA battle_stat_b_lo,X                           ; $A4E0: BD 26 05  ; province value lo
  SEC                                   ; $A4E3: 38
  SBC $0036                             ; $A4E4: ED 36 00  ; - share lo
  STA battle_stat_b_lo,X                           ; $A4E7: 9D 26 05
  LDA battle_stat_b_hi,X                           ; $A4EA: BD 27 05
  SBC $0037                             ; $A4ED: ED 37 00  ; - share hi
  STA battle_stat_b_hi,X                           ; $A4F0: 9D 27 05
  LDA battle_stat_a_lo,X                           ; $A4F3: BD 22 05
  CLC                                   ; $A4F6: 18
  ADC $0020                             ; $A4F7: 6D 20 00  ; + transfer lo
  STA battle_stat_a_lo,X                           ; $A4FA: 9D 22 05
  LDA battle_stat_a_hi,X                           ; $A4FD: BD 23 05
  ADC $0021                             ; $A500: 6D 21 00  ; + transfer hi
  STA battle_stat_a_hi,X                           ; $A503: 9D 23 05
  RTS                                   ; $A506: 60
; Action 6: Restore HP - march to target province ($9BA4 entry +4, bank $31),
; then spend 50 gold to restore officer HP by a random 0-10 amount (capped by the
; banked base record).
Action_RestoreHP:
  LDY #$31                              ; $A507: A0 31     ; data bank
  JSR B1F_SwitchBank8_A                             ; $A509: 20 66 F2  ; SwitchBank8_A
  LDA battle_province_idx                             ; $A50C: AD 0E 05  ; province index
  ASL                                   ; $A50F: 0A        ; *3 + 4 (entry +4)
  STA $0020                             ; $A510: 8D 20 00
  ASL                                   ; $A513: 0A
  CLC                                   ; $A514: 18
  ADC $0020                             ; $A515: 6D 20 00
  CLC                                   ; $A518: 18
  ADC #$04                              ; $A519: 69 04
  TAY                                   ; $A51B: A8
  LDA $9BA4,Y                           ; $A51C: B9 A4 9B  ; target X
  STA $0020                             ; $A51F: 8D 20 00
  INY                                   ; $A522: C8
  LDA $9BA4,Y                           ; $A523: B9 A4 9B  ; target Y
  CMP #$10                              ; $A526: C9 10
  BCC @HealStoreY                       ; $A528: 90 02
  SBC #$01                              ; $A52A: E9 01
@HealStoreY:
  STA $0021                             ; $A52C: 8D 21 00
  STA $0021                             ; $A52F: 8D 21 00  ; redundant store (ROM quirk)
  JSR AiExecuteMove                     ; $A532: 20 0C A6  ; march toward province
  LDA ai_action_result                             ; $A535: AD 8F 6F
  BNE @HealExit                         ; $A538: D0 5A     ; not arrived yet
  LDY ai_officer_idx                             ; $A53A: AC 8C 6F
  LDA unit_coord_x,Y                           ; $A53D: B9 00 06  ; officer X
  STA $0020                             ; $A540: 8D 20 00
  LDA unit_coord_y,Y                           ; $A543: B9 14 06  ; officer Y
  STA $0021                             ; $A546: 8D 21 00
  LDY #$00                              ; $A549: A0 00     ; adjust X by default
  LDA ai_target_slot                             ; $A54B: AD 8D 6F  ; move result flags
  AND #$02                              ; $A54E: 29 02
  BNE @HealAxisY                        ; $A550: D0 01
  INY                                   ; $A552: C8        ; bit1 clear: adjust Y
@HealAxisY:
  LDA ai_target_slot                             ; $A553: AD 8D 6F
  AND #$01                              ; $A556: 29 01
  BEQ @HealNegDir                       ; $A558: F0 05
  LDA #$01                              ; $A55A: A9 01     ; bit0 set: +1
  JMP @HealApplyStep                    ; $A55C: 4C 61 A5
@HealNegDir:
  LDA #$FF                              ; $A55F: A9 FF     ; bit0 clear: -1
@HealApplyStep:
  STA $0022                             ; $A561: 8D 22 00
  LDA $0020,Y                           ; $A564: B9 20 00  ; step coord toward target
  CLC                                   ; $A567: 18
  ADC $0022                             ; $A568: 6D 22 00
  STA $0020,Y                           ; $A56B: 99 20 00
  LDY #$31                              ; $A56E: A0 31     ; re-select data bank
  JSR B1F_SwitchBank8_A                             ; $A570: 20 66 F2  ; SwitchBank8_A
  LDA battle_province_idx                             ; $A573: AD 0E 05
  ASL                                   ; $A576: 0A
  STA $0022                             ; $A577: 8D 22 00
  ASL                                   ; $A57A: 0A
  CLC                                   ; $A57B: 18
  ADC $0022                             ; $A57C: 6D 22 00
  CLC                                   ; $A57F: 18
  ADC #$04                              ; $A580: 69 04     ; entry +4
  TAY                                   ; $A582: A8
  LDA $9BA4,Y                           ; $A583: B9 A4 9B  ; target X
  CMP $0020                             ; $A586: CD 20 00
  BNE @HealExit                         ; $A589: D0 09     ; not at target X
  INY                                   ; $A58B: C8
  LDA $9BA4,Y                           ; $A58C: B9 A4 9B  ; target Y
  CMP $0021                             ; $A58F: CD 21 00
  BEQ @HealArrived                      ; $A592: F0 01
@HealExit:
  RTS                                   ; $A594: 60
@HealArrived:
  LDY ai_officer_idx                             ; $A595: AC 8C 6F
  LDA officer_state_table,Y                           ; $A598: B9 A1 6F  ; officer state
  AND #$F0                              ; $A59B: 29 F0
  ORA #$07                              ; $A59D: 09 07     ; action nibble = 7
  STA officer_state_table,Y                           ; $A59F: 99 A1 6F
  LDX #$00                              ; $A5A2: A2 00     ; faction A funds
  LDA battle_side_flag                             ; $A5A4: AD 04 05
  BPL @HealCheckGold                    ; $A5A7: 10 02
  LDX #$02                              ; $A5A9: A2 02     ; faction B funds
@HealCheckGold:
  LDA battle_stat_b_hi,X                           ; $A5AB: BD 27 05  ; gold hi
  BNE @HealDeductGold                   ; $A5AE: D0 08     ; >= $100: affordable
  LDA battle_stat_b_lo,X                           ; $A5B0: BD 26 05  ; gold lo
  CMP #$32                              ; $A5B3: C9 32     ; need 50 gold
  BCS @HealDeductGold                   ; $A5B5: B0 01
  RTS                                   ; $A5B7: 60        ; too poor: abort
@HealDeductGold:
  LDA battle_stat_b_lo,X                           ; $A5B8: BD 26 05
  SEC                                   ; $A5BB: 38
  SBC #$32                              ; $A5BC: E9 32     ; -50 lo
  STA battle_stat_b_lo,X                           ; $A5BE: 9D 26 05
  LDA battle_stat_b_hi,X                           ; $A5C1: BD 27 05
  SBC #$00                              ; $A5C4: E9 00     ; borrow hi
  STA battle_stat_b_hi,X                           ; $A5C6: 9D 27 05
@HealRollLoop:
  JSR NextRandomByte                    ; $A5C9: 20 D5 B5
  AND #$0F                              ; $A5CC: 29 0F     ; random 0-15
  CMP #$0B                              ; $A5CE: C9 0B
  BCS @HealRollLoop                     ; $A5D0: B0 F7     ; reroll 11-15 -> 0-10
  CLC                                   ; $A5D2: 18
  ADC #$23                              ; $A5D3: 69 23     ; boost $23-$2D
  STA $002A                             ; $A5D5: 8D 2A 00
  LDY ai_officer_idx                             ; $A5D8: AC 8C 6F
  LDA battle_roster,Y                           ; $A5DB: B9 64 06  ; officer record id
  STA $002C                             ; $A5DE: 8D 2C 00
  JSR GetOfficerRecordPtrBanked         ; $A5E1: 20 E1 B4  ; ($20) = $8000+id*12 (bank $31)
  LDY #$00                              ; $A5E4: A0 00
  LDA ($20),Y                           ; $A5E6: B1 20     ; base HP
  STA $002B                             ; $A5E8: 8D 2B 00  ; cap
  LDA $002C                             ; $A5EB: AD 2C 00
  JSR GetOfficerRecordPtr               ; $A5EE: 20 91 B4  ; ($20) = $63C0+id*12
  LDY #$00                              ; $A5F1: A0 00
  LDA ($20),Y                           ; $A5F3: B1 20     ; current HP
  CLC                                   ; $A5F5: 18
  ADC $002A                             ; $A5F6: 6D 2A 00  ; + boost
  STA ($20),Y                           ; $A5F9: 91 20
  CMP $002B                             ; $A5FB: CD 2B 00  ; > base cap?
  BCC @HealDone                         ; $A5FE: 90 05
  LDA $002B                             ; $A600: AD 2B 00
  STA ($20),Y                           ; $A603: 91 20     ; clamp to base
@HealDone:
  RTS                                   ; $A605: 60
; Action 7: Idle - take no action
Action_Idle:
  LDA #$03                              ; $A606: A9 03     ; result = no action
  STA ai_action_result                             ; $A608: 8D 8F 6F
  RTS                                   ; $A60B: 60
;-------------------------------------------------------------------------------
; AiExecuteMove - Execute movement for current officer (nested)
; Only referenced by the Action_* handlers above: JMP tail-calls at
; $A0F3/$A163/$A1E2/$A286/$A2AA/$A302/$A326, JSR at $A34E/$A532
; Calculates direction and moves officer toward target position
; Input: $0020 = target X, $0021 = target Y
; Direction codes: 0=N, 1=S, 2=W, 3=E; $002A/$002B hold candidates as
; (cost<<4)|dir, ranked best-first; result in $6F8F (0=moved, 1=blocked by
; enemy -> attack, 3=no action), chosen direction in $6F8D (or enemy officer
; index on encounter), step cost in $6F97; a step is only taken when its
; terrain cost <= AI budget $0505
;-------------------------------------------------------------------------------
AiExecuteMove:
  LDY ai_officer_idx                             ; $A60C: AC 8C 6F  ; current officer
  JSR AiScanAdjacentOfficers            ; $A60F: 20 37 A8
  LDY ai_officer_idx                             ; $A612: AC 8C 6F
  LDA $0020                             ; $A615: AD 20 00  ; target X
  SEC                                   ; $A618: 38
  SBC unit_coord_x,Y                           ; $A619: F9 00 06  ; officer X
  STA $0020                             ; $A61C: 8D 20 00  ; delta X
  BPL @AbsX                             ; $A61F: 10 05
  EOR #$FF                              ; $A621: 49 FF     ; negate
  CLC                                   ; $A623: 18
  ADC #$01                              ; $A624: 69 01
@AbsX:
  STA $0022                             ; $A626: 8D 22 00  ; |delta X|
  LDA unit_coord_y,Y                           ; $A629: B9 14 06  ; officer Y
  CMP #$10                              ; $A62C: C9 10
  BCC @CalcDY                           ; $A62E: 90 03
  SEC                                   ; $A630: 38
  SBC #$01                              ; $A631: E9 01
@CalcDY:
  STA $0023                             ; $A633: 8D 23 00
  LDA $0021                             ; $A636: AD 21 00  ; target Y
  SEC                                   ; $A639: 38
  SBC $0023                             ; $A63A: ED 23 00
  STA $0021                             ; $A63D: 8D 21 00  ; delta Y
  BPL @AbsY                             ; $A640: 10 05
  EOR #$FF                              ; $A642: 49 FF     ; negate
  CLC                                   ; $A644: 18
  ADC #$01                              ; $A645: 69 01
@AbsY:
  STA $0023                             ; $A647: 8D 23 00
  LDY #$00                              ; $A64A: A0 00
  LDA $0023                             ; $A64C: AD 23 00
  CMP $0022                             ; $A64F: CD 22 00
  BCS @YAxisDominant                    ; $A652: B0 0C
  JSR @QueueXStepCandidate              ; $A654: 20 28 A7
  INY                                   ; $A657: C8
  JSR @QueueYStepCandidate              ; $A658: 20 33 A7
  LDY #$01                              ; $A65B: A0 01     ; secondary axis = Y
  JMP @SecondaryAxisDelta               ; $A65D: 4C 69 A6
@YAxisDominant:
  JSR @QueueYStepCandidate              ; $A660: 20 33 A7
  INY                                   ; $A663: C8
  JSR @QueueXStepCandidate              ; $A664: 20 28 A7
  LDY #$00                              ; $A667: A0 00     ; secondary axis = X
@SecondaryAxisDelta:
  LDA $0022,Y                           ; $A669: B9 22 00  ; secondary |delta|
  BNE @EvalNextCandidate                ; $A66C: D0 10
  LDA #$FF                              ; $A66E: A9 FF
  STA $002B                             ; $A670: 8D 2B 00  ; invalidate 2nd candidate
  TYA                                   ; $A673: 98
  EOR #$01                              ; $A674: 49 01
  TAY                                   ; $A676: A8        ; point at primary axis
  LDA $0022,Y                           ; $A677: B9 22 00  ; primary |delta|
  CMP #$01                              ; $A67A: C9 01     ; dead check (branch below
  BNE @EvalNextCandidate                ; $A67C: D0 00     ; has offset 0, always falls through)
@EvalNextCandidate:
  LDY #$00                              ; $A67E: A0 00
@EvalLoop:
  LDA $002A,Y                           ; $A680: B9 2A 00  ; candidate direction
  CMP #$FF                              ; $A683: C9 FF
  BEQ @StoreCandidateCost               ; $A685: F0 20     ; invalid: keep $FF
  TAX                                   ; $A687: AA
  TYA                                   ; $A688: 98
  PHA                                   ; $A689: 48
  JSR @EvalStepCost                     ; $A68A: 20 40 A7  ; Y=cost, C = cost <= $0505
  BCS @CostReturned                     ; $A68D: B0 02     ; C: affordable
  LDY #$0F                              ; $A68F: A0 0F     ; blocked: max cost
@CostReturned:
  TYA                                   ; $A691: 98
  ASL                                   ; $A692: 0A
  ASL                                   ; $A693: 0A
  ASL                                   ; $A694: 0A
  ASL                                   ; $A695: 0A        ; cost -> high nibble
  STA $0022                             ; $A696: 8D 22 00
  PLA                                   ; $A699: 68
  TAY                                   ; $A69A: A8
  LDA $002A,Y                           ; $A69B: B9 2A 00
  ORA $0022                             ; $A69E: 0D 22 00  ; (cost<<4)|dir
  STA $002A,Y                           ; $A6A1: 99 2A 00
  LDA $0022                             ; $A6A4: AD 22 00
@StoreCandidateCost:
  STA $002C,Y                           ; $A6A7: 99 2C 00  ; cost mirror
  INY                                   ; $A6AA: C8
  CPY #$02                              ; $A6AB: C0 02
  BCC @EvalLoop                         ; $A6AD: 90 D1
  LDA $002C                             ; $A6AF: AD 2C 00  ; candidate 0 cost
  CMP $002D                             ; $A6B2: CD 2D 00  ; candidate 1 cost
  BEQ @BestCandidateReady               ; $A6B5: F0 10
  BCC @BestCandidateReady               ; $A6B7: 90 0E     ; 0 already cheaper
  LDA $002B                             ; $A6B9: AD 2B 00  ; swap: cheapest first
  TAX                                   ; $A6BC: AA
  LDA $002A                             ; $A6BD: AD 2A 00
  STA $002B                             ; $A6C0: 8D 2B 00
  TXA                                   ; $A6C3: 8A
  STA $002A                             ; $A6C4: 8D 2A 00
@BestCandidateReady:
  LDY ai_officer_idx                             ; $A6C7: AC 8C 6F
  LDA move_reverse_dirs,Y                           ; $A6CA: B9 B5 6F  ; prev reverse direction
  STA $002F                             ; $A6CD: 8D 2F 00  ; dead store: never read again
  LDY #$00                              ; $A6D0: A0 00
@CandidateLoop:
  LDA $002A,Y                           ; $A6D2: B9 2A 00  ; ranked candidate
  CMP #$F0                              ; $A6D5: C9 F0
  BCS @TryNextCandidate                 ; $A6D7: B0 0D     ; cost 15: impassable
  STA $0020                             ; $A6D9: 8D 20 00
  AND #$0F                              ; $A6DC: 29 0F     ; direction code
  TAX                                   ; $A6DE: AA
  LDA adjacent_scan_results,X                           ; $A6DF: BD DD 6F  ; adjacent scan result
  CMP #$FF                              ; $A6E2: C9 FF
  BEQ @CommitMove                       ; $A6E4: F0 1C     ; tile empty: move there
@TryNextCandidate:
  INY                                   ; $A6E6: C8
  CPY #$02                              ; $A6E7: C0 02
  BCC @CandidateLoop                    ; $A6E9: 90 E7
  LDY ai_officer_idx                             ; $A6EB: AC 8C 6F
  LDA officer_state_table,Y                           ; $A6EE: B9 A1 6F  ; officer state
  CMP #$01                              ; $A6F1: C9 01     ; regrouping?
  BEQ @BlockedPathEncounter             ; $A6F3: F0 0A
  CMP #$05                              ; $A6F5: C9 05     ; capturing province?
  BEQ @BlockedPathEncounter             ; $A6F7: F0 06
@AbortNoAction:
  LDA #$03                              ; $A6F9: A9 03     ; result = no action
  STA ai_action_result                             ; $A6FB: 8D 8F 6F
  RTS                                   ; $A6FE: 60
@BlockedPathEncounter:
  JMP @CheckEnemyEncounter              ; $A6FF: 4C 05 A8  ; regroup/capture: engage
@CommitMove:
  LDY ai_officer_idx                             ; $A702: AC 8C 6F
  LDA unit_immobilized,Y                           ; $A705: B9 50 06  ; immobilized flag
  BNE @AbortNoAction                    ; $A708: D0 EF
  STX ai_target_slot                             ; $A70A: 8E 8D 6F  ; chosen direction
  LDA #$00                              ; $A70D: A9 00     ; result = moved
  STA ai_action_result                             ; $A70F: 8D 8F 6F
  LDA $0020                             ; $A712: AD 20 00  ; candidate byte
  LSR                                   ; $A715: 4A
  LSR                                   ; $A716: 4A
  LSR                                   ; $A717: 4A
  LSR                                   ; $A718: 4A        ; cost nibble
  STA ai_move_cost                             ; $A719: 8D 97 6F
  LDY ai_officer_idx                             ; $A71C: AC 8C 6F
  LDA ai_target_slot                             ; $A71F: AD 8D 6F  ; chosen direction
  EOR #$01                              ; $A722: 49 01     ; reverse dir (N<->S, W<->E)
  STA move_reverse_dirs,Y                           ; $A724: 99 B5 6F  ; store reverse of this move
  RTS                                   ; $A727: 60
; Store X-axis step candidate: dir 2 (west) if dx<0, else 3 (east)
@QueueXStepCandidate:
  LDX #$02                              ; $A728: A2 02
  LDA $0020                             ; $A72A: AD 20 00  ; signed delta X
  BMI @StoreCandidate                   ; $A72D: 30 0C
  INX                                   ; $A72F: E8
  JMP @StoreCandidate                   ; $A730: 4C 3B A7
; Store Y-axis step candidate: dir 0 (north) if dy<0, else 1 (south)
@QueueYStepCandidate:
  LDX #$00                              ; $A733: A2 00
  LDA $0021                             ; $A735: AD 21 00  ; signed delta Y
  BMI @StoreCandidate                   ; $A738: 30 01
  INX                                   ; $A73A: E8
@StoreCandidate:
  TXA                                   ; $A73B: 8A
  STA $002A,Y                           ; $A73C: 99 2A 00  ; queue direction
  RTS                                   ; $A73F: 60
; Evaluate one-step move in direction X; returns Y=cost and C = (cost <= $0505)
; (carry comes from the final SBC against the budget); C=0 also for off-map
@EvalStepCost:
  LDA #$00                              ; $A740: A9 00
  STA $0020                             ; $A742: 8D 20 00  ; step X = 0
  STA $0021                             ; $A745: 8D 21 00  ; step Y = 0
  LDA #$01                              ; $A748: A9 01
  STA $0022                             ; $A74A: 8D 22 00  ; default +1
  TXA                                   ; $A74D: 8A
  AND #$01                              ; $A74E: 29 01     ; bit0 = positive dir
  BNE @ApplyStepVector                  ; $A750: D0 05
  LDA #$FF                              ; $A752: A9 FF
  STA $0022                             ; $A754: 8D 22 00  ; negative step
@ApplyStepVector:
  TXA                                   ; $A757: 8A
  LSR                                   ; $A758: 4A
  AND #$01                              ; $A759: 29 01     ; bit1 = X axis
  EOR #$01                              ; $A75B: 49 01     ; 0=X, 1=Y index
  TAX                                   ; $A75D: AA
  LDA $0022                             ; $A75E: AD 22 00
  STA $0020,X                           ; $A761: 9D 20 00  ; set axis step
  LDX ai_officer_idx                             ; $A764: AE 8C 6F
  LDA unit_coord_x,X                           ; $A767: BD 00 06  ; officer X
  CLC                                   ; $A76A: 18
  ADC $0020                             ; $A76B: 6D 20 00
  STA $0020                             ; $A76E: 8D 20 00  ; candidate X
  BMI @StepBlocked                      ; $A771: 30 04
  CMP #$1F                              ; $A773: C9 1F     ; map width 31
  BCC @CheckYBounds                     ; $A775: 90 02
@StepBlocked:
  CLC                                   ; $A777: 18        ; C=0: out of bounds
  RTS                                   ; $A778: 60
@CheckYBounds:
  LDA unit_coord_y,X                           ; $A779: BD 14 06  ; officer Y
  CLC                                   ; $A77C: 18
  ADC $0021                             ; $A77D: 6D 21 00
  STA $0021                             ; $A780: 8D 21 00  ; candidate Y
  BMI @StepBlocked                      ; $A783: 30 F2
  CMP #$14                              ; $A785: C9 14     ; map height 20
  BCS @StepBlocked                      ; $A787: B0 EE
  JSR GetTileTerrainClamped             ; $A789: 20 E5 B6  ; A = terrain at ($0020,$0021)
  PHA                                   ; $A78C: 48
  LDY ai_officer_idx                             ; $A78D: AC 8C 6F
  LDA battle_roster,Y                           ; $A790: B9 64 06  ; officer id
  JSR GetOfficerRecordPtr               ; $A793: 20 91 B4
  LDY #$0B                              ; $A796: A0 0B
  LDA ($20),Y                           ; $A798: B1 20     ; status flags
  LSR                                   ; $A79A: 4A
  LSR                                   ; $A79B: 4A
  AND #$03                              ; $A79C: 29 03     ; move type 0-3
  STA $0022                             ; $A79E: 8D 22 00
  PLA                                   ; $A7A1: 68
  ASL                                   ; $A7A2: 0A
  ASL                                   ; $A7A3: 0A        ; terrain * 4
  ORA $0022                             ; $A7A4: 0D 22 00
  TAX                                   ; $A7A7: AA        ; table index
  LDY #$08                              ; $A7A8: A0 08
  LDA ($20),Y                           ; $A7AA: B1 20     ; record byte 8
  SEC                                   ; $A7AC: 38
  SBC #$59                              ; $A7AD: E9 59     ; intended 16-bit cmp vs $0259,
  LDA ($20),Y                           ; $A7AF: B1 20     ; but byte 8 is loaded twice
  SBC #$02                              ; $A7B1: E9 02     ; (missing INY) - actual effect:
  BCC @UseReducedCostTable              ; $A7B3: 90 0C     ; reduced iff byte 8 <= 2
  LDA @StepCostTable_Full,X             ; $A7B5: BD CD A7
  TAY                                   ; $A7B8: A8        ; Y = step cost
  LDA battle_action_points                             ; $A7B9: AD 05 05
  SEC                                   ; $A7BC: 38
  SBC @StepCostTable_Full,X             ; $A7BD: FD CD A7
  RTS                                   ; $A7C0: 60
@UseReducedCostTable:
  LDA @StepCostTable_Reduced,X          ; $A7C1: BD E9 A7
  TAY                                   ; $A7C4: A8        ; Y = step cost
  LDA battle_action_points                             ; $A7C5: AD 05 05
  SEC                                   ; $A7C8: 38
  SBC @StepCostTable_Reduced,X          ; $A7C9: FD E9 A7
  RTS                                   ; $A7CC: 60
; Step-cost table: 14 terrain groups x 4 move types (column 3 unused).
; Indexed by (terrain from $B6E5)<<2 | move type. The reduced variant is the
; same table offset by 7 groups ($A7E9), selected when record byte 8 <= 2.
@StepCostTable_Full:
  .byte $03,$05,$05,$00,$04,$04,$04,$00,$02,$03,$03,$00,$05,$06,$03,$00; $A7CD: 03 05 05 00 04 04 04 00 02 03 03 00 05 06 03 00  ; groups 0-3
  .byte $05,$03,$06,$00,$06,$06,$06,$00,$06,$06,$06,$00     ; $A7DD: 05 03 06 00 06 06 06 00 06 06 06 00  ; groups 4-6
@StepCostTable_Reduced:                     ; = @StepCostTable_Full + 7 groups ($A7E9)
  .byte $02,$03,$03,$00                       ; $A7E9: 02 03 03 00  ; group 7
  .byte $03,$03,$03,$00,$01,$02,$02,$00,$03,$05,$02,$00,$03,$02,$04,$00; $A7ED: 03 03 03 00 01 02 02 00 03 05 02 00 03 02 04 00  ; groups 8-11
  .byte $04,$04,$04,$00,$04,$04,$04,$00       ; $A7FD: 04 04 04 00 04 04 04 00  ; groups 12-13
; Regroup (state 1) / capture (state 5) paths reach here when both candidate
; tiles are occupied: if an enemy stands on a candidate direction, record the
; encounter ($6F8D = enemy officer index) and, when $0505 >= 2, set result 1
@CheckEnemyEncounter:
  LDY #$00                              ; $A805: A0 00
@EncounterLoop:
  LDA $002A,Y                           ; $A807: B9 2A 00
  CMP #$F0                              ; $A80A: C9 F0
  BCS @EncounterNext                    ; $A80C: B0 1E     ; cost 15: skip
  AND #$0F                              ; $A80E: 29 0F
  TAX                                   ; $A810: AA        ; direction code
  LDA adjacent_scan_results,X                           ; $A811: BD DD 6F  ; adjacent scan result
  BPL @EncounterNext                    ; $A814: 10 16     ; bit7 clear: ally
  CMP #$FF                              ; $A816: C9 FF
  BEQ @EncounterNext                    ; $A818: F0 12     ; empty tile
  AND #$7F                              ; $A81A: 29 7F     ; enemy officer index
  STA ai_target_slot                             ; $A81C: 8D 8D 6F
  LDA battle_action_points                             ; $A81F: AD 05 05
  CMP #$02                              ; $A822: C9 02
  BCC @EncounterNext                    ; $A824: 90 06
  LDA #$01                              ; $A826: A9 01     ; result = blocked/engage
  STA ai_action_result                             ; $A828: 8D 8F 6F
  RTS                                   ; $A82B: 60
@EncounterNext:
  INY                                   ; $A82C: C8
  CPY #$02                              ; $A82D: C0 02
  BCC @EncounterLoop                    ; $A82F: 90 D6
  LDA #$03                              ; $A831: A9 03     ; no enemy: no action
  STA ai_action_result                             ; $A833: 8D 8F 6F
  RTS                                   ; $A836: 60
;-------------------------------------------------------------------------------
; AiScanAdjacentOfficers - Scan 4 adjacent positions for officers (nested)
; Populates $6FDD-$6FE0 with officer indices found N/S/W/E
; Input: Y = officer index
; Referenced by the Action_* handlers above ($A11B/$A259), AiExecuteMove
; ($A60F), AiCheckAttackNearby ($A8B2), and AiCheckActionFeasible
; ($AD0A/$AD2E/$AD73/$AD9C/$AE08/$AE2A)
;-------------------------------------------------------------------------------
AiScanAdjacentOfficers:
  LDA unit_coord_x,Y                           ; $A837: B9 00 06  ; officer X
  STA $0022                             ; $A83A: 8D 22 00
  LDA unit_coord_y,Y                           ; $A83D: B9 14 06  ; officer Y
  CMP #$10                              ; $A840: C9 10
  BCC @StoreY                           ; $A842: 90 03
  SEC                                   ; $A844: 38
  SBC #$01                              ; $A845: E9 01
@StoreY:
  STA $0023                             ; $A847: 8D 23 00
  DEC $0023                             ; $A84A: CE 23 00  ; Y-1 (North)
  LDX #$00                              ; $A84D: A2 00
  JSR @ScanPosition                     ; $A84F: 20 71 A8
  INC $0023                             ; $A852: EE 23 00
  INC $0023                             ; $A855: EE 23 00  ; Y+1 (South)
  INX                                   ; $A858: E8
  JSR @ScanPosition                     ; $A859: 20 71 A8
  DEC $0023                             ; $A85C: CE 23 00
  DEC $0022                             ; $A85F: CE 22 00  ; X-1 (West)
  INX                                   ; $A862: E8
  JSR @ScanPosition                     ; $A863: 20 71 A8
  INC $0022                             ; $A866: EE 22 00
  INC $0022                             ; $A869: EE 22 00  ; X+1 (East)
  INX                                   ; $A86C: E8
  JSR @ScanPosition                     ; $A86D: 20 71 A8
  RTS                                   ; $A870: 60
@ScanPosition:
  LDY #$00                              ; $A871: A0 00
@Loop:
  LDA battle_roster,Y                           ; $A873: B9 64 06  ; officer record
  CMP #$FF                              ; $A876: C9 FF
  BEQ @NotFound                         ; $A878: F0 23
  LDA unit_coord_x,Y                           ; $A87A: B9 00 06  ; officer X
  CMP $0022                             ; $A87D: CD 22 00  ; target X
  BNE @NotFound                         ; $A880: D0 1B
  LDA unit_coord_y,Y                           ; $A882: B9 14 06  ; officer Y
  CMP #$10                              ; $A885: C9 10
  BCC @CompareY                         ; $A887: 90 02
  SBC #$01                              ; $A889: E9 01
@CompareY:
  CMP $0023                             ; $A88B: CD 23 00  ; target Y
  BNE @NotFound                         ; $A88E: D0 0D
  STY $0024                             ; $A890: 8C 24 00  ; save index
  JSR AiCheckFaction                    ; $A893: 20 44 A9
  ORA $0024                             ; $A896: 0D 24 00  ; combine faction flag
  STA adjacent_scan_results,X                           ; $A899: 9D DD 6F  ; store result
  RTS                                   ; $A89C: 60
@NotFound:
  INY                                   ; $A89D: C8
  CPY #$14                              ; $A89E: C0 14
  BCC @Loop                             ; $A8A0: 90 D1
  LDA #$FF                              ; $A8A2: A9 FF     ; no officer
  STA adjacent_scan_results,X                           ; $A8A4: 9D DD 6F
  RTS                                   ; $A8A7: 60
;-------------------------------------------------------------------------------
; AiCheckAttackNearby - Check for an enemy officer on a tile adjacent to the
; current officer ($6F8C) and select it as attack target (nested)
;
; Requires AI action budget $0505 >= 2 (attacking costs 2); below that the
; officer may not engage even with an enemy next to it.
;
; Scans N/S/W/E via AiScanAdjacentOfficers into $6FDD-$6FE0, then picks the
; first entry with bit 7 set (enemy). Direction order is fixed: N, S, W, E.
;
; Returns: C=1 if target found -> $6F8D = target officer index, $6F8F = 1
;          C=0 otherwise (budget too low or no adjacent enemy)
;
; Called from Action_DefaultDecision ($A0C5), Action_AttackNearest ($A175),
; Action_DefendBase ($A21C), and Action_SweepRange3 ($A2B9) above
;-------------------------------------------------------------------------------
AiCheckAttackNearby:
  LDA battle_action_points                             ; $A8A8: AD 05 05  ; AI action budget
  CMP #$02                              ; $A8AB: C9 02     ; need >= 2 to attack
  BCC @NoTarget                         ; $A8AD: 90 22     ; too weak: skip
  LDY ai_officer_idx                             ; $A8AF: AC 8C 6F  ; current officer
  JSR AiScanAdjacentOfficers            ; $A8B2: 20 37 A8  ; fill $6FDD-$6FE0
  LDX #$00                              ; $A8B5: A2 00     ; direction 0 = North
@CheckDirection:
  LDA adjacent_scan_results,X                           ; $A8B7: BD DD 6F  ; adjacent scan entry
  CMP #$FF                              ; $A8BA: C9 FF
  BEQ @NextDirection                    ; $A8BC: F0 0E     ; empty tile
  BPL @NextDirection                    ; $A8BE: 10 0C     ; bit7 clear: ally
  AND #$7F                              ; $A8C0: 29 7F     ; enemy officer index
  STA ai_target_slot                             ; $A8C2: 8D 8D 6F  ; attack target
  LDA #$01                              ; $A8C5: A9 01
  STA ai_action_result                             ; $A8C7: 8D 8F 6F  ; result = attack
  SEC                                   ; $A8CA: 38
  RTS                                   ; $A8CB: 60
@NextDirection:
  INX                                   ; $A8CC: E8
  CPX #$04                              ; $A8CD: E0 04     ; 4 directions
  BCC @CheckDirection                   ; $A8CF: 90 E6
@NoTarget:
  CLC                                   ; $A8D1: 18
  RTS                                   ; $A8D2: 60
;===============================================================================
; AiFindNearbyOfficers - Scan all officers within Manhattan-distance range
; Input:  A = search radius (per axis), Y = index of reference officer
; Output: $6FC9+i entry for each officer slot i (0..19):
;           bit7 = 1 if officer is enemy of current side (AiCheckFaction)
;           bits0-6 = Manhattan distance |dx|+|dy| from reference officer
;           $00 = slot inactive ($0664=$FF) or skipped (out of range)
; Note: Y coords >= $10 are normalized (-1) to skip the map's gap row, so
;       distances are computed on the corrected coordinate space.
;===============================================================================
AiFindNearbyOfficers:
  STA $0022                             ; $A8D3: 8D 22 00  ; search radius
  LDA unit_coord_x,Y                           ; $A8D6: B9 00 06  ; reference officer X
  STA $0020                             ; $A8D9: 8D 20 00
  LDA unit_coord_y,Y                           ; $A8DC: B9 14 06  ; reference officer Y
  CMP #$10                              ; $A8DF: C9 10
  BCC @InitDone                         ; $A8E1: 90 02
  SBC #$01                              ; $A8E3: E9 01     ; skip gap row
@InitDone:
  STA $0021                             ; $A8E5: 8D 21 00  ; normalized ref Y
AiFindNearbyOfficers_ScanLoop:
  LDY #$00                              ; $A8E8: A0 00     ; scan slots 0..19
@ScanSlot:
  LDA #$00                              ; $A8EA: A9 00
  STA proximity_table,Y                           ; $A8EC: 99 C9 6F  ; clear entry
  LDA battle_roster,Y                           ; $A8EF: B9 64 06  ; officer status
  CMP #$FF                              ; $A8F2: C9 FF
  BEQ @NextSlot                         ; $A8F4: F0 48     ; inactive slot
  LDA unit_coord_x,Y                           ; $A8F6: B9 00 06  ; candidate X
  SEC                                   ; $A8F9: 38
  SBC $0020                             ; $A8FA: ED 20 00  ; dx
  BPL @DxAbs                            ; $A8FD: 10 05
  EOR #$FF                              ; $A8FF: 49 FF     ; negate -> |dx|
  CLC                                   ; $A901: 18
  ADC #$01                              ; $A902: 69 01
@DxAbs:
  CMP $0022                             ; $A904: CD 22 00  ; |dx| vs radius
  BEQ @DxOk                             ; $A907: F0 05
  BCC @DxOk                             ; $A909: 90 03
  JMP @NextSlot                         ; $A90B: 4C 3E A9  ; |dx| > radius
@DxOk:
  STA $0023                             ; $A90E: 8D 23 00  ; save |dx|
  LDA unit_coord_y,Y                           ; $A911: B9 14 06  ; candidate Y
  CMP #$10                              ; $A914: C9 10
  BCC @DyNorm                           ; $A916: 90 02
  SBC #$01                              ; $A918: E9 01     ; skip gap row
@DyNorm:
  SEC                                   ; $A91A: 38
  SBC $0021                             ; $A91B: ED 21 00  ; dy
  BPL @DyAbs                            ; $A91E: 10 05
  EOR #$FF                              ; $A920: 49 FF     ; negate -> |dy|
  CLC                                   ; $A922: 18
  ADC #$01                              ; $A923: 69 01
@DyAbs:
  CMP $0022                             ; $A925: CD 22 00  ; |dy| vs radius
  BEQ @DyOk                             ; $A928: F0 05
  BCC @DyOk                             ; $A92A: 90 03
  JMP @NextSlot                         ; $A92C: 4C 3E A9  ; |dy| > radius
@DyOk:
  ADC $0023                             ; $A92F: 6D 23 00  ; dist = |dx|+|dy| (C=0 after CMP)
  STA $0023                             ; $A932: 8D 23 00
  JSR AiCheckFaction                    ; $A935: 20 44 A9  ; A=$80 enemy / $00 ally
  ORA $0023                             ; $A938: 0D 23 00  ; entry = faction bit | dist
  STA proximity_table,Y                           ; $A93B: 99 C9 6F
@NextSlot:
  INY                                   ; $A93E: C8
  CPY #$14                              ; $A93F: C0 14     ; 20 officer slots
  BCC @ScanSlot                         ; $A941: 90 A7
  RTS                                   ; $A943: 60
;===============================================================================
; AiCheckFaction - Check if officer is enemy or ally of the acting side
; Input:  Y = officer slot index (0-19)
; Uses:   $0504  = acting-side faction flag (bit7 selects which faction acts)
;         $0628,Y = per-officer faction byte (stride-$14 array $0600/$0614/
;                   $0628/$063C/$0650/$0664); bit7 = officer's faction,
;                   $FF = empty slot
; Logic:  enemy iff bit7($0504) != bit7($0628,Y) (sign-bit XOR)
; Returns: A=$80 if enemy (N=1), A=$00 if ally (N=0); Y preserved
; Note:   A byte-identical duplicate exists at $CC92 (called by the $C9xx-$CCxx
;         civil routines via JSR $CC92); both copies must stay in place for
;         byte-exact ROM matching.
;===============================================================================
AiCheckFaction:
  LDA battle_side_flag                             ; $A944: AD 04 05
  BMI @ActingSideBit7                   ; $A947: 30 08
  LDA unit_army_array,Y                           ; $A949: B9 28 06
  BMI @ReturnEnemy                      ; $A94C: 30 0B
  LDA #$00                              ; $A94E: A9 00
  RTS                                   ; $A950: 60
@ActingSideBit7:
  LDA unit_army_array,Y                           ; $A951: B9 28 06
  BPL @ReturnEnemy                      ; $A954: 10 03
  LDA #$00                              ; $A956: A9 00
  RTS                                   ; $A958: 60
@ReturnEnemy:
  LDA #$80                              ; $A959: A9 80
  RTS                                   ; $A95B: 60
;===============================================================================
; AiCheckMove ($A95C-$A9CE) - Select an action against the best nearby
; enemy candidate for the current AI officer ($6F8C).
;
; 1. Derive an officer rating tier from record field +2 ($002A = 1/3/5/7/9).
; 2. Fill the nearby-officer table ($6FC9, radius 5) and compact it to enemy
;    officer slot indices sorted by troop strength (AiSortNearbyOfficers).
; 3. Try candidates in strength order: AiCheckAttackFeasible picks the best
;    feasible action ($002C) against each candidate.
;
; Output: C=1 -> $6F8D = action code ($002C), $6F8E = target officer slot,
;                $6F8F = 2
;         C=0 -> $6F8F = 3 (no feasible action)
;===============================================================================
AiCheckMove:
  LDY ai_officer_idx                             ; $A95C: AC 8C 6F  ; current AI officer
  LDA battle_roster,Y                           ; $A95F: B9 64 06
  JSR GetOfficerRecordPtr               ; $A962: 20 91 B4  ; ($20) = record
  LDY #$02                              ; $A965: A0 02
  LDX #$01                              ; $A967: A2 01
  LDA ($20),Y                           ; $A969: B1 20     ; record field +2 (rating)
  CMP #$28                              ; $A96B: C9 28
  BCC @StoreTier                        ; $A96D: 90 14
  LDX #$03                              ; $A96F: A2 03
  CMP #$3C                              ; $A971: C9 3C
  BCC @StoreTier                        ; $A973: 90 0E
  LDX #$05                              ; $A975: A2 05
  CMP #$4B                              ; $A977: C9 4B
  BCC @StoreTier                        ; $A979: 90 08
  LDX #$07                              ; $A97B: A2 07
  CMP #$55                              ; $A97D: C9 55
  BCC @StoreTier                        ; $A97F: 90 02
  LDX #$09                              ; $A981: A2 09
@StoreTier:
  STX $002A                             ; $A983: 8E 2A 00  ; rating tier 1/3/5/7/9
  LDY ai_officer_idx                             ; $A986: AC 8C 6F
  LDA #$05                              ; $A989: A9 05     ; search radius 5
  JSR AiFindNearbyOfficers              ; $A98B: 20 D3 A8  ; fill $6FC9
  JSR AiSortNearbyOfficers              ; $A98E: 20 93 AE  ; enemy slots, strongest first
  LDY #$00                              ; $A991: A0 00
@TryCandidate:
  LDA proximity_table,Y                           ; $A993: B9 C9 6F  ; candidate officer slot
  CMP #$FF                              ; $A996: C9 FF
  BEQ @NoCandidate                      ; $A998: F0 2E     ; end of list
  TAX                                   ; $A99A: AA
  LDA battle_roster,X                           ; $A99B: BD 64 06
  CMP #$FF                              ; $A99E: C9 FF
  BEQ @NextCandidate                    ; $A9A0: F0 21     ; slot inactive
  STX $002B                             ; $A9A2: 8E 2B 00  ; candidate for feasibility check
  STY $002F                             ; $A9A5: 8C 2F 00  ; save list index (sort clobbers)
  JSR AiCheckAttackFeasible             ; $A9A8: 20 CF A9
  BCC @Retry                            ; $A9AB: 90 13
  LDA $002C                             ; $A9AD: AD 2C 00  ; chosen action code
  STA ai_target_slot                             ; $A9B0: 8D 8D 6F
  LDA $002B                             ; $A9B3: AD 2B 00
  STA ai_target_officer                             ; $A9B6: 8D 8E 6F  ; action target officer
  LDA #$02                              ; $A9B9: A9 02
  STA ai_action_result                             ; $A9BB: 8D 8F 6F  ; decision = act on target
  SEC                                   ; $A9BE: 38
  RTS                                   ; $A9BF: 60
@Retry:
  LDY $002F                             ; $A9C0: AC 2F 00  ; restore list index
@NextCandidate:
  INY                                   ; $A9C3: C8
  CPY #$14                              ; $A9C4: C0 14     ; 20 officer slots max
  BCC @TryCandidate                     ; $A9C6: 90 CB
@NoCandidate:
  LDA #$03                              ; $A9C8: A9 03
  STA ai_action_result                             ; $A9CA: 8D 8F 6F  ; decision = nothing feasible
  CLC                                   ; $A9CD: 18
  RTS                                   ; $A9CE: 60
;===============================================================================
; AiCheckAttackFeasible ($A9CF-$AAF7) - Choose a feasible action against the
; candidate officer in $002B for the current AI officer ($6F8C).
;
; Input:  $002A = rating tier (1/3/5/7/9 from AiCheckMove)
;         $002B = candidate officer slot
;         $0505 = AI action budget
; Output: C=1 -> $002C = chosen action code (also stored by AiCheckActionFeasible)
;         C=0 -> $6F8F = 3 (nothing feasible)
;
; Tries a fixed priority cascade of action codes, each gated by rating tier,
; whether the candidate has troops ($002D), the action budget $0505, and the
; terrain/situation check in AiCheckActionFeasible. If the direct cascade
; fails, a random branch picks between actions 2/1/3, then falls back to
; actions 4 and 0.
;===============================================================================
AiCheckAttackFeasible:
  LDY $002B                             ; $A9CF: AC 2B 00  ; candidate officer
  LDA battle_roster,Y                           ; $A9D2: B9 64 06
  JSR GetOfficerRecordPtr               ; $A9D5: 20 91 B4
  LDY #$09                              ; $A9D8: A0 09
  LDA ($20),Y                           ; $A9DA: B1 20     ; troop count high
  BNE @StoreTroopFlag                   ; $A9DC: D0 07
  DEY                                   ; $A9DE: 88
  LDA ($20),Y                           ; $A9DF: B1 20     ; troop count low
  BNE @StoreTroopFlag                   ; $A9E1: D0 02
  LDA #$00                              ; $A9E3: A9 00     ; candidate has no troops
@StoreTroopFlag:
  STA $002D                             ; $A9E5: 8D 2D 00
; --- Action 6: tier >= 6, candidate has troops, budget >= 8 ---
  LDA $002A                             ; $A9E8: AD 2A 00
  CMP #$06                              ; $A9EB: C9 06
  BCC @TryAction5                       ; $A9ED: 90 14
  LDA $002D                             ; $A9EF: AD 2D 00
  BEQ @TryAction5                       ; $A9F2: F0 0F
  LDA battle_action_points                             ; $A9F4: AD 05 05
  CMP #$08                              ; $A9F7: C9 08
  BCC @TryAction5                       ; $A9F9: 90 08
  LDX #$06                              ; $A9FB: A2 06
  JSR AiCheckActionFeasible             ; $A9FD: 20 7B AC
  BCC @TryAction5                       ; $AA00: 90 01
  RTS                                   ; $AA02: 60
; --- Action 5: tier >= 5, budget >= 8 ---
@TryAction5:
  LDA $002A                             ; $AA03: AD 2A 00
  CMP #$05                              ; $AA06: C9 05
  BCC @TryAction8                       ; $AA08: 90 0F
  LDA battle_action_points                             ; $AA0A: AD 05 05
  CMP #$08                              ; $AA0D: C9 08
  BCC @TryAction8                       ; $AA0F: 90 08
  LDX #$05                              ; $AA11: A2 05
  JSR AiCheckActionFeasible             ; $AA13: 20 7B AC
  BCC @TryAction8                       ; $AA16: 90 01
  RTS                                   ; $AA18: 60
; --- Action 8: tier >= 8, budget >= $0A ---
@TryAction8:
  LDA $002A                             ; $AA19: AD 2A 00
  CMP #$08                              ; $AA1C: C9 08
  BCC @TryAction9                       ; $AA1E: 90 0F
  LDA battle_action_points                             ; $AA20: AD 05 05
  CMP #$0A                              ; $AA23: C9 0A
  BCC @TryAction9                       ; $AA25: 90 08
  LDX #$08                              ; $AA27: A2 08
  JSR AiCheckActionFeasible             ; $AA29: 20 7B AC
  BCC @TryAction9                       ; $AA2C: 90 01
  RTS                                   ; $AA2E: 60
; --- Action 9: tier >= 9, candidate has troops, budget >= 9 ---
@TryAction9:
  LDA $002A                             ; $AA2F: AD 2A 00
  CMP #$09                              ; $AA32: C9 09
  BCC @TryAction7                       ; $AA34: 90 14
  LDA $002D                             ; $AA36: AD 2D 00
  BEQ @TryAction7                       ; $AA39: F0 0F
  LDA battle_action_points                             ; $AA3B: AD 05 05
  CMP #$09                              ; $AA3E: C9 09
  BCC @TryAction7                       ; $AA40: 90 08
  LDX #$09                              ; $AA42: A2 09
  JSR AiCheckActionFeasible             ; $AA44: 20 7B AC
  BCC @TryAction7                       ; $AA47: 90 01
  RTS                                   ; $AA49: 60
; --- Action 7: tier >= 7, candidate has troops, budget >= 8 ---
@TryAction7:
  LDA $002A                             ; $AA4A: AD 2A 00
  CMP #$07                              ; $AA4D: C9 07
  BCC @TryAction1                       ; $AA4F: 90 14
  LDA $002D                             ; $AA51: AD 2D 00
  BEQ @TryAction1                       ; $AA54: F0 0F
  LDA battle_action_points                             ; $AA56: AD 05 05
  CMP #$08                              ; $AA59: C9 08
  BCC @TryAction1                       ; $AA5B: 90 08
  LDX #$07                              ; $AA5D: A2 07
  JSR AiCheckActionFeasible             ; $AA5F: 20 7B AC
  BCC @TryAction1                       ; $AA62: 90 01
  RTS                                   ; $AA64: 60
; --- Action 1: no gating other than the feasibility check ---
@TryAction1:
  LDX #$01                              ; $AA65: A2 01
  JSR AiCheckActionFeasible             ; $AA67: 20 7B AC
  BCS @RandomPick                       ; $AA6A: B0 03
  JMP @TryAction4                       ; $AA6C: 4C C2 AA
; --- Random fallback: roll 0-3 and map to actions 2/1/3 (0 = reroll) ---
@RandomPick:
  JSR NextRandomByte                    ; $AA6F: 20 D5 B5
  AND #$03                              ; $AA72: 29 03
  BEQ @RandomPick                       ; $AA74: F0 F9     ; 0 -> reroll
  CMP #$01                              ; $AA76: C9 01
  BEQ @RandomAction2                    ; $AA78: F0 1D
  CMP #$02                              ; $AA7A: C9 02
  BEQ @RandomAction1                    ; $AA7C: F0 37
; --- Random roll 3: action 3, needs troops, tier >= 3, budget >= 6 ---
  LDA $002D                             ; $AA7E: AD 2D 00
  BEQ @RandomPick                       ; $AA81: F0 EC     ; no troops -> reroll
  LDA $002A                             ; $AA83: AD 2A 00
  CMP #$03                              ; $AA86: C9 03
  BCC @TryAction4                       ; $AA88: 90 38
  LDA #$03                              ; $AA8A: A9 03
  STA $002C                             ; $AA8C: 8D 2C 00
  LDA battle_action_points                             ; $AA8F: AD 05 05
  CMP #$06                              ; $AA92: C9 06
  BCC @TryAction4                       ; $AA94: 90 2C
  RTS                                   ; $AA96: 60
; --- Random roll 1: action 2, tier >= 2, target state low nibble 0, budget >= 4 ---
@RandomAction2:
  LDA $002A                             ; $AA97: AD 2A 00
  CMP #$02                              ; $AA9A: C9 02
  BCC @TryAction4                       ; $AA9C: 90 24
  LDY $002B                             ; $AA9E: AC 2B 00
  LDA unit_immobilized,Y                           ; $AAA1: B9 50 06  ; candidate state
  AND #$0F                              ; $AAA4: 29 0F
  BNE @TryAction4                       ; $AAA6: D0 1A     ; must be idle (0)
  LDA #$02                              ; $AAA8: A9 02
  STA $002C                             ; $AAAA: 8D 2C 00
  LDA battle_action_points                             ; $AAAD: AD 05 05
  CMP #$04                              ; $AAB0: C9 04
  BCC @TryAction4                       ; $AAB2: 90 0E
  RTS                                   ; $AAB4: 60
; --- Random roll 2: action 1, budget >= 5 ---
@RandomAction1:
  LDA #$01                              ; $AAB5: A9 01
  STA $002C                             ; $AAB7: 8D 2C 00
  LDA battle_action_points                             ; $AABA: AD 05 05
  CMP #$05                              ; $AABD: C9 05
  BCC @TryAction4                       ; $AABF: 90 01
  RTS                                   ; $AAC1: 60
; --- Action 4: tier >= 4, candidate has troops, budget >= 7 ---
@TryAction4:
  LDA $002A                             ; $AAC2: AD 2A 00
  CMP #$04                              ; $AAC5: C9 04
  BCC @TryAction0                       ; $AAC7: 90 14
  LDA $002D                             ; $AAC9: AD 2D 00
  BEQ @TryAction0                       ; $AACC: F0 0F
  LDA battle_action_points                             ; $AACE: AD 05 05
  CMP #$07                              ; $AAD1: C9 07
  BCC @TryAction0                       ; $AAD3: 90 08
  LDX #$04                              ; $AAD5: A2 04
  JSR AiCheckActionFeasible             ; $AAD7: 20 7B AC
  BCC @TryAction0                       ; $AADA: 90 01
  RTS                                   ; $AADC: 60
; --- Action 0: candidate has troops, budget >= 6 ---
@TryAction0:
  LDA $002D                             ; $AADD: AD 2D 00
  BEQ @NoAction                         ; $AAE0: F0 0F
  LDA battle_action_points                             ; $AAE2: AD 05 05
  CMP #$06                              ; $AAE5: C9 06
  BCC @NoAction                         ; $AAE7: 90 08
  LDX #$00                              ; $AAE9: A2 00
  JSR AiCheckActionFeasible             ; $AAEB: 20 7B AC
  BCC @NoAction                         ; $AAEE: 90 01
  RTS                                   ; $AAF0: 60
@NoAction:
  LDA #$03                              ; $AAF1: A9 03
  STA ai_action_result                             ; $AAF3: 8D 8F 6F  ; decision = nothing feasible
  CLC                                   ; $AAF6: 18
  RTS                                   ; $AAF7: 60
;===============================================================================
; AiCheckRecruit ($AAF8-$AC7A) - Try to recruit nearby officers for the
; current AI officer ($6F8C).
;
; Gates: self record field +2 (rating, $002A) >= $5C and the self record
; field +11 high nibble (rank, $0036) >= 3. Then scans the nearby-officer
; table (radius 5, sorted strongest first) and, for each candidate, tries
; recruit action codes $0A-$0F in order. Each attempt requires a class-table
; membership check (@CheckClassTable), optionally candidate troops
; (@CheckCandidateHasTroops), and a minimum AI action budget ($0505).
;
; Output: C=1 -> $6F8D = action code ($002C), $6F8E = target officer, $6F8F = 2
;         C=0 -> $6F8F = 3 (no valid recruit)
;===============================================================================
AiCheckRecruit:
  LDY ai_officer_idx                             ; $AAF8: AC 8C 6F  ; current AI officer
  LDA battle_roster,Y                           ; $AAFB: B9 64 06
  STA $002A                             ; $AAFE: 8D 2A 00  ; self rating
  JSR GetOfficerRecordPtr               ; $AB01: 20 91 B4
  LDY #$02                              ; $AB04: A0 02
  LDA ($20),Y                           ; $AB06: B1 20     ; record field +2
  CMP #$5C                              ; $AB08: C9 5C
  BCS @RankGate                         ; $AB0A: B0 02
  CLC                                   ; $AB0C: 18        ; rating too low
  RTS                                   ; $AB0D: 60
@RankGate:
  LDY #$0B                              ; $AB0E: A0 0B
  LDA ($20),Y                           ; $AB10: B1 20     ; record field +11
  LSR                                   ; $AB12: 4A
  LSR                                   ; $AB13: 4A
  LSR                                   ; $AB14: 4A
  LSR                                   ; $AB15: 4A        ; rank = high nibble
  STA $0036                             ; $AB16: 8D 36 00
  CMP #$03                              ; $AB19: C9 03
  BCS @ScanCandidates                   ; $AB1B: B0 02
  CLC                                   ; $AB1D: 18        ; rank too low
  RTS                                   ; $AB1E: 60
@ScanCandidates:
  LDY ai_officer_idx                             ; $AB1F: AC 8C 6F
  LDA #$05                              ; $AB22: A9 05     ; search radius 5
  JSR AiFindNearbyOfficers              ; $AB24: 20 D3 A8  ; fill $6FC9
  JSR AiSortNearbyOfficers              ; $AB27: 20 93 AE  ; enemy slots, strongest first
  LDY #$00                              ; $AB2A: A0 00
@TryCandidate:
  LDA proximity_table,Y                           ; $AB2C: B9 C9 6F  ; candidate officer slot
  CMP #$FF                              ; $AB2F: C9 FF
  BEQ @NoCandidate                      ; $AB31: F0 2E     ; end of list
  TAX                                   ; $AB33: AA
  LDA battle_roster,X                           ; $AB34: BD 64 06
  CMP #$FF                              ; $AB37: C9 FF
  BEQ @NextCandidate                    ; $AB39: F0 21     ; slot inactive
  STY $002F                             ; $AB3B: 8C 2F 00  ; save list index
  STX $002B                             ; $AB3E: 8E 2B 00  ; candidate for checks
  JSR @TryRecruitCandidate              ; $AB41: 20 68 AB
  BCC @Retry                            ; $AB44: 90 13
  LDA $002C                             ; $AB46: AD 2C 00  ; chosen recruit action
  STA ai_target_slot                             ; $AB49: 8D 8D 6F
  LDA $002B                             ; $AB4C: AD 2B 00
  STA ai_target_officer                             ; $AB4F: 8D 8E 6F  ; recruit target officer
  LDA #$02                              ; $AB52: A9 02
  STA ai_action_result                             ; $AB54: 8D 8F 6F  ; decision = act on target
  SEC                                   ; $AB57: 38
  RTS                                   ; $AB58: 60
@Retry:
  LDY $002F                             ; $AB59: AC 2F 00  ; restore list index
@NextCandidate:
  INY                                   ; $AB5C: C8
  CPY #$14                              ; $AB5D: C0 14     ; 20 officer slots max
  BCC @TryCandidate                     ; $AB5F: 90 CB
@NoCandidate:
  LDA #$03                              ; $AB61: A9 03
  STA ai_action_result                             ; $AB63: 8D 8F 6F  ; decision = nothing feasible
  CLC                                   ; $AB66: 18
  RTS                                   ; $AB67: 60
; ---------------------------------------------------------------------------
; @TryRecruitCandidate - attempt recruit actions $0A-$0F against $002B
; ---------------------------------------------------------------------------
@TryRecruitCandidate:
; --- Action $0A: rank >= 3 table match, candidate idle ($0650 low nibble 0),
; ---             budget >= 9 ---
  LDY #$00                              ; $AB68: A0 00     ; table offset
  LDA #$03                              ; $AB6A: A9 03
  STA $0022                             ; $AB6C: 8D 22 00  ; required rank
  JSR @CheckClassTable                  ; $AB6F: 20 31 AC
  BCC @TryRecruitB                      ; $AB72: 90 19
  LDX $002B                             ; $AB74: AE 2B 00
  LDA unit_immobilized,X                           ; $AB77: BD 50 06  ; candidate state
  AND #$0F                              ; $AB7A: 29 0F
  BNE @TryRecruitB                      ; $AB7C: D0 0F     ; must be idle (0)
  LDA battle_action_points                             ; $AB7E: AD 05 05
  CMP #$09                              ; $AB81: C9 09
  BCC @TryRecruitB                      ; $AB83: 90 08
  LDX #$0A                              ; $AB85: A2 0A
  JSR AiCheckActionFeasible             ; $AB87: 20 7B AC
  BCC @TryRecruitB                      ; $AB8A: 90 01
  RTS                                   ; $AB8C: 60
; --- Action $0B: rank >= 3 table match, budget >= $0A ---
@TryRecruitB:
  LDY #$00                              ; $AB8D: A0 00
  LDA #$03                              ; $AB8F: A9 03
  STA $0022                             ; $AB91: 8D 22 00
  JSR @CheckClassTable                  ; $AB94: 20 31 AC
  BCC @TryRecruitC                      ; $AB97: 90 0F
  LDA battle_action_points                             ; $AB99: AD 05 05
  CMP #$0A                              ; $AB9C: C9 0A
  BCC @TryRecruitC                      ; $AB9E: 90 08
  LDX #$0B                              ; $ABA0: A2 0B
  JSR AiCheckActionFeasible             ; $ABA2: 20 7B AC
  BCC @TryRecruitC                      ; $ABA5: 90 01
  RTS                                   ; $ABA7: 60
; --- Action $0C: rank >= 4 table match, candidate has troops, budget >= $0A ---
@TryRecruitC:
  LDY #$0B                              ; $ABA8: A0 0B     ; table offset
  LDA #$04                              ; $ABAA: A9 04
  STA $0022                             ; $ABAC: 8D 22 00
  JSR @CheckClassTable                  ; $ABAF: 20 31 AC
  BCC @TryRecruitD                      ; $ABB2: 90 14
  JSR @CheckCandidateHasTroops          ; $ABB4: 20 4D AC
  BCC @TryRecruitD                      ; $ABB7: 90 0F
  LDA battle_action_points                             ; $ABB9: AD 05 05
  CMP #$0A                              ; $ABBC: C9 0A
  BCC @TryRecruitD                      ; $ABBE: 90 08
  LDX #$0C                              ; $ABC0: A2 0C
  JSR AiCheckActionFeasible             ; $ABC2: 20 7B AC
  BCC @TryRecruitD                      ; $ABC5: 90 01
  RTS                                   ; $ABC7: 60
; --- Action $0D: rank >= 4 table match, candidate has troops, budget >= 8 ---
@TryRecruitD:
  LDY #$0B                              ; $ABC8: A0 0B
  LDA #$04                              ; $ABCA: A9 04
  STA $0022                             ; $ABCC: 8D 22 00
  JSR @CheckClassTable                  ; $ABCF: 20 31 AC
  BCC @TryRecruitE                      ; $ABD2: 90 14
  JSR @CheckCandidateHasTroops          ; $ABD4: 20 4D AC
  BCC @TryRecruitE                      ; $ABD7: 90 0F
  LDA battle_action_points                             ; $ABD9: AD 05 05
  CMP #$08                              ; $ABDC: C9 08
  BCC @TryRecruitE                      ; $ABDE: 90 08
  LDX #$0D                              ; $ABE0: A2 0D
  JSR AiCheckActionFeasible             ; $ABE2: 20 7B AC
  BCC @TryRecruitE                      ; $ABE5: 90 01
  RTS                                   ; $ABE7: 60
; --- Action $0E: rank >= 5 table match, candidate has troops, budget >= $0C ---
@TryRecruitE:
  LDY #$11                              ; $ABE8: A0 11     ; table offset
  LDA #$05                              ; $ABEA: A9 05
  STA $0022                             ; $ABEC: 8D 22 00
  JSR @CheckClassTable                  ; $ABEF: 20 31 AC
  BCC @TryRecruitF                      ; $ABF2: 90 14
  JSR @CheckCandidateHasTroops          ; $ABF4: 20 4D AC
  BCC @TryRecruitF                      ; $ABF7: 90 0F
  LDA battle_action_points                             ; $ABF9: AD 05 05
  CMP #$0C                              ; $ABFC: C9 0C
  BCC @TryRecruitF                      ; $ABFE: 90 08
  LDX #$0E                              ; $AC00: A2 0E
  JSR AiCheckActionFeasible             ; $AC02: 20 7B AC
  BCC @TryRecruitF                      ; $AC05: 90 01
  RTS                                   ; $AC07: 60
; --- Action $0F: self rating == $6D, rank >= 6, candidate state high nibble
; ---             clear, budget >= $0A ---
@TryRecruitF:
  LDA $002A                             ; $AC08: AD 2A 00
  CMP #$6D                              ; $AC0B: C9 6D
  BNE @RecruitFail                      ; $AC0D: D0 20
  LDA $0036                             ; $AC0F: AD 36 00
  CMP #$06                              ; $AC12: C9 06
  BCC @RecruitFail                      ; $AC14: 90 19
  LDX $002B                             ; $AC16: AE 2B 00
  LDA unit_immobilized,X                           ; $AC19: BD 50 06
  AND #$F0                              ; $AC1C: 29 F0
  BNE @RecruitFail                      ; $AC1E: D0 0F
  LDA battle_action_points                             ; $AC20: AD 05 05
  CMP #$0A                              ; $AC23: C9 0A
  BCC @RecruitFail                      ; $AC25: 90 08
  LDX #$0F                              ; $AC27: A2 0F
  JSR AiCheckActionFeasible             ; $AC29: 20 7B AC
  BCC @RecruitFail                      ; $AC2C: 90 01
  RTS                                   ; $AC2E: 60
@RecruitFail:
  CLC                                   ; $AC2F: 18
  RTS                                   ; $AC30: 60
; ---------------------------------------------------------------------------
; @CheckClassTable - requires rank $0036 >= required rank $0022, then scans
; AiRecruitClassTable from offset Y for the self rating $002A. $FF terminates.
; Returns C=1 if the rating is listed, C=0 otherwise.
; ---------------------------------------------------------------------------
@CheckClassTable:
  LDA $0036                             ; $AC31: AD 36 00
  CMP $0022                             ; $AC34: CD 22 00
  BCC @TableFail                        ; $AC37: 90 07
@TableNext:
  LDA AiRecruitClassTable,Y             ; $AC39: B9 65 AC
  CMP #$FF                              ; $AC3C: C9 FF
  BNE @TableCompare                     ; $AC3E: D0 02
@TableFail:
  CLC                                   ; $AC40: 18
  RTS                                   ; $AC41: 60
@TableCompare:
  CMP $002A                             ; $AC42: CD 2A 00
  BNE @TableAdvance                     ; $AC45: D0 02
  SEC                                   ; $AC47: 38        ; rating found
  RTS                                   ; $AC48: 60
@TableAdvance:
  INY                                   ; $AC49: C8
  JMP @TableNext                        ; $AC4A: 4C 39 AC
; ---------------------------------------------------------------------------
; @CheckCandidateHasTroops - C=1 if candidate officer's troop count (record
; fields +8/+9) is non-zero
; ---------------------------------------------------------------------------
@CheckCandidateHasTroops:
  LDY $002B                             ; $AC4D: AC 2B 00
  LDA battle_roster,Y                           ; $AC50: B9 64 06
  JSR GetOfficerRecordPtr               ; $AC53: 20 91 B4
  LDY #$09                              ; $AC56: A0 09
  LDA ($20),Y                           ; $AC58: B1 20     ; troop count high
  BNE @HasTroops                        ; $AC5A: D0 05
  DEY                                   ; $AC5C: 88
  LDA ($20),Y                           ; $AC5D: B1 20     ; troop count low
  BEQ @NoTroops                         ; $AC5F: F0 02
@HasTroops:
  SEC                                   ; $AC61: 38
  RTS                                   ; $AC62: 60
@NoTroops:
  CLC                                   ; $AC63: 18
  RTS                                   ; $AC64: 60
; Recruit class table: rating values eligible per rank group, $FF-terminated.
; Offsets: 0 = rank-3 group, $0B = rank-4 group, $11 = rank-5 group.
AiRecruitClassTable:
  .byte $A1,$63,$A7,$16,$C4,$DB,$EA,$6B,$CE,$EB,$B7,$18,$37,$70,$D5,$6E; $AC65: A1 63 A7 16 C4 DB EA 6B CE EB B7 18 37 70 D5 6E
  .byte $67,$C5,$56,$5D,$6D,$FF           ; $AC75: 67 C5 56 5D 6D FF
;===============================================================================
; AiCheckActionFeasible ($AC7B-$AE92) - Per-stratagem precondition check.
; Input:  X = stratagem code (0-$0F); $002B = target officer slot
; Output: C=1 if the stratagem is feasible for the current officer ($6F8C)
;
; Terrain codes: 0=woods, 2=plains, 3=water, 4=mountain, 5=castle.
; Computes the terrain under the target officer ($0028) and under the current
; officer ($0029) via the tile-terrain routine at $B6E5 (clamps values >= 6 to
; 2), then dispatches on the stratagem code through the inline .word table
; below to a small condition handler. Each handler returns C=1 / C=0.
;===============================================================================
AiCheckActionFeasible:
  STX $002C                             ; $AC7B: 8E 2C 00  ; save action code
  LDY $002B                             ; $AC7E: AC 2B 00  ; target officer slot
  LDA unit_coord_x,Y                           ; $AC81: B9 00 06  ; target map X
  STA $0020                             ; $AC84: 8D 20 00
  LDA unit_coord_y,Y                           ; $AC87: B9 14 06  ; target map Y
  STA $0021                             ; $AC8A: 8D 21 00
  JSR GetTileTerrainClamped             ; $AC8D: 20 E5 B6  ; terrain at target
  STA $0028                             ; $AC90: 8D 28 00
  LDY ai_officer_idx                             ; $AC93: AC 8C 6F  ; current officer
  LDA unit_coord_x,Y                           ; $AC96: B9 00 06  ; self map X
  STA $0020                             ; $AC99: 8D 20 00
  LDA unit_coord_y,Y                           ; $AC9C: B9 14 06  ; self map Y
  STA $0021                             ; $AC9F: 8D 21 00
  JSR GetTileTerrainClamped             ; $ACA2: 20 E5 B6  ; terrain at self
  STA $0029                             ; $ACA5: 8D 29 00
  LDA $002C                             ; $ACA8: AD 2C 00  ; action code -> A
  JSR CallbackDispatcher                 ; $ACAB: 20 17 B5
; --- Inline dispatch table: stratagem code (A) -> condition handler ---
  .word AiFeasible_FireAttack           ; $ACAE: CE AC      ; stratagem 0
  .word AiFeasible_Trap                 ; $ACB0: DB AC      ; stratagem 1
  .word AiFeasible_FeintTroops          ; $ACB2: DB AC      ; stratagem 2
  .word AiFeasible_AmbushStrike         ; $ACB4: DB AC      ; stratagem 3
  .word AiFeasible_MuddyWater           ; $ACB6: E8 AC      ; stratagem 4
  .word AiFeasible_FireArrows           ; $ACB8: F3 AC      ; stratagem 5
  .word AiFeasible_FeintCounter         ; $ACBA: 00 AD      ; stratagem 6
  .word AiFeasible_CoordinatedStrike    ; $ACBC: 22 AD      ; stratagem 7
  .word AiFeasible_WinOver              ; $ACBE: 45 AD      ; stratagem 8
  .word AiFeasible_FallingRocks         ; $ACC0: 65 AD      ; stratagem 9
  .word AiFeasible_ChainStratagem       ; $ACC2: 92 AD      ; stratagem 10
  .word AiFeasible_AmbushAllSides       ; $ACC4: CF AD      ; stratagem 11
  .word AiFeasible_WaterAttack          ; $ACC6: 92 AD      ; stratagem 12
  .word AiFeasible_RepeatingCrossbow    ; $ACC8: FE AD      ; stratagem 13
  .word AiFeasible_PillageFire          ; $ACCA: 20 AE      ; stratagem 14
  .word AiFeasible_QimenDunjia          ; $ACCC: 5D AE      ; stratagem 15
; FireAttack (火攻, stratagem 0): target terrain ($0028) must be 0 (woods)
;                                 or 2 (plains)
AiFeasible_FireAttack:
  LDA $0028                             ; $ACCE: AD 28 00
  BEQ @Feasible                         ; $ACD1: F0 06
  CMP #$02                              ; $ACD3: C9 02
  BEQ @Feasible                         ; $ACD5: F0 02
  CLC                                   ; $ACD7: 18
  RTS                                   ; $ACD8: 60
@Feasible:
  SEC                                   ; $ACD9: 38
  RTS                                   ; $ACDA: 60
; Trap (陷阱, stratagem 1) / FeintTroops (虚兵, stratagem 2) /
; AmbushStrike (要击, stratagem 3): target terrain ($0028) must be 0 (woods)
;                                   or 4 (mountain).
; Single shared handler body at $ACDB; FeintTroops and AmbushStrike are
; aliases so the dispatch table keeps semantic per-stratagem entries.
AiFeasible_Trap:
  LDA $0028                             ; $ACDB: AD 28 00
  BEQ @Feasible                         ; $ACDE: F0 06
  CMP #$04                              ; $ACE0: C9 04
  BEQ @Feasible                         ; $ACE2: F0 02
  CLC                                   ; $ACE4: 18
  RTS                                   ; $ACE5: 60
@Feasible:
  SEC                                   ; $ACE6: 38
  RTS                                   ; $ACE7: 60
AiFeasible_FeintTroops = AiFeasible_Trap
AiFeasible_AmbushStrike = AiFeasible_Trap
; MuddyWater (乱水, stratagem 4): target terrain ($0028) must be 3 (water)
AiFeasible_MuddyWater:
  LDA $0028                             ; $ACE8: AD 28 00
  CMP #$03                              ; $ACEB: C9 03
  BEQ @Feasible                         ; $ACED: F0 02
  CLC                                   ; $ACEF: 18
  RTS                                   ; $ACF0: 60
@Feasible:
  SEC                                   ; $ACF1: 38
  RTS                                   ; $ACF2: 60
; FireArrows (火箭, stratagem 5): target officer slot ($002B) must be a
;                                 faction base slot (0 or $0A)
AiFeasible_FireArrows:
  LDA $002B                             ; $ACF3: AD 2B 00
  BEQ @Feasible                         ; $ACF6: F0 06
  CMP #$0A                              ; $ACF8: C9 0A
  BEQ @Feasible                         ; $ACFA: F0 02
  CLC                                   ; $ACFC: 18
  RTS                                   ; $ACFD: 60
@Feasible:
  SEC                                   ; $ACFE: 38
  RTS                                   ; $ACFF: 60
; FeintCounter (伪击转杀, stratagem 6): target terrain must be 5 (castle)
;                                       and the current officer must be
;                                       adjacent to the target
AiFeasible_FeintCounter:
  LDA $0028                             ; $AD00: AD 28 00
  CMP #$05                              ; $AD03: C9 05
  BNE @Fail                             ; $AD05: D0 17
  LDY $002B                             ; $AD07: AC 2B 00
  JSR AiTurnProcess::AiScanAdjacentOfficers ; $AD0A: 20 37 A8
  LDY #$00                              ; $AD0D: A0 00
@ScanAdj:
  LDA adjacent_scan_results,Y                           ; $AD0F: B9 DD 6F
  AND #$7F                              ; $AD12: 29 7F
  CMP ai_officer_idx                             ; $AD14: CD 8C 6F
  BEQ @Feasible                         ; $AD17: F0 07     ; self is adjacent
  INY                                   ; $AD19: C8
  CPY #$04                              ; $AD1A: C0 04
  BCC @ScanAdj                          ; $AD1C: 90 F1
@Fail:
  CLC                                   ; $AD1E: 18
  RTS                                   ; $AD1F: 60
@Feasible:
  SEC                                   ; $AD20: 38
  RTS                                   ; $AD21: 60
; CoordinatedStrike (共杀, stratagem 7): target terrain must be 0 (woods)
;                                         or 4 (mountain) and an enemy
;                                         officer must be adjacent to the
;                                         target
AiFeasible_CoordinatedStrike:
  LDA $0028                             ; $AD22: AD 28 00
  BEQ @ScanAdj                          ; $AD25: F0 04
  CMP #$04                              ; $AD27: C9 04
  BNE @Fail                             ; $AD29: D0 16
@ScanAdj:
  LDY $002B                             ; $AD2B: AC 2B 00
  JSR AiTurnProcess::AiScanAdjacentOfficers ; $AD2E: 20 37 A8
  LDY #$00                              ; $AD31: A0 00
@CheckSlot:
  LDA adjacent_scan_results,Y                           ; $AD33: B9 DD 6F
  CMP #$FF                              ; $AD36: C9 FF
  BEQ @NextDir                          ; $AD38: F0 02     ; empty
  BMI @Feasible                         ; $AD3A: 30 07     ; bit7 = enemy
@NextDir:
  INY                                   ; $AD3C: C8
  CPY #$04                              ; $AD3D: C0 04
  BCC @CheckSlot                        ; $AD3F: 90 F2
@Fail:
  CLC                                   ; $AD41: 18
  RTS                                   ; $AD42: 60
@Feasible:
  SEC                                   ; $AD43: 38
  RTS                                   ; $AD44: 60
; WinOver (笼络, stratagem 8): target terrain must not be 5 (castle) and the
;                              target officer's record field +3 must be < $32
;                              (the == $64 check is rendered redundant)
AiFeasible_WinOver:
  LDA $0028                             ; $AD45: AD 28 00
  CMP #$05                              ; $AD48: C9 05
  BEQ @Fail                             ; $AD4A: F0 15
  LDY $002B                             ; $AD4C: AC 2B 00
  LDA battle_roster,Y                           ; $AD4F: B9 64 06
  JSR GetOfficerRecordPtr               ; $AD52: 20 91 B4
  LDY #$03                              ; $AD55: A0 03
  LDA ($20),Y                           ; $AD57: B1 20     ; record field +3
  CMP #$64                              ; $AD59: C9 64
  BEQ @Fail                             ; $AD5B: F0 04
  CMP #$32                              ; $AD5D: C9 32
  BCC @Feasible                         ; $AD5F: 90 02
@Fail:
  CLC                                   ; $AD61: 18
  RTS                                   ; $AD62: 60
@Feasible:
  SEC                                   ; $AD63: 38
  RTS                                   ; $AD64: 60
; FallingRocks (落石, stratagem 9): self terrain must be 4 (mountain) or
;                                   5 (castle), the target must be adjacent
;                                   to the current officer, and target terrain
;                                   must be 5 (castle)
AiFeasible_FallingRocks:
  LDA $0029                             ; $AD65: AD 29 00
  CMP #$04                              ; $AD68: C9 04
  BEQ @ScanAdj                          ; $AD6A: F0 04
  CMP #$05                              ; $AD6C: C9 05
  BNE @Fail                             ; $AD6E: D0 17
@ScanAdj:
  LDY ai_officer_idx                             ; $AD70: AC 8C 6F
  JSR AiTurnProcess::AiScanAdjacentOfficers ; $AD73: 20 37 A8
  LDY #$00                              ; $AD76: A0 00
@CheckSlot:
  LDA adjacent_scan_results,Y                           ; $AD78: B9 DD 6F
  AND #$7F                              ; $AD7B: 29 7F
  CMP $002B                             ; $AD7D: CD 2B 00
  BEQ @CheckTargetTerrain               ; $AD80: F0 07
  INY                                   ; $AD82: C8
  CPY #$04                              ; $AD83: C0 04
  BCC @CheckSlot                        ; $AD85: 90 F1
@Fail:
  CLC                                   ; $AD87: 18
  RTS                                   ; $AD88: 60
@CheckTargetTerrain:
  LDA $0028                             ; $AD89: AD 28 00
  CMP #$05                              ; $AD8C: C9 05
  BNE @Fail                             ; $AD8E: D0 F7
  SEC                                   ; $AD90: 38
  RTS                                   ; $AD91: 60
; ChainStratagem (连环, stratagem 10) / WaterAttack (水攻, stratagem 12):
;                                          target terrain must be 3 (water)
;                                          and an adjacent enemy officer must
;                                          stand on terrain 3.
; Single shared handler body at $AD92; WaterAttack is an alias so the
; dispatch table keeps semantic per-stratagem entries.
AiFeasible_ChainStratagem:
  LDA $0028                             ; $AD92: AD 28 00
  CMP #$03                              ; $AD95: C9 03
  BNE @Fail                             ; $AD97: D0 32
  LDY $002B                             ; $AD99: AC 2B 00
  JSR AiTurnProcess::AiScanAdjacentOfficers ; $AD9C: 20 37 A8
  LDY #$00                              ; $AD9F: A0 00
@CheckSlot:
  LDA adjacent_scan_results,Y                           ; $ADA1: B9 DD 6F
  BPL @NextDir                          ; $ADA4: 10 20     ; ally/empty -> skip
  CMP #$FF                              ; $ADA6: C9 FF
  BEQ @NextDir                          ; $ADA8: F0 1C
  STY $0027                             ; $ADAA: 8C 27 00  ; save direction index
  AND #$7F                              ; $ADAD: 29 7F
  TAY                                   ; $ADAF: A8
  LDA unit_coord_x,Y                           ; $ADB0: B9 00 06
  STA $0020                             ; $ADB3: 8D 20 00
  LDA unit_coord_y,Y                           ; $ADB6: B9 14 06
  STA $0021                             ; $ADB9: 8D 21 00
  JSR GetTileTerrainClamped             ; $ADBC: 20 E5 B6  ; terrain of adjacent officer
  CMP #$03                              ; $ADBF: C9 03
  BEQ @Feasible                         ; $ADC1: F0 0A
  LDY $0027                             ; $ADC3: AC 27 00
@NextDir:
  INY                                   ; $ADC6: C8
  CPY #$04                              ; $ADC7: C0 04
  BCC @CheckSlot                        ; $ADC9: 90 D6
@Fail:
  CLC                                   ; $ADCB: 18
  RTS                                   ; $ADCC: 60
@Feasible:
  SEC                                   ; $ADCD: 38
  RTS                                   ; $ADCE: 60
AiFeasible_WaterAttack = AiFeasible_ChainStratagem
; AmbushAllSides (十面埋伏, stratagem 11): self terrain must be 0 (woods),
;                                          the current officer's record field
;                                          +9 must be non-zero (or field +8
;                                          >= $64), and the faction's $04D8
;                                          slot entry must be empty ($FF)
AiFeasible_AmbushAllSides:
  LDA $0029                             ; $ADCF: AD 29 00
  BNE @Fail                             ; $ADD2: D0 26
  LDY ai_officer_idx                             ; $ADD4: AC 8C 6F
  LDA battle_roster,Y                           ; $ADD7: B9 64 06
  JSR GetOfficerRecordPtr               ; $ADDA: 20 91 B4
  LDY #$09                              ; $ADDD: A0 09
  LDA ($20),Y                           ; $ADDF: B1 20     ; record field +9
  BNE @CheckSlot                        ; $ADE1: D0 07
  DEY                                   ; $ADE3: 88
  LDA ($20),Y                           ; $ADE4: B1 20     ; record field +8
  CMP #$64                              ; $ADE6: C9 64
  BCC @Fail                             ; $ADE8: 90 10
@CheckSlot:
  LDY #$00                              ; $ADEA: A0 00
  LDA battle_side_flag                             ; $ADEC: AD 04 05  ; acting-side flag
  BPL @LoadSlot                         ; $ADEF: 10 02
  LDY #$04                              ; $ADF1: A0 04
@LoadSlot:
  LDA army_slot_base,Y                           ; $ADF3: B9 D8 04
  CMP #$FF                              ; $ADF6: C9 FF
  BEQ @Feasible                         ; $ADF8: F0 02
@Fail:
  CLC                                   ; $ADFA: 18
  RTS                                   ; $ADFB: 60
@Feasible:
  SEC                                   ; $ADFC: 38
  RTS                                   ; $ADFD: 60
; RepeatingCrossbow (连弩, stratagem 13): self terrain must be 5 (castle)
;                                         and the target must be adjacent to
;                                         the current officer (entries XOR $80
;                                         so enemy markers match bare slots)
AiFeasible_RepeatingCrossbow:
  LDY $0029                             ; $ADFE: AC 29 00
  CPY #$05                              ; $AE01: C0 05
  BNE @Fail                             ; $AE03: D0 17
  LDY ai_officer_idx                             ; $AE05: AC 8C 6F
  JSR AiTurnProcess::AiScanAdjacentOfficers ; $AE08: 20 37 A8
  LDY #$00                              ; $AE0B: A0 00
@CheckSlot:
  LDA adjacent_scan_results,Y                           ; $AE0D: B9 DD 6F
  EOR #$80                              ; $AE10: 49 80
  CMP $002B                             ; $AE12: CD 2B 00
  BEQ @Feasible                         ; $AE15: F0 07
  INY                                   ; $AE17: C8
  CPY #$04                              ; $AE18: C0 04
  BCC @CheckSlot                        ; $AE1A: 90 F1
@Fail:
  CLC                                   ; $AE1C: 18
  RTS                                   ; $AE1D: 60
@Feasible:
  SEC                                   ; $AE1E: 38
  RTS                                   ; $AE1F: 60
; PillageFire (劫火, stratagem 14): target terrain must not be 5 (castle)
;                                   and an adjacent enemy officer must NOT
;                                   stand on terrain 5 (feasible as soon as
;                                   one qualifies)
AiFeasible_PillageFire:
  LDY $0028                             ; $AE20: AC 28 00
  CPY #$05                              ; $AE23: C0 05
  BEQ @Fail                             ; $AE25: F0 32
  LDY $002B                             ; $AE27: AC 2B 00
  JSR AiTurnProcess::AiScanAdjacentOfficers ; $AE2A: 20 37 A8
  LDY #$00                              ; $AE2D: A0 00
@CheckSlot:
  LDA adjacent_scan_results,Y                           ; $AE2F: B9 DD 6F
  BPL @NextDir                          ; $AE32: 10 20     ; ally/empty -> skip
  CMP #$FF                              ; $AE34: C9 FF
  BEQ @NextDir                          ; $AE36: F0 1C
  STY $0027                             ; $AE38: 8C 27 00  ; save direction index
  AND #$7F                              ; $AE3B: 29 7F
  TAY                                   ; $AE3D: A8
  LDA unit_coord_x,Y                           ; $AE3E: B9 00 06
  STA $0020                             ; $AE41: 8D 20 00
  LDA unit_coord_y,Y                           ; $AE44: B9 14 06
  STA $0021                             ; $AE47: 8D 21 00
  JSR GetTileTerrainClamped             ; $AE4A: 20 E5 B6  ; terrain of adjacent officer
  CMP #$05                              ; $AE4D: C9 05
  BNE @Feasible                         ; $AE4F: D0 0A     ; not on terrain 5 -> ok
  LDY $0027                             ; $AE51: AC 27 00
@NextDir:
  INY                                   ; $AE54: C8
  CPY #$04                              ; $AE55: C0 04
  BCC @CheckSlot                        ; $AE57: 90 D6
@Fail:
  CLC                                   ; $AE59: 18
  RTS                                   ; $AE5A: 60
@Feasible:
  SEC                                   ; $AE5B: 38
  RTS                                   ; $AE5C: 60
; QimenDunjia (奇门遁甲, stratagem 15): target terrain must not be 5 (castle)
;                                       (the == 3 branch is a redundant jump
;                                       back to fall-through); otherwise the
;                                       target officer's record must satisfy:
;                                       field +1 >= $55 or field +2 >= $55,
;                                       field +9 >= 2, and field +8 >= $BC
AiFeasible_QimenDunjia:
  LDY $0028                             ; $AE5D: AC 28 00
  CPY #$03                              ; $AE60: C0 03
  BEQ @StatCheck                        ; $AE62: F0 04
  CPY #$05                              ; $AE64: C0 05
  BEQ @Fail                             ; $AE66: F0 27
@StatCheck:
  LDY $002B                             ; $AE68: AC 2B 00
  LDA battle_roster,Y                           ; $AE6B: B9 64 06
  JSR GetOfficerRecordPtr               ; $AE6E: 20 91 B4
  LDY #$01                              ; $AE71: A0 01
  LDA ($20),Y                           ; $AE73: B1 20     ; record field +1
  CMP #$55                              ; $AE75: C9 55
  BCS @CheckField9                      ; $AE77: B0 07
  INY                                   ; $AE79: C8
  LDA ($20),Y                           ; $AE7A: B1 20     ; record field +2
  CMP #$55                              ; $AE7C: C9 55
  BCC @Fail                             ; $AE7E: 90 0F
@CheckField9:
  LDY #$09                              ; $AE80: A0 09
  LDA ($20),Y                           ; $AE82: B1 20     ; record field +9
  CMP #$02                              ; $AE84: C9 02
  BCC @Fail                             ; $AE86: 90 07
  DEY                                   ; $AE88: 88
  LDA ($20),Y                           ; $AE89: B1 20     ; record field +8
  CMP #$BC                              ; $AE8B: C9 BC
  BCS @Feasible                         ; $AE8D: B0 02
@Fail:
  CLC                                   ; $AE8F: 18
  RTS                                   ; $AE90: 60
@Feasible:
  SEC                                   ; $AE91: 38
  RTS                                   ; $AE92: 60
;===============================================================================
; AiSortNearbyOfficers ($AE93-$AF0C) - Compact and sort the nearby-officer
; table produced by AiFindNearbyOfficers.
;
; Phase 1: scans the 20 $6FC9 entries, clears them to $FF, and compacts the
;          slot indices of enemy officers (bit7 set in the original entry)
;          into $6FC9[0..X-1]. The remaining entries stay $FF (terminator).
;          Fewer than 2 enemies -> return without sorting.
; Phase 2: bubble-sorts the compacted slot list by the officers' 16-bit troop
;          counts (record fields +8/+9), strongest first.
; Note: the outer pass counter reuses $002F (clobbered; callers save/restore
;       it around this call).
;===============================================================================
AiSortNearbyOfficers:
  LDX #$00                              ; $AE93: A2 00     ; compacted count
  LDY #$00                              ; $AE95: A0 00
@FilterLoop:
  LDA proximity_table,Y                           ; $AE97: B9 C9 6F  ; entry: bit7|distance
  STA $0020                             ; $AE9A: 8D 20 00
  LDA #$FF                              ; $AE9D: A9 FF
  STA proximity_table,Y                           ; $AE9F: 99 C9 6F  ; clear entry
  LDA $0020                             ; $AEA2: AD 20 00
  BPL @FilterNext                       ; $AEA5: 10 05     ; ally/empty -> skip
  TYA                                   ; $AEA7: 98
  STA proximity_table,X                           ; $AEA8: 9D C9 6F  ; keep enemy slot index
  INX                                   ; $AEAB: E8
@FilterNext:
  INY                                   ; $AEAC: C8
  CPY #$14                              ; $AEAD: C0 14     ; 20 officer slots
  BCC @FilterLoop                       ; $AEAF: 90 E6
  CPX #$02                              ; $AEB1: E0 02
  BCS @SortInit                         ; $AEB3: B0 01
  RTS                                   ; $AEB5: 60        ; <2 enemies: nothing to sort
@SortInit:
  DEX                                   ; $AEB6: CA
  STX $0024                             ; $AEB7: 8E 24 00  ; inner loop bound = count-1
@SortPass:
  LDX #$00                              ; $AEBA: A2 00
@ComparePair:
  LDA proximity_table,X                           ; $AEBC: BD C9 6F  ; slot of element X
  TAY                                   ; $AEBF: A8
  LDA battle_roster,Y                           ; $AEC0: B9 64 06
  JSR GetOfficerRecordPtr               ; $AEC3: 20 91 B4
  LDY #$08                              ; $AEC6: A0 08
  LDA ($20),Y                           ; $AEC8: B1 20     ; troop count low
  STA $0022                             ; $AECA: 8D 22 00
  INY                                   ; $AECD: C8
  LDA ($20),Y                           ; $AECE: B1 20     ; troop count high
  STA $0023                             ; $AED0: 8D 23 00
  LDA proximity_table+1,X                           ; $AED3: BD CA 6F  ; slot of element X+1
  TAY                                   ; $AED6: A8
  LDA battle_roster,Y                           ; $AED7: B9 64 06
  JSR GetOfficerRecordPtr               ; $AEDA: 20 91 B4
  LDY #$09                              ; $AEDD: A0 09
  LDA ($20),Y                           ; $AEDF: B1 20     ; next troop count high
  CMP $0023                             ; $AEE1: CD 23 00
  BCC @NoSwap                           ; $AEE4: 90 18     ; next < current: keep order
  BNE @Swap                             ; $AEE6: D0 08     ; next > current: swap
  DEY                                   ; $AEE8: 88
  LDA ($20),Y                           ; $AEE9: B1 20     ; next troop count low
  CMP $0022                             ; $AEEB: CD 22 00
  BCC @NoSwap                           ; $AEEE: 90 0E
@Swap:
  LDA proximity_table,X                           ; $AEF0: BD C9 6F
  TAY                                   ; $AEF3: A8
  LDA proximity_table+1,X                           ; $AEF4: BD CA 6F
  STA proximity_table,X                           ; $AEF7: 9D C9 6F
  TYA                                   ; $AEFA: 98
  STA proximity_table+1,X                           ; $AEFB: 9D CA 6F
@NoSwap:
  INX                                   ; $AEFE: E8
  CPX $0024                             ; $AEFF: EC 24 00
  BCC @ComparePair                      ; $AF02: 90 B8
  DEC $002F                             ; $AF04: CE 2F 00  ; outer pass counter
  LDA $002F                             ; $AF07: AD 2F 00
  BPL @SortPass                         ; $AF0A: 10 AE
  RTS                                   ; $AF0C: 60
;===============================================================================
; AiCheckFlee ($AF0D-$B066) - Decide whether the current AI officer ($6F8C)
; should retreat and pick a retreat destination.
;
; The owning side's province id is derived from $0507 (low nibble when the
; player side acts, high nibble when the AI side acts, selected via $0504
; bit7). That province record's first byte becomes the officer's home value,
; which drives three threshold paths:
;   - officer home == capital value      -> strict thresholds ($012D, min $33)
;   - officer slot 0 or $0A              -> army-strength comparison path
;   - anything else                      -> relaxed thresholds ($C9, min $64)
;                                            plus a random gate (< $46 passes)
; The strength gate (@CheckStrength) requires the officer's record field +8
; (troop low byte) to be at or below the threshold; when it passes, the home
; province value must also be >= the record threshold, and the candidate
; province must have a record byte +0 >= $0024.
;
; Output: C=1 -> $6F8D = destination province id, $6F8F = 4 (flee)
;         C=0 -> no retreat
;===============================================================================
AiCheckFlee:
  LDA battle_faction_pair                             ; $AF0D: AD 07 05  ; side/province packed byte
  LDX battle_side_flag                             ; $AF10: AE 04 05  ; acting-side flag
  BPL @MaskProvince                     ; $AF13: 10 04     ; player side: low nibble
  LSR                                   ; $AF15: 4A
  LSR                                   ; $AF16: 4A
  LSR                                   ; $AF17: 4A
  LSR                                   ; $AF18: 4A        ; AI side: high nibble
@MaskProvince:
  AND #$0F                              ; $AF19: 29 0F
  JSR GetFactionRecordPtr               ; $AF1B: 20 C2 B4  ; ($20) = faction record
  LDY #$00                              ; $AF1E: A0 00
  LDA ($20),Y                           ; $AF20: B1 20     ; province record byte 0
  STA $0022                             ; $AF22: 8D 22 00  ; home value
  LDY ai_officer_idx                             ; $AF25: AC 8C 6F
  LDA battle_roster,Y                           ; $AF28: B9 64 06  ; officer home value
  CMP $0022                             ; $AF2B: CD 22 00
  BNE @NotCapital                       ; $AF2E: D0 03
  JMP @CapitalPath                      ; $AF30: 4C AA AF  ; at capital -> strict path
@NotCapital:
  CPY #$00                              ; $AF33: C0 00
  BEQ @ArmyPath                         ; $AF35: F0 07     ; slot 0 (faction A leader)
  CPY #$0A                              ; $AF37: C0 0A
  BEQ @ArmyPath                         ; $AF39: F0 03     ; slot $0A (faction B leader)
  JMP @FieldPath                        ; $AF3B: 4C 88 AF  ; ordinary officer path
; --- Army-strength path: compare AI total army against enemy total ---
@ArmyPath:
  JSR AiComputeArmyStats                ; $AF3E: 20 67 B0
  LDA $002A                             ; $AF41: AD 2A 00  ; ally army low
  SEC                                   ; $AF44: 38
  SBC #$DD                              ; $AF45: E9 DD
  LDA $002B                             ; $AF47: AD 2B 00  ; ally army high
  SBC #$06                              ; $AF4A: E9 06      ; compare with $06DD
  BCS @ArmyThresholds                   ; $AF4C: B0 23     ; army large enough
  LDA $002A                             ; $AF4E: AD 2A 00
  CLC                                   ; $AF51: 18
  ADC #$AB                              ; $AF52: 69 AB
  STA $002A                             ; $AF54: 8D 2A 00  ; ally army + $0DAB
  LDA $002B                             ; $AF57: AD 2B 00
  ADC #$0D                              ; $AF5A: 69 0D
  STA $002B                             ; $AF5C: 8D 2B 00
  LDA $002A                             ; $AF5F: AD 2A 00
  SEC                                   ; $AF62: 38
  SBC $002C                             ; $AF63: ED 2C 00  ; vs enemy army low
  LDA $002B                             ; $AF66: AD 2B 00
  SBC $002D                             ; $AF69: ED 2D 00  ; vs enemy army high
  BCS @ArmyThresholds                   ; $AF6C: B0 03     ; still competitive
  JMP @ChooseDest                       ; $AF6E: 4C BE AF  ; badly outnumbered -> flee
@ArmyThresholds:
  LDA #$65                              ; $AF71: A9 65
  STA $0022                             ; $AF73: 8D 22 00  ; max strength threshold 101
  LDA #$00                              ; $AF76: A9 00
  STA $0023                             ; $AF78: 8D 23 00
  LDA #$29                              ; $AF7B: A9 29
  STA $0024                             ; $AF7D: 8D 24 00  ; province record minimum 41
  JSR @CheckStrength                    ; $AF80: 20 D4 AF
  BCS @NoFlee                           ; $AF83: B0 4D     ; too strong to flee
  JMP @ChooseDest                       ; $AF85: 4C BE AF
; --- Ordinary-officer path: relaxed thresholds plus a random gate ---
@FieldPath:
  LDA #$C9                              ; $AF88: A9 C9
  STA $0022                             ; $AF8A: 8D 22 00  ; max strength threshold 201
  LDA #$00                              ; $AF8D: A9 00
  STA $0023                             ; $AF8F: 8D 23 00
  LDA #$64                              ; $AF92: A9 64
  STA $0024                             ; $AF94: 8D 24 00  ; province record minimum 100
  JSR @CheckStrength                    ; $AF97: 20 D4 AF
  BCS @NoFlee                           ; $AF9A: B0 36     ; too strong to flee
@RandomGate:
  JSR NextRandomByte                    ; $AF9C: 20 D5 B5
  CMP #$64                              ; $AF9F: C9 64
  BCS @RandomGate                       ; $AFA1: B0 F9     ; reroll until < 100
  CMP #$46                              ; $AFA3: C9 46
  BCS @NoFlee                           ; $AFA5: B0 2B     ; >= 70: stay
  JMP @ChooseDest                       ; $AFA7: 4C BE AF
; --- Capital path: strictest thresholds ---
@CapitalPath:
  LDA #$2D                              ; $AFAA: A9 2D
  STA $0022                             ; $AFAC: 8D 22 00  ; max strength threshold 45
  LDA #$01                              ; $AFAF: A9 01
  STA $0023                             ; $AFB1: 8D 23 00
  LDA #$33                              ; $AFB4: A9 33
  STA $0024                             ; $AFB6: 8D 24 00  ; province record minimum 51
  JSR @CheckStrength                    ; $AFB9: 20 D4 AF
  BCS @NoFlee                           ; $AFBC: B0 14     ; too strong to flee
; ---------------------------------------------------------------------------
; @ChooseDest - pick the retreat destination province for $6F8D
; ---------------------------------------------------------------------------
@ChooseDest:
  LDA #$FF                              ; $AFBE: A9 FF
  STA ai_target_slot                             ; $AFC0: 8D 8D 6F  ; no destination yet
  JSR @FindDest                         ; $AFC3: 20 F6 AF
  LDA ai_target_slot                             ; $AFC6: AD 8D 6F
  BMI @NoFlee                           ; $AFC9: 30 07     ; none found
  LDA #$04                              ; $AFCB: A9 04
  STA ai_action_result                             ; $AFCD: 8D 8F 6F  ; decision = flee
  SEC                                   ; $AFD0: 38
  RTS                                   ; $AFD1: 60
@NoFlee:
  CLC                                   ; $AFD2: 18
  RTS                                   ; $AFD3: 60
; ---------------------------------------------------------------------------
; @CheckStrength - C=1 when the officer's troop low byte (record field +8)
; exceeds the ($0022,$0023) threshold, i.e. NOT weak enough to flee; when
; weak, additionally requires the home province value >= $0024.
; ---------------------------------------------------------------------------
@CheckStrength:
  LDY ai_officer_idx                             ; $AFD4: AC 8C 6F
  LDA battle_roster,Y                           ; $AFD7: B9 64 06
  JSR GetOfficerRecordPtr               ; $AFDA: 20 91 B4
  LDY #$08                              ; $AFDD: A0 08
  LDA ($20),Y                           ; $AFDF: B1 20     ; troop count low
  SEC                                   ; $AFE1: 38
  SBC $0022                             ; $AFE2: ED 22 00
  LDY #$09                              ; $AFE5: A0 09
  LDA ($20),Y                           ; $AFE7: B1 20     ; troop count high
  SBC $0023                             ; $AFE9: ED 23 00
  BCS @TooStrong                        ; $AFEC: B0 07     ; troops > threshold
  LDY #$00                              ; $AFEE: A0 00
  LDA ($20),Y                           ; $AFF0: B1 20     ; record byte 0 (home value)
  CMP $0024                             ; $AFF2: CD 24 00  ; C=1 if >= required minimum
@TooStrong:
  RTS                                   ; $AFF5: 60
; ---------------------------------------------------------------------------
; @FindDest - choose a retreat province id into $6F8D. For the AI side uses
; the preset destination $052A; for the player side scans the 8 candidate
; provinces of the current turn's group (table $9D72) for one owned by the
; acting faction with no stationed officers.
; ---------------------------------------------------------------------------
@FindDest:
  LDA battle_side_flag                             ; $AFF6: AD 04 05  ; acting-side flag
  BPL @ScanCandidates                   ; $AFF9: 10 07
  LDA battle_target_province                             ; $AFFB: AD 2A 05  ; AI preset retreat target
  STA ai_target_slot                             ; $AFFE: 8D 8D 6F
  RTS                                   ; $B001: 60
@ScanCandidates:
  LDA battle_faction_pair                             ; $B002: AD 07 05
  AND #$0F                              ; $B005: 29 0F     ; acting faction id
  STA $0022                             ; $B007: 8D 22 00
  LDY #$30                              ; $B00A: A0 30
  JSR B1F_SwitchBank8_A                             ; $B00C: 20 66 F2  ; SwitchBank8_A: bank $30
  LDA battle_province_idx                             ; $B00F: AD 0E 05  ; turn/phase index
  ASL                                   ; $B012: 0A
  ASL                                   ; $B013: 0A
  ASL                                   ; $B014: 0A        ; *8
  TAY                                   ; $B015: A8        ; group offset into $9D72
  LDX #$00                              ; $B016: A2 00
  LDA #$FF                              ; $B018: A9 FF
  STA $0025                             ; $B01A: 8D 25 00  ; best candidate = none
@CandidateLoop:
  LDA $9D72,Y                           ; $B01D: B9 72 9D  ; candidate province id
  BMI @Advance                          ; $B020: 30 31     ; $FF/negative: Y still index
  STA $0023                             ; $B022: 8D 23 00
  STY $0024                             ; $B025: 8C 24 00  ; save table index
  JSR GetProvinceRuntimePtr             ; $B028: 20 69 B4  ; ($20) = $6000 + id*32
  LDY #$00                              ; $B02B: A0 00
  LDA ($20),Y                           ; $B02D: B1 20     ; province record byte 0
  AND #$07                              ; $B02F: 29 07     ; owner field
  CMP #$07                              ; $B031: C9 07
  BNE @CheckOwned                       ; $B033: D0 09     ; not ownerless
  LDA $0023                             ; $B035: AD 23 00
  STA $0025                             ; $B038: 8D 25 00  ; ownerless fallback candidate
  JMP @NextCandidate                    ; $B03B: 4C 50 B0
@CheckOwned:
  CMP $0022                             ; $B03E: CD 22 00  ; owned by acting faction?
  BNE @NextCandidate                    ; $B041: D0 0D
  LDY #$11                              ; $B043: A0 11
@CheckOfficers:
  LDA ($20),Y                           ; $B045: B1 20     ; stationed officer slots
  CMP #$FF                              ; $B047: C9 FF
  BEQ @FoundDest                        ; $B049: F0 15     ; empty slot -> no garrison
  INY                                   ; $B04B: C8
  CPY #$1B                              ; $B04C: C0 1B     ; slots $11-$1A
  BCC @CheckOfficers                    ; $B04E: 90 F5
@NextCandidate:
  LDY $0024                             ; $B050: AC 24 00  ; restore table index
@Advance:
  INY                                   ; $B053: C8
  INX                                   ; $B054: E8
  CPX #$08                              ; $B055: E0 08     ; 8 candidates per group
  BCC @CandidateLoop                    ; $B057: 90 C4
  LDA $0025                             ; $B059: AD 25 00  ; fallback (or $FF)
  STA ai_target_slot                             ; $B05C: 8D 8D 6F
  RTS                                   ; $B05F: 60
@FoundDest:
  LDA $0023                             ; $B060: AD 23 00
  STA ai_target_slot                             ; $B063: 8D 8D 6F  ; owned, ungarrisoned province
  RTS                                   ; $B066: 60
;===============================================================================
; AiComputeArmyStats ($B067-$B0B7) - Sum 16-bit troop counts (officer record
; fields +8/+9) of all 20 active officers, split by faction relative to the
; acting side (AiCheckFaction).
; Output: ($002A,$002B) = ally total (low,high)
;         ($002C,$002D) = enemy total (low,high)
;===============================================================================
AiComputeArmyStats:
  LDY #$00                              ; $B067: A0 00
  STY $002A                             ; $B069: 8C 2A 00  ; ally total low
  STY $002B                             ; $B06C: 8C 2B 00  ; ally total high
  STY $002C                             ; $B06F: 8C 2C 00  ; enemy total low
  STY $002D                             ; $B072: 8C 2D 00  ; enemy total high
@OfficerLoop:
  LDA battle_roster,Y                           ; $B075: B9 64 06  ; officer home value
  CMP #$FF                              ; $B078: C9 FF
  BEQ @NextOfficer                      ; $B07A: F0 36     ; inactive slot
  STA $0022                             ; $B07C: 8D 22 00
  TYA                                   ; $B07F: 98
  PHA                                   ; $B080: 48        ; save slot index
  LDA $0022                             ; $B081: AD 22 00
  JSR GetOfficerRecordPtr               ; $B084: 20 91 B4
  LDY #$08                              ; $B087: A0 08
  LDA ($20),Y                           ; $B089: B1 20     ; troop count low
  STA $0022                             ; $B08B: 8D 22 00
  INY                                   ; $B08E: C8
  LDA ($20),Y                           ; $B08F: B1 20     ; troop count high
  STA $0023                             ; $B091: 8D 23 00
  PLA                                   ; $B094: 68
  TAY                                   ; $B095: A8        ; restore slot index
  LDX #$00                              ; $B096: A2 00     ; ally accumulator offset
  JSR AiCheckFaction                    ; $B098: 20 44 A9  ; N=1 if enemy
  BPL @AddToTotal                       ; $B09B: 10 02
  LDX #$02                              ; $B09D: A2 02     ; enemy accumulator offset
@AddToTotal:
  LDA $002A,X                           ; $B09F: BD 2A 00
  CLC                                   ; $B0A2: 18
  ADC $0022                             ; $B0A3: 6D 22 00
  STA $002A,X                           ; $B0A6: 9D 2A 00
  LDA $002B,X                           ; $B0A9: BD 2B 00
  ADC $0023                             ; $B0AC: 6D 23 00
  STA $002B,X                           ; $B0AF: 9D 2B 00
@NextOfficer:
  INY                                   ; $B0B2: C8
  CPY #$14                              ; $B0B3: C0 14     ; 20 officer slots
  BCC @OfficerLoop                      ; $B0B5: 90 BE
  RTS                                   ; $B0B7: 60
;===============================================================================
; AiComputeBattleStats ($B0B8-$B12F) - Time-scale the faction army totals.
;
; $002E = $1E - $0506 (days remaining in the 30-day month). Each faction's
; 16-bit total is scaled via @ScaleTotal: total * 4 / 1000 * days_remaining
; (Mul24x8 + Div24Bit). Result overwrites the totals from AiComputeArmyStats:
; Output: ($002A,$002B) = scaled ally total, ($002C,$002D) = scaled enemy total
;===============================================================================
AiComputeBattleStats:
  LDA #$1E                              ; $B0B8: A9 1E
  SEC                                   ; $B0BA: 38
  SBC battle_round_counter                             ; $B0BB: ED 06 05  ; day of month
  STA $002E                             ; $B0BE: 8D 2E 00  ; days remaining
  JSR AiComputeArmyStats                ; $B0C1: 20 67 B0
  LDA $002A                             ; $B0C4: AD 2A 00  ; ally total low
  STA $0020                             ; $B0C7: 8D 20 00
  LDA $002B                             ; $B0CA: AD 2B 00  ; ally total high
  STA $0021                             ; $B0CD: 8D 21 00
  JSR @ScaleTotal                       ; $B0D0: 20 FB B0
  LDA $0026                             ; $B0D3: AD 26 00  ; scaled low
  STA $002A                             ; $B0D6: 8D 2A 00
  LDA $0027                             ; $B0D9: AD 27 00  ; scaled high
  STA $002B                             ; $B0DC: 8D 2B 00
  LDA $002C                             ; $B0DF: AD 2C 00  ; enemy total low
  STA $0020                             ; $B0E2: 8D 20 00
  LDA $002D                             ; $B0E5: AD 2D 00  ; enemy total high
  STA $0021                             ; $B0E8: 8D 21 00
  JSR @ScaleTotal                       ; $B0EB: 20 FB B0
  LDA $0026                             ; $B0EE: AD 26 00
  STA $002C                             ; $B0F1: 8D 2C 00
  LDA $0027                             ; $B0F4: AD 27 00
  STA $002D                             ; $B0F7: 8D 2D 00
  RTS                                   ; $B0FA: 60
; ---------------------------------------------------------------------------
; @ScaleTotal - ($20,$21) * 4 / 1000 * $002E -> 24-bit result in ($26,$27,...)
; Mul24x8 destroys $23; Div24Bit leaves quotient in ($20,$21,$22).
; ---------------------------------------------------------------------------
@ScaleTotal:
  LDA #$00                              ; $B0FB: A9 00
  STA $0022                             ; $B0FD: 8D 22 00  ; 24-bit value high
  LDA #$04                              ; $B100: A9 04
  STA $0023                             ; $B102: 8D 23 00  ; multiplier = 4
  JSR Mul24x8                           ; $B105: 20 85 B5  ; ($26,$27,$28) = total*4
  LDA $0026                             ; $B108: AD 26 00
  STA $0020                             ; $B10B: 8D 20 00
  LDA $0027                             ; $B10E: AD 27 00
  STA $0021                             ; $B111: 8D 21 00
  LDA $0028                             ; $B114: AD 28 00
  STA $0022                             ; $B117: 8D 22 00  ; dividend = total*4
  LDA #$E8                              ; $B11A: A9 E8
  STA $0023                             ; $B11C: 8D 23 00
  LDA #$03                              ; $B11F: A9 03
  STA $0024                             ; $B121: 8D 24 00  ; divisor = $03E8 (1000)
  JSR Div24Bit                          ; $B124: 20 36 B5  ; quotient = total*4/1000
  LDA $002E                             ; $B127: AD 2E 00
  STA $0023                             ; $B12A: 8D 23 00  ; multiplier = days remaining
  JMP Mul24x8                           ; $B12D: 4C 85 B5  ; * days -> ($26,$27,$28)
.endproc
;===============================================================================
; BattleSetup - ($A003 dispatch callback) prepare a battle between two factions
; Clears the officer state table ($6FA1, $40 bytes) and the proximity table
; ($6FC9, $14 bytes). $0507 packs the two faction IDs: low nibble = side 0
; (defender), high nibble = side 1 (attacker). For each faction whose record
; byte 3 equals $03 (at war), builds the deployment roster
; (@CountAndSortUnits) and the unit placement order (@DeploySideUnits).
; Ends by resetting the army slots ($04D8) and the per-turn counters.
;===============================================================================
.proc BattleSetup
; --- Proc-local RAM ---
formation_slot_idx     = $6F9A  ; formation slot index nibbles (stride 2)
  LDY #$00                              ; $B130: A0 00
  LDA #$FF                              ; $B132: A9 FF
@ClearOfficerStates:
  STA officer_state_table,Y                           ; $B134: 99 A1 6F  ; officer state table
  INY                                   ; $B137: C8
  CPY #$40                              ; $B138: C0 40
  BCC @ClearOfficerStates               ; $B13A: 90 F8
  LDY #$00                              ; $B13C: A0 00
  LDA #$00                              ; $B13E: A9 00
@ClearProximityTable:
  STA proximity_table,Y                           ; $B140: 99 C9 6F  ; proximity scan table
  INY                                   ; $B143: C8
  CPY #$14                              ; $B144: C0 14
  BCC @ClearProximityTable              ; $B146: 90 F8
  LDA battle_faction_pair                             ; $B148: AD 07 05  ; battle faction pair
  AND #$0F                              ; $B14B: 29 0F     ; side 0 faction id
  STA $0022                             ; $B14D: 8D 22 00
  JSR GetFactionRecordPtr               ; $B150: 20 C2 B4  ; ($20) = faction record
  LDY #$03                              ; $B153: A0 03
  LDA ($20),Y                           ; $B155: B1 20     ; war status byte
  CMP #$03                              ; $B157: C9 03     ; 3 = in battle
  BNE @CheckAttacker                    ; $B159: D0 13
  LDA #$00                              ; $B15B: A9 00
  STA side_unit_base                             ; $B15D: 8D 91 6F  ; side 0 unit index base
  STA officer_state_table                             ; $B160: 8D A1 6F  ; first queue entry = 0
  JSR @CountAndSortUnits                ; $B163: 20 71 B3
  LDA #$00                              ; $B166: A9 00
  STA $0020                             ; $B168: 8D 20 00  ; side 0 placement base
  JSR @DeploySideUnits                  ; $B16B: 20 B0 B1
@CheckAttacker:
  LDA battle_faction_pair                             ; $B16E: AD 07 05
  LSR                                   ; $B171: 4A
  LSR                                   ; $B172: 4A
  LSR                                   ; $B173: 4A
  LSR                                   ; $B174: 4A        ; side 1 faction id
  STA $0022                             ; $B175: 8D 22 00
  JSR GetFactionRecordPtr               ; $B178: 20 C2 B4
  LDY #$03                              ; $B17B: A0 03
  LDA ($20),Y                           ; $B17D: B1 20
  CMP #$03                              ; $B17F: C9 03
  BNE @ClearArmySlots                   ; $B181: D0 15
  LDA #$0A                              ; $B183: A9 0A
  STA side_unit_base                             ; $B185: 8D 91 6F  ; side 1 unit index base (10)
  LDA #$00                              ; $B188: A9 00
  STA officer_state_table+$0A                             ; $B18A: 8D AB 6F  ; first queue entry = 0
  JSR @CountAndSortUnits                ; $B18D: 20 71 B3
  LDA #$36                              ; $B190: A9 36
  STA $0020                             ; $B192: 8D 20 00  ; side 1 placement base
  JSR @DeploySideUnits                  ; $B195: 20 B0 B1
@ClearArmySlots:
  LDY #$00                              ; $B198: A0 00
  LDA #$FF                              ; $B19A: A9 FF
@FillArmySlots:
  STA army_slot_base,Y                           ; $B19C: 99 D8 04  ; army_slot_base
  INY                                   ; $B19F: C8
  CPY #$08                              ; $B1A0: C0 08
  BCC @FillArmySlots                    ; $B1A2: 90 F8
  LDA #$00                              ; $B1A4: A9 00
  STA officer_scan_idx                             ; $B1A6: 8D 94 6F  ; officer scan index
  STA acted_officer_cnt                             ; $B1A9: 8D 95 6F  ; acted officer count
  STA valid_officer_cnt                             ; $B1AC: 8D 96 6F  ; valid officer count
  RTS                                   ; $B1AF: 60
;-------------------------------------------------------------------------------
; @DeploySideUnits - build unit placement order and coordinates for one side
; Input: $0022 = faction id, $0020 = side placement base (0 or $36),
;        $6F91 = side unit index base (0 or 10), $6F94 = unit count - 1.
; Faction id selects a formation row offset ({1,5} = $12, {2,4} = $24, other
; = 0). With >= 3 units the packed entry from @FormationData
; (base + 2*(count-2)) is unpacked into four (count,slot) nibbles at
; $6F99-$6F9C and expanded into the unit-id queue at $6FA1. Then the unit
; coordinate arrays $0614/$0600 (slots $6F91..$6F91+9) are filled from the
; banked roster data prepared by @SetupDefenderRoster/@SetupAttackerRoster
; (($20) = roster pointer, $0022-$0025 = per-slot read cursors).
;-------------------------------------------------------------------------------
@DeploySideUnits:
  LDA $0022                             ; $B1B0: AD 22 00  ; faction id
  CMP #$01                              ; $B1B3: C9 01
  BEQ @RowOffset12                      ; $B1B5: F0 11
  CMP #$05                              ; $B1B7: C9 05
  BEQ @RowOffset12                      ; $B1B9: F0 0D
  CMP #$02                              ; $B1BB: C9 02
  BEQ @RowOffset24                      ; $B1BD: F0 0E
  CMP #$04                              ; $B1BF: C9 04
  BEQ @RowOffset24                      ; $B1C1: F0 0A
  LDA #$00                              ; $B1C3: A9 00
  JMP @AddRowOffset                     ; $B1C5: 4C CF B1
@RowOffset12:
  LDA #$12                              ; $B1C8: A9 12
  JMP @AddRowOffset                     ; $B1CA: 4C CF B1
@RowOffset24:
  LDA #$24                              ; $B1CD: A9 24
@AddRowOffset:
  CLC                                   ; $B1CF: 18
  ADC $0020                             ; $B1D0: 6D 20 00  ; + side placement base
  STA $0020                             ; $B1D3: 8D 20 00  ; formation base offset
  LDA officer_scan_idx                             ; $B1D6: AD 94 6F  ; unit count - 1
  BNE @LoadFormation                    ; $B1D9: D0 03     ; >= 2 units: expand
  JMP @FillCoordinates                  ; $B1DB: 4C 58 B2  ; 1 unit: coords only
@LoadFormation:
  SEC                                   ; $B1DE: 38
  SBC #$01                              ; $B1DF: E9 01     ; count - 2
  ASL                                   ; $B1E1: 0A        ; 2 bytes per entry
  CLC                                   ; $B1E2: 18
  ADC $0020                             ; $B1E3: 6D 20 00
  STA $0020                             ; $B1E6: 8D 20 00
  LDA #$FD                              ; $B1E9: A9 FD
  CLC                                   ; $B1EB: 18
  ADC $0020                             ; $B1EC: 6D 20 00  ; + @FormationData low
  STA $0020                             ; $B1EF: 8D 20 00
  LDA #$B3                              ; $B1F2: A9 B3     ; @FormationData high
  ADC #$00                              ; $B1F4: 69 00
  STA $0021                             ; $B1F6: 8D 21 00  ; ($20) = formation entry
  LDX #$00                              ; $B1F9: A2 00
  LDA side_unit_base                             ; $B1FB: AD 91 6F
  BEQ @UnpackEntry                      ; $B1FE: F0 02
  LDX #$04                              ; $B200: A2 04     ; side 1 nibble offset
@UnpackEntry:
  LDY #$00                              ; $B202: A0 00
@UnpackLoop:
  LDA ($20),Y                           ; $B204: B1 20     ; packed (count<<4)|slot
  STA $0022                             ; $B206: 8D 22 00
  LSR                                   ; $B209: 4A
  LSR                                   ; $B20A: 4A
  LSR                                   ; $B20B: 4A
  LSR                                   ; $B20C: 4A        ; count nibble
  STA formation_slot0_units,X                           ; $B20D: 9D 99 6F
  LDA $0022                             ; $B210: AD 22 00
  AND #$0F                              ; $B213: 29 0F     ; slot nibble
  STA formation_slot_idx,X                           ; $B215: 9D 9A 6F
  INX                                   ; $B218: E8
  INX                                   ; $B219: E8
  INY                                   ; $B21A: C8
  CPY #$02                              ; $B21B: C0 02     ; 2 packed bytes
  BCC @UnpackLoop                       ; $B21D: 90 E5
  LDX #$00                              ; $B21F: A2 00
  LDA side_unit_base                             ; $B221: AD 91 6F
  BEQ @ExpandInit                       ; $B224: F0 02
  LDX #$04                              ; $B226: A2 04
@ExpandInit:
  TXA                                   ; $B228: 8A
  CLC                                   ; $B229: 18
  ADC #$04                              ; $B22A: 69 04     ; 4 nibble slots
  STA $0022                             ; $B22C: 8D 22 00  ; expand loop limit
  LDA #$01                              ; $B22F: A9 01
  STA $0020                             ; $B231: 8D 20 00  ; next unit id
  LDY side_unit_base                             ; $B234: AC 91 6F  ; queue write index
  INY                                   ; $B237: C8        ; skip head entry
@ExpandLoop:
  LDA formation_slot0_units,X                           ; $B238: BD 99 6F  ; units for this slot
  BEQ @NextSlot                         ; $B23B: F0 12
  STA $0021                             ; $B23D: 8D 21 00
@FillUnit:
  LDA $0020                             ; $B240: AD 20 00
  STA officer_state_table,Y                           ; $B243: 99 A1 6F  ; placement queue entry
  INY                                   ; $B246: C8
  DEC $0021                             ; $B247: CE 21 00
  LDA $0021                             ; $B24A: AD 21 00
  BNE @FillUnit                         ; $B24D: D0 F1
@NextSlot:
  INC $0020                             ; $B24F: EE 20 00  ; advance unit id
  INX                                   ; $B252: E8
  CPX $0022                             ; $B253: EC 22 00
  BCC @ExpandLoop                       ; $B256: 90 E0
@FillCoordinates:
  LDA side_unit_base                             ; $B258: AD 91 6F
  BNE @AttackerRoster                   ; $B25B: D0 06
  JSR @SetupDefenderRoster              ; $B25D: 20 AE B2
  JMP @StoreCoordinates                 ; $B260: 4C 66 B2
@AttackerRoster:
  JSR @SetupAttackerRoster              ; $B263: 20 12 B3
@StoreCoordinates:
  LDX side_unit_base                             ; $B266: AE 91 6F  ; side unit base
  TXA                                   ; $B269: 8A
  CLC                                   ; $B26A: 18
  ADC #$0A                              ; $B26B: 69 0A     ; 10 units per side
  STA $002A                             ; $B26D: 8D 2A 00  ; slot limit
  LDY #$00                              ; $B270: A0 00
  LDA ($20),Y                           ; $B272: B1 20     ; base Y coord
  STA unit_coord_y,X                           ; $B274: 9D 14 06
  INY                                   ; $B277: C8
  LDA ($20),Y                           ; $B278: B1 20     ; base X coord
  STA unit_coord_x,X                           ; $B27A: 9D 00 06
  INX                                   ; $B27D: E8
@CoordLoop:
  LDA officer_state_table,X                           ; $B27E: BD A1 6F  ; placement queue entry
  CMP #$FF                              ; $B281: C9 FF
  BEQ @CoordDone                        ; $B283: F0 28
  SEC                                   ; $B285: 38
  SBC #$01                              ; $B286: E9 01     ; unit id -> cursor index
  STA $002B                             ; $B288: 8D 2B 00
  TAY                                   ; $B28B: A8
  LDA $0022,Y                           ; $B28C: B9 22 00  ; per-slot roster cursor
  TAY                                   ; $B28F: A8
  LDA ($20),Y                           ; $B290: B1 20     ; unit Y coord
  STA unit_coord_y,X                           ; $B292: 9D 14 06
  INY                                   ; $B295: C8
  LDA ($20),Y                           ; $B296: B1 20     ; unit X coord
  STA unit_coord_x,X                           ; $B298: 9D 00 06
  LDY $002B                             ; $B29B: AC 2B 00
  LDA $0022,Y                           ; $B29E: B9 22 00
  CLC                                   ; $B2A1: 18
  ADC #$02                              ; $B2A2: 69 02     ; consume the pair
  STA $0022,Y                           ; $B2A4: 99 22 00
  INX                                   ; $B2A7: E8
  CPX $002A                             ; $B2A8: EC 2A 00
  BCC @CoordLoop                        ; $B2AB: 90 D1
@CoordDone:
  RTS                                   ; $B2AD: 60
;-------------------------------------------------------------------------------
; @SetupDefenderRoster - prepare side-0 coordinate roster pointer in ($20)
; Scans bank $30 province list $9D72 (8 entries per group, group index
; $050E) for the current province ($052A). Its deployment descriptor from
; $9AB4 (bank $31) is scaled by 32 and added to the side-0 roster base
; from bank $26 table $8C52[$050E]. The four per-slot read cursors are
; seeded from @DefenderCursorSeeds into $0022-$0025.
;-------------------------------------------------------------------------------
@SetupDefenderRoster:
  LDY #$30                              ; $B2AE: A0 30
  JSR B1F_SwitchBank8_A                             ; $B2B0: 20 66 F2  ; SwitchBank8_A: bank $30
  LDA battle_province_idx                             ; $B2B3: AD 0E 05  ; province group index
  ASL                                   ; $B2B6: 0A
  ASL                                   ; $B2B7: 0A
  ASL                                   ; $B2B8: 0A        ; *8
  TAY                                   ; $B2B9: A8
@FindProvince:
  LDA $9D72,Y                           ; $B2BA: B9 72 9D  ; province id
  BPL @CompareProvince                  ; $B2BD: 10 05
  LDA #$00                              ; $B2BF: A9 00     ; list end: descriptor 0
  JMP @ScaleDescriptor                  ; $B2C1: 4C D9 B2
@CompareProvince:
  CMP battle_target_province                             ; $B2C4: CD 2A 05  ; current province
  BEQ @GotProvince                      ; $B2C7: F0 04
  INY                                   ; $B2C9: C8
  JMP @FindProvince                     ; $B2CA: 4C BA B2
@GotProvince:
  TYA                                   ; $B2CD: 98
  PHA                                   ; $B2CE: 48
  LDY #$31                              ; $B2CF: A0 31
  JSR B1F_SwitchBank8_A                             ; $B2D1: 20 66 F2  ; bank $31
  PLA                                   ; $B2D4: 68
  TAY                                   ; $B2D5: A8
  LDA $9AB4,Y                           ; $B2D6: B9 B4 9A  ; deployment descriptor
@ScaleDescriptor:
  STA $0020                             ; $B2D9: 8D 20 00
  ASL                                   ; $B2DC: 0A
  ASL                                   ; $B2DD: 0A
  ASL                                   ; $B2DE: 0A
  ASL                                   ; $B2DF: 0A
  ASL                                   ; $B2E0: 0A        ; descriptor * 32
  STA $0020                             ; $B2E1: 8D 20 00
  LDY #$26                              ; $B2E4: A0 26
  JSR B1F_SwitchBank8_A                             ; $B2E6: 20 66 F2  ; bank $26
  LDA battle_province_idx                             ; $B2E9: AD 0E 05
  ASL                                   ; $B2EC: 0A
  TAY                                   ; $B2ED: A8
  LDA $8C52,Y                           ; $B2EE: B9 52 8C  ; side-0 roster base low
  CLC                                   ; $B2F1: 18
  ADC $0020                             ; $B2F2: 6D 20 00
  STA $0020                             ; $B2F5: 8D 20 00
  LDA $8C53,Y                           ; $B2F8: B9 53 8C  ; side-0 roster base high
  ADC #$00                              ; $B2FB: 69 00
  STA $0021                             ; $B2FD: 8D 21 00  ; ($20) = roster data
  LDY #$00                              ; $B300: A0 00
@CopySeeds:
  LDA @DefenderCursorSeeds,Y            ; $B302: B9 0E B3
  STA $0022,Y                           ; $B305: 99 22 00  ; per-slot cursors
  INY                                   ; $B308: C8
  CPY #$04                              ; $B309: C0 04
  BCC @CopySeeds                        ; $B30B: 90 F5
  RTS                                   ; $B30D: 60
@DefenderCursorSeeds:
  .byte $02,$08,$0C,$14                 ; $B30E: 02 08 0C 14
;-------------------------------------------------------------------------------
; @SetupAttackerRoster - prepare side-1 coordinate roster pointer in ($20)
; Same province scan as @SetupDefenderRoster, but the descriptor comes from
; $9E62 in bank $30 (scaled by 34) and the roster base from bank $26 table
; $8000[$050E]. Cursors are seeded from @AttackerCursorSeeds.
;-------------------------------------------------------------------------------
@SetupAttackerRoster:
  LDY #$30                              ; $B312: A0 30
  JSR B1F_SwitchBank8_A                             ; $B314: 20 66 F2  ; SwitchBank8_A: bank $30
  LDA battle_province_idx                             ; $B317: AD 0E 05  ; province group index
  ASL                                   ; $B31A: 0A
  ASL                                   ; $B31B: 0A
  ASL                                   ; $B31C: 0A        ; *8
  TAY                                   ; $B31D: A8
@FindProvinceAtk:
  LDA $9D72,Y                           ; $B31E: B9 72 9D  ; province id
  BPL @CompareProvinceAtk               ; $B321: 10 05
  LDA #$00                              ; $B323: A9 00     ; list end: descriptor 0
  JMP @ScaleDescriptorAtk               ; $B325: 4C 34 B3
@CompareProvinceAtk:
  CMP battle_target_province                             ; $B328: CD 2A 05  ; current province
  BEQ @GotProvinceAtk                   ; $B32B: F0 04
  INY                                   ; $B32D: C8
  JMP @FindProvinceAtk                  ; $B32E: 4C 1E B3
@GotProvinceAtk:
  LDA $9E62,Y                           ; $B331: B9 62 9E  ; deployment descriptor
@ScaleDescriptorAtk:
  STA $0020                             ; $B334: 8D 20 00
  ASL                                   ; $B337: 0A
  ASL                                   ; $B338: 0A
  ASL                                   ; $B339: 0A
  ASL                                   ; $B33A: 0A        ; *16
  CLC                                   ; $B33B: 18
  ADC $0020                             ; $B33C: 6D 20 00  ; *17
  ASL                                   ; $B33F: 0A        ; descriptor * 34
  STA $0020                             ; $B340: 8D 20 00
  LDY #$26                              ; $B343: A0 26
  JSR B1F_SwitchBank8_A                             ; $B345: 20 66 F2  ; bank $26
  LDA battle_province_idx                             ; $B348: AD 0E 05
  ASL                                   ; $B34B: 0A
  TAY                                   ; $B34C: A8
  LDA $8000,Y                           ; $B34D: B9 00 80  ; side-1 roster base low
  CLC                                   ; $B350: 18
  ADC $0020                             ; $B351: 6D 20 00
  STA $0020                             ; $B354: 8D 20 00
  LDA $8001,Y                           ; $B357: B9 01 80  ; side-1 roster base high
  ADC #$00                              ; $B35A: 69 00
  STA $0021                             ; $B35C: 8D 21 00  ; ($20) = roster data
  LDY #$00                              ; $B35F: A0 00
@CopySeedsAtk:
  LDA @AttackerCursorSeeds,Y            ; $B361: B9 6D B3
  STA $0022,Y                           ; $B364: 99 22 00  ; per-slot cursors
  INY                                   ; $B367: C8
  CPY #$04                              ; $B368: C0 04
  BCC @CopySeedsAtk                     ; $B36A: 90 F5
  RTS                                   ; $B36C: 60
@AttackerCursorSeeds:
  .byte $02,$0C,$16,$1C                 ; $B36D: 02 0C 16 1C
;-------------------------------------------------------------------------------
; @CountAndSortUnits - count and sort the active units of side $6F91
; Counts active officer slots in $0664[$6F91..$6F91+9] into $6F94
; (count - 1). With >= 3 units, bubble-sorts the adjacent slot pairs so that
; officers with higher SRAM record byte 1 come first (@SwapUnitPair).
;-------------------------------------------------------------------------------
@CountAndSortUnits:
  LDA side_unit_base                             ; $B371: AD 91 6F  ; side unit base
  TAY                                   ; $B374: A8
  CLC                                   ; $B375: 18
  ADC #$0A                              ; $B376: 69 0A     ; 10 slots per side
  STA $002A                             ; $B378: 8D 2A 00  ; scan limit
  LDX #$00                              ; $B37B: A2 00     ; active unit count
@CountLoop:
  LDA battle_roster,Y                           ; $B37D: B9 64 06  ; officer id
  CMP #$FF                              ; $B380: C9 FF
  BEQ @CountNext                        ; $B382: F0 01
  INX                                   ; $B384: E8
@CountNext:
  INY                                   ; $B385: C8
  CPY $002A                             ; $B386: CC 2A 00
  BCC @CountLoop                        ; $B389: 90 F2
  DEX                                   ; $B38B: CA        ; count - 1
  STX officer_scan_idx                             ; $B38C: 8E 94 6F
  CPX #$02                              ; $B38F: E0 02     ; need >= 3 units to sort
  BCS @SortOuter                        ; $B391: B0 01
  RTS                                   ; $B393: 60
@SortOuter:
  LDY #$01                              ; $B394: A0 01     ; pass number
@SortPass:
  TYA                                   ; $B396: 98
  PHA                                   ; $B397: 48
  LDX side_unit_base                             ; $B398: AE 91 6F
  TXA                                   ; $B39B: 8A
  CLC                                   ; $B39C: 18
  ADC officer_scan_idx                             ; $B39D: 6D 94 6F
  STA $002B                             ; $B3A0: 8D 2B 00  ; inner loop limit
  INX                                   ; $B3A3: E8
@SortInner:
  LDA battle_roster,X                           ; $B3A4: BD 64 06  ; slot X officer id
  JSR GetOfficerRecordPtr               ; $B3A7: 20 91 B4
  LDY #$01                              ; $B3AA: A0 01
  LDA ($20),Y                           ; $B3AC: B1 20     ; record byte 1
  STA $002A                             ; $B3AE: 8D 2A 00
  LDA battle_roster+1,X                           ; $B3B1: BD 65 06  ; slot X+1 officer id
  JSR GetOfficerRecordPtr               ; $B3B4: 20 91 B4
  LDY #$01                              ; $B3B7: A0 01
  LDA ($20),Y                           ; $B3B9: B1 20
  CMP $002A                             ; $B3BB: CD 2A 00
  BCC @NoSwap                           ; $B3BE: 90 03     ; already descending
  JSR @SwapUnitPair                     ; $B3C0: 20 D2 B3
@NoSwap:
  INX                                   ; $B3C3: E8
  CPX $002B                             ; $B3C4: EC 2B 00
  BCC @SortInner                        ; $B3C7: 90 DB
  PLA                                   ; $B3C9: 68
  TAY                                   ; $B3CA: A8
  INY                                   ; $B3CB: C8
  CPY officer_scan_idx                             ; $B3CC: CC 94 6F
  BCC @SortPass                         ; $B3CF: 90 C5
  RTS                                   ; $B3D1: 60
;-------------------------------------------------------------------------------
; @SwapUnitPair - swap adjacent unit slots X / X+1 in the officer roster
; ($0664), the army array ($0628) and the unit state array ($063C).
;-------------------------------------------------------------------------------
@SwapUnitPair:
  LDA battle_roster,X                           ; $B3D2: BD 64 06
  TAY                                   ; $B3D5: A8
  LDA battle_roster+1,X                           ; $B3D6: BD 65 06
  STA battle_roster,X                           ; $B3D9: 9D 64 06
  TYA                                   ; $B3DC: 98
  STA battle_roster+1,X                           ; $B3DD: 9D 65 06
  LDA unit_army_array,X                           ; $B3E0: BD 28 06
  TAY                                   ; $B3E3: A8
  LDA unit_army_array+1,X                           ; $B3E4: BD 29 06
  STA unit_army_array,X                           ; $B3E7: 9D 28 06
  TYA                                   ; $B3EA: 98
  STA unit_army_array+1,X                           ; $B3EB: 9D 29 06
  LDA unit_state_array,X                           ; $B3EE: BD 3C 06
  TAY                                   ; $B3F1: A8
  LDA unit_state_array+1,X                           ; $B3F2: BD 3D 06
  STA unit_state_array,X                           ; $B3F5: 9D 3C 06
  TYA                                   ; $B3F8: 98
  STA unit_state_array+1,X                           ; $B3F9: 9D 3D 06
  RTS                                   ; $B3FC: 60
;-------------------------------------------------------------------------------
; @FormationData - packed deployment formations used by @DeploySideUnits
; Addressed as @FormationData + side/terrain base + 2*(unit_count-2).
; Each 2-byte entry unpacks into four nibble pairs (count<<4)|slot: the high
; nibbles are the unit counts per slot, the low nibbles the slot indices.
;-------------------------------------------------------------------------------
@FormationData:
  .byte $10,$00,$11,$00,$21,$00,$21,$10,$31,$10,$32,$10,$32,$11,$32,$21 ; $B3FD: 10 00 11 00 21 00 21 10 31 10 32 10 32 11 32 21
  .byte $32,$22,$00,$10,$01,$10,$01,$20,$11,$20,$11,$21,$21,$21,$21,$31 ; $B40D: 32 22 00 10 01 10 01 20 11 20 11 21 21 21 21 31
  .byte $21,$32,$21,$33,$01,$00,$01,$10,$11,$10,$12,$10,$12,$20,$22,$20 ; $B41D: 21 32 21 33 01 00 01 10 11 10 12 10 12 20 22 20
  .byte $22,$21,$22,$22,$32,$31,$10,$00,$20,$00,$21,$00,$21,$01,$31,$01 ; $B42D: 22 21 22 22 32 31 10 00 20 00 21 00 21 01 31 01
  .byte $31,$11,$32,$11,$42,$11,$42,$12,$10,$00,$11,$00,$11,$10,$21,$10 ; $B43D: 31 11 32 11 42 11 42 12 10 00 11 00 11 10 21 10
  .byte $21,$11,$22,$11,$22,$21,$32,$21,$33,$21,$10,$00,$11,$00,$21,$00 ; $B44D: 21 11 22 11 22 21 32 21 33 21 10 00 11 00 21 00
  .byte $21,$10,$21,$11,$22,$11,$32,$11,$33,$11,$33,$12                  ; $B45D: 21 10 21 11 22 11 32 11 33 11 33 12
.endproc
; GetProvinceRuntimePtr - ($20) = $6000 + A*32 (32-byte province runtime record)
GetProvinceRuntimePtr:
  LDY #$00                              ; $B469: A0 00
  STY $0021                             ; $B46B: 8C 21 00
  ASL                                   ; $B46E: 0A
  ROL $0021                             ; $B46F: 2E 21 00
  ASL                                   ; $B472: 0A
  ROL $0021                             ; $B473: 2E 21 00
  ASL                                   ; $B476: 0A
  ROL $0021                             ; $B477: 2E 21 00
  ASL                                   ; $B47A: 0A
  ROL $0021                             ; $B47B: 2E 21 00
  ASL                                   ; $B47E: 0A
  ROL $0021                             ; $B47F: 2E 21 00
  CLC                                   ; $B482: 18
  ADC #$00                              ; $B483: 69 00
  STA $0020                             ; $B485: 8D 20 00
  LDA $0021                             ; $B488: AD 21 00
  ADC #$60                              ; $B48B: 69 60
  STA $0021                             ; $B48D: 8D 21 00
  RTS                                   ; $B490: 60
; GetOfficerRecordPtr - ($20) = $63C0 + A*12 (12-byte officer record, SRAM)
GetOfficerRecordPtr:
  LDY #$00                              ; $B491: A0 00
  STY $0021                             ; $B493: 8C 21 00
  STA $0020                             ; $B496: 8D 20 00
  ASL                                   ; $B499: 0A
  ROL $0021                             ; $B49A: 2E 21 00
  CLC                                   ; $B49D: 18
  ADC $0020                             ; $B49E: 6D 20 00
  PHA                                   ; $B4A1: 48
  LDA $0021                             ; $B4A2: AD 21 00
  ADC #$00                              ; $B4A5: 69 00
  STA $0021                             ; $B4A7: 8D 21 00
  PLA                                   ; $B4AA: 68
  ASL                                   ; $B4AB: 0A
  ROL $0021                             ; $B4AC: 2E 21 00
  ASL                                   ; $B4AF: 0A
  ROL $0021                             ; $B4B0: 2E 21 00
  CLC                                   ; $B4B3: 18
  ADC #$C0                              ; $B4B4: 69 C0
  STA $0020                             ; $B4B6: 8D 20 00
  LDA $0021                             ; $B4B9: AD 21 00
  ADC #$63                              ; $B4BC: 69 63
  STA $0021                             ; $B4BE: 8D 21 00
  RTS                                   ; $B4C1: 60
; GetFactionRecordPtr - ($20) = $6F07 + (A&$0F)*8 (8-byte faction record, SRAM)
GetFactionRecordPtr:
  AND #$0F                              ; $B4C2: 29 0F
  ASL                                   ; $B4C4: 0A
  TAY                                   ; $B4C5: A8
  LDA FactionRecordPtrTable,Y           ; $B4C6: B9 D3 B4
  STA $0020                             ; $B4C9: 8D 20 00
  LDA FactionRecordPtrTable+1,Y         ; $B4CC: B9 D4 B4
  STA $0021                             ; $B4CF: 8D 21 00
  RTS                                   ; $B4D2: 60
FactionRecordPtrTable:                  ; faction 0-6 records, 8 bytes apart
  .word faction_records,faction_records+$08,faction_records+$10,faction_records+$18,faction_records+$20,faction_records+$28,faction_records+$30 ; $B4D3: 07 6F 0F 6F 17 6F 1F 6F 27 6F 2F 6F 37 6F
; GetOfficerRecordPtrBanked - select bank $31 at $8000, ($20) = $8000 + A*12
; (12-byte officer record, banked base stats)
GetOfficerRecordPtrBanked:
; --- Code Region ---
  LDY #$31                              ; $B4E1: A0 31
  JSR B1F_SwitchBank8_A                             ; $B4E3: 20 66 F2  ; SwitchBank8_A
  LDY #$00                              ; $B4E6: A0 00
  STY $0021                             ; $B4E8: 8C 21 00
  STA $0020                             ; $B4EB: 8D 20 00
  ASL                                   ; $B4EE: 0A
  ROL $0021                             ; $B4EF: 2E 21 00
  CLC                                   ; $B4F2: 18
  ADC $0020                             ; $B4F3: 6D 20 00
  PHA                                   ; $B4F6: 48
  LDA $0021                             ; $B4F7: AD 21 00
  ADC #$00                              ; $B4FA: 69 00
  STA $0021                             ; $B4FC: 8D 21 00
  PLA                                   ; $B4FF: 68
  ASL                                   ; $B500: 0A
  ROL $0021                             ; $B501: 2E 21 00
  ASL                                   ; $B504: 0A
  ROL $0021                             ; $B505: 2E 21 00
  CLC                                   ; $B508: 18
  ADC #$00                              ; $B509: 69 00
  STA $0020                             ; $B50B: 8D 20 00
  LDA $0021                             ; $B50E: AD 21 00
  ADC #$80                              ; $B511: 69 80
  STA $0021                             ; $B513: 8D 21 00
  RTS                                   ; $B516: 60
;===============================================================================
; CallbackDispatcher ($B517-$B535)
; Inline table dispatcher: A = index into .word table following the JSR.
; JMPs to table[A]; handler RTS returns to code after the table.
; Y is preserved (saved via $20). Usage:
;   LDA #index / JSR CallbackDispatcher / .word target0, target1, ...
;===============================================================================
.proc CallbackDispatcher
  STY $0020                             ; $B517: 8C 20 00  ; save Y
  ASL                                   ; $B51A: 0A        ; A = index*2
  TAY                                   ; $B51B: A8
  INY                                   ; $B51C: C8        ; Y = index*2+1
  PLA                                   ; $B51D: 68        ; pull return addr (table ptr)
  STA $0021                             ; $B51E: 8D 21 00
  PLA                                   ; $B521: 68
  STA $0022                             ; $B522: 8D 22 00
  LDA ($21),Y                           ; $B525: B1 21     ; target low byte
  STA $0023                             ; $B527: 8D 23 00
  INY                                   ; $B52A: C8
  LDA ($21),Y                           ; $B52B: B1 21     ; target high byte
  STA $0024                             ; $B52D: 8D 24 00
  LDY $0020                             ; $B530: AC 20 00  ; restore Y
  JMP ($0023)                           ; $B533: 6C 23 00  ; jump to handler
.endproc
; Div24Bit - 24-bit division: ($20,$21,$22) / ($23,$24)
; Restoring binary long division, 24 iterations (Y from $17):
;   shift dividend ($20,$21,$22) into remainder ($25,$26,$27); tentatively
;   subtract divisor ($23,$24,0); if no borrow keep the subtraction and set
;   the quotient bit (INC $0020, whose shifted-out low bits accumulate the
;   quotient), else discard it. $0028/$0029 are scratch for the low/mid
;   difference. Quotient -> ($20,$21,$22), remainder -> ($25,$26,$27).
Div24Bit:
  LDA #$00                              ; $B536: A9 00
  STA $0025                             ; $B538: 8D 25 00
  STA $0026                             ; $B53B: 8D 26 00
  STA $0027                             ; $B53E: 8D 27 00
  LDY #$17                              ; $B541: A0 17
@Loop:
  ASL $0020                             ; $B543: 0E 20 00
  ROL $0021                             ; $B546: 2E 21 00
  ROL $0022                             ; $B549: 2E 22 00
  ROL $0025                             ; $B54C: 2E 25 00
  ROL $0026                             ; $B54F: 2E 26 00
  ROL $0027                             ; $B552: 2E 27 00
  LDA $0025                             ; $B555: AD 25 00
  SEC                                   ; $B558: 38
  SBC $0023                             ; $B559: ED 23 00
  STA $0028                             ; $B55C: 8D 28 00
  LDA $0026                             ; $B55F: AD 26 00
  SBC $0024                             ; $B562: ED 24 00
  STA $0029                             ; $B565: 8D 29 00
  LDA $0027                             ; $B568: AD 27 00
  SBC #$00                              ; $B56B: E9 00
  BCC @NoSubtract                       ; $B56D: 90 12
  STA $0027                             ; $B56F: 8D 27 00
  LDA $0028                             ; $B572: AD 28 00
  STA $0025                             ; $B575: 8D 25 00
  LDA $0029                             ; $B578: AD 29 00
  STA $0026                             ; $B57B: 8D 26 00
  INC $0020                             ; $B57E: EE 20 00
@NoSubtract:
  DEY                                   ; $B581: 88
  BPL @Loop                             ; $B582: 10 BF
  RTS                                   ; $B584: 60
; Mul24x8 - 24-bit multiply: ($20,$21,$22) * $23 -> ($26,$27,$28), 8 iterations
; Shift-and-add over multiplier $23 (LSB first; $23 is consumed). The
; multiplicand ($20,$21,$22) is doubled each pass, so it is ALSO destroyed;
; ($24,$29) hold the carry chain of the shifted multiplicand. Callers
; (e.g. $B105, $B12D) rely on the destroyed multiplicand and feed the
; result ($26,$27,$28) into Div24Bit or a chained multiply.
Mul24x8:
  LDY #$07                              ; $B585: A0 07
  LDA #$00                              ; $B587: A9 00
  STA $0024                             ; $B589: 8D 24 00
  STA $0025                             ; $B58C: 8D 25 00
  STA $0026                             ; $B58F: 8D 26 00
  STA $0027                             ; $B592: 8D 27 00
  STA $0028                             ; $B595: 8D 28 00
  STA $0029                             ; $B598: 8D 29 00
@Loop:
  LSR $0023                             ; $B59B: 4E 23 00
  BCC @NoAdd                            ; $B59E: 90 25
  LDA $0020                             ; $B5A0: AD 20 00
  CLC                                   ; $B5A3: 18
  ADC $0026                             ; $B5A4: 6D 26 00
  STA $0026                             ; $B5A7: 8D 26 00
  LDA $0021                             ; $B5AA: AD 21 00
  ADC $0027                             ; $B5AD: 6D 27 00
  STA $0027                             ; $B5B0: 8D 27 00
  LDA $0022                             ; $B5B3: AD 22 00
  ADC $0028                             ; $B5B6: 6D 28 00
  STA $0028                             ; $B5B9: 8D 28 00
  LDA $0024                             ; $B5BC: AD 24 00
  ADC $0029                             ; $B5BF: 6D 29 00
  STA $0029                             ; $B5C2: 8D 29 00
@NoAdd:
  ASL $0020                             ; $B5C5: 0E 20 00
  ROL $0021                             ; $B5C8: 2E 21 00
  ROL $0022                             ; $B5CB: 2E 22 00
  ROL $0024                             ; $B5CE: 2E 24 00
  DEY                                   ; $B5D1: 88
  BPL @Loop                             ; $B5D2: 10 C7
  RTS                                   ; $B5D4: 60
; NextRandomByte - RNG: A = RandomTable[$6F92], then $6F92++.
; RandomTable is a fixed 256-byte permutation of $00-$FF (byte-identical to
; B1F's RandomTable at $E8BA); the cursor $6F92 is never reset, so it wraps
; through the whole table. X preserved via $6F93.
NextRandomByte:
  STX rng_x_save                             ; $B5D5: 8E 93 6F
  LDX rng_cursor                             ; $B5D8: AE 92 6F
  LDA RandomTable,X                     ; $B5DB: BD E5 B5
  INC rng_cursor                             ; $B5DE: EE 92 6F
  LDX rng_x_save                             ; $B5E1: AE 93 6F
  RTS                                   ; $B5E4: 60
RandomTable:                            ; $B5E5: 256-byte permutation of $00-$FF, read indexed by $6F92
  .byte $3E,$4E,$4F,$83,$0E,$C9,$7F,$5D,$FC,$E6,$BA,$01,$F8,$00,$F4,$0A ; $B5E5: 3E 4E 4F 83 0E C9 7F 5D FC E6 BA 01 F8 00 F4 0A
  .byte $E5,$A9,$8D,$D1,$E8,$DB,$DE,$81,$95,$72,$08,$9A,$C7,$49,$C8,$23 ; $B5F5: E5 A9 8D D1 E8 DB DE 81 95 72 08 9A C7 49 C8 23
  .byte $39,$37,$E0,$91,$C3,$33,$9B,$5F,$BE,$41,$EE,$74,$E2,$0B,$47,$7E ; $B605: 39 37 E0 91 C3 33 9B 5F BE 41 EE 74 E2 0B 47 7E
  .byte $BF,$60,$BB,$20,$61,$05,$B2,$94,$B6,$E4,$3A,$21,$1E,$B4,$8C,$CE ; $B615: BF 60 BB 20 61 05 B2 94 B6 E4 3A 21 1E B4 8C CE
  .byte $7B,$FE,$22,$DC,$18,$C4,$6D,$FB,$CD,$27,$A0,$09,$6E,$38,$8A,$04 ; $B625: 7B FE 22 DC 18 C4 6D FB CD 27 A0 09 6E 38 8A 04
  .byte $7C,$56,$97,$5A,$A8,$4D,$78,$B5,$6C,$AA,$03,$1A,$4A,$0D,$26,$82 ; $B635: 7C 56 97 5A A8 4D 78 B5 6C AA 03 1A 4A 0D 26 82
  .byte $AD,$02,$A1,$B9,$A3,$6B,$D8,$0C,$4C,$AE,$19,$45,$5B,$9C,$16,$07 ; $B645: AD 02 A1 B9 A3 6B D8 0C 4C AE 19 45 5B 9C 16 07
  .byte $89,$51,$90,$29,$F5,$62,$F7,$CB,$F1,$53,$FF,$14,$65,$D0,$87,$35 ; $B655: 89 51 90 29 F5 62 F7 CB F1 53 FF 14 65 D0 87 35
  .byte $10,$73,$7A,$9F,$EB,$D9,$3C,$EF,$9E,$D7,$3D,$6F,$D6,$84,$AB,$11 ; $B665: 10 73 7A 9F EB D9 3C EF 9E D7 3D 6F D6 84 AB 11
  .byte $CA,$D2,$88,$17,$E1,$A6,$52,$8E,$5E,$36,$24,$44,$28,$A4,$55,$A7 ; $B675: CA D2 88 17 E1 A6 52 8E 5E 36 24 44 28 A4 55 A7
  .byte $C2,$FD,$76,$2E,$B7,$D5,$F6,$64,$15,$31,$99,$93,$C0,$8F,$B3,$FA ; $B685: C2 FD 76 2E B7 D5 F6 64 15 31 99 93 C0 8F B3 FA
  .byte $E9,$E3,$67,$4B,$85,$32,$C6,$69,$48,$DF,$A2,$EC,$98,$6A,$E7,$D4 ; $B695: E9 E3 67 4B 85 32 C6 69 48 DF A2 EC 98 6A E7 D4
  .byte $1C,$F3,$58,$50,$ED,$2B,$1D,$86,$F0,$71,$BD,$34,$1B,$AF,$30,$2D ; $B6A5: 1C F3 58 50 ED 2B 1D 86 F0 71 BD 34 1B AF 30 2D
  .byte $68,$CC,$0F,$57,$EA,$92,$8B,$3F,$3B,$AC,$B8,$C1,$2F,$F2,$46,$75 ; $B6B5: 68 CC 0F 57 EA 92 8B 3F 3B AC B8 C1 2F F2 46 75
  .byte $96,$7D,$2A,$79,$40,$DA,$9D,$25,$12,$42,$54,$D3,$1F,$80,$5C,$59 ; $B6C5: 96 7D 2A 79 40 DA 9D 25 12 42 54 D3 1F 80 5C 59
  .byte $43,$F9,$B0,$DD,$63,$A5,$77,$CF,$13,$2C,$66,$BC,$70,$B1,$C5,$06 ; $B6D5: 43 F9 B0 DD 63 A5 77 CF 13 2C 66 BC 70 B1 C5 06
;===============================================================================
; GetTileTerrainClamped - terrain of map coordinate ($0020,$0021)
; Wrapper around @GetTileTerrain that clamps terrain values >= 6 to 2.
; Output: A = terrain value.
;===============================================================================
.proc GetTileTerrainClamped
  JSR @GetTileTerrain                   ; $B6E5: 20 EF B6
  CMP #$06                              ; $B6E8: C9 06
  BCC @Done                             ; $B6EA: 90 02
  LDA #$02                              ; $B6EC: A9 02     ; clamp >= 6 to 2
@Done:
  RTS                                   ; $B6EE: 60
;-------------------------------------------------------------------------------
; @GetTileTerrain - province terrain lookup for map coords ($0020,$0021),
; each 0-31. Computes quadrant = (x >= 16) | ((y >= 16) << 1) and reads the
; terrain zone id from the caller-provided map zone table at ($00A8).
; The zone selects both the 16x16 detail-map pointer (TerrainMapPtrTable)
; and the PRG bank holding that map (TileBankTable, switched into the $8000
; window via SwitchBank8_A). The detail tile is map[(y&15)*16 + (x&15)];
; tiles >= $80 yield terrain 0, others are converted via TileTerrainTable.
;-------------------------------------------------------------------------------
@GetTileTerrain:
  LDY #$00                              ; $B6EF: A0 00
  LDA $0020                             ; $B6F1: AD 20 00  ; map X
  CMP #$10                              ; $B6F4: C9 10
  BCC @QuadrantXDone                    ; $B6F6: 90 02
  LDY #$01                              ; $B6F8: A0 01     ; bit0: right half
@QuadrantXDone:
  LDA $0021                             ; $B6FA: AD 21 00  ; map Y
  CMP #$10                              ; $B6FD: C9 10
  BCC @LoadZone                         ; $B6FF: 90 04
  TYA                                   ; $B701: 98
  ORA #$02                              ; $B702: 09 02     ; bit1: lower half
  TAY                                   ; $B704: A8
@LoadZone:
  LDA ($A8),Y                           ; $B705: B1 A8     ; zone id from map table
  PHA                                   ; $B707: 48
  ASL                                   ; $B708: 0A        ; word index
  TAY                                   ; $B709: A8
  LDA TerrainMapPtrTable,Y              ; $B70A: B9 CB B7  ; detail map ptr low
  STA $0022                             ; $B70D: 8D 22 00
  LDA TerrainMapPtrTable+1,Y            ; $B710: B9 CC B7  ; detail map ptr high
  STA $0023                             ; $B713: 8D 23 00
  PLA                                   ; $B716: 68
  TAY                                   ; $B717: A8        ; Y = zone id
  LDA TileBankTable,Y                   ; $B718: B9 BB B8  ; PRG bank for this zone
  TAY                                   ; $B71B: A8
  JSR B1F_SwitchBank8_A                             ; $B71C: 20 66 F2  ; SwitchBank8_A
  LDA #<TileTerrainTable                ; $B71F: A9 4B
  STA $0024                             ; $B721: 8D 24 00  ; ($24) = terrain table
  LDA #>TileTerrainTable                ; $B724: A9 B7
  STA $0025                             ; $B726: 8D 25 00
  LDA $0020                             ; $B729: AD 20 00
  AND #$0F                              ; $B72C: 29 0F     ; x within quadrant
  STA $0026                             ; $B72E: 8D 26 00
  LDX #$00                              ; $B731: A2 00
  LDA $0021                             ; $B733: AD 21 00
  ASL                                   ; $B736: 0A
  ASL                                   ; $B737: 0A
  ASL                                   ; $B738: 0A
  ASL                                   ; $B739: 0A        ; y within quadrant * 16
  ORA $0026                             ; $B73A: 0D 26 00  ; detail map offset
  TAY                                   ; $B73D: A8
  LDA ($22),Y                           ; $B73E: B1 22     ; detail tile
  TAY                                   ; $B740: A8
  CMP #$80                              ; $B741: C9 80
  BCC @ConvertTerrain                   ; $B743: 90 03
  LDA #$00                              ; $B745: A9 00     ; blocked tile -> 0
  RTS                                   ; $B747: 60
@ConvertTerrain:
  LDA ($24),Y                           ; $B748: B1 24     ; TileTerrainTable[tile]
  RTS                                   ; $B74A: 60
.endproc
;===============================================================================
; Terrain lookup tables used by GetTileTerrainClamped
;===============================================================================
TileTerrainTable:                       ; $B74B: tile id ($00-$7F) -> terrain type
  .byte $00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; $B74B: 00 01 03 03 03 03 03 03 03 03 03 03 03 03 03 03
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02 ; $B75B: 03 03 03 03 03 03 03 03 03 03 03 03 02 02 02 02
  .byte $04,$04,$02,$04,$04,$02,$04,$02,$04,$04,$04,$02,$00,$00,$02,$02 ; $B76B: 04 04 02 04 04 02 04 02 04 04 04 02 00 00 02 02
  .byte $02,$02,$02,$02,$02,$02,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00 ; $B77B: 02 02 02 02 02 02 00 00 00 02 00 00 00 00 00 00
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$02,$00,$00,$00,$02,$02,$02,$02 ; $B78B: 03 03 03 03 03 03 03 03 02 00 00 00 02 02 02 02
  .byte $02,$02,$02,$02,$02,$02,$04,$02,$02,$04,$02,$04,$04,$04,$03,$00 ; $B79B: 02 02 02 02 02 02 04 02 02 04 02 04 04 04 03 00
  .byte $00,$05,$05,$05,$05,$03,$00,$03,$03,$03,$01,$01,$01,$01,$02,$02 ; $B7AB: 00 05 05 05 05 03 00 03 03 03 01 01 01 01 02 02
  .byte $01,$02,$02,$02,$01,$02,$02,$03,$03,$06,$07,$08,$00,$00,$00,$00  ; $B7BB: 01 02 02 02 01 02 02 03 03 06 07 08 00 00 00 00
TerrainMapPtrTable:                     ; $B7CB: zone id -> 16x16 detail map ptr
  .word $8040,$8170,$8200,$8330,$83C0,$84F0,$8580,$86B0 ; $B7CB: 40 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86
  .word $8740,$8870,$8900,$8A30,$8AC0,$8BF0,$8C80,$8DB0 ; $B7DB: 40 87 70 88 00 89 30 8A C0 8A F0 8B 80 8C B0 8D
  .word $8E40,$8F70,$9000,$9130,$91C0,$92F0,$9380,$94B0 ; $B7EB: 40 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94
  .word $9540,$9670,$9700,$9830,$98C0,$99F0,$9A80,$9BB0 ; $B7FB: 40 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B
  .word $89A6,$8AD6,$8B66,$8C96,$8D26,$8E56,$8EE6,$9016 ; $B80B: A6 89 D6 8A 66 8B 96 8C 26 8D 56 8E E6 8E 16 90
  .word $90A6,$91D6,$9266,$9396,$9426,$9556,$95E6,$9716 ; $B81B: A6 90 D6 91 66 92 96 93 26 94 56 95 E6 95 16 97
  .word $97A6,$98D6,$9966,$9A96,$9B26,$9C56,$9CE6,$9E16 ; $B82B: A6 97 D6 98 66 99 96 9A 26 9B 56 9C E6 9C 16 9E
  .word $9540,$9670,$9700,$9830,$98C0,$99F0,$9A80,$9BB0 ; $B83B: 40 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B
  .word $8040,$8170,$8200,$8330,$83C0,$84F0,$8580,$86B0 ; $B84B: 40 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86
  .word $8740,$8870,$8900,$8A30,$8AC0,$8BF0,$8C80,$8DB0 ; $B85B: 40 87 70 88 00 89 30 8A C0 8A F0 8B 80 8C B0 8D
  .word $8E40,$8F70,$9000,$9130,$91C0,$92F0,$9380,$94B0 ; $B86B: 40 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94
  .word $9540,$9670,$9700,$9830,$98C0,$99F0,$9A80,$9BB0 ; $B87B: 40 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B
  .word $8040,$8170,$8200,$8330,$83C0,$84F0,$8580,$86B0 ; $B88B: 40 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86
  .word $8740,$8870,$8900,$8A30,$8AC0,$8BF0,$8C80,$8DB0 ; $B89B: 40 87 70 88 00 89 30 8A C0 8A F0 8B 80 8C B0 8D
  .word $8E40,$8F70,$9000,$9130,$91C0,$92F0,$9380,$94B0  ; $B8AB: 40 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94
TileBankTable:                          ; $B8BB: zone id -> PRG bank ($8000 window)
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20 ; $B8BB: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20 ; $B8CB: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
  .byte $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23 ; $B8DB: 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23
  .byte $23,$23,$23,$23,$23,$23,$23,$23,$25,$25,$25,$25,$25,$25,$25,$25 ; $B8EB: 23 23 23 23 23 23 23 23 25 25 25 25 25 25 25 25
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24 ; $B8FB: 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24 ; $B90B: 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25 ; $B91B: 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25
  .byte $25,$25,$25,$25,$25,$25,$25,$25                                     ; $B92B: 25 25 25 25 25 25 25 25
;===============================================================================
; BattleResultProcess - battle phase handler ($6F8B == $01, via $A039)
; Resolves the pending battle strike: the army slot selected by $0504
; (slot 0 when $0504 bit7 clear, slot 4 otherwise) supplies the target
; officer and target coordinates ($04D8-$04DA). If the current officer
; ($6F8C) is not already at the target spot, an AiFindNearbyOfficers scan
; (radius 2, entered at its scan loop $A8E8 with the target preloaded into
; ($20,$21)) decides whether the strike lands. On a hit, damage is computed
; from both officers' SRAM records (level and record byte $B) and applied
; to the attacker's HP field; the damage is stored into $042C-$042D.
; Ends by setting the game start flag $6F8B to $FF (battle resolved).
;===============================================================================
.proc BattleResultProcess
  LDA #$FF                              ; $B933: A9 FF
  STA ai_action_result                             ; $B935: 8D 8F 6F  ; action result = none
  LDY #$04                              ; $B938: A0 04     ; army slot base (side 1)
  LDA battle_side_flag                             ; $B93A: AD 04 05  ; AI faction flag
  BPL @SlotSelected                     ; $B93D: 10 02
  LDY #$00                              ; $B93F: A0 00     ; side 0 slot base
@SlotSelected:
  STY $002A                             ; $B941: 8C 2A 00
  LDA army_slot_base,Y                           ; $B944: B9 D8 04  ; army_slot_base entry
  CMP #$FF                              ; $B947: C9 FF
  BNE @LoadTargetCoords                 ; $B949: D0 03
  JMP @FinishBattle                     ; $B94B: 4C AD BA     ; no pending strike
@LoadTargetCoords:
  LDA army_slot_base+1,Y                           ; $B94E: B9 D9 04  ; target X
  STA $0020                             ; $B951: 8D 20 00
  LDA army_slot_base+2,Y                           ; $B954: B9 DA 04  ; target Y
  STA $0021                             ; $B957: 8D 21 00
  LDX ai_officer_idx                             ; $B95A: AE 8C 6F  ; current officer slot
  LDA unit_coord_x,X                           ; $B95D: BD 00 06  ; officer X
  CMP $0020                             ; $B960: CD 20 00
  BNE @NormalizeTargetY                 ; $B963: D0 08
  LDA unit_coord_y,Y                           ; $B965: B9 14 06  ; note: indexed by slot base Y
  CMP $0021                             ; $B968: CD 21 00
  BEQ @ResolveCombat                    ; $B96B: F0 20     ; already at target
@NormalizeTargetY:
  LDA $0021                             ; $B96D: AD 21 00
  CMP #$10                              ; $B970: C9 10
  BCC @RangeScan                        ; $B972: 90 06
  SEC                                   ; $B974: 38
  SBC #$01                              ; $B975: E9 01     ; skip map gap row
  STA $0021                             ; $B977: 8D 21 00
@RangeScan:
  LDA #$02                              ; $B97A: A9 02     ; scan radius 2
  STA $0022                             ; $B97C: 8D 22 00
  JSR AiTurnProcess::AiFindNearbyOfficers_ScanLoop ; $B97F: 20 E8 A8  ; scan loop; ($20,$21) = target
  LDX ai_officer_idx                             ; $B982: AE 8C 6F
  LDA proximity_table,X                           ; $B985: BD C9 6F  ; proximity entry for self
  BNE @ResolveCombat                    ; $B988: D0 03     ; nonzero = in range
  JMP @FinishBattle                     ; $B98A: 4C AD BA
@ResolveCombat:
  LDX ai_officer_idx                             ; $B98D: AE 8C 6F
  LDA unit_coord_x,X                           ; $B990: BD 00 06  ; own X
  STA $0020                             ; $B993: 8D 20 00
  LDA unit_coord_y,X                           ; $B996: BD 14 06  ; own Y
  STA $0021                             ; $B999: 8D 21 00
  JSR GetTileTerrainClamped             ; $B99C: 20 E5 B6  ; terrain under self
  CMP #$00                              ; $B99F: C9 00
  BEQ @LoadTargetOfficer                ; $B9A1: F0 03
  JMP @FinishBattle                     ; $B9A3: 4C AD BA     ; invalid terrain
@LoadTargetOfficer:
  LDY $002A                             ; $B9A6: AC 2A 00  ; slot base
  LDA army_slot_base,Y                           ; $B9A9: B9 D8 04  ; target officer index
  TAX                                   ; $B9AC: AA
  LDA battle_roster,X                           ; $B9AD: BD 64 06  ; target officer id
  JSR GetOfficerRecordPtr               ; $B9B0: 20 91 B4
  LDY #$02                              ; $B9B3: A0 02
  LDA ($20),Y                           ; $B9B5: B1 20     ; target level
  STA $0023                             ; $B9B7: 8D 23 00
  LDY #$0B                              ; $B9BA: A0 0B
  LDA ($20),Y                           ; $B9BC: B1 20     ; target attack (byte $B)
  STA $0024                             ; $B9BE: 8D 24 00
  LDY ai_officer_idx                             ; $B9C1: AC 8C 6F
  LDA battle_roster,Y                           ; $B9C4: B9 64 06  ; own officer id
  JSR GetOfficerRecordPtr               ; $B9C7: 20 91 B4
  LDY #$02                              ; $B9CA: A0 02
  LDA ($20),Y                           ; $B9CC: B1 20     ; own level
  STA $0022                             ; $B9CE: 8D 22 00
  LDA $0023                             ; $B9D1: AD 23 00
  SEC                                   ; $B9D4: 38
  SBC $0022                             ; $B9D5: ED 22 00  ; target level - own level
  BPL @LevelBonusOk                     ; $B9D8: 10 02
  LDA #$00                              ; $B9DA: A9 00     ; clamp at 0
@LevelBonusOk:
  CLC                                   ; $B9DC: 18
  ADC #$0A                              ; $B9DD: 69 0A     ; +10 base bonus
  STA $0020                             ; $B9DF: 8D 20 00
@RollHit:
  JSR NextRandomByte                    ; $B9E2: 20 D5 B5
  CMP #$65                              ; $B9E5: C9 65     ; reject >= 101
  BCS @RollHit                          ; $B9E7: B0 F9
  LDA $0024                             ; $B9E9: AD 24 00
  ASL                                   ; $B9EC: 0A
  ASL                                   ; $B9ED: 0A
  ASL                                   ; $B9EE: 0A        ; attack * 8
  CLC                                   ; $B9EF: 18
  ADC $0024                             ; $B9F0: 6D 24 00  ; *9
  ADC $0024                             ; $B9F3: 6D 24 00  ; attack * 10
  STA $002A                             ; $B9F6: 8D 2A 00  ; scaled attack value
  LDA $0023                             ; $B9F9: AD 23 00  ; target level
  STA $0020                             ; $B9FC: 8D 20 00  ; 24-bit multiplicand low
  LDA #$00                              ; $B9FF: A9 00
  STA $0021                             ; $BA01: 8D 21 00
  STA $0022                             ; $BA04: 8D 22 00
@RollFactor:
  JSR NextRandomByte                    ; $BA07: 20 D5 B5
  CMP #$0B                              ; $BA0A: C9 0B     ; reject >= 11
  BCS @RollFactor                       ; $BA0C: B0 F9
  CLC                                   ; $BA0E: 18
  ADC #$1E                              ; $BA0F: 69 1E     ; factor = 30..40
  STA $0023                             ; $BA11: 8D 23 00  ; multiplier
  JSR Mul24x8                           ; $BA14: 20 85 B5  ; level * factor
  LDA $0026                             ; $BA17: AD 26 00
  STA $0020                             ; $BA1A: 8D 20 00
  LDA $0027                             ; $BA1D: AD 27 00
  STA $0021                             ; $BA20: 8D 21 00  ; product low 16 bits
  LDA #$0A                              ; $BA23: A9 0A
  STA $0023                             ; $BA25: 8D 23 00  ; divisor 10 (low)
  LDA #$00                              ; $BA28: A9 00
  STA $0022                             ; $BA2A: 8D 22 00  ; dividend high
  STA $0024                             ; $BA2D: 8D 24 00  ; divisor high
  JSR Div24Bit                          ; $BA30: 20 36 B5  ; / 10
  LDA $0020                             ; $BA33: AD 20 00
  CLC                                   ; $BA36: 18
  ADC $002A                             ; $BA37: 6D 2A 00  ; + scaled attack
  STA $0022                             ; $BA3A: 8D 22 00  ; damage low
  LDA $0021                             ; $BA3D: AD 21 00
  ADC #$00                              ; $BA40: 69 00
  STA $0023                             ; $BA42: 8D 23 00  ; damage high
  LDY ai_officer_idx                             ; $BA45: AC 8C 6F
  LDA battle_roster,Y                           ; $BA48: B9 64 06  ; own officer id
  JSR GetOfficerRecordPtr               ; $BA4B: 20 91 B4
  LDY #$08                              ; $BA4E: A0 08
  LDA ($20),Y                           ; $BA50: B1 20     ; own HP low
  STA $0024                             ; $BA52: 8D 24 00
  INY                                   ; $BA55: C8
  LDA ($20),Y                           ; $BA56: B1 20     ; own HP high + flags
  AND #$03                              ; $BA58: 29 03
  STA $0025                             ; $BA5A: 8D 25 00
  LDA $0024                             ; $BA5D: AD 24 00
  SEC                                   ; $BA60: 38
  SBC $0022                             ; $BA61: ED 22 00  ; HP - damage (low)
  STA $0026                             ; $BA64: 8D 26 00
  LDA $0025                             ; $BA67: AD 25 00
  SBC $0023                             ; $BA6A: ED 23 00  ; (high)
  STA $0027                             ; $BA6D: 8D 27 00
  BCS @ApplyDamage                      ; $BA70: B0 14     ; HP >= damage
  LDA $0024                             ; $BA72: AD 24 00
  STA $0022                             ; $BA75: 8D 22 00  ; clamp damage to HP
  LDA $0025                             ; $BA78: AD 25 00
  STA $0023                             ; $BA7B: 8D 23 00
  LDA #$00                              ; $BA7E: A9 00
  STA $0026                             ; $BA80: 8D 26 00  ; remaining HP = 0
  STA $0027                             ; $BA83: 8D 27 00
@ApplyDamage:
  LDY #$08                              ; $BA86: A0 08
  LDA $0026                             ; $BA88: AD 26 00
  STA ($20),Y                           ; $BA8B: 91 20     ; write HP low
  INY                                   ; $BA8D: C8
  LDA ($20),Y                           ; $BA8E: B1 20
  AND #$FC                              ; $BA90: 29 FC     ; keep flag bits
  ORA $0027                             ; $BA92: 0D 27 00  ; merge HP high
  STA ($20),Y                           ; $BA95: 91 20
  LDA $0022                             ; $BA97: AD 22 00
  STA action_result_lo                             ; $BA9A: 8D 2C 04  ; result: damage low
  LDA $0023                             ; $BA9D: AD 23 00
  STA action_result_hi                             ; $BAA0: 8D 2D 04  ; result: damage high
  LDA #$00                              ; $BAA3: A9 00
  STA action_result_cnt                             ; $BAA5: 8D 2E 04  ; result counter
  LDA #$00                              ; $BAA8: A9 00
  STA ai_action_result                             ; $BAAA: 8D 8F 6F  ; action result = done
@FinishBattle:
  LDA #$FF                              ; $BAAD: A9 FF
  STA sram_game_start_flag                             ; $BAAF: 8D 8B 6F  ; game start flag = resolved
  RTS                                   ; $BAB2: 60
.endproc
;===============================================================================
; BattlePhaseProcess - Battle turn phase dispatcher
; Called via dispatch callback at $A006
; $0501 = phase index (0-3), dispatched via inline table at $BAB9
;   Phase 0: BattleAttackerSetup - configure attacker faction
;   Phase 1: BattleDefenderSetup - configure defender faction
;   Phase 2: BattleExecute - populate unit lists and resolve strikes
;   Phase 3: BattlePostProcess - post-battle updates
; Spans $BAB3-$C0BA
;===============================================================================
.proc BattlePhaseProcess
; --- Proc-local RAM (shared by nested phase procs) ---
scene_subparam         = $050B  ; scene sub-parameter ($11 attacker, $02 defender)
unit_ally_counts       = $0550  ; per-province ally unit counts (11 entries)
reserve_units          = $6F47  ; reserve unit id lists (2 x $14)
  LDA battle_scene_phase                             ; $BAB3: AD 01 05
  JSR B1F_CallbackDispatcher          ; $BAB6: 20 DE EA  ; dispatch on battle phase
; --- Inline dispatch table (high-byte-first format, 4 entries) ---
  .word BattleAttackerSetup                       ; $BAB9: C1 BA  (phase 0)
  .word BattleDefenderSetup                       ; $BABB: 3D BB  (phase 1)
  .word BattleExecute                             ; $BABD: 93 BB  (phase 2)
  .word BattlePostProcess                         ; $BABF: A0 BB  (phase 3)
;-------------------------------------------------------------------------------
; Phase 0: BattleAttackerSetup
; Sets bank switching regs ($00B2-$00DB) for PRG $08/$09.
; Reads attacker faction from $0507 upper nibble, checks if at war (byte 3 = $03).
; If not at war: skip battle. If at war: set $0504=$80 (attacker flag), dispatch.
;-------------------------------------------------------------------------------
.proc BattleAttackerSetup
  LDA #$08                              ; $BAC1: A9 08
  STA $00B2                             ; $BAC3: 8D B2 00
  STA $00C2                             ; $BAC6: 8D C2 00
  STA $00CA                             ; $BAC9: 8D CA 00
  STA $00D2                             ; $BACC: 8D D2 00
  STA $00DA                             ; $BACF: 8D DA 00
  LDA #$09                              ; $BAD2: A9 09
  STA $00B3                             ; $BAD4: 8D B3 00
  STA $00C3                             ; $BAD7: 8D C3 00
  STA $00CB                             ; $BADA: 8D CB 00
  STA $00D3                             ; $BADD: 8D D3 00
  STA $00DB                             ; $BAE0: 8D DB 00
  LDA battle_faction_pair                             ; $BAE3: AD 07 05
  LSR                                   ; $BAE6: 4A  ; upper nibble = attacker faction
  LSR                                   ; $BAE7: 4A
  LSR                                   ; $BAE8: 4A
  LSR                                   ; $BAE9: 4A
  JSR B1F_GetRulerDataPtr               ; $BAEA: 20 68 F3
  LDY #$03                              ; $BAED: A0 03
  LDA ($00),Y                           ; $BAEF: B1 00
  CMP #$03                              ; $BAF1: C9 03
  BEQ @AttNotAtWar                      ; $BAF3: F0 2A
  STA battle_outcome_flag                             ; $BAF5: 8D 44 6F  ; store defender faction
@AttNotAtWar:
  LDA battle_side_selector                             ; $BAF8: AD 14 05
  BEQ @AttSkipBattle                    ; $BAFB: F0 12
  LDA #$0A                              ; $BAFD: A9 0A  ; (dead store)
  LDA #$0D                              ; $BAFF: A9 0D
  STA battle_scene_id                             ; $BB01: 8D 00 05  ; next state
  LDA #$00                              ; $BB04: A9 00
  STA battle_scene_phase                             ; $BB06: 8D 01 05  ; reset phase
  LDA #$11                              ; $BB09: A9 11
  STA scene_subparam                             ; $BB0B: 8D 0B 05
  RTS                                   ; $BB0E: 60
@AttSkipBattle:
  LDA #$0E                              ; $BB0F: A9 0E
  STA battle_scene_id                             ; $BB11: 8D 00 05  ; next state (alt)
  LDA #$00                              ; $BB14: A9 00
  STA battle_scene_phase                             ; $BB16: 8D 01 05
  LDA #$11                              ; $BB19: A9 11
  STA scene_subparam                             ; $BB1B: 8D 0B 05
  RTS                                   ; $BB1E: 60
@AttAtWar:
  LDA #$80                              ; $BB1F: A9 80
  STA battle_side_flag                             ; $BB21: 8D 04 05  ; attacker flag (bit 7 set)
  LDA battle_side_selector                             ; $BB24: AD 14 05
  BEQ @AttDefNotWar                     ; $BB27: F0 08
  LDA #$02                              ; $BB29: A9 02
  STA side_unit_base                             ; $BB2B: 8D 91 6F  ; dispatch index
  JMP DoDispatch                        ; $BB2E: 4C 36 BB
@AttDefNotWar:
  LDA #$00                              ; $BB31: A9 00
  STA side_unit_base                             ; $BB33: 8D 91 6F
@AttDispatchDone:
  JSR DoDispatch                        ; $BB36: 20 46 BC
  INC battle_scene_phase                             ; $BB39: EE 01 05
  RTS                                   ; $BB3C: 60
.endproc
;-------------------------------------------------------------------------------
; Phase 1: BattleDefenderSetup
; Reads defender faction from $0507 lower nibble, checks if at war.
; If not at war: skip battle. If at war: set $0504=$00 (defender flag), dispatch.
;-------------------------------------------------------------------------------
.proc BattleDefenderSetup
  LDA battle_faction_pair                             ; $BB3D: AD 07 05
  AND #$0F                              ; $BB40: 29 0F
  JSR B1F_GetRulerDataPtr               ; $BB42: 20 68 F3
  LDY #$03                              ; $BB45: A0 03
  LDA ($00),Y                           ; $BB47: B1 00
  CMP #$03                              ; $BB49: C9 03
  BEQ @DefAtWar                         ; $BB4B: F0 28
  STA battle_outcome_flag                             ; $BB4D: 8D 44 6F  ; store attacker faction
  LDA battle_side_selector                             ; $BB50: AD 14 05
  BNE @DefSkipBattle1                   ; $BB53: D0 10
  LDA #$0D                              ; $BB55: A9 0D
  STA battle_scene_id                             ; $BB57: 8D 00 05
  LDA #$00                              ; $BB5A: A9 00
  STA battle_scene_phase                             ; $BB5C: 8D 01 05
  LDA #$02                              ; $BB5F: A9 02
  STA scene_subparam                             ; $BB61: 8D 0B 05
  RTS                                   ; $BB64: 60
@DefSkipBattle1:
  LDA #$0E                              ; $BB65: A9 0E
  STA battle_scene_id                             ; $BB67: 8D 00 05
  LDA #$00                              ; $BB6A: A9 00
  STA battle_scene_phase                             ; $BB6C: 8D 01 05
  LDA #$02                              ; $BB6F: A9 02
  STA scene_subparam                             ; $BB71: 8D 0B 05
  RTS                                   ; $BB74: 60
@DefAtWar:
  LDA #$00                              ; $BB75: A9 00
  STA battle_side_flag                             ; $BB77: 8D 04 05
  LDA battle_side_selector                             ; $BB7A: AD 14 05
  BNE @DefAtWar2                        ; $BB7D: D0 08
  LDA #$01                              ; $BB7F: A9 01
  STA side_unit_base                             ; $BB81: 8D 91 6F
  JMP DoDispatch                        ; $BB84: 4C 8C BB
@DefAtWar2:
  LDA #$00                              ; $BB87: A9 00
  STA side_unit_base                             ; $BB89: 8D 91 6F
  JSR DoDispatch                        ; $BB8C: 20 46 BC
  INC battle_scene_phase                             ; $BB8F: EE 01 05
  RTS                                   ; $BB92: 60
.endproc
;-------------------------------------------------------------------------------
; Phase 2: BattleExecute (entry at $BB93)
; Calls ECEE (unknown), PopulateOfficerArrays, ApplyCoordDeltas.
;-------------------------------------------------------------------------------
.proc BattleExecute  ; (dispatch callback target)
  JSR B1F_PaletteCopyBuffer                             ; $BB93: 20 EE EC
  JSR PopulateOfficerArrays             ; $BB96: 20 0A BF
  JSR ApplyCoordDeltas                  ; $BB99: 20 27 C0
  INC battle_scene_phase                             ; $BB9C: EE 01 05
  RTS                                   ; $BB9F: 60
.endproc
;-------------------------------------------------------------------------------
; Phase 3: BattlePostProcess
; Checks $0087 sign bit. If negative, calls SetupPostBattleState and iterates
; faction officer table ($9D72) calling $F2AF for each until $FF sentinel.
;-------------------------------------------------------------------------------
.proc BattlePostProcess
; --- Proc-local RAM (scene handoff, canonical names from prg_0c_0d.asm) ---
scene_callback_id      = $0400  ; next scene callback id ($0D post-battle)
scene_callback_st      = $0401  ; next scene callback state
  LDA $0087                             ; $BBA0: AD 87 00
  BPL @PostDone                         ; $BBA3: 10 12
  JSR SetupPostBattleState              ; $BBA5: 20 B8 BB
  LDA #$01                              ; $BBA8: A9 01
  STA $007A                             ; $BBAA: 8D 7A 00
  LDA #$0D                              ; $BBAD: A9 0D
  STA scene_callback_id                             ; $BBAF: 8D 00 04
  LDA #$00                              ; $BBB2: A9 00
  STA scene_callback_st                             ; $BBB4: 8D 01 04
@PostDone:
  RTS                                   ; $BBB7: 60
.endproc
;-------------------------------------------------------------------------------
; SetupPostBattleState
; Calls $F25F(Y=$30) and $F2AF to set up faction record.
; If $0514 == 0, patches faction record byte 0 with faction index.
; Then iterates $9D72 officer table calling $F2AF for each entry.
;-------------------------------------------------------------------------------
.proc SetupPostBattleState
  LDY #$30                              ; $BBB8: A0 30
  JSR B1F_SwitchBank8_B               ; $BBBA: 20 5F F2
  LDA battle_province_idx                             ; $BBBD: AD 0E 05
  JSR B1F_GetProvinceRecordAddr         ; $BBC0: 20 AF F2
  LDA battle_side_selector                             ; $BBC3: AD 14 05
  BNE @PostBattlePatch                  ; $BBC6: D0 17
  LDA battle_faction_pair                             ; $BBC8: AD 07 05
  LSR                                   ; $BBCB: 4A
  LSR                                   ; $BBCC: 4A
  LSR                                   ; $BBCD: 4A
  LSR                                   ; $BBCE: 4A
  AND #$0F                              ; $BBCF: 29 0F
  STA $0002                             ; $BBD1: 8D 02 00
  LDY #$00                              ; $BBD4: A0 00
  LDA ($00),Y                           ; $BBD6: B1 00
  AND #$F0                              ; $BBD8: 29 F0
  ORA $0002                             ; $BBDA: 0D 02 00
  STA ($00),Y                           ; $BBDD: 91 00
@PostBattlePatch:
  JSR SwapFirstUnitToFront              ; $BBDF: 20 00 BC
  LDA battle_province_idx                             ; $BBE2: AD 0E 05
  ASL                                   ; $BBE5: 0A
  ASL                                   ; $BBE6: 0A
  ASL                                   ; $BBE7: 0A
  TAY                                   ; $BBE8: A8
@IterOfficerTable:
  TYA                                   ; $BBE9: 98
  PHA                                   ; $BBEA: 48
  LDA $9D72,Y                           ; $BBEB: B9 72 9D
  CMP #$FF                              ; $BBEE: C9 FF
  BNE @CallProvinceAndSwap              ; $BBF0: D0 02
  PLA                                   ; $BBF2: 68
  RTS                                   ; $BBF3: 60
@CallProvinceAndSwap:
  JSR B1F_GetProvinceRecordAddr         ; $BBF4: 20 AF F2
  JSR SwapFirstUnitToFront              ; $BBF7: 20 00 BC
  PLA                                   ; $BBFA: 68
  TAY                                   ; $BBFB: A8
  INY                                   ; $BBFC: C8
  JMP @IterOfficerTable                   ; $BBFD: 4C E9 BB
.endproc  ; SetupPostBattleState
;-------------------------------------------------------------------------------
; SwapFirstUnitToFront - Copy ($00)→($0A) and swap matching entry
; Saves ($00)/($01) to ($0A)/($0B). Checks byte at ($0A) offset $11.
; If value == $07, return. Otherwise searches ($0A)+$11..$1B for match
; and swaps bytes at found offset with offset $11.
;-------------------------------------------------------------------------------
SwapFirstUnitToFront:
  LDA $0000                             ; $BC00: AD 00 00
  STA $000A                             ; $BC03: 8D 0A 00
  LDA $0001                             ; $BC06: AD 01 00
  STA $000B                             ; $BC09: 8D 0B 00
  LDY #$00                              ; $BC0C: A0 00
  LDA ($0A),Y                           ; $BC0E: B1 0A
  AND #$0F                              ; $BC10: 29 0F
  CMP #$07                              ; $BC12: C9 07
  BNE @SwapSearch                       ; $BC14: D0 01
  RTS                                   ; $BC16: 60
@SwapSearch:
  JSR B1F_GetRulerDataPtr                             ; $BC17: 20 68 F3
  LDY #$00                              ; $BC1A: A0 00
  LDA ($00),Y                           ; $BC1C: B1 00
  STA $0002                             ; $BC1E: 8D 02 00
  LDY #$11                              ; $BC21: A0 11
@SwapScan:
  LDA ($0A),Y                           ; $BC23: B1 0A
  CMP $0002                             ; $BC25: CD 02 00
  BEQ @SwapFound                        ; $BC28: F0 06
  INY                                   ; $BC2A: C8
  CPY #$1B                              ; $BC2B: C0 1B
  BCC @SwapScan                         ; $BC2D: 90 F4
  RTS                                   ; $BC2F: 60
@DoSwap:
  TYA                                   ; $BC30: 98
  PHA                                   ; $BC31: 48
  LDY #$11                              ; $BC32: A0 11
  LDA ($0A),Y                           ; $BC34: B1 0A
  STA $0003                             ; $BC36: 8D 03 00
  LDA $0002                             ; $BC39: AD 02 00
  STA ($0A),Y                           ; $BC3C: 91 0A
  PLA                                   ; $BC3E: 68
  TAY                                   ; $BC3F: A8
  LDA $0003                             ; $BC40: AD 03 00
  STA ($0A),Y                           ; $BC43: 91 0A
  RTS                                   ; $BC45: 60
DoDispatch:
  LDA side_unit_base                             ; $BC46: AD 91 6F
  JSR B1F_CallbackDispatcher          ; $BC49: 20 DE EA  ; dispatch on result type
; --- Inline dispatch table (high-byte-first format, 3 entries) ---
; Entry 0 → @ProcessAttackerUnits ($BC52, data-as-code)
; Entry 1 → BattleExecute+4 ($BD59, inside nested proc)
; Entry 2 → $FFE0 (unused/reserved)
  .word @ProcessAttackerUnits                     ; $BC4C: 52 BC  (entry 0)
  .byte $BD,$59                                        ; $BC4E: BD 59  (entry 1)
  .byte $FF,$E0                                        ; $BC50: FF E0  (entry 2, unused)
;-------------------------------------------------------------------------------
; @ProcessAttackerUnits (dispatch target 0 from $BC46)
; Data-as-code: loads $050E*8 as Y index, calls FindDefenderMatch for each
; attacker officer. Aborts if any match fails (X=$FF).
;-------------------------------------------------------------------------------
@ProcessAttackerUnits:
  LDA battle_province_idx                             ; $BC52: AD 0E 05
  ASL                                   ; $BC55: 0A
  ASL                                   ; $BC56: 0A
  ASL                                   ; $BC57: 0A
  TAY                                   ; $BC58: A8
  LDA #$00                              ; $BC59: A9 00
  STA $0004                             ; $BC5B: 8D 04 00
  JSR FindDefenderMatch                 ; $BC5E: 20 96 BD
  CPX #$FF                              ; $BC61: E0 FF
  BNE @ProcessAttackerUnits             ; $BC63: D0 ED  ; loop (self-referencing data-as-code)
  RTS                                   ; $BC65: 60
  ; Remaining bytes $BC52-$BC6C are data-as-code (opcodes reinterpreted)

;-------------------------------------------------------------------------------
; BattleUnitMatcher - Main unit matching loop
; Iterates $042C/$0550 arrays (officer IDs and status).
; For active officers ($0550,Y != 0 and != $0A), calls FindDefenderMatch.
; Then processes unpaired units and assigns faction to matched units.
;-------------------------------------------------------------------------------
BattleUnitMatcher:
  JSR PopulateOfficerArrays           ; $BC6D: 20 90 BE
  LDY #$00                              ; $BC70: A0 00
@MatchLoop:
  LDA action_result_lo,Y                           ; $BC72: B9 2C 04
  CMP #$FF                              ; $BC75: C9 FF
  BEQ @AssignFactionLoop                ; $BC77: F0 25
  STA $0002                             ; $BC79: 8D 02 00
  LDA unit_ally_counts,Y                           ; $BC7C: B9 50 05
  BEQ @MatchNext                        ; $BC7F: F0 18
  CMP #$0A                              ; $BC81: C9 0A
  BEQ @MatchNext                        ; $BC83: F0 14
  CLC                                   ; $BC85: 18
  ADC #$11                              ; $BC86: 69 11
  STA $0003                             ; $BC88: 8D 03 00
  STY $0005                             ; $BC8B: 8C 05 00
  JSR FindDefenderMatch                 ; $BC8E: 20 96 BD
  CPX #$FF                              ; $BC91: E0 FF
  BNE @MatchResume                      ; $BC93: D0 01
  RTS                                   ; $BC95: 60
@MatchResume:
  LDY $0005                             ; $BC96: AC 05 00
@MatchNext:
  INY                                   ; $BC99: C8
  CPY #$08                              ; $BC9A: C0 08
  BCC @MatchLoop                        ; $BC9C: 90 D4
@AssignFactionLoop:
  LDA battle_faction_pair                             ; $BC9E: AD 07 05
  LDY battle_side_flag                             ; $BCA1: AC 04 05
  BPL @GetFactionIndex                  ; $BCA4: 10 04
  LSR                                   ; $BCA6: 4A
  LSR                                   ; $BCA7: 4A
  LSR                                   ; $BCA8: 4A
  LSR                                   ; $BCA9: 4A
@GetFactionIndex:
  AND #$0F                              ; $BCAA: 29 0F
  STA $000A                             ; $BCAC: 8D 0A 00
  LDY #$00                              ; $BCAF: A0 00
@ScanUnpaired:
  LDA action_result_lo,Y                           ; $BCB1: B9 2C 04
  CMP #$FF                              ; $BCB4: C9 FF
  BEQ @AssignDone                       ; $BCB6: F0 30
  STA $0002                             ; $BCB8: 8D 02 00
  LDA unit_ally_counts,Y                           ; $BCBB: B9 50 05
  BNE @AssignNext                       ; $BCBE: D0 23
  CLC                                   ; $BCC0: 18
  ADC #$11                              ; $BCC1: 69 11
  STA $0003                             ; $BCC3: 8D 03 00
  STY $0005                             ; $BCC6: 8C 05 00
  JSR FindDefenderMatch                 ; $BCC9: 20 96 BD
  LDY #$11                              ; $BCCC: A0 11
  LDA ($00),Y                           ; $BCCE: B1 00
  CMP #$FF                              ; $BCD0: C9 FF
  BEQ @AssignSwap                       ; $BCD2: F0 07
  LDY #$00                              ; $BCD4: A0 00
  LDA $000A                             ; $BCD6: AD 0A 00
  STA ($00),Y                           ; $BCD9: 91 00
@AssignSwap:
  CPX #$FF                              ; $BCDB: E0 FF
  BNE @AssignCont                       ; $BCDD: D0 01
  RTS                                   ; $BCDF: 60
@AssignCont:
  LDY $0005                             ; $BCE0: AC 05 00
@AssignNext:
  INY                                   ; $BCE3: C8
  CPY #$08                              ; $BCE4: C0 08
  BCC @AssignFactionLoop                ; $BCE6: 90 C9
@AssignDone:
  LDA battle_faction_pair                             ; $BCE8: AD 07 05
  LDY battle_side_flag                             ; $BCEB: AC 04 05
  BPL @GetFactionIdx2                   ; $BCEE: 10 04
  LSR                                   ; $BCF0: 4A
  LSR                                   ; $BCF1: 4A
  LSR                                   ; $BCF2: 4A
  LSR                                   ; $BCF3: 4A
@GetFactionIdx2:
  AND #$0F                              ; $BCF4: 29 0F
  JSR B1F_GetRulerDataPtr               ; $BCF6: 20 68 F3
  LDY #$00                              ; $BCF9: A0 00
  LDA ($00),Y                           ; $BCFB: B1 00
  STA $0002                             ; $BCFD: 8D 02 00
  LDX $0004                             ; $BD00: AE 04 00
@ScanAllies:
  LDA officer_state_table,X                           ; $BD03: BD A1 6F
  STA $0003                             ; $BD06: 8D 03 00
  CMP #$FF                              ; $BD09: C9 FF
  BNE @AllyFound                        ; $BD0B: D0 01
  RTS                                   ; $BD0D: 60
@AllyFound:
  LDA $0003                             ; $BD0E: AD 03 00
  CMP $0002                             ; $BD11: CD 02 00
  BNE @MarkNotAtWar                     ; $BD14: D0 12
  LDA $0003                             ; $BD16: AD 03 00
  JSR B1F_GetOfficerRecordAddr          ; $BD19: 20 D7 F2
  LDY #$0B                              ; $BD1C: A0 0B
  LDA ($00),Y                           ; $BD1E: B1 00
  ORA #$03                              ; $BD20: 09 03
  STA ($00),Y                           ; $BD22: 91 00
  INX                                   ; $BD24: E8
  JMP @ScanAllies                       ; $BD25: 4C 03 BD
@MarkNotAtWar:
  JSR B1F_GetOfficerRecordAddr          ; $BD28: 20 D7 F2
  LDY #$0B                              ; $BD2B: A0 0B
  LDA ($00),Y                           ; $BD2D: B1 00
  AND #$FC                              ; $BD2F: 29 FC
  STA ($00),Y                           ; $BD31: 91 00
  LDY #$30                              ; $BD33: A0 30
  JSR B1F_SwitchBank8_A               ; $BD35: 20 66 F2
  LDA battle_province_idx                             ; $BD38: AD 0E 05
  ASL                                   ; $BD3B: 0A
  ASL                                   ; $BD3C: 0A
  ASL                                   ; $BD3D: 0A
  STA $0002                             ; $BD3E: 8D 02 00
  JSR B1F_RandomMod8                             ; $BD41: 20 56 E8  ; random or computed value
  CLC                                   ; $BD44: 18
  ADC $0002                             ; $BD45: 6D 02 00
  TAY                                   ; $BD48: A8
  LDA $9D72,Y                           ; $BD49: B9 72 9D
  BPL @StoreCoord                       ; $BD4C: 10 03
  LDA battle_province_idx                             ; $BD4E: AD 0E 05
@StoreCoord:
  LDY #$05                              ; $BD51: A0 05
  STA ($00),Y                           ; $BD53: 91 00
  INX                                   ; $BD55: E8
  JMP @ScanAllies                       ; $BD56: 4C 03 BD
;-------------------------------------------------------------------------------
; Phase 2: BattleExecute
; Calls CollectUnitsBySide to build $6FA1 unit list, then FrontloadFactionUnit
; to position current faction's unit, then enters BattleUnitMatcher.
;-------------------------------------------------------------------------------
@BattleExecute:
  JSR CollectUnitsBySide                ; $BD59: 20 CD BD
  JSR FrontloadFactionUnit              ; $BD5C: 20 55 BE
  LDA #$00                              ; $BD5F: A9 00
  STA $0004                             ; $BD61: 8D 04 00
  JMP BattleUnitMatcher                 ; $BD64: 4C 6D BC
;-------------------------------------------------------------------------------
; Phase 2 alt: BattleExecute (defender side / $BD67)
; Similar to $BD59 but also handles $052A faction target.
; Searches $0664 for $FF slot before calling FindDefenderMatch.
;-------------------------------------------------------------------------------
@BattleExecuteAlt:
  JSR CollectUnitsBySide                ; $BD67: 20 CD BD
  JSR FrontloadFactionUnit              ; $BD6A: 20 55 BE
  LDA battle_target_province                             ; $BD6D: AD 2A 05
  STA $0002                             ; $BD70: 8D 02 00
  JSR B1F_GetProvinceRecordAddr         ; $BD73: 20 AF F2
  LDY #$11                              ; $BD76: A0 11
@SearchSlot:
  LDA ($00),Y                           ; $BD78: B1 00
  CMP #$FF                              ; $BD7A: C9 FF
  BEQ @AltFoundSlot                   ; $BD7C: F0 08
  INY                                   ; $BD7E: C8
  CPY #$1B                              ; $BD7F: C0 1B
  BCC @SearchSlot                       ; $BD81: 90 F5
@AltJumpMatcher:
  JMP BattleUnitMatcher                 ; $BD83: 4C 6D BC
@AltFoundSlot:
  STY $0003                             ; $BD86: 8C 03 00
  LDA #$00                              ; $BD89: A9 00
  STA $0004                             ; $BD8B: 8D 04 00
  JSR FindDefenderMatch                 ; $BD8E: 20 96 BD
  CPX #$FF                              ; $BD91: E0 FF
  BNE @AltJumpMatcher                   ; $BD93: D0 EE
  RTS                                   ; $BD95: 60
;-------------------------------------------------------------------------------
; FindDefenderMatch - Find matching defender unit for attacker officer
; $0002 = attacker officer ID. Searches defender faction roster ($0664 range)
; via $F2AF lookup. If match found, swaps in $6FA1 list.
; Returns X = index past last written, or X = $FF on failure.
;-------------------------------------------------------------------------------
FindDefenderMatch:
  LDA $0002                             ; $BD96: AD 02 00
  JSR B1F_GetProvinceRecordAddr         ; $BD99: 20 AF F2
  LDY $0003                             ; $BD9C: AC 03 00
  LDX $0004                             ; $BD9F: AE 04 00
@IterUnitList:
  LDA officer_state_table,X                           ; $BDA2: BD A1 6F
  CMP #$FF                              ; $BDA5: C9 FF
  BNE @MatchFound                       ; $BDA7: D0 02
  TAX                                   ; $BDA9: AA  ; X = $FF → failure
  RTS                                   ; $BDAA: 60
@MatchFound:
  CMP battle_target_officer                             ; $BDAB: CD 2B 05
  BNE @SearchNext                       ; $BDAE: D0 08
  PHA                                   ; $BDB0: 48
  LDA $0002                             ; $BDB1: AD 02 00
  STA battle_target_param                             ; $BDB4: 8D 2C 05
  PLA                                   ; $BDB7: 68
@SearchNext:
  STA ($00),Y                           ; $BDB8: 91 00
  INX                                   ; $BDBA: E8
  INY                                   ; $BDBB: C8
  CPY #$1B                              ; $BDBC: C0 1B
  BCC @SearchNext                       ; $BDBE: 90 E2
  LDA officer_state_table,X                           ; $BDC0: BD A1 6F
  CMP #$FF                              ; $BDC3: C9 FF
  BNE @SaveCursor                       ; $BDC5: D0 02
  TAX                                   ; $BDC7: AA
  RTS                                   ; $BDC8: 60
@SaveCursor:
  STX $0004                             ; $BDC9: 8E 04 00
  RTS                                   ; $BDCC: 60
;-------------------------------------------------------------------------------
; CollectUnitsBySide - Collect units from $0628/$0664/$6F47 into $6FA1
; Based on $0504 sign bit, collects defender/attacker units first,
; then opposite side, then reserves ($6F47). Terminates with $FF.
;-------------------------------------------------------------------------------
CollectUnitsBySide:
  LDY #$00                              ; $BDCD: A0 00
  LDX #$00                              ; $BDCF: A2 00
  LDA battle_side_flag                             ; $BDD1: AD 04 05
  BPL @Side2Start                       ; $BDD4: 10 04
  LDY #$80                              ; $BDD6: A0 80
  LDX #$0A                              ; $BDD8: A2 0A
@Side2Start:
  STY $0010                             ; $BDDA: 8C 10 00
  TXA                                   ; $BDDD: 8A
  CLC                                   ; $BDDE: 18
  ADC #$0A                              ; $BDDF: 69 0A
  STA $0011                             ; $BDE1: 8D 11 00
  LDY #$00                              ; $BDE4: A0 00
@CollectLoop1:
  LDA unit_army_array,X                           ; $BDE6: BD 28 06
  CMP #$FF                              ; $BDE9: C9 FF
  BEQ @CollectNext1                     ; $BDEB: F0 0E
  AND #$80                              ; $BDED: 29 80
  CMP $0010                             ; $BDEF: CD 10 00
  BNE @CollectNext1                     ; $BDF2: D0 07
  LDA battle_roster,X                           ; $BDF4: BD 64 06
  STA officer_state_table,Y                           ; $BDF7: 99 A1 6F
  INY                                   ; $BDFA: C8
@CollectNext1:
  INX                                   ; $BDFB: E8
  CPX $0011                             ; $BDFC: EC 11 00
  BCC @CollectLoop1                     ; $BDFF: 90 E5
  CPX #$0A                              ; $BE01: E0 0A
  BEQ @Side2End                         ; $BE03: F0 02
  LDX #$00                              ; $BE05: A2 00
@Side2End:
  TXA                                   ; $BE07: 8A
  CLC                                   ; $BE08: 18
  ADC #$0A                              ; $BE09: 69 0A
  STA $0011                             ; $BE0B: 8D 11 00
@CollectLoop2:
  LDA unit_army_array,X                           ; $BE0E: BD 28 06
  CMP #$FF                              ; $BE11: C9 FF
  BEQ @CollectNext2                     ; $BE13: F0 0E
  AND #$80                              ; $BE15: 29 80
  CMP $0010                             ; $BE17: CD 10 00
  BNE @CollectNext2                     ; $BE1A: D0 07
  LDA battle_roster,X                           ; $BE1C: BD 64 06
  STA officer_state_table,Y                           ; $BE1F: 99 A1 6F
  INY                                   ; $BE22: C8
@CollectNext2:
  INX                                   ; $BE23: E8
  CPX $0011                             ; $BE24: EC 11 00
  BCC @CollectLoop2                     ; $BE27: 90 E5
  LDX #$00                              ; $BE29: A2 00
  LDA battle_side_flag                             ; $BE2B: AD 04 05
  BPL @ReserveStart                     ; $BE2E: 10 02
  LDX #$14                              ; $BE30: A2 14
@ReserveStart:
  TXA                                   ; $BE32: 8A
  CLC                                   ; $BE33: 18
  ADC #$14                              ; $BE34: 69 14
  STA $0011                             ; $BE36: 8D 11 00
@CollectReserves:
  LDA reserve_units,X                           ; $BE39: BD 47 6F
  CMP #$FF                              ; $BE3C: C9 FF
  BEQ @CollectNextRes                   ; $BE3E: F0 04
  STA officer_state_table,Y                           ; $BE40: 99 A1 6F
  INY                                   ; $BE43: C8
@CollectNextRes:
  INX                                   ; $BE44: E8
  CPX $0011                             ; $BE45: EC 11 00
  BCC @CollectReserves                  ; $BE48: 90 EF
@FillTerminator:
  LDA #$FF                              ; $BE4A: A9 FF
  STA officer_state_table,Y                           ; $BE4C: 99 A1 6F
  INY                                   ; $BE4F: C8
  CPY #$15                              ; $BE50: C0 15
  BCC @FillTerminator                   ; $BE52: 90 F6
  RTS                                   ; $BE54: 60
;-------------------------------------------------------------------------------
; FrontloadFactionUnit - Find current faction's unit in $0664, swap to $6FA1[0]
;-------------------------------------------------------------------------------
FrontloadFactionUnit:
  LDY #$00                              ; $BE55: A0 00
  LDA battle_side_flag                             ; $BE57: AD 04 05
  BPL @FrontSearch                      ; $BE5A: 10 02
  LDY #$0A                              ; $BE5C: A0 0A
@FrontSearch:
  LDA battle_roster,Y                           ; $BE5E: B9 64 06
  CMP #$FF                              ; $BE61: C9 FF
  BNE @FrontFound                       ; $BE63: D0 01
  RTS                                   ; $BE65: 60
@FrontFound:
  STA $0002                             ; $BE66: 8D 02 00
  LDY #$00                              ; $BE69: A0 00
@FrontScan:
  LDA officer_state_table,Y                           ; $BE6B: B9 A1 6F
  CMP #$FF                              ; $BE6E: C9 FF
  BEQ @FrontNotFound                    ; $BE70: F0 18
  CMP $0002                             ; $BE72: CD 02 00
  BNE @FrontNotFound                    ; $BE75: D0 13
  LDA officer_state_table                             ; $BE77: AD A1 6F
  STA $0003                             ; $BE7A: 8D 03 00
  LDA $0002                             ; $BE7D: AD 02 00
  STA officer_state_table                             ; $BE80: 8D A1 6F
  LDA $0003                             ; $BE83: AD 03 00
  STA officer_state_table,Y                           ; $BE86: 99 A1 6F
  RTS                                   ; $BE89: 60
@FrontNotFound:
  INY                                   ; $BE8A: C8
  CPY #$14                              ; $BE8B: C0 14
  BCC @FrontScan                        ; $BE8D: 90 DC
  RTS                                   ; $BE8F: 60
;-------------------------------------------------------------------------------
; PopulateOfficerArrays - Clear $042C/$0550 and populate from $9D72 table
; Initializes 11 entries each to $FF. Then iterates faction officer table
; ($9D72 + faction*8), adding matching officers to arrays.
;-------------------------------------------------------------------------------
PopulateOfficerArrays:
  LDY #$0A                              ; $BE90: A0 0A
  LDA #$FF                              ; $BE92: A9 FF
@ClearArrays:
  STA action_result_lo,Y                           ; $BE94: 99 2C 04
  STA unit_ally_counts,Y                           ; $BE97: 99 50 05
  DEY                                   ; $BE9A: 88
  BPL @ClearArrays                      ; $BE9B: 10 F7
  LDA battle_faction_pair                             ; $BE9D: AD 07 05
  LDY battle_side_flag                             ; $BEA0: AC 04 05
  BPL @GetMatchFaction                  ; $BEA3: 10 04
  LSR                                   ; $BEA5: 4A
  LSR                                   ; $BEA6: 4A
  LSR                                   ; $BEA7: 4A
  LSR                                   ; $BEA8: 4A
@GetMatchFaction:
  AND #$0F                              ; $BEA9: 29 0F
  STA $0012                             ; $BEAB: 8D 12 00
  LDY #$30                              ; $BEAE: A0 30
  JSR B1F_SwitchBank8_B               ; $BEB0: 20 5F F2
  LDA battle_province_idx                             ; $BEB3: AD 0E 05
  ASL                                   ; $BEB6: 0A
  ASL                                   ; $BEB7: 0A
  ASL                                   ; $BEB8: 0A
  TAX                                   ; $BEB9: AA
  LDA #$00                              ; $BEBA: A9 00
  STA $0015                             ; $BEBC: 8D 15 00
  STA $0016                             ; $BEBF: 8D 16 00
@PopIter:
  LDA $9D72,X                           ; $BEC2: BD 72 9D
  BPL @PopEnd                           ; $BEC5: 10 01
@PopEnd:
  RTS                                   ; $BEC7: 60
@PopLoop:
  STA $0013                             ; $BEC8: 8D 13 00
  STX $0014                             ; $BECB: 8E 14 00
  JSR B1F_GetProvinceRecordAddr         ; $BECE: 20 AF F2
  LDY #$00                              ; $BED1: A0 00
  LDA ($00),Y                           ; $BED3: B1 00
  AND #$07                              ; $BED5: 29 07
  CMP #$07                              ; $BED7: C9 07
  BEQ @PopMatch                         ; $BED9: F0 05
  CMP $0012                             ; $BEDB: CD 12 00
  BNE @PopNext                          ; $BEDE: D0 23
@PopMatch:
  LDA $0013                             ; $BEE0: AD 13 00
  LDY $0016                             ; $BEE3: AC 16 00
  STA action_result_lo,Y                           ; $BEE6: 99 2C 04
  LDY #$11                              ; $BEE9: A0 11
  LDX #$00                              ; $BEEB: A2 00
@CountAllies:
  LDA ($00),Y                           ; $BEED: B1 00
  CMP #$FF                              ; $BEEF: C9 FF
  BEQ @PopStore                         ; $BEF1: F0 06
  INX                                   ; $BEF3: E8
  INY                                   ; $BEF4: C8
  CPY #$1B                              ; $BEF5: C0 1B
  BCC @PopCount                         ; $BEF7: 90 F4
@PopStore:
  LDY $0016                             ; $BEF9: AC 16 00
  TXA                                   ; $BEFC: 8A
  STA unit_ally_counts,Y                           ; $BEFD: 99 50 05
  INC $0016                             ; $BF00: EE 16 00
@PopNext:
  LDX $0014                             ; $BF03: AE 14 00
  INX                                   ; $BF06: E8
  JMP @PopLoop                          ; $BF07: 4C C2 BE
;-------------------------------------------------------------------------------
; UpdateOfficerCoords - Post-battle coordinate update
; Checks $0514, computes turn-based value, reads threshold table at $C015.
; Updates officer coordinates via LoadCoordPair/FindNearestThreshold with clamping.
;-------------------------------------------------------------------------------
.proc UpdateOfficerCoords
  LDA battle_side_selector                             ; $BF0A: AD 14 05
  BEQ @CoordSkip                        ; $BF0D: F0 01
@CoordSkip:
  RTS                                   ; $BF0F: 60
@CoordMain:
  LDY #$30                              ; $BF10: A0 30
  JSR B1F_SwitchBank8_B               ; $BF12: 20 5F F2
  LDA battle_province_idx                             ; $BF15: AD 0E 05
  JSR B1F_GetProvinceRecordAddr         ; $BF18: 20 AF F2
  LDA $0000                             ; $BF1B: AD 00 00
  STA $001A                             ; $BF1E: 8D 1A 00
  LDA $0001                             ; $BF21: AD 01 00
  STA $001B                             ; $BF24: 8D 1B 00
  JSR B1F_RandomByte                             ; $BF27: 20 7A E8
  AND #$01                              ; $BF2A: 29 01
  CLC                                   ; $BF2C: 18
  ADC #$01                              ; $BF2D: 69 01
  STA $0003                             ; $BF2F: 8D 03 00
  LDY #$06                              ; $BF32: A0 06
  JSR LoadCoordPair                     ; $BF34: 20 9E BF
  LDX #$00                              ; $BF37: A2 00
  LDA battle_round_counter                             ; $BF39: AD 06 05
  CMP #$06                              ; $BF3C: C9 06
  BCC @ReadThreshold                    ; $BF3E: 90 10
  INX                                   ; $BF40: E8
  CMP #$0B                              ; $BF41: C9 0B
  BCC @ReadThreshold                    ; $BF43: 90 0B
  INX                                   ; $BF45: E8
  CMP #$10                              ; $BF46: C9 10
  BCC @ReadThreshold                    ; $BF48: 90 06
  INX                                   ; $BF4A: E8
  CMP #$15                              ; $BF4B: C9 15
  BCC @ReadThreshold                    ; $BF4D: 90 01
  INX                                   ; $BF4F: E8
@ReadThreshold:
  LDA TurnThresholds,X                   ; $BF50: BD 15 C0
  STA $0010                             ; $BF53: 8D 10 00
  LDA $0010                             ; $BF56: AD 10 00
  STA $0003                             ; $BF59: 8D 03 00
  LDY #$08                              ; $BF5C: A0 08
  JSR LoadCoordPair                     ; $BF5E: 20 9E BF
  LDA $0010                             ; $BF61: AD 10 00
  STA $0003                             ; $BF64: 8D 03 00
  LDY #$0E                              ; $BF67: A0 0E
  JSR LoadCoordPair                     ; $BF69: 20 9E BF
  LDA $0010                             ; $BF6C: AD 10 00
  STA $0003                             ; $BF6F: 8D 03 00
  LDY #$0B                              ; $BF72: A0 0B
  LDA ($1A),Y                           ; $BF74: B1 1A
  STA $0000                             ; $BF76: 8D 00 00
  LDA #$00                              ; $BF79: A9 00
  STA $0001                             ; $BF7B: 8D 01 00
  STA $0002                             ; $BF7E: 8D 02 00
  JSR @PushY                            ; $BF81: 20 B3 BF
  LDY #$02                              ; $BF84: A0 02
  JSR FindNearestThreshold              ; $BF86: 20 EC BF
  STA $0003                             ; $BF89: 8D 03 00
  LDY #$02                              ; $BF8C: A0 02
  JSR LoadCoordPair                     ; $BF8E: 20 9E BF
  LDY #$04                              ; $BF91: A0 04
  JSR FindNearestThreshold              ; $BF93: 20 EC BF
  STA $0003                             ; $BF96: 8D 03 00
  LDY #$04                              ; $BF99: A0 04
  JMP LoadCoordPair                     ; $BF9B: 4C 9E BF
;-------------------------------------------------------------------------------
; LoadCoordPair - Load 16-bit coord from ($1A)+Y into $0000/$0001
;-------------------------------------------------------------------------------
LoadCoordPair:
  TYA                                   ; $BF9E: 98
  PHA                                   ; $BF9F: 48
  LDA ($1A),Y                           ; $BFA0: B1 1A
  STA $0000                             ; $BFA2: 8D 00 00
  INY                                   ; $BFA5: C8
  LDA ($1A),Y                           ; $BFA6: B1 1A
  STA $0001                             ; $BFA8: 8D 01 00
  LDA #$00                              ; $BFAB: A9 00
  STA $0002                             ; $BFAD: 8D 02 00
  JMP @ComputeCoord                     ; $BFB0: 4C B5 BF
@PushY:
  TYA                                   ; $BFB3: 98
  PHA                                   ; $BFB4: 48
@ComputeCoord:
  LDA #$0A                              ; $BFB5: A9 0A
  SEC                                   ; $BFB7: 38
  SBC $0003                             ; $BFB8: ED 03 00
  STA $0003                             ; $BFBB: 8D 03 00
  JSR B1F_MathMul24x8                             ; $BFBE: 20 E9 EB
  LDA $0006                             ; $BFC1: AD 06 00
  STA $0001                             ; $BFC4: 8D 01 00
  LDA $0007                             ; $BFC7: AD 07 00
  STA $0002                             ; $BFCA: 8D 02 00
  LDA #$0A                              ; $BFCD: A9 0A
  STA $0003                             ; $BFCF: 8D 03 00
  LDA #$00                              ; $BFD2: A9 00
  STA $0004                             ; $BFD4: 8D 04 00
  JSR B1F_MathDiv16                             ; $BFD7: 20 7C EA
  PLA                                   ; $BFDA: 68
  TAY                                   ; $BFDB: A8
  LDA $0001                             ; $BFDC: AD 01 00
  STA ($1A),Y                           ; $BFDF: 91 1A
  CPY #$0B                              ; $BFE1: C0 0B
  BEQ @DoneCoord                        ; $BFE3: F0 06
  INY                                   ; $BFE5: C8
  LDA $0002                             ; $BFE6: AD 02 00
  STA ($1A),Y                           ; $BFE9: 91 1A
@DoneCoord:
  RTS                                   ; $BFEB: 60
;-------------------------------------------------------------------------------
; FindNearestThreshold - Search $C01A table for nearest 16-bit match
; Returns index/2 in X.
;-------------------------------------------------------------------------------
FindNearestThreshold:
  LDA ($1A),Y                           ; $BFEC: B1 1A
  STA $0000                             ; $BFEE: 8D 00 00
  INY                                   ; $BFF1: C8
  LDA ($1A),Y                           ; $BFF2: B1 1A
  STA $0001                             ; $BFF4: 8D 01 00
  LDX #$00                              ; $BFF7: A2 00
@SearchThreshold:
  LDA SearchThresholdTable,X             ; $BFF9: BD 1A C0
  SEC                                   ; $BFFC: 38
  SBC $0000                             ; $BFFD: ED 00 00

.segment "CODE_BANK09"

  LDA SearchThresholdTable+1,X           ; $C000: BD 1B C0
  SBC $0001                             ; $C003: ED 01 00
  BCC @ThresholdResult                  ; $C006: 90 06
  INX                                   ; $C008: E8
  INX                                   ; $C009: E8
  CPX #$08                              ; $C00A: E0 08
  BCC @SearchThreshold                  ; $C00C: 90 EB
@ThresholdResult:
  TXA                                   ; $C00E: 8A
  LSR                                   ; $C00F: 4A
  TAX                                   ; $C010: AA
  LDA ThresholdResultTable,X             ; $C011: BD 22 C0
  RTS                                   ; $C014: 60
;-------------------------------------------------------------------------------
; TurnThresholds - Game turn threshold values for $BF50 lookup
; Indexed by $0506/5 to determine number of coordinate updates.
;-------------------------------------------------------------------------------
TurnThresholds:
  .byte $01,$02,$03,$04,$06             ; $C015: turn index thresholds
SearchThresholdTable:
  .byte $F5,$01,$E8,$03,$B8,$0B,$88,$13 ; $C01A: 16-bit word thresholds
ThresholdResultTable:
  .byte $05,$06,$07,$08,$09             ; $C022: result values
;-------------------------------------------------------------------------------
; ApplyCoordDeltas - Apply coordinate deltas to officer records
; Applies deltas from $0522-$0527 to officer coords, with clamping.
; Handles both primary ($050E) and secondary ($052B/$052C) targets.
;-------------------------------------------------------------------------------
ApplyCoordDeltas:
  LDY #$30                              ; $C027: A0 30
  JSR B1F_SwitchBank8_B               ; $C029: 20 5F F2
  LDA battle_province_idx                             ; $C02C: AD 0E 05
  JSR B1F_GetProvinceRecordAddr         ; $C02F: 20 AF F2
  LDA battle_side_selector                             ; $C032: AD 14 05
  ASL                                   ; $C035: 0A
  EOR #$02                              ; $C036: 49 02
  TAX                                   ; $C038: AA
  JSR @ApplyCoordDelta                  ; $C039: 20 7A C0
  LDY #$31                              ; $C03C: A0 31
  JSR B1F_SwitchBank8_B               ; $C03E: 20 5F F2
  LDA battle_target_officer                             ; $C041: AD 2B 05
  CMP #$FF                              ; $C044: C9 FF
  BEQ @UsePrimary                       ; $C046: F0 0F
  JSR B1F_GetOfficerRecordAddr          ; $C048: 20 D7 F2
  LDY #$0B                              ; $C04B: A0 0B
  LDA ($00),Y                           ; $C04D: B1 00
  AND #$03                              ; $C04F: 29 03
  BEQ @UsePrimary                       ; $C051: F0 04
  CMP #$03                              ; $C053: C9 03
  BNE @UseSecondary                     ; $C055: D0 13
@UsePrimary:
  LDY #$30                              ; $C057: A0 30
  JSR B1F_SwitchBank8_B               ; $C059: 20 5F F2
  LDA battle_province_idx                             ; $C05C: AD 0E 05
  JSR B1F_GetProvinceRecordAddr         ; $C05F: 20 AF F2
  LDA battle_side_selector                             ; $C062: AD 14 05
  ASL                                   ; $C065: 0A
  TAX                                   ; $C066: AA
  JMP @ApplyCoordDelta                  ; $C067: 4C 7A C0
@UseSecondary:
  LDY #$30                              ; $C06A: A0 30
  JSR B1F_SwitchBank8_B               ; $C06C: 20 5F F2
  LDA battle_target_param                             ; $C06F: AD 2C 05
  JSR B1F_GetProvinceRecordAddr         ; $C072: 20 AF F2
  LDA battle_side_selector                             ; $C075: AD 14 05
  ASL                                   ; $C078: 0A
  TAX                                   ; $C079: AA
@ApplyCoordDelta:
  LDY #$02                              ; $C07A: A0 02
  LDA ($00),Y                           ; $C07C: B1 00
  CLC                                   ; $C07E: 18
  ADC battle_stat_b_lo,X                           ; $C07F: 7D 26 05
  STA ($00),Y                           ; $C082: 91 00
  INY                                   ; $C084: C8
  LDA ($00),Y                           ; $C085: B1 00
  ADC battle_stat_b_hi,X                           ; $C087: 7D 27 05
  STA ($00),Y                           ; $C08A: 91 00
  LDY #$02                              ; $C08C: A0 02
  JSR @ClampCoord                       ; $C08E: 20 A5 C0
  LDY #$04                              ; $C091: A0 04
  LDA ($00),Y                           ; $C093: B1 00
  CLC                                   ; $C095: 18
  ADC battle_stat_a_lo,X                           ; $C096: 7D 22 05
  STA ($00),Y                           ; $C099: 91 00
  INY                                   ; $C09B: C8
  LDA ($00),Y                           ; $C09C: B1 00
  ADC battle_stat_a_hi,X                           ; $C09E: 7D 23 05
  STA ($00),Y                           ; $C0A1: 91 00
  LDY #$04                              ; $C0A3: A0 04
;-------------------------------------------------------------------------------
; ClampCoord - Clamp 16-bit coordinate to max ($0F27)
; Subtracts $1027 from coord; if negative, cap at $0F27.
;-------------------------------------------------------------------------------
@ClampCoord:
  LDA ($00),Y                           ; $C0A5: B1 00
  SEC                                   ; $C0A7: 38
  SBC #$10                              ; $C0A8: E9 10
  INY                                   ; $C0AA: C8
  LDA ($00),Y                           ; $C0AB: B1 00
  SBC #$27                              ; $C0AD: E9 27
  BCC @ClampDone                        ; $C0AF: 90 09
  LDA #$27                              ; $C0B1: A9 27
  STA ($00),Y                           ; $C0B3: 91 00
  DEY                                   ; $C0B5: 88
  LDA #$0F                              ; $C0B6: A9 0F
  STA ($00),Y                           ; $C0B8: 91 00
@ClampDone:
  RTS                                   ; $C0BA: 60
.endproc  ; UpdateOfficerCoords
.endproc  ; BattlePhaseProcess
;===============================================================================
; AiOfficerActionDispatch - AI Officer Action State Machine (battle)
; Entry via JMP stub at $A009. Dispatches on $0501 (phase index) through
; B1F_CallbackDispatcher with an inline 10-entry jump table (states $00-$09).
; $0500 holds the command id, $0501 the phase within that command.
; $0081 is the command-step flag byte from the battle main loop:
;   bit0 = execute step, bit1 = confirm/continue step.
; Each handler performs one phase of a battle action (panel drawing, stat
; transfers, officer stat checks, formation setup/render, tile effects),
; then either RTS to wait for the next callback or loads a UI mode into A
; and JMPs B1F_SetUI2/B1F_SetUI5 to advance the battle presentation.
; Side stat pairs (X=0 near side, X=2 far side, from GetBattleSideOffset):
;   $0522/$0523 = stat A, $0526/$0527 = stat B (both clamped to 0..9999).
; States:
;   0 State0_ShowActionPanel        draw panel, parse action parameters
;   1 State1_GrowStatA              raise stat A by delta, lower stat B
;   2 State2_GrowStatB              raise stat B by scaled, lower stat A
;   3 State3_CheckOfficerStat       compare officer runtime/ROM record byte 0
;   4 State4_ConsumeAndRestore      spend 50 stat B, restore officer stat
;   5 State5_SetupFormation         expand formation id into 4 unit slots
;   6 State6_RenderFormationSprites write formation sprites to $0380 buffer
;   7 State7_ApplyTileEffect        apply selected tile / special tile check
;   8 State8_WaitForNextCommand     wait for animation, idle until command
;   9 State9_RouteNextAction        final routing by $0470 mode
;===============================================================================
.proc AiOfficerActionDispatch
; --- Proc-local RAM (action panel work area) ---
tile_cell_slots        = $044C  ; formation slot tile cells / selected tile
route_mode             = $0470  ; state 9 route mode
tile_result_flag       = $0471  ; tile apply result flag ($11 = out of reach)
action_work_0          = $048B  ; action work area byte 0 (cleared)
action_work_1          = $048C  ; action work area byte 1 (cleared)
action_work_2          = $048D  ; action work area byte 2 (cleared)
action_delta_lo        = $048E  ; stat A delta lo
action_delta_hi        = $048F  ; stat A delta hi
stat_delta_lo          = $0490  ; computed delta lo (ceil(statB*pct/100))
stat_delta_hi          = $0491  ; computed delta hi
action_percent         = $0492  ; action percent parameter
special_tile_latch     = $6FE1  ; one-shot special tile trigger latch
  LDA battle_scene_phase                             ; $C0BB: AD 01 05  ; phase index
  JSR B1F_CallbackDispatcher            ; $C0BE: 20 DE EA  ; dispatch on $0501
; --- B1F_CallbackDispatcher inline jump table (10 entries, A=$0501, Y=$00) ---
  .word State0_ShowActionPanel          ; $C0C1: D5 C0  ; state 0
  .word State1_GrowStatA                ; $C0C3: EB C1  ; state 1
  .word State2_GrowStatB                ; $C0C5: C0 C2  ; state 2
  .word State3_CheckOfficerStat         ; $C0C7: 92 C3  ; state 3
  .word State4_ConsumeAndRestore        ; $C0C9: E9 C3  ; state 4
  .word State5_SetupFormation           ; $C0CB: B8 C4  ; state 5
  .word State6_RenderFormationSprites   ; $C0CD: 43 C5  ; state 6
  .word State7_ApplyTileEffect          ; $C0CF: 2E C6  ; state 7
  .word State8_WaitForNextCommand       ; $C0D1: B0 C7  ; state 8
  .word State9_RouteNextAction          ; $C0D3: C8 C7  ; state 9
;-------------------------------------------------------------------------------
; State 0 - Show the action panel and parse command parameters.
; Draws the panel from State0PanelLayout via B1F_MenuStep2 /
; B1F_PointerTableLookup, then waits for the $0081 command flags:
;   bit0 -> @ExecuteAction: swap in bank $30 (B1F_SwitchBank8_B), fetch the
;           action parameter record for action index $050E from the $8FC0
;           pointer table into ($0002). With submode $0012 != 0 the full
;           stat A amount is used directly ($0490) -> state 2 (UI $AA);
;           with $0012 == 0 the percent path computes
;           ceil(statB * percent / 100) into $0490 -> state 1 (UI $A9).
;   bit1 -> reset command ($0500/$0501 = 0).
;-------------------------------------------------------------------------------
State0_ShowActionPanel:
  LDA #$DE                              ; $C0D5: A9 DE
  STA $0010                             ; $C0D7: 8D 10 00
  LDA #$C1                              ; $C0DA: A9 C1
  STA $0011                             ; $C0DC: 8D 11 00
  LDA #$00                              ; $C0DF: A9 00
  STA $0012                             ; $C0E1: 8D 12 00  ; submode = 0
  JSR B1F_MenuStep2                     ; $C0E4: 20 1E ED  ; draw panel (step 2)
  LDA #$E2                              ; $C0E7: A9 E2
  STA $0010                             ; $C0E9: 8D 10 00
  LDA #$C1                              ; $C0EC: A9 C1
  STA $0011                             ; $C0EE: 8D 11 00
  LDA #$E6                              ; $C0F1: A9 E6
  STA $0000                             ; $C0F3: 8D 00 00
  LDA #$C1                              ; $C0F6: A9 C1
  STA $0001                             ; $C0F8: 8D 01 00
  LDA $0012                             ; $C0FB: AD 12 00
  JSR B1F_PointerTableLookup            ; $C0FE: 20 F5 ED  ; sprite write, entry $0012
  JSR CheckAnimQueueDone                ; $C101: 20 48 C9
  BCC @Wait                             ; $C104: 90 11     ; animation still busy
  LDA $0081                             ; $C106: AD 81 00  ; command-step flags
  LSR                                   ; $C109: 4A
  BCS @ExecuteAction                    ; $C10A: B0 0C     ; bit0: execute step
  LSR                                   ; $C10C: 4A
  BCC @Wait                             ; $C10D: 90 08     ; bit1 clear: wait
  LDA #$00                              ; $C10F: A9 00
  STA battle_scene_id                             ; $C111: 8D 00 05  ; clear command id
  STA battle_scene_phase                             ; $C114: 8D 01 05  ; back to phase 0
@Wait:
  RTS                                   ; $C117: 60
@ExecuteAction:
  LDA #$00                              ; $C118: A9 00
  STA action_work_0                             ; $C11A: 8D 8B 04  ; clear action work area
  STA action_work_1                             ; $C11D: 8D 8C 04
  STA action_work_2                             ; $C120: 8D 8D 04
  STA action_delta_lo                             ; $C123: 8D 8E 04
  STA action_delta_hi                             ; $C126: 8D 8F 04
  LDY #$30                              ; $C129: A0 30     ; PRG bank for param table
  JSR B1F_SwitchBank8_B                 ; $C12B: 20 5F F2
  LDA battle_province_idx                             ; $C12E: AD 0E 05  ; action index
  ASL                                   ; $C131: 0A        ; *2 (word entries)
  CLC                                   ; $C132: 18
  ADC #$C0                              ; $C133: 69 C0
  STA $0002                             ; $C135: 8D 02 00  ; -> $8FC0 parameter table
  LDA #$8F                              ; $C138: A9 8F
  ADC #$00                              ; $C13A: 69 00
  STA $0003                             ; $C13C: 8D 03 00
  JSR GetBattleSideOffset               ; $C13F: 20 3E C9  ; X = side * 2
  LDA $0012                             ; $C142: AD 12 00  ; submode
  BEQ @PercentPath                      ; $C145: F0 28
  LDA battle_stat_a_lo,X                           ; $C147: BD 22 05  ; direct path: stat A pair
  STA stat_delta_lo                             ; $C14A: 8D 90 04
  LDA battle_stat_a_hi,X                           ; $C14D: BD 23 05
  STA stat_delta_hi                             ; $C150: 8D 91 04
  LDY #$00                              ; $C153: A0 00
  LDA ($02),Y                           ; $C155: B1 02     ; param byte 0 -> percent
  STA action_percent                             ; $C157: 8D 92 04
  STA action_result_lo                             ; $C15A: 8D 2C 04  ; reported amount
  LDA #$00                              ; $C15D: A9 00
  STA action_result_hi                             ; $C15F: 8D 2D 04
  STA action_result_cnt                             ; $C162: 8D 2E 04
  LDA #$02                              ; $C165: A9 02
  STA battle_scene_phase                             ; $C167: 8D 01 05  ; continue in state 2
  LDA #$AA                              ; $C16A: A9 AA     ; UI mode $AA
  JMP B1F_SetUI2                        ; $C16C: 4C 83 F2
@PercentPath:
  LDY #$01                              ; $C16F: A0 01
  LDA ($02),Y                           ; $C171: B1 02     ; param byte 1 -> percent
  STA action_percent                             ; $C173: 8D 92 04
  STA action_result_lo                             ; $C176: 8D 2C 04
  LDA #$00                              ; $C179: A9 00
  STA action_result_hi                             ; $C17B: 8D 2D 04
  STA action_result_cnt                             ; $C17E: 8D 2E 04
  LDA battle_stat_b_lo,X                           ; $C181: BD 26 05  ; stat B pair = base value
  STA $0000                             ; $C184: 8D 00 00
  LDA battle_stat_b_hi,X                           ; $C187: BD 27 05
  STA $0001                             ; $C18A: 8D 01 00
  LDA #$00                              ; $C18D: A9 00
  STA $0002                             ; $C18F: 8D 02 00
  LDA action_percent                             ; $C192: AD 92 04
  STA $0003                             ; $C195: 8D 03 00  ; multiplier = percent
  JSR B1F_MathMul24x8                   ; $C198: 20 E9 EB  ; statB * percent
  LDA $0006                             ; $C19B: AD 06 00
  STA $0000                             ; $C19E: 8D 00 00
  LDA $0007                             ; $C1A1: AD 07 00
  STA $0001                             ; $C1A4: 8D 01 00
  LDA $0008                             ; $C1A7: AD 08 00
  STA $0002                             ; $C1AA: 8D 02 00
  LDA #$64                              ; $C1AD: A9 64
  STA $0003                             ; $C1AF: 8D 03 00  ; divisor = 100
  LDA #$00                              ; $C1B2: A9 00
  STA $0004                             ; $C1B4: 8D 04 00
  JSR B1F_MathDiv24                     ; $C1B7: 20 A5 EA  ; / 100
  LDA $0005                             ; $C1BA: AD 05 00  ; remainder
  BEQ @RoundDone                        ; $C1BD: F0 05
  LDA #$01                              ; $C1BF: A9 01
  STA $0005                             ; $C1C1: 8D 05 00  ; round up
@RoundDone:
  LDA $0000                             ; $C1C4: AD 00 00
  CLC                                   ; $C1C7: 18
  ADC $0005                             ; $C1C8: 6D 05 00
  STA stat_delta_lo                             ; $C1CB: 8D 90 04  ; delta = ceil(statB*pct/100)
  LDA $0001                             ; $C1CE: AD 01 00
  ADC #$00                              ; $C1D1: 69 00
  STA stat_delta_hi                             ; $C1D3: 8D 91 04
  INC battle_scene_phase                             ; $C1D6: EE 01 05  ; continue in state 1
  LDA #$A9                              ; $C1D9: A9 A9     ; UI mode $A9
  JMP B1F_SetUI2                        ; $C1DB: 4C 83 F2
; Action panel layout descriptor for state 0 (drawn by B1F_MenuStep2 above)
State0PanelLayout:
  .byte $00,$01,$FF,$FF,$C6,$47,$C6,$87,$00,$07,$00,$00,$80; $C1DE: 00 01 FF FF C6 47 C6 87 00 07 00 00 80
;-------------------------------------------------------------------------------
; State 1 - Grow stat A: apply the delta computed in state 0.
; Waits for the panel animation, runs the banked callback at $A003 (bank Y
; selects the overlay), then on $0081:
;   bit0 -> @ApplyGain: base = delta * 100 / percent (inverse of state 0's
;           percent path). Stat B ($0526) is lowered by base (clamped at 0),
;           stat A ($0522) is raised by the delta $048E (clamped at 9999).
;           $042C reports the delta, then state 8 (UI $AB).
;   bit1 -> step back to state 0 (clear $0424/$0425, UI $A8).
;-------------------------------------------------------------------------------
State1_GrowStatA:
  JSR CheckAnimQueueDone                ; $C1EB: 20 48 C9
  BCC @Wait                             ; $C1EE: 90 2A     ; animation still busy
  LDA #$D0                              ; $C1F0: A9 D0
  STA $031C                             ; $C1F2: 8D 1C 03
  LDA #$24                              ; $C1F5: A9 24
  STA $031D                             ; $C1F7: 8D 1D 03
  LDY #$3B                              ; $C1FA: A0 3B     ; target bank
  JSR B1F_BankedCallbackTrampoline      ; $C1FC: 20 07 EE
  .word $A003                           ; $C1FF: 03 A0 (BankedCallbackTrampoline target)
  LDA $0081                             ; $C201: AD 81 00  ; command-step flags
  LSR                                   ; $C204: 4A
  BCS @ApplyGain                        ; $C205: B0 14     ; bit0: execute step
  LSR                                   ; $C207: 4A
  BCC @Wait                             ; $C208: 90 10     ; bit1 clear: wait
  DEC battle_scene_phase                             ; $C20A: CE 01 05  ; step back to state 0
  LDA #$00                              ; $C20D: A9 00
  STA menu_cursor_col                             ; $C20F: 8D 24 04
  STA menu_cursor_page                             ; $C212: 8D 25 04
  LDA #$A8                              ; $C215: A9 A8     ; UI mode $A8
  JMP B1F_SetUI2                        ; $C217: 4C 83 F2
@Wait:
  RTS                                   ; $C21A: 60
@ApplyGain:
  LDA action_delta_lo                             ; $C21B: AD 8E 04  ; delta pair
  STA $0000                             ; $C21E: 8D 00 00
  LDA action_delta_hi                             ; $C221: AD 8F 04
  STA $0001                             ; $C224: 8D 01 00
  LDA $0001                             ; $C227: AD 01 00
  BNE @ScaleToBase                      ; $C22A: D0 05
  LDA $0000                             ; $C22C: AD 00 00
  BEQ @Wait                             ; $C22F: F0 E9     ; zero delta: nothing to do
@ScaleToBase:
  LDA #$64                              ; $C231: A9 64
  STA $0003                             ; $C233: 8D 03 00  ; multiplier = 100
  LDA #$00                              ; $C236: A9 00
  STA $0002                             ; $C238: 8D 02 00
  JSR B1F_MathMul24x8                   ; $C23B: 20 E9 EB  ; delta * 100
  LDA $0006                             ; $C23E: AD 06 00
  STA $0000                             ; $C241: 8D 00 00
  LDA $0007                             ; $C244: AD 07 00
  STA $0001                             ; $C247: 8D 01 00
  LDA $0008                             ; $C24A: AD 08 00
  STA $0002                             ; $C24D: 8D 02 00
  LDA action_percent                             ; $C250: AD 92 04
  STA $0003                             ; $C253: 8D 03 00  ; divisor = percent
  LDA #$00                              ; $C256: A9 00
  STA $0004                             ; $C258: 8D 04 00
  JSR B1F_MathDiv24                     ; $C25B: 20 A5 EA  ; base = delta*100/percent
  JSR GetBattleSideOffset               ; $C25E: 20 3E C9  ; X = side * 2
  LDA battle_stat_b_lo,X                           ; $C261: BD 26 05  ; stat B -= base
  SEC                                   ; $C264: 38
  SBC $0000                             ; $C265: ED 00 00
  STA battle_stat_b_lo,X                           ; $C268: 9D 26 05
  LDA battle_stat_b_hi,X                           ; $C26B: BD 27 05
  SBC $0001                             ; $C26E: ED 01 00
  BCS @StatBClampDone                   ; $C271: B0 05
  LDA #$00                              ; $C273: A9 00
  STA battle_stat_b_lo,X                           ; $C275: 9D 26 05  ; clamp at 0
@StatBClampDone:
  STA battle_stat_b_hi,X                           ; $C278: 9D 27 05
  LDA battle_stat_a_lo,X                           ; $C27B: BD 22 05  ; stat A += delta
  CLC                                   ; $C27E: 18
  ADC action_delta_lo                             ; $C27F: 6D 8E 04
  STA battle_stat_a_lo,X                           ; $C282: 9D 22 05
  LDA battle_stat_a_hi,X                           ; $C285: BD 23 05
  ADC action_delta_hi                             ; $C288: 6D 8F 04
  STA battle_stat_a_hi,X                           ; $C28B: 9D 23 05
  LDA battle_stat_a_lo,X                           ; $C28E: BD 22 05  ; clamp at 9999 ($270F)
  SEC                                   ; $C291: 38
  SBC #$10                              ; $C292: E9 10
  LDA battle_stat_a_hi,X                           ; $C294: BD 23 05
  SBC #$27                              ; $C297: E9 27
  BCC @StatAClampDone                   ; $C299: 90 0A
  LDA #$0F                              ; $C29B: A9 0F
  STA battle_stat_a_lo,X                           ; $C29D: 9D 22 05
  LDA #$27                              ; $C2A0: A9 27
  STA battle_stat_a_hi,X                           ; $C2A2: 9D 23 05
@StatAClampDone:
  LDA action_delta_lo                             ; $C2A5: AD 8E 04  ; report the delta
  STA action_result_lo                             ; $C2A8: 8D 2C 04
  LDA action_delta_hi                             ; $C2AB: AD 8F 04
  STA action_result_hi                             ; $C2AE: 8D 2D 04
  LDA #$00                              ; $C2B1: A9 00
  STA action_result_cnt                             ; $C2B3: 8D 2E 04
  LDA #$08                              ; $C2B6: A9 08
  STA battle_scene_phase                             ; $C2B8: 8D 01 05  ; continue in state 8
  LDA #$AB                              ; $C2BB: A9 AB     ; UI mode $AB
  JMP B1F_SetUI2                        ; $C2BD: 4C 83 F2
;-------------------------------------------------------------------------------
; State 2 - Grow stat B: mirror of State1_GrowStatA.
; Waits for the panel animation, runs the banked callback at $A003, then on
; $0081:
;   bit0 -> @ApplyDrain: scaled = delta * percent / 100. Stat A ($0522) is
;           lowered by the delta $048E (clamped at 0), stat B ($0526) is
;           raised by scaled (clamped at 9999). $042C reports scaled,
;           then state 8 (UI $AC).
;   bit1 -> restart at state 0 (clear $0424/$0425, UI $A8).
;-------------------------------------------------------------------------------
State2_GrowStatB:
  JSR CheckAnimQueueDone                ; $C2C0: 20 48 C9
  BCC @Wait                             ; $C2C3: 90 2C     ; animation still busy
  LDA #$D0                              ; $C2C5: A9 D0
  STA $031C                             ; $C2C7: 8D 1C 03
  LDA #$24                              ; $C2CA: A9 24
  STA $031D                             ; $C2CC: 8D 1D 03
  LDY #$3B                              ; $C2CF: A0 3B     ; target bank
  JSR B1F_BankedCallbackTrampoline      ; $C2D1: 20 07 EE
  .word $A003                           ; $C2D4: 03 A0 (BankedCallbackTrampoline target)
  LDA $0081                             ; $C2D6: AD 81 00  ; command-step flags
  LSR                                   ; $C2D9: 4A
  BCS @ApplyDrain                       ; $C2DA: B0 16     ; bit0: execute step
  LSR                                   ; $C2DC: 4A
  BCC @Wait                             ; $C2DD: 90 12     ; bit1 clear: wait
  LDA #$00                              ; $C2DF: A9 00
  STA battle_scene_phase                             ; $C2E1: 8D 01 05  ; restart at state 0
  LDA #$00                              ; $C2E4: A9 00
  STA menu_cursor_col                             ; $C2E6: 8D 24 04
  STA menu_cursor_page                             ; $C2E9: 8D 25 04
  LDA #$A8                              ; $C2EC: A9 A8     ; UI mode $A8
  JMP B1F_SetUI2                        ; $C2EE: 4C 83 F2
@Wait:
  RTS                                   ; $C2F1: 60
@ApplyDrain:
  LDA action_delta_lo                             ; $C2F2: AD 8E 04  ; delta pair
  STA $0000                             ; $C2F5: 8D 00 00
  LDA action_delta_hi                             ; $C2F8: AD 8F 04
  STA $0001                             ; $C2FB: 8D 01 00
  LDA $0001                             ; $C2FE: AD 01 00
  BNE @ScaleDown                        ; $C301: D0 05
  LDA $0000                             ; $C303: AD 00 00
  BEQ @Wait                             ; $C306: F0 E9     ; zero delta: nothing to do
@ScaleDown:
  LDA action_percent                             ; $C308: AD 92 04
  STA $0003                             ; $C30B: 8D 03 00  ; multiplier = percent
  LDA #$00                              ; $C30E: A9 00
  STA $0002                             ; $C310: 8D 02 00
  JSR B1F_MathMul24x8                   ; $C313: 20 E9 EB  ; delta * percent
  LDA $0006                             ; $C316: AD 06 00
  STA $0000                             ; $C319: 8D 00 00
  LDA $0007                             ; $C31C: AD 07 00
  STA $0001                             ; $C31F: 8D 01 00
  LDA $0008                             ; $C322: AD 08 00
  STA $0002                             ; $C325: 8D 02 00
  LDA #$64                              ; $C328: A9 64
  STA $0003                             ; $C32A: 8D 03 00  ; divisor = 100
  LDA #$00                              ; $C32D: A9 00
  STA $0004                             ; $C32F: 8D 04 00
  JSR B1F_MathDiv24                     ; $C332: 20 A5 EA  ; scaled = delta*pct/100
  LDA $0000                             ; $C335: AD 00 00
  STA action_result_lo                             ; $C338: 8D 2C 04  ; report scaled amount
  LDA $0001                             ; $C33B: AD 01 00
  STA action_result_hi                             ; $C33E: 8D 2D 04
  JSR GetBattleSideOffset               ; $C341: 20 3E C9  ; X = side * 2
  LDA battle_stat_a_lo,X                           ; $C344: BD 22 05  ; stat A -= delta
  SEC                                   ; $C347: 38
  SBC action_delta_lo                             ; $C348: ED 8E 04
  STA battle_stat_a_lo,X                           ; $C34B: 9D 22 05
  LDA battle_stat_a_hi,X                           ; $C34E: BD 23 05
  SBC action_delta_hi                             ; $C351: ED 8F 04
  BCS @StatAClampDone                   ; $C354: B0 05
  LDA #$00                              ; $C356: A9 00
  STA battle_stat_a_lo,X                           ; $C358: 9D 22 05  ; clamp at 0
@StatAClampDone:
  STA battle_stat_a_hi,X                           ; $C35B: 9D 23 05
  LDA battle_stat_b_lo,X                           ; $C35E: BD 26 05  ; stat B += scaled
  CLC                                   ; $C361: 18
  ADC action_result_lo                             ; $C362: 6D 2C 04
  STA battle_stat_b_lo,X                           ; $C365: 9D 26 05
  LDA battle_stat_b_hi,X                           ; $C368: BD 27 05
  ADC action_result_hi                             ; $C36B: 6D 2D 04
  STA battle_stat_b_hi,X                           ; $C36E: 9D 27 05
  LDA battle_stat_b_lo,X                           ; $C371: BD 26 05  ; clamp at 9999 ($270F)
  SEC                                   ; $C374: 38
  SBC #$10                              ; $C375: E9 10
  LDA battle_stat_b_hi,X                           ; $C377: BD 27 05
  SBC #$27                              ; $C37A: E9 27
  BCC @StatBClampDone                   ; $C37C: 90 0A
  LDA #$0F                              ; $C37E: A9 0F
  STA battle_stat_b_lo,X                           ; $C380: 9D 26 05
  LDA #$27                              ; $C383: A9 27
  STA battle_stat_b_hi,X                           ; $C385: 9D 27 05
@StatBClampDone:
  LDA #$08                              ; $C388: A9 08
  STA battle_scene_phase                             ; $C38A: 8D 01 05  ; continue in state 8
  LDA #$AC                              ; $C38D: A9 AC     ; UI mode $AC
  JMP B1F_SetUI2                        ; $C38F: 4C 83 F2
;-------------------------------------------------------------------------------
; State 3 - Check officer stat against ROM baseline.
; Waits for the panel animation, draws the action marker (DrawActionMarker),
; then if either $0081 flag is set: officer id = $0664[$0509]; compares byte 0
; of the runtime officer record ($63C0 region) with byte 0 of the ROM record.
;   equal   -> state 8 (UI $B3), no change to apply.
;   changed -> $042C = $32 (50), clear $042D/$042E/$0424/$0425, state 4
;              (UI $B2).
;-------------------------------------------------------------------------------
State3_CheckOfficerStat:
  JSR CheckAnimQueueDone                ; $C392: 20 48 C9
  BCC @Wait                             ; $C395: 90 0A     ; animation still busy
  JSR DrawActionMarker                  ; $C397: 20 5A C9
  LDA $0081                             ; $C39A: AD 81 00
  AND #$03                              ; $C39D: 29 03     ; either command flag
  BNE @ReadRecords                      ; $C39F: D0 01
@Wait:
  RTS                                   ; $C3A1: 60
@ReadRecords:
  LDY battle_officer_slot                             ; $C3A2: AC 09 05  ; officer slot
  LDA battle_roster,Y                           ; $C3A5: B9 64 06  ; slot -> officer id
  STA $0010                             ; $C3A8: 8D 10 00
  JSR B1F_GetOfficerRecordAddr          ; $C3AB: 20 D7 F2  ; runtime record
  LDY #$00                              ; $C3AE: A0 00
  LDA ($00),Y                           ; $C3B0: B1 00     ; runtime byte 0
  STA $0011                             ; $C3B2: 8D 11 00
  LDA $0010                             ; $C3B5: AD 10 00
  JSR B1F_GetOfficerRomRecordAddr       ; $C3B8: 20 87 F3  ; ROM record
  LDY #$00                              ; $C3BB: A0 00
  LDA ($00),Y                           ; $C3BD: B1 00     ; ROM byte 0 (baseline)
  CMP $0011                             ; $C3BF: CD 11 00
  BNE @StatChanged                      ; $C3C2: D0 0A
  LDA #$08                              ; $C3C4: A9 08
  STA battle_scene_phase                             ; $C3C6: 8D 01 05  ; unchanged -> state 8
  LDA #$B3                              ; $C3C9: A9 B3     ; UI mode $B3
  JMP B1F_SetUI2                        ; $C3CB: 4C 83 F2
@StatChanged:
  LDA #$32                              ; $C3CE: A9 32     ; 50 units to restore
  STA action_result_lo                             ; $C3D0: 8D 2C 04
  LDA #$00                              ; $C3D3: A9 00
  STA action_result_hi                             ; $C3D5: 8D 2D 04
  STA action_result_cnt                             ; $C3D8: 8D 2E 04
  STA menu_cursor_col                             ; $C3DB: 8D 24 04
  STA menu_cursor_page                             ; $C3DE: 8D 25 04
  INC battle_scene_phase                             ; $C3E1: EE 01 05  ; continue in state 4
  LDA #$B2                              ; $C3E4: A9 B2     ; UI mode $B2
  JMP B1F_SetUI2                        ; $C3E6: 4C 83 F2
;-------------------------------------------------------------------------------
; State 4 - Consume stat B and restore the officer stat.
; Draws the panel from State4PanelLayout, waits for $0081:
;   bit0 -> @ApplyRestore (only when submode $0012 == 0):
;           if stat B ($0526/$0527) < 50 -> state 8 (UI $B0), not enough.
;           otherwise stat B -= 50; gain = 35 + (random mod 16, rerolled
;           until < 11); the officer runtime record byte 0 is raised by the
;           gain (clamped at the ROM baseline, excess removed from the gain),
;           then state 8 (UI $B4).
;   bit1 -> reset command ($0500/$0501 = 0).
;-------------------------------------------------------------------------------
State4_ConsumeAndRestore:
  LDA #$AB                              ; $C3E9: A9 AB
  STA $0010                             ; $C3EB: 8D 10 00
  LDA #$C4                              ; $C3EE: A9 C4
  STA $0011                             ; $C3F0: 8D 11 00
  LDA #$00                              ; $C3F3: A9 00
  STA $0012                             ; $C3F5: 8D 12 00  ; submode = 0
  JSR B1F_MenuStep2                     ; $C3F8: 20 1E ED  ; draw panel (step 2)
  LDA #$AF                              ; $C3FB: A9 AF
  STA $0010                             ; $C3FD: 8D 10 00
  LDA #$C4                              ; $C400: A9 C4
  STA $0011                             ; $C402: 8D 11 00
  LDA #$B3                              ; $C405: A9 B3
  STA $0000                             ; $C407: 8D 00 00
  LDA #$C4                              ; $C40A: A9 C4
  STA $0001                             ; $C40C: 8D 01 00
  LDA $0012                             ; $C40F: AD 12 00
  JSR B1F_PointerTableLookup            ; $C412: 20 F5 ED  ; sprite write, entry $0012
  JSR CheckAnimQueueDone                ; $C415: 20 48 C9
  BCC @Wait                             ; $C418: 90 11     ; animation still busy
  LDA $0081                             ; $C41A: AD 81 00  ; command-step flags
  LSR                                   ; $C41D: 4A
  BCS @ApplyRestore                     ; $C41E: B0 0C     ; bit0: execute step
  LSR                                   ; $C420: 4A
  BCC @Wait                             ; $C421: 90 08     ; bit1 clear: wait
@ResetCommand:
  LDA #$00                              ; $C423: A9 00
  STA battle_scene_id                             ; $C425: 8D 00 05  ; clear command id
  STA battle_scene_phase                             ; $C428: 8D 01 05  ; back to phase 0
@Wait:
  RTS                                   ; $C42B: 60
@ApplyRestore:
  LDA $0012                             ; $C42C: AD 12 00  ; submode
  BNE @ResetCommand                     ; $C42F: D0 F2
  JSR GetBattleSideOffset               ; $C431: 20 3E C9  ; X = side * 2
  LDA battle_stat_b_hi,X                           ; $C434: BD 27 05  ; stat B high byte
  BNE @Deduct50                         ; $C437: D0 11
  LDA battle_stat_b_lo,X                           ; $C439: BD 26 05  ; stat B low byte
  CMP #$32                              ; $C43C: C9 32     ; < 50 -> not enough
  BCS @Deduct50                         ; $C43E: B0 0A
  LDA #$08                              ; $C440: A9 08
  STA battle_scene_phase                             ; $C442: 8D 01 05  ; state 8
  LDA #$B0                              ; $C445: A9 B0     ; UI mode $B0
  JMP B1F_SetUI2                        ; $C447: 4C 83 F2
@Deduct50:
  LDA battle_stat_b_lo,X                           ; $C44A: BD 26 05  ; stat B -= 50
  SEC                                   ; $C44D: 38
  SBC #$32                              ; $C44E: E9 32
  STA battle_stat_b_lo,X                           ; $C450: 9D 26 05
  LDA battle_stat_b_hi,X                           ; $C453: BD 27 05
  SBC #$00                              ; $C456: E9 00
  STA battle_stat_b_hi,X                           ; $C458: 9D 27 05
@RollGain:
  JSR B1F_RandomMod16                   ; $C45B: 20 5C E8
  CMP #$0B                              ; $C45E: C9 0B     ; reroll if >= 11
  BCS @RollGain                         ; $C460: B0 F9
  CLC                                   ; $C462: 18
  ADC #$23                              ; $C463: 69 23     ; gain = 35..45
  STA action_result_lo                             ; $C465: 8D 2C 04  ; reported gain
  LDY battle_officer_slot                             ; $C468: AC 09 05  ; officer slot
  LDA battle_roster,Y                           ; $C46B: B9 64 06  ; slot -> officer id
  STA $0010                             ; $C46E: 8D 10 00
  JSR B1F_GetOfficerRomRecordAddr       ; $C471: 20 87 F3  ; ROM baseline
  LDY #$00                              ; $C474: A0 00
  LDA ($00),Y                           ; $C476: B1 00
  STA $0002                             ; $C478: 8D 02 00  ; baseline byte 0
  LDA $0010                             ; $C47B: AD 10 00
  JSR B1F_GetOfficerRecordAddr          ; $C47E: 20 D7 F2  ; runtime record
  LDA ($00),Y                           ; $C481: B1 00     ; current byte 0
  CLC                                   ; $C483: 18
  ADC action_result_lo                             ; $C484: 6D 2C 04  ; current += gain
  STA ($00),Y                           ; $C487: 91 00
  SEC                                   ; $C489: 38
  SBC $0002                             ; $C48A: ED 02 00  ; compare with baseline
  BCC @Finish                           ; $C48D: 90 12     ; below baseline: done
  STA $0003                             ; $C48F: 8D 03 00  ; overflow amount
  LDA action_result_lo                             ; $C492: AD 2C 04
  SEC                                   ; $C495: 38
  SBC $0003                             ; $C496: ED 03 00  ; clamp gain
  STA action_result_lo                             ; $C499: 8D 2C 04
  LDA $0002                             ; $C49C: AD 02 00
  STA ($00),Y                           ; $C49F: 91 00     ; clamp value to baseline
@Finish:
  LDA #$08                              ; $C4A1: A9 08
  STA battle_scene_phase                             ; $C4A3: 8D 01 05  ; continue in state 8
  LDA #$B4                              ; $C4A6: A9 B4     ; UI mode $B4
  JMP B1F_SetUI2                        ; $C4A8: 4C 83 F2
; Action panel layout descriptor for state 4 (drawn by B1F_MenuStep2 above)
State4PanelLayout:
  .byte $00,$01,$FF,$FF,$D6,$50,$D6,$98,$00,$07,$00,$00,$80; $C4AB: 00 01 FF FF D6 50 D6 98 00 07 00 00 80
;-------------------------------------------------------------------------------
; State 5 - Setup formation: expand the formation for action index $050E.
; Draws the panel from State5PanelLayout, then on $0081:
;   bit0 -> @ExpandSlots: formation id = FormationIdTable[$050E]; call
;           ExpandFormationSlots to fill the 4 unit slots ($044C tile cells,
;           $042C position records), clear $0424/$0425, state 6 (UI $AE via
;           B1F_SetUI5).
;   bit1 -> reset command ($0500/$0501 = 0).
;-------------------------------------------------------------------------------
State5_SetupFormation:
  LDA #$12                              ; $C4B8: A9 12
  STA $0010                             ; $C4BA: 8D 10 00
  LDA #$C5                              ; $C4BD: A9 C5
  STA $0011                             ; $C4BF: 8D 11 00
  LDA #$00                              ; $C4C2: A9 00
  STA $0012                             ; $C4C4: 8D 12 00  ; submode = 0
  JSR B1F_MenuStep2                     ; $C4C7: 20 1E ED  ; draw panel (step 2)
  LDA #$18                              ; $C4CA: A9 18
  STA $0010                             ; $C4CC: 8D 10 00
  LDA #$C5                              ; $C4CF: A9 C5
  STA $0011                             ; $C4D1: 8D 11 00
  LDA #$20                              ; $C4D4: A9 20
  STA $0000                             ; $C4D6: 8D 00 00
  LDA #$C5                              ; $C4D9: A9 C5
  STA $0001                             ; $C4DB: 8D 01 00
  LDA $0012                             ; $C4DE: AD 12 00
  JSR B1F_PointerTableLookup            ; $C4E1: 20 F5 ED  ; sprite write, entry $0012
  LDA $0081                             ; $C4E4: AD 81 00  ; command-step flags
  LSR                                   ; $C4E7: 4A
  BCS @ExpandSlots                      ; $C4E8: B0 0C     ; bit0: execute step
  LSR                                   ; $C4EA: 4A
  BCC @Wait                             ; $C4EB: 90 08     ; bit1 clear: wait
  LDA #$00                              ; $C4ED: A9 00
  STA battle_scene_id                             ; $C4EF: 8D 00 05  ; clear command id
  STA battle_scene_phase                             ; $C4F2: 8D 01 05  ; back to phase 0
@Wait:
  RTS                                   ; $C4F5: 60
@ExpandSlots:
  LDY battle_province_idx                             ; $C4F6: AC 0E 05  ; action index
  LDA FormationIdTable,Y                ; $C4F9: B9 25 C5  ; formation id 0-5
  STA $0000                             ; $C4FC: 8D 00 00
  JSR ExpandFormationSlots              ; $C4FF: 20 51 C8  ; fill $044C/$042C slots
  INC battle_scene_phase                             ; $C502: EE 01 05  ; continue in state 6
  LDA #$00                              ; $C505: A9 00
  STA menu_cursor_col                             ; $C507: 8D 24 04
  STA menu_cursor_page                             ; $C50A: 8D 25 04
  LDA #$AE                              ; $C50D: A9 AE     ; UI mode $AE
  JMP B1F_SetUI5                        ; $C50F: 4C 93 F2
; Formation panel layout descriptor for state 5 (4 tile entries, drawn by
; B1F_MenuStep2 above)
State5PanelLayout:
  .byte $00,$01,$02,$03,$FF,$FF,$C4,$56,$C4,$96,$D4,$56,$D4,$96,$00,$07; $C512: 00 01 02 03 FF FF C4 56 C4 96 D4 56 D4 96 00 07
  .byte $00,$00,$80                     ; $C522: 00 00 80
; FormationIdTable - formation id (0-5) per action index $050E, consumed by
; State5_SetupFormation and passed to ExpandFormationSlots.
FormationIdTable:
  .byte $00,$00,$00,$00,$04,$00,$03,$00,$01,$00,$00,$01,$01,$01,$00,$01; $C525: 00 00 00 00 04 00 03 00 01 00 00 01 01 01 00 01
  .byte $00,$00,$01,$00,$01,$01,$00,$00,$00,$01,$01,$01,$00,$05 ; $C535: 00 00 01 00 01 01 00 00 00 01 01 01 00 05
;-------------------------------------------------------------------------------
; State 6 - Render formation sprites into the $0380 display buffer.
; Waits until the animation queue ($0300) is idle, swaps in pattern bank
; $30 (B1F_SwitchBank8_B), zeroes the slot/buffer/param counters, then for
; each of the 4 unit slots ($044C): resolves the tile cell to a pattern
; pointer via $9B12 (+$80 page adjust) and writes 2 sprite rows to $0380
; (base attribute $08, param word from SlotParamTable, 8 pattern bytes per
; row). Slot 0 initializes the cached tile $00BC; later slots compare their
; first pattern byte against it and set the palette-flip offset $0015=$40
; when it changed ($00BD updated). After all slots: terminator $FF, dirty
; flag $007E bit2, advance to state 7.
;-------------------------------------------------------------------------------
State6_RenderFormationSprites:
  LDA $0300                             ; $C543: AD 00 03  ; animation queue flag
  CMP #$FF                              ; $C546: C9 FF
  BEQ @BeginRender                      ; $C548: F0 01     ; idle: proceed
  RTS                                   ; $C54A: 60
@BeginRender:
  LDY #$30                              ; $C54B: A0 30     ; pattern bank
  JSR B1F_SwitchBank8_B                 ; $C54D: 20 5F F2
  LDY #$00                              ; $C550: A0 00
  LDX #$00                              ; $C552: A2 00
  STX $0010                             ; $C554: 8E 10 00  ; slot index = 0
  STX $0011                             ; $C557: 8E 11 00  ; buffer offset = 0
  STX $0012                             ; $C55A: 8E 12 00  ; param word index = 0
@FirstSlot:
  LDY $0010                             ; $C55D: AC 10 00  ; slot index
  LDA tile_cell_slots,Y                           ; $C560: B9 4C 04  ; tile cell for slot
  ASL                                   ; $C563: 0A        ; *2 (word entries)
  TAY                                   ; $C564: A8
  LDA $9B12,Y                           ; $C565: B9 12 9B  ; pattern pointer low
  STA $0000                             ; $C568: 8D 00 00
  INY                                   ; $C56B: C8
  LDA $9B12,Y                           ; $C56C: B9 12 9B  ; pattern pointer high
  CLC                                   ; $C56F: 18
  ADC #$80                              ; $C570: 69 80
  STA $0001                             ; $C572: 8D 01 00
  LDY #$00                              ; $C575: A0 00
  LDA ($00),Y                           ; $C577: B1 00     ; first pattern byte
  STA $00BC                             ; $C579: 8D BC 00  ; initialize cached tile
  JMP @SetupRows                        ; $C57C: 4C 97 C5
@NextSlot:
  LDY $0010                             ; $C57F: AC 10 00  ; slot index
  LDA tile_cell_slots,Y                           ; $C582: B9 4C 04  ; tile cell for slot
  ASL                                   ; $C585: 0A        ; *2 (word entries)
  TAY                                   ; $C586: A8
  LDA $9B12,Y                           ; $C587: B9 12 9B  ; pattern pointer low
  STA $0000                             ; $C58A: 8D 00 00
  INY                                   ; $C58D: C8
  LDA $9B12,Y                           ; $C58E: B9 12 9B  ; pattern pointer high
  CLC                                   ; $C591: 18
  ADC #$80                              ; $C592: 69 80
  STA $0001                             ; $C594: 8D 01 00
@SetupRows:
  LDY #$00                              ; $C597: A0 00
  STY $0014                             ; $C599: 8C 14 00  ; row counter = 0
  STY $0015                             ; $C59C: 8C 15 00  ; palette flip = 0
  LDA ($00),Y                           ; $C59F: B1 00     ; first pattern byte
  CMP $00BC                             ; $C5A1: CD BC 00  ; changed since slot 0?
  BEQ @LoadSlotParams                   ; $C5A4: F0 08
  STA $00BD                             ; $C5A6: 8D BD 00  ; update cached tile
  LDA #$40                              ; $C5A9: A9 40
  STA $0015                             ; $C5AB: 8D 15 00  ; palette flip flag
@LoadSlotParams:
  LDX $0012                             ; $C5AE: AE 12 00  ; param word index
  LDA SlotParamTable,X                  ; $C5B1: BD 1E C6
  STA $0002                             ; $C5B4: 8D 02 00
  INX                                   ; $C5B7: E8
  LDA SlotParamTable,X                  ; $C5B8: BD 1E C6
  STA $0003                             ; $C5BB: 8D 03 00
  INX                                   ; $C5BE: E8
  STX $0012                             ; $C5BF: 8E 12 00
  LDX $0011                             ; $C5C2: AE 11 00  ; $0380 buffer offset
  LDA #$08                              ; $C5C5: A9 08
  STA $0380,X                           ; $C5C7: 9D 80 03  ; base attribute
  INX                                   ; $C5CA: E8
  LDA $0003                             ; $C5CB: AD 03 00
  STA $0380,X                           ; $C5CE: 9D 80 03
  INX                                   ; $C5D1: E8
  LDA $0002                             ; $C5D2: AD 02 00
  STA $0380,X                           ; $C5D5: 9D 80 03
  LDA #$00                              ; $C5D8: A9 00
  STA $0013                             ; $C5DA: 8D 13 00  ; tile counter = 0
@TileLoop:
  INX                                   ; $C5DD: E8
  INY                                   ; $C5DE: C8
  LDA ($00),Y                           ; $C5DF: B1 00     ; pattern byte
  CLC                                   ; $C5E1: 18
  ADC $0015                             ; $C5E2: 6D 15 00  ; apply palette flip
  STA $0380,X                           ; $C5E5: 9D 80 03
  INC $0013                             ; $C5E8: EE 13 00
  LDA $0013                             ; $C5EB: AD 13 00
  CMP #$08                              ; $C5EE: C9 08     ; 8 tiles per row
  BCC @TileLoop                         ; $C5F0: 90 EB
  INX                                   ; $C5F2: E8
  STX $0011                             ; $C5F3: 8E 11 00  ; save buffer offset
  INC $0014                             ; $C5F6: EE 14 00  ; rows done for slot
  LDA $0014                             ; $C5F9: AD 14 00
  CMP #$02                              ; $C5FC: C9 02     ; 2 rows per slot
  BCC @LoadSlotParams                   ; $C5FE: 90 AE
  INC $0010                             ; $C600: EE 10 00  ; next slot
  LDA $0010                             ; $C603: AD 10 00
  CMP #$04                              ; $C606: C9 04     ; 4 slots total
  BCS @SlotsDone                        ; $C608: B0 03
  JMP @NextSlot                         ; $C60A: 4C 7F C5
@SlotsDone:
  LDA #$FF                              ; $C60D: A9 FF
  STA $0380,X                           ; $C60F: 9D 80 03  ; list terminator
  LDA $007E                             ; $C612: AD 7E 00
  ORA #$04                              ; $C615: 09 04
  STA $007E                             ; $C617: 8D 7E 00  ; mark display dirty
  INC battle_scene_phase                             ; $C61A: EE 01 05  ; continue in state 7
  RTS                                   ; $C61D: 60
; SlotParamTable - per-slot parameter words (2 per slot) written into the
; $0380 display records by State6_RenderFormationSprites.
SlotParamTable:
  .word $2463,$2483,$2471,$2491         ; $C61E: 63 24 83 24 71 24 91 24
  .word $24C3,$24E3,$24D1,$24F1         ; $C626: C3 24 E3 24 D1 24 F1 24
;-------------------------------------------------------------------------------
; State 7 - Apply the selected tile effect.
; Draws the panel from State7PanelLayout, then on $0081:
;   bit0 -> restart formation selection: $00BD = $8C, state 5 (UI $AD).
;   bit1 -> @ApplySelectedTile: selected tile = $044C[$0012], target offset =
;           slot record $042C[$0012*3]. If the target exceeds the side's
;           stat B ($0526/$0527): $0471 = $11, state 8 (UI $B0).
;           Otherwise CheckSpecialTiles; if it handled a special tile ->
;           state 8, else apply the tile bits to officer record byte $0A
;           (masked with $0010, OR'd with $044C), subtract the target from
;           stat B, state 8 (UI $AF).
;-------------------------------------------------------------------------------
State7_ApplyTileEffect:
  LDA #$28                              ; $C62E: A9 28
  STA $0010                             ; $C630: 8D 10 00
  LDA #$C7                              ; $C633: A9 C7
  STA $0011                             ; $C635: 8D 11 00
  LDA #$00                              ; $C638: A9 00
  STA $0012                             ; $C63A: 8D 12 00  ; submode = 0
  JSR B1F_MenuStep2                     ; $C63D: 20 1E ED  ; draw panel (step 2)
  LDA #$2E                              ; $C640: A9 2E
  STA $0010                             ; $C642: 8D 10 00
  LDA #$C7                              ; $C645: A9 C7
  STA $0011                             ; $C647: 8D 11 00
  LDA #$36                              ; $C64A: A9 36
  STA $0000                             ; $C64C: 8D 00 00
  LDA #$C7                              ; $C64F: A9 C7
  STA $0001                             ; $C651: 8D 01 00
  LDA $0012                             ; $C654: AD 12 00
  JSR B1F_PointerTableLookup            ; $C657: 20 F5 ED  ; sprite write, entry $0012
  LDA $0081                             ; $C65A: AD 81 00  ; command-step flags
  LSR                                   ; $C65D: 4A
  BCS @ApplySelectedTile                ; $C65E: B0 1B     ; bit1: confirm step
  LSR                                   ; $C660: 4A
  BCC @Wait                             ; $C661: 90 17     ; bit0 clear: wait
  LDA #$8C                              ; $C663: A9 8C     ; bit0: reselect formation
  STA $00BD                             ; $C665: 8D BD 00
  LDA #$05                              ; $C668: A9 05
  STA battle_scene_phase                             ; $C66A: 8D 01 05  ; back to state 5
  LDA #$00                              ; $C66D: A9 00
  STA menu_cursor_col                             ; $C66F: 8D 24 04
  STA menu_cursor_page                             ; $C672: 8D 25 04
  LDA #$AD                              ; $C675: A9 AD     ; UI mode $AD
  JMP B1F_SetUI5                        ; $C677: 4C 93 F2
@Wait:
  RTS                                   ; $C67A: 60
@ApplySelectedTile:
  LDY $0012                             ; $C67B: AC 12 00  ; selection index
  LDA tile_cell_slots,Y                           ; $C67E: B9 4C 04
  STA tile_cell_slots                             ; $C681: 8D 4C 04  ; selected tile cell
  LDA $0012                             ; $C684: AD 12 00
  ASL                                   ; $C687: 0A        ; *3 (slot record stride)
  CLC                                   ; $C688: 18
  ADC $0012                             ; $C689: 6D 12 00
  TAY                                   ; $C68C: A8
  LDA action_result_lo,Y                           ; $C68D: B9 2C 04  ; target offset low
  STA $0010                             ; $C690: 8D 10 00
  INY                                   ; $C693: C8
  LDA action_result_lo,Y                           ; $C694: B9 2C 04  ; target offset high
  STA $0011                             ; $C697: 8D 11 00
  JSR GetBattleSideOffset               ; $C69A: 20 3E C9  ; X = side * 2
  LDA battle_stat_b_lo,X                           ; $C69D: BD 26 05  ; compare stat B with target
  SEC                                   ; $C6A0: 38
  SBC $0010                             ; $C6A1: ED 10 00
  LDA battle_stat_b_hi,X                           ; $C6A4: BD 27 05
  SBC $0011                             ; $C6A7: ED 11 00
  BCS @CheckSpecial                     ; $C6AA: B0 0D     ; stat B >= target
  LDA #$11                              ; $C6AC: A9 11     ; target out of reach
  STA tile_result_flag                             ; $C6AE: 8D 71 04
  INC battle_scene_phase                             ; $C6B1: EE 01 05  ; state 8
  LDA #$B0                              ; $C6B4: A9 B0     ; UI mode $B0
  JMP B1F_SetUI5                        ; $C6B6: 4C 93 F2
@CheckSpecial:
  JSR CheckSpecialTiles                 ; $C6B9: 20 3B C7
  BCS @ApplyTileBits                    ; $C6BC: B0 06     ; C=1: apply tile normally
  LDA #$08                              ; $C6BE: A9 08
  STA battle_scene_phase                             ; $C6C0: 8D 01 05  ; C=0: special handled, state 8
  RTS                                   ; $C6C3: 60
@ApplyTileBits:
  LDA #$0C                              ; $C6C4: A9 0C
  STA $00BD                             ; $C6C6: 8D BD 00
  LDA $0010                             ; $C6C9: AD 10 00
  STA action_result_lo                             ; $C6CC: 8D 2C 04  ; report target offset
  LDA $0011                             ; $C6CF: AD 11 00
  STA action_result_hi                             ; $C6D2: 8D 2D 04
  LDA #$E0                              ; $C6D5: A9 E0
  STA $0010                             ; $C6D7: 8D 10 00  ; preserve tile bits mask
  LDA tile_cell_slots                             ; $C6DA: AD 4C 04
  CMP #$18                              ; $C6DD: C9 18     ; cell >= $18 needs remap
  BCC @WriteRecord                      ; $C6DF: 90 12
  SEC                                   ; $C6E1: 38
  SBC #$18                              ; $C6E2: E9 18
  CLC                                   ; $C6E4: 18
  ROR                                   ; $C6E5: 6A        ; (cell-$18) >> 4 * $20
  ROR                                   ; $C6E6: 6A
  ROR                                   ; $C6E7: 6A
  ROR                                   ; $C6E8: 6A
  AND #$E0                              ; $C6E9: 29 E0
  STA tile_cell_slots                             ; $C6EB: 8D 4C 04
  LDA #$1F                              ; $C6EE: A9 1F
  STA $0010                             ; $C6F0: 8D 10 00  ; alternate preserve mask
@WriteRecord:
  LDY battle_officer_slot                             ; $C6F3: AC 09 05  ; officer slot
  LDA battle_roster,Y                           ; $C6F6: B9 64 06  ; slot -> officer id
  JSR B1F_GetOfficerRecordAddr          ; $C6F9: 20 D7 F2
  LDY #$0A                              ; $C6FC: A0 0A
  LDA ($00),Y                           ; $C6FE: B1 00     ; record byte $0A
  AND $0010                             ; $C700: 2D 10 00  ; keep masked bits
  ORA tile_cell_slots                             ; $C703: 0D 4C 04  ; merge tile bits
  STA ($00),Y                           ; $C706: 91 00
  JSR GetBattleSideOffset               ; $C708: 20 3E C9  ; X = side * 2
  LDA battle_stat_b_lo,X                           ; $C70B: BD 26 05  ; stat B -= target
  SEC                                   ; $C70E: 38
  SBC action_result_lo                             ; $C70F: ED 2C 04
  STA battle_stat_b_lo,X                           ; $C712: 9D 26 05
  LDA battle_stat_b_hi,X                           ; $C715: BD 27 05
  SBC action_result_hi                             ; $C718: ED 2D 04
  STA battle_stat_b_hi,X                           ; $C71B: 9D 27 05
  LDA #$08                              ; $C71E: A9 08
  STA battle_scene_phase                             ; $C720: 8D 01 05  ; continue in state 8
  LDA #$AF                              ; $C723: A9 AF     ; UI mode $AF
  JMP B1F_SetUI5                        ; $C725: 4C 93 F2
; Formation panel layout descriptor for state 7 (4 tile entries, drawn by
; B1F_MenuStep2 above)
State7PanelLayout:
  .byte $00,$01,$02,$03,$FF,$FF,$BA,$10,$BA,$80,$D2,$10,$D2,$80,$00,$07; $C728: 00 01 02 03 FF FF BA 10 BA 80 D2 10 D2 80 00 07
  .byte $00,$00,$80                     ; $C738: 00 00 80
;-------------------------------------------------------------------------------
; CheckSpecialTiles - one-shot special tile trigger check.
; Input: $044C = current tile cell, $0509 = officer slot ($0664 -> id).
; Matches the tile against the four special tiles and their conditions:
;   tile $0F and officer id == $26 -> trigger bit $02
;   tile $17 and officer id == $99 -> trigger bit $04
;   tile $16 and record byte 1 >= $5A -> trigger bit $08
;   tile $1E and record byte 4 >= $5A -> trigger bit $10
; Result: carry SET when the caller should apply the tile normally (tile is
; not special, or a fresh trigger was just latched into $6FE1); carry CLEAR
; when the caller must skip the normal application (special-tile condition
; failed -> UI mode $48, or the trigger was already latched -> UI mode $49).
;-------------------------------------------------------------------------------
CheckSpecialTiles:
  LDY battle_officer_slot                             ; $C73B: AC 09 05  ; officer slot
  LDA battle_roster,Y                           ; $C73E: B9 64 06  ; slot -> officer id
  STA $0002                             ; $C741: 8D 02 00
  JSR B1F_GetOfficerRecordAddr          ; $C744: 20 D7 F2  ; runtime record -> ($00)
  LDA tile_cell_slots                             ; $C747: AD 4C 04  ; current tile cell
  CMP #$0F                              ; $C74A: C9 0F
  BNE @CheckTile17                      ; $C74C: D0 0C
  LDA $0002                             ; $C74E: AD 02 00
  CMP #$26                              ; $C751: C9 26     ; officer id $26
  BNE @NoMatch                          ; $C753: D0 37
  LDA #$02                              ; $C755: A9 02     ; trigger bit $02
  JMP @LatchFlag                        ; $C757: 4C 93 C7
@CheckTile17:
  CMP #$17                              ; $C75A: C9 17
  BNE @CheckTile16                      ; $C75C: D0 0C
  LDA $0002                             ; $C75E: AD 02 00
  CMP #$99                              ; $C761: C9 99     ; officer id $99
  BNE @NoMatch                          ; $C763: D0 27
  LDA #$04                              ; $C765: A9 04     ; trigger bit $04
  JMP @LatchFlag                        ; $C767: 4C 93 C7
@CheckTile16:
  CMP #$16                              ; $C76A: C9 16
  BNE @CheckTile1E                      ; $C76C: D0 0D
  LDY #$01                              ; $C76E: A0 01
  LDA ($00),Y                           ; $C770: B1 00     ; record byte 1
  CMP #$5A                              ; $C772: C9 5A     ; threshold 90
  BCC @NoMatch                          ; $C774: 90 16
  LDA #$08                              ; $C776: A9 08     ; trigger bit $08
  JMP @LatchFlag                        ; $C778: 4C 93 C7
@CheckTile1E:
  CMP #$1E                              ; $C77B: C9 1E
  BNE @NotSpecial                       ; $C77D: D0 28
  LDY #$04                              ; $C77F: A0 04
  LDA ($00),Y                           ; $C781: B1 00     ; record byte 4
  CMP #$5A                              ; $C783: C9 5A     ; threshold 90
  BCC @NoMatch                          ; $C785: 90 05
  LDA #$10                              ; $C787: A9 10     ; trigger bit $10
  JMP @LatchFlag                        ; $C789: 4C 93 C7
@NoMatch:
  LDA #$48                              ; $C78C: A9 48     ; UI mode $48 (no trigger)
  JSR B1F_SetUI5                        ; $C78E: 20 93 F2
  CLC                                   ; $C791: 18
  RTS                                   ; $C792: 60
@LatchFlag:
  STA $0003                             ; $C793: 8D 03 00  ; trigger bit
  LDA special_tile_latch                             ; $C796: AD E1 6F  ; special tile latch byte
  AND $0003                             ; $C799: 2D 03 00
  BNE @AlreadyTriggered                 ; $C79C: D0 0B
  LDA special_tile_latch                             ; $C79E: AD E1 6F
  ORA $0003                             ; $C7A1: 0D 03 00
  STA special_tile_latch                             ; $C7A4: 8D E1 6F  ; latch the trigger
@NotSpecial:
  SEC                                   ; $C7A7: 38        ; proceed with normal apply
  RTS                                   ; $C7A8: 60
@AlreadyTriggered:
  LDA #$49                              ; $C7A9: A9 49     ; UI mode $49 (repeat)
  JSR B1F_SetUI5                        ; $C7AB: 20 93 F2
  CLC                                   ; $C7AE: 18
  RTS                                   ; $C7AF: 60
;-------------------------------------------------------------------------------
; State 8 - Wait for the animation to finish, then idle.
; Once CheckAnimQueueDone passes and DrawActionMarker refreshes the marker,
; any $0081 command flag resets the state machine ($0500/$0501 = 0) so the
; next dispatch restarts at state 0.
;-------------------------------------------------------------------------------
State8_WaitForNextCommand:
  JSR CheckAnimQueueDone                ; $C7B0: 20 48 C9
  BCC @Wait                             ; $C7B3: 90 12     ; animation still busy
  JSR DrawActionMarker                  ; $C7B5: 20 5A C9
  LDA $0081                             ; $C7B8: AD 81 00  ; command-step flags
  AND #$03                              ; $C7BB: 29 03
  BEQ @Wait                             ; $C7BD: F0 08     ; no command yet
  LDA #$00                              ; $C7BF: A9 00
  STA battle_scene_id                             ; $C7C1: 8D 00 05  ; clear command id
  STA battle_scene_phase                             ; $C7C4: 8D 01 05  ; restart at state 0
@Wait:
  RTS                                   ; $C7C7: 60
;-------------------------------------------------------------------------------
; State 9 - Route the next action by mode $0470.
; Draws the panel from State9PanelLayout, waits for $0081:
;   bit0 -> @ResetCommand (only when submode $0012 == 0): clear $0424/$0425,
;           then route by $0470:
;             $00 -> state 0 (UI $A8)
;             $01 -> state 5 with $00BD = $8C (UI $AD)
;             else -> state 3 (UI $B1)
;   bit1 -> reset command ($0500/$0501 = 0).
;-------------------------------------------------------------------------------
State9_RouteNextAction:
  LDA #$44                              ; $C7C8: A9 44
  STA $0010                             ; $C7CA: 8D 10 00
  LDA #$C8                              ; $C7CD: A9 C8
  STA $0011                             ; $C7CF: 8D 11 00
  LDA #$00                              ; $C7D2: A9 00
  STA $0012                             ; $C7D4: 8D 12 00  ; submode = 0
  JSR B1F_MenuStep2                     ; $C7D7: 20 1E ED  ; draw panel (step 2)
  LDA #$48                              ; $C7DA: A9 48
  STA $0010                             ; $C7DC: 8D 10 00
  LDA #$C8                              ; $C7DF: A9 C8
  STA $0011                             ; $C7E1: 8D 11 00
  LDA #$4C                              ; $C7E4: A9 4C
  STA $0000                             ; $C7E6: 8D 00 00
  LDA #$C8                              ; $C7E9: A9 C8
  STA $0001                             ; $C7EB: 8D 01 00
  LDA $0012                             ; $C7EE: AD 12 00
  JSR B1F_PointerTableLookup            ; $C7F1: 20 F5 ED  ; sprite write, entry $0012
  JSR CheckAnimQueueDone                ; $C7F4: 20 48 C9
  BCC @Wait                             ; $C7F7: 90 11     ; animation still busy
  LDA $0081                             ; $C7F9: AD 81 00  ; command-step flags
  LSR                                   ; $C7FC: 4A
  BCS @Route                            ; $C7FD: B0 0C     ; bit0: execute step
  LSR                                   ; $C7FF: 4A
  BCC @Wait                             ; $C800: 90 08     ; bit1 clear: wait
@ResetCommand:
  LDA #$00                              ; $C802: A9 00
  STA battle_scene_id                             ; $C804: 8D 00 05  ; clear command id
  STA battle_scene_phase                             ; $C807: 8D 01 05  ; back to phase 0
@Wait:
  RTS                                   ; $C80A: 60
@Route:
  LDA $0012                             ; $C80B: AD 12 00  ; submode
  BNE @ResetCommand                     ; $C80E: D0 F2
  LDA #$00                              ; $C810: A9 00
  STA menu_cursor_col                             ; $C812: 8D 24 04
  STA menu_cursor_page                             ; $C815: 8D 25 04
  LDA route_mode                             ; $C818: AD 70 04  ; route mode
  BNE @CheckMode1                       ; $C81B: D0 0A
  LDA #$00                              ; $C81D: A9 00
  STA battle_scene_phase                             ; $C81F: 8D 01 05  ; mode 0 -> state 0
  LDA #$A8                              ; $C822: A9 A8     ; UI mode $A8
  JMP B1F_SetUI2                        ; $C824: 4C 83 F2
@CheckMode1:
  CMP #$01                              ; $C827: C9 01
  BNE @RouteToState3                    ; $C829: D0 0F
  LDA #$05                              ; $C82B: A9 05
  STA battle_scene_phase                             ; $C82D: 8D 01 05  ; mode 1 -> state 5
  LDA #$8C                              ; $C830: A9 8C
  STA $00BD                             ; $C832: 8D BD 00
  LDA #$AD                              ; $C835: A9 AD     ; UI mode $AD
  JMP B1F_SetUI2                        ; $C837: 4C 83 F2
@RouteToState3:
  LDA #$03                              ; $C83A: A9 03
  STA battle_scene_phase                             ; $C83C: 8D 01 05  ; other -> state 3
  LDA #$B1                              ; $C83F: A9 B1     ; UI mode $B1
  JMP B1F_SetUI2                        ; $C841: 4C 83 F2
; Action panel layout descriptor for state 9 (drawn by B1F_MenuStep2 above)
State9PanelLayout:
  .byte $00,$01,$FF,$FF,$C6,$50,$C6,$97,$00,$07,$00,$00,$80; $C844: 00 01 FF FF C6 50 C6 97 00 07 00 00 80
;-------------------------------------------------------------------------------
; ExpandFormationSlots - expand a formation into 4 unit slots.
; Also reachable via the entry stub at $A01E.
; Input: $0000 = formation id (0-5), $0012 = side offset (0-3).
; Reads 4 consecutive tile cells from FormationTileLayouts
; (formation*16 + side*4) and writes, for each slot X=0-3:
;   $044C,X   = tile cell index
;   $042C+X*3 = (TileOffsetTable[cell], 0) position record
;-------------------------------------------------------------------------------
ExpandFormationSlots:
  LDA $0000                             ; $C851: AD 00 00  ; formation id
  ASL                                   ; $C854: 0A
  ASL                                   ; $C855: 0A
  ASL                                   ; $C856: 0A
  ASL                                   ; $C857: 0A        ; *16 (row stride)
  STA $0000                             ; $C858: 8D 00 00
  LDA $0012                             ; $C85B: AD 12 00  ; side offset
  ASL                                   ; $C85E: 0A
  ASL                                   ; $C85F: 0A        ; *4 (slot stride)
  CLC                                   ; $C860: 18
  ADC $0000                             ; $C861: 6D 00 00
  TAY                                   ; $C864: A8        ; Y = layout table offset
  LDX #$00                              ; $C865: A2 00     ; slot index
@SlotLoop:
  LDA FormationTileLayouts,Y            ; $C867: B9 DE C8  ; tile cell for slot X
  STA tile_cell_slots,X                           ; $C86A: 9D 4C 04
  ASL                                   ; $C86D: 0A        ; *2 (word entries)
  STA $0000                             ; $C86E: 8D 00 00
  TYA                                   ; $C871: 98
  PHA                                   ; $C872: 48
  STX $0001                             ; $C873: 8E 01 00
  TXA                                   ; $C876: 8A
  ASL                                   ; $C877: 0A
  CLC                                   ; $C878: 18
  ADC $0001                             ; $C879: 6D 01 00  ; X*3 (record stride)
  TAX                                   ; $C87C: AA
  LDY $0000                             ; $C87D: AC 00 00
  LDA TileOffsetTable,Y                 ; $C880: B9 9E C8  ; position offset low
  STA action_result_lo,X                           ; $C883: 9D 2C 04
  INY                                   ; $C886: C8
  LDA TileOffsetTable,Y                 ; $C887: B9 9E C8  ; position offset high
  STA action_result_hi,X                           ; $C88A: 9D 2D 04
  LDA #$00                              ; $C88D: A9 00
  STA action_result_cnt,X                           ; $C88F: 9D 2E 04  ; record byte 2 = 0
  LDX $0001                             ; $C892: AE 01 00
  PLA                                   ; $C895: 68
  TAY                                   ; $C896: A8
  INY                                   ; $C897: C8
  INX                                   ; $C898: E8
  CPX #$04                              ; $C899: E0 04     ; 4 slots
  BCC @SlotLoop                         ; $C89B: 90 CA
  RTS                                   ; $C89D: 60
;-------------------------------------------------------------------------------
; TileOffsetTable - battle-map position offset per tile cell (32 words).
; Indexed by cell*2, where cell = row*8+col within the formation tile grid.
; The word is stored as the slot position record at $042C by
; ExpandFormationSlots and later compared against the side stat B pair.
;-------------------------------------------------------------------------------
TileOffsetTable:
  .word $0032,$0046,$0078,$00B4,$00FA,$0000,$0000,$0000 ; $C89E: 32 00 46 00 78 00 B4 00 FA 00 00 00 00 00 00 00
  .word $003C,$0064,$0096,$00C8,$00F0                   ; $C8AE: 3C 00 64 00 96 00 C8 00 F0 00
  .word $0104,$0000,$0190,$0050,$0064,$0078,$00C8,$00FA ; $C8B8: 04 01 00 00 90 01 50 00 64 00 78 00 C8 00 FA 00
  .word $012C,$015E,$0190,$0032,$0050,$0064,$0096,$00C8 ; $C8C8: 2C 01 5E 01 90 01 32 00 50 00 64 00 96 00 C8 00
  .word $00FA,$015E,$0190                               ; $C8D8: FA 00 5E 01 90 01
;-------------------------------------------------------------------------------
; FormationTileLayouts - 6 formations x 4 slots x 4 tile cells (96 bytes).
; Each 16-byte row is one formation; each 4-byte group is the tile-cell set
; of one unit slot. Cell values index TileOffsetTable (cell = row*8+col).
;-------------------------------------------------------------------------------
FormationTileLayouts:
  .byte $00,$01,$02,$03,$08,$09,$0A,$0B,$10,$11,$12,$13,$18,$19,$1A,$1B; $C8DE: 00 01 02 03 08 09 0A 0B 10 11 12 13 18 19 1A 1B
  .byte $01,$02,$03,$04,$0A,$0B,$0C,$0D,$12,$13,$14,$15,$1A,$1B,$1C,$1D; $C8EE: 01 02 03 04 0A 0B 0C 0D 12 13 14 15 1A 1B 1C 1D
  .byte $00,$01,$02,$03,$08,$09,$0A,$0F,$11,$12,$13,$14,$18,$19,$1A,$1B; $C8FE: 00 01 02 03 08 09 0A 0F 11 12 13 14 18 19 1A 1B
  .byte $00,$01,$02,$03,$09,$0A,$0B,$0C,$11,$12,$13,$16,$19,$1A,$1B,$1D; $C90E: 00 01 02 03 09 0A 0B 0C 11 12 13 16 19 1A 1B 1D
  .byte $01,$02,$03,$04,$08,$09,$0A,$0B,$11,$12,$13,$14,$1A,$1B,$1C,$1D; $C91E: 01 02 03 04 08 09 0A 0B 11 12 13 14 1A 1B 1C 1D
  .byte $01,$02,$03,$04,$0A,$0B,$0C,$0D,$12,$13,$14,$15,$19,$1A,$1B,$1E; $C92E: 01 02 03 04 0A 0B 0C 0D 12 13 14 15 19 1A 1B 1E
;-------------------------------------------------------------------------------
; GetBattleSideOffset - battle-side table offset in X.
; X = 0 when $0504 is non-negative (near side), X = 2 otherwise (far side).
; Used to index the per-side stat pairs $0522/$0523 (stat A) and
; $0526/$0527 (stat B). Also called from the battle command region at $C983+
; via AiOfficerActionDispatch::GetBattleSideOffset.
;-------------------------------------------------------------------------------
GetBattleSideOffset:
  LDX #$00                              ; $C93E: A2 00     ; near side offset
  LDA battle_side_flag                             ; $C940: AD 04 05  ; side flag
  BPL @Done                             ; $C943: 10 02
  LDX #$02                              ; $C945: A2 02     ; far side offset
@Done:
  RTS                                   ; $C947: 60
;-------------------------------------------------------------------------------
; CheckAnimQueueDone - animation queue idle test.
; Carry SET when both queue flags $0304 and $0300 are $FF (idle), else clear.
;-------------------------------------------------------------------------------
CheckAnimQueueDone:
  LDA $0304                             ; $C948: AD 04 03  ; queue flag 1
  CMP #$FF                              ; $C94B: C9 FF
  BNE @NotDone                          ; $C94D: D0 09
  LDA $0300                             ; $C94F: AD 00 03  ; queue flag 2
  CMP #$FF                              ; $C952: C9 FF
  BNE @NotDone                          ; $C954: D0 02
  SEC                                   ; $C956: 38        ; both idle
  RTS                                   ; $C957: 60
@NotDone:
  CLC                                   ; $C958: 18
  RTS                                   ; $C959: 60
;-------------------------------------------------------------------------------
; DrawActionMarker - draw the action marker sprite.
; Sets sprite params $000A = $D8, $000C = $80, then writes ActionMarkerSprite
; via B1F_SpriteOamWriterSimple unless $005E bit4 (sprite-inhibit) is set.
;-------------------------------------------------------------------------------
DrawActionMarker:
  LDA #$D8                              ; $C95A: A9 D8
  STA $000A                             ; $C95C: 8D 0A 00  ; sprite Y position
  LDA #$80                              ; $C95F: A9 80
  STA $000C                             ; $C961: 8D 0C 00  ; sprite attribute
  LDA $005E                             ; $C964: AD 5E 00  ; display flags
  AND #$10                              ; $C967: 29 10     ; sprite-inhibit bit
  BNE @Skip                             ; $C969: D0 12
  LDA #$7E                              ; $C96B: A9 7E
  STA $0000                             ; $C96D: 8D 00 00  ; -> ActionMarkerSprite
  LDA #$C9                              ; $C970: A9 C9
  STA $0001                             ; $C972: 8D 01 00
  LDA #$00                              ; $C975: A9 00
  STA $0002                             ; $C977: 8D 02 00
  JMP B1F_SpriteOamWriterSimple         ; $C97A: 4C AD F1
@Skip:
  RTS                                   ; $C97D: 60
; ActionMarkerSprite - marker sprite descriptor for DrawActionMarker
ActionMarkerSprite:
  .byte $00,$04,$00,$00,$80             ; $C97E: 00 04 00 00 80
.endproc  ; AiOfficerActionDispatch
;===============================================================================
; BattleCasualtyResolution - Post-action battle damage and morale resolver
; $C983-$CD77 | Entry: JMP stub at $A00C
;===============================================================================
; Processes cascading battle effects after combat actions resolve:
;   1. Accumulate damage from officer states (5→+100, 6→+50, 7→dismiss)
;   2. Subtract total from acting side's stat B ($0526/$0527)
;   3. If stat B underflows, remove officers by state threshold (6→5), restart
;   4. Check opponent viability via averaged stats (@ComputeAverageStats → @TransformStatPair)
;   5. Rout/morale collapse check using reinforcement table at $9BA4
;
; Officer state low nibble ($6FA1,Y) semantics:
;   0 = idle/normal     4 = fleeing (set by @SetFleeingOfficers)
;   1 = active/marching 5 = taking damage (50 pts, set by @MarkOfficerByType)
;   2 = attacking       6 = heavily damaged (100 pts)
;   3 = retreating      7 = dismissed/casualty (removed, high nibble cleared)
;
; Side stat pairs (X = GetBattleSideOffset):
;   $0522,X/$0523,X = stat A (morale/leadership, clamped 0..9999)
;   $0526,X/$0527,X = stat B (troop strength, clamped 0..9999)
;
; Reinforcement table at $9BA4: 3 bytes per entry, indexed by $050E*3.
;   Entry+0: first check threshold (FF = no reinforcement available)
;   Entry+4: second check threshold (FF = skip second check)
;   Used to determine if a side can sustain losses or triggers rout.
;
; Key zero-page temporaries:
;   $0010/$0011 = 16-bit damage accumulator (Phase 1), reused as threshold
;   $001A/$001B = averaged ally stat A/B (from @ComputeAverageStats + @TransformStatPair)
;   $001C/$001D = averaged enemy stat A/B (from @ComputeAverageStats + @TransformStatPair)
;   $001E = scaling factor ($1E - $0506), used by @TransformStatPair
;===============================================================================
.proc BattleCasualtyResolution
; --- Code Region ---
  LDY #$00                              ; $C983: A0 00
  STY $0010                             ; $C985: 8C 10 00
  STY $0011                             ; $C988: 8C 11 00
;--- Phase 1: Accumulate damage from ally officer states ---------------------
; Scan all 20 officer slots. For each ally (faction matches acting side):
;   low nibble 7 → dismiss officer (clear high nibble, skip damage)
;   low nibble 5 → add 100 ($0064) to damage accumulator
;   low nibble 6 → add 50 ($0032) to damage accumulator
;   low nibble <5 → no damage contribution
@AccumDamageLoop:
  JSR @CheckFaction                       ; $C98B: 20 92 CC
  BMI @NextOfficer                        ; $C98E: 30 34
  LDA officer_state_table,Y                           ; $C990: B9 A1 6F
  AND #$0F                              ; $C993: 29 0F
  CMP #$07                              ; $C995: C9 07
  BNE @CheckDamageTier                    ; $C997: D0 0D
  LDA officer_state_table,Y                           ; $C999: B9 A1 6F
  LSR                                   ; $C99C: 4A
  LSR                                   ; $C99D: 4A
  LSR                                   ; $C99E: 4A
  LSR                                   ; $C99F: 4A
  STA officer_state_table,Y                           ; $C9A0: 99 A1 6F
  JMP @NextOfficer                        ; $C9A3: 4C C4 C9
@CheckDamageTier:
  CMP #$05                              ; $C9A6: C9 05  ; <5 → no damage
  BCC @NextOfficer                        ; $C9A8: 90 1A
  CMP #$05                              ; $C9AA: C9 05  ; ==5 → 100 dmg; !=5 (i.e. 6) → 50 dmg
  BNE @Load50                             ; $C9AC: D0 05
  LDA #$64                              ; $C9AE: A9 64
  JMP @AddToAccum                         ; $C9B0: 4C B5 C9
@Load50:
  LDA #$32                              ; $C9B3: A9 32
@AddToAccum:
  CLC                                   ; $C9B5: 18
  ADC $0010                             ; $C9B6: 6D 10 00
  STA $0010                             ; $C9B9: 8D 10 00
  LDA $0011                             ; $C9BC: AD 11 00
  ADC #$00                              ; $C9BF: 69 00
  STA $0011                             ; $C9C1: 8D 11 00
;--- Phase 2: Apply accumulated damage to acting side's stat B ---------------
; stat B ($0526,X/$0527,X) -= damage ($0010/$0011)
; If underflow (C=0): stat B depleted → enter Phase 3 casualty removal
; If no underflow: stat B held → skip to Phase 4 opponent viability check
@NextOfficer:
  INY                                   ; $C9C4: C8
  CPY #$14                              ; $C9C5: C0 14
  BCC @AccumDamageLoop                    ; $C9C7: 90 C2
  JSR AiOfficerActionDispatch::GetBattleSideOffset ; $C9C9: 20 3E C9
  LDA battle_stat_b_lo,X                           ; $C9CC: BD 26 05
  SEC                                   ; $C9CF: 38
  SBC $0010                             ; $C9D0: ED 10 00
  LDA battle_stat_b_hi,X                           ; $C9D3: BD 27 05
  SBC $0011                             ; $C9D6: ED 11 00
  BCC @InitThreshold                      ; $C9D9: 90 03
  JMP @CheckOpponentViable                ; $C9DB: 4C 10 CA
;--- Phase 3: Stat B depleted — remove officers by descending threshold ------
; Search ally officers for one with low nibble == threshold (starting at 6,
; decrementing to 5). When found: clear high nibble (dismiss from battle),
; then JMP back to Phase 1 entry ($C983) to recalculate damage from scratch.
; This creates a recursive loop: damage → deplete → remove → recalculate.
; If no officer matches at any threshold, fall through to Phase 4.
@InitThreshold:
  LDA #$06                              ; $C9DE: A9 06
  STA $0010                             ; $C9E0: 8D 10 00
@ThresholdLoop:
  LDY #$00                              ; $C9E3: A0 00
@ScanForThreshold:
  JSR @CheckFaction                       ; $C9E5: 20 92 CC
  BMI @NextThresholdSlot                  ; $C9E8: 30 17
  LDA officer_state_table,Y                           ; $C9EA: B9 A1 6F
  AND #$0F                              ; $C9ED: 29 0F
  CMP $0010                             ; $C9EF: CD 10 00
  BNE @NextThresholdSlot                  ; $C9F2: D0 0D
  LDA officer_state_table,Y                           ; $C9F4: B9 A1 6F
  LSR                                   ; $C9F7: 4A
  LSR                                   ; $C9F8: 4A
  LSR                                   ; $C9F9: 4A
  LSR                                   ; $C9FA: 4A
  STA officer_state_table,Y                           ; $C9FB: 99 A1 6F
  JMP BattleCasualtyResolution            ; $C9FE: 4C 83 C9
@NextThresholdSlot:
  INY                                   ; $CA01: C8
  CPY #$14                              ; $CA02: C0 14
  BCC @ScanForThreshold                   ; $CA04: 90 DF
  DEC $0010                             ; $CA06: CE 10 00
  LDA $0010                             ; $CA09: AD 10 00
  CMP #$05                              ; $CA0C: C9 05
  BCS @ThresholdLoop                      ; $CA0E: B0 D3
;--- Phase 4: Check opponent viability via averaged stats --------------------
; Call @ComputeScaledStats to compute averaged stats into $001A-$001D (via
; @ComputeAverageStats + @TransformStatPair, scaled by $001E = $1E - $0506).
; Then compare OPPONENT's stat A ($0522,X with X flipped) vs averaged ally
; stats ($001A/$001B). If opponent stat A depleted → Phase 5 rout check.
@CheckOpponentViable:
  JSR @ComputeScaledStats                 ; $CA10: 20 00 CD
  JSR AiOfficerActionDispatch::GetBattleSideOffset ; $CA13: 20 3E C9
  LDA battle_stat_a_lo,X                           ; $CA16: BD 22 05
  SEC                                   ; $CA19: 38
  SBC $001A                             ; $CA1A: ED 1A 00
  LDA battle_stat_a_hi,X                           ; $CA1D: BD 23 05
  SBC $001B                             ; $CA20: ED 1B 00
  BCS @CheckOwnStatA                      ; $CA23: B0 03
  JMP @LookupReinforcement                ; $CA25: 4C 5F CA
; Opponent stat A still viable — now check OWN side's stat A vs averaged
; enemy stats ($001C/$001D). Flip X to own side for comparison.
; If own stat A depleted → set scale to 5 (reduced severity), recheck with
;   fresh offset. If still depleted → @SetFleeingOfficers (morale breaks).
; If own stat A held → both sides viable, skip to Phase 6 (@LookupReinforcement2).
@CheckOwnStatA:
  JSR AiOfficerActionDispatch::GetBattleSideOffset ; $CA28: 20 3E C9
  TXA                                   ; $CA2B: 8A
  EOR #$02                              ; $CA2C: 49 02
  TAX                                   ; $CA2E: AA
  LDA battle_stat_a_lo,X                           ; $CA2F: BD 22 05
  SEC                                   ; $CA32: 38
  SBC $001C                             ; $CA33: ED 1C 00
  LDA battle_stat_a_hi,X                           ; $CA36: BD 23 05
  SBC $001D                             ; $CA39: ED 1D 00
  BCS @SkipToFallback                     ; $CA3C: B0 1E
  LDA #$05                              ; $CA3E: A9 05  ; reduced severity (scale=5 vs normal $1E-$0506)
  JSR SetScaleFactor                      ; $CA40: 20 06 CD  ; recompute averaged stats with scale=5
  JSR AiOfficerActionDispatch::GetBattleSideOffset ; $CA43: 20 3E C9
  TXA                                   ; $CA46: 8A
  EOR #$02                              ; $CA47: 49 02
  TAX                                   ; $CA49: AA
  LDA battle_stat_a_lo,X                           ; $CA4A: BD 22 05
  SEC                                   ; $CA4D: 38
  SBC $001C                             ; $CA4E: ED 1C 00
  LDA battle_stat_a_hi,X                           ; $CA51: BD 23 05
  SBC $001D                             ; $CA54: ED 1D 00
  BCS @SkipToFallback                     ; $CA57: B0 03
  JSR @SetFleeingOfficers                 ; $CA59: 20 4D CB
; Own stat A still depleted even with reduced scaling → morale breaks.
; Set fleeing officers, then proceed to Phase 6 (@LookupReinforcement2).
@SkipToFallback:
  JMP @LookupReinforcement2               ; $CA5C: 4C C2 CA
;--- Phase 5: Rout/morale check — first reinforcement table lookup ---------
; Opponent's stat A was depleted. Look up reinforcement table at $9BA4:
;   index = $050E * 3 (each entry is 3 bytes: ASL+ASL+ADC $0000 = *3)
;   entry+0 == $FF → no reinforcement, jump to @NoReinforcement (morale collapse)
;   entry+0 != $FF → check if own stat B can sustain (high byte != 0, or
;     low byte >= 100). If viable, search for officer with state 5 to dismiss.
;     If no state-5 officer found, call @MarkOfficerByType.
@LookupReinforcement:
  LDY #$31                              ; $CA5F: A0 31
  JSR B1F_SwitchBank8_B                             ; $CA61: 20 5F F2
  LDA battle_province_idx                             ; $CA64: AD 0E 05
  ASL                                   ; $CA67: 0A
  STA $0000                             ; $CA68: 8D 00 00
  ASL                                   ; $CA6B: 0A
  CLC                                   ; $CA6C: 18
  ADC $0000                             ; $CA6D: 6D 00 00
  TAY                                   ; $CA70: A8
  LDA $9BA4,Y                           ; $CA71: B9 A4 9B
  CMP #$FF                              ; $CA74: C9 FF
  BNE @CheckStatBSustain                  ; $CA76: D0 03
  JMP @NoReinforcement                    ; $CA78: 4C A8 CA
; Reinforcement entry+0 is valid. Check own stat B:
;   stat B >= $0064 (100) → can sustain, search for state-5 officer to dismiss
;   stat B < $0064 → insufficient strength, jump to morale collapse ($CAA8)
@CheckStatBSustain:
  JSR AiOfficerActionDispatch::GetBattleSideOffset ; $CA7B: 20 3E C9
  LDA battle_stat_b_hi,X                           ; $CA7E: BD 27 05
  BNE @SearchState5                       ; $CA81: D0 0A
  LDA battle_stat_b_lo,X                           ; $CA83: BD 26 05
  CMP #$64                              ; $CA86: C9 64
  BCS @SearchState5                       ; $CA88: B0 03
  JMP @NoReinforcement                    ; $CA8A: 4C A8 CA
; Stat B viable. Scan ally officers for one with low nibble == 5 (damaged).
; If found → fall through to @FoundState5 which JMPs to @LookupReinforcement2.
; If none found → call @MarkOfficerByType to force-mark by type priority.
@SearchState5:
  LDY #$00                              ; $CA8D: A0 00
@ScanForState5:
  JSR @CheckFaction                       ; $CA8F: 20 92 CC
  BMI @NextState5Slot                     ; $CA92: 30 09
  LDA officer_state_table,Y                           ; $CA94: B9 A1 6F
  AND #$0F                              ; $CA97: 29 0F
  CMP #$05                              ; $CA99: C9 05
  BEQ @FoundState5                        ; $CA9B: F0 08
@NextState5Slot:
  INY                                   ; $CA9D: C8
  CPY #$14                              ; $CA9E: C0 14
  BCC @ScanForState5                      ; $CAA0: 90 ED
  JSR @MarkOfficerByType                  ; $CAA2: 20 6A CB
@FoundState5:
  JMP @LookupReinforcement2               ; $CAA5: 4C C2 CA
;--- Phase 5b: Morale collapse path (no reinforcement or stat B too low) ---
; Set $001E = 10 ($0A) via SetScaleFactor entry, compute averaged stats.
; Check opponent's stat A vs averaged ally stats. If opponent still viable →
; call @ResetAllyStates to reset all ally states 1-4 to state 1 (rally/reorganize).
; If opponent depleted → trigger rout via @ResetAllyStates (same effect).
@NoReinforcement:
  LDA #$0A                              ; $CAA8: A9 0A
  JSR SetScaleFactor                      ; $CAAA: 20 06 CD
  JSR AiOfficerActionDispatch::GetBattleSideOffset ; $CAAD: 20 3E C9
  LDA battle_stat_a_lo,X                           ; $CAB0: BD 22 05
  SEC                                   ; $CAB3: 38
  SBC $001A                             ; $CAB4: ED 1A 00
  LDA battle_stat_a_hi,X                           ; $CAB7: BD 23 05
  SBC $001B                             ; $CABA: ED 1B 00
  BCS @LookupReinforcement2               ; $CABD: B0 03
  JSR @ResetAllyStates                    ; $CABF: 20 FE CB
;--- Phase 6: Second reinforcement table check -----------------------------
; Look up reinforcement table at $9BA4, entry+4 (offset by 4 from first
; lookup: ASL+ASL+ADC+$04 = index*3+4).
;   entry+4 == $FF → skip to final check at @FinalCheck
;   entry+4 != $FF → check own stat B >= $0032 (50). If below → @FinalCheck.
;     If viable, count ally officers with low nibble == 6 (heavily damaged).
;     If count >= 2 → @FinalCheck. If < 2 → process at @ProcessLowState.
@LookupReinforcement2:
  LDY #$31                              ; $CAC2: A0 31
  JSR B1F_SwitchBank8_B                             ; $CAC4: 20 5F F2
  LDA battle_province_idx                             ; $CAC7: AD 0E 05
  ASL                                   ; $CACA: 0A
  STA $0000                             ; $CACB: 8D 00 00
  ASL                                   ; $CACE: 0A
  CLC                                   ; $CACF: 18
  ADC $0000                             ; $CAD0: 6D 00 00
  CLC                                   ; $CAD3: 18
  ADC #$04                              ; $CAD4: 69 04
  TAY                                   ; $CAD6: A8
  LDA $9BA4,Y                           ; $CAD7: B9 A4 9B
  CMP #$FF                              ; $CADA: C9 FF
  BEQ @FinalCheck                         ; $CADC: F0 2B
  JSR AiOfficerActionDispatch::GetBattleSideOffset ; $CADE: 20 3E C9
  LDA battle_stat_b_hi,X                           ; $CAE1: BD 27 05
  BNE @CountHeavilyDamaged                ; $CAE4: D0 07
  LDA battle_stat_b_lo,X                           ; $CAE6: BD 26 05
  CMP #$32                              ; $CAE9: C9 32
  BCC @FinalCheck                         ; $CAEB: 90 1C
; Stat B >= $0032 (50). Count ally officers with low nibble == 6 (heavily
; damaged). If count >= 2 → enough presence, go to @ComputeFinalThreshold.
; If count < 2 → too few heavy officers, process at @ProcessLowState.
@CountHeavilyDamaged:
  LDY #$00                              ; $CAED: A0 00
  LDX #$00                              ; $CAEF: A2 00
@ScanState6:
  JSR @CheckFaction                       ; $CAF1: 20 92 CC
  BMI @NextState6Slot                     ; $CAF4: 30 0A
  LDA officer_state_table,Y                           ; $CAF6: B9 A1 6F
  AND #$0F                              ; $CAF9: 29 0F
  CMP #$06                              ; $CAFB: C9 06
  BNE @NextState6Slot                     ; $CAFD: D0 01
  INX                                   ; $CAFF: E8
@NextState6Slot:
  INY                                   ; $CB00: C8
  CPY #$14                              ; $CB01: C0 14
  BCC @ScanState6                         ; $CB03: 90 EC
  CPX #$02                              ; $CB05: E0 02
  BCC @ProcessLowState                    ; $CB07: 90 03
@FinalCheck:
  JMP @ComputeFinalThreshold              ; $CB09: 4C 27 CB
; Fewer than 2 heavily-damaged officers. For each ally with low nibble
; 1-4 (active/fighting), call @TransformOfficerToState6 to transform coordinates and potentially
; set them to state 6 (heavily damaged), simulating escalating casualties.
@ProcessLowState:
  STX $0010                             ; $CB0C: 8E 10 00
  LDY #$00                              ; $CB0F: A0 00
@ScanLowState:
  JSR @CheckFaction                       ; $CB11: 20 92 CC
  BMI @NextLowStateSlot                   ; $CB14: 30 0C
  LDA officer_state_table,Y                           ; $CB16: B9 A1 6F
  BEQ @NextLowStateSlot                   ; $CB19: F0 07
  CMP #$05                              ; $CB1B: C9 05
  BCS @NextLowStateSlot                   ; $CB1D: B0 03
  JSR @TransformOfficerToState6           ; $CB1F: 20 19 CC
@NextLowStateSlot:
  INY                                   ; $CB22: C8
  CPY #$14                              ; $CB23: C0 14
  BCC @ScanLowState                       ; $CB25: 90 EA
;--- Final check: averaged enemy stats vs absolute thresholds -----------
; Compute averaged stats via @ComputeAverageStats. Then compare:
;   averaged enemy stat A ($001C/$001D) vs $03E8 (1000): if >= → @CountAndDecrementStates
;   averaged ally  stat A ($001A/$001B) vs $1388 (5000): if >= → @ResetAllyStates (rally)
;   otherwise → @CountAndDecrementStates (state counting/reinforcement)
@ComputeFinalThreshold:
  JSR @ComputeAverageStats                ; $CB27: 20 AA CC
  LDA $001C                             ; $CB2A: AD 1C 00
  SEC                                   ; $CB2D: 38
  SBC #$E8                              ; $CB2E: E9 E8
  LDA $001D                             ; $CB30: AD 1D 00
  SBC #$03                              ; $CB33: E9 03
  BCC @CheckAllyThreshold                 ; $CB35: 90 03
  JMP @CountAndDecrementStates            ; $CB37: 4C 9A CB
@CheckAllyThreshold:
  LDA $001A                             ; $CB3A: AD 1A 00
  SEC                                   ; $CB3D: 38
  SBC #$88                              ; $CB3E: E9 88
  LDA $001B                             ; $CB40: AD 1B 00
  SBC #$13                              ; $CB43: E9 13
  BCS @TriggerRally                       ; $CB45: B0 03
  JMP @CountAndDecrementStates            ; $CB47: 4C 9A CB
@TriggerRally:
  JMP @ResetAllyStates                    ; $CB4A: 4C FE CB
;=== Helper: SetFleeingOfficers ($CB4D-$CB69) ===
; Scan all 20 officer slots. For each ally with state 1 (active) or
; 2 (attacking), set state to 4 (fleeing). Used when own stat A is
; depleted but recheck shows it's still viable.
@SetFleeingOfficers:
  LDY #$00                              ; $CB4D: A0 00
@FleeScanLoop:
  JSR @CheckFaction                       ; $CB4F: 20 92 CC
  BMI @NextFleeSlot                       ; $CB52: 30 10
  LDA officer_state_table,Y                           ; $CB54: B9 A1 6F
  CMP #$01                              ; $CB57: C9 01
  BEQ @SetFleeState                       ; $CB59: F0 04
  CMP #$02                              ; $CB5B: C9 02
  BNE @NextFleeSlot                       ; $CB5D: D0 05
@SetFleeState:
  LDA #$04                              ; $CB5F: A9 04
  STA officer_state_table,Y                           ; $CB61: 99 A1 6F
@NextFleeSlot:
  INY                                   ; $CB64: C8
  CPY #$14                              ; $CB65: C0 14
  BCC @FleeScanLoop                       ; $CB67: 90 E6
  RTS                                   ; $CB69: 60
;=== Helper: MarkOfficerByType ($CB6A-$CB95) ===
; Scan 4 officer types in priority order from @OfficerTypePriority ($02,$04,$01,$03).
; For each type, scan all 20 ally officers. If an ally's $6FA1,Y matches the
; type, set high nibble and ORA #$05 (state 5 = taking damage). RTS immediately
; after first match. If no match across all types, no officer is marked.
@MarkOfficerByType:
  LDX #$00                              ; $CB6A: A2 00
@TypeLoop:
  LDA @OfficerTypePriority,X              ; $CB6C: BD 96 CB
  STA $001A                             ; $CB6F: 8D 1A 00
  LDY #$00                              ; $CB72: A0 00
@ScanForType:
  JSR AiTurnProcess::AiCheckFaction     ; $CB74: 20 44 A9
  BMI @NextTypeSlot                       ; $CB77: 30 12
  LDA officer_state_table,Y                           ; $CB79: B9 A1 6F
  CMP $001A                             ; $CB7C: CD 1A 00
  BNE @NextTypeSlot                       ; $CB7F: D0 0A
  ASL                                   ; $CB81: 0A
  ASL                                   ; $CB82: 0A
  ASL                                   ; $CB83: 0A
  ASL                                   ; $CB84: 0A
  ORA #$05                              ; $CB85: 09 05
  STA officer_state_table,Y                           ; $CB87: 99 A1 6F
  RTS                                   ; $CB8A: 60
@NextTypeSlot:
  INY                                   ; $CB8B: C8
  CPY #$14                              ; $CB8C: C0 14
  BCC @ScanForType                        ; $CB8E: 90 E4
  INX                                   ; $CB90: E8
  CPX #$04                              ; $CB91: E0 04
  BCC @TypeLoop                           ; $CB93: 90 D7
  RTS                                   ; $CB95: 60
; Officer type priority table for MarkOfficerByType ($CB6A).
; Types scanned in order: 2, 4, 1, 3 (infantry, cavalry?, archer?, chariot?)
@OfficerTypePriority:
  .byte $02,$04,$01,$03                   ; $CB96: 02 04 01 03
;=== Helper: CountAndDecrementStates ($CB9A-$CBFD) ===
; Count ally officers in state 1 ($0010) and state 3 ($0011).
; Compare counts against thresholds at $6F99 and $6F9B:
;   state-1 count < $6F99 → find one state-2 officer, decrement to state 1
;   state-3 count < $6F9B → find one state-4 officer, decrement to state 3
; This gradually restores officers from fleeing/retreating to active states.
@CountAndDecrementStates:
; --- Code Region ---
  LDY #$00                              ; $CB9A: A0 00
  STY $0010                             ; $CB9C: 8C 10 00
  STY $0011                             ; $CB9F: 8C 11 00
@CountLoop:
  JSR @CheckFaction                       ; $CBA2: 20 92 CC
  LDA officer_state_table,Y                           ; $CBA5: B9 A1 6F
  CMP #$01                              ; $CBA8: C9 01
  BNE @CheckState3                        ; $CBAA: D0 06
  INC $0010                             ; $CBAC: EE 10 00
  JMP @NextCountSlot                      ; $CBAF: 4C B9 CB
@CheckState3:
  CMP #$03                              ; $CBB2: C9 03
  BNE @NextCountSlot                      ; $CBB4: D0 03
  INC $0011                             ; $CBB6: EE 11 00
@NextCountSlot:
  INY                                   ; $CBB9: C8
  CPY #$14                              ; $CBBA: C0 14
  BCC @CountLoop                          ; $CBBC: 90 E4
  LDA $0010                             ; $CBBE: AD 10 00
  CMP formation_slot0_units                             ; $CBC1: CD 99 6F
  BCS @CheckState3Threshold               ; $CBC4: B0 08
  LDA #$02                              ; $CBC6: A9 02
  STA $0000                             ; $CBC8: 8D 00 00
  JSR @DecrementOfficerState              ; $CBCB: 20 DF CB
@CheckState3Threshold:
  LDA $0011                             ; $CBCE: AD 11 00
  CMP formation_slot1_units                             ; $CBD1: CD 9B 6F
  BCS @DecrementReturn                    ; $CBD4: B0 08
  LDA #$04                              ; $CBD6: A9 04
  STA $0000                             ; $CBD8: 8D 00 00
  JSR @DecrementOfficerState              ; $CBDB: 20 DF CB
@DecrementReturn:
  RTS                                   ; $CBDE: 60
;=== Helper: DecrementOfficerState ($CBDF-$CBFD) ===
; Input: $0000 = target state to find among allies.
; Scan all 20 ally officers. Find first with $6FA1,Y == $0000, decrement
; $0000 and store back (effectively setting officer to state-1). RTS on match.
; If no match found, return with Y=$14 (no change).
@DecrementOfficerState:
  LDY #$00                              ; $CBDF: A0 00
@DecScanLoop:
  JSR @CheckFaction                       ; $CBE1: 20 92 CC
  BMI @DecNextSlot                        ; $CBE4: 30 12
  LDA officer_state_table,Y                           ; $CBE6: B9 A1 6F
  CMP $0000                             ; $CBE9: CD 00 00
  BNE @DecNextSlot                        ; $CBEC: D0 0A
  DEC $0000                             ; $CBEE: CE 00 00
  LDA $0000                             ; $CBF1: AD 00 00
  STA officer_state_table,Y                           ; $CBF4: 99 A1 6F
  RTS                                   ; $CBF7: 60
@DecNextSlot:
  INY                                   ; $CBF8: C8
  CPY #$14                              ; $CBF9: C0 14
  BCC @DecScanLoop                        ; $CBFB: 90 E4
  RTS                                   ; $CBFD: 60
;=== Helper: ResetAllyStates ($CBFE-$CC18) ===
; Scan all 20 ally officers. For each with state 1-4 (non-zero and < 5),
; reset to state 1 (active). Used during morale collapse to reorganize.
@ResetAllyStates:
  LDY #$00                              ; $CBFE: A0 00
@ResetScanLoop:
  JSR @CheckFaction                       ; $CC00: 20 92 CC
  BMI @ResetNextSlot                      ; $CC03: 30 0E
  LDA officer_state_table,Y                           ; $CC05: B9 A1 6F
  BEQ @ResetNextSlot                      ; $CC08: F0 09
  CMP #$05                              ; $CC0A: C9 05
  BCS @ResetNextSlot                      ; $CC0C: B0 05
  LDA #$01                              ; $CC0E: A9 01
  STA officer_state_table,Y                           ; $CC10: 99 A1 6F
@ResetNextSlot:
  INY                                   ; $CC13: C8
  CPY #$14                              ; $CC14: C0 14
  BCC @ResetScanLoop                      ; $CC16: 90 E8
  RTS                                   ; $CC18: 60
;=== Helper: TransformOfficerToState6 ($CC19-$CC91) ===
; Input: Y = officer index into $0664 slot table.
; Look up officer record via $0664,Y → $F387 (record addr) → $F2D7 (coord
; transform). Compare transformed Y-coordinate ($0011) against cached value
; ($0012). If officer's Y < cached → set officer to state 6 (high nibble
; preserved, low nibble = 6 = heavily damaged). Increment $0010 counter;
; if 2 officers transformed, force Y=$14 to exit outer loop early.
; Max 2 officers can be transformed per call.
@TransformOfficerToState6:
  LDA battle_roster,Y                           ; $CC19: B9 64 06
  CMP #$FF                              ; $CC1C: C9 FF
  BNE @TransformEntry                     ; $CC1E: D0 01
  RTS                                   ; $CC20: 60
@TransformEntry:
  STA $0011                             ; $CC21: 8D 11 00
  TYA                                   ; $CC24: 98
  PHA                                   ; $CC25: 48
  LDA $0011                             ; $CC26: AD 11 00
  JSR B1F_GetOfficerRomRecordAddr                             ; $CC29: 20 87 F3
  LDY #$00                              ; $CC2C: A0 00
  LDA ($00),Y                           ; $CC2E: B1 00
  STA $0000                             ; $CC30: 8D 00 00
  LDA #$00                              ; $CC33: A9 00
  STA $0001                             ; $CC35: 8D 01 00
  STA $0002                             ; $CC38: 8D 02 00
  LDA #$06                              ; $CC3B: A9 06
  STA $0003                             ; $CC3D: 8D 03 00
  JSR B1F_MathMul24x8                             ; $CC40: 20 E9 EB
  LDA $0006                             ; $CC43: AD 06 00
  STA $0001                             ; $CC46: 8D 01 00
  LDA $0007                             ; $CC49: AD 07 00
  STA $0002                             ; $CC4C: 8D 02 00
  LDA #$0A                              ; $CC4F: A9 0A
  STA $0003                             ; $CC51: 8D 03 00
  LDA #$00                              ; $CC54: A9 00
  STA $0004                             ; $CC56: 8D 04 00
  JSR B1F_MathDiv16                             ; $CC59: 20 7C EA
  LDA $0001                             ; $CC5C: AD 01 00
  STA $0012                             ; $CC5F: 8D 12 00
  LDA $0011                             ; $CC62: AD 11 00
  JSR B1F_GetOfficerRecordAddr                             ; $CC65: 20 D7 F2
  LDY #$00                              ; $CC68: A0 00
  LDA ($00),Y                           ; $CC6A: B1 00
  STA $0011                             ; $CC6C: 8D 11 00
  PLA                                   ; $CC6F: 68
  TAY                                   ; $CC70: A8
  LDA $0011                             ; $CC71: AD 11 00
  CMP $0012                             ; $CC74: CD 12 00
  BCS @TransformReturn                    ; $CC77: B0 18
  LDA officer_state_table,Y                           ; $CC79: B9 A1 6F
  ASL                                   ; $CC7C: 0A
  ASL                                   ; $CC7D: 0A
  ASL                                   ; $CC7E: 0A
  ASL                                   ; $CC7F: 0A
  ORA #$06                              ; $CC80: 09 06
  STA officer_state_table,Y                           ; $CC82: 99 A1 6F
  INC $0010                             ; $CC85: EE 10 00
  LDA $0010                             ; $CC88: AD 10 00
  CMP #$02                              ; $CC8B: C9 02
  BCC @TransformReturn                    ; $CC8D: 90 02
  LDY #$14                              ; $CC8F: A0 14
@TransformReturn:
  RTS                                   ; $CC91: 60
@CheckFaction:                          ; byte-identical duplicate of AiCheckFaction ($A944)
  LDA battle_side_flag                             ; $CC92: AD 04 05
  BMI @FactionNear                        ; $CC95: 30 08
  LDA unit_army_array,Y                           ; $CC97: B9 28 06
  BMI @FactionEnemy                       ; $CC9A: 30 0B
  LDA #$00                              ; $CC9C: A9 00
  RTS                                   ; $CC9E: 60
@FactionNear:
  LDA unit_army_array,Y                           ; $CC9F: B9 28 06
  BPL @FactionEnemy                       ; $CCA2: 10 03
  LDA #$00                              ; $CCA4: A9 00
  RTS                                   ; $CCA6: 60
@FactionEnemy:
  LDA #$80                              ; $CCA7: A9 80
  RTS                                   ; $CCA9: 60
;=== Helper: ComputeAverageStats ($CCAA-$CCFF) ===
; Sum stat A (bytes 8-9) and stat B (bytes 8-9 at offset $08) from all
; officer records ($0664 slot table → $F2D7 record lookup). Accumulates
; separately for allies ($001A/$001B) and enemies ($001C/$001D) based on
; faction check via $CC92. X selects pair: X=0 → ally accum, X=2 → enemy.
@ComputeAverageStats:
  LDY #$31                              ; $CCAA: A0 31
  JSR B1F_SwitchBank8_B                             ; $CCAC: 20 5F F2
  LDY #$00                              ; $CCAF: A0 00
  STY $001A                             ; $CCB1: 8C 1A 00
  STY $001B                             ; $CCB4: 8C 1B 00
  STY $001C                             ; $CCB7: 8C 1C 00
  STY $001D                             ; $CCBA: 8C 1D 00
@AvgScanLoop:
  LDA battle_roster,Y                           ; $CCBD: B9 64 06
  CMP #$FF                              ; $CCC0: C9 FF
  BEQ @AvgNextSlot                        ; $CCC2: F0 36
  STA $0002                             ; $CCC4: 8D 02 00
  TYA                                   ; $CCC7: 98
  PHA                                   ; $CCC8: 48
  LDA $0002                             ; $CCC9: AD 02 00
  JSR B1F_GetOfficerRecordAddr                             ; $CCCC: 20 D7 F2
  LDY #$08                              ; $CCCF: A0 08
  LDA ($00),Y                           ; $CCD1: B1 00
  STA $0002                             ; $CCD3: 8D 02 00
  INY                                   ; $CCD6: C8
  LDA ($00),Y                           ; $CCD7: B1 00
  STA $0003                             ; $CCD9: 8D 03 00
  PLA                                   ; $CCDC: 68
  TAY                                   ; $CCDD: A8
  LDX #$00                              ; $CCDE: A2 00
  JSR @CheckFaction                       ; $CCE0: 20 92 CC
  BPL @AvgAccumulate                      ; $CCE3: 10 02
  LDX #$02                              ; $CCE5: A2 02
@AvgAccumulate:
  LDA $001A,X                           ; $CCE7: BD 1A 00
  CLC                                   ; $CCEA: 18
  ADC $0002                             ; $CCEB: 6D 02 00
  STA $001A,X                           ; $CCEE: 9D 1A 00
  LDA $001B,X                           ; $CCF1: BD 1B 00
  ADC $0003                             ; $CCF4: 6D 03 00
  STA $001B,X                           ; $CCF7: 9D 1B 00
@AvgNextSlot:
  INY                                   ; $CCFA: C8
  CPY #$14                              ; $CCFB: C0 14
  BCC @AvgScanLoop                        ; $CCFD: 90 BE
  RTS                                   ; $CCFF: 60
;=== Helper: ComputeScaledStats ($CD00-$CD42) ===
; Entry at $CD00: compute scaling factor $001E = $1E - $0506.
; Entry at $CD06: accept A as $001E directly (used by Phase 5b with A=$0A).
; Calls $CCAA to accumulate raw stats, then applies $CD43 coordinate
; transform to both ally ($001A/$001B) and enemy ($001C/$001D) averages.
; Result: scaled/averaged stat values ready for comparison.
@ComputeScaledStats:
  LDA #$1E                              ; $CD00: A9 1E
  SEC                                   ; $CD02: 38
  SBC battle_round_counter                             ; $CD03: ED 06 05
SetScaleFactor:
  STA $001E                             ; $CD06: 8D 1E 00
  JSR @ComputeAverageStats                ; $CD09: 20 AA CC
  LDA $001A                             ; $CD0C: AD 1A 00
  STA $0000                             ; $CD0F: 8D 00 00
  LDA $001B                             ; $CD12: AD 1B 00
  STA $0001                             ; $CD15: 8D 01 00
  JSR @TransformStatPair                  ; $CD18: 20 43 CD
  LDA $0006                             ; $CD1B: AD 06 00
  STA $001A                             ; $CD1E: 8D 1A 00
  LDA $0007                             ; $CD21: AD 07 00
  STA $001B                             ; $CD24: 8D 1B 00
  LDA $001C                             ; $CD27: AD 1C 00
  STA $0000                             ; $CD2A: 8D 00 00
  LDA $001D                             ; $CD2D: AD 1D 00
  STA $0001                             ; $CD30: 8D 01 00
  JSR @TransformStatPair                  ; $CD33: 20 43 CD
  LDA $0006                             ; $CD36: AD 06 00
  STA $001C                             ; $CD39: 8D 1C 00
  LDA $0007                             ; $CD3C: AD 07 00
  STA $001D                             ; $CD3F: 8D 1D 00
  RTS                                   ; $CD42: 60
;=== Helper: TransformStatPair ($CD43-$CD77) ===
; Input: $0000/$0001 = stat pair to transform, $001E = scaling factor.
; Performs coordinate transform via $EBE9 (multiply) and $EAA5 (divide):
;   1. Multiply stat by $0400 via $EBE9 → 24-bit result in $0006-$0008
;   2. Divide by $00E8 (232) via $EAA5 → scaled value in $0006-$0007
;   3. Multiply by $001E via $EBE9 → final scaled result in $0006-$0007
; Output: $0006/$0007 = transformed stat value.
@TransformStatPair:
  LDA #$00                              ; $CD43: A9 00
  STA $0002                             ; $CD45: 8D 02 00
  LDA #$04                              ; $CD48: A9 04
  STA $0003                             ; $CD4A: 8D 03 00
  JSR B1F_MathMul24x8                             ; $CD4D: 20 E9 EB
  LDA $0006                             ; $CD50: AD 06 00
  STA $0000                             ; $CD53: 8D 00 00
  LDA $0007                             ; $CD56: AD 07 00
  STA $0001                             ; $CD59: 8D 01 00
  LDA $0008                             ; $CD5C: AD 08 00
  STA $0002                             ; $CD5F: 8D 02 00
  LDA #$E8                              ; $CD62: A9 E8
  STA $0003                             ; $CD64: 8D 03 00
  LDA #$03                              ; $CD67: A9 03
  STA $0004                             ; $CD69: 8D 04 00
  JSR B1F_MathDiv24                             ; $CD6C: 20 A5 EA
  LDA $001E                             ; $CD6F: AD 1E 00
  STA $0003                             ; $CD72: 8D 03 00
  JMP B1F_MathMul24x8                             ; $CD75: 4C E9 EB
.endproc  ; BattleCasualtyResolution
;===============================================================================
; BattleAttritionRound - Per-round mutual attrition resolver for field battles
; $CD78-$CFA1 | Entry: JMP stub at $A00F (BattleAttritionRound_Entry)
;===============================================================================
; Runs one round of a running battle (sibling of BattleCasualtyResolution at
; $C983). Each round:
;   1. Round timeout: $0506 >= $1F (30 rounds) -> stalemate outcome
;   2. Damage roll with scale factor $001E = $01 via ComputeScaledStats
;      ($CD06): per-round losses from each army's averaged troop strength
;      (ally roll in $001A/$001B, enemy roll in $001C/$001D)
;   3. Side B stat A ($0524/$0525) -= ally roll; zero -> ally-side outcome
;   4. Side A stat A ($0522/$0523) -= enemy roll; zero -> enemy-side outcome
;   5. Both armies survive: formation slot attrition passes over $0650,
;      special officer $6D handling (troop damage + banked record update),
;      then 5-slot action timers at $04DB expire into flags at $04D8
;
; Outcome variables set on battle end (consumed by battle scene dispatch):
;   $0000 = result code: $80 = opposing army annihilated, $00 = stalemate
;   $050A = outcome scene id: $B5 = special outcome (ruler state $050F == 3
;           on the ally-side branch / ruler record byte 3 == 3 on the
;           enemy-side branch), $BE = stalemate, $BF = annihilation
;   $0514 = outcome side selector: 1 = ally-side outcome (@AllySideOutcome),
;           0 = enemy-side outcome (@EnemySideOutcome)
;   $0509 = outcome variant flag ($0A = normal loss, $00 = special outcome)
;   $00A4 = outcome event index (3 = special, 4 = normal)
;   $042C = ruler id shown in outcome (low/high nibble of $0507 pair)
;   $6F44 = ruler result flag in save SRAM
;
; Key WRAM used:
;   $0506 = battle round counter, $0507 = packed ruler pair (A=hi, B=lo)
;   $050F = ruler status flag, $052B = outcome officer (from $0664 roster)
;   $052C/$052E = special officer record byte 11 high nibble / Power
;   $052F = slot index of special officer $6D in the $0664 roster
;   $0650-$0663 = formation slot attrition values (hi nibble = strength
;                 units, lo nibble = per-round counter), paired with the
;                 $0664-$0677 officer id roster ($FF = empty slot)
;   $000B/$000C = accumulated random troop damage (consumed by later scene)
;===============================================================================
.proc BattleAttritionRound
; --- Proc-local RAM ---
special_officer_flag   = $052E  ; special officer record byte 1 flag
special_officer_idx    = $052F  ; special officer roster index
; --- Round timeout check ------------------------------------------------------
; Clear the outcome scene id; if 30 rounds have elapsed ($0506 >= $1F) the
; battle is decided as a stalemate (result code $0000 = $00).
@CheckRoundTimeout:
  LDA #$00                              ; $CD78: A9 00
  STA battle_scene_index                             ; $CD7A: 8D 0A 05
  LDA battle_round_counter                             ; $CD7D: AD 06 05
  CMP #$1F                              ; $CD80: C9 1F
  BCC @ProcessRound                     ; $CD82: 90 08
  LDA #$00                              ; $CD84: A9 00
  STA $0000                             ; $CD86: 8D 00 00
  JMP @AllySideOutcome                  ; $CD89: 4C AB CE
; --- Mutual attrition roll ----------------------------------------------------
; Scale factor $01 -> ComputeScaledStats ($CD06) produces per-round losses:
; $001A/$001B = ally roll, $001C/$001D = enemy roll (both 16-bit).
@ProcessRound:
  LDA #$01                              ; $CD8C: A9 01
  JSR BattleCasualtyResolution::SetScaleFactor ; $CD8E: 20 06 CD
; Side B stat A ($0524/$0525) -= ally roll; underflow or zero means that
; army is annihilated -> result code $80, ally-side outcome branch.
  LDA battle_stat_a_lo+2                             ; $CD91: AD 24 05
  SEC                                   ; $CD94: 38
  SBC $001A                             ; $CD95: ED 1A 00
  STA battle_stat_a_lo+2                             ; $CD98: 8D 24 05
  LDA battle_stat_a_hi+2                             ; $CD9B: AD 25 05
  SBC $001B                             ; $CD9E: ED 1B 00
  STA battle_stat_a_hi+2                             ; $CDA1: 8D 25 05
  BCC @SideBAnnihilated                 ; $CDA4: 90 0A
  LDA battle_stat_a_lo+2                             ; $CDA6: AD 24 05
  BNE @ApplySideALosses                 ; $CDA9: D0 15
  LDA battle_stat_a_hi+2                             ; $CDAB: AD 25 05
  BNE @ApplySideALosses                 ; $CDAE: D0 10
@SideBAnnihilated:
  LDA #$00                              ; $CDB0: A9 00
  STA battle_stat_a_lo+2                             ; $CDB2: 8D 24 05
  STA battle_stat_a_hi+2                             ; $CDB5: 8D 25 05
  LDA #$80                              ; $CDB8: A9 80
  STA $0000                             ; $CDBA: 8D 00 00
  JMP @AllySideOutcome                  ; $CDBD: 4C AB CE
; Side A stat A ($0522/$0523) -= enemy roll; zero means that army is
; annihilated -> enemy-side outcome branch.
@ApplySideALosses:
  LDA battle_stat_a_lo                             ; $CDC0: AD 22 05
  SEC                                   ; $CDC3: 38
  SBC $001C                             ; $CDC4: ED 1C 00
  STA battle_stat_a_lo                             ; $CDC7: 8D 22 05
  LDA battle_stat_a_hi                             ; $CDCA: AD 23 05
  SBC $001D                             ; $CDCD: ED 1D 00
  STA battle_stat_a_hi                             ; $CDD0: 8D 23 05
  BCC @SideAAnnihilated                 ; $CDD3: 90 0A
  LDA battle_stat_a_lo                             ; $CDD5: AD 22 05
  BNE @BothSidesSurvive                 ; $CDD8: D0 10
  LDA battle_stat_a_hi                             ; $CDDA: AD 23 05
  BNE @BothSidesSurvive                 ; $CDDD: D0 0B
@SideAAnnihilated:
  LDA #$00                              ; $CDDF: A9 00
  STA battle_stat_a_lo                             ; $CDE1: 8D 22 05
  STA battle_stat_a_hi                             ; $CDE4: 8D 23 05
  JMP @EnemySideOutcome                 ; $CDE7: 4C 06 CF
; --- Both armies survive the round ---------------------------------------------
; Pass 1: decrement low-nibble counters of every occupied formation slot.
; Then load the special officer $6D's status/Power; if the officer is active
; (Power != 0), pass 2 decrements high-nibble strength units (each lost unit
; also inflicts random troop damage via @RandomOfficerTroopDamage) and the
; officer's record is updated through a banked callback.
@BothSidesSurvive:
  LDA #$0F                              ; $CDEA: A9 0F
  STA $0010                             ; $CDEC: 8D 10 00
  LDA #$01                              ; $CDEF: A9 01
  STA $0011                             ; $CDF1: 8D 11 00
  JSR @ApplySlotAttrition               ; $CDF4: 20 40 CE
  JSR @LoadSpecialOfficer               ; $CDF7: 20 60 CF
  LDA special_officer_flag                             ; $CDFA: AD 2E 05
  BEQ @ExpireActionTimers               ; $CDFD: F0 21
  LDA #$F0                              ; $CDFF: A9 F0
  STA $0010                             ; $CE01: 8D 10 00
  LDA #$10                              ; $CE04: A9 10
  STA $0011                             ; $CE06: 8D 11 00
  LDA #$00                              ; $CE09: A9 00
  STA $000B                             ; $CE0B: 8D 0B 00
  STA $000C                             ; $CE0E: 8D 0C 00
  JSR @ApplySlotAttrition               ; $CE11: 20 40 CE
; Banked record update for the special officer: parameter $000A = $6D selects
; the officer; the trampoline maps bank pair $2E ($A000 <- prg $0E,
; $C000 <- prg $0F) and jumps to $A006 in bank $0E (JMP $D7FB in bank $0F),
; which applies the round's troop losses to officer $6D's record bytes 8-9.
; Execution resumes at @ExpireActionTimers after the inline target word.
  LDA #$6D                              ; $CE14: A9 6D
  STA $000A                             ; $CE16: 8D 0A 00
  LDY #$2E                              ; $CE19: A0 2E
  JSR B1F_BankedCallbackTrampoline      ; $CE1B: 20 07 EE
  .word $A006                           ; $CE1E: 06 A0  ; inline banked target
@ExpireActionTimers:
; Decrement the 5 action timers at $04DB-$04DF ($FF = inactive). A timer
; that reaches zero marks its slot in $04D8-$04DC as expired ($FF).
; Two passes: slots 0-3, then slot 4.
  LDY #$00                              ; $CE20: A0 00
@TimerLoop:
  LDA army_slot_base+3,Y                           ; $CE22: B9 DB 04
  CMP #$FF                              ; $CE25: C9 FF
  BEQ @TimerNext                        ; $CE27: F0 0D
  SEC                                   ; $CE29: 38
  SBC #$01                              ; $CE2A: E9 01
  STA army_slot_base+3,Y                           ; $CE2C: 99 DB 04
  BNE @TimerNext                        ; $CE2F: D0 05
  LDA #$FF                              ; $CE31: A9 FF
  STA army_slot_base,Y                           ; $CE33: 99 D8 04
@TimerNext:
  CPY #$04                              ; $CE36: C0 04
  BEQ @RoundDone                        ; $CE38: F0 05
  LDY #$04                              ; $CE3A: A0 04
  JMP @TimerLoop                        ; $CE3C: 4C 22 CE
@RoundDone:
  RTS                                   ; $CE3F: 60
;=== Helper: ApplySlotAttrition ($CE40-$CE5F) ===
; Decrements the attrition values of all 20 formation slots ($0650,Y).
; $0010 = nibble mask selecting which half of the packed byte is decremented,
; $0011 = decrement amount. Slot entries must be non-zero and match the mask.
;   Pass 1 ($0010=$0F, $0011=$01): decrement low-nibble per-round counter.
;   Pass 2 ($0010=$F0, $0011=$10): decrement high-nibble strength unit and
;   additionally inflict random troop damage on the slot's officer ($CE60).
@ApplySlotAttrition:
  LDY #$00                              ; $CE40: A0 00
@SlotLoop:
  LDA unit_immobilized,Y                           ; $CE42: B9 50 06
  BEQ @SlotNext                         ; $CE45: F0 13
  AND $0010                             ; $CE47: 2D 10 00
  BEQ @SlotNext                         ; $CE4A: F0 0E
  SEC                                   ; $CE4C: 38
  SBC $0011                             ; $CE4D: ED 11 00
  STA unit_immobilized,Y                           ; $CE50: 99 50 06
  LDA $0011                             ; $CE53: AD 11 00
  CMP #$10                              ; $CE56: C9 10
  BEQ @RandomOfficerTroopDamage         ; $CE58: F0 06
@SlotNext:
  INY                                   ; $CE5A: C8
  CPY #$14                              ; $CE5B: C0 14
  BCC @SlotLoop                         ; $CE5D: 90 E3
  RTS                                   ; $CE5F: 60
;=== Helper: RandomOfficerTroopDamage ($CE60-$CEA8) ===
; Strength-unit loss follow-up: subtracts a random amount ($50..$96) from the
; slot officer's troop count (record bytes 8-9, clamped at 0) and adds the
; applied damage to the $000B/$000C accumulator. Officer id comes from the
; $0664 roster at the current slot index Y.
@RandomOfficerTroopDamage:
  TYA                                   ; $CE60: 98
  PHA                                   ; $CE61: 48
  LDA battle_roster,Y                           ; $CE62: B9 64 06
  JSR B1F_GetOfficerRecordAddr          ; $CE65: 20 D7 F2
@RollDamage:
  JSR B1F_RandomByte                    ; $CE68: 20 7A E8
  CMP #$47                              ; $CE6B: C9 47
  BCS @RollDamage                       ; $CE6D: B0 F9
  CLC                                   ; $CE6F: 18
  ADC #$50                              ; $CE70: 69 50
  STA $0002                             ; $CE72: 8D 02 00
  LDY #$08                              ; $CE75: A0 08
  LDA ($00),Y                           ; $CE77: B1 00
  SEC                                   ; $CE79: 38
  SBC $0002                             ; $CE7A: ED 02 00
  STA $0002                             ; $CE7D: 8D 02 00
  INY                                   ; $CE80: C8
  LDA ($00),Y                           ; $CE81: B1 00
  SBC #$00                              ; $CE83: E9 00
  BPL @StoreTroops                      ; $CE85: 10 05
  LDA #$00                              ; $CE87: A9 00
  STA $0002                             ; $CE89: 8D 02 00
@StoreTroops:
  STA ($00),Y                           ; $CE8C: 91 00
  DEY                                   ; $CE8E: 88
  LDA $0002                             ; $CE8F: AD 02 00
  STA ($00),Y                           ; $CE92: 91 00
; Accumulate the damage actually applied for the later outcome scene.
  LDA $0002                             ; $CE94: AD 02 00
  CLC                                   ; $CE97: 18
  ADC $000B                             ; $CE98: 6D 0B 00
  STA $000B                             ; $CE9B: 8D 0B 00
  LDA #$00                              ; $CE9E: A9 00
  ADC $000C                             ; $CEA0: 6D 0C 00
  STA $000C                             ; $CEA3: 8D 0C 00
  PLA                                   ; $CEA6: 68
  TAY                                   ; $CEA7: A8
  JMP @SlotNext                         ; $CEA8: 4C 5A CE
;=== Outcome: ally-side branch ($CEAB-$CF05) ===
; Reached when side B stat A ($0524/$0525) is depleted or the round limit is
; hit. Records the outcome officer (11th roster slot), then sets the outcome
; variables and selects side via $0514 = 1.
@AllySideOutcome:
  LDA battle_roster+$0A                             ; $CEAB: AD 6E 06
  STA battle_target_officer                             ; $CEAE: 8D 2B 05
  LDA battle_attacker_code                             ; $CEB1: AD 0F 05
  CMP #$03                              ; $CEB4: C9 03
  BNE @AllyNormalLoss                   ; $CEB6: D0 1D
; Special outcome ($050F == 3): store ruler-B record byte 3 into the SRAM
; result flag, show ruler B ($0507 low nibble), scene $B5.
@AllySpecialOutcome:
  JSR @StoreRulerResultFlag             ; $CEB8: 20 92 CF
  LDA #$00                              ; $CEBB: A9 00
  STA battle_officer_slot                             ; $CEBD: 8D 09 05
  LDA battle_faction_pair                             ; $CEC0: AD 07 05
  AND #$0F                              ; $CEC3: 29 0F
  STA action_result_lo                             ; $CEC5: 8D 2C 04
  LDA #$03                              ; $CEC8: A9 03
  STA $00A4                             ; $CECA: 8D A4 00
  LDA #$B5                              ; $CECD: A9 B5
  STA battle_scene_index                             ; $CECF: 8D 0A 05
  JMP @SetAllyOutcomeSide               ; $CED2: 4C 00 CF
; Normal loss: ruler status flag itself becomes the SRAM result flag; show
; ruler A ($0507 high nibble). Scene $BF on annihilation ($0000 bit 7 set),
; $BE on stalemate.
@AllyNormalLoss:
  STA battle_outcome_flag                             ; $CED5: 8D 44 6F
  LDA #$0A                              ; $CED8: A9 0A
  STA battle_officer_slot                             ; $CEDA: 8D 09 05
  LDA battle_faction_pair                             ; $CEDD: AD 07 05
  LSR                                   ; $CEE0: 4A
  LSR                                   ; $CEE1: 4A
  LSR                                   ; $CEE2: 4A
  LSR                                   ; $CEE3: 4A
  AND #$0F                              ; $CEE4: 29 0F
  STA action_result_lo                             ; $CEE6: 8D 2C 04
  LDA #$04                              ; $CEE9: A9 04
  STA $00A4                             ; $CEEB: 8D A4 00
  LDA $0000                             ; $CEEE: AD 00 00
  BMI @AllyAnnihilationScene            ; $CEF1: 30 08
  LDA #$BE                              ; $CEF3: A9 BE
  STA battle_scene_index                             ; $CEF5: 8D 0A 05
  JMP @SetAllyOutcomeSide               ; $CEF8: 4C 00 CF
@AllyAnnihilationScene:
  LDA #$BF                              ; $CEFB: A9 BF
  STA battle_scene_index                             ; $CEFD: 8D 0A 05
@SetAllyOutcomeSide:
  LDA #$01                              ; $CF00: A9 01
  STA battle_side_selector                             ; $CF02: 8D 14 05
  RTS                                   ; $CF05: 60
;=== Outcome: enemy-side branch ($CF06-$CF5F) ===
; Reached when side A stat A ($0522/$0523) is depleted. Records the outcome
; officer (1st roster slot), inspects ruler B's record, and selects side via
; $0514 = 0.
@EnemySideOutcome:
  LDA battle_roster                             ; $CF06: AD 64 06
  STA battle_target_officer                             ; $CF09: 8D 2B 05
  LDA battle_faction_pair                             ; $CF0C: AD 07 05
  AND #$0F                              ; $CF0F: 29 0F
  JSR B1F_GetRulerDataPtr               ; $CF11: 20 68 F3
  LDY #$03                              ; $CF14: A0 03
  LDA ($00),Y                           ; $CF16: B1 00
  CMP #$03                              ; $CF18: C9 03
  BNE @EnemyNormalLoss                  ; $CF1A: D0 24
; Special outcome (ruler-B record byte 3 == 3): ruler status flag becomes the
; SRAM result flag, show ruler A ($0507 high nibble), scene $B5.
@EnemySpecialOutcome:
  LDA battle_attacker_code                             ; $CF1C: AD 0F 05
  STA battle_outcome_flag                             ; $CF1F: 8D 44 6F
  LDA #$0A                              ; $CF22: A9 0A
  STA battle_officer_slot                             ; $CF24: 8D 09 05
  LDA battle_faction_pair                             ; $CF27: AD 07 05
  LSR                                   ; $CF2A: 4A
  LSR                                   ; $CF2B: 4A
  LSR                                   ; $CF2C: 4A
  LSR                                   ; $CF2D: 4A
  AND #$0F                              ; $CF2E: 29 0F
  STA action_result_lo                             ; $CF30: 8D 2C 04
  LDA #$03                              ; $CF33: A9 03
  STA $00A4                             ; $CF35: 8D A4 00
  LDA #$B5                              ; $CF38: A9 B5
  STA battle_scene_index                             ; $CF3A: 8D 0A 05
  JMP @SetEnemyOutcomeSide              ; $CF3D: 4C 5A CF
; Normal loss: ruler-B record byte 3 becomes the SRAM result flag, show
; ruler B ($0507 low nibble), annihilation scene $BF.
@EnemyNormalLoss:
  JSR @StoreRulerResultFlag             ; $CF40: 20 92 CF
  LDA #$00                              ; $CF43: A9 00
  STA battle_officer_slot                             ; $CF45: 8D 09 05
  LDA battle_faction_pair                             ; $CF48: AD 07 05
  AND #$0F                              ; $CF4B: 29 0F
  STA action_result_lo                             ; $CF4D: 8D 2C 04
  LDA #$04                              ; $CF50: A9 04
  STA $00A4                             ; $CF52: 8D A4 00
  LDA #$BF                              ; $CF55: A9 BF
  STA battle_scene_index                             ; $CF57: 8D 0A 05
@SetEnemyOutcomeSide:
  LDA #$00                              ; $CF5A: A9 00
  STA battle_side_selector                             ; $CF5C: 8D 14 05
  RTS                                   ; $CF5F: 60
;=== Helper: LoadSpecialOfficer ($CF60-$CF91) ===
; Scans the $0664 roster for special officer id $6D. When found: records the
; slot index in $052F, and unless the record's status low bits (byte 11 & 3)
; equal 3, exports byte 11 high nibble to $052C and Power (byte 1) to $052E.
; $052E != 0 enables the pass-2 strength attrition in the caller.
@LoadSpecialOfficer:
  LDY #$00                              ; $CF60: A0 00
@ScanRoster:
  LDA battle_roster,Y                           ; $CF62: B9 64 06
  CMP #$6D                              ; $CF65: C9 6D
  BEQ @FoundSpecialOfficer              ; $CF67: F0 06
  INY                                   ; $CF69: C8
  CPY #$14                              ; $CF6A: C0 14
  BCC @ScanRoster                       ; $CF6C: 90 F4
  RTS                                   ; $CF6E: 60
@FoundSpecialOfficer:
  STY special_officer_idx                             ; $CF6F: 8C 2F 05
  LDA #$6D                              ; $CF72: A9 6D
  JSR B1F_GetOfficerRecordAddr          ; $CF74: 20 D7 F2
  LDY #$0B                              ; $CF77: A0 0B
  LDA ($00),Y                           ; $CF79: B1 00
  AND #$03                              ; $CF7B: 29 03
  CMP #$03                              ; $CF7D: C9 03
  BEQ @SpecialOfficerDone               ; $CF7F: F0 10
  LDY #$0B                              ; $CF81: A0 0B
  LDA ($00),Y                           ; $CF83: B1 00
  AND #$F0                              ; $CF85: 29 F0
  STA battle_target_param                             ; $CF87: 8D 2C 05
  LDY #$01                              ; $CF8A: A0 01
  LDA ($00),Y                           ; $CF8C: B1 00
  STA special_officer_flag                             ; $CF8E: 8D 2E 05
@SpecialOfficerDone:
  RTS                                   ; $CF91: 60
;=== Helper: StoreRulerResultFlag ($CF92-$CFA1) ===
; Copies ruler-B ($0507 low nibble) record byte 3 into the SRAM battle
; result flag at $6F44 via B1F_GetRulerDataPtr.
@StoreRulerResultFlag:
  LDA battle_faction_pair                             ; $CF92: AD 07 05
  AND #$0F                              ; $CF95: 29 0F
  JSR B1F_GetRulerDataPtr               ; $CF97: 20 68 F3
  LDY #$03                              ; $CF9A: A0 03
  LDA ($00),Y                           ; $CF9C: B1 00
  STA battle_outcome_flag                             ; $CF9E: 8D 44 6F
  RTS                                   ; $CFA1: 60
.endproc  ; BattleAttritionRound
;===============================================================================
; BattleStatusPanelDraw - battle status panel sprite renderer
; $CFA2-$D125 (helper @DrawDigit at $D126, panel data at $D13C-$D1EC).
; Entry: JMP stub BattleStatusPanelDraw_Entry at $A012.
;
; Gates: $008F (scroll hi / nametable bit) == 0, $04C8 == 0, battle command
; $0500 < $0C, and display-flags $005E bit5 set (panel enable).
;
; Draws the battle status panel in the top-right screen area via
; B1F_SpriteOamWriterSimple ($000A = Y base, $000C = X base):
;   1. Panel header icon (@PanelHeaderSprite) at (Y,X) = ($20,$B0): two 16x16
;      blocks - tiles $40/$41/$50/$51 at (Y+0, X+$20) and tiles
;      $60/$61/$70/$71 at (Y-$10, X+$30).
;   2. One mode-dependent 16x16 block at (Y+$10, X+$20): @PanelModeBlock1
;      (tiles $44/$45/$54/$55) when $005E bit6 is set, otherwise
;      @PanelModeBlock0 (tiles $42/$43/$52/$53).
;   3. Battle status counter $0505 via B1F_MathBinToBcd: tens digit at
;      (Y,X) = ($20,$E0) when non-zero, ones digit at ($20,$E8).
;   4. Round counter $0506: tens digit at ($10,$D0) when non-zero, ones
;      digit at ($10,$D8).
;   5. Selected side's strength as a 4-digit BCD number at Y = $40 with
;      leading-zero suppression ($0011 counts digits already drawn):
;      $005E bit6 clear -> stat A pair ($0522/$0523 = side 0,
;      $0524/$0525 = side 1); bit6 set -> stat B pair ($0526/$0527 or
;      $0528/$0529). $0504 bit7 (attacker flag) selects side 1 when set.
;      Digit columns: thousands X=$D0, hundreds X=$D8, tens X=$E0,
;      ones X=$E8.
;===============================================================================
.proc BattleStatusPanelDraw
  LDA $008F                             ; $CFA2: AD 8F 00  ; scroll hi (nametable bit)
  BNE @Exit                             ; $CFA5: D0 13
  LDA battle_overlay_flag                             ; $CFA7: AD C8 04
  BNE @Exit                             ; $CFAA: D0 0E
  LDA battle_scene_id                             ; $CFAC: AD 00 05  ; battle command id
  CMP #$0C                              ; $CFAF: C9 0C
  BCS @Exit                             ; $CFB1: B0 07
  LDA $005E                             ; $CFB3: AD 5E 00  ; display flags
  AND #$20                              ; $CFB6: 29 20     ; panel-enable bit
  BNE @DrawPanel                        ; $CFB8: D0 01
@Exit:
  RTS                                   ; $CFBA: 60
; --- Panel header: sprite base (Y,X) = ($20,$B0) --------------------------------
@DrawPanel:
  LDA #$20                              ; $CFBB: A9 20
  STA $000A                             ; $CFBD: 8D 0A 00  ; sprite Y base
  LDA #$B0                              ; $CFC0: A9 B0
  STA $000C                             ; $CFC2: 8D 0C 00  ; sprite X base
  LDA #<@PanelHeaderSprite              ; $CFC5: A9 3C
  STA $0000                             ; $CFC7: 8D 00 00
  LDA #>@PanelHeaderSprite              ; $CFCA: A9 D1
  STA $0001                             ; $CFCC: 8D 01 00
  LDA #$00                              ; $CFCF: A9 00
  STA $0002                             ; $CFD1: 8D 02 00  ; flip flags = none
  JSR B1F_SpriteOamWriterSimple         ; $CFD4: 20 AD F1
; --- Mode-dependent block: default @PanelModeBlock1 (bit6 set) ---------------
  LDA #<@PanelModeBlock1                ; $CFD7: A9 5D
  STA $0000                             ; $CFD9: 8D 00 00
  LDA #>@PanelModeBlock1                ; $CFDC: A9 D1
  STA $0001                             ; $CFDE: 8D 01 00
  LDA $005E                             ; $CFE1: AD 5E 00  ; display flags
  AND #$40                              ; $CFE4: 29 40     ; panel mode bit
  BNE @DrawModeBlock                    ; $CFE6: D0 0A
  LDA #<@PanelModeBlock0                ; $CFE8: A9 6E
  STA $0000                             ; $CFEA: 8D 00 00
  LDA #>@PanelModeBlock0                ; $CFED: A9 D1
  STA $0001                             ; $CFEF: 8D 01 00
@DrawModeBlock:
  JSR B1F_SpriteOamWriterSimple         ; $CFF2: 20 AD F1
; --- Status counter $0505: tens at ($20,$E0) if non-zero, ones at ($20,$E8) ---
  LDA battle_action_points                             ; $CFF5: AD 05 05  ; battle status counter
  STA $0001                             ; $CFF8: 8D 01 00  ; BCD input lo
  LDA #$00                              ; $CFFB: A9 00
  STA $0002                             ; $CFFD: 8D 02 00  ; BCD input mid
  STA $0003                             ; $D000: 8D 03 00  ; BCD input hi
  JSR B1F_MathBinToBcd                  ; $D003: 20 BA E9
  LDA $0007                             ; $D006: AD 07 00  ; BCD tens|ones
  LSR                                   ; $D009: 4A
  LSR                                   ; $D00A: 4A
  LSR                                   ; $D00B: 4A
  LSR                                   ; $D00C: 4A
  BEQ @StatusOnes                       ; $D00D: F0 0D     ; tens == 0: skip
  LDY #$20                              ; $D00F: A0 20
  STY $000A                             ; $D011: 8C 0A 00  ; Y = $20
  LDY #$E0                              ; $D014: A0 E0
  STY $000C                             ; $D016: 8C 0C 00  ; X = $E0
  JSR @DrawDigit                        ; $D019: 20 26 D1
@StatusOnes:
  LDA $0007                             ; $D01C: AD 07 00
  AND #$0F                              ; $D01F: 29 0F     ; ones digit
  LDY #$20                              ; $D021: A0 20
  STY $000A                             ; $D023: 8C 0A 00  ; Y = $20
  LDY #$E8                              ; $D026: A0 E8
  STY $000C                             ; $D028: 8C 0C 00  ; X = $E8
  JSR @DrawDigit                        ; $D02B: 20 26 D1
; --- Round counter $0506: tens at ($10,$D0) if non-zero, ones at ($10,$D8) ---
  LDA battle_round_counter                             ; $D02E: AD 06 05  ; battle round counter
  STA $0001                             ; $D031: 8D 01 00  ; BCD input lo
  LDA #$00                              ; $D034: A9 00
  STA $0002                             ; $D036: 8D 02 00  ; BCD input mid
  STA $0003                             ; $D039: 8D 03 00  ; BCD input hi
  JSR B1F_MathBinToBcd                  ; $D03C: 20 BA E9
  LDA $0007                             ; $D03F: AD 07 00  ; BCD tens|ones
  LSR                                   ; $D042: 4A
  LSR                                   ; $D043: 4A
  LSR                                   ; $D044: 4A
  LSR                                   ; $D045: 4A
  BEQ @RoundOnes                        ; $D046: F0 0D     ; tens == 0: skip
  LDY #$10                              ; $D048: A0 10
  STY $000A                             ; $D04A: 8C 0A 00  ; Y = $10
  LDY #$D0                              ; $D04D: A0 D0
  STY $000C                             ; $D04F: 8C 0C 00  ; X = $D0
  JSR @DrawDigit                        ; $D052: 20 26 D1
@RoundOnes:
  LDA $0007                             ; $D055: AD 07 00
  AND #$0F                              ; $D058: 29 0F     ; ones digit
  LDY #$10                              ; $D05A: A0 10
  STY $000A                             ; $D05C: 8C 0A 00  ; Y = $10
  LDY #$D8                              ; $D05F: A0 D8
  STY $000C                             ; $D061: 8C 0C 00  ; X = $D8
  JSR @DrawDigit                        ; $D064: 20 26 D1
; --- Strength value: stat A (bit6 clear) or stat B (bit6 set) -----------------
; $0504 bit7 (attacker flag) selects side 1 (X=2) instead of side 0 (X=0).
  LDA $005E                             ; $D067: AD 5E 00  ; display flags
  AND #$40                              ; $D06A: 29 40     ; panel mode bit
  BNE @LoadStatB                        ; $D06C: D0 2A
  LDX #$00                              ; $D06E: A2 00     ; side 0 stat pair
  LDA battle_side_flag                             ; $D070: AD 04 05  ; attacker flag
  BPL @LoadStatA                        ; $D073: 10 02
  LDX #$02                              ; $D075: A2 02     ; side 1 stat pair
@LoadStatA:
  LDA battle_stat_a_lo,X                           ; $D077: BD 22 05  ; stat A lo
  STA $0001                             ; $D07A: 8D 01 00  ; BCD input lo
  LDA battle_stat_a_hi,X                           ; $D07D: BD 23 05  ; stat A hi
  STA $0002                             ; $D080: 8D 02 00  ; BCD input mid
  LDA #$00                              ; $D083: A9 00
  STA $0003                             ; $D085: 8D 03 00  ; BCD input hi
  JSR B1F_MathBinToBcd                  ; $D088: 20 BA E9
  LDA #$40                              ; $D08B: A9 40
  STA $0010                             ; $D08D: 8D 10 00  ; digit row Y = $40
  LDA #$00                              ; $D090: A9 00
  STA $0011                             ; $D092: 8D 11 00  ; digits-drawn count
  JMP @DrawStrength                     ; $D095: 4C BF D0
@LoadStatB:
  LDX #$00                              ; $D098: A2 00     ; side 0 stat pair
  LDA battle_side_flag                             ; $D09A: AD 04 05  ; attacker flag
  BPL @StatBSelected                    ; $D09D: 10 02
  LDX #$02                              ; $D09F: A2 02     ; side 1 stat pair
@StatBSelected:
  LDA battle_stat_b_lo,X                           ; $D0A1: BD 26 05  ; stat B lo
  STA $0001                             ; $D0A4: 8D 01 00  ; BCD input lo
  LDA battle_stat_b_hi,X                           ; $D0A7: BD 27 05  ; stat B hi
  STA $0002                             ; $D0AA: 8D 02 00  ; BCD input mid
  LDA #$00                              ; $D0AD: A9 00
  STA $0003                             ; $D0AF: 8D 03 00  ; BCD input hi
  JSR B1F_MathBinToBcd                  ; $D0B2: 20 BA E9
  LDA #$40                              ; $D0B5: A9 40
  STA $0010                             ; $D0B7: 8D 10 00  ; digit row Y = $40
  LDA #$00                              ; $D0BA: A9 00
  STA $0011                             ; $D0BC: 8D 11 00  ; digits-drawn count
; --- 4-digit strength at Y=$40, leading zeros suppressed ----------------------
; Thousands X=$D0, hundreds X=$D8, tens X=$E0, ones X=$E8. $0011 counts the
; digits drawn so far; once a non-zero digit has appeared, remaining zeros
; are drawn as well (the ones digit is drawn unconditionally).
@DrawStrength:
  LDA $0008                             ; $D0BF: AD 08 00  ; BCD thousands|hundreds
  LSR                                   ; $D0C2: 4A
  LSR                                   ; $D0C3: 4A
  LSR                                   ; $D0C4: 4A
  LSR                                   ; $D0C5: 4A
  BEQ @StrengthHundreds                 ; $D0C6: F0 11     ; thousands == 0: skip
  INC $0011                             ; $D0C8: EE 11 00  ; one digit drawn
  LDY $0010                             ; $D0CB: AC 10 00  ; Y = $40
  STY $000A                             ; $D0CE: 8C 0A 00
  LDY #$D0                              ; $D0D1: A0 D0
  STY $000C                             ; $D0D3: 8C 0C 00  ; X = $D0
  JSR @DrawDigit                        ; $D0D6: 20 26 D1
@StrengthHundreds:
  LDA $0008                             ; $D0D9: AD 08 00
  AND #$0F                              ; $D0DC: 29 0F     ; hundreds digit
  BNE @DrawHundreds                     ; $D0DE: D0 05
  LDY $0011                             ; $D0E0: AC 11 00
  BEQ @StrengthTens                     ; $D0E3: F0 11     ; still leading zero
@DrawHundreds:
  INC $0011                             ; $D0E5: EE 11 00
  LDY $0010                             ; $D0E8: AC 10 00  ; Y = $40
  STY $000A                             ; $D0EB: 8C 0A 00
  LDY #$D8                              ; $D0EE: A0 D8
  STY $000C                             ; $D0F0: 8C 0C 00  ; X = $D8
  JSR @DrawDigit                        ; $D0F3: 20 26 D1
@StrengthTens:
  LDA $0007                             ; $D0F6: AD 07 00  ; BCD tens|ones
  LSR                                   ; $D0F9: 4A
  LSR                                   ; $D0FA: 4A
  LSR                                   ; $D0FB: 4A
  LSR                                   ; $D0FC: 4A
  BNE @DrawTens                         ; $D0FD: D0 05
  LDY $0011                             ; $D0FF: AC 11 00
  BEQ @StrengthOnes                     ; $D102: F0 0E     ; still leading zero
@DrawTens:
  LDY $0010                             ; $D104: AC 10 00  ; Y = $40
  STY $000A                             ; $D107: 8C 0A 00
  LDY #$E0                              ; $D10A: A0 E0
  STY $000C                             ; $D10C: 8C 0C 00  ; X = $E0
  JSR @DrawDigit                        ; $D10F: 20 26 D1
@StrengthOnes:
  LDA $0007                             ; $D112: AD 07 00
  AND #$0F                              ; $D115: 29 0F     ; ones digit
  LDY $0010                             ; $D117: AC 10 00  ; Y = $40
  STY $000A                             ; $D11A: 8C 0A 00
  LDY #$E8                              ; $D11D: A0 E8
  STY $000C                             ; $D11F: 8C 0C 00  ; X = $E8
  JSR @DrawDigit                        ; $D122: 20 26 D1
  RTS                                   ; $D125: 60
;=== Helper: DrawDigit ($D126-$D13A) ===
; Draws one decimal digit (A = 0-9) as a two-tile sprite (top/bottom tiles
; $46+A / $56+A) at the current sprite base ($000A = Y, $000C = X) via the
; @DigitPtrTable string lookup; tail-calls B1F_SpriteOamWriterSimple.
@DrawDigit:
  ASL                                   ; $D126: 0A        ; word index
  TAY                                   ; $D127: A8
  LDA @DigitPtrTable,Y                  ; $D128: B9 7F D1  ; string ptr lo
  STA $0000                             ; $D12B: 8D 00 00
  LDA @DigitPtrTable+1,Y                ; $D12E: B9 80 D1  ; string ptr hi
  STA $0001                             ; $D131: 8D 01 00
  LDA #$00                              ; $D134: A9 00
  STA $0002                             ; $D136: 8D 02 00  ; flip flags = none
  JMP B1F_SpriteOamWriterSimple         ; $D139: 4C AD F1
;=== Panel sprite data ($D13C-$D1EC) ===
; Sprite string format for B1F_SpriteOamWriterSimple: 4-byte entries
; [y_off, tile, attr, x_off] terminated by $80; screen position =
; (y_off + $000A, x_off + $000C).
; Panel header icon: two 16x16 blocks - the label block at (Y+0, X+$20) and
; the header block at (Y-$10, X+$30) via negative y_off.
@PanelHeaderSprite:
  .byte $00,$40,$00,$20                 ; $D13C: 00 40 00 20  ; (Y+0,   X+$20) tile $40
  .byte $00,$41,$00,$28                 ; $D140: 00 41 00 28  ; (Y+0,   X+$28) tile $41
  .byte $08,$50,$00,$20                 ; $D144: 08 50 00 20  ; (Y+8,   X+$20) tile $50
  .byte $08,$51,$00,$28                 ; $D148: 08 51 00 28  ; (Y+8,   X+$28) tile $51
  .byte $F0,$60,$00,$30                 ; $D14C: F0 60 00 30  ; (Y-$10, X+$30) tile $60
  .byte $F0,$61,$00,$38                 ; $D150: F0 61 00 38  ; (Y-$10, X+$38) tile $61
  .byte $F8,$70,$00,$30                 ; $D154: F8 70 00 30  ; (Y-$08, X+$30) tile $70
  .byte $F8,$71,$00,$38                 ; $D158: F8 71 00 38  ; (Y-$08, X+$38) tile $71
  .byte $80                             ; $D15C: 80           ; terminator
; Mode-dependent 16x16 block at (Y+$10, X+$20); variant for $005E bit6 set.
@PanelModeBlock1:
  .byte $10,$44,$00,$20                 ; $D15D: 10 44 00 20  ; (Y+$10, X+$20) tile $44
  .byte $10,$45,$00,$28                 ; $D161: 10 45 00 28  ; (Y+$10, X+$28) tile $45
  .byte $18,$54,$00,$20                 ; $D165: 18 54 00 20  ; (Y+$18, X+$20) tile $54
  .byte $18,$55,$00,$28                 ; $D169: 18 55 00 28  ; (Y+$18, X+$28) tile $55
  .byte $80                             ; $D16D: 80           ; terminator
; Mode-dependent 16x16 block variant for $005E bit6 clear.
@PanelModeBlock0:
  .byte $10,$42,$00,$20                 ; $D16E: 10 42 00 20  ; (Y+$10, X+$20) tile $42
  .byte $10,$43,$00,$28                 ; $D172: 10 43 00 28  ; (Y+$10, X+$28) tile $43
  .byte $18,$52,$00,$20                 ; $D176: 18 52 00 20  ; (Y+$18, X+$20) tile $52
  .byte $18,$53,$00,$28                 ; $D17A: 18 53 00 28  ; (Y+$18, X+$28) tile $53
  .byte $80                             ; $D17E: 80           ; terminator
; Digit sprite string pointers, indexed by digit value (see @DrawDigit).
@DigitPtrTable:
  .word @Digit0Sprite,@Digit1Sprite,@Digit2Sprite,@Digit3Sprite ; $D17F: 93 D1 9C D1 A5 D1 AE D1
  .word @Digit4Sprite,@Digit5Sprite,@Digit6Sprite,@Digit7Sprite ; $D187: B7 D1 C0 D1 C9 D1 D2 D1
  .word @Digit8Sprite,@Digit9Sprite                             ; $D18F: DB D1 E4 D1
; Digit sprite strings: each digit is two stacked tiles (top tile $46+digit
; at Y+0, bottom tile $56+digit at Y+8) drawn at the sprite base position.
@Digit0Sprite:
  .byte $00,$46,$00,$00,$08,$56,$00,$00,$80 ; $D193: 00 46 00 00 08 56 00 00 80
@Digit1Sprite:
  .byte $00,$47,$00,$00,$08,$57,$00,$00,$80 ; $D19C: 00 47 00 00 08 57 00 00 80
@Digit2Sprite:
  .byte $00,$48,$00,$00,$08,$58,$00,$00,$80 ; $D1A5: 00 48 00 00 08 58 00 00 80
@Digit3Sprite:
  .byte $00,$49,$00,$00,$08,$59,$00,$00,$80 ; $D1AE: 00 49 00 00 08 59 00 00 80
@Digit4Sprite:
  .byte $00,$4A,$00,$00,$08,$5A,$00,$00,$80 ; $D1B7: 00 4A 00 00 08 5A 00 00 80
@Digit5Sprite:
  .byte $00,$4B,$00,$00,$08,$5B,$00,$00,$80 ; $D1C0: 00 4B 00 00 08 5B 00 00 80
@Digit6Sprite:
  .byte $00,$4C,$00,$00,$08,$5C,$00,$00,$80 ; $D1C9: 00 4C 00 00 08 5C 00 00 80
@Digit7Sprite:
  .byte $00,$4D,$00,$00,$08,$5D,$00,$00,$80 ; $D1D2: 00 4D 00 00 08 5D 00 00 80
@Digit8Sprite:
  .byte $00,$4E,$00,$00,$08,$5E,$00,$00,$80 ; $D1DB: 00 4E 00 00 08 5E 00 00 80
@Digit9Sprite:
  .byte $00,$4F,$00,$00,$08,$5F,$00,$00,$80 ; $D1E4: 00 4F 00 00 08 5F 00 00 80
.endproc  ; BattleStatusPanelDraw
;===============================================================================
; DrawStratagemTargetMarkers - Battle stratagem target marker rendering
; Bank entry via StratagemTargetMarker_Entry ($A015). Runs once per battle
; screen refresh to draw 16x16 target marker sprites on the tactical map:
;   1. Select the effect CHR banks (@SelectEffectChrBanks).
;   2. Marker at the battle province's map position (@ProvinceMarkerOam),
;      suppressed when the province sits on a city tile and $005E bit6 is
;      clear.
;   3. Up to three markers at the city tile positions listed for the province
;      in the bank-$31 table at $9BA4 (@DrawCityTargetMarkers), each
;      suppressed when that city is actually in play and $005E bit6 is clear.
;
; Gates: $008F (scroll high/nametable bit) must be 0, battle command $0500
; must be < $0C, and screen mode $0061 must not be $07.
;
; Tables (PRG bank $31 in the $8000 window via B1F_SwitchBank8_B):
;   $9D58 - province pixel position, 4 bytes per province $050E:
;           (Y,X) pair of 16-bit little-endian pixel coordinates.
;   $9BA4 - 6 bytes per province $050E: three (X,Y) city tile pairs; a pair
;           with X >= $80 is unused.
; RAM: $0600/$0614 = X/Y tile coords of the 20 city tiles of the battlefield.
;===============================================================================
.proc DrawStratagemTargetMarkers
  LDA $008F                             ; $D1ED: AD 8F 00  ; scroll hi (nametable bit)
  BNE @Exit                             ; $D1F0: D0 07     ; wrapped scroll: skip
  LDA battle_scene_id                             ; $D1F2: AD 00 05  ; battle command id
  CMP #$0C                              ; $D1F5: C9 0C
  BCC @SelectChr                        ; $D1F7: 90 01     ; only commands 0-$0B
@Exit:
  RTS                                   ; $D1F9: 60
@SelectChr:
  JSR @SelectEffectChrBanks             ; $D1FA: 20 F5 D2
  LDA $0061                             ; $D1FD: AD 61 00  ; screen mode
  CMP #$07                              ; $D200: C9 07
  BEQ @Exit                             ; $D202: F0 F5     ; mode 7: skip markers
;--- Province marker ----------------------------------------------------------
; Fetch the province's 16-bit pixel position from the bank-$31 table at
; $9D58 (4 bytes per province $050E: Y lo/hi then X lo/hi). It stays in
; $000A-$000D and becomes the sprite base position for B1F_SpriteOamWriterScroll.
  LDY #$31                              ; $D204: A0 31
  JSR B1F_SwitchBank8_B                 ; $D206: 20 5F F2  ; PRG bank $31 -> $8000
  LDA battle_province_idx                             ; $D209: AD 0E 05  ; battle province id
  ASL                                   ; $D20C: 0A
  ASL                                   ; $D20D: 0A        ; *4
  TAY                                   ; $D20E: A8
  LDA $9D58,Y                           ; $D20F: B9 58 9D  ; pixel Y lo
  STA $000A                             ; $D212: 8D 0A 00
  LDA $9D59,Y                           ; $D215: B9 59 9D  ; pixel Y hi
  STA $000B                             ; $D218: 8D 0B 00
  LDA $9D5A,Y                           ; $D21B: B9 5A 9D  ; pixel X lo
  STA $000C                             ; $D21E: 8D 0C 00
  LDA $9D5B,Y                           ; $D221: B9 5B 9D  ; pixel X hi
  STA $000D                             ; $D224: 8D 0D 00
  JSR @CheckPositionHitsCityTile        ; $D227: 20 37 D3
  BCC @DrawCityMarkers                  ; $D22A: 90 21     ; on a city + bit6 clear: suppress
  LDA #$00                              ; $D22C: A9 00
  STA $0002                             ; $D22E: 8D 02 00  ; OAM writer flags: no flip
  LDA #<@ProvinceMarkerOam              ; $D231: A9 15
  STA $0000                             ; $D233: 8D 00 00
  LDA #>@ProvinceMarkerOam              ; $D236: A9 D3
  STA $0001                             ; $D238: 8D 01 00
  LDA #$00                              ; $D23B: A9 00
  STA $0002                             ; $D23D: 8D 02 00
  LDA #$00                              ; $D240: A9 00
  STA $0003                             ; $D242: 8D 03 00  ; tile index bias
  LDA #$9C                              ; $D245: A9 9C
  STA $0004                             ; $D247: 8D 04 00  ; on-screen Y clamp
  JSR B1F_SpriteOamWriterScroll_NoInit  ; $D24A: 20 9C F0  ; keeps preset $0003/$0004
;--- City target markers ------------------------------------------------------
; Falls through into @DrawCityTargetMarkers.
@DrawCityMarkers:
  LDY #$31                              ; $D24D: A0 31
  JSR B1F_SwitchBank8_B                 ; $D24F: 20 5F F2  ; PRG bank $31 -> $8000
  LDA battle_province_idx                             ; $D252: AD 0E 05
  ASL                                   ; $D255: 0A
  CLC                                   ; $D256: 18
  ADC battle_province_idx                             ; $D257: 6D 0E 05  ; *3
  ASL                                   ; $D25A: 0A        ; *6
  PHA                                   ; $D25B: 48
  TAY                                   ; $D25C: A8
; Pair 0 ($9BA4+0): X tile in $9BA4,Y / Y tile in $9BA5,Y
  LDA $9BA4,Y                           ; $D25D: B9 A4 9B  ; city X tile
  BMI @Pair1                            ; $D260: 30 0C     ; X >= $80: pair unused
  STA $000C                             ; $D262: 8D 0C 00
  LDA $9BA5,Y                           ; $D265: B9 A5 9B  ; city Y tile
  STA $000A                             ; $D268: 8D 0A 00
  JSR @DrawCityTargetMarker             ; $D26B: 20 96 D2
@Pair1:
  PLA                                   ; $D26E: 68
  PHA                                   ; $D26F: 48
  TAY                                   ; $D270: A8
  LDA $9BA6,Y                           ; $D271: B9 A6 9B  ; city X tile
  BMI @Pair2                            ; $D274: 30 0C
  STA $000C                             ; $D276: 8D 0C 00
  LDA $9BA7,Y                           ; $D279: B9 A7 9B  ; city Y tile
  STA $000A                             ; $D27C: 8D 0A 00
  JSR @DrawCityTargetMarker             ; $D27F: 20 96 D2
@Pair2:
  PLA                                   ; $D282: 68
  TAY                                   ; $D283: A8
  LDA $9BA8,Y                           ; $D284: B9 A8 9B  ; city X tile
  BMI @Done                             ; $D287: 30 0C
  STA $000C                             ; $D289: 8D 0C 00
  LDA $9BA9,Y                           ; $D28C: B9 A9 9B  ; city Y tile
  STA $000A                             ; $D28F: 8D 0A 00
  JSR @DrawCityTargetMarker             ; $D292: 20 96 D2
@Done:
  RTS                                   ; $D295: 60
;-------------------------------------------------------------------------------
; @DrawCityTargetMarker ($D296-$D2F4)
; Input: $000C = city X tile, $000A = city Y tile (bank-$31 $9BA4 pair).
; Scales the tile coords by 16 (tile -> pixel), re-uses the shared city-tile
; check, and when the marker is not suppressed draws the 16x16 city marker
; sprite list (@CityMarkerOam) at that pixel position.
;-------------------------------------------------------------------------------
@DrawCityTargetMarker:
  LDA #$00                              ; $D296: A9 00
  STA $000B                             ; $D298: 8D 0B 00
  STA $000D                             ; $D29B: 8D 0D 00
  ASL $000A                             ; $D29E: 0E 0A 00  ; Y tile *16
  ROL $000B                             ; $D2A1: 2E 0B 00
  ASL $000A                             ; $D2A4: 0E 0A 00
  ROL $000B                             ; $D2A7: 2E 0B 00
  ASL $000A                             ; $D2AA: 0E 0A 00
  ROL $000B                             ; $D2AD: 2E 0B 00
  ASL $000A                             ; $D2B0: 0E 0A 00
  ROL $000B                             ; $D2B3: 2E 0B 00
  ASL $000C                             ; $D2B6: 0E 0C 00  ; X tile *16
  ROL $000D                             ; $D2B9: 2E 0D 00
  ASL $000C                             ; $D2BC: 0E 0C 00
  ROL $000D                             ; $D2BF: 2E 0D 00
  ASL $000C                             ; $D2C2: 0E 0C 00
  ROL $000D                             ; $D2C5: 2E 0D 00
  ASL $000C                             ; $D2C8: 0E 0C 00
  ROL $000D                             ; $D2CB: 2E 0D 00
  JSR @CheckPositionHitsCityTile        ; $D2CE: 20 37 D3
  BCC @NoMarker                         ; $D2D1: 90 21     ; in-play city + bit6 clear: suppress
  LDA #$00                              ; $D2D3: A9 00
  STA $0002                             ; $D2D5: 8D 02 00  ; OAM writer flags: no flip
  LDA #<@CityMarkerOam                  ; $D2D8: A9 26
  STA $0000                             ; $D2DA: 8D 00 00
  LDA #>@CityMarkerOam                  ; $D2DD: A9 D3
  STA $0001                             ; $D2DF: 8D 01 00
  LDA #$00                              ; $D2E2: A9 00
  STA $0002                             ; $D2E4: 8D 02 00
  LDA #$00                              ; $D2E7: A9 00
  STA $0003                             ; $D2E9: 8D 03 00  ; tile index bias
  LDA #$9C                              ; $D2EC: A9 9C
  STA $0004                             ; $D2EE: 8D 04 00  ; on-screen Y clamp
  JMP B1F_SpriteOamWriterScroll_NoInit  ; $D2F1: 4C 9C F0  ; keeps preset $0003/$0004
@NoMarker:
  RTS                                   ; $D2F4: 60
;-------------------------------------------------------------------------------
; @SelectEffectChrBanks ($D2F5-$D314)
; Points the effect CHR slots at bank $88 or $8B depending on $005E bit4
; (which side's effect graphics). When $04C8 is clear the same bank is also
; mirrored into the extra slots $00C2/$00C6/$00D2.
;-------------------------------------------------------------------------------
@SelectEffectChrBanks:
  LDX #$88                              ; $D2F5: A2 88
  LDA $005E                             ; $D2F7: AD 5E 00  ; battle UI flags
  AND #$10                              ; $D2FA: 29 10
  BEQ @StoreChr                         ; $D2FC: F0 02
  LDX #$8B                              ; $D2FE: A2 8B
@StoreChr:
  STX $00B2                             ; $D300: 8E B2 00  ; CHR slot mirror
  STX $00D6                             ; $D303: 8E D6 00
  LDA battle_overlay_flag                             ; $D306: AD C8 04  ; battle overlay flag
  BNE @ChrDone                          ; $D309: D0 09
  STX $00C2                             ; $D30B: 8E C2 00
  STX $00C6                             ; $D30E: 8E C6 00
  STX $00D2                             ; $D311: 8E D2 00
@ChrDone:
  RTS                                   ; $D314: 60
; Province marker: 2x2 sprites (16x16 px), $80-terminated OAM list
; (X offset, tile, attribute, Y offset)
@ProvinceMarkerOam:
  .byte $00,$02,$01,$00                 ; $D315: 00 02 01 00
  .byte $00,$03,$01,$08                 ; $D319: 00 03 01 08
  .byte $08,$0E,$01,$00                 ; $D31D: 08 0E 01 00
  .byte $08,$0F,$01,$08                 ; $D321: 08 0F 01 08
  .byte $80                             ; $D325: 80        ; terminator
; City target marker: 2x2 sprites (16x16 px), $80-terminated OAM list
@CityMarkerOam:
  .byte $00,$3C,$01,$00                 ; $D326: 00 3C 01 00
  .byte $00,$3D,$01,$08                 ; $D32A: 00 3D 01 08
  .byte $08,$3E,$01,$00                 ; $D32E: 08 3E 01 00
  .byte $08,$3F,$01,$08                 ; $D332: 08 3F 01 08
  .byte $80                             ; $D336: 80        ; terminator
;-------------------------------------------------------------------------------
; @CheckPositionHitsCityTile ($D337-$D38F)
; Input: ($000A,$000B) and ($000C,$000D) = two 16-bit pixel coordinates.
; Divides each by 16 (pixel -> tile), then scans the 20 battlefield city
; tiles ($0600 = X, $0614 = Y) for a match on the (X,Y) pair.
; Output: carry set  = no match, OR (match AND $005E bit6 set);
;         carry clear = match AND $005E bit6 clear (marker suppressed).
;-------------------------------------------------------------------------------
@CheckPositionHitsCityTile:
  LDA $000A                             ; $D337: AD 0A 00
  STA $0000                             ; $D33A: 8D 00 00
  LDA $000B                             ; $D33D: AD 0B 00
  STA $0001                             ; $D340: 8D 01 00
  LDA $000C                             ; $D343: AD 0C 00
  STA $0002                             ; $D346: 8D 02 00
  LDA $000D                             ; $D349: AD 0D 00
  STA $0003                             ; $D34C: 8D 03 00
  LSR $0001                             ; $D34F: 4E 01 00  ; pair 1 /16
  ROR $0000                             ; $D352: 6E 00 00
  LSR $0000                             ; $D355: 4E 00 00
  LSR $0000                             ; $D358: 4E 00 00
  LSR $0000                             ; $D35B: 4E 00 00
  LSR $0003                             ; $D35E: 4E 03 00  ; pair 2 /16
  ROR $0002                             ; $D361: 6E 02 00
  LSR $0002                             ; $D364: 4E 02 00
  LSR $0002                             ; $D367: 4E 02 00
  LSR $0002                             ; $D36A: 4E 02 00
  LDY #$00                              ; $D36D: A0 00
@CityScan:
  LDA unit_coord_x,Y                           ; $D36F: B9 00 06  ; city X tile
  CMP $0002                             ; $D372: CD 02 00
  BNE @CityNext                         ; $D375: D0 13
  LDA unit_coord_y,Y                           ; $D377: B9 14 06  ; city Y tile
  CMP $0000                             ; $D37A: CD 00 00
  BNE @CityNext                         ; $D37D: D0 0B
  LDA $005E                             ; $D37F: AD 5E 00
  AND #$40                              ; $D382: 29 40
  BNE @MatchBit6Set                     ; $D384: D0 02
  CLC                                   ; $D386: 18        ; match + bit6 clear
  RTS                                   ; $D387: 60
@MatchBit6Set:
  SEC                                   ; $D388: 38        ; match + bit6 set
  RTS                                   ; $D389: 60
@CityNext:
  INY                                   ; $D38A: C8
  CPY #$14                              ; $D38B: C0 14     ; 20 city tiles
  BCC @CityScan                         ; $D38D: 90 E0
  RTS                                   ; $D38F: 60        ; no match (carry set)
.endproc  ; DrawStratagemTargetMarkers
;===============================================================================
; ValidateSpecialOfficer - special officer roster check for officer exchange
; $D390-$D3ED (roster @SpecialOfficerTable at $D3D8).
; Entry: JMP stub ValidateSpecialOfficer_Entry at $A018; invoked via
;        B1F_BankedCallbackTrampoline with LDY #$28 (PRG banks 08+09) from
;        prg_0c_0d officer exchange flows: OfficerExchangeDispatch::
;        @SetupAndValidate ($C73D) and ValidateExchangeOfficer ($DF12).
;
; Input:  $042C = candidate officer ID (officer_sel_list work byte).
; Output: $042D = unchanged (callers pre-clear it to 0) when the officer is
;                 a member of the roster partition for its status class;
;                 $FF = rejected (class outside 3-6 or not a member).
;
; Logic:  Fetches the 12-byte officer record ($63C0 + id*12) via
;         B1F_GetOfficerRecordAddr and derives the status class from the
;         high nibble of record byte 11 (status flags). Classes 3..6 select
;         a partition of the contiguous @SpecialOfficerTable (start offsets
;         $00/$0B/$11/$14); every other class rejects immediately. The
;         partition is scanned toward the shared $FF terminator: a match
;         accepts the officer, the terminator rejects it.
;
; Note:   The same roster and class thresholds are reused by BuildCommandList
;         (banked entry $A01B), which grants these special officers an
;         extended command menu (menu types 5-8 = 12/14/15/16 items) in
;         prg_0c_0d CommandState_Init. Officer $6D is the same "special
;         officer" handled by BattleAttritionRound::@LoadSpecialOfficer.
;===============================================================================
.proc ValidateSpecialOfficer
  LDA action_result_lo                             ; $D390: AD 2C 04  ; candidate officer id
  JSR B1F_GetOfficerRecordAddr          ; $D393: 20 D7 F2  ; ($00) = record ptr
  LDY #$0B                              ; $D396: A0 0B
  LDA ($00),Y                           ; $D398: B1 00     ; status flags byte
  LSR                                   ; $D39A: 4A
  LSR                                   ; $D39B: 4A
  LSR                                   ; $D39C: 4A
  LSR                                   ; $D39D: 4A        ; A = status class (hi nibble)
  CMP #$03                              ; $D39E: C9 03
  BNE @CheckClass4                      ; $D3A0: D0 05
  LDY #$00                              ; $D3A2: A0 00     ; class 3 partition offset
  JMP @ScanRoster                       ; $D3A4: 4C C8 D3
@CheckClass4:
  CMP #$04                              ; $D3A7: C9 04
  BNE @CheckClass5                      ; $D3A9: D0 05
  LDY #$0B                              ; $D3AB: A0 0B     ; class 4 partition offset
  JMP @ScanRoster                       ; $D3AD: 4C C8 D3
@CheckClass5:
  CMP #$05                              ; $D3B0: C9 05
  BNE @CheckClass6                      ; $D3B2: D0 05
  LDY #$11                              ; $D3B4: A0 11     ; class 5 partition offset
  JMP @ScanRoster                       ; $D3B6: 4C C8 D3
@CheckClass6:
  CMP #$06                              ; $D3B9: C9 06
  BNE @Reject                           ; $D3BB: D0 05     ; class outside 3-6
  LDY #$14                              ; $D3BD: A0 14     ; class 6 partition offset
  JMP @ScanRoster                       ; $D3BF: 4C C8 D3
@Reject:
  LDA #$FF                              ; $D3C2: A9 FF
  STA action_result_hi                             ; $D3C4: 8D 2D 04  ; reject: not in roster
@Done:
  RTS                                   ; $D3C7: 60
@ScanRoster:
  LDA @SpecialOfficerTable,Y            ; $D3C8: B9 D8 D3
  CMP #$FF                              ; $D3CB: C9 FF
  BEQ @Reject                           ; $D3CD: F0 F3     ; partition exhausted
  CMP action_result_lo                             ; $D3CF: CD 2C 04
  BEQ @Done                             ; $D3D2: F0 F3     ; member: keep $042D
  INY                                   ; $D3D4: C8
  JMP @ScanRoster                       ; $D3D5: 4C C8 D3
; Special officer roster, partitioned by status class (record byte 11 high
; nibble): class 3 = $A1..$B7 (11 ids), class 4 = $18..$67 (6 ids),
; class 5 = $C5,$56,$5D (3 ids), class 6 = $6D (1 id). Partitions are
; contiguous and share the single $FF terminator at $D3ED.
@SpecialOfficerTable:
  .byte $A1,$63,$A7,$16,$C4,$DB,$EA,$6B,$CE,$EB,$B7,$18,$37,$70,$D5,$6E; $D3D8: A1 63 A7 16 C4 DB EA 6B CE EB B7 18 37 70 D5 6E
  .byte $67,$C5,$56,$5D,$6D,$FF           ; $D3E8: 67 C5 56 5D 6D FF
.endproc  ; ValidateSpecialOfficer
;===============================================================================
; BuildCommandList - build the command/slot ID list for the current commander
; $D3EE-$D508 (slot tier pointers SlotTierPtrs at $D509, slot ID lists at
; $D51B-$D57A).
; Entry: JMP stub BuildCommandList_Entry at $A01B; invoked via
;        B1F_BankedCallbackTrampoline with LDY #$28 (PRG banks 08+09) from
;        prg_0c_0d CommandState_Init ($A8BB, inline .word $A01B).
;
; Input:  $050A = scene/command index; $0664 = battle roster (officer ids).
; Output: $0580-$058F = slot ID list ($FF-filled tail = unused slots),
;         $0542 = last used index (slot count - 1).
;
; Logic:  Commander = $0664[$050A]. Fetches the 12-byte officer record
;         ($63C0 + id*12) via B1F_GetOfficerRecordAddr and derives the
;         status class from the high nibble of record byte 11 ($0011).
;         Officers belonging to the special officer roster (same IDs as
;         ValidateSpecialOfficer::@SpecialOfficerTable) get an extended
;         slot list based on their status class:
;           class 3 roster ($A1..$B7)              -> 12 slots
;           class 4 roster ($18..$67)              -> 14 slots (class 3: 12)
;           class 5 roster ($C5,$56,$5D)           -> 16 slots (4: 15, 3: 12)
;           special officer $6D                    -> 16 slots (5: 15, 4: 14, 3: 12)
;         All other officers fall back to record byte 2 (rating):
;           < $28 -> 2 slots, < $3C -> 4, < $4B -> 6, < $55 -> 8, else 10.
;         The resulting slot tier Y indexes SlotTierPtrs; the selected
;         $FF-terminated slot ID list is copied into $0580 and $0542 is
;         set to count-1. Consumers in banks $0C/$0D use $0542 to pick
;         the menu layout and iterate $0580 for per-slot messages.
;===============================================================================
.proc BuildCommandList
; --- Proc-local RAM ---
slot_id_list           = $0580  ; slot ID list output ($FF = unused)
slot_count_m1          = $0542  ; last used slot index (count - 1)
; --- Code Region ---
  LDY #$0F                              ; $D3EE: A0 0F
  LDA #$FF                              ; $D3F0: A9 FF
@ClearSlotBuf:
  STA slot_id_list,Y                           ; $D3F2: 99 80 05  ; $FF = unused slot
  DEY                                   ; $D3F5: 88
  BPL @ClearSlotBuf                     ; $D3F6: 10 FA
  LDY battle_scene_index                             ; $D3F8: AC 0A 05  ; scene/command index
  LDA battle_roster,Y                           ; $D3FB: B9 64 06  ; commander officer id
  STA $0010                             ; $D3FE: 8D 10 00
  JSR B1F_GetOfficerRecordAddr          ; $D401: 20 D7 F2  ; ($00) = record ptr
  LDY #$0B                              ; $D404: A0 0B
  LDA ($00),Y                           ; $D406: B1 00     ; status flags byte
  LSR                                   ; $D408: 4A
  LSR                                   ; $D409: 4A
  LSR                                   ; $D40A: 4A
  LSR                                   ; $D40B: 4A        ; A = status class
  STA $0011                             ; $D40C: 8D 11 00
  LDA $0010                             ; $D40F: AD 10 00
  CMP #$A1                              ; $D412: C9 A1     ; class 3 roster ids
  BEQ @Class3Roster                     ; $D414: F0 28
  CMP #$63                              ; $D416: C9 63
  BEQ @Class3Roster                     ; $D418: F0 24
  CMP #$A7                              ; $D41A: C9 A7
  BEQ @Class3Roster                     ; $D41C: F0 20
  CMP #$16                              ; $D41E: C9 16
  BEQ @Class3Roster                     ; $D420: F0 1C
  CMP #$C4                              ; $D422: C9 C4
  BEQ @Class3Roster                     ; $D424: F0 18
  CMP #$DB                              ; $D426: C9 DB
  BEQ @Class3Roster                     ; $D428: F0 14
  CMP #$EA                              ; $D42A: C9 EA
  BEQ @Class3Roster                     ; $D42C: F0 10
  CMP #$6B                              ; $D42E: C9 6B
  BEQ @Class3Roster                     ; $D430: F0 0C
  CMP #$CE                              ; $D432: C9 CE
  BEQ @Class3Roster                     ; $D434: F0 08
  CMP #$EB                              ; $D436: C9 EB
  BEQ @Class3Roster                     ; $D438: F0 04
  CMP #$B7                              ; $D43A: C9 B7
  BNE @Class4RosterCheck                ; $D43C: D0 0C
@Class3Roster:
  LDA $0011                             ; $D43E: AD 11 00
  CMP #$03                              ; $D441: C9 03
  BCC @Class4RosterCheck                ; $D443: 90 05     ; class < 3: no boost
  LDY #$05                              ; $D445: A0 05     ; tier 5 = 12 slots
  JMP @ApplyTier                        ; $D447: 4C E6 D4
@Class4RosterCheck:
  LDA $0010                             ; $D44A: AD 10 00
  CMP #$18                              ; $D44D: C9 18     ; class 4 roster ids
  BEQ @Class4Roster                     ; $D44F: F0 14
  CMP #$37                              ; $D451: C9 37
  BEQ @Class4Roster                     ; $D453: F0 10
  CMP #$70                              ; $D455: C9 70
  BEQ @Class4Roster                     ; $D457: F0 0C
  CMP #$D5                              ; $D459: C9 D5
  BEQ @Class4Roster                     ; $D45B: F0 08
  CMP #$6E                              ; $D45D: C9 6E
  BEQ @Class4Roster                     ; $D45F: F0 04
  CMP #$67                              ; $D461: C9 67
  BNE @Class5RosterCheck                ; $D463: D0 15
@Class4Roster:
  LDA $0011                             ; $D465: AD 11 00
  CMP #$04                              ; $D468: C9 04
  BCC @Class4RosterClass3               ; $D46A: 90 05
  LDY #$06                              ; $D46C: A0 06     ; class 4: 14 slots
  JMP @ApplyTier                        ; $D46E: 4C E6 D4
@Class4RosterClass3:
  CMP #$03                              ; $D471: C9 03
  BCC @Class5RosterCheck                ; $D473: 90 05     ; class < 3: no boost
  LDY #$05                              ; $D475: A0 05     ; class 3: 12 slots
  JMP @ApplyTier                        ; $D477: 4C E6 D4
@Class5RosterCheck:
  LDA $0010                             ; $D47A: AD 10 00
  CMP #$C5                              ; $D47D: C9 C5     ; class 5 roster ids
  BEQ @Class5Roster                     ; $D47F: F0 08
  CMP #$56                              ; $D481: C9 56
  BEQ @Class5Roster                     ; $D483: F0 04
  CMP #$5D                              ; $D485: C9 5D
  BNE @SpecialOfficerCheck              ; $D487: D0 1E
@Class5Roster:
  LDA $0011                             ; $D489: AD 11 00
  CMP #$05                              ; $D48C: C9 05
  BCC @Class5RosterClass4               ; $D48E: 90 05
  LDY #$07                              ; $D490: A0 07     ; class 5: 16 slots
  JMP @ApplyTier                        ; $D492: 4C E6 D4
@Class5RosterClass4:
  CMP #$04                              ; $D495: C9 04
  BCC @Class5RosterClass3               ; $D497: 90 05
  LDY #$06                              ; $D499: A0 06     ; class 4: 15 slots
  JMP @ApplyTier                        ; $D49B: 4C E6 D4
@Class5RosterClass3:
  CMP #$03                              ; $D49E: C9 03
  BCC @SpecialOfficerCheck              ; $D4A0: 90 05     ; class < 3: no boost
  LDY #$05                              ; $D4A2: A0 05     ; class 3: 12 slots
  JMP @ApplyTier                        ; $D4A4: 4C E6 D4
@SpecialOfficerCheck:
  LDA $0010                             ; $D4A7: AD 10 00
  CMP #$6D                              ; $D4AA: C9 6D     ; special officer $6D
  BNE @RatingFallback                   ; $D4AC: D0 18
  LDA $0011                             ; $D4AE: AD 11 00
  LDY #$08                              ; $D4B1: A0 08     ; class 6: 16 slots
  CMP #$06                              ; $D4B3: C9 06
  BCS @ApplyTier                        ; $D4B5: B0 2F
  DEY                                   ; $D4B7: 88        ; class 5: 15 slots
  CMP #$05                              ; $D4B8: C9 05
  BCS @ApplyTier                        ; $D4BA: B0 2A
  DEY                                   ; $D4BC: 88        ; class 4: 14 slots
  CMP #$04                              ; $D4BD: C9 04
  BCS @ApplyTier                        ; $D4BF: B0 25
  DEY                                   ; $D4C1: 88        ; class 3: 12 slots
  CMP #$03                              ; $D4C2: C9 03
  BCS @ApplyTier                        ; $D4C4: B0 20     ; else: fall through
@RatingFallback:
  LDA $0010                             ; $D4C6: AD 10 00
  JSR B1F_GetOfficerRecordAddr          ; $D4C9: 20 D7 F2  ; ($00) = record ptr
  LDY #$02                              ; $D4CC: A0 02
  LDA ($00),Y                           ; $D4CE: B1 00     ; record byte 2 (rating)
  LDY #$00                              ; $D4D0: A0 00     ; Y = slot tier
  CMP #$28                              ; $D4D2: C9 28
  BCC @ApplyTier                        ; $D4D4: 90 10     ; rating < 40: 2 slots
  INY                                   ; $D4D6: C8
  CMP #$3C                              ; $D4D7: C9 3C
  BCC @ApplyTier                        ; $D4D9: 90 0B     ; < 60: 4 slots
  INY                                   ; $D4DB: C8
  CMP #$4B                              ; $D4DC: C9 4B
  BCC @ApplyTier                        ; $D4DE: 90 06     ; < 75: 6 slots
  INY                                   ; $D4E0: C8
  CMP #$55                              ; $D4E1: C9 55
  BCC @ApplyTier                        ; $D4E3: 90 01     ; < 85: 8 slots
  INY                                   ; $D4E5: C8        ; >= 85: 10 slots
@ApplyTier:
  TYA                                   ; $D4E6: 98
  ASL                                   ; $D4E7: 0A
  TAY                                   ; $D4E8: A8
  LDA SlotTierPtrs,Y                    ; $D4E9: B9 09 D5
  STA $0000                             ; $D4EC: 8D 00 00
  LDA SlotTierPtrs+1,Y                  ; $D4EF: B9 0A D5
  STA $0001                             ; $D4F2: 8D 01 00
  LDY #$00                              ; $D4F5: A0 00
@CopySlotList:
  LDA ($00),Y                           ; $D4F7: B1 00
  CMP #$FF                              ; $D4F9: C9 FF     ; list terminator
  BEQ @StoreSlotCount                   ; $D4FB: F0 07
  STA slot_id_list,Y                           ; $D4FD: 99 80 05
  INY                                   ; $D500: C8
  JMP @CopySlotList                     ; $D501: 4C F7 D4
@StoreSlotCount:
  DEY                                   ; $D504: 88        ; Y = last used index
  STY slot_count_m1                             ; $D505: 8C 42 05  ; slot count - 1
  RTS                                   ; $D508: 60
; --- Data Region ---
; Slot tier pointer table: tier Y (0-8) -> slot ID list below.
; Tier 0-4 = rating fallback (2/4/6/8/10 slots), tier 5-8 = special
; officer extensions (12/14/15/16 slots).
SlotTierPtrs:
  .word SlotList_2                      ; $D509: 1B D5
  .word SlotList_4                      ; $D50B: 1E D5
  .word SlotList_6                      ; $D50D: 23 D5
  .word SlotList_8                      ; $D50F: 2A D5
  .word SlotList_10                     ; $D511: 33 D5
  .word SlotList_12                     ; $D513: 3E D5
  .word SlotList_14                     ; $D515: 4B D5
  .word SlotList_15                     ; $D517: 5A D5
  .word SlotList_16                     ; $D519: 6A D5
; Slot ID lists, $FF-terminated (slot IDs 0..N-1).
SlotList_2:
  .byte $00,$01,$FF                     ; $D51B: 00 01 FF
SlotList_4:
  .byte $00,$01,$02,$03,$FF             ; $D51E: 00 01 02 03 FF
SlotList_6:
  .byte $00,$01,$02,$03,$04,$05,$FF     ; $D523: 00 01 02 03 04 05 FF
SlotList_8:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$FF; $D52A: 00 01 02 03 04 05 06 07 FF
SlotList_10:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$FF; $D533: 00 01 02 03 04 05 06 07 08 09 FF
SlotList_12:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$FF; $D53E: 00 01 02 03 04 05 06 07 08 09 0A 0B FF
SlotList_14:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$FF; $D54B: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D FF
SlotList_15:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$FF; $D55A: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E FF
SlotList_16:
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F; $D56A: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
  .byte $FF                             ; $D57A: FF
.endproc  ; BuildCommandList
;===============================================================================
; BattleMapScrollUpdate - Battlefield map scroll handler ($D57B-$D66D)
; Called via bank entry stub $A021 (bank 0C/0D scenes reach it through
; B1F_BankedCallbackTrampoline with Y=$28).
; Applies pending scroll requests from the $0508 direction bits to the
; battle map scroll registers, stepping 2 pixels per frame per direction:
;   bit 7: scroll_x ($008E) += 2 (east)    bit 6: scroll_x -= 2 (west)
;   bit 5: scroll_y ($0090) -= 2 (north)   bit 4: scroll_y += 2 (south)
; Each step updates the facing flags in $009C (bit 7/6 = last X direction,
; bit 4/5 = last Y direction). A direction bit is cleared when the scroll
; reaches its limit: X on carry/borrow or when ($008E & $0E) == 0, Y on
; borrow or when scroll_y >= $90. $0000 acts as a secondary direction
; mirror (bit 4 mirrors the north request, bit 5 mirrors south); it is
; cleared on entry, so normally only the $0508 bits drive scrolling.
; Only runs while scene id $0500 < $0C.
;===============================================================================
.proc BattleMapScrollUpdate
; --- Proc-local RAM ---
scroll_dir_bits        = $0508  ; pending scroll direction bits (7=E,6=W,5=N,4=S)
  LDA battle_scene_id                             ; $D57B: AD 00 05  ; scene id
  CMP #$0C                              ; $D57E: C9 0C
  BCC @Process                          ; $D580: 90 01     ; scenes 0-11 only
  RTS                                   ; $D582: 60
@Process:
  LDA #$00                              ; $D583: A9 00     ; clear secondary
  STA $0000                             ; $D585: 8D 00 00  ; direction mirror
  LDA scroll_dir_bits                             ; $D588: AD 08 05  ; direction bits
  BMI @ScrollEast                       ; $D58B: 30 05     ; bit 7: east
  LDA $0000                             ; $D58D: AD 00 00  ; mirror (always 0)
  BPL @CheckWest                        ; $D590: 10 2C     ; always taken
@ScrollEast:
  LDA scroll_dir_bits                             ; $D592: AD 08 05
  ORA #$80                              ; $D595: 09 80     ; reassert east bit
  STA scroll_dir_bits                             ; $D597: 8D 08 05
  LDA $008E                             ; $D59A: AD 8E 00  ; scroll_x
  CLC                                   ; $D59D: 18
  ADC #$02                              ; $D59E: 69 02     ; += 2 px
  BCS @ClearEast                        ; $D5A0: B0 14     ; past $FF: stop
  STA $008E                             ; $D5A2: 8D 8E 00
  LDA $009C                             ; $D5A5: AD 9C 00  ; facing flags
  AND #$BF                              ; $D5A8: 29 BF     ; clear west
  ORA #$80                              ; $D5AA: 09 80     ; set east
  STA $009C                             ; $D5AC: 8D 9C 00
  LDA $008E                             ; $D5AF: AD 8E 00
  AND #$0E                              ; $D5B2: 29 0E     ; edge check
  BNE @CheckWest                        ; $D5B4: D0 08     ; not at edge
@ClearEast:
  LDA scroll_dir_bits                             ; $D5B6: AD 08 05
  AND #$7F                              ; $D5B9: 29 7F     ; clear east bit
  STA scroll_dir_bits                             ; $D5BB: 8D 08 05
@CheckWest:
  LDA scroll_dir_bits                             ; $D5BE: AD 08 05
  ASL                                   ; $D5C1: 0A        ; bit 6 -> N
  BMI @ScrollWest                       ; $D5C2: 30 06     ; west requested
  LDA $0000                             ; $D5C4: AD 00 00  ; secondary mirror
  ASL                                   ; $D5C7: 0A
  BPL @CheckNorth                       ; $D5C8: 10 2C     ; no west: vertical
@ScrollWest:
  LDA scroll_dir_bits                             ; $D5CA: AD 08 05
  ORA #$40                              ; $D5CD: 09 40     ; reassert west bit
  STA scroll_dir_bits                             ; $D5CF: 8D 08 05
  LDA $008E                             ; $D5D2: AD 8E 00  ; scroll_x
  SEC                                   ; $D5D5: 38
  SBC #$02                              ; $D5D6: E9 02     ; -= 2 px
  BCC @ClearWest                        ; $D5D8: 90 14     ; underflow: stop
  STA $008E                             ; $D5DA: 8D 8E 00
  LDA $009C                             ; $D5DD: AD 9C 00
  AND #$7F                              ; $D5E0: 29 7F     ; clear east
  ORA #$40                              ; $D5E2: 09 40     ; set west
  STA $009C                             ; $D5E4: 8D 9C 00
  LDA $008E                             ; $D5E7: AD 8E 00
  AND #$0E                              ; $D5EA: 29 0E     ; edge check
  BNE @CheckNorth                       ; $D5EC: D0 08
@ClearWest:
  LDA scroll_dir_bits                             ; $D5EE: AD 08 05
  AND #$BF                              ; $D5F1: 29 BF     ; clear west bit
  STA scroll_dir_bits                             ; $D5F3: 8D 08 05
@CheckNorth:
  LDA scroll_dir_bits                             ; $D5F6: AD 08 05
  ASL                                   ; $D5F9: 0A
  ASL                                   ; $D5FA: 0A        ; bit 5 -> N
  BMI @ScrollNorth                      ; $D5FB: 30 07     ; north requested
  LDA $0000                             ; $D5FD: AD 00 00  ; secondary mirror
  AND #$10                              ; $D600: 29 10     ; mirror bit 4
  BEQ @CheckSouth                       ; $D602: F0 2C     ; no north: south
@ScrollNorth:
  LDA scroll_dir_bits                             ; $D604: AD 08 05
  ORA #$20                              ; $D607: 09 20     ; reassert north bit
  STA scroll_dir_bits                             ; $D609: 8D 08 05
  LDA $0090                             ; $D60C: AD 90 00  ; scroll_y
  SEC                                   ; $D60F: 38
  SBC #$02                              ; $D610: E9 02     ; -= 2 px
  BCC @ClearNorth                       ; $D612: 90 14     ; underflow: stop
  STA $0090                             ; $D614: 8D 90 00
  LDA $009C                             ; $D617: AD 9C 00
  AND #$DF                              ; $D61A: 29 DF     ; clear south
  ORA #$10                              ; $D61C: 09 10     ; set north
  STA $009C                             ; $D61E: 8D 9C 00
  LDA $0090                             ; $D621: AD 90 00
  AND #$0E                              ; $D624: 29 0E     ; edge check
  BNE @CheckSouth                       ; $D626: D0 08
@ClearNorth:
  LDA scroll_dir_bits                             ; $D628: AD 08 05
  AND #$DF                              ; $D62B: 29 DF     ; clear north bit
  STA scroll_dir_bits                             ; $D62D: 8D 08 05
@CheckSouth:
  LDA scroll_dir_bits                             ; $D630: AD 08 05
  ASL                                   ; $D633: 0A
  ASL                                   ; $D634: 0A
  ASL                                   ; $D635: 0A        ; bit 4 -> N
  BMI @ScrollSouth                      ; $D636: 30 07     ; south requested
  LDA $0000                             ; $D638: AD 00 00  ; secondary mirror
  AND #$20                              ; $D63B: 29 20     ; mirror bit 5
  BEQ @Done                             ; $D63D: F0 2E     ; no south: exit
@ScrollSouth:
  LDA scroll_dir_bits                             ; $D63F: AD 08 05
  ORA #$10                              ; $D642: 09 10     ; reassert south bit
  STA scroll_dir_bits                             ; $D644: 8D 08 05
  LDA $0090                             ; $D647: AD 90 00  ; scroll_y
  CLC                                   ; $D64A: 18
  ADC #$02                              ; $D64B: 69 02     ; += 2 px
  CMP #$90                              ; $D64D: C9 90     ; lower limit $90
  BCS @ClearSouth                       ; $D64F: B0 14     ; reached: stop
  STA $0090                             ; $D651: 8D 90 00
  LDA $009C                             ; $D654: AD 9C 00
  AND #$EF                              ; $D657: 29 EF     ; clear north
  ORA #$20                              ; $D659: 09 20     ; set south
  STA $009C                             ; $D65B: 8D 9C 00
  LDA $0090                             ; $D65E: AD 90 00
  AND #$0E                              ; $D661: 29 0E     ; edge check
  BNE @Done                             ; $D663: D0 08
@ClearSouth:
  LDA scroll_dir_bits                             ; $D665: AD 08 05
  AND #$EF                              ; $D668: 29 EF     ; clear south bit
  STA scroll_dir_bits                             ; $D66A: 8D 08 05
@Done:
  RTS                                   ; $D66D: 60
.endproc  ; BattleMapScrollUpdate
;===============================================================================
; BattleResultSceneInit - Battle result scene setup ($D66E-$D6CC)
; Called via bank entry stub $A027 (bank 0C/0D scenes reach it through
; B1F_BankedCallbackTrampoline with Y=$28).
; Prepares the battle result scene from the attacker code in $050F:
;   attacker == 3 (ally side): ruler outcome flag $6F44 is taken from
;     byte 3 of the ally ruler's record (low nibble of $0507 resolved via
;     B1F_GetRulerDataPtr), variant $0509 cleared, ruler id $042C = low
;     nibble, event index $00A4 = 4, scene id $050A = $51 (victory).
;   otherwise (enemy side): $6F44 = attacker code, ruler id $042C = high
;     nibble of $0507, event index $00A4 = 3, scene id $050A = $50 (defeat).
; Then enters the result scene: state $0500 = 7, sub-state $0501 = 2.
; Also clears side selector $0514 and copies the special officer id from
; $0664 into $052B.
;===============================================================================
.proc BattleResultSceneInit
  LDA #$00                              ; $D66E: A9 00
  STA battle_side_selector                             ; $D670: 8D 14 05  ; side selector = 0
  LDA battle_roster                             ; $D673: AD 64 06  ; special officer id
  STA battle_target_officer                             ; $D676: 8D 2B 05
  LDA battle_attacker_code                             ; $D679: AD 0F 05  ; attacker code
  CMP #$03                              ; $D67C: C9 03
  BEQ @AllyVictory                      ; $D67E: F0 1C     ; ally side won
  STA battle_outcome_flag                             ; $D680: 8D 44 6F  ; ruler result flag
  LDA battle_faction_pair                             ; $D683: AD 07 05  ; packed ruler pair
  LSR                                   ; $D686: 4A
  LSR                                   ; $D687: 4A
  LSR                                   ; $D688: 4A
  LSR                                   ; $D689: 4A        ; high nibble
  AND #$0F                              ; $D68A: 29 0F
  STA action_result_lo                             ; $D68C: 8D 2C 04  ; ruler id
  LDA #$03                              ; $D68F: A9 03
  STA $00A4                             ; $D691: 8D A4 00  ; event index
  LDA #$50                              ; $D694: A9 50
  STA battle_scene_index                             ; $D696: 8D 0A 05  ; scene id: defeat
  JMP @EnterResultScene                 ; $D699: 4C C2 D6
@AllyVictory:
  LDA battle_faction_pair                             ; $D69C: AD 07 05  ; packed ruler pair
  AND #$0F                              ; $D69F: 29 0F     ; low nibble
  JSR B1F_GetRulerDataPtr               ; $D6A1: 20 68 F3  ; ($00) = ruler data
  LDY #$03                              ; $D6A4: A0 03
  LDA ($00),Y                           ; $D6A6: B1 00     ; ruler outcome flag
  STA battle_outcome_flag                             ; $D6A8: 8D 44 6F
  LDA #$00                              ; $D6AB: A9 00
  STA battle_officer_slot                             ; $D6AD: 8D 09 05  ; variant = 0
  LDA battle_faction_pair                             ; $D6B0: AD 07 05
  AND #$0F                              ; $D6B3: 29 0F
  STA action_result_lo                             ; $D6B5: 8D 2C 04  ; ruler id
  LDA #$04                              ; $D6B8: A9 04
  STA $00A4                             ; $D6BA: 8D A4 00  ; event index
  LDA #$51                              ; $D6BD: A9 51
  STA battle_scene_index                             ; $D6BF: 8D 0A 05  ; scene id: victory
@EnterResultScene:
  LDA #$07                              ; $D6C2: A9 07
  STA battle_scene_id                             ; $D6C4: 8D 00 05  ; state = result
  LDA #$02                              ; $D6C7: A9 02
  STA battle_scene_phase                             ; $D6C9: 8D 01 05  ; sub-state = 2
  RTS                                   ; $D6CC: 60
.endproc  ; BattleResultSceneInit
;===============================================================================
; BattleSlotClear - Clear battle slot records and timer group ($D6CD-$D70E)
; Called via bank entry stub $A02A; the slot index arrives in $0000.
; Writes $FF into column Y of all seven slot record tables ($0600, $0614,
; $0628, $063C, $0650, $0664, $6FA1), then clears the 4-byte action timer
; group ($04D8-$04DB or $04DC-$04DF) whose owner byte matches the slot:
; owner byte plus the three following timer bytes are reset to $FF. If
; neither group owns the slot, only the record column is cleared.
;===============================================================================
.proc BattleSlotClear
  LDY $0000                             ; $D6CD: AC 00 00  ; slot index
  LDA #$FF                              ; $D6D0: A9 FF
  STA unit_coord_x,Y                           ; $D6D2: 99 00 06  ; record row 0
  STA unit_coord_y,Y                           ; $D6D5: 99 14 06  ; record row 1
  STA unit_army_array,Y                           ; $D6D8: 99 28 06  ; record row 2
  STA unit_state_array,Y                           ; $D6DB: 99 3C 06  ; record row 3
  STA unit_immobilized,Y                           ; $D6DE: 99 50 06  ; record row 4
  STA battle_roster,Y                           ; $D6E1: 99 64 06  ; record row 5
  STA officer_state_table,Y                           ; $D6E4: 99 A1 6F  ; record row 6
  LDX #$00                              ; $D6E7: A2 00     ; timer group 0
  LDA army_slot_base                             ; $D6E9: AD D8 04  ; group 0 owner slot
  CMP $0000                             ; $D6EC: CD 00 00
  BEQ @ClearTimerGroup                  ; $D6EF: F0 0B
  LDX #$04                              ; $D6F1: A2 04     ; timer group 1
  LDA army_slot_base+4                             ; $D6F3: AD DC 04  ; group 1 owner slot
  CMP $0000                             ; $D6F6: CD 00 00
  BEQ @ClearTimerGroup                  ; $D6F9: F0 01
  RTS                                   ; $D6FB: 60        ; slot not owned
@ClearTimerGroup:
  TXA                                   ; $D6FC: 8A
  CLC                                   ; $D6FD: 18
  ADC #$04                              ; $D6FE: 69 04     ; group end offset
  STA $0001                             ; $D700: 8D 01 00
  LDA #$FF                              ; $D703: A9 FF
@ClearLoop:
  STA army_slot_base,X                           ; $D705: 9D D8 04  ; owner + 3 timers
  INX                                   ; $D708: E8
  CPX $0001                             ; $D709: EC 01 00
  BCC @ClearLoop                        ; $D70C: 90 F7
  RTS                                   ; $D70E: 60
.endproc  ; BattleSlotClear
;===============================================================================
; BattleResultDispatch - Battle result scene per-frame state machine
; ($D70F-$D739, phases nested through $D905)
; Called via bank entry stub $A024: NmiState7_Strategy in prg_1f ($FA44)
; maps banks 08/09 (Y=$28) and JSRs $A024 every frame of the result scene.
; Per frame it first runs the four direction input-repeat handlers
; (BattleResultDirRepeat0-3, counters $0545-$0548), then dispatches twice
; through B1F_CallbackDispatcher with inline tables:
;   1) on $0540 (scene sub-mode; single entry -> the scene tick below)
;   2) on $0541 (phase index, 7 entries below)
; The dispatcher pops the JSR return address and JMPs to the selected
; handler, so a phase handler's RTS returns directly to the NMI caller
; (tail call); execution never continues past an inline table.
;   Phase 0: BattleResult_InitRecords   - init entry records, enter UI page $DA
;   Phase 1: BattleResult_OpenMenuWait  - wait A/B press, open the entry menu
;   Phase 2: BattleResult_SelectMenuEntry - A/B on a menu row (B=finalize)
;   Phase 3: BattleResult_ConfirmMenuWait - second A/B wait, enter pick mode
;   Phase 4: BattleResult_PickEntry     - row pick; banked slot clear ($A02A)
;   Phase 5: BattleResult_InspectEntry  - banked callback ($A000), A/B -> back
;   Phase 6: BattleResult_Finalize      - banked finalize, slot template reset
;===============================================================================
.proc BattleResultDispatch
; --- Proc-local RAM (shared by nested phase procs) ---
result_sub_mode        = $0540  ; result scene sub-mode (dispatch index)
picked_entry_id        = $046D  ; picked entry id (phases 4-5)
result_param_copy      = $6F43  ; latched result parameter ($0543 copy)
  JSR BattleResultDirRepeat0            ; $D70F: 20 10 DB  ; dir repeat, group 0
  JSR BattleResultDirRepeat1            ; $D712: 20 62 DB  ; dir repeat, group 1
  JSR BattleResultDirRepeat2            ; $D715: 20 B4 DB  ; dir repeat, group 2
  JSR BattleResultDirRepeat3            ; $D718: 20 FF DB  ; dir repeat, group 3
  LDA result_sub_mode                             ; $D71B: AD 40 05  ; scene sub-mode (0)
  JSR B1F_CallbackDispatcher            ; $D71E: 20 DE EA
; --- Inline dispatch table (1 entry) ---
  .word BattleResult_SceneTick          ; $D721: 23 D7
BattleResult_SceneTick:  ; (dispatch callback target)
  JSR BattleResultSceneFrameDraw        ; $D723: 20 48 DA  ; scene frame sprites
  LDA result_scene_phase                             ; $D726: AD 41 05  ; phase index
  JSR B1F_CallbackDispatcher            ; $D729: 20 DE EA
; --- Inline dispatch table (7 entries, phases 0-6) ---
  .word BattleResult_InitRecords        ; $D72C: 3A D7  (phase 0)
  .word BattleResult_OpenMenuWait       ; $D72E: 78 D7  (phase 1)
  .word BattleResult_SelectMenuEntry    ; $D730: B0 D7  (phase 2)
  .word BattleResult_ConfirmMenuWait    ; $D732: 0C D8  (phase 3)
  .word BattleResult_PickEntry          ; $D734: 44 D8  (phase 4)
  .word BattleResult_InspectEntry       ; $D736: A0 D8  (phase 5)
  .word BattleResult_Finalize           ; $D738: E4 D8  (phase 6)
;-------------------------------------------------------------------------------
; Phase 0: BattleResult_InitRecords
; Initializes the seven result entry records at $6F07..$6F3A (stride 8) from
; BattleResult_RecordInitTable, clears the dir-repeat counters $0545-$0549,
; latches the result parameters ($0543 -> $6F43, $0544 -> $6F02), clears the
; outcome flag $6F44, arms UI context $042C=1/$042D=0/$042E=0 and enters UI
; page $DA via B1F_SetUI4 (does not return here).
;-------------------------------------------------------------------------------
.proc BattleResult_InitRecords  ; (dispatch callback target)
; --- Proc-local RAM ---
result_param_a         = $0543  ; result parameter A (-> result_param_copy)
result_param_b         = $0544  ; result parameter B (-> result_kingdom_idx)
result_kingdom_idx     = $6F02  ; latched kingdom index
dir_repeat_spare       = $0549  ; spare dir-repeat byte (cleared)
  JSR BattleResultEntryInit             ; $D73A: 20 7A D9
  LDA #$00                              ; $D73D: A9 00
  STA result_dir_repeat                             ; $D73F: 8D 45 05  ; dir repeat idx 0
  STA result_dir_repeat+1                             ; $D742: 8D 46 05  ; dir repeat idx 1
  STA result_dir_repeat+2                             ; $D745: 8D 47 05  ; dir repeat idx 2
  STA result_dir_repeat+3                             ; $D748: 8D 48 05  ; dir repeat idx 3
  STA dir_repeat_spare                             ; $D74B: 8D 49 05
  LDA result_param_a                             ; $D74E: AD 43 05  ; result parameter
  STA result_param_copy                             ; $D751: 8D 43 6F
  LDA result_param_b                             ; $D754: AD 44 05  ; result parameter
  STA result_kingdom_idx                             ; $D757: 8D 02 6F
  LDA #$00                              ; $D75A: A9 00
  STA battle_outcome_flag                             ; $D75C: 8D 44 6F  ; outcome flag = none
  STA $00A4                             ; $D75F: 8D A4 00  ; event index = 0
  INC result_scene_phase                             ; $D762: EE 41 05  ; -> phase 1
  LDA #$01                              ; $D765: A9 01
  STA action_result_lo                             ; $D767: 8D 2C 04  ; UI context
  LDA #$00                              ; $D76A: A9 00
  STA action_result_hi                             ; $D76C: 8D 2D 04
  STA action_result_cnt                             ; $D76F: 8D 2E 04
  LDA #$DA                              ; $D772: A9 DA
  JMP B1F_SetUI4                        ; $D774: 4C 8B F2  ; enter UI page $DA
.endproc  ; BattleResult_InitRecords
  .byte $60                             ; $D777: 60       ; pad (RTS opcode)
;-------------------------------------------------------------------------------
; Phase 1: BattleResult_OpenMenuWait
; Waits until the scene is ready (BattleResultReadyCheck), keeps the menu
; cursor sprite alive (BattleResultCursorSpriteDraw), then waits for an A or B
; press ($0081 bits 0-1). On press: advance to phase 2, clear the menu
; context ($0424/$0425/$040C/$040D), reset the row cursor $046C, preselect
; entry $DE in $0410 and re-arm the UI request registers.
;-------------------------------------------------------------------------------
.proc BattleResult_OpenMenuWait  ; (dispatch callback target)
  JSR BattleResultReadyCheck            ; $D778: 20 FE DA
  BCC @Wait                             ; $D77B: 90 32     ; scene not ready
  JSR BattleResultCursorSpriteDraw      ; $D77D: 20 D9 DA
  LDA $0081                             ; $D780: AD 81 00  ; new presses
  AND #$03                              ; $D783: 29 03     ; A or B
  BEQ @Wait                             ; $D785: F0 28
  INC result_scene_phase                             ; $D787: EE 41 05  ; -> phase 2
  LDA #$00                              ; $D78A: A9 00
  STA menu_cursor_col                             ; $D78C: 8D 24 04
  STA menu_cursor_page                             ; $D78F: 8D 25 04
  STA result_cursor_x                             ; $D792: 8D 0C 04
  STA result_cursor_y                             ; $D795: 8D 0D 04
  STA result_menu_row                             ; $D798: 8D 6C 04  ; row cursor = 0
  LDA #$DE                              ; $D79B: A9 DE
  STA result_sel_entry                             ; $D79D: 8D 10 04  ; default entry id
  LDA #$00                              ; $D7A0: A9 00
  STA $0098                             ; $D7A2: 8D 98 00
  LDA #$01                              ; $D7A5: A9 01
  STA $0097                             ; $D7A7: 8D 97 00
  LDA #$06                              ; $D7AA: A9 06
  STA $00BB                             ; $D7AC: 8D BB 00
@Wait:
  RTS                                   ; $D7AF: 60
.endproc  ; BattleResult_OpenMenuWait
;-------------------------------------------------------------------------------
; Phase 2: BattleResult_SelectMenuEntry
; Polls the entry menu (BattleResultMenuPoll) until the selection is stable,
; then samples the pad. A-only press selects the row in $0012: the mapped
; entry record's status byte ($6F07+idx*8, offset 3) is cleared to 0 and,
; depending on the result parameter $6F43, either enters the confirm wait
; (phase 3, outcome flag $6F44=1, UI context $042C=2) or jumps straight to
; phase 6 after a palette buffer copy. A+B together finalizes immediately.
;-------------------------------------------------------------------------------
.proc BattleResult_SelectMenuEntry  ; (dispatch callback target)
  JSR BattleResultMenuPoll              ; $D7B0: 20 06 D9
  BCC @Done                             ; $D7B3: 90 2D     ; cursor still moving
  LDA $0081                             ; $D7B5: AD 81 00  ; new presses
  AND #$01                              ; $D7B8: 29 01     ; A
  BEQ @Done                             ; $D7BA: F0 26
  LDA $0083                             ; $D7BC: AD 83 00  ; held buttons
  AND #$08                              ; $D7BF: 29 08     ; B held too
  BEQ @Select                           ; $D7C1: F0 03
  JMP BattleResult_Finalize             ; $D7C3: 4C E4 D8  ; A+B -> finalize
@Select:
  LDY $0012                             ; $D7C6: AC 12 00  ; selected row
  LDA BattleResult_RowToRecordMap,Y     ; $D7C9: B9 07 DA  ; row -> record idx
  ASL                                   ; $D7CC: 0A
  ASL                                   ; $D7CD: 0A
  ASL                                   ; $D7CE: 0A        ; idx*8
  TAY                                   ; $D7CF: A8
  LDA #$00                              ; $D7D0: A9 00
  STA faction_rec_status,Y                           ; $D7D2: 99 0A 6F  ; record status = 0
  LDA result_param_copy                             ; $D7D5: AD 43 6F  ; result parameter
  BNE @AdvanceConfirm                   ; $D7D8: D0 09
  LDA #$06                              ; $D7DA: A9 06
  STA result_scene_phase                             ; $D7DC: 8D 41 05  ; -> phase 6
  JSR B1F_PaletteCopyBuffer             ; $D7DF: 20 EE EC
@Done:
  RTS                                   ; $D7E2: 60
@AdvanceConfirm:
  INC result_scene_phase                             ; $D7E3: EE 41 05  ; -> phase 3
  LDA #$01                              ; $D7E6: A9 01
  STA battle_outcome_flag                             ; $D7E8: 8D 44 6F  ; outcome flag = 1
  LDA #$A0                              ; $D7EB: A9 A0
  STA $0098                             ; $D7ED: 8D 98 00
  LDA #$00                              ; $D7F0: A9 00
  STA $0097                             ; $D7F2: 8D 97 00
  LDA #$09                              ; $D7F5: A9 09
  STA $00BB                             ; $D7F7: 8D BB 00
  LDA #$02                              ; $D7FA: A9 02
  STA action_result_lo                             ; $D7FC: 8D 2C 04  ; UI context
  LDA #$00                              ; $D7FF: A9 00
  STA action_result_hi                             ; $D801: 8D 2D 04
  STA action_result_cnt                             ; $D804: 8D 2E 04
  LDA #$DA                              ; $D807: A9 DA
  JMP B1F_SetUI4                        ; $D809: 4C 8B F2  ; enter UI page $DA
.endproc  ; BattleResult_SelectMenuEntry
;-------------------------------------------------------------------------------
; Phase 3: BattleResult_ConfirmMenuWait
; Mirror of phase 1 for the confirm step: waits for scene readiness, keeps
; the cursor sprite alive, and on an A/B press advances to phase 4 with the
; menu context cleared, entry preselect $DE and re-armed UI registers.
;-------------------------------------------------------------------------------
.proc BattleResult_ConfirmMenuWait  ; (dispatch callback target)
  JSR BattleResultReadyCheck            ; $D80C: 20 FE DA
  BCC @Wait                             ; $D80F: 90 32     ; scene not ready
  JSR BattleResultCursorSpriteDraw      ; $D811: 20 D9 DA
  LDA $0081                             ; $D814: AD 81 00  ; new presses
  AND #$03                              ; $D817: 29 03     ; A or B
  BEQ @Wait                             ; $D819: F0 28
  INC result_scene_phase                             ; $D81B: EE 41 05  ; -> phase 4
  LDA #$00                              ; $D81E: A9 00
  STA menu_cursor_col                             ; $D820: 8D 24 04
  STA menu_cursor_page                             ; $D823: 8D 25 04
  STA result_cursor_x                             ; $D826: 8D 0C 04
  STA result_cursor_y                             ; $D829: 8D 0D 04
  STA result_menu_row                             ; $D82C: 8D 6C 04  ; row cursor = 0
  LDA #$DE                              ; $D82F: A9 DE
  STA result_sel_entry                             ; $D831: 8D 10 04  ; default entry id
  LDA #$00                              ; $D834: A9 00
  STA $0098                             ; $D836: 8D 98 00
  LDA #$01                              ; $D839: A9 01
  STA $0097                             ; $D83B: 8D 97 00
  LDA #$06                              ; $D83E: A9 06
  STA $00BB                             ; $D840: 8D BB 00
@Wait:
  RTS                                   ; $D843: 60
.endproc  ; BattleResult_ConfirmMenuWait
;-------------------------------------------------------------------------------
; Phase 4: BattleResult_PickEntry
; Polls the entry menu and, on an A press with the selection stable, looks up
; the row's entry record. Status != 0: record is marked consumed (status = 1)
; and the scene jumps to phase 6 after a palette buffer copy. Status == 0:
; fresh pick - the entry id ($DA0F table, idx*4) goes to $046D, phase -> 5,
; UI re-armed ($0098=$A0/$0097=0/$00BB=9), then the slot is cleared through a
; banked call ($A02A stub, bank pair $3D) with the entry id in $0000, and UI
; mode $DB is entered via B1F_SetUI0 (does not return here).
;-------------------------------------------------------------------------------
.proc BattleResult_PickEntry  ; (dispatch callback target)
  JSR BattleResultMenuPoll              ; $D844: 20 06 D9
  BCC @Done                             ; $D847: 90 23     ; cursor still moving
  LDA $0081                             ; $D849: AD 81 00  ; new presses
  AND #$01                              ; $D84C: 29 01     ; A
  BEQ @Done                             ; $D84E: F0 1C
  LDY $0012                             ; $D850: AC 12 00  ; selected row
  LDA BattleResult_RowToRecordMap,Y     ; $D853: B9 07 DA  ; row -> record idx
  ASL                                   ; $D856: 0A
  ASL                                   ; $D857: 0A
  ASL                                   ; $D858: 0A        ; idx*8
  TAY                                   ; $D859: A8
  LDA faction_rec_status,Y                           ; $D85A: B9 0A 6F  ; record status
  BEQ @PickFresh                        ; $D85D: F0 0E     ; status 0 -> pick
  LDA #$01                              ; $D85F: A9 01
  STA faction_rec_status,Y                           ; $D861: 99 0A 6F  ; status = consumed
  LDA #$06                              ; $D864: A9 06
  STA result_scene_phase                             ; $D866: 8D 41 05  ; -> phase 6
  JSR B1F_PaletteCopyBuffer             ; $D869: 20 EE EC
@Done:
  RTS                                   ; $D86C: 60
@PickFresh:
  LDY $0012                             ; $D86D: AC 12 00  ; selected row
  LDA BattleResult_RowToRecordMap,Y     ; $D870: B9 07 DA  ; row -> record idx
  ASL                                   ; $D873: 0A
  ASL                                   ; $D874: 0A        ; idx*4
  TAY                                   ; $D875: A8
  LDA BattleResult_RecordInitTable,Y    ; $D876: B9 0F DA  ; entry id
  STA picked_entry_id                             ; $D879: 8D 6D 04
  INC result_scene_phase                             ; $D87C: EE 41 05  ; -> phase 5
  LDA #$A0                              ; $D87F: A9 A0
  STA $0098                             ; $D881: 8D 98 00
  LDA #$00                              ; $D884: A9 00
  STA $0097                             ; $D886: 8D 97 00
  LDA #$09                              ; $D889: A9 09
  STA $00BB                             ; $D88B: 8D BB 00
  LDA picked_entry_id                             ; $D88E: AD 6D 04  ; entry id
  STA $0000                             ; $D891: 8D 00 00  ; slot index param
  LDY #$3D                              ; $D894: A0 3D     ; bank pair param
  JSR B1F_BankedCallbackTrampoline      ; $D896: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word B1D_1E_OfficerDisplay_Lookup     ; $D899: 2A A0  ; slot clear (bank $3D)
  LDA #$DB                              ; $D89B: A9 DB
  JMP B1F_SetUI0                        ; $D89D: 4C 6D F2  ; UI mode $DB
.endproc  ; BattleResult_PickEntry
;-------------------------------------------------------------------------------
; Phase 5: BattleResult_InspectEntry
; Runs the banked callback for the picked entry ($046D in $0000, target $A000,
; bank pair $39, OAM slot base $000A=$A7), then waits for scene readiness and
; an A/B press. Any press returns to phase 4 (DEC $0541) with the entry id
; promoted to the selection $0410 and the UI request registers re-armed.
;-------------------------------------------------------------------------------
.proc BattleResult_InspectEntry  ; (dispatch callback target)
  LDA picked_entry_id                             ; $D8A0: AD 6D 04  ; picked entry id
  STA $0000                             ; $D8A3: 8D 00 00  ; callback param
  LDX #$00                              ; $D8A6: A2 00
  LDA #$A7                              ; $D8A8: A9 A7
  STA $000A                             ; $D8AA: 8D 0A 00  ; OAM slot base
  LDY #$39                              ; $D8AD: A0 39     ; bank pair param
  JSR B1F_BankedCallbackTrampoline      ; $D8AF: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                           ; $D8B2: 00 A0
  JSR BattleResultReadyCheck            ; $D8B4: 20 FE DA
  BCC @Wait                             ; $D8B7: 90 2A     ; scene not ready
  JSR BattleResultCursorSpriteDraw      ; $D8B9: 20 D9 DA
  LDA $0081                             ; $D8BC: AD 81 00  ; new presses
  AND #$03                              ; $D8BF: 29 03     ; A or B
  BEQ @Wait                             ; $D8C1: F0 20
  DEC result_scene_phase                             ; $D8C3: CE 41 05  ; back to phase 4
  LDA picked_entry_id                             ; $D8C6: AD 6D 04  ; entry id
  STA result_sel_entry                             ; $D8C9: 8D 10 04  ; -> selection
  LDA #$00                              ; $D8CC: A9 00
  STA result_cursor_x                             ; $D8CE: 8D 0C 04
  STA result_cursor_y                             ; $D8D1: 8D 0D 04
  LDA #$00                              ; $D8D4: A9 00
  STA $0098                             ; $D8D6: 8D 98 00
  LDA #$01                              ; $D8D9: A9 01
  STA $0097                             ; $D8DB: 8D 97 00
  LDA #$06                              ; $D8DE: A9 06
  STA $00BB                             ; $D8E0: 8D BB 00
@Wait:
  RTS                                   ; $D8E3: 60
.endproc  ; BattleResult_InspectEntry
;-------------------------------------------------------------------------------
; Phase 6: BattleResult_Finalize
; Final banked callback (selection $0410 in $0000, target $A000, bank pair
; $39, OAM slot base $A7). If the battle-continue flag $0087 is negative the
; scene hands over to BattleResultSlotReset (sets $007A=1 and tail-JMPs);
; otherwise it just returns and keeps polling.
;-------------------------------------------------------------------------------
.proc BattleResult_Finalize  ; (dispatch callback target)
  LDA #$A7                              ; $D8E4: A9 A7
  STA $000A                             ; $D8E6: 8D 0A 00  ; OAM slot base
  LDA result_sel_entry                             ; $D8E9: AD 10 04  ; selected entry
  STA $0000                             ; $D8EC: 8D 00 00  ; callback param
  LDX #$00                              ; $D8EF: A2 00
  LDY #$39                              ; $D8F1: A0 39     ; bank pair param
  JSR B1F_BankedCallbackTrampoline      ; $D8F3: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                           ; $D8F6: 00 A0
  LDA $0087                             ; $D8F8: AD 87 00  ; battle-continue flag
  BPL @Exit                             ; $D8FB: 10 08
  LDA #$01                              ; $D8FD: A9 01
  STA $007A                             ; $D8FF: 8D 7A 00
  JMP BattleResultSlotReset             ; $D902: 4C 4A DC
@Exit:
  RTS                                   ; $D905: 60
.endproc  ; BattleResult_Finalize
.endproc  ; BattleResultDispatch
;-------------------------------------------------------------------------------
; BattleResultMenuPoll - entry menu refresh and selection poll ($D906-$D979)
; Called from phases 2 and 4.
; 1) Points ($0010) at BattleResult_CursorPosTable and ($00) at
;    BattleResult_CursorSpriteLayout; B1F_PointerTableLookup draws the cursor
;    sprite at the Y/X base pair selected by the row cursor $046C.
; 2) Banked UI refresh ($A000, bank pair $39, OAM slot base $A7) with the
;    current selection $0410 in $0000.
; 3) If the pending-selection flag $040D != $FF: re-arms the banked refresh
;    with target $A012 and reports busy (CLC).
;    Otherwise steps the menu via B1F_MenuStep2 over
;    BattleResult_EntryOrderList (result in $0012): a changed row index
;    updates $046C, resolves the entry id through RowToRecordMap /
;    RecordInitTable into $0410, clears $040C/$040D and reports busy (CLC);
;    an unchanged index reports stable (SEC) so the caller polls the pad.
;-------------------------------------------------------------------------------
.proc BattleResultMenuPoll
  LDA #$35                              ; $D906: A9 35
  STA $0010                             ; $D908: 8D 10 00
  LDA #$DA                              ; $D90B: A9 DA
  STA $0011                             ; $D90D: 8D 11 00  ; ($0010) = $DA35 pos table
  LDA #$43                              ; $D910: A9 43
  STA $0000                             ; $D912: 8D 00 00
  LDA #$DA                              ; $D915: A9 DA
  STA $0001                             ; $D917: 8D 01 00  ; ($00) = $DA43 cursor layout
  LDA result_menu_row                             ; $D91A: AD 6C 04  ; row cursor
  JSR B1F_PointerTableLookup            ; $D91D: 20 F5 ED  ; draw cursor sprite
  LDA #$A7                              ; $D920: A9 A7
  STA $000A                             ; $D922: 8D 0A 00  ; OAM slot base
  LDA result_sel_entry                             ; $D925: AD 10 04  ; selection
  STA $0000                             ; $D928: 8D 00 00  ; callback param
  LDX #$00                              ; $D92B: A2 00
  LDY #$39                              ; $D92D: A0 39     ; bank pair param
  JSR B1F_BankedCallbackTrampoline      ; $D92F: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A000                           ; $D932: 00 A0
  LDA result_cursor_y                             ; $D934: AD 0D 04  ; pending-selection flag
  CMP #$FF                              ; $D937: C9 FF
  BEQ @StepMenu                         ; $D939: F0 09     ; none: step the menu
  LDY #$39                              ; $D93B: A0 39     ; bank pair param
  JSR B1F_BankedCallbackTrampoline      ; $D93D: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word $A012                           ; $D940: 12 A0
  CLC                                   ; $D942: 18        ; busy: skip input
  RTS                                   ; $D943: 60
@StepMenu:
  LDA #$2B                              ; $D944: A9 2B
  STA $0010                             ; $D946: 8D 10 00
  LDA #$DA                              ; $D949: A9 DA
  STA $0011                             ; $D94B: 8D 11 00  ; ($0010) = $DA2B entry list
  LDA #$00                              ; $D94E: A9 00
  STA $0012                             ; $D950: 8D 12 00  ; step result
  JSR B1F_MenuStep2                     ; $D953: 20 1E ED
  LDA $0012                             ; $D956: AD 12 00  ; new row index
  CMP result_menu_row                             ; $D959: CD 6C 04
  BNE @CursorMoved                      ; $D95C: D0 02
  SEC                                   ; $D95E: 38        ; stable: poll input
  RTS                                   ; $D95F: 60
@CursorMoved:
  STA result_menu_row                             ; $D960: 8D 6C 04  ; update row cursor
  TAY                                   ; $D963: A8
  LDA BattleResult_RowToRecordMap,Y     ; $D964: B9 07 DA  ; row -> record idx
  ASL                                   ; $D967: 0A
  ASL                                   ; $D968: 0A        ; idx*4
  TAY                                   ; $D969: A8
  LDA BattleResult_RecordInitTable,Y    ; $D96A: B9 0F DA  ; entry id
  STA result_sel_entry                             ; $D96D: 8D 10 04  ; -> selection
  LDA #$00                              ; $D970: A9 00
  STA result_cursor_x                             ; $D972: 8D 0C 04
  STA result_cursor_y                             ; $D975: 8D 0D 04
  CLC                                   ; $D978: 18        ; moving: skip input
  RTS                                   ; $D979: 60
.endproc  ; BattleResultMenuPoll
;-------------------------------------------------------------------------------
; BattleResultEntryInit - entry record block init ($D97A-$DA06)
; Writes the seven 8-byte entry records at $6F07, $6F0F, ... $6F37 from
; BattleResult_RecordInitTable: record byte 0 = entry id ($AD,$08,$83,$8A,
; $DE,$DC,$B6), bytes 1-2 = 0, byte 3 (status, at +3) = 3.
;-------------------------------------------------------------------------------
.proc BattleResultEntryInit
  LDA #$AD                              ; $D97A: A9 AD
  STA faction_records                             ; $D97C: 8D 07 6F
  LDA #$00                              ; $D97F: A9 00
  STA faction_records+1                             ; $D981: 8D 08 6F
  LDA #$00                              ; $D984: A9 00
  STA faction_records+2                             ; $D986: 8D 09 6F
  LDA #$03                              ; $D989: A9 03
  STA faction_rec_status                             ; $D98B: 8D 0A 6F
  LDA #$08                              ; $D98E: A9 08
  STA faction_records+$08                             ; $D990: 8D 0F 6F
  LDA #$00                              ; $D993: A9 00
  STA faction_records+$09                             ; $D995: 8D 10 6F
  LDA #$00                              ; $D998: A9 00
  STA faction_records+$0A                             ; $D99A: 8D 11 6F
  LDA #$03                              ; $D99D: A9 03
  STA faction_records+$0B                             ; $D99F: 8D 12 6F
  LDA #$83                              ; $D9A2: A9 83
  STA faction_records+$10                             ; $D9A4: 8D 17 6F
  LDA #$00                              ; $D9A7: A9 00
  STA faction_records+$11                             ; $D9A9: 8D 18 6F
  LDA #$00                              ; $D9AC: A9 00
  STA faction_records+$12                             ; $D9AE: 8D 19 6F
  LDA #$03                              ; $D9B1: A9 03
  STA faction_records+$13                             ; $D9B3: 8D 1A 6F
  LDA #$8A                              ; $D9B6: A9 8A
  STA faction_records+$18                             ; $D9B8: 8D 1F 6F
  LDA #$00                              ; $D9BB: A9 00
  STA faction_records+$19                             ; $D9BD: 8D 20 6F
  LDA #$00                              ; $D9C0: A9 00
  STA faction_records+$1A                             ; $D9C2: 8D 21 6F
  LDA #$03                              ; $D9C5: A9 03
  STA faction_records+$1B                             ; $D9C7: 8D 22 6F
  LDA #$DE                              ; $D9CA: A9 DE
  STA faction_records+$20                             ; $D9CC: 8D 27 6F
  LDA #$00                              ; $D9CF: A9 00
  STA faction_records+$21                             ; $D9D1: 8D 28 6F
  LDA #$00                              ; $D9D4: A9 00
  STA faction_records+$22                             ; $D9D6: 8D 29 6F
  LDA #$03                              ; $D9D9: A9 03
  STA faction_records+$23                             ; $D9DB: 8D 2A 6F
  LDA #$DC                              ; $D9DE: A9 DC
  STA faction_records+$28                             ; $D9E0: 8D 2F 6F
  LDA #$00                              ; $D9E3: A9 00
  STA faction_records+$29                             ; $D9E5: 8D 30 6F
  LDA #$00                              ; $D9E8: A9 00
  STA faction_records+$2A                             ; $D9EA: 8D 31 6F
  LDA #$03                              ; $D9ED: A9 03
  STA faction_records+$2B                             ; $D9EF: 8D 32 6F
  LDA #$B6                              ; $D9F2: A9 B6
  STA faction_records+$30                             ; $D9F4: 8D 37 6F
  LDA #$00                              ; $D9F7: A9 00
  STA faction_records+$31                             ; $D9F9: 8D 38 6F
  LDA #$00                              ; $D9FC: A9 00
  STA faction_records+$32                             ; $D9FE: 8D 39 6F
  LDA #$03                              ; $DA01: A9 03
  STA faction_records+$33                             ; $DA03: 8D 3A 6F
  RTS                                   ; $DA06: 60
.endproc  ; BattleResultEntryInit
;-------------------------------------------------------------------------------
; Result scene data tables ($DA07-$DA47)
;-------------------------------------------------------------------------------
BattleResult_RowToRecordMap:            ; $DA07: menu row -> record index
  .byte $04,$02,$03,$01,$06,$05,$00,$00 ; $DA07: 04 02 03 01 06 05 00 00
BattleResult_RecordInitTable:           ; $DA0F: 7 x 4-byte entry records
  .byte $AD,$00,$00,$03                 ; $DA0F: entry 0 (id $AD)
  .byte $08,$00,$00,$03                 ; $DA13: entry 1 (id $08)
  .byte $83,$00,$00,$03                 ; $DA17: entry 2 (id $83)
  .byte $8A,$00,$00,$03                 ; $DA1B: entry 3 (id $8A)
  .byte $DE,$00,$00,$03                 ; $DA1F: entry 4 (id $DE)
  .byte $DC,$00,$00,$03                 ; $DA23: entry 5 (id $DC)
  .byte $B6,$00,$00,$03                 ; $DA27: entry 6 (id $B6)
BattleResult_EntryOrderList:            ; $DA2B: entry order + $FF sentinels
  .byte $00,$01,$02,$03,$04,$05,$06,$FF,$FF,$FF ; $DA2B: 00..06, FF FF FF
BattleResult_CursorPosTable:            ; $DA35: cursor (Y,X) base per row
  .byte $24,$10,$24,$80,$44,$10,$44,$80 ; $DA35: rows 0-3
  .byte $64,$10,$64,$80,$84,$10         ; $DA3D: rows 4-6
BattleResult_CursorSpriteLayout:        ; $DA43: single-tile cursor layout
  .byte $00,$07,$00,$00                 ; $DA43: Y=$00 tile=$07 attr=$00 X=$00
  .byte $80                             ; $DA47: terminator
;-------------------------------------------------------------------------------
; BattleResultSceneFrameDraw - result scene frame sprites ($DA48-$DA67)
; Scene tick called from BattleResultDispatch's sub-mode table: draws the
; full scene frame from BattleResult_FrameSpriteLayout through
; B1F_SpriteOamWriterSimple with Y base $000A=$20 and X base $000C=$48.
;-------------------------------------------------------------------------------
.proc BattleResultSceneFrameDraw
  LDA #$68                              ; $DA48: A9 68
  STA $0000                             ; $DA4A: 8D 00 00
  LDA #$DA                              ; $DA4D: A9 DA
  STA $0001                             ; $DA4F: 8D 01 00  ; ($00) = $DA68 layout
  LDA #$00                              ; $DA52: A9 00
  STA $0002                             ; $DA54: 8D 02 00  ; flip flags = 0
  LDA $0003                             ; $DA57: AD 03 00  ; dead read
  LDA #$20                              ; $DA5A: A9 20
  STA $000A                             ; $DA5C: 8D 0A 00  ; OAM Y base
  LDA #$48                              ; $DA5F: A9 48
  STA $000C                             ; $DA61: 8D 0C 00  ; OAM X base
  JSR B1F_SpriteOamWriterSimple         ; $DA64: 20 AD F1
  RTS                                   ; $DA67: 60
.endproc  ; BattleResultSceneFrameDraw
; --- Data Region ---
BattleResult_FrameSpriteLayout:         ; $DA68: 28 OAM records + terminator
  .byte $60,$62,$00,$00                 ; $DA68: Y=$60 tile=$62 attr=$00 X=$00
  .byte $60,$63,$00,$08                 ; $DA6C: Y=$60 tile=$63 attr=$00 X=$08
  .byte $68,$72,$00,$00                 ; $DA70: Y=$68 tile=$72 attr=$00 X=$00
  .byte $68,$73,$00,$08                 ; $DA74: Y=$68 tile=$73 attr=$00 X=$08
  .byte $20,$64,$00,$70                 ; $DA78: Y=$20 tile=$64 attr=$00 X=$70
  .byte $20,$65,$00,$78                 ; $DA7C: Y=$20 tile=$65 attr=$00 X=$78
  .byte $28,$74,$00,$70                 ; $DA80: Y=$28 tile=$74 attr=$00 X=$70
  .byte $28,$75,$00,$78                 ; $DA84: Y=$28 tile=$75 attr=$00 X=$78
  .byte $00,$66,$01,$70                 ; $DA88: Y=$00 tile=$66 attr=$01 X=$70
  .byte $00,$67,$01,$78                 ; $DA8C: Y=$00 tile=$67 attr=$01 X=$78
  .byte $08,$76,$01,$70                 ; $DA90: Y=$08 tile=$76 attr=$01 X=$70
  .byte $08,$77,$01,$78                 ; $DA94: Y=$08 tile=$77 attr=$01 X=$78
  .byte $20,$68,$01,$00                 ; $DA98: Y=$20 tile=$68 attr=$01 X=$00
  .byte $20,$69,$01,$08                 ; $DA9C: Y=$20 tile=$69 attr=$01 X=$08
  .byte $28,$78,$01,$00                 ; $DAA0: Y=$28 tile=$78 attr=$01 X=$00
  .byte $28,$79,$01,$08                 ; $DAA4: Y=$28 tile=$79 attr=$01 X=$08
  .byte $00,$6A,$00,$00                 ; $DAA8: Y=$00 tile=$6A attr=$00 X=$00
  .byte $00,$6B,$00,$08                 ; $DAAC: Y=$00 tile=$6B attr=$00 X=$08
  .byte $08,$7A,$00,$00                 ; $DAB0: Y=$08 tile=$7A attr=$00 X=$00
  .byte $08,$7B,$00,$08                 ; $DAB4: Y=$08 tile=$7B attr=$00 X=$08
  .byte $40,$6C,$00,$70                 ; $DAB8: Y=$40 tile=$6C attr=$00 X=$70
  .byte $40,$6D,$00,$78                 ; $DABC: Y=$40 tile=$6D attr=$00 X=$78
  .byte $48,$7C,$00,$70                 ; $DAC0: Y=$48 tile=$7C attr=$00 X=$70
  .byte $48,$7D,$00,$78                 ; $DAC4: Y=$48 tile=$7D attr=$00 X=$78
  .byte $40,$6E,$00,$00                 ; $DAC8: Y=$40 tile=$6E attr=$00 X=$00
  .byte $40,$6F,$00,$08                 ; $DACC: Y=$40 tile=$6F attr=$00 X=$08
  .byte $48,$7E,$00,$00                 ; $DAD0: Y=$48 tile=$7E attr=$00 X=$00
  .byte $48,$7F,$00,$08                 ; $DAD4: Y=$48 tile=$7F attr=$00 X=$08
  .byte $80                             ; $DAD8: terminator
;-------------------------------------------------------------------------------
; BattleResultCursorSpriteDraw - menu cursor sprite ($DAD9-$DAF8)
; Called every frame from phases 1, 3 and 5 while the scene is ready. If
; $005E bit 4 is set, draws BattleResult_MarkerSpriteLayout at the base
; position (Y/X bases 0) through B1F_SpriteOamWriterSimple.
;-------------------------------------------------------------------------------
.proc BattleResultCursorSpriteDraw
  LDA $005E                             ; $DAD9: AD 5E 00  ; cursor enable flags
  AND #$10                              ; $DADC: 29 10     ; bit 4 = draw cursor
  BEQ @Done                             ; $DADE: F0 18
  LDA #$00                              ; $DAE0: A9 00
  STA $0002                             ; $DAE2: 8D 02 00  ; flip flags = 0
  STA $000C                             ; $DAE5: 8D 0C 00  ; OAM X base = 0
  STA $000A                             ; $DAE8: 8D 0A 00  ; OAM Y base = 0
  LDA #$F9                              ; $DAEB: A9 F9
  STA $0000                             ; $DAED: 8D 00 00
  LDA #$DA                              ; $DAF0: A9 DA
  STA $0001                             ; $DAF2: 8D 01 00  ; ($00) = $DAF9 layout
  JSR B1F_SpriteOamWriterSimple         ; $DAF5: 20 AD F1
@Done:
  RTS                                   ; $DAF8: 60
.endproc  ; BattleResultCursorSpriteDraw
BattleResult_MarkerSpriteLayout:        ; $DAF9: single marker sprite
  .byte $D9,$04,$00,$7C                 ; $DAF9: Y=$D9 tile=$04 attr=$00 X=$7C
  .byte $80                             ; $DAFD: terminator
;-------------------------------------------------------------------------------
; BattleResultReadyCheck - result scene readiness ($DAFE-$DB0F)
; Returns carry set once both scene handshake bytes $0304 and $0300 are no
; longer $FF (scene data loaded); carry clear while still pending.
;-------------------------------------------------------------------------------
.proc BattleResultReadyCheck
  LDA $0304                             ; $DAFE: AD 04 03  ; handshake byte 1
  CMP #$FF                              ; $DB01: C9 FF
  BNE @CheckSecond                      ; $DB03: D0 09
  LDA $0300                             ; $DB05: AD 00 03  ; handshake byte 0
  CMP #$FF                              ; $DB08: C9 FF
  BNE @CheckSecond                      ; $DB0A: D0 02
  SEC                                   ; $DB0C: 38        ; ready
  RTS                                   ; $DB0D: 60
@CheckSecond:
  CLC                                   ; $DB0E: 18        ; not ready
  RTS                                   ; $DB0F: 60
.endproc  ; BattleResultReadyCheck
;-------------------------------------------------------------------------------
; Direction input-repeat handlers ($DB10-$DC49)
; Four near-identical trackers, run every frame by BattleResultDispatch,
; advance hold counters $0545-$0548 while a direction stays held and fire
; sound $62 once (per-group $6FEA latch bit) when a counter reaches the $80
; terminator entry of its hold-mask table:
;   group 0: gated to phase 1, counter $0545, latch bit 0, pad $0083/$0081
;   group 1: gated to phase 3, counter $0546, latch bit 1, pad $0085/$0082
;   group 2: ungated,          counter $0547, latch bit 2, pad $0083/$0081
;   group 3: ungated,          counter $0548, latch bit 3, pad $0083/$0081
;-------------------------------------------------------------------------------
.proc BattleResultDirRepeat0
  LDA result_scene_phase                             ; $DB10: AD 41 05  ; phase index
  CMP #$01                              ; $DB13: C9 01     ; only phase 1
  BNE @Done2                            ; $DB15: D0 39
  LDY result_dir_repeat                             ; $DB17: AC 45 05  ; repeat counter
  LDA @HoldMasks,Y                      ; $DB1A: B9 51 DB
  BPL @CheckHold                        ; $DB1D: 10 15     ; $80 = hold complete
  LDA result_latch_flags                             ; $DB1F: AD EA 6F  ; latch flags
  AND #$01                              ; $DB22: 29 01
  BNE @Done                             ; $DB24: D0 0D     ; already fired
  LDA result_latch_flags                             ; $DB26: AD EA 6F
  ORA #$01                              ; $DB29: 09 01
  STA result_latch_flags                             ; $DB2B: 8D EA 6F
  LDA #$62                              ; $DB2E: A9 62     ; repeat sound
  JSR B1F_SoundWrapperE                 ; $DB30: 20 93 E6
@Done:
  RTS                                   ; $DB33: 60
@CheckHold:
  LDA $0083                             ; $DB34: AD 83 00  ; held directions
  LDY result_dir_repeat                             ; $DB37: AC 45 05
  AND @HoldMasks,Y                      ; $DB3A: 39 51 DB
  BNE @CheckEdge                        ; $DB3D: D0 06
  LDA #$00                              ; $DB3F: A9 00
  STA result_dir_repeat                             ; $DB41: 8D 45 05  ; released: reset
  RTS                                   ; $DB44: 60
@CheckEdge:
  LDA $0081                             ; $DB45: AD 81 00  ; new presses
  AND @EdgeMasks,Y                      ; $DB48: 39 5A DB
  BEQ @Done2                            ; $DB4B: F0 03
  INC result_dir_repeat                             ; $DB4D: EE 45 05  ; advance counter
@Done2:
  RTS                                   ; $DB50: 60
@HoldMasks:
  .byte $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C ; $DB51: hold masks (idx 0-7)
  .byte $80                             ; $DB59: hold-complete terminator
@EdgeMasks:
  .byte $10,$20,$10,$20,$40,$80,$40,$80 ; $DB5A: edge masks (idx 0-7)
.endproc  ; BattleResultDirRepeat0
.proc BattleResultDirRepeat1
  LDA result_scene_phase                             ; $DB62: AD 41 05  ; phase index
  CMP #$03                              ; $DB65: C9 03     ; only phase 3
  BNE @Done2                            ; $DB67: D0 39
  LDY result_dir_repeat+1                             ; $DB69: AC 46 05  ; repeat counter
  LDA @HoldMasks,Y                      ; $DB6C: B9 A3 DB
  BPL @CheckHold                        ; $DB6F: 10 15     ; $80 = hold complete
  LDA result_latch_flags                             ; $DB71: AD EA 6F  ; latch flags
  AND #$02                              ; $DB74: 29 02
  BNE @Done                             ; $DB76: D0 0D     ; already fired
  LDA result_latch_flags                             ; $DB78: AD EA 6F
  ORA #$02                              ; $DB7B: 09 02
  STA result_latch_flags                             ; $DB7D: 8D EA 6F
  LDA #$62                              ; $DB80: A9 62     ; repeat sound
  JSR B1F_SoundWrapperE                 ; $DB82: 20 93 E6
@Done:
  RTS                                   ; $DB85: 60
@CheckHold:
  LDA $0085                             ; $DB86: AD 85 00  ; held directions
  LDY result_dir_repeat+1                             ; $DB89: AC 46 05
  AND @HoldMasks,Y                      ; $DB8C: 39 A3 DB
  BNE @CheckEdge                        ; $DB8F: D0 06
  LDA #$00                              ; $DB91: A9 00
  STA result_dir_repeat+1                             ; $DB93: 8D 46 05  ; released: reset
  RTS                                   ; $DB96: 60
@CheckEdge:
  LDA $0082                             ; $DB97: AD 82 00  ; new presses
  AND @EdgeMasks,Y                      ; $DB9A: 39 AC DB
  BEQ @Done2                            ; $DB9D: F0 03
  INC result_dir_repeat+1                             ; $DB9F: EE 46 05  ; advance counter
@Done2:
  RTS                                   ; $DBA2: 60
@HoldMasks:
  .byte $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C ; $DBA3: hold masks (idx 0-7)
  .byte $80                             ; $DBAB: hold-complete terminator
@EdgeMasks:
  .byte $10,$40,$20,$80,$40,$10,$80,$20 ; $DBAC: edge masks (idx 0-7)
.endproc  ; BattleResultDirRepeat1
.proc BattleResultDirRepeat2
  LDY result_dir_repeat+2                             ; $DBB4: AC 47 05  ; repeat counter
  LDA @HoldMasks,Y                      ; $DBB7: B9 EE DB
  BPL @CheckHold                        ; $DBBA: 10 15     ; $80 = hold complete
  LDA result_latch_flags                             ; $DBBC: AD EA 6F  ; latch flags
  AND #$04                              ; $DBBF: 29 04
  BNE @Done                             ; $DBC1: D0 0D     ; already fired
  LDA result_latch_flags                             ; $DBC3: AD EA 6F
  ORA #$04                              ; $DBC6: 09 04
  STA result_latch_flags                             ; $DBC8: 8D EA 6F
  LDA #$62                              ; $DBCB: A9 62     ; repeat sound
  JSR B1F_SoundWrapperE                 ; $DBCD: 20 93 E6
@Done:
  RTS                                   ; $DBD0: 60
@CheckHold:
  LDA $0083                             ; $DBD1: AD 83 00  ; held directions
  LDY result_dir_repeat+2                             ; $DBD4: AC 47 05
  AND @HoldMasks,Y                      ; $DBD7: 39 EE DB
  BNE @CheckEdge                        ; $DBDA: D0 06
  LDA #$00                              ; $DBDC: A9 00
  STA result_dir_repeat+2                             ; $DBDE: 8D 47 05  ; released: reset
  RTS                                   ; $DBE1: 60
@CheckEdge:
  LDA $0081                             ; $DBE2: AD 81 00  ; new presses
  AND @EdgeMasks,Y                      ; $DBE5: 39 F7 DB
  BEQ @Done2                            ; $DBE8: F0 03
  INC result_dir_repeat+2                             ; $DBEA: EE 47 05  ; advance counter
@Done2:
  RTS                                   ; $DBED: 60
@HoldMasks:
  .byte $04,$04,$04,$04,$04,$04,$04,$04 ; $DBEE: hold masks (idx 0-7)
  .byte $80                             ; $DBF6: hold-complete terminator
@EdgeMasks:
  .byte $80,$80,$20,$20,$10,$20,$10,$20 ; $DBF7: edge masks (idx 0-7)
.endproc  ; BattleResultDirRepeat2
.proc BattleResultDirRepeat3
  LDY result_dir_repeat+3                             ; $DBFF: AC 48 05  ; repeat counter
  LDA @HoldMasks,Y                      ; $DC02: B9 39 DC
  BPL @CheckHold                        ; $DC05: 10 15     ; $80 = hold complete
  LDA result_latch_flags                             ; $DC07: AD EA 6F  ; latch flags
  AND #$08                              ; $DC0A: 29 08
  BNE @Done                             ; $DC0C: D0 0D     ; already fired
  LDA result_latch_flags                             ; $DC0E: AD EA 6F
  ORA #$08                              ; $DC11: 09 08
  STA result_latch_flags                             ; $DC13: 8D EA 6F
  LDA #$62                              ; $DC16: A9 62     ; repeat sound
  JSR B1F_SoundWrapperE                 ; $DC18: 20 93 E6
@Done:
  RTS                                   ; $DC1B: 60
@CheckHold:
  LDA $0083                             ; $DC1C: AD 83 00  ; held directions
  LDY result_dir_repeat+3                             ; $DC1F: AC 48 05
  AND @HoldMasks,Y                      ; $DC22: 39 39 DC
  BNE @CheckEdge                        ; $DC25: D0 06
  LDA #$00                              ; $DC27: A9 00
  STA result_dir_repeat+3                             ; $DC29: 8D 48 05  ; released: reset
  RTS                                   ; $DC2C: 60
@CheckEdge:
  LDA $0081                             ; $DC2D: AD 81 00  ; new presses
  AND @EdgeMasks,Y                      ; $DC30: 39 42 DC
  BEQ @Done2                            ; $DC33: F0 03
  INC result_dir_repeat+3                             ; $DC35: EE 48 05  ; advance counter
@Done2:
  RTS                                   ; $DC38: 60
@HoldMasks:
  .byte $08,$08,$08,$08,$08,$08,$08,$08 ; $DC39: hold masks (idx 0-7)
  .byte $80                             ; $DC41: hold-complete terminator
@EdgeMasks:
  .byte $10,$80,$20,$40,$10,$40,$20,$80 ; $DC42: edge masks (idx 0-7)
.endproc  ; BattleResultDirRepeat3
;-------------------------------------------------------------------------------
; BattleResultSlotReset - post-result slot record refresh ($DC4A-$DC9B)
; Reached from BattleResult_Finalize (JMP $DC4A). Scans the seven ruler/slot
; records via B1F_GetRulerDataPtr (slot index in A, record to ($00)) and
; applies BattleResultSlotTemplateApply to the first slot whose record byte 3
; matches the outcome class selected by the $6FEA latch bits:
;   bit 0 set: byte 3 == 0 -> apply template, then fall through to bit 1
;   bit 1 set: byte 3 == 1 -> apply template and return
;-------------------------------------------------------------------------------
.proc BattleResultSlotReset
  LDA result_latch_flags                             ; $DC4A: AD EA 6F  ; latch/outcome bits
  AND #$01                              ; $DC4D: 29 01
  BEQ @CheckSecondBit                   ; $DC4F: F0 23
  LDA #$00                              ; $DC51: A9 00
  STA $0002                             ; $DC53: 8D 02 00  ; slot index = 0
@ScanClass0:
  JSR B1F_GetRulerDataPtr               ; $DC56: 20 68 F3  ; ($00) = slot record
  LDY #$03                              ; $DC59: A0 03
  LDA ($00),Y                           ; $DC5B: B1 00     ; record byte 3
  CMP #$00                              ; $DC5D: C9 00     ; class 0
  BNE @NextClass0                       ; $DC5F: D0 09
  LDA $0002                             ; $DC61: AD 02 00  ; slot index
  JSR BattleResultSlotTemplateApply     ; $DC64: 20 9C DC
  JMP @CheckSecondBit                   ; $DC67: 4C 74 DC
@NextClass0:
  INC $0002                             ; $DC6A: EE 02 00
  LDA $0002                             ; $DC6D: AD 02 00
  CMP #$07                              ; $DC70: C9 07     ; 7 slots
  BCC @ScanClass0                       ; $DC72: 90 E2
@CheckSecondBit:
  LDA result_latch_flags                             ; $DC74: AD EA 6F
  AND #$02                              ; $DC77: 29 02
  BEQ @Exit                             ; $DC79: F0 20
  LDA #$00                              ; $DC7B: A9 00
  STA $0002                             ; $DC7D: 8D 02 00  ; slot index = 0
@ScanClass1:
  JSR B1F_GetRulerDataPtr               ; $DC80: 20 68 F3  ; ($00) = slot record
  LDY #$03                              ; $DC83: A0 03
  LDA ($00),Y                           ; $DC85: B1 00     ; record byte 3
  CMP #$01                              ; $DC87: C9 01     ; class 1
  BNE @NextClass1                       ; $DC89: D0 06
  LDA $0002                             ; $DC8B: AD 02 00  ; slot index
  JMP BattleResultSlotTemplateApply     ; $DC8E: 4C 9C DC  ; apply + return
@NextClass1:
  INC $0002                             ; $DC91: EE 02 00
  LDA $0002                             ; $DC94: AD 02 00
  CMP #$07                              ; $DC97: C9 07     ; 7 slots
  BCC @ScanClass1                       ; $DC99: 90 E5
@Exit:
  RTS                                   ; $DC9B: 60
.endproc  ; BattleResultSlotReset
;-------------------------------------------------------------------------------
; BattleResultSlotTemplateApply - reset one slot record ($DC9C-$DCD3)
; A = slot index. Loads the slot's record pointer from
; BattleResult_SlotRecordPtrs into ($00) and copies 15 bytes of
; BattleResult_SlotRecordTemplate into record offsets 2-$10 (the loop indexes
; the template from $DCC3 with Y = 2..$10).
;-------------------------------------------------------------------------------
.proc BattleResultSlotTemplateApply
  ASL                                   ; $DC9C: 0A        ; slot * 2
  TAY                                   ; $DC9D: A8
  LDA BattleResult_SlotRecordPtrs,Y     ; $DC9E: B9 B7 DC  ; ptr low
  STA $0000                             ; $DCA1: 8D 00 00
  LDA BattleResult_SlotRecordPtrs+1,Y   ; $DCA4: B9 B8 DC  ; ptr high
  STA $0001                             ; $DCA7: 8D 01 00
  LDY #$02                              ; $DCAA: A0 02     ; first record offset
@CopyLoop:
  LDA BattleResult_SlotRecordTemplate-2,Y ; $DCAC: B9 C3 DC ; Y spans 2-$10
  STA ($00),Y                           ; $DCAF: 91 00
  INY                                   ; $DCB1: C8
  CPY #$11                              ; $DCB2: C0 11     ; past offset $10
  BCC @CopyLoop                         ; $DCB4: 90 F6
  RTS                                   ; $DCB6: 60
; --- Data Region ---
BattleResult_SlotRecordPtrs:            ; $DCB7: slot -> record pointer
  .word $6180                           ; $DCB7: slot 0
  .word $6080                           ; $DCB9: slot 1
  .word $6160                           ; $DCBB: slot 2
  .word $6280                           ; $DCBD: slot 3
  .word $6040                           ; $DCBF: slot 4
  .word $6340                           ; $DCC1: slot 5
  .word $60C0                           ; $DCC3: slot 6
BattleResult_SlotRecordTemplate:        ; $DCC5: values for offsets 2-$10
  .byte $0F,$27,$0F,$27,$0F,$27,$0F,$27 ; $DCC5: 0F 27 0F 27 0F 27 0F 27
  .byte $63,$63,$0F,$27,$E7,$03,$63     ; $DCCD: 63 63 0F 27 E7 03 63
.endproc  ; BattleResultSlotTemplateApply
;-------------------------------------------------------------------------------
; Padding ($DCD4-$DFFF) - unused bank 09 region, $FF fill
;-------------------------------------------------------------------------------
  .res $032C, $FF                       ; $DCD4: FF fill to end of bank ($DFFF)
